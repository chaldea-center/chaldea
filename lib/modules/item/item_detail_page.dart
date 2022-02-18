import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/tabs/item_info_tab.dart';
import 'package:chaldea/modules/item/tabs/item_obtain_interlude.dart';

import 'tabs/item_obtain_event_page.dart';
import 'tabs/item_obtain_free_page.dart';
import 'tabs/item_servant_cost_page.dart';
import 'tabs/item_servant_demand_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemKey;
  final int initialTabIndex;

  ItemDetailPage({Key? key, required this.itemKey, this.initialTabIndex = 0})
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

  // svt
  int viewType = 0;

  // svt, quest
  int sortType = 0;

  // event
  bool filtrateOutdated = true;

  //free tab

  @override
  void initState() {
    super.initState();
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
        title: AutoSizeText(Item.lNameOf(widget.itemKey), maxLines: 1),
        centerTitle: false,
        titleSpacing: 0,
        actions: <Widget>[
          if (curTab == 0 || curTab == 1) viewTypeButton,
          if (curTab == 0 || curTab == 1 || curTab == 4) sortButton,
          if (curTab == 3) filterOutdatedButton,
          if (curTab == 0 || curTab == 4) favoriteButton,
        ],
        bottom: TabBar(
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
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ItemServantDemandPage(
            itemKey: widget.itemKey,
            favorite: favorite,
            viewType: viewType,
            sortType: sortType,
          ),
          ItemServantCostPage(
            itemKey: widget.itemKey,
            viewType: viewType,
            sortType: sortType,
          ),
          ItemObtainFreeTab(itemKey: widget.itemKey),
          ItemObtainEventPage(
              itemKey: widget.itemKey, filtrateOutdated: filtrateOutdated),
          ItemObtainInterludeTab(
              itemKey: widget.itemKey, favorite: favorite, sortType: sortType),
          ItemInfoTab(itemKey: widget.itemKey),
          // Container(child: Center(child: Text('Interludes'))),
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
          viewType = (viewType + 1) % 3;
        });
      },
    );
  }

  Widget get sortButton {
    return IconButton(
      icon: const Icon(Icons.sort),
      tooltip: S.of(context).filter_sort +
          '-' +
          [
            S.of(context).filter_sort_number,
            S.of(context).filter_sort_class,
            S.of(context).rarity
          ][sortType % 3],
      onPressed: () {
        setState(() {
          sortType = (sortType + 1) % 3;
        });
      },
    );
  }

  Widget get filterOutdatedButton {
    return IconButton(
      icon: Icon(filtrateOutdated ? Icons.timer : Icons.timer_off),
      tooltip: 'Outdated',
      onPressed: () {
        setState(() {
          filtrateOutdated = !filtrateOutdated;
        });
      },
    );
  }
}
