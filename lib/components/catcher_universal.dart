import 'dart:io';

/// This package is platform-compatibility fix for catcher.
/// If official support is release, this should be removed.
import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'constants.dart';
import 'utils.dart';

class PageReportModeCross extends PageReportMode {
  PageReportModeCross({bool showStackTrace = true})
      : super(showStackTrace: showStackTrace);

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();
}

class FileHandlerCross extends FileHandler {
  FileHandlerCross(File file,
      {bool enableDeviceParameters = true,
      bool enableApplicationParameters = true,
      bool enableStackTrace = true,
      bool enableCustomParameters = true,
      bool printLogs = false})
      : super(file,
            enableDeviceParameters: enableDeviceParameters,
            enableApplicationParameters: enableApplicationParameters,
            enableStackTrace: enableStackTrace,
            enableCustomParameters: enableCustomParameters,
            printLogs: printLogs);

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();
}

class ConsoleHandlerCross extends ConsoleHandler {
  ConsoleHandlerCross(
      {bool enableDeviceParameters = true,
      bool enableApplicationParameters = true,
      bool enableStackTrace = true,
      bool enableCustomParameters = true})
      : super(
            enableDeviceParameters: enableDeviceParameters,
            enableApplicationParameters: enableApplicationParameters,
            enableStackTrace: enableStackTrace,
            enableCustomParameters: enableCustomParameters);

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();
}

class ToastHandlerCross extends ReportHandler {
  final Duration duration;
  final EasyLoadingToastPosition toastPosition;
  final String customMessage;

  ToastHandlerCross({this.duration, this.toastPosition, this.customMessage});

  @override
  Future<bool> handle(Report error) async {
    EasyLoading.showToast(_getErrorMessage(error),
        duration: duration, toastPosition: toastPosition);
    return true;
  }

  String _getErrorMessage(Report error) {
    if (customMessage != null && customMessage.length > 0) {
      return customMessage;
    } else {
      return "Error occurred: ${error.error}";
    }
  }

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values.toList();
}

class EmailAutoHandlerCross extends EmailAutoHandler {
  EmailAutoHandlerCross(String smtpHost, int smtpPort, String senderEmail,
      String senderName, String senderPassword, List<String> recipients,
      {bool enableSsl = false,
      bool enableDeviceParameters = true,
      bool enableApplicationParameters = true,
      bool enableStackTrace = true,
      bool enableCustomParameters = true,
      String emailTitle,
      String emailHeader,
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
}

EmailAutoHandlerCross kEmailAutoHandlerCross = EmailAutoHandlerCross(
  'smtp.qiye.aliyun.com',
  465,
  b64('Y2hhbGRlYS1jbGllbnRAbmFydW1pLmNj'),
  'Chaldea Feedback',
  b64('Q2hhbGRlYUBjbGllbnQ='),
  [kSupportTeamEmailAddress],
  enableSsl: true,
);
