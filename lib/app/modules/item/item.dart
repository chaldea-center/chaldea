import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'tabs/cost_detail.dart';
import 'tabs/item_info.dart';
import 'tabs/obtain_event.dart';
import 'tabs/obtain_event_free.dart';
import 'tabs/obtain_free.dart';
import 'tabs/obtain_interlude.dart';

class ItemDetailPage extends StatefulWidget {
  final int itemId;
  final int initialTabIndex;

  ItemDetailPage({super.key, required this.itemId, this.initialTabIndex = 0});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

enum _TabType {
  demand,
  consumed,
  free,
  event,
  eventFree,
  interlude,
  info,
}

const _kEventTabs = [_TabType.event];
const _kStatTabs = [_TabType.demand, _TabType.consumed, _TabType.free, _TabType.interlude];

class _TabInfo {
  final Widget header;
  final Widget view;
  final List<Widget> actions;
  _TabInfo({
    required this.header,
    required this.view,
    required this.actions,
  });
}

class _ItemDetailPageState extends State<ItemDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int get curTab => _tabController.index;

  // event
  bool showOutdated = false;

  List<_TabType> _shownTabs = [];

  @override
  void initState() {
    super.initState();
    final item = db.gameData.items[widget.itemId];
    _shownTabs = [];
    switch (item?.category) {
      case ItemCategory.normal:
      case ItemCategory.ascension:
      case ItemCategory.skill:
      case ItemCategory.eventAscension:
        _shownTabs = _TabType.values.toList();
        break;
      case ItemCategory.coin:
        _shownTabs = [_TabType.info, _TabType.demand, _TabType.consumed, _TabType.event];
        break;
      case ItemCategory.event:
      case ItemCategory.other:
        if ([
          // fp, Q/A/B opener, Beast's Footprint
          4, 5000, 5001, 5002, 5003, 2000,
        ].contains(widget.itemId)) {
          _shownTabs = _kEventTabs.toList();
        }
        break;
      case ItemCategory.special:
        _shownTabs.addAll(_kEventTabs);
        if (<int>[
          Items.qpId,
          Items.grailId,
          Items.lanternId,
          Items.stellarSandId,
          Items.torchNovaId,
          Items.torchMorningStarId,
          Items.torchPolarStarId
        ].contains(widget.itemId)) {
          _shownTabs.addAll(_kStatTabs);
        } else if (<int>[Items.stoneId].contains(widget.itemId)) {
          _shownTabs.addAll([_TabType.interlude]);
        }
        _shownTabs.sort2((e) => e.index);
        break;
      case null: // svtMat
        if (Items.fous.contains(widget.itemId)) {
          _shownTabs = _TabType.values.toList();
        } else if (Items.embers.contains(widget.itemId)) {
          _shownTabs = _kEventTabs.toList();
        }
        break;
    }
    if (_shownTabs.contains(_TabType.eventFree) &&
        db.gameData.dropData.freeDrops2.values.every((e) => !e.items.containsKey(widget.itemId))) {
      _shownTabs.remove(_TabType.eventFree);
    }
    if (!_shownTabs.contains(_TabType.info)) _shownTabs.add(_TabType.info);

    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: _shownTabs.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<_TabInfo> tabs = [
      for (final tabType in _shownTabs)
        switch (tabType) {
          _TabType.demand => _TabInfo(
              header: Tab(text: S.current.demands),
              view: db.onUserData((context, _) => ItemCostSvtDetailTab(itemId: widget.itemId, matType: null)),
              actions: [viewTypeButton, sortButton, popupMenu],
            ),
          _TabType.consumed => _TabInfo(
              header: Tab(text: S.current.consumed),
              view: db.onUserData((context, _) => ItemCostSvtDetailTab(
                    itemId: widget.itemId,
                    matType: SvtMatCostDetailType.consumed,
                  )),
              actions: [viewTypeButton, sortButton, popupMenu],
            ),
          _TabType.free => _TabInfo(
              header: Tab(text: S.current.free_quest),
              view: ItemObtainFreeTab(itemId: widget.itemId),
              actions: [popupMenu],
            ),
          _TabType.event => _TabInfo(
              header: Tab(text: S.current.event),
              view: ItemObtainEventTab(itemId: widget.itemId, showOutdated: showOutdated),
              actions: [filterOutdatedButton, popupMenu],
            ),
          _TabType.eventFree => _TabInfo(
              header: Tab(text: S.current.event_free_quest),
              view: ItemObtainEventFreeTab(itemId: widget.itemId, showOutdated: showOutdated),
              actions: [filterOutdatedButton, popupMenu],
            ),
          _TabType.interlude => _TabInfo(
              header: Tab(text: S.current.interlude_and_rankup),
              view: ItemObtainInterludeTab(itemId: widget.itemId),
              actions: [sortButton, popupMenu],
            ),
          _TabType.info => _TabInfo(
              header: Tab(text: S.current.card_info),
              view: ItemInfoTab(itemId: widget.itemId),
              actions: [popupMenu],
            )
        }
    ];

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(Item.getName(widget.itemId), maxLines: 1),
        centerTitle: false,
        titleSpacing: 0,
        actions: tabs.getOrNull(curTab)?.actions ?? [],
        bottom: tabs.length < 2
            ? null
            : FixedHeight.tabBar(TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: tabs.map((e) => e.header).toList(),
              )),
      ),
      body: tabs.length == 1
          ? tabs.first.view
          : TabBarView(
              controller: _tabController,
              children: tabs.map((e) => e.view).toList(),
            ),
    );
  }

  Widget get popupMenu {
    return PopupMenuButton<dynamic>(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            enabled: false,
            height: 32,
            child: Text('No.${widget.itemId}', textScaler: const TextScaler.linear(0.9)),
          ),
          const PopupMenuDivider(),
          // if (_shownTabs.length > 1 || db.gameData.items[widget.itemId]?.type == ItemType.svtCoin)
          PopupMenuItem(
            child: Text(S.current.item_edit_owned_amount),
            onTap: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => _ItemAmountEditDialog(widget.itemId),
              );
            },
          ),
          ...SharedBuilder.websitesPopupMenuItems(
            atlas: Atlas.dbUrl(
              Items.specialSvtMat.contains(widget.itemId) ? 'servant' : 'item',
              widget.itemId,
            ),
          )
        ];
      },
    );
  }

  Widget get viewTypeButton {
    return IconButton(
      icon: const Icon(Icons.view_carousel),
      tooltip: S.current.filter_shown_type,
      onPressed: () {
        setState(() {
          db.settings.display.itemDetailViewType =
              EnumUtil.next(ItemDetailViewType.values, db.settings.display.itemDetailViewType);
          db.saveSettings();
        });
      },
    );
  }

  Widget get sortButton {
    return IconButton(
      icon: const Icon(Icons.sort),
      tooltip: _getSortTypeText(db.settings.display.itemDetailSvtSort),
      onPressed: () {
        setState(() {
          db.settings.display.itemDetailSvtSort =
              EnumUtil.next(ItemDetailSvtSort.values, db.settings.display.itemDetailSvtSort);
          db.saveSettings();
          EasyLoading.showToast(_getSortTypeText(db.settings.display.itemDetailSvtSort));
        });
      },
    );
  }

  String _getSortTypeText(ItemDetailSvtSort type) {
    return '${S.current.filter_sort}-${[
      S.current.filter_sort_number,
      S.current.svt_class,
      S.current.rarity
    ][type.index]}';
  }

  Widget get filterOutdatedButton {
    return IconButton(
      icon: Icon(showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
      tooltip: S.current.outdated,
      onPressed: () {
        setState(() {
          showOutdated = !showOutdated;
        });
      },
    );
  }
}

class _ItemAmountEditDialog extends HookWidget {
  final int itemId;
  const _ItemAmountEditDialog(this.itemId);

  @override
  Widget build(BuildContext context) {
    final s = (db.curUser.items[itemId] ?? 0).toString();
    final controller = useTextEditingController.fromValue(TextEditingValue(
      text: s,
      selection: TextSelection(baseOffset: 0, extentOffset: s.length),
    ));
    return AlertDialog(
      title: Text(S.current.item_edit_owned_amount),
      content: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        autofocus: true,
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
            final v = int.tryParse(controller.text);
            if (v != null) {
              db.curUser.items[itemId] = v;
              db.itemCenter.updateLeftItems();
            }
            Navigator.pop(context);
          },
          child: Text(S.current.confirm),
        )
      ],
    );
  }
}
