import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import '../../../models/models.dart';
import '../func/filter.dart';

enum SkillSearchScope {
  svt,
  ce,
  cc,
  mc,
}

class SkillFilterData {
  final type = FilterGroupData<SkillType>();
  final scope = FilterGroupData<SkillSearchScope>();
  final funcTargetType = FilterGroupData<FuncTargetType>();
  final funcType = FilterGroupData<FuncType>();
  final buffType = FilterGroupData<BuffType>();

  List<FilterGroupData> get groups => [type, scope, funcTargetType, funcType, buffType];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

class SkillFilter extends FilterPage<SkillFilterData> {
  const SkillFilter({
    super.key,
    required super.filterData,
    super.onChanged,
  });

  @override
  _SkillFilterState createState() => _SkillFilterState();
}

class _SkillFilterState extends FilterPageState<SkillFilterData, SkillFilter> with FuncFilterMixin {
  @override
  Widget build(BuildContext context) {
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'skill_list_filter', children: [
        FilterGroup<SkillType>(
          title: Text(S.current.general_type),
          options: SkillType.values,
          values: filterData.type,
          optionBuilder: (v) => Text(v.name),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        // FilterGroup<SkillSearchScope>(
        //   title: Text(S.current.effect_scope),
        //   options: SkillSearchScope.values,
        //   values: filterData.scope,
        //   optionBuilder: (v) {
        //     switch (v) {
        //       case SkillSearchScope.svt:
        //         return Text(S.current.servant);
        //       case SkillSearchScope.ce:
        //         return Text(S.current.craft_essence);
        //       case SkillSearchScope.cc:
        //         return Text(S.current.command_code);
        //       case SkillSearchScope.mc:
        //         return Text(S.current.mystic_code);
        //     }
        //   },
        //   onFilterChanged: (value, _) {
        //     update();
        //   },
        // ),
        FilterGroup<FuncTargetType>(
          title: Text(S.current.effect_target),
          options: funcTargetTypes.keys.toList(),
          values: filterData.funcTargetType,
          optionBuilder: (v) => Text(Transl.funcTargetType(v).l),
          onFilterChanged: (value, _) {
            update();
          },
        ),
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

  @override
  Iterable<BaseFunction> getAllFuncs() sync* {
    for (final skill in db.gameData.baseSkills.values) {
      yield* skill.functions;
    }
  }

  @override
  Iterable<Buff> getAllBuffs() sync* {
    for (final skill in db.gameData.baseSkills.values) {
      for (final func in skill.functions) {
        yield* func.buffs;
      }
    }
  }
}
