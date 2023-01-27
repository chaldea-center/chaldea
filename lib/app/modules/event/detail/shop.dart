import 'package:flutter/services.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../shop/shop.dart';

class EventShopsPage extends StatefulWidget {
  final Event? event;
  final List<NiceShop> shops;
  final bool showTime;

  const EventShopsPage({
    super.key,
    required this.event,
    required this.shops,
    this.showTime = false,
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
    plan = event == null
        ? LimitEventPlan()
        : db.curUser.limitEventPlanOf(event!.id);
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
        if (payItems.length > 2 || payItems.values.every((e) => e.length > 1)) {
          final itemIds = payItems.keys.toList();
          itemIds.sort2((e) => db.gameData.items[e]?.priority ?? 999999);
          for (final itemId in itemIds) {
            views.add(shopList(context, payItems[itemId]!, plan));
            if (itemId == -1) {
              headers.add(
                  Tab(child: Text(S.current.general_others, style: style)));
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
              if (views.length > 1)
                FixedHeight.tabBar(TabBar(tabs: headers, isScrollable: true)),
              Expanded(
                child: views.length == 1
                    ? views.single
                    : TabBarView(children: views),
              ),
              kDefaultDivider,
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: getEventItemCost(),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget shopList(
      BuildContext context, List<NiceShop> shops, LimitEventPlan plan) {
    return ListView.separated(
      itemBuilder: (context, index) =>
          shopItemBuilder(context, shops[index], plan),
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemCount: shops.length,
    );
  }

  Widget shopItemBuilder(
      BuildContext context, NiceShop shop, LimitEventPlan plan) {
    final rewards =
        ShopHelper.purchases(context, shop, showSpecialName: true).toList();
    Widget? leading;
    Widget title;
    if (rewards.length == 1) {
      leading = rewards.first.item1;
      title = Text.rich(rewards.first.item2, textScaleFactor: 0.8);
    } else {
      List<InlineSpan> spans = [];
      for (int index = 0; index < rewards.length; index++) {
        final reward = rewards[index];
        if (reward.item1 != null) {
          spans.add(CenterWidgetSpan(
              child: SizedBox(height: 28, child: reward.item1)));
        }
        spans.add(reward.item2);
        if (index != rewards.length - 1) spans.add(const TextSpan(text: ' / '));
      }
      title = Text.rich(TextSpan(children: spans), textScaleFactor: 0.8);
    }
    if (shop.image != null) {
      leading ??= db.getIconImage(shop.image, aspectRatio: 1);
    }
    if (leading != null) {
      leading = SizedBox(width: 40, child: leading);
    }

    List<InlineSpan> costs = ShopHelper.cost(context, shop);

    final planCount = plan.shopBuyCount[shop.id] ?? shop.limitNum;
    final limitCount = shop.limitNum == 0 ? '∞' : shop.limitNum.format();
    Widget trailing = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () {
            if (shop.limitNum == 0) {
              plan.shopBuyCount.remove(shop.id);
            } else {
              if (planCount == 0) {
                plan.shopBuyCount[shop.id] = shop.limitNum;
              } else if (planCount == shop.limitNum) {
                plan.shopBuyCount[shop.id] = 0;
              } else {
                plan.shopBuyCount.remove(shop.id);
              }
            }
            event?.updateStat();
            setState(() {});
          },
          style: OutlinedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
          ),
          child: Text(
            '${planCount.format()}/$limitCount',
            style: planCount == shop.limitNum
                ? null
                : TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        IconButton(
          onPressed: () {
            // show edit dialog
            showDialog(
              context: context,
              builder: (context) {
                return _EditShopNumDialog(
                  title: title,
                  initValue: plan.shopBuyCount[shop.id],
                  limitNum: shop.limitNum,
                  onChanged: (v) {
                    if (v == null || v == shop.limitNum) {
                      plan.shopBuyCount.remove(shop.id);
                    } else {
                      plan.shopBuyCount[shop.id] = v;
                    }
                    event?.updateStat();
                    setState(() {});
                  },
                );
              },
            );
          },
          icon: const Icon(Icons.edit, size: 16),
          padding: const EdgeInsets.all(6),
        )
      ],
    );

    return ListTile(
      key: Key('shop_${shop.id}'),
      leading: leading,
      title: title,
      subtitle: Text.rich(
        TextSpan(text: '${S.current.cost}:  ', children: [
          ...costs,
          if (widget.showTime)
            TextSpan(
                text: '\n${shop.openedAt.sec2date().toDateString()}'
                    ' ~ ${shop.closedAt.sec2date().toDateString()}')
        ]),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      onTap: shop.routeTo,
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
        IconButton(
          onPressed: () {
            plan.shopBuyCount.clear();
            event?.updateStat();
            setState(() {});
          },
          icon: const Icon(Icons.replay),
          tooltip: S.current.reset,
        )
      ],
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
    bool invalid = buyCount != null &&
        (buyCount! < 0 || (widget.limitNum > 0 && buyCount! > widget.limitNum));
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
