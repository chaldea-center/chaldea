import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/utils/worker_pool_lifecycle.dart';

void main() {
  test('a load lease protects network gaps and all task leases must finish before idle release', () {
    fakeAsync((clock) {
      var disposals = 0;
      final pool = WorkerPoolLifecycle(
        initialize: () async {},
        dispose: () async => disposals++,
        onDisposeError: (e, s) => fail('$e'),
      );
      final releaseLoad = pool.retain();
      unawaited(pool.init());
      clock.flushMicrotasks();
      clock.elapse(const Duration(minutes: 1));
      expect(disposals, 0);
      unawaited(pool.dispose());
      clock.flushMicrotasks();
      expect(disposals, 0);

      final releaseFirst = pool.retain(), releaseSecond = pool.retain();
      releaseLoad();
      releaseFirst();
      releaseFirst(); // A duplicated cleanup cannot release another caller's lease.
      clock.elapse(const Duration(seconds: 20));
      expect(disposals, 0);
      releaseSecond();
      clock.elapse(const Duration(seconds: 9));
      expect(disposals, 0);
      clock.elapse(const Duration(seconds: 1));
      expect(disposals, 1);
    });
  });

  test('new work cancels idle release and a later idle period releases the reused pool', () {
    fakeAsync((clock) {
      var initializations = 0, disposals = 0;
      final pool = WorkerPoolLifecycle(
        initialize: () async => initializations++,
        dispose: () async => disposals++,
        onDisposeError: (e, s) => fail('$e'),
      );
      unawaited(pool.init());
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 9));
      final release = pool.retain();
      unawaited(pool.init());
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 20));
      expect(initializations, 1);
      expect(disposals, 0);
      release();
      clock.elapse(const Duration(seconds: 10));
      expect(disposals, 1);
      unawaited(pool.init());
      clock.flushMicrotasks();
      expect(initializations, 2);
    });
  });

  test('arrivals during disposal wait and share one initialization afterwards', () {
    fakeAsync((clock) {
      var initializations = 0, disposals = 0, arrivalsReady = 0;
      final disposal = Completer<void>();
      final pool = WorkerPoolLifecycle(
        initialize: () async => initializations++,
        dispose: () {
          disposals++;
          return disposal.future;
        },
        onDisposeError: (e, s) => fail('$e'),
      );
      unawaited(pool.init());
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 10));
      expect(disposals, 1);
      final releaseLoad = pool.retain();
      unawaited(pool.init().then((_) => arrivalsReady++));
      unawaited(pool.init().then((_) => arrivalsReady++));
      clock.flushMicrotasks();
      clock.elapse(const Duration(minutes: 1));
      expect(initializations, 1);
      expect(arrivalsReady, 0);
      disposal.complete();
      clock.flushMicrotasks();
      expect(initializations, 2);
      expect(arrivalsReady, 2);
      clock.elapse(const Duration(seconds: 20));
      expect(disposals, 1);
      releaseLoad();
      clock.elapse(const Duration(seconds: 10));
      expect(disposals, 2);
    });
  });

  test('abandoning a load does not dispose shared initialization before it settles', () {
    fakeAsync((clock) {
      final initialization = Completer<void>();
      var disposals = 0;
      final pool = WorkerPoolLifecycle(
        initialize: () => initialization.future,
        dispose: () async => disposals++,
        onDisposeError: (e, s) => fail('$e'),
      );
      final releaseLoad = pool.retain();
      unawaited(pool.init());
      releaseLoad();
      unawaited(pool.dispose());
      clock.elapse(const Duration(minutes: 1));
      expect(disposals, 0);
      initialization.complete();
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 10));
      expect(disposals, 1);
    });
  });

  test('failed initialization finishes cleanup before sharing its error and allowing retry', () {
    fakeAsync((clock) {
      final cleanup = Completer<void>();
      final failure = StateError('initialization failed');
      var initializations = 0, disposals = 0;
      final errors = <Object>[];
      final pool = WorkerPoolLifecycle(
        initialize: () async {
          if (++initializations == 1) throw failure;
        },
        dispose: () {
          disposals++;
          return cleanup.future;
        },
        onDisposeError: (e, s) => fail('$e'),
      );
      unawaited(pool.init().catchError((Object e) => errors.add(e)));
      clock.flushMicrotasks();
      unawaited(pool.init().catchError((Object e) => errors.add(e)));
      clock.flushMicrotasks();
      expect(initializations, 1);
      expect(disposals, 1);
      expect(errors, isEmpty);
      cleanup.complete();
      clock.flushMicrotasks();
      expect(errors, [failure, failure]);
      unawaited(pool.init());
      clock.flushMicrotasks();
      expect(initializations, 2);
    });
  });

  test('failed idle disposal is reported and cleanup is retried before initialization', () {
    fakeAsync((clock) {
      final events = <String>[];
      final errors = <Object>[];
      final pool = WorkerPoolLifecycle(
        initialize: () async => events.add('init'),
        dispose: () async {
          events.add('dispose');
          if (events.length == 2) throw StateError('disposal failed');
        },
        onDisposeError: (e, s) => errors.add(e),
      );
      unawaited(pool.init());
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 10));
      expect(errors, hasLength(1));
      unawaited(pool.init());
      clock.flushMicrotasks();
      expect(events, ['init', 'dispose', 'dispose', 'init']);
    });
  });

  test('initialization and idle timers use the owner zone rather than the load zone', () {
    fakeAsync((clock) {
      final key = Object();
      final callbackZones = <Object?>[];
      final pool = WorkerPoolLifecycle(
        initialize: () async => callbackZones.add(Zone.current[key]),
        dispose: () async => callbackZones.add(Zone.current[key]),
        onDisposeError: (e, s) => fail('$e'),
      );
      runZoned(() => unawaited(pool.init()), zoneValues: {key: 'load'});
      clock.flushMicrotasks();
      clock.elapse(const Duration(seconds: 10));
      expect(callbackZones, [null, null]);
    });
  });
}
