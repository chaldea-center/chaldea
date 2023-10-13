import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventLotteryTab extends StatefulWidget {
  final Event event;
  final EventLottery lottery;
  const EventLotteryTab({super.key, required this.event, required this.lottery});

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
            subtitle: Text.rich(TextSpan(
              children: [
                TextSpan(
                    text: lottery.limited
                        ? '${S.current.event_lottery_limited}: ${S.current.event_lottery_limit_hint(Maths.max(boxIndices, 0) + 1)}'
                        : S.current.event_lottery_unlimited),
                TextSpan(text: '\n${S.current.lottery_cost_per_roll}: '),
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
            items: [for (final index in boxIndices) DropdownMenuItem(value: index, child: Text('Box ${index + 1}'))],
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
    Widget? title;

    if (box.gifts.length == 1) {
      leading = box.gifts.first.iconBuilder(context: context, width: 36, text: '');
      String titleText = GameCardMixin.anyCardItemName(box.gifts.first.objectId).l;
      if (box.gifts.first.num != 1) {
        titleText += ' ×${box.gifts.first.num.format()}';
      }
      title = Text(titleText);
    } else {
      title = Text.rich(TextSpan(children: [
        for (final gift in box.gifts) ...[
          CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 28, text: '')),
          TextSpan(text: '×${gift.num.format()} ')
        ],
      ]));
    }

    return ListTile(
      dense: true,
      leading: leading,
      title: title,
      tileColor: box.isRare ? Colors.yellow.withAlpha(100) : null,
      trailing: Text('×${box.maxNum.format()}'),
      // horizontalTitleGap: 0,
    );
  }
}
