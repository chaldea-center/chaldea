import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/mission_cond_detail.dart';
import 'package:chaldea/models/models.dart';

class CustomMission {
  CustomMissionType type;
  int count;
  List<int> ids;
  String? originDetail;

  bool _useAnd;
  set useAnd(bool v) => _useAnd = v;
  bool get useAnd => fixedLogicType ?? _useAnd;

  bool? get fixedLogicType {
    switch (type) {
      case CustomMissionType.trait:
      case CustomMissionType.questTrait:
        return null;
      case CustomMissionType.quest:
      case CustomMissionType.enemy:
      case CustomMissionType.servantClass:
      case CustomMissionType.enemyClass:
      case CustomMissionType.enemyNotServantClass:
        return false;
    }
  }

  CustomMission({
    required this.type,
    required this.count,
    required this.ids,
    this.originDetail,
    required bool useAnd,
  }) : _useAnd = useAnd;

  static CustomMission? fromEventMission(EventMission eventMission) {
    for (final cond in eventMission.conds) {
      if (cond.missionProgressType != MissionProgressType.clear ||
          cond.condType != CondType.missionConditionDetail ||
          cond.detail == null) {
        continue;
      }
      final type = kDetailCondMapping[cond.detail!.missionCondType];
      if (type == null) continue;
      if (type == CustomMissionType.quest &&
          cond.detail!.targetIds.length == 1 &&
          cond.detail!.targetIds.first == 0) {
        // any quest
        continue;
      }
      bool useAnd;
      switch (type) {
        case CustomMissionType.trait:
          useAnd = true;
          break;
        case CustomMissionType.questTrait:
          useAnd = false;
          break;
        case CustomMissionType.quest:
        case CustomMissionType.enemy:
        case CustomMissionType.servantClass:
        case CustomMissionType.enemyClass:
        case CustomMissionType.enemyNotServantClass:
          useAnd = false;
          break;
      }
      return CustomMission(
        type: type,
        count: cond.targetNum,
        ids: cond.detail!.targetIds,
        originDetail: cond.conditionMessage,
        useAnd: useAnd,
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
      useAnd: useAnd,
    );
  }

  Widget buildDescriptor(BuildContext context) {
    int missionCondType = kDetailCondMappingReverse[type] ?? -1;
    return MissionCondDetailDescriptor(
      targetNum: count,
      detail: EventMissionConditionDetail(
        id: 0,
        missionTargetId: 0,
        missionCondType: missionCondType,
        targetIds: ids,
        logicType: 0,
        conditionLinkType: DetailMissionCondLinkType.missionStart,
      ),
      textScaleFactor: 0.9,
      useAnd: useAnd,
    );
  }

  static const kDetailCondMapping = {
    DetailCondType.questClearNum1: CustomMissionType.quest,
    DetailCondType.questClearNum2: CustomMissionType.quest,
    DetailCondType.enemyKillNum: CustomMissionType.enemy,
    DetailCondType.defeatEnemyIndividuality: CustomMissionType.trait,
    DetailCondType.enemyIndividualityKillNum: CustomMissionType.trait,
    DetailCondType.defeatServantClass: CustomMissionType.servantClass,
    DetailCondType.defeatEnemyClass: CustomMissionType.enemyClass,
    DetailCondType.defeatEnemyNotServantClass:
        CustomMissionType.enemyNotServantClass,
  };

  static final kDetailCondMappingReverse = {
    CustomMissionType.quest: DetailCondType.questClearNum1,
    CustomMissionType.enemy: DetailCondType.enemyKillNum,
    CustomMissionType.trait: DetailCondType.defeatEnemyIndividuality,
    CustomMissionType.servantClass: DetailCondType.defeatServantClass,
    CustomMissionType.enemyClass: DetailCondType.defeatEnemyClass,
    CustomMissionType.enemyNotServantClass:
        DetailCondType.defeatEnemyNotServantClass,
    CustomMissionType.questTrait: DetailCondType.questClearIndividuality,
  };
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

enum CustomMissionType {
  trait,
  questTrait,
  quest,
  enemy,
  servantClass,
  enemyClass,
  enemyNotServantClass
}
