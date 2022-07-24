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
  final trait = FilterGroupData<int>();

  FuncFilterData();

  List<FilterGroupData> get groups =>
      [funcTargetType, funcTargetTeam, funcType, trait];

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
  _BuffFuncFilterState createState() => _BuffFuncFilterState();
}

class _BuffFuncFilterState extends FilterPageState<FuncFilterData, FuncFilter> {
  Map<FuncType, String> funcTypes = {};
  Map<FuncTargetType, String> funcTargetTypes = {};

  @override
  void initState() {
    super.initState();
    funcTypes = {
      for (final func in db.gameData.baseFunctions.values)
        func.funcType:
            SearchUtil.getSortAlphabet(Transl.funcType(func.funcType).l),
    };
    funcTypes =
        Map.fromEntries(funcTypes.entries.toList()..sort2((e) => e.value));
    funcTargetTypes = {
      for (final func in db.gameData.baseFunctions.values)
        func.funcTargetType: SearchUtil.getSortAlphabet(
            Transl.funcTargetType(func.funcTargetType).l),
    };
    funcTargetTypes = Map.fromEntries(
        funcTargetTypes.entries.toList()..sort2((e) => e.value));
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
        FilterGroup<FuncApplyTarget>(
          title: Text(S.current.effect_target),
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
      ]),
    );
  }
}
