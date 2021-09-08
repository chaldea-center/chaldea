import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:hive/hive.dart';

import '../logger.dart';

class JsonStore<T> {
  final String fp;
  final Duration lapse;
  final String? indent;
  Map<String, dynamic> _data = {};

  JsonStore(this.fp, {Duration? lapse, this.indent})
      : lapse = lapse ?? const Duration(seconds: 10) {
    loadSync();
  }

  String get _boxName => 'json_store_$fp';

  String get _key => 'key';

  Future<void> load() async {
    try {
      if (PlatformU.isWeb) {
        final box = await Hive.openBox(_boxName);
        final content = box.get(_key) ?? '{}';
        _data = json.decode(content) as Map<String, dynamic>;
      } else {
        final _file = File(fp);
        if (await _file.exists()) {
          final content = await File(fp).readAsString();
          _data = json.decode(content) as Map<String, dynamic>;
        } else {
          _file.createSync(recursive: true);
        }
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
  }

  Future<void> loadSync() {
    try {
      if (PlatformU.isWeb) {
        return load();
      } else {
        final _file = File(fp);
        if (_file.existsSync()) {
          final content = File(fp).readAsStringSync();
          _data = json.decode(content) as Map<String, dynamic>;
        } else {
          _file
            ..createSync(recursive: true)
            ..writeAsString('{}');
        }
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
    return Future.value();
  }

  void saveSync() {
    try {
      if (PlatformU.isWeb) {
        Hive.openBox(_boxName).then((box) {
          box.put(_key, _encode());
        });
      } else {
        File(fp).writeAsString(_encode());
      }
    } catch (e, s) {
      logger.e('save JsonStore data failed', e, s);
    }
  }

  Timer? _timer;

  void saveDeferred() async {
    _timer?.cancel();
    _timer = Timer(lapse, () {
      saveSync();
    });
  }

  String _encode() {
    try {
      return JsonEncoder.withIndent(indent, (v) => null).convert(_data);
    } catch (e, s) {
      logger.e('encoding json failed', e, s);
      return '{}';
    }
  }

  void clear() {
    _data.clear();
    saveDeferred();
  }

  T? get<T>(String key) {
    final v = _data[key];
    if (v is T?)
      return v;
    else
      return null;
  }

  void set<T>(String key, T value, {bool deferred = true}) {
    _data[key] = value;
    if (deferred)
      saveDeferred();
    else
      saveSync();
  }
}

class JsonStoreItem<T> {
  final JsonStore parent;
  final String key;

  JsonStoreItem(this.parent, this.key);

  T? get() => parent.get<T>(key);

  void set(T value) => parent.set<T>(key, value);
}
