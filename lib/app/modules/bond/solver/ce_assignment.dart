/// One scored placement for an ID. All placements of that ID share one DP stage.
abstract interface class BondAssignmentChoice {
  int get cost;
  int get position;
  int get score;
}

class BondAssignmentPath<T extends BondAssignmentChoice> {
  final BondAssignmentPath<T>? previous;
  final T choice;
  const BondAssignmentPath(this.previous, this.choice);
}

class BondAssignmentState<T extends BondAssignmentChoice> {
  final int score;
  final BondAssignmentPath<T>? path;
  const BondAssignmentState(this.score, this.path);
}

/// Builds the exact mask/COST table, publishing it only after all IDs complete.
/// Ascending mask/COST and choice order preserve the first witness at equal score.
Iterable<void> bondAssignmentSteps<T extends BondAssignmentChoice>({
  required int positions,
  required int budget,
  required Map<int, List<T>> byId,
  required void Function(List<BondAssignmentState<T>?>) onComplete,
}) sync* {
  // Batch cheap transitions; the caller still controls wall-clock slicing.
  var ticks = 0;
  final masks = 1 << positions, width = budget + 1;
  var states = List<BondAssignmentState<T>?>.filled(masks * width, null);
  states[0] = BondAssignmentState<T>(0, null);
  // JS bitwise words are signed. Use 31 bits to keep isolated bits positive.
  const wordBits = 31;
  final wordsPerMask = (width + wordBits - 1) ~/ wordBits;
  final reachable = List<int>.filled(masks * wordsPerMask, 0)..[0] = 1;
  for (final choices in byId.values) {
    if (++ticks % 128 == 0) yield null;
    final next = List<BondAssignmentState<T>?>.of(states);
    // New states must not feed this ID again, including zero-COST placements.
    final sourceReachable = List<int>.of(reachable);
    for (var mask = 0; mask < masks; mask++) {
      if (++ticks % 128 == 0) yield null;
      for (var word = 0; word < wordsPerMask; word++) {
        if (++ticks % 128 == 0) yield null;
        var bits = sourceReachable[mask * wordsPerMask + word];
        while (bits != 0) {
          if (++ticks % 128 == 0) yield null;
          final offset = (bits & -bits).bitLength - 1;
          bits &= bits - 1;
          final cost = word * wordBits + offset;
          final current = states[mask * width + cost]!;
          for (final choice in choices) {
            if (++ticks % 128 == 0) yield null;
            final bit = 1 << choice.position;
            if ((mask & bit) != 0) continue;
            final newCost = cost + choice.cost;
            if (newCost >= width) continue;
            final nextMask = mask | bit;
            final index = nextMask * width + newCost;
            final score = current.score + choice.score;
            final previous = next[index];
            if (previous == null || score > previous.score) {
              if (previous == null) {
                reachable[nextMask * wordsPerMask + newCost ~/ wordBits] |= 1 << (newCost % wordBits);
              }
              next[index] = BondAssignmentState(score, BondAssignmentPath(current.path, choice));
            }
          }
        }
      }
    }
    states = next;
  }
  onComplete(states);
}

class BondAssignmentResult<T> {
  final Map<int, T>? servants;
  const BondAssignmentResult(this.servants);
}

/// Request-local exact results, including infeasibility; full caches keep old entries.
class BondAssignmentCache<T> {
  final int capacity;
  final _entries = <String, BondAssignmentResult<T>>{};
  BondAssignmentCache({this.capacity = 512});

  int get length => _entries.length;
  BondAssignmentResult<T>? operator [](String key) => _entries[key];

  String key(List<int> rates, List<int> values, int budget, int ce1Count) =>
      '$budget/$ce1Count/${rates.join(',')}/${values.join(',')}';

  void remember(String key, Map<int, T>? servants) {
    if (_entries.length >= capacity || _entries.containsKey(key)) return;
    _entries[key] = BondAssignmentResult(servants == null ? null : Map<int, T>.unmodifiable(servants));
  }
}
