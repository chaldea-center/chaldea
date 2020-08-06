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
    String num2str(int n) => formatNum(n ?? 0, 'kilo', 10000);
    return StreamBuilder<ItemStatistics>(
        initialData: db.itemStat,
        stream: db.itemStat.onUpdated.stream,
        builder: (context, snapshot) {
          final statistics = snapshot.data;
          final counts = statistics.svtItemDetail.getItemCounts(favorite);
          final details = statistics.svtItemDetail.getCountByItem(favorite);
          List<Widget> children = [
            CustomTile(
              title: Text('剩余 ${num2str(statistics.leftItems[itemKey])}\n'
                  '拥有 ${num2str(db.curUser.items[itemKey])} '
                  '活动 ${num2str(statistics.eventItems[itemKey])}'),
              trailing: Text(
                '共需 ${num2str(counts.summation[itemKey])}\n' +
                    counts.values.map((v) => num2str(v[itemKey])).join('/'),
                textAlign: TextAlign.end,
              ),
            ),
          ];
          if (viewType == 0) {
            for (int i in [0, 1, 2]) {
              children.add(Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTile(
                    title: Text(['灵基再临', '技能升级', '灵衣开放'][i]),
                    trailing: Text(formatNum(counts.values[i][itemKey], 'decimal', 10000)),
                  ),
                  _buildSvtIconGrid(context, details.values[i][itemKey],
                      highlight: favorite == false),
                ],
              ));
            }
          } else if (viewType == 1) {
            children.add(_buildSvtIconGrid(context, details.summation[itemKey],
                highlight: favorite == false));
          } else {
            children.addAll(buildSvtList(context, details));
          }

          return ListView(
            children: divideTiles(children),
          );
        });
  }

  Widget _buildSvtIconGrid(BuildContext context, Map<int, int> src, {bool highlight = false}) {
    List<Widget> children = [];
    var sortedSvts = sortSvts(src.keys.toList());
    sortedSvts.forEach((svtNo) {
      final svt = db.gameData.servants[svtNo];
      final num = src[svtNo];
      bool showShadow = highlight && db.curUser.servants[svtNo]?.curVal?.favorite == true;
      if (num > 0) {
        children.add(
          Padding(
            padding: EdgeInsets.all(3),
            child: Container(
              decoration: showShadow
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent, blurRadius: 1.5, spreadRadius: 2),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      shape: BoxShape.rectangle,
                    )
                  : null,
              child: ImageWithText(
                image: Image(image: db.getIconImage(svt.icon)),
                text: formatNum(num, 'kilo', 10000),
                padding: EdgeInsets.only(right: 5, bottom: 16),
                onTap: () {
                  SplitRoute.push(context, builder: (context) => ServantDetailPage(svt));
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
        crossAxisCount: isTablet(context) ? 7 : 5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: children,
      );
    }
  }

  List<Widget> buildSvtList(BuildContext context, SvtParts<Map<String, Map<int, int>>> stat) {
    List<Widget> children = [];
    sortSvts(stat.summation[itemKey].keys.toList()).forEach((svtNo) {
      final allNum = stat.summation[itemKey][svtNo];
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
          SplitRoute.push(context, builder: (context) => ServantDetailPage(svt));
        },
      ));
    });

    return children;
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
    svts.sort((a, b) =>
        Servant.compare(db.gameData.servants[a], db.gameData.servants[b], sortKeys, sortReversed));
    return svts;
  }
}
