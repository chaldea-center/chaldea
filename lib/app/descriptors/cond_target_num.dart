import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'descriptor_base.dart';
import 'mission_cond_detail.dart';
import 'multi_entry.dart';

class CondTargetNumDescriptor extends StatelessWidget with DescriptorBase {
  final CondType condType;
  final int targetNum;
  @override
  final List<int> targetIds;
  final EventMissionConditionDetail? detail;
  final List<EventMission> missions;

  const CondTargetNumDescriptor({
    Key? key,
    required this.condType,
    required this.targetNum,
    required this.targetIds,
    this.detail,
    this.missions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => const Text('NONE'),
          kr: null,
        );
      case CondType.questClear:
        bool all = targetNum == targetIds.length && targetNum != 1;
        return localized(
          jp: null,
          cn: () => combineToRich(
            context,
            '通关${all ? "所有" : ""}$targetNum个关卡',
            quests(context),
          ),
          tw: null,
          na: () => combineToRich(
            context,
            'Clear ${all ? "all" : ""} $targetNum quests of ',
            quests(context),
          ),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: null,
          cn: () =>
              combineToRich(context, '通关', quests(context), '进度$targetNum'),
          tw: null,
          na: () => combineToRich(
              context, 'Cleared arrow $targetNum of quest', quests(context)),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: null,
          cn: () =>
              combineToRich(context, '通关$targetNum次以下关卡', quests(context)),
          tw: null,
          na: () => combineToRich(
            context,
            '$targetNum runs of quests ',
            quests(context),
          ),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, servants(context), '达到灵基再临第$targetNum阶段'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at ascension $targetNum',
          ),
          kr: null,
        );
      case CondType.svtFriendship:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, null, servants(context), '的羁绊等级达到$targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' at bond level $targetNum',
          ),
          kr: null,
        );
      case CondType.svtGet:
        return localized(
          jp: null,
          cn: () => combineToRich(context, null, servants(context), '正式加入'),
          tw: null,
          na: () => combineToRich(
            context,
            null,
            servants(context),
            ' in Spirit Origin Collection',
          ),
          kr: null,
        );
      case CondType.eventEnd:
        final event = db.gameData.events[targetIds.first];
        final targets = [
          MultiDescriptor.inkWell(
            context: context,
            text: event?.shownName ?? targetIds.toString(),
            onTap: () => event?.routeTo(),
          )
        ];
        return localized(
          jp: null,
          cn: () => combineToRich(context, '活动', targets, '结束'),
          tw: null,
          na: () => combineToRich(context, 'Event ', targets, ' has ended'),
          kr: null,
        );
      case CondType.svtHaving:
        return localized(
          jp: null,
          cn: () => combineToRich(context, '持有从者', servants(context)),
          tw: null,
          na: () =>
              combineToRich(context, 'Presense of Servant ', servants(context)),
          kr: null,
        );
      case CondType.svtRecoverd:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => const Text('Servant Recovered'),
          kr: null,
        );
      case CondType.limitCountAbove:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, '从者', servants(context), '的灵基再临 ≥ $targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≥ $targetNum',
          ),
          kr: null,
        );
      case CondType.limitCountBelow:
        return localized(
          jp: null,
          cn: () => combineToRich(
              context, '从者', servants(context), '的灵基再临 ≤ $targetNum'),
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            servants(context),
            ' at ascension ≤ $targetNum',
          ),
          kr: null,
        );
      case CondType.svtLevelClassNum:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text('Raise $targetNum servants of class_level $targetIds'),
          kr: null,
        );
      case CondType.svtLimitClassNum:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text(
              'Raise $targetNum ${MultiDescriptor.classLimits(targetIds)}'),
          kr: null,
        );
      case CondType.svtEquipRarityLevelNum:
        break;
      case CondType.eventMissionAchieve:
        final mission = missions
            .firstWhereOrNull((mission) => mission.id == targetIds.first);
        final targets =
            '${mission?.dispNo}-${mission?.name ?? targetIds.first}';
        return localized(
          jp: null,
          cn: () => Text('完成任务 $targets'),
          tw: null,
          na: () => Text('Archive mission $targets'),
          kr: null,
        );
      case CondType.eventTotalPoint:
        return localized(
          jp: null,
          cn: () => Text('获得活动点数$targetNum点'),
          tw: null,
          na: () => Text('Reach $targetNum event points'),
          kr: null,
        );
      case CondType.eventMissionClear:
        final missionMap = {for (final m in missions) m.id: m};
        final dispNos =
            targetIds.map((e) => missionMap[e]?.dispNo ?? e).toList();

        if (dispNos.length == targetNum) {
          return localized(
            jp: null,
            cn: () => combineToRich(
                context, '完成以下全部任务:', missionList(context, missionMap)),
            tw: null,
            na: () => combineToRich(context, 'Clear all missions of',
                missionList(context, missionMap)),
            kr: null,
          );
        } else {
          return localized(
            jp: null,
            cn: () => combineToRich(context, '完成$targetNum个不同的任务',
                missionList(context, missionMap)),
            tw: null,
            na: () => combineToRich(
              context,
              'Clear $targetNum different missions from ',
              missionList(context, missionMap),
            ),
            kr: null,
          );
        }
      case CondType.missionConditionDetail:
        if (detail == null) break;
        return MissionCondDetailDescriptor(
            targetNum: targetNum, detail: detail!);
      case CondType.date:
        final time = DateTime.fromMillisecondsSinceEpoch(targetNum * 1000)
            .toStringShort(omitSec: true);
        return localized(
          jp: null,
          cn: () => Text('$time后开放'),
          tw: null,
          na: () => Text('After $time'),
          kr: null,
        );
      default:
        break;
    }
    return localized(
      jp: null,
      cn: () => Text('未知条件(${condType.name}): $targetNum, $targetIds'),
      tw: null,
      na: () => Text('Unknown Cond(${condType.name}): $targetNum, $targetIds'),
      kr: null,
    );
  }
}
