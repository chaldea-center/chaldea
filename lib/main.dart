import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  await db.initial();
  db.loadUserData();
  FileHandler crashFileHandler = FileHandler(File(db.paths.crashLog));
  final catcherOptions = CatcherOptions(SilentReportMode(), [
    crashFileHandler,
    ConsoleHandler(),
    ToastHandler(),
  ]);

  FlutterError.onError = (details) {
    // only called in release mode?
    // if use Catcher, errors will be caught by Catcher not this handler.
    if (kDebugMode_) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  if (kDebugMode_)
    runApp(Chaldea());
  else
    Catcher(
      rootWidget: Chaldea(),
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      enableLogger: true,
      ensureInitialized: true,
    );
}
