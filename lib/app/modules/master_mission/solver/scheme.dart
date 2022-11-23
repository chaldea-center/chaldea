import 'package:flutter/material.dart';

import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/models/models.dart';

class CustomMissionCond {
  CustomMissionType type;
  List<int> taregtIds;
  bool _useAnd;
  set useAnd(bool v) => _useAnd = v;
  bool get useAnd => fixedLogicType ?? _useAnd;

  CustomMissionCond({
    required this.type,
    required this.taregtIds,
    required bool useAnd,
  }) : _useAnd = useAnd;

  bool? get fixedLogicType {
    switch (type) {
      case CustomMissionType.trait:
      case CustomMissionType.questTrait:
        return null;
      case CustomMissionType.quest:
      case CustomMissionType.enemy:
      case CustomMissionType.enemyClass:
      case CustomMissionType.servantClass:
      case CustomMissionType.enemyNotServantClass:
        return false;
    }
  }

  CustomMissionCond copy() {
    return CustomMissionCond(
      type: type,
      taregtIds: taregtIds.toList(),
      useAnd: useAnd,
    );
  }
}

class CustomMission {
  int count;

  /// only if [CustomMissionType.trait], can have multi conds and [condAnd]
  List<CustomMissionCond> conds;
  bool condAnd;
  bool enemyDeckOnly;

  final String? originDetail;

  CustomMission({
    required this.count,
    required this.conds,
    this.condAnd = false,
    this.enemyDeckOnly = true,
    this.originDetail,
  });

  static CustomMission? fromEventMission(EventMission? eventMission) {
    if (eventMission == null) return null;
    for (final cond in eventMission.conds) {
      if (cond.missionProgressType != MissionProgressType.clear ||
          cond.condType != CondType.missionConditionDetail ||
          cond.details?.isNotEmpty != true) {
        continue;
      }
      List<CustomMissionCond> conds = [];
      for (final detail in cond.details!) {
        final type = kDetailCondMapping[detail.missionCondType];
        if (type == null) continue;
        if (type == CustomMissionType.quest &&
            detail.targetIds.length == 1 &&
            detail.targetIds.first == 0) {
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
          case CustomMissionType.enemyClass:
          case CustomMissionType.servantClass:
          case CustomMissionType.enemyNotServantClass:
            useAnd = false;
            break;
        }
        conds.add(CustomMissionCond(
            type: type, taregtIds: detail.targetIds, useAnd: useAnd));
      }
      if (conds.isEmpty) continue;

      return CustomMission(
        count: cond.targetNum,
        conds: conds,
        condAnd: false,
        originDetail: cond.conditionMessage,
      );
    }
    return null;
  }

  CustomMission copy() {
    return CustomMission(
      count: count,
      conds: conds.map((e) => e.copy()).toList(),
      condAnd: condAnd,
      enemyDeckOnly: enemyDeckOnly,
      originDetail: originDetail,
    );
  }

  Widget buildDescriptor(BuildContext context, {double? textScaleFactor}) {
    return CondTargetNumDescriptor(
      condType: CondType.missionConditionDetail,
      targetNum: count,
      targetIds: List.generate(conds.length, (index) => index),
      details: List.generate(conds.length, (index) {
        final cond = conds[index];
        return EventMissionConditionDetail(
          id: index,
          missionTargetId: 0,
          missionCondType: kDetailCondMappingReverse[cond.type] ?? -1,
          targetIds: cond.taregtIds,
          logicType: 1,
          conditionLinkType: DetailMissionCondLinkType.missionStart,
          useAnd: cond.useAnd,
        );
      }),
      textScaleFactor: textScaleFactor ?? 0.9,
      useAnd: condAnd,
    );
  }

  static const kDetailCondMapping = {
    DetailCondType.questClearNum1: CustomMissionType.quest,
    DetailCondType.questClearNum2: CustomMissionType.quest,
    DetailCondType.enemyKillNum: CustomMissionType.enemy,
    DetailCondType.targetQuestEnemyKillNum: CustomMissionType.enemy,
    DetailCondType.defeatEnemyIndividuality: CustomMissionType.trait,
    DetailCondType.enemyIndividualityKillNum: CustomMissionType.trait,
    DetailCondType.targetQuestEnemyIndividualityKillNum:
        CustomMissionType.enemy,
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
  enemy,
  enemyClass,
  servantClass,
  enemyNotServantClass,
  quest,
  questTrait,
}

extension CustomMissionTypeX on CustomMissionType {
  bool get isQuestType =>
      this == CustomMissionType.questTrait || this == CustomMissionType.quest;
  bool get isEnemyType => !isQuestType;
}
