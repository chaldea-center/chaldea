import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';
import '../common/filter_group.dart';
import '../common/filter_page_base.dart';

class CraftFilterPage extends FilterPage<CraftFilterData> {
  const CraftFilterPage({
    Key? key,
    required CraftFilterData filterData,
    ValueChanged<CraftFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _CraftFilterPageState createState() => _CraftFilterPageState();
}

class _CraftFilterPageState extends FilterPageState<CraftFilterData> {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_shown_type, children: [
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
              items: Map.fromIterables(CraftCompare.values, [
                S.current.filter_sort_number,
                S.current.filter_sort_rarity,
                'ATK',
                'HP'
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
            )
        ]),
        FilterGroup<int>(
          title: Text(S.current.rarity),
          options: const [1, 2, 3, 4, 5],
          values: filterData.rarity,
          optionBuilder: (v) => Text('$v$kStarChar'),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<CEObtain>(
          title: Text(S.current.filter_category),
          options: CEObtain.values,
          values: filterData.obtain,
          optionBuilder: (v) => Text(Transl.ceObtain(v).l),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<Region>(
          title: Text(S.current.game_server, style: textStyle),
          options: Region.values,
          values: filterData.region,
          optionBuilder: (v) => Text(v.localName),
          onFilterChanged: (v) {
            update();
          },
        ),
        FilterGroup<CraftATKType>(
          title: Text(S.current.filter_atk_hp_type),
          options: CraftATKType.values,
          values: filterData.atkType,
          optionBuilder: (v) => Text(_getHpAtkType(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<int>(
          title: Text(S.current.ce_status),
          options: CraftStatus.values,
          values: filterData.status,
          optionBuilder: (v) => Text(CraftStatus.shownText(v)),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<EffectTarget>(
          title: Text(S.current.effect_target),
          options: EffectTarget.values,
          values: filterData.effectTarget,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value) {
            update();
          },
        ),
        FilterGroup<SkillEffect>(
          title: Text(S.current.effect_type),
          options: List.of(SkillEffect.values
              .where((v) => !SkillEffect.ceIgnores.contains(v))),
          values: filterData.effectType,
          showMatchAll: true,
          showInvert: false,
          optionBuilder: (v) => Text(v.transl.l),
          onFilterChanged: (value) {
            update();
          },
        ),
        // SFooter(Localized.niceSkillFilterHint.localized)
      ]),
    );
  }

  String _getHpAtkType(CraftATKType type) {
    switch (type) {
      case CraftATKType.none:
        return S.current.ce_type_none_hp_atk;
      case CraftATKType.hp:
        return S.current.ce_type_pure_hp;
      case CraftATKType.atk:
        return S.current.ce_type_pure_atk;
      case CraftATKType.mix:
        return S.current.ce_type_mix_hp_atk;
    }
  }
}
