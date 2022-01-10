import 'dart:convert';
import 'dart:typed_data';

import 'package:catcher/catcher.dart';
import 'package:chaldea/app/chaldea_next.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/models/basic.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:chaldea/utils/catcher/server_feedback_handler.dart';

import 'models/db.dart';
import 'utils/catcher/catcher_util.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  runChaldeaNext = false;
  await db.paths.initRootPath();
  await AppInfo.resolve(db.paths.appPath);
  if (runChaldeaNext) {
    await _mainNext();
  } else {
    await _mainLegacy();
  }
}

Future<void> _mainNext() async {
  await db2.initiate();
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
    runApp(const Chaldea());
  } else {
    Catcher(
      rootWidget: const Chaldea(),
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      navigatorKey: kAppKey,
      ensureInitialized: true,
      enableLogger: kDebugMode,
    );
  }
}
