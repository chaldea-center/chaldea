import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
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
          optionBuilder: (v) => Text('$v$kStarChar'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CardType>(
          title: Text(S.of(context).noble_phantasm, style: textStyle),
          options: const [CardType.arts, CardType.buster, CardType.quick],
          values: filterData.npColor,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<NpDamageType>(
          values: filterData.npType,
          options: NpDamageType.values,
          optionBuilder: (v) => Text(v.name.toTitle()),
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
        FilterGroup<bool>(
          title: Text(S.of(context).plan, style: textStyle),
          options: const [false, true],
          values: filterData.planCompletion,
          optionBuilder: (v) => Text(v
              ? S.of(context).filter_plan_reached
              : S.of(context).filter_plan_not_reached),
          onFilterChanged: (value) {
            update();
          },
        ),
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
          optionBuilder: (v) => Text(Transl.svtObtain(v).l),
          onFilterChanged: (value) {
            filterData.obtain = value;
            update();
          },
        ),
        FilterGroup<Attribute>(
          title: Text(S.of(context).filter_attribute, style: textStyle),
          options: Attribute.values.sublist(0, 5),
          values: filterData.attribute,
          optionBuilder: (v) => Text(Transl.svtAttribute(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<ServantPolicy>(
          title: Text(S.of(context).info_alignment, style: textStyle),
          options:
              ServantPolicy.values.sublist(1, ServantPolicy.values.length - 1),
          values: filterData.policy,
          optionBuilder: (v) => Text(Transl.servantPolicy(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<ServantPersonality>(
          values: filterData.personality,
          options: ServantPersonality.values
              .sublist(1, ServantPersonality.values.length - 1),
          optionBuilder: (v) => Text(Transl.servantPersonality(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Gender>(
          title: Text(S.of(context).filter_gender, style: textStyle),
          options: Gender.values.toList(),
          values: filterData.gender,
          optionBuilder: (v) => Text(Transl.gender(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Trait>(
          title: Text(S.of(context).info_trait, style: textStyle),
          options: _traitsForFilter,
          values: filterData.trait,
          optionBuilder: (v) =>
              Text(v.id != null ? Transl.trait(v.id!).l : v.name),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value) {
            update();
          },
        ),
        groupDivider,
        FilterGroup<SvtEffectScope>(
          title: const Text('Effect Scope'),
          options: SvtEffectScope.values,
          values: filterData.effectScope,
          optionBuilder: (v) => Text(v.name),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<FuncTargetType>(
          title: const Text('Effect Target'),
          options: FuncTargetType.values.toList(),
          values: filterData.funcTarget,
          optionBuilder: (v) => Text(Transl.funcTargetType(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<FuncType>(
          title: const Text('FuncType'),
          options: List.of(db.gameData.others.svtFuncs)..sort2((e) => e.name),
          values: filterData.funcType,
          showMatchAll: true,
          showInvert: true,
          optionBuilder: (v) => Text(v.name),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<BuffType>(
          title: const Text('BuffType'),
          options: List.of(db.gameData.others.svtBuffs)..sort2((e) => e.name),
          values: filterData.buffType,
          showMatchAll: true,
          showInvert: true,
          optionBuilder: (v) => Text(v.name),
          onFilterChanged: (value) {
            update();
          },
        ),
      ]),
    );
  }

  Widget _buildClassFilter() {
    final shownClasses = SvtClassX.regularAllWithB2;
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
                      final icon = SvtClass.ALL.icon(index == 0 ? 5 : 1);
                      return GestureDetector(
                        child: db.getIconImage(icon, width: 60),
                        onTap: () {
                          if (index == 0) {
                            filterData.svtClass.options.addAll(shownClasses);
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
                      children: shownClasses.map((className) {
                        final selected =
                            filterData.svtClass.options.contains(className);
                        Widget icon = db.getIconImage(
                            className.icon(selected ? 5 : 1),
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
  Trait.hasCostume,
];
