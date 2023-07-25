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
      battleData.withTargetSync(target, () {
        for (final skill in target.skillInfoList) {
          skill.shortenSkill(dataVals.Value!);
        }
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }

  static void extendSkill(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    for (final target in targets) {
      battleData.withTargetSync(target, () {
        for (final skill in target.skillInfoList) {
          skill.extendSkill(dataVals.Value!);
        }
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }
}
