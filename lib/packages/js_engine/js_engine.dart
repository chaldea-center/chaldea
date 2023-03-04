/// There may be some compile error if directly import flutter_qjs in web
export 'js_engine_io.dart' if (dart.library.js) 'js_engine_web.dart' show JsEngine;
