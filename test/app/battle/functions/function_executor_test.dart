import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
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

  await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

  final BattleServantData ally = battle.targetedAlly!;
  final BattleServantData enemy = battle.targetedEnemy!;

  group('Test FunctionExecutor.validateFunctionTargetTeam', () {
    test('FuncApplyTarget.enemy', () {
      final BaseFunction enemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.enemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, ally), isFalse);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, enemy), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, null), isTrue);
    });

    test('FuncApplyTarget.player', () {
      final BaseFunction allyFunciton =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.player);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, ally), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, enemy), isFalse);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunciton, null), isTrue);
    });

    test('FuncApplyTarget.playerAndEnemy', () {
      final BaseFunction playerAndEnemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.playerAndEnemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(playerAndEnemyFunction, ally), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(playerAndEnemyFunction, enemy), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(playerAndEnemyFunction, null), isTrue);
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
      final ptOne =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOne, -1, battle.onFieldAllyServants[1]);
      expect(ptOne.length, 1);
      expect(ptOne.first, ally);
      expect(ptOne.first, isNot(battle.onFieldAllyServants[1]!));

      final enemyList = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemy, -1, ally);
      expect(enemyList.length, 1);
      expect(enemyList.first, enemy);
    });

    test('Select all types', () {
      final ptAll =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptAll, -1, battle.onFieldAllyServants[1]);
      expect(ptAll, unorderedEquals(battle.nonnullAllies));

      final ptFull =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptFull, -1, battle.onFieldAllyServants[1]);
      expect(ptFull, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));

      final enemyAll = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyAll, -1, ally);
      expect(enemyAll, unorderedEquals(battle.nonnullEnemies));

      final enemyFullAsEnemy = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyFull, -1, enemy);
      expect(enemyFullAsEnemy, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));
    });

    test('Select other types', () {
      final ptOther =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOther, -1, battle.onFieldAllyServants[1]);
      expect(ptOther, unorderedEquals([battle.onFieldAllyServants[0], battle.onFieldAllyServants[2]]));

      final ptOneOther =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOneOther, -1, battle.onFieldAllyServants[1]);
      expect(ptOneOther, unorderedEquals([battle.onFieldAllyServants[1], battle.onFieldAllyServants[2]]));

      final enemyOther = FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOther, -1, ally);
      expect(enemyOther, unorderedEquals([battle.onFieldEnemies[1], battle.onFieldEnemies[2]]));

      final ptOtherFull =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOtherFull, -1, battle.onFieldAllyServants[1]);
      expect(
          ptOtherFull,
          unorderedEquals([
            battle.onFieldAllyServants[0],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));

      final enemyOtherFullAsEnemy =
          FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOtherFull, -1, enemy);
      expect(
          enemyOtherFullAsEnemy,
          unorderedEquals([
            battle.onFieldAllyServants[1],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));
    });

    test('Dynamic types', () {
      final as0 = FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[0]);
      expect(as0.length, 1);
      expect(as0.first, battle.onFieldAllyServants[1]);

      final as1 = FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
      expect(as1.length, 1);
      expect(as1.first, battle.onFieldAllyServants[0]);

      battle.onFieldAllyServants[0]!.addBuff(
          BuffData(Buff(id: -1, name: '', detail: '', vals: [NiceTrait(id: Trait.cantBeSacrificed.id)]), DataVals()));

      final as1With0Unselectable = FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
      expect(as1With0Unselectable.length, 1);
      expect(as1With0Unselectable.first, battle.onFieldAllyServants[2]);

      battle.onFieldAllyServants[0]!.battleBuff.activeList.removeLast();

      final as1AfterRemove = FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, -1, battle.onFieldAllyServants[1]);
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

    test('Field traits tests', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null); // no field traits
      final buffCountBefore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfter = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore + 1);

      await battle.init(db.gameData.questPhases[9300030103]!, playerSettings, null); // field shore
      final buffCountBeforeShore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfterShore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountAfterShore, buffCountBeforeShore + 2);
    });

    test('Function checks target trait', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final buffCountNemoBefore = battle.onFieldAllyServants[0]!.battleBuff.activeList.length;
      final buffCountEliBefore = battle.onFieldAllyServants[1]!.battleBuff.activeList.length;
      final buffCountKamaBefore = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      await battle.activateSvtSkill(1, 0); // Eli skill 1, check female
      final buffCountNemoAfter = battle.onFieldAllyServants[0]!.battleBuff.activeList.length;
      final buffCountEliAfter = battle.onFieldAllyServants[1]!.battleBuff.activeList.length;
      final buffCountKamaAfter = battle.onFieldAllyServants[2]!.battleBuff.activeList.length;
      expect(buffCountNemoAfter, buffCountNemoBefore + 1);
      expect(buffCountEliAfter, buffCountEliBefore + 1);
      expect(buffCountKamaAfter, buffCountKamaBefore + 2);
    });

    test('Function checks target alive', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      await battle.activateSvtSkill(2, 2); // Kama skill 2, just to guarantee kill
      final buffCountBefore = battle.onFieldEnemies[2]!.battleBuff.activeList.length;
      final npActions = [
        CombatAction(battle.onFieldAllyServants[2]!, battle.onFieldAllyServants[2]!.getNPCard(battle)!)
      ];
      await battle.playerTurn(npActions);
      final buffCountAfter = battle.onFieldEnemies[2]!.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore);
    });
  });

  group('Individual function types', () {
    test('addState', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(800100)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 3
          ..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;
      expect(mash.battleBuff.activeList.length, 0);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 0);
      expect(mash.battleBuff.activeList.length, 1);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.turn, 3);

      await battle.playerTurn([CombatAction(mash, mash.getCards(battle)[0])]);
      expect(mash.battleBuff.activeList.length, 1);
      expect(mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.turn, 2);
    });

    test('addFieldChangeToField', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(2300500)
          ..npLv = 3
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData(2300500)
          ..npLv = 3
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final archType1 = battle.onFieldAllyServants[0]!;
      final archType2 = battle.onFieldAllyServants[1]!;

      expect(battle.getFieldTraits().map((e) => e.id).contains(Trait.milleniumCastle.id), isFalse);

      await battle.playerTurn([CombatAction(archType1, archType1.getNPCard(battle)!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.id).length, 1);

      await battle.playerTurn([CombatAction(archType2, archType1.getNPCard(battle)!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.id).length, 2);

      await battle.activateSvtSkill(0, 1);
      await battle.playerTurn([CombatAction(archType1, archType1.getNPCard(battle)!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.id).length, 2);

      // kill one to remove buff
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final archType3 = battle.onFieldAllyServants[0]!;
      final archType4 = battle.onFieldAllyServants[1]!;

      expect(battle.getFieldTraits().map((e) => e.id).contains(Trait.milleniumCastle.id), isFalse);

      await battle.playerTurn([CombatAction(archType3, archType3.getNPCard(battle)!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.id).length, 1);

      archType3.hp = 0;

      await battle.playerTurn([CombatAction(archType4, archType4.getNPCard(battle)!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.id).length, 1);
    });

    test('gainStar', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(501500)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 3
          ..lv = 60,
        PlayerSvtData(501500)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 3
          ..lv = 60,
        PlayerSvtData(501500)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 3
          ..lv = 60,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.001));
      await battle.activateSvtSkill(0, 2);
      expect(battle.criticalStars, moreOrLessEquals(50, epsilon: 0.001));
      await battle.activateSvtSkill(1, 2);
      expect(battle.criticalStars, moreOrLessEquals(99, epsilon: 0.001));
      await battle.activateSvtSkill(2, 2);
      expect(battle.criticalStars, moreOrLessEquals(99, epsilon: 0.001));
    });

    test('subState affectTraits', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(701600)
          ..lv = 80
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData(2800100)..lv = 90,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final cat = battle.onFieldAllyServants[0]!;

      await battle.activateSvtSkill(1, 2);

      expect(collectBuffsPerType(cat.battleBuff.allBuffs, BuffType.donotAct).length, 0);

      await battle.playerTurn([CombatAction(cat, cat.getNPCard(battle)!)]);

      expect(collectBuffsPerType(cat.battleBuff.allBuffs, BuffType.donotAct).length, 2);
    });

    test('subState count', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(1000100)..lv = 80,
        PlayerSvtData(2300300)..lv = 90,
        PlayerSvtData(203900)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final lip = battle.onFieldAllyServants[0]!;

      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 2);

      expect(collectBuffsPerType(lip.battleBuff.allBuffs, BuffType.donotAct).length, 1);
      expect(collectBuffsPerType(lip.battleBuff.allBuffs, BuffType.donotSkill).length, 1);

      await battle.activateSvtSkill(2, 0);

      expect(collectBuffsPerType(lip.battleBuff.allBuffs, BuffType.donotAct).length, 1);
      expect(collectBuffsPerType(lip.battleBuff.allBuffs, BuffType.donotSkill).length, 0);
    });

    test('gainNpFromTargets', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(304000)
          ..skillLvs = [9, 9, 9]
          ..npLv = 3
          ..lv = 80,
        PlayerSvtData(2500400)
          ..skillLvs = [9, 9, 9]
          ..appendLvs = [0, 10, 0]
          ..npLv = 3
          ..lv = 90,
        PlayerSvtData(2500400)
          ..skillLvs = [9, 9, 9]
          ..npLv = 3
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final lambda = battle.onFieldAllyServants[0]!;
      final yuyu1 = battle.onFieldAllyServants[1]!;
      final yuyu2 = battle.onFieldAllyServants[2]!;
      final enemy = battle.onFieldEnemies[0]!;

      expect(lambda.np, 0);
      expect(yuyu1.np, 2000);
      expect(yuyu2.np, 10000);
      expect(enemy.npLineCount, 0);

      await battle.activateSvtSkill(0, 2);

      expect(lambda.np, 4800);
      expect(yuyu1.np, 0);
      expect(yuyu2.np, 7200);
      expect(enemy.npLineCount, 0);

      await battle.activateSvtSkill(1, 1);

      expect(lambda.np, 4800);
      expect(yuyu1.np, 0);
      expect(yuyu2.np, 7200);
      expect(enemy.npLineCount, 0);

      await battle.playerTurn([CombatAction(yuyu2, yuyu2.getCards(battle).last)]); // buster card

      expect(lambda.np, 4800);
      expect(yuyu1.np, 0);
      expect(yuyu2.np, 7200);
      expect(enemy.npLineCount, 1);

      await battle.activateSvtSkill(2, 1);

      expect(lambda.np, 4800);
      expect(yuyu1.np, 0);
      expect(yuyu2.np, 7200 + 1800 * 3);
      expect(enemy.npLineCount, 0);
    });
  });
}
