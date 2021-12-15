import 'dart:convert';

import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';
import 'package:chaldea/modules/shared/common_builders.dart';

class ItemServantCostPage extends StatefulWidget {
  final String itemKey;

  /// [viewType] for svt cost tab
  /// 0 - Header+Grid of ascension/skill/dress/grail,
  /// 1 - grid of servants
  /// 2 - list of servants
  final int viewType;
  final int sortType;

  const ItemServantCostPage({
    Key? key,
    required this.itemKey,
    this.viewType = 0,
    this.sortType = 0,
  }) : super(key: key);

  @override
  _ItemServantCostPageState createState() => _ItemServantCostPageState();
}

class _ItemServantCostPageState extends State<ItemServantCostPage> {
  String get itemKey => widget.itemKey;

  int get viewType => widget.viewType;

  int get sortType => widget.sortType;

  ItemStatistics? stat;

  @override
  void initState() {
    super.initState();
    final user = User(
      key: 'svt_cost_tmp',
      servants: db.curUser.servants.map((key, status) => MapEntry(
          key,
          ServantStatus(
            coin: 0,
            priority: status.priority,
            curVal: ServantPlan(favorite: status.curVal.favorite),
          ))),
      servantPlans: [
        db.curUser.servants.map((key, status) => MapEntry(
            key, ServantPlan.fromJson(jsonDecode(jsonEncode(status.curVal)))))
      ],
      duplicatedServants: db.curUser.duplicatedServants,
    );
    Future.delayed(kTabScrollDuration, () {
      stat = ItemStatistics(user: user);
      stat!.update(shouldBroadcast: false, lapse: Duration.zero);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(db.itemStat.svtItemDetail.allCountBySvt.skill);
    if (stat == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String num2str(int? n) =>
        formatNumber(n ?? 0, compact: true, minVal: 10000);

    final counts = stat!.svtItemDetail.getItemCounts();
    final details = stat!.svtItemDetail.getCountByItem();
    List<Widget> children = [
      CustomTile(
        title: Text(
            '${S.current.consumed} ${num2str(counts.summation![itemKey])}'),
        trailing: Text(
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
                  highlight: false),
            ],
          ));
        }
      }
    } else if (viewType == 1) {
      children.add(_buildSvtIconGrid(context, details.summation![itemKey],
          highlight: false));
    } else {
      children.addAll(buildSvtList(context, details));
    }
    return ListView(
      children: divideTiles(children),
    );
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
