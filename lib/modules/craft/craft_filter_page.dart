import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

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
      title: Text(S.of(context).filter),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_sort, children: [
          FilterGroup(
            useRadio: true,
            padding: const EdgeInsets.only(right: 12),
            options: const ['List', 'Grid'],
            values: filterData.display,
            combined: true,
            onFilterChanged: (v) {
              update();
            },
          ),
        ]), //end
        getGroup(header: S.of(context).filter_sort, children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<CraftCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(CraftFilterData.sortKeyData, [
                S.of(context).filter_sort_number,
                S.of(context).filter_sort_rarity,
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
        FilterGroup(
          title: Text(S.of(context).rarity),
          options: CraftFilterData.rarityData,
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v★'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_category),
          options: CraftFilterData.categoryData,
          values: filterData.category,
          optionBuilder: (v) => Text(Localized.craftFilter.of(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_atk_hp_type),
          options: CraftFilterData.atkHpTypeData,
          values: filterData.atkHpType,
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: const Text('Status'),
          options: const ['0', '1', '2'],
          values: filterData.status,
          optionBuilder: (v) {
            return Text(Localized.craftFilter
                .of(CraftFilterData.statusTexts[int.parse(v)]));
          },
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.current.filter_effects),
          options: EffectType.craftEffectsMap.keys.toList(),
          values: filterData.effects,
          showMatchAll: true,
          showInvert: true,
          optionBuilder: (v) => Text(EffectType.craftEffectsMap[v]!.shownName),
          onFilterChanged: (value) {
            update();
          },
        ),
      ]),
    );
  }
}
