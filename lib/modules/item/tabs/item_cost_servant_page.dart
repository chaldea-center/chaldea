import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

class ItemCostServantPage extends StatelessWidget {
  final String itemKey;
  final bool favorite;
  final int viewType;
  final int sortType;

  ItemCostServantPage({
    @required this.itemKey,
    this.favorite = true,
    this.viewType = 0,
    this.sortType = 0,
  });

  @override
  Widget build(BuildContext context) {
    final statistics = db.runtimeData.itemStatistics;
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
              trailing:
                  Text(formatNumToString(counts.values[i][itemKey], 'decimal')),
            ),
            _buildSvtIconGrid(context, svtsDetail.values[i][itemKey],
                highlight: favorite == false),
          ],
        ));
      }
      contents = SingleChildScrollView(child: TileGroup(children: children));
    } else if (viewType == 1) {
      contents = _buildSvtIconGrid(context, svtsDetail.summation[itemKey],
          scrollable: true, highlight: favorite == false);
    } else {
      contents = buildSvtList(context, svtsDetail);
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: CustomTile(
            title: Text('拥有 ${db.curUser.items[itemKey] ?? 0}  '
                '剩余 ${statistics.leftItems[itemKey] ?? 0}'),
            trailing: Text(
              '共需 ${counts.summation[itemKey]}'
              '(${counts.values.map((v) => (v[itemKey] ?? 0).toString()).join('/')})',
            ),
          ),
        ),
        Expanded(child: contents),
      ],
    );
  }

  Widget _buildSvtIconGrid(BuildContext context, Map<int, int> src,
      {bool scrollable = false, bool highlight = false}) {
    List<Widget> children = [];
    var sortedSvts = sortSvts(src.keys.toList());
    sortedSvts.forEach((svtNo) {
      final svt = db.gameData.servants[svtNo];
      final num = src[svtNo];
      bool showShadow =
          highlight && db.curUser.servants[svtNo]?.curVal?.favorite == true;
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
                      .then((_) {});
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

  Widget buildSvtList(
      BuildContext context, SvtParts<Map<String, Map<int, int>>> stat) {
    List<Widget> children = [];
    sortSvts(stat.summation[itemKey].keys.toList()).forEach((svtNo){
      final allNum=stat.summation[itemKey][svtNo];
      if (allNum <= 0) {
        return;
      }
      final svt = db.gameData.servants[svtNo];
      bool _planned = db.curUser.servants[svtNo]?.curVal?.favorite == true;
      final textStyle = _planned ? TextStyle(color: Colors.blueAccent) : null;
      final ascensionNum = stat.ascension[itemKey][svtNo] ?? 0,
          skillNum = stat.skill[itemKey][svtNo] ?? 0,
          dressNum = stat.dress[itemKey][svtNo] ?? 0;
      children.add(CustomTile(
        leading: Image(image: db.getIconImage(svt.icon), height: 144 * 0.4),
        title: Text('${svt.info.name}', style: textStyle),
        subtitle: Text(
          '$allNum($ascensionNum/$skillNum/$dressNum)',
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

  List<int> sortSvts(List<int> svts) {
    List<SvtCompare> sortKeys;
    List<bool> sortReversed;
    if (sortType == 0) {
      sortKeys = [SvtCompare.no];
      sortReversed = [true];
    } else if (sortType == 1) {
      sortKeys = [SvtCompare.className, SvtCompare.rarity, SvtCompare.no];
      sortReversed = [false, true, true];
    } else {
      sortKeys = [SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
      sortReversed = [true, false, true];
    }
    svts.sort((a, b) => Servant.compare(db.gameData.servants[a],
        db.gameData.servants[b], sortKeys, sortReversed));
    return svts;
  }
}
