import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/gamedata/vals.dart';

bool gainNP(BattleData battleData, DataVals dataVals, Iterable<BattleServantData> targets) {
  final functionRate = dataVals.Rate ?? 1000;
  if (functionRate < battleData.probabilityThreshold) {
    return false;
  }

  targets.forEach((target) {
    battleData.target = target;

    target.changeNP(dataVals.Value!);

    battleData.target = null;
  });

  return true;
}
