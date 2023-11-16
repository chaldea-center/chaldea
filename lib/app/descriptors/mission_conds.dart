import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import '../../generated/l10n.dart';
import '../../models/models.dart';
import 'cond_target_num.dart';

class MissionCondsDescriptor extends StatelessWidget {
  final EventMission mission;
  final List<EventMission> missions;
  final bool onlyShowClear;
  final int? eventId;

  const MissionCondsDescriptor({
    super.key,
    required this.mission,
    this.missions = const [],
    this.onlyShowClear = false,
    this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final cond in mission.conds) {
      final isClearCond = cond.missionProgressType == MissionProgressType.clear;
      if (onlyShowClear && !isClearCond) {
        continue;
      }
      if (!onlyShowClear) {
        children.add(Text(
          '~~~ ${Transl.enums(cond.missionProgressType, (enums) => enums.missionProgressType).l} ~~~',
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(0.9),
          style: TextStyle(
            color: isClearCond
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: isClearCond ? FontWeight.bold : null,
          ),
        ));
      }
      if (![mission.name, "???", "？？？"].contains(cond.conditionMessage)) {
        children.add(Text(
          cond.conditionMessage,
          style: Theme.of(context).textTheme.bodySmall,
          textScaler: const TextScaler.linear(0.9),
        ));
      }
      children.add(CondTargetNumDescriptor(
        condType: cond.condType,
        targetNum: cond.targetNum,
        targetIds: cond.targetIds,
        details: cond.details,
        missions: missions,
        eventId: eventId,
      ));
    }
    if (!onlyShowClear && mission.gifts.isNotEmpty) {
      children.add(Text(
        '~~~ ${S.current.game_rewards} ~~~',
        textAlign: TextAlign.center,
        textScaler: const TextScaler.linear(0.9),
        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
      ));
      children.add(SharedBuilder.giftGrid(context: context, gifts: mission.gifts));
    }
    if (!onlyShowClear) {
      children.add(const SizedBox(height: 10));
    }
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(0.9))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
