import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart' show getCrc32;

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'request.dart';

class FakerAgent {
  final NetworkManager network;
  FakerAgent({required this.network});
  FakerAgent.s({
    required GameTop gameTop,
    required AutoLoginData user,
  }) : network = NetworkManager(gameTop: gameTop.copy(), user: user);

  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  FResponse? lastResp;

  Future<FResponse> gamedataTop({bool checkAppUpdate = true}) async {
    final request = FRequestBase(network: network, path: '/gamedata/top');
    final fresp = await request.beginRequest();
    if (fresp.data.responses.any((e) => e.fail?['action'] == 'app_version_up')) {
      if (!checkAppUpdate) {
        throw Exception('fgo version updated');
      }
      final newVer = await AtlasApi.gPlayVer(network.gameTop.region);
      if (newVer == null) {
        throw Exception('fgo version updated but resolve new version failed');
      }
      if (AppVersion.parse(newVer) <= AppVersion.parse(network.gameTop.appVer)) {
        throw Exception('fgo version updated but no new version found');
      }
      network.gameTop.appVer = newVer;
      return gamedataTop(checkAppUpdate: false);
    }
    final resp = fresp.data.getResponse('gamedata');
    if (resp.isSuccess()) {
      int dataVer = resp.success!['dataVer']!;
      int dateVer = resp.success!['dateVer']!;
      String assetbundle = resp.success!['assetbundle'] ?? "";
      // String assetbundleKey = resp.success!['assetbundleKey']!;
      if (dataVer > network.gameTop.dataVer) network.gameTop.dataVer = dataVer;
      if (dateVer > network.gameTop.dateVer) network.gameTop.dateVer = dateVer;
      if (assetbundle.isNotEmpty) {
        final assetbundleData = network.catMouseGame.mouseInfoMsgpack(base64Decode(assetbundle));
        final String folderName = assetbundleData['folderName']!;
        network.gameTop.assetbundleFolder = folderName;
        // network.gameTop.assetbundle = assetbundle;
      }
      return fresp;
    } else {
      return fresp.throwError('gamedata');
    }
  }

  Future<FResponse> loginTop() async {
    final request = FRequestBase(network: network, path: '/login/top');
    request.addBaseField();
    if (network.gameTop.region == Region.jp) {
      await request.addSignatureField();
    }
    request.addFieldStr('deviceInfo', network.user.deviceInfo ?? FakerUA.deviceinfo);
    final int lastAccessTime = int.parse(request.paramString['lastAccessTime']!);
    final int userId = int.parse(network.user.auth!.userId);
    int userState = (-lastAccessTime >> 2) ^ userId & network.gameTop.folderCrc;
    request.addFieldInt64('userState', userState);
    request.addFieldStr('assetbundleFolder', network.gameTop.assetbundleFolder);
    request.addFieldInt32('isTerminalLogin', 1);
    if (network.gameTop.region == Region.na) {
      request.addFieldInt32('country', network.user.country.countryId);
    }
    final resp = await network.requestStart(request);
    resp.throwError('login');
    // topLogin = resp;
    final userGame = resp.data.mstData.user;
    if (userGame != null) {
      network.user.userGame = userGame;
    }
    return resp.throwError('login');
  }

  Future<FResponse> homeTop() async {
    final request = FRequestBase(network: network, path: '/home/top');
    return request.beginRequestAndCheckError('home');
  }

  Future<FResponse> folowerList(
      {required int32_t questId, required int32_t questPhase, required bool isEnfoceRefresh}) async {
    final request = FRequestBase(network: network, path: '/follower/list');
    request.addFieldInt32('questId', questId);
    request.addFieldInt32('questPhase', questPhase);
    request.addFieldInt32('refresh', isEnfoceRefresh ? 1 : 0);
    return request.beginRequestAndCheckError('follower_list');
  }

  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num}) async {
    final request = FRequestBase(network: network, path: '/item/recover');
    request.addFieldInt32('recoverId', recoverId);
    request.addFieldInt32('num', num);
    final itemId = mstRecovers[recoverId]?.targetId;
    logger.t(
        'item/recover($recoverId): Item $itemId ${db.gameData.items[itemId]?.lName.l ?? "unknown recover id"} ×$num');
    return request.beginRequestAndCheckError('item_recover');
  }

  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num}) async {
    final request = FRequestBase(network: network, path: '/item/recover');
    request.addFieldInt32('id', id);
    request.addFieldInt32('num', num);
    return request.beginRequest();
  }

  Future<FResponse> battleSetup({
    required int32_t questId,
    required int32_t questPhase,
    required int64_t activeDeckId,
    required int64_t followerId,
    required int32_t followerClassId,
    int32_t itemId = 0,
    int32_t boostId = 0,
    int32_t enemySelect = 0,
    int32_t questSelect = 0,
    int64_t userEquipId = 0,
    required int32_t followerType,
    List<int> routeSelect = const [],
    int32_t followerRandomLimitCount = 0, //?
    String choiceRandomLimitCounts = "{}",
    int32_t followerSpoilerProtectionLimitCount = 4, //?
    required int32_t followerSupportDeckId,
    int32_t campaignItemId = 0,
    int32_t restartWave = 0,
  }) async {
    final request = FRequestBase(network: network, path: '/battle/setup');
    request.addFieldInt32("questId", questId);
    request.addFieldInt32("questPhase", questPhase);
    request.addFieldInt64("activeDeckId", activeDeckId);
    request.addFieldInt64("followerId", followerId);
    request.addFieldInt32("followerClassId", followerClassId);
    request.addFieldInt32("itemId", itemId);
    request.addFieldInt32("boostId", boostId);
    request.addFieldInt32("enemySelect", enemySelect);
    request.addFieldInt32("questSelect", questSelect);
    request.addFieldInt64("userEquipId", userEquipId);
    request.addFieldInt32("followerType", followerType);
    request.addFieldStr("routeSelect", jsonEncode(routeSelect));
    request.addFieldStr("choiceRandomLimitCounts", choiceRandomLimitCounts);
    request.addFieldInt32("followerRandomLimitCount", followerRandomLimitCount);
    request.addFieldInt32("followerSpoilerProtectionLimitCount", followerSpoilerProtectionLimitCount);
    request.addFieldInt32("followerSupportDeckId", followerSupportDeckId);
    request.addFieldInt32("campaignItemId", campaignItemId);
    request.addFieldInt32("restartWave", restartWave);
    final resp = await request.beginRequestAndCheckError('battle_setup');
    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity != null) {
      lastBattle = curBattle ?? battleEntity;
      curBattle = battleEntity;
    }
    return resp;
  }

  Future<FResponse> battleResult({
    required int64_t battleId,
    required BattleResultType battleResult, // 0-none,1-win,2-lose,3-retire
    required BattleWinResultType winResult, // 1 or 1
    String scores = "",
    required BattleDataActionList action,
    List<List<int>> voicePlayedArray = const [], // [[svtId, x],...]
    List<int> aliveUniqueIds = const [], // add this if retire/fail
    List raidResult = const [], // BattleResultRequest.RaidResult[]
    List superBossResult = const [], // BattleResultRequest.SuperBossResult[]
    int32_t elapsedTurn = 1,
    required List<int32_t> usedTurnArray, // win 001, retire 100
    int32_t recordType = 1,
    Map<String, Object> recordJson = const {
      "turnMaxDamage": 0,
      "knockdownNum": 0,
      "totalDamageToAliveEnemy": 0,
    },
    List<Map<String, Object>> firstNpPlayList = const [],
    List<PlayerServantNoblePhantasmUsageDataEntity> playerServantNoblePhantasmUsageData =
        const [], // []/ [{"svtId":403500,"followerType":0,"seqId":403500,"addCount":3}]"
    // required  PlayerServantNoblePhantasmUsageData playerServantNoblePhantasmUsageData,
    Map<int, int> usedEquipSkillDict = const {},
    Map<int, int> svtCommonFlagDict = const {},
    List<int32_t> skillShiftUniqueIdArray = const [],
    List<int64_t> skillShiftNpcSvtIdArray = const [],
    List<int32_t> calledEnemyUniqueIdArray = const [],
    List<int32_t> routeSelectIdArray = const [],
    List<int32_t> dataLostUniqueIdArray = const [],
    List waveInfos = const [],
  }) async {
    final request = FRequestBase(network: network, path: '/battle/result');
    final _battleResult = battleResult.value, _winResult = winResult.value;

    Map<String, Object> dictionary = {
      "battleId": battleId,
      "battleResult": _battleResult,
      "winResult": _winResult,
      "scores": scores,
      "action": action.getSaveData(),
      "raidResult": jsonEncode(raidResult),
      "superBossResult": jsonEncode(superBossResult),
      "elapsedTurn": elapsedTurn,
      "recordType": recordType,
      "recordValueJson": recordJson,
      "tdPlayed": jsonEncode(firstNpPlayList),
      "useTreasureDevices": jsonEncode(playerServantNoblePhantasmUsageData.map((e) => e.getSaveData()).toList()),
      "usedEquipSkillList": usedEquipSkillDict,
      "svtCommonFlagList": svtCommonFlagDict,
      "skillShiftUniqueIds": skillShiftUniqueIdArray,
      "skillShiftNpcSvtIds": skillShiftNpcSvtIdArray,
      "calledEnemyUniqueIds": calledEnemyUniqueIdArray,
      "routeSelect": routeSelectIdArray,
      "dataLostUniqueIds": dataLostUniqueIdArray,
      // "battleStatus": 1393373180,
      // "voicePlayedList": "[]",
      // "usedTurnList": [0, 0, 1]
    };

    int64_t num1 = 0;
    if (raidResult.isNotEmpty) {
      throw ArgumentError.value(raidResult, 'raidResult', 'raidResult is not supported');
    }
    // for(final result in raidResult){
    //   num1 += result.getStatusLong();
    // }
    int64_t num2 = 0;
    if (superBossResult.isNotEmpty) {
      throw ArgumentError.value(superBossResult, 'superBossResult', 'superBossResult is not supported');
    }
    // for(final result in superBossResult){
    //   num2 += result.getStatusLong();
    // }
    int64_t num3 = 0;

    dictionary["aliveUniqueIds"] = aliveUniqueIds;
    for (int num4 in aliveUniqueIds) {
      num3 += num4;
    }

    dictionary['battleStatus'] = getCrc32([
      ...BitConverter.getInt64(network.user.auth!.userIdInt + _battleResult),
      ...BitConverter.getInt64(num1 - 4231125),
      ...BitConverter.getInt64(num3 ~/ 2),
      ...BitConverter.getInt64(battleId - 2147483647),
      ...BitConverter.getInt64(num2 - 2469110),
    ]);
    dictionary['voicePlayedList'] = jsonEncode(voicePlayedArray);
    dictionary['usedTurnList'] = usedTurnArray;
    dictionary['waveInfo'] = "[]";
    logger.t('battle_result.result=${jsonEncode(dictionary)}');
    request.addFieldStr('result', network.catMouseGame.encryptBattleResult(dictionary));
    final resp = await request.beginRequestAndCheckError('battle_result');
    lastBattle = curBattle;
    curBattle = null;
    try {
      lastBattleResultData = BattleResultData.fromJson(resp.data.getResponse('battle_result').success!);
    } catch (e, s) {
      logger.e('parse battle result data failed', e, s);
    }
    network.mstData.battles.clear();
    return resp;
  }
}

extension FakerAgentX on FakerAgent {
  Future<FResponse> battleSetupWithOptions(AutoBattleOptions options) async {
    final region = network.user.region;
    final quest = db.gameData.quests[options.questId];
    final mstData = network.mstData;
    if (quest == null) {
      throw Exception('quest ${options.questId} not found');
    }
    if (!quest.phases.contains(options.questPhase)) {
      throw Exception('Invalid phase ${options.questPhase}');
    }
    final userQuest = mstData.userQuest[quest.id];
    if (userQuest != null && userQuest.questPhase > options.questPhase) {
      throw Exception('Latest phase: ${userQuest.questPhase}, cannot start phase ${options.questPhase}');
    }
    if (mstData.userDeck[options.deckId] == null) {
      throw Exception('Deck ${options.deckId} not found');
    }
    final questPhaseEntity = await AtlasApi.questPhase(options.questId, options.questPhase, region: region);
    if (questPhaseEntity == null) {
      throw Exception('Quest ${options.questId}/${options.questPhase} not found');
    }
    final curAp = mstData.user!.calCurAp();
    if (questPhaseEntity.consumeType.useAp) {
      final consume = options.isHpHalf ? quest.consume ~/ 2 : quest.consume;
      if (curAp < consume) {
        throw Exception('AP not enough: $curAp<${questPhaseEntity.consume}');
      }
    }
    if (questPhaseEntity.consumeType.useItem) {
      for (final item in questPhaseEntity.consumeItem) {
        final itemNum = mstData.userItem[item.itemId]?.num ?? 0;
        if (itemNum < item.amount) {
          throw Exception('Item not enough: $itemNum<${item.amount}');
        }
      }
    }

    int campaignItemId = 0;
    if (options.useCampaignItem) {
      List<UserItemEntity> campaignItems = [];
      final now = DateTime.now().timestamp;
      for (final userItem in mstData.userItem) {
        if (userItem.num <= 0) continue;
        final jpItem = db.gameData.items[userItem.itemId];
        if (jpItem != null && jpItem.type != ItemType.friendshipUpItem) continue;
        final item = region == Region.jp ? jpItem : await AtlasApi.item(userItem.itemId, region: region);
        if (item == null || item.type != ItemType.friendshipUpItem) continue;
        if (item.startedAt < now && item.endedAt > now) {
          campaignItems.add(userItem);
        }
      }
      if (campaignItems.isEmpty) {
        throw Exception('no valid Teapot item found');
      }
      print("Teapot count: ${{for (final x in campaignItems) x.itemId: x.num}}");
      if (campaignItems.length > 1) {
        throw Exception('multiple Teapot items found, why??? (${campaignItems.map((e) => e.itemId).join("/")})');
      }
      campaignItemId = campaignItems.single.itemId;
    }

    final (follower, followerSvt) = await _getValidSupport(
      questId: options.questId,
      questPhase: options.questPhase,
      useEventDeck: options.useEventDeck,
      enforceRefreshSupport: options.enfoceRefreshSupport,
      supportSvtIds: options.supportSvtIds.toList(),
      supportEquipIds: options.supportCeIds.toList(),
    );

    // print({
    //   "questId": options.questId,
    //   "questPhase": options.questPhase,
    //   "activeDeckId": options.deckId,
    //   "followerId": follower.userId,
    //   "followerClassId": followerSvt.classId,
    //   "followerType": follower.type,
    //   "followerSupportDeckId": followerSvt.supportDeckId,
    // });
    return battleSetup(
      questId: options.questId,
      questPhase: options.questPhase,
      activeDeckId: options.deckId,
      followerId: follower.userId,
      followerClassId: followerSvt.classId,
      followerType: follower.type,
      followerSupportDeckId: followerSvt.supportDeckId,
      campaignItemId: campaignItemId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required int questId,
    required int questPhase,
    required bool useEventDeck,
    required bool enforceRefreshSupport,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
  }) async {
    int refreshCount = 0;

    while (true) {
      final resp = await folowerList(
          questId: questId, questPhase: questPhase, isEnfoceRefresh: enforceRefreshSupport || refreshCount > 0);
      if (refreshCount > 0) {
        await Future.delayed(const Duration(seconds: 5));
      }
      refreshCount += 1;
      if (refreshCount > 20) {
        throw Exception('After $refreshCount times refresh, no support svt is valid');
      }
      final followers = resp.data.mstData.userFollower.first.followerInfo;

      for (final follower in followers) {
        for (final svt in useEventDeck ? follower.eventUserSvtLeaderHash : follower.userSvtLeaderHash) {
          if (supportSvtIds.isNotEmpty && !supportSvtIds.contains(svt.svtId)) {
            continue;
          }
          if (supportEquipIds.isNotEmpty && !supportEquipIds.contains(svt.equipTarget1?.svtId)) {
            continue;
          }
          return (follower, svt);
        }
      }
    }
  }

  Future<FResponse> battleResultWithOptions(
      {required BattleEntity battleEntity, required BattleResultType resultType, required String actionLogs}) async {
    final stageCount = battleEntity.battleInfo!.enemyDeck.length;
    if (resultType == BattleResultType.cancel) {
      return battleResult(
        battleId: battleEntity.id,
        battleResult: BattleResultType.cancel,
        winResult: BattleWinResultType.none,
        action: BattleDataActionList(
            logs: "", dt: battleEntity.battleInfo!.enemyDeck.first.svts.map((e) => e.uniqueId).toList()),
        usedTurnArray: List.generate(stageCount, (i) => i == 0 ? 1 : 0),
        aliveUniqueIds: battleEntity.battleInfo!.enemyDeck.expand((e) => e.svts).map((e) => e.uniqueId).toList(),
      );
    } else if (resultType == BattleResultType.win) {
      final usedTurnArray = List.generate(stageCount, (i) => i == stageCount - 1 ? 1 : 0);
      final totalTurns = Maths.sum(usedTurnArray.map((e) => max(1, e)));
      if (actionLogs.isEmpty) {
        actionLogs = List<String>.generate(totalTurns, (i) => const ['1B2B3B', '1B1D2C', '1B1C2B'][i % 3]).join('');
      }
      if (!RegExp(r'^' + (r'[123][BCD]' * totalTurns * 3) + r'$').hasMatch(actionLogs)) {
        throw Exception('Invalid action logs or not match turn length: $usedTurnArray, $actionLogs');
      }
      return battleResult(
        battleId: battleEntity.id,
        battleResult: BattleResultType.win,
        winResult: BattleWinResultType.normal,
        action: BattleDataActionList(
          logs: actionLogs,
          dt: battleEntity.battleInfo!.enemyDeck.last.svts.map((e) => e.uniqueId).toList(),
        ),
        usedTurnArray: usedTurnArray,
      );
    } else {
      throw Exception('resultType=$resultType not supported');
    }
  }
}

// PlayerServantNoblePhantasmUsageData
class PlayerServantNoblePhantasmUsageDataEntity {
  int svtId;
  int followerType;
  int seqId;
  int addCount;
  PlayerServantNoblePhantasmUsageDataEntity({
    required this.svtId,
    required this.followerType,
    required this.seqId,
    required this.addCount,
  });

  Map<String, int> getSaveData() {
    return {
      "svtId": svtId,
      "followerType": followerType,
      "seqId": seqId,
      "addCount": addCount,
    };
  }
}

class BattleDataActionList {
  // commandhistory(uniqueId+commadtype): 1B2B3B1B1D2C1B1C2B
  String logs;
  // current wave's enemy info("u"+uniqueId): u13u14u15
  List<int> dt;
  String hd;
  String data;

  BattleDataActionList({
    required this.logs,
    required this.dt,
    this.hd = "",
    this.data = "",
  });
  // { \"logs\":\"1B2B3B1B1D2C1B1C2B\", \"dt\":\"u13u14u15\", \"hd\":\"\", \"data\":\"\" }
  String getSaveData() {
    final dtStr = dt.map((e) => 'u$e').join();
    return """{ "logs":"$logs", "dt":"$dtStr", "hd":"$hd", "data":"$data" }""";
  }
}

class BitConverter {
  static List<int> getInt32(int32_t value) {
    final data = ByteData(4)..setInt32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  static List<int> getInt64(int64_t value) {
    final data = ByteData(8)..setInt64(0, value, Endian.little);
    return data.buffer.asUint8List();
  }
}
