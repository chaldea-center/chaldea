import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/servant/servant_detail.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    statistics = (widget.statistics ??
        ItemCostStatistics(db.gameData, db.curPlan.servants));
  }

  List<Widget> getSvtIconList(Map<int, int> src) {
    List<Widget> list = [];
    src.forEach((no, num) {
      final svt = db.gameData.servants[no];
      if (num > 0) {
        list.add(ImageWithText(
          image: Image.file(db.getIconFile(svt.icon), width: 110 * 0.5),
          text: num.toString(),
          bottom: ImageWithText.svtBottom,
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
    return list;
  }

  @override
  Widget build(BuildContext context) {
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
        shrinkWrap: true,
        children: <Widget>[
          TileGroup(
            tiles: <Widget>[
              CustomTile(
                title: Text('共需'),
                trailing: Text('${sum(counts.values)}'),
              ),
              CustomTile(
                title: Text('灵基再临'),
                trailing: Text('${counts.ascension}'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: getSvtIconList(svtList.ascension)),
              ),
              CustomTile(
                title: Text('技能升级'),
                trailing: Text('${counts.skill}'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: getSvtIconList(svtList.skill)),
              ),
              CustomTile(
                title: Text('灵衣开放'),
                trailing: Text('${counts.dress}'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: getSvtIconList(svtList.dress)),
              )
            ],
          )
        ],
      ),
    );
  }
}
