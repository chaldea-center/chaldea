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
      int change = isNegative ? -dataVals.Value! : dataVals.Value!;
      target.changeNP(change);
      battleData.setFuncResult(target.uniqueId, true);
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
      int change = isNegative ? -dataVals.Value! : dataVals.Value!;
      target.changeNP((target.np * toModifier(change)).toInt());
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static void gainNpPerIndividual(
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
        final List<BattleServantData> aliveAllies =
            target.isPlayer ? battleData.nonnullPlayers : battleData.nonnullEnemies;
        final List<BattleServantData> aliveEnemies =
            target.isPlayer ? battleData.nonnullEnemies : battleData.nonnullPlayers;
        final List<BattleServantData> countTargets = [];
        final targetType = dataVals.Value2 ?? 0;
        if (targetType == 0) {
          countTargets.add(target);
        } else if (targetType == 1) {
          countTargets.addAll(aliveAllies);
        } else if (targetType == 2) {
          countTargets.addAll(aliveEnemies);
        } else if (targetType == 3) {
          countTargets.addAll(aliveAllies);
          countTargets.addAll(aliveEnemies);
        }

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
        change *= count;
      }

      target.changeNP(change);
      battleData.setFuncResult(target.uniqueId, true);
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
    }
  }
}
