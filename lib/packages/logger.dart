/// Since most messages of flutter console are helpless,
/// Wrap our logs inside a drawn box to make it easy to identify.

// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

class _LoggerWrap {
  final Logger _l;
  _LoggerWrap(this._l);

  void t(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.t(message, error: error, stackTrace: stackTrace);

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.d(message, error: error, stackTrace: stackTrace);

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.i(message, error: error, stackTrace: stackTrace);

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.w(message, error: error, stackTrace: stackTrace);

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.e(message, error: error, stackTrace: stackTrace);

  void fetal(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.f(message, error: error, stackTrace: stackTrace);

  void log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _l.log(level, message, error: error, stackTrace: stackTrace);

  bool isClosed() => _l.isClosed();

  void close() => _l.close();
}

/// default logger
_LoggerWrap _logger = _LoggerWrap(
  Logger(
    filter: ProductionFilter(),
    printer: _CustomPrettyPrinter(methodCount: 2, colors: false, printEmojis: false, printTime: true),
    level: Level.trace,
  ),
);

_LoggerWrap get logger => _logger;

extension LoggerUtils on Logger {
  static void initiateLoggerPath([String? fp]) {
    DioException.readableStringBuilder = (DioException e) {
      final buffer = StringBuffer('DioException [${e.response?.statusCode ?? ""} ${e.type.name}]: ');
      if (e.error != null) {
        buffer.write('Error: ${e.error}');
      }
      return buffer.toString();
    };

    if (fp != null) {
      rollLogFiles(fp, 5, 10 * 1024 * 1024); //10MB
    }
    _logger = _LoggerWrap(
      Logger(
        filter: ProductionFilter(),
        level: Level.trace,
        printer: _CustomPrettyPrinter(
          methodCount: 2,
          colors: false,
          printEmojis: false,
          printTime: true,
          lineLength: 10,
        ),
        output: MultiOutput([ConsoleOutput(), if (!kIsWeb && fp != null) FileOutput(file: File(fp))]),
      ),
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
    super.methodCount = 2,
    super.lineLength = 10,
    super.colors = true,
    super.printEmojis = true,
    super.printTime = false,
  });

  final _ignoredErrors = <String>{};

  bool _tryIgnore(Object? exception) {
    if (exception is DioException) {
      final dioError = exception.error;
      if (dioError is! Exception) return false;
      exception = dioError;
    }
    if (exception is SocketException) {
      exception = SocketException(exception.message, osError: exception.osError, address: exception.address);
    }
    if (exception is IOException) {
      return !_ignoredErrors.add(exception.toString());
    }
    return false;
  }

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

    if (_tryIgnore(event.error)) {
      return [];
    }

    dynamic error = event.error;
    StackTrace? stackTrace = error is DioException ? error.stackTrace : event.stackTrace;
    String? stackTraceStr;

    if (event.level == Level.trace) {
      stackTraceStr = null;
    } else if (stackTrace == null) {
      if ((methodCount ?? 0) > 0) {
        stackTraceStr = formatStackTrace(_fmtStackTrace(StackTrace.current), methodCount);
      }
    } else if ((errorMethodCount ?? 0) > 0) {
      stackTraceStr = formatStackTrace(_fmtStackTrace(stackTrace), errorMethodCount);
    }
    if ((error is DioException && kReleaseMode) || (error is SilentException && error.silent)) {
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
        message: error.response?.statusCode == 404 ? "" : null,
      );
    }
    String? errorStr = error?.toString();
    if (error is CheckedFromJsonException && error.innerStack != null) {
      errorStr = '$errorStr\nInnerStack:\n${error.innerStack}';
    }
    if (printEmojis && errorStr != null) {
      errorStr = (PrettyPrinter.defaultLevelEmojis[event.level] ?? '') + errorStr;
    }
    String timeStr = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch).toString();

    String levelStr = event.level.toString().split('.').last.toUpperCase();

    final fullMessageStr = '[$timeStr][$levelStr] $messageStr';

    const addBottom = kDebugMode;

    final lines = <String>[
      if (stackTraceStr != null)
        ...stackTraceStr.split('\n').where((line) => line != '<asynchronous suspension>').take(20),
      if (errorStr != null) errorStr,
      fullMessageStr,
    ];
    if (lines.length > 1) {
      for (int index = 0; index < lines.length - 1; index++) {
        lines[index] = '├ ${lines[index]}';
      }
      lines[lines.length - 1] = (addBottom ? '├ ' : '└-') + lines[lines.length - 1];
      if (addBottom) {
        lines.add('└---------');
      }
    }
    return lines;
  }
}

class SilentException implements Exception {
  final dynamic message;
  final bool silent;

  SilentException(this.message, {this.silent = true});

  @override
  String toString() {
    return "SilentException: $message";
  }
}
