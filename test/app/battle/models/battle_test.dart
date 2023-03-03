import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;

  test('Init test', () {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData(100100)
        ..svtId = 100100
        ..skillStrengthenLvs = [1, 2, 1]
        ..npLv = 1
        ..npStrengthenLv = 2
        ..lv = 90
        ..atkFou = 0
        ..hpFou = 0
    ];
    final battle = BattleData();
    battle.init(db.gameData.questPhases[9300000103]!, playerSettings, null);
  });
}
