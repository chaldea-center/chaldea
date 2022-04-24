import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventTreasureBoxTab extends StatelessWidget {
  final Event event;
  const EventTreasureBoxTab({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxes = List.of(event.treasureBoxes);
    return ListView.separated(
      itemBuilder: (context, index) =>
          rewardBuilder(context, boxes[index], index),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: boxes.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventTreasureBox box, int index) {
    List<Widget> children = [];
    children.add(
        ListTile(title: Text(S.current.event_treasure_box + ' ${index + 1}')));
    final itemId = box.commonConsume.objectId;
    children.add(ListTile(
        subtitle: Text.rich(TextSpan(
            text:
                '${S.current.treasure_box_max_draw_once}: ${box.maxDrawNumOnce}\n',
            children: [
          TextSpan(text: S.current.treasure_box_draw_cost + ': '),
          CenterWidgetSpan(
            child: Item.iconBuilder(
              context: context,
              item: null,
              itemId: itemId,
              width: 32,
              showName: true,
            ),
          ),
          TextSpan(text: ' ×${box.commonConsume.num}\n'),
          TextSpan(text: '${S.current.treasure_box_extra_gift}: '),
          for (final gift in box.extraGifts) ...[
            CenterWidgetSpan(
              child: gift.iconBuilder(
                context: context,
                showName: true,
                width: 32,
                text: '',
              ),
            ),
            TextSpan(text: ' ×${gift.num * box.commonConsume.num}')
          ]
        ]))));
    children.add(TileGroup(
      children: [
        for (final gifts in box.treasureBoxGifts)
          for (final gift in gifts.gifts)
            ListTile(
              leading: gift.iconBuilder(context: context, width: 42),
              title: Text(Item.getName(gift.objectId) + ' ×${gift.num}'),
              onTap: () {
                gift.routeTo();
              },
            ),
      ],
    ));

    children.add(const SizedBox(height: 8));

    return Column(children: children);
  }
}
