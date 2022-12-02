import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:crclib/catalog.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/rate_limiter.dart';
import 'package:chaldea/utils/hive_extention.dart';
import 'package:chaldea/utils/utils.dart';
import '../../models/models.dart';
import 'hosts.dart';

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
  final List<int> statusCodes = const [200];
  final Map<String, _CachedInfo> _data = {};
  final Map<String, List<int>> _memoryCache = {};
  final Map<String, Completer<List<int>?>> _downloading = {};

  LazyBox<Uint8List>? _webBox;
  late final FilePlus _infoFile;

  _CacheManager(this.cacheKey);

  Completer? _initCompleter;

  Future<void> clearCache() async {
    _memoryCache.clear();
    _data.clear();
    _downloading.clear();
    await _saveCacheInfo();
  }

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer();
    try {
      _data.clear();
      _infoFile = FilePlus(kIsWeb
          ? 'api_cache/$cacheKey.json'
          : joinPaths(db.paths.tempDir, 'api_cache/$cacheKey.json'));
      if (kIsWeb) {
        _webBox = await Hive.openLazyBoxRetry('api_cache');
      }
      if (_infoFile.existsSync()) {
        Map.from(jsonDecode(await _infoFile.readAsString()))
            .forEach((key, value) {
          _data[key] = _CachedInfo.fromJson(value);
        });
      }
    } catch (e, s) {
      logger.e('init api cache manager ($cacheKey)', e, s);
    } finally {
      _initCompleter!.complete();
    }
  }

  void saveCacheInfo() {
    EasyDebounce.debounce('_CacheManager_saveCacheInfo',
        const Duration(seconds: 10), _saveCacheInfo);
  }

  Future<void> _saveCacheInfo() async {
    try {
      await _infoFile.create(recursive: true);
      await _infoFile.writeAsString(jsonEncode(_data));
    } catch (e, s) {
      logger.e('Save Api Cache info failed', e, s);
    }
  }

  Future<void> removeUrl(String url) async {
    final key = _url2uuid(url);
    try {
      final fp = _data[key]?.fp;
      if (fp != null) {
        await _getCacheFile(key).delete();
        _data.remove(key);
        saveCacheInfo();
      }
    } catch (e, s) {
      logger.e('failed to remove api cache: $url', e, s);
    }
  }

  void removeWhere(bool Function(_CachedInfo info) test) {
    _data.removeWhere((key, info) {
      final remove = test(info);
      if (remove) {
        _memoryCache.remove(info.key);
        _downloading.remove(info.url);
      }
      return remove;
    });
  }

  final RateLimiter _rateLimiter = RateLimiter();

  Future<List<int>?> _download(String url) async {
    print('fetching Atlas API: $url');
    final _t = StopwatchX(url);
    final response = await DioE().get<List<int>>(url,
        options: Options(responseType: ResponseType.bytes));
    _t.log();
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
      kIsWeb ? '$cacheKey/$key' : joinPaths(db.paths.tempDir, '$cacheKey/$key'),
      box: _webBox,
    );
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
    saveCacheInfo();
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
        await file.delete().catchError((e, s) => null);
      }
      if (_downloading[url] != null) {
        return _downloading[url]!.future;
      } else {
        Completer<List<int>?> _completer = Completer();
        _rateLimiter.limited<List<int>?>(() => _download(url)).then((value) {
          _downloading.remove(url);
          _completer.complete(value);
        }).catchError((e, s) {
          _downloading.remove(url);
          _completer.complete(null);
        });
        _downloading[url] = _completer;
        return _completer.future;
      }
    } catch (e, s) {
      _data.remove(key);
      logger.e('get api cache failed', e, s);
    }
    return null;
  }

  static const dwReplace = {"\ue000": "{jin}", "\ue001": "鯖"};

  Future<dynamic> getJson(String url, {Duration? expireAfter}) async {
    dynamic result;
    try {
      result = await get(url, expireAfter: expireAfter);
      if (result != null) {
        String text = utf8.decode(result);
        dwReplace.forEach((key, value) {
          text = text.replaceAll(key, value);
        });
        text = text.replaceAll('\ue000', '{jin}');
        if (url.contains('/CN/')) {
          String cnText = text;
          db.gameData.mappingData.cnReplace.forEach((key, value) {
            cnText = cnText.replaceAll(key, value);
          });
          try {
            return jsonDecode(cnText);
          } catch (e) {
            //
          }
        }
        return jsonDecode(text);
      }
    } catch (e, s) {
      logger.e('fetch $url', e, s);
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
  static final Map<String, QuestPhase> cachedQuestPhases = {};

  static RateLimiter get rateLimiter => cacheManager._rateLimiter;

  static String get _atlasApiHost => Hosts.atlasApiHost;

  static Future<void> clear() async {
    cachedQuestPhases.clear();
    await cacheManager.clearCache();
  }

  static Future<Map<String, dynamic>?> regionInfo(
      {Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/info',
      (data) => data[region.upper],
      expireAfter: expireAfter,
    );
  }

  static Future<Quest?> quest(int questId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/quest/$questId',
      (data) => Quest.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<QuestPhase?> questPhase(int questId, int phase,
      {Region region = Region.jp, Duration? expireAfter}) async {
    // free quests, only phase 3 saved in db
    if (region == Region.jp && expireAfter == null) {
      final questJP = db.gameData.quests[questId];

      final phaseInDb = db.gameData.questPhases[questId * 100 + phase];

      if (phaseInDb != null) {
        return SynchronousFuture(phaseInDb);
      }

      if (questJP != null) {
        final now = DateTime.now().timestamp;
        // main story's main quest:
        //  if just released in 1 month
        if (questJP.type == QuestType.main &&
            questJP.closedAt > kNeverClosedTimestamp) {
          expireAfter =
              now - questJP.openedAt < const Duration(days: 30).inSeconds
                  ? const Duration(days: 3)
                  : const Duration(days: 15);
        } else if (now > questJP.closedAt) {
          expireAfter = const Duration(days: 15);
        }
      }
    }
    final url = '$_atlasApiHost/nice/${region.upper}/quest/$questId/$phase';
    return cacheManager.getModel(
      url,
      (data) => cachedQuestPhases[url] = QuestPhase.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static QuestPhase? questPhaseCache(int questId, int phase,
      [Region region = Region.jp]) {
    return cachedQuestPhases[
        '$_atlasApiHost/nice/${region.upper}/quest/$questId/$phase'];
  }

  static Future<List<MasterMission>?> masterMissions(
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/nice_master_mission.json',
      (data) => List.generate((data as List).length,
          (index) => MasterMission.fromJson(data[index])),
      expireAfter: expireAfter,
    );
  }

  static Future<MasterMission?> masterMission(int id,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/mm/$id',
      (data) => MasterMission.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceWar?> war(int warId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/war/$warId',
      (data) => NiceWar.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Event?> event(int eventId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/event/$eventId',
      (data) => Event.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Servant?> svt(int svtId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/servant/$svtId?lore=true',
      (data) => Servant.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CraftEssence?> ce(int ceId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/equip/$ceId?lore=true',
      (data) => CraftEssence.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CommandCode?> cc(int ccId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/CC/$ccId',
      (data) => CommandCode.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceSkill?> skill(int skillId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/skill/$skillId',
      (data) => NiceSkill.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<BaseFunction?> func(int funcId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/function/$funcId',
      (data) => BaseFunction.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Buff?> buff(int buffId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/buff/$buffId',
      (data) => Buff.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceTd?> td(int tdId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/NP/$tdId',
      (data) => NiceTd.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  // export
  static Future<List<BasicServant>?> basicServants(
      {Region region = Region.jp,
      Duration? expireAfter = Duration.zero}) async {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_servant.json',
      (data) => (data as List).map((e) => BasicServant.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCraftEssence>?> basicCraftEssences(
      {Region region = Region.jp,
      Duration? expireAfter = Duration.zero}) async {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_equip.json',
      (data) =>
          (data as List).map((e) => BasicCraftEssence.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCommandCode>?> basicCommandCodes(
      {Region region = Region.jp,
      Duration? expireAfter = Duration.zero}) async {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_command_code.json',
      (data) =>
          (data as List).map((e) => BasicCommandCode.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<Item>?> niceItems(
      {Region region = Region.jp,
      Duration? expireAfter = Duration.zero}) async {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/nice_items.json',
      (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceScript?> script(String scriptId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/script/$scriptId',
      (data) => NiceScript.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceShop?> shop(int shopId,
      {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/shop/$shopId',
      (data) => NiceShop.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<NiceShop>?> searchShop({
    ShopType? type,
    int? eventId,
    PayType? payType,
    Region region = Region.jp,
    Duration? expireAfter,
  }) async {
    if (type == null && eventId == null && payType == null) return [];
    return cacheManager.getModel(
      Uri.parse('$_atlasApiHost/nice/${region.upper}/shop/search')
          .replace(queryParameters: {
        if (type != null) 'type': type.name,
        if (eventId != null) 'eventId': eventId.toString(),
        if (payType != null) 'payType': payType.name,
      }).toString(),
      (data) => (data as List).map((e) => NiceShop.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }
}
