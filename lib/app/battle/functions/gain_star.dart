import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class GainStar {
  static bool gainStar(
    final BattleData battleData,
    final DataVals dataVals, {
    final int times = 1,
    final bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    final gainTimes = battleData.activator == null && times == 0 ? 1 : times;

    for (int i = 0; i < gainTimes; i += 1) {
      battleData.changeStar(isNegative ? -dataVals.Value! : dataVals.Value!);
    }

    return true;
  }
}
