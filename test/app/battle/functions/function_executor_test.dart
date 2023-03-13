import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;

  final battle = BattleData();
  final playerSettings = [
    PlayerSvtData(504900)
      ..npLv = 1
      ..lv = 90,
    PlayerSvtData(504900)
      ..npLv = 2
      ..lv = 90,
    PlayerSvtData(503900)
      ..npLv = 2
      ..lv = 90,
    PlayerSvtData(503300)
      ..npLv = 2
      ..lv = 90,
    PlayerSvtData(503200)
      ..npLv = 2
      ..lv = 90
  ];

  battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

  final BattleServantData ally = battle.targetedAlly!;
  final BattleServantData enemy = battle.targetedEnemy!;

  group('Test FunctionExecutor.validateFunctionTargetTeam', () {
    test('FuncApplyTarget.enemy', () {
      final BaseFunction enemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.enemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, battle.nonnullAllies), isFalse);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, battle.nonnullEnemies), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, []), isTrue);
    });

    test('FuncApplyTarget.player', () {
      final BaseFunction allyFunciton =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.player);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, battle.nonnullAllies), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, battle.nonnullEnemies), isFalse);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, []), isTrue);
    });

    test('FuncApplyTarget.playerAndEnemy', () {
      final BaseFunction enemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.playerAndEnemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, battle.nonnullAllies), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, battle.nonnullEnemies), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, []), isTrue);
    });
  });

  test('Test FunctionExecutor.getDataVals', () {
    final NiceFunction yuyuNpDamageFunction = db.gameData.servantsById[2500400]!.noblePhantasms.first.functions.first;

    final damageRates = [9000, 12000, 13500, 14250, 15000];
    final corrections = [1500, 1625, 1750, 1875, 2000];

    for (int npLv = 1; npLv <= 5; npLv += 1) {
      for (int ocLv = 1; ocLv <= 5; ocLv += 1) {
        expect(FunctionExecutor.getDataVals(yuyuNpDamageFunction, npLv, ocLv).Value, damageRates[npLv - 1]);
        expect(FunctionExecutor.getDataVals(yuyuNpDamageFunction, npLv, ocLv).Correction, corrections[ocLv - 1]);
      }
    }
  });

  group('Test FunctionExecutor.acquireFunctionTarget', () {
    test('FuncTargetType.self', () {
      final allyTargets = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.self, -1, ally);
      expect(allyTargets.length, 1);
      expect(allyTargets.first, ally);

      final enemyTargets = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.self, -1, enemy);
      expect(enemyTargets.length, 1);
      expect(enemyTargets.first, enemy);
    });

    test('Targeted types', () {
      final ptOne = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOne, -1, battle.onFieldAllyServants[1]);
      expect(ptOne.length, 1);
      expect(ptOne.first, ally);
      expect(ptOne.first, isNot(battle.onFieldAllyServants[1]!));

      final enemyList = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemy, -1, ally);
      expect(enemyList.length, 1);
      expect(enemyList.first, enemy);

      final ptSelectOneSubOnEnemy =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptselectOneSub, -1, battle.onFieldEnemies[1]);
      expect(ptSelectOneSubOnEnemy.length, 1);
      expect(ptSelectOneSubOnEnemy.first, enemy);
      expect(ptSelectOneSubOnEnemy.first, isNot(battle.onFieldEnemies[1]!));
    });

    test('Select all types', () {
      final ptAll = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptAll, -1, battle.onFieldAllyServants[1]);
      expect(ptAll, unorderedEquals(battle.nonnullAllies));

      final ptFull = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptFull, -1, battle.onFieldAllyServants[1]);
      expect(ptFull, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));

      final enemyAll = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyAll, -1, ally);
      expect(enemyAll, unorderedEquals(battle.nonnullEnemies));

      final enemyFullAsEnemy = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyFull, -1, enemy);
      expect(enemyFullAsEnemy, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));
    });

    test('Select other types', () {
      final ptOther = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOther, -1, battle.onFieldAllyServants[1]);
      expect(ptOther, unorderedEquals([battle.onFieldAllyServants[0], battle.onFieldAllyServants[2]]));

      final ptOneOther = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOneOther, -1, battle.onFieldAllyServants[1]);
      expect(ptOneOther, unorderedEquals([battle.onFieldAllyServants[1], battle.onFieldAllyServants[2]]));

      final enemyOther = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOther, -1, ally);
      expect(enemyOther, unorderedEquals([battle.onFieldEnemies[1], battle.onFieldEnemies[2]]));

      final ptOtherFull = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOtherFull, -1, battle.onFieldAllyServants[1]);
      expect(
          ptOtherFull,
          unorderedEquals([
            battle.onFieldAllyServants[0],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));

      final enemyOtherFullAsEnemy = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOtherFull, -1, enemy);
      expect(
          enemyOtherFullAsEnemy,
          unorderedEquals([
            battle.onFieldAllyServants[1],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));
    });

    test('Dynamic types', () {
      final as0 = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[0]);
      expect(as0.length, 1);
      expect(as0.first, battle.onFieldAllyServants[1]);

      final as1 = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
      expect(as1.length, 1);
      expect(as1.first, battle.onFieldAllyServants[0]);

      battle.onFieldAllyServants[0]!.addBuff(
          BuffData(Buff(id: -1, name: '', detail: '', vals: [NiceTrait(id: Trait.cantBeSacrificed.id)]), DataVals()));

      final as1With0Unselectable =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
      expect(as1With0Unselectable.length, 1);
      expect(as1With0Unselectable.first, battle.onFieldAllyServants[2]);

      battle.onFieldAllyServants[0]!.battleBuff.activeList.removeLast();

      final as1AfterRemove =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
      expect(as1AfterRemove.length, 1);
      expect(as1AfterRemove.first, battle.onFieldAllyServants[0]);
    });
  });

  group('Integration', () {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(403700) // nemo
        ..npLv = 1
        ..lv = 90,
      PlayerSvtData(300500) // eli
        ..skillStrengthenLvs = [2, 1, 1]
        ..npLv = 2
        ..lv = 80,
      PlayerSvtData(1101100) // kama
        ..npLv = 5
        ..lv = 120,
    ];

    test('Field traits tests', () {
      battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null); // no field traits
      final buffCountBefore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfter = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore + 1);

      battle.init(db.gameData.questPhases[9300030103]!, playerSettings, null); // field shore
      final buffCountBeforeShore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfterShore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountAfterShore, buffCountBeforeShore + 2);
    });

    test('Function checks target trait', () {
      battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final buffCountNemoBefore = battle.onFieldAllyServants[0]!.battleBuff.activeList.length;
      final buffCountEliBefore = battle.onFieldAllyServants[1]!.battleBuff.activeList.length;
      final buffCountKamaBefore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      battle.activateSvtSkill(1, 0); // Eli skill 1, check female
      final buffCountNemoAfter = battle.onFieldAllyServants[0]!.battleBuff.activeList.length;
      final buffCountEliAfter = battle.onFieldAllyServants[1]!.battleBuff.activeList.length;
      final buffCountKamaAfter = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountNemoAfter, buffCountNemoBefore + 1);
      expect(buffCountEliAfter, buffCountEliBefore + 1);
      expect(buffCountKamaAfter, buffCountKamaBefore + 2);
    });

    test('Function checks target alive', () {
      battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      battle.activateSvtSkill(2, 2); // Kama skill 2, just to guarantee kill
      final buffCountBefore = battle.onFieldEnemies[2]!.battleBuff.activeList.length;
      final npActions = [CombatAction(battle.onFieldAllyServants[2]!, battle.onFieldAllyServants[2]!.getNPCard()!)];
      battle.playerTurn(npActions);
      final buffCountAfter = battle.onFieldEnemies[2]!.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore);
    });
  });

  group('Individual function types', () {
    test('addState', () {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(800100)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 3
          ..lv = 80,
      ];
      battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;
      expect(mash.battleBuff.activeList.length, 0);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1000);

      battle.activateSvtSkill(0, 0);
      expect(mash.battleBuff.activeList.length, 1);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.turn, 3);

      battle.playerTurn([CombatAction(mash, mash.getCards()[0])]);
      expect(mash.battleBuff.activeList.length, 1);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.turn, 2);
    });
  });
}
