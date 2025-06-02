import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  group('Test shouldApplyBuff', () {
    final battle = BattleData();
    final okuni = BattleServantData.fromPlayerSvtData(
      PlayerSvtData.id(504900)..lv = 90,
      battle.getNextUniqueId(),
      isUseGrandBoard: false,
    );
    final cba = BattleServantData.fromPlayerSvtData(
      PlayerSvtData.id(503900)..lv = 90,
      battle.getNextUniqueId(),
      isUseGrandBoard: false,
    );

    test('target check', () {
      final buff = BuffData(
        Buff(
          id: -1,
          name: '',
          detail: '',
          ckOpIndv: [
            NiceTrait(id: Trait.king.value),
            NiceTrait(id: Trait.divine.value),
            NiceTrait(id: Trait.demon.value),
          ],
        ),
        DataVals({'UseRate': 1000}),
        1,
      );

      expect(buff.shouldActivateBuffNoProbabilityCheck(okuni.getTraits(), opponentTraits: cba.getTraits()), true);
      expect(buff.shouldActivateBuffNoProbabilityCheck(cba.getTraits(), opponentTraits: okuni.getTraits()), false);
    });

    test('checkIndivType 1', () {
      final buff = BuffData(
        Buff(
          id: -1,
          name: '',
          detail: '',
          ckOpIndv: [
            NiceTrait(id: Trait.attributeSky.value),
            NiceTrait(id: Trait.alignmentGood.value),
          ],
          script: BuffScript(checkIndvType: 1),
        ),
        DataVals({'UseRate': 1000}),
        1,
      );

      expect(buff.shouldActivateBuffNoProbabilityCheck(okuni.getTraits(), opponentTraits: cba.getTraits()), true);
      expect(buff.shouldActivateBuffNoProbabilityCheck(cba.getTraits(), opponentTraits: okuni.getTraits()), false);
    });

    test('probability check', () async {
      final buff = BuffData(
        Buff(
          id: -1,
          name: '',
          detail: '',
          ckOpIndv: [
            NiceTrait(id: Trait.king.value),
            NiceTrait(id: Trait.divine.value),
          ],
        ),
        DataVals({'UseRate': 500}),
        1,
      );

      expect(await buff.shouldActivateBuff(battle, okuni.getTraits(), opponentTraits: cba.getTraits()), isFalse);

      battle.options.threshold = 500;

      expect(await buff.shouldActivateBuff(battle, okuni.getTraits(), opponentTraits: cba.getTraits()), isTrue);
    });
  });

  test('can stack', () {
    final buff = BuffData(Buff(id: -1, name: '', detail: '', buffGroup: 500), DataVals(), 1);
    expect(buff.canStack(500), isFalse);
    expect(buff.canStack(300), isTrue);
    expect(buff.canStack(0), isTrue);

    final stackable = BuffData(Buff(id: -1, name: '', detail: '', buffGroup: 0), DataVals(), 1);
    expect(stackable.canStack(500), isTrue);
    expect(stackable.canStack(300), isTrue);
    expect(stackable.canStack(0), isTrue);
  });

  group('Individual buff types', () {
    test('upDefence', () async {
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
      expect(await mash.getBuffValue(battle, BuffAction.defencePierce), 1000);
    });

    test('subSelfdamage', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(800100)
          ..setSkillStrengthenLvs([2, 1, 1])
          ..tdLv = 3
          ..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;

      await battle.activateSvtSkill(0, 0);
      expect(await mash.getBuffValue(battle, BuffAction.receiveDamage), -2000);
      expect(await mash.getBuffValue(battle, BuffAction.pierceSubdamage), 1000);
    });

    test('instantDeath grant', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(1001000)
          ..lv = 1
          ..equip1 = getNP100Equip(),
      ];
      final mysticCodeData = MysticCodeData()..mysticCode = db.gameData.mysticCodes[240]!;
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, mysticCodeData);

      await battle.skipWave();
      await battle.skipWave();
      final douman = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      await battle.playerTurn([CombatAction(douman, douman.getNPCard()!)]);
      expect(battle.nonnullEnemies.length, 1);

      douman.np = 10000;
      await battle.activateMysticCodeSkill(1);
      await battle.playerTurn([CombatAction(douman, douman.getNPCard()!)]);
      expect(enemy1.hp, 0);
      expect(battle.nonnullEnemies.length, 0);
    });

    test('fieldIndividuality & subFieldIndividuality', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(100700)
          ..setSkillStrengthenLvs([1, 2, 1])
          ..tdLv = 3
          ..lv = 80,
        PlayerSvtData.id(604700)
          ..tdLv = 3
          ..lv = 90,
      ];

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      expect(battle.getQuestIndividuality().isEmpty, isTrue);

      await battle.activateSvtSkill(0, 1);
      expect(battle.getQuestIndividuality().isNotEmpty, isTrue);

      await battle.activateSvtSkill(1, 2);
      expect(battle.getQuestIndividuality().isEmpty, isTrue);

      // reset to test order does not affect subFieldIndiv
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      expect(battle.getQuestIndividuality().isEmpty, isTrue);

      await battle.activateSvtSkill(1, 2);
      expect(battle.getQuestIndividuality().isEmpty, isTrue);

      await battle.activateSvtSkill(0, 1);
      expect(battle.getQuestIndividuality().isEmpty, isTrue);
    });

    test('downGrant', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2800100)..lv = 90, PlayerSvtData.id(500800)..lv = 90];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final merlin = battle.onFieldAllyServants[1]!;

      final buffCount = merlin.battleBuff.getAllBuffs().length;
      await battle.activateSvtSkill(1, 0);
      expect(merlin.battleBuff.getAllBuffs().length, buffCount);
    });

    test('ParamAdd & ParamMax', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(604000)
          ..tdLv = 3
          ..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final okita = battle.onFieldAllyServants[0]!;
      expect(await okita.getBuffValue(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 2);
      expect(await okita.getBuffValue(battle, BuffAction.defencePierce), 900);

      await battle.skipWave();
      expect(await okita.getBuffValue(battle, BuffAction.defencePierce), 700);

      await battle.skipWave();
      expect(await okita.getBuffValue(battle, BuffAction.defencePierce), 500);
    });

    test('Check buffTrait', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(703300)
          ..tdLv = 5
          ..lv = 90
          ..equip1 = getNP100Equip(),
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      await battle.activateSvtSkill(0, 0);
      final arjuna = battle.onFieldAllyServants[0]!;
      final enemy = battle.onFieldEnemies[0]!;
      final prevHp = enemy.hp;
      await battle.playerTurn([CombatAction(arjuna, arjuna.getNPCard()!)]);
      expect(prevHp - enemy.hp, 96971);
    });

    test('HpRatio', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(1000100)
          ..lv = 80
          ..setSkillStrengthenLvs([2, 2, 1]),
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);
      await battle.activateSvtSkill(0, 1);

      final lip = battle.onFieldAllyServants[0]!;
      lip.hp = lip.maxHp ~/ 2 + 13;
      lip.updateActState(battle);
      expect(await lip.getBuffValue(battle, BuffAction.atk), 1000);

      lip.hp = lip.maxHp ~/ 2 - 1;
      lip.updateActState(battle);
      expect((await lip.getBuffValue(battle, BuffAction.atk)).toDouble(), moreOrLessEquals(1300, epsilon: 1));

      lip.hp = lip.maxHp ~/ 4;
      lip.updateActState(battle);
      expect((await lip.getBuffValue(battle, BuffAction.atk)).toDouble(), moreOrLessEquals(1400, epsilon: 1));

      lip.hp = 1;
      lip.updateActState(battle);
      expect((await lip.getBuffValue(battle, BuffAction.atk)).toDouble(), moreOrLessEquals(1500, epsilon: 1));
    });

    test('INDIVIDUALITIE', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(203200)..lv = 90, PlayerSvtData.id(304000)..lv = 80];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final jeanne = battle.onFieldAllyServants[0]!;

      expect(jeanne.np, 0);
      await battle.skipWave();
      expect(jeanne.np, 0);

      await battle.activateSvtSkill(1, 1);
      await battle.skipWave();
      expect(jeanne.np, 300);
    });

    test('maxhp', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(603700)..lv = 90, PlayerSvtData.id(500800)..lv = 80];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final kama = battle.onFieldAllyServants[0]!;

      expect(kama.hp, 12889 + 1000);
      expect(kama.maxHp, 12889 + 1000);

      await battle.activateSvtSkill(0, 0);

      expect(kama.hp, 12889 + 1000 - 1000);
      expect(kama.maxHp, 12889 + 1000 - 1000);

      await battle.activateSvtSkill(1, 2);

      expect(kama.hp, 12889 + 1000 - 1000 + 3000);
      expect(kama.maxHp, 12889 + 1000 - 1000 + 3000);
    });

    test('convert', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2501100)..lv = 90, PlayerSvtData.id(504500)..lv = 80];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final kukulcan = battle.onFieldAllyServants[0]!;

      expect(await kukulcan.hasBuff(battle, BuffAction.specialInvincible), false);
      expect(await kukulcan.hasBuff(battle, BuffAction.invincible), false);

      await battle.activateSvtSkill(1, 2);

      expect(await kukulcan.hasBuff(battle, BuffAction.specialInvincible), true);
      expect(await kukulcan.hasBuff(battle, BuffAction.invincible), false);
    });

    test('buffRate', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2800100)..lv = 90];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final oberon = battle.onFieldAllyServants[0]!;

      final target = battle.onFieldEnemies[0]!;
      final card = oberon.getNPCard();
      expect(await oberon.getBuffValue(battle, BuffAction.commandAtk, opponent: target, card: card), 1000);
      expect(await oberon.getBuffValue(battle, BuffAction.npdamage, opponent: target, card: card), 0);

      await battle.activateSvtSkill(0, 0);

      expect(await oberon.getBuffValue(battle, BuffAction.commandAtk, opponent: target, card: card), 1000);
      expect(await oberon.getBuffValue(battle, BuffAction.npdamage, opponent: target, card: card), 300);

      await battle.activateSvtSkill(0, 2);

      expect(await oberon.getBuffValue(battle, BuffAction.commandAtk, opponent: target, card: card), 1500);
      expect(await oberon.getBuffValue(battle, BuffAction.npdamage, opponent: target, card: card), 600);
    });

    test('changeCommandCardType', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(100100)
          ..lv = 90
          ..setSkillStrengthenLvs([1, 2, 2])
          ..cardStrengthens = [500, 0, 300, 0, 100]
          ..commandCodes = [
            db.gameData.commandCodes[120],
            null,
            db.gameData.commandCodes[100],
            null,
            db.gameData.commandCodes[90],
          ],
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final altria = battle.onFieldAllyServants[0]!;
      final cardBefore = altria.getCards();
      expect(cardBefore[0].cardStrengthen, 500);
      expect(cardBefore[2].cardStrengthen, 300);
      expect(cardBefore[4].cardStrengthen, 100);
      expect(cardBefore[0].commandCode?.collectionNo, 120);
      expect(cardBefore[2].commandCode?.collectionNo, 100);
      expect(cardBefore[4].commandCode?.collectionNo, 90);

      await battle.activateSvtSkill(0, 1);
      final cardsAfter = altria.getCards();
      expect(cardsAfter.where((card) => card.cardType == CardType.buster).length, 5);
      expect(cardsAfter[0].cardStrengthen, 500);
      expect(cardsAfter[2].cardStrengthen, 300);
      expect(cardsAfter[4].cardStrengthen, 100);
      expect(cardsAfter[0].commandCode?.collectionNo, 120);
      expect(cardsAfter[2].commandCode?.collectionNo, 100);
      expect(cardsAfter[4].commandCode?.collectionNo, 90);
    });

    test('multiAttack', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(703600)..lv = 90];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final musashi = battle.onFieldAllyServants[0]!;
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getNPCard()), false);
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getCards()[0]), false);
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getCards()[1]), false);

      await battle.activateSvtSkill(0, 1);
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getNPCard()), false);
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getCards()[0]), false);
      expect(await musashi.hasBuff(battle, BuffAction.multiattack, card: musashi.getCards()[1]), true);

      await battle.playerTurn([CombatAction(musashi, musashi.getCards()[1])]);
      expect(musashi.np, 1836);
    });

    test('overchargeBuff', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(901000)
          ..lv = 90
          ..equip1 = getNP100Equip(),
        PlayerSvtData.id(901000)
          ..lv = 90
          ..equip1 = getNP100Equip(),
        PlayerSvtData.id(500300)..lv = 90,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final himiko1 = battle.onFieldAllyServants[0]!;
      final himiko2 = battle.onFieldAllyServants[1]!;
      final tamamo = battle.onFieldAllyServants[2]!;
      await battle.playerTurn([
        CombatAction(himiko1, himiko1.getNPCard()!),
        CombatAction(himiko2, himiko2.getNPCard()!),
      ]);
      tamamo.np = 30000;
      await battle.playerTurn([CombatAction(tamamo, tamamo.getNPCard()!)]);
      expect(himiko1.np, 5000);
      expect(himiko2.np, 5000);
      expect(tamamo.np, 5000);
    });

    test('CheckOpponentBuffTypes', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(104900)..lv = 90, PlayerSvtData.id(504500)..lv = 80];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final murasama = battle.onFieldAllyServants[0]!;
      final castoria = battle.onFieldAllyServants[1]!;
      battle.playerTargetIndex = 1;

      await battle.activateSvtSkill(0, 1);
      final card = murasama.getCards()[0];
      expect(await murasama.getBuffValue(battle, BuffAction.criticalDamage, opponent: castoria, card: card), 1050);

      await battle.activateSvtSkill(1, 2);
      expect(await murasama.getBuffValue(battle, BuffAction.criticalDamage, opponent: castoria, card: card), 2050);
    });

    test('overwriteClassRelation kama skill first', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(603700)..lv = 90,
        PlayerSvtData.id(403200)
          ..lv = 80
          ..equip1 = getNP100Equip(),
        PlayerSvtData.id(1001500)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final kama = battle.onFieldAllyServants[0]!;
      final reinis = battle.onFieldAllyServants[1]!;
      final kirei = battle.onFieldAllyServants[2]!;

      expect(await Damage.getClassRelation(battle, kama, reinis), 2000);
      expect(await Damage.getClassRelation(battle, kama, kirei), 1000);
      expect(await Damage.getClassRelation(battle, reinis, kama), 500);
      expect(await Damage.getClassRelation(battle, reinis, kirei), 1000);
      expect(await Damage.getClassRelation(battle, kirei, kama), 1500);
      expect(await Damage.getClassRelation(battle, kirei, reinis), 1500);

      await battle.activateSvtSkill(0, 2);

      expect(await Damage.getClassRelation(battle, kama, reinis), 2000);
      expect(await Damage.getClassRelation(battle, kama, kirei), 2000);
      expect(await Damage.getClassRelation(battle, reinis, kama), 500);
      expect(await Damage.getClassRelation(battle, reinis, kirei), 1000);
      expect(await Damage.getClassRelation(battle, kirei, kama), 500);
      expect(await Damage.getClassRelation(battle, kirei, reinis), 1500);

      await battle.playerTurn([CombatAction(reinis, reinis.getNPCard()!)]);

      expect(await Damage.getClassRelation(battle, kama, reinis), 1000);
      expect(await Damage.getClassRelation(battle, kama, kirei), 1000);
      expect(await Damage.getClassRelation(battle, reinis, kama), 500);
      expect(await Damage.getClassRelation(battle, reinis, kirei), 1000);
      expect(await Damage.getClassRelation(battle, kirei, kama), 500);
      expect(await Damage.getClassRelation(battle, kirei, reinis), 1000);
    });

    test('overwriteClassRelation reinis np first', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(603700)..lv = 90,
        PlayerSvtData.id(403200)
          ..lv = 80
          ..equip1 = getNP100Equip(),
        PlayerSvtData.id(1001500)..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final kama = battle.onFieldAllyServants[0]!;
      final reinis = battle.onFieldAllyServants[1]!;
      final kirei = battle.onFieldAllyServants[2]!;

      await battle.playerTurn([CombatAction(reinis, reinis.getNPCard()!)]);

      expect(await Damage.getClassRelation(battle, kama, reinis), 1000);
      expect(await Damage.getClassRelation(battle, kama, kirei), 1000);
      expect(await Damage.getClassRelation(battle, reinis, kama), 500);
      expect(await Damage.getClassRelation(battle, reinis, kirei), 1000);
      expect(await Damage.getClassRelation(battle, kirei, kama), 1000);
      expect(await Damage.getClassRelation(battle, kirei, reinis), 1000);

      await battle.activateSvtSkill(0, 2);

      expect(await Damage.getClassRelation(battle, kama, reinis), 1000);
      expect(await Damage.getClassRelation(battle, kama, kirei), 1000);
      expect(await Damage.getClassRelation(battle, reinis, kama), 500);
      expect(await Damage.getClassRelation(battle, reinis, kirei), 1000);
      expect(await Damage.getClassRelation(battle, kirei, kama), 1000);
      expect(await Damage.getClassRelation(battle, kirei, reinis), 1000);
    });

    test('preventDeathByDamage', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2500600)..lv = 90];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final vanGogh = battle.onFieldAllyServants[0]!;
      battle.playerTargetIndex = 1;

      await battle.activateSvtSkill(0, 1);
      await battle.activateSvtSkill(0, 0);
      vanGogh.hp = 200;
      await battle.skipWave();
      expect(vanGogh.hp, 301);

      vanGogh.hp = 200;
      await battle.skipTurn();
      expect(vanGogh.hp, 100);

      vanGogh.hp = 50;
      await battle.skipTurn();
      expect(vanGogh.hp, 1);
    });

    test('skillRankUp & selfTurnEnd', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(2300400)
          ..lv = 90
          ..equip1 = getNP100Equip(),
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final kiara = battle.onFieldAllyServants[0]!;
      await battle.activateSvtSkill(0, 0);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 0);

      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 1);

      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 2);

      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 3);

      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 4);

      await battle.activateSvtSkill(0, 1);
      expect(kiara.np, 15000);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 2);

      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 2);
      await battle.activateSvtSkill(0, 2);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 0);
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;

      final prevHp2 = enemy2.hp;
      final prevHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(kiara, kiara.getNPCard()!)]);
      expect(kiara.countBuffWithTrait([NiceTrait(id: Trait.buffSkillRankUp.value)]), 0);
      expect(prevHp2 - enemy2.hp, 65301);
      expect(prevHp3 - enemy3.hp, 65301);
    });

    test('skillRankUp correctly updated', () async {
      final List<PlayerSvtData> setting = [PlayerSvtData.id(2300400)..lv = 90];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final kiara = battle.onFieldAllyServants[0]!;
      await battle.activateSvtSkill(0, 0);
      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      await battle.playerTurn([CombatAction(kiara, kiara.getCards()[4])]);
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(0, 1);
      expect(kiara.np, 3000);
    });

    test('funcHpReduce with multiple types', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(1001500)
          ..lv = 1
          ..tdLv = 1,
        PlayerSvtData.id(1001500)
          ..lv = 1
          ..tdLv = 1,
        PlayerSvtData.id(1001500)
          ..lv = 1
          ..tdLv = 1,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);
      await battle.skipWave();
      await battle.skipWave();

      final kirei1 = battle.onFieldAllyServants[0]!;
      final kirei2 = battle.onFieldAllyServants[1]!;
      final kirei3 = battle.onFieldAllyServants[2]!;

      final enemy = battle.onFieldEnemies[0]!;
      final prevHp1 = enemy.hp;
      kirei1.np = 10000;
      kirei2.np = 10000;
      kirei3.np = 10000;
      await battle.playerTurn([
        CombatAction(kirei1, kirei1.getNPCard()!),
        CombatAction(kirei2, kirei2.getNPCard()!),
        CombatAction(kirei3, kirei3.getNPCard()!),
      ]);
      expect(prevHp1 - enemy.hp, 1457 + 1514 + 1571 + 1000 * 3 * (1 + 3) * 2);

      final prevHp2 = enemy.hp;
      kirei1.np = 10000;
      kirei2.np = 10000;
      kirei3.np = 10000;
      await battle.playerTurn([
        CombatAction(kirei1, kirei1.getNPCard()!),
        CombatAction(kirei2, kirei2.getNPCard()!),
        CombatAction(kirei3, kirei3.getNPCard()!),
      ]);
      expect(prevHp2 - enemy.hp, 1457 + 1514 + 1571 + 1000 * 6 * (1 + 3 + 3) * 2);

      enemy.hp = 100000;
      kirei1.np = 10000;
      kirei2.np = 10000;
      kirei3.np = 10000;
      await battle.playerTurn([
        CombatAction(kirei1, kirei1.getNPCard()!),
        CombatAction(kirei2, kirei2.getNPCard()!),
        CombatAction(kirei3, kirei3.getNPCard()!),
      ]);
      expect(100000 - enemy.hp, 1457 + 1514 + 1571 + 1000 * 9 * (1 + 3 + 3 + 3) * 2);
    });

    test('delay & turnend', () async {
      final List<PlayerSvtData> setting = [PlayerSvtData.id(404200)..lv = 80, PlayerSvtData.id(2800100)..lv = 90];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final habetrot = battle.onFieldAllyServants[0]!;
      await battle.activateSvtSkill(0, 1);
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 2);
      await battle.activateSvtSkill(1, 1);
      expect(habetrot.np, 13000);
      await battle.skipWave();
      expect(habetrot.np, 11000);
      expect(habetrot.hp, 0);
      expect(battle.nonnullPlayers.length, 1);
    });

    test('guts function', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(403700)..lv = 90,
        PlayerSvtData.id(504400)
          ..lv = 65
          ..equip1 = getNP100Equip(),
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

      final nemo = battle.onFieldAllyServants[0]!;
      final chenGong = battle.onFieldAllyServants[1]!;
      await battle.activateSvtSkill(0, 1);
      expect(nemo.hp, 14680);
      expect(nemo.np, 3000);
      await battle.playerTurn([CombatAction(chenGong, chenGong.getNPCard()!)]);
      expect(nemo.np, 8000);
      expect(nemo.hp, 3000);
    });

    test('INDIVIDUALITIE svtId', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData.id(600700)
          ..lv = 70
          ..appendLvs = [10, 10, 10, 0, 0],
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final henry = battle.onFieldAllyServants[0]!;
      expect(await henry.getBuffValue(battle, BuffAction.atk, opponent: battle.onFieldEnemies[0]!), 1300);
      expect(await henry.getBuffValue(battle, BuffAction.atk, opponent: battle.onFieldEnemies[1]!), 1000);
    });

    test('BuffAction turnvalNp', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2800300)..lv = 70, PlayerSvtData.id(504200)..lv = 70];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final protoMerlin = battle.onFieldAllyServants[0]!;
      final enemy = battle.onFieldEnemies[0]!;
      expect(enemy.npLineCount, 0);

      await battle.playerTurn([CombatAction(protoMerlin, protoMerlin.getCards()[0])]);
      expect(enemy.npLineCount, 1);

      await battle.activateSvtSkill(0, 2);
      battle.options.threshold = 500;
      await battle.activateSvtSkill(1, 1);
      await battle.playerTurn([CombatAction(protoMerlin, protoMerlin.getCards()[0])]);
      expect(enemy.npLineCount, 1);

      await battle.playerTurn([CombatAction(protoMerlin, protoMerlin.getCards()[0])]);
      expect(enemy.npLineCount, 1);

      await battle.playerTurn([CombatAction(protoMerlin, protoMerlin.getCards()[0])]);
      expect(enemy.npLineCount, 2);
    });

    test('BuffAction turnendHpReduceToRegain', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(604800)..lv = 70, PlayerSvtData.id(2500600)..lv = 70];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final locusta = battle.onFieldAllyServants[0]!;
      final vanGogh = battle.onFieldAllyServants[1]!;
      locusta.hp = 5000;
      vanGogh.hp = 5000;

      await battle.activateSvtSkill(0, 1);
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 1);
      await battle.playerTurn([CombatAction(locusta, locusta.getCards()[0])]);
      expect(locusta.hp, 5000 + 1000 + 300 - 100);
      expect(vanGogh.hp, 5000 + 300 - 100);
    });

    test('npattackPrevBuff (Hokusai 3rd Skill on NP)', () async {
      final List<PlayerSvtData> setting = [
        PlayerSvtData.id(2500200)
          ..lv = 1
          ..tdLv = 2
          ..atkFou = 0
          ..skillLvs = [6, 6, 6]
          ..setSkillStrengthenLvs([1, 1, 2]),
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, null);

      final hokusai = battle.onFieldAllyServants[0]!;
      final enemy1 = battle.onFieldEnemies[0]!;
      final enemy2 = battle.onFieldEnemies[1]!;
      final enemy3 = battle.onFieldEnemies[2]!;
      await battle.activateSvtSkill(0, 2);

      hokusai.np = 10000;
      final previousHp1 = enemy1.hp;
      final previousHp2 = enemy2.hp;
      final previousHp3 = enemy3.hp;
      final previousBuffCount1 = enemy1.battleBuff.getAllBuffs().length;
      final previousBuffCount2 = enemy2.battleBuff.getAllBuffs().length;
      final previousBuffCount3 = enemy3.battleBuff.getAllBuffs().length;
      await battle.playerTurn([
        CombatAction(hokusai, hokusai.getNPCard()!),
        CombatAction(hokusai, hokusai.getCards()[1]),
      ]);
      expect(enemy1.hp, previousHp1 - 2831 - 786);
      expect(enemy2.hp, previousHp2 - 2831);
      expect(enemy3.hp, previousHp3 - 2831);
      expect(enemy1.battleBuff.getAllBuffs().length, previousBuffCount1 + 2);
      expect(enemy2.battleBuff.getAllBuffs().length, previousBuffCount2 + 1);
      expect(enemy3.battleBuff.getAllBuffs().length, previousBuffCount3 + 1);

      hokusai.np = 20000;
      battle.enemyTargetIndex = 1;
      final previousHp4 = enemy1.hp;
      final previousHp5 = enemy2.hp;
      final previousHp6 = enemy3.hp;
      final previousBuffCount4 = enemy1.battleBuff.getAllBuffs().length;
      final previousBuffCount5 = enemy2.battleBuff.getAllBuffs().length;
      final previousBuffCount6 = enemy3.battleBuff.getAllBuffs().length;
      await battle.playerTurn([
        CombatAction(hokusai, hokusai.getNPCard()!),
        CombatAction(hokusai, hokusai.getCards()[1]),
        CombatAction(hokusai, hokusai.getCards()[2]),
      ]);
      expect(enemy1.hp, previousHp4 - 3629);
      expect(enemy2.hp, previousHp5 - 3230 - 865 - 1073 - 2559);
      expect(enemy3.hp, previousHp6 - 3230);
      expect(enemy1.battleBuff.getAllBuffs().length, previousBuffCount4 + 1);
      expect(enemy2.battleBuff.getAllBuffs().length, previousBuffCount5 + 3);
      expect(enemy3.battleBuff.getAllBuffs().length, previousBuffCount6 + 1);
    });

    test('gainMultiplyNp', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(704900), PlayerSvtData.id(704900)];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final soujyuro1 = battle.onFieldAllyServants[0]!;
      final soujyuro2 = battle.onFieldAllyServants[1]!;
      soujyuro1.np = 0;
      await battle.activateSvtSkill(0, 1);
      expect(soujyuro1.np, 0);

      soujyuro2.np = 4950;
      await battle.activateSvtSkill(1, 1);
      expect(soujyuro2.np, 10000);
    });

    test('protagonist correction on activator should block', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2501400), PlayerSvtData.id(2800100)];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final aoko = battle.onFieldAllyServants[0]!;
      aoko.np = 3000;
      battle.playerTargetIndex = 1;
      await battle.activateSvtSkill(0, 2);
      battle.playerTargetIndex = 0;
      await battle.activateSvtSkill(1, 1);
      expect(aoko.np, 8000);

      await battle.skipTurn();
      expect(aoko.np, 8000);
    });

    test('protagonist correction on target should not block', () async {
      final battle = BattleData();
      final playerSettings = [PlayerSvtData.id(2501400), PlayerSvtData.id(2800100)];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final aoko = battle.onFieldAllyServants[0]!;
      aoko.np = 3000;
      battle.playerTargetIndex = 0;
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 1);
      expect(aoko.np, 8000);

      await battle.skipTurn();
      expect(aoko.np, 6000);
    });
  });
}
