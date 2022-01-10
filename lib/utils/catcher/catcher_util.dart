import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  static Widget errorWidgetBuilder(FlutterErrorDetails details) {
    if (details.silent) return Container();
    return Center(
      child: RichText(
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
        text: const TextSpan(
          children: [
            WidgetSpan(
                child: Icon(Icons.announcement, color: Colors.red, size: 40)),
            TextSpan(text: '\nThere is an Error')
          ],
        ),
      ),
    );
  }
}
