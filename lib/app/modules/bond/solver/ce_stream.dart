part of 'solver.dart';

/// Exact, bounded-memory alternative when materializing CE combinations would
/// exceed the preparation limit. Bounds relax identity, COST and source
/// compatibility; only a concrete matched combination may enter the servant DP.
extension _CeFirstStreaming on _CeFirstSearch {
  Iterable<void> _solveStreamingSteps(
    List<(_CeFirstPosition, List<_CeFirstServant>)> upperGroups,
    List<int> upperGroupAtPosition,
    List<int> upperScores,
    List<int> ce1Slots,
    List<int> ce3Slots,
    List<int> supportSlots, {
    required int? maxEvaluations,
    required void Function(_CeFirstSolution, int?) remember,
    required void Function(_CeFirstResult)? onProgress,
    required void Function(_CeFirstResult) onComplete,
  }) sync* {
    final profiles = problem.fixedRates.length;
    final rates = List<int>.of(problem.fixedRates);
    final values = List<int>.of(problem.fixedValues);
    final upperRates = List<int>.filled(profiles, 0);
    final upperValues = List<int>.filled(profiles, 0);
    final supportRates = List.generate(supportSlots.length + 1, (_) => List<int>.filled(profiles, 0));
    final supportValues = List.generate(supportSlots.length + 1, (_) => List<int>.filled(profiles, 0));
    for (var s = supportSlots.length - 1; s >= 0; s--) {
      final localRates = List<int>.filled(profiles, 0);
      final localValues = List<int>.filled(profiles, 0);
      for (final choice in problem.positions[supportSlots[s]].supportChoices) {
        for (var r = 0; r < profiles; r++) {
          localRates[r] = math.max(localRates[r], choice.rates[r]);
          localValues[r] = math.max(localValues[r], choice.values[r]);
          if (++_workTicks % 64 == 0) yield null;
        }
      }
      for (var r = 0; r < profiles; r++) {
        supportRates[s][r] = localRates[r] + supportRates[s + 1][r];
        supportValues[s][r] = localValues[r] + supportValues[s + 1][r];
      }
    }

    final counts = List<int>.filled(problem.ownCes.length, 0);
    final selected1 = <int>[], selected3 = <int>[];
    final supportSelection = List<int>.filled(supportSlots.length, 0);
    var cost = problem.fixedCost;
    var upper = 0;
    var interrupted = false, collecting = false, collectionStopped = false;
    var supplementary = (maxTies + maxCandidates) * 4;
    var lastProgress = 0;

    void change(List<int> sourceRates, List<int> sourceValues, int sign) {
      for (var r = 0; r < profiles; r++) {
        rates[r] += sign * sourceRates[r];
        values[r] += sign * sourceValues[r];
      }
    }

    // Ordering only: it does not discard candidates or enter any proof.
    final firstScale = problem.positions.fold<int>(0, (v, p) => math.max(v, p.first));
    int priority(List<int> rr, List<int> vv) =>
        rr.fold<int>(0, (v, x) => v + x) * firstScale + vv.fold<int>(0, (v, x) => v + x) * 1000;
    final ceOrder = List.generate(problem.ownCes.length, (i) => i);
    yield* bondSortSteps(ceOrder, (a, b) {
      final aa = problem.ownCes[a], bb = problem.ownCes[b];
      final c = priority(bb.rates, bb.values).compareTo(priority(aa.rates, aa.values));
      return c != 0 ? c : a.compareTo(b);
    });
    final supportOrder = <List<int>>[];
    for (final slot in supportSlots) {
      final choices = problem.positions[slot].supportChoices;
      final order = List.generate(choices.length, (i) => i);
      yield* bondSortSteps(order, (a, b) {
        final c = priority(
          choices[b].rates,
          choices[b].values,
        ).compareTo(priority(choices[a].rates, choices[a].values));
        return c != 0 ? c : a.compareTo(b);
      });
      supportOrder.add(order);
    }

    final sourceBound = BondCeSourceBound(problem.ownCes, ceOrder, profiles);

    // Slot kinds independently borrow remaining class capacity. Shared
    // identities, joint equip1 COST and source compatibility stay relaxed.
    Iterable<void> bound(int slots1Left, int slots3Left, int supportIndex, {int start1 = 0, int start3 = 0}) sync* {
      for (var r = 0; r < profiles; r++) {
        upperRates[r] =
            rates[r] +
            sourceBound.contribution(r, slots1Left, start1, counts, value: false, costLeft: problem.maxCost - cost) +
            sourceBound.contribution(r, slots3Left, start3, counts, value: false) +
            supportRates[supportIndex][r];
        upperValues[r] =
            values[r] +
            sourceBound.contribution(r, slots1Left, start1, counts, value: true, costLeft: problem.maxCost - cost) +
            sourceBound.contribution(r, slots3Left, start3, counts, value: true) +
            supportValues[supportIndex][r];
        if (++_workTicks % 64 == 0) yield null;
      }
      for (final (g, group) in upperGroups.indexed) {
        final (position, servants) = group;
        var highest = position.fixedServant ? kImpossibleScore : 0;
        for (final servant in servants) {
          highest = math.max(highest, _score(position, servant, upperRates, upperValues));
          if (++_workTicks % 64 == 0) yield null;
        }
        upperScores[g] = highest;
      }
      upper = 0;
      // Preserve position addition order, including empty fixed domains.
      for (final group in upperGroupAtPosition) {
        if (group >= 0) upper += upperScores[group];
      }
      if (onProgress != null && _clock.elapsedMilliseconds - lastProgress >= 250) {
        lastProgress = _clock.elapsedMilliseconds;
        onProgress(_snapshot(collecting, null));
      }
    }

    bool getPruned() {
      if (interrupted || collectionStopped || cost > problem.maxCost) return true;
      if (collecting) {
        return _candidates.length >= maxCandidates && upper < _candidates.last.totalBond;
      }
      return _best != null && upper <= _best!.totalBond;
    }

    // Matching depends on ordered owned classes and fixed identities only;
    // changing support/source vectors does not invalidate a completed match.
    final reuseMatches =
        ce3Slots.isNotEmpty &&
        (supportSlots.any((p) => problem.positions[p].supportChoices.length > 1) ||
            (maxEvaluations == null && maxCandidates > 1));
    final matchCache = reuseMatches
        ? BondCeMatchCache(problem.ownCes, problem.fixedCeIdentities, maxSlots: ce1Slots.length + ce3Slots.length)
        : null;

    Iterable<void> third(int start) sync* {
      if (interrupted || collectionStopped || cost > problem.maxCost) return;
      final selected = [...selected1, ...selected3];
      final matched = matchCache != null ? matchCache.match(selected) : _matchCeIds(problem, selected);
      if (matched == null) return;
      yield* bound(0, ce3Slots.length - selected3.length, supportSlots.length, start3: start);
      if (getPruned()) return;
      if (selected3.length < ce3Slots.length) {
        for (var j = start; j < ceOrder.length; j++) {
          if (++_workTicks % 64 == 0) yield null;
          final i = ceOrder[j], ce = problem.ownCes[i];
          if (!ce.canAdd(counts[i])) continue;
          counts[i]++;
          selected3.add(i);
          change(ce.rates, ce.values, 1);
          yield* third(j);
          change(ce.rates, ce.values, -1);
          selected3.removeLast();
          counts[i]--;
          if (interrupted || collectionStopped) return;
        }
      }
      // Stopping at this prefix leaves the remaining equipment slots empty.
      yield* bound(0, 0, supportSlots.length);
      if (getPruned()) return;
      if (collecting && supplementary == 0) {
        collectionStopped = true;
        return;
      }
      if (!collecting && maxEvaluations != null && _evaluated >= maxEvaluations) {
        interrupted = true;
        return;
      }
      final combo = _CeFirstCombo(
        List.of(selected1),
        List.of(selected3),
        List.of(supportSelection),
        matched,
        cost,
        upper,
      );
      if (collecting) supplementary--;
      _evaluated++;
      yield* _evaluateSteps(combo, ce1Slots, ce3Slots, supportSlots);
      final solution = _evaluatedSolution;
      if (solution != null) remember(solution, null);
    }

    Iterable<void> first(int start) sync* {
      if (interrupted || collectionStopped || cost > problem.maxCost) return;
      if ((matchCache != null ? matchCache.match(selected1) : _matchCeIds(problem, selected1)) == null) return;
      yield* bound(ce1Slots.length - selected1.length, ce3Slots.length, supportSlots.length, start1: start);
      if (getPruned()) return;
      if (selected1.length < ce1Slots.length) {
        for (var j = start; j < ceOrder.length; j++) {
          if (++_workTicks % 64 == 0) yield null;
          final i = ceOrder[j], ce = problem.ownCes[i];
          if (!ce.canAdd(counts[i]) || cost + ce.cost > problem.maxCost) continue;
          counts[i]++;
          selected1.add(i);
          cost += ce.cost;
          change(ce.rates, ce.values, 1);
          yield* first(j);
          change(ce.rates, ce.values, -1);
          cost -= ce.cost;
          selected1.removeLast();
          counts[i]--;
          if (interrupted || collectionStopped) return;
        }
      }
      yield* third(0);
    }

    Iterable<void> support(int index) sync* {
      if (interrupted || collectionStopped || cost > problem.maxCost) return;
      yield* bound(ce1Slots.length, ce3Slots.length, index);
      if (getPruned()) return;
      if (index == supportSlots.length) {
        yield* first(0);
        return;
      }
      final choices = problem.positions[supportSlots[index]].supportChoices;
      for (final i in supportOrder[index]) {
        if (++_workTicks % 64 == 0) yield null;
        supportSelection[index] = i;
        change(choices[i].rates, choices[i].values, 1);
        yield* support(index + 1);
        change(choices[i].rates, choices[i].values, -1);
        if (interrupted || collectionStopped) return;
      }
    }

    yield* support(0);
    final proven = !interrupted;
    if (proven && _best != null) {
      onProgress?.call(_snapshot(true, null));
      if (_bestSolution != null) yield* _rememberNearbyServantsSteps(_bestSolution!);
      if (maxEvaluations == null) {
        collecting = true;
        yield* support(0);
      }
    }
    if (kDebugMode) {
      debugPrint(
        '[BondSolver] streaming CE search: ${_clock.elapsedMilliseconds}ms evaluations=$_evaluated proven=$proven',
      );
    }
    onComplete(_snapshot(proven, null));
  }
}
