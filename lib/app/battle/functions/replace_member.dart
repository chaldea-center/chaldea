import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:tuple/tuple.dart';
import '../interactions/replace_member.dart';

class ReplaceMember {
  ReplaceMember._();

  static Future<void> replaceMember(
    final BattleData battleData,
    final DataVals dataVals,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    if (battleData.nonnullAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty ||
        battleData.nonnullBackupAllies.where((svt) => svt.canOrderChange(battleData)).isEmpty) {
      return;
    }

    battleData.nonnullAllies.forEach((svt) {
      svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
    });

    final List<BattleServantData?> onFieldList = battleData.onFieldAllyServants;
    final List<BattleServantData?> backupList = battleData.playerDataList;

    final Tuple2<BattleServantData, BattleServantData>? selections;
    if (battleData.delegate?.replaceMember != null) {
      selections = await battleData.delegate!.replaceMember!.call(onFieldList, backupList);
    } else {
      selections = await ReplaceMemberSelectionDialog.show(battleData);
    }
    if (selections == null) return;

    battleData.recorder.orderChange(onField: selections.item1, backup: selections.item2);

    onFieldList[onFieldList.indexOf(selections.item1)] = selections.item2;
    backupList[backupList.indexOf(selections.item2)] = selections.item1;
    battleData.curFuncResults[selections.item1.uniqueId] = true;
    battleData.curFuncResults[selections.item2.uniqueId] = true;

    selections.item2.enterField(battleData);
  }
}
