import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventShopsPage extends StatelessWidget with PrimaryScrollMixin {
  final Event event;
  final int slot;
  const EventShopsPage({Key? key, required this.event, required this.slot})
      : super(key: key);

  @override
  Widget buildContent(BuildContext context) {
    final plan = db.curUser.limitEventPlanOf(event.id);
    final shops = event.shop.where((e) => e.slot == slot).toList();
    shops.sort2((e) => e.priority);
    return db.onUserData(
      (context, snapshot) => ListView.separated(
        itemBuilder: (context, index) =>
            shopItemBuilder(context, shops[index], plan),
        separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
        itemCount: shops.length,
      ),
    );
  }

  Widget shopItemBuilder(
      BuildContext context, NiceShop shop, LimitEventPlan plan) {
    Widget? leading;
    String? title;
    Widget? titleWidget;
    int? targetId = shop.targetIds.getOrNull(0);
    bool excluded = plan.shopExcludes.contains(shop.id);
    TextStyle? style;
    if (excluded) {
      style = TextStyle(
        color: Theme.of(context).disabledColor,
        decoration: TextDecoration.lineThrough,
      );
    }
    if (shop.purchaseType == PurchaseType.setItem) {
      titleWidget = Text.rich(
        TextSpan(
          children: [
            for (final itemSet in shop.itemSet) ...[
              WidgetSpan(
                  child: _iconBuilder(
                      context, itemSet.purchaseType, itemSet.targetId, 28)),
              TextSpan(
                  text: _getItemName(
                      itemSet.purchaseType, itemSet.targetId, itemSet.setNum)),
            ],
            if (shop.setNum != 1) TextSpan(text: ' (x${shop.setNum})'),
          ],
        ),
        style: style,
      );
    } else if (targetId != null) {
      leading = _iconBuilder(context, shop.purchaseType, targetId, 42);
      title = _getItemName(shop.purchaseType, targetId, null);
      title ??= shop.name;
      if (shop.setNum != 1) {
        title += ' x${shop.setNum}';
      }
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
    Widget trailing =
        Text(shop.limitNum == 0 ? '∞' : '×${shop.limitNum}', style: style);
    titleWidget ??= title?.toText(style: style);
    return ListTile(
      key: Key('event_shop_${shop.id}'),
      leading: leading,
      title: titleWidget,
      subtitle: subtitle,
      trailing: trailing,
      tileColor: excluded ? Theme.of(context).splashColor : null,
      onTap: () {
        if (excluded) {
          plan.shopExcludes.remove(shop.id);
        } else {
          plan.shopExcludes.add(shop.id);
        }
        event.updateStat();
      },
    );
  }

  String? _getItemName(PurchaseType purchaseType, int targetId, int? setNum) {
    String? title;
    switch (purchaseType) {
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
        final svt = db.gameData.servantsById[targetId] ??
            db.gameData.craftEssencesById[targetId] ??
            db.gameData.entities[targetId];
        title = svt?.lName.l;
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
        // leading = const SizedBox();
        break;
      case PurchaseType.commandCode:
        title = db.gameData.commandCodesById[targetId]?.lName.l;
        break;
      case PurchaseType.kiaraPunisherReset:
        title = 'Kiara Punisher Reset';
        break;
      default:
        break;
    }
    if (title != null && setNum != null) {
      title += ' ×$setNum';
    }
    return title;
  }

  Widget _iconBuilder(BuildContext context, PurchaseType purchaseType,
      int targetId, double? width) {
    switch (purchaseType) {
      case PurchaseType.lotteryShop:
      // return const SizedBox();
      case PurchaseType.kiaraPunisherReset:
        return const SizedBox();
      default:
        return GameCardMixin.anyCardItemBuilder(
          context: context,
          id: targetId,
          width: width,
        );
    }
  }
}
