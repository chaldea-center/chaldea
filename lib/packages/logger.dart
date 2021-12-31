/// Since most messages of flutter console are helpless,
/// Wrap our logs inside a drawn box to make it easy to identify.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:logger/src/outputs/file_output.dart'; // ignore: implementation_imports

import 'platform/platform.dart';

/// default logger
Logger _logger = Logger(
  filter: ProductionFilter(),
  printer: _CustomPrettyPrinter(
      methodCount: 2, colors: false, printEmojis: false, printTime: true),
);

Logger get logger => _logger;

void initiateLoggerPath(String fp) {
  rollLogFiles(fp, 5, 10 * 1024 * 1024); //10MB
  _logger = Logger(
    filter: ProductionFilter(),
    printer: _CustomPrettyPrinter(
        methodCount: 2, colors: false, printEmojis: false, printTime: true),
    output: MultiOutput([
      ConsoleOutput(),
      if (!PlatformU.isWeb) FileOutput(file: File(fp)),
    ]),
    level: kDebugMode ? null : Level.debug,
  );
}

/// fp, fp.1,...,fp.[maxCount], [maxSize] in bytes
void rollLogFiles(String fp, int maxBackup, int maxSize) {
  if (PlatformU.isWeb) {
    print('ignore rolling log on web');
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

    String? stackTraceStr;
    if (event.stackTrace == null) {
      if (methodCount > 0) {
        final lines = StackTrace.current.toString().split('\n');
        lines.removeWhere((line) =>
            line.contains('chaldea/packages/logger.dart') ||
            line == '<asynchronous suspension>');
        stackTraceStr = formatStackTrace(
            StackTrace.fromString(lines.join('\n')), methodCount);
      }
    } else if (errorMethodCount > 0) {
      stackTraceStr = formatStackTrace(event.stackTrace, errorMethodCount);
    }

    String? errorStr = event.error?.toString();

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
      buffer.add('├ ' + errorStr);
    }
    buffer.add('├ [$timeStr][$levelStr] $messageStr');
    buffer.add('└'.padRight(lineLength, '-'));
    return buffer;
  }
}
