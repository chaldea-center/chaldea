import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';

class FuncFilterData {
  final funcTargetType = FilterGroupData<FuncTargetType>();
  final funcTargetTeam = FilterGroupData<FuncApplyTarget>();
  final funcType = FilterGroupData<FuncType>();
  final buffType = FilterGroupData<BuffType>();
  final trait = FilterGroupData<int>();

  FuncFilterData();

  List<FilterGroupData> get groups =>
      [funcTargetType, funcTargetTeam, funcType, buffType, trait];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class FuncFilter extends FilterPage<FuncFilterData> {
  const FuncFilter({
    Key? key,
    required FuncFilterData filterData,
    ValueChanged<FuncFilterData>? onChanged,
  }) : super(key: key, onChanged: onChanged, filterData: filterData);

  @override
  _FuncFilterState createState() => _FuncFilterState();
}

class _FuncFilterState extends FilterPageState<FuncFilterData, FuncFilter>
    with FuncFilterMixin {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(children: [
        FilterGroup<FuncApplyTarget>(
          title: const Text('Target Team'),
          options: FuncApplyTarget.values,
          values: filterData.funcTargetTeam,
          optionBuilder: (v) => Text(v.name),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<FuncTargetType>(
          title: Text(S.current.effect_target),
          options: funcTargetTypes.keys.toList(),
          values: filterData.funcTargetType,
          optionBuilder: (v) => Text(Transl.funcTargetType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        // FilterGroup<int>(
        //   title: const Text('Condition Traits'),
        //   options: [],
        //   values: filterData.trait,
        //   showMatchAll: false,
        //   showInvert: false,
        //   optionBuilder: (v) => Text(Transl.trait(v).l),
        //   onFilterChanged: (value, _) {
        //     update();
        //   },
        // ),
        const Divider(height: 16),
        FilterGroup<FuncType>(
          title: const Text('Func Type'),
          options: funcTypes.keys.toList(),
          values: filterData.funcType,
          showMatchAll: false,
          showInvert: false,
          optionBuilder: (v) => Text(Transl.funcType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        const Divider(height: 16),
        FilterGroup<BuffType>(
          title: const Text('Buff Type'),
          options: buffTypes.keys.toList(),
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

mixin FuncFilterMixin {
  late Map<FuncType, String> funcTypes = _getFuncTypes();
  late Map<FuncTargetType, String> funcTargetTypes = _getFuncTargetTypes();
  late Map<BuffType, String> buffTypes = _getBuffTypes();

  Iterable<BaseFunction> getAllFuncs() => db.gameData.baseFunctions.values;
  Iterable<Buff> getAllBuffs() => db.gameData.baseBuffs.values;

  Map<FuncType, String> _getFuncTypes() {
    var types = {
      for (final func in getAllFuncs())
        func.funcType:
            SearchUtil.getSortAlphabet(Transl.funcType(func.funcType).l),
    };
    return Map.fromEntries(types.entries.toList()..sort2((e) => e.value));
  }

  Map<FuncTargetType, String> _getFuncTargetTypes() {
    var types = {
      for (final func in getAllFuncs())
        func.funcTargetType: SearchUtil.getSortAlphabet(
            Transl.funcTargetType(func.funcTargetType).l),
    };
    return Map.fromEntries(types.entries.toList()..sort2((e) => e.value));
  }

  Map<BuffType, String> _getBuffTypes() {
    var types = {
      for (final buff in getAllBuffs())
        buff.type: SearchUtil.getSortAlphabet(Transl.buffType(buff.type).l),
    };
    return Map.fromEntries(types.entries.toList()..sort2((e) => e.value));
  }
}
