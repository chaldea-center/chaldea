import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import '../quiz/crypt_data.dart';
import '../shared/agent.dart';
import 'network.dart';

class FakerAgentCN extends FakerAgent<FRequestCN, AutoLoginDataCN, NetworkManagerCN> {
  FakerAgentCN({required super.network});
  FakerAgentCN.s({
    required GameTop gameTop,
    required AutoLoginDataCN user,
  }) : super(network: NetworkManagerCN(gameTop: gameTop.copy(), user: user));

  String get host => switch (network.user.gameServer) {
        BiliGameServer.android => 'https://le1-bili-fate.bilibiligame.net',
        BiliGameServer.ios => 'https://le1-ios-fate.bilibiligame.net',
        BiliGameServer.uo => 'https://line1-ts-uo-fate.bilibiligame.net',
      };

  @override
  AutoLoginDataCN get user => network.user;

  String rguid = '';
  String usk = '';
  String sguid = '';
  int sgtype = 2;
  String sgtag = ''; // 20170101, fgo register time
  List<String> encryptApi = [];

  static const developmentAuthCode = 'aK8mTxBJCwZyxBjNJSKA5xCWL7zKtgZEQNiZmffXUbyQd5aLun';

  Future<FResponse> _member() async {
    network.cookies.clear();
    final request = FRequestCN(network: network, path: '$host/rongame_beta/rgfate/60_member/member.php', key: 'member');
    final params = <String, Object>{
      "deviceid": "",
      "t": "22360",
      "v": "1.0.1",
      "s": "1",
      "mac": "00000000000000E0",
      "os": "",
      "ptype": "",
      "imei": "aaaaa",
      "username": "lv9999", //
      "type": "login",
      "password": "111111",
      "rksdkid": "1",
      "rkchannel": user.rkchannel,
      "cPlat": user.cPlat,
      "uPlat": user.uPlat,
      "appVer": network.gameTop.appVer,
      "dateVer": network.gameTop.dataVer, // init value is same as dataVer
      "lastAccessTime": getNowTimestamp(),
      "developmentAuthCode": developmentAuthCode,
      "idempotencyKey": const Uuid().v4(),
      "version": network.gameTop.dataVer,
      "dataVer": network.gameTop.dataVer,
    };
    request.form.addFromMap(params);
    final resp = await request.beginRequestAndCheckError('gamedata');
    final success = resp.data.getResponse('gamedata').success!;
    network.gameTop
      ..dataVer = success['version'] as int
      ..dateVer = success['version'] as int;
    return resp;
  }

  Future<FResponse> _loginToMemberCenter() async {
    final request = FRequestCN(
        network: network,
        path: '$host/rongame_beta/rgfate/60_member/logintomembercenter.php',
        key: 'logintomembercenter');
    final params = <String, Object>{
      "deviceid": "",
      "t": "22360",
      "v": "1.0.1",
      "s": "1",
      "mac": "00000000000000E0",
      "os": "",
      "ptype": "",
      "imei": "aaaaa",
      "rksdkid": "1",
      "username": user.username, // Android uses bilibili username, iOS uses "userName"
      if (user.isAndroidDevice) "bundleid": "com.bilibili.fatego", // android only
      "type": "token",
      "rkuid": user.uid,
      "access_token": user.accessToken,
      "rkchannel": user.rkchannel,
      "cPlat": user.cPlat,
      "uPlat": user.uPlat,
      "appVer": network.gameTop.appVer,
      "dateVer": network.gameTop.dataVer, // init value is same as dataVer
      "lastAccessTime": getNowTimestamp(),
      "developmentAuthCode": developmentAuthCode,
      "idempotencyKey": const Uuid().v4(),
      "version": network.gameTop.dataVer,
      "dataVer": network.gameTop.dataVer,
    };
    request.form.addFromMap(params);
    final resp = await request.beginRequestAndCheckError('login_to_membercenter');
    final success = resp.data.getResponse('login_to_membercenter').success!;
    // assetbundle, assetbundleKey
    network.gameTop
      ..dataVer = success['dataVer'] as int
      ..dateVer = success['dateVer'] as int;
    rguid = success['rguid'];
    usk = success['rgusk'];
    return resp;
  }

  Future<FResponse> _login() async {
    // has Set-Cookie
    final request = FRequestCN(network: network, path: '$host/rongame_beta/rgfate/60_1001/login.php', key: 'login');
    final params = <String, Object>{
      "deviceid": user.deviceId,
      "os": user.getOS(),
      "ptype": user.getPtype(),
      "rgsid": 1001,
      "rguid": rguid,
      "rgusk": usk,
      "idfa": "",
      "v": "1.0.1",
      "mac": "0",
      "imei": "",
      "type": "login",
      "nickname": user.nickname,
      "rkchannel": user.rkchannel,
      "cPlat": user.cPlat,
      "uPlat": user.uPlat,
      "assetbundleFolder": "",
      "appVer": network.gameTop.appVer,
      "dateVer": network.gameTop.dateVer,
      "lastAccessTime": getNowTimestamp(),
      "developmentAuthCode": developmentAuthCode,
      "idempotencyKey": const Uuid().v4(),
      "userAgent": 1,
      "t": 20399,
      "s": 1,
      "rksdkid": 1,
      "dataVer": network.gameTop.dataVer,
    };
    request.form.addFromMap(params);
    final resp = await request.beginRequestAndCheckError('');
    final success = resp.data.getResponse('').success!;
    assert(success['type'] == 'login', success);
    user.nickname = success['nickname'] ?? user.nickname;
    sguid = success['sguid'];
    sgtype = success['sgtype'];
    sgtag = success['sgtag'];
    usk = CryptData.encryptMD5Usk(success['sgusk']);
    // userGame updated too
    return resp;
  }

  Future<FResponse> _acPhp({
    required String key,
    required String nid,
    Map<String, Object>? params1,
    Map<String, Object>? params2,
    Map<String, Object>? params3,
    Map<String, Object>? params4,
  }) async {
    // has Set-Cookie
    final request = FRequestCN(
        network: network, path: '$host/rongame_beta/rgfate/60_1001/ac.php?_userId=$sguid&_key=$key', key: key);
    Map<String, Object> params = <String, Object>{
      ...?params1,
      "ac": "action",
      "key": key,
      "deviceid": user.deviceId,
      "os": user.getOS(),
      "ptype": user.getPtype(),
      "usk": usk,
      "umk": "",
      "rgsid": 1001,
      "rkchannel": user.rkchannel,
      "cPlat": user.cPlat,
      "uPlat": user.uPlat,
      ...?params2,
      "userId": sguid,
      "appVer": network.gameTop.appVer,
      "dateVer": network.gameTop.dateVer,
      "lastAccessTime": getNowTimestamp(),
      "developmentAuthCode": developmentAuthCode,
      "idempotencyKey": const Uuid().v4(),
      ...?params3,
      "userAgent": 1,
      ...?params4,
      "dataVer": network.gameTop.dataVer,
    };
    request.form.addFromMap(params);
    final resp = await request.beginRequest();
    final _usk = resp.data.responses.firstWhereOrNull((e) => e.nid == nid && e.usk?.isNotEmpty == true)?.usk ??
        resp.data.responses.firstWhereOrNull((e) => e.usk?.isNotEmpty == true)?.usk;
    if (_usk != null) {
      final oldUsk = usk;
      usk = CryptData.encryptMD5Usk(_usk);
      print('Update usk: $oldUsk->$usk($_usk)');
      final _encryptApi = resp.data.getResponseNull(nid)?.encryptApi;
      if (_encryptApi != null) encryptApi = _encryptApi;
    }
    resp.throwError(nid);
    return resp;
  }

  @override
  Future<FResponse> loginTop() async {
    await _member();
    await _loginToMemberCenter();
    await Future.delayed(const Duration(seconds: 2));
    await _login();
    await Future.delayed(const Duration(seconds: 5));
    return _acPhp(
      key: 'toplogin',
      nid: 'login',
      params2: {
        "nickname": user.nickname,
        "sgtype": sgtype,
        "sgtag": sgtag,
      },
    );
  }

  @override
  Future<FResponse> gamedataTop({bool checkAppUpdate = true}) async {
    final resp = await Dio()
        .get('https://static.biligame.com/config/fgo.config.js', options: Options(responseType: ResponseType.plain));
    final m = RegExp(r"FateGO_(\d+\.\d+\.\d+)_").firstMatch(resp.data as String)!;
    final newVersion = m.group(1)!;
    if (AppVersion.compare(newVersion, network.gameTop.appVer) > 0) {
      network.gameTop.appVer = newVersion;
    }
    return _member();
  }

  @override
  Future<FResponse> homeTop() async {
    return _acPhp(key: 'home', nid: 'home');
  }

  @override
  Future<FResponse> followerList(
      {required int32_t questId, required int32_t questPhase, required bool isEnfoceRefresh}) async {
    return _acPhp(
      key: 'followerlist',
      nid: 'follower_list',
      params3: {
        "questId": questId,
        "questPhase": questPhase,
        "refresh": isEnfoceRefresh ? 1 : 0,
      },
    );
  }

  @override
  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num}) async {
    return _acPhp(
      key: 'itemrecover',
      nid: 'item_recover',
      params4: {
        "recoverId": recoverId,
        "num": num,
      },
    );
  }

  @override
  Future<FResponse> shopPurchase({required int32_t id, required int32_t num, int32_t anotherPayFlag = 0}) async {
    return _acPhp(
      key: 'shoppurchase',
      nid: 'purchase',
      params4: {
        "id": id,
        "num": num,
        if (anotherPayFlag > 0) "anotherPayFlag": anotherPayFlag,
      },
    );
  }

  @override
  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num}) async {
    return _acPhp(
      key: 'shoppurchasebystone',
      nid: 'purchase_by_stone',
      params4: {
        "id": id,
        "num": num,
      },
    );
  }

  @override
  Future<FResponse> eventMissionClearReward({required List<int32_t> missionIds}) {
    return _acPhp(key: 'eventmissionreceive', nid: 'event_mission_receive', params1: {
      'missionIds': jsonEncode(missionIds),
    });
  }

  @override
  Future<FResponse> userPresentReceive(
      {required List<int64_t> presentIds, required int32_t itemSelectIdx, required int32_t itemSelectNum}) {
    return _acPhp(
      key: 'presentreceive',
      nid: 'present_receive',
      params2: {
        'presentIds': jsonEncode(presentIds),
      },
      params4: {
        'itemSelectIdx': itemSelectIdx,
        'itemSelectNum': itemSelectNum,
      },
    );
  }

  @override
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
    final resp = await _acPhp(
      key: 'battlesetup',
      nid: 'battle_setup',
      params1: {
        "activeDeckId": activeDeckId,
        "followerId": followerId,
        "userEquipId": userEquipId,
        "routeSelect": jsonEncode(routeSelect),
        "choiceRandomLimitCounts": choiceRandomLimitCounts,
      },
      params3: {
        "questId": questId,
        "questPhase": questPhase,
        "followerClassId": followerClassId,
        "itemId": itemId,
        "boostId": boostId,
        "enemySelect": enemySelect,
        "questSelect": questSelect,
        "followerType": followerType,
        "followerRandomLimitCount": followerRandomLimitCount,
        "followerSpoilerProtectionLimitCount": followerSpoilerProtectionLimitCount,
        "followerSupportDeckId": followerSupportDeckId,
        // "recommendSupportIdx": 0,
        "campaignItemId": campaignItemId,
        // "restartWave": restartWave,
      },
    );
    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity != null) {
      lastBattle = curBattle ?? battleEntity;
      curBattle = battleEntity;
    }
    return resp;
  }

  @override
  Future<FResponse> battleResume({
    required int64_t battleId,
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> usedTurnList,
  }) async {
    final resp = await _acPhp(
      key: 'battleresume',
      nid: 'battle_resume',
      params3: {
        "battleId": battleId,
        "questId": questId,
        "questPhase": questPhase,
        "usedTurnList": usedTurnList,
      },
    );

    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity != null) {
      lastBattle = curBattle ?? battleEntity;
      curBattle = battleEntity;
    }
    return resp;
  }

  @override
  Future<FResponse> battleResult({
    required int64_t battleId,
    required BattleResultType battleResult, // 0-none,1-win,2-lose,3-retire
    required BattleWinResultType winResult, // 1 or 1
    String scores = "",
    required BattleDataActionList action,
    List<List<int>> voicePlayedArray = const [], // [[svtId, x],...]
    List<int> aliveUniqueIds = const [], // add this if retire/fail
    List<BattleRaidResult> raidResult = const [],
    List<BattleSuperBossResult> superBossResult = const [],
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
    final _battleResult = battleResult.value, _winResult = winResult.value;

    Map<String, dynamic> dictionary = {
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
      "aliveUniqueIds": aliveUniqueIds,
      // "battleStatus": 3845526358,
      // "voicePlayedList": "[]",
      // "usedTurnList": [2, 0, 1],
    };

    int64_t num1 = 0;
    for (final result in raidResult) {
      num1 += result.getStatusLong();
    }
    int64_t num2 = 0;
    if (superBossResult.isNotEmpty) {
      throw ArgumentError.value(superBossResult, 'superBossResult', 'superBossResult is not supported');
    }
    // for(final result in superBossResult){
    //   num2 += result.getStatusLong();
    // }
    int64_t num3 = 0;

    for (int num4 in aliveUniqueIds) {
      num3 += num4;
    }

    dictionary['battleStatus'] = getCrc32([
      ...BitConverter.getInt64(network.mstData.user!.userId + _battleResult),
      ...BitConverter.getInt64(num1 - 4231125),
      ...BitConverter.getInt64(num3 ~/ 2),
      ...BitConverter.getInt64(battleId - 2147483647),
      ...BitConverter.getInt64(num2 - 2469110),
    ]);
    dictionary['voicePlayedList'] = jsonEncode(voicePlayedArray);
    dictionary['usedTurnList'] = usedTurnArray;
    dictionary['waveInfo'] = "[]";

    logger.t('battle_result.result=${jsonEncode(dictionary)}');

    final resp = await _acPhp(
      key: 'battleresult',
      nid: 'battle_result',
      params2: {
        "raidResult": jsonEncode(raidResult),
        "superBossResult": jsonEncode(superBossResult),
        "result": jsonEncode(dictionary),
      },
    );
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
