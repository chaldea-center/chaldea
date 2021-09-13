import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';
import 'package:chaldea/modules/shared/item_related_builder.dart';

class ItemCostServantPage extends StatelessWidget {
  final String itemKey;
  final bool favorite;

  /// [viewType] for svt cost tab
  /// 0 - Header+Grid of ascension/skill/dress/grail,
  /// 1 - grid of servants
  /// 2 - list of servants
  final int viewType;
  final int sortType;

  const ItemCostServantPage({
    Key? key,
    required this.itemKey,
    this.favorite = true,
    this.viewType = 0,
    this.sortType = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(db.itemStat.svtItemDetail.allCountBySvt.skill);
    String num2str(int? n) =>
        formatNumber(n ?? 0, compact: true, minVal: 10000);
    return db.streamBuilder((context) {
      final stat = db.itemStat;
      final counts = stat.svtItemDetail.getItemCounts(favorite);
      final details = stat.svtItemDetail.getCountByItem(favorite);
      List<Widget> children = [
        CustomTile(
          title: Text(
              '${S.current.item_left} ${num2str(stat.leftItems[itemKey])}\n'
              '${S.current.item_own} ${num2str(db.curUser.items[itemKey])} '
              '${S.current.event_title} ${num2str(stat.eventItems[itemKey])}'),
          trailing: Text(
            '${S.current.item_total_demand} ${num2str(counts.summation![itemKey])}\n' +
                counts
                    .valuesIfExtra(itemKey)
                    .map((v) => num2str(v[itemKey]))
                    .join('/'),
            textAlign: TextAlign.end,
          ),
        ),
      ];
      if (viewType == 0) {
        // 0 ascension 1 skill 2 dress 3 append 4 extra
        final headers = [
          S.current.ascension_up,
          S.current.active_skill,
          S.current.costume_unlock,
          S.current.append_skill,
          'Extra'
        ];
        for (int i = 0; i < headers.length; i++) {
          final _allSvtCounts =
              db.itemStat.svtItemDetail.allCountByItem.values[i][itemKey];
          bool _hasSvt = _allSvtCounts?.values.any((e) => e > 0) ?? false;
          if (_hasSvt) {
            children.add(Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTile(
                  title: Text(headers[i]),
                  trailing: Text(formatNumber(counts.values[i][itemKey] ?? 0,
                      minVal: 10000)),
                ),
                _buildSvtIconGrid(context, details.values[i][itemKey],
                    highlight: favorite == false),
              ],
            ));
          }
        }
      } else if (viewType == 1) {
        children.add(_buildSvtIconGrid(context, details.summation![itemKey],
            highlight: favorite == false));
      } else {
        children.addAll(buildSvtList(context, details));
      }
      if (itemKey == Items.servantCoin) {
        children.add(Center(
          child: Text(
            LocalizedText.of(
                chs: '\n通用从者硬币消耗总计中已减去专用从者硬币数',
                jpn: '\n通用のサーヴァントコインの総数は、専用のサーヴァントコインの数から差し引かれています。',
                eng:
                    '\nThe total cost of universal servant coins has been subtracted from dedicated servant coins.'),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ));
      }
      return ListView(
        children: divideTiles(children),
      );
    });
  }

  Widget _buildSvtIconGrid(BuildContext context, Map<int, int>? src,
      {bool highlight = false}) {
    src ??= {};
    List<Widget> children = [];
    var sortedSvts = sortSvts(src.keys.toList());
    sortedSvts.forEach((svtNo) {
      final svt = db.gameData.servantsWithUser[svtNo];
      if (svt == null) return;
      final num = src![svtNo]!;
      bool shouldHighlight =
          highlight && db.curUser.svtStatusOf(svtNo).favorite;
      if (num > 0) {
        Widget avatar = svt.iconBuilder(
          context: context,
          text: formatNumber(num, compact: true, minVal: 10000),
          textPadding: const EdgeInsets.only(right: 2, bottom: 12),
        );
        if (shouldHighlight) {
          avatar = Stack(
            alignment: Alignment.topRight,
            children: [
              avatar,
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(3)),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          );
        }
        children.add(avatar);
      }
    });
    return buildGridIcons(context: context, children: children);
  }

  List<Widget> buildSvtList(
      BuildContext context, SvtParts<Map<String, Map<int, int>>> details) {
    List<Widget> children = [];
    if (!details.summation!.containsKey(itemKey)) {
      return children;
    }
    sortSvts(details.summation![itemKey]!.keys.toList()).forEach((svtNo) {
      final allNum = details.summation![itemKey]?[svtNo] ?? 0;
      if (allNum <= 0) {
        return;
      }
      final svt = db.gameData.servantsWithUser[svtNo]!;
      bool _planned = db.curUser.svtStatusOf(svtNo).favorite;
      final textStyle =
          _planned ? const TextStyle(color: Colors.blueAccent) : null;
      final ascensionNum = details.ascension[itemKey]?[svtNo] ?? 0,
          skillNum = details.skill[itemKey]?[svtNo] ?? 0,
          dressNum = details.dress[itemKey]?[svtNo] ?? 0,
          appendNum = details.appendSkill[itemKey]?[svtNo] ?? 0,
          extraNum = details.extra[itemKey]?[svtNo] ?? 0;
      children.add(CustomTile(
        leading: db.getIconImage(svt.icon, width: 52),
        title: Text(svt.info.name, style: textStyle),
        subtitle: Text(
          Items.extraPlanningItems.contains(itemKey)
              ? '$extraNum'
              : '$allNum($ascensionNum/$skillNum/$dressNum/$appendNum)',
          style: textStyle,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          SplitRoute.push(context, ServantDetailPage(svt));
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
    svts.sort((a, b) => Servant.compare(
        db.gameData.servantsWithUser[a], db.gameData.servantsWithUser[b],
        keys: sortKeys, reversed: sortReversed, user: db.curUser));
    return svts;
  }
}
