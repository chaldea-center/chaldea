import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../battle/formation/formation_card.dart';
import 'solver.dart';

/// The card grid shared by the two solver exclusion sections.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text(title),
          subtitle: sorted.isEmpty ? null : const Text('Long press a card to remove'),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: servant ? 'Add servant' : 'Add craft essence',
            onPressed: onAdd,
          ),
        ),
        if (sorted.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Wrap(spacing: 6, runSpacing: 6, children: [for (final id in sorted) _card(context, id)]),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, int id) {
    final card = servant ? db.gameData.servantsById[id] : db.gameData.craftEssencesById[id];
    final name = card?.lName.l ?? '#$id';
    return Semantics(
      label: '$name, long press to remove',
      child: InkWell(
        onTap: card?.routeTo,
        onLongPress: () => onRemove(id),
        child:
            card?.iconBuilder(context: context, width: 52, jumpToDetail: false) ??
            GameCardMixin.cardIconBuilder(
              context: context,
              icon: servant ? Atlas.common.unknownEnemyIcon : Atlas.common.emptyCeIcon,
              width: 52,
              aspectRatio: 132 / 144,
              text: '#$id',
            ),
      ),
    );
  }
}

/// Renders immutable search output using the current display-only teapot multiplier.
class BondSolverResults extends StatelessWidget {
  final BondSolverResult solved;
  final BattleTeamSetup formation;
  final FormationBondOption option;
  final QuestPhase quest;
  final bool solving;
  final bool showAllCandidates;
  final VoidCallback onToggleCandidates;

  const BondSolverResults({
    super.key,
    required this.solved,
    required this.formation,
    required this.option,
    required this.quest,
    required this.solving,
    required this.showAllCandidates,
    required this.onToggleCandidates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [_diagnostics(), _resultArea(context)]);
  }

  Widget _resultArea(BuildContext context) {
    final best = solved.best;
    if (best == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          solved.provenOptimal
              ? 'No feasible team'
              : solving
              ? 'No feasible team found yet'
              : 'No team found before the search stopped',
        ),
      );
    }
    final teams = solved.ties.isEmpty ? [best] : solved.ties;
    final visibleTeams = showAllCandidates ? teams : teams.take(5).toList();
    final standardCost = ConstData.userLevel[ConstData.maxUserLevel]?.maxCost ?? solved.maxCost;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text('${best.totalBond * option.teapotTimes}', style: Theme.of(context).textTheme.titleLarge),
          subtitle: Text(
            'COST ${best.totalCost}/${solved.maxCost}'
            '${solved.maxCost == standardCost ? "" : " · max ${solved.maxCost}/$standardCost (custom / standard)"}\n'
            '${teams.length} ${solved.provenOptimal ? "maximum-score" : "best-known-score"} '
            '${teams.length == 1 ? "candidate" : "candidates"} available. '
            '${solved.allTiesCollected ? "All searched effect groups collected; concrete variants are limited." : "More equal-score teams may exist."}',
          ),
        ),
        for (final (i, team) in visibleTeams.indexed)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text('Team ${i + 1}: ${team.totalBond * option.teapotTimes}'),
                  subtitle: Text('COST ${team.totalCost}/${solved.maxCost}'),
                ),
                IgnorePointer(
                  child: FormationCard(formation: _previewFormation(team), questPhase: quest),
                ),
                _bondValues(context, team),
                const SizedBox(height: 8),
              ],
            ),
          ),
        if (teams.length > 5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: onToggleCandidates,
              child: Text(showAllCandidates ? 'Show fewer teams' : 'Show all ${teams.length} teams'),
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
    final base = quest.bond * option.teapotTimes;
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
                final total = slot.bond * option.teapotTimes;
                final delta = total - base;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      delta >= 0 ? '+$delta' : '$delta',
                      maxLines: 1,
                      minFontSize: 8,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AutoSizeText('$total', maxLines: 1, minFontSize: 8),
                  ],
                );
              },
            ),
          ),
        const Expanded(flex: 8, child: SizedBox.shrink()),
      ],
    );
  }

  Widget _diagnostics() {
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
