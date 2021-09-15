import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/datatypes/effect_type/effect_type.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:flutter/cupertino.dart';

class ServantFilterPage extends FilterPage<SvtFilterData> {
  const ServantFilterPage({
    Key? key,
    required SvtFilterData filterData,
    ValueChanged<SvtFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _ServantFilterPageState createState() => _ServantFilterPageState();
}

class _ServantFilterPageState extends FilterPageState<SvtFilterData> {
  @override
  Widget build(BuildContext context) {
    const groupDivider = Divider(height: 16, indent: 12, endIndent: 12);
    return buildAdaptive(
      title: Text(S.of(context).filter),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(
          header: S.of(context).filter_shown_type,
          children: [
            FilterGroup(
              useRadio: true,
              padding: EdgeInsets.zero,
              options: const ['List', 'Grid'],
              values: filterData.display,
              combined: true,
              onFilterChanged: (v) {
                filterData.display = v;
                update();
              },
            ),
            FilterOption(
              selected: filterData.hasDress,
              value: S.of(context).costume,
              onChanged: (v) {
                setState(() {
                  filterData.hasDress = v;
                  update();
                });
              },
            ),
          ],
        ),
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
                filterData.sortKeys[i] = key ?? filterData.sortKeys[i];
                update();
              },
              reversed: filterData.sortReversed[i],
              onSortDirectional: (reversed) {
                filterData.sortReversed[i] = reversed;
                update();
              },
            ),
        ]),
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
          title: Text(S.of(context).noble_phantasm, style: textStyle),
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
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            filterData.npType = value;
            update();
          },
        ),
        groupDivider,
        FilterGroup(
          title: Text(const LocalizedText(
                  chs: '重复从者', jpn: '重複サーバント', eng: 'Duplicated Servant')
              .localized),
          options: const ['1', '2'],
          values: filterData.svtDuplicated,
          optionBuilder: (v) =>
              Text(Localized.svtFilter.of(v == '1' ? '初号机' : '2号机')),
          combined: true,
          onFilterChanged: (v) {
            setState(() {
              filterData.svtDuplicated = v;
              update();
            });
          },
        ),
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
        groupDivider,
        FilterGroup(
          title: Text(S.of(context).filter_obtain, style: textStyle),
          options: SvtFilterData.obtainData,
          values: filterData.obtain,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            filterData.obtain = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_attribute, style: textStyle),
          options: SvtFilterData.attributeData,
          values: filterData.attribute,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            filterData.attribute = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).info_alignment, style: textStyle),
          options: SvtFilterData.alignment1Data,
          values: filterData.alignment1,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            filterData.alignment1 = value;
            update();
          },
        ),
        FilterGroup(
          values: filterData.alignment2,
          options: SvtFilterData.alignment2Data,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          onFilterChanged: (value) {
            filterData.alignment2 = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).filter_gender, style: textStyle),
          options: SvtFilterData.genderData,
          values: filterData.gender,
          optionBuilder: (v) => Text(Localized.gender.of(v)),
          onFilterChanged: (value) {
            filterData.gender = value;
            update();
          },
        ),
        FilterGroup(
          title: Text(S.of(context).info_trait, style: textStyle),
          options: SvtFilterData.traitData,
          values: filterData.trait,
          optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value) {
            filterData.trait = value;
            update();
          },
        ),
        // FilterGroup(
        //   title: Text('Special', style: textStyle),
        //   options: const ['充能(技能)', '充能(宝具)'],
        //   values: filterData.special,
        //   showInvert: true,
        //   showMatchAll: true,
        //   optionBuilder: (v) => Text(Localized.svtFilter.of(v)),
        //   onFilterChanged: (value) {
        //     // filterData.special = value;
        //     update();
        //   },
        // ),
        groupDivider,
        FilterGroup(
          title: Text(LocalizedText.of(
              chs: '效果范围', jpn: '効果の範囲', eng: 'Scope of Effects')),
          options: SvtFilterData.buffScope,
          values: filterData.effectScope,
          optionBuilder: (v) => Text([
            S.current.active_skill,
            S.current.noble_phantasm,
            S.current.passive_skill
          ][int.parse(v)]),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup(
          title: Text(S.current.filter_effects),
          options: EffectType.svtEffectsMap.keys.toList(),
          values: filterData.effects,
          showMatchAll: true,
          showInvert: true,
          optionBuilder: (v) => Text(EffectType.svtEffectsMap[v]!.shownName),
          onFilterChanged: (value) {
            update();
          },
        ),
      ]),
    );
  }

  Widget _buildClassFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(S.of(context).filter_sort_class, style: textStyle),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(2, (index) {
                      final name = ['金卡', '铜卡'][index] + 'All';
                      return GestureDetector(
                        child: db.getIconImage(name),
                        onTap: () {
                          if (index == 0) {
                            SvtFilterData.classesData.forEach(
                                (e) => filterData.className.options[e] = true);
                          } else {
                            filterData.className.options.clear();
                          }
                          update();
                        },
                      );
                    }),
                  ),
                ),
                Container(width: 10),
                Expanded(
                    flex: 8,
                    child: GridView.count(
                      crossAxisCount: 8,
                      shrinkWrap: true,
                      childAspectRatio: 1.2,
                      physics: const NeverScrollableScrollPhysics(),
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
