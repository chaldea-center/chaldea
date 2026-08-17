import 'dart:math' show max, min;

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/utils/utils.dart';

class BattlePointCalc {
  BattlePointCalc._();

  static void changeBattlePoint(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
    final int? overchargeState,
    final List<int>? ignoreBattlePoints, {
    required final bool isAddition,
  }) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final battlePointId = dataVals.BattlePointId ?? 0;
    if (battlePointId == 0) {
      return;
    }
    final questBlockList = battleData.niceQuest?.extraDetail?.IgnoreBattlePointUp;
    if (questBlockList != null && questBlockList.contains(battlePointId)) {
      return;
    }

    if (ignoreBattlePoints != null && ignoreBattlePoints.contains(battlePointId)) {
      return;
    }

    for (final target in targets) {
      if (!canReceiveBattlePoint(target, battlePointId)) continue;

      final friendShipAbove = dataVals.FriendShipAbove ?? 0;
      if (friendShipAbove > target.bondLv) {
        continue;
      }

      final startingPosition = dataVals.StartingPosition;
      if (startingPosition != null && !startingPosition.contains(target.startingPosition)) {
        continue;
      }

      final ocStateRange = dataVals.CheckOverChargeStageRange;
      if (ocStateRange != null &&
          (overchargeState == null || !DataVals.isSatisfyRangeText(overchargeState, ranges: ocStateRange))) {
        continue;
      }

      final battlePoint = getOrCreateBattlePoint(target, battlePointId);
      battlePoint.maxValue = getBattlePointMax(target, battlePointId);
      final curBattlePoint = battlePoint.value;
      final nextBattlePoint = curBattlePoint + (isAddition ? 1 : -1) * dataVals.BattlePointValue!;
      battlePoint.value = battlePoint.maxValue == null
          ? (isAddition ? nextBattlePoint : max(nextBattlePoint, 0))
          : nextBattlePoint.clamp(0, battlePoint.maxValue!);
      battleData.setFuncResult(target.uniqueId, true);
      battleData.battleLogger.debug(
        "${isAddition ? 'Add' : 'Sub'}BattlePoint ($battlePointId): $curBattlePoint => "
        "${battlePoint.value}",
      );
    }
  }

  static int? getBattlePointMax(final BattleServantData target, final int battlePointId) {
    final battlePoint = getBattlePointDefinition(target, battlePointId);
    final script = battlePoint?.script;
    if (script == null) return null;

    int? maxValue = script.defaultMax;
    final maxChanges = script.maxChange ?? [], maxLimit = script.maxLimit;

    for (final change in maxChanges) {
      if (Individuality.checkSignedIndivPartialMatch(
            self: target.getTraits(isIncludeNpEffectIndiv: false),
            signedTarget: change.individuality,
          ) &&
          change.value != null) {
        maxValue = change.value;
        break; // first match
      }
    }

    for (final buff in collectBuffsPerAction(target.battleBuff.validBuffs, BuffAction.maxBattlePoint)) {
      if (buff.vals.BattlePointId == null || buff.vals.BattlePointId == battlePointId) {
        maxValue = (maxValue ?? 0) + buff.param;
      }
    }

    if (maxValue != null && maxLimit != null && maxLimit != 0) {
      maxValue = min(maxValue, maxLimit);
    }

    return maxValue;
  }

  static BattlePoint? getBattlePointDefinition(final BattleServantData target, final int battlePointId) {
    final battlePoint = ConstData.battlePoints[battlePointId];
    if (battlePoint == null) return null;

    final targetTraits = target.getTraits(isIncludeNpEffectIndiv: false);
    final isTargetSvt = battlePoint.svts.any(
      (svt) =>
          svt.svtId == target.svtId ||
          (svt.individuality != null &&
              Individuality.checkSignedMultiIndividuality(
                selfArray: targetTraits,
                signedTargetsArray: svt.individuality,
              )),
    );
    if (!isTargetSvt) return null;
    return battlePoint;
  }

  static bool canReceiveBattlePoint(final BattleServantData target, final int battlePointId) {
    final battlePoint = getBattlePointDefinition(target, battlePointId);
    if (battlePoint == null) return false;
    if (battlePoint.flags.contains(BattlePointFlag.notTargetOtherPlayer) &&
        target.playerSvtData?.supportType == .friend) {
      return false;
    }
    return true;
  }

  static BattlePointData getOrCreateBattlePoint(final BattleServantData target, final int battlePointId) {
    return target.curBattlePoints[battlePointId] ??= BattlePointData(
      value: 0,
      maxValue: getBattlePointMax(target, battlePointId),
    );
  }

  static int determineBattlePointPhase(final BattleServantData target, final int battlePointId) {
    final battlePoint = BattlePointCalc.getBattlePointDefinition(target, battlePointId);
    if (battlePoint == null) return 0;

    final state = target.curBattlePoints[battlePointId];
    if (state == null) return 0;
    final curBattlePoint = state.value;

    if (battlePoint.flags.contains(BattlePointFlag.battlePointCheckAsPercentage) == true) {
      assert(state.maxValue != null);
      final maxValue = state.maxValue ?? 0;
      final percentage = maxValue == 0 ? 0 : curBattlePoint * 1000 ~/ maxValue;
      int phase = 0;
      for (final battlePointPhase in battlePoint.phases) {
        if (battlePointPhase.value <= percentage) {
          phase = max(phase, battlePointPhase.phase);
        }
      }
      return phase;
    } else {
      int phase = 0;
      for (final battlePointPhase in battlePoint.phases) {
        if (battlePointPhase.value <= curBattlePoint) {
          phase = max(phase, battlePointPhase.phase);
        }
      }
      return phase;
    }
  }

  static int getMaxBattlePointPhase(final BattleServantData target, int battlePointId) {
    final battlePoint = BattlePointCalc.getBattlePointDefinition(target, battlePointId);
    return Maths.max(battlePoint?.phases.map((e) => e.phase) ?? <int>[], 0);
  }

  static int getBattlePointRate(final BattleServantData target, final int battlePointId) {
    final maxValue = BattlePointCalc.getBattlePointMax(target, battlePointId);
    if (maxValue == null || maxValue <= 0) return 0;
    return ((target.curBattlePoints[battlePointId]?.value ?? 0) * 1000 ~/ maxValue).clamp(0, 1000);
  }
}
