import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/modules/bond/solver/search.dart';

void main() {
  test('owned Grand count is enforced in seeds, optimum and candidates', () {
    for (int cap = 0; cap <= 3; cap++) {
      final problem = BondSearchProblem(
        baseBond: 100,
        rateCap: 5000,
        maxCost: 0,
        maxGrandServants: cap,
        receiverProfileCount: 1,
        positions: [
          for (int p = 0; p < 3; p++)
            BondSearchPosition(
              frontlineRate: 0,
              items: [
                for (final grand in [false, true])
                  BondSearchItem(
                    cost: 0,
                    receiverProfile: 0,
                    selfRate: 0,
                    selfValue: grand ? (3 - p) * 10 : 0,
                    teamRates: const [0],
                    teamValues: const [0],
                    isGrandServant: grand,
                  ),
              ],
            ),
        ],
      );
      final result = BondSearch.solve(problem);
      expect(result.provenOptimal, isTrue);
      expect(result.best!.totalBond, 300 + [0, 30, 50, 60][cap]);
      for (final team in [result.best!, ...result.candidates, ...result.ties]) {
        expect(team.items.where((item) => item.isGrandServant).length, lessThanOrEqualTo(cap));
      }
    }
  });

  test('CE capacity checks preserve multiplicity and restore sibling capacity', () {
    for (final indices in <List<int>>[
      [],
      [0],
      [0, 0],
      [0, 1],
      [0, 0, 0],
      [0, 1, 0, 1],
    ]) {
      for (var capacity = 0; capacity <= 4; capacity++) {
        final problem = BondSearchProblem(
          baseBond: 100,
          rateCap: 5000,
          maxCost: 0,
          receiverProfileCount: 1,
          ownedCeClassCapacities: [capacity, capacity],
          positions: [
            for (var p = 0; p < 2; p++)
              BondSearchPosition(
                frontlineRate: 0,
                items: [
                  BondSearchItem(
                    cost: 0,
                    receiverProfile: 0,
                    selfRate: 0,
                    selfValue: 100,
                    teamRates: const [0],
                    teamValues: const [0],
                    servantIds: {p + 1},
                    ownedCeIds: [
                      for (var d = 0; d < indices.length; d++) {10 + 4 * p + d},
                    ],
                    ownedCeClassIndices: indices,
                  ),
                  _item(p + 1, 0),
                ],
              ),
          ],
        );
        for (var repeat = 0; repeat < 2; repeat++) {
          final result = BondSearch.solve(problem, maxCandidates: 4);
          expect(result.provenOptimal, isTrue);
          expect(result.best?.totalBond, _bruteForce(problem), reason: '$indices, capacity $capacity');
          for (final witness in [...result.ties, ...result.candidates]) {
            for (var ci = 0; ci < 2; ci++) {
              final used = witness.items.fold<int>(
                0,
                (sum, item) => sum + item.ownedCeClassIndices.where((index) => index == ci).length,
              );
              expect(used, lessThanOrEqualTo(capacity));
            }
          }
        }
      }
    }
  });

  test('equal-cost bounds retain alternatives with different identities and source effects', () {
    BondSearchItem choice(int id, {int cost = 1, int self = 0, int team = 0}) => BondSearchItem(
      cost: cost,
      receiverProfile: 0,
      selfRate: self,
      selfValue: -150,
      teamRates: [team],
      teamValues: const [0],
      servantIds: {id},
    );
    for (final budget in [0, 1, 2, 3, 4]) {
      final problem = BondSearchProblem(
        baseBond: 100,
        rateCap: 5000,
        maxCost: budget,
        receiverProfileCount: 1,
        positions: [
          BondSearchPosition(
            frontlineRate: 0,
            items: [choice(1, self: 2000), choice(2, team: 1500), choice(3, cost: 0), choice(4, cost: 5, self: 5000)],
          ),
          BondSearchPosition(frontlineRate: 0, items: [choice(1, self: 3000), choice(3)]),
        ],
      );
      final result = BondSearch.solve(problem);
      expect(result.provenOptimal, isTrue);
      expect(result.best?.totalBond, _bruteForce(problem), reason: 'budget $budget');
      if (budget >= 2) {
        expect(result.best!.servantIds, [2, 1]);
        expect(result.best!.totalBond, 500);
      }
    }
  });

  test('prefix identity pruning checks Hall subsets and allows empty positions', () {
    BondSearchItem choice(Set<int> ids, int cls) => BondSearchItem(
      cost: 0,
      receiverProfile: 0,
      selfRate: 1000,
      selfValue: 0,
      teamRates: const [0],
      teamValues: const [0],
      servantIds: ids,
      servantClassIndex: cls,
    );
    const empty = BondSearchItem(
      cost: 0,
      receiverProfile: null,
      selfRate: 0,
      selfValue: 0,
      teamRates: [0],
      teamValues: [0],
    );
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      servantClassCapacities: const [4, 4, 4, 4, 4],
      positions: [
        for (var p = 0; p < 3; p++)
          BondSearchPosition(
            frontlineRate: 0,
            items: [
              choice({1, 2}, p),
              empty,
            ],
          ),
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            choice({3, 4, 5}, 3),
            empty,
          ],
        ),
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            choice({6, 7, 8, 9, 10}, 4),
            empty,
          ],
        ),
      ],
    );
    final result = BondSearch.solve(problem);
    expect(result.provenOptimal, isTrue);
    expect(result.best?.totalBond, 800);
    expect(result.best?.totalBond, _bruteForce(problem));
  });

  test('cross-class servant identity conflicts cannot set the incumbent', () {
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      positions: [
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0, selfRate: 1000)]),
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0), _item(2, 0)]),
      ],
    );
    final result = BondSearch.solve(problem);
    expect(result.provenOptimal, isTrue);
    expect(result.best!.servantIds, [1, 2]);
    expect(result.best!.totalBond, 360);
  });

  test('two CE dimensions need two distinct concrete IDs', () {
    BondSearchItem item(List<Set<int>> ces, int rate) => BondSearchItem(
      cost: 0,
      receiverProfile: 0,
      selfRate: rate,
      selfValue: 0,
      teamRates: const [0],
      teamValues: const [0],
      servantIds: const {1},
      ownedCeIds: ces,
      ownedCeClassIndices: [for (final _ in ces) 0],
    );
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      ownedCeClassCapacities: const [2],
      positions: [
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            item([
              const {10},
              const {10},
            ], 1000),
            item([
              const {10},
              const {10, 11},
            ], 500),
          ],
        ),
      ],
    );
    final result = BondSearch.solve(problem);
    expect(result.best!.totalBond, 150);
    expect(result.best!.ownedCeIds.single.toSet(), {10, 11});
  });

  test('CE family matching reserves shared identity and preserves concrete IDs', () {
    BondSearchItem choice(int servant, Set<int> ces) => BondSearchItem(
      cost: 0,
      receiverProfile: 0,
      selfRate: 0,
      selfValue: 0,
      teamRates: const [0],
      teamValues: const [0],
      servantIds: {servant},
      ownedCeIds: [ces],
    );
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      ownedCeIdentities: const {10: 10, 11: 10},
      positions: [
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            choice(1, {10, 20}),
          ],
        ),
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            choice(2, {11}),
          ],
        ),
      ],
    );
    final solved = BondSearch.solve(problem);
    expect(solved.best!.ownedCeIds, [
      [20],
      [11],
    ]);
    final conflict = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      ownedCeIdentities: problem.ownedCeIdentities,
      positions: [
        BondSearchPosition(
          frontlineRate: 0,
          items: [
            choice(1, {10}),
          ],
        ),
        problem.positions[1],
      ],
    );
    expect(BondSearch.solve(conflict).best, isNull);
  });

  test('random small problems match concrete exhaustive enumeration', () {
    final random = math.Random(44721);
    for (var trial = 0; trial < 1000; trial++) {
      final positions = <BondSearchPosition>[];
      final n = 2 + random.nextInt(3);
      for (var p = 0; p < n; p++) {
        final items = <BondSearchItem>[];
        for (var j = 0; j < 2 + random.nextInt(2); j++) {
          final isSupport = random.nextInt(6) == 0;
          final ceDimensions = random.nextInt(4);
          final servantIds = isSupport ? <int>{} : <int>{1 + random.nextInt(4), 1 + random.nextInt(4)};
          items.add(
            BondSearchItem(
              cost: random.nextInt(4),
              receiverProfile: isSupport ? null : random.nextInt(2),
              selfRate: random.nextInt(501) - 100,
              selfValue: random.nextInt(31) - 5,
              teamRates: [random.nextInt(401) - 100, random.nextInt(401) - 100],
              teamValues: [random.nextInt(21) - 5, random.nextInt(21) - 5],
              servantIds: servantIds,
              servantClassIndex: isSupport ? null : random.nextInt(2),
              ownedCeIds: [
                for (var d = 0; d < ceDimensions; d++) <int>{10 + random.nextInt(5), 10 + random.nextInt(5)},
              ],
              ownedCeClassIndices: [for (var d = 0; d < ceDimensions; d++) random.nextInt(2)],
            ),
          );
        }
        positions.add(BondSearchPosition(frontlineRate: p < 3 ? 200 : 0, items: items));
      }
      final problem = BondSearchProblem(
        baseBond: 100 + random.nextInt(901),
        rateCap: 500 + random.nextInt(2501),
        maxCost: 2 + random.nextInt(7),
        receiverProfileCount: 2,
        positions: positions,
        servantClassCapacities: [1 + random.nextInt(3), 1 + random.nextInt(3)],
        ownedCeClassCapacities: [1 + random.nextInt(3), 1 + random.nextInt(3)],
        ownedCeIdentities: trial.isEven ? const {10: 10, 11: 10} : const {},
      );
      final expected = _bruteForce(problem);
      final actual = BondSearch.solve(problem);
      expect(actual.provenOptimal, isTrue, reason: 'trial $trial');
      expect(actual.best?.totalBond, expected, reason: 'trial $trial');
      if (actual.best != null) {
        expect(actual.best!.totalCost, lessThanOrEqualTo(problem.maxCost));
        expect(
          actual.best!.servantIds.whereType<int>().toSet().length,
          actual.best!.servantIds.whereType<int>().length,
        );
        final ces = actual.best!.ownedCeIds.expand((e) => e).map((id) => problem.ownedCeIdentities[id] ?? id).toList();
        expect(ces.toSet().length, ces.length);
      }
    }
  });

  test('a node cap never reports an unproven value as optimal', () {
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 10,
      receiverProfileCount: 1,
      positions: [
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0, selfRate: 1000), _item(2, 0)]),
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0, selfRate: 1000), _item(3, 0)]),
      ],
    );
    final result = BondSearch.solve(problem, maxNodes: 1);
    expect(result.provenOptimal, isFalse);
    expect(result.best, isNotNull);
    expect(result.best!.servantIds.whereType<int>().toSet().length, 2);
  });

  test('progress reports a feasible candidate before the score proof', () {
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 10,
      receiverProfileCount: 1,
      positions: [
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0), _item(2, 0)]),
        BondSearchPosition(frontlineRate: 200, items: [_item(1, 0), _item(3, 0)]),
      ],
    );
    final updates = <BondSearchResult>[];
    final result = BondSearch.solve(problem, onProgress: updates.add);
    expect(updates, isNotEmpty);
    expect(updates.first.best, isNotNull);
    expect(updates.first.provenOptimal, isFalse);
    expect(updates.last.provenOptimal, isTrue);
    expect(updates.last.best!.totalBond, result.best!.totalBond);
    expect(updates.map((e) => e.visitedNodes), orderedEquals([...updates.map((e) => e.visitedNodes)]..sort()));
  });

  test('the first feasible seed is published before local improvement', () {
    final updates = <BondSearchResult>[];
    final result = BondSearch.solve(
      BondSearchProblem(
        baseBond: 100,
        rateCap: 5000,
        maxCost: 1,
        receiverProfileCount: 1,
        positions: [
          BondSearchPosition(frontlineRate: 0, items: [_item(1, 0), _item(2, 1, selfRate: 1000)]),
        ],
      ),
      onProgress: updates.add,
    );
    expect(updates.first.best!.totalBond, 100);
    expect(updates.first.firstFeasibleMilliseconds, isNotNull);
    expect(updates.first.provenOptimal, isFalse);
    expect(result.best!.totalBond, 200);
    expect(result.provenOptimal, isTrue);
  });

  test('equal outcomes share a group and keep the higher-cost representative', () {
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 10,
      receiverProfileCount: 1,
      positions: [
        BondSearchPosition(frontlineRate: 0, items: [_item(1, 5), _item(2, 0)]),
      ],
    );
    final result = BondSearch.solve(problem);
    expect(result.provenOptimal, isTrue);
    expect(result.allTiesCollected, isTrue);
    expect(result.best!.totalCost, 5);
    expect(result.candidates.map((e) => e.totalCost), [5, 0]);
    expect(result.ties, hasLength(1));
    expect(result.tieGroupCounts, [2]);
  });

  test('bounded candidates include lower scores without changing the maximum proof', () {
    final problem = BondSearchProblem(
      baseBond: 100,
      rateCap: 5000,
      maxCost: 0,
      receiverProfileCount: 1,
      positions: [
        BondSearchPosition(
          frontlineRate: 0,
          items: [_item(1, 0, selfRate: 1000), _item(2, 0, selfRate: 500), _item(3, 0)],
        ),
      ],
    );
    final result = BondSearch.solve(problem, maxCandidates: 2);
    expect(result.provenOptimal, isTrue);
    expect(result.best!.totalBond, 200);
    expect(result.candidates.map((e) => e.totalBond), [200, 150]);
    expect(result.candidates.map((e) => e.servantIds.single), [1, 2]);
  });
}

BondSearchItem _item(int id, int cost, {int selfRate = 0}) => BondSearchItem(
  cost: cost,
  receiverProfile: 0,
  selfRate: selfRate,
  selfValue: 0,
  teamRates: const [0],
  teamValues: const [0],
  servantIds: {id},
);

int? _bruteForce(BondSearchProblem problem) {
  final chosen = <BondSearchItem>[];
  int? best;
  void visit(int p, int cost) {
    if (p == problem.positions.length) {
      final svtSets = [
        for (final item in chosen)
          if (item.servantIds.isNotEmpty) item.servantIds,
      ];
      final ceSets = [
        for (final item in chosen)
          for (final ids in item.ownedCeIds) {for (final id in ids) problem.ownedCeIdentities[id] ?? id},
      ];
      if (!_canAssign(svtSets) || !_canAssign(ceSets)) return;
      for (final (i, capacity) in problem.servantClassCapacities.indexed) {
        if (chosen.where((item) => item.servantClassIndex == i).length > capacity) return;
      }
      for (final (i, capacity) in problem.ownedCeClassCapacities.indexed) {
        if (chosen.fold<int>(0, (sum, item) => sum + item.ownedCeClassIndices.where((c) => c == i).length) > capacity) {
          return;
        }
      }
      var total = 0;
      for (final (i, item) in chosen.indexed) {
        final profile = item.receiverProfile;
        if (profile == null) continue;
        final first = (problem.baseBond * (1 + problem.positions[i].frontlineRate / 1000)).floor();
        final rate = item.selfRate + chosen.fold<int>(0, (v, source) => v + source.teamRates[profile]);
        final value = item.selfValue + chosen.fold<int>(0, (v, source) => v + source.teamValues[profile]);
        total += (first * (1 + math.min(rate, problem.rateCap) / 1000)).floor() + value;
      }
      best = math.max(best ?? total, total);
      return;
    }
    for (final item in problem.positions[p].items) {
      if (cost + item.cost > problem.maxCost) continue;
      chosen.add(item);
      visit(p + 1, cost + item.cost);
      chosen.removeLast();
    }
  }

  visit(0, 0);
  return best;
}

bool _canAssign(List<Set<int>> dimensions) {
  bool visit(int i, Set<int> used) {
    if (i == dimensions.length) return true;
    for (final id in dimensions[i]) {
      if (used.contains(id)) continue;
      used.add(id);
      if (visit(i + 1, used)) return true;
      used.remove(id);
    }
    return false;
  }

  return visit(0, <int>{});
}
