import 'package:chaldea/utils/basic.dart';
import 'common.dart';
import 'event.dart';
import 'toplogin.dart';

extension MasterDataManagerX on MasterDataManager {
  MissionProgressType getMissionProgress(int missionId) {
    return MissionProgressType.fromValue(userEventMission[missionId]?.missionProgressType ?? 0);
  }

  ({MissionProgressType progressType, List<({int? progress, int targetNum})> progresses}) resolveMissionProgress(
    EventMission mission,
  ) {
    final eventMissionFix = userEventMissionFix[mission.id];
    if (eventMissionFix != null) {
      // progressType=eventMissionFix.progressType;
      // progressNum = eventMissionFix.num;
    }
    List<({int? progress, int targetNum})> progresses = [];
    // DIDN'T consider condGroup
    for (final cond in mission.clearConds) {
      int? progressNum;
      if (cond.condType == CondType.missionConditionDetail) {
        progressNum = Maths.sum(cond.targetIds.map((e) => userEventMissionCondDetail[e]?.progressNum));
      } else if (cond.condType == CondType.eventMissionClear) {
        progressNum = cond.targetIds.where((missionId) => getMissionProgress(missionId).isClearOrAchieve).length;
      } else if (cond.condType == CondType.questClear) {
        progressNum = cond.targetIds.where((questId) => (userQuest[questId]?.clearNum ?? 0) > 0).length;
      }
      progresses.add((progress: progressNum, targetNum: cond.targetNum));
    }

    return (progressType: getMissionProgress(mission.id), progresses: progresses);
  }
}
