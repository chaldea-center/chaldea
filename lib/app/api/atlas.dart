import 'dart:convert';
import 'dart:typed_data';

import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/rate_limiter.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:crclib/catalog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../models/models.dart';

String _url2uuid(String url) => const Uuid().v5(Uuid.NAMESPACE_URL, url);

class _CachedInfo {
  String url;
  int statusCode;
  String crc;
  int timestamp; // in seconds
  String fp;

  String get key => _url2uuid(url);

  _CachedInfo({
    required this.url,
    required this.statusCode,
    required this.crc,
    required this.timestamp,
    required this.fp,
  });

  factory _CachedInfo.fromJson(Map<String, dynamic> data) {
    return _CachedInfo(
      url: data['url'] as String,
      statusCode: data['statusCode'] as int,
      crc: data['crc'] as String,
      timestamp: data['timestamp'] as int,
      fp: data['fp'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'url': url,
        'statusCode': statusCode,
        'crc': crc,
        'timestamp': timestamp,
        'fp': fp,
      };
}

class _CacheManager {
  bool _initiated = false;
  final String cacheKey;
  final List<int> statusCodes;
  final Map<String, _CachedInfo> _data = {};
  final Map<String, List<int>> _memoryCache = {};

  LazyBox<Uint8List>? _webBox;

  _CacheManager(this.cacheKey, {this.statusCodes = const [200]});

  Future<void> init() async {
    _data.clear();
    String fp = kIsWeb
        ? 'api_cache/$cacheKey.json'
        : joinPaths(db2.paths.tempDir, 'api_cache/$cacheKey.json');
    try {
      if (kIsWeb) {
        _webBox = await Hive.openLazyBox('api_cache');
      }
      final file = FilePlus(fp);
      if (file.existsSync()) {
        for (final jsonData in jsonDecode(await file.readAsString())) {
          final entry = _CachedInfo.fromJson(jsonData);
          _data[entry.key] = entry;
        }
      }
    } catch (e, s) {
      logger.e('init api cache manager ($cacheKey)', e, s);
    }
  }

  Future<void> removeUrl(String url) async {
    final key = _url2uuid(url);
    try {
      final fp = _data[key]?.fp;
      if (fp != null) {
        await _getCacheFile(key).delete();
        _data.remove(key);
      }
    } catch (e, s) {
      logger.e('failed to remove api cache: $url', e, s);
    }
  }

  static final RateLimiter _rateLimiter = RateLimiter();

  Future<List<int>?> _download(String url) async {
    print('fetching Atlas API: $url');
    final response = await Dio().get<List<int>>(url,
        options: Options(responseType: ResponseType.bytes));
    if (statusCodes.contains(response.statusCode) && response.data != null) {
      try {
        await _saveEntry(url, response);
      } catch (e, s) {
        logger.e('save cache entry failed', e, s);
      }
      return response.data;
    } else {
      print('fetch api [$url] failed: ${response.data}');
    }
    return null;
  }

  FilePlus _getCacheFile(String key) {
    return FilePlus(
        kIsWeb
            ? '$cacheKey/$key'
            : joinPaths(db2.paths.tempDir, '$cacheKey/$key'),
        box: _webBox);
  }

  Future<void> _saveEntry(String url, Response<List<int>> response) async {
    final key = _url2uuid(url);
    final bytes = response.data!;
    final file = _getCacheFile(key);

    final crc = Crc32Xz().convert(bytes).toString();
    _memoryCache[key] = bytes;

    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    final fp = _getCacheFile(key).path;
    print('caching api $url to $fp');
    _data[key] = _CachedInfo(
      url: url,
      statusCode: response.statusCode!,
      crc: crc,
      timestamp: DateTime.now().timestamp,
      fp: fp,
    );
  }

  /// [expireAfter]
  ///   * null: (default) use memory cache if possible
  ///   * 0: always fetch new
  ///   * >-: expiration in seconds
  bool _isExpired(String key, int timestamp, Duration? expireAfter) {
    if (expireAfter == Duration.zero) {
      return true;
    }
    if (expireAfter == null && _memoryCache[key] != null) {
      return false;
    }
    return (DateTime.now().timestamp - timestamp) >=
        (expireAfter?.inSeconds ?? 0);
  }

  Future<List<int>?> get(String url, {Duration? expireAfter}) async {
    final key = _url2uuid(url);
    try {
      if (!_initiated) {
        await init();
        _initiated = true;
      }
      final entry = _data[key];
      if (entry != null) {
        final file = FilePlus(entry.fp, box: _webBox);
        if (!_isExpired(key, entry.timestamp, expireAfter)) {
          final bytes = _memoryCache[key] ?? await file.readAsBytes();
          if (Crc32Xz().convert(bytes).toString() == entry.crc) {
            return SynchronousFuture(bytes);
          }
        }
        _data.remove(key);
        await file.delete();
      }
      return _rateLimiter.limited<List<int>?>(() => _download(url));
    } catch (e, s) {
      _data.remove(key);
      logger.e('get api cache failed', e, s);
    }
    return null;
  }

  Future<dynamic> getJson(String url, {Duration? expireAfter}) async {
    dynamic result;
    try {
      result = await get(url, expireAfter: expireAfter);
      if (result != null) {
        return jsonDecode(utf8.decode(result));
      }
    } catch (e, s) {
      if (e is DioError) {
        logger.e('fetch $url', e.getShownError());
      } else {
        logger.e('fetch $url', e, s);
      }
      return result;
    }
  }

  Future<T?> getModel<T>(String url, T Function(dynamic) fromJson,
      {Duration? expireAfter}) async {
    try {
      final obj = await getJson(url, expireAfter: expireAfter);
      if (obj != null) return fromJson(obj);
    } catch (e, s) {
      removeUrl(url);
      logger.e('load model($T) failed', e, s);
    }
    return null;
  }
}

class AtlasApi {
  const AtlasApi._();
  static final _CacheManager cacheManager = _CacheManager('atlas_api');

  static const String _atlasApiHost = 'https://api.atlasacademy.io';

  static Future<Quest?> quest(int questId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.toUpper()}/quest/$questId',
      (data) => Quest.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<QuestPhase?> questPhase(int questId, int phase,
      {Region region = Region.jp, Duration? expireAfter}) async {
    // free quests, only phase 3 saved in db
    if (region == Region.jp && expireAfter == null) {
      final quest = db2.gameData.quests[questId];

      final phaseInDb = db2.gameData.questPhases[questId * 100 + phase];

      if (phaseInDb != null) {
        return SynchronousFuture(phaseInDb);
      }

      if (quest != null) {
        final now = DateTime.now().timestamp;
        // main story's main quest:
        //  if just released in 1 month, only cache for 1 day, otherwise 7 days
        if (quest.type == QuestType.main &&
            quest.closedAt > kNeverClosedTimestamp) {
          expireAfter =
              now - quest.openedAt < const Duration(days: 30).inSeconds
                  ? const Duration(days: 1)
                  : const Duration(days: 7);
        } else if (now - quest.closedAt > const Duration(days: 30).inSeconds) {
          expireAfter = const Duration(days: 30);
        }
      }
    }
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.toUpper()}/quest/$questId/$phase',
      (data) => QuestPhase.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<MasterMission>?> masterMissions(
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.toUpper()}/nice_master_mission.json',
      (data) => List.generate((data as List).length,
          (index) => MasterMission.fromJson(data[index])),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceWar?> war(int warId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.toUpper()}/war/$warId',
      (data) => NiceWar.fromJson(data),
      expireAfter: expireAfter,
    );
  }
}

extension _DioErrorX on DioError {
  String getShownError() {
    final buffer = StringBuffer(message);
    if (response != null) {
      buffer.write(' :');
      if (response!.data is List<int>) {
        try {
          buffer.write(utf8.decode(response!.data));
        } catch (e) {
          //
        }
      } else {
        buffer.write(response!.data.toString());
      }
    }
    return buffer.toString();
  }
}
