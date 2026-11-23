part of 'solver.dart';

/// Searches each distinct placement of newly activated Grand reward slots.
/// Ordinary servant classes and the two exact engines remain shared.
final class _GrandFormationSearch {
  final _CeFirstProblem? _ceTemplate;
  final List<List<int>> _layouts;
  final Map<int, _CeFirstPosition> _ceGrandPositions;
  final List<BondSearchProblem> _generalProblems;
  final ({int equip1, int equip3})? _fixedEquips;

  _GrandFormationSearch.ceFirst(_CeFirstProblem template, this._layouts, Set<int> eligible)
    : _ceTemplate = template,
      _ceGrandPositions = {
        for (final p in _layouts.expand((layout) => layout).toSet()) p: template.positions[p].withGrandReward(eligible),
      },
      _generalProblems = const [],
      _fixedEquips = null;

  _GrandFormationSearch.general(this._generalProblems, this._fixedEquips)
    : _ceTemplate = null,
      _layouts = const [],
      _ceGrandPositions = const {};

  bool get usesCeFirst => _ceTemplate != null;

  static List<List<int>> layouts({
    required BondGrandRules rules,
    required List<PlayerSvtData> decks,
    required List<FormationBondSvtBonus> bonuses,
    required bool frontline,
    required int limit,
  }) {
    if (limit == 0) return const [];
    final free = [
      for (final (p, slot) in decks.indexed)
        if (rules.positions.contains(p) && slot.svt == null && !slot.supportType.isSupport) p,
    ];
    if (free.isEmpty) return const [];

    final previousEquivalent = <int, int>{};
    final lastInGroup = <(bool, int, int), int>{};
    for (final p in free) {
      if (decks[p].equip1.ce != null) continue;
      final key = (frontline && p < 3, bonuses[p].addRate, bonuses[p].addValue);
      final previous = lastInGroup[key];
      if (previous != null) previousEquivalent[p] = previous;
      lastInGroup[key] = p;
    }

    final layouts = <List<int>>[];
    for (var mask = 0; mask < (1 << free.length); mask++) {
      final selected = [
        for (final (bit, position) in free.indexed)
          if (mask & (1 << bit) != 0) position,
      ];
      if (selected.length > limit) continue;
      // Equivalent positions have the same candidates, fixed inputs and score.
      // Move selected positions to the beginning of each such group.
      if (selected.any((p) {
        final previous = previousEquivalent[p];
        return previous != null && !selected.contains(previous);
      })) {
        continue;
      }
      layouts.add(selected);
    }
    // More reward slots tend to yield a strong feasible bound earlier.
    layouts.sort((a, b) => b.length.compareTo(a.length));
    return layouts;
  }

  _ConcreteBondSearchResult solve({int? maxNodes, required int maxTies, required int maxCandidates}) {
    late _ConcreteBondSearchResult result;
    for (final _ in solveSteps(
      maxNodes: maxNodes,
      maxTies: maxTies,
      maxCandidates: maxCandidates,
      onComplete: (value) => result = value,
    )) {}
    return result;
  }

  Iterable<void> solveSteps({
    int? maxNodes,
    int maxTies = 20,
    required int maxCandidates,
    void Function(_ConcreteBondSearchResult)? onProgress,
    required void Function(_ConcreteBondSearchResult) onComplete,
  }) sync* {
    if (maxNodes != null && maxNodes < 0) throw ArgumentError.value(maxNodes, 'maxNodes');
    if (maxTies < 1) throw ArgumentError.value(maxTies, 'maxTies');
    final clock = Stopwatch()..start();
    final candidates = <String, BondSolvedTeam>{};
    BondSolvedTeam? best;
    int? firstFeasible;
    var visited = 0;
    var lastReport = -250;

    int compare(BondSolvedTeam a, BondSolvedTeam b) {
      final score = b.totalBond.compareTo(a.totalBond);
      if (score != 0) return score;
      final cost = b.totalCost.compareTo(a.totalCost);
      return cost != 0 ? cost : a._signature.compareTo(b._signature);
    }

    _ConcreteBondSearchResult snapshot(bool proven, int nodes) {
      final teams = candidates.values.toList()..sort(compare);
      final ties = teams.where((team) => team.totalBond == best?.totalBond).take(maxTies).toList();
      return _ConcreteBondSearchResult(best, ties, teams, const [], proven, nodes, null, firstFeasible);
    }

    void remember(BondSolvedTeam team) {
      firstFeasible ??= clock.elapsedMilliseconds;
      if (best == null || compare(team, best!) < 0) best = team;
      if (candidates.containsKey(team._signature)) return;
      candidates[team._signature] = team;
      if (candidates.length > maxCandidates) {
        final worst = candidates.values.reduce((a, b) => compare(a, b) > 0 ? a : b);
        candidates.remove(worst._signature);
      }
    }

    void report(BondSolvedTeam? team, int nodes) {
      if (onProgress == null) return;
      final first = team != null && firstFeasible == null;
      if (team != null) remember(team);
      final elapsed = clock.elapsedMilliseconds;
      if (first || elapsed - lastReport >= 250) {
        lastReport = elapsed;
        onProgress(snapshot(false, visited + nodes));
      }
    }

    final template = _ceTemplate;
    final count = template == null ? _generalProblems.length : _layouts.length;
    for (var index = 0; index < count; index++) {
      yield null;
      final remaining = maxNodes == null ? null : math.max(0, maxNodes - visited);
      if (template != null) {
        final selected = _layouts[index];
        final problem = template.withPositions([
          for (final (p, position) in template.positions.indexed)
            selected.contains(p) ? _ceGrandPositions[p]! : position,
        ]);
        late _ConcreteBondSearchResult result;
        yield* _CeFirstSearch(
          problem,
          maxTies: maxTies,
          maxCandidates: maxCandidates,
          minimumBond: best?.totalBond,
          collectCandidates: false,
        ).solveSteps(
          maxEvaluations: remaining,
          onProgress: (value) => report(value.best, value.evaluatedCombinations),
          onComplete: (value) => result = value,
        );
        visited += result.evaluatedCombinations;
        if (result.best != null) remember(result.best!);
        for (final team in [...result.ties, ...result.candidates]) {
          yield null;
          remember(team);
        }
        if (!result.provenOptimal) {
          onComplete(snapshot(false, visited));
          return;
        }
      } else {
        late BondSearchResult result;
        BondSolvedTeam expand(BondSearchWitness witness) => FormationBondSolver._expandWitness(witness, _fixedEquips!);
        yield* BondSearch.solveSteps(
          _generalProblems[index],
          maxNodes: remaining,
          maxTies: maxTies,
          maxCandidates: maxCandidates,
          maxTieNodes: 0,
          maxCandidateNodes: 0,
          onProgress: (value) => report(value.best == null ? null : expand(value.best!), value.visitedNodes),
          onComplete: (value) => result = value,
        );
        visited += result.visitedNodes;
        if (result.best != null) remember(expand(result.best!));
        for (final witness in [...result.ties, ...result.candidates]) {
          yield null;
          remember(expand(witness));
        }
        if (!result.provenOptimal) {
          onComplete(snapshot(false, visited));
          return;
        }
      }
    }
    onComplete(snapshot(true, visited));
  }
}

final class _GrandSearchInput {
  final _GrandFormationSearch problem;
  final int? maxNodes;
  final int maxTies;
  final int maxCandidates;

  const _GrandSearchInput(this.problem, this.maxNodes, this.maxTies, this.maxCandidates);

  static _ConcreteBondSearchResult run(_GrandSearchInput input) =>
      input.problem.solve(maxNodes: input.maxNodes, maxTies: input.maxTies, maxCandidates: input.maxCandidates);
}
