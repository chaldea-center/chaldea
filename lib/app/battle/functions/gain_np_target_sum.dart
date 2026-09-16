import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';

import 'gain_np.dart';

class GainNpTargetSum {
  GainNpTargetSum._();

  static void gainNpTargetSum(
    BattleData battleData,
    DataVals dataVals,
    Iterable<BattleServantData> targets,
    List<int>? targetTraits,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      int change = dataVals.Value!;
      if (targetTraits != null) {
        final targetType = dataVals.Value2 ?? 0;
        final List<BattleServantData> countTargets = GainNp.getCountTargets(battleData, target, targetType);

        final count = countTargets
            .where(
              (svt) => Individuality.checkSignedIndivPartialMatch(
                self: svt.getTraits(
                  addTraits: svt.getBuffTraits(
                    activeOnly: dataVals.GainNpTargetPassiveIndividuality != 1,
                    ignoreIndivUnreleaseable: false,
                    includeIgnoreIndiv: false,
                  ),
                ),
                signedTarget: targetTraits,
              ),
            )
            .length;

        if (count > 0) {
          target.changeNP(change * count);
          battleData.setFuncResult(target.uniqueId, true);
        }
      }
    }
  }
}
