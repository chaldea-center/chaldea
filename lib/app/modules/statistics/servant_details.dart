import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/tools/item_center.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ServantDemandDetailStat extends StatefulWidget {
  ServantDemandDetailStat({super.key});

  @override
  State<ServantDemandDetailStat> createState() => _ServantDemandDetailStatState();
}

class _ServantDemandDetailStatState extends State<ServantDemandDetailStat> {
  final typeFilter = FilterRadioData<SvtMatCostDetailType>.nonnull(SvtMatCostDetailType.demands);
  SvtCompare sortOrder = SvtCompare.no;
  bool sortReversed = true;

  @override
  Widget build(BuildContext context) {
    final data = {
      for (final svt in db.gameData.servantsWithDup.values)
        svt: db.itemCenter.getSvtCostDetail(svt.collectionNo, typeFilter.radioValue ?? SvtMatCostDetailType.demands),
    };
    data.removeWhere((key, value) => value.all.values.every((v) => v <= 0));
    final servants = data.keys.toList();
    List<SvtCompare> orders;
    List<bool> reversed;
    switch (sortOrder) {
      case SvtCompare.className:
        orders = [sortOrder, SvtCompare.no];
        reversed = [sortReversed, false];
        break;
      case SvtCompare.rarity:
        orders = [sortOrder, SvtCompare.className, SvtCompare.no];
        reversed = [sortReversed, false, false];
        break;
      case SvtCompare.priority:
        orders = [sortOrder, SvtCompare.rarity, SvtCompare.className, SvtCompare.no];
        reversed = [sortReversed, true, false, false];
        break;
      default:
        orders = [sortOrder];
        reversed = [sortReversed];
    }
    servants.sort((a, b) => SvtFilterData.compare(a, b, keys: orders, reversed: reversed));
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => buildOne(servants[index], data[servants[index]]!),
            separatorBuilder: (_, _) => kDefaultDivider,
            itemCount: servants.length,
          ),
        ),
        kDefaultDivider,
        SafeArea(child: buttonBar),
      ],
    );
  }

  Widget buildOne(Servant svt, SvtMatCostDetail<Map<int, int>> detail) {
    final ratio = SplitRoute.isSplit(context) ? 1.5 : 1.0;
    return SimpleAccordion(
      key: ValueKey(svt),
      headerBuilder: (context, _) {
        final items = Item.sortMapByPriority(detail.all, reversed: true).entries;
        Widget child = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            svt.iconBuilder(context: context, width: 36 * ratio),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(child: SharedBuilder.itemGrid(context: context, items: items, width: 42 * ratio)),
                  ],
                ),
                textScaler: const TextScaler.linear(0.8),
              ),
            ),
          ],
        );
        return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: child);
      },
      contentBuilder: (context) {
        List<Widget> children = [];
        void _addPart(Map<int, int> items, String title) {
          items = Map.of(items)..removeWhere((key, value) => value <= 0);
          if (items.isEmpty) return;
          children.add(SHeader(title, padding: const EdgeInsetsDirectional.only(start: 0, top: 8.0, bottom: 4.0)));
          children.add(
            SharedBuilder.itemGrid(
              context: context,
              items: Item.sortMapByPriority(items, reversed: true).entries,
              width: 42 * .8 * ratio,
            ),
          );
        }

        _addPart(detail.ascension, S.current.ascension_up);
        _addPart(detail.activeSkill, S.current.active_skill);
        _addPart(detail.appendSkill, S.current.append_skill);
        _addPart(detail.costume, S.current.costume_unlock);
        _addPart(detail.special, S.current.general_special);

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(56 * ratio, 0, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }

  Widget get buttonBar {
    return OverflowBar(
      children: [
        FilterGroup<SvtMatCostDetailType>(
          options: const [SvtMatCostDetailType.consumed, SvtMatCostDetailType.demands],
          values: typeFilter,
          combined: true,
          optionBuilder:
              (v) => Text(
                {
                      SvtMatCostDetailType.consumed: S.current.consumed,
                      SvtMatCostDetailType.demands: S.current.demands,
                    }[v] ??
                    v.name,
              ),
          onFilterChanged: (v, _) {
            setState(() {});
          },
          padding: EdgeInsets.zero,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('  ${S.current.filter_sort}: '),
            DropdownButton<SvtCompare>(
              value: sortOrder,
              items: [
                for (final order in [SvtCompare.no, SvtCompare.className, SvtCompare.rarity, SvtCompare.priority])
                  DropdownMenuItem(value: order, child: Text(order.showName)),
              ],
              onChanged: (v) {
                setState(() {
                  if (v != null) sortOrder = v;
                });
              },
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  sortReversed = !sortReversed;
                });
              },
              icon: FaIcon(sortReversed ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpWideShort),
              tooltip: S.current.sort_order,
            ),
          ],
        ),
      ],
    );
  }
}
