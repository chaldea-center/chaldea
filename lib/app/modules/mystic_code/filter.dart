import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/effect.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';

class MysticCodeFilterPage extends FilterPage<MysticCodeFilterData> {
  const MysticCodeFilterPage({super.key, required super.filterData, super.onChanged});

  @override
  _MysticCodeFilterPageState createState() => _MysticCodeFilterPageState();
}

class _MysticCodeFilterPageState extends FilterPageState<MysticCodeFilterData, MysticCodeFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(
        onTapReset: () {
          filterData.reset();
          update();
        },
      ),
      content: getListViewBody(
        restorationId: 'mc_list_filter',
        children: [
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
              FilterGroup<bool>(
                padding: EdgeInsets.zero,
                options: const [true, false],
                values: FilterRadioData.nonnull(filterData.ascending),
                optionBuilder: (v) => Text('${S.current.sort_order} ${v ? "↑" : "↓"}'),
                combined: true,
                onFilterChanged: (v, _) {
                  filterData.ascending = v.radioValue ?? filterData.ascending;
                  update();
                },
              ),
            ],
          ),
          FilterGroup<Region>(
            title: Text(S.current.game_server, style: textStyle),
            options: Region.values,
            values: filterData.region,
            optionBuilder: (v) => Text(v.localName),
            onFilterChanged: (v, _) {
              update();
            },
          ),
          buildGroupDivider(text: S.current.effect_search),
          FilterGroup<EffectTarget>(
            title: Text(S.current.effect_target),
            options: const [EffectTarget.ptOne, EffectTarget.ptAll, EffectTarget.enemy, EffectTarget.enemyAll],
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
        ],
      ),
    );
  }

  List<SkillEffect> _getValidEffects(List<SkillEffect> effects) {
    return effects.where((v) => !SkillEffect.mcIgnores.contains(v)).toList();
  }
}
