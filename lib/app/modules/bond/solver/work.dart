import 'dart:async';

/// Drives the same resumable work used by synchronous and progressive searches.
class BondWorkScheduler {
  BondWorkScheduler({this.isCancelled, this.slice = const Duration(milliseconds: 10)});
  final bool Function()? isCancelled;
  final Duration slice;
  int longestStepMicroseconds = 0;
  int yields = 0;

  Future<void> run(Iterable<void> work) async {
    final iterator = work.iterator;
    final clock = Stopwatch()..start();
    while (true) {
      if (isCancelled?.call() == true) throw const BondWorkCancelled();
      final before = clock.elapsedMicroseconds;
      if (!iterator.moveNext()) break;
      final step = clock.elapsedMicroseconds - before;
      if (step > longestStepMicroseconds) longestStepMicroseconds = step;
      if (clock.elapsedMicroseconds >= slice.inMicroseconds) {
        yields++;
        // A timer yields to input and frame events, unlike a microtask.
        await Future<void>.delayed(const Duration(milliseconds: 16));
        clock.reset();
      }
    }
    if (isCancelled?.call() == true) throw const BondWorkCancelled();
  }
}

class BondWorkCancelled implements Exception {
  const BondWorkCancelled();
}

/// Stable bottom-up merging also makes large sorts resumable.
Iterable<void> bondSortSteps<T>(List<T> list, int Function(T, T) compare) sync* {
  if (list.length < 2) return;
  var source = List<T>.of(list);
  var target = List<T>.of(list);
  for (var width = 1; width < list.length; width *= 2) {
    for (var start = 0; start < list.length; start += width * 2) {
      final middle = (start + width).clamp(0, list.length);
      final end = (start + width * 2).clamp(0, list.length);
      var left = start, right = middle;
      for (var out = start; out < end; out++) {
        target[out] = left < middle && (right >= end || compare(source[left], source[right]) <= 0)
            ? source[left++]
            : source[right++];
        if (out % 128 == 0) yield null;
      }
    }
    final swap = source;
    source = target;
    target = swap;
  }
  list.setAll(0, source);
}
