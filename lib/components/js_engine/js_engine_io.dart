import 'package:flutter_qjs/flutter_qjs.dart';

import 'js_engine_interface.dart' as platform;

class JsEngine implements platform.JsEngineMixin {
  final IsolateQjs engine = IsolateQjs();

  JsEngine();

  @override
  Future<void> init([Function? callback]) async {
    if (callback != null) await callback();
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
