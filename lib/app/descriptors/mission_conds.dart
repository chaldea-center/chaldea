import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import '../../generated/l10n.dart';
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
          textScaleFactor: 0.9,
          style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
        ));
      }
      if (![mission.name, "???", "？？？"].contains(cond.conditionMessage)) {
        children.add(Text(
          cond.conditionMessage,
          style: Theme.of(context).textTheme.caption,
          textScaleFactor: 0.9,
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
    if (!onlyShowClear && mission.gifts.isNotEmpty) {
      children.add(Text(
        '~~~ ${S.current.game_rewards} ~~~',
        textAlign: TextAlign.center,
        textScaleFactor: 0.9,
        style: TextStyle(color: Theme.of(context).textTheme.caption?.color),
      ));
      children
          .add(SharedBuilder.giftGrid(context: context, gifts: mission.gifts));
    }
    if (!onlyShowClear) {
      children.add(const SizedBox(height: 10));
    }
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaleFactor: mq.textScaleFactor * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
