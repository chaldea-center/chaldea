import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

bool gainStar(final BattleData battleData, final DataVals dataVals) {
  final functionRate = dataVals.Rate ?? 1000;
  if (functionRate < battleData.probabilityThreshold) {
    return false;
  }

  battleData.changeStar(dataVals.Value!);

  return true;
}
