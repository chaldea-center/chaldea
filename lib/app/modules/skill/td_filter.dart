import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import '../../../models/models.dart';
import '../func/filter.dart';

class TdFilterData with FilterDataMixin {
  final card = FilterGroupData<int>();
  final type = FilterGroupData<TdEffectFlag>();
  final funcTargetType = FilterGroupData<FuncTargetType>();
  final funcType = FilterGroupData<FuncType>();
  final buffType = FilterGroupData<BuffType>();

  @override
  List<FilterGroupData> get groups => [card, type, funcTargetType, funcType, buffType];
}

class TdFilter extends FilterPage<TdFilterData> {
  const TdFilter({super.key, required super.filterData, super.onChanged});

  @override
  _TdFilterState createState() => _TdFilterState();
}

class _TdFilterState extends FilterPageState<TdFilterData, TdFilter> with FuncFilterMixin {
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
        restorationId: 'td_list_filter',
        children: [
          FilterGroup<int>(
            title: Text(S.current.general_type),
            options: [CardType.arts.value, CardType.buster.value, CardType.quick.value],
            values: filterData.card,
            optionBuilder: (v) => Text(CardType.getName(v).toTitle()),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<TdEffectFlag>(
            options: TdEffectFlag.values,
            values: filterData.type,
            optionBuilder: (v) => Text(Transl.enums(v, (enums) => enums.tdEffectFlag).l),
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
        ],
      ),
    );
  }

  @override
  Iterable<BaseFunction> getAllFuncs() sync* {
    for (final td in db.gameData.baseTds.values) {
      yield* td.functions;
    }
  }

  @override
  Iterable<Buff> getAllBuffs() sync* {
    for (final td in db.gameData.baseTds.values) {
      for (final func in td.functions) {
        yield* func.buffs;
      }
    }
  }
}
