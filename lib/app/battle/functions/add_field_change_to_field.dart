import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class AddFieldChangeToField {
  AddFieldChangeToField._();

  static void addFieldChangeToField(
    BattleData battleData,
    Buff buff,
    DataVals dataVals,
    BattleServantData? activator,
    List<BattleServantData> targets, {
    bool isShortBuff = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final buffData = BuffData(
      buff: buff,
      vals: dataVals,
      addOrder: battleData.getNextAddOrder(),
      activatorUniqueId: activator?.uniqueId,
      activatorName: activator?.lBattleName,
    );

    if (isShortBuff) {
      buffData.logicTurn -= 1;
    }
    battleData.fieldBuffs.add(buffData);

    for (final target in targets) {
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
