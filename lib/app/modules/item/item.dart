import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'tabs/cost_detail.dart';
import 'tabs/item_info.dart';
// import 'tabs/item_obtain_interlude.dart';
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

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int get curTab => _tabController.index;

  // all
  bool favorite = true;

  // event
  bool showOutdated = false;

  //free tab
  bool isSvtCoin = false;

  @override
  void initState() {
    super.initState();
    isSvtCoin = db2.gameData.items[widget.itemId]?.type == ItemType.svtCoin;
    _tabController = TabController(
        initialIndex: widget.initialTabIndex, length: 6, vsync: this);
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
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(Item.getName(widget.itemId), maxLines: 1),
        centerTitle: false,
        titleSpacing: 0,
        actions: isSvtCoin
            ? []
            : <Widget>[
                if (curTab == 0 || curTab == 1) viewTypeButton,
                if (curTab == 0 || curTab == 1 || curTab == 4) sortButton,
                if (curTab == 3) filterOutdatedButton,
                if (curTab == 0 || curTab == 4) favoriteButton,
              ],
        bottom: isSvtCoin
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: S.current.demands),
                  Tab(text: S.current.consumed),
                  Tab(text: S.current.free_quest),
                  Tab(text: S.current.event_title),
                  Tab(text: S.current.interlude_and_rankup),
                  Tab(text: S.current.card_info),
                ],
              ),
      ),
      body: isSvtCoin
          ? ItemInfoTab(itemId: widget.itemId)
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                db2.onUserData((context, _) => ItemCostSvtDetailTab(
                      itemId: widget.itemId,
                      matType: favorite
                          ? SvtMatCostDetailType.demands
                          : SvtMatCostDetailType.full,
                    )),
                db2.onUserData((context, _) => ItemCostSvtDetailTab(
                      itemId: widget.itemId,
                      matType: SvtMatCostDetailType.consumed,
                    )),
                ItemObtainFreeTab(itemId: widget.itemId),
                ItemObtainEventTab(
                    itemId: widget.itemId, showOutdated: showOutdated),
                ItemObtainInterludeTab(
                    itemId: widget.itemId, favorite: favorite),
                ItemInfoTab(itemId: widget.itemId),
              ],
            ),
    );
  }

  Widget get favoriteButton {
    return IconButton(
      icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
      tooltip: S.of(context).favorite,
      onPressed: () {
        setState(() {
          favorite = !favorite;
        });
      },
    );
  }

  Widget get viewTypeButton {
    return IconButton(
      icon: const Icon(Icons.view_carousel),
      tooltip: S.of(context).filter_shown_type,
      onPressed: () {
        setState(() {
          db2.settings.display.itemDetailViewType = EnumUtil.next(
              ItemDetailViewType.values,
              db2.settings.display.itemDetailViewType);
          db2.saveSettings();
        });
      },
    );
  }

  Widget get sortButton {
    return IconButton(
      icon: const Icon(Icons.sort),
      tooltip: _getSortTypeText(db2.settings.display.itemDetailSvtSort),
      onPressed: () {
        setState(() {
          db2.settings.display.itemDetailSvtSort = EnumUtil.next(
              ItemDetailSvtSort.values, db2.settings.display.itemDetailSvtSort);
          db2.saveSettings();
          EasyLoading.showToast(
              _getSortTypeText(db2.settings.display.itemDetailSvtSort));
        });
      },
    );
  }

  String _getSortTypeText(ItemDetailSvtSort type) {
    return S.current.filter_sort +
        '-' +
        [
          S.current.filter_sort_number,
          S.current.filter_sort_class,
          S.current.rarity
        ][type.index];
  }

  Widget get filterOutdatedButton {
    return IconButton(
      icon:
          Icon(showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
      tooltip: 'Outdated',
      onPressed: () {
        setState(() {
          showOutdated = !showOutdated;
        });
      },
    );
  }
}
