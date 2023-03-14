import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class GainStar {
  static bool gainStar(
    final BattleData battleData,
    final DataVals dataVals, {
    final bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    battleData.changeStar(dataVals.Value! * (isNegative ? -1 : 1));

    return true;
  }
}
