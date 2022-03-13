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
    return MappingBase<WidgetBuilder>(
      // jp: buildJP,
      // cn: buildCN,
      // tw: buildTW,
      na: buildNA,
      // kr: buildKR,
    ).l!(context);
  }

  @override
  Widget buildCN(BuildContext context) {
    // TODO: implement buildCN
    throw UnimplementedError();
  }

  @override
  Widget buildJP(BuildContext context) {
    // TODO: implement buildJP
    throw UnimplementedError();
  }

  @override
  Widget buildKR(BuildContext context) {
    // TODO: implement buildKR
    throw UnimplementedError();
  }

  @override
  Widget buildNA(BuildContext context) {
    switch (condType) {
      case CondType.none:
        return const Text('NONE');
      case CondType.questClear:
        return combineToRich(
          context,
          'Clear ${targetNum == targetIds.length ? "all" : ""} $targetNum quests of ',
          MultiDescriptor.quests(context, targetIds),
        );
      case CondType.questClearPhase:
        return combineToRich(
          context,
          'Cleared arrow $targetNum of quest',
          MultiDescriptor.quests(context, targetIds),
        );
      case CondType.questClearNum:
        return combineToRich(
          context,
          '$targetNum runs of quests ',
          MultiDescriptor.quests(context, targetIds),
        );
      case CondType.svtLimit:
        return combineToRich(
          context,
          null,
          MultiDescriptor.servants(context, targetIds),
          ' at ascension $targetNum',
        );
      case CondType.svtFriendship:
        return combineToRich(
          context,
          null,
          MultiDescriptor.servants(context, targetIds),
          ' at bond level $targetNum',
        );
      case CondType.svtGet:
        return combineToRich(
          context,
          null,
          MultiDescriptor.servants(context, targetIds),
          ' in Spirit Origin Collection',
        );
      case CondType.eventEnd:
        final event = db2.gameData.events[targetIds.first];
        return combineToRich(
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
        );
      case CondType.svtHaving:
        return combineToRich(
          context,
          'Presense of Servant ',
          MultiDescriptor.servants(context, targetIds),
        );
      case CondType.svtRecoverd:
        return const Text('Servant Recovered');
      case CondType.limitCountAbove:
        return combineToRich(
          context,
          'Servant',
          MultiDescriptor.servants(context, targetIds),
          ' at ascension ≥ $targetNum',
        );
      case CondType.limitCountBelow:
        return combineToRich(
          context,
          'Servant',
          MultiDescriptor.servants(context, targetIds),
          ' at ascension ≤ $targetNum',
        );
      case CondType.svtLevelClassNum:
        return Text('Raise $targetNum servants of class_level $targetIds');
      case CondType.svtLimitClassNum:
        return Text(
            'Raise $targetNum ' + MultiDescriptor.classLimits(targetIds));
      case CondType.svtEquipRarityLevelNum:
        break;
      case CondType.eventMissionAchieve:
        final mission = missions[targetIds.first];
        return Text('Archive mission ${mission?.dispNo}-${mission?.name}');
      case CondType.eventTotalPoint:
        return Text('Reach $targetNum event points');
      case CondType.eventMissionClear:
        final dispNos = targetIds.map((e) => missions[e]?.dispNo ?? e).toList();
        if (dispNos.length == targetNum) {
          return Text('Clear all missions of $dispNos');
        } else {
          return combineToRich(
              context, 'Clear $targetNum different missions from ', [
            MultiDescriptor.collapsed(
                context, targetIds, 'All ${targetIds.length} missions',
                (context, id) {
              final mission = missions[id];
              return ListTile(
                  title: Text('${mission?.dispNo} - ${mission?.name}'));
            }),
          ]);
        }
      case CondType.missionConditionDetail:
        if (detail == null) break;
        return MissionCondDetailDescriptor(
            targetNum: targetNum, detail: detail!);
      case CondType.date:
        return Text(
            'After ${DateTime.fromMillisecondsSinceEpoch(targetNum).toStringShort()}');
      default:
        break;
    }
    return Text('Unknown: $condType, $targetNum, $targetIds');
  }

  @override
  Widget buildTW(BuildContext context) {
    // TODO: implement buildTW
    throw UnimplementedError();
  }
}
