import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class AddBattlePoint {
  AddBattlePoint._();

  static void addBattlePoint(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
    final int? overchargeState,
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

    for (final target in targets) {
      final friendShipAbove = dataVals.FriendShipAbove ?? 0;
      if (friendShipAbove > target.bond) {
        continue;
      }

      final startingPosition = dataVals.StartingPosition;
      if (startingPosition != null && !startingPosition.contains(target.startingPosition)) {
        continue;
      }

      final ocStateRange = dataVals.CheckOverChargeStageRange;
      if (ocStateRange != null
          && (overchargeState == null || !DataVals.isSatisfyRangeText(overchargeState, ranges: ocStateRange))) {
        continue;
      }

      final curBattlePoint = target.curBattlePoints[battlePointId];
      if (curBattlePoint != null) {
        target.curBattlePoints[battlePointId] = curBattlePoint + dataVals.BattlePointValue!;
        battleData.setFuncResult(target.uniqueId, true);
        battleData.battleLogger.debug("AddBattlePoint ($battlePointId): $curBattlePoint => "
            "${target.curBattlePoints[battlePointId]}");
      }
    }
  }
}
