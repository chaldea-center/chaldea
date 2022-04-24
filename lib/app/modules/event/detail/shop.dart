import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class EventShopsPage extends StatelessWidget {
  final Event event;
  final int slot;
  const EventShopsPage({Key? key, required this.event, required this.slot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shops = event.shop.where((e) => e.slot == slot).toList();
    shops.sort2((e) => e.priority);
    return ListView.separated(
      itemBuilder: (context, index) => shopItemBuilder(context, shops[index]),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: shops.length,
    );
  }

  Widget shopItemBuilder(BuildContext context, NiceShop shop) {
    Widget? leading;
    String? title;
    int? targetId = shop.targetIds.getOrNull(0);
    if (shop.purchaseType != PurchaseType.setItem && targetId != null) {
      leading =
          GameCardMixin.anyCardItemBuilder(context: context, id: targetId);
      switch (shop.purchaseType) {
        case PurchaseType.item:
          title = Item.getName(targetId);
          break;
        case PurchaseType.equip:
          title = db.gameData.mysticCodes[targetId]?.lName.l;
          break;
        case PurchaseType.friendGacha:
          title = 'Friend Points';
          break;
        case PurchaseType.servant:
          title = (db.gameData.servantsById[targetId] ??
                  db.gameData.craftEssencesById[targetId])
              ?.lName
              .l;
          break;
        case PurchaseType.quest:
          final quest = db.gameData.quests[targetId];
          title = 'Quest ${quest?.lName.l ?? targetId}';
          break;
        case PurchaseType.eventSvtJoin:
        case PurchaseType.eventSvtGet:
          final svt = db.gameData.servantsById[targetId];
          title = '${svt?.lName.l ?? targetId} join';
          break;
        case PurchaseType.costumeRelease:
          int svtId = targetId ~/ 100, costumeId = targetId % 100;
          final svt = db.gameData.servantsById[svtId];
          final costume = svt?.profile.costume.values
              .firstWhereOrNull((costume) => costume.id == costumeId);
          title = costume?.lName.l;
          break;
        case PurchaseType.lotteryShop:
          title = 'A random item';
          leading = const SizedBox();
          break;
        case PurchaseType.commandCode:
          title = db.gameData.commandCodesById[targetId]?.lName.l;
          break;
        default:
          break;
      }
    } else {
      // TODO: itemSet
    }
    title ??= shop.name;
    if (shop.setNum != 1) {
      title += ' ×${shop.setNum}';
    }
    Widget subtitle;
    if (shop.cost.amount == 0) {
      subtitle = const Text(' ');
    } else {
      subtitle = Text.rich(
        TextSpan(text: 'Cost: ', children: [
          WidgetSpan(
            child: GameCardMixin.anyCardItemBuilder(
              context: context,
              id: shop.cost.itemId,
              height: 24,
            ),
          ),
          TextSpan(text: ' ×${shop.cost.amount}'),
        ]),
        style: Theme.of(context).textTheme.caption,
      );
    }

    return ListTile(
      key: Key('event_shop_${shop.id}'),
      leading: leading,
      title: Text(title),
      subtitle: subtitle,
      trailing: Text(shop.limitNum == 0 ? '∞' : '×${shop.limitNum}'),
    );
  }
}
