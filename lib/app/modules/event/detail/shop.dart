import 'package:flutter/services.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/free_quest_calc/event_item_calc_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../shop/shop.dart';

class EventShopsPage extends StatefulWidget {
  final Event? event;
  final List<NiceShop> shops;
  final bool showTime;
  final Region? region;

  const EventShopsPage({
    super.key,
    required this.event,
    required this.shops,
    this.showTime = false,
    this.region,
  });

  @override
  State<EventShopsPage> createState() => _EventShopsPageState();
}

class _EventShopsPageState extends State<EventShopsPage> {
  Event? get event => widget.event;
  late final LimitEventPlan plan;

  @override
  void initState() {
    super.initState();
    plan = event == null ? LimitEventPlan() : db.curUser.limitEventPlanOf(event!.id);
  }

  @override
  Widget build(BuildContext context) {
    final shops = widget.shops.toList();
    Map<int, List<NiceShop>> payItems = {};
    for (final shop in shops) {
      payItems.putIfAbsent(shop.cost?.itemId ?? -1, () => []).add(shop);
    }

    return db.onUserData(
      (context, snapshot) {
        List<Widget> headers = [], views = [];
        final style = Theme.of(context).textTheme.bodyMedium;
        headers.add(Tab(child: Text(S.current.general_all, style: style)));
        views.add(shopList(context, shops, plan));
        // valentine shop
        if (payItems.length > 1 && (payItems.length > 2 || payItems.values.every((e) => e.length > 1))) {
          final itemIds = payItems.keys.toList();
          itemIds.sort2((e) => db.gameData.items[e]?.priority ?? 999999);
          for (final itemId in itemIds) {
            views.add(shopList(context, payItems[itemId]!, plan));
            if (itemId == -1) {
              headers.add(Tab(child: Text(S.current.general_others, style: style)));
            } else {
              headers.add(Tab(
                child: Text.rich(
                  TextSpan(children: [
                    CenterWidgetSpan(
                      child: Item.iconBuilder(
                        context: context,
                        item: null,
                        itemId: itemId,
                        width: 18,
                        icon: db.gameData.items[itemId]?.icon,
                        jumpToDetail: false,
                      ),
                    ),
                    TextSpan(text: Item.getName(itemId)),
                  ]),
                  style: style,
                ),
              ));
            }
          }
        }
        return DefaultTabController(
          length: views.length,
          child: Column(
            children: [
              if (views.length > 1) FixedHeight.tabBar(TabBar(tabs: headers, isScrollable: true)),
              Expanded(
                child: views.length == 1 ? views.single : TabBarView(children: views),
              ),
              kDefaultDivider,
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: getEventItemCost(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget shopList(BuildContext context, List<NiceShop> shops, LimitEventPlan plan) {
    return ListView.separated(
      itemBuilder: (context, index) => shopItemBuilder(context, shops[index], plan),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: shops.length,
    );
  }

  Widget shopItemBuilder(BuildContext context, NiceShop shop, LimitEventPlan plan) {
    return ShopDescriptor(
      key: Key('shop_${shop.id}'),
      shop: shop,
      region: widget.region,
      showTime: widget.showTime,
      buyCount: plan.shopBuyCount[shop.id] ?? shop.limitNum,
      onChanged: (v) {
        if (v == null) {
          plan.shopBuyCount.remove(shop.id);
        } else {
          plan.shopBuyCount[shop.id] = v;
        }
        event?.updateStat();
        setState(() {});
      },
    );
  }

  Widget getEventItemCost() {
    Map<int, int> items = {};
    for (final shop in widget.shops) {
      final count = plan.shopBuyCount[shop.id] ?? shop.limitNum;
      if (shop.cost != null) {
        items.addNum(shop.cost!.itemId, shop.cost!.amount * count);
      }
      for (final consume in shop.consumes) {
        if (consume.type == CommonConsumeType.item) {
          items.addNum(consume.objectId, consume.num);
        }
      }
    }
    items.removeWhere((key, value) => value <= 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${S.current.cost}: '),
        Expanded(
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final entry in items.entries)
                  if (entry.value != 0)
                    Item.iconBuilder(
                      context: context,
                      item: null,
                      itemId: entry.key,
                      text: entry.value.format(),
                      width: 36,
                    ),
              ],
            ),
          ),
        ),
        if (event != null && event!.warIds.isNotEmpty)
          IconButton(
            onPressed: () {
              router.pushPage(EventItemCalcPage(
                warId: event!.warIds.first,
                objectiveCounts: items,
              ));
            },
            icon: const Icon(Icons.calculate),
            tooltip: S.current.drop_calc_solve,
          ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return SimpleCancelOkDialog(
                  title: Text(S.current.cost),
                  scrollable: true,
                  hideCancel: true,
                  content: SharedBuilder.itemGrid(context: context, items: items.entries),
                );
              },
            );
          },
          icon: const Icon(Icons.open_in_full_rounded),
        ),
        PopupMenuButton(
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.reset),
                  onTapOk: () {
                    plan.shopBuyCount.clear();
                    event?.updateStat();
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
              child: Text(S.current.reset),
            ),
            PopupMenuItem(
              enabled: db.runtimeData.clipBoard.userShops != null,
              onTap: () {
                final userShops = db.runtimeData.clipBoard.userShops?.toList() ?? [];
                final buyCounts = {for (final shop in userShops) shop.shopId: shop.num};
                for (final shop in widget.shops) {
                  final buyCount = buyCounts[shop.id] ?? 0;
                  if (buyCount > 0 && shop.limitNum > 0 && buyCount <= shop.limitNum) {
                    plan.shopBuyCount[shop.id] = shop.limitNum - buyCount;
                  }
                }
                if (mounted) setState(() {});
              },
              child: const Text("Read Login Data"),
            )
          ],
        )
      ],
    );
  }
}

class ShopDescriptor extends StatelessWidget {
  final NiceShop shop;
  final bool showTime;
  final int? buyCount;
  final ValueChanged<int?>? onChanged;
  final Region? region;

  const ShopDescriptor(
      {super.key, required this.shop, this.showTime = false, this.buyCount, this.onChanged, this.region});

  @override
  Widget build(BuildContext context) {
    final rewards = ShopHelper.purchases(context, shop, showSpecialName: true).toList();
    Widget? leading;
    Widget title;
    if (rewards.length == 1) {
      leading = rewards.first.item1;
      title = Text.rich(rewards.first.item2, textScaler: const TextScaler.linear(0.8));
    } else {
      List<InlineSpan> spans = [];
      for (int index = 0; index < rewards.length; index++) {
        final reward = rewards[index];
        if (reward.item1 != null) {
          spans.add(CenterWidgetSpan(child: SizedBox(height: 28, child: reward.item1)));
        }
        spans.add(reward.item2);
        if (index != rewards.length - 1) spans.add(const TextSpan(text: ' / '));
      }
      title = Text.rich(TextSpan(children: spans), textScaler: const TextScaler.linear(0.8));
    }
    if (shop.image != null) {
      leading ??= db.getIconImage(shop.image, aspectRatio: 1);
    }
    if (leading != null) {
      leading = SizedBox(width: 40, child: leading);
    }

    List<InlineSpan> costs = ShopHelper.cost(context, shop);

    Widget? trailing;
    final planCount = buyCount ?? shop.limitNum;
    final limitCount = shop.limitNum == 0 ? '∞' : shop.limitNum.format();
    trailing = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () {
            if (onChanged == null) return;
            if (shop.limitNum == 0) {
              onChanged!(null);
            } else {
              if (planCount == 0) {
                onChanged!(shop.limitNum);
              } else if (planCount == shop.limitNum) {
                onChanged!(0);
              } else {
                onChanged!(null);
              }
            }
          },
          style: OutlinedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(12),
            minimumSize: const Size(64, 42),
          ),
          child: Text(
            onChanged != null ? '${planCount.format()}/$limitCount' : limitCount.toString(),
            style: planCount == 0 ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
          ),
        ),
        if (onChanged != null)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return _EditShopNumDialog(
                    title: title,
                    initValue: buyCount,
                    limitNum: shop.limitNum,
                    onChanged: (v) {
                      if (onChanged == null) return;
                      if (v == null || v == shop.limitNum) {
                        onChanged!(null);
                      } else {
                        onChanged!(v);
                      }
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            padding: const EdgeInsets.all(6),
          )
        else
          const SizedBox(width: 16),
      ],
    );

    return ListTile(
      leading: leading,
      title: title,
      subtitle: Text.rich(
        TextSpan(text: '${S.current.cost}:  ', children: [
          ...costs,
          if (showTime)
            TextSpan(
                text: '\n${shop.openedAt.sec2date().toDateString()}'
                    ' ~ ${shop.closedAt.sec2date().toDateString()}')
        ]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      onTap: () {
        shop.routeTo(region: region);
      },
    );
  }
}

class _EditShopNumDialog extends StatefulWidget {
  final Widget? title;
  final int? initValue;
  final int limitNum;
  final ValueChanged<int?> onChanged;

  const _EditShopNumDialog({
    required this.title,
    required this.initValue,
    required this.limitNum,
    required this.onChanged,
  });

  @override
  State<_EditShopNumDialog> createState() => __EditShopNumDialogState();
}

class __EditShopNumDialogState extends State<_EditShopNumDialog> {
  int? buyCount;
  @override
  void initState() {
    super.initState();
    buyCount = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    bool invalid = buyCount != null && (buyCount! < 0 || (widget.limitNum > 0 && buyCount! > widget.limitNum));
    final limitText = widget.limitNum == 0 ? 'Max ∞' : 'Max ${widget.limitNum}';
    return AlertDialog(
      title: widget.title,
      content: SizedBox(
        width: 240,
        child: TextFormField(
          initialValue: widget.initValue?.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.limitNum.toString(),
            helperText: invalid ? null : limitText,
            errorText: invalid ? limitText : null,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (s) {
            if (s.isEmpty) {
              buyCount = null;
            } else {
              int? v = int.tryParse(s);
              if (v != null) buyCount = v;
            }
            setState(() {});
          },
          onFieldSubmitted: (s) {
            Navigator.pop(context);
            widget.onChanged(buyCount);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: invalid
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onChanged(buyCount);
                },
          child: Text(S.current.confirm.toUpperCase()),
        ),
      ],
    );
  }
}
