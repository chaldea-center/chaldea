/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/src/entities/attachment.dart'; // ignore: implementation_imports
import 'package:path/path.dart' as p;

import 'config.dart';
import 'constants.dart';
import 'device_app_info.dart';
import 'logger.dart';
import 'utils.dart';

export 'page_report_mode_cross.dart';

String get dumpsFp => p.join(db.paths.logDir, 'dumps.log');

class SilentReportFilterMode extends ReportMode {
  HashSet<String> _caughtErrors = HashSet();

  @override
  void requestAction(Report report, BuildContext? context) {
    // no action needed, request is automatically accepted
    String s = '';
    s += report.error.toString();
    s += report.errorDetails.toString();
    s += report.stackTrace.toString();
    if (!ignoreKnownError(report, s) && !_caughtErrors.contains(s)) {
      // dumpWidgetTree(s);
      super.onActionConfirmed(report);
      _caughtErrors.add(s);
    } else {
      logger.w('ignore duplicated error', report.error ?? report.errorDetails,
          report.stackTrace);
      super.onActionRejected(report);
    }
  }

  bool ignoreKnownError(Report report, String s) {
    // TextField changes too fast
    // https://github.com/flutter/flutter/issues/80226
    if (s.contains('''
#0      _StringBase.substring (dart:core-patch/string_patch.dart:399)
#1      TextRange.textBefore (dart:ui/text.dart:2750)
#2      RenderEditable.delete (package:flutter/src/rendering/editable.dart:1119)
#3      _DeleteTextAction.invoke (package:flutter/src/widgets/default_text_editing_actions.dart:88)
#4      ActionDispatcher.invokeAction (package:flutter/src/widgets/actions.dart:517)''')) {
      return true;
    }
    return false;
  }

  // not work in release mode
  void dumpWidgetTree(String msg) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Logging Time: ${DateTime.now().toIso8601String()}');
    buffer.writeln(msg);
    buffer.writeln('\n=============== Start dump widget tree ==============\n');
    buffer.write(WidgetsBinding.instance?.renderViewElement?.toStringDeep() ??
        '<no tree currently mounted>');
    buffer.writeln('\n=============== widget tree dumped ==================');
    File(dumpsFp)
      ..createSync(recursive: true)
      ..writeAsStringSync(buffer.toString(), flush: true);
    logger.d('dump widget tree info to file');
  }

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();
}

class EmailAutoHandlerCross extends EmailAutoHandler {
  final Logger _logger = Logger("EmailAutoHandler");
  final List<File> attachments;
  final bool screenshot;

  EmailAutoHandlerCross(String smtpHost, int smtpPort, String senderEmail,
      String senderName, String senderPassword, List<String> recipients,
      {this.screenshot = false,
      bool enableSsl = false,
      bool enableDeviceParameters = true,
      bool enableApplicationParameters = true,
      bool enableStackTrace = true,
      bool enableCustomParameters = true,
      String? emailTitle,
      String? emailHeader,
      this.attachments = const [],
      bool sendHtml = true,
      bool printLogs = false})
      : super(smtpHost, smtpPort, senderEmail, senderName, senderPassword,
            recipients,
            enableSsl: enableSsl,
            enableDeviceParameters: enableDeviceParameters,
            enableApplicationParameters: enableApplicationParameters,
            enableStackTrace: enableStackTrace,
            enableCustomParameters: enableCustomParameters,
            emailTitle: emailTitle,
            emailHeader: emailHeader,
            sendHtml: sendHtml,
            printLogs: printLogs);

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();

  @override
  Future<bool> handle(Report error, BuildContext? context) async {
    return _sendMail(error);
  }

  /// store html message, this should have the same effect with
  /// [SilentReportFilterMode._caughtErrors]
  HashSet<String> _sentReports = HashSet();

  String? get contactInfo => db.prefs.contactInfo.get();

  Future<bool> _sendMail(Report report) async {
    try {
      String htmlMsg = _setupHtmlMessageText(report);
      // don't send email repeatedly
      if (_sentReports.contains(htmlMsg)) return true;

      final message = new Message()
        ..from = new Address(this.senderEmail, this.senderName)
        ..recipients.addAll(recipients)
        ..subject = _getEmailTitle(report)
        ..text = _setupRawMessageText(report)
        ..attachments = _archiveAttachments([...attachments, File(dumpsFp)]);
      if (screenshot) {
        final shot = await _captureScreenshot();
        if (shot != null) {
          message.attachments.add(shot);
        }
      }
      if (sendHtml) {
        message.html = htmlMsg;
      }
      _printLog("Sending email...");
      if (kDebugMode) return true;

      _sentReports.add(htmlMsg);
      // wait a moment to let other handlers finish, e.g. FileHandler
      await Future.delayed(Duration(seconds: 3));
      var result = await send(message, _setupSmtpServer());
      _printLog("Email result: mail: ${result.mail} "
          "sending start time: ${result.messageSendingStart} "
          "sending end time: ${result.messageSendingEnd}");
      return true;
    } catch (stacktrace, exception) {
      _printLog(stacktrace.toString());
      _printLog(exception.toString());
      return false;
    } finally {
      // var f = File(archiveTmpFp);
      // if (f.existsSync()) f.deleteSync();
    }
  }

  String get archiveTmpFp => '${db.paths.tempDir}/.tmp_attach.zip';

  List<Attachment> _archiveAttachments(List<File> files) {
    files = files.where((f) => f.existsSync()).toList();
    if (files.isEmpty) return [];

    var encoder = ZipFileEncoder();
    encoder.create(archiveTmpFp);
    for (File file in files) {
      encoder.addFile(file);
    }
    encoder.close();
    return [FileAttachment(File(archiveTmpFp), fileName: 'attachment.zip')];
  }

  Future<Attachment?> _captureScreenshot() async {
    String shotFn = p.join(db.paths.appPath, 'crash.jpg');
    Uint8List? shotBinary = await db.runtimeData.screenshotController?.capture(
      pixelRatio:
          MediaQuery.of(kAppKey.currentContext!).devicePixelRatio * 0.75,
      delay: Duration(milliseconds: 500),
    );
    if (shotBinary == null) return null;
    final img = decodePng(shotBinary);
    if (img == null) return null;
    final f = File(shotFn);
    await f.writeAsBytes(encodeJpg(img, quality: 60), flush: true);
    return FileAttachment(f);
  }

  SmtpServer _setupSmtpServer() {
    return SmtpServer(smtpHost,
        port: smtpPort,
        ssl: enableSsl,
        username: senderEmail,
        password: senderPassword);
  }

  String? _getEmailTitle(Report report) {
    if (emailTitle?.isNotEmpty == true) {
      return emailTitle;
    } else {
      return "[${AppInfo.fullVersion}] Error: ${report.error}";
    }
  }

  String _setupHtmlMessageText(Report report) {
    final escape = HtmlEscape().convert;
    StringBuffer buffer = StringBuffer("");
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(escape(emailHeader!));
      buffer.write("<hr>");
    }
    buffer.write('<style>h3{margin:0.2em 0;}</style>');

    if (contactInfo?.isNotEmpty == true) {
      buffer.write("<h3>Contact:</h3>");
      buffer.write("${escape(contactInfo!)}<br>");
    }
    buffer.write("<h3>Summary:</h3>");
    Map<String, dynamic> summary = {
      'appVersion': '${AppInfo.appName} v${AppInfo.fullVersion2}',
      'datasetMemory': db.gameData.version,
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'lang': Language.current,
    };
    for (var entry in summary.entries) {
      buffer
          .write("<b>${entry.key}</b>: ${escape(entry.value.toString())}<br>");
    }
    buffer.write('<hr>');

    buffer.write("<h3>Error:</h3>");
    buffer.write(escape(report.error.toString()));
    if (report.error.toString().trim().isEmpty && report.errorDetails != null) {
      buffer.write(escape(report.errorDetails!.exceptionAsString()));
    }
    buffer.write("<hr>");

    if (enableStackTrace) {
      buffer.write("<h3>Stack trace:</h3>");
      buffer
          .write(escape(report.stackTrace.toString()).replaceAll("\n", "<br>"));
      if (report.stackTrace?.toString().trim().isNotEmpty != true &&
          report.errorDetails != null) {
        buffer.write(escape(report.errorDetails!.stack.toString())
            .replaceAll('\n', '<br>'));
      }
      buffer.write("<hr>");
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

  String _setupRawMessageText(Report report) {
    StringBuffer buffer = StringBuffer("");
    if (emailHeader?.isNotEmpty == true) {
      buffer.write(emailHeader);
      buffer.write("\n\n");
    }
    if (contactInfo?.isNotEmpty == true) {
      buffer.write('Contact: $contactInfo\n\n');
    }

    buffer.write("Error:\n");
    buffer.write(report.error.toString());
    buffer.write("\n\n");
    if (enableStackTrace) {
      buffer.write("Stack trace:\n");
      buffer.write(report.stackTrace.toString());
      buffer.write("\n\n");
    }
    if (enableDeviceParameters) {
      buffer.write("Device parameters:\n");
      for (var entry in report.deviceParameters.entries) {
        buffer.write("${entry.key}: ${entry.value}\n");
      }
      buffer.write("\n\n");
    }
    if (enableApplicationParameters) {
      buffer.write("Application parameters:\n");
      for (var entry in report.applicationParameters.entries) {
        buffer.write("${entry.key}: ${entry.value}\n");
      }
      buffer.write("\n\n");
    }
    if (enableCustomParameters) {
      buffer.write("Custom parameters:\n");
      for (var entry in report.customParameters.entries) {
        buffer.write("${entry.key}: ${entry.value}\n");
      }
      buffer.write("\n\n");
    }
    return buffer.toString();
  }

  void _printLog(String log) {
    if (printLogs) {
      _logger.info(log);
    }
  }
}

EmailAutoHandlerCross kEmailAutoHandlerCross(
        {List<File> attachments = const []}) =>
    EmailAutoHandlerCross(
      'smtp.qiye.aliyun.com',
      465,
      'chaldea-client@narumi.cc',
      'Chaldea Crash',
      b64('Q2hhbGRlYUBjbGllbnQ='), //Chaldea@client
      [kSupportTeamEmailAddress],
      attachments: attachments,
      screenshot: true,
      enableSsl: true,
      printLogs: true,
    );
