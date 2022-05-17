import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'cond_target_num.dart';

class MissionCondsDescriptor extends StatelessWidget {
  final EventMission mission;
  final List<EventMission> missions;
  final bool onlyShowClear;
  const MissionCondsDescriptor({
    Key? key,
    required this.mission,
    this.missions = const [],
    this.onlyShowClear = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (final cond in mission.conds) {
      if (onlyShowClear &&
          cond.missionProgressType != MissionProgressType.clear) {
        continue;
      }
      if (!onlyShowClear) {
        children.add(Text(
          '~~~ ${Transl.enums(cond.missionProgressType, (enums) => enums.missionProgressType).l} ~~~',
          textAlign: TextAlign.center,
        ));
      }
      if (![mission.name, "???", "？？？"].contains(cond.conditionMessage)) {
        children.add(Text(
          cond.conditionMessage,
          style: Theme.of(context).textTheme.caption,
        ));
      }
      children.add(CondTargetNumDescriptor(
        condType: cond.condType,
        targetNum: cond.targetNum,
        targetIds: cond.targetIds,
        detail: cond.detail,
        missions: missions,
      ));
    }
    if (!onlyShowClear) {
      children.add(const SizedBox(height: 10));
    }
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaleFactor: mq.textScaleFactor * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
