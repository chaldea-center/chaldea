import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  final List<PlayerSvtData> okuniWithDoubleCba = [
    PlayerSvtData.id(504900)
      ..tdLv = 3
      ..lv = 90,
    PlayerSvtData.id(503900)..lv = 90,
    PlayerSvtData.id(503900)..lv = 90,
  ];

  test('Test changeNP', () async {
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
    final okuni = battle.onFieldAllyServants[0]!;

    expect(okuni.np, 0);

    okuni.changeNP(9899);
    expect(okuni.np, 9899);

    okuni.changeNP(1);
    expect(okuni.np, 10000);

    okuni.changeNP(30000);
    expect(okuni.np, 20000);

    okuni.changeNP(-10005);
    expect(okuni.np, 9995);
  });

  test('Test get buff value', () async {
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
    final okuni = battle.onFieldAllyServants[0]!;

    expect(await okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);

    await battle.withCard(okuni.getNPCard(battle), () async {
      expect(await okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);
    });

    await battle.withCard(okuni.getCards(battle)[2], () async {
      // arts
      expect(await okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1040);
      expect(await okuni.hasBuffOnAction(battle, BuffAction.avoidance), isFalse);
    });

    await okuni.activateSkill(battle, 0);
    battle.withCard(okuni.getNPCard(battle), () async {
      expect(await okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1300);
      expect(await okuni.hasBuffOnAction(battle, BuffAction.avoidance), isTrue);
    });
  });

  test('Test commandCode', () async {
    final List<PlayerSvtData> okuniCommandCode = [
      PlayerSvtData.id(100100)
        ..tdLv = 3
        ..lv = 90
        ..commandCodes = [
          null,
          null,
          null,
          db.gameData.commandCodesById[8400460], // Mage of Flowers on buster card
          db.gameData.commandCodesById[8400460], // Mage of Flowers on buster card
        ],
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, okuniCommandCode, null);

    final altria = battle.onFieldAllyServants[0]!;
    expect(altria.np, 0);

    await battle.playerTurn([CombatAction(altria, altria.getCards(battle)[4])]);
    expect(altria.np, 1000);

    await battle.playerTurn([CombatAction(altria, altria.getCards(battle)[4])]);
    expect(altria.np, 1000);

    await battle.playerTurn(
        [CombatAction(altria, altria.getCards(battle)[4]), CombatAction(altria, altria.getCards(battle)[3])]);
    expect(altria.np, 2000);

    await battle.playerTurn([CombatAction(altria, altria.getCards(battle)[4])]);
    expect(altria.np, 3000);
  });

  test('Test traits', () async {
    final List<PlayerSvtData> melusineAndFeihu = [
      PlayerSvtData.id(304800)
        ..limitCount = 0
        ..lv = 90,
      PlayerSvtData.id(304800)
        ..limitCount = 3
        ..lv = 90,
      PlayerSvtData.id(404900)..lv = 80,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, melusineAndFeihu, null);

    final melusine = battle.onFieldAllyServants[0]!;
    final melusine2 = battle.onFieldAllyServants[1]!;
    final feihu = battle.onFieldAllyServants[2]!;
    expect(melusine.getTraits(battle).map((e) => e.signedId).contains(Trait.fae.id), true);
    expect(melusine2.getTraits(battle).map((e) => e.signedId).contains(Trait.fae.id), true);
    expect(melusine.getTraits(battle).map((e) => e.signedId).contains(Trait.havingAnimalsCharacteristics.id), true);
    expect(melusine2.getTraits(battle).map((e) => e.signedId).contains(Trait.havingAnimalsCharacteristics.id), true);
    expect(melusine.getTraits(battle).map((e) => e.signedId).contains(Trait.knightsOfTheRound.id), true);
    expect(melusine2.getTraits(battle).map((e) => e.signedId).contains(Trait.knightsOfTheRound.id), false);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(301), true);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(300), false);

    await battle.activateSvtSkill(2, 0);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(301), false);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(300), true);
  });

  test('Test skill scripts', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData.id(101000)..lv = 80,
      PlayerSvtData.id(504600)
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), false);
    expect(battle.isSkillSealed(0, 2), false);
    expect(battle.isSkillCondFailed(0, 2), true);

    final eli = battle.onFieldAllyServants[0]!;
    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), false);
    expect(battle.isSkillSealed(0, 2), false);
    expect(battle.isSkillCondFailed(0, 2), true);

    eli.np = 100;
    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), false);
    expect(battle.isSkillSealed(0, 2), false);
    expect(battle.isSkillCondFailed(0, 2), true);

    eli.np = 10000;
    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), true);
    expect(battle.isSkillSealed(0, 2), false);
    expect(battle.isSkillCondFailed(0, 2), false);

    expect(battle.canUseNp(1), true);
    expect(battle.canSelectNp(1), false);

    battle.criticalStars = 20;
    expect(battle.canUseNp(1), true);
    expect(battle.canSelectNp(1), true);
  });

  test('Test act rarity skill script', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData.id(201300)..ce = db.gameData.craftEssencesById[9407100],
      PlayerSvtData.id(102600)..ce = db.gameData.craftEssencesById[9407100],
    ];

    final quest = db.gameData.questPhases[9300040603]!;
    quest.individuality = [...quest.individuality, NiceTrait(id: 94000144)];
    final battle = BattleData();
    await battle.init(quest, playerSettings, null);

    final arash = battle.onFieldAllyServants[0]!;
    final deon = battle.onFieldAllyServants[1]!;

    expect(arash.battleBuff.allBuffs.length, 4);
    expect(deon.battleBuff.allBuffs.length, 3);
  });

  test('Chen Gong NP', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData.id(504400)
        ..lv = 80
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(2800100)..lv = 90,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    expect(battle.canUseNp(0), true);

    battle.allyTargetIndex = 1;
    await battle.activateSvtSkill(1, 2);

    await battle.skipWave();

    expect(battle.canUseNp(0), false);
  });

  test('UI method does not reset stack', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData.id(504400)
        ..lv = 80
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);
    final svt = battle.onFieldAllyServants[0]!;

    expect(battle.activator, null);

    svt.getTraits(battle);
    expect(battle.activator, null);

    svt.isAlive(battle);
    expect(battle.activator, null);

    svt.isSkillSealed(battle, 0);
    expect(battle.activator, null);

    svt.isSkillSealed(battle, 2);
    expect(battle.activator, null);

    svt.canUseSkillIgnoreCoolDown(battle, 0);
    expect(battle.activator, null);

    await svt.activateSkill(battle, 0);
    expect(battle.activator, null);

    svt.canNP(battle);
    expect(battle.activator, null);

    svt.canAttack(battle);
    expect(battle.activator, null);

    svt.canOrderChange(battle);
    expect(battle.activator, null);

    svt.canSelectNP(battle);
    expect(battle.activator, null);

    svt.checkNPScript(battle);
    expect(battle.activator, null);

    svt.getCurrentNP(battle);
    expect(battle.activator, null);
  });
}
