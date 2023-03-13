import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class GainNP {
  GainNP._();

  static bool gainNP(final BattleData battleData, final DataVals dataVals, final Iterable<BattleServantData> targets) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    targets.forEach((target) {
      battleData.setTarget(target);

      target.changeNP(dataVals.Value!);

      battleData.unsetTarget();
    });

    return true;
  }
}

