import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventTreasureBoxTab extends HookWidget {
  final Event event;
  const EventTreasureBoxTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final boxes = List.of(event.treasureBoxes);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => rewardBuilder(context, boxes[index], index),
      separatorBuilder: (_, _) => const Divider(height: 16),
      itemCount: boxes.length,
    );
  }

  Widget rewardBuilder(BuildContext context, EventTreasureBox box, int index) {
    List<Widget> children = [];
    // children.add(
    //     ListTile(title: Text('${S.current.event_treasure_box} ${index + 1}')));
    children.add(
      ListTile(
        title: Text('${S.current.event_treasure_box} ${index + 1}'),
        subtitle: Text.rich(
          TextSpan(
            children: [
              for (final gifts in box.treasureBoxGifts)
                for (final gift in gifts.gifts)
                  CenterWidgetSpan(
                    child: gift.iconBuilder(context: context, width: 42, text: gift.num > 1 ? gift.num.format() : ''),
                  ),
              const TextSpan(text: '\n'),
              TextSpan(text: '${S.current.treasure_box_draw_cost}: '),
              for (final consume in box.consumes) ...[
                CenterWidgetSpan(
                  child: Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: consume.objectId,
                    width: 28,
                    showName: true,
                  ),
                ),
                TextSpan(text: ' ×${consume.num} '),
              ],
              const TextSpan(text: '\n'),
              TextSpan(text: '${S.current.treasure_box_extra_gift}: '),
              for (final gift in box.extraGifts) ...[
                CenterWidgetSpan(
                  child: gift.iconBuilder(context: context, showName: true, width: 28, text: ''),
                ),
                TextSpan(text: ' ×${gift.num}'),
              ],
              TextSpan(text: '\n${S.current.treasure_box_max_draw_once}: ${box.maxDrawNumOnce}'),
            ],
          ),
        ),
      ),
    );
    return Column(children: children);
  }
}
