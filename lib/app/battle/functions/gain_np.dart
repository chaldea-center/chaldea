import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainNP {
  GainNP._();

  static void gainNP(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final bool isNegative = false,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      battleData.withTargetSync(target, () {
        int change = isNegative ? -dataVals.Value! : dataVals.Value!;
        target.changeNP(change);
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }

  static Future<void> gainNpPerIndividual(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final List<NiceTrait>? targetTraits,
    final bool onlyCheckBuff = false,
    final bool isNegative = false,
  }) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        int change = isNegative ? -dataVals.Value! : dataVals.Value!;
        if (targetTraits != null) {
          final List<BattleServantData> countTargets = [];
          final targetType = dataVals.Value2 ?? 0;
          if (targetType == 0) {
            countTargets.add(target);
          }
          if (targetType == 1 || targetType == 3) {
            countTargets.addAll(await FunctionExecutor.acquireFunctionTarget(battleData, FuncTargetType.ptAll, target));
          }
          if (targetType == 2 || targetType == 3) {
            countTargets
                .addAll(await FunctionExecutor.acquireFunctionTarget(battleData, FuncTargetType.enemyAll, target));
          }

          int count = 0;
          final bool activeBuffOnly = onlyCheckBuff || (dataVals.GainNpTargetPassiveIndividuality ?? 0) < 1;

          for (final countTarget in countTargets) {
            count += countTarget.countBuffWithTrait(targetTraits, activeOnly: activeBuffOnly);
            if (!onlyCheckBuff) {
              count += countTarget.countTrait(battleData, targetTraits);
            }
          }
          change *= count;
        }

        target.changeNP(change);
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }
}
