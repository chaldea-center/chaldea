import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventCooltimePage extends HookWidget {
  final Event event;
  const EventCooltimePage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final allRewards = event.cooltime?.rewards ?? [];
    if (allRewards.isEmpty) return const SizedBox();
    final grouped = <int, List<EventCooltimeReward>>{};
    for (final reward in allRewards) {
      grouped.putIfAbsent(reward.spotId, () => []).add(reward);
    }
    for (final rewards in grouped.values) {
      rewards.sort2((e) => e.lv);
    }
    final keys = grouped.keys.toList();
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, grouped[keys[index]]!),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: keys.length,
    );
  }

  Widget itemBuilder(BuildContext context, List<EventCooltimeReward> rewards) {
    final first = rewards.first;
    assert(rewards.every((e) =>
        e.name == first.name &&
        e.upperLimitGiftNum == first.upperLimitGiftNum &&
        e.gifts.length == 1 &&
        e.gifts.first.objectId == first.gifts.first.objectId &&
        e.gifts.first.num == first.gifts.first.num));
    final spot = db.gameData.spots[rewards.first.spotId];
    final maxPointRate = Maths.max(rewards.map((e) => e.addEventPointRate), 0);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 8),
          horizontalTitleGap: 8,
          dense: true,
          leading: spot?.shownImage == null ? null : db.getIconImage(spot?.shownImage),
          title: Text(Transl.spotNames(first.name).l),
          subtitle: Text('${_fmtCooltime(rewards.first.cooltime)}→${_fmtCooltime(rewards.last.cooltime)},'
              ' +${(maxPointRate / 1000).toStringAsFixed(1)}'),
          trailing: Text.rich(
            TextSpan(children: [
              for (final gift in first.gifts) CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 28)),
              TextSpan(text: '×${first.upperLimitGiftNum.format()}')
            ]),
            textScaleFactor: 0.9,
          ),
        );
      },
      contentBuilder: (context) {
        return CustomTable(children: [
          CustomTableRow.fromTexts(texts: const ['Lv.', 'Cooltime', 'Point Rate'], isHeader: true),
          for (final reward in rewards)
            CustomTableRow.fromTexts(texts: [
              reward.lv.toString(),
              _fmtCooltime(reward.cooltime),
              '+${(reward.addEventPointRate / 1000).toStringAsFixed(1)}'
            ])
        ]);
      },
    );
  }

  String _fmtCooltime(int sec) {
    return '${(sec / 3600).format()}h';
  }
}
