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
  UserEventTradeEntity? eventTrade;
  Event? event;
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

    final tradeInfoList = eventTrade!.tradeList.toList();
    final resultList = eventTrade!.resultList.toList();
    final pickupList = eventTrade!.pickupList.toList();
    final tradeInfoMap = {for (final trade in tradeInfoList) trade.tradeGoodsId: trade};
    final resultMap = {for (final result in resultList) result.tradeGoodsId: result};
    final pickupMap = {for (final pickup in pickupList) pickup.tradeGoodsId: pickup};

    final tradeGoodsList = tradeGoodsMap.values.toList();
    tradeGoodsList.sortByList((e) => [tradeInfoMap[e.id]?.storeIdx ?? 999, e.id]);
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
                leading: const SizedBox.shrink(),
                title: Wrap(
                  spacing: 2,
                  children: [
                    for (final itemId in tradeGoodsList.expand((e) => e.consumes).map((e) => e.objectId).toSet())
                      Item.iconBuilder(
                        context: context,
                        item: null,
                        itemId: itemId,
                        text: ((runtime.mstData.userItem[itemId]?.num ?? 0).format()),
                      ),
                  ],
                ),
              ),
              kDefaultDivider,
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) =>
                      buildTrade(tradeGoodsList[index], tradeInfoMap, resultMap, pickupMap),
                  itemCount: tradeGoodsList.length,
                  separatorBuilder: (context, index) => const Divider(height: 16, indent: 16, endIndent: 16),
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
                  '${tradeInfo.getNum}(${min(tradeInfo.tradeNum, (DateTime.now().timestamp - tradeInfo.startedAt) / tradeGood.tradeTime).format(precision: 2)})'
                  '/${tradeInfo.tradeNum}/${tradeInfo.maxTradeNum}',
                ),
              if (tradeInfo != null) CountDown(endedAt: tradeInfo.endedAt.sec2date()),
              Text('${(tradeGood.tradeTime / 3600).format()}h'),
            ],
          ),
        ),
        for (final gift in tradeGood.gifts)
          gift.iconBuilder(
            context: context,
            width: 32,
            text: [
              (runtime.mstData.userItem[gift.objectId]?.num ?? 0).format(),
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
              onPressed: tradeInfo != null && tradeInfo.tradeNum >= tradeInfo.maxTradeNum
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
                        if (tradeInfo.getNum > 0) {
                          EasyLoading.showInfo('Do Receive first');
                          return;
                        }
                        tradeGoodsNum = Maths.min([
                          tradeInfo.maxTradeNum - tradeInfo.tradeNum,
                          for (final consume in tradeGood.consumes)
                            ((runtime.mstData.userItem[consume.objectId]?.num ?? 0) / consume.num).floor(),
                        ]);
                      }
                      if (tradeGoodsNum <= 0) {
                        EasyLoading.showError('No enough item');
                        return;
                      }

                      if (tradeGoodsNum > 1) {
                        final chosenCount = await router.showDialog<int>(
                          builder: (context) {
                            return SimpleDialog(
                              title: Text('Trade Num'),
                              children: [
                                for (int count = 1; count <= tradeGoodsNum; count++)
                                  SimpleDialogOption(
                                    child: Text(count.toString()),
                                    onPressed: () {
                                      Navigator.pop(context, count);
                                    },
                                  ),
                              ],
                            );
                          },
                        );
                        if (chosenCount == null) return;
                        tradeGoodsNum = chosenCount;
                      }

                      runTask(
                        () => runtime.agent.eventTradeStart(
                          eventId: eventTrade!.eventId,
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
                color: tradeInfo.getNum > 0 ? Colors.green : null,
                onPressed: () async {
                  if (tradeInfo.getNum == 0) {
                    final confirm = await SimpleConfirmDialog(
                      title: Text('Receive?'),
                      content: Text('Now getNum=0'),
                    ).showDialog(context);
                    if (confirm != true) return;
                  }
                  runTask(
                    () => runtime.agent.eventTradeReceive(
                      eventId: eventTrade!.eventId,
                      tradeStoreIdxs: [tradeInfo.storeIdx],
                      receiveNum: max(1, tradeInfo.getNum),
                      cancelTradeFlag: 0,
                    ),
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
                          eventId: eventTrade!.eventId,
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
      style: TextButton.styleFrom(foregroundColor: color),
      child: Text(text, textScaler: TextScaler.linear(0.8)),
    );
    // return OutlinedButton(onPressed: onPressed, child: child);
  }

  Future<void> runTask(Future Function() cb) async {
    await showEasyLoading(() => runtime.runTask(cb));
    if (mounted) setState(() {});
  }
}
