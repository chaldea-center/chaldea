import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:catcher_2/catcher_2.dart';
import 'package:catcher_2/model/platform_type.dart';

class CatcherUtil {
  CatcherUtil._();

  static Catcher2Options getOptions({String? logPath, ReportHandler? feedbackHandler}) {
    return Catcher2Options(
      // when error occurs when building:
      // DialogReportMode will keep generating error and you can do nothing
      // PageReportMode will generate error repeatedly for about 3 times.
      SilentReportMode(),
      [
        if (!kIsWeb && logPath != null) _StacktraceHandler(FileHandler(File(logPath)), 50),
        _StacktraceHandler(ConsoleHandler(), 50),
        // ToastHandler(),
        ?feedbackHandler,
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

class _StacktraceHandler extends ReportHandler {
  final ReportHandler handler;
  final int maxLines;
  _StacktraceHandler(this.handler, this.maxLines);

  @override
  set logger(Catcher2Logger v) {
    handler.logger = v;
    super.logger = v;
  }

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values;

  @override
  Future<bool> handle(Report error, BuildContext? context) {
    final stackTrace = error.stackTrace;
    if (stackTrace != null) {
      final lines = const LineSplitter().convert(stackTrace.toString());
      if (lines.length > maxLines) {
        error = Report(
          error.error,
          StackTrace.fromString(lines.take(maxLines).join('\n')),
          error.dateTime,
          error.deviceParameters,
          error.applicationParameters,
          error.customParameters,
          error.errorDetails,
          error.platformType,
          error.screenshot,
        );
      }
    }
    return handler.handle(error, context);
  }
}
