import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;

  final BattleServantData ally = BattleServantData.fromPlayerSvtData(PlayerSvtData(504900)
    ..svtId = 504900
    ..skillStrengthenLvs = [1, 1, 1]
    ..npLv = 5
    ..npStrengthenLv = 1
    ..lv = 90
    ..atkFou = 1000
    ..hpFou = 1000);
  final BattleServantData enemy =
  BattleServantData.fromEnemy(db.gameData.questPhases[9300040603]!.stages.first.enemies.first);

  group('Test validateFunctionTargetTeam', () {
    test('FuncApplyTarget.enemy', () {
      final BaseFunction enemyFunction =
      BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.enemy);
      expect(validateFunctionTargetTeam(enemyFunction, ally), isFalse);
      expect(validateFunctionTargetTeam(enemyFunction, enemy), isTrue);
      expect(validateFunctionTargetTeam(enemyFunction, null), isTrue);
    });

    test('FuncApplyTarget.enemy', () {
      final BaseFunction allyFunciton =
      BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.player);
      expect(validateFunctionTargetTeam(allyFunciton, ally), isTrue);
      expect(validateFunctionTargetTeam(allyFunciton, enemy), isFalse);
      expect(validateFunctionTargetTeam(allyFunciton, null), isTrue);
    });

    test('FuncApplyTarget.enemy', () {
      final BaseFunction enemyFunction =
      BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.playerAndEnemy);
      expect(validateFunctionTargetTeam(enemyFunction, ally), isTrue);
      expect(validateFunctionTargetTeam(enemyFunction, enemy), isTrue);
      expect(validateFunctionTargetTeam(enemyFunction, null), isTrue);
    });
  });

  test('Test getDataVals', () {
    final NiceFunction yuyuNpDamageFunction = db.gameData.servantsById[2500400]!.noblePhantasms.first.functions.first;

    final damageRates = [9000, 12000, 13500, 14250, 15000];
    final corrections = [1500, 1625, 1750, 1875, 2000];

    for (int npLv = 1; npLv <= 5; npLv += 1) {
      for (int ocLv = 1; ocLv <= 5; ocLv += 1) {
        expect(getDataVals(yuyuNpDamageFunction, npLv, ocLv).Value, damageRates[npLv - 1]);
        expect(getDataVals(yuyuNpDamageFunction, npLv, ocLv).Correction, corrections[ocLv - 1]);
      }
    }
  });
}
