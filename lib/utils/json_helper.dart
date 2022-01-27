import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:worker_manager/worker_manager.dart';

import '../packages/file_plus/file_plus.dart';
import '../packages/logger.dart';

class JsonHelper {
  static Future<T> loadModel<T>({
    required String fp,
    required T Function(dynamic data) fromJson,
    T Function()? onError,
  }) async {
    final file = FilePlus(fp);
    if (!file.existsSync()) {
      if (onError == null) {
        throw OSError('File not found: $fp');
      }
      return onError();
    }
    try {
      final content = await file.readAsString();
      final decoded = content.length < 10e5
          ? jsonDecode(content)
          : await decodeAsync(content);
      return fromJson(decoded);
    } catch (e, s) {
      logger.e('failed to load $T json model', e, s);
      if (onError == null) {
        rethrow;
      }
      return onError();
    }
  }

  static Future<dynamic> decodeAsync<T>(String data) async {
    if (kIsWeb || data.length < 10 * 1024) return jsonDecode(data);
    return Executor().execute(fun1: jsonDecode, arg1: data);
  }

  static Future<dynamic> decodeBytesAsync<T>(List<int> bytes) async {
    if (kIsWeb || bytes.length < 10 * 1024) return _decodeBytes(bytes);
    return Executor().execute(fun1: _decodeBytes, arg1: bytes);
  }

  static dynamic _decodeBytes<T>(List<int> bytes) {
    return jsonDecode(utf8.decode(bytes));
  }
}
