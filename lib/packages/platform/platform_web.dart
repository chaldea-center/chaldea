// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:js' as js;

import 'platform_interface.dart';

class PlatformMethods implements PlatformMethodsInterface {
  @override
  String? getLocalStorage(String key) => window.localStorage[key];

  @override
  void setLocalStorage(String key, String value) =>
      window.localStorage[key] = value;

  @override
  bool get rendererCanvasKit {
    var r = js.context['flutterCanvasKit'];
    return r != null;
  }
}
