import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class ShortenSkill {
  ShortenSkill._();

  static bool shortenSkill(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    for (final target in targets) {
      battleData.setTarget(target);
      target.skillInfoList.forEach((skill) {
        skill.shortenSkill(dataVals.Value!);
      });
      battleData.unsetTarget();
    }
    return true;
  }
}
