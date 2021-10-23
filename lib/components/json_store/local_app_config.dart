import 'json_store.dart';

class LocalAppConfig extends JsonStore {
  LocalAppConfig(String fp, {Duration? lapse})
      : super.raw(fp, lapse: lapse, indent: '  ');

  JsonStoreItem<bool> get alwaysOnTop =>
      JsonStoreItem<bool>(this, 'alwaysOnTop');

  JsonStoreItem get windowPos => JsonStoreItem(this, 'windowPos');

  JsonStoreItem<int> get ffoSort => JsonStoreItem<int>(this, 'ffoSort');

  JsonStoreItem<int> get launchTimes => JsonStoreItem<int>(this, 'launchTimes');
}

class PersistentAppConfig extends JsonStore {
  PersistentAppConfig(String fp)
      : super.raw(fp, indent: '  ', lapse: Duration.zero);

  JsonStoreItem get androidUseExternal =>
      JsonStoreItem(this, 'android_use_external');
}
