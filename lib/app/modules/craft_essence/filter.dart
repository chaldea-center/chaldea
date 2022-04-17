import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

class CraftFilterPage extends FilterPage<CraftFilterData> {
  const CraftFilterPage({
    Key? key,
    required CraftFilterData filterData,
    ValueChanged<CraftFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CraftFilterPageState createState() => _CraftFilterPageState();
}

class _CraftFilterPageState extends FilterPageState<CraftFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_sort, children: [
          FilterGroup.display(
            useGrid: filterData.useGrid,
            onChanged: (v) {
              if (v != null) filterData.useGrid = v;
              update();
            },
          ),
        ]),
        //end
        getGroup(header: S.current.filter_sort, children: [
          for (int i = 0; i < CraftCompare.values.length; i++)
            getSortButton<CraftCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(CraftCompare.values, [
                S.current.filter_sort_number,
                S.current.filter_sort_rarity,
                'ATK',
                'HP'
              ]),
              onSortAttr: (key) {
                filterData.sortKeys[i] = key ?? filterData.sortKeys[i];
                update();
              },
              reversed: filterData.sortReversed[i],
              onSortDirectional: (reversed) {
                filterData.sortReversed[i] = reversed;
                update();
              },
            )
        ]),
        FilterGroup<int>(
          title: Text(S.current.rarity),
          options: const [1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v★'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CEObtain>(
          title: Text(S.current.filter_category),
          options: CEObtain.values,
          values: filterData.obtain,
          optionBuilder: (v) => Text(Transl.ceObtain(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CraftATKType>(
          title: Text(S.current.filter_atk_hp_type),
          options: CraftATKType.values,
          values: filterData.atkType,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CraftStatus>(
          title: const Text('Status'),
          options: CraftStatus.values,
          values: filterData.status,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value) {
            update();
          },
        ),
        // FilterGroup(
        //   title: Text(S.current.filter_effects),
        //   options: EffectType.craftEffectsMap.keys.toList(),
        //   values: filterData.effects,
        //   showMatchAll: true,
        //   showInvert: true,
        //   optionBuilder: (v) => Text(EffectType.craftEffectsMap[v]!.shownName),
        //   onFilterChanged: (value) {
        //     update();
        //   },
        // ),
        // SFooter(Localized.niceSkillFilterHint.localized)
      ]),
    );
  }
}
