import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventPointsPage extends StatelessWidget {
  final Event event;
  const EventPointsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    List<Tab> tabs = [];
    List<Widget> views = [];

    final pointGroups = {for (final group in event.pointGroups) group.groupId: group};

    Map<int, List<EventPointReward>> pointRewards = {};
    for (final reward in event.pointRewards) {
      pointRewards.putIfAbsent(reward.groupId, () => []).add(reward);
    }

    Map<int, Map<int, EventPointBuff>> pointBuffs = {};
    for (final buff in event.pointBuffs) {
      pointBuffs.putIfAbsent(buff.groupId, () => {})[buff.eventPoint] = buff;
    }

    List<int> groupIds = pointRewards.keys.toList()..sort();
    for (final groupId in groupIds) {
      String? pointName;
      final group = pointGroups[groupId];
      if (group != null) {
        pointName = Transl.itemNames(group.name).l;
      }
      pointName ??= S.current.event_point_reward + (groupIds.length > 1 ? ' $groupId' : '');
      final icon = group?.icon ?? pointBuffs[groupId]?.values.firstOrNull?.icon;

      final rewards = pointRewards[groupId]!;
      rewards.sort2((e) => e.point);
      tabs.add(
        Tab(
          child: Text.rich(
            TextSpan(
              children: [
                if (icon != null) CenterWidgetSpan(child: db.getIconImage(icon, width: 24)),
                TextSpan(text: pointName),
              ],
            ),
          ),
        ),
      );
      views.add(EventPointTab(rewards: rewards, pointBuffs: pointBuffs[groupId] ?? {}));
    }
    if (views.isEmpty) return const SizedBox.shrink();
    if (views.length == 1) return views.single;
    return DefaultTabController(
      length: views.length,
      child: Column(
        children: [
          FixedHeight.tabBar(
            TabBar(isScrollable: tabs.length > 2, tabs: tabs, labelStyle: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(child: TabBarView(children: views)),
        ],
      ),
    );
  }
}

class EventPointTab extends HookWidget {
  final List<EventPointReward> rewards;
  final Map<int, EventPointBuff> pointBuffs;

  const EventPointTab({super.key, required this.rewards, required this.pointBuffs});

  @override
  Widget build(BuildContext context) {
    rewards.sort2((e) => e.point);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => rewardBuilder(context, rewards[index], pointBuffs),
      separatorBuilder: (_, __) => const Divider(indent: 72, height: 1),
      itemCount: rewards.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventPointReward reward, Map<int, EventPointBuff> pointBuffs) {
    List<InlineSpan> titles = [];
    final groups = Gift.group(reward.gifts);
    for (final gifts in groups.values) {
      if (titles.isNotEmpty) titles.add(const TextSpan(text: '\n'));
      for (final gift in gifts) {
        titles.add(CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 28, text: '', showName: true)));
        titles.add(TextSpan(text: ' ×${gift.num.format(compact: false, groupSeparator: ',')}'));
        final buff = pointBuffs[reward.point];
        if (buff == null) continue;
        titles.add(const TextSpan(text: '\n'));
        titles.add(TextSpan(text: '${buff.name}\n'));
        titles.add(TextSpan(text: 'Value: ${buff.value.format(percent: true, base: 10)}'));
      }
      final giftAdds = gifts.first.giftAdds;
      if (giftAdds.isNotEmpty) {
        titles.addAll([
          const TextSpan(text: '\n→'),
          CenterWidgetSpan(child: db.getIconImage(giftAdds.first.replacementGiftIcon, width: 28)),
          for (final gift in giftAdds.first.replacementGifts)
            CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 28, text: '', showName: true)),
        ]);
      }
    }

    return ListTile(
      key: Key('event_point_${reward.groupId}_${reward.point}'),
      minLeadingWidth: 72,
      dense: true,
      leading: Text(reward.point.format(compact: false, groupSeparator: ',')),
      title: Text.rich(TextSpan(children: titles)),
    );
  }
}
