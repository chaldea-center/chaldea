import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventPointsPage extends HookWidget {
  final Event event;
  final int groupId;
  const EventPointsPage(
      {super.key, required this.event, required this.groupId});

  @override
  Widget build(BuildContext context) {
    List<EventReward> rewards =
        event.rewards.where((e) => e.groupId == groupId).toList();
    rewards.sort2((e) => e.point);

    // <groupId, <point, buff>>
    Map<int, EventPointBuff> pointBuffs = {
      for (final buff in event.pointBuffs)
        if (buff.groupId == groupId) buff.eventPoint: buff
    };

    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) =>
          rewardBuilder(context, rewards[index], pointBuffs),
      separatorBuilder: (_, __) => const Divider(indent: 72, height: 1),
      itemCount: rewards.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventReward reward,
      Map<int, EventPointBuff> pointBuffs) {
    List<InlineSpan> titles = [];
    for (final gift in reward.gifts) {
      if (titles.isNotEmpty) titles.add(const TextSpan(text: '\n'));
      titles.add(CenterWidgetSpan(
          child: gift.iconBuilder(
              context: context, width: 36, text: '', showName: true)));
      titles.add(TextSpan(
          text: ' ×${gift.num.format(compact: false, groupSeparator: ',')}'));

      final buff = pointBuffs[reward.point];
      if (buff == null) continue;
      titles.add(const TextSpan(text: '\n'));
      titles
          .add(CenterWidgetSpan(child: db.getIconImage(buff.icon, width: 36)));
      titles.add(TextSpan(text: '${buff.name}\n'));
      titles.add(TextSpan(
          text: 'Value: ${buff.value.format(percent: true, base: 100)}'));
    }

    return ListTile(
      key: Key('event_point_${reward.groupId}_${reward.point}'),
      minLeadingWidth: 72,
      leading: Text(reward.point.format(compact: false, groupSeparator: ',')),
      title: Text.rich(TextSpan(children: titles)),
    );
  }
}
