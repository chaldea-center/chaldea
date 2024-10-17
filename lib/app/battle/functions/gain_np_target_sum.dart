import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'gain_np.dart';

class GainNpTargetSum {
  GainNpTargetSum._();

  static void gainNpTargetSum(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final List<NiceTrait>? targetTraits,
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
            .where((svt) => checkSignedIndividualities2(
                  myTraits: svt.getTraits(
                    addTraits: svt.getBuffTraits(
                      activeOnly: dataVals.GainNpTargetPassiveIndividuality != 1,
                      ignoreIndivUnreleaseable: false,
                      includeIgnoreIndiv: false,
                    ),
                  ),
                  requiredTraits: targetTraits,
                ))
            .length;
        target.changeNP(change * count);

        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }
}
