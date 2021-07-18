import 'package:hive/hive.dart';

class AppConfigBox {
  final Box box;

  AppConfigBox(this.box);

  HiveItem<bool> get alwaysOnTop => HiveItem(box: box, key: 'alwaysOnTop');

  HiveItem get windowPos => HiveItem(box: box, key: 'windowPos');

  HiveItem<int> get ffoSort => HiveItem(box: box, key: 'ffoSort');
}

class HiveItem<T> {
  Box box;
  dynamic key;
  T? defaultValue;
  bool Function(T)? check;

  HiveItem(
      {required this.box, required this.key, this.defaultValue, this.check});

  T? get() {
    final v = box.get(key, defaultValue: defaultValue);
    if (check != null && !check!(v)) {
      return defaultValue;
    }
    return v;
  }

  void put(T value) => box.put(key, value);
}
