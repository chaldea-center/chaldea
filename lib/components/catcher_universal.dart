import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.
import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/src/entities/attachment.dart'; // ignore: implementation_imports
import 'package:path/path.dart' as pathlib;

import 'config.dart';
import 'constants.dart';
import 'device_app_info.dart';
import 'shared_prefs.dart';
import 'utils.dart';

export 'page_report_mode_cross.dart';

class ToastHandlerCross extends ReportHandler {
  final Duration? duration;
  final EasyLoadingToastPosition? toastPosition;
  final String? customMessage;

  ToastHandlerCross({this.duration, this.toastPosition, this.customMessage});

  @override
  Future<bool> handle(Report error) async {
    EasyLoading.showToast(_getErrorMessage(error),
        duration: duration, toastPosition: toastPosition);
    return true;
  }

  String _getErrorMessage(Report error) {
    if (customMessage != null && customMessage!.length > 0) {
      return customMessage!;
    } else {
      return "Error occurred: ${error.error}";
    }
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
  Future<bool> handle(Report error) async {
    return _sendMail(error);
  }

  /// maintain list for every contact if contact changed
  Map<String, List<Report>> _sentReports = {};

  String? get contactInfo =>
      db.prefs.instance.getString(SharedPrefs.contactInfo);

  Future<bool> _sendMail(Report report) async {
    // don't send email repeatedly
    String contact = contactInfo?.trim() ?? '';
    List<Report> _cachedReports = _sentReports.putIfAbsent(contact, () => []);
    if (_cachedReports.any((element) =>
        report.error.toString() == element.error.toString() &&
        report.stackTrace.toString() == element.stackTrace.toString())) {
      return true;
    }
    try {
      final message = new Message()
        ..from = new Address(this.senderEmail, this.senderName)
        ..recipients.addAll(recipients)
        ..subject = _getEmailTitle(report)
        ..text = _setupRawMessageText(report)
        ..attachments = _getAttachments(attachments);
      if (screenshot) {
        String shotFn = pathlib.join(db.paths.appPath, 'crash.png');
        Uint8List? shotBinary = await db.runtimeData.screenshotController
            ?.capture(pixelRatio: 1.5, delay: Duration(seconds: 2));
        if (shotBinary != null) {
          File(shotFn).writeAsBytesSync(shotBinary, flush: true);
          message.attachments.add(FileAttachment(File(shotFn)));
        }
      }
      if (sendHtml) {
        message.html = _setupHtmlMessageText(report);
      }
      _printLog("Sending email...");

      var result = await send(message, _setupSmtpServer());
      _cachedReports.add(report);
      _printLog("Email result: mail: ${result.mail} "
          "sending start time: ${result.messageSendingStart} "
          "sending end time: ${result.messageSendingEnd}");
      return true;
    } catch (stacktrace, exception) {
      _printLog(stacktrace.toString());
      _printLog(exception.toString());
      return false;
    }
  }

  List<Attachment> _getAttachments(List<File> files) {
    List<Attachment> attachments = [];
    for (File file in files) {
      if (file.existsSync()) {
        // set file limit less than 1MB
        if (file.lengthSync() > 1024 * 1024) {
          String s = file.readAsStringSync();
          s.substring(s.length - min(s.length, 1000 * 1000), s.length);
          file.writeAsStringSync(s);
        }
        attachments.add(FileAttachment(file));
      }
    }
    return attachments;
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
    final dataVerFile = File(db.paths.datasetVersionFile);
    Map<String, dynamic> summary = {
      'appVersion': '${AppInfo.appName} v${AppInfo.fullVersion}',
      'datasetVersion': dataVerFile.existsSync()
          ? dataVerFile.readAsStringSync()
          : "Not detected",
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    };
    for (var entry in summary.entries) {
      buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
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
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
      }
      buffer.write("<hr>");
    }
    if (enableApplicationParameters) {
      buffer.write("<h3>Application parameters:</h3>");
      for (var entry in report.applicationParameters.entries) {
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
      }
      buffer.write("<hr>");
    }

    if (enableCustomParameters) {
      buffer.write("<h3>Custom parameters:</h3>");
      for (var entry in report.customParameters.entries) {
        buffer.write("<b>${entry.key}</b>: ${escape(entry.value)}<br>");
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
