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

  static Completer? _completer;
  static bool _initiated = false;

  static Future<void> init() async {
    if (_initiated) return;
    if (_completer != null) return _completer!.future;
    final completer = _completer = Completer();
    try {
      await workerManager.init();
      completer.complete();
      _initiated = true;
    } catch (e, s) {
      completer.completeError(e, s);
    } finally {
      _completer = null;
    }
  }

  static Future<void> dispose() async {
    _initiated = false;
    return _executor.dispose();
  }

  static Future<dynamic> decodeString<T>(String data) async {
    if (kIsWeb || data.length < _minWorkerSize) {
      return TaskObserver.sync('json.decode', () => _decodeString(data));
    }
    return _onWorker('json.decode', () => _decodeString(data));
  }

  static Future<dynamic> decodeBytes<T>(List<int> bytes) async {
    if (kIsWeb || bytes.length < _minWorkerSize) {
      return TaskObserver.sync('json.decode', () => _decodeBytes(bytes));
    }
    return _onWorker('json.decode', () => _decodeBytes(bytes));
  }

  static Future<dynamic> decodeFile<T>(String fp) async {
    if (kIsWeb) {
      final text = await TaskObserver.wall('json.file.read', () => FilePlus(fp).readAsString());
      return TaskObserver.sync('json.decode', () => _decodeString(text));
    }
    return _onWorker('json.file.decode', () => _decodeFile(fp), kind: TaskTimingKind.wall);
  }

  /// Lowercase md5 hex of [bytes]; large inputs are hashed on a worker isolate.
  static Future<String> md5Hex(List<int> bytes) async {
    if (kIsWeb || bytes.length < _minWorkerSize) {
      return TaskObserver.sync('json.md5', () => _md5Hex(bytes));
    }
    return _onWorker('json.md5', () => _md5Hex(bytes));
  }

  static Future<R> _onWorker<R>(
    String task,
    FutureOr<R> Function() action, {
    TaskTimingKind kind = TaskTimingKind.sync,
  }) {
    return TaskObserver.wall('$task.request', () async {
      await init();
      if (!TaskObserver.enabled) return _executor.execute(action);
      final result = await _executor.execute(() => _measureWorker(action));
      TaskObserver.record(task, kind, result.elapsedUs, isolate: 'worker', failed: result.failed);
      if (result.failed) Error.throwWithStackTrace(result.error!, result.stack!);
      return result.value as R;
    });
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

class _WorkerTiming<R> {
  const _WorkerTiming({this.value, required this.elapsedUs, this.error, this.stack, this.failed = false});

  final R? value;
  final int elapsedUs;
  final Object? error;
  final StackTrace? stack;
  final bool failed;
}
