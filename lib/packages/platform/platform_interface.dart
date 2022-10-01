import 'dart:convert';

abstract class PlatformMethodsInterface {
  String? getLocalStorage(String key);

  void setLocalStorage(String key, String value);

  bool get rendererCanvasKit;

  void downloadFile(List<int> bytes, String name);

  void downloadString(String text, String name) {
    downloadFile(utf8.encode(text), name);
  }
}

enum WebRenderMode {
  auto,
  canvaskit,
  html,
}
