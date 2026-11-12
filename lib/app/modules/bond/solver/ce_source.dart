import 'dart:math' as math;

/// A wearer-independent CE source. Identity policy is resolved by the caller.
class BondCeSource {
  final int cost;
  final List<int> rates;
  final List<int> values;
  final Map<int, bool> limits;
  final bool repeatable;
  final Map<int, int> _identities;
  final int identityCapacity;
  late final List<int> sortedIds = List<int>.unmodifiable(limits.keys.toList()..sort());

  BondCeSource(
    this.cost,
    this.rates,
    this.values,
    this.limits,
    this.repeatable, {
    required int Function(int) identityOf,
  }) : _identities = {for (final id in limits.keys) id: identityOf(id)},
       identityCapacity = limits.keys.map(identityOf).toSet().length;

  int identityOf(int id) => _identities[id]!;
  bool canAdd(int count) => repeatable || count < identityCapacity;
}

/// Optimistic contributions within a canonical suffix and remaining capacity.
/// Slot kinds borrow capacity independently; joint COST and identity stay relaxed.
class BondCeSourceBound {
  final List<BondCeSource> sources;
  final List<int> order;
  final List<int> _ranks;
  final List<List<int>> _rateOrders = [];
  final List<List<int>> _valueOrders = [];

  BondCeSourceBound(this.sources, this.order, int profiles) : _ranks = List<int>.filled(order.length, 0) {
    for (final (rank, index) in order.indexed) {
      _ranks[index] = rank;
    }
    for (var profile = 0; profile < profiles; profile++) {
      _rateOrders.add(
        List<int>.of(order)..sort((a, b) => sources[b].rates[profile].compareTo(sources[a].rates[profile])),
      );
      _valueOrders.add(
        List<int>.of(order)..sort((a, b) => sources[b].values[profile].compareTo(sources[a].values[profile])),
      );
    }
  }

  int contribution(int profile, int slots, int start, List<int> counts, {required bool value, int? costLeft}) {
    if (slots == 0) return 0;
    final sorted = value ? _valueOrders[profile] : _rateOrders[profile];
    var left = slots, total = 0;
    for (final index in sorted) {
      final ce = sources[index];
      final amount = value ? ce.values[profile] : ce.rates[profile];
      if (amount <= 0) break;
      if (_ranks[index] < start || (costLeft != null && ce.cost > costLeft)) continue;
      final capacity = ce.repeatable ? left : math.min(left, ce.identityCapacity - counts[index]);
      if (capacity <= 0) continue;
      total += capacity * amount;
      left -= capacity;
      if (left == 0) break;
    }
    return total;
  }
}
