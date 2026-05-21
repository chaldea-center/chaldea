import 'dart:math' show min;

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/shop/filter.dart';
import 'package:chaldea/app/modules/shop/shop.dart';
import 'package:chaldea/app/modules/timer/base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../runtime.dart';

enum _UserShopStatus { normal, unreleased, soldOut }

class UserShopsPage extends StatefulWidget {
  final FakerRuntime runtime;
  final String title;
  final List<NiceShop> shops;
  final Event? event;
  const UserShopsPage({super.key, required this.runtime, required this.title, required this.shops, this.event});

  @override
  State<UserShopsPage> createState() => _UserShopsPageState();
}

class _UserShopsPageState extends State<UserShopsPage>
    with SingleTickerProviderStateMixin, FakerRuntimeStateMixin, SearchableListState<NiceShop, UserShopsPage> {
  @override
  late final runtime = widget.runtime;
  late final shops = widget.shops.toList();
  @override
  Iterable<NiceShop> get wholeData => shops;

  final filterData = ShopFilterData();
  final Set<int> consumeItemIds = {};
  final shownConsumeItem = FilterRadioData<int>();
  final shopStatus = FilterGroupData<_UserShopStatus>();

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) {
        final aa = filterData.reversed ? b : a, bb = filterData.reversed ? a : b;
        return ListX.compareByList<NiceShop, int>(aa, bb, (e) {
          switch (filterData.sortType) {
            case ShopSort.priority:
              return [isSoldOut(e) ? 1 : 0, isShopReleased(e) ? 0 : 1, e.priority, -e.openedAt];
            case ShopSort.openTime:
              return [isSoldOut(e) ? 1 : 0, isShopReleased(e) ? 0 : 1, -e.openedAt, e.priority];
          }
        });
      },
    );

    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(widget.title),
        bottom: showSearchBar ? searchBar : null,
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
          searchIcon,
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () {
              final purchaseTypes = <PurchaseType>{
                for (final shop in shops) ...[shop.purchaseType, ...shop.itemSet.map((e) => e.purchaseType)],
              };
              FilterPage.show(
                context: context,
                builder: (context) => ShopFilter(
                  filterData: filterData,
                  onChanged: (_) {
                    if (mounted) setState(() {});
                  },
                  purchaseTypes: purchaseTypes.toList(),
                  extraFilters: (context, update) {
                    return [
                      FilterGroup<_UserShopStatus>(
                        title: Text('User Shop Status'),
                        options: _UserShopStatus.values,
                        values: shopStatus,
                        optionBuilder: (v) => Text(v.name),
                        onFilterChanged: (value, _) {
                          update();
                          if (mounted) setState(() {});
                        },
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget gridItemBuilder(NiceShop shop) => throw UnimplementedError();

  @override
  Widget listItemBuilder(NiceShop shop) {
    final reward = ShopHelper.purchases(context, shop, showSpecialName: true).firstOrNull;
    final userShop = mstData.userShop[shop.id];
    final _soldOut = isSoldOut(shop), _released = isShopReleased(shop);
    final bool canBuy = !_soldOut && _released;
    final TextStyle? textStyle = canBuy
        ? null
        : _soldOut
        ? TextStyle(color: Theme.of(context).hintColor)
        : TextStyle(color: Theme.of(context).disabledColor);
    Widget? leading = reward?.$1;
    if (leading != null && !canBuy) {
      leading = Opacity(opacity: 0.5, child: leading);
    }

    final coinText = getCoinSvtInfo(shop);
    return ListTile(
      key: Key('userShop-${shop.id}'),
      dense: true,
      leading: leading == null ? null : ConstrainedBox(constraints: BoxConstraints(maxWidth: 36), child: leading),
      title: Text.rich(
        TextSpan(
          text: shop.lName,
          children: [if (coinText != null) TextSpan(text: '\n$coinText')],
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            if (shop.cost != null) ...[
              CenterWidgetSpan(
                child: Opacity(
                  opacity: canBuy ? 1 : 0.5,
                  child: Item.iconBuilder(context: context, item: shop.cost!.item, width: 24),
                ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                text: [
                  if (userShop != null && userShop.resetNum > 0) '[${userShop.resetNum}]',
                  userShop?.num ?? 0,
                  '/',
                  shop.limitNum == 0 ? '∞' : shop.limitNum,
                ].join(''),
                children: [
                  if (shop.purchaseType == PurchaseType.item && shop.targetIds.length == 1)
                    TextSpan(
                      text: [
                        '\n${S.current.item_own} ${mstData.getItemOrSvtNum(shop.targetIds.single).format()}',
                        if (mstData.isCurPlanUser)
                          '${S.current.item_left} ${(db.itemCenter.itemLeft[shop.targetIds.single] ?? 0).format()}',
                      ].join('\n'),
                      style: canBuy ? Theme.of(context).textTheme.bodySmall : null,
                    ),
                ],
              ),
              textAlign: TextAlign.end,
            ),
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

  String? getCoinSvtInfo(NiceShop shop) {
    if (shop.purchaseType != .item) return null;
    final item = db.gameData.items[shop.targetIds.firstOrNull];
    if (item == null || item.type != .svtCoin) return null;
    final svtId = item.value;
    int lv = mstData.userSvtCollection[svtId]?.maxLv ?? 0;
    List<int> appendLvs = [];
    for (final userSvt in mstData.userSvtAndStorage) {
      if (userSvt.svtId == svtId) {
        List<int> _appendLvs = mstData.getSvtAppendSkillLvs(userSvt);
        if (Maths.sum(_appendLvs) > Maths.sum(appendLvs)) {
          appendLvs = _appendLvs;
        }
      }
    }

    return 'Lv$lv  ${appendLvs.map((e) => e == 0 ? "-" : e).join('/')}';
  }

  @override
  PreferredSizeWidget? get buttonBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
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
    final now = DateTime.now().timestamp;
    return shop.openedAt <= now && shop.closedAt > now && shop.releaseConditions.every(isReleaseOpen);
  }

  bool isReleaseOpen(ShopRelease release) {
    return runtime.condCheck.isCondOpen2(release.condType, release.condValues, release.condNum) ?? true;
  }

  @override
  Iterable<String?> getSummary(NiceShop shop) sync* {
    Set<String> names = {shop.name};
    if (shop.purchaseType == PurchaseType.equip) {
      for (final targetId in shop.targetIds) {
        final equip = db.gameData.mysticCodes[targetId];
        if (equip != null) {
          names.add(equip.name);
          names.add(equip.lName.l);
        }
      }
    } else if (shop.purchaseType == PurchaseType.costumeRelease) {
      for (final targetId in shop.targetIds) {
        final costume = db.gameData.servantsById[targetId ~/ 100]?.costume.values.firstWhereOrNull(
          (e) => e.costumeCollectionNo == targetId % 100,
        );
        if (costume != null) {
          names.add(costume.name);
          names.add(costume.lName.l);
        }
      }
    } else {
      for (final targetId in shop.getItemAndCardIds()) {
        final lName =
            db.gameData.entities[targetId]?.lName ??
            db.gameData.commandCodesById[targetId]?.lName ??
            db.gameData.items[targetId]?.lName;
        if (lName != null) {
          names.add(lName.key);
          names.add(lName.l);
        }
      }
    }

    yield* names;
    yield shop.detail;
  }

  @override
  bool filter(NiceShop shop) {
    if (!filterData.filter(shop)) return false;

    if (shownConsumeItem.options.isNotEmpty) {
      if (shownConsumeItem.options.intersection(shop.getConsumeItems().keys.toSet()).isEmpty) {
        return false;
      }
    }

    if (shopStatus.isNotEmpty) {
      final status = [
        if (isSoldOut(shop)) _UserShopStatus.soldOut,
        if (!isShopReleased(shop)) _UserShopStatus.unreleased,
      ];
      if (status.isEmpty) status.add(_UserShopStatus.normal);
      if (!shopStatus.matchAny(status)) {
        return false;
      }
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
      title: Text(widget.shop.lName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Buy Count'),
            trailing: TextButton(
              child: Text('$buyCount/${widget.maxCount}'),
              onPressed: () {
                InputCancelOkDialog.number(
                  title: 'Buy Count',
                  initValue: buyCount,
                  helperText: '${widget.maxCount}',
                  validate: (v) => v > 0 && v <= widget.maxCount,
                  onSubmit: (value) {
                    if (mounted) {
                      setState(() {
                        buyCount = value;
                      });
                    }
                  },
                ).showDialog(context);
              },
            ),
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
