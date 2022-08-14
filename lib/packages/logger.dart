/// Since most messages of flutter console are helpless,
/// Wrap our logs inside a drawn box to make it easy to identify.

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:logger/src/outputs/file_output.dart'; // ignore: implementation_imports

/// default logger
Logger _logger = Logger(
  filter: ProductionFilter(),
  printer: _CustomPrettyPrinter(
      methodCount: 2, colors: false, printEmojis: false, printTime: true),
);

Logger get logger => _logger;

void initiateLoggerPath([String? fp]) {
  if (fp != null) {
    rollLogFiles(fp, 5, 10 * 1024 * 1024); //10MB
  }
  _logger = Logger(
    filter: ProductionFilter(),
    printer: _CustomPrettyPrinter(
        methodCount: 2, colors: false, printEmojis: false, printTime: true),
    output: MultiOutput([
      ConsoleOutput(),
      if (!kIsWeb && fp != null) FileOutput(file: File(fp)),
    ]),
    level: kDebugMode ? null : Level.debug,
  );
}

/// fp, fp.1,...,fp.[maxCount], [maxSize] in bytes
void rollLogFiles(String fp, int maxBackup, int maxSize) {
  if (kIsWeb) {
    // debugPrint('ignore rolling log on web');
    return;
  }
  var f = File(fp);
  String _fpAt(int index) {
    return index == 0 ? fp : '$fp.$index';
  }

  if (f.existsSync() && f.statSync().size >= maxSize) {
    for (int i = maxBackup - 1; i >= 0; i--) {
      var _f = File(_fpAt(i));
      if (_f.existsSync()) _f.renameSync(_fpAt(i + 1));
    }
  }
}

class _CustomPrettyPrinter extends PrettyPrinter {
  _CustomPrettyPrinter({
    int stackTraceBeginIndex = 0,
    int methodCount = 2,
    int errorMethodCount = 8,
    int lineLength = 120,
    bool colors = true,
    bool printEmojis = true,
    bool printTime = false,
    Map<Level, bool> excludeBox = const {},
    bool noBoxingByDefault = false,
  }) : super(
          stackTraceBeginIndex: stackTraceBeginIndex,
          methodCount: methodCount,
          errorMethodCount: errorMethodCount,
          lineLength: lineLength,
          colors: colors,
          printEmojis: printEmojis,
          printTime: printTime,
          excludeBox: excludeBox,
          noBoxingByDefault: noBoxingByDefault,
        );

  @override
  List<String> log(LogEvent event) {
    String messageStr = stringifyMessage(event.message);
    StackTrace _fmtStackTrace(Object? s) {
      final lines = (s ?? StackTrace.current).toString().split('\n');
      lines.removeWhere((line) =>
          line.contains('chaldea/packages/logger.dart') ||
          line == '<asynchronous suspension>');
      if (kIsWeb && lines.isNotEmpty && lines.first.trim() == "Error") {
        lines.removeAt(0);
      }
      return StackTrace.fromString(lines.join('\n'));
    }

    String? stackTraceStr;
    if (event.stackTrace == null) {
      if (methodCount > 0) {
        stackTraceStr =
            formatStackTrace(_fmtStackTrace(StackTrace.current), methodCount);
      }
    } else if (errorMethodCount > 0) {
      stackTraceStr =
          formatStackTrace(_fmtStackTrace(event.stackTrace), errorMethodCount);
    }
    dynamic error = event.error;
    if (error is DioError && error.response?.data != null) {
      String detail = error.response!.data.toString();
      if (detail.length > 1000) detail = detail.substring(0, 1000);
      error = DioError(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: '${error.error}\n$detail',
      )..stackTrace = error.stackTrace;
    }
    String? errorStr = error?.toString();

    String timeStr = DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch)
        .toString();

    List<String> buffer = [];

    String levelStr = event.level.toString().split('.').last.toUpperCase();

    if (stackTraceStr != null) {
      final lines = stackTraceStr.split('\n');
      for (int index = 0; index < lines.length; index++) {
        buffer.add((index == 0 ? '├ ' : '│ ') + lines[index]);
      }
    }
    if (errorStr != null) {
      if (printEmojis) {
        errorStr = (PrettyPrinter.levelEmojis[event.level] ?? '') + errorStr;
      }
      buffer.add('├ $errorStr');
    }
    buffer.add('├ [$timeStr][$levelStr] $messageStr');
    buffer.add('└'.padRight(lineLength, '-'));
    return buffer;
  }
}
