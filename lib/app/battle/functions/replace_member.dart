import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../interactions/replace_member.dart';

class ReplaceMember {
  ReplaceMember._();

  static Future<bool> replaceMember(
    final BattleData battleData,
    final DataVals dataVals,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return false;
    }

    if (battleData.nonnullAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty ||
        battleData.nonnullBackupAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty) {
      return false;
    }

    battleData.nonnullAllies.forEach((svt) {
      svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
    });

    final List<BattleServantData?> onFieldList = battleData.onFieldAllyServants;
    final List<BattleServantData?> backupList = battleData.playerDataList;

    final selections = await ReplaceMemberSelectionDialog.show(battleData);
    if (selections == null) return false;

    battleData.recorder.orderChange(onField: selections.item1, backup: selections.item2);

    onFieldList[onFieldList.indexOf(selections.item1)] = selections.item2;
    backupList[backupList.indexOf(selections.item2)] = selections.item1;

    selections.item2.enterField(battleData);

    return true;
  }
}
