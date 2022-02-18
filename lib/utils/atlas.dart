import '../models/models.dart';

class Atlas {
  Atlas._();
  static const String assetHost = 'https://static.atlasacademy.io/';
  static const String appHost = 'https://apps.atlasacademy.io/db/';
  static const String _dbAssetHost =
      'https://cdn.jsdelivr.net/gh/atlasacademy/apps/packages/db/src/Assets/';
  static String asset(String path, [Region region = Region.jp]) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$assetHost${region.toUpperCase()}/$path';
  }

  static String servant(int id, [Region region = Region.jp]) {
    return '$appHost${region.toUpperCase()}/servant/$id';
  }

  static String dbAsset(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$_dbAssetHost$path';
  }
}
