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
    return name;
  }
}

enum CELimitType {
  allowed,
  allowedNoMLB,
  banned,
  ;

  String get shownName {
    return name;
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
  static List<int> get _blockedSvtIds => [16, 258, 284, 316];

  final attackerTdCardType = FilterRadioData<CardType>(); // attacker only
  final blockedSvts = FilterGroupData<int>();
  final useSvts = FilterRadioData<int>();
  final normalAttackCount = FilterRadioData<int>.nonnull(-1);
  final criticalAttackCount = FilterRadioData<int>.nonnull(-1);
  final miscOptions = FilterGroupData<TeamFilterMiscType>();
  final kaleidoCELimit = FilterRadioData<CELimitType>.nonnull(CELimitType.allowed);
  final blackGrailLimit = FilterRadioData<CELimitType>.nonnull(CELimitType.allowed);

  List<FilterGroupData> get groups => [
        attackerTdCardType,
        blockedSvts,
        useSvts,
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
  const TeamFilter({
    super.key,
    required super.filterData,
    super.onChanged,
    this.availableSvts = const {},
  });

  @override
  _ShopFilterState createState() => _ShopFilterState();
}

class _ShopFilterState extends FilterPageState<TeamFilterData, TeamFilter> {
  @override
  Widget build(BuildContext context) {
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
        FilterGroup<int>(
          title: const Text("Blocked Servants"),
          options: TeamFilterData._blockedSvtIds,
          values: filterData.blockedSvts,
          optionBuilder: (v) => svtIcon(v),
          shrinkWrap: true,
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
          header: "Attacks",
          children: [
            DropdownButton(
              isDense: true,
              value: filterData.normalAttackCount.radioValue,
              items: [
                for (int count in [-1, 0, 1, 2, 3, 4, 5])
                  DropdownMenuItem(
                    value: count,
                    child: Text(
                      "Normal Attack ≤${count == -1 ? "Any" : count}",
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
                      "${S.current.critical_attack} ≤${count == -1 ? "Any" : count}",
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
          title: const Text("Use Servant"),
          options: widget.availableSvts.toList(),
          values: filterData.useSvts,
          optionBuilder: (v) => svtIcon(v),
          shrinkWrap: true,
          onFilterChanged: (value, _) {
            update();
          },
        ),
      ]),
    );
  }

  Widget svtIcon(int id) {
    final svt = db.gameData.servantsNoDup[id] ?? db.gameData.servantsById[id];
    if (svt == null) return Text(id.toString());
    return Opacity(
      opacity: 0.9,
      child: svt.iconBuilder(
        context: context,
        height: 42,
        jumpToDetail: false,
        padding: const EdgeInsets.all(2),
      ),
    );
  }
}
