import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class CmdCodeFilterPage extends FilterPage<CmdCodeFilterData> {
  const CmdCodeFilterPage(
      {Key key, CmdCodeFilterData filterData, bool Function(CmdCodeFilterData) onChanged})
      : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<CmdCodeFilterData> {
  @override
  void initiate() {
    filterData = widget.filterData ?? CmdCodeFilterData();
  }

  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text('Filter'),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: '显示', children: [
          getToggleButton(
              texts: ['List', 'Grid'],
              isSelected: [!filterData.useGrid, filterData.useGrid],
              onPressed: (i) {
                filterData.useGrid = i == 1;
                update();
              }),
        ]),
        getGroup(header: '排序', children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<CmdCodeCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(CmdCodeFilterData.sortKeyData, ['序号', '星级']),
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
          title: Text('稀有度'),
          options: CmdCodeFilterData.rarityData,
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v星'),
          onFilterChanged: (value) {
            filterData.rarity = value;
            update();
          },
        ),
        FilterGroup(
          title: Text('分类'),
          options: CmdCodeFilterData.obtainData,
          values: filterData.obtain,
          onFilterChanged: (value) {
            filterData.obtain = value;
            update();
          },
        ),
      ]),
    );
  }
}
