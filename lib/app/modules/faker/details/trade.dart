import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/timer/base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../state.dart';

class UserEventTradePage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserEventTradePage({super.key, required this.runtime});

  @override
  State<UserEventTradePage> createState() => _UserEventTradePageState();
}

class _UserEventTradePageState extends State<UserEventTradePage> with SingleTickerProviderStateMixin {
  late final runtime = widget.runtime;
  late final userEventTrades = runtime.mstData.userEventTrade;
  UserEventTradeEntity? eventTrade;
  Event? event;
  Map<int, EventTradeGoods> tradeGoodsMap = {};
  late final tabController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    if (userEventTrades.length == 1) {
      selectTrade(userEventTrades.single);
    }
  }

  void selectTrade(UserEventTradeEntity trade) {
    eventTrade = trade;
    event = db.gameData.events[trade.eventId];
    if (event != null) {
      tradeGoodsMap = {for (final goods in event!.tradeGoods) goods.id: goods};
    } else {
      tradeGoodsMap.clear();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (eventTrade == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.current.event_trade)),
        body: ListView(
          children: [
            for (final trade in userEventTrades)
              ListTile(
                title: Text(db.gameData.events[trade.eventId]?.shownName ?? trade.eventId.toString()),
                onTap: () {
                  selectTrade(trade);
                },
              ),
          ],
        ),
      );
    }

    final tradeList = eventTrade!.tradeList.toList();
    tradeList.sort2((e) => e.endedAt);
    final resultList = eventTrade!.resultList.toList();
    final pickupList = eventTrade!.pickupList.toList();
    final resultMap = {for (final result in resultList) result.tradeGoodsId: result};
    final pickupMap = {for (final pickup in pickupList) pickup.tradeGoodsId: pickup};
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_trade),
        actions: [
          if (eventTrade != null)
            IconButton(
              onPressed: () {
                router.push(url: Routes.eventI(eventTrade!.eventId));
              },
              icon: Icon(Icons.flag),
              tooltip: S.current.event,
            ),
        ],
        bottom: FixedHeight.tabBar(
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'Trades'),
              Tab(text: 'Results'),
              Tab(text: 'Pickups'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ListView.separated(
            itemBuilder: (context, index) => buildTrade(tradeList[index], resultMap, pickupMap),
            itemCount: tradeList.length,
            separatorBuilder: (context, index) => const Divider(height: 16, indent: 16, endIndent: 16),
          ),
          ListView.builder(
            itemBuilder: (context, index) => buildResult(resultList[index]),
            itemCount: resultList.length,
          ),
          ListView.builder(
            itemBuilder: (context, index) => buildPickup(pickupList[index]),
            itemCount: pickupList.length,
          ),
        ],
      ),
    );
  }

  Widget buildTrade(
    EventTradeInfo tradeInfo,
    Map<int, EventTradeResultInfo> results,
    Map<int, EventCraftPickupInfo> pickups,
  ) {
    final goods = tradeGoodsMap[tradeInfo.tradeGoodsId];
    final pickup = pickups[tradeInfo.tradeGoodsId];
    final now = DateTime.now().timestamp;
    final isCraftPickup = pickup != null && pickup.startedAt <= now && pickup.endedAt >= now;
    return ListTile(
      dense: true,
      selected: isCraftPickup,
      horizontalTitleGap: 8,
      leading: goods?.goodsIcon == null ? null : db.getIconImage(goods?.goodsIcon, width: 32),
      title: Text(goods?.lName ?? '${tradeInfo.tradeGoodsId}', textScaler: const TextScaler.linear(0.9)),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final consume in goods?.consumes ?? <CommonConsume>[]) ...[
                      Item.iconBuilder(
                        context: context,
                        item: db.gameData.items[consume.objectId],
                        width: 24,
                        icon: db.gameData.items[consume.objectId]?.icon,
                      ),
                      Text('${consume.num.format()} ', textScaler: const TextScaler.linear(0.9)),
                    ],
                  ],
                ),
              ),
              Text('${tradeInfo.getNum}/${tradeInfo.tradeNum}/${tradeInfo.maxTradeNum}'),
            ],
          ),
          // Text('num ${tradeInfo.tradeNum}, maxNum ${tradeInfo.maxTradeNum}, getNum ${tradeInfo.getNum}'),
          buildTime(tradeInfo.startedAt, tradeInfo.endedAt),
        ],
      ),
      trailing: goods == null ? null : buildGifts(goods),
    );
  }

  Widget buildResult(EventTradeResultInfo result) {
    final goods = tradeGoodsMap[result.tradeGoodsId];
    return ListTile(
      dense: true,
      title: Text(goods == null ? '${result.tradeGoodsId}' : goods.lName),
      subtitle: goods == null ? null : buildGifts(goods),
      trailing: Text('×${result.getNum}'),
    );
  }

  Widget buildPickup(EventCraftPickupInfo pickup) {
    final goods = tradeGoodsMap[pickup.tradeGoodsId];
    return ListTile(
      dense: true,
      title: Text(goods == null ? '${pickup.tradeGoodsId}' : goods.lName),
      subtitle: buildTime(pickup.startedAt, pickup.endedAt),
      // trailing: Item.iconBuilder(context: context, item: null, itemId: pickup.itemId),
      trailing: goods == null ? null : buildGifts(goods),
    );
  }

  Widget buildTime(int startedAt, int endedAt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            [startedAt, endedAt].map((e) => e.sec2date().toCustomString(year: false, second: false)).join(' ~ '),
          ),
        ),
        CountDown(endedAt: endedAt.sec2date()),
      ],
    );
  }

  Widget buildGifts(EventTradeGoods goods) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        alignment: WrapAlignment.start,
        children: [
          for (final gift in goods.gifts) gift.iconBuilder(context: context, width: 32, showOne: true),
          if (goods.eventPointItem != null && goods.eventPointNum != 0)
            Item.iconBuilder(
              context: context,
              item: goods.eventPointItem,
              width: 32,
              icon: goods.eventPointItem?.icon,
              text: goods.eventPointNum.format(compact: false, groupSeparator: ','),
            ),
        ],
      ),
    );
  }
}
