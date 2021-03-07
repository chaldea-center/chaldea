//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/tabs/item_obtain_interlude.dart';

import 'tabs/item_cost_servant_page.dart';
import 'tabs/item_obtain_event_page.dart';
import 'tabs/item_obtain_free_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemKey;

  const ItemDetailPage({Key? key, required this.itemKey}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int curTab = 0;

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        curTab = _tabController.index;
      });
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
        leading: BackButton(),
        title: AutoSizeText(Item.localizedNameOf(widget.itemKey), maxLines: 1),
        centerTitle: false,
        actions: <Widget>[
          if (curTab == 0) viewTypeButton,
          if (curTab == 0 || curTab == 3) sortButton,
          if (curTab == 2) filterOutdatedButton,
          favoriteButton,
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: S.of(context).servant),
            Tab(text: S.of(context).free_quest),
            Tab(text: S.of(context).event_title),
            Tab(text: S.of(context).interlude_and_rankup),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ItemCostServantPage(
            itemKey: widget.itemKey,
            favorite: favorite,
            viewType: viewType,
            sortType: sortType,
          ),
          ItemObtainFreeTab(itemKey: widget.itemKey),
          ItemObtainEventPage(
              itemKey: widget.itemKey,
              favorite: favorite,
              filtrateOutdated: filtrateOutdated),
          ItemObtainInterludeTab(
              itemKey: widget.itemKey, favorite: favorite, sortType: sortType)
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
      icon: Icon(Icons.view_carousel),
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
      icon: Icon(Icons.sort),
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
