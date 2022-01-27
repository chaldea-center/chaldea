/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:chaldea/app/api/api.dart';
import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:intl/intl_standalone.dart';
import 'package:path/path.dart' as p;
import 'package:pool/pool.dart';
import 'package:screenshot/screenshot.dart';

import '../../components/config.dart' show db;
import '../../components/git_tool.dart';
import '../../models/db.dart';
import '../../packages/app_info.dart';
import '../../packages/language.dart';
import '../../packages/logger.dart' as logger_;
import '../../packages/platform/platform.dart';
import '../constants.dart';

class ServerFeedbackHandler extends ReportHandler {
  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values;

  // send email one-by-one
  final Pool _pool = Pool(1);

  // limit the maximum emails, for some framework error, they will keep raising
  // similar errors with different stacktrace. It's disastrous.
  final int _maxEmailCount = 10;

  final bool enableDeviceParameters;
  final bool enableApplicationParameters;
  final bool enableStackTrace;
  final bool enableCustomParameters;

  final String? senderName;
  final String? emailTitle;
  final String? emailHeader;

  final ScreenshotController? screenshotController;
  final String? screenshotPath;
  final List<String> attachments;
  final Map<String, Uint8List> Function()? onGenerateAttachments;
  final bool sendHtml;
  final bool printLogs;

  ServerFeedbackHandler({
    this.enableDeviceParameters = true,
    this.enableApplicationParameters = true,
    this.enableStackTrace = true,
    this.enableCustomParameters = true,
    this.senderName,
    this.emailTitle,
    this.emailHeader,
    this.screenshotController,
    this.screenshotPath,
    this.attachments = const [],
    this.onGenerateAttachments,
    this.sendHtml = true,
    this.printLogs = false,
  });

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    Uint8List? screenshotBytes = await _captureScreenshot();
    Map<String, Uint8List> generatedAttachments =
        onGenerateAttachments == null ? {} : onGenerateAttachments!();

    return _pool.withResource<bool>(() => _sendMail(report,
        screenshotBytes: screenshotBytes,
        generatedAttachments: generatedAttachments));
  }

  /// store html message that has already be sent
  final HashSet<String> _sentReports = HashSet();

  /// the same error may have different StackTrace
  String _getReportShortSummary(Report report) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(report.error.toString());
    final lines = report.stackTrace.toString().split('\n');
    int index =
        lines.lastIndexWhere((line) => line.contains('package:chaldea'));
    if (lines.isNotEmpty) {
      buffer.writeAll(lines.take(index < 0 ? 3 : min(index + 1, 20)), '\n');
    }
    return buffer.toString();
  }

  Future<bool> _sendMail(
    Report report, {
    Uint8List? screenshotBytes,
    Map<String, Uint8List> generatedAttachments = const {},
  }) async {
    if (network.unavailable) return false;

    try {
      if (await _isBlockedError(report)) return false;

      String reportSummary = _getReportShortSummary(report);
      // don't send email repeatedly
      if (_sentReports.contains(reportSummary)) {
        logger.fine('"${report.error}" has been sent before');
        return true;
      }

      if (_sentReports.length > _maxEmailCount) {
        logger.warning(
            'Already reach maximum limit($_maxEmailCount) of sent email, skip');
        return false;
      }

      // wait a moment to let other handlers finish, e.g. FileHandler
      await Future.delayed(const Duration(seconds: 1));
      Map<String, Uint8List> resolvedAttachments = {};

      Archive archive = Archive();

      for (final fn in attachments) {
        if (FilePlus(fn).existsSync()) {
          final bytes = await FilePlus(fn).readAsBytes();
          archive.addFile(ArchiveFile(p.basename(fn), bytes.length, bytes));
        }
      }
      for (final entry in generatedAttachments.entries) {
        archive
            .addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
      }
      List<int>? zippedBytes;
      if (archive.isNotEmpty) {
        zippedBytes = ZipEncoder().encode(archive);
        if (zippedBytes != null) {
          resolvedAttachments['attachment.zip'] =
              Uint8List.fromList(zippedBytes);
        }
      }

      if (screenshotBytes != null) {
        resolvedAttachments['screenshot.jpg'] = screenshotBytes;
      }

      final response = await ChaldeaApi.sendFeedback(
        subject: _getEmailTitle(report),
        senderName: senderName ?? 'Chaldea ${AppInfo.versionString} Crash',
        html: sendHtml ? await _setupHtmlMessageText(report) : null,
        files: resolvedAttachments,
      );
      return response.success;
    } catch (e, s) {
      logger_.logger.e('failed to send mail', e, s);
      return false;
    }
  }

  /// List temporary blocked error on gitee wiki
  ///
  /// Fetch from https://gitee.com/chaldea-center/chaldea/wikis/blocked_error?sort_id=4200566
  List<String>? _blockedErrors;

  Future<bool> _isBlockedError(Report report) async {
    if (_blockedErrors == null) {
      final String content = await GitTool.giteeWikiPage('blocked_error');
      _blockedErrors = [];
      content.trim().split('\n\n').forEach((line) {
        line = line.trim().replaceAll('\r', '');
        if (line.isNotEmpty) _blockedErrors!.add(line);
      });
      // logger_.logger.d('_blockedErrors=${jsonEncode(_blockedErrors)}');
    }

    final error = (report.error ?? report.errorDetails).toString();
    final stackTrace = report.stackTrace.toString();
    bool? shouldIgnore =
        _blockedErrors?.any((e) => error.contains(e) || stackTrace.contains(e));
    if (shouldIgnore == true) {
      // logger_.logger.e('don\'t send blocked error', report.error, report.stackTrace);
      return true;
    }
    return false;
  }

  Future<Uint8List?> _captureScreenshot() async {
    Uint8List? shotBinary = await screenshotController?.capture(
      pixelRatio:
          MediaQuery.of(kAppKey.currentContext!).devicePixelRatio * 0.75,
      delay: const Duration(milliseconds: 500),
    );
    if (shotBinary == null) return null;
    final img = decodePng(shotBinary);
    if (img == null) return null;
    final bytes = Uint8List.fromList(encodeJpg(img, quality: 60));
    if (!kIsWeb && screenshotPath != null) {
      FilePlus(screenshotPath!).writeAsBytes(bytes);
    }
    return bytes;
  }

  String? _getEmailTitle(Report report) {
    if (emailTitle?.isNotEmpty == true) {
      return emailTitle;
    } else {
      return "Error: ${report.error}";
    }
  }

  Future<String> _setupHtmlMessageText(Report report) async {
    final escape = const HtmlEscape().convert;
    StringBuffer buffer = StringBuffer("");
    buffer.write('<style>h3{margin:0.2em 0;}</style>');
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(emailHeader!);
      buffer.write("<hr>");
    }
    if (report is FeedbackReport) {
      if (report.contactInfo?.isNotEmpty == true) {
        buffer.write("<h3>Contact:</h3>");
        buffer.write(escape(report.contactInfo ?? ''));
        buffer.write('<br/>');
      }

      buffer.write('<h3>Body</h3>');
      buffer.write(escape(report.body));
      buffer.write('<br/><br/>');
    }

    buffer.write("<h3>Summary:</h3>");
    Map<String, dynamic> summary = {
      'app': '${AppInfo.appName} v${AppInfo.fullVersion2}',
      'dataset': '${db.gameData.version} / ${db2.gameData.version.utc}',
      'os': '${PlatformU.operatingSystem} ${PlatformU.operatingSystemVersion}',
      'lang': Language.current.code,
      'locale': await findSystemLocale(),
      'uuid': AppInfo.uuid,
    };
    for (var entry in summary.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write('<hr>');

    if (report is! FeedbackReport) {
      buffer.write("<h3>Error:</h3>");
      buffer.write(escape(report.error.toString()));
      if (report.error.toString().trim().isEmpty &&
          report.errorDetails != null) {
        buffer.write(escape(report.errorDetails!.exceptionAsString()));
      }
      buffer.write("<hr>");

      if (enableStackTrace) {
        buffer.write("<h3>Stack trace:</h3>");
        buffer.write(
            escape(report.stackTrace.toString()).replaceAll("\n", "<br>"));
        if (report.stackTrace?.toString().trim().isNotEmpty != true &&
            report.errorDetails != null) {
          buffer.write(escape(report.errorDetails!.stack.toString())
              .replaceAll('\n', '<br>'));
        }
        buffer.write("<hr>");
      }
    }

    if (enableDeviceParameters) {
      buffer.write("<h3>Device parameters:</h3>");
      for (var entry in report.deviceParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }
    if (enableApplicationParameters) {
      buffer.write("<h3>Application parameters:</h3>");
      for (var entry in report.applicationParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }

    if (enableCustomParameters) {
      buffer.write("<h3>Custom parameters:</h3>");
      for (var entry in report.customParameters.entries) {
        buffer.write(
            "<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }

    return buffer.toString();
  }
}

class FeedbackReport extends Report {
  final String? contactInfo;
  final String body;

  FeedbackReport(this.contactInfo, this.body)
      : super(null, '', DateTime.now(), AppInfo.deviceParams, AppInfo.appParams,
            {}, null, PlatformType.unknown, null);
}
