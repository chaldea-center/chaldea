import 'dart:math' show max;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/app/modules/bond/solver2/solver2.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../battle/formation/team.dart';
import 'formation_bond.dart' show BondQuestPicker, validateFormationBondOption;

const int _kMaxSvtNum = 6;

/// Equal-value solutions rendered before the rest collapse behind a
/// "show more" button (the solver keeps at most 20 ties).
const int _kVisibleCandidates = 5;

/// State of the result area for the latest solve run.
enum _SolveStatus { idle, loading, error, empty, success }

String _strRate(int value) => value.format(percent: true, base: 10);

/// Solver tab: computes the maximum achievable team bond for the configured
/// formation, quest and solver options.
///
/// Mirrors [FormationBondTab] in structure but keeps its own persisted
/// configuration (`BondSolverOptions.formationOption`), so the two pages never
/// read or write each other's settings.
class BondSolverTab extends StatefulWidget {
  const BondSolverTab({super.key});

  @override
  State<BondSolverTab> createState() => _BondSolverTabState();
}

class _BondSolverTabState extends State<BondSolverTab> {
  /// Persisted solver options. Mutations are picked up by the periodic user
  /// data save loop, no explicit save call needed.
  late final BondSolverOptions solverOptions = db.userData.curUser.bondSolverOptions;

  /// Formation/quest/event settings handed to the solver. Owned by
  /// [solverOptions] — deliberately NOT `User.formationBondOption`.
  late final FormationBondOption option = solverOptions.formationOption;

  // runtime formation, converted from/to [option.teamFormation] on load/save
  final BattleTeamSetup formation = BattleTeamSetup();
  QuestPhase? questEntity;

  _SolveStatus _status = _SolveStatus.idle;
  BondSolver2Result? _result;
  String? _errorText;
  bool _expandCandidates = false;

  /// False until [restore] finishes. [dispose] refuses to persist before then,
  /// otherwise leaving the tab mid-restore would overwrite the stored
  /// formation with the still-empty runtime one.
  bool _restored = false;

  Region get region => db.settings.resolvedPreferredRegions.firstOrNull ?? Region.jp;

  @override
  void initState() {
    super.initState();
    restore();
  }

  @override
  void dispose() {
    if (_restored) saveData();
    super.dispose();
  }

  /// Restore the two non-JSON runtime values (team setup, quest entity) from
  /// the persisted option. Quest resolution falls back to network; on failure
  /// the quest is cleared but other settings are kept.
  Future<void> restore() async {
    final questInfo = option.quest;
    if (questInfo != null) {
      questEntity =
          db.gameData.getQuestPhase(questInfo.id, questInfo.phase) ??
          await AtlasApi.questPhase(questInfo.id, questInfo.phase);
      if (questEntity == null) option.quest = null;
    }

    final saved = option.teamFormation;
    final svts = <PlayerSvtData>[];
    for (int index = 0; index < max(_kMaxSvtNum, saved.svts.length); index++) {
      svts.add(await PlayerSvtData.fromStoredData(saved.svts.getOrNull(index)));
    }
    formation.svts
      ..clear()
      ..addAll(svts);
    formation.mysticCodeData.loadStoredData(saved.mysticCode);
    _restored = true;
    if (mounted) setState(() {});
  }

  /// Persist runtime formation/quest back into [option].
  void saveData() {
    option.teamFormation = formation.toFormationData();
    option.quest = questEntity == null ? null : BattleQuestInfo.quest(questEntity!);
  }

  /// Runs the solver.
  ///
  /// The solver is synchronous and reads the global game database throughout,
  /// so it stays on the UI isolate: a frame is yielded first to paint the
  /// loading state, then the (blocking) search runs under a loading mask.
  Future<void> solve() async {
    if (questEntity == null) {
      setState(() {
        _status = _SolveStatus.error;
        _result = null;
        _errorText = 'Select a quest first';
      });
      return;
    }
    setState(() {
      _status = _SolveStatus.loading;
      _result = null;
      _errorText = null;
      _expandCandidates = false;
    });
    // `clear` blocks input without drawing a visible mask. This is required,
    // not cosmetic: the search yields, so the event loop runs while the solver
    // still holds live references to `formation`/`option` — without the barrier
    // the user could mutate them mid-search.
    EasyLoading.show(status: 'Solving...', maskType: EasyLoadingMaskType.clear);
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;

    BondSolver2Result? result;
    String? error;
    try {
      result = await FormationBondSolver2.solve(
        option: option,
        quest: questEntity,
        formation: formation,
        solverOptions: solverOptions,
        region: region,
        yieldInterval: const Duration(milliseconds: 50),
      );
    } catch (e) {
      error = e is BondSolverException ? e.message : e.toString();
    }
    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() {
      _result = result;
      _errorText = error;
      // The engine throws "no solution found" today, so the empty branch is
      // defensive — kept because the result contract allows an empty list.
      _status = error != null
          ? _SolveStatus.error
          : (result!.candidates.isEmpty ? _SolveStatus.empty : _SolveStatus.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quest = questEntity;
    validateFormationBondOption(option, quest);
    // resolve id/idx-keyed campaigns into runtime Event/EventCampaign instances
    final eventCampaignToggles = <(Event, EventCampaign, bool)>[];
    for (final (eventId, eventCampaigns) in option.campaigns.items) {
      final event = db.gameData.events[eventId];
      if (event == null) continue;
      for (final (idx, enabled) in eventCampaigns.items) {
        final campaign = event.campaigns.firstWhereOrNull((e) => e.idx == idx);
        if (campaign == null) continue;
        eventCampaignToggles.add((event, campaign, enabled));
      }
    }
    return ListView(
      children: [
        TeamSetupCard(
          formation: formation,
          quest: quest,
          playerRegion: Region.jp,
          onChanged: () {
            if (mounted) setState(() {});
          },
        ),
        DividerWithTitle(title: '${S.current.general_custom} / ${S.current.bond} 15 / ${S.current.bond_limit}'),
        Row(
          children: [
            for (final index in range(option.svtBonus.length)) Expanded(child: Center(child: buildExtraBonus(index))),
          ],
        ),
        DividerWithTitle(title: S.current.settings_tab_name),
        BondQuestPicker(
          quest: quest,
          onChanged: (v) {
            questEntity = v;
            if (mounted) setState(() {});
          },
        ),
        DividerWithTitle(title: S.current.event, indent: 16),
        SwitchListTile.adaptive(
          dense: true,
          title: Text(S.current.event_skill),
          value: option.enableEvent,
          onChanged: (v) {
            setState(() {
              option.enableEvent = v;
            });
          },
        ),
        DividerWithTitle(title: 'solver', indent: 16),
        buildMaxCostTile(),
        SwitchListTile.adaptive(
          dense: true,
          title: const Text('Favorite Servants Only'),
          value: solverOptions.favoriteOnly,
          onChanged: (v) {
            setState(() {
              solverOptions.favoriteOnly = v;
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          title: const Text('Exclude Unreleased'),
          subtitle: Text('region ${region.upper}'),
          value: solverOptions.excludeUnreleased,
          onChanged: (v) {
            setState(() {
              solverOptions.excludeUnreleased = v;
            });
          },
        ),
        buildMaxBondTile(),
        buildExclusionTile(
          title: 'Excluded Servants',
          ids: solverOptions.excludedSvts,
          nameOf: (id) => db.gameData.servantsById[id]?.lName.l ?? '#$id',
        ),
        buildExclusionTile(
          title: 'Excluded Craft Essences',
          ids: solverOptions.excludedCes,
          nameOf: (id) => db.gameData.craftEssencesById[id]?.lName.l ?? '#$id',
        ),
        DividerWithTitle(title: 'misc', indent: 16),
        ListTile(
          dense: true,
          leading: Item.iconBuilder(
            context: context,
            item: null,
            itemId: Items.teapotId,
            width: 28,
            jumpToDetail: false,
          ),
          title: Text(Transl.itemNames('星見のティーポット').l),
          subtitle: const Text('display only, solver always computes ×1'),
          trailing: DropdownButton<int>(
            value: option.teapotTimes,
            items: [
              for (final times in [1, 2, 3]) DropdownMenuItem(value: times, child: Text(times == 1 ? '--' : '×$times')),
            ],
            onChanged: (v) {
              setState(() {
                if (v != null) option.teapotTimes = v;
              });
            },
          ),
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: option.frontlineBonus,
          title: Text("${S.current.bond_bonus}: ${S.current.team_starting_member}"),
          subtitle: Text(
            '${Transl.funcTargetType(FuncTargetType.self).l}+20%; [${S.current.support_servant_short}] ${Transl.funcTargetType(FuncTargetType.ptFull).l} +4%',
          ),
          onChanged: (v) {
            setState(() {
              option.frontlineBonus = v;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _status == _SolveStatus.loading ? null : solve,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Solve Max Bond'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Exhaustive search: a high-bond quest can take over a minute. '
                  'Input is blocked while it runs.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        DividerWithTitle(title: S.current.results, indent: 16),
        buildResultArea(),
        if (eventCampaignToggles.isNotEmpty) DividerWithTitle(title: S.current.event_campaign, indent: 16),
        for (final (event, campaign, enabled) in eventCampaignToggles)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SwitchListTile.adaptive(
                  dense: true,
                  title: Text(event.lShortName.l),
                  subtitle: Text(
                    '${S.current.bond} ${campaign.calcType.operatorText}${campaign.value.format(percent: true, base: 10)}'
                    '\n${strTime(event.startedAt)}~${strTime(event.endedAt)}',
                  ),
                  value: enabled,
                  onChanged: (v) {
                    setState(() {
                      (option.campaigns[event.id] ??= {})[campaign.idx] = v;
                    });
                  },
                ),
              ),
              IconButton(onPressed: event.routeTo, icon: Icon(DirectionalIcons.keyboard_arrow_forward(context))),
            ],
          ),
      ],
    );
  }

  String strTime(int t) => t.sec2date().toStringShort(omitSec: true);

  Widget buildExtraBonus(int index) {
    final deckSvt = formation.svts.getOrNull(index);
    if (deckSvt == null || deckSvt.svt == null || deckSvt.supportType.isSupport) return const SizedBox.shrink();
    final detail = option.svtBonus[index];

    Widget _textButton(String text, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 18),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 2,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _textButton('+${detail.addValue}', () {
          InputCancelOkDialog.number(
            title: 'Bond Add Value',
            autofocus: true,
            initValue: detail.addValue,
            validate: (v) => v >= 0,
            onSubmit: (value) {
              detail.addValue = value;
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }),
        _textButton('+${detail.addRate.format(percent: true, base: 10)}', () {
          InputCancelOkDialog(
            title: 'Bond Add Percent(%)',
            autofocus: true,
            initValue: (detail.addRate / 10).format(),
            validate: (s) => (double.parse(s) * 10).toInt() >= 0,
            onSubmit: (s) {
              detail.addRate = (double.parse(s) * 10).toInt();
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBond15,
          onChanged: (v) {
            setState(() {
              detail.isBond15 = v!;
            });
          },
        ),
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: detail.isBondReachLimit,
          onChanged: (v) {
            setState(() {
              detail.isBondReachLimit = v!;
            });
          },
        ),
      ],
    );
  }

  // ================================================================================
  // solver options
  // ================================================================================

  Widget buildMaxCostTile() {
    final defaultCost = ConstData.maxUserCost;
    return ListTile(
      dense: true,
      title: const Text('Max Cost'),
      subtitle: Text(solverOptions.maxCost == null ? 'default ($defaultCost)' : '${solverOptions.maxCost}'),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        InputCancelOkDialog.number(
          title: 'Max Cost',
          initValue: solverOptions.maxCost,
          helperText: '0 = default ($defaultCost)',
          validate: (v) => v >= 0,
          onSubmit: (v) {
            solverOptions.maxCost = v > 0 ? v : null;
            if (mounted) setState(() {});
          },
        ).showDialog(context);
      },
    );
  }

  Widget buildMaxBondTile() {
    return ListTile(
      dense: true,
      title: const Text('Max Bond'),
      subtitle: Text(
        solverOptions.maxBond <= 0 ? 'no limit' : 'excludes servants with bond >= ${solverOptions.maxBond}',
      ),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () {
        InputCancelOkDialog.number(
          title: 'Max Bond',
          initValue: solverOptions.maxBond,
          helperText: '0 = no limit',
          validate: (v) => v >= 0,
          onSubmit: (v) {
            solverOptions.maxBond = v;
            if (mounted) setState(() {});
          },
        ).showDialog(context);
      },
    );
  }

  Widget buildExclusionTile({required String title, required Set<int> ids, required String Function(int id) nameOf}) {
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: Text(ids.isEmpty ? 'none' : '${ids.length} excluded'),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () => editExclusions(title: title, ids: ids, nameOf: nameOf),
    );
  }

  /// Adds/removes ids of a custom exclusion set. Ids are edited directly —
  /// there is no game-data-backed picker for "exclude these" lists yet.
  Future<void> editExclusions({
    required String title,
    required Set<int> ids,
    required String Function(int id) nameOf,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final sorted = ids.toList()..sort();
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (sorted.isEmpty)
                      Text('none', style: Theme.of(dialogContext).textTheme.bodySmall)
                    else
                      for (final id in sorted)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(nameOf(id), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('ID $id'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              ids.remove(id);
                              setDialogState(() {});
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    InputCancelOkDialog.number(
                      title: 'ID',
                      autofocus: true,
                      validate: (v) => v > 0,
                      onSubmit: (v) {
                        ids.add(v);
                        setDialogState(() {});
                        if (mounted) setState(() {});
                      },
                    ).showDialog(dialogContext);
                  },
                  child: const Text('Add by ID'),
                ),
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(S.current.confirm)),
              ],
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  // ================================================================================
  // result
  // ================================================================================

  Widget buildResultArea() {
    switch (_status) {
      case _SolveStatus.idle:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text('Configure the formation and tap "Solve Max Bond".'),
        );
      case _SolveStatus.loading:
        // The search yields every ~50ms, so this keeps spinning. Input stays
        // blocked by the mask for the whole run.
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Solving...'),
              SizedBox(height: 4),
              Text(
                'Exhaustive search — a high-bond quest can take over a minute. '
                'Input is blocked until it finishes.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case _SolveStatus.error:
        return buildMessage(_errorText ?? 'Solving failed', Theme.of(context).colorScheme.error);
      case _SolveStatus.empty:
        return buildMessage(
          'No feasible team under the current filters and cost budget',
          Theme.of(context).colorScheme.error,
        );
      case _SolveStatus.success:
        return buildResult();
    }
  }

  Widget buildMessage(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(text, style: TextStyle(color: color)),
    );
  }

  Widget buildResult() {
    final result = _result!;
    final teapotTimes = option.teapotTimes;
    final candidates = result.candidates;
    final shown = _expandCandidates ? candidates : candidates.take(_kVisibleCandidates).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text(
            '${result.totalBond * teapotTimes}',
            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
          ),
          subtitle: Text(
            'cost ${result.totalCost} / budget ${result.budget + result.fixedCost} (${result.fixedCost} fixed)\n'
            'T=${_strRate(result.teamRate)} V=+${result.teamValue} '
            '${result.provenOptimal ? "optimal" : "NOT proven optimal"}',
          ),
        ),
        if (result.warnings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              result.warnings.join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        for (final (ci, candidate) in shown.indexed) buildCandidate(ci, candidate),
        if (candidates.length > _kVisibleCandidates)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _expandCandidates = !_expandCandidates;
                });
              },
              child: Text(
                _expandCandidates
                    ? 'Collapse'
                    : 'Show ${candidates.length - _kVisibleCandidates} more equivalent solutions',
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCandidate(int index, BondSolution2 candidate) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            title: Text('Solution #${index + 1}'),
            subtitle: Text(
              'total ${candidate.totalBond * option.teapotTimes}  '
              'cost ${candidate.totalCost}  T=${_strRate(candidate.teamRate)} V=+${candidate.teamValue}',
            ),
            trailing: TextButton(onPressed: () => applySolution(candidate), child: const Text('Apply')),
          ),
          for (final slot in candidate.slots) buildSlotRow(slot),
        ],
      ),
    );
  }

  Widget buildSlotRow(BondSlotSolution2 slot) {
    final svt = slot.svtId == null ? null : db.gameData.servantsById[slot.svtId];
    final ce1 = slot.ce1 == null ? null : db.gameData.craftEssencesById[slot.ce1!.ceId];
    final ce3 = slot.ce3 == null ? null : db.gameData.craftEssencesById[slot.ce3!.ceId];
    final ceText = [if (ce1 != null) ce1.lName.l, if (ce3 != null) '${ce3.lName.l} (equip3)'].join(' / ');
    final prefix = slot.isSupport ? '[Support] ' : '';
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(
        width: 32,
        child: svt?.iconBuilder(context: context, width: 32) ?? const Icon(Icons.remove, size: 20),
      ),
      title: Text(
        '${slot.position + 1} ${slot.position < 3 ? "[front]" : "[back]"} $prefix${svt?.lName.l ?? "-"}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${ceText.isEmpty ? '-' : ceText}  bond ${slot.slotBond * option.teapotTimes}'),
      trailing: slot.slotCost > 0 ? Text('cost ${slot.slotCost}') : null,
      onTap: svt?.routeTo,
    );
  }

  /// Writes one solved team back into the runtime formation: fixed slots keep
  /// their servant (only free CE dimensions are updated), free slots are
  /// replaced by the instantiated servants.
  void applySolution(BondSolution2 candidate) {
    final isGrand = questEntity?.isUseGrandBoard == true;
    for (final slot in candidate.slots) {
      final deck = formation.svts[slot.position];
      if (slot.isSupport) {
        _applyEquip(deck, SvtEquipTarget.normal, slot.ce1);
        if (isGrand) _applyEquip(deck, SvtEquipTarget.reward, slot.ce3);
        continue;
      }
      if (slot.isFixed) {
        _applyEquip(deck, SvtEquipTarget.normal, slot.ce1);
        if (isGrand) _applyEquip(deck, SvtEquipTarget.reward, slot.ce3);
        continue;
      }
      if (slot.svtId == null) {
        formation.svts[slot.position] = PlayerSvtData.base();
        continue;
      }
      final svt = db.gameData.servantsById[slot.svtId];
      if (svt == null) continue;
      final data = PlayerSvtData.svt(svt)..limitCount = slot.limitCount ?? 4;
      final equip = _equipOf(slot.ce1);
      if (equip != null) data.equip1 = equip;
      formation.svts[slot.position] = data;
    }
    if (mounted) setState(() {});
  }

  /// Overwrites one equip dimension unless the pick is identical to what the
  /// deck already holds (keeps user-owned CE level details intact).
  void _applyEquip(PlayerSvtData deck, SvtEquipTarget target, BondCePick? pick) {
    final equip = deck.getEquip(target);
    final newEquip = _equipOf(pick);
    final newCe = newEquip?.ce;
    if (equip.ce?.id == newCe?.id && equip.limitBreak == (newEquip?.limitBreak ?? false)) {
      return;
    }
    equip
      ..ce = newCe
      ..limitBreak = newEquip?.limitBreak ?? false
      ..lv = newEquip?.lv ?? 0;
  }

  SvtEquipData? _equipOf(BondCePick? pick) {
    if (pick == null) return null;
    final ce = db.gameData.craftEssencesById[pick.ceId];
    if (ce == null) return null;
    return SvtEquipData(ce: ce, limitBreak: pick.limitBreak, lv: ce.lvMax);
  }
}
