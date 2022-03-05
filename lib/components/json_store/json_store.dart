import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/packages/packages.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as pathlib;

class JsonStore<T> {
  final String fp;
  final Duration lapse;
  final String? indent;
  Map<String, dynamic> _data = {};

  static final Map<String, JsonStore> _instances = {};

  JsonStore.raw(this.fp, {Duration? lapse, this.indent, bool autoLoad = true})
      : lapse = lapse ?? const Duration(seconds: 10) {
    if (autoLoad) {
      loadSync();
    }
  }

  factory JsonStore(String fp,
      {Duration? lapse, String? indent, bool autoLoad = true}) {
    fp = pathlib.absolute(fp);
    final instance = _instances[fp];
    if (instance is JsonStore<T>) {
      return instance;
    } else {
      return _instances[fp] = JsonStore<T>.raw(fp,
          lapse: lapse, indent: indent, autoLoad: autoLoad);
    }
  }

  String get _boxName => 'json_store_$fp';

  String get _key => 'key';

  Future<void> load() async {
    try {
      if (PlatformU.isWeb) {
        final box = await Hive.openBox(_boxName);
        final content = box.get(_key) ?? '{}';
        _data = _decode(content);
      } else {
        final _file = File(fp);
        if (await _file.exists()) {
          final content = await File(fp).readAsString();
          _data = _decode(content);
        } else {
          _file.createSync(recursive: true);
        }
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
  }

  Future<void> loadSync() async {
    try {
      if (PlatformU.isWeb) {
        return load();
      } else {
        final _file = File(fp);
        if (_file.existsSync()) {
          _data = _decode(File(fp).readAsStringSync());
        } else {
          _file.createSync(recursive: true);
          _file.writeAsStringSync('{}');
        }
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
    return Future.value();
  }

  Future<void> saveSync() async {
    try {
      if (PlatformU.isWeb) {
        Hive.openBox(_boxName).then((box) {
          box.put(_key, _encode());
        });
      } else {
        File(fp).writeAsStringSync(_encode());
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

  Map<String, dynamic> _decode(String content) {
    try {
      if (content.trim().isEmpty) return {};
      final decoded = json.decode(content);
      if (decoded is Map) {
        return Map.from(decoded);
      }
    } catch (e, s) {
      logger.e('decoding $runtimeType json data failed', e, s);
    }
    return {};
  }

  void clear() {
    _data.clear();
    saveDeferred();
  }

  T? get(String key) {
    final v = _data[key];
    if (v is T?) {
      return v;
    } else {
      return null;
    }
  }

  void set(String key, T value, {bool deferred = true}) {
    _data[key] = value;
    if (deferred) {
      saveDeferred();
    } else {
      saveSync();
    }
  }
}

class JsonStoreItem<T> {
  final JsonStore parent;
  final String key;

  JsonStoreItem(this.parent, this.key);

  T? get() => parent.get(key);

  T get2(T _default) => get() ?? _default;

  void set(T value) => parent.set(key, value);
}
