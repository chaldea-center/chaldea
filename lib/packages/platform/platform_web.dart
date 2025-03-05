import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:web/web.dart' as web;

import 'platform_interface.dart';

class PlatformMethods extends PlatformMethodsInterface {
  @override
  String get href => web.window.location.href;

  @override
  String? getLocalStorage(String key) => web.window.localStorage.getItem(key);

  @override
  void setLocalStorage(String key, String value) => web.window.localStorage.setItem(key, value);

  @override
  void downloadFile(List<int> bytes, String name) {
    final xfile = XFile.fromData(Uint8List.fromList(bytes), name: name);
    xfile.saveTo('');
  }
}
