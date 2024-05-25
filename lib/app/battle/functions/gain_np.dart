import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
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
        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }

  static void gainMultiplyNP(
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
        target.changeNP((target.np * toModifier(change)).toInt());
        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }

  static Future<void> gainNpPerIndividual(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final List<NiceTrait>? targetTraits,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        int change = dataVals.Value!;
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

          for (final countTarget in countTargets) {
            count += countTarget.countBuffWithTrait(
              targetTraits,
              activeOnly: dataVals.GainNpTargetPassiveIndividuality != 1,
              ignoreIndivUnreleaseable: false,
              includeIgnoreIndiv: false,
            );
            count += countTarget.countTrait(battleData, targetTraits);
          }
          change *= count;
        }

        target.changeNP(change);
        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }

  static Future<void> gainNpPerBuffIndividual(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final List<NiceTrait> targetTraits,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        int change = dataVals.Value!;
        if (targetTraits.isNotEmpty) {
          int count = target.countBuffWithTrait(
            targetTraits,
            activeOnly: true,
            ignoreIndivUnreleaseable: false,
            includeIgnoreIndiv: false,
          );
          change *= count;
        }

        target.changeNP(change);
        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }
}
