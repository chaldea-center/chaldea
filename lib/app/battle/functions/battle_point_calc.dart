import 'dart:math' show max;

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/userdata/battle.dart';
import 'package:chaldea/utils/utils.dart';

class BattlePointCalc {
  BattlePointCalc._();

  static void addBattlePoint(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
    final int? overchargeState,
    final List<int>? ignoreBattlePoints,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final battlePointId = dataVals.BattlePointId;
    if (battlePointId == null) {
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
      battlePoint.max = getBattlePointMax(target, battlePointId);
      final curBattlePoint = battlePoint.current;
      final nextBattlePoint = curBattlePoint + dataVals.BattlePointValue!;
      battlePoint.current = battlePoint.max == null ? nextBattlePoint : nextBattlePoint.clamp(0, battlePoint.max!);
      battleData.setFuncResult(target.uniqueId, true);
      battleData.battleLogger.debug(
        "AddBattlePoint ($battlePointId): $curBattlePoint => "
        "${battlePoint.current}",
      );
    }
  }

  static void subBattlePoint(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
    final int? overchargeState,
    final List<int>? ignoreBattlePoints,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final battlePointId = dataVals.BattlePointId;
    if (battlePointId == null) {
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
      battlePoint.max = getBattlePointMax(target, battlePointId);
      final curBattlePoint = battlePoint.current;
      final nextBattlePoint = curBattlePoint - dataVals.BattlePointValue!;
      battlePoint.current = battlePoint.max == null
          ? max(nextBattlePoint, 0)
          : nextBattlePoint.clamp(0, battlePoint.max!);
      battleData.setFuncResult(target.uniqueId, true);
      battleData.battleLogger.debug(
        "SubBattlePoint ($battlePointId): $curBattlePoint => "
        "${battlePoint.current}",
      );
    }
  }

  static int? getBattlePointMax(final BattleServantData target, final int battlePointId) {
    final battlePoint = getBattlePointDefinition(target, battlePointId);
    if (battlePoint == null) return null;

    final script = battlePoint.script;
    if (script == null ||
        (script.defaultMax == null &&
            script.maxLimit == null &&
            (script.maxChange == null || script.maxChange!.isEmpty))) {
      return null;
    }

    int? maxValue = script.defaultMax;
    for (final change in script.maxChange ?? const <BattlePointScriptMaxChange>[]) {
      if (Individuality.checkSignedIndivPartialMatch(self: target.getTraits(), signedTarget: change.individuality)) {
        maxValue = change.value;
      }
    }

    for (final buff in collectBuffsPerAction(target.battleBuff.validBuffs, BuffAction.maxBattlePoint)) {
      if (buff.vals.BattlePointId == null || buff.vals.BattlePointId == battlePointId) {
        maxValue = (maxValue ?? 0) + buff.param;
      }
    }

    return script.maxLimit == null || maxValue == null ? maxValue : maxValue.clamp(0, script.maxLimit!);
  }

  static BattlePoint? getBattlePointDefinition(final BattleServantData target, final int battlePointId) {
    return target.niceSvt?.battlePoints.firstWhereOrNull((e) => e.id == battlePointId) ??
        ConstData.battlePoints[battlePointId];
  }

  static bool canReceiveBattlePoint(final BattleServantData target, final int battlePointId) {
    final battlePoint = getBattlePointDefinition(target, battlePointId);
    return battlePoint?.flags.contains(BattlePointFlag.notTargetOtherPlayer) != true ||
        target.playerSvtData?.supportType != SupportSvtType.friend;
  }

  static BattlePointState getOrCreateBattlePoint(final BattleServantData target, final int battlePointId) {
    final existing = target.curBattlePoints[battlePointId];
    if (existing != null) return existing;

    return target.curBattlePoints[battlePointId] = BattlePointState(
      current: 0,
      max: getBattlePointMax(target, battlePointId),
    );
  }

  static int determineBattlePointPhase(final BattleServantData target, final int battlePointId) {
    final battlePoint = BattlePointCalc.getBattlePointDefinition(target, battlePointId);
    final state = target.curBattlePoints[battlePointId];
    final curBattlePoint = state?.current;
    if (curBattlePoint == null) {
      return 0;
    }

    if (battlePoint?.flags.contains(BattlePointFlag.battlePointCheckAsPercentage) == true && state!.max != null) {
      final percentage = state.max == 0 ? 0 : curBattlePoint * 1000 ~/ state.max!;
      int phase = 0;
      for (final battlePointPhase in battlePoint!.phases) {
        if (battlePointPhase.value <= percentage) {
          phase = max(phase, battlePointPhase.phase);
        }
      }
      return phase;
    }
    if (battlePoint == null) return 0;

    int phase = 0;
    for (final battlePointPhase in battlePoint.phases) {
      if (battlePointPhase.value <= curBattlePoint) {
        phase = max(phase, battlePointPhase.phase);
      }
    }
    return phase;
  }

  static int getMaxBattlePointPhase(final BattleServantData target, int battlePointId) {
    final battlePoint = BattlePointCalc.getBattlePointDefinition(target, battlePointId);
    return Maths.max(battlePoint?.phases.map((e) => e.phase) ?? <int>[], 0);
  }

  static int getBattlePointRate(final BattleServantData target, final int battlePointId) {
    final maxValue = BattlePointCalc.getBattlePointMax(target, battlePointId);
    if (maxValue == null || maxValue <= 0) return 0;
    return ((target.curBattlePoints[battlePointId]?.current ?? 0) * 1000 ~/ maxValue).clamp(0, 1000);
  }
}
