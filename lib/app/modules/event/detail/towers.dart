import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

class EventTowersPage extends StatefulWidget {
  final Event event;
  const EventTowersPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventTowersPage> createState() => _EventTowersPageState();
}

class _EventTowersPageState extends State<EventTowersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<EventTower> towers = [];
  @override
  void initState() {
    super.initState();
    towers = List.of(widget.event.towers);
    towers.sort2((e) => e.towerId);
    _tabController = TabController(length: towers.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tower Rewards'),
        bottom: towers.length > 1
            ? TabBar(
                controller: _tabController,
                tabs: towers.map((tower) {
                  return Tab(text: tower.name);
                }).toList(),
              )
            : null,
      ),
      body: towers.length > 1
          ? TabBarView(
              controller: _tabController,
              children: [
                for (final tower in towers) towerRewardsBuilder(context, tower)
              ],
            )
          : towers.isNotEmpty
              ? towerRewardsBuilder(context, towers.first)
              : const SizedBox(),
    );
  }

  Widget towerRewardsBuilder(BuildContext context, EventTower tower) {
    return ListView.separated(
      itemBuilder: (context, index) =>
          rewardBuilder(context, tower.rewards[index]),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: tower.rewards.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventTowerReward reward) {
    List<InlineSpan> titles = [];
    for (final gift in reward.gifts) {
      if (titles.isNotEmpty) titles.add(const TextSpan(text: '\n'));
      titles.add(WidgetSpan(
          child: gift.iconBuilder(context: context, width: 36, text: '')));
      titles.add(TextSpan(
          text: ' ×' + gift.num.format(compact: false, groupSeparator: ',')));
    }

    return ListTile(
      key: Key('event_tower_${reward.floor}'),
      leading: Text(reward.floor.toString()),
      title: Text.rich(
        TextSpan(children: titles),
      ),
    );
  }
}
