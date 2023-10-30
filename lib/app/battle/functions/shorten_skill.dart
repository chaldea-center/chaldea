import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class ShortenSkill {
  ShortenSkill._();

  static bool _ignoreSkill(DataVals dataVals, int skillNum) {
    final targetNum = dataVals.Target;
    return targetNum != null && targetNum != skillNum;
  }

  static void shortenSkill(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      battleData.withTargetSync(target, () {
        for (int index = 0; index < target.skillInfoList.length; index++) {
          if (_ignoreSkill(dataVals, index + 1)) continue;
          final skill = target.skillInfoList[index];
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
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      battleData.withTargetSync(target, () {
        for (int index = 0; index < target.skillInfoList.length; index++) {
          if (_ignoreSkill(dataVals, index + 1)) continue;
          final skill = target.skillInfoList[index];
          skill.extendSkill(dataVals.Value!);
        }
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }
}
