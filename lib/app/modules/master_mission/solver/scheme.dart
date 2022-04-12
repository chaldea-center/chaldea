import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/models/models.dart';
import 'package:flutter/material.dart';

class CustomMission {
  MissionTargetType type;
  int count;
  List<int> ids;
  String? originDetail;
  CustomMission({
    required this.type,
    required this.count,
    required this.ids,
    this.originDetail,
  });

  static CustomMission? fromEventMission(EventMission eventMission) {
    for (final cond in eventMission.conds) {
      if (cond.missionProgressType != MissionProgressType.clear ||
          cond.condType != CondType.missionConditionDetail ||
          cond.detail == null) {
        continue;
      }
      final type = _kDetailCondMapping[cond.detail!.missionCondType];
      if (type == null) continue;
      if (type == MissionTargetType.quest &&
          cond.detail!.targetIds.length == 1 &&
          cond.detail!.targetIds.first == 0) {
        // any quest
        continue;
      }
      return CustomMission(
        type: type,
        count: cond.targetNum,
        ids: cond.detail!.targetIds,
        originDetail: cond.conditionMessage,
      );
    }
    return null;
  }

  CustomMission copy() {
    return CustomMission(
      type: type,
      count: count,
      ids: List.of(ids),
      originDetail: originDetail,
    );
  }

  Widget buildDescriptor(BuildContext context) {
    CondType condType = CondType.missionConditionDetail;
    int missionCondType = _kDetailCondMappingReverse[type] ?? -1;
    return CondTargetNumDescriptor(
      condType: condType,
      targetNum: count,
      targetIds: const [0],
      detail: EventMissionConditionDetail(
        id: 0,
        missionTargetId: 0,
        missionCondType: missionCondType,
        targetIds: ids,
        logicType: 0,
        conditionLinkType: DetailMissionCondLinkType.missionStart,
      ),
    );
  }
}

class MissionSolution {
  final Map<int, int> result;
  final List<CustomMission> missions;
  final Map<int, QuestPhase> quests;
  final Region region;
  MissionSolution({
    required this.result,
    required this.missions,
    required List<QuestPhase> quests,
    this.region = Region.jp,
  }) : quests = {for (final quest in quests) quest.id: quest};
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

const _kDetailCondMapping = {
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

final _kDetailCondMappingReverse = {
  MissionTargetType.quest: DetailCondType.questClearNum1,
  MissionTargetType.enemy: DetailCondType.enemyKillNum,
  MissionTargetType.trait: DetailCondType.defeatEnemyIndividuality,
  MissionTargetType.servantClass: DetailCondType.defeatServantClass,
  MissionTargetType.enemyClass: DetailCondType.defeatEnemyClass,
  MissionTargetType.enemyNotServantClass:
      DetailCondType.defeatEnemyNotServantClass,
  MissionTargetType.questTrait: DetailCondType.questClearIndividuality,
};
