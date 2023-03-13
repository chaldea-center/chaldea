import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
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
          Buff(
            id: -1,
            name: '',
            detail: '',
            vals: [NiceTrait(id: Trait.buffNegativeEffect.id)]
          ),
          DataVals({'UseRate': 1000}));

      battle.setTarget(cba);
      battle.setActivator(okuni);
      battle.setCurrentBuff(currentBuff);

      expect(buff.shouldApplyBuff(battle, false), isTrue);

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
    test('upDefence', () {
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
      expect(mash.getBuffValueOnAction(battle, BuffAction.defencePierce), 1000);
    });

    test('subSelfdamage', () {
      final battle = BattleData();
      final playerSettings = [
        PlayerSvtData(800100)
          ..skillStrengthenLvs = [2, 1, 1]
          ..npLv = 3
          ..lv = 80,
      ];
      battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

      final mash = battle.onFieldAllyServants[0]!;

      battle.activateSvtSkill(0, 0);
      expect(mash.getBuffValueOnAction(battle, BuffAction.receiveDamage), -2000);
    });
  });
}
