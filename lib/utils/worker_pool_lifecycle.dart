import 'dart:async';

/// Keeps a shared pool alive while callers hold leases, then releases it after idle time.
class WorkerPoolLifecycle {
  WorkerPoolLifecycle({
    required Future<void> Function() initialize,
    required Future<void> Function() dispose,
    required this.onDisposeError,
    this.idleDelay = const Duration(seconds: 10),
  }) : _initializeWorkers = initialize,
       _disposeWorkers = dispose;

  final Future<void> Function() _initializeWorkers;
  final Future<void> Function() _disposeWorkers;
  final void Function(Object, StackTrace) onDisposeError;
  final Duration idleDelay;
  final Zone _zone = Zone.current;

  int _leases = 0;
  bool _ready = false;
  bool _needsCleanup = false;
  Timer? _idleTimer;
  Future<void>? _initializing;
  Future<void>? _disposing;

  /// Acquire before any await, including network waits. The release callback is idempotent.
  void Function() retain() {
    _leases++;
    _idleTimer?.cancel();
    _idleTimer = null;
    var released = false;
    return () {
      if (released) return;
      released = true;
      _leases--;
      _scheduleIdleRelease();
    };
  }

  Future<void> init() async {
    final release = retain();
    try {
      if (_initializing != null) return await _initializing;
      if (_ready) return;
      final completer = Completer<void>();
      _initializing = completer.future;
      _zone.run(() => unawaited(_initialize(completer)));
      await completer.future;
    } finally {
      release();
    }
  }

  Future<void> _initialize(Completer<void> completer) async {
    try {
      // A timer can be canceled; disposal already in progress must finish first.
      if (_disposing != null) await _disposing;
      if (_needsCleanup) {
        await _disposeWorkers();
        _needsCleanup = false;
      }
      try {
        await _initializeWorkers();
        _ready = true;
      } catch (e, s) {
        _needsCleanup = true;
        try {
          await _disposeWorkers();
          _needsCleanup = false;
        } catch (cleanupError, cleanupStack) {
          onDisposeError(cleanupError, cleanupStack);
        }
        Error.throwWithStackTrace(e, s);
      }
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
    } finally {
      _initializing = null;
      _scheduleIdleRelease();
    }
  }

  /// Explicit disposal also respects leases and initialization.
  Future<void> dispose() {
    if (_disposing != null) return _disposing!;
    if (_leases != 0 || _initializing != null || (!_ready && !_needsCleanup)) return Future<void>.value();
    _idleTimer?.cancel();
    _idleTimer = null;
    _ready = false;
    final completer = Completer<void>();
    _disposing = completer.future;
    _zone.run(() => unawaited(_dispose(completer)));
    return completer.future;
  }

  Future<void> _dispose(Completer<void> completer) async {
    _needsCleanup = true;
    try {
      await _disposeWorkers();
      _needsCleanup = false;
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
    } finally {
      _disposing = null;
    }
  }

  void _scheduleIdleRelease() {
    if (_leases != 0 || !_ready || _initializing != null || _disposing != null) return;
    _idleTimer?.cancel();
    // Use the owner's zone, not a caller's load zone which may retain a whole dataset.
    _idleTimer = _zone.run(
      () => Timer(idleDelay, () {
        _idleTimer = null;
        unawaited(dispose().catchError(onDisposeError));
      }),
    );
  }
}
