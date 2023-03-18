import 'package:flutter_test/flutter_test.dart';

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

  group('Test shouldApplyBuff', () {
    final battle = BattleData();
    final okuni = BattleServantData.fromPlayerSvtData(PlayerSvtData(504900)..lv = 90);
    final cba = BattleServantData.fromPlayerSvtData(PlayerSvtData(503900)..lv = 90);

    test('target check', () {
      final buff = BuffData(
          Buff(id: -1, name: '', detail: '', ckOpIndv: [
            NiceTrait(id: Trait.king.id),
            NiceTrait(id: Trait.divine.id),
            NiceTrait(id: Trait.demon.id),
          ]),
          DataVals({'UseRate': 1000}));

      battle.setTarget(cba);
      battle.setActivator(okuni);

      expect(buff.shouldApplyBuff(battle, false), isTrue);
      expect(buff.shouldApplyBuff(battle, true), isFalse);

      battle.unsetTarget();
      battle.unsetActivator();
    });

    test('checkIndivType 1', () {
      final buff = BuffData(
          Buff(
            id: -1,
            name: '',
            detail: '',
            ckOpIndv: [
              NiceTrait(id: Trait.attributeSky.id),
              NiceTrait(id: Trait.alignmentGood.id),
            ],
            script: BuffScript(checkIndvType: 1),
          ),
          DataVals({'UseRate': 1000}));

      battle.setTarget(cba);
      battle.setActivator(okuni);

      expect(buff.shouldApplyBuff(battle, false), isTrue);
      expect(buff.shouldApplyBuff(battle, true), isFalse);

      battle.unsetTarget();
      battle.unsetActivator();
    });

    test('checkIndivType with current buff', () {
      final buff = BuffData(
          Buff(
            id: -1,
            name: '',
            detail: '',
            ckOpIndv: [
              NiceTrait(id: Trait.attributeSky.id),
              NiceTrait(id: Trait.buffNegativeEffect.id),
            ],
            script: BuffScript(checkIndvType: 1),
          ),
          DataVals({'UseRate': 1000}));

      final currentBuff = BuffData(
          Buff(id: -1, name: '', detail: '', vals: [NiceTrait(id: Trait.buffNegativeEffect.id)]),
          DataVals({'UseRate': 1000}));

      battle.setTarget(cba);
      battle.setActivator(okuni);
      cba.addBuff(currentBuff); // make sure we are not checking servant's buffs' traits

      expect(buff.shouldApplyBuff(battle, false), isFalse);

      battle.setCurrentBuff(currentBuff);

      expect(buff.shouldApplyBuff(battle, false), isTrue);

      battle.unsetCurrentBuff();
      battle.unsetTarget();
      battle.unsetActivator();
    });

    test('probability check', () {
      final buff = BuffData(
          Buff(id: -1, name: '', detail: '', ckOpIndv: [NiceTrait(id: Trait.king.id), NiceTrait(id: Trait.divine.id)]),
          DataVals({'UseRate': 500}));

      battle.setTarget(cba);
      battle.setActivator(okuni);

      expect(buff.shouldApplyBuff(battle, false), isFalse);

      battle.probabilityThreshold = 500;

      expect(buff.shouldApplyBuff(battle, false), isTrue);

      battle.unsetTarget();
      battle.unsetActivator();
    });
  });

  test('can stack', () {
    final buff = BuffData(Buff(id: -1, name: '', detail: '', buffGroup: 500), DataVals());
    expect(buff.canStack(500), isFalse);
    expect(buff.canStack(300), isTrue);
    expect(buff.canStack(0), isTrue);

    final stackable = BuffData(Buff(id: -1, name: '', detail: '', buffGroup: 0), DataVals());
    expect(stackable.canStack(500), isTrue);
    expect(stackable.canStack(300), isTrue);
    expect(stackable.canStack(0), isTrue);
  });

  group('Individual buff types', () {
    test('upDefence', () async {
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
      expect(mash.getBuffValueOnAction(battle, BuffAction.defencePierce), 1000);
    });

    test('subSelfdamage', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(800100)
          ..skillStrengthenLvs = [2, 1, 1]
          ..npLv = 3
          ..lv = 80,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;

      await battle.activateSvtSkill(0, 0);
      expect(mash.getBuffValueOnAction(battle, BuffAction.receiveDamage), -2000);
    });

    test('fieldIndividuality & subFieldIndividuality', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(100700)
          ..skillStrengthenLvs = [1, 2, 1]
          ..npLv = 3
          ..lv = 80,
        PlayerSvtData(604700)
          ..npLv = 3
          ..lv = 90,
      ];

      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      expect(battle.getFieldTraits().isEmpty, isTrue);

      await battle.activateSvtSkill(0, 1);
      expect(battle.getFieldTraits().isNotEmpty, isTrue);

      await battle.activateSvtSkill(1, 2);
      expect(battle.getFieldTraits().isEmpty, isTrue);

      // reset to test order does not affect subFieldIndiv
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
      expect(battle.getFieldTraits().isEmpty, isTrue);

      await battle.activateSvtSkill(1, 2);
      expect(battle.getFieldTraits().isEmpty, isTrue);

      await battle.activateSvtSkill(0, 1);
      expect(battle.getFieldTraits().isEmpty, isTrue);
    });

    test('downGrant', () async {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(2800100)..lv = 90,
        PlayerSvtData(500800)..lv = 90,
      ];
      await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final merlin = battle.onFieldAllyServants[1]!;

      final buffCount = merlin.battleBuff.allBuffs.length;
      await battle.activateSvtSkill(1, 0);
      expect(merlin.battleBuff.allBuffs.length, buffCount);
    });
  });

  test('ParamAdd & ParamMax', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(604000)
        ..npLv = 3
        ..lv = 80,
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final okita = battle.onFieldAllyServants[0]!;
    expect(okita.getBuffValueOnAction(battle, BuffAction.defence), 1000);

    await battle.activateSvtSkill(0, 2);
    expect(okita.getBuffValueOnAction(battle, BuffAction.defencePierce), 900);

    await battle.skipWave();
    expect(okita.getBuffValueOnAction(battle, BuffAction.defencePierce), 700);

    await battle.skipWave();
    expect(okita.getBuffValueOnAction(battle, BuffAction.defencePierce), 500);
  });

  test('Check buffTrait', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(703300)
        ..npLv = 5
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    await battle.activateSvtSkill(0, 0);
    final arjuna = battle.onFieldAllyServants[0]!;
    final enemy = battle.onFieldEnemies[0]!;
    final prevHp = enemy.hp;
    await battle.playerTurn([CombatAction(arjuna, arjuna.getNPCard(battle)!)]);
    expect(prevHp - enemy.hp, 96971);
  });

  test('HpRatio', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData(1000100)
        ..lv = 80
        ..skillStrengthenLvs = [2, 2, 1],
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);
    await battle.activateSvtSkill(0, 1);

    final lip = battle.onFieldAllyServants[0]!;
    battle.setActivator(lip);

    lip.hp = lip.getMaxHp(battle) ~/ 2 + 13;
    expect(lip.getBuffValueOnAction(battle, BuffAction.atk), 1000);

    lip.hp = lip.getMaxHp(battle) ~/ 2 - 1;
    expect(lip.getBuffValueOnAction(battle, BuffAction.atk).toDouble(), moreOrLessEquals(1300, epsilon: 1));

    lip.hp = lip.getMaxHp(battle) ~/ 4;
    expect(lip.getBuffValueOnAction(battle, BuffAction.atk).toDouble(), moreOrLessEquals(1400, epsilon: 1));

    lip.hp = 1;
    expect(lip.getBuffValueOnAction(battle, BuffAction.atk).toDouble(), moreOrLessEquals(1500, epsilon: 1));
  });

  test('INDIVIDUALITIE', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(203200)..lv = 90,
      PlayerSvtData(304000)..lv = 80,
    ];
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
    final playerSettings = [
      PlayerSvtData(603700)..lv = 90,
      PlayerSvtData(500800)..lv = 80,
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final kama = battle.onFieldAllyServants[0]!;

    expect(kama.hp, 12889 + 1000);
    expect(kama.getMaxHp(battle), 12889 + 1000);

    await battle.activateSvtSkill(0, 0);

    expect(kama.hp, 12889 + 1000 - 1000);
    expect(kama.getMaxHp(battle), 12889 + 1000 - 1000);

    await battle.activateSvtSkill(1, 2);

    expect(kama.hp, 12889 + 1000 - 1000 + 3000);
    expect(kama.getMaxHp(battle), 12889 + 1000 - 1000 + 3000);
  });

  test('convert', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(2501100)..lv = 90,
      PlayerSvtData(504500)..lv = 80,
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final kukulcan = battle.onFieldAllyServants[0]!;
    battle.setActivator(battle.onFieldEnemies[0]!);
    battle.setTarget(kukulcan);

    expect(kukulcan.hasBuffOnAction(battle, BuffAction.specialInvincible), false);
    expect(kukulcan.hasBuffOnAction(battle, BuffAction.invincible), false);

    await battle.activateSvtSkill(1, 2);

    expect(kukulcan.hasBuffOnAction(battle, BuffAction.specialInvincible), true);
    expect(kukulcan.hasBuffOnAction(battle, BuffAction.invincible), false);
  });

  test('buffRate', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(2800100)..lv = 90,
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final oberon = battle.onFieldAllyServants[0]!;
    battle.setActivator(oberon);
    battle.setTarget(battle.onFieldEnemies[0]!);
    battle.currentCard = oberon.getNPCard(battle);

    expect(oberon.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);
    expect(oberon.getBuffValueOnAction(battle, BuffAction.npdamage), 0);

    await battle.activateSvtSkill(0, 0);

    expect(oberon.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);
    expect(oberon.getBuffValueOnAction(battle, BuffAction.npdamage), 300);

    await battle.activateSvtSkill(0, 2);

    expect(oberon.getBuffValueOnAction(battle, BuffAction.commandAtk), 1500);
    expect(oberon.getBuffValueOnAction(battle, BuffAction.npdamage), 600);
  });

  test('changeCommandCardType', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData(100100)
        ..lv = 90
        ..skillStrengthenLvs = [1, 2, 2],
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final altria = battle.onFieldAllyServants[0]!;

    await battle.activateSvtSkill(0, 1);
    expect(altria.getCards(battle).where((element) => element.cardType == CardType.buster).length, 5);
  });
}
