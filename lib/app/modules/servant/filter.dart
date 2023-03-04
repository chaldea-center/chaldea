import 'dart:math';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';

class ServantFilterPage extends FilterPage<SvtFilterData> {
  final bool planMode;
  const ServantFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
    required this.planMode,
  });

  @override
  _ServantFilterPageState createState() => _ServantFilterPageState();
}

class _ServantFilterPageState extends FilterPageState<SvtFilterData, ServantFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'svt_list_filter', children: [
        getGroup(
          header: S.current.filter_shown_type,
          children: [
            FilterGroup.display(
              useGrid: filterData.useGrid,
              onChanged: (v) {
                if (v != null) filterData.useGrid = v;
                update();
              },
            ),
            FilterGroup<FavoriteState>(
              options: FavoriteState.values,
              combined: true,
              values: FilterRadioData.nonnull(widget.planMode ? filterData.planFavorite : filterData.favorite),
              padding: EdgeInsets.zero,
              optionBuilder: (v) {
                return Text.rich(TextSpan(children: [
                  CenterWidgetSpan(child: Icon(v.icon, size: 16)),
                  TextSpan(text: v.shownName),
                ]));
              },
              onFilterChanged: (v, _) {
                if (widget.planMode) {
                  filterData.planFavorite = v.radioValue!;
                } else {
                  filterData.favorite = v.radioValue!;
                }
                update();
              },
            ),
          ],
        ),
        getGroup(header: S.current.filter_sort, children: [
          for (int i = 0; i < min(4, filterData.sortKeys.length); i++)
            getSortButton<SvtCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: {for (final e in SvtCompare.values) e: e.showName},
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
        buildClassFilter(filterData.svtClass),
        FilterGroup<int>(
          title: Text(S.current.filter_sort_rarity, style: textStyle),
          options: const [0, 1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v$kStarChar'),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<CardType>(
          title: Text(S.current.noble_phantasm, style: textStyle),
          options: const [CardType.arts, CardType.buster, CardType.quick],
          values: filterData.npColor,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<TdEffectFlag>(
          values: filterData.npType,
          options: TdEffectFlag.values,
          optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.tdEffectFlag).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        buildGroupDivider(text: S.current.plan),
        FilterGroup<int>(
          title: Text('${S.current.priority} (${S.current.display_setting} - ${S.current.setting_priority_tagging})',
              style: textStyle),
          options: const [1, 2, 3, 4, 5],
          values: filterData.priority,
          optionBuilder: (value) {
            String text = value.toString();
            final tag = db.settings.priorityTags[value];
            if (tag != null && tag.isNotEmpty) {
              text += ' $tag';
            }
            return Text(text);
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<SvtPlanScope>(
          title: Text(S.current.filter_plan_not_reached, style: textStyle),
          options: SvtPlanScope.values,
          values: filterData.planCompletion,
          showMatchAll: true,
          optionBuilder: (v) {
            String text;
            switch (v) {
              case SvtPlanScope.all:
                text = '(${S.current.general_all})';
                break;
              case SvtPlanScope.ascension:
                text = S.current.ascension_short;
                break;
              case SvtPlanScope.active:
                text = S.current.active_skill_short;
                break;
              case SvtPlanScope.append:
                text = S.current.append_skill_short;
                break;
              case SvtPlanScope.costume:
                text = S.current.costume;
                break;
              case SvtPlanScope.misc:
                text = S.current.general_others;
                break;
            }
            return Text(text);
          },
          onFilterChanged: (value, lastChanged) {
            if (lastChanged == SvtPlanScope.all) {
              if (value.contain(SvtPlanScope.all)) {
                value.options = SvtPlanScope.values.toSet();
              } else {
                value.options.clear();
              }
            } else if (lastChanged != null) {
              value.options.remove(SvtPlanScope.all);
            }
            update();
          },
        ),
        FilterGroup<SvtSkillLevelState>(
          title: Text(S.current.active_skill),
          options: SvtSkillLevelState.values,
          values: filterData.activeSkillLevel,
          optionBuilder: (v) {
            switch (v) {
              case SvtSkillLevelState.normal:
                return const Text('<999');
              case SvtSkillLevelState.max9:
                return const Text('999');
              case SvtSkillLevelState.max10:
                return const Text('10/10/10');
            }
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<bool>(
          title: Text(S.current.duplicated_servant),
          options: const [false, true],
          values: filterData.svtDuplicated,
          optionBuilder: (v) =>
              Text(v ? S.current.duplicated_servant_duplicated : S.current.duplicated_servant_primary),
          onFilterChanged: (v, _) {
            setState(() {
              update();
            });
          },
        ),
        buildGroupDivider(text: S.current.gamedata),
        FilterGroup<Region>(
          title: Text(S.current.game_server, style: textStyle),
          options: Region.values,
          values: filterData.region,
          optionBuilder: (v) => Text(v.localName),
          onFilterChanged: (v, _) {
            update();
          },
        ),
        FilterGroup<SvtObtain>(
          title: Text(S.current.filter_obtain, style: textStyle),
          options: SvtObtain.values,
          values: filterData.obtain,
          optionBuilder: (v) => Text(Transl.svtObtain(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<Attribute>(
          title: Text(S.current.filter_attribute, style: textStyle),
          options: Attribute.values.sublist(0, 5),
          values: filterData.attribute,
          optionBuilder: (v) => Text(Transl.svtAttribute(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<ServantPolicy>(
          title: Text(S.current.info_alignment, style: textStyle),
          options: ServantPolicy.values.sublist(1, ServantPolicy.values.length - 1),
          values: filterData.policy,
          optionBuilder: (v) => Text(Transl.servantPolicy(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<ServantPersonality>(
          values: filterData.personality,
          options: ServantPersonality.values.sublist(1, ServantPersonality.values.length - 1),
          optionBuilder: (v) => Text(Transl.servantPersonality(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<Gender>(
          title: Text(S.current.gender, style: textStyle),
          options: Gender.values.toList(),
          values: filterData.gender,
          optionBuilder: (v) => Text(Transl.gender(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<Trait>(
          title: Text(S.current.trait, style: textStyle),
          options: _traitsForFilter,
          values: filterData.trait,
          optionBuilder: (v) => Text(Transl.trait(v.id).l),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (value, _) {
            update();
          },
        ),
        buildGroupDivider(text: S.current.effect_search),
        FilterGroup<SvtEffectScope>(
          title: Text(S.current.effect_scope),
          options: SvtEffectScope.values,
          values: filterData.effectScope,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<EffectTarget>(
          title: Text(S.current.effect_target),
          options: EffectTarget.values,
          values: filterData.effectTarget,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        EffectFilterUtil.buildTraitFilter(context, filterData.targetTrait, update),
        FilterGroup<SkillEffect>(
          title: Text(S.current.effect_type),
          options: _getValidEffects(SkillEffect.kAttack),
          values: filterData.effectType,
          showMatchAll: true,
          showInvert: false,
          optionBuilder: (v) => Text(v.lName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        const SizedBox(height: 4),
        FilterGroup<SkillEffect>(
          options: _getValidEffects(SkillEffect.kDefence),
          values: filterData.effectType,
          optionBuilder: (v) => Text(v.lName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        const SizedBox(height: 4),
        FilterGroup<SkillEffect>(
          options: _getValidEffects(SkillEffect.kDebuffRelated),
          values: filterData.effectType,
          optionBuilder: (v) => Text(v.lName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        const SizedBox(height: 4),
        FilterGroup<SkillEffect>(
          options: _getValidEffects(SkillEffect.kOthers),
          values: filterData.effectType,
          optionBuilder: (v) => Text(v.lName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }

  List<SkillEffect> _getValidEffects(List<SkillEffect> effects) {
    return effects.where((v) => !SkillEffect.svtIgnores.contains(v)).toList();
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
  Trait.skyOrEarthExceptPseudoAndDemiServant,
  Trait.hominidaeServant,
  Trait.demonicBeastServant, // 魔兽型
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
  Trait.havingAnimalsCharacteristics, // 兽科
  Trait.summerModeServant,
  Trait.immuneToPigify,
];
