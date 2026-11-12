import 'ce_source.dart';

List<int>? matchBondCeIds(
  List<BondCeSource> sources,
  Set<int> fixedIdentities,
  List<int> selected, {
  int maxBacktrackChecks = 128,
}) {
  if (selected.isEmpty) return const [];
  final assignments = List<int>.filled(selected.length, -1);
  final order = List<int>.generate(selected.length, (i) => i)
    ..sort((a, b) => sources[selected[a]].limits.length.compareTo(sources[selected[b]].limits.length));
  final used = Set<int>.of(fixedIdentities);
  // Keep easy matches cheap; reaching the limit switches algorithms rather
  // than treating an unfinished search as infeasible.
  var checks = 0;
  var exhausted = false;
  bool visit(int depth) {
    if (depth == order.length) return true;
    final dimension = order[depth];
    final ce = sources[selected[dimension]];
    for (final id in ce.sortedIds) {
      if (++checks > maxBacktrackChecks) {
        exhausted = true;
        return false;
      }
      final identity = sources[selected[dimension]].identityOf(id);
      final restricted = !ce.repeatable;
      if (restricted && !used.add(identity)) continue;
      assignments[dimension] = id;
      if (visit(depth + 1)) return true;
      if (restricted) used.remove(identity);
      // Other copies of a repeatable CE leave exactly the same suffix state.
      if (exhausted || !restricted) return false;
    }
    return false;
  }

  if (visit(0)) return assignments;
  if (!exhausted) return null;

  // The bounded DFS has unwound all temporary reservations. Augmenting paths
  // decide suffix feasibility without enumerating permutations of shared IDs.
  bool canComplete(int depth) {
    final owner = <int, int>{};
    bool augment(int dimension, Set<int> seen) {
      for (final id in sources[selected[dimension]].sortedIds) {
        final identity = sources[selected[dimension]].identityOf(id);
        if (used.contains(identity) || !seen.add(identity)) continue;
        final previous = owner[identity];
        if (previous == null || augment(previous, seen)) {
          owner[identity] = dimension;
          return true;
        }
      }
      return false;
    }

    for (var i = depth; i < order.length; i++) {
      final dimension = order[i], ce = sources[selected[dimension]];
      if (ce.sortedIds.isEmpty) return false;
      if (!ce.repeatable && !augment(dimension, <int>{})) return false;
    }
    return true;
  }

  if (!canComplete(0)) return null;
  // Greedily lock the first ID with a feasible suffix in the original search
  // order. This returns the same concrete witness as exhaustive backtracking.
  for (var depth = 0; depth < order.length; depth++) {
    final dimension = order[depth], ce = sources[selected[dimension]];
    var found = false;
    for (final id in ce.sortedIds) {
      final identity = sources[selected[dimension]].identityOf(id);
      if (!ce.repeatable && !used.add(identity)) continue;
      if (ce.repeatable || canComplete(depth + 1)) {
        assignments[dimension] = id;
        found = true;
        break;
      }
      used.remove(identity);
    }
    if (!found) return null;
  }
  return assignments;
}

/// A lossless ordered sequence key with a conservative JS integer range guard.
class BondCeMatchKey {
  final int base;
  final bool packed;
  BondCeMatchKey(int classCount, int maxSlots) : base = classCount + 1, packed = _canPack(classCount, maxSlots);

  static bool _canPack(int classCount, int maxSlots) {
    const maxExact = 9007199254740991;
    var maximum = 1;
    for (var i = 0; i < maxSlots; i++) {
      final next = maximum.toDouble() * (classCount + 1) + classCount;
      if (next > maxExact) return false;
      maximum = next.toInt();
    }
    return true;
  }

  Object encode(List<int> selected) {
    if (!packed) return selected.join(',');
    var encoded = 1;
    for (final index in selected) {
      encoded = encoded * base + index + 1;
    }
    return encoded;
  }
}

class _CachedMatch {
  final List<int>? ids;
  const _CachedMatch(this.ids);
}

/// Request-local canonical witnesses; support/source changes do not affect matching.
class BondCeMatchCache {
  final List<BondCeSource> sources;
  final Set<int> fixedIdentities;
  final int capacity;
  final BondCeMatchKey keys;
  final _entries = <Object, _CachedMatch>{};
  BondCeMatchCache(this.sources, this.fixedIdentities, {required int maxSlots, this.capacity = 4096})
    : keys = BondCeMatchKey(sources.length, maxSlots);
  int get length => _entries.length;
  List<int>? match(List<int> selected) {
    if (selected.isEmpty) return const [];
    final key = keys.encode(selected);
    final cached = _entries[key];
    if (cached != null) return cached.ids;
    final matched = matchBondCeIds(sources, fixedIdentities, selected);
    if (_entries.length >= capacity) return matched;
    final entry = _CachedMatch(matched == null ? null : List<int>.unmodifiable(matched));
    _entries[key] = entry;
    return entry.ids;
  }
}
