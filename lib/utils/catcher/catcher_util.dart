import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:catcher_2/catcher_2.dart';

class CatcherUtil {
  CatcherUtil._();

  static Catcher2Options getOptions({String? logPath, ReportHandler? feedbackHandler}) {
    return Catcher2Options(
      // when error occurs when building:
      // DialogReportMode will keep generating error and you can do nothing
      // PageReportMode will generate error repeatedly for about 3 times.
      SilentReportMode(),
      [
        if (!kIsWeb && logPath != null) FileHandler(File(logPath)),
        ConsoleHandler(),
        // ToastHandler(),
        if (feedbackHandler != null) feedbackHandler,
      ],
      handleSilentError: false,
      filterFunction: CatcherUtil.reportFilter,
      handlerTimeout: 12000, // feedbackHandler is a little slow
    );
  }

  static bool reportFilter(Report report) {
    return true;
  }

  static void reportError(dynamic error, StackTrace? stacktrace) {
    try {
      Catcher2.getInstance();
      Catcher2.reportCheckedError(error, stacktrace);
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stacktrace));
    }
  }
}
