import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager extends CacheManager with ImageCacheManager {
  static final Map<String, MyCacheManager> _instances = {};

  /// add loading/downloading delay to not stuck ui when drag scrollbar
  final Duration? delay;

  MyCacheManager._(Config config, [this.delay]) : super(config);

  factory MyCacheManager.singleton(String cacheKey, {Duration? delay}) {
    return _instances[cacheKey] ??= MyCacheManager._(Config(cacheKey), delay);
  }

  @override
  Future<FileInfo?> getFileFromCache(String key,
      {bool ignoreMemCache = false}) async {
    final info =
        await super.getFileFromCache(key, ignoreMemCache: ignoreMemCache);
    if (info == null && delay != null) {
      await Future.delayed(delay!);
    }
    return info;
  }
}
