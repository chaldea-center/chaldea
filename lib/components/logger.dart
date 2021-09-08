/// Since most messages of flutter console are helpless,
/// Wrap our logs inside a drawn box to make it easy to identify.
import 'dart:io';

import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:logger/src/outputs/file_output.dart'; // ignore: implementation_imports

/// default logger
Logger _logger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(
      methodCount: 2, colors: false, printEmojis: false, printTime: true),
);

Logger get logger => _logger;

void initiateLoggerPath(String fp) {
  rollLogFiles(fp, 5, 10 * 1024 * 1024); //10MB
  _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
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
