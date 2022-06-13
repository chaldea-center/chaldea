import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';

class BuffFuncFilterData {
  bool useGrid = false;
  final effectScope = FilterGroupData<SvtEffectScope>();
  final effectTarget = FilterGroupData<FuncTargetType>();
  final funcAndBuff = FilterGroupData();
  final funcType = FilterGroupData<FuncType>();
  final buffType = FilterGroupData<BuffType>();

  BuffFuncFilterData();

  List<FilterGroupData> get groups =>
      [effectScope, effectTarget, funcType, buffType, funcAndBuff];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class BuffFuncFilter extends FilterPage<BuffFuncFilterData> {
  const BuffFuncFilter({
    Key? key,
    required BuffFuncFilterData filterData,
    ValueChanged<BuffFuncFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _BuffFuncFilterState createState() => _BuffFuncFilterState();
}

class _BuffFuncFilterState extends FilterPageState<BuffFuncFilterData> {
  final ignoredFuncTarget = [
    FuncTargetType.ptSelfAnotherFirst,
    FuncTargetType.ptOneHpLowestRate,
    FuncTargetType.commandTypeSelfTreasureDevice,
    FuncTargetType.enemyOneNoTargetNoAction,
  ];
  final ignoredFuncTypes = [FuncType.classDropUp];
  final ignoredBuffTypes = [
    BuffType.donotNobleCondMismatch,
    BuffType.downDefencecommandall,
    BuffType.preventDeathByDamage
  ];

  @override
  Widget build(BuildContext context) {
    Map<FuncType, String> funcs = {
      for (final type in db.gameData.others.allFuncs)
        if (!ignoredFuncTypes.contains(type)) type: Transl.funcType(type).l,
    };
    funcs = Map.fromEntries(funcs.entries.toList()..sort2((e) => e.value));
    Map<BuffType, String> buffs = {
      for (final type in db.gameData.others.allBuffs)
        if (!ignoredBuffTypes.contains(type)) type: Transl.buffType(type).l,
    };
    buffs = Map.fromEntries(buffs.entries.toList()..sort2((e) => e.value));

    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        getGroup(header: S.of(context).filter_sort, children: [
          FilterGroup.display(
            useGrid: filterData.useGrid,
            onChanged: (v) {
              if (v != null) filterData.useGrid = v;
              update();
            },
          ),
        ]),
        FilterGroup<SvtEffectScope>(
          title: Text(S.current.effect_scope),
          options: SvtEffectScope.values,
          values: filterData.effectScope,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<FuncTargetType>(
          title: Text(S.current.effect_target),
          options: db.gameData.others.funcTargets
              .where((e) => !ignoredFuncTarget.contains(e))
              .toList(),
          values: filterData.effectTarget,
          optionBuilder: (v) => Text(Transl.funcTargetType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        const Divider(height: 16),
        FilterGroup<dynamic>(
          options: const [],
          values: filterData.funcAndBuff,
          title: const Text('FuncType & BuffType'),
          showMatchAll: true,
          showInvert: true,
          onFilterChanged: (v, _) {
            update();
          },
        ),
        FilterGroup<FuncType>(
          title: const Text('FuncType'),
          options: funcs.keys.toList(),
          values: filterData.funcType,
          showMatchAll: false,
          showInvert: false,
          optionBuilder: (v) => Text(Transl.funcType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<BuffType>(
          title: const Text('BuffType'),
          options: buffs.keys.toList(),
          values: filterData.buffType,
          showMatchAll: false,
          showInvert: false,
          optionBuilder: (v) => Text(Transl.buffType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }
}
