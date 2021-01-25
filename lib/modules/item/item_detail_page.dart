import 'package:chaldea/components/components.dart';

import 'tabs/item_cost_servant_page.dart';
import 'tabs/item_obtain_event_page.dart';
import 'tabs/item_obtain_free_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemKey;

  const ItemDetailPage(this.itemKey, {Key key}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  // svt tab
  bool favorite = true;
  int viewType = 0;
  int sortType = 0;

  //free tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text(Item.localizedNameOf(widget.itemKey)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.view_carousel),
              onPressed: () {
                setState(() {
                  viewType = (viewType + 1) % 3;
                });
              }),
          IconButton(
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
              }),
          IconButton(
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                setState(() {
                  favorite = !favorite;
                });
              }),
        ],
        bottom: TabBar(controller: _tabController, tabs: [
          Tab(text: S.of(context).servant),
          Tab(text: S.of(context).free_quest),
          Tab(text: S.of(context).event_title),
          // Tab(text: 'Interludes'),
        ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ItemCostServantPage(
              itemKey: widget.itemKey,
              favorite: favorite,
              viewType: viewType,
              sortType: sortType),
          ItemObtainFreeTab(itemKey: widget.itemKey),
          ItemObtainEventPage(itemKey: widget.itemKey),
          // Container(child: Center(child: Text('Interludes'))),
        ],
      ),
    );
  }
}
