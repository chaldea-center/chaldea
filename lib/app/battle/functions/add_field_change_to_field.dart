import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class AddFieldChangeToField {
  AddFieldChangeToField._();

  static void addFieldChangeToField(
    final BattleData battleData,
    final Buff buff,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    final activator = battleData.activator;
    final buffData = BuffData(buff, dataVals)
      ..actorUniqueId = activator?.uniqueId
      ..actorName = activator?.lBattleName;
    battleData.fieldBuffs.add(buffData);

    for (final target in targets) {
      battleData.curFuncResults[target.uniqueId] = true;
    }
  }
}
