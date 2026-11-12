import 'dart:math' as math;

/// Counts class multisets split between two slot types, including empty slots.
///
/// A class's capacity is shared between both types. Cross-class identity
/// overlap and COST are relaxed, so the count is an upper bound on feasible
/// combinations. Counts saturate at [limit] + 1 to bound arithmetic.
int bondCeCombinationUpper({
  required List<int> capacities,
  required int slots1,
  required int slots3,
  required int limit,
}) {
  if (slots1 < 0 || slots3 < 0 || limit < 0 || capacities.any((c) => c < 0)) {
    throw ArgumentError('negative combination dimensions');
  }
  final width = slots3 + 1;
  var counts = List<int>.filled((slots1 + 1) * width, 0);
  counts[0] = 1;
  for (final capacity in capacities) {
    final next = List<int>.filled(counts.length, 0);
    for (var a = 0; a <= slots1; a++) {
      for (var b = 0; b <= slots3; b++) {
        final count = counts[a * width + b];
        if (count == 0) continue;
        for (var x = 0; x <= math.min(capacity, slots1 - a); x++) {
          for (var y = 0; y <= math.min(capacity - x, slots3 - b); y++) {
            final index = (a + x) * width + b + y;
            next[index] = math.min(limit + 1, next[index] + count);
          }
        }
      }
    }
    counts = next;
  }
  return counts.fold<int>(0, (sum, count) => math.min(limit + 1, sum + count));
}
