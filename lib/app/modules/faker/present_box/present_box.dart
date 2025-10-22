import 'dart:math';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/faker/state.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../card_enhance/svt_combine.dart';
import 'filter.dart';
import 'history.dart';

const int _kMaxPresentSelectCount = 99;
const int _kMaxItemSelectExchangeCount = 99;

class UserPresentBoxManagePage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserPresentBoxManagePage({super.key, required this.runtime});

  @override
  State<UserPresentBoxManagePage> createState() => _UserPresentBoxManagePageState();
}

class _UserPresentBoxManagePageState extends State<UserPresentBoxManagePage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final userPresents = runtime.mstData.userPresentBox;

  Map<int, Item> items = {};
  final selectedPresents = <int>{};
  bool showSelectedOnly = false;

  late final filterData = runtime.agent.user.presentBox;

  @override
  void initState() {
    super.initState();
    showSelectedOnly = false;
    items = Map.of(db.gameData.items);
    Future.microtask(() async {
      if (runtime.region != Region.jp) {
        final itemList = await AtlasApi.exportedData<List<Item>>(
          'nice_item',
          (data) => (data as List).map((e) => Item.fromJson(Map.from(e))).toList(),
        );
        if (itemList != null && itemList.isNotEmpty) {
          items = {for (final item in itemList) item.id: item};
        }
      }
      if (mounted) setState(() {});
    });
  }

  List<UserPresentBoxEntity> filterPresents() {
    final presents = runtime.mstData.userPresentBox.toList();
    if (showSelectedOnly) {
      presents.retainWhere((e) => selectedPresents.contains(e.presentId));
    }
    if (filterData.maxNum > 0) {
      presents.retainWhere((e) => e.num <= filterData.maxNum);
    }
    if (filterData.presentTypes.isNotEmpty || filterData.rarities.isNotEmpty) {
      presents.retainWhere((present) {
        final giftType = GiftType.fromId(present.giftType);
        PresentType presentType = PresentType.others;
        int rarity = -1;
        switch (giftType) {
          case GiftType.servant:
            final svt = db.gameData.entities[present.objectId];
            if (svt != null) {
              rarity = svt.rarity;
              if (svt.type == SvtType.statusUp) {
                presentType = PresentType.statusUp;
              } else if (svt.type == SvtType.combineMaterial) {
                presentType = PresentType.servantExp;
              } else if (const [SvtType.normal, SvtType.heroine, SvtType.svtMaterialTd].contains(svt.type)) {
                presentType = PresentType.servant;
              } else if (svt.flags.contains(SvtFlag.svtEquipExp) || svt.flags.contains(SvtFlag.svtEquipChocolate)) {
                presentType = PresentType.svtEquipExp;
              } else if (svt.type == SvtType.servantEquip) {
                presentType = PresentType.svtEquip;
              }
            }
          case GiftType.commandCode:
            final cc = db.gameData.commandCodesById[present.objectId];
            if (cc != null) {
              rarity = cc.rarity;
              presentType = PresentType.commandCode;
            }
          case GiftType.item:
            final item = items[present.objectId];
            if (item != null) {
              rarity = item.rarity;
              presentType = switch (item.type) {
                ItemType.apRecover || ItemType.apAdd || ItemType.rpAdd => PresentType.fruit,
                ItemType.gachaTicket => PresentType.summonTicket,
                ItemType.itemSelect => PresentType.itemSelect,
                ItemType.stone ||
                ItemType.chargeStone ||
                ItemType.aniplexPlusChargeStone ||
                ItemType.stoneFragments => PresentType.stone,
                ItemType.mana || ItemType.purePri || ItemType.rarePri => PresentType.manaPrism,
                ItemType.eventPoint || ItemType.eventItem => PresentType.eventItem,
                _ => PresentType.others,
              };
            }
          default:
            break;
        }
        if (filterData.presentTypes.isNotEmpty && !filterData.presentTypes.contains(presentType)) return false;
        if (filterData.rarities.isNotEmpty && !filterData.rarities.contains(rarity)) return false;
        return true;
      });
    }
    if (filterData.presentFromType.isNotEmpty) {
      presents.retainWhere((e) => filterData.presentFromType.contains(e.fromType));
    }
    presents.sortByList((e) {
      Item? item;
      if (e.giftType == GiftType.item.value) {
        item = items[e.objectId];
      }
      return <int>[
        -e.flags.length,
        item?.type == ItemType.itemSelect ? 0 : 1,
        filterData.reversed ? e.createdAt : -e.createdAt,
      ];
    });
    return presents;
  }

  @override
  Widget build(BuildContext context) {
    _ensureSelected();
    final shownPresents = filterPresents();
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.present_box} (${shownPresents.length}/${runtime.mstData.userPresentBox.length})'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showSelectedOnly = !showSelectedOnly;
              });
            },
            icon: Icon(showSelectedOnly ? Icons.check_circle : Icons.check_circle_outline),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => UserPresentBoxFilterPage(
                filterData: filterData,
                presentFromTypes: mstData.userPresentBox.map((e) => e.fromType).toSet(),
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
          runtime.buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemBuilder: (context, index) => buildPresent(shownPresents[index]),
                    itemCount: shownPresents.length,
                  ),
          ),
          kDefaultDivider,
          SafeArea(child: buttonBar(shownPresents)),
        ],
      ),
    );
  }

  bool isItemSelect(int presentId) {
    return items[userPresents[presentId]?.objectId]?.type == ItemType.itemSelect;
  }

  Widget buildPresent(UserPresentBoxEntity present) {
    final flags = present.flags;
    Item? item;
    if (present.giftType == GiftType.item.value) {
      item = items[present.objectId];
    }
    final expireAt = present.getExpireAt(item);
    Duration leftDur = Duration(seconds: expireAt - DateTime.now().timestamp);
    String leftDurStr = leftDur.isNegative ? '-' : '';
    leftDur = leftDur.abs();
    if (leftDur.inDays > 10) {
      leftDurStr += '${leftDur.inDays}d';
    } else if (leftDur.inDays != 0) {
      leftDurStr += '${leftDur.inDays}d ${leftDur.inHours % Duration.hoursPerDay}h';
    } else {
      leftDurStr += '${leftDur.inHours}h${leftDur.inMinutes % Duration.minutesPerHour}m';
    }
    return CheckboxListTile(
      dense: true,
      secondary: present.toGift().iconBuilder(context: context, width: 32),
      title: Text('${GameCardMixin.anyCardItemName(present.objectId).l} ×${present.num}'),
      subtitle: Text.rich(
        TextSpan(
          children: [
            if (flags.isNotEmpty)
              TextSpan(
                children: [
                  ...divideList([
                    for (final flag in flags)
                      TextSpan(
                        text: flag.name,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ], const TextSpan(text: ' / ')),
                  const TextSpan(text: '\n'),
                ],
              ),
            TextSpan(text: '${present.message}\n'),
            TextSpan(
              text: present.flags.contains(UserPresentBoxFlag.indefinitePeriod)
                  ? 'Forever'
                  : '$leftDurStr (${expireAt.sec2date().toCustomString(second: false)})',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            TextSpan(text: '\n${present.createdAt.sec2date().toCustomString(second: false)}'),
          ],
        ),
      ),
      value: selectedPresents.contains(present.presentId),
      onChanged: (v) async {
        if (item != null && item.type == ItemType.itemSelect) {
          return receiveExchangeTicket(item);
        }
        if (v == true && selectedPresents.length >= _kMaxPresentSelectCount) {
          return;
        }
        setState(() {
          selectedPresents.toggle(present.presentId);
        });
      },
    );
  }

  Widget buttonBar(List<UserPresentBoxEntity> shownPresents) {
    final cardCounts = runtime.mstData.countSvtKeep();
    final userGame = runtime.mstData.user;
    final cardInfo = [
      '${S.current.servant} ${cardCounts.svtCount}/${userGame?.svtKeep}',
      '${S.current.craft_essence_short} ${cardCounts.svtEquipCount}/${userGame?.svtEquipKeep}',
      '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.timerData.constants.maxUserCommandCode}',
      if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
    ].join(' ');

    bool allChecked =
        selectedPresents.length >= _kMaxPresentSelectCount ||
        (selectedPresents.length >= shownPresents.length &&
            shownPresents.every((e) => selectedPresents.contains(e.presentId)));

    final buttonGroups = [
      [
        runtime.buildCircularProgress(context: context, padding: const EdgeInsets.symmetric(horizontal: 8)),
        FilledButton(
          onPressed: () {
            receivePresents(selectedPresents.toSet());
          },
          child: Text('Receive ×${selectedPresents.length}!'),
        ),
        IconButton(
          onPressed: showSelectedOnly
              ? null
              : () {
                  if (allChecked) {
                    selectedPresents.removeAll(shownPresents.map((e) => e.presentId));
                  } else {
                    if (shownPresents.every(
                      (e) => e.giftType == GiftType.servant.value && Items.embers.contains(e.objectId),
                    )) {
                      shownPresents = shownPresents.toList();
                      shownPresents.sortByList((e) => [e.objectId, e.num]);
                    }
                    final leftIds = shownPresents.map((e) => e.presentId).toSet().difference(selectedPresents);
                    leftIds.removeWhere(isItemSelect);
                    selectedPresents.addAll(leftIds.take(_kMaxPresentSelectCount - selectedPresents.length));
                  }
                  setState(() {});
                },
          icon: Icon(allChecked ? Icons.check_box : Icons.square_outlined),
        ),
      ],
      [
        FilledButton.tonal(
          onPressed: () {
            _SellCombineMaterialDialog(runtime: runtime).showDialog(context);
          },
          child: Text('Sell'),
        ),
        IconButton(
          onPressed: () {
            runtime.runTask(() => runtime.agent.userPresentList());
          },
          icon: Icon(Icons.replay),
          tooltip: S.current.refresh,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              filterData.reversed = !filterData.reversed;
            });
          },
          icon: FaIcon(filterData.reversed ? FontAwesomeIcons.arrowDown19 : FontAwesomeIcons.arrowUp91),
          tooltip: S.current.sort_order,
        ),
        IconButton(
          onPressed: () {
            router.pushPage(UserPresentHistoryPage(runtime: runtime));
          },
          icon: Icon(Icons.history),
          tooltip: S.current.history,
        ),
      ],
    ];

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(cardInfo, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          for (final buttons in buttonGroups)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              children: buttons,
            ),
        ],
      ),
    );
  }

  void _ensureSelected([Set<int>? presentIds]) {
    (presentIds ?? selectedPresents).removeWhere((e) => !userPresents.lookup.containsKey(e) || isItemSelect(e));
  }

  Future<void> receiveExchangeTicket(Item item) async {
    List<UserPresentBoxEntity> presents = userPresents
        .where((e) => e.giftType == GiftType.item.value && e.objectId == item.id)
        .toList();
    if (presents.isEmpty) return;
    if (!mounted) return;
    final itemSelect = await router.showDialog<ItemSelect>(
      builder: (context) => _ItemSelectListDialog(item: item, mstData: runtime.mstData),
    );
    if (itemSelect == null || itemSelect.gifts.isEmpty) return;
    int? selectNum = await router.showDialog<int>(
      builder: (context) => _ItemSelectCountDialog(item: item, itemSelect: itemSelect, mstData: runtime.mstData),
    );
    if (selectNum == null || selectNum <= 0) return;
    presents = userPresents.where((e) => e.giftType == GiftType.item.value && e.objectId == item.id).toList();
    if (presents.isEmpty) return;
    presents.sort2((e) => e.createdAt);
    selectNum = selectNum.clamp(1, min(_kMaxItemSelectExchangeCount, Maths.sum(presents.map((e) => e.num))));
    await runtime.runTask(
      () => runtime.agent.userPresentReceive(
        presentIds: presents.take(selectNum!).map((e) => e.presentId).toList(),
        itemSelectIdx: itemSelect.idx,
        itemSelectNum: selectNum,
      ),
    );
    _ensureSelected();
    if (mounted) setState(() {});
  }

  Future<void> receivePresents(Set<int> presentIds) async {
    _ensureSelected(presentIds);
    if (presentIds.isEmpty) return;
    Map<int, Map<int, int>> total = {};
    for (final presentId in presentIds) {
      final present = mstData.userPresentBox[presentId];
      if (present == null) continue;
      total.putIfAbsent(present.giftType, () => {}).addNum(present.objectId, present.num);
    }
    final confirm = await router.showDialog(
      builder: (context) {
        return SimpleConfirmDialog(
          title: Text('Receive ${presentIds.length} presents'),
          content: Wrap(
            children: [
              for (final (giftType, gifts) in total.items)
                for (final (objectId, count) in gifts.items)
                  Gift(
                    id: 0,
                    objectId: objectId,
                    num: count,
                    type: GiftType.fromId(giftType),
                  ).iconBuilder(context: context, width: 32, showOne: true),
            ],
          ),
        );
      },
    );
    if (confirm != true) return;
    await runtime.runTask(() async {
      runtime.checkSvtKeep();
      final resp = await runtime.agent.userPresentReceive(
        presentIds: presentIds.toList(),
        itemSelectIdx: 0,
        itemSelectNum: 0,
      );
      final overflowType = resp.data.getResponse('present_receive').success?['overflowType'];
      if (overflowType is int && overflowType != 0 && mounted) {
        SimpleConfirmDialog(
          title: Text('Overflow'),
          content: Text('$overflowType ${PresentOverflowType.values.firstWhereOrNull((e) => e.value == overflowType)}'),
          actions: [
            if (overflowType == PresentOverflowType.svt.value)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _SellCombineMaterialDialog(runtime: runtime).showDialog(context);
                },
                child: Text('Sell'),
              ),
            if (overflowType == PresentOverflowType.svt.value)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  router.pushPage(SvtCombinePage(runtime: runtime));
                },
                child: Text('从者强化'),
              ),
          ],
        ).showDialog(context);
      }
    });
    _ensureSelected();
    if (mounted) setState(() {});
  }
}

class _ItemSelectTile extends StatelessWidget {
  final ItemSelect itemSelect;
  final int count;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  const _ItemSelectTile({required this.itemSelect, required this.count, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final gift = itemSelect.gifts.firstOrNull;
    return ListTile(
      dense: true,
      contentPadding: padding,
      leading: gift?.iconBuilder(context: context, text: count.format(), width: 32),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [for (final gift in itemSelect.gifts) Text('${gift.shownName} ×${gift.num}  ')],
      ),
      // subtitle: itemSelect.detail
      trailing: Text('COST ${itemSelect.requireNum}'),
      onTap: onTap,
    );
  }
}

class _ItemSelectListDialog extends StatelessWidget {
  final Item item;
  final MasterDataManager mstData;

  const _ItemSelectListDialog({required this.item, required this.mstData});

  @override
  Widget build(BuildContext context) {
    final presents = mstData.userPresentBox
        .where((e) => e.giftType == GiftType.item.value && e.objectId == item.id)
        .toList();

    return SimpleDialog(
      title: Text('${item.lName.l}\n×${presents.length}'),
      children: [
        for (final select in item.itemSelects)
          _ItemSelectTile(
            itemSelect: select,
            count: mstData.getItemOrSvtNum(select.gifts.firstOrNull?.objectId ?? -1),
            onTap: () {
              Navigator.pop(context, select);
            },
          ),
      ],
    );
  }
}

class _ItemSelectCountDialog extends StatefulWidget {
  final Item item;
  final ItemSelect itemSelect;
  final MasterDataManager mstData;
  const _ItemSelectCountDialog({required this.item, required this.itemSelect, required this.mstData});

  @override
  State<_ItemSelectCountDialog> createState() => __ItemSelectCountDialogState();
}

class __ItemSelectCountDialogState extends State<_ItemSelectCountDialog> {
  late final itemSelect = widget.itemSelect;
  int count = 1;

  @override
  Widget build(BuildContext context) {
    final presents = widget.mstData.userPresentBox
        .where((e) => e.giftType == GiftType.item.value && e.objectId == widget.item.id)
        .toList();
    final int maxCount = min(Maths.sum(presents.map((e) => e.num)), _kMaxItemSelectExchangeCount);
    if (count > maxCount) count = maxCount;
    return AlertDialog(
      title: Text(widget.item.lName.l),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ItemSelectTile(
            padding: EdgeInsets.zero,
            itemSelect: itemSelect,
            count: widget.mstData.getItemOrSvtNum(itemSelect.gifts.firstOrNull?.objectId ?? -1),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SliderWithPrefix(
                  titled: true,
                  label: S.current.counts,
                  min: 1,
                  max: maxCount,
                  value: count,
                  onChange: (v) {
                    setState(() {
                      count = v.round().clamp(1, maxCount);
                    });
                  },
                ),
              ),
              Text(' $maxCount '),
            ],
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
            Navigator.pop(context, count);
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

class _SellCombineMaterialDialog extends StatefulWidget {
  final FakerRuntime runtime;

  const _SellCombineMaterialDialog({required this.runtime});

  @override
  State<_SellCombineMaterialDialog> createState() => _SellCombineMaterialDialogState();
}

class _SellCombineMaterialDialogState extends State<_SellCombineMaterialDialog> {
  late final runtime = widget.runtime;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('变换种火'),
      children: [
        buildRarity(3, 200),
        buildRarity(4, 100),
        Center(
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  Widget buildRarity(int rarity, int maxCount) {
    final cards = runtime.mstData.userSvt.where((userSvt) {
      final entity = userSvt.dbEntity;
      if (entity == null || entity.type != SvtType.combineMaterial || userSvt.isLocked()) return false;
      if (entity.rarity != rarity) return false;
      return true;
    }).toList();
    cards.sortByList((e) {
      final entity = e.dbEntity;
      return <int>[entity?.rarity ?? 999, entity == null || entity.classId == SvtClass.ALL.value ? 1 : 0, -e.createdAt];
    });
    final svt = db.gameData.entities[(97700 + rarity) * 100];
    return ListTile(
      leading: svt?.iconBuilder(context: context, width: 28),
      title: Text(svt?.lName.l ?? 'Rarity $rarity'),
      trailing: Text('${min(maxCount, cards.length)}/${cards.length}'),
      enabled: cards.isNotEmpty,
      onTap: () async {
        await runtime.runTask(
          () => runtime.agent.sellServant(
            servantUserIds: cards.take(maxCount).map((e) => e.id).toList(),
            commandCodeUserIds: [],
          ),
        );
        if (mounted) setState(() {});
      },
    );
  }
}
