part of 'solver.dart';

/// Completes displayed teams using the prepared owned CE classes.
/// The underlying search still explores its original space and proves the maximum.
final class _CandidateEquipment {
  final FormationBondSolver _solver;
  late final List<_CeClass> _classes = List.of(_solver._ownedCeClasses)..sort((a, b) => a.cost.compareTo(b.cost));
  final _completed = <BondSolvedTeam, BondSolvedTeam>{};

  _CandidateEquipment(this._solver);

  Iterable<void> completeSteps(BondSolvedTeam team, void Function(BondSolvedTeam) onComplete) sync* {
    final cached = _completed[team];
    if (cached != null) {
      onComplete(cached);
      return;
    }
    final cheapest = _classes.firstOrNull;
    if (cheapest == null || team.totalCost + cheapest.cost > _solver._maxCost) {
      onComplete(team);
      return;
    }
    final emptyPositions = [
      for (final (p, slot) in team.slots.indexed)
        if (!slot.isSupport && slot.servantId != null && !slot.fixedEquip1 && slot.equip1 == null) p,
    ];
    if (emptyPositions.isEmpty) {
      onComplete(team);
      return;
    }

    final used = <int>{
      for (final slot in team.slots)
        if (!slot.isSupport)
          for (final ce in [slot.equip1, slot.equip3])
            if (ce != null && BondCeIdentity.requiresUniqueOwnedIdentity(db.gameData.craftEssencesById[ce.id]!))
              BondCeIdentity.of(ce.id),
    };
    yield* _solver._preparePreviewSteps(team);
    final slots = List.of(team.previewTeam.slots);
    final trial = BondSolvedTeam(team.totalBond, team.totalCost, slots);
    var totalBond = team.totalBond;
    var totalCost = team.totalCost;
    List<int>? finalBonds;
    for (final p in emptyPositions) {
      final original = slots[p];
      var bestBond = totalBond;
      ({BondSolvedSlot slot, List<int> bonds, int cost, int? identity})? best;
      for (final cls in _classes) {
        if (totalCost + cls.cost > _solver._maxCost) break;
        final entry = cls.limitBreaks.entries
            .where((entry) => cls.repeatable || !used.contains(BondCeIdentity.of(entry.key)))
            .firstOrNull;
        if (entry == null) continue;
        final ce = BondSolvedCe(entry.key, entry.value);
        slots[p] = original.copyWith(cost: original.cost + cls.cost, ce1: (ce, {ce.id: ce.limitBreak}));
        final (bonds, cost) = _solver._scoreConcrete(trial);
        final bond = bonds.fold<int>(0, (sum, value) => sum + value);
        if (cost <= _solver._maxCost && bond > bestBond) {
          bestBond = bond;
          best = (slot: slots[p], bonds: bonds, cost: cost, identity: cls.repeatable ? null : BondCeIdentity.of(ce.id));
        }
        yield null;
      }
      if (best == null) {
        slots[p] = original;
        // A free owned CE has the same effect in every open position.
        break;
      }
      slots[p] = best.slot;
      if (best.identity case final identity?) used.add(identity);
      totalBond = bestBond;
      totalCost = best.cost;
      finalBonds = best.bonds;
    }

    // Previously equivalent servants may receive different bonuses from an added CE.
    var result = team;
    if (finalBonds != null) {
      for (final (p, slot) in slots.indexed) {
        slots[p] = slot.copyWith(bond: finalBonds[p], servantVariants: {?slot.servantId: slot.limitCount ?? 4});
      }
      _solver._orderFreeEquip1(slots);
      result = BondSolvedTeam(totalBond, totalCost, slots);
      // This exact set of ascensions passed the equipment check.
      BondSolvedTeam._previews[result] = result;
    }
    if (_completed.length >= _solver._candidateLimit * 4) _completed.remove(_completed.keys.first);
    _completed[team] = result;
    onComplete(result);
  }
}
