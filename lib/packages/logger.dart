/// Since most messages of flutter console are helpless,
/// Wrap our logs inside a drawn box to make it easy to identify.

// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// default logger
Logger _logger = Logger(
  filter: ProductionFilter(),
  printer: _CustomPrettyPrinter(methodCount: 2, colors: false, printEmojis: false, printTime: true),
);

Logger get logger => _logger;

extension LoggerUtils on Logger {
  void errorSkipDio(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (e is DioException) {
      v(message, error);
    } else {
      e(message, error, stackTrace);
    }
  }

  static void initiateLoggerPath([String? fp]) {
    if (fp != null) {
      rollLogFiles(fp, 5, 10 * 1024 * 1024); //10MB
    }
    _logger = Logger(
      filter: ProductionFilter(),
      printer: _CustomPrettyPrinter(
        methodCount: 2,
        colors: false,
        printEmojis: false,
        printTime: true,
        lineLength: 10,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        if (!kIsWeb && fp != null) FileOutput(file: File(fp)),
      ]),
      level: kDebugMode ? null : Level.debug,
    );
  }

  /// fp, fp.1,...,fp.[maxCount], [maxSize] in bytes
  static void rollLogFiles(String fp, int maxBackup, int maxSize) {
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
}

class _CustomPrettyPrinter extends PrettyPrinter {
  _CustomPrettyPrinter({
    super.stackTraceBeginIndex = 0,
    super.methodCount = 2,
    super.errorMethodCount = 8,
    super.lineLength = 10,
    super.colors = true,
    super.printEmojis = true,
    super.printTime = false,
    super.excludeBox = const {},
    super.noBoxingByDefault = false,
  });

  @override
  List<String> log(LogEvent event) {
    String messageStr = stringifyMessage(event.message);
    StackTrace _fmtStackTrace(Object? s) {
      final lines = (s ?? StackTrace.current).toString().split('\n');
      lines.removeWhere((line) => line.contains('chaldea/packages/logger.dart') || line == '<asynchronous suspension>');
      if (kIsWeb && lines.isNotEmpty && lines.first.trim() == "Error") {
        lines.removeAt(0);
      }
      return StackTrace.fromString(lines.join('\n'));
    }

    String? stackTraceStr;
    dynamic error = event.error;
    if (event.stackTrace == null) {
      if (methodCount > 0 && event.level.index > Level.verbose.index) {
        stackTraceStr = formatStackTrace(_fmtStackTrace(StackTrace.current), methodCount);
      }
    } else if (errorMethodCount > 0) {
      stackTraceStr = formatStackTrace(_fmtStackTrace(event.stackTrace), errorMethodCount);
    }
    if (error is DioException && kReleaseMode) {
      stackTraceStr = null;
    }
    if (error is DioException) {
      final respData = error.response?.data;
      String? detail;
      if (respData is List<int>) {
        try {
          detail = utf8.decode(respData);
        } catch (e) {
          //
        }
      }
      detail ??= respData?.toString() ?? "";

      if (detail.length > 1000) detail = "\n${detail.substring(0, 1000)}";

      List<String> lines = error.stackTrace.toString().split('\n');
      while (lines.isNotEmpty && lines.last.contains('package:flutter/src') || lines.last.contains('(dart:')) {
        lines.removeLast();
      }
      lines.insertAll(0, {
        error.requestOptions.uri.toString(),
        if (error.response != null) error.response!.realUri.toString(),
      });
      error = error.copyWith(
        error: '${error.error}$detail',
        stackTrace: StackTrace.fromString(lines.take(10).join('\n')),
      );
    }
    String? errorStr = error?.toString();

    String timeStr = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch).toString();

    List<String> buffer = [];

    String levelStr = event.level.toString().split('.').last.toUpperCase();

    if (stackTraceStr != null && event.level != Level.verbose) {
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
    buffer.add('└'.padRight(kReleaseMode ? 10 : lineLength, '-'));
    return buffer;
  }
}
