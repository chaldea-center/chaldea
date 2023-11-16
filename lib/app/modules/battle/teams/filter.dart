import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';

enum TeamFilterMiscType {
  noOrderChange,
  noSameSvt,
  noAppendSkill,
  noGrailFou,
  noLv100,
  ;

  String get shownName {
    switch (this) {
      case noOrderChange:
        return S.current.team_no_order_change;
      case noSameSvt:
        return S.current.team_no_same_svt;
      case noAppendSkill:
        return S.current.team_no_append_skill;
      case noGrailFou:
        return S.current.team_no_grail_fou;
      case noLv100:
        return S.current.team_no_lv100;
    }
  }
}

class TeamFilterData {
  // static const List<int> _blockedSvtIds = [16, 258, 284, 307, 314, 316, 357];

  bool favorite = false;
  final attackerTdCardType = FilterRadioData<CardType>(); // attacker only
  final blockSvts = FilterGroupData<int>();
  final useSvts = FilterGroupData<int>();
  final blockCEs = FilterGroupData<int>();
  final blockCEMLBOnly = <int, bool>{}; // true=block MLB only
  final normalAttackCount = FilterRadioData<int>.nonnull(-1);
  final criticalAttackCount = FilterRadioData<int>.nonnull(-1);
  final miscOptions = FilterGroupData<TeamFilterMiscType>();

  List<FilterGroupData> get groups => [
        attackerTdCardType,
        blockSvts,
        useSvts,
        blockCEs,
        normalAttackCount,
        criticalAttackCount,
        miscOptions,
      ];

  void reset() {
    favorite = false;
    for (final group in groups) {
      group.reset();
    }
    blockCEMLBOnly.clear();
  }
}

class TeamFilter extends FilterPage<TeamFilterData> {
  final Set<int> availableSvts; // in fetched teams
  final Set<int> availableCEs;
  const TeamFilter({
    super.key,
    required super.filterData,
    super.onChanged,
    this.availableSvts = const {},
    required this.availableCEs,
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<TeamFilterData, TeamFilter> {
  @override
  Widget build(BuildContext context) {
    final availableSvts =
        {...widget.availableSvts, ...filterData.useSvts.options, ...filterData.blockSvts.options}.toList();
    availableSvts.sort((a, b) => SvtFilterData.compare(db.gameData.servantsById[a], db.gameData.servantsById[b],
        keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no], reversed: [true, false, true]));
    final availableCEs = {...widget.availableCEs, ...filterData.blockCEs.options}.toList();
    availableCEs.sort((a, b) => CraftFilterData.compare(
        db.gameData.craftEssencesById[a], db.gameData.craftEssencesById[b],
        keys: [CraftCompare.rarity, CraftCompare.no], reversed: [true, true]));
    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'team_list_filter', children: [
        FilterGroup<bool>(
          options: const [true],
          values: FilterRadioData(filterData.favorite),
          optionBuilder: (v) => Text(S.current.favorite),
          onFilterChanged: (value, _) {
            filterData.favorite = !filterData.favorite;
            update();
          },
        ),
        FilterGroup<CardType>(
          title: Text(S.current.noble_phantasm, style: textStyle),
          options: const [CardType.arts, CardType.buster, CardType.quick],
          values: filterData.attackerTdCardType,
          optionBuilder: (v) => Text(v.name.toTitle()),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<TeamFilterMiscType>(
          title: Text("Misc", style: textStyle),
          options: TeamFilterMiscType.values,
          values: filterData.miscOptions,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        getGroup(
          header: S.current.battle_command_card,
          children: [
            DropdownButton(
              isDense: true,
              value: filterData.normalAttackCount.radioValue,
              items: [
                for (int count in [-1, 0, 1, 2, 3, 4, 5])
                  DropdownMenuItem(
                    value: count,
                    child: Text(
                      "${S.current.battle_command_card} ${count == -1 ? S.current.general_any : "≤$count"}",
                      textScaler: const TextScaler.linear(0.8),
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  filterData.normalAttackCount.set(v);
                }
                update();
              },
            ),
            DropdownButton(
              isDense: true,
              value: filterData.criticalAttackCount.radioValue,
              items: [
                for (int count in [-1, 0, 1, 2, 3, 4, 5])
                  DropdownMenuItem(
                    value: count,
                    child: Text(
                      "${S.current.critical_attack} ${count == -1 ? S.current.general_any : "≤$count"}",
                      textScaler: const TextScaler.linear(0.8),
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  filterData.criticalAttackCount.set(v);
                }
                update();
              },
            ),
          ],
        ),
        FilterGroup<int>(
          title: Text(S.current.team_block_servant),
          options: availableSvts,
          values: filterData.blockSvts,
          constraints: const BoxConstraints(maxHeight: 50),
          optionBuilder: (v) => cardIcon(v),
          shrinkWrap: true,
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<int>(
          title: Text(S.current.team_use_servant),
          options: availableSvts,
          values: filterData.useSvts,
          optionBuilder: (v) => cardIcon(v),
          shrinkWrap: true,
          constraints: const BoxConstraints(maxHeight: 50),
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<int>(
          title: Text.rich(TextSpan(text: '${S.current.team_block_ce}  ( ', children: [
            TextSpan(
              text: S.current.disabled,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const TextSpan(text: '  '),
            TextSpan(
              text: S.current.disallow_mlb,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const TextSpan(text: ' )'),
          ])),
          options: availableCEs,
          values: filterData.blockCEs.copy(),
          constraints: const BoxConstraints(maxHeight: 50),
          optionBuilder: (v) => cardIcon(v,
              color: filterData.blockCEs.options.contains(v)
                  ? (filterData.blockCEMLBOnly[v] ?? false)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error
                  : null),
          shrinkWrap: true,
          onFilterChanged: (_, last) {
            if (last != null) {
              // null-false-true
              if (!filterData.blockCEs.options.contains(last)) {
                filterData.blockCEs.options.add(last);
                filterData.blockCEMLBOnly[last] = false;
              } else {
                if (filterData.blockCEMLBOnly[last] != true) {
                  filterData.blockCEMLBOnly[last] = true;
                } else {
                  filterData.blockCEs.options.remove(last);
                  filterData.blockCEMLBOnly.remove(last);
                }
              }
            }
            update();
          },
        ),
      ]),
    );
  }

  Widget cardIcon(int id, {Color? color}) {
    final card = db.gameData.servantsById[id] ?? db.gameData.craftEssencesById[id];
    Widget child = card == null
        ? Text(id.toString())
        : Opacity(
            opacity: 0.9,
            child: card.iconBuilder(
              context: context,
              height: 42,
              jumpToDetail: false,
            ),
          );
    if (color != null) {
      child = Container(
        padding: const EdgeInsets.all(2),
        color: color,
        child: child,
      );
    } else {
      child = Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      );
    }
    return child;
  }
}
