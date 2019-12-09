import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher_plugin.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.paths.initRootPath();
  FileHandler fileHandler = FileHandler(File(db.paths.crashLog));
  final catcherOptions = CatcherOptions(SilentReportMode(), [
    fileHandler,
    ConsoleHandler(),
    ToastHandler(),
  ]);

  FlutterError.onError = (details) {
    // only called in release mode?
    // if use Catcher, errors will be caught by Catcher not this handler.
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZoned(
    () {
      Catcher(
        Chaldea(),
        debugConfig: catcherOptions,
        profileConfig: catcherOptions,
        releaseConfig: catcherOptions,
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // catch all print msg(line)
      },
    ),
    onError: (error, stackTrace) async {
      // called in release mode
    },
  );
}
