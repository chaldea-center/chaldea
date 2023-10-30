import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class HastenNpturn {
  HastenNpturn._();

  static void hastenNpturn(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    targets.forEach((target) {
      battleData.withTargetSync(target, () {
        target.changeNPLineCount(isNegative ? -dataVals.Value! : dataVals.Value!);
        battleData.curFuncResults[target.uniqueId] = true;
      });
    });
  }
}
