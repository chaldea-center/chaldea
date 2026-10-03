import 'dart:math' as math;

/// One effect-equivalent choice for a formation position.
///
/// The caller has already resolved quest, wearer, target, event, and CE rules.
/// Team effects are indexed by receiver profile. Identity sets contain the
/// concrete members represented by this choice; owned CE dimensions are
/// matched independently, even when both use the same CE class.
class BondSearchItem {
  final int cost;
  final int? receiverProfile;
  final int selfRate;
  final int selfValue;
  final List<int> teamRates;
  final List<int> teamValues;
  final Set<int> servantIds;
  final List<Set<int>> ownedCeIds;
  final int? servantClassIndex;
  final List<int> ownedCeClassIndices;
  final int? wornCeCount;

  /// Stable order within a set of equivalent formation positions.
  final int symmetryOrder;

  /// Opaque caller value used to expand this item into a concrete team.
  final Object? payload;

  const BondSearchItem({
    required this.cost,
    required this.receiverProfile,
    required this.selfRate,
    required this.selfValue,
    required this.teamRates,
    required this.teamValues,
    this.servantIds = const {},
    this.ownedCeIds = const [],
    this.servantClassIndex,
    this.ownedCeClassIndices = const [],
    this.wornCeCount,
    this.symmetryOrder = 0,
    this.payload,
  });

  int get wearCount => wornCeCount ?? ownedCeIds.length;
}

class BondSearchPosition {
  final int frontlineRate;
  final List<BondSearchItem> items;

  /// Positions with the same non-null key must be interchangeable, including
  /// their items, fixed dimensions, custom bonuses, and frontline rate.
  final int? symmetryGroup;

  const BondSearchPosition({required this.frontlineRate, required this.items, this.symmetryGroup});
}

class BondSearchProblem {
  final int baseBond;
  final int rateCap;
  final int maxCost;
  final int receiverProfileCount;
  final List<BondSearchPosition> positions;
  final List<int> servantClassCapacities;
  final List<int> ownedCeClassCapacities;
  final Map<int, int> ownedCeIdentities;

  const BondSearchProblem({
    required this.baseBond,
    required this.rateCap,
    required this.maxCost,
    required this.receiverProfileCount,
    required this.positions,
    this.servantClassCapacities = const [],
    this.ownedCeClassCapacities = const [],
    this.ownedCeIdentities = const {},
  });
}

class BondSearchWitness {
  final int totalBond;
  final int totalCost;
  final List<int> slotBonds;
  final List<BondSearchItem> items;
  final List<int?> servantIds;
  final List<List<int>> ownedCeIds;

  const BondSearchWitness({
    required this.totalBond,
    required this.totalCost,
    required this.slotBonds,
    required this.items,
    required this.servantIds,
    required this.ownedCeIds,
  });
}

class BondSearchResult {
  final BondSearchWitness? best;
  final List<BondSearchWitness> ties;
  final List<BondSearchWitness> candidates;
  final List<int> tieGroupCounts;
  final bool provenOptimal;
  final bool allTiesCollected;
  final int visitedNodes;

  const BondSearchResult({
    required this.best,
    required this.ties,
    this.candidates = const [],
    required this.tieGroupCounts,
    required this.provenOptimal,
    required this.allTiesCollected,
    required this.visitedNodes,
  });
}

/// Exact search over preprocessed bond choices.
///
/// The cost DP and per-source maxima deliberately relax identity and capacity
/// constraints. Their score can overestimate, but can never underestimate, a
/// feasible completion. A concrete identity matching is required before any
/// leaf can become the incumbent.
class BondSearch {
  BondSearch._(this.problem, this.maxNodes, this.maxTies, this.maxCandidates);

  final BondSearchProblem problem;
  final int? maxNodes;
  final int maxTies;
  final int maxCandidates;

  late final List<int> _firstValues;
  late final List<List<int>> _maxSourceRates;
  late final List<List<int>> _maxSourceValues;
  late final List<List<List<int>>> _sourceRateMaxByGroup;
  late final List<List<List<int>>> _sourceValueMaxByGroup;
  late final List<List<List<int>>> _sourceRateGroupOrder;
  late final List<List<List<int>>> _sourceValueGroupOrder;
  late final List<List<BondSearchItem>> _orderedItems;
  late final List<List<BondSearchItem>> _seedOrderedItems;
  late final List<List<int>> _dp;
  late final int _dpMaxBudget;
  late final List<BondSearchItem?> _chosen;
  late final List<int> _servantClassUsed;
  late final List<int> _ownedCeClassUsed;
  late final List<BondSearchWitness> _ties;
  late final List<BondSearchWitness> _candidates;
  final Set<String> _candidateKeys = {};
  late final List<int> _tieGroupCounts;
  final Map<String, int> _tieIndexByKey = {};
  BondSearchWitness? _best;
  bool _interrupted = false;
  bool _tiesTruncated = false;
  bool _collectTies = false;
  bool _collectCandidates = false;
  bool _scoreProven = false;
  int _visitedOffset = 0;
  int? _nodeLimit;
  int _visitedNodes = 0;
  int _seedVisited = 0;
  void Function(BondSearchResult)? _onProgress;
  final Stopwatch _progressClock = Stopwatch();
  int _lastProgressMs = -250;

  static BondSearchResult solve(
    BondSearchProblem problem, {
    int? maxNodes,
    int maxTies = 20,
    int maxTieNodes = 100000,
    int maxCandidates = 100,
    int maxCandidateNodes = 100000,
    void Function(BondSearchResult)? onProgress,
  }) {
    if (maxNodes != null && maxNodes < 0) throw ArgumentError.value(maxNodes, 'maxNodes');
    if (maxTies < 1) throw ArgumentError.value(maxTies, 'maxTies');
    if (maxTieNodes < 0) throw ArgumentError.value(maxTieNodes, 'maxTieNodes');
    if (maxCandidates < 1) throw ArgumentError.value(maxCandidates, 'maxCandidates');
    if (maxCandidateNodes < 0) throw ArgumentError.value(maxCandidateNodes, 'maxCandidateNodes');
    final search = BondSearch._(problem, maxNodes, maxTies, maxCandidates);
    search._onProgress = onProgress;
    search._progressClock.start();
    search._prepare();
    if (search._dp[0][search._dpMaxBudget] != -0x3fffffffffffffff) {
      search._seedFeasible(0, 0);
    }
    if (search._best != null) search._improveSeed();
    search._reportProgress();
    search._nodeLimit = maxNodes;
    search._visit(0, 0);
    final provenOptimal = !search._interrupted;
    search._scoreProven = provenOptimal;
    final primaryNodes = search._visitedNodes;
    var tieNodes = 0;
    if (provenOptimal && search._best != null) {
      search._reportProgress(provenOptimal: true);
      search
        .._collectTies = true
        .._nodeLimit = maxTieNodes
        .._visitedOffset = primaryNodes
        .._visitedNodes = 0;
      search._visit(0, 0);
      tieNodes = search._visitedNodes;
    }
    final allTiesCollected = provenOptimal && !search._interrupted && !search._tiesTruncated;
    if (provenOptimal && search._best != null && maxCandidateNodes > 0) {
      search
        .._collectTies = false
        .._collectCandidates = true
        .._interrupted = false
        .._nodeLimit = maxCandidateNodes
        .._visitedOffset = primaryNodes + tieNodes
        .._visitedNodes = 0;
      search._visit(0, 0);
    }
    return BondSearchResult(
      best: search._best,
      ties: List.unmodifiable(search._ties),
      candidates: List.unmodifiable(search._candidates),
      tieGroupCounts: List.unmodifiable(search._tieGroupCounts),
      provenOptimal: provenOptimal,
      allTiesCollected: allTiesCollected,
      visitedNodes: search._visitedOffset + search._visitedNodes,
    );
  }

  void _reportProgress({bool provenOptimal = false}) {
    if (_onProgress == null) return;
    _lastProgressMs = _progressClock.elapsedMilliseconds;
    _onProgress!(
      BondSearchResult(
        best: _best,
        ties: List.unmodifiable(_ties),
        candidates: List.unmodifiable(_candidates),
        tieGroupCounts: List.unmodifiable(_tieGroupCounts),
        provenOptimal: provenOptimal || _scoreProven,
        allTiesCollected: false,
        visitedNodes: _visitedOffset + _visitedNodes,
      ),
    );
  }

  bool _seedFeasible(int p, int spent) {
    if (_seedVisited++ >= 20000) return false;
    if (p == problem.positions.length) {
      _acceptLeaf(spent);
      return _best != null;
    }
    for (final item in _seedOrderedItems[p]) {
      if (spent + item.cost > problem.maxCost || !_capacityAvailable(item)) continue;
      _chosen[p] = item;
      _changeCapacity(item, 1);
      final feasible = _selectedIdsMatch(p + 1) && _seedFeasible(p + 1, spent + item.cost);
      _changeCapacity(item, -1);
      _chosen[p] = null;
      if (feasible) return true;
    }
    return false;
  }

  void _improveSeed() {
    for (var pass = 0; pass < 2; pass++) {
      var improved = false;
      for (var p = 0; p < problem.positions.length; p++) {
        final base = _best!;
        _chosen.setAll(0, base.items);
        for (final item in base.items) {
          _changeCapacity(item, 1);
        }
        final old = base.items[p];
        _changeCapacity(old, -1);
        for (final item in _orderedItems[p]) {
          final cost = base.totalCost - old.cost + item.cost;
          if (cost > problem.maxCost || !_capacityAvailable(item)) continue;
          _chosen[p] = item;
          _changeCapacity(item, 1);
          _acceptLeaf(cost);
          _changeCapacity(item, -1);
        }
        _chosen[p] = old;
        _changeCapacity(old, 1);
        for (final item in base.items) {
          _changeCapacity(item, -1);
        }
        _chosen.fillRange(0, _chosen.length, null);
        if (_best!.totalBond > base.totalBond || _prefer(_best!, base)) improved = true;
      }
      if (!improved) break;
    }
  }

  bool _selectedIdsMatch(int count) {
    final servantDimensions = <_IdentityDimension>[];
    final ceDimensions = <_IdentityDimension>[];
    for (var p = 0; p < count; p++) {
      final item = _chosen[p]!;
      if (item.servantIds.isNotEmpty) servantDimensions.add(_IdentityDimension(p, -1, item.servantIds));
      for (final (d, ids) in item.ownedCeIds.indexed) {
        ceDimensions.add(_IdentityDimension(p, d, ids));
      }
    }
    return _match(servantDimensions) != null && _match(ceDimensions, ce: true) != null;
  }

  void _prepare() {
    final n = problem.positions.length;
    final profiles = problem.receiverProfileCount;
    if (n > 6 || profiles < 0 || problem.baseBond < 0 || problem.maxCost < 0) {
      throw ArgumentError('invalid bond search dimensions');
    }
    _ties = [];
    _candidates = [];
    _tieGroupCounts = [];
    _chosen = List.filled(n, null);
    _servantClassUsed = List<int>.filled(problem.servantClassCapacities.length, 0);
    _ownedCeClassUsed = List<int>.filled(problem.ownedCeClassCapacities.length, 0);
    _firstValues = [
      for (final position in problem.positions) (problem.baseBond * (1 + position.frontlineRate / 1000)).floor(),
    ];
    _maxSourceRates = List.generate(n, (_) => List<int>.filled(profiles, 0));
    _maxSourceValues = List.generate(n, (_) => List<int>.filled(profiles, 0));
    for (final (p, position) in problem.positions.indexed) {
      for (final item in position.items) {
        if (item.cost < 0 || item.teamRates.length != profiles || item.teamValues.length != profiles) {
          throw ArgumentError('invalid item at position $p');
        }
        if (item.receiverProfile != null && (item.receiverProfile! < 0 || item.receiverProfile! >= profiles)) {
          throw ArgumentError('invalid receiver profile at position $p');
        }
        final si = item.servantClassIndex;
        if (si != null && (si < 0 || si >= _servantClassUsed.length)) {
          throw ArgumentError('invalid servant class at position $p');
        }
        for (final ci in item.ownedCeClassIndices) {
          if (ci < 0 || ci >= _ownedCeClassUsed.length) {
            throw ArgumentError('invalid CE class at position $p');
          }
        }
        for (var r = 0; r < profiles; r++) {
          _maxSourceRates[p][r] = math.max(_maxSourceRates[p][r], item.teamRates[r]);
          _maxSourceValues[p][r] = math.max(_maxSourceValues[p][r], item.teamValues[r]);
        }
      }
    }
    _buildCapacitySourceBounds(n, profiles);

    final optimistic = List.generate(n, (_) => <BondSearchItem, int>{});
    _orderedItems = [];
    _seedOrderedItems = [];
    for (var p = 0; p < n; p++) {
      final list = List<BondSearchItem>.of(problem.positions[p].items);
      _seedOrderedItems.add(
        List<BondSearchItem>.of(list)..sort((a, b) {
          final cost = a.cost.compareTo(b.cost);
          if (cost != 0) return cost;
          final worn = a.wearCount.compareTo(b.wearCount);
          if (worn != 0) return worn;
          return (a.receiverProfile == null ? 0 : 1).compareTo(b.receiverProfile == null ? 0 : 1);
        }),
      );
      for (final item in list) {
        final profile = item.receiverProfile;
        if (profile == null) {
          optimistic[p][item] = 0;
          continue;
        }
        var rate = item.selfRate + item.teamRates[profile];
        var value = item.selfValue + item.teamValues[profile];
        for (var q = 0; q < n; q++) {
          if (q == p) continue;
          rate += _maxSourceRates[q][profile];
          value += _maxSourceValues[q][profile];
        }
        optimistic[p][item] = _upperSlot(_firstValues[p], rate, value);
      }
      list.sort((a, b) {
        final c = optimistic[p][b]!.compareTo(optimistic[p][a]!);
        return c != 0 ? c : a.cost.compareTo(b.cost);
      });
      _orderedItems.add(list);
    }

    // MCKP relaxation: every position selects one item; shared IDs are ignored.
    final maxSelectableCost = problem.positions.fold<int>(
      0,
      (sum, position) => sum + position.items.fold<int>(0, (maxCost, item) => math.max(maxCost, item.cost)),
    );
    final budget = _dpMaxBudget = math.min(problem.maxCost, maxSelectableCost);
    const impossible = -0x3fffffffffffffff;
    _dp = List.generate(n + 1, (_) => List<int>.filled(budget + 1, impossible));
    for (var b = 0; b <= budget; b++) {
      _dp[n][b] = 0;
    }
    for (var p = n - 1; p >= 0; p--) {
      for (var b = 0; b <= budget; b++) {
        var best = impossible;
        for (final item in _orderedItems[p]) {
          if (item.cost > b) continue;
          final tail = _dp[p + 1][b - item.cost];
          if (tail == impossible) continue;
          best = math.max(best, optimistic[p][item]! + tail);
        }
        _dp[p][b] = best;
      }
    }
  }

  void _buildCapacitySourceBounds(int n, int profiles) {
    final groups = problem.ownedCeClassCapacities.length + 1;
    _sourceRateMaxByGroup = List.generate(n + 1, (_) => List.generate(profiles, (_) => List<int>.filled(groups, 0)));
    _sourceValueMaxByGroup = List.generate(n + 1, (_) => List.generate(profiles, (_) => List<int>.filled(groups, 0)));
    for (var p = n - 1; p >= 0; p--) {
      for (var r = 0; r < profiles; r++) {
        final rates = _sourceRateMaxByGroup[p][r];
        final values = _sourceValueMaxByGroup[p][r];
        rates.setAll(0, _sourceRateMaxByGroup[p + 1][r]);
        values.setAll(0, _sourceValueMaxByGroup[p + 1][r]);
        for (final item in problem.positions[p].items) {
          final group = item.ownedCeClassIndices.isEmpty ? 0 : item.ownedCeClassIndices.first + 1;
          rates[group] = math.max(rates[group], item.teamRates[r]);
          values[group] = math.max(values[group], item.teamValues[r]);
        }
      }
    }
    _sourceRateGroupOrder = List.generate(
      n + 1,
      (p) => List.generate(profiles, (r) {
        return List<int>.generate(groups, (g) => g)
          ..sort((a, b) => _sourceRateMaxByGroup[p][r][b].compareTo(_sourceRateMaxByGroup[p][r][a]));
      }),
    );
    _sourceValueGroupOrder = List.generate(
      n + 1,
      (p) => List.generate(profiles, (r) {
        return List<int>.generate(groups, (g) => g)
          ..sort((a, b) => _sourceValueMaxByGroup[p][r][b].compareTo(_sourceValueMaxByGroup[p][r][a]));
      }),
    );
  }

  int _capacitySourceBound(int suffix, int profile, {required bool rate}) {
    var slotsLeft = problem.positions.length - suffix;
    if (slotsLeft <= 0) return 0;
    final maxima = rate ? _sourceRateMaxByGroup[suffix][profile] : _sourceValueMaxByGroup[suffix][profile];
    final order = rate ? _sourceRateGroupOrder[suffix][profile] : _sourceValueGroupOrder[suffix][profile];
    var total = 0;
    for (final group in order) {
      if (slotsLeft == 0) break;
      final capacity = group == 0
          ? slotsLeft
          : math.max(0, problem.ownedCeClassCapacities[group - 1] - _ownedCeClassUsed[group - 1]);
      final copies = math.min(slotsLeft, capacity);
      total += copies * maxima[group];
      slotsLeft -= copies;
    }
    return total;
  }

  void _visit(int p, int spent) {
    if (_interrupted) return;
    if (_nodeLimit != null && _visitedNodes >= _nodeLimit!) {
      _interrupted = true;
      return;
    }
    _visitedNodes++;
    if (_onProgress != null && !_collectTies && _visitedNodes % 16384 == 0) {
      if (_progressClock.elapsedMilliseconds - _lastProgressMs >= 250) _reportProgress();
    }
    if (p == problem.positions.length) {
      _acceptLeaf(spent);
      return;
    }
    final remaining = problem.maxCost - spent;
    final budgetIndex = math.min(remaining, _dpMaxBudget);
    if (_dp[p][budgetIndex] == -0x3fffffffffffffff) return;
    final upper = _assignedUpper(p) + _dp[p][budgetIndex];
    if (_collectCandidates) {
      if (_candidates.length >= maxCandidates && upper < _candidates.last.totalBond) return;
    } else if (_best != null && (_collectTies ? upper < _best!.totalBond : upper <= _best!.totalBond)) {
      return;
    }
    final group = problem.positions[p].symmetryGroup;
    for (final item in _orderedItems[p]) {
      if (item.cost > remaining) continue;
      if (!_capacityAvailable(item)) continue;
      if (group != null) {
        var previousOrder = -1;
        for (var q = 0; q < p; q++) {
          if (problem.positions[q].symmetryGroup == group) {
            previousOrder = _chosen[q]!.symmetryOrder;
          }
        }
        if (item.symmetryOrder < previousOrder) continue;
      }
      _chosen[p] = item;
      _changeCapacity(item, 1);
      _visit(p + 1, spent + item.cost);
      _changeCapacity(item, -1);
      _chosen[p] = null;
      if (_interrupted) return;
    }
  }

  bool _capacityAvailable(BondSearchItem item) {
    final si = item.servantClassIndex;
    if (si != null && _servantClassUsed[si] >= problem.servantClassCapacities[si]) return false;
    final needed = <int, int>{};
    for (final ci in item.ownedCeClassIndices) {
      needed[ci] = (needed[ci] ?? 0) + 1;
    }
    for (final entry in needed.entries) {
      if (_ownedCeClassUsed[entry.key] + entry.value > problem.ownedCeClassCapacities[entry.key]) return false;
    }
    return true;
  }

  void _changeCapacity(BondSearchItem item, int delta) {
    final si = item.servantClassIndex;
    if (si != null) _servantClassUsed[si] += delta;
    for (final ci in item.ownedCeClassIndices) {
      _ownedCeClassUsed[ci] += delta;
    }
  }

  int _assignedUpper(int count) {
    var total = 0;
    final futureRateByProfile = <int, int>{};
    final futureValueByProfile = <int, int>{};
    for (var p = 0; p < count; p++) {
      final item = _chosen[p]!;
      final profile = item.receiverProfile;
      if (profile == null) continue;
      var rate = item.selfRate;
      var value = item.selfValue;
      for (var q = 0; q < count; q++) {
        rate += _chosen[q]!.teamRates[profile];
        value += _chosen[q]!.teamValues[profile];
      }
      rate += futureRateByProfile.putIfAbsent(profile, () {
        var perPosition = 0;
        for (var q = count; q < problem.positions.length; q++) {
          perPosition += _maxSourceRates[q][profile];
        }
        return math.min(perPosition, _capacitySourceBound(count, profile, rate: true));
      });
      value += futureValueByProfile.putIfAbsent(profile, () {
        var perPosition = 0;
        for (var q = count; q < problem.positions.length; q++) {
          perPosition += _maxSourceValues[q][profile];
        }
        return math.min(perPosition, _capacitySourceBound(count, profile, rate: false));
      });
      total += _upperSlot(_firstValues[p], rate, value);
    }
    return total;
  }

  int _upperSlot(int first, int rate, int value) {
    final numerator = first * (1000 + math.min(rate, problem.rateCap));
    final ceil = numerator >= 0 ? (numerator + 999) ~/ 1000 : numerator ~/ 1000;
    return ceil + value;
  }

  void _acceptLeaf(int spent) {
    final items = [for (final item in _chosen) item!];
    final servantDimensions = <_IdentityDimension>[];
    final ceDimensions = <_IdentityDimension>[];
    for (final (p, item) in items.indexed) {
      if (item.servantIds.isNotEmpty) servantDimensions.add(_IdentityDimension(p, -1, item.servantIds));
      for (final (d, ids) in item.ownedCeIds.indexed) {
        ceDimensions.add(_IdentityDimension(p, d, ids));
      }
    }
    final servants = _match(servantDimensions);
    if (servants == null) return;
    final ces = _match(ceDimensions, ce: true);
    if (ces == null) return;

    var total = 0;
    final slotBonds = List<int>.filled(items.length, 0);
    for (final (p, item) in items.indexed) {
      final profile = item.receiverProfile;
      if (profile == null) continue;
      var rate = item.selfRate;
      var value = item.selfValue;
      for (final source in items) {
        rate += source.teamRates[profile];
        value += source.teamValues[profile];
      }
      var bond = (_firstValues[p] * (1 + math.min(rate, problem.rateCap) / 1000)).floor();
      bond += value;
      slotBonds[p] = bond;
      total += bond;
    }
    final servantIds = List<int?>.filled(items.length, null);
    final ownedCeIds = List.generate(items.length, (_) => <int>[]);
    for (final entry in servants.entries) {
      servantIds[entry.key.position] = entry.value;
    }
    for (final entry in ces.entries) {
      final result = ownedCeIds[entry.key.position];
      while (result.length <= entry.key.index) {
        result.add(-1);
      }
      result[entry.key.index] = entry.value;
    }
    final witness = BondSearchWitness(
      totalBond: total,
      totalCost: spent,
      slotBonds: List.unmodifiable(slotBonds),
      items: List.unmodifiable(items),
      servantIds: List.unmodifiable(servantIds),
      ownedCeIds: [for (final ids in ownedCeIds) List<int>.unmodifiable(ids)],
    );
    _recordCandidate(witness);
    if (_best != null && total < _best!.totalBond) return;
    if (_best == null || total > _best!.totalBond) {
      _best = witness;
      _ties.clear();
      _tieGroupCounts.clear();
      _tieIndexByKey.clear();
      _tiesTruncated = false;
    } else if (total == _best!.totalBond && _prefer(witness, _best!)) {
      _best = witness;
    }
    if (!_collectTies) return;
    final key = [for (final (p, item) in items.indexed) '${item.receiverProfile ?? -1}:${slotBonds[p]}'].join('|');
    final existing = _tieIndexByKey[key];
    if (existing != null) {
      if (existing >= 0) {
        _tieGroupCounts[existing]++;
        if (_prefer(witness, _ties[existing])) _ties[existing] = witness;
      }
      return;
    }
    if (_ties.length >= maxTies) {
      _tiesTruncated = true;
      _tieIndexByKey[key] = -1;
      _interrupted = true;
      return;
    }
    _tieIndexByKey[key] = _ties.length;
    _ties.add(witness);
    _tieGroupCounts.add(1);
  }

  String _candidateKey(BondSearchWitness witness) => [
    for (final (p, item) in witness.items.indexed)
      '${item.symmetryOrder}:${witness.servantIds[p]}:${witness.ownedCeIds[p].join(',')}',
  ].join('|');

  int _compareCandidates(BondSearchWitness a, BondSearchWitness b) {
    final score = b.totalBond.compareTo(a.totalBond);
    if (score != 0) return score;
    final cost = b.totalCost.compareTo(a.totalCost);
    return cost != 0
        ? cost
        : a.items
              .fold<int>(0, (sum, item) => sum + item.wearCount)
              .compareTo(b.items.fold<int>(0, (sum, item) => sum + item.wearCount));
  }

  void _recordCandidate(BondSearchWitness witness) {
    if (_candidates.length >= maxCandidates && _compareCandidates(witness, _candidates.last) >= 0) return;
    final key = _candidateKey(witness);
    if (!_candidateKeys.add(key)) return;
    var index = 0;
    while (index < _candidates.length && _compareCandidates(_candidates[index], witness) <= 0) {
      index++;
    }
    _candidates.insert(index, witness);
    if (_candidates.length > maxCandidates) {
      _candidateKeys.remove(_candidateKey(_candidates.removeLast()));
    }
  }

  bool _prefer(BondSearchWitness a, BondSearchWitness b) {
    if (a.totalCost != b.totalCost) return a.totalCost > b.totalCost;
    final wearsA = a.items.fold<int>(0, (sum, item) => sum + item.wearCount);
    final wearsB = b.items.fold<int>(0, (sum, item) => sum + item.wearCount);
    return wearsA < wearsB;
  }

  /// Small bipartite matching. The number of dimensions is bounded by six
  /// servants and the finite owned CE slots, so augmenting paths are cheap.
  Map<_IdentityDimension, int>? _match(List<_IdentityDimension> dimensions, {bool ce = false}) {
    final byId = <int, _IdentityDimension>{};
    final concrete = <_IdentityDimension, int>{};
    bool augment(_IdentityDimension dimension, Set<int> seen) {
      for (final id in dimension.ids) {
        final identity = ce ? problem.ownedCeIdentities[id] ?? id : id;
        if (!seen.add(identity)) continue;
        final previous = byId[identity];
        if (previous == null || augment(previous, seen)) {
          byId[identity] = dimension;
          concrete[dimension] = id;
          return true;
        }
      }
      return false;
    }

    final sorted = List<_IdentityDimension>.of(dimensions)..sort((a, b) => a.ids.length.compareTo(b.ids.length));
    for (final dimension in sorted) {
      if (!augment(dimension, <int>{})) return null;
    }
    return concrete;
  }
}

class _IdentityDimension {
  final int position;
  final int index;
  final Set<int> ids;

  const _IdentityDimension(this.position, this.index, this.ids);
}
