import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widget_builders.dart';

enum TeamFilterMiscType {
  noOrderChange,
  noAppendSkill,
  noGrailFou,
  noLv100,
  noSameSvt,
  noDoubleCastoria,
  noDoubleKoyan,
  noDoubleOberon;

  String get shownName {
    return switch (this) {
      noOrderChange => S.current.team_no_order_change,
      noAppendSkill => S.current.team_no_append_skill,
      noGrailFou => S.current.team_no_grail_fou,
      noLv100 => S.current.team_no_lv100,
      noSameSvt => S.current.team_no_same_svt,
      noDoubleCastoria => S.current.team_no_double_castoria,
      noDoubleKoyan => S.current.team_no_double_koyan,
      noDoubleOberon => S.current.team_no_double_oberon,
    };
  }
}

class TeamFilterData with FilterDataMixin {
  // static const List<int> _blockedSvtIds = [16, 258, 284, 307, 314, 316, 357];
  final bool hasFavorite;
  TeamFilterData(this.hasFavorite);

  bool favorite = false;
  final attackerTdCardType = FilterRadioData<CardType>(); // attacker only
  final blockSvts = FilterGroupData<int>();
  final useSvts = FilterGroupData<int>();
  int useSvtTdLv = 0;
  final blockCEs = FilterGroupData<int>();
  final blockCEMLBOnly = <int, bool>{}; // true=block MLB only
  final normalAttackCount = FilterRadioData<int>.nonnull(-1);
  final criticalAttackCount = FilterRadioData<int>.nonnull(-1);
  final tdAttackCount = FilterRadioData<int>.nonnull(-1);
  final mysticCode = FilterGroupData<int>();
  final miscOptions = FilterGroupData<TeamFilterMiscType>();
  final eventWarId = FilterRadioData<int>();

  @override
  List<FilterGroupData> get groups => [
    attackerTdCardType,
    blockSvts,
    useSvts,
    blockCEs,
    normalAttackCount,
    criticalAttackCount,
    tdAttackCount,
    mysticCode,
    miscOptions,
    eventWarId,
  ];

  @override
  void reset() {
    super.reset();
    favorite = false;
    useSvtTdLv = 0;
    blockCEMLBOnly.clear();
  }

  bool filter(BattleShareData data) {
    final filterData = this;

    final eventWarId = filterData.eventWarId.radioValue;
    if (eventWarId != null && db.gameData.quests[data.quest?.id]?.eventIdPriorWarId != eventWarId) {
      return false;
    }

    for (final svtId in filterData.blockSvts.options) {
      if (data.formation.allSvts.any((svt) => svt?.svtId == svtId)) {
        return false;
      }
    }
    if (filterData.useSvts.options.isNotEmpty &&
        !filterData.useSvts.options.every((svtId) => data.formation.allSvts.any((e) => e?.svtId == svtId))) {
      return false;
    }
    if (filterData.useSvts.options.length == 1 && filterData.useSvtTdLv > 0) {
      final svtId = filterData.useSvts.options.single;
      if (!data.formation.allSvts.any(
        (e) => e != null && e.svtId == svtId && (e.tdId ?? 0) != 0 && e.tdLv <= filterData.useSvtTdLv,
      )) {
        return false;
      }
    }

    bool _isCEMismatch(SvtSaveData? svt, int ceId) {
      if (svt == null || (svt.svtId ?? 0) <= 0) return false;
      if (svt.ceId != ceId) return false;
      final mlbOnly = filterData.blockCEMLBOnly[ceId] ?? false;
      return mlbOnly ? svt.ceLimitBreak : true;
    }

    for (final ceId in filterData.blockCEs.options) {
      if (data.formation.allSvts.any((svt) => _isCEMismatch(svt, ceId))) {
        return false;
      }
    }

    final attackerTdCard = filterData.attackerTdCardType.radioValue;
    if (attackerTdCard != null) {
      final tdCheck = data.containsTdCardType(attackerTdCard);
      if (tdCheck == false) {
        return false;
      }
    }

    int maxNormalAttackCount = filterData.normalAttackCount.radioValue!;
    int maxCriticalAttackCount = filterData.criticalAttackCount.radioValue!;
    int maxTdCount = filterData.tdAttackCount.radioValue!;

    if (maxNormalAttackCount >= 0 && data.normalAttackCount > maxNormalAttackCount) {
      return false;
    }
    if (maxCriticalAttackCount >= 0 && data.critsCount > maxCriticalAttackCount) {
      return false;
    }
    if (maxTdCount > 0 && data.tdAttackCount > maxTdCount) {
      return false;
    }

    if (filterData.mysticCode.isNotEmpty) {
      final mcId = data.hasUsedMCSkills() ? data.formation.mysticCode.mysticCodeId ?? 0 : 0;
      if (!filterData.mysticCode.matchOne(mcId)) {
        return false;
      }
    }

    for (final miscOption in filterData.miscOptions.options) {
      switch (miscOption) {
        case TeamFilterMiscType.noOrderChange:
          if ([20, 210].contains(data.formation.mysticCode.mysticCodeId) && data.usedMysticCodeSkill(2) == true) {
            return false;
          }
        case TeamFilterMiscType.noSameSvt:
          final svtIds = data.formation.allSvts.map((e) => e?.svtId ?? 0).where((e) => e > 0).toList();
          if (svtIds.length != svtIds.toSet().length) {
            return false;
          }
        case TeamFilterMiscType.noAppendSkill:
          for (final svt in data.formation.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (svt.appendLvs.any((lv) => lv > 0)) {
              return false;
            }
          }
        case TeamFilterMiscType.noGrailFou:
          for (final svt in data.formation.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (dbSvt.type != SvtType.heroine && svt.lv > dbSvt.lvMax) {
              return false;
            }
            if (svt.hpFou > 1000 || svt.atkFou > 1000) {
              return false;
            }
          }
        case TeamFilterMiscType.noLv100:
          for (final svt in data.formation.allSvts) {
            final dbSvt = db.gameData.servantsById[svt?.svtId];
            if (svt == null || dbSvt == null) continue;
            if (svt.lv > 100) {
              return false;
            }
          }
          break;
        case TeamFilterMiscType.noDoubleCastoria:
          if (data.formation.allSvts.where((e) => e?.svtId == 504500).length >= 2) {
            return false;
          }
          break;
        case TeamFilterMiscType.noDoubleKoyan:
          if (data.formation.allSvts.where((e) => e?.svtId == 604200).length >= 2) {
            return false;
          }
          break;
        case TeamFilterMiscType.noDoubleOberon:
          if (data.formation.allSvts.where((e) => e?.svtId == 2800100).length >= 2) {
            return false;
          }
          break;
      }
    }

    return true;
  }
}

class TeamFilterPage extends FilterPage<TeamFilterData> {
  final Set<int> availableSvts; // in fetched teams
  final Set<int> availableCEs;
  final Set<int> availableMCs;
  final Set<int> availableEventWarIds;

  const TeamFilterPage({
    super.key,
    required super.filterData,
    super.onChanged,
    required this.availableSvts,
    required this.availableCEs,
    required this.availableMCs,
    required this.availableEventWarIds,
  });

  @override
  _TeamFilterPageState createState() => _TeamFilterPageState();
}

class _TeamFilterPageState extends FilterPageState<TeamFilterData, TeamFilterPage> {
  @override
  Widget build(BuildContext context) {
    final availableSvts =
        {...widget.availableSvts, ...filterData.useSvts.options, ...filterData.blockSvts.options}.toList();
    availableSvts.sort(
      (a, b) => SvtFilterData.compare(
        db.gameData.servantsById[a],
        db.gameData.servantsById[b],
        keys: [SvtCompare.rarity, SvtCompare.className, SvtCompare.no],
        reversed: [true, false, true],
      ),
    );
    final availableCEs = {...widget.availableCEs, ...filterData.blockCEs.options}.toList();
    availableCEs.sort(
      (a, b) => CraftFilterData.compare(
        db.gameData.craftEssencesById[a],
        db.gameData.craftEssencesById[b],
        keys: [CraftCompare.rarity, CraftCompare.no],
        reversed: [true, true],
      ),
    );
    final availableMCs = {0, ...widget.availableMCs, ...filterData.mysticCode.options}.toList()..sort();
    final availableEventWarIds =
        {...widget.availableEventWarIds, ...filterData.eventWarId.options}.toList()
          ..sortByList((e) => [db.gameData.events.containsKey(e) ? 1 : 0, -(db.gameData.events[e]?.startedAt ?? -e)]);

    return buildAdaptive(
      title: Text(S.current.filter, textScaler: const TextScaler.linear(0.8)),
      actions: getDefaultActions(
        onTapReset: () {
          filterData.reset();
          update();
        },
      ),
      content: getListViewBody(
        restorationId: 'team_list_filter',
        children: [
          if (filterData.hasFavorite)
            FilterGroup<bool>(
              options: const [true],
              values: FilterRadioData(filterData.favorite),
              optionBuilder: (v) => Text(S.current.favorite),
              onFilterChanged: (value, _) {
                filterData.favorite = !filterData.favorite;
                update();
              },
            ),
          if (availableEventWarIds.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<int?>(
                isExpanded: true,
                value: filterData.eventWarId.radioValue,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('${S.current.war}: ${S.current.general_any}', style: const TextStyle(fontSize: 14)),
                  ),
                  for (final id in availableEventWarIds)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        (db.gameData.events[id]?.lName.l ?? db.gameData.wars[id]?.lName.l ?? id.toString()).setMaxLines(
                          1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v == null) {
                    filterData.eventWarId.reset();
                  } else {
                    filterData.eventWarId.set(v);
                  }
                  update();
                },
              ),
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
            header: '${S.current.battle_attack} ${S.current.counts}',
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
              DropdownButton(
                isDense: true,
                value: filterData.tdAttackCount.radioValue,
                items: [
                  for (int count in [-1, 2, 3, 4, 5])
                    DropdownMenuItem(
                      value: count,
                      child: Text(
                        "${S.current.np_short} ${count == -1 ? S.current.general_any : "≤$count"}",
                        textScaler: const TextScaler.linear(0.8),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    filterData.tdAttackCount.set(v);
                  }
                  update();
                },
              ),
            ],
          ),
          FilterGroup<int>(
            title: Text(S.current.mystic_code),
            showInvert: true,
            options: availableMCs,
            values: filterData.mysticCode,
            constraints: const BoxConstraints(maxHeight: 50),
            optionBuilder: (v) => cardIcon(v, db.gameData.mysticCodes[v]),
            shrinkWrap: true,
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<int>(
            title: Text(S.current.team_block_servant),
            options: availableSvts,
            values: filterData.blockSvts,
            constraints: const BoxConstraints(maxHeight: 50),
            optionBuilder: (v) => cardIcon(v, db.gameData.servantsById[v]),
            shrinkWrap: true,
            onFilterChanged: (value, _) {
              update();
            },
          ),
          FilterGroup<int>(
            title: Text(S.current.team_use_servant),
            options: availableSvts,
            values: filterData.useSvts,
            optionBuilder: (v) => cardIcon(v, db.gameData.servantsById[v]),
            shrinkWrap: true,
            constraints: const BoxConstraints(maxHeight: 50),
            onFilterChanged: (value, _) {
              update();
            },
          ),
          ListTile(
            dense: true,
            enabled: filterData.useSvts.options.length == 1,
            title: Text(S.current.noble_phantasm_level),
            subtitle: Text.rich(
              TextSpan(
                text: '${S.current.team_use_servant}: ',
                children: [
                  filterData.useSvts.options.length == 1
                      ? CenterWidgetSpan(
                        child: GameCardMixin.anyCardItemBuilder(
                          context: context,
                          id: filterData.useSvts.options.single,
                          width: 18,
                        ),
                      )
                      : const TextSpan(text: "Select 1 servant"),
                ],
              ),
            ),
            trailing: DropdownButton<int>(
              isDense: true,
              value: filterData.useSvtTdLv,
              items: [
                for (final tdLv in range(5))
                  DropdownMenuItem(value: tdLv, child: Text(tdLv == 0 ? S.current.general_any : '≤Lv$tdLv')),
              ],
              onChanged:
                  filterData.useSvts.options.length == 1
                      ? (v) {
                        if (v != null) filterData.useSvtTdLv = v;
                        update();
                      }
                      : null,
            ),
          ),
          FilterGroup<int>(
            title: Text.rich(
              TextSpan(
                text: '${S.current.team_block_ce}  ( ',
                children: [
                  TextSpan(text: S.current.disabled, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: S.current.disallow_mlb,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const TextSpan(text: ' )'),
                ],
              ),
            ),
            options: availableCEs,
            values: filterData.blockCEs.copy(),
            constraints: const BoxConstraints(maxHeight: 50),
            optionBuilder:
                (v) => cardIcon(
                  v,
                  db.gameData.craftEssencesById[v],
                  color:
                      filterData.blockCEs.options.contains(v)
                          ? (filterData.blockCEMLBOnly[v] ?? false)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error
                          : null,
                ),
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
        ],
      ),
    );
  }

  Widget cardIcon(int id, GameCardMixin? card, {Color? color}) {
    // final card = db.gameData.servantsById[id] ?? db.gameData.craftEssencesById[id];
    Widget child =
        card == null
            ? GameCardMixin.cardIconBuilder(
              context: context,
              icon: null,
              text: id == 0 ? null : id.toString(),
              height: 42,
            )
            : Opacity(opacity: 0.9, child: card.iconBuilder(context: context, height: 42, jumpToDetail: false));
    if (color != null) {
      child = Container(padding: const EdgeInsets.all(2), color: color, child: child);
    } else {
      child = Padding(padding: const EdgeInsets.all(2), child: child);
    }
    return child;
  }
}
