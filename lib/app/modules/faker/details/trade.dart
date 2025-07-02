import 'dart:math' show max, min;

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/timer/base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../history.dart';
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
  int eventId = 0;
  Map<int, EventTradeGoods> tradeGoodsMap = {};
  late final tabController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    runtime.addDependency(this);
    if (userEventTrades.length == 1) {
      selectTrade(userEventTrades.single);
    }
  }

  @override
  void dispose() {
    runtime.removeDependency(this);
    super.dispose();
  }

  void selectTrade(UserEventTradeEntity trade) {
    eventId = trade.eventId;
    final event = db.gameData.events[trade.eventId];
    if (event != null) {
      tradeGoodsMap = {for (final goods in event.tradeGoods) goods.id: goods};
    } else {
      tradeGoodsMap.clear();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final eventTrade = userEventTrades[eventId];
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

    final tradeInfoList = eventTrade.tradeList.toList();
    final resultList = eventTrade.resultList.toList();
    final pickupList = eventTrade.pickupList.toList();
    final tradeInfoMap = {for (final trade in tradeInfoList) trade.tradeGoodsId: trade};
    final resultMap = {for (final result in resultList) result.tradeGoodsId: result};
    final pickupMap = {for (final pickup in pickupList) pickup.tradeGoodsId: pickup};

    final tradeGoodsList = tradeGoodsMap.values.toList();
    tradeGoodsList.sortByList((e) => [tradeInfoMap[e.id]?.storeIdx ?? 999, e.id]);

    final consumeItemIds = tradeGoodsList.expand((e) => e.consumes).map((e) => e.objectId).toSet().toList();
    consumeItemIds.sort();

    final demandItems = <int, int>{};
    for (final tradeInfo in tradeInfoList) {
      final tradeGoods = tradeGoodsMap[tradeInfo.tradeGoodsId];
      if (tradeGoods == null) continue;
      for (final consume in tradeGoods.consumes) {
        demandItems.addNum(consume.objectId, consume.num * (kSecsPerDay / tradeGoods.tradeTime).round());
      }
    }
    sortDict(demandItems, inPlace: true, compare: (a, b) => b.key.compareTo(a.key));
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.event_trade),
        actions: [
          IconButton(
            onPressed: () {
              router.push(url: Routes.eventI(eventTrade.eventId));
            },
            icon: Icon(Icons.flag),
            tooltip: S.current.event,
          ),
          IconButton(
            onPressed: () {
              router.pushPage(FakerHistoryViewer(agent: runtime.agent));
            },
            icon: const Icon(Icons.history),
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
          Column(
            children: [
              ListTile(
                dense: true,
                // leading: const SizedBox.shrink(),
                title: Wrap(
                  spacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${S.current.item_own}: '),
                    for (final itemId in consumeItemIds.reversed)
                      Item.iconBuilder(
                        context: context,
                        item: null,
                        itemId: itemId,
                        text: runtime.mstData.getItemOrSvtNum(itemId).format(),
                      ),
                    Text('  24h: '),
                    for (final (itemId, count) in demandItems.items)
                      Item.iconBuilder(context: context, item: null, itemId: itemId, text: count.format()),
                  ],
                ),
              ),
              kDefaultDivider,
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) =>
                      buildTrade(tradeGoodsList[index], tradeInfoMap, resultMap, pickupMap),
                  itemCount: tradeGoodsList.length,
                  separatorBuilder: (context, index) => const Divider(height: 4, indent: 16, endIndent: 16),
                ),
              ),
            ],
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
    EventTradeGoods tradeGood,
    Map<int, EventTradeInfo> tradeInfoMap,
    Map<int, EventTradeResultInfo> results,
    Map<int, EventCraftPickupInfo> pickups,
  ) {
    final tradeInfo = tradeInfoMap[tradeGood.id];
    final pickup = pickups[tradeGood.id];
    final now = DateTime.now().timestamp;
    final isCraftPickup = pickup != null && pickup.startedAt <= now && pickup.endedAt >= now;

    double getLeastReceiveNum() {
      if (tradeInfo == null) return 0;
      final now = DateTime.now().timestamp;
      if (tradeInfo.tradeNum == 0) return 0;
      return (now - tradeInfo.startedAt) / tradeGood.tradeTime;
    }

    Widget tile = ListTile(
      dense: true,
      selected: isCraftPickup,
      horizontalTitleGap: 8,
      contentPadding: EdgeInsetsDirectional.only(start: 16),
      leading: tradeGood.goodsIcon == null ? null : db.getIconImage(tradeGood.goodsIcon, width: 32),
      title: Text(
        [
          if (tradeInfo != null) '[${tradeInfo.storeIdx}]',
          tradeGood.lName,
          '(${(tradeGood.tradeTime / 3600).format()}h)',
        ].join(' '),
        textScaler: const TextScaler.linear(0.9),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final consume in tradeGood.consumes) ...[
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
          if (tradeInfo != null)
            Text(
              [
                tradeInfo.startedAt,
                tradeInfo.endedAt,
              ].map((e) => e.sec2date().toCustomString(year: false, second: false)).join(' ~ '),
            ),
        ],
      ),
    );

    Widget trailing = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 2,
      children: [
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (tradeInfo != null)
                Text(
                  '${tradeInfo.getNum}(${min(tradeInfo.tradeNum, getLeastReceiveNum()).format(precision: 2)})'
                  '/${tradeInfo.tradeNum}/${tradeInfo.maxTradeNum}',
                ),
              if (tradeInfo != null)
                tradeInfo.endedAt == 0
                    ? const Text('-:-:-', style: TextStyle(color: Colors.red))
                    : CountDown(endedAt: tradeInfo.endedAt.sec2date()),
              Text('${(tradeGood.tradeTime / 3600).format()}h'),
            ],
          ),
        ),
        for (final gift in tradeGood.gifts)
          gift.iconBuilder(
            context: context,
            width: 32,
            text: [
              runtime.mstData.getItemOrSvtNum(gift.objectId).format(),
              (db.itemCenter.itemLeft[gift.objectId] ?? 0).format(),
            ].join('\n'),
          ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: tile),
            trailing,
            const SizedBox(width: 16),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            _buildButton(
              onPressed:
                  (tradeInfo != null && tradeInfo.tradeNum >= tradeInfo.maxTradeNum) ||
                      tradeGood.consumes.any((e) => runtime.mstData.getItemOrSvtNum(e.objectId) < e.num)
                  ? null
                  : () async {
                      int tradeGoodsNum = 1;
                      final curIdxs = tradeInfoMap.values.map((e) => e.storeIdx).toSet();
                      final idx = tradeInfo?.storeIdx ?? range(1, 8).firstWhereOrNull((e) => !curIdxs.contains(e));
                      if (idx == null) {
                        EasyLoading.showToast('No valid idx');
                        return;
                      }
                      if (tradeInfo != null) {
                        if (tradeInfo.tradeNum >= tradeInfo.maxTradeNum) {
                          EasyLoading.showError('Already max trade num ${tradeInfo.tradeNum}/${tradeInfo.maxTradeNum}');
                          return;
                        }
                        tradeGoodsNum = Maths.min([
                          tradeInfo.maxTradeNum - tradeInfo.tradeNum,
                          for (final consume in tradeGood.consumes)
                            (runtime.mstData.getItemOrSvtNum(consume.objectId) / consume.num).floor(),
                        ]);
                      } else {
                        final confirm = await SimpleConfirmDialog(
                          title: Text('Start Trade'),
                          content: Text('Current in trade: ${tradeInfoMap.length}'),
                        ).showDialog(context);
                        if (confirm != true) return;
                      }
                      if (tradeGoodsNum <= 0) {
                        EasyLoading.showError('No enough item');
                        return;
                      }

                      final chosenCount = await router.showDialog<int>(
                        builder: (context) {
                          return SimpleDialog(
                            title: Text('Trade Num'),
                            children: [
                              if ((tradeInfo?.getNum ?? 0) > 0 || getLeastReceiveNum().floor() >= 1)
                                SimpleDialogOption(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  child: Text('Do Receive first', style: Theme.of(context).textTheme.bodySmall),
                                ),
                              for (int count = 1; count <= tradeGoodsNum; count++)
                                SimpleDialogOption(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  onPressed: () {
                                    Navigator.pop(context, count);
                                  },
                                  child: Text('×$count'),
                                ),
                            ],
                          );
                        },
                      );
                      if (chosenCount == null) return;
                      tradeGoodsNum = chosenCount;

                      runTask(
                        () => runtime.agent.eventTradeStart(
                          eventId: eventId,
                          tradeStoreIdx: idx,
                          tradeGoodsId: tradeGood.id,
                          tradeGoodsNum: tradeGoodsNum,
                          itemId: 0,
                        ),
                      );
                    },
              text: 'Trade',
            ),
            if (tradeInfo != null) ...[
              _buildButton(
                color: tradeInfo.getNum > 0 || getLeastReceiveNum().floor() > 0 ? Colors.green : null,
                onPressed: tradeInfo.tradeNum == 0
                    ? null
                    : () async {
                        int receiveNum = Maths.max([tradeInfo.getNum, getLeastReceiveNum().floor()]);
                        await router.showDialog<int>(
                          builder: (context) {
                            return SimpleDialog(
                              title: Text('Receive Num ×$receiveNum'),
                              children: [
                                SimpleDialogOption(
                                  child: Text(
                                    'getNum=${tradeInfo.getNum}, least=${getLeastReceiveNum().format(precision: 2)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                for (int count = 0; count <= max(1, receiveNum); count++)
                                  if (count > 0 || receiveNum == 0)
                                    SimpleDialogOption(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        runTask(
                                          () => runtime.agent.eventTradeReceive(
                                            eventId: eventId,
                                            tradeStoreIdxs: [tradeInfo.storeIdx],
                                            receiveNum: max(1, tradeInfo.getNum),
                                            cancelTradeFlag: 0,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '×$count',
                                        style: count == receiveNum
                                            ? TextStyle(color: Theme.of(context).listTileTheme.selectedColor)
                                            : null,
                                      ),
                                    ),
                              ],
                            );
                          },
                        );
                      },
                text: 'Receive',
              ),
              _buildButton(
                color: Colors.red,
                onPressed: () {
                  SimpleConfirmDialog(
                    title: Text(S.current.cancel),
                    content: Text('Sure?'),
                    onTapOk: () {
                      runTask(
                        () => runtime.agent.eventTradeReceive(
                          eventId: eventId,
                          tradeStoreIdxs: [tradeInfo.storeIdx],
                          receiveNum: 0,
                          cancelTradeFlag: 1,
                        ),
                      );
                    },
                  ).showDialog(context);
                },
                text: 'Cancel',
              ),
            ],
          ],
        ),
      ],
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

  Widget _buildButton({VoidCallback? onPressed, required String text, Color? color}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(text, textScaler: TextScaler.linear(0.8)),
    );
  }

  Future<void> runTask(Future Function() cb) async {
    await showEasyLoading(() => runtime.runTask(cb));
    if (mounted) setState(() {});
  }
}
