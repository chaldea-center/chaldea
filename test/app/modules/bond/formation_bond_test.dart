import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
    await db.initiateForTest(testAppPath: const String.fromEnvironment('APP_PATH'));
    db.gameData = (await GameDataLoader.instance.reload(offline: true, silent: true))!;
  });

  test('solver settings belong to the formation option', () {
    final first = User();
    final second = User();
    expect(first.formationBondOption.maxCost, isNull);
    expect(second.formationBondOption.maxCost, isNull);
    expect(first.formationBondOption, isNot(same(second.formationBondOption)));

    first.formationBondOption
      ..maxCost = 120
      ..maxCandidateTeams = 60
      ..excludedSvts.add(100100);
    final restored = User.fromJson(first.toJson());
    expect(restored.formationBondOption.maxCost, 120);
    expect(restored.formationBondOption.maxCandidateTeams, 60);
    expect(restored.formationBondOption.excludedSvts, {100100});
    expect(second.formationBondOption.maxCost, isNull);
  });

  test('empty support slot survives formation serialization', () {
    final team = BattleTeamSetup();
    team.svts[2].supportType = SupportSvtType.friend;
    final saved = team.toFormationData();
    expect(saved.svts[2]?.supportType, SupportSvtType.friend);
    final restored = BattleTeamFormation.fromJson(saved.toJson());
    expect(restored.svts[2]?.supportType, SupportSvtType.friend);
    expect(restored.svts[2]?.svtId, isNull);
  });

  test('formation draft copies a fixed CE independently', () {
    final source = FormationBondOption(
      maxCost: 120,
      excludedSvts: {100100},
      teamFormation: BattleTeamFormation(
        svts: [
          SvtSaveData(equip1: SvtEquipSaveData(id: 9401060)),
          null,
          null,
          null,
          null,
          null,
        ],
      ),
    );
    final draft = FormationBondOption.fromJson(source.toJson());
    expect(draft.teamFormation.svts[0]?.equip1.id, 9401060);
    draft.teamFormation.svts[0]?.equip1.id = 9401061;
    draft.excludedSvts.add(100200);
    expect(source.teamFormation.svts[0]?.equip1.id, 9401060);
    expect(source.excludedSvts, {100100});
  });
}
