import 'dart:convert';

abstract class PlatformMethodsInterface {
  String get href;
  String? getLocalStorage(String key);

  void setLocalStorage(String key, String value);

  void downloadFile(List<int> bytes, String name);

  void downloadString(String text, String name) {
    downloadFile(utf8.encode(text), name);
  }
}
