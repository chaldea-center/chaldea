import 'platform_interface.dart';

class PlatformMethods extends PlatformMethodsInterface {
  @override
  String get href => '';

  @override
  String? getLocalStorage(String key) => throw UnimplementedError();

  @override
  void setLocalStorage(String key, String value) => throw UnimplementedError();

  @override
  bool get rendererCanvasKit => false;

  @override
  void downloadFile(List<int> bytes, String name) {
    // do nothing
  }
}
