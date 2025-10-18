import 'dart:math' show min;

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/shop/shop.dart';
import 'package:chaldea/app/modules/timer/base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../state.dart';

class UserShopsPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String title;
  final List<NiceShop> shops;
  final Event? event;
  const UserShopsPage({super.key, required this.runtime, required this.title, required this.shops, this.event});

  @override
  State<UserShopsPage> createState() => _UserShopsPageState();
}

class _UserShopsPageState extends State<UserShopsPage> with SingleTickerProviderStateMixin, FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final shops = widget.shops.toList();
  final shownConsumeItem = FilterRadioData<int>();

  @override
  Widget build(BuildContext context) {
    shops.sortByList((shop) => <int>[isShopReleased(shop) ? 0 : 1, isSoldOut(shop) ? 1 : 0, shop.priority, shop.id]);
    Set<int> consumeItemIds = {};
    for (final shop in shops) {
      if (shop.cost != null) {
        consumeItemIds.add(shop.cost!.itemId);
      }
      for (final consume in shop.consumes) {
        if (consume.type == CommonConsumeType.item) {
          consumeItemIds.add(consume.objectId);
        }
      }
    }
    List<NiceShop> shownShops = shops;
    if (shownConsumeItem.options.isNotEmpty) {
      shownShops = shops
          .where((shop) => shownConsumeItem.options.intersection(shop.getConsumeItems().keys.toSet()).isNotEmpty)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.event != null)
            IconButton(
              onPressed: () {
                router.push(url: Routes.eventI(widget.event!.id));
              },
              icon: Icon(Icons.flag),
              tooltip: S.current.event,
            ),
          runtime.buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) => buildShop(shownShops[index]),
              separatorBuilder: (context, _) => const Divider(),
              itemCount: shownShops.length,
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: ListTile(
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  runtime.buildCircularProgress(context: context),
                  const SizedBox(width: 8),
                  FilterGroup<int>(
                    options: consumeItemIds.toList()..sort2((e) => -e),
                    values: shownConsumeItem,
                    shrinkWrap: true,
                    constraints: const BoxConstraints(),
                    optionBuilder: (itemId) => Item.iconBuilder(
                      context: context,
                      item: null,
                      itemId: itemId,
                      text: mstData.getItemOrSvtNum(itemId).format(),
                      width: 42,
                      jumpToDetail: false,
                      padding: EdgeInsets.all(2),
                    ),
                    onFilterChanged: (_, _) {
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildShop(NiceShop shop) {
    final reward = ShopHelper.purchases(context, shop, showSpecialName: true).firstOrNull;
    final userShop = mstData.userShop[shop.id];
    final bool canBuy = !isSoldOut(shop) && shop.releaseConditions.every(isReleaseOpen);
    final TextStyle? textStyle = canBuy ? null : TextStyle(color: Theme.of(context).disabledColor);
    Widget? leading = reward?.$1;
    if (leading != null && !canBuy) {
      leading = Opacity(opacity: 0.5, child: leading);
    }
    return ListTile(
      key: Key('userShop-${shop.id}'),
      dense: true,
      leading: leading,
      title: Text(shop.name),
      subtitle: Text.rich(
        TextSpan(
          children: [
            if (shop.cost != null) ...[
              CenterWidgetSpan(
                child: Item.iconBuilder(context: context, item: shop.cost!.item, width: 24),
              ),
              TextSpan(text: '×${shop.cost!.amount}  '),
            ],
            CenterWidgetSpan(child: CountDown(endedAt: shop.closedAt.sec2date())),
          ],
        ),
      ),
      titleTextStyle: textStyle,
      subtitleTextStyle: textStyle,
      leadingAndTrailingTextStyle: textStyle,
      statesController: WidgetStatesController(),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text.rich(
            TextSpan(
              text: [userShop?.num ?? 0, shop.limitNum == 0 ? '∞' : shop.limitNum].join('/'),
              children: [
                if (shop.purchaseType == PurchaseType.item && shop.targetIds.length == 1)
                  TextSpan(
                    text: '\n${S.current.item_own} ${mstData.getItemOrSvtNum(shop.targetIds.single).format()}',
                    style: canBuy ? Theme.of(context).textTheme.bodySmall : null,
                  ),
              ],
            ),
            textAlign: TextAlign.end,
          ),
          OutlinedButton(
            onPressed: canBuy ? () => buyShop(shop) : null,
            style: OutlinedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text('BUY'),
          ),
        ],
      ),
      onTap: () => shop.routeTo(region: runtime.region),
    );
  }

  Future<void> buyShop(NiceShop shop) async {
    final now = DateTime.now().timestamp;
    if (shop.openedAt > now || shop.closedAt <= now) {
      EasyLoading.showError('Shop not open');
      return;
    }
    for (final release in shop.releaseConditions) {
      if (!isReleaseOpen(release)) {
        EasyLoading.showError('Release condition failed: ${release.condType.name} ${release.closedMessage}');
        return;
      }
    }
    List<int> maxBuyCounts = [];
    if (shop.cost != null && shop.cost!.amount > 0) {
      maxBuyCounts.add(mstData.getItemOrSvtNum(shop.cost!.itemId) ~/ shop.cost!.amount);
    }
    for (final consume in shop.consumes) {
      if (consume.num == 0) continue;
      switch (consume.type) {
        case CommonConsumeType.item:
          maxBuyCounts.add(mstData.getItemOrSvtNum(consume.objectId) ~/ consume.num);
        case CommonConsumeType.ap:
          maxBuyCounts.add((mstData.user?.calCurAp() ?? 0) ~/ consume.num);
      }
    }
    if (maxBuyCounts.isEmpty) {
      EasyLoading.showError('Consume item not found');
      return;
    }
    final userShop = mstData.userShop[shop.id];
    if (shop.limitNum > 0) {
      maxBuyCounts.add(shop.limitNum - (userShop?.num ?? 0));
    }
    int maxBuyCount = Maths.min(maxBuyCounts);
    if (maxBuyCount <= 0) {
      EasyLoading.showError('Not enough item');
      return;
    }
    if (shop.purchaseType == PurchaseType.item &&
        shop.targetIds.isNotEmpty &&
        shop.targetIds.first == Items.stormPodId) {
      const int kStormPodMaxOwnCount = 9;
      int maxStormPodBuyCount = kStormPodMaxOwnCount - mstData.getItemOrSvtNum(Items.stormPodId);
      if (maxStormPodBuyCount <= 0) {
        EasyLoading.showError('StormPod full');
        return;
      }
      maxBuyCount = min(maxBuyCount, maxStormPodBuyCount);
    }

    if (!mounted) return;
    final int? buyCount = await _BuyCountDialog(
      runtime: runtime,
      shop: shop,
      maxCount: maxBuyCount,
    ).showDialog(context);
    if (buyCount == null || buyCount <= 0 || buyCount > maxBuyCount) return;
    await runtime.runTask(() => runtime.agent.shopPurchase(id: shop.id, num: buyCount));
  }

  bool isSoldOut(NiceShop shop) {
    return shop.limitNum != 0 && (mstData.userShop[shop.id]?.num ?? 0) >= shop.limitNum;
  }

  bool isShopReleased(NiceShop shop) {
    return shop.releaseConditions.every(isReleaseOpen);
  }

  bool isReleaseOpen(ShopRelease release) {
    final List<int> condValues = release.condValues;
    final int condValue = release.condValues.firstOrNull ?? 0;
    final int condNum = release.condNum;
    switch (release.condType) {
      case CondType.svtGet:
        return mstData.userSvtCollection[condValue]?.status == 2;
      case CondType.notSvtHaving:
        return mstData.userSvt.followedBy(mstData.userSvtStorage).every((e) => e.svtId != condValue);
      case CondType.svtHaving:
        return mstData.userSvt.followedBy(mstData.userSvtStorage).any((e) => e.svtId == condValue);
      case CondType.questClear:
        return (mstData.userQuest[condValue]?.clearNum ?? 0) > 0;
      case CondType.questNotClear:
        return (mstData.userQuest[condValue]?.clearNum ?? 0) == 0;
      case CondType.questNotClearAnd:
        if (condValues.isEmpty) return false;
        for (final questId in condValues) {
          if ((mstData.userQuest[questId]?.clearNum ?? 0) > 0) {
            return false;
          }
        }
        return true;
      case CondType.questClearPhase:
        final userQuest = mstData.userQuest[condValue];
        return userQuest != null && userQuest.questPhase >= condNum;
      case CondType.notShopPurchase:
        for (final shopId in condValues) {
          if ((mstData.userShop[shopId]?.num ?? 0) == 0) return true;
        }
        return false;
      case CondType.purchaseShop:
        int num2 = 0;
        for (final shopId in condValues) {
          num2 += (mstData.userShop[shopId]?.num ?? 0);
        }
        return condNum > 0 && num2 == condNum;
      case CondType.date:
        return DateTime.now().timestamp > condNum;
      case CondType.eventMissionAchieve:
        return mstData.userEventMission[condValue]?.missionProgressType == MissionProgressType.achieve.value;
      case CondType.notEquipGet:
        return mstData.userEquip.every((e) => e.equipId != condValue);
      case CondType.equipGet:
        return mstData.userEquip.any((e) => e.equipId == condValue);
      // case CondType.questGroupClear:
      // case CondType.eventPoint:
      // case CondType.itemGet:
      // case CondType.notSvtCostumeReleased:
      // case CondType.shopGroupLimitNum:
      // case CondType.commonRelease:
      // case CondType.purchaseQpShop:
      // case CondType.shopReleased:
      case CondType.forceFalse:
        return false;
      default:
      //
    }

    return true;
  }
}

class _BuyCountDialog extends StatefulWidget {
  final FakerRuntime runtime;
  final NiceShop shop;
  final int maxCount;
  const _BuyCountDialog({required this.runtime, required this.shop, required this.maxCount});

  @override
  State<_BuyCountDialog> createState() => __BuyCountDialogState();
}

class __BuyCountDialogState extends State<_BuyCountDialog> {
  late final mstData = widget.runtime.mstData;
  int buyCount = 1;

  @override
  Widget build(BuildContext context) {
    final consumes = widget.shop.getConsumeItems();
    return AlertDialog(
      title: Text(widget.shop.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Buy Count'),
            trailing: Text('$buyCount/${widget.maxCount}'),
          ),
          ...consumes.keys.map((itemId) {
            final int ownNum = mstData.getItemOrSvtNum(itemId), consumeNum = consumes[itemId]! * buyCount;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Item.iconBuilder(context: context, item: null, itemId: itemId),
              title: Text('$ownNum - $consumeNum = ${ownNum - consumeNum}'),
            );
          }),
          Slider(
            value: buyCount.toDouble(),
            onChanged: (v) {
              setState(() {
                buyCount = v.round().clamp(1, widget.maxCount);
              });
            },
            min: 1.0,
            max: widget.maxCount.toDouble(),
            divisions: widget.maxCount > 1 ? widget.maxCount - 1 : null,
            label: buyCount.toString(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, buyCount);
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}
