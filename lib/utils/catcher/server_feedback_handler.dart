/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:archive/archive_io.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:catcher_2/model/platform_type.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;
import 'package:pool/pool.dart';
import 'package:screenshot/screenshot.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/home/subpage/feedback_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/widgets/widgets.dart';
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
  final Map<String, Uint8List> extraAttachments;
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
    this.extraAttachments = const {},
    this.sendHtml = true,
    this.printLogs = false,
  });

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    Uint8List? screenshotBytes = await _captureScreenshot();
    Map<String, Uint8List> generatedAttachments = onGenerateAttachments == null ? {} : onGenerateAttachments!();

    return _pool.withResource<bool>(
        () => _sendMail(report, screenshotBytes: screenshotBytes, generatedAttachments: generatedAttachments));
  }

  /// store html message that has already be sent
  final HashSet<String> _sentReports = HashSet();

  Future<bool> _sendMail(
    Report report, {
    Uint8List? screenshotBytes,
    Map<String, Uint8List> generatedAttachments = const {},
  }) async {
    if (network.unavailable) throw S.current.error_no_internet;

    if (await _isBlockedError(report)) throw 'Blocked Error';

    // don't send email repeatedly
    if (_sentReports.contains(report.shownError)) {
      logger.fine('"${report.error}" has been sent before');
      return true;
    }

    if (_sentReports.length > _maxEmailCount) {
      logger.warning('Already reach maximum limit($_maxEmailCount) of sent email, skip');
      return false;
    }

    // wait a moment to let other handlers finish, e.g. FileHandler
    await Future.delayed(const Duration(milliseconds: 300));
    Map<String, Uint8List> resolvedAttachments = {};

    Archive archive = Archive();

    for (final fn in attachments) {
      if (FilePlus(fn).existsSync()) {
        final bytes = await FilePlus(fn).readAsBytes();
        archive.addFile(ArchiveFile(p.basename(fn), bytes.length, bytes));
      }
    }
    for (final entry in generatedAttachments.entries) {
      archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
    }
    List<int>? zippedBytes;
    if (archive.isNotEmpty) {
      zippedBytes = ZipEncoder().encode(archive);
      if (zippedBytes != null) {
        resolvedAttachments['attachment.zip'] = Uint8List.fromList(zippedBytes);
      }
    }

    if (screenshotBytes != null) {
      resolvedAttachments['_screenshot.jpg'] = screenshotBytes;
    }
    resolvedAttachments.addAll(extraAttachments);

    if (kDebugMode) {
      print('skip sending mail in debug mode');
      return true;
    }
    final response = await ChaldeaWorkerApi.sendFeedback(
      subject: _getEmailTitle(report),
      senderName: senderName ?? 'Chaldea ${AppInfo.versionString} Crash',
      html: sendHtml ? await _setupHtmlMessageText(report) : null,
      files: resolvedAttachments,
    );
    final success = response != null && response.error == null;
    if (!success) {
      logger_.logger.e('failed to send mail', response?.fullMessage);
    }
    if (report is! FeedbackReport) {
      _sentReports.add(report.shownError);
    }
    return success;
  }

  /// List temporary blocked error on gitee wiki
  ///
  /// Fetch from https://gitee.com/chaldea-center/chaldea/wikis/blocked_error?sort_id=4200566
  List<String>? _blockedErrors;

  Future<bool> _isBlockedError(Report report) async {
    if (report is FeedbackReport) return false;
    if (report.error is DioException) return true;
    final error = report.shownError;
    final stackTrace = report.stackTrace.toString();
    final errorAndStackTrace = '$error\n$stackTrace';
    if (kIsWeb) {
      if ([
        'TypeError: Failed to fetch',
        'Bad state: Future already completed',
        'Bad state: A RenderObject does not have any constraints before it has been laid out.',
        "NoSuchMethodError: method not found: 'toString' on null",
        "TypeError: Cannot read propert",
        "Null check operator",
        "Bad state: Too many elements",
        "Bad state: No element",
        // "TypeError: Cannot read property 'toString' of null",
        // "TypeError: Cannot read properties of undefined",
        // "TypeError: Cannot read properties of null",
      ].any(errorAndStackTrace.contains)) {
        return true;
      }
      if (report.shownError.contains('Stack Overflow') &&
          report.stackTrace.toString().contains('tear_off.<anonymous>')) {
        return true;
      }
      if (RegExp(r"NoSuchMethodError: method not found: '.+?' on null").hasMatch(errorAndStackTrace)) {
        return true;
      }
    }
    if (!kIsWeb) {
      if (report.stackTrace != null && !report.stackTrace.toString().contains('chaldea')) {
        return true;
      }
    }
    if (_blockedErrors == null) {
      _blockedErrors = (await CachedApi.remoteConfig())?.blockedErrors ?? [];
      _blockedErrors?.removeWhere((e) => e.isEmpty);
      // logger_.logger.d('_blockedErrors=${jsonEncode(_blockedErrors)}');
    }

    bool? shouldIgnore = _blockedErrors?.any((e) => error.contains(e) || stackTrace.contains(e));
    if (shouldIgnore == true) {
      // logger_.logger.e('don\'t send blocked error', report.error, report.stackTrace);
      return true;
    }
    return false;
  }

  Future<Uint8List?> _captureScreenshot() async {
    if (kIsWeb && !kPlatformMethods.rendererCanvasKit) return null;
    try {
      Uint8List? shotBinary = await screenshotController?.capture(
        pixelRatio: 1,
        delay: const Duration(milliseconds: 200),
      );
      if (shotBinary == null) return null;
      final img = decodePng(shotBinary);
      if (img == null) return null;
      final bytes = Uint8List.fromList(encodeJpg(img, quality: 60));
      if (!kIsWeb && screenshotPath != null) {
        try {
          await FilePlus(screenshotPath!).writeAsBytes(bytes);
        } catch (e, s) {
          logger_.logger.e('save crash screenshot failed', e, s);
        }
      }
      return bytes;
    } catch (e, s) {
      logger_.logger.e('screenshot failed', e, s);
      return null;
    }
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

    String escapeCode(String s) {
      return '<pre>${escape(s)}</pre>';
    }

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
      buffer.write(escape(report.body).replaceAll('\n', '<br/>'));
      buffer.write('<br/><br/>');
    }

    buffer.write("<h3>Summary:</h3>");
    Map<String, dynamic> summary = {
      'app': '${AppInfo.appName} v${AppInfo.fullVersion2} ${AppInfo.commitHash}-${AppInfo.commitDate}',
      'dataset': db.gameData.version.utc,
      'os': '${PlatformU.operatingSystem} ${PlatformU.operatingSystemVersion}',
      'lang': Language.current.code,
      'locale': Language.systemLocale.toString(),
      'uuid': AppInfo.uuid,
      'user': db.settings.secrets.user?.name ?? "",
      if (kIsWeb) 'renderer': kPlatformMethods.rendererCanvasKit ? 'canvaskit' : 'html',
    };
    for (var entry in summary.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write('<hr>');

    if (report is! FeedbackReport) {
      buffer.write("<h3>Error:</h3>");
      buffer.write(escapeCode(report.error.toString()));
      if (report.error.toString().trim().isEmpty && report.errorDetails != null) {
        buffer.write(escapeCode(report.errorDetails!.exceptionAsString()));
      }
      final error = (report.error ?? report.errorDetails?.exception).toString();
      if (kIsWeb && error.contains('Unsupported operation: NaN.floor()')) {
        final context = kAppKey.currentContext;
        final nav = context == null ? null : Navigator.maybeOf(context);
        if (context != null && nav != null) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return SimpleCancelOkDialog(
                title: const Text('Help'),
                content: Text('Error: $error\n'
                    'I have trouble to figure out the just happened bug.\n'
                    'Would you like to share details? such as which page, screenshots,'
                    ' operations in recent seconds, browser Console output(F12)...\n'
                    'Looking forward to your response.'),
                confirmText: S.current.about_feedback,
                onTapCancel: () {
                  buffer.write('<br>canceled<br>');
                },
                onTapOk: () {
                  buffer.write('<br>feedback<br>');
                  router.pushPage(FeedbackPage());
                },
              );
            },
          );
        } else {
          buffer.write('<br>navigator not found<br>');
        }
        kPlatformMethods.setLocalStorage('flutterWebRenderer', 'canvaskit');
        buffer.write('<br>Set canvaskit renderer!<br>');
      }
      buffer.write("<hr>");

      if (enableStackTrace) {
        buffer.write("<h3>Stack trace:</h3>");
        final lines = report.stackTrace.toString().split('\n');
        lines.removeWhere((e) => e == '<asynchronous suspension>');
        buffer.write(escapeCode(lines.join('\n')));

        if (report.stackTrace?.toString().trim().isNotEmpty != true && report.errorDetails != null) {
          buffer.write(escapeCode(report.errorDetails!.stack.toString()));
        }
        buffer.write("<hr>");
      }
    }

    buffer.write("<h3>Pages</h3>");
    for (final page in router.pages.reversed.take(5)) {
      buffer.write(escape(page.toString()));
      buffer.write("<br>");
    }
    buffer.write("<hr>");

    if (enableDeviceParameters) {
      buffer.write("<h3>Device parameters:</h3>");
      for (var entry in report.deviceParameters.entries) {
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }
    if (enableApplicationParameters) {
      buffer.write("<h3>Application parameters:</h3>");
      for (var entry in report.applicationParameters.entries) {
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
      }
      buffer.write("<hr>");
    }

    if (enableCustomParameters && report.customParameters.isNotEmpty) {
      buffer.write("<h3>Custom parameters:</h3>");
      for (var entry in report.customParameters.entries) {
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
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
      : super(null, '', DateTime.now(), AppInfo.deviceParams, AppInfo.appParams, {}, null, PlatformType.unknown, null);
}

extension _ReportX on Report {
  String get shownError => (error ?? errorDetails?.exception).toString();
}
