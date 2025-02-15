import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';

class CmdCodeFilterPage extends FilterPage<CmdCodeFilterData> {
  const CmdCodeFilterPage({super.key, required super.filterData, super.onChanged});

  @override
  _CmdCodeFilterPageState createState() => _CmdCodeFilterPageState();
}

class _CmdCodeFilterPageState extends FilterPageState<CmdCodeFilterData, CmdCodeFilterPage> {
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
        restorationId: 'cc_list_filter',
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
            ],
          ),
          //end
          getGroup(
            header: S.current.filter_sort,
            children: [
              for (int i = 0; i < CmdCodeCompare.values.length; i++)
                getSortButton<CmdCodeCompare>(
                  prefix: '${i + 1}',
                  value: filterData.sortKeys[i],
                  items: {for (final e in CmdCodeCompare.values) e: e.shownName},
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
            ],
          ),
          FilterGroup<int>(
            title: Text(S.current.rarity),
            options: const [1, 2, 3, 4, 5],
            values: filterData.rarity,
            optionBuilder: (v) => Text('$v$kStarChar'),
            onFilterChanged: (value, _) {
              update();
            },
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
          buildGroupDivider(text: S.current.card_collection_status),
          FilterGroup<int>(
            title: Text(S.current.card_collection_status),
            options: CmdCodeStatus.values,
            values: filterData.status,
            optionBuilder: (v) => Text(CmdCodeStatus.shownText(v)),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          buildGroupDivider(text: S.current.effect_search),
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
        ],
      ),
    );
  }

  List<SkillEffect> _getValidEffects(List<SkillEffect> effects) {
    return effects.where((v) => !SkillEffect.ccIgnores.contains(v)).toList();
  }
}
