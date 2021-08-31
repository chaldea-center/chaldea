import 'json_store.dart';

class LocalAppConfig extends JsonStore {
  LocalAppConfig(String fp, {Duration? lapse})
      : super(fp, lapse: lapse, indent: '  ');

  JsonStoreItem<bool> get alwaysOnTop =>
      JsonStoreItem<bool>(this, 'alwaysOnTop');

  JsonStoreItem get windowPos => JsonStoreItem(this, 'windowPos');

  JsonStoreItem<int> get ffoSort => JsonStoreItem<int>(this, 'ffoSort');
}
