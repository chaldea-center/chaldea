import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class CmdCodeFilterPage extends FilterPage<CmdCodeFilterData> {
  const CmdCodeFilterPage({
    Key? key,
    required CmdCodeFilterData filterData,
    ValueChanged<CmdCodeFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<CmdCodeFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.of(context).filter),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_shown_type, children: [
          FilterGroup(
            useRadio: true,
            padding: EdgeInsets.only(right: 12),
            options: const ['List', 'Grid'],
            values: filterData.display,
            combined: true,
            onFilterChanged: (v) {
              update();
            },
          ),
        ]),
        getGroup(
          header: S.of(context).filter_sort,
          children: [
            for (int i = 0; i < filterData.sortKeys.length; i++)
              getSortButton<CmdCodeCompare>(
                prefix: '${i + 1}',
                value: filterData.sortKeys[i],
                items: Map.fromIterables(CmdCodeFilterData.sortKeyData, [
                  S.of(context).filter_sort_number,
                  S.of(context).filter_sort_rarity
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
          ],
        ),
        FilterGroup(
          title: Text(S.of(context).rarity),
          options: CmdCodeFilterData.rarityData,
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v★'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_category),
          options: CmdCodeFilterData.categoryData,
          values: filterData.category,
          optionBuilder: (v) => Text(Localized.craftFilter.of(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.current.filter_effects),
          options: EffectType.craftEffectsMap.keys.toList(),
          values: filterData.effects,
          optionBuilder: (v) => Text(EffectType.craftEffectsMap[v]!.shownName),
          onFilterChanged: (value) {
            update();
          },
        ),
      ]),
    );
  }
}
