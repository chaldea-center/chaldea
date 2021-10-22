import 'dart:async';

class RateLimiter {
  final Duration minInterval;
  DateTime? _lastCalled;

  RateLimiter(this.minInterval);

  Future<T> call<T>(FutureOr<T> Function() func) async {
    final now = DateTime.now();
    if (_lastCalled != null) {
      final elapsed = now.difference(_lastCalled!);
      if (elapsed < minInterval) {
        await Future.delayed(minInterval - elapsed);
      }
    }
    _lastCalled = now;
    return func();
  }

// Future<T> debounce<T>(T Function() func);
}
