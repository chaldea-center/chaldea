import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:catcher/catcher.dart';

class CatcherUtil {
  CatcherUtil._();

  static CatcherOptions getOptions(
      {String? logPath, ReportHandler? feedbackHandler}) {
    return CatcherOptions(
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
      handlerTimeout: 10000,
    );
  }

  static bool reportFilter(Report report) {
    return true;
  }
}
