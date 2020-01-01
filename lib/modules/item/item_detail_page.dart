import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

import 'item_list_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemKey;
  final ItemListPageState parent;

  const ItemDetailPage(this.itemKey, {Key key, this.parent}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool favorite = true;
  int viewType = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.itemKey),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  viewType = (viewType + 1) % 3;
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
          Tab(text: 'Servants'),
          Tab(text: 'Free'),
          Tab(text: 'Events'),
          Tab(text: 'Interludes'),
        ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          KeepAliveBuilder(builder: (_) => buildSvtTab()),
          Container(child: Center(child: Text('Free'))),
          Container(child: Center(child: Text('Events'))),
          Container(child: Center(child: Text('Interludes'))),
        ],
      ),
    );
  }

  Widget buildSvtTab() {
    final detail = db.runtimeData.itemStatistics.svtItemDetail;
    final counts = favorite ? detail.planItemCounts : detail.allItemCounts;
    final svtsDetail =
        favorite ? detail.planCountByItem : detail.allCountByItem;
    Widget contents;
    if (viewType == 0) {
      List<Widget> children = [];
      for (int i in [0, 1, 2]) {
        children.add(Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomTile(
              title: Text(['灵基再临', '技能升级', '灵衣开放'][i]),
              trailing: Text(formatNumToString(
                  counts.values[i][widget.itemKey], 'decimal')),
            ),
            _buildSvtIconGrid(svtsDetail.values[i][widget.itemKey],
                highlight: favorite == false),
          ],
        ));
      }
      contents = SingleChildScrollView(child: TileGroup(children: children));
    } else if (viewType == 1) {
      contents = _buildSvtIconGrid(svtsDetail.summation[widget.itemKey],
          scrollable: true, highlight: favorite == false);
    } else {
      contents = buildSvtList(svtsDetail);
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: CustomTile(
            title: Text('共需  ' +
                counts.values
                    .map((v) => (v[widget.itemKey] ?? 0).toString())
                    .join('/')),
            trailing: Text(
              formatNumToString(
                  counts.summation[widget.itemKey] ?? 0, 'decimal'),
            ),
          ),
        ),
        Expanded(child: contents),
      ],
    );
  }

  Widget _buildSvtIconGrid(Map<int, int> src,
      {bool scrollable = false, bool highlight = false}) {
    List<Widget> children = [];
    var sortedSvts = src.keys.toList()
      ..sort((a, b) {
        return Servant.compare(
            db.gameData.servants[a],
            db.gameData.servants[b],
            [SvtCompare.className, SvtCompare.rarity, SvtCompare.no],
            [false, true, false]);
      });
    sortedSvts.forEach((no) {
      final svt = db.gameData.servants[no];
      final num = src[no];
      bool showShadow =
          highlight && db.curUser.servants[no]?.curVal?.favorite == true;
      if (num > 0) {
        children.add(
          Padding(
            padding: EdgeInsets.all(3),
            child: Container(
              decoration: showShadow
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent,
                          blurRadius: 1.5,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      shape: BoxShape.rectangle,
                    )
                  : null,
              child: ImageWithText(
                image: Image(image: db.getIconImage(svt.icon)),
                text: formatNumToString(num, 'kilo'),
                padding: EdgeInsets.only(right: 5, bottom: 16),
                onTap: () {
                  Navigator.of(context)
                      .push(SplitRoute(
                          builder: (context) => ServantDetailPage(svt)))
                      .then((_) {
                    db.runtimeData.itemStatistics.updateSvtItems(db.curUser);
                    widget.parent?.setState(() {});
                  });
                },
              ),
            ),
          ),
        );
      }
    });
    if (children.isEmpty) {
      return Container();
    } else {
      return GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: scrollable ? null : NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: children,
      );
    }
  }

  Widget buildSvtList(SvtParts<Map<String, Map<int, int>>> stat) {
    List<Widget> children = [];
    stat.summation[widget.itemKey].forEach((svtNo, allNum) {
      if (allNum <= 0) {
        return;
      }
      final svt = db.gameData.servants[svtNo];
      bool _planned = db.curUser.servants[svtNo]?.curVal?.favorite == true;
      final textStyle = _planned ? TextStyle(color: Colors.blueAccent) : null;
      final ascensionNum = stat.ascension[widget.itemKey][svtNo] ?? 0,
          skillNum = stat.skill[widget.itemKey][svtNo] ?? 0,
          dressNum = stat.dress[widget.itemKey][svtNo] ?? 0;
      children.add(CustomTile(
        leading: Image(image: db.getIconImage(svt.icon), height: 144 * 0.4),
        title: Text('${svt.info.name}', style: textStyle),
        subtitle: Text(
          '$allNum/$ascensionNum/$skillNum/$dressNum',
          style: textStyle,
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          SplitRoute.push(context,
              builder: (context) => ServantDetailPage(svt));
        },
      ));
    });

    return ListView.separated(
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
