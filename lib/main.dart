import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catcher/catcher.dart';
import 'package:window_size/window_size.dart';
import 'package:worker_manager/worker_manager.dart';

import 'package:chaldea/app/chaldea.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/http_override.dart';
import 'package:chaldea/utils/utils.dart';
import 'app/error.dart';
import 'app/modules/common/blank_page.dart';
import 'models/db.dart';
import 'models/gamedata/common.dart';
import 'packages/network.dart';
import 'packages/packages.dart';
import 'packages/split_route/split_route.dart';
import 'utils/catcher/catcher_util.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  dynamic initError, initStack;
  CatcherOptions? catcherOptions;
  try {
    await _initiateCommon();
    await Executor().warmUp();
    await db.initiate();
    await db.loadSettings();
    if (db.settings.splitMasterRatio != null) {
      SplitRoute.defaultMasterRatio = db.settings.splitMasterRatio!;
    }
    await db.loadUserData().then((value) async {
      if (value != null) db.userData = value;
    });
    catcherOptions = CatcherUtil.getOptions(
      logPath: db.paths.crashLog,
      feedbackHandler: ServerFeedbackHandler(
        screenshotController: db.runtimeData.screenshotController,
        screenshotPath: joinPaths(db.paths.tempDir, 'crash.jpg'),
        attachments: [
          db.paths.appLog,
          db.paths.crashLog,
          db.paths.userDataPath
        ],
        onGenerateAttachments: () => {
          'userdata.memory.json':
              Uint8List.fromList(utf8.encode(jsonEncode(db.userData)))
        },
      ),
    );
  } catch (e, s) {
    initError = e;
    initStack = s;
    try {
      logger.e('initiate app failed at startup', e, s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
  final app = initError == null
      ? Chaldea()
      : StartupErrorPage(initError: initError, initStack: initStack);
  if (kDebugMode) {
    runApp(app);
  } else {
    Catcher(
      rootWidget: app,
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      navigatorKey: kAppKey,
      ensureInitialized: true,
      enableLogger: kDebugMode,
    );
  }
}

Future<void> _initiateCommon() async {
  // Config min size of the window for desktops app
  // (This is a prototype, and in the long term is expected to be replaced by functionality within the Flutter framework.)
  if (PlatformU.isDesktop) {
    setWindowTitle(kAppName);
    setWindowMinSize(const Size(375, 568));
    setWindowMaxSize(Size.infinite);
  }

  LicenseRegistry.addLicense(() async* {
    Map<String, String> licenses = {
      'MOONCELL': 'doc/license/CC-BY-NC-SA-4.0.txt',
      'FANDOM': 'doc/license/CC-BY-SA-3.0.txt',
      'Atlas Academy': 'doc/license/ODC-BY 1.0.txt',
    };
    for (final entry in licenses.entries) {
      String license =
          await rootBundle.loadString(entry.value).catchError((e, s) async {
        logger.e('load license(${entry.key}, ${entry.value}) failed.', e, s);
        return 'load license failed';
      });
      yield LicenseEntryWithLineBreaks([entry.key], license);
    }
  });
  network.init();
  kTraitIdMappingReverse.length; // call assert
  if (!kIsWeb) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  SplitRoute.defaultMasterFillPageBuilder = (context) => const BlankPage();
}
