import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

import 'item_list_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemKey;
  final ItemsOfSvts statistics;
  final ItemListPageState parent;

  const ItemDetailPage(this.itemKey, {Key key, this.statistics, this.parent})
      : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  List<List<Widget>> tiles;
  bool favorite = true;
  bool split = true;
  PartSet<String> panelTitles =
      PartSet(ascension: '灵基再临', skill: '技能升级', dress: '灵衣开放');

  @override
  void initState() {
    super.initState();
  }

  Widget buildSvtIconGrid(Map<int, int> src) {
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
              db.runtimeData.itemStatistics.updateSvtItems(db.curUser);
              widget.parent?.setState(() {});
            });
          },
        ));
      }
    });
    if (children.isEmpty) {
      return Container();
    } else {
      return GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: children,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //todo: add list view by svt (no ascension/skill/dress classification)
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.itemKey),
        actions: <Widget>[
          IconButton(
              icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                setState(() {
                  favorite = !favorite;
                });
              }),
          IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  split = !split;
                });
              })
        ],
      ),
      body: buildContent(),
    );
  }

  Widget buildContent() {
    final detail = db.runtimeData.itemStatistics.svtItemDetail;
    final counts = favorite ? detail.planItemCounts : detail.allItemCounts;
    final svtsDetail =
        favorite ? detail.planCountByItem : detail.allCountByItem;
    List<Widget> children = [];
    children.add(CustomTile(
      title: Text('共需'),
      trailing: Text(
        formatNumToString(counts.summation[widget.itemKey] ?? 0, 'decimal'),
      ),
    ));
    if (split) {
      for (int i in [0, 1, 2]) {
        children.add(Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomTile(
              title: Text(panelTitles.values[i]),
              trailing: Text(formatNumToString(
                  counts.values[i][widget.itemKey], 'decimal')),
            ),
            buildSvtIconGrid(svtsDetail.values[i][widget.itemKey]),
          ],
        ));
      }
    } else {
      children.add(buildSvtIconGrid(svtsDetail.summation[widget.itemKey]));
    }
    return SingleChildScrollView(
      child: TileGroup(children: children),
    );
  }
}
