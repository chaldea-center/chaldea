import 'dart:async';

import 'package:flutter_js/flutter_js.dart';

import 'js_engine_interface.dart';

class JsEngine implements JsEngineInterface {
  final JavascriptRuntime engine = getJavascriptRuntime(xhr: false);

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
    return (await engine.evaluateAsync(command)).stringResult;
  }

  @override
  void dispose() {
    engine.dispose();
  }
}
