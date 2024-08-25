import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:worker_manager/worker_manager.dart';

import '../packages/file_plus/file_plus.dart';

class JsonHelper {
  JsonHelper._();

  static final _executor = workerManager;

  static Future<dynamic> decodeString<T>(String data) async {
    if (kIsWeb || data.length < 10 * 1024) return jsonDecode(data);
    return _executor.execute(() => _decodeString(data));
  }

  static Future<dynamic> decodeBytes<T>(List<int> bytes) async {
    if (kIsWeb || bytes.length < 10 * 1024) return _decodeBytes(bytes);
    return _executor.execute(() => _decodeBytes(bytes));
  }

  static Future<dynamic> decodeFile<T>(String fp) async {
    if (kIsWeb) return jsonDecode(await FilePlus(fp).readAsString());
    return _executor.execute(() => _decodeFile(fp));
  }

  static dynamic _decodeBytes<T>(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes));
  }

  static dynamic _decodeString<T>(String text) {
    return jsonDecode(text);
  }

  static Future<dynamic> _decodeFile<T>(String fp) async {
    return jsonDecode(utf8.decode(await FilePlus(fp).readAsBytes()));
  }
}
