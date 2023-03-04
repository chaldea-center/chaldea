import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventDiggingTab extends StatelessWidget {
  final Event event;
  final EventDigging digging;

  const EventDiggingTab({super.key, required this.event, required this.digging});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.addAll([
      ListTile(
        dense: true,
        title: const Text('Map'),
        subtitle: Text('Size ${digging.sizeX}x${digging.sizeY}'),
        trailing: db.getIconImage(digging.bgImage),
        onTap: () {
          FullscreenImageViewer.show(context: context, urls: [digging.bgImage]);
        },
      ),
      ListTile(
        dense: true,
        title: Text(S.current.event_point),
        trailing: Item.iconBuilder(context: context, item: digging.eventPointItem, width: 24),
      ),
      ListTile(
        dense: true,
        title: Text(S.current.resettable_digged_num),
        trailing: Text(digging.resettableDiggedNum.toString()),
      ),
      kDefaultDivider,
    ]);

    digging.blocks.sort((a, b) {
      if (a.objectId != b.objectId) return a.objectId - b.objectId;
      return a.id - b.id;
    });
    children.add(const SHeader('Blocks'));
    for (final block in digging.blocks) {
      children.add(ListTile(
        leading: db.getIconImage(block.image, width: 36, aspectRatio: 1),
        title: Text.rich(TextSpan(children: [
          for (final consume in block.consumes) ...[
            CenterWidgetSpan(
              child: Item.iconBuilder(
                context: context,
                item: null,
                itemId: consume.objectId,
                width: 24,
              ),
            ),
            TextSpan(text: ' ×${consume.num}  '),
          ],
          CenterWidgetSpan(
            child: Item.iconBuilder(
              context: context,
              item: digging.eventPointItem,
              width: 24,
            ),
          ),
          TextSpan(text: '+${block.diggingEventPoint}')
        ])),
        trailing: Text('×${block.blockNum}'),
      ));
    }

    children.add(const SHeader('Rewards'));
    digging.rewards.sort((a, b) {
      if (a.rewardSize != b.rewardSize) return b.rewardSize - a.rewardSize;
      return -Item.compare(a.gifts.first.objectId, b.gifts.first.objectId);
    });
    final rewardWidgets = [
      for (final reward in digging.rewards)
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: reward.rewardSize == 2 ? Theme.of(context).colorScheme.errorContainer : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text.rich(TextSpan(children: [
            for (final gift in reward.gifts) ...[
              CenterWidgetSpan(
                child: Item.iconBuilder(
                  context: context,
                  item: null,
                  itemId: gift.objectId,
                  width: 36,
                ),
              ),
              if (gift.num != 1) TextSpan(text: '×${gift.num.format()}')
            ]
          ])),
        )
    ];
    children.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 1,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: rewardWidgets,
      ),
    ));
    return ListView.builder(
      itemBuilder: (context, index) => children[index],
      itemCount: children.length,
    );
  }
}
