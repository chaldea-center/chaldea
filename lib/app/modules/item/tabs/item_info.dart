import 'dart:math';

import 'package:flutter/gestures.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../app.dart';

class ItemInfoTab extends StatefulWidget {
  final int itemId;

  const ItemInfoTab({super.key, required this.itemId});

  @override
  _ItemInfoTabState createState() => _ItemInfoTabState();
}

class _ItemInfoTabState extends State<ItemInfoTab> {
  late final itemId = widget.itemId;

  bool _hasUnknownRegion = false;
  bool _loading = false;
  Region? region;
  Item? _item;

  @override
  void initState() {
    super.initState();
    _item = db.gameData.items[itemId];
    if (_item != null) {
      region = Region.fromUrl(_item!.icon);
      if (region == null) _hasUnknownRegion = true;
    }
    svtCoinOwner = db.gameData.servantsById[db.gameData.items[itemId]?.value];
    if (svtCoinOwner != null) {
      _summonCoin = svtCoinOwner!.coin?.summonNum ?? 0;
    }
  }

  Future<void> fetchItem(Region? r) async {
    _loading = true;
    _item = null;
    if (mounted) setState(() {});
    Item? result;
    if (r == null) {
      result = db.gameData.items[itemId];
    } else {
      result = await AtlasApi.item(itemId, region: r);
    }
    if (r == region) {
      _item = result;
    }
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (Items.specialSvtMat.contains(itemId)) {
      final svt = db.gameData.entities[itemId];
      return ListTile(
        title: Center(
          child: ElevatedButton(
            onPressed: () {
              router.push(url: Routes.enemyI(itemId));
            },
            child: Text('${S.current.servant} - ${svt?.lName.l}'),
          ),
        ),
      );
    }
    Widget child;
    final item = _item;
    if (item == null) {
      if (_loading) {
        child = Center(child: CircularProgressIndicator());
      } else {
        child = ListTile(
          title: Text('NotFound: $itemId'),
        );
      }
    } else {
      final eventIds = <int>{if (item.eventId != 0) item.eventId};
      if (item.isId94 &&
          const [ItemCategory.eventAscension, ItemCategory.event, ItemCategory.other].contains(item.category)) {
        for (final event in db.gameData.events.values) {
          if (eventIds.contains(event.id)) continue;
          if (isForEvent(item, event)) {
            eventIds.add(event.id);
          }
        }
      }
      child = SingleChildScrollView(
        child: CustomTable(
          selectable: true,
          children: <Widget>[
            CustomTableRow(
              children: [
                TableCellData(
                  child: CachedImage(imageUrl: item.borderedIcon, height: 72, showSaveOnLongPress: true),
                  flex: 1,
                  padding: const EdgeInsets.all(3),
                ),
                TableCellData(
                  flex: 3,
                  padding: EdgeInsets.zero,
                  child: CustomTable(
                    hideOutline: true,
                    children: <Widget>[
                      CustomTableRow(children: [
                        TableCellData(
                          child: Text(item.lName.l, style: const TextStyle(fontWeight: FontWeight.bold)),
                          isHeader: true,
                          textAlign: TextAlign.center,
                        )
                      ]),
                      if (!Transl.isJP) CustomTableRow.fromTexts(texts: [item.name]),
                      if (!Transl.isEN) CustomTableRow.fromTexts(texts: [item.lName.na]),
                      CustomTableRow.fromTexts(texts: [item.type.name, item.category.name]),
                    ],
                  ),
                ),
              ],
            ),
            if (svtCoinOwner != null)
              TextButton(
                onPressed: () => svtCoinOwner!.routeTo(),
                style: kTextButtonDenseStyle,
                child: Text(svtCoinOwner!.lName.l),
              ),
            if (item.individuality.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.trait], isHeader: true),
              CustomTableRow.fromChildren(
                  children: [SharedBuilder.traitList(context: context, traits: item.individuality)])
            ],
            CustomTableRow.fromTexts(texts: const ['ID', 'Value', 'Priority', 'Drop Priority'], isHeader: true),
            CustomTableRow.fromTexts(
                texts: ['${item.id}', '${item.value}', '${item.priority}', '${item.dropPriority}']),
            if (eventIds.isNotEmpty) ...[
              CustomTableRow.fromTexts(texts: [S.current.event], isHeader: true),
              for (final eventId in eventIds)
                TextButton(
                  onPressed: () {
                    router.push(url: Routes.eventI(eventId));
                  },
                  child: Text(
                    db.gameData.events[eventId]?.lName.l ?? '${S.current.event} $eventId',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
            if (!(item.endedAt > kNeverClosedTimestamp && item.startedAt < 1000000000)) ...[
              CustomTableRow.fromTexts(texts: [S.current.time], isHeader: true),
              CustomTableRow.fromTexts(texts: [
                [item.startedAt, item.endedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ '),
              ]),
            ],
            CustomTableRow.fromTexts(texts: [S.current.card_description], isHeader: true),
            CustomTableRow(
              children: [
                TableCellData(
                  text: item.detail,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                )
              ],
            ),
            if (item.type == ItemType.svtCoin) ..._svtCoinObtain(),
            if (item.type == ItemType.itemSelect) ...[
              CustomTableRow.fromTexts(
                texts: [S.current.exchange_ticket],
                isHeader: true,
              ),
              CustomTableRow.fromChildren(children: [
                SharedBuilder.giftGrid(
                    context: context, gifts: [for (final select in item.itemSelects) ...select.gifts])
              ]),
            ],
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(child: child),
        kDefaultDivider,
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<Region?>(
          combined: true,
          padding: EdgeInsets.zero,
          options: [if (_hasUnknownRegion) null, ...Region.values],
          optionBuilder: (v) => Text(v?.upper ?? S.current.general_default),
          values: FilterRadioData(region),
          onFilterChanged: (v, _) {
            region = v.radioValue;
            fetchItem(region);
            setState(() {});
          },
        ),
      ],
    );
  }

  Servant? svtCoinOwner;
  final validSummonCoins = const [0, 2, 6, 15, 30, 50, 90];
  final List<int> bondCoinsAfter9thAnni = [
    ...List.generate(6, (index) => 5), // 1-6
    ...List.generate(3, (index) => 20), // 7-9
    40, // 10
    50, // 11
    ...List.generate(4, (index) => 60), // 12-15
  ];
  final List<int> bondCoinsBefore9thAnni = <int>[
    ...List.generate(6, (index) => 5),
    ...List.generate(3, (index) => 10),
    ...List.generate(6, (index) => 20),
  ];
  bool _useNewBondCoinRewards = const [Region.jp].contains(db.curUser.region) ? true : false;
  int _summonCoin = 90;
  int _baseNp = 1;
  int _offsetNp = 0;

  List<Widget> _svtCoinObtain() {
    final bondCoins = _useNewBondCoinRewards ? bondCoinsAfter9thAnni : bondCoinsBefore9thAnni;
    return [
      CustomTableRow(
        children: [
          TableCellData(
            isHeader: true,
            child: Text.rich(
              TextSpan(text: 'coins/NP & NP range', children: [
                const TextSpan(text: ': '),
                TextSpan(
                  text: 'NEW',
                  style: _useNewBondCoinRewards ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _useNewBondCoinRewards = true;
                      });
                    },
                ),
                const TextSpan(text: '/'),
                TextSpan(
                  text: 'OLD',
                  style: !_useNewBondCoinRewards ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _useNewBondCoinRewards = false;
                      });
                    },
                ),
              ]),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
      SizedBox(
        height: 36,
        child: CustomTableRow.fromChildren(
          children: List.generate(
            validSummonCoins.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  _summonCoin = validSummonCoins[index];
                });
              },
              child: SizedBox.expand(
                child: Center(
                  child: AutoSizeText(
                    '${validSummonCoins[index]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _summonCoin == validSummonCoins[index] ? Theme.of(context).colorScheme.error : null,
                      fontWeight: _summonCoin == validSummonCoins[index] ? FontWeight.bold : null,
                      decoration:
                          svtCoinOwner?.coin?.summonNum == validSummonCoins[index] ? TextDecoration.underline : null,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 36,
        child: CustomTableRow.fromChildren(
          defaults: TableCellData(padding: const EdgeInsets.symmetric(vertical: 4)),
          children: [
            const Text('Range'),
            ...List.generate(
              6,
              (index) {
                int baseNp = 1 + 5 * (index + max(0, _offsetNp));
                return InkWell(
                  onTap: () {
                    setState(() {
                      _baseNp = baseNp;
                      if (index == 4) _offsetNp += 1;
                      if (index == 0) _offsetNp = max(0, _offsetNp - 1);
                    });
                  },
                  child: SizedBox.expand(
                    child: Center(
                      child: AutoSizeText(
                        '$baseNp~${baseNp + 4}',
                        textAlign: TextAlign.center,
                        minFontSize: 6,
                        style: baseNp == _baseNp
                            ? TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                        maxLines: 1,
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
      CustomTableRow.fromTexts(
        texts: [
          (S.current.bond),
          for (int np = _baseNp; np < _baseNp + 5; np++) 'NP $np',
        ],
        isHeader: true,
      ),
      for (int index = 0; index < bondCoins.length + 1; index++)
        CustomTableRow(
          children: List.generate(
            6,
            (np) {
              if (np == 0) {
                return TableCellData(text: 'Lv.$index');
              }
              int coins = Maths.sum(bondCoins.sublist(0, index)) + (np + _baseNp - 1) * _summonCoin;
              return TableCellData(
                text: coins.toString(),
                style: coins > 660
                    ? TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      )
                    : coins > 480
                        ? const TextStyle(fontWeight: FontWeight.w300)
                        : const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
              );
            },
          ),
        ),
    ];
  }

  bool isForEvent(Item item, Event event) {
    Iterable<int> itemIds = (event.shop.map((e) => e.cost?.itemId ?? 0))
        .followedBy(event.shop.expand((e) => e.consumes).map((e) => e.objectId))
        .followedBy(event.itemShop.values.expand((e) => e.keys))
        .followedBy(event.itemPointReward.keys)
        .followedBy(event.itemMission.keys)
        .followedBy(event.itemWarDrop.keys)
        .followedBy(event.itemLottery.values.expand((e) => e.values).expand((e) => e.keys))
        // event point
        .followedBy(event.treasureBoxes.expand((box) => box.extraGifts.map(((e) => e.objectId))))
        .followedBy(event.recipes.map((e) => e.eventPointItem.id))
        .followedBy(event.tradeGoods.map((e) => e.eventPointItem?.id ?? 0));
    if (itemIds.contains(item.id)) {
      return true;
    }

    for (final warId in event.warIds) {
      final war = db.gameData.wars[warId];
      if (war == null) continue;
      for (final quest in war.quests) {
        if (quest.gifts.any((e) => e.objectId == item.id)) {
          return true;
        }
        final items = db.gameData.dropData.eventFreeDrops[quest.id]?.items;
        if (items != null && items.keys.contains(item.id)) {
          return true;
        }
        if (quest.consumeItem.any((e) => e.itemId == item.id)) {
          return true;
        }
      }
    }

    for (final campaign in event.campaigns) {
      if (campaign.target == CombineAdjustTarget.questUseFriendshipUpItem && campaign.targetIds.contains(item.id)) {
        return true;
      }
      if (campaign.target == CombineAdjustTarget.questUseContinueItem && campaign.value == item.id) {
        return true;
      }
    }
    return false;
  }
}
