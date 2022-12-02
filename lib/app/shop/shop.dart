import 'dart:async';

import 'package:tuple/tuple.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../descriptors/multi_entry.dart';

class ShopDetailPage extends StatefulWidget {
  final int? id;
  final NiceShop? shop;
  final Region? region;
  const ShopDetailPage({super.key, this.id, this.shop, this.region})
      : assert(id != null || shop != null);

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage>
    with RegionBasedState<NiceShop, ShopDetailPage> {
  int get id => widget.shop?.id ?? widget.id ?? data?.id ?? -1;
  NiceShop get shop => data!;

  @override
  void initState() {
    super.initState();
    region = widget.region ?? (widget.shop == null ? Region.jp : null);
    doFetchData();
  }

  @override
  Future<NiceShop?> fetchData(Region? r) async {
    NiceShop? v;
    if (r == null || r == widget.region) v = widget.shop;
    if (r == Region.jp) {
      v ??= db.gameData.shops[id];
    }
    v ??= await AtlasApi.shop(id, region: r ?? Region.jp);
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return InheritSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            data?.name ?? '${S.current.event_shop} $id',
            overflow: TextOverflow.fade,
          ),
          actions: [
            dropdownRegion(shownNone: widget.shop != null),
            popupMenu,
          ],
        ),
        body: buildBody(context),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, NiceShop shop) {
    return ListView(
      children: [
        CustomTable(children: [
          CustomTableRow.fromTexts(texts: ['No.${shop.id}'], isHeader: true),
          CustomTableRow.fromChildren(children: [
            Text.rich(TextSpan(children: [
              if (shop.image != null)
                CenterWidgetSpan(child: db.getIconImage(shop.image, width: 32)),
              TextSpan(text: shop.name)
            ]))
          ]),
          CustomTableRow.fromTexts(texts: [shop.detail]),
          CustomTableRow.fromTexts(
              texts: [S.current.opening_time], isHeader: true),
          CustomTableRow.fromTexts(texts: [
            [
              shop.openedAt.sec2date().toStringShort(omitSec: true),
              shop.closedAt.sec2date().toStringShort(omitSec: true),
            ].join(' ~ ')
          ]),
          CustomTableRow.fromTexts(texts: [S.current.cost], isHeader: true),
          CustomTableRow.fromChildren(children: [
            Text.rich(TextSpan(
                children: ShopHelper.cost(context, shop, iconSize: 36)))
          ]),
          CustomTableRow.fromTexts(
              texts: [S.current.game_rewards], isHeader: true),
          CustomTableRow(children: [
            TableCellData(
              child: getRewards(context),
              alignment: AlignmentDirectional.centerStart,
            )
          ]),
          if (shop.script != null && shop.scriptId != null) ...[
            CustomTableRow.fromTexts(
                texts: [S.current.script_story], isHeader: true),
            TextButton(
              onPressed: () {
                ScriptLink(scriptId: shop.scriptId!, script: shop.script!)
                    .routeTo(region: region);
              },
              style: kTextButtonDenseStyle,
              child: Text(shop.scriptName ?? shop.scriptId!),
            )
          ],
          if (shop.releaseConditions.isNotEmpty) ...[
            CustomTableRow.fromTexts(
                texts: [S.current.open_condition], isHeader: true),
            CustomTableRow(children: [
              TableCellData(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final cond in shop.releaseConditions) ...[
                      CondTargetNumDescriptor(
                        condType: cond.condType,
                        targetNum: cond.condNum,
                        targetIds: cond.condValues,
                        leading: const TextSpan(text: kULLeading),
                      ),
                      if (cond.closedMessage.isNotEmpty)
                        Text(
                          cond.closedMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        )
                    ]
                  ],
                ),
                alignment: AlignmentDirectional.centerStart,
              ),
            ]),
            if (shop.warningMessage.isNotEmpty) ...[
              CustomTableRow.fromTexts(
                  texts: [S.current.warning], isHeader: true),
              CustomTableRow.fromTexts(
                  texts: [shop.warningMessage.replaceAll('{0}', shop.name)]),
            ],
          ]
        ]),
      ],
    );
  }

  Widget getRewards(BuildContext context) {
    final rewards = ShopHelper.purchases(context, shop);
    List<Widget> children = [];
    for (final reward in rewards) {
      children.add(Text.rich(TextSpan(text: kULLeading, children: [
        if (reward.item1 != null)
          CenterWidgetSpan(child: SizedBox(height: 42, child: reward.item1!)),
        reward.item2,
      ])));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget cardList(String header, List<GameCardMixin> cards) {
    return TileGroup(
      header: header,
      children: [
        for (final card in cards)
          ListTile(
            dense: true,
            leading: card.iconBuilder(context: context),
            title: Text(card.lName.l),
            onTap: card.routeTo,
          )
      ],
    );
  }

  Widget get popupMenu {
    return PopupMenuButton(
      itemBuilder: (context) => SharedBuilder.websitesPopupMenuItems(
          atlas: Atlas.dbSkill(id, region ?? Region.jp)),
    );
  }
}

class ShopHelper {
  const ShopHelper._();
  static List<InlineSpan> cost(BuildContext context, NiceShop shop,
      {double iconSize = 24}) {
    List<InlineSpan> children = [];
    if (shop.payType == PayType.free) {
      children.add(const TextSpan(text: 'FREE!'));
    }
    final cost = shop.cost;
    if (cost != null) {
      children.add(CenterWidgetSpan(
        child: Item.iconBuilder(
          context: context,
          item: null,
          itemId: cost.itemId,
          width: iconSize,
        ),
      ));
      children.add(TextSpan(text: '×${cost.amount.format()} '));
    }
    for (final consume in shop.consumes) {
      switch (consume.type) {
        case CommonConsumeType.item:
          children.add(CenterWidgetSpan(
            child: Item.iconBuilder(
              context: context,
              item: null,
              itemId: consume.objectId,
              width: iconSize,
            ),
          ));
          children.add(TextSpan(text: '×${consume.num.format()} '));
          break;
        case CommonConsumeType.ap:
          children.add(TextSpan(text: ' AP ${consume.num.format()} '));
          break;
      }
    }
    return children;
  }

  static Iterable<Tuple2<Widget?, InlineSpan>> purchases(
    BuildContext context,
    NiceShop shop, {
    bool showSpecialName = false,
  }) sync* {
    final shopName = TextSpan(
      text: '\n(${shop.name})',
      style: Theme.of(context).textTheme.bodySmall,
    );
    switch (shop.purchaseType) {
      case PurchaseType.quest:
        yield Tuple2(
          null,
          TextSpan(
            text: '${S.current.unlock_quest}:',
            children: [
              ...MultiDescriptor.quests(context, shop.targetIds),
              if (showSpecialName) shopName
            ],
          ),
        );
        return;
      case PurchaseType.kiaraPunisherReset:
        yield Tuple2(
          null,
          TextSpan(
            text: 'Reset Kiara Punishers: ',
            children: MultiDescriptor.shops(context, shop.targetIds),
          ),
        );
        return;
      case PurchaseType.setItem:
        for (final set in shop.itemSet) {
          final rewards = onePurchase(context, shop, set.purchaseType,
              set.targetId, set.setNum, set.gifts);
          if (shop.setNum == 1) {
            yield* rewards;
          } else {
            for (final reward in rewards) {
              yield Tuple2(
                reward.item1,
                TextSpan(children: [
                  reward.item2,
                  TextSpan(text: '(×${shop.setNum.format()})')
                ]),
              );
            }
          }
        }
        return;
      default:
        yield* onePurchase(context, shop, shop.purchaseType,
            shop.targetIds.getOrNull(0) ?? 0, shop.setNum, shop.gifts);
    }
  }

  static Iterable<Tuple2<Widget?, InlineSpan>> onePurchase(
    BuildContext context,
    NiceShop shop,
    PurchaseType purchaseType,
    int targetId,
    int targetNum,
    List<Gift> gifts, {
    bool showSpecialName = false,
  }) sync* {
    final shopName = TextSpan(
      text: '\n(${shop.name})',
      style: Theme.of(context).textTheme.bodySmall,
    );

    switch (purchaseType) {
      case PurchaseType.none:
        yield Tuple2(null, TextSpan(text: 'NONE $targetId'));
        return;
      case PurchaseType.item:
      case PurchaseType.itemAsPresent:
      case PurchaseType.servant:
      case PurchaseType.commandCode:
      case PurchaseType.costumeRelease:
        yield Tuple2(
          GameCardMixin.anyCardItemBuilder(context: context, id: targetId),
          TextSpan(
              text: GameCardMixin.anyCardItemName(targetId).l +
                  (targetNum == 1 ? "" : " ×${targetNum.format()}")),
        );
        return;
      case PurchaseType.equip:
        final equip = db.gameData.mysticCodes[targetId];
        yield Tuple2(
            equip?.iconBuilder(context: context),
            TextSpan(
                text: equip?.lName.l ?? '${S.current.mystic_code} $targetId'));
        return;
      case PurchaseType.friendGacha:
        yield Tuple2(
            Item.iconBuilder(context: context, item: Items.friendPoint),
            TextSpan(text: Transl.itemNames('フレンドポイント').l));
        return;
      case PurchaseType.setItem:
        assert(false, 'Should not reach here');
        yield Tuple2(null, TextSpan(text: 'Error: $purchaseType $targetId'));
        return;
      case PurchaseType.quest:
        yield Tuple2(
          null,
          TextSpan(
            text: '${S.current.unlock_quest}: ',
            children: MultiDescriptor.quests(context, [targetId]),
          ),
        );
        return;
      case PurchaseType.eventShop:
        yield Tuple2(
          null,
          TextSpan(
            text: 'Shop ',
            children: MultiDescriptor.shops(context, [targetId]),
          ),
        );
        return;
      case PurchaseType.eventSvtGet:
      case PurchaseType.eventSvtJoin:
        final svt = db.gameData.servantsById[targetId];
        yield Tuple2(
          svt?.iconBuilder(context: context),
          TextSpan(
              text: (svt?.lName.l ?? 'Svt $targetId') +
                  (purchaseType == PurchaseType.eventSvtJoin
                      ? ' Join'
                      : ' Get')),
        );
        return;
      case PurchaseType.manaShop:
        List<int> manaShops = [];
        for (final cond in shop.releaseConditions) {
          if (cond.condType == CondType.notShopPurchase) {
            manaShops.addAll(cond.condValues);
          }
        }
        yield Tuple2(
          null,
          TextSpan(text: 'Mana Shop ', children: [
            ...MultiDescriptor.shops(context, manaShops),
            if (showSpecialName) shopName
          ]),
        );
        return;
      case PurchaseType.storageSvt:
        yield const Tuple2(null, TextSpan(text: 'サーヴァント保管枠の拡張'));
        return;
      case PurchaseType.storageSvtequip:
        yield const Tuple2(null, TextSpan(text: '概念礼装保管枠の拡張'));
        return;
      case PurchaseType.bgm:
      case PurchaseType.bgmRelease:
        final bgm = db.gameData.bgms.values
            .firstWhereOrNull((e) => e.shop?.id == shop.id);
        yield Tuple2(
          bgm?.logo == null ? null : db.getIconImage(bgm?.logo, width: 48),
          SharedBuilder.textButtonSpan(
            context: context,
            text: bgm?.lName.l ?? shop.name,
            onTap: bgm?.routeTo,
          ),
        );
        return;
      case PurchaseType.lotteryShop:
        yield Tuple2(null, TextSpan(text: 'A random shop ${shop.name}'));
        return;
      case PurchaseType.eventFactory:
        yield Tuple2(
            null, TextSpan(text: 'Event Factory $targetId: ${shop.name}'));
        return;
      case PurchaseType.gift:
        for (final gift in gifts) {
          yield Tuple2(
            gift.iconBuilder(context: context, showOne: false),
            TextSpan(
              text: [
                gift.shownName,
                if (gift.num != 1) gift.num.format(),
                if (targetNum != 1) targetNum.format(),
              ].join(' ×'),
            ),
          );
        }
        return;
      case PurchaseType.assist:
        yield Tuple2(null, TextSpan(text: 'Assist $targetId'));
        return;
      case PurchaseType.kiaraPunisherReset:
        assert(false, 'Should not reach here');
        yield Tuple2(
          null,
          TextSpan(
            text: 'Reset Kiara Punishers: ',
            children: MultiDescriptor.shops(context, [targetId]),
          ),
        );
        return;
    }
  }
}
