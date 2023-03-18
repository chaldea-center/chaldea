import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  final List<PlayerSvtData> okuniWithDoubleCba = [
    PlayerSvtData(504900)
      ..npLv = 3
      ..lv = 90,
    PlayerSvtData(503900)..lv = 90,
    PlayerSvtData(503900)..lv = 90,
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

    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);

    battle.currentCard = okuni.getNPCard(battle);
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);

    battle.currentCard = okuni.getCards(battle)[2]; // arts
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1040);
    expect(okuni.hasBuffOnAction(battle, BuffAction.avoidance), isFalse);

    await okuni.activateSkill(battle, 0);
    battle.currentCard = okuni.getNPCard(battle);
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1300);
    expect(okuni.hasBuffOnAction(battle, BuffAction.avoidance), isTrue);
  });

  test('Test commandCode', () async {
    final List<PlayerSvtData> okuniCommandCode = [
      PlayerSvtData(100100)
        ..npLv = 3
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
      PlayerSvtData(304800)
        ..ascensionPhase = 0
        ..lv = 90,
      PlayerSvtData(404900)..lv = 80,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, melusineAndFeihu, null);

    final melusine = battle.onFieldAllyServants[0]!;
    final feihu = battle.onFieldAllyServants[1]!;
    expect(melusine.getTraits(battle).map((e) => e.signedId).contains(Trait.knightsOfTheRound.id), isTrue);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(301), isTrue);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(300), isFalse);

    await battle.activateSvtSkill(1, 0);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(301), isFalse);
    expect(feihu.getTraits(battle).map((e) => e.signedId).contains(300), isTrue);
  });

  test('Test skill scripts', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData(101000)..lv = 80,
      PlayerSvtData(504600)
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), false);
    expect(battle.canUseNp(1), true);
    expect(battle.canSelectNp(1), false);

    final eli = battle.onFieldAllyServants[0]!;

    eli.np = 10000;

    expect(battle.canUseSvtSkillIgnoreCoolDown(0, 2), true);

    battle.criticalStars = 20;

    expect(battle.canUseNp(1), true);
    expect(battle.canSelectNp(1), true);
  });

  test('Chen Gong NP', () async {
    final List<PlayerSvtData> playerSettings = [
      PlayerSvtData(504400)
        ..lv = 80
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData(2800100)..lv = 90,
    ];

    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    expect(battle.canUseNp(0), true);

    battle.allyTargetIndex = 1;
    await battle.activateSvtSkill(1, 2);

    await battle.skipWave();

    expect(battle.canUseNp(0), false);
  });
}
