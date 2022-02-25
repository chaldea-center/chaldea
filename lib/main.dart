import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:catcher/catcher.dart';
import 'package:chaldea/app/chaldea_next.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';
import 'package:chaldea/utils/http_override.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:worker_manager/worker_manager.dart';

import 'app/modules/common/blank_page.dart';
import 'models/basic.dart';
import 'models/db.dart';
import 'packages/network.dart';
import 'utils/catcher/catcher_util.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  runChaldeaNext = false;
  await _initiateCommon();
  if (runChaldeaNext) {
    await _mainNext();
  } else {
    await _mainLegacy();
  }
}

Future<void> _mainNext() async {
  await Executor().warmUp();
  await db2.initiate();
  await db2.loadSettings();
  await db2.loadUserData().then((value) async {
    if (value != null) db2.userData = value;
  });
  final catcherOptions = CatcherUtil.getOptions(
    logPath: db2.paths.crashLog,
    feedbackHandler: ServerFeedbackHandler(
      screenshotController: db2.runtimeData.screenshotController,
      screenshotPath: joinPaths(db2.paths.tempDir, 'crash.jpg'),
      attachments: [
        db2.paths.appLog,
        db2.paths.crashLog,
        db2.paths.userDataPath
      ],
      onGenerateAttachments: () => {
        'userdata.memory.json':
            Uint8List.fromList(utf8.encode(jsonEncode(db2.userData)))
      },
    ),
  );
  if (kDebugMode) {
    runApp(ChaldeaNext());
  } else {
    Catcher(
      rootWidget: ChaldeaNext(),
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      navigatorKey: kAppKey,
      ensureInitialized: true,
      enableLogger: kDebugMode,
    );
  }
}

Future<void> _mainLegacy() async {
  await db.initial().catchError((e, s) async {
    db.initErrorDetail =
        FlutterErrorDetails(exception: e, stack: s, library: 'initiation');
    logger.e('db.initial failed', e, s);
    Future.delayed(const Duration(seconds: 10), () {
      Catcher.reportCheckedError(e, s);
    });
  });

  final catcherOptions = CatcherUtil.getOptions(
    logPath: db.paths.crashLog,
    feedbackHandler: ServerFeedbackHandler(
      screenshotController: db.runtimeData.screenshotController,
      screenshotPath: joinPaths(db.paths.tempDir, 'crash.jpg'),
      attachments: [db.paths.appLog, db.paths.crashLog, db.paths.userDataPath],
      onGenerateAttachments: () => {
        'userdata.memory.json':
            Uint8List.fromList(utf8.encode(jsonEncode(db.userData)))
      },
    ),
  );
  if (kDebugMode) {
    runApp(Chaldea());
  } else {
    Catcher(
      rootWidget: Chaldea(),
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
  if (kIsWeb) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  SplitRoute.defaultMasterFillPageBuilder = (context) => const BlankPage();
}
