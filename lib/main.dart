import 'package:catcher/catcher.dart';
import 'package:chaldea/components/catcher_util/catcher_config.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  await db.initial().catchError((e, s) {
    logger.e('db.initial failed', e, s);
    Future.delayed(const Duration(seconds: 10), () {
      Catcher.reportCheckedError(e, s);
    });
  });

  final catcherOptions = CatcherUtility.getOptions();
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
