import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';

class BuffFuncFilterData {
  bool useGrid = false;
  final rarity = FilterGroupData<int>();
  final svtClass = FilterGroupData<SvtClass>();
  final region = FilterRadioData<Region>();
  final effectScope = FilterGroupData<SvtEffectScope>(
      options: {SvtEffectScope.active, SvtEffectScope.td});
  final effectTarget = FilterGroupData<FuncTargetType>();
  final funcAndBuff = FilterGroupData();
  final funcType = FilterGroupData<FuncType>();
  final buffType = FilterGroupData<BuffType>();
  final targetTrait = FilterGroupData<int>();

  BuffFuncFilterData();

  List<FilterGroupData> get groups => [
        rarity,
        svtClass,
        region,
        effectScope,
        effectTarget,
        funcType,
        buffType,
        funcAndBuff,
        targetTrait
      ];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
    effectScope.options = {SvtEffectScope.active, SvtEffectScope.td};
  }
}

class BuffFuncFilter extends FilterPage<BuffFuncFilterData> {
  final bool showClassFilter;
  const BuffFuncFilter({
    Key? key,
    required BuffFuncFilterData filterData,
    this.showClassFilter = true,
    ValueChanged<BuffFuncFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _BuffFuncFilterState createState() => _BuffFuncFilterState();
}

class _BuffFuncFilterState
    extends FilterPageState<BuffFuncFilterData, BuffFuncFilter> {
  final ignoredFuncTarget = [
    FuncTargetType.ptSelfAnotherFirst,
    FuncTargetType.ptOneHpLowestRate,
    FuncTargetType.commandTypeSelfTreasureDevice,
    FuncTargetType.enemyOneNoTargetNoAction,
  ];
  final ignoredFuncTypes = [FuncType.classDropUp];
  final ignoredBuffTypes = [
    BuffType.donotNobleCondMismatch,
    // BuffType.downDefencecommandall,
    BuffType.preventDeathByDamage
  ];

  Map<FuncType, String> funcs = {};
  Map<BuffType, String> buffs = {};
  @override
  void initState() {
    super.initState();
    funcs = {
      for (final type in db.gameData.others.allFuncs)
        if (!ignoredFuncTypes.contains(type)) type: Transl.funcType(type).l,
    };
    funcs = Map.fromEntries(funcs.entries.toList()
      ..sort2((e) => SearchUtil.getSortAlphabet(e.value)));

    buffs = {
      for (final type in db.gameData.others.allBuffs)
        if (!ignoredBuffTypes.contains(type)) type: Transl.buffType(type).l,
    };
    buffs = Map.fromEntries(buffs.entries.toList()
      ..sort2((e) => SearchUtil.getSortAlphabet(e.value)));
  }

  @override
  Widget build(BuildContext context) {
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
        if (widget.showClassFilter) buildClassFilter(filterData.svtClass),
        FilterGroup<int>(
          title: Text(S.of(context).filter_sort_rarity, style: textStyle),
          options: const [0, 1, 2, 3, 4, 5],
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
        const Divider(height: 16, indent: 12, endIndent: 12),
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
        FilterGroup<int>(
          title: const Text('Card'),
          options: [
            Trait.cardQuick.id!,
            Trait.cardArts.id!,
            Trait.cardBuster.id!,
            Trait.cardExtra.id!,
            Trait.cardNP.id!,
          ],
          values: filterData.targetTrait,
          showMatchAll: false,
          showInvert: false,
          optionBuilder: (v) => Text({
                Trait.cardQuick.id!: 'Quick',
                Trait.cardArts.id!: 'Arts',
                Trait.cardBuster.id!: 'Buster',
                Trait.cardExtra.id!: 'Extra',
                Trait.cardNP.id!: S.current.np_short,
              }[v] ??
              v.toString()),
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
