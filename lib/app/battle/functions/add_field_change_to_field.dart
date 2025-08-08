import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class AddFieldChangeToField {
  AddFieldChangeToField._();

  static void addFieldChangeToField(
    final BattleData battleData,
    final Buff buff,
    final DataVals dataVals,
    final BattleServantData? activator,
    final List<BattleServantData> targets,
  ) {
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
    battleData.fieldBuffs.add(buffData);

    for (final target in targets) {
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
