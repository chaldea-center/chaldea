import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/modules/bond/solver/combination_count.dart';

void main() {
  test('both equipment types consume the same restricted capacity', () {
    expect(bondCeCombinationUpper(capacities: [1], slots1: 1, slots3: 1, limit: 100), 3);
    expect(bondCeCombinationUpper(capacities: [2], slots1: 1, slots3: 1, limit: 100), 4);
    expect(bondCeCombinationUpper(capacities: [1, 1], slots1: 3, slots3: 0, limit: 100), 4);
    expect(bondCeCombinationUpper(capacities: [], slots1: 6, slots3: 6, limit: 100), 1);
  });

  test('capacity count and saturation match canonical slot enumeration', () {
    final random = Random(4105);
    for (var trial = 0; trial < 150; trial++) {
      final capacities = List.generate(random.nextInt(5), (_) => random.nextInt(5));
      final a = random.nextInt(4), b = random.nextInt(4);
      List<List<int>> selections(int slots) {
        final result = <List<int>>[];
        void visit(List<int> chosen, int start) {
          result.add(List.of(chosen));
          if (chosen.length == slots) return;
          for (var c = start; c < capacities.length; c++) {
            visit([...chosen, c], c);
          }
        }

        visit([], 0);
        return result;
      }

      var expected = 0;
      for (final first in selections(a)) {
        for (final third in selections(b)) {
          final uses = List.filled(capacities.length, 0);
          for (final c in [...first, ...third]) {
            uses[c]++;
          }
          if (uses.indexed.every((e) => e.$2 <= capacities[e.$1])) expected++;
        }
      }
      for (final limit in [0, 5, 100000]) {
        expect(
          bondCeCombinationUpper(capacities: capacities, slots1: a, slots3: b, limit: limit),
          min(expected, limit + 1),
          reason: 'trial $trial, limit $limit',
        );
      }
    }
  });
}
