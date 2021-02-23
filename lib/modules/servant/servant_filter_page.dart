//@dart=2.9
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

class ServantFilterPage extends FilterPage<SvtFilterData> {
  const ServantFilterPage(
      {Key key,
      SvtFilterData filterData,
      bool Function(SvtFilterData) onChanged})
      : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _ServantFilterPageState createState() => _ServantFilterPageState();
}

class _ServantFilterPageState extends FilterPageState<SvtFilterData> {
  @override
  void initiate() {
    filterData = widget.filterData ?? SvtFilterData();
  }

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
          FilterOption(
            selected: filterData.hasDress,
            value: S.of(context).dress,
            onChanged: (v) {
              setState(() {
                filterData.hasDress = v;
                update();
              });
            },
          ),
        ]),
        getGroup(header: S.of(context).filter_sort, children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<SvtCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(SvtFilterData.sortKeyData, [
                S.current.filter_sort_number,
                S.current.filter_sort_class,
                S.current.filter_sort_rarity,
                'ATK',
                'HP',
                S.current.priority
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
            ),
        ]),
        FilterGroup(
          title: Text(S.of(context).plan, style: textStyle),
          options: SvtFilterData.planCompletionData,
          values: filterData.planCompletion,
          optionBuilder: (v) => Text(v == '0'
              ? S.of(context).filter_plan_not_reached
              : S.of(context).filter_plan_reached),
          onFilterChanged: (value) {
            // object should be the same, need not to update manually
            filterData.planCompletion = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_skill_lv, style: textStyle),
          options: SvtFilterData.skillLevelData,
          values: filterData.skillLevel,
          onFilterChanged: (value) {
            // object should be the same, need not to update manually
            filterData.skillLevel = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).priority, style: textStyle),
          options: SvtFilterData.priorityData,
          values: filterData.priority,
          onFilterChanged: (value) {
            // object should be the same, need not to update manually
            filterData.priority = value;
            update();
          },
        ),
        _buildClassFilter(),
        FilterGroup(
          title: Text(S.of(context).filter_sort_rarity, style: textStyle),
          options: SvtFilterData.rarityData,
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v☆'),
          onFilterChanged: (value) {
            // object should be the same, need not to update manually
            filterData.rarity = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_obtain, style: textStyle),
          options: SvtFilterData.obtainData,
          values: filterData.obtain,
          onFilterChanged: (value) {
            filterData.obtain = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).nobel_phantasm, style: textStyle),
          options: SvtFilterData.npColorData,
          values: filterData.npColor,
          onFilterChanged: (value) {
            filterData.npColor = value;
            update();
          },
        ),
        FilterGroup(
          values: filterData.npType,
          options: SvtFilterData.npTypeData,
          onFilterChanged: (value) {
            filterData.npType = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_attribute, style: textStyle),
          options: SvtFilterData.attributeData,
          values: filterData.attribute,
          onFilterChanged: (value) {
            filterData.attribute = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).info_alignment, style: textStyle),
          options: SvtFilterData.alignment1Data,
          values: filterData.alignment1,
          onFilterChanged: (value) {
            filterData.alignment1 = value;
            update();
          },
        ),
        FilterGroup(
          values: filterData.alignment2,
          options: SvtFilterData.alignment2Data,
          onFilterChanged: (value) {
            filterData.alignment2 = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_gender, style: textStyle),
          options: SvtFilterData.genderData,
          values: filterData.gender,
          onFilterChanged: (value) {
            filterData.gender = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).info_trait, style: textStyle),
          options: SvtFilterData.traitData,
          values: filterData.trait,
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value) {
            filterData.trait = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_special_trait, style: textStyle),
          options: SvtFilterData.traitSpecialData,
          values: filterData.traitSpecial,
          onFilterChanged: (value) {
            filterData.traitSpecial = value;
            update();
          },
        ),
      ]),
    );
  }

  Widget _buildClassFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).filter_sort_class, style: textStyle),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: 1.2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(2, (index) {
                        final name = ['金卡', '铜卡'][index] + 'All';
                        return GestureDetector(
                          child: db.getIconImage(name),
                          onTap: () {
                            if (index == 0) {
                              SvtFilterData.classesData.forEach((e) =>
                                  filterData.className.options[e] = true);
                            } else {
                              filterData.className.options.clear();
                            }
                            update();
                          },
                        );
                      }),
                    )),
                Container(width: 10),
                Expanded(
                    flex: 21,
                    child: GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      childAspectRatio: 1.2,
                      physics: NeverScrollableScrollPhysics(),
                      children: SvtFilterData.classesData.map((className) {
                        final selected =
                            filterData.className.options[className] ?? false;
                        final color = selected ? '金卡' : '铜卡';
                        return GestureDetector(
                          child: db.getIconImage('$color$className'),
                          onTap: () {
                            filterData.className.options[className] = !selected;
                            update();
                          },
                        );
                      }).toList(),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
