import 'dart:async';

import '../packages/logger.dart';

enum TaskTimingKind { sync, wall, gap }

/// Bounded, local observations of task timing and event-loop delays. Wall time is never CPU time.
class TaskObserver {
  TaskObserver._();

  /// Opt in when building diagnostic runs; ordinary builds stay quiet.
  static bool _enabled = const bool.fromEnvironment('TASK_OBSERVER_ENABLED', defaultValue: false);
  static bool get enabled => _enabled;
  static set enabled(bool value) {
    _enabled = value;
    if (!value) {
      _gapTimer?.cancel();
      _gapTimer = null;
    }
  }

  static const sampleCapacity = 512;
  static const warningThreshold = Duration(milliseconds: 200);
  static const gapInterval = Duration(milliseconds: 10);
  static const summaryInterval = Duration(minutes: 5);
  static const _warningInterval = Duration(seconds: 10);
  static const _maxMetrics = 128;

  static final _clock = Stopwatch()..start();
  static final _metrics = <(String, TaskTimingKind, String), _TaskSamples>{};
  static int _nextSpan = 0;
  static int _lastSummaryUs = 0;
  static int _loadingScopes = 0;
  static Timer? _gapTimer;
  static int _lastTickUs = 0;
  static int _loadingMaxGapUs = 0;
  static int _loadingGapCount = 0;

  static T sync<T>(String task, T Function() action, {String? detail}) {
    if (!enabled) return action();
    final sw = Stopwatch()..start();
    var failed = true;
    try {
      final value = action();
      failed = false;
      return value;
    } finally {
      record(task, TaskTimingKind.sync, sw.elapsedMicroseconds, detail: detail, failed: failed);
    }
  }

  static Future<T> wall<T>(String task, Future<T> Function() action, {String? detail, bool phase = false}) async {
    if (!enabled) return action();
    final span = start(task, detail: detail, phase: phase);
    var failed = true;
    try {
      final value = await action();
      failed = false;
      return value;
    } finally {
      span.finish(failed: failed);
    }
  }

  static TaskSpan start(String task, {String? detail, bool phase = false}) {
    final span = TaskSpan._(task, detail, phase, enabled ? ++_nextSpan : null);
    if (span.id != null && phase) {
      _log('[TaskObserver][phase.begin] id=${span.id} task=$task isolate=main${_detail(detail)}');
    }
    return span;
  }

  /// Worker execution is measured there, but recorded by its caller here.
  static void record(
    String task,
    TaskTimingKind kind,
    int elapsedUs, {
    String isolate = 'main',
    String? detail,
    bool failed = false,
  }) {
    if (!enabled) return;
    try {
      final key = (task, kind, isolate);
      var samples = _metrics[key];
      if (samples == null) {
        if (_metrics.length >= _maxMetrics) return;
        samples = _metrics[key] = _TaskSamples();
      }
      samples.add(elapsedUs, failed);
      if (kind != TaskTimingKind.wall && isolate == 'main' && elapsedUs > warningThreshold.inMicroseconds) {
        final now = _clock.elapsedMicroseconds;
        if (samples.lastWarningUs == null || now - samples.lastWarningUs! >= _warningInterval.inMicroseconds) {
          samples.lastWarningUs = now;
          _log(
            '[TaskObserver][long] task=$task kind=${kind.name} isolate=$isolate '
            'elapsed_us=$elapsedUs failed=$failed${_detail(detail)}',
            warning: true,
          );
        }
      }
    } catch (_) {
      // Observations must never change business results or exception paths.
    }
  }

  static String _detail(String? detail) => detail == null ? '' : ' detail=${detail.replaceAll('\n', ' ')}';

  static void _log(String message, {bool warning = false}) {
    try {
      if (warning) {
        logger.w(message, null, StackTrace.empty);
      } else {
        logger.t(message);
      }
    } catch (_) {
      // The log sink may be closed during shutdown.
    }
  }

  /// The timer is shared by overlapping load scopes and absent otherwise.
  static LoadingObservation observeLoading() {
    if (!enabled) return LoadingObservation._(false);
    _loadingScopes++;
    if (_gapTimer == null) {
      _lastTickUs = _clock.elapsedMicroseconds;
      _loadingMaxGapUs = 0;
      _loadingGapCount = 0;
      _gapTimer = Timer.periodic(gapInterval, (_) {
        final now = _clock.elapsedMicroseconds;
        final gap = now - _lastTickUs;
        _lastTickUs = now;
        if (gap > _loadingMaxGapUs) _loadingMaxGapUs = gap;
        _loadingGapCount++;
        record('loading.event_loop', TaskTimingKind.gap, gap);
      });
    }
    return LoadingObservation._(true);
  }

  static Future<void> _finishLoading() async {
    // Let overdue timer events run before cancellation, including tail blocks.
    await Future<void>.delayed(gapInterval * 2);
    _loadingScopes--;
    if (_loadingScopes != 0) return;
    _gapTimer?.cancel();
    _gapTimer = null;
    if (!enabled) return;
    _log(
      '[TaskObserver][loading.gaps] samples=$_loadingGapCount max_us=$_loadingMaxGapUs interval_us=${gapInterval.inMicroseconds}',
    );
    summary(reason: 'loading.end');
  }

  /// Called from the existing saving heartbeat; creates no periodic timer.
  static void summaryIfDue() {
    if (!enabled || _clock.elapsedMicroseconds - _lastSummaryUs < summaryInterval.inMicroseconds) return;
    summary(reason: 'heartbeat');
  }

  static void summary({required String reason}) {
    if (!enabled) return;
    try {
      _lastSummaryUs = _clock.elapsedMicroseconds;
      for (final entry in _metrics.entries) {
        final (task, kind, isolate) = entry.key;
        final s = entry.value;
        final sorted = s.values.take(s.count < sampleCapacity ? s.count : sampleCapacity).toList()..sort();
        if (sorted.isEmpty) continue;
        int percentile(int percent) => sorted[(sorted.length * percent + 99) ~/ 100 - 1];
        _log(
          '[TaskObserver][summary] reason=$reason task=$task kind=${kind.name} isolate=$isolate '
          'window=recent_$sampleCapacity n=${sorted.length} total=${s.count} failed=${s.failed} '
          'over_200ms=${s.overThreshold} p95_us=${percentile(95)} p99_us=${percentile(99)} '
          'window_max_us=${sorted.last} session_max_us=${s.maxUs}',
        );
      }
    } catch (_) {
      // Keep summary generation independent of the saving heartbeat.
    }
  }
}

class TaskSpan {
  TaskSpan._(this.task, this.detail, this.phase, this.id) : _sw = id == null ? null : (Stopwatch()..start());

  final String task;
  final String? detail;
  final bool phase;
  final int? id;
  final Stopwatch? _sw;
  bool _finished = false;

  void finish({bool failed = false}) {
    if (_finished || id == null) return;
    _finished = true;
    final elapsedUs = _sw!.elapsedMicroseconds;
    TaskObserver.record(task, TaskTimingKind.wall, elapsedUs, detail: detail, failed: failed);
    if (TaskObserver.enabled && phase) {
      TaskObserver._log(
        '[TaskObserver][phase.end] id=$id task=$task kind=wall isolate=main '
        'elapsed_us=$elapsedUs failed=$failed${TaskObserver._detail(detail)}',
      );
    }
  }
}

class LoadingObservation {
  LoadingObservation._(this._active);

  bool _active;

  void finish() {
    if (!_active) return;
    _active = false;
    unawaited(TaskObserver._finishLoading());
  }
}

class _TaskSamples {
  final values = List<int>.filled(TaskObserver.sampleCapacity, 0);
  int count = 0;
  int failed = 0;
  int overThreshold = 0;
  int maxUs = 0;
  int? lastWarningUs;

  void add(int elapsedUs, bool isFailure) {
    values[count % values.length] = elapsedUs;
    count++;
    if (isFailure) failed++;
    if (elapsedUs > TaskObserver.warningThreshold.inMicroseconds) overThreshold++;
    if (elapsedUs > maxUs) maxUs = elapsedUs;
  }
}
