import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../runtime.dart';
import 'shop.dart';

// Assume all mstShopDaily is normal item purchase shop
class ExRoomShopPage extends StatefulWidget {
  final FakerRuntime runtime;
  const ExRoomShopPage({super.key, required this.runtime});

  @override
  State<ExRoomShopPage> createState() => _ExRoomShopPageState();
}

typedef _ItemInfo = ({int itemId, int itemNum, int ownNum, int? leftNum});
// typedef _DailyShopInfo = ({ShopDailyEntity shopDaily, UserShopDailyEntity? userShopDaily, NiceShop? shop});

class _ExRoomShopPageState extends State<ExRoomShopPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;

  late int? curDayKey = ShopDailyInfo.getTodayKey(runtime.region);

  @override
  Widget build(BuildContext context) {
    final todayKey = ShopDailyInfo.getTodayKey(runtime.region);
    Map<int, List<ShopDailyEntity>> groups = {};
    for (final shop in mstData.mstShopDaily) {
      (groups[shop.dayKey] ??= []).add(shop);
    }
    groups = {
      for (final key in groups.keys.toList()..sort()) key: groups[key]!..sortByList((e) => [-e.lineupGroup, e.shopId]),
    };

    final shownDailyShops = curDayKey == null ? groups.values.expand((e) => e).toList() : groups[curDayKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(Transl.enums(ShopType.exRoomShop, (e) => e.shopType).l),
        actions: [runtime.buildHistoryButton(context)],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: .horizontal,
            child: FilterGroup<int>(
              options: groups.keys.toList(),
              values: FilterRadioData(curDayKey),
              optionBuilder: (v) => Text(
                ShopDailyInfo.fmtDayKey(v),
                style: todayKey == v ? const TextStyle(decoration: .underline, fontWeight: .bold) : null,
              ),
              onFilterChanged: (v, _) {
                curDayKey = v.radioValue;
                if (mounted) setState(() {});
              },
            ),
          ),
          const Divider(height: 8),
          Expanded(child: ListView(children: [for (final shop in shownDailyShops) buildShop(shop)])),
          SafeArea(
            child: OverflowBar(
              spacing: 8,
              children: [
                runtime.buildCircularProgress(context: context),
                buildCompactButton(
                  text: 'home',
                  onPressed: () async {
                    await agent.homeTop();
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildShop(ShopDailyEntity shopDaily) {
    final info = ShopDailyInfo(shopDaily: shopDaily, userShopDaily: mstData.userShopDaily[shopDaily.shopId]);
    if (info.shop != null) {
      assert(
        info.shop!.purchaseType == .item && info.shop!.targetIds.length == 1 && info.shop!.setNum == 1,
        info.shop!.toJson(),
      );
    }

    final payItemInfo = _getItemInfo(shopDaily.useItemIds.firstOrNull, shopDaily.usePrices.firstOrNull ?? 1);
    final purchaseItemInfo = _getItemInfo(info.shop?.targetIds.firstOrNull, info.shop?.setNum ?? 1);

    return ListTile(
      dense: true,
      horizontalTitleGap: 0,
      // leading: curDayKey == null ? Text(fmtDayKey(dailyShop.dayKey)) : null,
      leading: curDayKey == null ? Text((info.shopDaily.dayKey % 100).toString()) : null,
      title: Row(
        spacing: 8,
        children: [
          ..._buildItemInfo(payItemInfo, purchaseItemInfo, TextStyle(color: Theme.of(context).colorScheme.primary)),
          Icon(Directionality.of(context) == .ltr ? Icons.arrow_forward : Icons.arrow_back, size: 16),
          ..._buildItemInfo(purchaseItemInfo, payItemInfo, TextStyle(color: Theme.of(context).colorScheme.error)),
          // Expanded(child: const SizedBox.shrink()),
        ],
      ),
      trailing: FilledButton(
        style: OutlinedButton.styleFrom(tapTargetSize: .shrinkWrap, padding: .zero),
        onPressed: _checkBuyEnabled(info) != null ? null : () => buyShop(info),
        child: Text('${info.buyNum}/${shopDaily.dailyLimitNum}'),
      ),
    );
  }

  _ItemInfo _getItemInfo(int? itemId, int itemNum) {
    return (
      itemId: itemId ?? 0,
      itemNum: itemNum,
      ownNum: itemId == null ? 0 : mstData.getItemOrSvtNum(itemId),
      leftNum: mstData.isCurPlanUser && itemId != null ? db.itemCenter.itemLeft[itemId] ?? 0 : null,
    );
  }

  List<Widget> _buildItemInfo(_ItemInfo itemInfo, _ItemInfo otherInfo, TextStyle highlightStyle) {
    if (itemInfo.itemId == 0) {
      return [OutlinedButton(onPressed: null, child: Text('Unknown'))];
    }
    // final labelStyle = Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(fontSize: 10));
    return [
      Item.iconBuilder(
        context: context,
        item: null,
        itemId: itemInfo.itemId,
        text: itemInfo.itemNum == 1 ? null : '×${itemInfo.itemNum}',
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 36),
        child: Text.rich(
          TextSpan(
            children: [
              // TextSpan(text: '${S.current.item_own} ', style: labelStyle),
              TextSpan(
                text: itemInfo.ownNum.toString(),
                style: otherInfo.ownNum > itemInfo.ownNum ? highlightStyle : null,
              ),
              if (itemInfo.leftNum != null)
                TextSpan(
                  style: const TextStyle(fontSize: 10),
                  children: [
                    const TextSpan(text: '\n'),
                    // TextSpan(text: '${S.current.item_left} ', style: labelStyle),
                    TextSpan(
                      text: itemInfo.leftNum.toString(),
                      style: (otherInfo.leftNum ?? 0) > (itemInfo.leftNum ?? 0) ? highlightStyle : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ];
  }

  String? _checkBuyEnabled(ShopDailyInfo info) {
    final now = DateTime.now().timestamp;
    if (info.shopDaily.openedAt > now || info.shopDaily.closedAt < now) {
      return 'Not open';
    }
    if (info.buyNum >= info.shopDaily.dailyLimitNum) {
      return 'Limit ${info.buyNum}/${info.shopDaily.dailyLimitNum}';
    }
    return null;
  }

  Future<void> buyShop(ShopDailyInfo info) async {
    int maxBuyCount = info.limitNum - info.buyNum;
    String? error = _checkBuyEnabled(info);
    for (final (index, useItemId) in info.shopDaily.useItemIds.indexed) {
      final usePrice = info.shopDaily.usePrices[index];
      final ownNum = mstData.getItemOrSvtNum(useItemId);
      maxBuyCount = min(maxBuyCount, ownNum ~/ usePrice);
      if (ownNum < usePrice) {
        error ??= '${S.current.item} ${Item.getName(useItemId)} not enough: $ownNum<$usePrice';
      }
    }
    if (error != null) {
      EasyLoading.showError(error);
      return;
    }
    if (!mounted) return;

    final int? buyCount = await ShopBuyCountDialog(
      runtime: runtime,
      shop: info.shop!,
      maxCount: maxBuyCount,
    ).showDialog(context);
    if (buyCount == null || buyCount <= 0 || buyCount > maxBuyCount) return;
    await runtime.runTask(() => runtime.agent.shopPurchase(id: info.shopDaily.shopId, num: buyCount));
  }
}

class ShopDailyInfo {
  final ShopDailyEntity shopDaily;
  final UserShopDailyEntity? userShopDaily;
  final NiceShop? shop;

  ShopDailyInfo({required this.shopDaily, required UserShopDailyEntity? userShopDaily, NiceShop? shop})
    : userShopDaily = userShopDaily?.dayKey == shopDaily.dayKey ? userShopDaily : null,
      shop = _parseShop(shopDaily, shop);

  static NiceShop? _parseShop(ShopDailyEntity shopDaily, NiceShop? shop) {
    if (shop != null && shop.id == shopDaily.shopId) return shop;
    final targetItemId = ConstData.shopDailyTargets[shopDaily.shopId];
    if (targetItemId == null) return null;
    final item = db.gameData.items[targetItemId];
    assert(item != null, 'Item $targetItemId not found');
    return NiceShop(
      id: shopDaily.shopId,
      shopType: .exRoomShopDaily,
      releaseConditions: [],
      slot: 0,
      priority: 130,
      name: "【日替り】${item?.name ?? targetItemId}",
      payType: .item,
      cost: ItemAmount(item: item, itemId: targetItemId, amount: 1),
      purchaseType: .item,
      targetIds: [targetItemId],
      setNum: 1,
      limitNum: 0,
      openedAt: 1785661200,
      closedAt: 1901199599,
    );
  }

  int get limitNum => shopDaily.dailyLimitNum;
  int get buyNum => userShopDaily?.num ?? 0;

  static int getTodayKey(Region region) {
    final d = region.getDateTimeByOffset(DateTime.now().timestamp);
    return d.year * 10000 + d.month * 100 + d.day;
  }

  static String fmtDayKey(int dayKey) {
    final s = dayKey.toString();
    return s.length > 4 ? s.substring2(s.length - 4) : s;
  }
}
