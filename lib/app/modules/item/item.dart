import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'tabs/cost_detail.dart';
import 'tabs/item_info.dart';
import 'tabs/obtain_event.dart';
import 'tabs/obtain_free.dart';
import 'tabs/obtain_interlude.dart';

class ItemDetailPage extends StatefulWidget {
  final int itemId;
  final int initialTabIndex;

  ItemDetailPage({Key? key, required this.itemId, this.initialTabIndex = 0})
      : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

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

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int get curTab => _tabController.index;

  // event
  bool showOutdated = false;

  //free tab
  bool _showEvent = true;
  bool _showStat = true;

  @override
  void initState() {
    super.initState();
    final item = db.gameData.items[widget.itemId];
    switch (item?.category) {
      case ItemCategory.coin:
        _showStat = false;
        _showEvent = false;
        break;
      case ItemCategory.event:
      case ItemCategory.other:
        _showEvent = _showStat = false;
        if ([
          //
          4, 19, 5000, 5001, 5002, 5003, 2000,
        ].contains(widget.itemId)) {
          _showEvent = true;
        }
        break;
      case null:
        if ([Items.ember5, Items.ember4, Items.ember3]
            .contains(widget.itemId)) {
          _showStat = false;
        }
        break;
      default:
        break;
    }

    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: (_showStat ? 4 : 0) + (_showEvent ? 1 : 0) + 1,
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
    List<_TabInfo> tabs = [];

    if (_showStat) {
      tabs.addAll([
        _TabInfo(
          header: Tab(text: S.current.demands),
          view: db.onUserData((context, _) =>
              ItemCostSvtDetailTab(itemId: widget.itemId, matType: null)),
          actions: [viewTypeButton, sortButton, popupMenu],
        ),
        _TabInfo(
          header: Tab(text: S.current.consumed),
          view: db.onUserData((context, _) => ItemCostSvtDetailTab(
                itemId: widget.itemId,
                matType: SvtMatCostDetailType.consumed,
              )),
          actions: [viewTypeButton, sortButton, popupMenu],
        ),
        _TabInfo(
          header: Tab(text: S.current.free_quest),
          view: ItemObtainFreeTab(itemId: widget.itemId),
          actions: [popupMenu],
        ),
      ]);
    }
    if (_showEvent) {
      tabs.add(_TabInfo(
        header: Tab(text: S.current.event_title),
        view: ItemObtainEventTab(
            itemId: widget.itemId, showOutdated: showOutdated),
        actions: [filterOutdatedButton, popupMenu],
      ));
    }
    if (_showStat) {
      tabs.add(_TabInfo(
        header: Tab(text: S.current.interlude_and_rankup),
        view: ItemObtainInterludeTab(itemId: widget.itemId),
        actions: [sortButton, popupMenu],
      ));
    }
    tabs.add(_TabInfo(
      header: Tab(text: S.current.card_info),
      view: ItemInfoTab(itemId: widget.itemId),
      actions: [popupMenu],
    ));

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(Item.getName(widget.itemId), maxLines: 1),
        centerTitle: false,
        titleSpacing: 0,
        actions: tabs.getOrNull(curTab)?.actions ?? [],
        bottom: tabs.length < 2
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: tabs.map((e) => e.header).toList(),
              ),
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
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          if (_showStat || _showEvent)
            PopupMenuItem(
              child: Text(S.current.item_edit_owned_amount),
              onTap: () async {
                await null;
                if (!mounted) return;
                _showChangeAmount();
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
      tooltip: S.of(context).filter_shown_type,
      onPressed: () {
        setState(() {
          db.settings.display.itemDetailViewType = EnumUtil.next(
              ItemDetailViewType.values,
              db.settings.display.itemDetailViewType);
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
          db.settings.display.itemDetailSvtSort = EnumUtil.next(
              ItemDetailSvtSort.values, db.settings.display.itemDetailSvtSort);
          db.saveSettings();
          EasyLoading.showToast(
              _getSortTypeText(db.settings.display.itemDetailSvtSort));
        });
      },
    );
  }

  String _getSortTypeText(ItemDetailSvtSort type) {
    return '${S.current.filter_sort}-${[
      S.current.filter_sort_number,
      S.current.filter_sort_class,
      S.current.rarity
    ][type.index]}';
  }

  Widget get filterOutdatedButton {
    return IconButton(
      icon:
          Icon(showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
      tooltip: S.current.outdated,
      onPressed: () {
        setState(() {
          showOutdated = !showOutdated;
        });
      },
    );
  }

  void _showChangeAmount() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.item_edit_owned_amount),
          content: TextFormField(
            initialValue: (db.curUser.items[widget.itemId] ?? 0).toString(),
            keyboardType: TextInputType.number,
            onChanged: (s) {
              final v = int.tryParse(s);
              if (v != null) {
                db.curUser.items[widget.itemId] = v;
                EasyDebounce.debounce(
                  'item_owned_changed',
                  const Duration(milliseconds: 500),
                  () {
                    db.itemCenter.updateLeftItems();
                  },
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(S.current.cancel),
            )
          ],
        );
      },
    );
  }
}
