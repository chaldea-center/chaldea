import 'dart:math' show max;

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class SubBattlePoint {
  SubBattlePoint._();

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

    final battlePointId = dataVals.BattlePointId!;
    final questBlockList = battleData.niceQuest?.extraDetail?.IgnoreBattlePointUp;
    if (questBlockList != null && questBlockList.contains(battlePointId)) {
      return;
    }

    if (ignoreBattlePoints != null && ignoreBattlePoints.contains(battlePointId)) {
      return;
    }

    for (final target in targets) {
      if (!target.canReceiveBattlePoint(battlePointId)) continue;

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

      final battlePoint = target.getOrCreateBattlePoint(battlePointId);
      battlePoint.max = target.getBattlePointMax(battlePointId);
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
}
