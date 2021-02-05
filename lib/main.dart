import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:chaldea/components/catcher_universal.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  await db.initial();
  db.loadUserData();
  final catcherOptions = CatcherOptions(PageReportModeCross(), [
    FileHandlerCross(File(db.paths.crashLog)),
    ConsoleHandlerCross(),
    ToastHandlerCross(),
    if (!kDebugMode) kEmailAutoHandlerCross,
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
  Catcher(
    rootWidget: Chaldea(),
    debugConfig: catcherOptions,
    profileConfig: catcherOptions,
    releaseConfig: catcherOptions,
    enableLogger: true,
    ensureInitialized: true,
    navigatorKey: kAppKey,
  );
}
