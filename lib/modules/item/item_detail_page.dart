import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

import 'item_list_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemName;
  final ItemsOfSvts statistics;
  final ItemListPageState parent;

  const ItemDetailPage(this.itemName, {Key key, this.statistics, this.parent})
      : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  List<List<Widget>> tiles;
  bool planned = true;
  PartSet<String> panelTitles =
      PartSet(ascension: '灵基再临', skill: '技能升级', dress: '灵衣开放');

  @override
  void initState() {
    super.initState();
  }

  Widget getSvtIconList(Map<int, int> src) {
    if (src.isEmpty) {
      return Container();
    }
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
      if (num > 0) {
        children.add(ImageWithText(
          image: Image(image: db.getIconFile(svt.icon)),
          text: formatNumToString(num, 'kilo'),
          padding: EdgeInsets.only(right: 5, bottom: 16),
          onTap: () {
            Navigator.of(context)
                .push(SplitRoute(builder: (context) => ServantDetailPage(svt)))
                .then((_) {
              db.runtimeData.itemsOfSvts
                  .update(db.curUser.servants, db.curUser.curPlan2);
              widget.parent?.setState(() {});
            });
          },
        ));
      }
    });
    return GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: children);
  }

  @override
  Widget build(BuildContext context) {
    //todo: add list view by svt (no ascension/skill/dress classification)
    final svtList =
        db.runtimeData.itemsOfSvts.getSvtListOfItem(widget.itemName, planned);
    final counts =
        db.runtimeData.itemsOfSvts.getNumOfItem(widget.itemName, planned);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.itemName),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                  planned ? Icons.check_circle : Icons.check_circle_outline),
              onPressed: () {
                setState(() {
                  planned = !planned;
                });
              })
        ],
      ),
      body: ListView(
        children: <Widget>[
          TileGroup(
            children: <Widget>[
              CustomTile(
                title: Text('共需'),
                trailing:
                    Text(formatNumToString(sum(counts.values), 'decimal')),
              ),
              for (int i in [0, 1, 2])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomTile(
                      title: Text(panelTitles.values[i]),
                      trailing:
                          Text(formatNumToString(counts.values[i], 'decimal')),
                    ),
                    getSvtIconList(svtList.values[i]),
                  ],
                )
            ],
          )
        ],
      ),
    );
  }
}
