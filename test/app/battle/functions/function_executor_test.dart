import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  final battle = BattleData();
  final playerSettings = [
    PlayerSvtData.id(504900)
      ..tdLv = 1
      ..lv = 90,
    PlayerSvtData.id(504900)
      ..tdLv = 2
      ..lv = 90,
    PlayerSvtData.id(503900)
      ..tdLv = 2
      ..lv = 90,
    PlayerSvtData.id(503300)
      ..tdLv = 2
      ..lv = 90,
    PlayerSvtData.id(503200)
      ..tdLv = 2
      ..lv = 90
  ];

  await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

  final BattleServantData ally = battle.targetedAlly!;
  final BattleServantData enemy = battle.targetedEnemy!;

  group('Test FunctionExecutor.validateFunctionTargetTeam', () {
    test('FuncApplyTarget.enemy', () {
      final BaseFunction enemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.enemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, ally.isPlayer), isFalse);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, enemy.isPlayer), isTrue);
    });

    test('FuncApplyTarget.player', () {
      final BaseFunction allyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.player);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, enemy.isPlayer), isFalse);
    });

    test('FuncApplyTarget.playerAndEnemy', () {
      final BaseFunction playerAndEnemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.self, funcTargetTeam: FuncApplyTarget.playerAndEnemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(playerAndEnemyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(playerAndEnemyFunction, enemy.isPlayer), isTrue);
    });

    test('FuncTargetType.fieldOther', () {
      final BaseFunction allyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.fieldOther, funcTargetTeam: FuncApplyTarget.player);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, enemy.isPlayer), isTrue);

      final BaseFunction enemyFunction =
          BaseFunction(funcId: -1, funcTargetType: FuncTargetType.fieldOther, funcTargetTeam: FuncApplyTarget.enemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, enemy.isPlayer), isTrue);
    });

    test('FuncTargetType.enemyOneNoTargetNoAction', () {
      final BaseFunction allyFunction = BaseFunction(
          funcId: -1, funcTargetType: FuncTargetType.enemyOneNoTargetNoAction, funcTargetTeam: FuncApplyTarget.player);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(allyFunction, enemy.isPlayer), isTrue);

      final BaseFunction enemyFunction = BaseFunction(
          funcId: -1, funcTargetType: FuncTargetType.enemyOneNoTargetNoAction, funcTargetTeam: FuncApplyTarget.enemy);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, ally.isPlayer), isTrue);
      expect(FunctionExecutor.validateFunctionTargetTeam(enemyFunction, enemy.isPlayer), isTrue);
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
    test('FuncTargetType.self', () async {
      final allyTargets = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.self, ally);
      expect(allyTargets.length, 1);
      expect(allyTargets.first, ally);

      final enemyTargets = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.self, enemy);
      expect(enemyTargets.length, 1);
      expect(enemyTargets.first, enemy);
    });

    test('Targeted types', () async {
      final ptOne =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOne, battle.onFieldAllyServants[1]);
      expect(ptOne.length, 1);
      expect(ptOne.first, ally);
      expect(ptOne.first, isNot(battle.onFieldAllyServants[1]!));

      final enemyList = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemy, ally);
      expect(enemyList.length, 1);
      expect(enemyList.first, enemy);
    });

    test('Select all types', () async {
      final ptAll =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptAll, battle.onFieldAllyServants[1]);
      expect(ptAll, unorderedEquals(battle.nonnullAllies));

      final ptFull =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptFull, battle.onFieldAllyServants[1]);
      expect(ptFull, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));

      final enemyAll = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyAll, ally);
      expect(enemyAll, unorderedEquals(battle.nonnullEnemies));

      final enemyFullAsEnemy = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyFull, enemy);
      expect(enemyFullAsEnemy, unorderedEquals([...battle.nonnullAllies, ...battle.nonnullBackupAllies]));
    });

    test('Select other types', () async {
      final ptOther =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptOther, battle.onFieldAllyServants[1]);
      expect(ptOther, unorderedEquals([battle.onFieldAllyServants[0], battle.onFieldAllyServants[2]]));

      final ptOneOther = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptOneOther, battle.onFieldAllyServants[1]);
      expect(ptOneOther, unorderedEquals([battle.onFieldAllyServants[1], battle.onFieldAllyServants[2]]));

      final enemyOther = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOther, ally);
      expect(enemyOther, unorderedEquals([battle.onFieldEnemies[1], battle.onFieldEnemies[2]]));

      final ptOtherFull = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptOtherFull, battle.onFieldAllyServants[1]);
      expect(
          ptOtherFull,
          unorderedEquals([
            battle.onFieldAllyServants[0],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));

      final enemyOtherFullAsEnemy =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOtherFull, enemy);
      expect(
          enemyOtherFullAsEnemy,
          unorderedEquals([
            battle.onFieldAllyServants[1],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupAllies,
          ]));
    });

    test('Dynamic types', () async {
      final as0 = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, battle.onFieldAllyServants[0]);
      expect(as0.length, 1);
      expect(as0.first, battle.onFieldAllyServants[1]);

      final as1 = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, battle.onFieldAllyServants[1]);
      expect(as1.length, 1);
      expect(as1.first, battle.onFieldAllyServants[0]);

      battle.onFieldAllyServants[0]!.addBuff(
          BuffData(Buff(id: -1, name: '', detail: '', vals: [NiceTrait(id: Trait.cantBeSacrificed.id)]), DataVals()));

      final as1With0Unselectable = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, battle.onFieldAllyServants[1]);
      expect(as1With0Unselectable.length, 1);
      expect(as1With0Unselectable.first, battle.onFieldAllyServants[2]);

      battle.onFieldAllyServants[0]!.battleBuff.activeList.removeLast();

      final as1AfterRemove = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, battle.onFieldAllyServants[1]);
      expect(as1AfterRemove.length, 1);
      expect(as1AfterRemove.first, battle.onFieldAllyServants[0]);
    });
  });

  group('Integration', () {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData.id(403700) // nemo
        ..tdLv = 1
        ..lv = 90,
      PlayerSvtData.id(300500) // eli
        ..setSkillStrengthenLvs([2, 1, 1])
        ..tdLv = 2
        ..lv = 80,
      PlayerSvtData.id(1101100) // kama
        ..tdLv = 5
        ..lv = 120,
    ];

    test('Field traits tests', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null); // no field traits
      final nemo1 = battle.onFieldAllyServants[0]!;
      final buffCountBefore = nemo1.battleBuff.activeList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfter = nemo1.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore + 1);
      expect(battle.actionHistory[6010]![nemo1.uniqueId], false);

      await battle.init(db.gameData.questPhases[9300030103]!, playerSettings, null); // field shore
      final nemo2 = battle.onFieldAllyServants[0]!;
      final buffCountBeforeShore = nemo2.battleBuff.activeList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfterShore = nemo2.battleBuff.activeList.length;
      expect(buffCountAfterShore, buffCountBeforeShore + 2);
      expect(battle.actionHistory[6010]![nemo1.uniqueId], true);
    });

    test('Function checks target trait', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final nemo = battle.onFieldAllyServants[0]!;
      final eli = battle.onFieldAllyServants[1]!;
      final kama = battle.onFieldAllyServants[2]!;
      final buffCountNemoBefore = nemo.battleBuff.activeList.length;
      final buffCountEliBefore = eli.battleBuff.activeList.length;
      final buffCountKamaBefore = kama.battleBuff.activeList.length;
      await battle.activateSvtSkill(1, 0); // Eli skill 1, check female
      final buffCountNemoAfter = nemo.battleBuff.activeList.length;
      final buffCountEliAfter = eli.battleBuff.activeList.length;
      final buffCountKamaAfter = kama.battleBuff.activeList.length;
      expect(buffCountNemoAfter, buffCountNemoBefore + 1);
      expect(buffCountEliAfter, buffCountEliBefore + 1);
      expect(buffCountKamaAfter, buffCountKamaBefore + 2);

      // last skill is on female targets except self
      expect(battle.actionHistory.length, 2);
      expect(battle.actionHistory[1137]![nemo.uniqueId], false);
      expect(battle.actionHistory[1137]![eli.uniqueId], null);
      expect(battle.actionHistory[1137]![kama.uniqueId], true);
    });

    test('Function checks target alive', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final kama = battle.onFieldAllyServants[2]!;
      kama.np = 10000;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;
      await battle.activateSvtSkill(2, 1); // Kama skill 2, just to guarantee kill
      final buffCountBefore = enemy2.battleBuff.activeList.length;
      final npCard = kama.getNPCard(battle)!;
      battle.recorder.startPlayerCard(kama, npCard);
      await battle.withAction(() async {
        await battle.withCard(npCard, () async {
          await kama.activateNP(battle, npCard, 0);
        });
      });
      final buffCountAfter = enemy2.battleBuff.activeList.length;
      expect(buffCountAfter, buffCountBefore);

      // last func is addState on dead enemies
      expect(battle.actionHistory.length, 2);
      expect(battle.actionHistory[197]!.length, 3);
      expect(battle.actionHistory[197]![enemy1.uniqueId], false);
      expect(battle.actionHistory[197]![enemy2.uniqueId], false);
      expect(battle.actionHistory[197]![enemy3.uniqueId], false);
    });

    test('TriggeredFuncPosition', () async {
      await battle.init(
          db.gameData.questPhases[9300040603]!,
          [
            PlayerSvtData.id(600200) // cursed arm
              ..tdLv = 5
              ..setNpStrengthenLv(2)
              ..lv = 65,
          ],
          null); // no field traits
      final enemy1 = battle.onFieldEnemies[0]!;
      final cursedArm = battle.onFieldAllyServants[0]!;
      final npCard = cursedArm.getNPCard(battle)!;
      final buffCountBefore1 = cursedArm.battleBuff.activeList.length;
      cursedArm.np = 10000;
      battle.recorder.startPlayerCard(cursedArm, npCard);
      await battle.withAction(() async {
        await battle.withCard(npCard, () async {
          await cursedArm.activateNP(battle, npCard, 0);
        });
      });
      final buffCountAfter1 = cursedArm.battleBuff.activeList.length;
      expect(buffCountAfter1, buffCountBefore1);
      expect(battle.actionHistory[479]![enemy1.uniqueId], false);
      expect(battle.actionHistory[146]![cursedArm.uniqueId], false);
      expect(battle.actionHistory[460]![cursedArm.uniqueId], false);
      expect(battle.actionHistory[470], null);
      expect(battle.actionHistory[12]![enemy1.uniqueId], true);

      battle.enemyTargetIndex = 1;
      final enemy2 = battle.onFieldEnemies[1]!;
      final buffCountBefore2 = cursedArm.battleBuff.activeList.length;
      cursedArm.np = 10000;
      battle.options.probabilityThreshold = 10;
      battle.recorder.startPlayerCard(cursedArm, npCard);
      await battle.withAction(() async {
        await battle.withCard(npCard, () async {
          await cursedArm.activateNP(battle, npCard, 0);
        });
      });
      final buffCountAfter2 = cursedArm.battleBuff.activeList.length;
      expect(buffCountAfter2, buffCountBefore2 + 1);
      expect(battle.actionHistory[479]![enemy2.uniqueId], true);
      expect(battle.actionHistory[146]![cursedArm.uniqueId], true);
      expect(battle.actionHistory[460]![cursedArm.uniqueId], true);
      expect(battle.actionHistory[470], null);
      expect(battle.actionHistory[12]![enemy2.uniqueId], false);
    });
  });

  group('Individual function types', () {
    test('addState', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(800100)
          ..setSkillStrengthenLvs([1, 1, 1])
          ..tdLv = 3
          ..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;
      expect(mash.battleBuff.activeList.length, 0);
      expect(await mash.getBuffValueOnAction(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 0);
      expect(mash.battleBuff.activeList.length, 1);
      expect(await mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.logicTurn, 6);

      await battle.playerTurn([CombatAction(mash, mash.getCards(battle)[0])]);
      expect(mash.battleBuff.activeList.length, 1);
      expect(await mash.getBuffValueOnAction(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.activeList.first.logicTurn, 4);
    });

    test('addState & addStateShort', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(200900),
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final orion = battle.onFieldAllyServants[0]!;
      expect(orion.battleBuff.activeList.length, 0);
      expect(await orion.getBuffValueOnAction(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 0);
      expect(orion.battleBuff.activeList.length, 3);
      expect(await orion.getBuffValueOnAction(battle, BuffAction.defence), 1500);
      expect(orion.battleBuff.activeList.first.buff.type, BuffType.upDefence);
      expect(orion.battleBuff.activeList.first.logicTurn, 2);
      expect(await orion.getBuffValueOnAction(battle, BuffAction.atk), 1200);
      expect(orion.battleBuff.activeList[1].buff.type, BuffType.upAtk);
      expect(orion.battleBuff.activeList[1].logicTurn, 5);

      await battle.playerTurn([CombatAction(orion, orion.getCards(battle)[0])]);
      expect(orion.battleBuff.activeList.length, 2);
      expect(await orion.getBuffValueOnAction(battle, BuffAction.defence), 1000);
      expect(await orion.getBuffValueOnAction(battle, BuffAction.atk), 1200);
      expect(orion.battleBuff.activeList[0].buff.type, BuffType.upAtk);
      expect(orion.battleBuff.activeList[0].logicTurn, 3);
    });

    test('addFieldChangeToField', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(2300500)
          ..tdLv = 3
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(2300500)
          ..tdLv = 3
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
        PlayerSvtData.id(501500)
          ..setSkillStrengthenLvs([1, 1, 1])
          ..tdLv = 3
          ..lv = 60,
        PlayerSvtData.id(501500)
          ..setSkillStrengthenLvs([1, 1, 1])
          ..tdLv = 3
          ..lv = 60,
        PlayerSvtData.id(501500)
          ..setSkillStrengthenLvs([1, 1, 1])
          ..tdLv = 3
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

    test('gainStar Per target', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(501500)..lv = 60,
        PlayerSvtData.id(504600)..lv = 60,
        PlayerSvtData.id(100100)..lv = 60,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.001));
      await battle.activateSvtSkill(1, 0);
      expect(battle.criticalStars, moreOrLessEquals(10, epsilon: 0.001));
      expect(battle.actionHistory[7015]!.length, 2);
      expect(battle.actionHistory[7015]![battle.onFieldAllyServants[0]!.uniqueId], false);
      expect(battle.actionHistory[7015]![battle.onFieldAllyServants[2]!.uniqueId], true);
    });

    test('subState affectTraits', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(701600)
          ..lv = 80
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(2800100)..lv = 90,
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
        PlayerSvtData.id(1000100)..lv = 80,
        PlayerSvtData.id(2300300)..lv = 90,
        PlayerSvtData.id(203900)..lv = 80,
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
        PlayerSvtData.id(304000)
          ..skillLvs = [9, 9, 9]
          ..tdLv = 3
          ..lv = 80,
        PlayerSvtData.id(2500400)
          ..skillLvs = [9, 9, 9]
          ..appendLvs = [0, 10, 0]
          ..tdLv = 3
          ..lv = 90,
        PlayerSvtData.id(2500400)
          ..skillLvs = [9, 9, 9]
          ..tdLv = 3
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

    test('moveToLastSubMember', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(1000100)..lv = 80,
        PlayerSvtData.id(2300300)
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9404120] // 20 star on entry
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(504600)
          ..lv = 80
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(504500)..lv = 80,
        PlayerSvtData.id(504900)..lv = 90,
        PlayerSvtData.id(503900)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final onField1 = battle.onFieldAllyServants[0]!;
      final onField2 = battle.onFieldAllyServants[1]!;
      final crane = battle.onFieldAllyServants[2]!;
      final backup1 = battle.playerDataList[0]!;
      final backup2 = battle.playerDataList[1]!;
      final backup3 = battle.playerDataList[2]!;
      expect(onField1.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(crane.fieldIndex, 2);
      expect(backup1.fieldIndex, 3);
      expect(backup2.fieldIndex, 4);
      expect(backup3.fieldIndex, 5);
      expect(battle.canUseNp(2), true);

      await battle.playerTurn([CombatAction(crane, crane.getNPCard(battle)!)]);

      expect(battle.playerDataList.length, 3);
      expect(battle.playerDataList.last, crane);
      expect(onField1.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(backup1.fieldIndex, 2);
      expect(backup2.fieldIndex, 3);
      expect(backup3.fieldIndex, 4);
      expect(crane.fieldIndex, 5);
    });

    test('DataVals IncludePassiveIndividuality', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(105200)
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(105200)
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final charlie1 = battle.onFieldAllyServants[0]!;
      final charlie2 = battle.onFieldAllyServants[1]!;
      final prevCount1 = charlie1.battleBuff.allBuffs.length;
      final prevCount2 = charlie2.battleBuff.allBuffs.length;

      await battle.activateSvtSkill(0, 0);

      final afterCount1 = charlie1.battleBuff.allBuffs.length;

      expect(afterCount1, prevCount1 + 2);
      expect(charlie1.canNP(battle), false);

      await battle.activateSvtSkill(1, 0);

      final afterCount2 = charlie2.battleBuff.allBuffs.length;

      expect(afterCount2, prevCount2 + 2);
      expect(charlie2.canNP(battle), true);
    });

    test('DataVals SameBuffLimitNum', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(1000900)
          ..setSkillStrengthenLvs([2, 1, 2])
          ..lv = 90,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final kingprotea = battle.onFieldAllyServants[0]!;

      final prevCount = kingprotea.battleBuff.allBuffs.length;

      await battle.activateSvtSkill(0, 0);

      for (int i = 0; i < 10; i += 1) {
        await battle.playerTurn([CombatAction(kingprotea, kingprotea.getCards(battle)[0])]);
      }

      final afterCount = kingprotea.battleBuff.allBuffs.length;

      expect(afterCount, prevCount + 20);

      await battle.activateSvtSkill(0, 0);

      for (int i = 0; i < 10; i += 1) {
        await battle.playerTurn([CombatAction(kingprotea, kingprotea.getCards(battle)[0])]);
      }

      final afterCount2 = kingprotea.battleBuff.allBuffs.length;

      expect(afterCount2, prevCount + 20);
    });

    test('DataVals StarHigher', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(203700)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final jane = battle.onFieldAllyServants[0]!;
      final prevCount = jane.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(0, 2);
      final afterCount = jane.battleBuff.allBuffs.length;
      expect(afterCount, prevCount + 1);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      battle.criticalStars = 20;
      final jane2 = battle.onFieldAllyServants[0]!;
      final prevCount2 = jane2.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(0, 2);
      final afterCount2 = jane2.battleBuff.allBuffs.length;
      expect(afterCount2, prevCount2 + 3);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      battle.criticalStars = 50;
      final jane3 = battle.onFieldAllyServants[0]!;
      final prevCount3 = jane3.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(0, 2);
      final afterCount3 = jane3.battleBuff.allBuffs.length;
      expect(afterCount3, prevCount3 + 5);
      expect(jane3.np, 2000);
    });

    test('DataVals Negative Rates', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(501100)..lv = 70,
        PlayerSvtData.id(2300100)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final babbage = battle.onFieldAllyServants[0]!;
      final prevCount = babbage.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(0, 2);
      final afterCount = babbage.battleBuff.allBuffs.length;
      expect(afterCount, prevCount + 3);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final babbage2 = battle.onFieldAllyServants[0]!;
      final prevCount2 = babbage2.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(1, 0);
      await battle.activateSvtSkill(0, 2);
      final afterCount2 = babbage2.battleBuff.allBuffs.length;
      expect(afterCount2, prevCount2 + 1);
    });

    test('damageNpHpratioLow', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(702500)
          ..lv = 90
          ..setNpStrengthenLv(2)
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final toshizo = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp1 = enemy1.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard(battle)!)]);
      expect(prevHp1 - enemy1.hp, 107144);

      toshizo.hp = toshizo.getMaxHp(battle) ~/ 2;
      toshizo.np = 10000;
      final prevHp2 = enemy2.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard(battle)!)]);
      expect((prevHp2 - enemy2.hp).toDouble(), moreOrLessEquals(142859, epsilon: 5));

      toshizo.hp = 1;
      toshizo.np = 10000;
      final prevHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard(battle)!)]);
      expect((prevHp3 - enemy3.hp).toDouble(), moreOrLessEquals(178567, epsilon: 5));

      final enemy4 = battle.onFieldEnemies[0]!;
      toshizo.np = 30000;
      final prevHp4 = enemy4.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard(battle)!)]);
      expect((prevHp4 - enemy4.hp).toDouble(), moreOrLessEquals(196424, epsilon: 5));
    });

    test('damageNpIndividualSum enemyBuff', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(2300400)
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(2500700)..lv = 90,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 0);
      await battle.activateSvtSkill(1, 1);

      final kiara = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp1 = enemy1.hp;
      final prevHp2 = enemy2.hp;
      final prevHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard(battle)!)]);
      expect(prevHp1 - enemy1.hp, 88719);
      expect(prevHp2 - enemy2.hp, 57200);
      expect(prevHp3 - enemy3.hp, 57200);
    });

    test('damageNpIndividualSum selfTrait', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(1001300)
          ..lv = 90
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final bunyan = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final prevHp1 = enemy1.hp;
      await battle.playerTurn([CombatAction(bunyan, bunyan.getNPCard(battle)!)]);
      expect(prevHp1 - enemy1.hp, 20323);

      final enemy2 = battle.onFieldEnemies[1]!;
      final prevHp2 = enemy2.hp;
      await battle.playerTurn([
        CombatAction(bunyan, bunyan.getCards(battle)[0]),
        CombatAction(bunyan, bunyan.getCards(battle)[1]),
        CombatAction(bunyan, bunyan.getCards(battle)[2]),
      ]);
      expect(prevHp2 - enemy2.hp, 5283 + 6909 + 10567 + 12193);

      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp3 = enemy3.hp;
      bunyan.np = 10000;
      await battle.playerTurn([CombatAction(bunyan, bunyan.getNPCard(battle)!)]);
      expect(prevHp3 - enemy3.hp, 25403);
    });

    test('damageNpRare', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(403400)
          ..lv = 60
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final roberts = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp1 = enemy1.hp;
      final prevHp2 = enemy2.hp;
      final prevHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(roberts, roberts.getNPCard(battle)!)]);
      expect(prevHp1 - enemy1.hp, 24043);
      expect(prevHp2 - enemy2.hp, 48087);
      expect(prevHp3 - enemy3.hp, 24043);
    });

    test('instantDeath', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(2300400)
          ..lv = 1
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final kiara = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard(battle)!)]);
      expect(battle.waveCount, 1);
      expect(enemy1.hp, greaterThan(0));
      expect(enemy2.hp, greaterThan(0));
      expect(enemy3.hp, greaterThan(0));
      expect(battle.nonnullEnemies.length, 3);

      battle.options.probabilityThreshold = 800;
      kiara.np = 10000;
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard(battle)!)]);
      expect(enemy1.hp, 0);
      expect(enemy2.hp, 0);
      expect(enemy3.hp, 0);
    });

    test('forceInstantDeath', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(201300)
          ..lv = 60
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(701400)
          ..lv = 90
          ..setSkillStrengthenLvs([2, 1, 1]),
        PlayerSvtData.id(701400)
          ..lv = 90
          ..setSkillStrengthenLvs([2, 1, 1]),
        PlayerSvtData.id(701400)
          ..lv = 90
          ..setSkillStrengthenLvs([2, 1, 1]),
        PlayerSvtData.id(701400)
          ..lv = 90
          ..setSkillStrengthenLvs([2, 1, 1]),
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);
      final arash = battle.onFieldAllyServants[0]!;
      final onField2 = battle.onFieldAllyServants[1]!;
      final onField3 = battle.onFieldAllyServants[2]!;
      final backup1 = battle.playerDataList[0]!;
      final backup2 = battle.playerDataList[1]!;
      expect(arash.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(onField3.fieldIndex, 2);
      expect(backup1.fieldIndex, 3);
      expect(backup2.fieldIndex, 4);
      expect(battle.playerDataList.length, 2);
      await battle.activateSvtSkill(1, 0);
      await battle.playerTurn([CombatAction(arash, arash.getNPCard(battle)!)]);

      expect(arash.hp, 0);
      expect(arash.fieldIndex, -1);
      expect(backup1.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(onField3.fieldIndex, 2);
      expect(backup2.fieldIndex, 3);
      expect(battle.playerDataList.length, 1);
    });

    test('lossHpSafe & gainHp', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(604200)..lv = 90,
        PlayerSvtData.id(701400)
          ..lv = 90
          ..setSkillStrengthenLvs([2, 1, 1]),
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final koyan = battle.onFieldAllyServants[0]!;
      final nightingale = battle.onFieldAllyServants[1]!;

      koyan.hp = 501;
      final prevNightingaleHp = nightingale.hp;
      await battle.activateSvtSkill(0, 0);
      expect(koyan.hp, 1);
      expect(prevNightingaleHp - nightingale.hp, 1000);

      await battle.activateSvtSkill(1, 0);
      expect(koyan.hp, 4001);
      expect(prevNightingaleHp - nightingale.hp, 1000);
    });

    test('gainHpPerTarget', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(403600)..lv = 80,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final carmilla = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;

      carmilla.hp = 1000;
      final prevHp1 = enemy1.hp;
      enemy2.hp = 1500;
      final prevHp3 = enemy3.hp;
      await battle.activateSvtSkill(0, 2);
      expect(carmilla.hp, 1499 + 2000 + 2000 + 1000);
      expect(prevHp1 - enemy1.hp, 2000);
      expect(enemy2.hp, 1);
      expect(prevHp3 - enemy3.hp, 2000);
    });

    test('gainNpBuffIndividualSum & moveState', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(2500600)..lv = 90,
        PlayerSvtData.id(1000900)..lv = 90,
        PlayerSvtData.id(1001000)..lv = 90,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final vanGogh = battle.onFieldAllyServants[0]!;
      final kingprotea = battle.onFieldAllyServants[1]!;
      expect(vanGogh.np, 0);
      expect(kingprotea.np, 0);

      await battle.activateSvtSkill(2, 0);
      await battle.activateSvtSkill(2, 2);
      await battle.activateSvtSkill(0, 1);
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(0, 0);
      expect(vanGogh.np, 12000);
      expect(kingprotea.np, 0);

      await battle.activateSvtSkill(1, 1);
      expect(vanGogh.np, 12000);
      expect(kingprotea.np, 0);
    });

    test('transformSvt 304800 asc 4', () async {
      final playerSvtData = PlayerSvtData.id(304800)..lv = 90;
      for (final skillNum in kActiveSkillNums) {
        final List<NiceSkill> shownSkills =
            BattleUtils.getShownSkills(playerSvtData.svt!, playerSvtData.limitCount, skillNum);
        playerSvtData.skills[skillNum - 1] = shownSkills.lastOrNull;
      }

      final List<NiceTd> shownTds = BattleUtils.getShownTds(playerSvtData.svt!, playerSvtData.limitCount);
      playerSvtData.td = shownTds.last;

      final List<PlayerSvtData> setting = [
        playerSvtData,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final melusine = battle.onFieldAllyServants[0]!;
      expect(melusine.np, 0);
      expect(melusine.getCurrentNP(battle)!.svt.card, CardType.buster);
      await battle.activateSvtSkill(0, 2);
      expect(melusine.np, 0);
      expect(melusine.getCurrentNP(battle)!.svt.card, CardType.buster);
    });

    test('transformSvt 304800 asc 11', () async {
      final playerSvtData = PlayerSvtData.id(304800)
        ..lv = 90
        ..limitCount = 304830;
      for (final skillNum in kActiveSkillNums) {
        final List<NiceSkill> shownSkills =
            BattleUtils.getShownSkills(playerSvtData.svt!, playerSvtData.limitCount, skillNum);
        playerSvtData.skills[skillNum - 1] = shownSkills.lastOrNull;
      }

      final List<NiceTd> shownTds = BattleUtils.getShownTds(playerSvtData.svt!, playerSvtData.limitCount);
      playerSvtData.td = shownTds.last;
      final List<PlayerSvtData> setting = [
        playerSvtData,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final melusine = battle.onFieldAllyServants[0]!;
      expect(melusine.np, 0);
      expect(melusine.getCurrentNP(battle)!.svt.card, CardType.arts);
      await battle.activateSvtSkill(0, 2);
      expect(melusine.np, 10000);
      expect(melusine.getCurrentNP(battle)!.svt.card, CardType.buster);
    });

    test('transformSvt preserve CD & upgrades', () async {
      final playerSvtData = PlayerSvtData.id(600700)
        ..lv = 70
        ..setSkillStrengthenLvs([1, 1, 1]);
      final List<PlayerSvtData> setting = [
        playerSvtData,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final henry = battle.onFieldAllyServants[0]!;
      await battle.activateSvtSkill(0, 0);
      henry.np = 10000;
      expect(henry.svtClass, SvtClass.assassin);
      expect(henry.skillInfoList[0].chargeTurn, 5);
      expect(henry.skillInfoList[2].baseSkill!.id, 71255);
      await battle.playerTurn([CombatAction(henry, henry.getNPCard(battle)!)]);
      expect(henry.svtClass, SvtClass.berserker);
      expect(henry.skillInfoList[0].chargeTurn, 5 - 1);
      expect(henry.skillInfoList[2].baseSkill!.id, 71255);
    });

    test('gainNpIndividualSum', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(502600)
          ..lv = 80
          ..setSkillStrengthenLvs([2, 1, 1]),
        PlayerSvtData.id(302500)..lv = 80,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final eliz = battle.onFieldAllyServants[0]!;
      final kyohime = battle.onFieldAllyServants[1]!;
      expect(eliz.np, 0);

      await battle.activateSvtSkill(1, 2);
      await battle.activateSvtSkill(0, 0);
      expect(eliz.np, 2000);

      kyohime.skillInfoList[2].chargeTurn = 0;
      await battle.activateSvtSkill(1, 2);
      battle.enemyTargetIndex = 1;
      kyohime.skillInfoList[2].chargeTurn = 0;
      await battle.activateSvtSkill(1, 2);
      battle.enemyTargetIndex = 2;
      kyohime.skillInfoList[2].chargeTurn = 0;
      await battle.activateSvtSkill(1, 2);
      // each enemy should have one buff now

      eliz.skillInfoList[0].chargeTurn = 0;
      await battle.activateSvtSkill(0, 0);
      expect(eliz.np, 8000);
    });
  });
}
