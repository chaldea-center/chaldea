import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemName;
  final ItemCostStatistics statistics;
  final ItemListPageState parent;

  const ItemDetailPage(this.itemName, {Key key, this.statistics, this.parent})
      : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  List<List<Widget>> tiles;
  bool planned = true;
  ItemCostStatistics statistics;
  PartSet<String> panelTitles = PartSet(
      ascension: '灵基再临', skill: '技能升级', dress: '灵衣开放');

  @override
  void initState() {
    super.initState();
    statistics = (widget.statistics ??
        ItemCostStatistics(db.gameData, db.curPlan.servants));
  }

  Widget getSvtIconList(Map<int, int> src) {
    List<Widget> list = [];
    src.forEach((no, num) {
      final svt = db.gameData.servants[no];
      if (num > 0) {
        list.add(ImageWithText(
          image: Image.file(db.getIconFile(svt.icon)),
          text: formatNumToString(num,'kilo'),
          padding: EdgeInsets.only(right: 5, bottom: 16),
          onTap: () {
            Navigator.of(context)
                .push(SplitRoute(builder: (context) => ServantDetailPage(svt)))
                .then((_) {
              statistics.update(db.gameData, db.curPlan.servants);
              widget.parent?.setState(() {});
            });
          },
        ));
      }
    });
    if (list.isEmpty) {
      return Container();
    }
    return GridView.count(
        crossAxisCount: 6,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: list);
  }

  @override
  Widget build(BuildContext context) {
    //todo: add list view by svt (no ascension/skill/dress classification)
    final svtList = statistics.getSvtListOfItem(widget.itemName, planned);
    final counts = statistics.getNumOfItem(widget.itemName, planned);
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
            tiles: <Widget>[
              CustomTile(
                title: Text('共需'),
                trailing: Text(formatNumToString(sum(counts.values),'decimal')),
              ),
              for(int i in[0, 1, 2])
                Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  CustomTile(
                    title: Text(panelTitles.values[i]),
                    trailing: Text(formatNumToString(counts.values[i],'decimal')),
                  ),
                  getSvtIconList(svtList.values[i]),
                ],)
            ],
          )
        ],
      ),
    );
  }
}
