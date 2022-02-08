import 'dart:async';
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

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
    return (await js.context.callMethod('eval', [command])).toString();
  }

  @override
  void dispose() {}
}
