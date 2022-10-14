import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventTowersPage extends HookWidget {
  final Event event;
  final EventTower tower;
  const EventTowersPage({super.key, required this.event, required this.tower});

  @override
  Widget build(BuildContext context) {
    final rewards = List.of(tower.rewards)..sort2((e) => e.floor);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => rewardBuilder(context, rewards[index]),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: rewards.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventTowerReward reward) {
    List<InlineSpan> titles = [];
    for (final gift in reward.gifts) {
      if (titles.isNotEmpty) titles.add(const TextSpan(text: '\n'));
      titles.add(CenterWidgetSpan(
        child: gift.iconBuilder(
          context: context,
          width: 36,
          text: '',
          showName: true,
        ),
      ));
      titles.add(TextSpan(
          text: ' ×${gift.num.format(compact: false, groupSeparator: ',')}'));
    }

    return ListTile(
      key: Key('event_tower_${reward.floor}'),
      leading: Text(reward.floor.toString()),
      horizontalTitleGap: 0,
      title: Text.rich(
        TextSpan(children: titles),
      ),
    );
  }
}
