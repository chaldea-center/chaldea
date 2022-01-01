import 'dart:convert';

import '../file_plus/file_plus.dart';
import '../logger.dart';

class LocalStore<T> {
  final String fp;
  final Duration lapse;
  final String? indent;
  Map<String, dynamic> _data = {};

  LocalStore({
    required this.fp,
    this.lapse = const Duration(seconds: 1),
    this.indent,
  });

  LocalStoreItem<S> newItem<S>(String key) => LocalStoreItem<S>(this, key);

  Future<void> load() async {
    final file = FilePlus(fp);
    if (!await file.exists()) {
      _data = {};
      return;
    }
    final contents = await FilePlus(fp).readAsString();
    try {
      _data = Map.from(jsonDecode(contents));
    } catch (e, s) {
      logger.e('fail to decode LocalStore $fp', e, s);
    }
  }

  Future<void> save() async {
    await FilePlus(fp).writeAsString(jsonEncode(_data));
  }

  Future<void> clear() {
    _data.clear();
    return save();
  }

  T? get(String key) {
    final v = _data[key];
    if (v is T?) {
      return v;
    } else {
      return null;
    }
  }

  Future<void> set(String key, T value) {
    _data[key] = value;
    return save();
  }
}

class LocalStoreItem<T> {
  final LocalStore store;
  final String key;

  LocalStoreItem(this.store, this.key);

  T? get() => store.get(key);

  T get2(T _default) => get() ?? _default;

  Future<void> set(T value) => store.set(key, value);
}
