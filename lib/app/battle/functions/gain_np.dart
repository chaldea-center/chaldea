import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainNp {
  GainNp._();

  static void gainNp(
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
      int change = isNegative ? -dataVals.Value! : dataVals.Value!;
      target.changeNP(change);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static void gainMultiplyNp(
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
      int change = isNegative ? -dataVals.Value! : dataVals.Value!;
      target.changeNP((target.np * toModifier(change)).toInt());
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static void gainNpPerIndividual(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? actor,
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
        final List<BattleServantData> countTargets = getCountTargets(battleData, target, targetType);

        int count = 0;

        for (final countTarget in countTargets) {
          count += countTarget.countBuffWithTrait(
            targetTraits,
            activeOnly: dataVals.GainNpTargetPassiveIndividuality != 1,
            ignoreIndivUnreleaseable: false,
            includeIgnoreIndiv: false,
          );
          count += countTarget.countTrait(targetTraits);
        }

        if (count > 0) {
          target.changeNP(change * count);
          battleData.setFuncResult(target.uniqueId, true);
        }
      }
    }
  }

  static void gainNpPerBuffIndividual(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final List<NiceTrait> targetTraits,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      int change = dataVals.Value!;
      int count = target.countBuffWithTrait(
        targetTraits,
        activeOnly: dataVals.GainNpTargetPassiveIndividuality != 1,
        ignoreIndivUnreleaseable: false,
        includeIgnoreIndiv: false,
      );

      if (count > 0) {
        target.changeNP(change * count);
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }

  static List<BattleServantData> getCountTargets(
    final BattleData battleData,
    final BattleServantData currentTarget,
    final int countType,
  ) {
    final List<BattleServantData> countTargets = [];

    final List<BattleServantData> aliveAllies = currentTarget.isPlayer
        ? battleData.nonnullPlayers
        : battleData.nonnullEnemies;
    final List<BattleServantData> aliveEnemies = currentTarget.isPlayer
        ? battleData.nonnullEnemies
        : battleData.nonnullPlayers;

    if (countType == GainNpIndividualSumTarget.target.value) {
      countTargets.add(currentTarget);
    } else if (countType == GainNpIndividualSumTarget.player.value) {
      countTargets.addAll(aliveAllies);
    } else if (countType == GainNpIndividualSumTarget.enemy.value) {
      countTargets.addAll(aliveEnemies);
    } else if (countType == GainNpIndividualSumTarget.all.value) {
      countTargets.addAll(aliveAllies);
      countTargets.addAll(aliveEnemies);
    } else if (countType == GainNpIndividualSumTarget.otherAll.value) {
      countTargets.addAll(aliveAllies);
      countTargets.addAll(aliveEnemies);
      countTargets.remove(currentTarget);
    }

    return countTargets;
  }

  static void gainNpCriticalStarSum(
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
      final changePerStar = isNegative ? -dataVals.Value! : dataVals.Value!;
      final maxStar = dataVals.Value2 ?? BattleData.kValidStarMax;
      target.changeNP(changePerStar * min(battleData.criticalStars.floor(), maxStar));
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
