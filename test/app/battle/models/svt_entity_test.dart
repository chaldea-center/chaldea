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

    expect(await okuni.getBuffValue(battle, BuffAction.commandAtk), 1000);

    expect(await okuni.getBuffValue(battle, BuffAction.commandAtk, card: okuni.getNPCard()), 1000);

    // arts
    expect(await okuni.getBuffValue(battle, BuffAction.commandAtk, card: okuni.getCards()[2]), 1040);
    expect(await okuni.hasBuff(battle, BuffAction.avoidance), isFalse);

    await okuni.activateSkill(battle, 0);
    expect(await okuni.getBuffValue(battle, BuffAction.commandAtk, card: okuni.getNPCard()), 1300);
    expect(await okuni.hasBuff(battle, BuffAction.avoidance), isTrue);
  });

  test('Test commandCode CD', () async {
    final List<PlayerSvtData> svts = [
      PlayerSvtData.id(100100)
        ..tdLv = 3
        ..lv = 90
        ..commandCodes = [
          // QAABB
          null,
          db.gameData.commandCodesById[8400840]!, // 鞍馬の申し子, critical dmg 20%
          null,
          db.gameData.commandCodesById[8400460]!, // Mage of Flowers on buster card
          db.gameData.commandCodesById[8400460]!, // Mage of Flowers on buster card
        ],
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, svts, null);

    final altria = battle.onFieldAllyServants[0]!;
    expect(altria.np, 0);

    await battle.playerTurn([CombatAction(altria, altria.getCards()[4])]);
    expect(altria.np, 1000);

    await battle.playerTurn([CombatAction(altria, altria.getCards()[4])]);
    expect(altria.np, 1000);

    await battle.playerTurn([CombatAction(altria, altria.getCards()[4]), CombatAction(altria, altria.getCards()[3])]);
    expect(altria.np, 2000);

    await battle.playerTurn([CombatAction(altria, altria.getCards()[4])]);
    expect(altria.np, 3000);

    await battle.playerTurn([CombatAction(altria, altria.getCards()[1]), CombatAction(altria, altria.getCards()[2])]);
  });

  test('Test commandCode Clear', () async {
    final List<PlayerSvtData> svts = [
      PlayerSvtData.id(100100)
        ..tdLv = 3
        ..lv = 90
        ..commandCodes = [
          // QAABB
          null,
          db.gameData.commandCodesById[8400840]!, // 鞍馬の申し子, critical dmg 20%
          null, null, null
        ],
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, svts, null);

    final altria = battle.onFieldAllyServants[0]!;
    final enemy = battle.onFieldEnemies[0]!;
    expect(enemy.hp, 20094);

    await battle.playerTurn([
      CombatAction(altria, altria.getCards()[1]..critical = true),
      CombatAction(altria, altria.getCards()[2]..critical = true)
    ]);
    expect(enemy.hp, 9166);
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
    expect(melusine.getTraits().map((e) => e.signedId).contains(Trait.fae.value), true);
    expect(melusine2.getTraits().map((e) => e.signedId).contains(Trait.fae.value), true);
    expect(melusine.getTraits().map((e) => e.signedId).contains(Trait.havingAnimalsCharacteristics.value), true);
    expect(melusine2.getTraits().map((e) => e.signedId).contains(Trait.havingAnimalsCharacteristics.value), true);
    expect(melusine.getTraits().map((e) => e.signedId).contains(Trait.knightsOfTheRound.value), true);
    expect(melusine2.getTraits().map((e) => e.signedId).contains(Trait.knightsOfTheRound.value), false);
    expect(feihu.getTraits().map((e) => e.signedId).contains(301), true);
    expect(feihu.getTraits().map((e) => e.signedId).contains(300), false);

    await battle.activateSvtSkill(2, 0);
    expect(feihu.getTraits().map((e) => e.signedId).contains(301), false);
    expect(feihu.getTraits().map((e) => e.signedId).contains(300), true);
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
    quest.individuality = [...quest.questIndividuality, NiceTrait(id: 94000144)];
    quest.phaseIndividuality.clear();
    final battle = BattleData();
    await battle.init(quest, playerSettings, null);

    final arash = battle.onFieldAllyServants[0]!;
    final deon = battle.onFieldAllyServants[1]!;

    expect(arash.battleBuff.getAllBuffs().length, 4);
    expect(deon.battleBuff.getAllBuffs().length, 3);
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

    battle.playerTargetIndex = 1;
    await battle.activateSvtSkill(1, 2);

    await battle.skipWave();

    expect(battle.canUseNp(0), false);
  });
}
