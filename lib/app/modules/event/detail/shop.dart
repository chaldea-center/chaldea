import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventShopsPage extends StatefulWidget {
  final Event event;
  final int slot;
  const EventShopsPage({Key? key, required this.event, required this.slot})
      : super(key: key);

  @override
  State<EventShopsPage> createState() => _EventShopsPageState();
}

class _EventShopsPageState extends State<EventShopsPage> {
  Event get event => widget.event;

  @override
  Widget build(BuildContext context) {
    final plan = db.curUser.limitEventPlanOf(event.id);
    final shops = event.shop.where((e) => e.slot == widget.slot).toList();
    shops.sort2((e) => e.priority);

    return db.onUserData(
      (context, snapshot) => Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) =>
                  shopItemBuilder(context, shops[index], plan),
              separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
              itemCount: shops.length,
            ),
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
  }

  Widget shopItemBuilder(
      BuildContext context, NiceShop shop, LimitEventPlan plan) {
    Widget? leading;
    String? title;
    Widget? titleWidget;
    int? targetId = shop.targetIds.getOrNull(0);

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
        textScaleFactor: 0.9,
      );
    } else if (targetId != null) {
      leading = _iconBuilder(context, shop.purchaseType, targetId, 42);
      title = _getItemName(shop.purchaseType, targetId, null);
      title ??= shop.name;
      if (shop.setNum != 1) {
        title += ' x${shop.setNum}';
      }
    }
    if (title != null) {
      titleWidget ??= Text(title, textScaleFactor: 0.9);
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
            event.updateStat();
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
                : TextStyle(color: Theme.of(context).errorColor),
          ),
        ),
        IconButton(
          onPressed: () {
            // show edit dialog
            showDialog(
              context: context,
              builder: (context) {
                return _EditShopNumDialog(
                  title: titleWidget,
                  initValue: plan.shopBuyCount[shop.id],
                  limitNum: shop.limitNum,
                  onChanged: (v) {
                    if (v == null || v == shop.limitNum) {
                      plan.shopBuyCount.remove(shop.id);
                    } else {
                      plan.shopBuyCount[shop.id] = v;
                    }
                    event.updateStat();
                  },
                );
              },
            );
            TextFormField();
          },
          icon: const Icon(Icons.edit, size: 16),
          padding: const EdgeInsets.all(6),
        )
      ],
    );

    return ListTile(
      key: Key('event_shop_${shop.id}'),
      leading: leading,
      title: titleWidget,
      subtitle: subtitle,
      trailing: trailing,
      contentPadding: const EdgeInsetsDirectional.only(start: 16),
      onTap: () => showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => showConditions(context, shop, titleWidget),
      ),
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
          onDefault: () {
            if (purchaseType == PurchaseType.costumeRelease) {
              return db.getIconImage(Atlas.assetItem(23),
                  width: width, height: width);
            }
            return null;
          },
        );
    }
  }

  Widget showConditions(BuildContext context, NiceShop shop, Widget? title) {
    return SimpleCancelOkDialog(
      title: title,
      scrollable: true,
      hideCancel: true,
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 20.0, 24.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SHeader('Original Name'),
          ListTile(
            dense: true,
            title: Text(shop.name),
          ),
          if (shop.releaseConditions.isNotEmpty)
            SHeader(S.current.open_condition),
          ...List.generate(
            shop.releaseConditions.length,
            (index) {
              final release = shop.releaseConditions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CondTargetNumDescriptor(
                      condType: release.condType,
                      targetNum: release.condNum,
                      targetIds: release.condValues,
                      textScaleFactor: 0.85,
                      leading: const TextSpan(text: ' ꔷ '),
                    ),
                    if (release.closedMessage.isNotEmpty)
                      Text(
                        release.closedMessage,
                        textScaleFactor: 0.75,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getEventItemCost() {
    final plan = db.curUser.limitEventPlanOf(event.id);
    Map<int, int> items = {};
    for (final shop in event.shop) {
      final count = plan.shopBuyCount[shop.id] ?? shop.limitNum;
      items.addNum(shop.cost.itemId, shop.cost.amount * count);
    }
    items.removeWhere((key, value) => value <= 0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Cost: '),
        Expanded(
          child: SharedBuilder.itemGrid(
            context: context,
            items: items.entries,
            width: 36,
          ),
        ),
        IconButton(
          onPressed: () {
            plan.shopBuyCount.clear();
            event.updateStat();
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
