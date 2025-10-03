import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/packages/rate_limiter.dart';
import 'package:chaldea/utils/utils.dart';
import '../../models/models.dart';
import 'cache.dart';

class AtlasApi {
  const AtlasApi._();
  static final ApiCacheManager cacheManager = ApiCacheManager('atlas_api');
  static final Map<String, QuestPhase> cachedQuestPhases = {};
  static final Set<int> cacheDisabledQuests = {};

  static RateLimiter get rateLimiter => cacheManager.rateLimiter;

  static String get atlasApiHost => HostsX.atlasApiHost;

  static Future<void> clear() async {
    cachedQuestPhases.clear();
    await cacheManager.clearCache();
  }

  static String _tBump(String urlNoQuery, Duration? expireAfter) {
    if (expireAfter == Duration.zero) {
      urlNoQuery += '?t=${DateTime.now().timestamp}';
    }
    return urlNoQuery;
  }

  static Future<RegionInfo?> regionInfo({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$atlasApiHost/raw/${region.upper}/info',
      (data) => RegionInfo.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Quest?> quest(int questId, {Region region = Region.jp, Duration? expireAfter}) {
    if (questId < 0) return Future.value();
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/quest/$questId',
      (data) => Quest.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<QuestPhase?> questPhase(
    int questId,
    int phase, {
    String? hash,
    Region region = Region.jp,
    Duration? expireAfter,
  }) async {
    if (questId <= 0) return Future.value();

    if (hash != null) hash = hash.trim();
    String url = questPhaseUrl(questId, phase, hash, region);
    QuestPhase? phaseCache;
    if (expireAfter == null) {
      phaseCache = questPhaseCache(questId, phase, hash, region);
      if (phaseCache != null) return phaseCache;
    }
    // free quests, only phase 3 saved in db
    if (region == Region.jp && expireAfter == null) {
      final questJP = db.gameData.quests[questId];
      final now = DateTime.now().timestamp;
      if (questJP != null) {
        final dt = now - questJP.openedAt;
        if (dt > 0) {
          expireAfter = Duration(seconds: (dt ~/ 4).clamp(1, 7 * kSecsPerDay));
        }
      }
    }
    return cacheManager.getModel(url, (data) {
      final quest = QuestPhase.fromJson(data);
      // what if multi-phases are requesting
      if (expireAfter != kExpireCacheOnly) {
        cachedQuestPhases[url] = quest;
      }
      cacheDisabledQuests.remove(questId);
      return quest;
    }, expireAfter: expireAfter);
  }

  static String questPhaseUrl(int questId, int phase, String? hash, Region region) {
    String url = '$atlasApiHost/nice/${region.upper}/quest/$questId/$phase';
    if (hash != null) {
      url += '?hash=$hash';
    }
    return url;
  }

  static QuestPhase? questPhaseCache(int questId, int phase, [String? hash, Region region = Region.jp]) {
    if (cacheDisabledQuests.contains(questId)) return null;
    QuestPhase? cache = cachedQuestPhases[questPhaseUrl(questId, phase, hash, region)];
    if (cache == null && region == Region.jp) {
      final dbCache = db.gameData.getQuestPhase(questId, phase);
      if (dbCache != null && (hash == null || dbCache.enemyHash == hash)) {
        cache = dbCache;
      }
    }
    return cache;
  }

  static Future<List<MasterMission>?> masterMissions({Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      _tBump('$atlasApiHost/export/${region.upper}/nice_master_mission.json', expireAfter),
      (data) => List.generate((data as List).length, (index) => MasterMission.fromJson(data[index])),
      expireAfter: expireAfter,
    );
  }

  static Future<MasterMission?> masterMission(int id, {Region region = Region.jp, Duration? expireAfter}) {
    if (id <= 0) return Future.value();
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/mm/$id',
      (data) => MasterMission.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceWar?> war(int warId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/war/$warId',
      (data) => NiceWar.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Event?> event(int eventId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/event/$eventId',
      (data) => Event.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Servant?> svt(int svtId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/servant/$svtId?lore=true',
      (data) => Servant.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CraftEssence?> ce(int ceId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/equip/$ceId?lore=true',
      (data) => CraftEssence.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<CommandCode?> cc(int ccId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/CC/$ccId',
      (data) => CommandCode.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Item?> item(int itemId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/item/$itemId',
      (data) => Item.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceSkill?> skill(int skillId, {Region region = Region.jp, Duration? expireAfter}) {
    if (skillId <= 0) return Future.value();
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/skill/$skillId',
      (data) => NiceSkill.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<BaseSkill?> baseSkill(int skillId, {Region region = Region.jp, Duration? expireAfter}) async {
    if (skillId <= 0) return null;
    BaseSkill? _skill;
    if (region.isJP) _skill = db.gameData.baseSkills[skillId];
    if (_skill != null) return _skill;
    return skill(skillId, region: region, expireAfter: expireAfter);
  }

  static Future<BaseFunction?> func(int funcId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/function/$funcId',
      (data) => BaseFunction.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Buff?> buff(int buffId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/buff/$buffId',
      (data) => Buff.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceTd?> td(int tdId, {int? svtId, Region region = Region.jp, Duration? expireAfter}) {
    if (tdId <= 0) return Future.value();
    String url = '$atlasApiHost/nice/${region.upper}/NP/$tdId';
    if (svtId != null) url += '?svtId=$svtId';
    return cacheManager.getModel(url, (data) => NiceTd.fromJson(data), expireAfter: expireAfter);
  }

  static Future<EventMission?> eventMission(int missionId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/event-mission/$missionId',
      (data) => EventMission.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<Gift>?> gift(int giftId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/gift/$giftId',
      (data) => (data as List).map((e) => Gift.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<CommonRelease>?> commonRelease(int releaseId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/common-release/$releaseId',
      (data) => (data as List).map((e) => CommonRelease.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceAiCollection?> ai(AiType type, int aiId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/ai/${type.name}/$aiId',
      (data) => NiceAiCollection.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BattleMasterImage>?> battleMasterImage(
    int imageId, {
    Region region = Region.jp,
    Duration? expireAfter,
  }) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/battle-master-image/$imageId',
      (data) => (data as List).map((e) => BattleMasterImage.fromJson(Map.from(e))).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BattleMessage>?> battleMessage(int msgId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/battle-message/$msgId',
      (data) => (data as List).map((e) => BattleMessage.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BattleMessageGroup>?> battleMessageGroup(
    int groupId, {
    Region region = Region.jp,
    Duration? expireAfter,
  }) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/battle-message-group/$groupId',
      (data) => (data as List).map((e) => BattleMessageGroup.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<QuestDateRange>?> questDateRange(int rangeId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/raw/${region.upper}/quest-date-range/$rangeId',
      (data) => (data as List).map((e) => QuestDateRange.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  // export
  static Future<List<BasicServant>?> basicServants({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$atlasApiHost/export/${region.upper}/basic_servant.json',
      (data) => (data as List).map((e) => BasicServant.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCraftEssence>?> basicCraftEssences({
    Region region = Region.jp,
    Duration? expireAfter = Duration.zero,
  }) {
    return cacheManager.getModel(
      '$atlasApiHost/export/${region.upper}/basic_equip.json',
      (data) => (data as List).map((e) => BasicCraftEssence.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<BasicCommandCode>?> basicCommandCodes({
    Region region = Region.jp,
    Duration? expireAfter = Duration.zero,
  }) {
    return cacheManager.getModel(
      '$atlasApiHost/export/${region.upper}/basic_command_code.json',
      (data) => (data as List).map((e) => BasicCommandCode.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<Item>?> niceItems({Region region = Region.jp, Duration? expireAfter = Duration.zero}) {
    return cacheManager.getModel(
      '$atlasApiHost/export/${region.upper}/nice_items.json',
      (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceScript?> script(String scriptId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/script/$scriptId',
      (data) => NiceScript.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<SvtScript>?> svtScript(int charaId, {Region region = Region.jp, Duration? expireAfter}) {
    // charaId can be list
    return cacheManager.getModel(
      '$atlasApiHost/raw/${region.upper}/svtScript?charaId=$charaId',
      (data) => (data as List).map((e) => SvtScript.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceShop?> shop(int shopId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/shop/$shopId',
      (data) => NiceShop.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<NiceGacha?> gacha(int gachaId, {Region region = Region.jp, Duration? expireAfter}) {
    return cacheManager.getModel(
      '$atlasApiHost/nice/${region.upper}/gacha/$gachaId',
      (data) => NiceGacha.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<EnemyMaster>?> enemyMasters({Region region = Region.jp, Duration? expireAfter}) {
    return exportedData(
      'nice_enemy_master',
      (data) => (data as List).map((e) => EnemyMaster.fromJson(e)).toList(),
      region: region,
      expireAfter: expireAfter,
    );
  }

  static Future<List<NiceGacha>?> gachas({Region region = Region.jp, Duration? expireAfter}) {
    return exportedData(
      'nice_gacha',
      (data) => (data as List).map((e) => NiceGacha.fromJson(e)).toList(),
      region: region,
      expireAfter: expireAfter,
    );
  }

  /// search
  static Future<List<NiceShop>?> searchShop({
    ShopType? type,
    int? eventId,
    PayType? payType,
    PurchaseType? purchaseType,
    int? limit,
    Region region = Region.jp,
    Duration? expireAfter,
  }) async {
    if (type == null && eventId == null && payType == null) return [];
    return cacheManager.getModel(
      Uri.parse('$atlasApiHost/nice/${region.upper}/shop/search')
          .replace(
            queryParameters: {
              'type': ?type?.name,
              'eventId': ?eventId?.toString(),
              'payType': ?payType?.name,
              'purchaseType': ?purchaseType?.name,
              'limit': ?limit,
            },
          )
          .toString(),
      (data) => (data as List).map((e) => NiceShop.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  // game top
  static Future<GameTops?> gametopsRaw({Duration? expireAfter}) async {
    return cacheManager.getModel(
      '${HostsX.dataHost}/gametop.json',
      (data) => GameTops.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<GameTops?> gametops({Duration? expireAfter}) async {
    final tops = await gametopsRaw(expireAfter: expireAfter);
    if (tops != null) {
      final tasks = <Future>[
        assetbundle(
          Region.jp,
          expireAfter: expireAfter,
        ).then((v) => tops.jp.assetbundleFolder = v?.folderName ?? tops.jp.assetbundleFolder),
        assetbundle(
          Region.na,
          expireAfter: expireAfter,
        ).then((v) => tops.na.assetbundleFolder = v?.folderName ?? tops.na.assetbundleFolder),
        verCode(Region.jp, expireAfter: expireAfter).then((v) {
          if (v == null) return;
          tops.jp.appVer = v.appVer;
          tops.jp.verCode = v.verCode;
        }),
        verCode(Region.na, expireAfter: expireAfter).then((v) {
          if (v == null) return;
          tops.na.appVer = v.appVer;
          tops.na.verCode = v.verCode;
        }),
      ];
      await Future.wait(tasks);
    }
    return tops;
  }

  static Future<AssetBundleDecrypt?> assetbundle(Region region, {Duration? expireAfter}) {
    return cacheManager.getModel(
      HostsX.proxyWorker(
        'https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${region.upper}/metadata/assetbundle.json',
      ),
      (data) => AssetBundleDecrypt.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<T?> mstData<T>(
    String table,
    T Function(dynamic json) fromJson, {
    Region region = Region.jp,
    Duration? expireAfter,
    bool? proxy,
    String? ref,
  }) {
    proxy ??= HostsX.proxy.worker;
    String url;
    if (ref != null) {
      url = "https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/commit/$ref/master/$table.json";
    } else {
      url = "https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${region.upper}/master/$table.json";
    }
    if (proxy) url = HostsX.proxyWorker(url);
    return cacheManager.getModel(
      url,
      fromJson,
      expireAfter: expireAfter,
      options: Options(headers: {if (expireAfter == Duration.zero) HttpHeaders.cacheControlHeader: 'nocache'}),
    );
  }

  static Future<T?> exportedData<T>(
    String name,
    T Function(dynamic json) fromJson, {
    Region region = Region.jp,
    Duration? expireAfter,
  }) {
    return cacheManager.getModel('$atlasApiHost/export/${region.upper}/$name.json', fromJson, expireAfter: expireAfter);
  }

  static Future<GameTimerData?> timerData(Region region, {Duration? expireAfter}) async {
    return cacheManager.getModel(
      _tBump('$atlasApiHost/export/${region.upper}/timer_data.json', expireAfter),
      (data) => GameTimerData.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<GameAppVerCode?> verCode(Region region, {Duration? expireAfter, bool? proxy}) {
    assert(region == Region.jp || region == Region.na || region == Region.kr);
    proxy ??= HostsX.proxy.worker;
    String url = "https://fgo.bigcereal.com/${region.upper}/verCode.txt";
    if (proxy) url = HostsX.proxyWorker(url);
    return cacheManager.getModelRaw(url, (data) {
      Map<String, String> out = {};
      for (final entry in data.split('&')) {
        final values = entry.split('=');
        if (values.length == 2) {
          out[values[0].trim()] = values[1].trim();
        }
      }
      final v = GameAppVerCode.fromJson(out);
      if (RegExp(r'^\d+\.\d+\.\d+$').hasMatch(v.appVer) && v.verCode.length == 64) {
        return v;
      }
      throw FormatException("Unexpected ver code format: $data => ${jsonEncode(out)}");
    }, expireAfter: expireAfter);
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
    return cacheManager.getModelRaw('${HostsX.workerHost}/app-ver/gplay?id=$bundleId', (data) {
      if (RegExp(r'^\d+\.\d+\.\d+$').hasMatch(data)) {
        return data;
      }
      throw ArgumentError(data);
    }, expireAfter: expireAfter);
  }
}
