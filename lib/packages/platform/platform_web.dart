// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js' as js;

import 'platform_interface.dart';

class PlatformMethods extends PlatformMethodsInterface {
  @override
  String get href => html.window.location.href;

  @override
  String? getLocalStorage(String key) => html.window.localStorage[key];

  @override
  void setLocalStorage(String key, String value) =>
      html.window.localStorage[key] = value;

  @override
  bool get rendererCanvasKit {
    var r = js.context['flutterCanvasKit'];
    return r != null;
  }

  @override
  void downloadFile(List<int> bytes, String name) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = name;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
