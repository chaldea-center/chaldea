import 'dart:async';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  await db.initial();
  db.loadUserData();
  FileHandler crashFileHandler = FileHandler(File(db.paths.crashLog));
  final catcherOptions = CatcherOptions(ForceSilentReportMode(), [
    crashFileHandler,
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
  if (kDebugMode)
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

/// Catcher doesn't support desktop, so override it.
class ForceSilentReportMode extends ReportMode {
  @override
  void requestAction(Report report, BuildContext context) {
    // no action needed, request is automatically accepted
    super.onActionConfirmed(report);
  }

  @override
  List<PlatformType> getSupportedPlatforms() => [
        PlatformType.Web,
        PlatformType.Android,
        PlatformType.iOS,
        PlatformType.Unknown
      ];
}
