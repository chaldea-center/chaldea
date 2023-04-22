import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class HastenNpturn {
  HastenNpturn._();

  static bool hastenNpturn(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return false;
    }

    targets.forEach((target) {
      battleData.setTarget(target);

      target.changeNPLineCount(isNegative ? -dataVals.Value! : dataVals.Value!);

      battleData.unsetTarget();
    });

    return true;
  }
}
