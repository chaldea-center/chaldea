import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';

Future<void> initiateForTest() async {
  // - flutter test ** --dart-define=APP_PATH=/path/to/root
  // - for vsc, add
  //    "dart.flutterTestAdditionalArgs": ["--dart-define=APP_PATH=/path/to/app"]
  // - remember to escape special chars such as Space
  String appPath = const String.fromEnvironment('APP_PATH');
  print(appPath);
  assert(appPath.trim().isNotEmpty, 'APP_PATH must be provided');

  CustomTestBindings();
  await S.load(const Locale('en'));
  await db.initiateForTest(testAppPath: appPath);
}

class CustomTestBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}
