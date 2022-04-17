import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

class EventPointsPage extends StatefulWidget {
  final Event event;
  const EventPointsPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventPointsPage> createState() => _EventPointsPageState();
}

class _EventPointsPageState extends State<EventPointsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<int, List<EventReward>> groupRewords = {};
  Map<int, EventPointGroup> pointGroups = {};
  // <groupId, <point, buff>>
  Map<int, Map<int, EventPointBuff>> pointBuffs = {};
  @override
  void initState() {
    super.initState();
    pointGroups = {
      for (final group in widget.event.pointGroups) group.groupId: group
    };
    pointBuffs.clear();
    for (final buff in widget.event.pointBuffs) {
      pointBuffs
          .putIfAbsent(buff.groupId, () => {})
          .putIfAbsent(buff.eventPoint, () => buff);
    }
    for (final reward in widget.event.rewards) {
      groupRewords.putIfAbsent(reward.groupId, () => []).add(reward);
    }
    for (final rewards in groupRewords.values) {
      rewards.sort2((e) => e.point);
    }
    _tabController = TabController(length: groupRewords.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> groupIds = groupRewords.keys.toList();
    groupIds.sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point Rewards'),
        bottom: groupRewords.length > 1
            ? TabBar(
                controller: _tabController,
                tabs: groupIds.map((groupId) {
                  final group = pointGroups[groupId];
                  if (group == null) return Tab(text: groupId.toString());
                  return Tab(
                    child: Text.rich(TextSpan(children: [
                      WidgetSpan(child: db.getIconImage(group.icon, width: 24)),
                      TextSpan(text: group.name)
                    ])),
                  );
                }).toList(),
              )
            : null,
      ),
      body: groupRewords.length > 1
          ? TabBarView(
              controller: _tabController,
              children: [
                for (final slot in groupIds)
                  rewardListBuilder(context, groupRewords[slot]!)
              ],
            )
          : rewardListBuilder(
              context, groupRewords.isEmpty ? [] : groupRewords.values.first),
    );
  }

  Widget rewardListBuilder(BuildContext context, List<EventReward> rewards) {
    return ListView.separated(
      itemBuilder: (context, index) => rewardBuilder(context, rewards[index]),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: rewards.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventReward reward) {
    List<InlineSpan> titles = [];
    for (final gift in reward.gifts) {
      if (titles.isNotEmpty) titles.add(const TextSpan(text: '\n'));
      titles.add(WidgetSpan(
          child: gift.iconBuilder(context: context, width: 36, text: '')));
      titles.add(TextSpan(
          text: ' ×' + gift.num.format(compact: false, groupSeparator: ',')));

      final buff = pointBuffs[reward.groupId]?[reward.point];
      if (buff == null) continue;
      titles.add(const TextSpan(text: '\n'));
      titles.add(WidgetSpan(child: db.getIconImage(buff.icon, width: 36)));
      titles.add(TextSpan(text: buff.name + '\n'));
      titles.add(TextSpan(
          text: 'Value: ${buff.value.format(percent: true, base: 100)}'));
    }

    return ListTile(
      key: Key('event_point_${reward.groupId}_${reward.point}'),
      leading: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 72),
        child: Text(reward.point.format(compact: false, groupSeparator: ',')),
      ),
      title: Text.rich(
        TextSpan(children: titles),
      ),
    );
  }
}
