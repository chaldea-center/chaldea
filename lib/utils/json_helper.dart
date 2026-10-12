import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:worker_manager/worker_manager.dart';

import '../packages/file_plus/file_plus.dart';
import 'constants.dart';
import 'task_observer.dart';

class JsonHelper {
  JsonHelper._();

  static final _executor = workerManager;

  /// Below this size tasks run on the calling isolate: the worker round-trip
  /// and queue wait would outweigh the tiny synchronous cost.
  static const _minWorkerSize = 10 * 1024;

  static Completer<void>? _completer;
  static bool _initiated = false;

  static Future<void> init() {
    if (_initiated) return Future.value();
    if (_completer != null) return _completer!.future;
    final completer = _completer = Completer<void>();
    unawaited(_initialize(completer));
    return completer.future;
  }

  static Future<void> _initialize(Completer<void> completer) async {
    try {
      await workerManager.init();
      _initiated = true;
      completer.complete();
    } catch (e, s) {
      // No jobs are submitted until initialization succeeds. Drop a failed
      // pool so a later explicit retry can initialize again.
      await workerManager.dispose();
      completer.completeError(e, s);
    } finally {
      if (identical(_completer, completer)) _completer = null;
    }
  }

  static Future<void> dispose() async {
    _initiated = false;
    return _executor.dispose();
  }

  static Future<dynamic> decodeString<T>(String data, {JsonWorkerScope? scope}) async {
    scope?.check();
    if (kIsWeb || data.length < _minWorkerSize) {
      return TaskObserver.sync('json.decode', () => _decodeString(data));
    }
    return _onWorker('json.decode', _stringAction(data), scope: scope);
  }

  static Future<dynamic> decodeBytes<T>(List<int> bytes, {JsonWorkerScope? scope}) async {
    scope?.check();
    if (kIsWeb || bytes.length < _minWorkerSize) {
      return TaskObserver.sync('json.decode', () => _decodeBytes(bytes));
    }
    return _onWorker('json.decode', _bytesAction(bytes), scope: scope);
  }

  static Future<dynamic> decodeFile<T>(String fp) async {
    if (kIsWeb) {
      final text = await TaskObserver.wall('json.file.read', () => FilePlus(fp).readAsString());
      return TaskObserver.sync('json.decode', () => _decodeString(text));
    }
    return _onWorker('json.file.decode', () => _decodeFile(fp), kind: TaskTimingKind.wall);
  }

  /// Lowercase md5 hex of [bytes]; large inputs are hashed on a worker isolate.
  static Future<String> md5Hex(List<int> bytes, {JsonWorkerScope? scope}) async {
    scope?.check();
    if (kIsWeb || bytes.length < _minWorkerSize) {
      return TaskObserver.sync('json.md5', () => _md5Hex(bytes));
    }
    return _onWorker('json.md5', _hashAction(bytes), scope: scope);
  }

  static Future<R> _onWorker<R>(
    String task,
    FutureOr<R> Function() action, {
    TaskTimingKind kind = TaskTimingKind.sync,
    JsonWorkerScope? scope,
  }) {
    return TaskObserver.wall('$task.request', () async {
      scope?.check();
      if (scope == null) {
        await init();
      } else {
        await scope.wait(init());
      }
      scope?.check();
      final measured = TaskObserver.enabled;
      final job = _dispatchWorker(action, measured);
      scope?._jobs.add(job);
      dynamic result;
      try {
        result = scope == null ? await job : await scope.wait(job);
      } finally {
        scope?._jobs.remove(job);
      }
      if (!measured) return result as R;
      result = result as _WorkerTiming<R>;
      TaskObserver.record(task, kind, result.elapsedUs, isolate: 'worker', failed: result.failed);
      if (result.failed) {
        Error.throwWithStackTrace(result.error!, result.stack!);
      }
      return result.value as R;
    });
  }

  // Build worker closures outside the scope-owning stack so they only capture
  // transferable input and never the caller's cancellation state.
  static dynamic Function() _stringAction(String data) =>
      () => _decodeString(data);
  static dynamic Function() _bytesAction(List<int> bytes) =>
      () => _decodeBytes(bytes);
  static String Function() _hashAction(List<int> bytes) =>
      () => _md5Hex(bytes);

  static Cancelable<dynamic> _dispatchWorker<R>(FutureOr<R> Function() action, bool measured) {
    if (!measured) return _executor.execute(action);
    return _executor.execute(() => _measureWorker(action));
  }

  /// This callback runs in the worker. Do not access the caller's log sink or
  /// statistics here; return only the result and fixed-size timing metadata.
  static Future<_WorkerTiming<R>> _measureWorker<R>(FutureOr<R> Function() action) async {
    final sw = Stopwatch()..start();
    try {
      final result = action();
      final value = result is Future<R> ? await result : result;
      return _WorkerTiming(value: value, elapsedUs: sw.elapsedMicroseconds);
    } catch (e, s) {
      return _WorkerTiming(elapsedUs: sw.elapsedMicroseconds, error: e, stack: s, failed: true);
    }
  }

  /// Game data may contain private-use placeholder chars, replace them before
  /// parsing so every caller gets the plain text.
  static dynamic _decodeString<T>(String text) {
    return jsonDecode(kReplaceDWChars(text));
  }

  static dynamic _decodeBytes<T>(List<int> bytes) {
    return _decodeString(utf8.decode(bytes));
  }

  static Future<dynamic> _decodeFile<T>(String fp) async {
    return _decodeBytes(await FilePlus(fp).readAsBytes());
  }

  static String _md5Hex(List<int> bytes) {
    return md5.convert(bytes).toString().toLowerCase();
  }
}

/// Owns only one caller's jobs; cancellation leaves unrelated worker jobs alive.
/// Computation has no deadline: slow devices may keep working until the caller
/// explicitly cancels. Initialization is shared and is never disposed here.
class JsonWorkerScope {
  final _jobs = <Cancelable<dynamic>>{};
  final _cancellation = Completer<void>();

  void check() {
    if (_cancellation.isCompleted) throw CanceledError();
  }

  Future<T> wait<T>(Future<T> future) async {
    final value = await Future.any<T>([future, _cancellation.future.then<T>((_) => throw CanceledError())]);
    check();
    return value;
  }

  void cancel() {
    if (_cancellation.isCompleted) return;
    _cancellation.complete();
    for (final job in _jobs.toList()) {
      job.cancel();
    }
  }
}

class _WorkerTiming<R> {
  const _WorkerTiming({this.value, required this.elapsedUs, this.error, this.stack, this.failed = false});

  final R? value;
  final int elapsedUs;
  final Object? error;
  final StackTrace? stack;
  final bool failed;
}
