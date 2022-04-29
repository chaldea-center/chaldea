import '../app/api/hosts.dart';
import '../models/models.dart';

class Atlas {
  Atlas._();

  static String get assetHost => Hosts.atlasAssetHost;
  static const String appHost = 'https://apps.atlasacademy.io/db/';
  static const String _dbAssetHost =
      'https://cdn.jsdelivr.net/gh/atlasacademy/apps/packages/db/src/Assets/';

  static bool isAtlasAsset(String url) {
    return url.startsWith(Hosts.kAtlasAssetHostGlobal) ||
        url.startsWith(Hosts.kAtlasAssetHostCN);
  }

  static String proxyAssetUrl(String url) {
    return Hosts.cn && url.startsWith(Hosts.kAtlasAssetHostGlobal)
        ? url.replaceFirst(Hosts.kAtlasAssetHostGlobal, Hosts.kAtlasAssetHostCN)
        : url;
  }

  /// db link
  static String dbUrl(String path, int id, [Region region = Region.jp]) {
    return '$appHost${region.toUpper()}/$path/$id';
  }

  static String dbServant(int id, [Region region = Region.jp]) {
    return dbUrl('servant', id, region);
  }

  static String dbCraftEssence(int id, [Region region = Region.jp]) {
    return dbUrl('craft-essence', id, region);
  }

  static String dbCommandCode(int id, [Region region = Region.jp]) {
    return dbUrl('command-code', id, region);
  }

  static String dbEvent(int id, [Region region = Region.jp]) {
    return dbUrl('event', id, region);
  }

  static String dbWar(int id, [Region region = Region.jp]) {
    return dbUrl('war', id, region);
  }

  static String dbQuest(int id, [int? phase, Region region = Region.jp]) {
    String url = dbUrl('quest', id, region);
    if (phase != null) {
      url += '/$phase';
    }
    return url;
  }

  static String asset(String path, [Region region = Region.jp]) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$assetHost/${region.toUpper()}/$path';
  }

  static String assetItem(int id, [Region region = Region.jp]) {
    return '$assetHost/${region.toUpper()}/Items/$id.png';
  }

  static String dbAsset(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$_dbAssetHost$path';
  }
}
