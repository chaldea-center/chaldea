import 'dart:convert';
import 'dart:math';

import 'package:chaldea/app/modules/bond/solver/ce_assignment.dart';
import 'package:chaldea/app/modules/bond/solver/ce_identity.dart';
import 'package:chaldea/app/modules/bond/solver/ce_source.dart';

// The same cases run in Flutter's regular suite and directly on the VM/JS.
void main() {
  var count = 0;
  registerCeAlgorithmCases((name, body) {
    body();
    count++;
  });
  print('$count CE algorithm cases passed');
}

void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void _equal(Object? actual, Object? expected) =>
    _check(jsonEncode(actual) == jsonEncode(expected), '$actual != $expected');

int _identity(int id) => id % 100;
BondCeSource _source(Iterable<int> ids, {bool repeatable = false, int cost = 0, List<int>? rates, List<int>? values}) =>
    BondCeSource(cost, rates ?? [], values ?? [], {for (final id in ids) id: false}, repeatable, identityOf: _identity);

List<int>? _bruteMatch(List<BondCeSource> sources, Set<int> fixed, List<int> selected) {
  final order = List.generate(selected.length, (i) => i)
    ..sort((a, b) => sources[selected[a]].limits.length.compareTo(sources[selected[b]].limits.length));
  final used = {...fixed}, result = List<int>.filled(selected.length, -1);
  bool visit(int depth) {
    if (depth == order.length) return true;
    final dimension = order[depth], source = sources[selected[dimension]];
    final ids = source.limits.keys.toList()..sort();
    for (final id in ids) {
      if (!source.repeatable && used.contains(_identity(id))) continue;
      result[dimension] = id;
      if (!source.repeatable) used.add(_identity(id));
      if (visit(depth + 1)) return true;
      if (!source.repeatable) used.remove(_identity(id));
    }
    return false;
  }

  return visit(0) ? result : null;
}

class _Choice implements BondAssignmentChoice {
  final int id;
  @override
  final int cost;
  @override
  final int position;
  @override
  final int score;
  final int tag;
  const _Choice(this.id, this.cost, this.position, this.score, this.tag);
}

typedef _Expected = (int, List<_Choice>);

List<_Expected?> _dense(int positions, int budget, Map<int, List<_Choice>> byId) {
  final width = budget + 1, masks = 1 << positions;
  var states = List<_Expected?>.filled(masks * width, null)..[0] = (0, <_Choice>[]);
  for (final choices in byId.values) {
    final next = List<_Expected?>.of(states);
    for (var mask = 0; mask < masks; mask++) {
      for (var cost = 0; cost < width; cost++) {
        final state = states[mask * width + cost];
        if (state == null) continue;
        for (final choice in choices) {
          if (mask & (1 << choice.position) != 0 || cost + choice.cost > budget) continue;
          final index = (mask | (1 << choice.position)) * width + cost + choice.cost;
          final score = state.$1 + choice.score;
          if (next[index] == null || score > next[index]!.$1) next[index] = (score, [...state.$2, choice]);
        }
      }
    }
    states = next;
  }
  return states;
}

List<int> _path(BondAssignmentState<_Choice> state) {
  final result = <int>[];
  for (var path = state.path; path != null; path = path.previous) {
    result.add(path.choice.tag);
  }
  return result.reversed.toList();
}

void registerCeAlgorithmCases(void Function(String, void Function()) add) {
  add('CE matching preserves exhaustive canonical witnesses and polynomial fallback', () {
    final random = Random(6143);
    for (var trial = 0; trial < 1000; trial++) {
      final sources = List.generate(
        1 + random.nextInt(5),
        (_) => _source(
          List.generate(random.nextInt(5), (_) => 1 + random.nextInt(6) + 100 * random.nextInt(2)),
          repeatable: random.nextInt(4) == 0,
        ),
      );
      final fixed = <int>{if (trial.isEven) 1 + random.nextInt(6)};
      final selected = List.generate(random.nextInt(6), (_) => random.nextInt(sources.length));
      final original = [...selected];
      final expected = _bruteMatch(sources, fixed, selected);
      for (final limit in [128, 0]) {
        _equal(matchBondCeIds(sources, fixed, selected, maxBacktrackChecks: limit), expected);
      }
      _equal(selected, original);
    }
    // Every class fits and the total union has twelve identities, but the
    // eleven overlapping classes only have ten: a proper Hall subset fails.
    final impossible = [
      for (var i = 0; i < 11; i++) _source(List.generate(10, (j) => j + 1), rates: [i]),
      _source([98, 99]),
    ];
    _equal(matchBondCeIds(impossible, {}, List.generate(12, (i) => i)), null);
    final sources = [
      _source([1, 9]),
      for (var i = 0; i < 8; i++) _source(List.generate(8, (j) => j + 1), rates: [i]),
    ];
    final selected = List.generate(9, (i) => i);
    final expected = _bruteMatch(sources, {}, selected);
    _equal(expected, [9, 1, 2, 3, 4, 5, 6, 7, 8]);
    for (final limit in [0, 128]) {
      _equal(matchBondCeIds(sources, {}, selected, maxBacktrackChecks: limit), expected);
    }
  });

  add('ordered match keys preserve length and JS integer precision', () {
    for (var classes = 0; classes <= 5; classes++) {
      final codec = BondCeMatchKey(classes, 6), seen = <Object, String>{}, selected = <int>[];
      void visit() {
        final key = codec.encode(selected), text = selected.join(',');
        _check(!seen.containsKey(key) || seen[key] == text, 'key collision');
        seen[key] = text;
        if (selected.length == 6) return;
        for (var i = 0; i < classes; i++) {
          selected.add(i);
          visit();
          selected.removeLast();
        }
      }

      visit();
    }
    final random = Random(1989);
    for (var trial = 0; trial < 1000; trial++) {
      final classes = random.nextInt(100000), slots = random.nextInt(13);
      final codec = BondCeMatchKey(classes, slots);
      var maximum = BigInt.one;
      for (var i = 0; i < slots; i++) {
        maximum = maximum * BigInt.from(classes + 1) + BigInt.from(classes);
      }
      _check(codec.packed == (maximum <= BigInt.parse('9007199254740991')), 'unsafe JS key guard');
      final selected = classes == 0 ? <int>[] : List.generate(slots, (_) => random.nextInt(classes));
      final key = codec.encode(selected);
      if (codec.packed) {
        var exact = BigInt.one;
        for (final index in selected) {
          exact = exact * BigInt.from(classes + 1) + BigInt.from(index + 1);
        }
        _equal(key.toString(), exact.toString());
      } else {
        _equal(key, selected.join(','));
      }
    }
    _check(!BondCeMatchKey(65535, 4).packed, 'large key did not use textual fallback');
  });

  add('match cache keeps canonical immutable successes, failures and bounded entries', () {
    final sources = [
      for (var id = 1; id <= 3; id++) _source([id], repeatable: true),
      _source([]),
    ];
    final cache = BondCeMatchCache(sources, {}, maxSlots: 8);
    _equal(cache.match([3]), null);
    _equal(cache.length, 1);
    _equal(cache.match([3]), null);
    _equal(cache.length, 1);
    final first = cache.match([0])!;
    var immutable = false;
    try {
      first[0] = 99;
    } on UnsupportedError {
      immutable = true;
    }
    _check(immutable, 'cached witness is mutable');
    for (var i = 0; i < 5000; i++) {
      var digits = i;
      final selected = List.generate(8, (_) {
        final digit = digits % 3;
        digits ~/= 3;
        return digit;
      });
      _equal(cache.match(selected), selected.map((index) => index + 1).toList());
    }
    _equal(cache.length, 4096);
    _check(identical(first, cache.match([0])), 'full cache evicted an earlier witness');
    _equal(
      BondCeMatchCache(
        [
          _source([1, 101]),
        ],
        {1},
        maxSlots: 2,
      ).match([0]),
      null,
    );
    final textual = BondCeMatchCache(
      [
        for (var id = 1; id <= 30; id++) _source([id]),
      ],
      {},
      maxSlots: 12,
    );
    _check(!textual.keys.packed, 'fixture did not use textual keys');
    _equal(textual.match([0, 1]), [1, 2]);
    _equal(textual.match([1, 0]), [2, 1]);
    _equal(textual.match([0, 0]), null);
  });

  add('assignment DP matches every dense cell/path and independent ID enumeration', () {
    final random = Random(7823);
    final budgets = [0, 1, 30, 31, 32, 61, 62, 63, 92, 93, 94, 127, 128, 255];
    for (final cost in budgets) {
      late List<BondAssignmentState<_Choice>?> table;
      final width = cost * 2 + 1;
      for (final _ in bondAssignmentSteps(
        positions: 2,
        budget: cost * 2,
        byId: {
          1: [_Choice(1, cost, 0, 2, 0)],
          2: [_Choice(2, cost, 1, 3, 1)],
        },
        onComplete: (states) => table = states,
      )) {}
      _equal(table[width + cost]?.score, 2);
      _equal(table[2 * width + cost]?.score, 3);
      _equal(table[3 * width + cost * 2]?.score, 5);
    }
    late List<BondAssignmentState<_Choice>?> empty;
    for (final _ in bondAssignmentSteps<_Choice>(
      positions: 0,
      budget: 0,
      byId: {},
      onComplete: (table) => empty = table,
    )) {}
    _equal(empty.length, 1);
    _equal(empty.single?.score, 0);
    for (var trial = 0; trial < 350; trial++) {
      final positions = 1 + random.nextInt(3), budget = trial < budgets.length ? budgets[trial] : random.nextInt(12);
      var tag = 0;
      final byId = <int, List<_Choice>>{
        for (var id = 1; id <= 5; id++)
          id: List.generate(
            1 + random.nextInt(3),
            (_) => _Choice(id, random.nextInt(budget + 1), random.nextInt(positions), random.nextInt(12) - 4, tag++),
          ),
      };
      late List<BondAssignmentState<_Choice>?> actual;
      for (final _ in bondAssignmentSteps(
        positions: positions,
        budget: budget,
        byId: byId,
        onComplete: (states) => actual = states,
      )) {}
      final expected = _dense(positions, budget, byId);
      for (var index = 0; index < actual.length; index++) {
        _equal(actual[index]?.score, expected[index]?.$1);
        if (actual[index] != null) {
          _equal(_path(actual[index]!), expected[index]!.$2.map((choice) => choice.tag).toList());
        }
      }
      final exhaustive = <int, int>{};
      final ids = byId.keys.toList();
      void visit(int depth, int mask, int cost, int score) {
        if (depth == ids.length) {
          final index = mask * (budget + 1) + cost;
          exhaustive[index] = max(exhaustive[index] ?? score, score);
          return;
        }
        visit(depth + 1, mask, cost, score);
        for (final choice in byId[ids[depth]]!) {
          if (mask & (1 << choice.position) != 0 || cost + choice.cost > budget) continue;
          visit(depth + 1, mask | (1 << choice.position), cost + choice.cost, score + choice.score);
        }
      }

      visit(0, 0, 0, 0);
      for (var index = 0; index < actual.length; index++) {
        _equal(actual[index]?.score, exhaustive[index]);
      }
    }
    late List<BondAssignmentState<_Choice>?> zero;
    for (final _ in bondAssignmentSteps(
      positions: 2,
      budget: 0,
      byId: {
        1: [const _Choice(1, 0, 0, 10, 0), const _Choice(1, 0, 1, 10, 1)],
      },
      onComplete: (table) => zero = table,
    )) {}
    _equal(zero[3], null);
  });

  add('unfinished assignment work cannot publish a partial table', () {
    var published = false;
    final work = bondAssignmentSteps(
      positions: 6,
      budget: 100,
      byId: {for (var id = 0; id < 100; id++) id: List.generate(6, (p) => _Choice(id, 0, p, 1, id * 6 + p))},
      onComplete: (_) => published = true,
    );
    _check(work.iterator.moveNext(), 'fixture did not yield');
    _check(!published, 'partial assignment published');
  });

  add('assignment cache separates every exact input and stores immutable bounded results', () {
    final cache = BondAssignmentCache<int>();
    final key = cache.key([1, 23], [4], 5, 1);
    final variants = [
      cache.key([12, 3], [4], 5, 1),
      cache.key([1, 23], [5], 5, 1),
      cache.key([1, 23], [4], 6, 1),
      cache.key([1, 23], [4], 5, 2),
    ];
    _check(!variants.contains(key) && variants.toSet().length == variants.length, 'assignment inputs merged');
    _equal(cache[key], null);
    cache.remember(key, null);
    _check(cache[key] != null && cache[key]!.servants == null, 'infeasibility is a cache miss');
    final input = {0: 7};
    cache.remember('success', input);
    input[0] = 8;
    _equal(cache['success']!.servants![0], 7);
    var immutable = false;
    try {
      cache['success']!.servants![0] = 9;
    } on UnsupportedError {
      immutable = true;
    }
    _check(immutable, 'assignment result is mutable');
    for (var i = 0; i < 600; i++) {
      cache.remember('entry$i', {0: i});
    }
    _equal(cache.length, 512);
    _equal(cache['entry599'], null);
    _check(cache[key] != null, 'old infeasible entry lost');
  });

  add('source bound dominates all legal shared-capacity and COST completions', () {
    final random = Random(9981);
    var completions = 0;
    for (var trial = 0; trial < 1000; trial++) {
      final profiles = 1 + random.nextInt(3), count = random.nextInt(5), budget = random.nextInt(6);
      final sources = List.generate(
        count,
        (i) => _source(
          List.generate(1 + random.nextInt(2), (j) => i * 3 + j + 1),
          cost: random.nextInt(5),
          repeatable: random.nextInt(4) == 0,
          rates: List.generate(profiles, (_) => random.nextInt(9) * 100 - 200),
          values: List.generate(profiles, (_) => random.nextInt(13) - 3),
        ),
      );
      final order = List.generate(count, (i) => i)..shuffle(random);
      final counts = [for (final ce in sources) random.nextInt(ce.identityCapacity + 1)];
      final original = [...counts], first = random.nextInt(3), third = random.nextInt(3);
      final start1 = random.nextInt(count + 1), start3 = random.nextInt(count + 1);
      final bound = BondCeSourceBound(sources, order, profiles);
      final upperRates = [
        for (var r = 0; r < profiles; r++)
          bound.contribution(r, first, start1, counts, value: false, costLeft: budget) +
              bound.contribution(r, third, start3, counts, value: false),
      ];
      final upperValues = [
        for (var r = 0; r < profiles; r++)
          bound.contribution(r, first, start1, counts, value: true, costLeft: budget) +
              bound.contribution(r, third, start3, counts, value: true),
      ];
      final rates = List.filled(profiles, 0), values = List.filled(profiles, 0);
      void change(int index, int sign) {
        counts[index] += sign;
        for (var r = 0; r < profiles; r++) {
          rates[r] += sign * sources[index].rates[r];
          values[r] += sign * sources[index].values[r];
        }
      }

      void verify() {
        completions++;
        for (var r = 0; r < profiles; r++) {
          _check(upperRates[r] >= rates[r] && upperValues[r] >= values[r], 'underestimated source completion');
          final firstBond = trial % 2001, cap = [0, 500, 2000][trial % 3];
          int score(int rate, int value) => (firstBond * (1 + min(cap, rate) / 1000)).floor() + value;
          _check(
            score(upperRates[r], upperValues[r]) >= score(rates[r], values[r]),
            'underestimated capped/floored score',
          );
        }
      }

      void equip3(int left, int start) {
        verify();
        if (left == 0) return;
        for (var j = start; j < order.length; j++) {
          final i = order[j];
          if (!sources[i].canAdd(counts[i])) continue;
          change(i, 1);
          equip3(left - 1, j);
          change(i, -1);
        }
      }

      void equip1(int left, int start, int costLeft) {
        equip3(third, start3);
        if (left == 0) return;
        for (var j = start; j < order.length; j++) {
          final i = order[j], ce = sources[i];
          if (!ce.canAdd(counts[i]) || ce.cost > costLeft) continue;
          change(i, 1);
          equip1(left - 1, j, costLeft - ce.cost);
          change(i, -1);
        }
      }

      equip1(first, start1, budget);
      _equal(counts, original);
    }
    _check(completions > 1000, 'bound fixture did not explore nonempty completions');
  });
}
