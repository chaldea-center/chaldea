import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

class EventShopsPage extends StatefulWidget {
  final Event event;
  const EventShopsPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventShopsPage> createState() => _EventShopsPageState();
}

class _EventShopsPageState extends State<EventShopsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<int, List<NiceShop>> slotShops = {};
  @override
  void initState() {
    super.initState();
    for (final shop in widget.event.shop) {
      slotShops.putIfAbsent(shop.slot, () => []).add(shop);
    }
    for (final shops in slotShops.values) {
      shops.sort2((e) => e.priority);
    }
    _tabController = TabController(length: slotShops.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> slots = slotShops.keys.toList();
    slots.sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Shop'),
        bottom: slotShops.length > 1
            ? TabBar(
                controller: _tabController,
                tabs: slots.map((e) => Tab(text: 'Shop $e')).toList(),
              )
            : null,
      ),
      body: slotShops.length > 1
          ? TabBarView(
              controller: _tabController,
              children: [
                for (final slot in slots) shopBuilder(context, slotShops[slot]!)
              ],
            )
          : shopBuilder(
              context, slotShops.isEmpty ? [] : slotShops.values.first),
    );
  }

  Widget shopBuilder(BuildContext context, List<NiceShop> shops) {
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
          title = db2.gameData.mysticCodes[targetId]?.lName.l;
          break;
        case PurchaseType.friendGacha:
          title = 'Friend Points';
          break;
        case PurchaseType.servant:
          title = (db2.gameData.servantsById[targetId] ??
                  db2.gameData.craftEssencesById[targetId])
              ?.lName
              .l;
          break;
        case PurchaseType.quest:
          final quest = db2.gameData.quests[targetId];
          title = 'Quest ${quest?.lName.l ?? targetId}';
          break;
        case PurchaseType.eventSvtJoin:
        case PurchaseType.eventSvtGet:
          final svt = db2.gameData.servantsById[targetId];
          title = '${svt?.lName.l ?? targetId} join';
          break;
        case PurchaseType.costumeRelease:
          int svtId = targetId ~/ 100, costumeId = targetId % 100;
          final svt = db2.gameData.servantsById[svtId];
          final costume = svt?.profile.costume.values
              .firstWhereOrNull((costume) => costume.id == costumeId);
          title = costume?.lName.l;
          break;
        case PurchaseType.lotteryShop:
          title = 'A random item';
          leading = const SizedBox();
          break;
        case PurchaseType.commandCode:
          title = db2.gameData.commandCodesById[targetId]?.lName.l;
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
      trailing: Text(shop.limitNum == 0 ? '∞' : shop.limitNum.toString()),
      // horizontalTitleGap: 0,
      // contentPadding: const EdgeInsetsDirectional.only(start: 16),
    );
  }
}
