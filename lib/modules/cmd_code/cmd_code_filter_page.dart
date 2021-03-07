//@dart=2.12
import 'package:chaldea/components/components.dart';
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
          getToggleButton(
              texts: ['List', 'Grid'],
              isSelected: [!filterData.useGrid, filterData.useGrid],
              onPressed: (i) {
                filterData.useGrid = i == 1;
                update();
              }),
        ]),
        getGroup(header: S.of(context).filter_sort, children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<CmdCodeCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(CmdCodeFilterData.sortKeyData, [
                S.of(context).filter_sort_number,
                S.of(context).filter_sort_rarity
              ]),
              onSortAttr: (key) {
                filterData.sortKeys[i] = key;
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
          options: CmdCodeFilterData.rarityData,
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v★'),
          onFilterChanged: (value) {
            filterData.rarity = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_category),
          options: CmdCodeFilterData.categoryData,
          values: filterData.category,
          onFilterChanged: (value) {
            filterData.category = value;
            update();
          },
        ),
      ]),
    );
  }
}
