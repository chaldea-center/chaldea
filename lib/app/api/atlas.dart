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

const kExpireCacheOnly = Duration(days: -999);

class _CachedInfo {
  String url;
  int statusCode;
  String crc;
  int timestamp; // in seconds
  String? fp;

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

class _DownloadingTask {
  String url;
  Completer<List<int>?> completer;
  DateTime startedAt;
  bool canceled;

  _DownloadingTask({
    required this.url,
    required this.completer,
    DateTime? startedAt,
  })  : startedAt = startedAt ?? DateTime.now(),
        canceled = false;

  void cancel() {
    canceled = true;
    completer.complete(null);
  }
}

class ApiCacheManager {
  bool _initiated = false;
  final String? cacheKey;
  final List<int> statusCodes = const [200];
  final Map<String, _CachedInfo> _data = {}; // key=uuid
  final Map<String, List<int>> _memoryCache = {}; // key=uuid
  final Map<String, _DownloadingTask> _downloading = {}; // key=url
  final Map<String, DateTime> _failed = {}; // key=url

  LazyBox<Uint8List>? _webBox;
  late final FilePlus? _infoFile = cacheKey == null
      ? null
      : FilePlus(kIsWeb ? 'api_cache/$cacheKey.json' : joinPaths(db.paths.tempDir, 'api_cache/$cacheKey.json'));

  ApiCacheManager(this.cacheKey);

  Dio Function() createDio = () => DioE();

  Completer? _initCompleter;

  void clearFailed() {
    _failed.clear();
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    _data.clear();
    _downloading.clear();
    _failed.clear();
    await _saveCacheInfo();
  }

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer();
    try {
      _data.clear();
      if (kIsWeb) {
        _webBox = await Hive.openLazyBoxRetry('api_cache');
      }
      if (_infoFile != null && _infoFile!.existsSync()) {
        Map.from(jsonDecode(await _infoFile!.readAsString())).forEach((key, value) {
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
    EasyDebounce.debounce('_CacheManager_saveCacheInfo', const Duration(seconds: 10), _saveCacheInfo);
  }

  Future<void> _saveCacheInfo() async {
    if (_infoFile == null) return;
    try {
      await _infoFile!.create(recursive: true);
      await _infoFile!.writeAsString(jsonEncode(_data));
    } catch (e, s) {
      logger.e('Save Api Cache info failed', e, s);
    }
  }

  Future<void> removeUrl(String url) async {
    final key = _url2uuid(url);
    try {
      final fp = _data[key]?.fp;
      if (fp != null) {
        _data.remove(key);
        final file = _getCacheFile(key);
        if (await file?.exists() == true) {
          await file?.deleteSafe();
        }
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
    if (!kReleaseMode) print('fetching Atlas API: $url');
    final _t = StopwatchX(url);
    final response = await createDio().get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
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

  FilePlus? _getCacheFile(String key) {
    if (cacheKey == null) return null;
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

    await file?.create(recursive: true);
    await file?.writeAsBytes(bytes);
    final fp = _getCacheFile(key)?.path;
    if (!kReleaseMode) print('caching api $url to $fp');
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
    return (DateTime.now().timestamp - timestamp) >= (expireAfter?.inSeconds ?? 0);
  }

  Future<List<int>?> get(String url, {Duration? expireAfter, bool cacheOnly = false}) async {
    final key = _url2uuid(url);
    try {
      if (!_initiated) {
        await init();
        _initiated = true;
      }
      final entry = _data[key];
      if (entry != null) {
        bool fileExist = false;
        FilePlus? file = entry.fp == null ? null : FilePlus(entry.fp!, box: _webBox);
        if (!_isExpired(key, entry.timestamp, expireAfter) || expireAfter == kExpireCacheOnly) {
          List<int>? bytes = _memoryCache[key];
          if (bytes == null) {
            if (file != null) {
              fileExist = file.existsSync();
              if (fileExist) {
                bytes = await file.readAsBytes();
              }
            }
          }
          if (bytes != null && Crc32Xz().convert(bytes).toString() == entry.crc) {
            return SynchronousFuture(bytes);
          }
        }

        _data.remove(key);
        if (fileExist) {
          // may also exist even if it is false when file not checked
          await file?.deleteSafe();
        }
      }
      var prevTask = _downloading[url];
      if (prevTask != null) {
        if (DateTime.now().difference(prevTask.startedAt) < const Duration(seconds: 30)) {
          return prevTask.completer.future;
        }
        print('api cancel timeout: $url');
        _downloading.remove(url);
        prevTask.cancel();
      }

      if (cacheOnly || expireAfter == kExpireCacheOnly) return null;

      print('api get: $url');
      final task = _downloading[url] = _DownloadingTask(url: url, completer: Completer());
      _failed.remove(url);
      _rateLimiter.limited<List<int>?>(() => _download(url)).then((value) {
        _downloading.remove(url);
        _failed.remove(url);
        if (!task.completer.isCompleted) task.completer.complete(value);
        return Future.value();
      }).catchError((e, s) {
        _downloading.remove(url);
        if (!task.completer.isCompleted) task.completer.complete(null);
        if (!task.canceled) _failed[url] = DateTime.now();
        if (kDebugMode) print(escapeDioError(e));
        return Future.value();
      });
      return task.completer.future;
    } catch (e, s) {
      _data.remove(key);
      _downloading.remove(url);
      logger.e('get api cache failed', e, s);
    }
    return null;
  }

  Future<String?> getText(String url, {Duration? expireAfter, bool cacheOnly = false}) async {
    try {
      final data = await get(url, expireAfter: expireAfter, cacheOnly: cacheOnly);
      if (data == null) return null;
      return utf8.decode(data);
    } catch (e, s) {
      logger.e('fetch $url', e, s);
      return null;
    }
  }

  Future<dynamic> getJson(String url, {Duration? expireAfter, bool cacheOnly = false}) async {
    dynamic result;
    try {
      result = await get(url, expireAfter: expireAfter, cacheOnly: cacheOnly);
      if (result != null) {
        String text = utf8.decode(result);
        text = kReplaceDWChars(text);
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

  Future<T?> getModelRaw<T>(String url, T Function(String data) fromText,
      {Duration? expireAfter, bool cacheOnly = false}) async {
    try {
      final text = await getText(url, expireAfter: expireAfter, cacheOnly: true);
      if (text != null) return fromText(text);
    } catch (e, s) {
      removeUrl(url);
      logger.e('load model($T) failed', e, s);
      cacheOnly = false;
    }
    if (cacheOnly) return null;
    try {
      final obj = await getText(url, expireAfter: Duration.zero, cacheOnly: cacheOnly);
      if (obj != null) return fromText(obj);
    } catch (e, s) {
      removeUrl(url);
      logger.e('load model($T) failed', e, s);
    }
    return null;
  }

  Future<T?> getModel<T>(String url, T Function(dynamic data) fromJson,
      {Duration? expireAfter, bool cacheOnly = false}) async {
    try {
      final obj = await getJson(url, expireAfter: expireAfter, cacheOnly: true);
      if (obj != null) return fromJson(obj);
    } catch (e, s) {
      removeUrl(url);
      logger.e('load model($T) failed', e, s);
      cacheOnly = false;
    }
    if (cacheOnly) return null;
    try {
      final obj = await getJson(url, expireAfter: Duration.zero, cacheOnly: cacheOnly);
      if (obj != null) return fromJson(obj);
    } catch (e, s) {
      removeUrl(url);
      logger.e('load model($T) failed', e, s);
    }
    return null;
  }

  static String removeHost(String url) {
    final match = RegExp(r"^https?://([^/]+)(/.+)$", caseSensitive: false).firstMatch(url);
    return match?.group(2) ?? url;
  }

  bool isDownloading(String url, {bool skipHost = false}) {
    if (skipHost) url = removeHost(url);
    if (skipHost) {
      return _downloading.keys.any((e) => removeHost(e) == e);
    }
    return _downloading.containsKey(url);
  }

  bool isFailed(String url, {bool skipHost = false}) {
    if (skipHost) {
      return _failed.keys.any((e) => removeHost(e) == e);
    }
    return _failed.containsKey(url);
  }
}

class AtlasApi {
  const AtlasApi._();
  static final ApiCacheManager cacheManager = ApiCacheManager('atlas_api');
  static final Map<String, QuestPhase> cachedQuestPhases = {};
  static final Set<int> cacheDisabledQuests = {};

  static RateLimiter get rateLimiter => cacheManager._rateLimiter;

  static String get _atlasApiHost => Hosts.atlasApiHost;

  static Future<void> clear() async {
    cachedQuestPhases.clear();
    await cacheManager.clearCache();
  }

  static Future<Map<String, dynamic>?> regionInfo({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/info',
      (data) => data[region.upper],
      expireAfter: expireAfter,
    );
  }

  static Future<Quest?> quest(int questId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/quest/$questId',
      (data) => Quest.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<QuestPhase?> questPhase(int questId, int phase,
      {String? hash, Region region = Region.jp, Duration? expireAfter}) async {
    if (hash != null) hash = hash.trim();
    String url = questPhaseUrl(questId, phase, hash, region);
    QuestPhase? phaseCache;
    if (expireAfter == null) {
      phaseCache = questPhaseCache(questId, phase, hash, region);
      if (phaseCache != null) return SynchronousFuture(phaseCache);
    }
    // free quests, only phase 3 saved in db
    if (region == Region.jp && expireAfter == null) {
      final questJP = db.gameData.quests[questId];
      if (questJP != null) {
        final now = DateTime.now().timestamp;
        // main story's main quest:
        //  if just released in 1 month
        if (questJP.type == QuestType.main && questJP.closedAt > kNeverClosedTimestamp) {
          expireAfter = now - questJP.openedAt < const Duration(days: 30).inSeconds
              ? const Duration(days: 3)
              : const Duration(days: 15);
        } else if (now > questJP.closedAt) {
          expireAfter = const Duration(days: 15);
        }
      }
    }
    return cacheManager.getModel(
      url,
      (data) {
        final quest = QuestPhase.fromJson(data);
        // what if multi-phases are requesting
        if (expireAfter != kExpireCacheOnly) {
          cachedQuestPhases[url] = quest;
        }
        cacheDisabledQuests.remove(questId);
        return quest;
      },
      expireAfter: expireAfter,
    );
  }

  static String questPhaseUrl(int questId, int phase, String? hash, Region region) {
    String url = '$_atlasApiHost/nice/${region.upper}/quest/$questId/$phase';
    if (hash != null) {
      url += '?hash=$hash';
    }
    return url;
  }

  static QuestPhase? questPhaseCache(int questId, int phase, [String? hash, Region region = Region.jp]) {
    if (cacheDisabledQuests.contains(questId)) return null;
    QuestPhase? cache = cachedQuestPhases[questPhaseUrl(questId, phase, hash, region)];
    if (cache == null && region == Region.jp && hash == null) {
      cache = db.gameData.getQuestPhase(questId, phase);
    }
    return cache;
  }

  static Future<List<MasterMission>?> masterMissions({Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/nice_master_mission.json',
      (data) => List.generate((data as List).length, (index) => MasterMission.fromJson(data[index])),
      expireAfter: expireAfter,
    );
  }

  static Future<MasterMission?> masterMission(int id, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/mm/$id',
      (data) => MasterMission.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceWar?> war(int warId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/war/$warId',
      (data) => NiceWar.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Event?> event(int eventId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/event/$eventId',
      (data) => Event.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Servant?> svt(int svtId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/servant/$svtId?lore=true',
      (data) => Servant.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CraftEssence?> ce(int ceId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/equip/$ceId?lore=true',
      (data) => CraftEssence.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CommandCode?> cc(int ccId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/CC/$ccId',
      (data) => CommandCode.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceSkill?> skill(int skillId, {Region region = Region.jp, Duration? expireAfter}) {
    if (skillId <= 0) return Future.value();
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/skill/$skillId',
      (data) => NiceSkill.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<BaseFunction?> func(int funcId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/function/$funcId',
      (data) => BaseFunction.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Buff?> buff(int buffId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/buff/$buffId',
      (data) => Buff.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceTd?> td(int tdId, {Region region = Region.jp, Duration? expireAfter}) {
    if (tdId <= 0) return Future.value();
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/NP/$tdId',
      (data) => NiceTd.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<CommonRelease>?> commonRelease(int releaseId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/common-release/$releaseId',
      (data) => (data as List).map((e) => CommonRelease.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  // export
  static Future<List<BasicServant>?> basicServants({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_servant.json',
      (data) => (data as List).map((e) => BasicServant.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCraftEssence>?> basicCraftEssences(
      {Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_equip.json',
      (data) => (data as List).map((e) => BasicCraftEssence.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCommandCode>?> basicCommandCodes(
      {Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/basic_command_code.json',
      (data) => (data as List).map((e) => BasicCommandCode.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<Item>?> niceItems({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/nice_items.json',
      (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceScript?> script(String scriptId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/script/$scriptId',
      (data) => NiceScript.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<SvtScript>?> svtScript(int charaId, {Region region = Region.jp, Duration? expireAfter}) {
    // charaId can be list
    return cacheManager.getModel(
      '$_atlasApiHost/raw/${region.upper}/svtScript?charaId=$charaId',
      (data) => (data as List).map((e) => SvtScript.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceShop?> shop(int shopId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/nice/${region.upper}/shop/$shopId',
      (data) => NiceShop.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<EnemyMaster>?> enemyMasters({Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$_atlasApiHost/export/${region.upper}/nice_enemy_master.json',
      (data) => (data as List).map((e) => EnemyMaster.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  /// search
  static Future<List<NiceShop>?> searchShop({
    ShopType? type,
    int? eventId,
    PayType? payType,
    Region region = Region.jp,
    Duration? expireAfter,
  }) async {
    if (type == null && eventId == null && payType == null) return [];
    return cacheManager.getModel(
      Uri.parse('$_atlasApiHost/nice/${region.upper}/shop/search').replace(queryParameters: {
        if (type != null) 'type': type.name,
        if (eventId != null) 'eventId': eventId.toString(),
        if (payType != null) 'payType': payType.name,
      }).toString(),
      (data) => (data as List).map((e) => NiceShop.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  // game top
  static Future<GameTops?> gametops({Duration? expireAfter = Duration.zero}) async {
    final tops = await cacheManager.getModel(
      '${Hosts.dataHost}/gametop.json',
      (data) => GameTops.fromJson(data),
      expireAfter: expireAfter,
    );
    if (tops != null) {
      final tasks = <Future>[
        assetbundle(Region.jp, expireAfter: expireAfter)
            .then((v) => tops.jp.assetbundleFolder = v?.folderName ?? tops.jp.assetbundleFolder),
        assetbundle(Region.na, expireAfter: expireAfter)
            .then((v) => tops.na.assetbundleFolder = v?.folderName ?? tops.na.assetbundleFolder),
        gPlayVer(Region.jp).then((v) => tops.jp.appVer = v ?? tops.jp.appVer),
        gPlayVer(Region.na).then((v) => tops.na.appVer = v ?? tops.na.appVer),
      ];
      await Future.wait(tasks);
    }
    return tops;
  }

  static Future<AssetBundleDecrypt?> assetbundle(Region region, {Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      Hosts.proxyWorker(
          'https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${region.upper}/metadata/assetbundle.json'),
      (data) => AssetBundleDecrypt.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<String?> gPlayVer(Region region, {Duration? expireAfter = Duration.zero}) {
    assert(region == Region.jp || region == Region.na);
    String bundleId;
    switch (region) {
      case Region.jp:
        bundleId = 'com.aniplex.fategrandorder';
        break;
      case Region.cn:
        return Future.value(null);
      case Region.tw:
        bundleId = 'com.xiaomeng.fategrandorder';
        break;
      case Region.na:
        bundleId = 'com.aniplex.fategrandorder.en';
        break;
      case Region.kr:
        bundleId = 'com.netmarble.fgok';
        break;
    }
    return cacheManager.getModelRaw(
      '${Hosts.workerHost}/proxy/gplay-ver?id=$bundleId',
      (data) {
        if (RegExp(r'^\d+\.\d+\.\d+$').hasMatch(data)) {
          return data;
        }
        throw ArgumentError(data);
      },
      expireAfter: expireAfter,
    );
  }

  // chaldea
  static Future<RemoteConfig?> remoteConfig({Duration? expireAfter}) {
    return cacheManager.getModel(
      '${Hosts.dataHost}/config.json',
      (data) => RemoteConfig.fromJson(data),
      expireAfter: expireAfter,
    );
  }
}

class CachedApi {
  const CachedApi._();
  static final ApiCacheManager cacheManager = ApiCacheManager(null);

  static Future<Map?> biliVideoInfo({int? aid, String? bvid, Duration? expireAfter}) async {
    if (aid == null && bvid == null) return null;
    String url = 'https://api.bilibili.com/x/web-interface/view?';
    if (aid != null) {
      url += 'aid=$aid';
    } else if (bvid != null) {
      url += 'bvid=$bvid';
    }
    return cacheManager.getModel(
      corsWebOnly(url),
      (data) => Map.from(data),
      expireAfter: expireAfter,
    );
  }

  static String corsWebOnly(String url) {
    if (kIsWeb) return corsProxy(url);
    return url;
  }

  static String corsProxy(String url) {
    return Uri.parse(Hosts.workerHost).replace(path: '/corsproxy/', queryParameters: {'url': url}).toString();
  }
}
