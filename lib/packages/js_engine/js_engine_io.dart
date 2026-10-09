import 'dart:async';

import 'package:flutter_js/flutter_js.dart';

import '../../utils/task_observer.dart';
import 'js_engine_interface.dart';

class JsEngine implements JsEngineInterface {
  final JavascriptRuntime engine = TaskObserver.sync('solver.engine.create', () => getJavascriptRuntime(xhr: false));

  JsEngine();

  Completer? _completer;

  @override
  Future<void> init([Function? callback]) async {
    if (_completer != null) return _completer!.future;
    _completer = Completer();
    if (callback != null) await callback();
    _completer!.complete();
  }

  @override
  Future<void> ensureInitiated() {
    assert(() {
      if (_completer == null) {
        throw StateError('$runtimeType must be initiated first!');
      }
      return true;
    }());
    return _completer!.future;
  }

  @override
  Future<String?> eval(String command, {String? name}) async {
    final result = TaskObserver.sync(
      name == 'solver_caller' ? 'solver.engine.solve' : 'solver.engine.script',
      () => engine.evaluateAsync(command),
    );
    return (await result).stringResult;
  }

  @override
  void dispose() {
    engine.dispose();
  }
}
