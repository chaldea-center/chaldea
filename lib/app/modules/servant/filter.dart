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
  final bool showSort;
  final bool showPlans;
  final List<Widget> Function(BuildContext context, VoidCallback update)? customFilters;

  const ServantFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
    required this.planMode,
    this.showSort = true,
    this.showPlans = true,
    this.customFilters,
  });

  @override
  _ServantFilterPageState createState() => _ServantFilterPageState();

  static bool filter(
    SvtFilterData filterData,
    Servant svt, {
    bool planMode = false,
    int eventId = 0,
    SvtStatus? svtStat,
    SvtPlan? svtPlan,
  }) {
    svtStat ??= db.curUser.svtStatusOf(svt.collectionNo);
    svtPlan ??= db.curUser.svtPlanOf(svt.collectionNo);
    final favoriteState = planMode ? filterData.planFavorite : filterData.favorite;
    if (!favoriteState.check(svtStat.cur.favorite)) {
      return false;
    }

    if (filterData.planCompletion.options.isNotEmpty) {
      if (!svtStat.favorite) return false;
      final planCompletion = <SvtPlanScope>[
        if (svtPlan.ascension > svtStat.cur.ascension) SvtPlanScope.ascension,
        if ([for (var i = 0; i < kActiveSkillNums.length; i++) svtPlan.skills[i] > svtStat.cur.skills[i]].any((e) => e))
          SvtPlanScope.active,
        if ([
          for (var i = 0; i < kAppendSkillNums.length; i++) svtPlan.appendSkills[i] > svtStat.cur.appendSkills[i],
        ].any((e) => e))
          SvtPlanScope.append,
        if ([
          for (var costume in svt.profile.costume.values)
            (svtPlan.costumes[costume.battleCharaId] ?? 0) > (svtStat.cur.costumes[costume.battleCharaId] ?? 0),
        ].any((e) => e))
          SvtPlanScope.costume,
        // don't use cur.bondLimit < plan.bondLimit
        if (!svtStat.isReachBondLImit) SvtPlanScope.bond,
        if ([
          svtPlan.grail > svtStat.cur.grail,
          svtPlan.fouHp > svtStat.cur.fouHp,
          svtPlan.fouAtk > svtStat.cur.fouAtk,
          svtPlan.fouHp3 > svtStat.cur.fouHp3,
          svtPlan.fouAtk3 > svtStat.cur.fouAtk3,
        ].any((e) => e))
          SvtPlanScope.misc,
      ];
      if (!filterData.planCompletion.matchAny(planCompletion)) return false;
    }
    // svt data filter
    // skill level
    if (filterData.curStatus.options.isNotEmpty) {
      if (!svtStat.favorite) return false;
      int minActive = Maths.min(svtStat.cur.skills, 0);
      int append2 = svtStat.cur.appendSkills[1];
      int minAppend = Maths.min(svtStat.cur.appendSkills.where((e) => e > 0), -1);
      final values = [
        svtStat.cur.ascension < 4 ? SvtStatusState.asc3 : SvtStatusState.asc4,
        minActive == 10 ? SvtStatusState.active10 : (minActive == 9 ? SvtStatusState.active9 : SvtStatusState.active8),
        append2 < 9 ? SvtStatusState.appendTwo8 : SvtStatusState.appendTwo9,
        if (minAppend != -1) minAppend < 9 ? SvtStatusState.append8 : SvtStatusState.append9,
      ];

      if (!filterData.curStatus.matchAny(values)) {
        return false;
      }
    }
    if (!filterData.miscStatus.matchAny([
      svt.isDupSvt ? SvtStatusMiscType.secondarySvt : SvtStatusMiscType.primarySvt,
      if (svtStat.grandSvt) SvtStatusMiscType.grandSvt,
    ])) {
      return false;
    }
    final comparedBond = filterData.bondValue.radioValue;
    if (comparedBond != null && filterData.bondCompare.options.isNotEmpty) {
      final bond = svtStat.bond;
      if (filterData.bondCompare.options.every((c) => !c.test(bond, comparedBond))) {
        return false;
      }
    }

    // class name
    if (!filterData.svtClass.matchOne(svt.className, compare: SvtClassX.match)) {
      return false;
    }
    if (!filterData.rarity.matchAny({svt.rarity, ...svt.ascensionAdd.overwriteRarity.all.values})) {
      return false;
    }
    if (filterData.cardDeck.isNotEmpty) {
      final cardType = CardDeckType.resolve(svt.cards);
      if (!filterData.cardDeck.matchOne(cardType)) {
        return false;
      }
    }

    if (filterData.tdCardType.options.isNotEmpty && filterData.tdType.options.isNotEmpty) {
      if (!svt.noblePhantasms.any(
        (np) => filterData.tdCardType.contain(np.svt.card) && filterData.tdType.contain(np.damageType),
      )) {
        return false;
      }
    } else {
      if (!filterData.tdCardType.matchAny(svt.noblePhantasms.map((e) => e.svt.card).toList())) {
        return false;
      }
      if (!filterData.tdType.matchAny(svt.noblePhantasms.map((e) => e.damageType))) {
        return false;
      }
    }

    // plan status
    if (!filterData.priority.matchOne(svtStat.priority)) {
      return false;
    }
    // end plan status

    final region = filterData.region.radioValue;
    if (region != null && region != Region.jp) {
      final released = db.gameData.mappingData.entityRelease.ofRegion(region);
      if (released?.contains(svt.id) == false) {
        return false;
      }
    }

    if (!filterData.obtain.matchAny(svt.obtains)) {
      return false;
    }

    if (!filterData.attribute.matchAny({svt.attribute, ...svt.ascensionAdd.attribute.all.values})) {
      return false;
    }
    final policy = svt.profile.stats?.policy ?? ServantPolicy.none,
        personality = svt.profile.stats?.personality ?? ServantPersonality.none;
    if (!filterData.policy.matchAny({policy, ...svt.limits.values.map((e) => e.policy ?? policy)})) {
      return false;
    }
    if (!filterData.personality.matchAny({
      personality,
      ...svt.limits.values.map((e) => e.personality ?? personality),
    })) {
      return false;
    }

    final traits = svt.traitsAll.map((e) => kTraitIdMapping[e] ?? Trait.unknown).toSet();
    if (!filterData.gender.matchAny({svt.gender, ...Gender.values.where((e) => traits.contains(e.trait))})) {
      return false;
    }

    if (!filterData.trait.matchAny(traits)) {
      return false;
    }
    if (filterData.effectType.isNotEmpty || filterData.targetTrait.isNotEmpty || filterData.effectTarget.isNotEmpty) {
      List<BaseFunction> funcs = [
        if (filterData.effectScope.contain(SvtEffectScope.active))
          for (final skill in svt.skills) ...skill.filteredFunction(includeTrigger: true),
        if (filterData.effectScope.contain(SvtEffectScope.passive))
          for (final skill in svt.classPassive) ...skill.filteredFunction(includeTrigger: true),
        if (filterData.effectScope.contain(SvtEffectScope.passive))
          for (final skill in svt.extraPassive)
            if (skill.extraPassive.any((e) => e.getValidEventIds().isEmpty))
              ...skill.filteredFunction(includeTrigger: true),
        if (filterData.effectScope.contain(SvtEffectScope.append))
          for (final skill in svt.appendPassive) ...skill.skill.filteredFunction(includeTrigger: true),
        if (filterData.effectScope.contain(SvtEffectScope.td))
          for (final td in svt.noblePhantasms) ...td.filteredFunction(includeTrigger: true),
      ];
      if (filterData.effectTarget.isNotEmpty) {
        funcs.retainWhere((func) {
          return filterData.effectTarget.matchOne(EffectTarget.fromFunc(func.funcTargetType));
        });
      }
      if (filterData.targetTrait.isNotEmpty) {
        funcs.retainWhere((func) => EffectFilterUtil.checkFuncTraits(func, filterData.targetTrait));
      }
      if (funcs.isEmpty) return false;
      if (filterData.effectType.options.isEmpty) return true;
      if (filterData.effectType.matchAll) {
        if (!filterData.effectType.options.every((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      } else {
        if (!filterData.effectType.options.any((effect) => funcs.any((func) => effect.match(func)))) {
          return false;
        }
      }
    }
    final freeSvtEvent = filterData.freeExchangeSvtEvent.radioValue;
    if (freeSvtEvent != null) {
      if (!freeSvtEvent.shop.any(
        (shop) =>
            (shop.purchaseType == PurchaseType.servant || shop.purchaseType == PurchaseType.eventSvtJoin) &&
            shop.targetIds.contains(svt.id),
      )) {
        return false;
      }
    }
    if (filterData.isEventSvt && eventId > 0) {
      if (svt.eventSkills(eventId: eventId, includeZero: false).isEmpty) {
        return false;
      }
    }
    return true;
  }
}

class _ServantFilterPageState extends FilterPageState<SvtFilterData, ServantFilterPage> {
  int _lastResetTime = 0;
  List<Event> freeExchangeSvtEvents = [];

  @override
  void initState() {
    super.initState();
    freeExchangeSvtEvents = db.gameData.events.values.where((e) => e.isExchangeSvtEvent && e.shop.isNotEmpty).toList();
    freeExchangeSvtEvents.sort2((e) => -e.startedAt);
  }

  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(
        onTapReset: () {
          filterData.reset();
          final now = DateTime.now().timestamp;
          if (now - _lastResetTime < 2) {
            filterData.favorite = FavoriteState.all;
          }
          _lastResetTime = now;
          update();
        },
      ),
      content: getListViewBody(
        restorationId: 'svt_list_filter',
        children: [
          getGroup(
            header: S.current.filter_shown_type,
            children: [
              if (!widget.planMode)
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
                  return Text.rich(
                    TextSpan(
                      children: [
                        CenterWidgetSpan(child: Icon(v.icon, size: 16)),
                        TextSpan(text: v.shownName),
                      ],
                    ),
                  );
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
          if (widget.showSort)
            getGroup(
              header: S.current.filter_sort,
              children: [
                for (int i = 0; i < min(4, filterData.sortKeys.length); i++)
                  getSortButton<SvtCompare>(
                    prefix: '${i + 1}',
                    value: filterData.sortKeys[i],
                    items: {for (final e in SvtCompare.values) e: e.showName},
                    onSortAttr: (key) {
                      filterData.sortKeys[i] = key ?? filterData.sortKeys[i];
                      update();
                    },
                    reversed: filterData.sortReversed[i] ?? filterData.sortKeys[i].defaultReversed,
                    onSortDirectional: (reversed) {
                      filterData.sortReversed[i] = reversed;
                      update();
                    },
                  ),
              ],
            ),
          ...?widget.customFilters?.call(context, update),
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
          FilterGroup<int>(
            title: Text(S.current.noble_phantasm, style: textStyle),
            options: [CardType.arts.value, CardType.buster.value, CardType.quick.value],
            values: filterData.tdCardType,
            optionBuilder: (v) => Text(CardType.getName(v).toTitle()),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<TdEffectFlag>(
            values: filterData.tdType,
            options: TdEffectFlag.values,
            optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.tdEffectFlag).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          getGroup(
            header: S.current.bond,
            children: [
              FilterGroup<CompareOperator>(
                combined: true,
                padding: EdgeInsets.zero,
                options: CompareOperator.values,
                values: filterData.bondCompare,
                optionBuilder: (v) => Text(v.text),
                onFilterChanged: (v, last) {
                  if (v.contain(CompareOperator.lessThan) && v.contain(CompareOperator.moreThan)) {
                    if (last == CompareOperator.lessThan) {
                      v.options.remove(CompareOperator.moreThan);
                    } else if (last == CompareOperator.moreThan) {
                      v.options.remove(CompareOperator.lessThan);
                    }
                  }
                  if (v.options.isEmpty && last != null) {
                    v.options.add(last);
                  }
                  setState(() {
                    update();
                  });
                },
              ),
              FilterGroup<int>(
                combined: true,
                padding: EdgeInsets.zero,
                options: const [5, 6, 10, 15],
                minimumSize: const Size(36, 36),
                values: filterData.bondValue,
                onFilterChanged: (v, _) {
                  setState(() {
                    update();
                  });
                },
              ),
            ],
          ),
          if (widget.showPlans) ...[
            buildGroupDivider(text: S.current.plan),
            FilterGroup<int>(
              title: Text(
                '${S.current.priority} (${S.current.display_setting} - ${S.current.setting_priority_tagging})',
                style: textStyle,
              ),
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
                return Text(switch (v) {
                  SvtPlanScope.all => '(${S.current.general_all})',
                  SvtPlanScope.ascension => S.current.ascension_short,
                  SvtPlanScope.active => S.current.active_skill_short,
                  SvtPlanScope.append => S.current.append_skill_short,
                  SvtPlanScope.costume => S.current.costume,
                  SvtPlanScope.bond => S.current.bond,
                  SvtPlanScope.misc => S.current.general_others,
                });
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
            FilterGroup<SvtStatusState>(
              title: Text("${S.current.current_}: ${S.current.ascension_short}/${S.current.active_skill_short}"),
              options: const [
                SvtStatusState.asc3,
                SvtStatusState.asc4,
                SvtStatusState.active8,
                SvtStatusState.active9,
                SvtStatusState.active10,
              ],
              values: filterData.curStatus,
              optionBuilder: (v) => Text(v.shownName),
              onFilterChanged: (value, _) {
                update();
              },
            ),
            FilterGroup<SvtStatusState>(
              title: Text(
                "${S.current.current_}: ${S.current.append_skill_short}2/${S.current.append_skill_short}(Unlocked only)",
              ),
              options: const [
                SvtStatusState.appendTwo8,
                SvtStatusState.appendTwo9,
                // SvtStatusState.appendTwo10,
                SvtStatusState.append8,
                SvtStatusState.append9,
                // SvtStatusState.append10,
              ],
              values: filterData.curStatus,
              optionBuilder: (v) => Text(v.shownName),
              onFilterChanged: (value, _) {
                update();
              },
            ),
            FilterGroup<SvtStatusMiscType>(
              title: Text(S.current.general_others),
              options: SvtStatusMiscType.values,
              values: filterData.miscStatus,
              optionBuilder: (v) => Text(v.shownName),
              onFilterChanged: (v, _) {
                setState(() {
                  update();
                });
              },
            ),
          ],
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
          FilterGroup<ServantSubAttribute>(
            title: Text(S.current.svt_sub_attribute, style: textStyle),
            options: ServantSubAttribute.validValues,
            values: filterData.attribute,
            optionBuilder: (v) => Text(Transl.svtSubAttribute(v).l),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<ServantPolicy>(
            title: Text(S.current.svt_attribute, style: textStyle),
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
          FilterGroup<CardDeckType>(
            title: Text(S.current.info_cards, style: textStyle),
            options: CardDeckType.values,
            values: filterData.cardDeck,
            optionBuilder: (v) => v == CardDeckType.others
                ? Text(S.current.general_others)
                : Text.rich(
                    TextSpan(
                      children: [
                        for (final (card, count, color) in [
                          ('Q', v.q, Colors.green.shade800),
                          ('A', v.a, Colors.blue.shade800),
                          ('B', v.b, Colors.red),
                        ])
                          TextSpan(
                            text: card * count,
                            style: TextStyle(color: color),
                          ),
                      ],
                    ),
                  ),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<Trait>(
            title: Text(S.current.trait, style: textStyle),
            options: _traitsForFilter.toList(),
            values: filterData.trait,
            optionBuilder: (v) => Text(Transl.traitName(v.value)),
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
          FilterGroup<Event>(
            title: Text(S.current.free_exchange_svt),
            options: freeExchangeSvtEvents.toList(),
            values: filterData.freeExchangeSvtEvent,
            optionBuilder: (v) => Text(v.lShortName.l.setMaxLines(1)),
            onFilterChanged: (value, _) {
              update();
            },
          ),
        ],
      ),
    );
  }

  List<SkillEffect> _getValidEffects(List<SkillEffect> effects) {
    return effects.where((v) => !SkillEffect.svtIgnores.contains(v)).toList();
  }
}

const _traitsForFilter = <Trait>{
  // ce
  Trait.hasCostume,
  Trait.livingHuman,
  Trait.havingAnimalsCharacteristics, // 兽科
  //
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
  Trait.childServant,
  Trait.existenceOutsideTheDomain,
  Trait.oni,
  Trait.genji,
  Trait.mechanical,
  Trait.fae,
  Trait.knightsOfTheRound,
  Trait.fairyTaleServant,
  Trait.divineSpirit,
  Trait.summerModeServant,
  Trait.immuneToPigify,
};
