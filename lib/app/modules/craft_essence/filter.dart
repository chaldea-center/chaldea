import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';
import '../effect_search/util.dart';

class CraftFilterPage extends FilterPage<CraftFilterData> {
  const CraftFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _CraftFilterPageState createState() => _CraftFilterPageState();
}

class _CraftFilterPageState
    extends FilterPageState<CraftFilterData, CraftFilterPage> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'ce_list_filter', children: [
        getGroup(header: S.current.filter_shown_type, children: [
          FilterGroup.display(
            useGrid: filterData.useGrid,
            onChanged: (v) {
              if (v != null) filterData.useGrid = v;
              update();
            },
          ),
        ]),
        //end
        getGroup(header: S.current.filter_sort, children: [
          for (int i = 0; i < CraftCompare.values.length; i++)
            getSortButton<CraftCompare>(
              prefix: '${i + 1}',
              value: filterData.sortKeys[i],
              items: {for (final e in CraftCompare.values) e: e.shownName},
              onSortAttr: (key) {
                filterData.sortKeys[i] = key ?? filterData.sortKeys[i];
                update();
              },
              reversed: filterData.sortReversed[i],
              onSortDirectional: (reversed) {
                filterData.sortReversed[i] = reversed;
                update();
              },
            )
        ]),
        FilterGroup<int>(
          title: Text(S.current.rarity),
          options: const [1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v$kStarChar'),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<CEObtain>(
          title: Text(S.current.filter_category),
          options: CEObtain.values,
          values: filterData.obtain,
          optionBuilder: (v) => Text(Transl.ceObtain(v).l),
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
        FilterGroup<CraftATKType>(
          title: Text(S.current.filter_atk_hp_type),
          options: CraftATKType.values,
          values: filterData.atkType,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        buildGroupDivider(text: S.current.card_collection_status),
        FilterGroup<int>(
          title: Text(S.current.ascension),
          options: const [0, 1, 2, 3, 4],
          values: filterData.limitCount,
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<int>(
          title: Text(S.current.card_collection_status),
          options: CraftStatus.values,
          values: filterData.status,
          optionBuilder: (v) => Text(CraftStatus.shownText(v)),
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
        EffectFilterUtil.buildTraitFilter(
            context, filterData.targetTrait, update),
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
    return effects.where((v) => !SkillEffect.ceIgnores.contains(v)).toList();
  }
}
