import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import 'descriptor_base.dart';
import 'mission_cond_detail.dart';
import 'multi_entry.dart';

class CondTargetNumDescriptor extends StatelessWidget with DescriptorBase {
  final CondType condType;
  final int targetNum;
  final List<int> targetIds;
  final EventMissionConditionDetail? detail;
  final Map<int, EventMission> missions;

  const CondTargetNumDescriptor({
    Key? key,
    required this.condType,
    required this.targetNum,
    required this.targetIds,
    this.detail,
    this.missions = const {},
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
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Clear ${targetNum == targetIds.length ? "all" : ""} $targetNum quests of ',
            MultiDescriptor.quests(context, targetIds),
          ),
          kr: null,
        );
      case CondType.questClearPhase:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Cleared arrow $targetNum of quest',
            MultiDescriptor.quests(context, targetIds),
          ),
          kr: null,
        );
      case CondType.questClearNum:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            '$targetNum runs of quests ',
            MultiDescriptor.quests(context, targetIds),
          ),
          kr: null,
        );
      case CondType.svtLimit:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            null,
            MultiDescriptor.servants(context, targetIds),
            ' at ascension $targetNum',
          ),
          kr: null,
        );
      case CondType.svtFriendship:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            null,
            MultiDescriptor.servants(context, targetIds),
            ' at bond level $targetNum',
          ),
          kr: null,
        );
      case CondType.svtGet:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            null,
            MultiDescriptor.servants(context, targetIds),
            ' in Spirit Origin Collection',
          ),
          kr: null,
        );
      case CondType.eventEnd:
        final event = db2.gameData.events[targetIds.first];
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Event ',
            [
              MultiDescriptor.inkWell(
                context: context,
                text: event?.lName.l ?? targetIds.first.toString(),
                onTap: () => event?.routeTo(),
              )
            ],
            ' has ended',
          ),
          kr: null,
        );
      case CondType.svtHaving:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Presense of Servant ',
            MultiDescriptor.servants(context, targetIds),
          ),
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
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            MultiDescriptor.servants(context, targetIds),
            ' at ascension ≥ $targetNum',
          ),
          kr: null,
        );
      case CondType.limitCountBelow:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => combineToRich(
            context,
            'Servant',
            MultiDescriptor.servants(context, targetIds),
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
              'Raise $targetNum ' + MultiDescriptor.classLimits(targetIds)),
          kr: null,
        );
      case CondType.svtEquipRarityLevelNum:
        break;
      case CondType.eventMissionAchieve:
        final mission = missions[targetIds.first];
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text('Archive mission ${mission?.dispNo}-${mission?.name}'),
          kr: null,
        );
      case CondType.eventTotalPoint:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text('Reach $targetNum event points'),
          kr: null,
        );
      case CondType.eventMissionClear:
        final dispNos = targetIds.map((e) => missions[e]?.dispNo ?? e).toList();
        if (dispNos.length == targetNum) {
          return localized(
            jp: null,
            cn: null,
            tw: null,
            na: () => Text('Clear all missions of $dispNos'),
            kr: null,
          );
        } else {
          return localized(
            jp: null,
            cn: null,
            tw: null,
            na: () => combineToRich(
              context,
              'Clear $targetNum different missions from ',
              [
                MultiDescriptor.collapsed(
                    context, targetIds, 'All ${targetIds.length} missions',
                    (context, id) {
                  final mission = missions[id];
                  return ListTile(
                      title: Text('${mission?.dispNo} - ${mission?.name}'));
                }),
              ],
            ),
            kr: null,
          );
        }
      case CondType.missionConditionDetail:
        if (detail == null) break;
        return MissionCondDetailDescriptor(
            targetNum: targetNum, detail: detail!);
      case CondType.date:
        return localized(
          jp: null,
          cn: null,
          tw: null,
          na: () => Text(
              'After ${DateTime.fromMillisecondsSinceEpoch(targetNum * 1000).toStringShort()}'),
          kr: null,
        );
      default:
        break;
    }
    return localized(
      jp: null,
      cn: null,
      tw: null,
      na: () => Text('Unknown: $condType, $targetNum, $targetIds'),
      kr: null,
    );
  }
}
