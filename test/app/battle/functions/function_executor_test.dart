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

  final BattleServantData ally = battle.targetedPlayer!;
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
      expect(ptAll, unorderedEquals(battle.nonnullPlayers));

      final ptFull =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.ptFull, battle.onFieldAllyServants[1]);
      expect(ptFull, unorderedEquals([...battle.nonnullPlayers, ...battle.nonnullBackupPlayers]));

      final enemyAll = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyAll, ally);
      expect(enemyAll, unorderedEquals(battle.nonnullEnemies));

      final enemyFullAsEnemy = await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyFull, enemy);
      expect(enemyFullAsEnemy, unorderedEquals([...battle.nonnullPlayers, ...battle.nonnullBackupPlayers]));
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
            ...battle.nonnullBackupPlayers,
          ]));

      final enemyOtherFullAsEnemy =
          await FunctionExecutor.acquireFunctionTarget(battle, FuncTargetType.enemyOtherFull, enemy);
      expect(
          enemyOtherFullAsEnemy,
          unorderedEquals([
            battle.onFieldAllyServants[1],
            battle.onFieldAllyServants[2],
            ...battle.nonnullBackupPlayers,
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

      battle.onFieldAllyServants[0]!.addBuff(BuffData(
          Buff(id: -1, name: '', detail: '', vals: [NiceTrait(id: Trait.cantBeSacrificed.value)]), DataVals(), 1));

      final as1With0Unselectable = await FunctionExecutor.acquireFunctionTarget(
          battle, FuncTargetType.ptSelfAnotherFirst, battle.onFieldAllyServants[1]);
      expect(as1With0Unselectable.length, 1);
      expect(as1With0Unselectable.first, battle.onFieldAllyServants[2]);

      battle.onFieldAllyServants[0]!.battleBuff.originalActiveList.removeLast();

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
      final buffCountBefore = nemo1.battleBuff.originalActiveList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfter = nemo1.battleBuff.originalActiveList.length;
      expect(buffCountAfter, buffCountBefore + 1);
      expect(battle.checkDuplicateFuncData[1]![6010]![nemo1.uniqueId], false);

      await battle.init(db.gameData.questPhases[9300030103]!, playerSettings, null); // field shore
      final nemo2 = battle.onFieldAllyServants[0]!;
      final buffCountBeforeShore = nemo2.battleBuff.originalActiveList.length;
      await battle.activateSvtSkill(0, 2); // nemo skill 3, check field shore
      final buffCountAfterShore = nemo2.battleBuff.originalActiveList.length;
      expect(buffCountAfterShore, buffCountBeforeShore + 2);
      expect(battle.checkDuplicateFuncData[1]![6010]![nemo1.uniqueId], true);
    });

    test('Function checks target trait', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final nemo = battle.onFieldAllyServants[0]!;
      final eli = battle.onFieldAllyServants[1]!;
      final kama = battle.onFieldAllyServants[2]!;
      final buffCountNemoBefore = nemo.battleBuff.originalActiveList.length;
      final buffCountEliBefore = eli.battleBuff.originalActiveList.length;
      final buffCountKamaBefore = kama.battleBuff.originalActiveList.length;
      await battle.activateSvtSkill(1, 0); // Eli skill 1, check female
      final buffCountNemoAfter = nemo.battleBuff.originalActiveList.length;
      final buffCountEliAfter = eli.battleBuff.originalActiveList.length;
      final buffCountKamaAfter = kama.battleBuff.originalActiveList.length;
      expect(buffCountNemoAfter, buffCountNemoBefore + 1);
      expect(buffCountEliAfter, buffCountEliBefore + 1);
      expect(buffCountKamaAfter, buffCountKamaBefore + 2);

      // last skill is on female targets except self
      expect(battle.checkDuplicateFuncData.length, 2);
      expect(battle.checkDuplicateFuncData[1]![1137]![nemo.uniqueId], false);
      expect(battle.checkDuplicateFuncData[1]![1137]![eli.uniqueId], null);
      expect(battle.checkDuplicateFuncData[1]![1137]![kama.uniqueId], true);
    });

    test('Function checks overwriteTvals target trait', () async {
      final playerSettings = [
        PlayerSvtData.id(200200) // Gil
          ..setSkillStrengthenLvs([2, 1, 1])
          ..tdLv = 1
          ..lv = 90,
        PlayerSvtData.id(200200) // Gil
          ..tdLv = 2
          ..lv = 80,
        PlayerSvtData.id(204900) // Earth svt
          ..tdLv = 5
          ..lv = 120,
      ];

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final gil1 = battle.onFieldAllyServants[0]!;
      final gil2 = battle.onFieldAllyServants[1]!;
      final earth = battle.onFieldAllyServants[2]!;
      final buffCountGil1Before = gil1.battleBuff.originalActiveList.length;
      final buffCountGil2Before = gil2.battleBuff.originalActiveList.length;
      final buffCountEarthBefore = earth.battleBuff.originalActiveList.length;
      await battle.activateSvtSkill(0, 0); // Gil skill 1, check Sky Servant with overwriteTvals
      final buffCountGil1After = gil1.battleBuff.originalActiveList.length;
      final buffCountGil2After = gil2.battleBuff.originalActiveList.length;
      final buffCountEarthAfter = earth.battleBuff.originalActiveList.length;
      expect(buffCountGil1After, buffCountGil1Before + 2);
      expect(buffCountGil2After, buffCountGil2Before + 2);
      expect(buffCountEarthAfter, buffCountEarthBefore + 1);
    });

    test('Function checks target alive', () async {
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final kama = battle.onFieldAllyServants[2]!;
      kama.np = 10000;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;
      await battle.activateSvtSkill(2, 1); // Kama skill 2, just to guarantee kill
      final buffCountBefore = enemy2.battleBuff.originalActiveList.length;
      final npCard = kama.getNPCard()!;
      battle.recorder.startPlayerCard(kama, npCard);
      await battle.withAction(() async {
        await kama.activateNP(battle, npCard, 0);
      });
      final buffCountAfter = enemy2.battleBuff.originalActiveList.length;
      expect(buffCountAfter, buffCountBefore);

      // last func is addState on dead enemies
      expect(battle.checkDuplicateFuncData.length, 2);
      expect(battle.checkDuplicateFuncData[1]![197]!.length, 3);
      expect(battle.checkDuplicateFuncData[1]![197]![enemy1.uniqueId], false);
      expect(battle.checkDuplicateFuncData[1]![197]![enemy2.uniqueId], false);
      expect(battle.checkDuplicateFuncData[1]![197]![enemy3.uniqueId], false);
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
      final npCard = cursedArm.getNPCard()!;
      final buffCountBefore1 = cursedArm.battleBuff.originalActiveList.length;
      cursedArm.np = 10000;
      battle.recorder.startPlayerCard(cursedArm, npCard);
      await battle.withAction(() async {
        await cursedArm.activateNP(battle, npCard, 0);
      });
      final buffCountAfter1 = cursedArm.battleBuff.originalActiveList.length;
      expect(buffCountAfter1, buffCountBefore1);
      expect(battle.checkDuplicateFuncData[0]![12]![enemy1.uniqueId], true);
      expect(battle.checkDuplicateFuncData[1]![479]![enemy1.uniqueId], false);
      expect(battle.checkDuplicateFuncData[2]![146]![cursedArm.uniqueId], false);
      expect(battle.checkDuplicateFuncData[3]![460]![cursedArm.uniqueId], false);
      expect(battle.checkDuplicateFuncData[4]![470], null);

      battle.enemyTargetIndex = 1;
      final enemy2 = battle.onFieldEnemies[1]!;
      final buffCountBefore2 = cursedArm.battleBuff.originalActiveList.length;
      cursedArm.np = 10000;
      battle.options.threshold = 10;
      battle.recorder.startPlayerCard(cursedArm, npCard);
      await battle.withAction(() async {
        await cursedArm.activateNP(battle, npCard, 0);
      });
      final buffCountAfter2 = cursedArm.battleBuff.originalActiveList.length;
      expect(buffCountAfter2, buffCountBefore2 + 1);
      expect(battle.checkDuplicateFuncData[0]![12]![enemy2.uniqueId], true);
      expect(battle.checkDuplicateFuncData[1]![479]![enemy2.uniqueId], true);
      expect(battle.checkDuplicateFuncData[2]![146]![cursedArm.uniqueId], true);
      expect(battle.checkDuplicateFuncData[3]![460]![cursedArm.uniqueId], true);
      expect(battle.checkDuplicateFuncData[4]![470], null);
    });

    test('Function checks avoidFunctionExecuteSelf', () async {
      await battle.init(
        db.gameData.questPhases[9300040603]!,
        [
          PlayerSvtData.id(502800) // Illyasviel
            ..tdLv = 5
            ..setNpStrengthenLv(2)
            ..lv = 90,
          PlayerSvtData.id(2501400), // Aoko
        ],
        null,
      );
      final illya = battle.onFieldAllyServants[0]!;
      illya.np = 10000;
      final buffCountBefore = illya.battleBuff.originalActiveList.length;
      final npCard = illya.getNPCard()!;
      await battle.playerTurn([CombatAction(illya, npCard)]);
      final buffCountAfter = illya.battleBuff.originalActiveList.length;
      expect(buffCountAfter, buffCountBefore + 4);

      illya.np = 10000;
      await battle.activateSvtSkill(1, 2);
      final buffCountBefore2 = illya.battleBuff.originalActiveList.length;
      await battle.playerTurn([CombatAction(illya, npCard)]);
      final buffCountAfter2 = illya.battleBuff.originalActiveList.length;
      expect(buffCountAfter2, buffCountBefore2 + 2);
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
      expect(mash.battleBuff.originalActiveList.length, 0);
      expect(await mash.getBuffValue(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 0);
      expect(mash.battleBuff.originalActiveList.length, 1);
      expect(await mash.getBuffValue(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.originalActiveList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.originalActiveList.first.logicTurn, 6);

      await battle.playerTurn([CombatAction(mash, mash.getCards()[0])]);
      expect(mash.battleBuff.originalActiveList.length, 1);
      expect(await mash.getBuffValue(battle, BuffAction.defence), 1150);
      expect(mash.battleBuff.originalActiveList.first.buff.type, BuffType.upDefence);
      expect(mash.battleBuff.originalActiveList.first.logicTurn, 4);
    });

    test('addState & addStateShort', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(200900),
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final orion = battle.onFieldAllyServants[0]!;
      expect(orion.battleBuff.originalActiveList.length, 0);
      expect(await orion.getBuffValue(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 0);
      expect(orion.battleBuff.originalActiveList.length, 3);
      expect(await orion.getBuffValue(battle, BuffAction.defence), 1500);
      expect(orion.battleBuff.originalActiveList.first.buff.type, BuffType.upDefence);
      expect(orion.battleBuff.originalActiveList.first.logicTurn, 2);
      expect(await orion.getBuffValue(battle, BuffAction.atk), 1200);
      expect(orion.battleBuff.originalActiveList[1].buff.type, BuffType.upAtk);
      expect(orion.battleBuff.originalActiveList[1].logicTurn, 5);

      await battle.playerTurn([CombatAction(orion, orion.getCards()[0])]);
      expect(orion.battleBuff.originalActiveList.length, 2);
      expect(await orion.getBuffValue(battle, BuffAction.defence), 1000);
      expect(await orion.getBuffValue(battle, BuffAction.atk), 1200);
      expect(orion.battleBuff.originalActiveList[0].buff.type, BuffType.upAtk);
      expect(orion.battleBuff.originalActiveList[0].logicTurn, 3);
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

      expect(battle.getFieldTraits().map((e) => e.id).contains(Trait.milleniumCastle.value), isFalse);

      await battle.playerTurn([CombatAction(archType1, archType1.getNPCard()!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.value).length, 1);

      await battle.playerTurn([CombatAction(archType2, archType1.getNPCard()!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.value).length, 2);

      await battle.activateSvtSkill(0, 1);
      await battle.playerTurn([CombatAction(archType1, archType1.getNPCard()!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.value).length, 2);

      // kill one to remove buff
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final archType3 = battle.onFieldAllyServants[0]!;
      final archType4 = battle.onFieldAllyServants[1]!;

      expect(battle.getFieldTraits().map((e) => e.id).contains(Trait.milleniumCastle.value), isFalse);

      await battle.playerTurn([CombatAction(archType3, archType3.getNPCard()!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.value).length, 1);

      archType3.hp = 0;

      await battle.playerTurn([CombatAction(archType4, archType4.getNPCard()!)]);

      expect(battle.getFieldTraits().map((e) => e.id).where((e) => e == Trait.milleniumCastle.value).length, 1);
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
      expect(battle.checkDuplicateFuncData[3]![7015]!.length, 2);
      expect(battle.checkDuplicateFuncData[3]![7015]![battle.onFieldAllyServants[0]!.uniqueId], false);
      expect(battle.checkDuplicateFuncData[3]![7015]![battle.onFieldAllyServants[2]!.uniqueId], true);
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

      expect(collectBuffsPerType(cat.battleBuff.validBuffs, BuffType.donotAct).length, 0);

      await battle.playerTurn([CombatAction(cat, cat.getNPCard()!)]);

      expect(collectBuffsPerType(cat.battleBuff.validBuffs, BuffType.donotAct).length, 2);
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

      expect(collectBuffsPerType(lip.battleBuff.validBuffs, BuffType.donotAct).length, 1);
      expect(collectBuffsPerType(lip.battleBuff.validBuffs, BuffType.donotSkill).length, 1);

      await battle.activateSvtSkill(2, 0);

      expect(collectBuffsPerType(lip.battleBuff.validBuffs, BuffType.donotAct).length, 1);
      expect(collectBuffsPerType(lip.battleBuff.validBuffs, BuffType.donotSkill).length, 0);
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

      await battle.playerTurn([CombatAction(yuyu2, yuyu2.getCards().last)]); // buster card

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
      final backup1 = battle.backupAllyServants[0]!;
      final backup2 = battle.backupAllyServants[1]!;
      final backup3 = battle.backupAllyServants[2]!;
      expect(onField1.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(crane.fieldIndex, 2);
      expect(backup1.fieldIndex, 3);
      expect(backup2.fieldIndex, 4);
      expect(backup3.fieldIndex, 5);
      expect(battle.canUseNp(2), true);

      await battle.playerTurn([CombatAction(crane, crane.getNPCard()!)]);

      expect(battle.backupAllyServants.length, 3);
      expect(battle.backupAllyServants.last, crane);
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
      final prevCount1 = charlie1.battleBuff.getAllBuffs().length;
      final prevCount2 = charlie2.battleBuff.getAllBuffs().length;

      await battle.activateSvtSkill(0, 0);

      final afterCount1 = charlie1.battleBuff.getAllBuffs().length;

      expect(afterCount1, prevCount1 + 2);
      expect(charlie1.canNP(), false);

      await battle.activateSvtSkill(1, 0);

      final afterCount2 = charlie2.battleBuff.getAllBuffs().length;

      expect(afterCount2, prevCount2 + 2);
      expect(charlie2.canNP(), true);
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

      final prevCount = kingprotea.battleBuff.getAllBuffs().length;

      await battle.activateSvtSkill(0, 0);

      for (int i = 0; i < 10; i += 1) {
        await battle.playerTurn([CombatAction(kingprotea, kingprotea.getCards()[0])]);
      }

      final afterCount = kingprotea.battleBuff.getAllBuffs().length;

      expect(afterCount, prevCount + 20);

      await battle.activateSvtSkill(0, 0);

      for (int i = 0; i < 10; i += 1) {
        await battle.playerTurn([CombatAction(kingprotea, kingprotea.getCards()[0])]);
      }

      final afterCount2 = kingprotea.battleBuff.getAllBuffs().length;

      expect(afterCount2, prevCount + 20);
    });

    test('DataVals StarHigher', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(203700)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final jane = battle.onFieldAllyServants[0]!;
      final prevCount = jane.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(0, 2);
      final afterCount = jane.battleBuff.getAllBuffs().length;
      expect(afterCount, prevCount + 1);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      battle.criticalStars = 20;
      final jane2 = battle.onFieldAllyServants[0]!;
      final prevCount2 = jane2.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(0, 2);
      final afterCount2 = jane2.battleBuff.getAllBuffs().length;
      expect(afterCount2, prevCount2 + 3);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      battle.criticalStars = 50;
      final jane3 = battle.onFieldAllyServants[0]!;
      final prevCount3 = jane3.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(0, 2);
      final afterCount3 = jane3.battleBuff.getAllBuffs().length;
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
      final prevCount = babbage.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(0, 2);
      final afterCount = babbage.battleBuff.getAllBuffs().length;
      expect(afterCount, prevCount + 3);

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      final babbage2 = battle.onFieldAllyServants[0]!;
      final prevCount2 = babbage2.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(1, 0);
      await battle.activateSvtSkill(0, 2);
      final afterCount2 = babbage2.battleBuff.getAllBuffs().length;
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
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard()!)]);
      expect(prevHp1 - enemy1.hp, 107144);

      toshizo.hp = toshizo.maxHp ~/ 2;
      toshizo.np = 10000;
      final prevHp2 = enemy2.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard()!)]);
      expect((prevHp2 - enemy2.hp).toDouble(), moreOrLessEquals(142859, epsilon: 5));

      toshizo.hp = 1;
      toshizo.np = 10000;
      final prevHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard()!)]);
      expect((prevHp3 - enemy3.hp).toDouble(), moreOrLessEquals(178567, epsilon: 5));

      final enemy4 = battle.onFieldEnemies[0]!;
      toshizo.np = 30000;
      final prevHp4 = enemy4.hp;
      await battle.playerTurn([CombatAction(toshizo, toshizo.getNPCard()!)]);
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
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard()!)]);
      expect(prevHp1 - enemy1.hp, 88719);
      expect(prevHp2 - enemy2.hp, 57200);
      expect(prevHp3 - enemy3.hp, 57200);
    });

    test('damageNpIndividualSum selfBuff', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(1101600)
          ..lv = 80
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final chloe = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final prevHp1 = enemy1.hp;

      await battle.activateSvtSkill(0, 0);
      await battle.playerTurn([CombatAction(chloe, chloe.getNPCard()!)]);
      expect(prevHp1 - enemy1.hp, 67832);
      final linkedBuffs = chloe.battleBuff.getActiveList().where((buff) => buff.vals.BehaveAsFamilyBuff == 1);
      expect(linkedBuffs.length, 2);
      expect(linkedBuffs.first.count, 4);
      expect(linkedBuffs.last.count, 4);

      final enemy2 = battle.onFieldEnemies[1]!;
      final prevHp2 = enemy2.hp;
      await battle.playerTurn([
        CombatAction(chloe, chloe.getCards()[0]),
        CombatAction(chloe, chloe.getCards()[1]),
        CombatAction(chloe, chloe.getCards()[2]),
      ]);
      expect(prevHp2 - enemy2.hp, 3391 + 4069 + 4748 + 13489);
      final linkedBuffsUsedUp = chloe.battleBuff.getActiveList().where((buff) => buff.vals.BehaveAsFamilyBuff == 1);
      expect(linkedBuffsUsedUp.isEmpty, isTrue);

      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp3 = enemy3.hp;
      chloe.np = 10000;
      await battle.playerTurn([CombatAction(chloe, chloe.getNPCard()!)]);
      expect(prevHp3 - enemy3.hp, 110999);
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
      await battle.playerTurn([CombatAction(bunyan, bunyan.getNPCard()!)]);
      expect(prevHp1 - enemy1.hp, 20323);

      final enemy2 = battle.onFieldEnemies[1]!;
      final prevHp2 = enemy2.hp;
      await battle.playerTurn([
        CombatAction(bunyan, bunyan.getCards()[0]),
        CombatAction(bunyan, bunyan.getCards()[1]),
        CombatAction(bunyan, bunyan.getCards()[2]),
      ]);
      expect(prevHp2 - enemy2.hp, 5283 + 6909 + 10567 + 12193);

      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp3 = enemy3.hp;
      bunyan.np = 10000;
      await battle.playerTurn([CombatAction(bunyan, bunyan.getNPCard()!)]);
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
      await battle.playerTurn([CombatAction(roberts, roberts.getNPCard()!)]);
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
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard()!)]);
      expect(battle.waveCount, 1);
      expect(enemy1.hp, greaterThan(0));
      expect(enemy2.hp, greaterThan(0));
      expect(enemy3.hp, greaterThan(0));
      expect(battle.nonnullEnemies.length, 3);

      battle.options.threshold = 800;
      kiara.np = 10000;
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard()!)]);
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
      final backup1 = battle.backupAllyServants[0]!;
      final backup2 = battle.backupAllyServants[1]!;
      expect(arash.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(onField3.fieldIndex, 2);
      expect(backup1.fieldIndex, 3);
      expect(backup2.fieldIndex, 4);
      expect(battle.backupAllyServants.length, 2);
      await battle.activateSvtSkill(1, 0);
      await battle.playerTurn([CombatAction(arash, arash.getNPCard()!)]);

      expect(arash.hp, 0);
      expect(arash.fieldIndex, -1);
      expect(backup1.fieldIndex, 0);
      expect(onField2.fieldIndex, 1);
      expect(onField3.fieldIndex, 2);
      expect(backup2.fieldIndex, 3);
      expect(battle.backupAllyServants.length, 1);
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
      expect(melusine.getCurrentNP()!.svt.card, CardType.buster);
      await battle.activateSvtSkill(0, 2);
      expect(melusine.np, 0);
      expect(melusine.getCurrentNP()!.svt.card, CardType.buster);
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
      expect(melusine.getCurrentNP()!.svt.card, CardType.arts);
      await battle.activateSvtSkill(0, 2);
      expect(melusine.np, 10000);
      expect(melusine.getCurrentNP()!.svt.card, CardType.buster);
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
      expect(henry.classId, SvtClass.assassin.value);
      expect(henry.skillInfoList[0].chargeTurn, 5);
      expect(henry.skillInfoList[2].skill, isNotNull);
      expect(henry.skillInfoList[2].skill!.id, 71255);
      await battle.playerTurn([CombatAction(henry, henry.getNPCard()!)]);
      expect(henry.classId, SvtClass.berserker.value);
      expect(henry.skillInfoList[0].chargeTurn, 5 - 1);
      expect(henry.skillInfoList[2].skill, isNotNull);
      expect(henry.skillInfoList[2].skill!.id, 71255);
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
