import 'package:chaldea/models/models.dart';

class CustomMission {
  MissionTargetType type;
  int count;
  List<int> ids;
  CustomMission({
    required this.type,
    required this.count,
    required this.ids,
  });

  static CustomMission? fromEventMission(EventMission eventMission) {
    for (final cond in eventMission.conds) {
      if (cond.missionProgressType != MissionProgressType.clear ||
          cond.condType != CondType.missionConditionDetail ||
          cond.detail == null) {
        continue;
      }
      final type = kMissionDetailCondMapping[cond.detail!.missionCondType];
      if (type == null) continue;
      if (type == MissionTargetType.quest &&
          cond.detail!.targetIds.length == 1 &&
          cond.detail!.targetIds.first == 0) {
        // any quest
        continue;
      }
      return CustomMission(
          type: type, count: cond.targetNum, ids: cond.detail!.targetIds);
    }
    return null;
  }
}

enum MissionTargetType {
  trait,
  questTrait,
  quest,
  enemy,
  servantClass,
  enemyClass,
  enemyNotServantClass
}

const kMissionDetailCondMapping = {
  DetailCondType.questClearNum1: MissionTargetType.quest,
  DetailCondType.questClearNum2: MissionTargetType.quest,
  DetailCondType.enemyKillNum: MissionTargetType.enemy,
  DetailCondType.defeatEnemyIndividuality: MissionTargetType.trait,
  DetailCondType.enemyIndividualityKillNum: MissionTargetType.trait,
  DetailCondType.defeatServantClass: MissionTargetType.servantClass,
  DetailCondType.defeatEnemyClass: MissionTargetType.enemyClass,
  DetailCondType.defeatEnemyNotServantClass:
      MissionTargetType.enemyNotServantClass,
};
