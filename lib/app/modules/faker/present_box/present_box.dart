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
import 'filter.dart';

const int _kMaxPresentSelectCount = 99;
const int _kMaxItemSelectExchangeCount = 99;

class UserPresentBoxManagePage extends StatefulWidget {
  final FakerRuntime runtime;
  const UserPresentBoxManagePage({super.key, required this.runtime});

  @override
  State<UserPresentBoxManagePage> createState() => _UserPresentBoxManagePageState();
}

class _UserPresentBoxManagePageState extends State<UserPresentBoxManagePage> {
  late final runtime = widget.runtime;
  late final userPresents = runtime.mstData.userPresentBox;

  Map<int, Item> items = {};
  final selectedPresents = <int>{};

  final filterData = PresentBoxFilterData();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (runtime.region == Region.jp) {
        items = Map.of(db.gameData.items);
      } else {
        final itemList = await AtlasApi.exportedData<List<Item>>(
            'nice_item', (data) => (data as List).map((e) => Item.fromJson(Map.from(e))).toList());
        if (itemList != null) {
          items = {for (final item in itemList) item.id: item};
        }
      }
      if (mounted) setState(() {});
    });
  }

  List<UserPresentBoxEntity> filterPresents() {
    final presents = runtime.mstData.userPresentBox.toList();
    if (filterData.showSelectedOnly) {
      presents.retainWhere((e) => selectedPresents.contains(e.presentId));
    }
    if (filterData.maxNum > 0) {
      presents.retainWhere((e) => e.num <= filterData.maxNum);
    }
    if (filterData.presentType.isNotEmpty || filterData.rarity.isNotEmpty) {
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
                ItemType.stoneFragments =>
                  PresentType.stone,
                ItemType.mana || ItemType.purePri || ItemType.rarePri => PresentType.manaPrism,
                ItemType.eventPoint || ItemType.eventItem => PresentType.eventItem,
                _ => PresentType.others,
              };
            }
          default:
            break;
        }
        if (!filterData.presentType.matchOne(presentType)) return false;
        if (!filterData.rarity.matchOne(rarity)) return false;
        return true;
      });
    }
    presents.sortByList((e) {
      Item? item;
      if (e.giftType == GiftType.item.value) {
        item = items[e.objectId];
      }
      return <int>[
        -e.flags.length,
        item?.type == ItemType.itemSelect ? 0 : 1,
        filterData.reversed ? e.createdAt : -e.createdAt
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
        title: Text('${S.current.present_box} (${runtime.mstData.userPresentBox.length})'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                filterData.showSelectedOnly = !filterData.showSelectedOnly;
              });
            },
            icon: Icon(filterData.showSelectedOnly ? Icons.check_circle : Icons.check_circle_outline),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => UserPresentBoxFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
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

  int getPresentExpireAt(UserPresentBoxEntity present) {
    if (present.flags.contains(UserPresentBoxFlag.indefinitePeriod)) return DateTime(2099).timestamp;
    int expireAt = present.createdAt + ConstData.constants.presentValidTime;
    final item = items[present.objectId];
    if (item == null) return expireAt;
    return min(item.endedAt, expireAt);
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
    final expireAt = getPresentExpireAt(present);
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
      secondary: Gift(
        id: 0,
        type: GiftType.fromId(present.giftType),
        objectId: present.objectId,
        num: present.num,
      ).iconBuilder(context: context, width: 32),
      title: Text('${GameCardMixin.anyCardItemName(present.objectId).l} ×${present.num}'),
      subtitle: Text.rich(TextSpan(children: [
        if (flags.isNotEmpty)
          TextSpan(children: [
            ...divideList(
              [
                for (final flag in flags)
                  TextSpan(text: flag.name, style: TextStyle(color: Theme.of(context).colorScheme.error))
              ],
              const TextSpan(text: ' / '),
            ),
            const TextSpan(text: '\n'),
          ]),
        TextSpan(text: '${present.message}\n'),
        TextSpan(
          text: present.flags.contains(UserPresentBoxFlag.indefinitePeriod)
              ? 'Forever'
              : '$leftDurStr (${expireAt.sec2date().toCustomString(second: false)})',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ])),
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
      '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.constants.maxUserCommandCode}',
      if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
    ].join(' ');

    bool allChecked = selectedPresents.length >= _kMaxPresentSelectCount ||
        (selectedPresents.length >= shownPresents.length &&
            shownPresents.every((e) => selectedPresents.contains(e.presentId)));

    final buttons = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton(
          onPressed: () {
            receivePresents(selectedPresents.toSet());
          },
          child: Text('Receive ×${selectedPresents.length}!'),
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
          onPressed: filterData.showSelectedOnly
              ? null
              : () {
                  if (allChecked) {
                    selectedPresents.removeAll(shownPresents.map((e) => e.presentId));
                  } else {
                    final leftIds = shownPresents.map((e) => e.presentId).toSet().difference(selectedPresents);
                    leftIds.removeWhere(isItemSelect);
                    selectedPresents.addAll(leftIds.take(_kMaxPresentSelectCount - selectedPresents.length));
                  }
                  setState(() {});
                },
          icon: Icon(allChecked ? Icons.check_box : Icons.square_outlined),
        )
      ],
    );
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(cardInfo, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          buttons,
        ],
      ),
    );
  }

  void _ensureSelected([Set<int>? presentIds]) {
    (presentIds ?? selectedPresents).removeWhere((e) => !userPresents.lookup.containsKey(e) || isItemSelect(e));
  }

  Future<void> receiveExchangeTicket(Item item) async {
    List<UserPresentBoxEntity> presents =
        userPresents.where((e) => e.giftType == GiftType.item.value && e.objectId == item.id).toList();
    if (presents.isEmpty) return;
    if (!mounted) return;
    final itemSelect = await router.showDialog<ItemSelect>(
        builder: (context) => _ItemSelectListDialog(item: item, mstData: runtime.mstData));
    if (itemSelect == null || itemSelect.gifts.isEmpty) return;
    int? selectNum = await router.showDialog<int>(
        builder: (context) => _ItemSelectCountDialog(item: item, itemSelect: itemSelect, mstData: runtime.mstData));
    if (selectNum == null || selectNum <= 0) return;
    presents = userPresents.where((e) => e.giftType == GiftType.item.value && e.objectId == item.id).toList();
    if (presents.isEmpty) return;
    presents.sort2((e) => e.createdAt);
    selectNum = selectNum.clamp(1, min(_kMaxItemSelectExchangeCount, presents.length));
    await runtime.runTask(() => runtime.agent.userPresentReceive(
          presentIds: presents.take(selectNum!).map((e) => e.presentId).toList(),
          itemSelectIdx: itemSelect.idx,
          itemSelectNum: selectNum,
        ));
    _ensureSelected();
    if (mounted) setState(() {});
  }

  Future<void> receivePresents(Set<int> presentIds) async {
    _ensureSelected(presentIds);
    if (presentIds.isEmpty) return;
    final confirm = await router.showDialog(builder: (context) {
      return SimpleCancelOkDialog(
        title: Text('Receive ${presentIds.length} presents'),
      );
    });
    if (confirm != true) return;
    await runtime.runTask(() async {
      runtime.checkSvtKeep();
      final resp =
          await runtime.agent.userPresentReceive(presentIds: presentIds.toList(), itemSelectIdx: 0, itemSelectNum: 0);
      final overflowType = resp.data.getResponse('present_receive').success?['overflowType'];
      if (overflowType is int && overflowType != 0 && mounted) {
        SimpleCancelOkDialog(
          title: Text('Overflow'),
          content: Text('$overflowType ${PresentOverflowType.values.firstWhereOrNull((e) => e.value == overflowType)}'),
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
      leading: gift?.iconBuilder(context: context, text: count.format()),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final gift in itemSelect.gifts) Text('${gift.shownName} ×${gift.num}  '),
        ],
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
    final presents =
        mstData.userPresentBox.where((e) => e.giftType == GiftType.item.value && e.objectId == item.id).toList();

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
    final int maxCount = min(presents.length, _kMaxItemSelectExchangeCount);
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
        )
      ],
    );
  }
}
