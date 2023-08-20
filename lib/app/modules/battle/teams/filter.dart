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

enum CELimitType {
  allowed,
  allowedNoMLB,
  banned,
  ;

  String get shownName {
    switch (this) {
      case allowed:
        return S.current.general_any;
      case allowedNoMLB:
        return S.current.non_mlb;
      case banned:
        return S.current.disabled;
    }
  }

  bool check(bool mlb) {
    switch (this) {
      case CELimitType.allowed:
        return true;
      case CELimitType.allowedNoMLB:
        return !mlb;
      case CELimitType.banned:
        return false;
    }
  }
}

class TeamFilterData {
  // static const List<int> _blockedSvtIds = [16, 258, 284, 307, 314, 316, 357];

  final attackerTdCardType = FilterRadioData<CardType>(); // attacker only
  final blockSvts = FilterGroupData<int>();
  final useSvts = FilterRadioData<int>();
  final blockCEs = FilterGroupData<int>();
  final normalAttackCount = FilterRadioData<int>.nonnull(-1);
  final criticalAttackCount = FilterRadioData<int>.nonnull(-1);
  final miscOptions = FilterGroupData<TeamFilterMiscType>();
  final kaleidoCELimit = FilterRadioData<CELimitType>.nonnull(CELimitType.allowed);
  final blackGrailLimit = FilterRadioData<CELimitType>.nonnull(CELimitType.allowed);

  List<FilterGroupData> get groups => [
        attackerTdCardType,
        blockSvts,
        useSvts,
        blockCEs,
        normalAttackCount,
        criticalAttackCount,
        miscOptions,
        kaleidoCELimit,
        blackGrailLimit,
      ];

  void reset() {
    for (final group in groups) {
      group.reset();
    }
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
    final availableSvts = widget.availableSvts.toList();
    availableSvts.sort((a, b) => SvtFilterData.compare(db.gameData.servantsById[a], db.gameData.servantsById[b],
        keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no], reversed: [true, false, true]));
    final availableCEs = widget.availableCEs.toList();
    availableCEs.sort((a, b) => CraftFilterData.compare(
        db.gameData.craftEssencesById[a], db.gameData.craftEssencesById[b],
        keys: [CraftCompare.rarity, CraftCompare.no], reversed: [true, true]));
    return buildAdaptive(
      title: Text(S.current.filter, textScaleFactor: 0.8),
      actions: getDefaultActions(onTapReset: () {
        filterData.reset();
        update();
      }),
      content: getListViewBody(restorationId: 'team_list_filter', children: [
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
        FilterGroup<CELimitType>(
          title: Text(db.gameData.craftEssences[34]?.lName.l ?? "The Black Grail"),
          options: CELimitType.values,
          values: filterData.kaleidoCELimit,
          optionBuilder: (v) {
            return Text(v.shownName);
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
        FilterGroup<CELimitType>(
          title: Text(db.gameData.craftEssences[48]?.lName.l ?? "The Black Grail"),
          options: CELimitType.values,
          values: filterData.blackGrailLimit,
          optionBuilder: (v) {
            return Text(v.shownName);
          },
          onFilterChanged: (value, _) {
            update();
          },
        ),
        getGroup(
          header: S.current.battle_attack,
          children: [
            DropdownButton(
              isDense: true,
              value: filterData.normalAttackCount.radioValue,
              items: [
                for (int count in [-1, 0, 1, 2, 3, 4, 5])
                  DropdownMenuItem(
                    value: count,
                    child: Text(
                      "${S.current.normal_attack} ${count == -1 ? S.current.general_any : "≤$count"}",
                      textScaleFactor: 0.8,
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
                      textScaleFactor: 0.8,
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
          title: Text(S.current.team_block_ce),
          options: availableCEs,
          values: filterData.blockCEs,
          constraints: const BoxConstraints(maxHeight: 50),
          optionBuilder: (v) => cardIcon(v),
          shrinkWrap: true,
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }

  Widget cardIcon(int id) {
    final card = db.gameData.servantsById[id] ?? db.gameData.craftEssencesById[id];
    if (card == null) return Text(id.toString());
    return Opacity(
      opacity: 0.9,
      child: card.iconBuilder(
        context: context,
        height: 42,
        jumpToDetail: false,
        padding: const EdgeInsets.all(2),
      ),
    );
  }
}
