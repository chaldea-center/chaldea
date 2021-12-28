import 'dart:async';

class _RateLimitTask<T> {
  final Completer<T> completer;
  final FutureOr<T> Function()? onCanceled;

  _RateLimitTask(this.completer, [this.onCanceled]);
}

class RateLimiter {
  final int maxCalls;
  final Duration period;
  final bool raiseOnLimit;

  DateTime _lastReset;

  RateLimiter({
    this.maxCalls = 50,
    this.period = const Duration(seconds: 5),
    this.raiseOnLimit = false,
  }) : _lastReset = DateTime.now();

  final List<_RateLimitTask> _allTasks = [];
  final List<_RateLimitTask> _periodTasks = [];

  bool get isIdle => _allTasks.isEmpty;

  Future<T> limited<T>(Future<T> Function() func,
      {Future<T> Function()? onCanceled}) async {
    final task = _RateLimitTask<T>(Completer(), onCanceled);

    _allTasks.add(task);
    Future.microtask(() async {
      await _wait(task);
      if (task.completer.isCompleted) return;
      try {
        final value = await func();
        if (!task.completer.isCompleted) task.completer.complete(value);
      } catch (e, s) {
        if (!task.completer.isCompleted) task.completer.completeError(e, s);
      } finally {
        _allTasks.remove(task);
      }
    });
    return task.completer.future;
  }

  Future<void> _wait(_RateLimitTask task) async {
    while (true) {
      if (task.completer.isCompleted) return;
      if (_periodTasks.length < maxCalls) {
        _periodTasks.add(task);
        return;
      }
      final remain = period - DateTime.now().difference(_lastReset);
      if (raiseOnLimit) {
        throw RateLimitError(remain);
      }
      await Future.delayed(remain);
      if (_lastReset.add(period).isBefore(DateTime.now())) {
        _periodTasks.removeWhere((e) => e.completer.isCompleted);
        _lastReset = DateTime.now();
      }
    }
  }

  void cancelAll() {
    for (final task in _allTasks) {
      if (task.onCanceled != null) {
        task.completer.complete(task.onCanceled!());
      } else {
        task.completer
            .completeError(RateLimitCancelError(), StackTrace.current);
      }
    }
    _allTasks.clear();
  }
}

class RateLimitCancelError extends Error {}

class RateLimitError extends Error {
  final Duration? periodRemaining;
  RateLimitError([this.periodRemaining]);

  @override
  String toString() {
    return '$runtimeType: wait $periodRemaining';
  }
}
