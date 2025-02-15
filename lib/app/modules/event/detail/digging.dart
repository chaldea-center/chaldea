import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventDiggingTab extends StatefulWidget {
  final Event event;
  final EventDigging digging;

  const EventDiggingTab({super.key, required this.event, required this.digging});

  @override
  State<EventDiggingTab> createState() => _EventDiggingTabState();
}

class _EventDiggingTabState extends State<EventDiggingTab> {
  Event get event => widget.event;
  EventDigging get digging => widget.digging;

  bool showItemPlan = false;

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
        trailing: Item.iconBuilder(
          context: context,
          item: digging.eventPointItem,
          width: 24,
          icon: digging.eventPointItem.icon,
        ),
      ),
      ListTile(
        dense: true,
        title: Text(S.current.resettable_digged_num),
        trailing: Text(digging.resettableDiggedNum.toString()),
      ),
      kDefaultDivider,
      SwitchListTile(
        dense: true,
        title: Text('${S.current.show}(${S.current.item}): ${S.current.item_own}/${S.current.item_left}'),
        value: showItemPlan,
        onChanged: (v) {
          setState(() {
            showItemPlan = v;
          });
        },
      ),
      kDefaultDivider,
    ]);

    digging.blocks.sort((a, b) {
      if (a.objectId != b.objectId) return a.objectId - b.objectId;
      return a.id - b.id;
    });
    children.add(const SHeader('Blocks'));
    for (final block in digging.blocks) {
      final rewardIds = EventDigging.blockRewards[event.id]?[block.id % event.id] ?? [];
      final rewards = digging.rewards.where((e) => rewardIds.contains(e.id % event.id)).toList();
      children.add(
        ListTile(
          leading: ImageWithText(
            image: CachedImage(imageUrl: block.image, width: 36, aspectRatio: 1),
            text: '×${block.blockNum}',
            option: ImageWithTextOption(fontSize: 12, textStyle: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          // horizontalTitleGap: 8,
          title: Text.rich(
            TextSpan(
              children: [
                for (final consume in block.consumes) ...[
                  CenterWidgetSpan(
                    child: Item.iconBuilder(context: context, item: null, itemId: consume.objectId, width: 24),
                  ),
                  TextSpan(text: '×${consume.num} '),
                ],
                CenterWidgetSpan(
                  child: Item.iconBuilder(
                    context: context,
                    item: digging.eventPointItem,
                    width: 24,
                    icon: digging.eventPointItem.icon,
                  ),
                ),
                TextSpan(text: '+${block.diggingEventPoint}'),
              ],
            ),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: db.onUserData(
            (context, snapshot) => Wrap(
              spacing: 1,
              children: [
                for (final reward in rewards)
                  ...reward.gifts.map((gift) {
                    final itemCounts = [
                      db.curUser.items[gift.objectId] ?? 0,
                      db.itemCenter.itemLeft[gift.objectId] ?? 0,
                    ];
                    final notEnough = itemCounts.any((e) => e < 0);
                    return gift.iconBuilder(
                      context: context,
                      width: 36,
                      showOne: false,
                      text: showItemPlan ? itemCounts.map((e) => e.format()).join('\n') : null,
                      option: ImageWithTextOption(
                        fontSize: 10,
                        shadowColor: notEnough ? Colors.white : null,
                        textStyle: TextStyle(color: notEnough ? Theme.of(context).colorScheme.errorContainer : null),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      );
    }

    children.add(const SHeader('Rewards'));
    final rewards = digging.rewards.toList();
    rewards.sort((a, b) {
      if (a.rewardSize != b.rewardSize) return b.rewardSize - a.rewardSize;
      return Item.compare2(a.gifts.first.objectId, b.gifts.first.objectId);
    });

    final rewardWidgets = [
      for (final reward in rewards)
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: reward.rewardSize == 2 ? Theme.of(context).colorScheme.errorContainer : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                for (final gift in reward.gifts) ...[
                  CenterWidgetSpan(
                    child: Item.iconBuilder(context: context, item: null, itemId: gift.objectId, width: 36),
                  ),
                  if (gift.num != 1) TextSpan(text: '×${gift.num.format()}'),
                ],
              ],
            ),
          ),
        ),
    ];
    children.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 1, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: rewardWidgets),
      ),
    );
    return ListView.builder(itemBuilder: (context, index) => children[index], itemCount: children.length);
  }
}
