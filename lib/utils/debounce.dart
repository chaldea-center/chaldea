/// https://pub.dev/packages/easy_debounce

import 'dart:async';

typedef EasyDebounceCallback = void Function();

class _EasyDebounceOperation {
  EasyDebounceCallback callback;
  Timer timer;

  _EasyDebounceOperation(this.callback, this.timer);
}

/// run task at the end
class EasyDebounce {
  static final Map<String, _EasyDebounceOperation> _operations = {};

  static void debounce(String tag, Duration duration, EasyDebounceCallback onExecute) {
    if (duration == Duration.zero) {
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExecute();
    } else {
      _operations[tag]?.timer.cancel();

      _operations[tag] = _EasyDebounceOperation(
        onExecute,
        Timer(duration, () {
          _operations[tag]?.timer.cancel();
          _operations.remove(tag);

          onExecute();
        }),
      );
    }
  }

  static void fire(String tag) {
    _operations[tag]?.callback();
  }

  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  static void cancelAll() {
    for (final operation in _operations.values) {
      operation.timer.cancel();
    }
    _operations.clear();
  }

  static int count() {
    return _operations.length;
  }
}

/// run task instantly
class EasyThrottle {
  EasyThrottle._();
  static final Map<String, DateTime> _operations = {};

  static void throttle(String tag, Duration duration, EasyDebounceCallback onExecute) {
    final op = _operations[tag];
    final now = DateTime.now();
    if (op == null || now.difference(op) > duration) {
      _operations[tag] = now;
      onExecute();
    } else {
      _operations.remove(tag);
    }
  }

  static final Map<String, Completer> _tasks = {};

  static Future<T> throttleAsync<T>(String tag, Future<T> Function() onExecute) {
    Completer<T>? completer = _tasks[tag] as Completer<T>?;
    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer<T>();
    _tasks[tag] = completer;
    onExecute()
        .then((value) => completer!.complete(value), onError: completer.completeError)
        .whenComplete(() => _tasks.remove(tag));
    return completer.future;
  }

  static void cancel(String tag) {
    _operations.remove(tag);
  }

  static void cancelAll() {
    _operations.clear();
  }
}
