import 'dart:async';
import 'dart:js_interop';

import 'js_engine_interface.dart';

class JsEngine implements JsEngineInterface {
  JsEngine();

  Completer? _completer;

  @override
  Future<void> init([Function? callback]) async {
    if (_completer != null) return _completer!.future;
    _completer = Completer();
    Future<void>.microtask(() async {
      if (callback != null) await callback();
      _completer!.complete();
    }).catchError(_completer!.completeError);
    return _completer!.future;
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
    return _eval(command);
  }

  @override
  void dispose() {}
}

@JS('eval')
external String? _eval(String script);
