import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class SkillChargeTurn {
  SkillChargeTurn._();

  static bool _ignoreSkill(DataVals dataVals, int skillIndex) {
    final targetIndex = (dataVals.Value2 ?? 0) - 1;
    return targetIndex >= 0 && targetIndex != skillIndex;
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
      for (final (index, skill) in target.skillInfoList.indexed) {
        if (_ignoreSkill(dataVals, index)) continue;
        skill.shortenSkill(dataVals.Value ?? 0);
      }
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static void extendSkill(final BattleData battleData, final DataVals dataVals, final List<BattleServantData> targets) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      for (final (index, skill) in target.skillInfoList.indexed) {
        if (_ignoreSkill(dataVals, index)) continue;
        skill.extendSkill(dataVals.Value ?? 0);
      }
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static void updateUserEquipSkillChargeTurn(BattleData battleData, DataVals dataVals, bool isProgress) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final turns = dataVals.Value ?? 0;

    for (final (index, skill) in battleData.masterSkillInfo.indexed) {
      if (_ignoreSkill(dataVals, index)) continue;
      if (isProgress) {
        skill.shortenSkill(turns);
      } else {
        skill.extendSkill(turns);
      }
    }
    battleData.setFuncResult(-8888, true);
  }
}
