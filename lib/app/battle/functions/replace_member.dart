import 'package:tuple/tuple.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../interactions/replace_member.dart';

class ReplaceMember {
  ReplaceMember._();

  static Future<void> replaceMember(
    final BattleData battleData,
    final DataVals dataVals,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    if (battleData.nonnullPlayers.where((svt) => svt.canOrderChange()).isEmpty ||
        battleData.nonnullBackupPlayers.where((svt) => svt.canOrderChange()).isEmpty) {
      return;
    }

    for (final svt in battleData.nonnullPlayers) {
      svt.battleBuff.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
    }

    final List<BattleServantData?> onFieldList = battleData.onFieldAllyServants;
    final List<BattleServantData?> backupList = battleData.playerDataList;

    final Tuple2<BattleServantData, BattleServantData>? selections;
    if (battleData.delegate?.replaceMember != null) {
      selections = await battleData.delegate!.replaceMember!.call(onFieldList, backupList);
    } else {
      selections = await ReplaceMemberSelectionDialog.show(battleData);
    }
    if (selections == null) return;

    // cannot use fieldIndex since order may have already changed
    // fieldIndex is maintained at the end of skill activations
    final onFieldIndex = onFieldList.indexOf(selections.item1);
    final backupIndex = backupList.indexOf(selections.item2);
    battleData.replayDataRecord.replaceMemberIndexes.add([onFieldIndex, backupIndex]);

    battleData.recorder.orderChange(onField: selections.item1, backup: selections.item2);

    onFieldList[onFieldIndex] = selections.item2;
    backupList[backupIndex] = selections.item1;
    battleData.curFuncResults[selections.item1.uniqueId] = true;
    battleData.curFuncResults[selections.item2.uniqueId] = true;

    await selections.item2.enterField(battleData);
  }
}
