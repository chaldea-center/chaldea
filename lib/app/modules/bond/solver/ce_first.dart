part of 'solver.dart';

// All freely selected CEs in this problem are wearer independent team sources.
// Their positions can therefore be assigned after their multiset is chosen.
// The servant subproblem is a small cost-constrained assignment by concrete ID.
class _CeFirstServant {
  final int id;
  final int limit;
  final int cost;
  final int profile;
  final int selfRate;
  final int selfValue;

  const _CeFirstServant(this.id, this.limit, this.cost, this.profile, this.selfRate, this.selfValue);
}

class _CeFirstSupportChoice {
  final List<int> rates;
  final List<int> values;
  final BondSolvedCe? ce;
  final Map<int, bool> candidates;
  final BondSolvedCe? ce3;
  final Map<int, bool> ce3Candidates;

  const _CeFirstSupportChoice(
    this.rates,
    this.values,
    this.ce, [
    this.candidates = const {},
    this.ce3,
    this.ce3Candidates = const {},
  ]);
}

class _CeFirstPosition {
  final bool support;
  final bool fixedServant;
  final bool searchAscensions;
  bool get variableServant => !fixedServant || searchAscensions;
  final bool bondLimit;
  final bool freeCe1;
  final bool freeCe3;
  final int first;
  final BondSolvedCe? fixedCe1;
  final BondSolvedCe? fixedCe3;
  final int fixedCe1Cost;
  final List<_CeFirstServant> servants;
  final List<_CeFirstSupportChoice> supportChoices;

  const _CeFirstPosition({
    required this.support,
    required this.fixedServant,
    this.searchAscensions = false,
    required this.bondLimit,
    required this.freeCe1,
    required this.freeCe3,
    required this.first,
    required this.fixedCe1,
    required this.fixedCe3,
    required this.fixedCe1Cost,
    required this.servants,
    required this.supportChoices,
  });
}

class _CeFirstProblem {
  final int maxCost;
  final int rateCap;
  final int fixedCost;
  final List<int> fixedRates;
  final List<int> fixedValues;
  final List<_CeFirstPosition> positions;
  final List<BondCeSource> ownCes;
  final Set<int> fixedCeIdentities;
  final List<_CeFirstSelection>? preparedOwnSelections;
  final bool streaming;

  const _CeFirstProblem({
    required this.maxCost,
    required this.rateCap,
    required this.fixedCost,
    required this.fixedRates,
    required this.fixedValues,
    required this.positions,
    required this.ownCes,
    required this.fixedCeIdentities,
    this.preparedOwnSelections,
    this.streaming = false,
  });

  _CeFirstProblem asStreaming() => _CeFirstProblem(
    maxCost: maxCost,
    rateCap: rateCap,
    fixedCost: fixedCost,
    fixedRates: fixedRates,
    fixedValues: fixedValues,
    positions: positions,
    ownCes: ownCes,
    fixedCeIdentities: fixedCeIdentities,
    streaming: true,
  );
}

class _CeFirstResult {
  final BondSolvedTeam? best;
  final List<BondSolvedTeam> ties;
  final List<BondSolvedTeam> candidates;
  final List<int> tieGroupCounts;
  final bool provenOptimal;
  final int evaluatedCombinations;
  final int? possibleCombinations;
  final int? firstFeasibleMilliseconds;

  const _CeFirstResult(
    this.best,
    this.ties,
    this.candidates,
    this.tieGroupCounts,
    this.provenOptimal,
    this.evaluatedCombinations,
    this.possibleCombinations,
    this.firstFeasibleMilliseconds,
  );
}

class _CeFirstSolution {
  final BondSolvedTeam team;
  final String groupKey;
  final List<int> rates;
  final List<int> values;
  const _CeFirstSolution(this.team, this.groupKey, this.rates, this.values);
}

class _CeFirstNeighbor {
  final int position;
  final _CeFirstServant servant;
  final int bond;
  final int totalCost;
  final int totalBond;

  const _CeFirstNeighbor(this.position, this.servant, this.bond, this.totalCost, this.totalBond);
}

class _CeFirstCombo {
  final List<int> ownCe1;
  final List<int> ownCe3;
  final List<int> supportChoices;
  final List<int> matchedIds;
  final int ceCost;
  final int upper;

  const _CeFirstCombo(this.ownCe1, this.ownCe3, this.supportChoices, this.matchedIds, this.ceCost, this.upper);
}

class _CeFirstServantCostGroup {
  final int cost;
  final List<List<_CeFirstServant>> byId;

  const _CeFirstServantCostGroup(this.cost, this.byId);
}

class _CeFirstScoredServant implements BondAssignmentChoice {
  final _CeFirstServant servant;
  @override
  final int position;
  @override
  final int score;

  const _CeFirstScoredServant(this.servant, this.position, this.score);
  @override
  int get cost => servant.cost;
}

class _CeFirstSearchInput {
  final _CeFirstProblem problem;
  final int? maxEvaluations;
  final int maxTies;
  final int maxCandidates;
  const _CeFirstSearchInput(this.problem, this.maxEvaluations, this.maxTies, this.maxCandidates);
}

class _CeFirstSelection {
  final List<int> ownCe1;
  final List<int> ownCe3;
  final List<int> matchedIds;
  final int cost;
  const _CeFirstSelection(this.ownCe1, this.ownCe3, this.matchedIds, this.cost);
}

/// Enumerates owned CE multisets independently of support sources. Null entries
/// are scheduler checkpoints, including branches rejected by COST or identity.
Iterable<_CeFirstSelection?> _ownCeSelections(_CeFirstProblem problem) sync* {
  final slots1 = problem.positions.where((p) => p.freeCe1).length;
  final slots3 = problem.positions.where((p) => p.freeCe3).length;
  final selected1 = <int>[];
  final selected3 = <int>[];
  final counts = List<int>.filled(problem.ownCes.length, 0);
  var cost = problem.fixedCost;
  var ticks = 0;

  Iterable<_CeFirstSelection?> third(int start) sync* {
    if (++ticks % 64 == 0) yield null;
    final matched = _matchCeIds(problem, [...selected1, ...selected3]);
    if (matched != null) {
      yield _CeFirstSelection(List.of(selected1), List.of(selected3), matched, cost);
    }
    // Adding more dimensions cannot repair an already impossible matching.
    if (matched == null || selected3.length == slots3) return;
    for (var i = start; i < problem.ownCes.length; i++) {
      if (++ticks % 64 == 0) yield null;
      if (!problem.ownCes[i].canAdd(counts[i])) continue;
      counts[i]++;
      selected3.add(i);
      yield* third(i);
      selected3.removeLast();
      counts[i]--;
    }
  }

  Iterable<_CeFirstSelection?> first(int start) sync* {
    if (++ticks % 64 == 0) yield null;
    // All CE costs are nonnegative. Equip3 cannot rescue an over-budget prefix.
    if (cost > problem.maxCost) return;
    yield* third(0);
    if (selected1.length == slots1) return;
    for (var i = start; i < problem.ownCes.length; i++) {
      if (++ticks % 64 == 0) yield null;
      if (!problem.ownCes[i].canAdd(counts[i])) continue;
      counts[i]++;
      selected1.add(i);
      cost += problem.ownCes[i].cost;
      yield* first(i);
      cost -= problem.ownCes[i].cost;
      selected1.removeLast();
      counts[i]--;
    }
  }

  yield* first(0);
}

List<int>? _matchCeIds(_CeFirstProblem problem, List<int> selected) =>
    matchBondCeIds(problem.ownCes, problem.fixedCeIdentities, selected);

class _CeFirstSearch {
  final _CeFirstProblem problem;
  final int maxTies;
  final int maxCandidates;
  BondSolvedTeam? _best;
  final List<BondSolvedTeam> _ties = [];
  final List<BondSolvedTeam> _candidates = [];
  final Set<String> _candidateKeys = {};
  final Stopwatch _clock = Stopwatch();
  int? _firstFeasibleMilliseconds;
  _CeFirstSolution? _bestSolution;
  final List<int> _tieCounts = [];
  final List<String> _tieKeys = [];
  final Map<String, int> _tieIndex = {};
  int _evaluated = 0;
  int _workTicks = 0;
  BondAssignmentCache<_CeFirstScoredServant>? _assignmentCache;
  final _servantCostGroups = <int, List<_CeFirstServantCostGroup>>{};

  _CeFirstSearch(this.problem, {this.maxTies = 20, this.maxCandidates = 100});

  _CeFirstResult _snapshot(bool proven, int? possible) => _CeFirstResult(
    _best,
    List<BondSolvedTeam>.unmodifiable(_ties),
    List<BondSolvedTeam>.unmodifiable(_candidates),
    List<int>.unmodifiable(_tieCounts),
    proven,
    _evaluated,
    possible,
    _firstFeasibleMilliseconds,
  );

  _CeFirstSolution? _evaluatedSolution;
  _CeFirstResult solve({int? maxEvaluations, void Function(_CeFirstResult)? onProgress}) {
    late _CeFirstResult result;
    for (final _ in solveSteps(
      maxEvaluations: maxEvaluations,
      onProgress: onProgress,
      onComplete: (value) => result = value,
    )) {}
    return result;
  }

  Iterable<void> solveSteps({
    int? maxEvaluations,
    void Function(_CeFirstResult)? onProgress,
    required void Function(_CeFirstResult) onComplete,
  }) sync* {
    if (maxTies < 1) throw ArgumentError.value(maxTies, 'maxTies');
    if (maxCandidates < 1) throw ArgumentError.value(maxCandidates, 'maxCandidates');
    if (maxEvaluations != null && maxEvaluations < 0) {
      throw ArgumentError.value(maxEvaluations, 'maxEvaluations');
    }
    _clock.start();
    // Only streaming candidate collection revisits the proof traversal. Keep
    // bounded and single-candidate requests free of cache key construction.
    if (problem.streaming &&
        maxEvaluations == null &&
        maxCandidates > 1 &&
        problem.positions.any((p) => !p.support && p.variableServant)) {
      _assignmentCache = BondAssignmentCache();
    }
    final combos = <_CeFirstCombo>[];
    final seeded = <_CeFirstCombo>{};
    var seedUpper = kImpossibleScore;
    void rememberSolution(_CeFirstSolution solution, int? possible) {
      final team = solution.team;
      _rememberCandidate(team);
      if (_best == null || team.totalBond > _best!.totalBond) {
        _firstFeasibleMilliseconds ??= _clock.elapsedMilliseconds;
        _best = team;
        _bestSolution = solution;
        _ties.clear();
        _tieCounts.clear();
        _tieKeys.clear();
        _tieIndex.clear();
        _addTie(solution);
        onProgress?.call(_snapshot(false, possible));
      } else if (team.totalBond == _best!.totalBond) {
        if (team.totalCost > _best!.totalCost) {
          _best = team;
          _bestSolution = solution;
        }
        _addTie(solution);
      }
    }

    final ce1Slots = [
      for (var p = 0; p < problem.positions.length; p++)
        if (problem.positions[p].freeCe1) p,
    ];
    final ce3Slots = [
      for (var p = 0; p < problem.positions.length; p++)
        if (problem.positions[p].freeCe3) p,
    ];
    final supportSlots = [
      for (var p = 0; p < problem.positions.length; p++)
        if (problem.positions[p].support) p,
    ];
    final supportSelection = List<int>.filled(supportSlots.length, 0);
    final upperServants = <List<_CeFirstServant>>[];
    for (final position in problem.positions) {
      final seen = <(int, int, int)>{};
      final distinct = <_CeFirstServant>[];
      for (final servant in position.servants) {
        if (++_workTicks % 64 == 0) yield null;
        // The upper bound ignores identity and COST. Equal receiver/self
        // effects therefore have exactly the same score for every CE vector.
        if (seen.add((servant.profile, servant.selfRate, servant.selfValue))) distinct.add(servant);
      }
      upperServants.add(distinct);
    }

    // Equal score functions and complete receiver domains have equal maxima
    // for every CE vector. Identity/COST remain part of the exact servant DP.
    final upperGroupAtPosition = List<int>.filled(problem.positions.length, -1);
    final upperGroupByKey = <(int, bool, String), int>{};
    final upperGroups = <(_CeFirstPosition, List<_CeFirstServant>)>[];
    for (final (p, position) in problem.positions.indexed) {
      if (++_workTicks % 64 == 0) yield null;
      if (position.support || position.bondLimit) continue;
      final key = (
        position.first,
        position.fixedServant,
        upperServants[p].map((s) => '${s.profile},${s.selfRate},${s.selfValue}').join(';'),
      );
      upperGroupAtPosition[p] = upperGroupByKey.putIfAbsent(key, () {
        upperGroups.add((position, upperServants[p]));
        return upperGroups.length - 1;
      });
    }
    final upperScores = List<int>.filled(upperGroups.length, 0);

    if (problem.streaming) {
      yield* _solveStreamingSteps(
        upperGroups,
        upperGroupAtPosition,
        upperScores,
        ce1Slots,
        ce3Slots,
        supportSlots,
        maxEvaluations: maxEvaluations,
        remember: rememberSolution,
        onProgress: onProgress,
        onComplete: onComplete,
      );
      return;
    }

    Iterable<void> collect(_CeFirstSelection selection) sync* {
      // Rejected combinations and bond-capped receivers must also yield.
      if (++_workTicks % 64 == 0) yield null;
      final selected1 = selection.ownCe1, selected3 = selection.ownCe3;
      final totalCost = selection.cost;
      final matched = selection.matchedIds;
      final selected = [...selected1, ...selected3];
      final rates = List<int>.of(problem.fixedRates);
      final values = List<int>.of(problem.fixedValues);
      for (final (s, p) in supportSlots.indexed) {
        final choice = problem.positions[p].supportChoices[supportSelection[s]];
        _addVector(rates, choice.rates);
        _addVector(values, choice.values);
      }
      for (final i in selected) {
        _addVector(rates, problem.ownCes[i].rates);
        _addVector(values, problem.ownCes[i].values);
      }
      for (final (g, group) in upperGroups.indexed) {
        final (position, servants) = group;
        var highest = position.fixedServant ? kImpossibleScore : 0;
        for (final servant in servants) {
          if (++_workTicks % 64 == 0) yield null;
          highest = math.max(highest, _score(position, servant, rates, values));
        }
        upperScores[g] = highest;
      }
      var upper = 0;
      // Preserve the original addition order, including empty/fixed domains.
      for (final group in upperGroupAtPosition) {
        if (group >= 0) upper += upperScores[group];
      }
      final combo = _CeFirstCombo(selected1, selected3, List<int>.of(supportSelection), matched, totalCost, upper);
      combos.add(combo);
      // Establish a real lower bound before building the entire CE space.
      // A few improving upper-bound records provide bounded high-score seeds;
      // all remaining combinations still go through the exact proof below.
      if (seeded.length < 2 &&
          combo.upper > seedUpper &&
          (_best == null || combo.upper > _best!.totalBond) &&
          (maxEvaluations == null || _evaluated < maxEvaluations)) {
        seedUpper = combo.upper;
        seeded.add(combo);
        _evaluated++;
        yield* _evaluateSteps(combo, ce1Slots, ce3Slots, supportSlots);
        final solution = _evaluatedSolution;
        if (solution != null) rememberSolution(solution, null);
      }
    }

    // Owned selections do not depend on support sources or their identities.
    // Fill lazily so the first feasible seed does not wait for a separate pass.
    final reuseOwnSelections =
        problem.preparedOwnSelections == null &&
        supportSlots.any((p) => problem.positions[p].supportChoices.length > 1);
    List<_CeFirstSelection>? ownedSelectionCache;
    Iterable<_CeFirstSelection?> reusableOwnSelections() sync* {
      final cached = ownedSelectionCache;
      if (cached != null) {
        yield* cached;
        return;
      }
      final pending = <_CeFirstSelection>[];
      for (final selection in _ownCeSelections(problem)) {
        if (selection != null) pending.add(selection);
        yield selection;
      }
      // Publish only a complete traversal, including an empty result list.
      ownedSelectionCache = pending;
    }

    Iterable<void> enumerateSupport(int index) sync* {
      if (index == supportSlots.length) {
        for (final selection
            in problem.preparedOwnSelections ??
                (reuseOwnSelections ? reusableOwnSelections() : _ownCeSelections(problem))) {
          if (selection == null) {
            yield null;
          } else {
            yield* collect(selection);
          }
        }
        return;
      }
      final choices = problem.positions[supportSlots[index]].supportChoices;
      for (var i = 0; i < choices.length; i++) {
        if (++_workTicks % 64 == 0) yield null;
        supportSelection[index] = i;
        yield* enumerateSupport(index + 1);
      }
    }

    yield* enumerateSupport(0);
    yield* bondSortSteps(combos, (a, b) {
      final score = b.upper.compareTo(a.upper);
      return score != 0 ? score : a.ceCost.compareTo(b.ceCost);
    });
    if (kDebugMode) {
      debugPrint(
        '[BondSolver] CE combinations prepared: ${_clock.elapsedMilliseconds}ms count=${combos.length} '
        'upperVariants=${upperServants.fold<int>(0, (sum, variants) => sum + variants.length)} '
        'seeds=${seeded.length}',
      );
    }
    onProgress?.call(_snapshot(false, combos.length));
    final progressClock = Stopwatch()..start();
    var lastProgressMs = 0;
    var scoreProven = false;
    void reportIfDue() {
      if (onProgress != null && _evaluated % 16 == 0 && progressClock.elapsedMilliseconds - lastProgressMs >= 250) {
        onProgress(_snapshot(scoreProven, combos.length));
        lastProgressMs = progressClock.elapsedMilliseconds;
      }
    }

    var nextCombo = 0;
    for (; nextCombo < combos.length; nextCombo++) {
      final combo = combos[nextCombo];
      if (_best != null && combo.upper <= _best!.totalBond) break;
      if (seeded.contains(combo)) continue;
      if (maxEvaluations != null && _evaluated >= maxEvaluations) {
        onComplete(_snapshot(false, combos.length));
        return;
      }
      _evaluated++;
      yield* _evaluateSteps(combo, ce1Slots, ce3Slots, supportSlots);
      final solution = _evaluatedSolution;
      if (solution == null) {
        reportIfDue();
        continue;
      }
      rememberSolution(solution, combos.length);
      reportIfDue();
    }
    // The maximum score is proved above. Explore a bounded number of equal
    // upper-bound combinations for other effect groups without delaying proof.
    if (_best != null) {
      scoreProven = true;
      onProgress?.call(_snapshot(true, combos.length));
      if (_bestSolution != null) {
        yield* _rememberNearbyServantsSteps(_bestSolution!);
      }
      if (maxEvaluations != null) {
        onComplete(_snapshot(true, combos.length));
        return;
      }
      var tieEvaluations = 0;
      for (; nextCombo < combos.length && tieEvaluations < maxTies * 4 && _ties.length < maxTies; nextCombo++) {
        final combo = combos[nextCombo];
        if (combo.upper < _best!.totalBond) break;
        if (seeded.contains(combo)) continue;
        tieEvaluations++;
        _evaluated++;
        yield* _evaluateSteps(combo, ce1Slots, ce3Slots, supportSlots);
        final solution = _evaluatedSolution;
        if (solution != null) {
          _rememberCandidate(solution.team);
          if (_candidates.length < maxCandidates && solution.team.totalBond == _best!.totalBond) {
            yield* _rememberNearbyServantsSteps(solution);
          }
        }
        if (solution != null && solution.team.totalBond == _best!.totalBond) {
          if (solution.team.totalCost > _best!.totalCost) _best = solution.team;
          _addTie(solution);
        }
        reportIfDue();
      }
      var candidateEvaluations = 0;
      for (; nextCombo < combos.length && candidateEvaluations < maxCandidates * 4; nextCombo++) {
        final combo = combos[nextCombo];
        if (_candidates.length == maxCandidates && combo.upper < _candidates.last.totalBond) break;
        if (seeded.contains(combo)) continue;
        candidateEvaluations++;
        _evaluated++;
        yield* _evaluateSteps(combo, ce1Slots, ce3Slots, supportSlots);
        final solution = _evaluatedSolution;
        if (solution != null) {
          _rememberCandidate(solution.team);
          if (solution.team.totalBond == _best!.totalBond) _addTie(solution);
        }
        reportIfDue();
      }
    }
    onComplete(_snapshot(true, combos.length));
  }

  void _rememberCandidate(BondSolvedTeam team) {
    if (_candidates.length == maxCandidates && _compareCandidate(team, _candidates.last) >= 0) return;
    final key = team._signature;
    if (!_candidateKeys.add(key)) return;
    var index = 0;
    while (index < _candidates.length && _compareCandidate(_candidates[index], team) <= 0) {
      index++;
    }
    _candidates.insert(index, team);
    if (_candidates.length > maxCandidates) {
      _candidateKeys.remove(_candidates.removeLast()._signature);
    }
  }

  int _compareCandidate(BondSolvedTeam a, BondSolvedTeam b) {
    final score = b.totalBond.compareTo(a.totalBond);
    return score != 0 ? score : b.totalCost.compareTo(a.totalCost);
  }

  void _addTie(_CeFirstSolution solution) {
    final index = _tieIndex[solution.groupKey];
    if (index != null) {
      _tieCounts[index]++;
      if (solution.team.totalCost > _ties[index].totalCost) _ties[index] = solution.team;
    } else if (_ties.length < maxTies) {
      _tieIndex[solution.groupKey] = _ties.length;
      _tieKeys.add(solution.groupKey);
      _ties.add(solution.team);
      _tieCounts.add(1);
    } else if (identical(solution.team, _best)) {
      final last = _ties.length - 1;
      _tieIndex.remove(_tieKeys[last]);
      _tieKeys[last] = solution.groupKey;
      _tieIndex[solution.groupKey] = last;
      _ties[last] = solution.team;
      _tieCounts[last] = 1;
    }
  }

  static void _addVector(List<int> target, List<int> source) {
    for (var i = 0; i < target.length; i++) {
      target[i] += source[i];
    }
  }

  int _score(_CeFirstPosition position, _CeFirstServant servant, List<int> rates, List<int> values) {
    if (position.bondLimit) return 0;
    final profile = servant.profile;
    final rate = math.min(problem.rateCap, servant.selfRate + rates[profile]);
    return (position.first * (1 + rate / 1000)).floor() + servant.selfValue + values[profile];
  }

  void _rememberAssignment(String? key, Map<int, _CeFirstScoredServant>? servants) {
    final cache = _assignmentCache;
    if (key != null) cache?.remember(key, servants);
  }

  Iterable<void> _prepareServantCostGroupsSteps(int p) sync* {
    if (_servantCostGroups.containsKey(p)) return;
    final byCost = <int, Map<int, List<_CeFirstServant>>>{};
    for (final servant in problem.positions[p].servants) {
      if (++_workTicks % 64 == 0) yield null;
      byCost.putIfAbsent(servant.cost, () => {}).putIfAbsent(servant.id, () => []).add(servant);
    }
    final groups = <_CeFirstServantCostGroup>[];
    for (final entry in byCost.entries) {
      if (++_workTicks % 64 == 0) yield null;
      final byId = <List<_CeFirstServant>>[];
      for (final variants in entry.value.values) {
        if (++_workTicks % 64 == 0) yield null;
        byId.add(List.unmodifiable(variants));
      }
      groups.add(_CeFirstServantCostGroup(entry.key, List.unmodifiable(byId)));
    }
    // Only grouping is invariant. Scores and the best ascension are selected
    // again for each source vector, retaining first-seen COST/ID/tie order.
    _servantCostGroups[p] = List.unmodifiable(groups);
  }

  Iterable<void> _evaluateSteps(
    _CeFirstCombo combo,
    List<int> ce1Slots,
    List<int> ce3Slots,
    List<int> supportSlots,
  ) sync* {
    _evaluatedSolution = null;
    final rates = List<int>.of(problem.fixedRates);
    final values = List<int>.of(problem.fixedValues);
    for (final (s, p) in supportSlots.indexed) {
      if (++_workTicks % 64 == 0) yield null;
      final source = problem.positions[p].supportChoices[combo.supportChoices[s]];
      _addVector(rates, source.rates);
      _addVector(values, source.values);
    }
    for (final i in [...combo.ownCe1, ...combo.ownCe3]) {
      if (++_workTicks % 64 == 0) yield null;
      _addVector(rates, problem.ownCes[i].rates);
      _addVector(values, problem.ownCes[i].values);
    }
    final freePositions = [
      for (var p = 0; p < problem.positions.length; p++)
        if (!problem.positions[p].support && problem.positions[p].variableServant) p,
    ];
    var fixedScore = 0;
    for (final position in problem.positions) {
      if (++_workTicks % 64 == 0) yield null;
      if (position.support || position.variableServant || position.bondLimit) continue;
      fixedScore += _score(position, position.servants.single, rates, values);
    }
    final maximumServantCost = freePositions.fold<int>(
      0,
      (sum, p) => sum + problem.positions[p].servants.fold<int>(0, (highest, svt) => math.max(highest, svt.cost)),
    );
    final remainingCost = math.min(problem.maxCost - combo.ceCost, maximumServantCost);
    if (remainingCost < 0) return;
    final mandatoryMask = freePositions.indexed.fold<int>(0, (mask, entry) {
      final (bit, p) = entry;
      return !problem.positions[p].fixedServant && problem.positions[p].fixedCe1 == null ? mask : mask | (1 << bit);
    });
    final freeCe1Mask = freePositions.indexed.fold<int>(0, (mask, entry) {
      final (bit, p) = entry;
      return problem.positions[p].freeCe1 ? mask | (1 << bit) : mask;
    });
    final guaranteedCe1Slots = ce1Slots.where((p) => !problem.positions[p].variableServant).length;

    // CE identity and source assembly are still evaluated per combination.
    // Only the exact servant assignment is reusable within this request.
    final assignmentKey = _assignmentCache?.key(rates, values, remainingCost, combo.ownCe1.length);
    final cachedAssignment = assignmentKey == null ? null : _assignmentCache![assignmentKey];
    late final Map<int, _CeFirstScoredServant> selectedServants;
    if (cachedAssignment != null) {
      final cachedServants = cachedAssignment.servants;
      if (cachedServants == null) return;
      selectedServants = cachedServants;
    } else {
      // A candidate outside the best F distinct IDs of the same cost at a
      // position can be replaced by one of those F: at most F-1 other free
      // positions can occupy them. This preserves the optimum exactly.
      final topPerPosition = <int, List<_CeFirstScoredServant>>{};
      for (final (bit, p) in freePositions.indexed) {
        if (++_workTicks % 64 == 0) yield null;
        final position = problem.positions[p];
        var groups = _servantCostGroups[p];
        if (groups == null) {
          yield* _prepareServantCostGroupsSteps(p);
          groups = _servantCostGroups[p]!;
        }
        final selected = <_CeFirstScoredServant>[];
        for (final group in groups) {
          if (++_workTicks % 64 == 0) yield null;
          if (group.cost > remainingCost) continue;
          final ordered = <_CeFirstScoredServant>[];
          for (final variants in group.byId) {
            _CeFirstServant? best;
            var bestScore = 0;
            for (final servant in variants) {
              if (++_workTicks % 64 == 0) yield null;
              final score = _score(position, servant, rates, values);
              if (best == null || score > bestScore) {
                best = servant;
                bestScore = score;
              }
            }
            ordered.add(_CeFirstScoredServant(best!, bit, bestScore));
          }
          ordered.sort((a, b) => b.score.compareTo(a.score));
          selected.addAll(ordered.take(freePositions.length));
        }
        topPerPosition[bit] = selected;
      }
      final byId = <int, List<_CeFirstScoredServant>>{};
      for (final choices in topPerPosition.values) {
        if (++_workTicks % 64 == 0) yield null;
        for (final choice in choices) {
          if (++_workTicks % 64 == 0) yield null;
          byId.putIfAbsent(choice.servant.id, () => []).add(choice);
        }
      }

      final masks = 1 << freePositions.length;
      final width = remainingCost + 1;
      late List<BondAssignmentState<_CeFirstScoredServant>?> states;
      yield* bondAssignmentSteps<_CeFirstScoredServant>(
        positions: freePositions.length,
        budget: remainingCost,
        byId: byId,
        onComplete: (table) => states = table,
      );
      BondAssignmentState<_CeFirstScoredServant>? winner;
      var winnerCost = 0;
      for (var mask = 0; mask < masks; mask++) {
        if (++_workTicks % 64 == 0) yield null;
        if ((mask & mandatoryMask) != mandatoryMask) continue;
        if (guaranteedCe1Slots + _bitCount(mask & freeCe1Mask) < combo.ownCe1.length) continue;
        for (var cost = 0; cost < width; cost++) {
          if (cost % 64 == 0) yield null;
          final state = states[mask * width + cost];
          if (state == null) continue;
          if (winner == null || state.score > winner.score || (state.score == winner.score && cost < winnerCost)) {
            winner = state;
            winnerCost = cost;
          }
        }
      }
      if (winner == null) {
        _rememberAssignment(assignmentKey, null);
        return;
      }
      selectedServants = <int, _CeFirstScoredServant>{};
      for (var path = winner.path; path != null; path = path.previous) {
        if (++_workTicks % 64 == 0) yield null;
        selectedServants[freePositions[path.choice.position]] = path.choice;
      }
      _rememberAssignment(assignmentKey, selectedServants);
    }
    final ce1At = <int, BondSolvedCe>{};
    final ce1VariantsAt = <int, Map<int, bool>>{};
    var assigned = 0;
    for (final p in ce1Slots) {
      if (++_workTicks % 64 == 0) yield null;
      if (problem.positions[p].variableServant && !selectedServants.containsKey(p)) continue;
      if (assigned == combo.ownCe1.length) break;
      final cls = problem.ownCes[combo.ownCe1[assigned]];
      final id = combo.matchedIds[assigned];
      ce1At[p] = BondSolvedCe(id, cls.limits[id]!);
      ce1VariantsAt[p] = cls.limits;
      assigned++;
    }
    if (assigned != combo.ownCe1.length) return;
    final ce3At = <int, BondSolvedCe>{};
    final ce3VariantsAt = <int, Map<int, bool>>{};
    for (var i = 0; i < combo.ownCe3.length; i++) {
      if (++_workTicks % 64 == 0) yield null;
      final cls = problem.ownCes[combo.ownCe3[i]];
      final id = combo.matchedIds[combo.ownCe1.length + i];
      ce3At[ce3Slots[i]] = BondSolvedCe(id, cls.limits[id]!);
      ce3VariantsAt[ce3Slots[i]] = cls.limits;
    }
    final supportChoiceAt = <int, _CeFirstSupportChoice>{};
    for (final (i, p) in supportSlots.indexed) {
      if (++_workTicks % 64 == 0) yield null;
      supportChoiceAt[p] = problem.positions[p].supportChoices[combo.supportChoices[i]];
    }
    final slots = <BondSolvedSlot>[];
    var totalCost = 0;
    for (final (p, position) in problem.positions.indexed) {
      if (++_workTicks % 64 == 0) yield null;
      final servant = !position.variableServant ? position.servants.single : selectedServants[p]?.servant;
      final ce1 = position.fixedCe1 ?? ce1At[p] ?? supportChoiceAt[p]?.ce;
      final ce3 = position.fixedCe3 ?? ce3At[p] ?? supportChoiceAt[p]?.ce3;
      final bond = servant == null || position.bondLimit ? 0 : _score(position, servant, rates, values);
      final servantVariants = servant == null
          ? const <int, int>{}
          : position.fixedServant
          ? {servant.id: servant.limit}
          : {
              for (final alternative in position.servants)
                if (alternative.cost == servant.cost && _score(position, alternative, rates, values) == bond)
                  alternative.id: alternative.limit,
              servant.id: servant.limit,
            };
      final cost = position.support
          ? 0
          : (servant?.cost ?? 0) +
                (ce1 == null ? 0 : (position.fixedCe1 != null ? position.fixedCe1Cost : _chosenCeCost(combo, ce1.id)));
      totalCost += cost;
      slots.add(
        BondSolvedSlot(
          position: p,
          servantId: servant?.id,
          limitCount: servant?.limit,
          equip1: ce1,
          equip3: ce3,
          isSupport: position.support,
          fixedServant: position.fixedServant,
          fixedEquip1: position.fixedCe1 != null,
          fixedEquip3: position.fixedCe3 != null,
          bond: bond,
          cost: cost,
          servantCandidates: servant == null ? const [] : [servant.id],
          equip1Candidates: ce1 == null ? const [] : [ce1.id],
          equip3Candidates: ce3 == null ? const [] : [ce3.id],
          servantVariants: servantVariants,
          equip1Variants: position.fixedCe1 != null
              ? {ce1!.id: ce1.limitBreak}
              : ce1VariantsAt[p] ?? supportChoiceAt[p]?.candidates ?? const {},
          equip3Variants: position.fixedCe3 != null
              ? {ce3!.id: ce3.limitBreak}
              : ce3VariantsAt[p] ?? supportChoiceAt[p]?.ce3Candidates ?? const {},
        ),
      );
    }
    final total = slots.fold<int>(0, (v, slot) => v + slot.bond);
    assert(total == fixedScore + selectedServants.values.fold<int>(0, (v, c) => v + c.score));
    assert(totalCost == combo.ceCost + selectedServants.values.fold<int>(0, (v, c) => v + c.servant.cost));
    final groupKey = [
      for (final (p, position) in problem.positions.indexed)
        '${!position.variableServant ? position.servants.single.profile : selectedServants[p]?.servant.profile ?? -1}:${slots[p].bond}',
      rates.join(','),
      values.join(','),
    ].join('|');
    _evaluatedSolution = _CeFirstSolution(BondSolvedTeam(total, totalCost, slots), groupKey, rates, values);
  }

  /// A one-servant substitution keeps every CE source unchanged in the
  /// separable path. Score only that receiver and retain feasible alternatives.
  Iterable<void> _rememberNearbyServantsSteps(_CeFirstSolution solution) sync* {
    final team = solution.team;
    final neighbors = <_CeFirstNeighbor>[];
    for (final (p, position) in problem.positions.indexed) {
      if (++_workTicks % 64 == 0) yield null;
      if (position.support || position.fixedServant) continue;
      final slot = team.slots[p];
      if (slot.servantId == null) continue;
      final current = position.servants.firstWhere(
        (servant) => servant.id == slot.servantId && servant.limit == slot.limitCount,
      );
      final occupiedIds = <int>{
        for (final other in team.slots)
          if (other.position != p && other.servantId != null) other.servantId!,
      };
      for (final servant in position.servants) {
        if (++_workTicks % 64 == 0) yield null;
        if (servant.id == current.id && servant.limit == current.limit) continue;
        if (occupiedIds.contains(servant.id)) continue;
        final totalCost = team.totalCost - current.cost + servant.cost;
        if (totalCost > problem.maxCost) continue;
        final bond = _score(position, servant, solution.rates, solution.values);
        final totalBond = team.totalBond - slot.bond + bond;
        if (_candidates.length == maxCandidates && totalBond < _candidates.last.totalBond) continue;
        neighbors.add(_CeFirstNeighbor(p, servant, bond, totalCost, totalBond));
      }
    }
    neighbors.sort((a, b) {
      final score = b.totalBond.compareTo(a.totalBond);
      return score != 0 ? score : b.totalCost.compareTo(a.totalCost);
    });
    for (final neighbor in neighbors.take(maxCandidates)) {
      if (++_workTicks % 64 == 0) yield null;
      final original = team.slots[neighbor.position];
      final position = problem.positions[neighbor.position];
      final current = position.servants.firstWhere(
        (servant) => servant.id == original.servantId && servant.limit == original.limitCount,
      );
      final replacement = BondSolvedSlot(
        position: original.position,
        servantId: neighbor.servant.id,
        limitCount: neighbor.servant.limit,
        equip1: original.equip1,
        equip3: original.equip3,
        isSupport: false,
        fixedServant: false,
        fixedEquip1: original.fixedEquip1,
        fixedEquip3: original.fixedEquip3,
        bond: neighbor.bond,
        cost: original.cost - current.cost + neighbor.servant.cost,
        servantCandidates: [neighbor.servant.id],
        equip1Candidates: original.equip1Candidates,
        equip3Candidates: original.equip3Candidates,
        servantVariants: {neighbor.servant.id: neighbor.servant.limit},
        equip1Variants: original.equip1Variants,
        equip3Variants: original.equip3Variants,
      );
      final slots = List<BondSolvedSlot>.of(team.slots)..[neighbor.position] = replacement;
      _rememberCandidate(BondSolvedTeam(neighbor.totalBond, neighbor.totalCost, slots));
    }
  }

  int _chosenCeCost(_CeFirstCombo combo, int id) {
    for (var i = 0; i < combo.ownCe1.length; i++) {
      if (combo.matchedIds[i] == id) return problem.ownCes[combo.ownCe1[i]].cost;
    }
    return 0;
  }

  int _bitCount(int value) {
    var count = 0;
    while (value != 0) {
      value &= value - 1;
      count++;
    }
    return count;
  }
}
