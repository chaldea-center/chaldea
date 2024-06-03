import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart' show getCrc32;

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/logger.dart';
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
    print('battle_result.result=${jsonEncode(dictionary)}');
    request.addFieldStr('result', network.catMouseGame.encryptBattleResult(dictionary));
    final resp = await request.beginRequestAndCheckError('battle_result');
    lastBattle = curBattle;
    curBattle = null;
    network.mstData.battles.clear();
    return resp;
  }
}

extension FakerAgentX on FakerAgent {
  Future<FResponse> battleSetupWithOptions(AutoBattleOptions info) async {
    final quest = db.gameData.quests[info.questId];
    final mstData = network.mstData;
    if (quest == null) {
      throw Exception('quest ${info.questId} not found');
    }
    if (!quest.phases.contains(info.questPhase)) {
      throw Exception('Invalid phase ${info.questPhase}');
    }
    final userQuest = mstData.userQuest[quest.id];
    if (userQuest != null && userQuest.questPhase > info.questPhase) {
      throw Exception('Latest phase: ${userQuest.questPhase}, cannot start phase ${info.questPhase}');
    }
    if (mstData.userDeck[info.deckId] == null) {
      throw Exception('Deck ${info.deckId} not found');
    }
    final questPhaseEntity = await AtlasApi.questPhase(info.questId, info.questPhase, region: network.user.region);
    if (questPhaseEntity == null) {
      throw Exception('Quest ${info.questId}/${info.questPhase} not found');
    }
    final curAp = mstData.user!.calCurAp();
    switch (questPhaseEntity.consumeType) {
      case ConsumeType.none:
        break;
      case ConsumeType.ap:
        if (curAp < questPhaseEntity.consume) {
          throw Exception('AP not enough: $curAp<${questPhaseEntity.consume}');
        }
        break;
      case ConsumeType.rp:
        throw Exception('BP quest not supported');
      case ConsumeType.item:
        for (final item in questPhaseEntity.consumeItem) {
          final itemNum = mstData.userItem[item.itemId]?.num ?? 0;
          if (itemNum < item.amount) {
            throw Exception('Item not enough: $itemNum<${item.amount}');
          }
        }
        break;
      case ConsumeType.apAndItem:
        if (curAp < questPhaseEntity.consume) {
          throw Exception('AP not enough: $curAp<${questPhaseEntity.consume}');
        }
        for (final item in questPhaseEntity.consumeItem) {
          final itemNum = mstData.userItem[item.itemId]?.num ?? 0;
          if (itemNum < item.amount) {
            throw Exception('Item not enough: $itemNum<${item.amount}');
          }
        }
        break;
    }

    final (follower, followerSvt) = await _getValidSupport(
      questId: info.questId,
      questPhase: info.questPhase,
      useEventDeck: info.useEventDeck,
      supportSvtIds: info.supportSvtIds.toList(),
      supportEquipIds: info.supportCeIds.toList(),
    );
    print({
      "questId": info.questId,
      "questPhase": info.questPhase,
      "activeDeckId": info.deckId,
      "followerId": follower.userId,
      "followerClassId": followerSvt.classId,
      "followerType": follower.type,
      "followerSupportDeckId": followerSvt.supportDeckId,
    });
    return battleSetup(
      questId: info.questId,
      questPhase: info.questPhase,
      activeDeckId: info.deckId,
      followerId: follower.userId,
      followerClassId: followerSvt.classId,
      followerType: follower.type,
      followerSupportDeckId: followerSvt.supportDeckId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required int questId,
    required int questPhase,
    required bool useEventDeck,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
  }) async {
    int refreshCount = 0;

    while (true) {
      final resp = await folowerList(questId: questId, questPhase: questPhase, isEnfoceRefresh: refreshCount > 0);
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
      return battleResult(
        battleId: battleEntity.id,
        battleResult: BattleResultType.win,
        winResult: BattleWinResultType.normal,
        action: BattleDataActionList(
          logs: actionLogs,
          dt: battleEntity.battleInfo!.enemyDeck.last.svts.map((e) => e.uniqueId).toList(),
        ),
        usedTurnArray: List.generate(stageCount, (i) => i == stageCount - 1 ? 1 : 0),
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
