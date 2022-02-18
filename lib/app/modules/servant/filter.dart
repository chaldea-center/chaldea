import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:flutter/material.dart';

import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

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
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(
          header: S.of(context).filter_shown_type,
          children: [
            FilterGroup.display(
              useGrid: filterData.useGrid,
              onChanged: (v) {
                if (v != null) filterData.useGrid = v;
                update();
              },
            ),
          ],
        ),
        getGroup(header: S.of(context).filter_sort, children: [
          for (int i = 0; i < filterData.sortKeys.length; i++)
            getSortButton<SvtCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: Map.fromIterables(SvtCompare.values, [
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
        FilterGroup<int>(
          title: Text(S.of(context).filter_sort_rarity, style: textStyle),
          options: const [0, 1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v☆'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CardType>(
          title: Text(S.of(context).noble_phantasm, style: textStyle),
          options: const [CardType.arts, CardType.buster, CardType.quick],
          values: filterData.npColor,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<NpDamageType>(
          values: filterData.npType,
          options: NpDamageType.values,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        groupDivider,
        // FilterGroup(
        //   title: Text(const LocalizedText(
        //           chs: '重复从者',
        //           jpn: '重複サーバント',
        //           eng: 'Duplicated Servant',
        //           kor: '중복된 서번트')
        //       .localized),
        //   options: const ['1', '2'],
        //   values: filterData.svtDuplicated,
        //   optionBuilder: (v) =>
        //       Text(Localized.svtFilter.of(v == '1' ? '初号机' : '2号机')),
        //   combined: true,
        //   onFilterChanged: (v) {
        //     setState(() {
        //       filterData.svtDuplicated = v;
        //       update();
        //     });
        //   },
        // ),
        // FilterGroup(
        //   title: Text(S.of(context).plan, style: textStyle),
        //   options: SvtFilterData.planCompletionData,
        //   values: filterData.planCompletion,
        //   optionBuilder: (v) => Text(v == '0'
        //       ? S.of(context).filter_plan_not_reached
        //       : S.of(context).filter_plan_reached),
        //   onFilterChanged: (value) {
        //     // object should be the same, need not to update manually
        //     filterData.planCompletion = value;
        //     update();
        //   },
        // ),
        // FilterGroup(
        //   title: Text(S.of(context).filter_skill_lv, style: textStyle),
        //   options: SvtFilterData.skillLevelData,
        //   values: filterData.skillLevel,
        //   onFilterChanged: (value) {
        //     // object should be the same, need not to update manually
        //     filterData.skillLevel = value;
        //     update();
        //   },
        // ),
        FilterGroup<int>(
          title: Text(S.of(context).priority, style: textStyle),
          options: const [1, 2, 3, 4, 5],
          values: filterData.priority,
          onFilterChanged: (value) {
            update();
          },
        ),
        groupDivider,
        FilterGroup<SvtObtain>(
          title: Text(S.of(context).filter_obtain, style: textStyle),
          options: SvtObtain.values,
          values: filterData.obtain,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            filterData.obtain = value;
            update();
          },
        ),
        FilterGroup<Attribute>(
          title: Text(S.of(context).filter_attribute, style: textStyle),
          options: Attribute.values.sublist(0, 5),
          values: filterData.attribute,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Trait>(
          title: Text(S.of(context).info_alignment, style: textStyle),
          options: const [
            Trait.alignmentLawful,
            Trait.alignmentChaotic,
            Trait.alignmentNeutral,
          ],
          values: filterData.alignment1,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Trait>(
          values: filterData.alignment2,
          options: const [
            Trait.alignmentGood,
            Trait.alignmentEvil,
            Trait.alignmentBalanced,
            Trait.alignmentMadness,
            Trait.alignmentSummer,
          ],
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Gender>(
          title: Text(S.of(context).filter_gender, style: textStyle),
          options: Gender.values,
          values: filterData.gender,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Trait>(
          title: Text(S.of(context).info_trait, style: textStyle),
          options: _traitsForFilter,
          values: filterData.trait,
          optionBuilder: (v) => Text(EnumUtil.titled(v)),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value) {
            update();
          },
        ),
        groupDivider,
        // FilterGroup(
        //   title: Text(LocalizedText.of(
        //       chs: '效果范围',
        //       jpn: '効果の範囲',
        //       eng: 'Scope of Effects',
        //       kor: '스킬/보구')),
        //   options: SvtFilterData.buffScope,
        //   values: filterData.effectScope,
        //   optionBuilder: (v) => Text([
        //     S.current.active_skill,
        //     S.current.noble_phantasm,
        //     S.current.passive_skill
        //   ][int.parse(v)]),
        //   onFilterChanged: (value) {
        //     update();
        //   },
        // ),
        // FilterGroup(
        //   title: Text(LocalizedText.of(
        //     chs: '效果对象',
        //     jpn: '効果の対象',
        //     eng: 'Effect Target',
        //     kor: '효과 대상',
        //   )),
        //   options: FuncTargetType.allTypes,
        //   values: filterData.effectTarget,
        //   optionBuilder: (v) => Text(FuncTargetType.localizedOf(v)),
        //   onFilterChanged: (value) {
        //     update();
        //   },
        // ),
        // FilterGroup(
        //   title: Text(S.current.filter_effects),
        //   options: EffectType.svtEffectsMap.keys.toList(),
        //   values: filterData.effects,
        //   showMatchAll: true,
        //   showInvert: true,
        //   optionBuilder: (v) => Text(EffectType.svtEffectsMap[v]!.shownName),
        //   onFilterChanged: (value) {
        //     update();
        //   },
        // ),
        // SFooter(Localized.niceSkillFilterHint.localized)
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
                      final icon = SvtClass.ALL.icon(index == 0 ? 3 : 1);
                      return GestureDetector(
                        child: db2.getIconImage(icon),
                        onTap: () {
                          if (index == 0) {
                            filterData.svtClass.options
                                .addAll(SvtClassX.regularAll);
                          } else {
                            filterData.svtClass.options.clear();
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
                      children: SvtClassX.regularAll.map((className) {
                        final selected =
                            filterData.svtClass.options.contains(className);
                        Widget icon = db2.getIconImage(
                            className.icon(selected ? 3 : 1),
                            aspectRatio: 1);
                        if (className == SvtClass.beastII && !selected) {
                          icon = Opacity(opacity: 0.5, child: icon);
                        }
                        return GestureDetector(
                          child: icon,
                          onTap: () {
                            filterData.svtClass.toggle(className);
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

const _traitsForFilter = <Trait>[
  Trait.dragon,
  Trait.riding,
  Trait.divine,
  Trait.humanoid, //?
  Trait.demonBeast,
  Trait.king,
  Trait.roman,
  Trait.arthur,
  Trait.saberface,
  Trait.weakToEnumaElish,
  Trait.brynhildsBeloved,
  Trait.greekMythologyMales,
  Trait.threatToHumanity,
  Trait.argonaut,
  Trait.demonic,
  Trait.giant,
  Trait.superGiant,
  Trait.skyOrEarthExceptPseudoAndDemi,
  Trait.hominidaeServant,
  Trait.demonicBeastServant,
  Trait.livingHuman,
  Trait.childServant,
  Trait.existenceOutsideTheDomain,
  Trait.oni,
  Trait.genji,
  Trait.mechanical,
  Trait.fae,
  Trait.knightsOfTheRound,
  Trait.fairyTaleServant,
  Trait.divineSpirit,
];
