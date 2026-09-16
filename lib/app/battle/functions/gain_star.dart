import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class GainStar {
  static void gainStar(
    BattleData battleData,
    DataVals dataVals,
    BattleServantData? activator, {
    List<BattleServantData>? targets,
    bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }
    final times = targets?.length ?? 0;
    final gainTimes = activator == null && times == 0 ? 1 : times;

    for (int i = 0; i < gainTimes; i += 1) {
      battleData.changeStar(isNegative ? -dataVals.Value! : dataVals.Value!);
    }

    if (targets != null) {
      for (final target in targets) {
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }
}
