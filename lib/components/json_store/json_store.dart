import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../logger.dart';

class JsonStore<T> {
  final String fp;
  final Duration lapse;
  final String? indent;
  final File _file;
  Map<String, dynamic> _data = {};

  JsonStore(this.fp, {Duration? lapse, this.indent})
      : _file = File(fp),
        lapse = lapse ?? const Duration(seconds: 10) {
    loadSync();
  }

  Future<void> load() async {
    try {
      if (await _file.exists()) {
        final content = await File(fp).readAsString();
        _data = json.decode(content) as Map<String, dynamic>;
      } else {
        _file.createSync(recursive: true);
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
  }

  void loadSync() {
    try {
      if (_file.existsSync()) {
        final content = File(fp).readAsStringSync();
        _data = json.decode(content) as Map<String, dynamic>;
      } else {
        _file
          ..createSync(recursive: true)
          ..writeAsString('{}');
      }
    } catch (e, s) {
      logger.e('Failed loading JsonStore data', e, s);
    }
  }

  void saveSync() {
    try {
      _file.writeAsString(_encode());
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
