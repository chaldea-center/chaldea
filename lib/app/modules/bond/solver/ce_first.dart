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

class _CeFirstCe {
  final int cost;
  final List<int> rates;
  final List<int> values;
  final Map<int, bool> limits;

  const _CeFirstCe(this.cost, this.rates, this.values, this.limits);
}

class _CeFirstSupportChoice {
  final List<int> rates;
  final List<int> values;
  final BondSolvedCe? ce;
  final Map<int, bool> candidates;

  const _CeFirstSupportChoice(this.rates, this.values, this.ce, [this.candidates = const {}]);
}

class _CeFirstPosition {
  final bool support;
  final bool fixedServant;
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
  final List<_CeFirstCe> ownCes;

  const _CeFirstProblem({
    required this.maxCost,
    required this.rateCap,
    required this.fixedCost,
    required this.fixedRates,
    required this.fixedValues,
    required this.positions,
    required this.ownCes,
  });
}

class _CeFirstResult {
  final BondSolvedTeam? best;
  final List<BondSolvedTeam> ties;
  final List<int> tieGroupCounts;
  final bool provenOptimal;
  final int evaluatedCombinations;
  final int possibleCombinations;

  const _CeFirstResult(
    this.best,
    this.ties,
    this.tieGroupCounts,
    this.provenOptimal,
    this.evaluatedCombinations,
    this.possibleCombinations,
  );
}

class _CeFirstSolution {
  final BondSolvedTeam team;
  final String groupKey;
  const _CeFirstSolution(this.team, this.groupKey);
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

class _CeFirstScoredServant {
  final _CeFirstServant servant;
  final int position;
  final int score;

  const _CeFirstScoredServant(this.servant, this.position, this.score);
}

class _CeFirstPath {
  final _CeFirstPath? previous;
  final _CeFirstScoredServant choice;

  const _CeFirstPath(this.previous, this.choice);
}

class _CeFirstState {
  final int score;
  final _CeFirstPath? path;

  const _CeFirstState(this.score, this.path);
}

_CeFirstResult _runCeFirstSearch(_CeFirstSearchInput input) =>
    _CeFirstSearch(input.problem, maxTies: input.maxTies).solve(maxEvaluations: input.maxEvaluations);

class _CeFirstSearchInput {
  final _CeFirstProblem problem;
  final int? maxEvaluations;
  final int maxTies;
  const _CeFirstSearchInput(this.problem, this.maxEvaluations, this.maxTies);
}

class _CeFirstSearch {
  final _CeFirstProblem problem;
  final int maxTies;
  BondSolvedTeam? _best;
  final List<BondSolvedTeam> _ties = [];
  final List<int> _tieCounts = [];
  final List<String> _tieKeys = [];
  final Map<String, int> _tieIndex = {};
  int _evaluated = 0;

  _CeFirstSearch(this.problem, {this.maxTies = 20});

  _CeFirstResult _snapshot(bool proven, int possible) => _CeFirstResult(
    _best,
    List<BondSolvedTeam>.unmodifiable(_ties),
    List<int>.unmodifiable(_tieCounts),
    proven,
    _evaluated,
    possible,
  );

  _CeFirstResult solve({int? maxEvaluations, void Function(_CeFirstResult)? onProgress}) {
    if (maxTies < 1) throw ArgumentError.value(maxTies, 'maxTies');
    if (maxEvaluations != null && maxEvaluations < 0) {
      throw ArgumentError.value(maxEvaluations, 'maxEvaluations');
    }
    final combos = <_CeFirstCombo>[];
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
    final selected1 = <int>[];
    final selected3 = <int>[];
    final fixedIds = <int>{
      for (final p in problem.positions)
        if (!p.support) ...[if (p.fixedCe1 != null) p.fixedCe1!.id, if (p.fixedCe3 != null) p.fixedCe3!.id],
    };
    final counts = List<int>.filled(problem.ownCes.length, 0);

    void collect() {
      final totalCost = problem.fixedCost + selected1.fold<int>(0, (v, i) => v + problem.ownCes[i].cost);
      if (totalCost > problem.maxCost) return;
      final selected = [...selected1, ...selected3];
      final matched = _matchCeIds(selected, fixedIds);
      if (matched == null) return;
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
      var upper = 0;
      for (final position in problem.positions) {
        if (position.support || position.bondLimit) continue;
        var highest = position.fixedServant ? -0x3fffffffffffffff : 0;
        for (final servant in position.servants) {
          highest = math.max(highest, _score(position, servant, rates, values));
        }
        upper += highest;
      }
      combos.add(
        _CeFirstCombo(
          List<int>.of(selected1),
          List<int>.of(selected3),
          List<int>.of(supportSelection),
          matched,
          totalCost,
          upper,
        ),
      );
    }

    void enumerateCe3(int start) {
      collect();
      if (selected3.length == ce3Slots.length) return;
      for (var i = start; i < problem.ownCes.length; i++) {
        if (counts[i] >= problem.ownCes[i].limits.length) continue;
        counts[i]++;
        selected3.add(i);
        enumerateCe3(i);
        selected3.removeLast();
        counts[i]--;
      }
    }

    void enumerateCe1(int start) {
      enumerateCe3(0);
      if (selected1.length == ce1Slots.length) return;
      for (var i = start; i < problem.ownCes.length; i++) {
        if (counts[i] >= problem.ownCes[i].limits.length) continue;
        counts[i]++;
        selected1.add(i);
        enumerateCe1(i);
        selected1.removeLast();
        counts[i]--;
      }
    }

    void enumerateSupport(int index) {
      if (index == supportSlots.length) {
        enumerateCe1(0);
        return;
      }
      final choices = problem.positions[supportSlots[index]].supportChoices;
      for (var i = 0; i < choices.length; i++) {
        supportSelection[index] = i;
        enumerateSupport(index + 1);
      }
    }

    enumerateSupport(0);
    combos.sort((a, b) {
      final score = b.upper.compareTo(a.upper);
      return score != 0 ? score : a.ceCost.compareTo(b.ceCost);
    });
    onProgress?.call(_snapshot(false, combos.length));
    final progressClock = Stopwatch()..start();
    var lastProgressMs = 0;
    void reportIfDue() {
      if (onProgress != null && _evaluated % 16 == 0 && progressClock.elapsedMilliseconds - lastProgressMs >= 250) {
        onProgress(_snapshot(false, combos.length));
        lastProgressMs = progressClock.elapsedMilliseconds;
      }
    }

    var nextCombo = 0;
    for (; nextCombo < combos.length; nextCombo++) {
      final combo = combos[nextCombo];
      if (_best != null && combo.upper <= _best!.totalBond) break;
      if (maxEvaluations != null && _evaluated >= maxEvaluations) {
        return _snapshot(false, combos.length);
      }
      _evaluated++;
      final solution = _evaluate(combo, ce1Slots, ce3Slots, supportSlots);
      if (solution == null) {
        reportIfDue();
        continue;
      }
      final team = solution.team;
      if (_best == null || team.totalBond > _best!.totalBond) {
        _best = team;
        _ties.clear();
        _tieCounts.clear();
        _tieKeys.clear();
        _tieIndex.clear();
        _addTie(solution);
        onProgress?.call(_snapshot(false, combos.length));
      } else if (team.totalBond == _best!.totalBond) {
        if (team.totalCost < _best!.totalCost) _best = team;
        _addTie(solution);
      }
      reportIfDue();
    }
    // The maximum score is proved above. Explore a bounded number of equal
    // upper-bound combinations for other effect groups without delaying proof.
    if (_best != null && maxEvaluations == null) {
      onProgress?.call(_snapshot(true, combos.length));
      var tieEvaluations = 0;
      for (; nextCombo < combos.length && tieEvaluations < maxTies * 4 && _ties.length < maxTies; nextCombo++) {
        final combo = combos[nextCombo];
        if (combo.upper < _best!.totalBond) break;
        tieEvaluations++;
        _evaluated++;
        final solution = _evaluate(combo, ce1Slots, ce3Slots, supportSlots);
        if (solution != null && solution.team.totalBond == _best!.totalBond) {
          if (solution.team.totalCost < _best!.totalCost) _best = solution.team;
          _addTie(solution);
        }
        reportIfDue();
      }
    }
    return _snapshot(true, combos.length);
  }

  void _addTie(_CeFirstSolution solution) {
    final index = _tieIndex[solution.groupKey];
    if (index != null) {
      _tieCounts[index]++;
      if (solution.team.totalCost < _ties[index].totalCost) _ties[index] = solution.team;
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

  List<int>? _matchCeIds(List<int> selected, Set<int> fixedIds) {
    if (selected.isEmpty) return const [];
    final assignments = List<int>.filled(selected.length, -1);
    final order = List<int>.generate(selected.length, (i) => i)
      ..sort((a, b) => problem.ownCes[selected[a]].limits.length.compareTo(problem.ownCes[selected[b]].limits.length));
    final used = Set<int>.of(fixedIds);
    bool visit(int depth) {
      if (depth == order.length) return true;
      final dimension = order[depth];
      for (final id in problem.ownCes[selected[dimension]].limits.keys) {
        if (!used.add(id)) continue;
        assignments[dimension] = id;
        if (visit(depth + 1)) return true;
        used.remove(id);
      }
      return false;
    }

    return visit(0) ? assignments : null;
  }

  static void _addVector(List<int> target, List<int> source) {
    for (var i = 0; i < target.length; i++) {
      target[i] += source[i];
    }
  }

  int _score(_CeFirstPosition position, _CeFirstServant servant, List<int> rates, List<int> values) {
    final profile = servant.profile;
    final rate = math.min(problem.rateCap, servant.selfRate + rates[profile]);
    return (position.first * (1 + rate / 1000)).floor() + servant.selfValue + values[profile];
  }

  _CeFirstSolution? _evaluate(_CeFirstCombo combo, List<int> ce1Slots, List<int> ce3Slots, List<int> supportSlots) {
    final rates = List<int>.of(problem.fixedRates);
    final values = List<int>.of(problem.fixedValues);
    for (final (s, p) in supportSlots.indexed) {
      final source = problem.positions[p].supportChoices[combo.supportChoices[s]];
      _addVector(rates, source.rates);
      _addVector(values, source.values);
    }
    for (final i in [...combo.ownCe1, ...combo.ownCe3]) {
      _addVector(rates, problem.ownCes[i].rates);
      _addVector(values, problem.ownCes[i].values);
    }
    final freePositions = [
      for (var p = 0; p < problem.positions.length; p++)
        if (!problem.positions[p].support && !problem.positions[p].fixedServant) p,
    ];
    var fixedScore = 0;
    for (final position in problem.positions) {
      if (position.support || !position.fixedServant || position.bondLimit) continue;
      fixedScore += _score(position, position.servants.single, rates, values);
    }
    final maximumServantCost = freePositions.fold<int>(
      0,
      (sum, p) => sum + problem.positions[p].servants.fold<int>(0, (highest, svt) => math.max(highest, svt.cost)),
    );
    final remainingCost = math.min(problem.maxCost - combo.ceCost, maximumServantCost);
    if (remainingCost < 0) return null;
    final mandatoryMask = freePositions.indexed.fold<int>(0, (mask, entry) {
      final (bit, p) = entry;
      return problem.positions[p].fixedCe1 == null ? mask : mask | (1 << bit);
    });
    final freeCe1Mask = freePositions.indexed.fold<int>(0, (mask, entry) {
      final (bit, p) = entry;
      return problem.positions[p].freeCe1 ? mask | (1 << bit) : mask;
    });
    final guaranteedCe1Slots = ce1Slots.where((p) => problem.positions[p].fixedServant).length;

    // A candidate outside the best F distinct IDs of the same cost at a
    // position can be replaced by one of those F: at most F-1 other free
    // positions can occupy them. This preserves the optimum exactly.
    final topPerPosition = <int, List<_CeFirstScoredServant>>{};
    for (final (bit, p) in freePositions.indexed) {
      final position = problem.positions[p];
      final byCost = <int, Map<int, _CeFirstScoredServant>>{};
      for (final servant in position.servants) {
        if (servant.cost > remainingCost) continue;
        final score = _score(position, servant, rates, values);
        final byId = byCost.putIfAbsent(servant.cost, () => {});
        final previous = byId[servant.id];
        if (previous == null || score > previous.score) {
          byId[servant.id] = _CeFirstScoredServant(servant, bit, score);
        }
      }
      final selected = <_CeFirstScoredServant>[];
      for (final choices in byCost.values) {
        final ordered = choices.values.toList()..sort((a, b) => b.score.compareTo(a.score));
        selected.addAll(ordered.take(freePositions.length));
      }
      topPerPosition[bit] = selected;
    }
    final byId = <int, List<_CeFirstScoredServant>>{};
    for (final choices in topPerPosition.values) {
      for (final choice in choices) {
        byId.putIfAbsent(choice.servant.id, () => []).add(choice);
      }
    }

    final masks = 1 << freePositions.length;
    final width = remainingCost + 1;
    var states = List<_CeFirstState?>.filled(masks * width, null);
    states[0] = const _CeFirstState(0, null);
    for (final choices in byId.values) {
      final next = List<_CeFirstState?>.of(states);
      for (var mask = 0; mask < masks; mask++) {
        for (var cost = 0; cost < width; cost++) {
          final current = states[mask * width + cost];
          if (current == null) continue;
          for (final choice in choices) {
            final bit = 1 << choice.position;
            if ((mask & bit) != 0) continue;
            final newCost = cost + choice.servant.cost;
            if (newCost >= width) continue;
            final index = (mask | bit) * width + newCost;
            final score = current.score + choice.score;
            if (next[index] == null || score > next[index]!.score) {
              next[index] = _CeFirstState(score, _CeFirstPath(current.path, choice));
            }
          }
        }
      }
      states = next;
    }
    _CeFirstState? winner;
    var winnerCost = 0;
    for (var mask = 0; mask < masks; mask++) {
      if ((mask & mandatoryMask) != mandatoryMask) continue;
      if (guaranteedCe1Slots + _bitCount(mask & freeCe1Mask) < combo.ownCe1.length) continue;
      for (var cost = 0; cost < width; cost++) {
        final state = states[mask * width + cost];
        if (state == null) continue;
        if (winner == null || state.score > winner.score || (state.score == winner.score && cost < winnerCost)) {
          winner = state;
          winnerCost = cost;
        }
      }
    }
    if (winner == null) return null;
    final selectedServants = <int, _CeFirstScoredServant>{};
    for (var path = winner.path; path != null; path = path.previous) {
      selectedServants[freePositions[path.choice.position]] = path.choice;
    }
    final ce1At = <int, BondSolvedCe>{};
    final ce1VariantsAt = <int, Map<int, bool>>{};
    var assigned = 0;
    for (final p in ce1Slots) {
      if (!problem.positions[p].fixedServant && !selectedServants.containsKey(p)) continue;
      if (assigned == combo.ownCe1.length) break;
      final cls = problem.ownCes[combo.ownCe1[assigned]];
      final id = combo.matchedIds[assigned];
      ce1At[p] = BondSolvedCe(id, cls.limits[id]!);
      ce1VariantsAt[p] = cls.limits;
      assigned++;
    }
    if (assigned != combo.ownCe1.length) return null;
    final ce3At = <int, BondSolvedCe>{};
    final ce3VariantsAt = <int, Map<int, bool>>{};
    for (var i = 0; i < combo.ownCe3.length; i++) {
      final cls = problem.ownCes[combo.ownCe3[i]];
      final id = combo.matchedIds[combo.ownCe1.length + i];
      ce3At[ce3Slots[i]] = BondSolvedCe(id, cls.limits[id]!);
      ce3VariantsAt[ce3Slots[i]] = cls.limits;
    }
    final supportChoiceAt = <int, _CeFirstSupportChoice>{};
    for (final (i, p) in supportSlots.indexed) {
      supportChoiceAt[p] = problem.positions[p].supportChoices[combo.supportChoices[i]];
    }
    final slots = <BondSolvedSlot>[];
    var totalCost = 0;
    for (final (p, position) in problem.positions.indexed) {
      final servant = position.fixedServant ? position.servants.single : selectedServants[p]?.servant;
      final ce1 = position.fixedCe1 ?? ce1At[p] ?? supportChoiceAt[p]?.ce;
      final ce3 = position.fixedCe3 ?? ce3At[p];
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
          bond: bond,
          cost: cost,
          servantCandidates: servant == null ? const [] : [servant.id],
          equip1Candidates: ce1 == null ? const [] : [ce1.id],
          equip3Candidates: ce3 == null ? const [] : [ce3.id],
          servantVariants: servantVariants,
          equip1Variants: position.fixedCe1 != null
              ? {ce1!.id: ce1.limitBreak}
              : ce1VariantsAt[p] ?? supportChoiceAt[p]?.candidates ?? const {},
          equip3Variants: position.fixedCe3 != null ? {ce3!.id: ce3.limitBreak} : ce3VariantsAt[p] ?? const {},
        ),
      );
    }
    final total = slots.fold<int>(0, (v, slot) => v + slot.bond);
    assert(total == fixedScore + winner.score);
    assert(totalCost == combo.ceCost + winnerCost);
    final groupKey = [
      for (final (p, position) in problem.positions.indexed)
        '${position.fixedServant ? position.servants.single.profile : selectedServants[p]?.servant.profile ?? -1}:${slots[p].bond}',
      rates.join(','),
      values.join(','),
    ].join('|');
    return _CeFirstSolution(BondSolvedTeam(total, totalCost, slots), groupKey);
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
