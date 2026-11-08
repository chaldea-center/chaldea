import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/modules/bond/solver/search.dart';
import 'package:chaldea/app/modules/bond/solver/work.dart';

void main() {
  test('preparation probe distinguishes empty, complete and truncated streams', () {
    for (final source in [
      <int?>[],
      <int?>[1, null, 2],
    ]) {
      final probe = BondPreparationProbe<int>(maxItems: 2, maxSteps: 3);
      for (final _ in probe.collect(source)) {}
      expect(probe.complete, isTrue);
      expect(probe.items, source.whereType<int>().toList());
    }
    final storage = BondPreparationProbe<int>(maxItems: 1, maxSteps: 10);
    for (final _ in storage.collect([1, 2, 3])) {}
    expect(storage.complete, isFalse);
    expect(storage.items, isEmpty);
    expect(storage.steps, 2);
    final work = BondPreparationProbe<int>(maxItems: 10, maxSteps: 2);
    for (final _ in work.collect([null, null, null, 1])) {}
    expect(work.complete, isFalse);
    expect(work.items, isEmpty);
    expect(work.steps, 3);
  });

  test('cancelling a preparation probe cannot publish completeness', () async {
    var cancelled = false;
    var touched = 0;
    Iterable<int?> source() sync* {
      for (var i = 0; i < 1000; i++) {
        touched++;
        yield i;
      }
    }

    final probe = BondPreparationProbe<int>(maxItems: 1000, maxSteps: 2000);
    final scheduler = BondWorkScheduler(isCancelled: () => cancelled, slice: Duration.zero);
    Timer.run(() => cancelled = true);
    await expectLater(scheduler.run(probe.collect(source())), throwsA(isA<BondWorkCancelled>()));
    expect(probe.complete, isFalse);
    expect(touched, lessThan(1000));
    final stopped = touched;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(touched, stopped);
  });
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
