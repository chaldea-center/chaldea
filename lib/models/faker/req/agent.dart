import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:archive/archive.dart' show getCrc32;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import 'request.dart';

class FRequestAgent {
  final NetworkManager network;
  FResponse? topLogin;

  FRequestAgent({
    required GameTop gameTop,
    required AutoLoginData user,
  }) : network = NetworkManager(gameTop: gameTop.copy(), user: user);

  Future<void> waitSeconds(int minSec, [int? maxSec, String? msg]) async {
    int milliseconds = minSec * 1000;
    int dx = maxSec != null && maxSec > minSec ? maxSec - minSec : 1;
    milliseconds += (Random().nextDouble() * dx).toInt();
    int dt = 500;
    while (milliseconds > 0) {
      String msg2;
      if (msg == null) {
        msg2 = '${milliseconds ~/ 1000}s';
      } else {
        msg2 = '$msg after ${milliseconds ~/ 1000}s';
      }
      EasyLoading.show(status: msg2, indicator: const SizedBox.shrink());
      await Future.delayed(Duration(milliseconds: min(dt, milliseconds)));
      milliseconds -= dt;
    }
  }

  Future<FResponse> gamedataTop({bool checkAppUpdate = true}) async {
    final request = FRequestBase(network: network, path: '/gamedata/top');
    final fresp = await request.beginRequest();
    final resp = fresp.getResponse('gamedata');
    if (resp.checkError()) {
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
      final detail = resp.fail?['detail'] as String?;
      if (resp.fail?['action'] == 'app_version_up' && checkAppUpdate) {
        final versions =
            RegExp(r'\D(\d+\.\d+\.\d+)\D').allMatches(detail ?? '').map((e) => AppVersion.parse(e.group(1)!)).toList();
        versions.sort((a, b) => b.compareTo(a));
        if (versions.isNotEmpty && versions.first > AppVersion.parse(network.gameTop.appVer)) {
          network.gameTop.appVer = versions.first.versionString;
          return gamedataTop(checkAppUpdate: false);
        }
      }
      return fresp.throwError();
    }
  }

  Future<FResponse> loginTop() async {
    final request = FRequestBase(network: network, path: '/login/top');
    request.addBaseField();
    if (network.gameTop.region == Region.jp) {
      await request.addSignatureField();
    }
    request.addFieldStr('deviceInfo', network.user.deviceInfo ?? UA.deviceinfo);
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
    resp.throwError();
    topLogin = resp;
    final userGame = resp.data?.mstData.userGame.firstOrNull;
    if (userGame != null) {
      network.user.userGame = userGame;
    }
    return resp.throwError();
  }

  Future<FResponse> homeTop() async {
    final request = FRequestBase(network: network, path: '/home/top');
    return request.beginRequestAndCheckError();
  }

  Future<FResponse> folowerList(
      {required int32_t questId, required int32_t questPhase, required bool isEnfoceRefresh}) async {
    final request = FRequestBase(network: network, path: '/follower/list');
    request.addFieldInt32('questId', questId);
    request.addFieldInt32('questPhase', questPhase);
    request.addFieldInt32('refresh', isEnfoceRefresh ? 1 : 0);
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
  }) {
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
    return request.beginRequestAndCheckError();
  }

  Future<FResponse> battleResult({
    required int64_t battleId,
    required int32_t battleResult, // 0-none,1-win,2-lose,3-retire
    required int32_t winResult, // 1 or 1
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
    required List<PlayerServantNoblePhantasmUsageDataEntity>
        playerServantNoblePhantasmUsageData, // []/ [{"svtId":403500,"followerType":0,"seqId":403500,"addCount":3}]"
    // required  PlayerServantNoblePhantasmUsageData playerServantNoblePhantasmUsageData,
    Map<int, int> usedEquipSkillDict = const {},
    Map<int, int> svtCommonFlagDict = const {},
    List<int32_t> skillShiftUniqueIdArray = const [],
    List<int64_t> skillShiftNpcSvtIdArray = const [],
    List<int32_t> calledEnemyUniqueIdArray = const [],
    List<int32_t> routeSelectIdArray = const [],
    List<int32_t> dataLostUniqueIdArray = const [],
  }) {
    final request = FRequestBase(network: network, path: '/battle/result');

    Map<String, Object> dictionary = {
      "battleId": battleId,
      "battleResult": battleResult,
      "winResult": winResult,
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
      ...BitConverter.getInt64(network.user.auth!.userIdInt + battleResult),
      ...BitConverter.getInt64(num1 - 4231125),
      ...BitConverter.getInt64(num3 ~/ 2),
      ...BitConverter.getInt64(battleId - 2147483647),
      ...BitConverter.getInt64(num2 - 2469110),
    ]);
    dictionary['voicePlayedList'] = jsonEncode(voicePlayedArray);
    dictionary['usedTurnList'] = usedTurnArray;
    print(jsonEncode(dictionary));
    final List<int> packed = msgpack.serialize(dictionary);
    final List<int> encryped = network.catMouseGame.catGame5Bytes(packed);
    request.addFieldStr('result', base64Encode(encryped));
    return request.beginRequestAndCheckError();
  }

  Future<(int battleResult, Map<int, int> drops, FResponse resp)> startBattle({
    String msgPrefix = "Battle:",
    required int questId,
    required int questPhase,
    required int activeDeckId,
    required bool useEventDeck,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
    required Map<int, int> targetDropItems, // withdraw if not dropped
    List<PlayerServantNoblePhantasmUsageDataEntity> playerServantNoblePhantasmUsageData = const [],
    List<List<int>> voicePlayedArray = const [],
  }) async {
    // assert activeDeckId in replaced.userDeck[].id
    int refreshCount = 0;
    ServantLeaderInfo? followerSvt;
    FollowerInfo? follower;

    (FollowerInfo follower, ServantLeaderInfo svt)? getValidFollowerSvt(List<FollowerInfo> followers) {
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
      return null;
    }

    while (true) {
      final resp = await folowerList(questId: questId, questPhase: questPhase, isEnfoceRefresh: refreshCount > 0);
      refreshCount += 1;
      if (refreshCount > 20) {
        throw Exception('After $refreshCount times refresh, no support svt is valid');
      }
      dynamic result = resp.raw['cache'];
      result = result['updated'];
      result = result['userFollower'];
      result = result[0];
      result = result['followerInfo'];
      final rawList = result;
      List<FollowerInfo> followers = (rawList as List).map((e) => FollowerInfo.fromJson(Map.from(e))).toList();
      final _followerSvt = getValidFollowerSvt(followers);
      if (_followerSvt != null) {
        follower = _followerSvt.$1;
        followerSvt = _followerSvt.$2;
        break;
      }
      await waitSeconds(10, null, '$msgPrefix follower refresh');
    }
    final battleResp = await battleSetup(
      questId: questId,
      questPhase: questPhase,
      activeDeckId: activeDeckId,
      followerId: followerSvt.userId,
      followerClassId: followerSvt.classId,
      followerType: follower.type,
      followerSupportDeckId: followerSvt.supportDeckId,
    );
    final raw = battleResp.raw;
    final Map battle = raw['cache']['replaced']['battle'][0];
    final int battleId = battle['id'];
    final Map battleInfo = battle['battleInfo'];
    final List stages = battleInfo['enemyDeck'];
    final int stageCount = stages.length;
    final List enemySvts = stages.expand((e) => e['svts']).toList();
    final List drops = enemySvts.expand((e) => e['dropInfos']).toList();
    final Map<int, int> dropNums = {};
    for (final drop in drops) {
      dropNums.addNum(drop['objectId'], drop['num']);
    }
    final originalDropNums = Map.of(dropNums);
    bool desiredDrop = true;
    for (final itemId in targetDropItems.keys) {
      if ((dropNums[itemId] ?? 0) < targetDropItems[itemId]!) {
        desiredDrop = false;
        break;
      }
    }
    if (targetDropItems.isNotEmpty) {
      dropNums.removeWhere((key, value) => !targetDropItems.containsKey(key));
    }
    // final List<int> dropObjectIds = drops.map((e) => e['objectId'] as int).toList();
    // dropObjectIds.retainWhere((e) => targetDropItems.contains(e));

    List<int> usedTurnList = List.filled(stageCount, 0);
    if (targetDropItems.isNotEmpty && !desiredDrop) {
      logger.i('target drops not meet: $originalDropNums, retire battle after 5s');
      await waitSeconds(3, null, '$msgPrefix retire');
      usedTurnList[0] = 1;
      final List wave1Enemies = stages[0]['svts'];

      final retireResp = await battleResult(
        battleId: battleId,
        battleResult: 3,
        winResult: 0,
        action: BattleDataActionList(logs: "", dt: wave1Enemies.map((e) => e['uniqueId'] as int).toList()),
        usedTurnArray: usedTurnList,
        playerServantNoblePhantasmUsageData: [],
        aliveUniqueIds: enemySvts.map((e) => e['uniqueId'] as int).toList(),
      );
      return (3, originalDropNums, retireResp);
    } else {
      logger.i('target drop found $targetDropItems, win battle after 60s');
      await waitSeconds(60, 70, '$msgPrefix win');
      usedTurnList[usedTurnList.length - 1] = 1;
      final List lastWaveEnemies = stages.last['svts'];

      final resp = await battleResult(
        battleId: battleId,
        battleResult: 1,
        winResult: 1,
        action: BattleDataActionList(
            logs: "1B2B3B1B1D2C1B1C2B", dt: lastWaveEnemies.map((e) => e['uniqueId'] as int).toList()),
        usedTurnArray: usedTurnList,
        playerServantNoblePhantasmUsageData: playerServantNoblePhantasmUsageData,
        voicePlayedArray: voicePlayedArray,
      );
      return (1, originalDropNums, resp);
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
