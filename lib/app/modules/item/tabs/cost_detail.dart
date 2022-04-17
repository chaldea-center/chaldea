import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ItemCostSvtDetailTab extends StatefulWidget {
  final int itemId;
  final SvtMatCostDetailType? matType;

  const ItemCostSvtDetailTab({
    Key? key,
    required this.itemId,
    this.matType,
  }) : super(key: key);

  @override
  State<ItemCostSvtDetailTab> createState() => _ItemCostSvtDetailTabState();
}

class _ItemCostSvtDetailTabState extends State<ItemCostSvtDetailTab> {
  int get itemId => widget.itemId;
  bool _favorite = true;

  SvtMatCostDetailType get matType =>
      widget.matType ??
      (_favorite ? SvtMatCostDetailType.demands : SvtMatCostDetailType.full);

  @override
  Widget build(BuildContext context) {
    String num2str(int? n) => (n ?? 0).format(minVal: 10000);

    final stat = db.itemCenter;
    final details = stat.getItemCostDetail(itemId, matType);
    final svtDemands = SvtMatCostDetail<int>(() => 0);
    for (final svtDetail in details.values) {
      svtDemands.updateFrom<int>(svtDetail, (p1, p2) => p1 + p2);
    }

    Widget header = CustomTile(
      title: Text('${S.current.item_left} ${num2str(stat.itemLeft[itemId])}\n'
          '${S.current.item_own} ${num2str(db.curUser.items[itemId])} '
          '${S.current.event_title} ${num2str(stat.statObtain[itemId])}'),
      trailing: Text(
        '${S.current.item_total_demand} ${num2str(svtDemands.all)}\n'
        '${svtDemands.parts.map((e) => num2str(e)).join('/')}',
        textAlign: TextAlign.end,
      ),
    );

    /////////////////////////////////////////////////////////
    List<Widget> children = [
      if (widget.matType == null)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (final fav in [true, false])
              RadioWithLabel<bool>(
                value: fav,
                groupValue: _favorite,
                label: Text(fav ? S.current.favorite : 'All'),
                onChanged: (v) {
                  if (v != null) {
                    _favorite = v;
                  }
                  setState(() {});
                },
              ),
          ],
        ),
      header
    ];
    if (db.settings.display.itemDetailViewType ==
        ItemDetailViewType.separated) {
      // 0 ascension 1 skill 2 dress 3 append 4 extra
      final headers = [
        S.current.ascension_up,
        S.current.active_skill,
        S.current.append_skill,
        S.current.costume_unlock,
        'Special'
      ];
      for (int i = 0; i < headers.length; i++) {
        Map<int, int> partDetail = {};
        details.forEach((svtId, detail) {
          if (detail.parts[i] > 0) {
            partDetail[svtId] = detail.parts[i];
          }
        });
        if (partDetail.isNotEmpty) {
          children.add(Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTile(
                title: Text(headers[i]),
                trailing: Text(num2str(svtDemands.parts[i])),
              ),
              _buildSvtIconGrid(context, partDetail,
                  highlight: matType == SvtMatCostDetailType.full),
            ],
          ));
        }
      }
    } else if (db.settings.display.itemDetailViewType ==
        ItemDetailViewType.grid) {
      children.add(_buildSvtIconGrid(
          context, details.map((key, value) => MapEntry(key, value.all)),
          highlight: matType == SvtMatCostDetailType.full));
    } else {
      children.addAll(buildSvtList(context, details));
    }
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) =>
          index == 0 ? const SizedBox() : kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget _buildSvtIconGrid(BuildContext context, Map<int, int> src,
      {bool highlight = false}) {
    List<Widget> children = [];
    var sortedSvts = sortSvts(src.keys.toList());
    sortedSvts.forEach((svtNo) {
      final svt = db.gameData.servants[svtNo];
      if (svt == null) return;
      final count = src[svtNo]!;
      bool shouldHighlight =
          highlight && db.curUser.svtStatusOf(svtNo).cur.favorite;
      if (count > 0) {
        Widget avatar = svt.iconBuilder(
          context: context,
          text: count.format(),
          textPadding: const EdgeInsets.only(right: 2, bottom: 12),
          overrideIcon: svt.customIcon,
        );
        if (shouldHighlight) {
          avatar = Stack(
            children: [
              avatar,
              Positioned(
                top: 2,
                right: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(3)),
                  child: const Padding(
                    padding: EdgeInsets.all(1.6),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        children.add(Padding(padding: const EdgeInsets.all(1), child: avatar));
      }
    });
    return GridView.extent(
      maxCrossAxisExtent: 72,
      childAspectRatio: 132 / 144,
      children: children,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsetsDirectional.only(
          start: 16, top: 3, bottom: 3, end: 10),
    );
  }

  List<Widget> buildSvtList(
      BuildContext context, Map<int, SvtMatCostDetail<int>> details) {
    List<Widget> children = [];

    for (final svtNo in sortSvts(details.keys.toList())) {
      final detail = details[svtNo]!;
      if (detail.all <= 0) continue;

      final svt = db.gameData.servants[svtNo];
      bool _planned = db.curUser.svtStatusOf(svtNo).cur.favorite;
      final textStyle = _planned && matType == SvtMatCostDetailType.full
          ? TextStyle(color: Theme.of(context).colorScheme.secondary)
          : const TextStyle();
      children.add(CustomTile(
        leading: db.getIconImage(svt?.borderedIcon, width: 42),
        title: Text(svt?.lName.l ?? 'No.$svtNo', style: textStyle, maxLines: 1),
        subtitle: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text('${detail.all} (${detail.parts.join("/")})',
              style: textStyle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          router.push(url: Routes.servantI(svtNo), detail: true);
        },
      ));
    }

    return children;
  }

  List<int> sortSvts(List<int> svts) {
    List<SvtCompare> sortKeys;
    List<bool> sortReversed;
    switch (db.settings.display.itemDetailSvtSort) {
      case ItemDetailSvtSort.collectionNo:
        sortKeys = [SvtCompare.no];
        sortReversed = [true];
        break;
      case ItemDetailSvtSort.clsName:
        sortKeys = [SvtCompare.className, SvtCompare.rarity, SvtCompare.no];
        sortReversed = [false, true, true];
        break;
      case ItemDetailSvtSort.rarity:
        sortKeys = [SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
        sortReversed = [true, false, true];
        break;
    }
    svts.sort((a, b) => SvtFilterData.compare(
        db.gameData.servants[a], db.gameData.servants[b],
        keys: sortKeys, reversed: sortReversed, user: db.curUser));
    return svts;
  }
}
