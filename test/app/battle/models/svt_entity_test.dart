import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
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

  final List<PlayerSvtData> okuniWithDoubleCba = [
    PlayerSvtData(504900)
      ..svtId = 504900
      ..npLv = 3
      ..lv = 90,
    PlayerSvtData(503900)
      ..svtId = 503900
      ..lv = 90,
    PlayerSvtData(503900)
      ..svtId = 503900
      ..lv = 90,
  ];

  test('Test changeNP', () {
    final battle = BattleData();
    battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
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

  test('Test get buff value', () {
    final battle = BattleData();
    battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
    final okuni = battle.onFieldAllyServants[0]!;

    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);

    battle.currentCard = okuni.getNPCard();
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1000);

    battle.currentCard = okuni.getCards()[2]; // arts
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1040);
    expect(okuni.hasBuffOnAction(battle, BuffAction.avoidance), isFalse);

    okuni.activateSkill(battle, 0);
    battle.currentCard = okuni.getNPCard();
    expect(okuni.getBuffValueOnAction(battle, BuffAction.commandAtk), 1300);
    expect(okuni.hasBuffOnAction(battle, BuffAction.avoidance), isTrue);
  });
}
