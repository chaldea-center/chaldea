import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';
import '../item/item.dart';

class ItemStatTab extends StatefulWidget {
  final bool demandMode;
  ItemStatTab({super.key, required this.demandMode});

  @override
  _ItemStatTabState createState() => _ItemStatTabState();
}

class _ItemStatTabState extends State<ItemStatTab> {
  late ScrollController _scrollController;
  Map<int, int> shownItems = {};
  final svtParts = FilterGroupData<int>();

  bool get demandMode => widget.demandMode;
  // consume
  bool includeOwnedItems = false;
  // demand
  bool subtractOwnedItems = false;
  bool subtractEventItems = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (demandMode) {
      calculateDemand();
    } else {
      calculateConsumed();
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
              CustomTile(
                color: Theme.of(context).cardColor,
                leading: db.getIconImage(Items.qp?.borderedIcon, height: 56),
                title: Text((shownItems[Items.qpId] ?? 0).format(compact: false, groupSeparator: ',')),
                onTap: () => Items.qp?.routeTo(),
              ),
              SharedBuilder.groupItems(
                context: context,
                items: Map.of(shownItems)..remove(Items.qpId),
                onTap: (itemId) {
                  router.push(
                    url: Routes.itemI(itemId),
                    child: ItemDetailPage(itemId: itemId, initialTabIndex: demandMode ? 0 : 1),
                  );
                },
              )
            ],
          ),
        ),
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<int>(
          options: List.generate(5, (index) => index),
          values: svtParts,
          combined: true,
          shrinkWrap: true,
          optionBuilder: (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Text([
                  S.current.ascension_short,
                  S.current.active_skill_short,
                  S.current.append_skill_short,
                  S.current.costume,
                  S.current.general_special,
                ][index]),
              ),
            );
          },
          onFilterChanged: (v, _) {
            setState(() {});
          },
        ),
        Wrap(
          spacing: 4,
          runSpacing: 2,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!demandMode)
              CheckboxWithLabel(
                value: includeOwnedItems,
                label: Text(S.current.item_stat_include_owned),
                onChanged: (v) {
                  setState(() {
                    if (v != null) includeOwnedItems = v;
                  });
                },
              ),
            if (demandMode) ...[
              CheckboxWithLabel(
                value: subtractOwnedItems,
                label: Text(S.current.item_stat_sub_owned),
                onChanged: (v) {
                  setState(() {
                    subtractOwnedItems = v ?? subtractOwnedItems;
                  });
                },
              ),
              CheckboxWithLabel(
                value: subtractEventItems,
                label: Text(S.current.item_stat_sub_event),
                onChanged: (v) {
                  setState(() {
                    subtractEventItems = v ?? subtractEventItems;
                  });
                },
              ),
            ]
          ],
        ),
      ],
    );
  }

  void calculateConsumed() {
    shownItems.clear();
    final emptyPlan = SvtStatus();
    emptyPlan.cur.favorite = true;
    db.curUser.servants.forEach((no, svtStat) {
      if (!svtStat.favorite) return;
      if (!db.gameData.servantsWithDup.containsKey(no)) {
        print('No $no: ${db.gameData.servantsWithDup.length}');
        return;
      }
      final svt = db.gameData.servantsWithDup[no]!;
      final detail = db.itemCenter.calcOneSvt(svt, emptyPlan.cur, svtStat.cur);
      Maths.sumDict(
        [
          shownItems,
          if (svtParts.options.isEmpty) detail.all,
          if (svtParts.options.isNotEmpty)
            ...List.generate(
              detail.parts.length,
              (index) => svtParts.options.contains(index) ? detail.parts[index] : <int, int>{},
            ),
        ],
        inPlace: true,
      );
    });
    Maths.sumDict([shownItems, if (includeOwnedItems) db.curUser.items], inPlace: true);
    shownItems.removeWhere((key, value) {
      return value <= 0;
    });
  }

  void calculateDemand() {
    shownItems.clear();
    if (svtParts.options.isEmpty) {
      shownItems = Map.of(db.itemCenter.statSvtDemands);
    } else {
      db.curUser.servants.forEach((no, svtStat) {
        if (!svtStat.favorite) return;
        final svt = db.gameData.servantsWithDup[no];
        if (svt == null) {
          print('No $no: ${db.gameData.servantsWithDup.length}');
          return;
        }
        final detail = db.itemCenter.calcOneSvt(svt, svtStat.cur, db.curUser.svtPlanOf(no));
        Maths.sumDict(
          [
            shownItems,
            ...List.generate(
              detail.parts.length,
              (index) => svtParts.options.contains(index) ? detail.parts[index] : <int, int>{},
            ),
          ],
          inPlace: true,
        );
      });
    }
    Maths.sumDict([
      shownItems,
      if (subtractOwnedItems) Maths.multiplyDict(db.curUser.items, -1),
      if (subtractEventItems) Maths.multiplyDict(db.itemCenter.statObtain, -1),
    ], inPlace: true);
    shownItems.removeWhere((key, value) {
      return value <= 0;
    });
  }
}
