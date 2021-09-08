import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

import 'js_engine_interface.dart' as platform;

class JsEngine implements platform.JsEngineMixin {
  JsEngine();

  @override
  Future<void> init([Function? callback]) async {
    if (callback != null) await callback();
  }

  @override
  Future<String?> eval(String command, {String? name}) async {
    return (await js.context.callMethod('eval', [command])).toString();
  }

  @override
  void dispose() {}
}
