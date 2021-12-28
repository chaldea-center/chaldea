import 'dart:async';

import 'package:flutter_qjs/flutter_qjs.dart';

import 'js_engine_interface.dart';

class JsEngine implements JsEngineInterface {
  final IsolateQjs engine = IsolateQjs();

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
    return (await engine.evaluate(command, name: name)).toString();
  }

  @override
  void dispose() {
    engine.close();
  }
}
