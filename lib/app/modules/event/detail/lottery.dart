import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventLotteryTab extends StatefulWidget {
  final Event event;
  final EventLottery lottery;
  const EventLotteryTab({Key? key, required this.event, required this.lottery})
      : super(key: key);

  @override
  State<EventLotteryTab> createState() => _EventLotteryTabState();
}

class _EventLotteryTabState extends State<EventLotteryTab> {
  int? selected;

  EventLottery get lottery => widget.lottery;

  @override
  Widget build(BuildContext context) {
    Map<int, List<EventLotteryBox>> groups = {};
    for (final box in lottery.boxes) {
      groups.putIfAbsent(box.boxIndex, () => []).add(box);
    }
    groups.values.forEach((group) {
      group.sort2((e) => e.no);
    });
    final boxIndices = groups.keys.toList()..sort();
    if (!boxIndices.contains(selected)) {
      selected = boxIndices.first;
    }
    final boxes = groups[selected]!;
    final listView = ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Text.rich(TextSpan(
              text: S.current.lottery_cost_per_roll + ': ',
              children: [
                CenterWidgetSpan(
                  child: Item.iconBuilder(
                    context: context,
                    item: lottery.cost.item,
                    width: 24,
                    showName: true,
                  ),
                ),
                TextSpan(text: ' ×${lottery.cost.amount}')
              ],
            )),
          );
        }
        return boxItemBuilder(context, boxes[index - 1]);
      },
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: boxes.length + 1,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<int>(
            value: selected,
            isExpanded: true,
            items: [
              for (final index in boxIndices)
                DropdownMenuItem(value: index, child: Text('Box ${index + 1}'))
            ],
            onChanged: (v) {
              setState(() {
                selected = v;
              });
            },
          ),
        ),
        Expanded(child: listView)
      ],
    );
  }

  Widget boxItemBuilder(BuildContext context, EventLotteryBox box) {
    Widget? leading;
    String? title;
    Widget? subtitle;
    leading =
        box.gifts.first.iconBuilder(context: context, width: 42, text: '');
    title = GameCardMixin.anyCardItemName(box.gifts.first.objectId).l;
    if (box.gifts.length > 1) {
      subtitle = Text.rich(TextSpan(children: [
        for (final gift in box.gifts.skip(1))
          CenterWidgetSpan(
            child: gift.iconBuilder(context: context, showName: true),
          )
      ]));
    }

    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle,
      tileColor: box.isRare ? Colors.yellow.withAlpha(100) : null,
      trailing: Text('×' + box.gifts.first.num.format()),
      // horizontalTitleGap: 0,
    );
  }
}
