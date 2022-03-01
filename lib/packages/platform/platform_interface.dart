abstract class PlatformMethodsInterface {
  String? getLocalStorage(String key);

  void setLocalStorage(String key, String value);

  bool get rendererCanvasKit;
}

enum WebRenderMode {
  auto,
  canvaskit,
  html,
}
