import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/user.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../battle/formation/formation_card.dart';
import '../../common/builders.dart';
import '../bond_rules.dart';
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
    return AddRemoveList<int>(title: Text(title), items: sorted, onAdd: onAdd, onRemove: onRemove, itemBuilder: _card);
  }

  Widget _card(BuildContext context, int id) {
    final card = servant ? db.gameData.servantsById[id] : db.gameData.craftEssencesById[id];
    return card?.iconBuilder(context: context, width: 42) ??
        GameCardMixin.cardIconBuilder(
          context: context,
          icon: servant ? Atlas.common.unknownEnemyIcon : Atlas.common.emptyCeIcon,
          width: 42,
          aspectRatio: 132 / 144,
          text: '#$id',
        );
  }
}

/// Search lifetime is separate from candidate availability and score proof.
enum BondSolverRunState {
  idle,
  preparing,
  searching,
  completed,
  cancelled,
  failed;

  bool get isRunning => this == preparing || this == searching;

  String conclusion(BondSolverResult? result) {
    if (result?.provenOptimal != true) return S.current.bond_solver_maximum_not_proven;
    return result!.best == null ? S.current.bond_solver_no_feasible_team : S.current.bond_solver_maximum_proven;
  }

  String describe(BondSolverResult? result) => switch (this) {
    idle => S.current.not_started,
    preparing => '${S.current.search}…',
    searching => result?.provenOptimal == true ? conclusion(result) : '${S.current.search}…',
    completed =>
      result?.provenOptimal == true
          ? '${S.current.completed} · ${conclusion(result)}'
          : '${S.current.ended} · ${conclusion(result)}',
    cancelled => '${S.current.cancelled} · ${conclusion(result)}',
    failed => S.current.failed,
  };
}

/// Renders immutable search output using the current display-only teapot multiplier.
class BondSolverResultsTab extends StatelessWidget {
  static final _ascensions = Expando<Map<int, BondAscensionRequirement>>();

  BondAscensionRequirement _ascensionRequirement(BondSolvedTeam team, BondSolvedSlot slot) {
    final prepared = team.cachedAscensionRequirement(slot.position);
    if (prepared != null) return prepared;
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
  final int teapotTimes;
  final QuestPhase? quest;
  final BondSolverRunState runState;

  bool get solving => runState.isRunning;
  String get status => runState.describe(solved);
  final String? error;
  final VoidCallback? onCancel;

  const BondSolverResultsTab({
    super.key,
    required this.solved,
    required this.formation,
    required this.option,
    required this.teapotTimes,
    required this.quest,
    required this.runState,
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
                    if (index == 0) return _diagnostics(result!);
                    return _candidateCard(context, result!, teams, index - 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context, BondSolverResult? result) {
    final best = result?.best;
    final colorScheme = Theme.of(context).colorScheme;
    final statusIcon = switch (runState) {
      BondSolverRunState.failed => Icons.error_outline,
      BondSolverRunState.cancelled => Icons.cancel_outlined,
      BondSolverRunState.preparing || BondSolverRunState.searching => Icons.search,
      _ =>
        result?.provenOptimal == true
            ? best == null
                  ? Icons.search_off
                  : Icons.verified_outlined
            : Icons.info_outline,
    };
    final failed = runState == BondSolverRunState.failed;
    final statusText = failed && error != null ? '${S.current.failed} · $error' : status;
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
                  best == null ? '—' : _formatBond(best.totalBond * teapotTimes),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: failed ? colorScheme.error : colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: statusText,
                    hint: S.current.details,
                    child: Tooltip(
                      message: S.current.details,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => _showStatusDetails(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            statusText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: failed ? colorScheme.error : colorScheme.onSurfaceVariant),
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
                  FilledButton(onPressed: onCancel, child: Text(S.current.cancel)),
                ],
              ],
            ),
          ),
          if (result != null) _candidatePools(context, result),
          if (solving) const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: _DiscreteSearchIndicator()),
        ],
      ),
    );
  }

  String _baseBondLabel() {
    final baseBond = quest?.bond;
    if (baseBond == null) return '${S.current.base_bond} —';
    final baseText = _formatBond(baseBond);
    if (teapotTimes <= 1) return '${S.current.base_bond} $baseText';
    final adjustedBase = _formatBond(baseBond * teapotTimes);
    return '${S.current.base_bond} $baseText × $teapotTimes = $adjustedBase';
  }

  String _formatBond(int value) => value.format(compact: false, groupSeparator: ',');

  String? _bondMultiplier(int totalBond, int baseBond) =>
      baseBond > 0 ? '(×${(totalBond / baseBond).toStringAsFixed(2)})' : null;

  TextSpan _bondMultiplierSpan(BuildContext context, String text) {
    final theme = Theme.of(context);
    return TextSpan(
      text: text,
      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  String get _resultsHelp => S.current.bond_solver_results_help(option.maxCandidateTeams.clamp(1, 200));

  void _showStatusDetails(BuildContext context) {
    final message = [status, ?error, if (solved != null) _resultsHelp].join('\n\n');
    SimpleConfirmDialog(
      title: Text(S.current.search),
      content: SelectableText(message),
      showCancel: false,
      confirmText: S.current.ok,
      scrollable: true,
    ).showDialog(context);
  }

  Widget _emptyState(BuildContext context, BondSolverResult? result) {
    if (result?.provenOptimal != true || result?.best != null) return const SizedBox.shrink();
    final message = S.current.bond_solver_no_feasible_team;
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
    final team = teams[teamIndex].previewTeam;
    final quest = this.quest;
    if (quest == null) return const SizedBox.shrink();
    final score = team.totalBond * teapotTimes;
    final ownSlots = option.maxServants.clamp(1, 6) - team.slots.where((slot) => slot.isSupport).length;
    final teamBaseBond = quest.bond * ownSlots;
    final multiplier = _bondMultiplier(score, teamBaseBond);
    final title = Text.rich(
      TextSpan(
        text: '${S.current.team} ${teamIndex + 1}: $score',
        children: [if (multiplier != null) _bondMultiplierSpan(context, ' $multiplier')],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (teamIndex == 0 || team.totalBond != teams[teamIndex - 1].totalBond)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '$score ${S.current.bond}',
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
                title: multiplier == null
                    ? title
                    : Tooltip(
                        message:
                            '${S.current.base_bond} ${_formatBond(quest.bond)} × $ownSlots'
                            ' = ${_formatBond(teamBaseBond)}',
                        child: title,
                      ),
                trailing: Text(
                  'COST ${team.totalCost}/${result.maxCost}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    FormationCard(
                      formation: _previewFormation(team),
                      questPhase: quest,
                      showMysticCode: false,
                      svtInfoBuilder: (_) => null,
                      ceInfoBuilder: (_, _) => null,
                    ),
                    Padding(padding: const EdgeInsets.only(bottom: 4), child: _bondValues(context, team)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BattleTeamFormation _previewFormation(BondSolvedTeam team) {
    final applied = team.applyTo(formation, option.copy());
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
    final base = (quest?.bond ?? 0) * teapotTimes;
    final deltaGroup = AutoSizeGroup();
    final totalGroup = AutoSizeGroup();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var p = 0; p < 6; p++)
          Flexible(
            flex: 10,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: FormationCard.kCardWidth),
              child: SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) {
                    final slot = byPosition[p];
                    if (slot == null || slot.isSupport || slot.servantId == null) {
                      return Center(child: Text('–', style: Theme.of(context).textTheme.bodySmall));
                    }
                    final requirement = _ascensionRequirement(team, slot);
                    final total = slot.bond * teapotTimes;
                    final delta = total == 0 ? 0 : total - base;
                    return InkWell(
                      onTap: () => _showBondDetails(context, team, slot),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: requirement.restricted
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
                                ),
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
            ),
          ),
      ],
    );
  }

  Future<void> _showBondDetails(BuildContext context, BondSolvedTeam team, BondSolvedSlot target) async {
    final quest = this.quest;
    if (quest == null) return;
    final totalBond = target.bond * teapotTimes;
    final multiplier = _bondMultiplier(totalBond, quest.bond);
    final details = FormationBondSolver.recipientDetails(
      team: team,
      target: target,
      option: option,
      quest: quest,
      formation: formation,
    );
    final requirement = _ascensionRequirement(team, target);
    final targetSvt = db.gameData.servantsById[target.servantId] ?? db.gameData.entities[target.servantId];
    final status = !target.isSupport && targetSvt is Servant ? targetSvt.status : null;
    final formSvt = (target.fixedServant ? formation.svts[target.position].dispSvt : null) ?? targetSvt;
    String limitName(int limit) {
      final name = formSvt is Servant ? formSvt.getLimitName(limit) : '$limit';
      if (limit < 0 || limit > 4) return name;
      final stage = Servant.limitCountToDispLimitCount(limit);
      return '$name (${S.current.ascension_stage_short} $stage)';
    }

    await router.showDialog<void>(
      context: context,
      builder: (context) => SimpleConfirmDialog(
        showCancel: false,
        scrollable: true,
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
              if (status?.favorite == true)
                _bondDetailRow('${S.current.bond} Lv.', '${status!.bond}/${status.cur.bondLimit}'),
              _bondDetailRow(S.current.base_bond, _formatBond(quest.bond)),
              _bondDetailRow(
                '${S.current.total} ${S.current.bond}',
                _formatBond(totalBond),
                amountSuffix: multiplier == null ? null : _bondMultiplierSpan(context, '\n$multiplier'),
              ),
              kDefaultDivider,
              if (requirement.restricted)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.current.ascension),
                  subtitle: Text(requirement.allowed.map(limitName).join(' / ')),
                ),
              if (requirement.unreleasedCostumes.isNotEmpty)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(S.current.bond_excluded_unreleased_costumes),
                  subtitle: Text(requirement.unreleasedCostumes.map(limitName).join(' / ')),
                ),
              if (details?.atBondLimit == true)
                _bondDetailRow(S.current.bond_limit, 'Lv.MAX')
              else if (details != null) ...[
                ..._bonusRows(context, team, details),
                if (teapotTimes > 1) _bondDetailRow(Transl.itemNames('星見のティーポット').l, '×$teapotTimes'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _bonusRows(BuildContext context, BondSolvedTeam team, BondRecipientDetails details) sync* {
    final frontlineBonuses = [
      if (details.frontlineRate != 0) (S.current.team_starting_member, details.frontlineRate),
      if (details.supportFrontlineRate != 0)
        ('${S.current.team_starting_member} · ${S.current.support_servant}', details.supportFrontlineRate),
    ];
    if (frontlineBonuses.isNotEmpty) {
      yield _bondDetailRow(
        frontlineBonuses.map((bonus) => bonus.$1).join('\n'),
        frontlineBonuses.map((bonus) => _bonusText(bonus.$2, 0)).join('\n'),
      );
    }
    for (final bonus in details.craftEssences) {
      final ce = db.gameData.craftEssencesById[bonus.ce.id];
      final wearer = team.slots.firstWhere((slot) => slot.position == bonus.wearerPosition);
      final traitSummary = bonus.targetTraitGroups
          .map((group) => group.map((trait) => Transl.traitName(trait)).join(' & '))
          .join(' / ');
      final title = [
        '#${bonus.wearerPosition + 1}',
        if (wearer.isSupport) S.current.support_servant,
        ce?.lName.l ?? '#${bonus.ce.id}',
      ].join(' · ');
      yield _bondDetailRow(
        title,
        _bonusText(bonus.rate, bonus.value),
        maxTitleLines: 1,
        leading: ce?.iconBuilder(context: context, width: 40, jumpToDetail: false),
        subtitle: traitSummary.isEmpty ? null : traitSummary,
        onTap: ce?.routeTo,
      );
    }
    for (final bonus in details.eventSkills) {
      yield _bondDetailRow(
        bonus.skill.lName.l,
        _bonusText(bonus.rate, bonus.value),
        subtitle: S.current.event_skill,
        onTap: () => router.push(url: Routes.skillI(bonus.skill.id)),
      );
    }
    for (final bonus in details.campaigns) {
      yield _bondDetailRow(
        bonus.event.lShortName.l,
        _bonusText(bonus.rate, 0),
        subtitle: S.current.event_campaign,
        onTap: bonus.event.routeTo,
      );
    }
    if (details.customRate != 0 || details.customValue != 0) {
      yield _bondDetailRow(S.current.general_custom, _bonusText(details.customRate, details.customValue));
    }
    for (final source in details.bond15Sources) {
      final servant = db.gameData.servantsById[source.servantId];
      yield _bondDetailRow(
        '${S.current.bond} Lv. 15',
        _bonusText(kBond15BonusRate, 0),
        subtitle: '#${source.position + 1} · ${servant?.lName.l ?? source.servantId}',
      );
    }
    final cap = ConstData.constants.maxFriendShipUpRatio;
    final uncappedRate = details.uncappedRate;
    if (uncappedRate > cap) {
      yield _bondDetailRow(S.current.bond_bonus, '${_bonusText(uncappedRate, 0)} → ${_bonusText(cap, 0)}');
    }
  }

  String _bonusText(int rate, int value) => [
    if (rate != 0) '${rate > 0 ? '+' : ''}${rate.format(percent: true, base: 10)}',
    if (value != 0) '${value > 0 ? '+' : ''}${_formatBond(value)}',
  ].join(' · ');

  Widget _bondDetailRow(
    String title,
    String amount, {
    int maxTitleLines = 2,
    TextSpan? amountSuffix,
    String? subtitle,
    Widget? leading,
    VoidCallback? onTap,
  }) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: leading,
    title: Text(title, maxLines: maxTitleLines, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null ? null : Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis),
    trailing: Text.rich(
      TextSpan(text: amount, children: [?amountSuffix]),
      textAlign: TextAlign.end,
    ),
    onTap: onTap,
  );

  /// How much the search was allowed to draw from. A null id list means that
  /// pool was never built — the team had no free slot for it — so the whole
  /// row collapses rather than reporting a misleading zero.
  Widget _candidatePools(BuildContext context, BondSolverResult result) {
    final svtIds = result.candidateSvtIds;
    final ceIds = result.candidateCeIds;
    if (svtIds == null && ceIds == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall;
    Widget label(IconData icon, String text, {Color? color, bool tappable = false}) => Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 16, color: color ?? colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text,
          style: style?.copyWith(color: color, decoration: tappable ? TextDecoration.underline : null),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: [
          if (svtIds != null) label(Icons.person_outline, '${S.current.servant} ${svtIds.length}'),
          if (ceIds != null)
            InkWell(
              onTap: () => _showCandidateCes(context, ceIds),
              child: label(
                Icons.style_outlined,
                '${S.current.craft_essence} ${ceIds.length}',
                color: colorScheme.primary,
                tappable: true,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showCandidateCes(BuildContext context, List<int> ceIds) async {
    final ces = <CraftEssence>[for (final id in ceIds) ?db.gameData.craftEssencesById[id]];
    await router.showDialog<void>(
      context: context,
      builder: (context) => SimpleConfirmDialog(
        showCancel: false,
        title: Text('${S.current.craft_essence} ${ces.length}'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ces.isEmpty
              ? const Text('—')
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    child: SharedBuilder.grid<CraftEssence>(
                      context: context,
                      items: ces,
                      builder: (context, ce) => ce.iconBuilder(context: context, width: 42),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _diagnostics(BondSolverResult solved) {
    final combinations = solved.possibleCombinations;
    final visitedNodeCountText = solved.visitedNodes.formatSep();
    final evaluated = !solved.isCeFirst
        ? '$visitedNodeCountText nodes'
        : (combinations == null
              ? '$visitedNodeCountText CE combinations'
              : '$visitedNodeCountText/$combinations CE combinations');
    return SimpleAccordion(
      headerBuilder: (context, expanded) => const ListTile(dense: true, title: Text('Search details')),
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            title: const Text('Method'),
            trailing: Text(solved.isCeFirst ? 'CE-first search' : 'General search'),
          ),
          ListTile(dense: true, title: const Text('Evaluated'), trailing: Text(evaluated)),
          ListTile(dense: true, title: const Text('Elapsed'), trailing: Text('${solved.elapsedMilliseconds} ms')),
          ListTile(dense: true, title: const Text('Candidate choices'), trailing: Text('${solved.itemCount}')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(_resultsHelp, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// A low-frequency activity cue, not a completion percentage.
class _DiscreteSearchIndicator extends StatefulWidget {
  const _DiscreteSearchIndicator();
  @override
  State<_DiscreteSearchIndicator> createState() => _DiscreteSearchIndicatorState();
}

class _DiscreteSearchIndicatorState extends State<_DiscreteSearchIndicator> {
  int segment = 0;
  late final Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => segment = (segment + 1) % 5);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: S.current.search,
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i == segment ? colors.primary : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
