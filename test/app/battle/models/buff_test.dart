import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
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

  group('Test shouldApplyBuff', () {
    final battle = BattleData();
    final okuni = BattleServantData.fromPlayerSvtData(PlayerSvtData(504900)
      ..svtId = 504900
      ..lv = 90);
    final cba = BattleServantData.fromPlayerSvtData(PlayerSvtData(504900)
      ..svtId = 503900
      ..lv = 90);

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
}
