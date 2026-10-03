import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../battle/formation/formation_card.dart';
import 'solver.dart';

/// The card grid shared by the two solver exclusion lists.
class BondExcludedCards extends StatelessWidget {
  final String title;
  final Set<int> ids;
  final bool servant;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const BondExcludedCards({
    super.key,
    required this.title,
    required this.ids,
    required this.servant,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = ids.toList()..sort();
    return AddRemoveList<int>(
      title: title,
      // subtitle: sorted.isEmpty ? 'No cards excluded' : '${sorted.length} excluded · long press a card to remove',
      items: sorted,
      onAdd: onAdd,
      onRemove: onRemove,
      itemBuilder: _card,
    );
  }

  Widget _card(BuildContext context, int id, VoidCallback remove) {
    final card = servant ? db.gameData.servantsById[id] : db.gameData.craftEssencesById[id];
    final name = card?.lName.l ?? '#$id';
    return Semantics(
      label: '$name, ${S.current.long_press_to_remove}',
      child: InkWell(
        onTap: card?.routeTo,
        onLongPress: remove,
        child:
            card?.iconBuilder(context: context, width: 42) ??
            GameCardMixin.cardIconBuilder(
              context: context,
              icon: servant ? Atlas.common.unknownEnemyIcon : Atlas.common.emptyCeIcon,
              width: 42,
              aspectRatio: 132 / 144,
              text: '#$id',
            ),
      ),
    );
  }
}

/// Renders immutable search output using the current display-only teapot multiplier.
class BondSolverResultsTab extends StatelessWidget {
  static final _ascensions = Expando<Map<int, BondAscensionRequirement>>();

  BondAscensionRequirement _ascensionRequirement(BondSolvedTeam team, BondSolvedSlot slot) {
    final quest = this.quest;
    if (quest == null) return const BondAscensionRequirement([], []);
    final cache = _ascensions[team] ??= {};
    return cache.putIfAbsent(
      slot.position,
      () => FormationBondSolver.ascensionRequirement(
        team: team,
        target: slot,
        option: option,
        quest: quest,
        formation: formation,
      ),
    );
  }

  final BondSolverResult? solved;
  final BattleTeamSetup formation;
  final FormationBondOption option;
  final QuestPhase? quest;
  final bool solving;
  final String status;
  final String? error;
  final VoidCallback? onCancel;

  const BondSolverResultsTab({
    super.key,
    required this.solved,
    required this.formation,
    required this.option,
    required this.quest,
    required this.solving,
    required this.status,
    required this.error,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final result = solved;
    final best = result?.best;
    final teams = result == null || best == null
        ? const <BondSolvedTeam>[]
        : (result.candidates.isEmpty ? [best] : result.candidates);
    return Column(
      children: [
        _summary(context, result),
        Expanded(
          child: teams.isEmpty
              ? ListView(
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [_emptyState(context, result), if (result != null) _diagnostics(result)],
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: teams.length + (result == null ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == teams.length) return _diagnostics(result!);
                    return _candidateCard(context, result!, teams, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, BondSolverResult? result) {
    final best = result?.best;
    final colorScheme = Theme.of(context).colorScheme;
    final statusIcon = (result?.provenOptimal == true && !solving)
        ? Icons.verified_outlined
        : (solving ? Icons.search : (error != null ? Icons.error_outline : Icons.info_outline));
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.place_outlined),
            title: Text(quest?.lNameWithChapter ?? S.current.quest, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(_baseBondLabel()),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Highest', style: Theme.of(context).textTheme.labelSmall),
                Text(
                  best == null ? '—' : _formatBond(best.totalBond * option.teapotTimes),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: error != null ? colorScheme.error : colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: error ?? status,
                    hint: S.current.details,
                    child: Tooltip(
                      message: S.current.details,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => _showStatusDetails(context, error ?? status),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            error ?? status,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: error != null ? colorScheme.error : colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (solving && onCancel != null) ...[
                  const SizedBox(width: 8),
                  TextButton(onPressed: onCancel, child: Text(S.current.cancel)),
                ],
              ],
            ),
          ),
          if (solving)
            const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: LinearProgressIndicator(minHeight: 2)),
        ],
      ),
    );
  }

  String _baseBondLabel() {
    final baseBond = quest?.bond;
    if (baseBond == null) return '${S.current.base_bond} —';
    final baseText = _formatBond(baseBond);
    if (option.teapotTimes <= 1) return '${S.current.base_bond} $baseText';
    final adjustedBase = _formatBond(baseBond * option.teapotTimes);
    return '${S.current.base_bond} $baseText × ${option.teapotTimes} = $adjustedBase';
  }

  String _formatBond(int value) => value.format(compact: false, groupSeparator: ',');

  void _showStatusDetails(BuildContext context, String message) {
    SimpleConfirmDialog(
      title: Text(S.current.search),
      content: SelectableText(message),
      showCancel: false,
      confirmText: S.current.ok,
      scrollable: true,
    ).showDialog(context);
  }

  Widget _emptyState(BuildContext context, BondSolverResult? result) {
    final message =
        error ??
        (solving
            ? 'No feasible team found yet'
            : result == null
            ? 'Solve to collect candidate teams'
            : result.provenOptimal
            ? 'No feasible team'
            : 'No team found before the search stopped');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_2_outlined, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _candidateCard(BuildContext context, BondSolverResult result, List<BondSolvedTeam> teams, int teamIndex) {
    final team = teams[teamIndex];
    final quest = this.quest;
    if (quest == null) return const SizedBox.shrink();
    final score = team.totalBond * option.teapotTimes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (teamIndex == 0 || team.totalBond != teams[teamIndex - 1].totalBond)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '$score ${S.current.bond} · score group',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                dense: true,
                title: Text('Team ${teamIndex + 1}: $score'),
                trailing: Text(
                  'COST ${team.totalCost}/${result.maxCost}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              FormationCard(formation: _previewFormation(team), questPhase: quest),
              Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 4), child: _bondValues(context, team)),
            ],
          ),
        ),
      ],
    );
  }

  BattleTeamFormation _previewFormation(BondSolvedTeam team) {
    final applied = team.applyTo(formation, FormationBondOption.fromJson(option.toJson()));
    final preview = applied.toFormationData();
    for (final slot in team.slots) {
      if (!slot.isSupport) continue;
      preview.svts[slot.position] =
          applied.svts[slot.position].toStoredData() ??
          SvtSaveData(supportType: applied.svts[slot.position].supportType);
    }
    return preview;
  }

  Widget _bondValues(BuildContext context, BondSolvedTeam team) {
    final byPosition = {for (final slot in team.slots) slot.position: slot};
    final base = (quest?.bond ?? 0) * option.teapotTimes;
    final deltaGroup = AutoSizeGroup();
    final totalGroup = AutoSizeGroup();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var p = 0; p < 6; p++)
          Expanded(
            flex: 10,
            child: Builder(
              builder: (context) {
                final slot = byPosition[p];
                if (slot == null || slot.isSupport || slot.servantId == null) {
                  return Center(child: Text('–', style: Theme.of(context).textTheme.bodySmall));
                }
                final requirement = _ascensionRequirement(team, slot);
                final total = slot.bond * option.teapotTimes;
                final delta = total == 0 ? 0 : total - base;
                return InkWell(
                  onTap: () => _showTraitBondCes(context, team, slot),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: requirement.restricted
                        ? BoxDecoration(
                            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5)),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          delta >= 0 ? '+$delta' : '$delta',
                          group: deltaGroup,
                          maxLines: 1,
                          minFontSize: 8,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        AutoSizeText(
                          '$total',
                          group: totalGroup,
                          maxLines: 1,
                          minFontSize: 9,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const Expanded(flex: 8, child: SizedBox.shrink()),
      ],
    );
  }

  Future<void> _showTraitBondCes(BuildContext context, BondSolvedTeam team, BondSolvedSlot target) async {
    final quest = this.quest;
    if (quest == null) return;
    final bonuses = team.traitCeBonusesFor(target, quest, option);
    final requirement = _ascensionRequirement(team, target);
    final targetSvt = db.gameData.servantsById[target.servantId] ?? db.gameData.entities[target.servantId];
    await router.showDialog<void>(
      context: context,
      builder: (context) => SimpleConfirmDialog(
        showCancel: false,
        title: Text.rich(
          TextSpan(
            children: [
              if (targetSvt != null) ...[
                CenterWidgetSpan(child: targetSvt.iconBuilder(context: context, width: 36)),
                const TextSpan(text: ' '),
              ],
              TextSpan(text: targetSvt?.lName.l ?? 'SVT ${target.servantId}'),
            ],
          ),
          maxLines: 1,
          overflow: .ellipsis,
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: .min,
            children: [
              if (requirement.restricted)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.current.ascension),
                  subtitle: Text(
                    requirement.allowed
                        .map((limit) => targetSvt is Servant ? targetSvt.getLimitName(limit) : '$limit')
                        .join(' / '),
                  ),
                ),
              if (bonuses.isEmpty) const Text('—'),
              ...bonuses.map((bonus) {
                final ce = db.gameData.craftEssencesById[bonus.ce.id];
                final wearer = team.slots.firstWhere((slot) => slot.position == bonus.wearerPosition);
                final effects = <String>[
                  if (bonus.rate != 0) bonus.rate.format(percent: true, base: 10),
                  if (bonus.value != 0) '+${bonus.value}',
                ];
                final traitSummary = bonus.targetTraitGroups
                    .map((group) => group.map((trait) => Transl.traitName(trait)).join(' & '))
                    .join(' / ');
                return ListTile(
                  dense: true,
                  contentPadding: .zero,
                  leading: ce?.iconBuilder(context: context, width: 40, jumpToDetail: false),
                  title: Text(ce?.lName.l ?? '#${bonus.ce.id}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    [
                      '#${bonus.wearerPosition + 1}${wearer.isSupport ? ' · ${S.current.support_servant}' : ''}',
                      if (traitSummary.isNotEmpty) traitSummary,
                    ].join('\n'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(effects.join(' · ')),
                  onTap: ce?.routeTo,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _diagnostics(BondSolverResult solved) {
    final combinations = solved.possibleCombinations;
    return SimpleAccordion(
      headerBuilder: (context, expanded) => ListTile(
        dense: true,
        title: const Text('Search details'),
        subtitle: Text(
          combinations == null
              ? '${solved.visitedNodes} nodes visited · total unknown'
              : '${solved.visitedNodes}/$combinations CE combinations evaluated',
        ),
      ),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            title: const Text('Method'),
            trailing: Text(combinations == null ? 'General search' : 'CE-first search'),
          ),
          ListTile(
            dense: true,
            title: const Text('Last reported time'),
            trailing: Text('${solved.elapsedMilliseconds} ms'),
          ),
          ListTile(dense: true, title: const Text('Candidate items'), trailing: Text('${solved.itemCount}')),
          ListTile(
            dense: true,
            title: const Text('Score proof'),
            trailing: Text(
              solved.provenOptimal
                  ? 'Proven'
                  : solving
                  ? 'In progress'
                  : 'Unproven',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Equivalent concrete teams are not counted. Shown teams represent effect groups found during the search.',
            ),
          ),
        ],
      ),
    );
  }
}
