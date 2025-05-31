import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/user.dart' show SvtEquipData;
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';

Future<void> initiateForTest({bool loadData = true}) async {
  // - flutter test ** --dart-define=APP_PATH=/path/to/root
  // - for vsc, add
  //    "dart.flutterTestAdditionalArgs": ["--dart-define=APP_PATH=/path/to/app"]
  // - remember to escape special chars such as Space
  String appPath = const String.fromEnvironment('APP_PATH');
  print('Provided appPath: $appPath');
  assert(appPath.trim().isNotEmpty, 'APP_PATH must be provided');

  CustomTestBindings();
  await S.load(const Locale('en'));
  await db.initiateForTest(testAppPath: appPath);
  if (loadData) {
    final data = await GameDataLoader.instance.reload(offline: true, silent: true);
    print('Data version: ${data?.version.dateTime.toString()}');
    assert(data != null && data.version.timestamp > 0);
    db.gameData = data!;
  }
}

class CustomTestBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

SvtEquipData getNP100Equip() => SvtEquipData(
  ce: db.gameData.craftEssencesById[9400340], // Kaleidoscope
  lv: 100,
  limitBreak: true,
);
