import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class ShortenSkill {
  ShortenSkill._();

  static void shortenSkill(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    for (final target in targets) {
      battleData.setTarget(target);
      target.skillInfoList.forEach((skill) {
        skill.shortenSkill(dataVals.Value!);
      });
      battleData.curFuncResults[target.uniqueId] = true;
      battleData.unsetTarget();
    }
  }
}
