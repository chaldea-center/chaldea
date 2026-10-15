import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/modules/bond/solver/search.dart';
import 'package:chaldea/app/modules/bond/solver/work.dart';

void main() {
  test('resumable stable sort matches sorting for uneven and empty lists', () {
    final random = Random(710);
    for (final size in [0, 1, 2, 3, 17, 129, 1001]) {
      final values = List.generate(size, (i) => (random.nextInt(20), i));
      final expected = List.of(values)
        ..sort((a, b) {
          final score = a.$1.compareTo(b.$1);
          return score != 0 ? score : a.$2.compareTo(b.$2);
        });
      for (final _ in bondSortSteps(values, (a, b) => a.$1.compareTo(b.$1))) {}
      expect(values, expected);
    }
  });

  test('sliced search yields to timers and preserves its exact witness and proof', () async {
    final problem = BondSearchProblem(
      baseBond: 1000,
      rateCap: 5000,
      maxCost: 80,
      receiverProfileCount: 1,
      positions: List.generate(
        4,
        (_) => BondSearchPosition(
          frontlineRate: 0,
          items: [
            for (var id = 1; id <= 12; id++)
              BondSearchItem(
                cost: id,
                receiverProfile: 0,
                selfRate: id * 10,
                selfValue: 0,
                teamRates: const [0],
                teamValues: const [0],
                servantIds: {id},
              ),
          ],
        ),
      ),
    );
    final expected = BondSearch.solve(problem);
    late BondSearchResult actual;
    var timerRan = false;
    final timer = Timer(Duration.zero, () => timerRan = true);
    final scheduler = BondWorkScheduler(slice: const Duration(microseconds: 1));
    await scheduler.run(BondSearch.solveSteps(problem, onComplete: (value) => actual = value));
    timer.cancel();
    expect(timerRan, isTrue);
    expect(scheduler.yields, greaterThan(0));
    expect(actual.best!.totalBond, expected.best!.totalBond);
    expect(actual.best!.servantIds, expected.best!.servantIds);
    expect(actual.visitedNodes, expected.visitedNodes);
    expect(actual.provenOptimal, expected.provenOptimal);
    expect(actual.allTiesCollected, expected.allTiesCollected);
  });

  test('cancellation stops resumable work before further mutations', () async {
    var cancelled = false, completed = 0;
    Iterable<void> work() sync* {
      for (var i = 0; i < 1000; i++) {
        completed++;
        yield null;
      }
    }

    final timer = Timer(Duration.zero, () => cancelled = true);
    final scheduler = BondWorkScheduler(isCancelled: () => cancelled, slice: Duration.zero);
    await expectLater(scheduler.run(work()), throwsA(isA<BondWorkCancelled>()));
    timer.cancel();
    expect(completed, 1);
  });
}
