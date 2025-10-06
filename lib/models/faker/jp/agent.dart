import 'dart:convert';

import 'package:archive/archive.dart' show getCrc32;

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import '../shared/agent.dart';
import 'network.dart';

class FakerAgentJP extends FakerAgent<FRequestJP, AutoLoginDataJP, NetworkManagerJP> {
  FakerAgentJP({required super.network});
  FakerAgentJP.s({required GameTop gameTop, required AutoLoginDataJP user})
    : super(
        network: NetworkManagerJP(gameTop: gameTop.copy(), user: user),
      );

  @override
  Future<FResponse> gamedataTop({bool checkAppUpdate = true}) async {
    final tops = await AtlasApi.gametopsRaw(expireAfter: Duration.zero);
    if (tops != null) {
      network.gameTop.updateFrom(tops.jp);
    }
    final regionInfo = await AtlasApi.regionInfo(region: user.region);
    if (regionInfo != null) {
      network.gameTop.updateFromRegionInfo(regionInfo);
    }
    final request = FRequestJP(network: network, path: '/gamedata/top');
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

  @override
  Future<FResponse> loginTop() async {
    raidRecords.clear();
    final request = FRequestJP(network: network, path: '/login/top');
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

  @override
  Future<FResponse> homeTop() async {
    final request = FRequestJP(network: network, path: '/home/top');
    final resp = await request.beginRequestAndCheckError('home');
    updateRaidInfo(homeResp: resp);
    return resp;
  }

  @override
  Future<FResponse> followerList({
    required int32_t questId,
    required int32_t questPhase,
    required bool isEnfoceRefresh,
  }) async {
    final request = FRequestJP(network: network, path: '/follower/list');
    request.addFieldInt32('questId', questId);
    request.addFieldInt32('questPhase', questPhase);
    request.addFieldInt32('refresh', isEnfoceRefresh ? 1 : 0);
    return request.beginRequestAndCheckError('follower_list');
  }

  @override
  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num}) async {
    final request = FRequestJP(network: network, path: '/item/recover');
    request.addFieldInt32('recoverId', recoverId);
    request.addFieldInt32('num', num);
    final itemId = mstRecovers[recoverId]?.targetId;
    logger.t(
      'item/recover($recoverId): Item $itemId ${db.gameData.items[itemId]?.lName.l ?? "unknown recover id"} ×$num',
    );
    return request.beginRequestAndCheckError('item_recover');
  }

  @override
  Future<FResponse> shopPurchase({required int32_t id, required int32_t num, int32_t anotherPayFlag = 0}) async {
    final request = FRequestJP(network: network, path: '/shop/purchase');
    request.addFieldInt32('id', id);
    request.addFieldInt32('num', num);
    if (anotherPayFlag > 0) {
      request.addFieldInt32('anotherPayFlag', anotherPayFlag);
    }
    return request.beginRequest();
  }

  @override
  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num}) async {
    final request = FRequestJP(network: network, path: '/shop/purchaseByStone');
    request.addFieldInt32('id', id);
    request.addFieldInt32('num', num);
    return request.beginRequest();
  }

  @override
  Future<FResponse> eventMissionClearReward({required List<int32_t> missionIds}) {
    // success: {missionIds:[],overflowType:0,isOverPresentBox:false}
    final request = FRequestJP(network: network, path: '/eventMission/receive');
    request.addFieldStr('missionIds', jsonEncode(missionIds));
    return request.beginRequestAndCheckError('event_mission_receive');
  }

  @override
  Future<FResponse> eventMissionRandomCancel({required int32_t missionId}) {
    final request = FRequestJP(network: network, path: '/eventMission/randomCancel');
    request.addFieldInt32('missionId', missionId);
    return request.beginRequestAndCheckError('event_mission_random_cancel');
  }

  @override
  Future<FResponse> eventTradeStart({
    required int32_t eventId,
    required int32_t tradeStoreIdx,
    required int32_t tradeGoodsId,
    required int32_t tradeGoodsNum,
    required int32_t itemId,
  }) {
    final request = FRequestJP(network: network, path: '/event/tradeStart');
    request.addFieldInt32('eventId', eventId);
    request.addFieldInt32('tradeStoreIdx', tradeStoreIdx);
    request.addFieldInt32('tradeGoodsId', tradeGoodsId);
    request.addFieldInt32('tradeGoodsNum', tradeGoodsNum);
    request.addFieldInt32('reduceTimeItemId', itemId);
    return request.beginRequestAndCheckError('event_trade_start');
  }

  @override
  Future<FResponse> eventTradeReceive({
    required int32_t eventId,
    required List<int32_t> tradeStoreIdxs,
    required int32_t receiveNum,
    required int32_t cancelTradeFlag,
  }) {
    final request = FRequestJP(network: network, path: '/event/tradeReceive');
    request.addFieldInt32('eventId', eventId);
    request.addFieldStr('tradeStoreIdxs', jsonEncode(tradeStoreIdxs));
    request.addFieldInt32('receiveNum', receiveNum);
    request.addFieldInt32('cancelTradeFlag', cancelTradeFlag);
    return request.beginRequestAndCheckError('event_trade_receive');
  }

  @override
  Future<FResponse> userPresentReceive({
    required List<int64_t> presentIds,
    required int32_t itemSelectIdx,
    required int32_t itemSelectNum,
  }) {
    // success: {overflowType:0,getSvts:[],getCommandCodes:[]}
    final request = FRequestJP(network: network, path: '/present/receive');
    request.addFieldStr('presentIds', network.catMouseGame.encodeMsgpackBase64(presentIds));
    request.addFieldInt32('itemSelectIdx', itemSelectIdx);
    request.addFieldInt32('itemSelectNum', itemSelectNum);
    return request.beginRequest();
  }

  @override
  Future<FResponse> userPresentList() {
    final request = FRequestJP(network: network, path: '/present/list');
    return request.beginRequestAndCheckError('present_list');
  }

  @override
  Future<FResponse> userPresentHistory() {
    final request = FRequestJP(network: network, path: '/present/history');
    return request.beginRequestAndCheckError('present_receive_history');
  }

  @override
  Future<FResponse> gachaDraw({
    required int32_t gachaId,
    required int32_t num,
    // required int32_t warId,
    int32_t ticketItemId = 0,
    int32_t shopIdIdx = 1,
    required int32_t gachaSubId,
    List<int32_t> storyAdjustIds = const [],
    String selectBonusListData = "",
  }) async {
    final request = FRequestJP(network: network, path: '/gacha/draw');
    request.addFieldInt32("gachaId", gachaId);
    request.addFieldInt32("num", num);
    request.addFieldInt32("ticketItemId", ticketItemId);
    request.addFieldInt32("shopIdIndex", shopIdIdx);
    request.addFieldInt32("gachaSubId", gachaSubId);
    request.addFieldStr("storyAdjustIds", jsonEncode(storyAdjustIds));
    request.addFieldStr("selectBonusList", selectBonusListData);
    return request.beginRequestAndCheckError('gacha_draw');
  }

  @override
  Future<FResponse> boxGachaDraw({required int32_t gachaId, required int32_t num}) {
    final request = FRequestJP(network: network, path: '/boxGacha/draw');
    request.addFieldInt32("boxGachaId", gachaId);
    request.addFieldInt32("num", num);
    return request.beginRequestAndCheckError('box_gacha_draw');
  }

  @override
  Future<FResponse> boxGachaReset({required int32_t gachaId}) {
    final request = FRequestJP(network: network, path: '/boxGacha/reset');
    request.addFieldInt32("boxGachaId", gachaId);
    return request.beginRequestAndCheckError('box_gacha_reset');
  }

  @override
  Future<FResponse> sellServant({required List<int64_t> servantUserIds, required List<int64_t> commandCodeUserIds}) {
    // success: {"sellRarePriPrice":0,"sellManaPrice":0,"sellQpPrice":2000}
    List<Map<String, dynamic>> _useSvtHash(List<int> ids) => [
      for (final id in ids) {"id": id, "num": 1},
    ];
    final request = FRequestJP(network: network, path: '/shop/sellSvt');
    request.addFieldStr("sellData", network.catMouseGame.encodeMsgpackBase64(_useSvtHash(servantUserIds)));
    request.addFieldStr("sellCommandCode", network.catMouseGame.encodeMsgpackBase64(_useSvtHash(commandCodeUserIds)));
    return request.beginRequestAndCheckError('sell_svt');
  }

  @override
  Future<FResponse> servantCombine({
    required int64_t baseUserSvtId,
    required List<int64_t> materialSvtIds,
    required int32_t useQp,
    required int32_t getExp,
  }) {
    final request = FRequestJP(network: network, path: '/card/combine');
    request.addFieldInt64("baseUserSvtId", baseUserSvtId);
    request.addFieldStr("materialUserSvtIds", jsonEncode(materialSvtIds));
    request.addFieldInt32("useQp", useQp);
    request.addFieldInt32("getExp", getExp);
    return request.beginRequestAndCheckError('card_combine');
  }

  @override
  Future<FResponse> servantLimitCombine({required int64_t baseUserSvtId}) {
    final request = FRequestJP(network: network, path: '/card/combineLimit');
    request.addFieldInt64("baseUserSvtId", baseUserSvtId);
    return request.beginRequest();
  }

  @override
  Future<FResponse> servantLevelExceed({required int64_t baseUserSvtId}) {
    final request = FRequestJP(network: network, path: '/card/combineExceed');
    request.addFieldInt64("baseUserSvtId", baseUserSvtId);
    return request.beginRequestAndCheckError('card_combine_exceed');
  }

  @override
  Future<FResponse> servantFriendshipExceed({required int64_t baseUserSvtId}) {
    final request = FRequestJP(network: network, path: '/card/friendshipExceed');
    request.addFieldInt64("baseUserSvtId", baseUserSvtId);
    return request.beginRequestAndCheckError('card_friendship_exceed');
  }

  @override
  Future<FResponse> servantSkillCombine({
    required int64_t baseUsrSvtId,
    required int32_t selectSkillIndex,
    required int32_t selectSkillId,
  }) {
    final request = FRequestJP(network: network, path: '/card/combineSkill');
    request.addFieldInt64("baseUserSvtId", baseUsrSvtId);
    request.addFieldInt32("num", selectSkillIndex);
    request.addFieldInt32("skillId", selectSkillId);
    return request.beginRequestAndCheckError('card_combine_skill');
  }

  @override
  Future<FResponse> appendSkillCombine({
    required int64_t baseUsrSvtId,
    required int32_t skillNum,
    required int32_t currentSkillLv,
  }) {
    final request = FRequestJP(network: network, path: '/card/combineAppendPassiveSkill');
    request.addFieldInt64("baseUserSvtId", baseUsrSvtId);
    request.addFieldInt32("skillNum", skillNum);
    request.addFieldInt32("currentSkillLv", currentSkillLv);
    return request.beginRequestAndCheckError('card_combine_append_passive_skill');
  }

  @override
  Future<FResponse> servantEquipCombine({required int64_t baseUserSvtId, required List<int64_t> materialSvtIds}) {
    // success: { "addTotalExp": 0, "successResult": 1, "normalExp": 30000 }
    final request = FRequestJP(network: network, path: '/svtEquip/combine');
    request.addFieldInt64("baseUserSvtId", baseUserSvtId);
    request.addFieldStr("materialUserSvtIds", jsonEncode(materialSvtIds));
    return request.beginRequestAndCheckError('svt_equip_combine');
  }

  @override
  Future<FResponse> commandCodeUnlock({required int32_t servantId, required int32_t idx}) {
    final request = FRequestJP(network: network, path: '/commandCode/unlock');
    request.addFieldInt32("svtId", servantId);
    request.addFieldInt32("idx", idx);
    return request.beginRequestAndCheckError('command_code_unlock');
  }

  @override
  Future<FResponse> userStatusFlagSet({required List<int32_t> onFlagNumbers, required List<int32_t> offFlagNumbers}) {
    final request = FRequestJP(network: network, path: '/userStatus/flagSet');
    if (onFlagNumbers.isNotEmpty) {
      request.addFieldStr("onFlagNumbers", jsonEncode(onFlagNumbers));
    }
    if (offFlagNumbers.isNotEmpty) {
      request.addFieldStr("offFlagNumbers", jsonEncode(offFlagNumbers));
    }
    return request.beginRequestAndCheckError('user_status_flag_set');
  }

  @override
  Future<FResponse> deckSetup({required int64_t activeDeckId, required UserDeckEntity userDeck}) {
    final request = FRequestJP(network: network, path: '/deck/setup');
    request.addFieldInt32("activeDeckId", activeDeckId);
    request.addFieldStr("userDeck", network.catMouseGame.encodeMsgpackBase64([userDeck]));
    return request.beginRequestAndCheckError('battle_scenario');
  }

  @override
  Future<FResponse> eventDeckSetup({
    required UserEventDeckEntity userEventDeck,
    required int32_t eventId,
    required int32_t questId,
    required int32_t phase,
    int32_t restartWave = 0,
  }) {
    final request = FRequestJP(network: network, path: '/eventDeck/setup');
    request.addFieldInt32("restartWave", restartWave);
    request.addFieldInt32("eventId", eventId);
    request.addFieldInt32("questId", questId);
    request.addFieldInt32("phase", phase);
    request.addFieldStr("deckInfo", jsonEncode(userEventDeck.deckInfo!));
    return request.beginRequestAndCheckError('event_deck_setup');
  }

  @override
  Future<FResponse> battleScenario({
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> routeSelect,
  }) {
    final request = FRequestJP(network: network, path: '/battle/scenario');
    request.addFieldInt32("questId", questId);
    request.addFieldInt32("questPhase", questPhase);
    request.addFieldStr("routeSelect", jsonEncode(routeSelect));
    return request.beginRequestAndCheckError('battle_scenario');
  }

  @override
  Future<FResponse> battleSetup({
    required int32_t questId,
    required int32_t questPhase,
    required int64_t activeDeckId,
    required int64_t followerId,
    required int32_t followerClassId,
    required int32_t followerGrandGraphId,
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
    int32_t recommendSupportIdx = 0,
    required int32_t followerSupportDeckId,
    int32_t campaignItemId = 0,
    int32_t restartWave = 0,
    List<int32_t> useRewardAddItemIds = const [],
  }) async {
    final request = FRequestJP(network: network, path: '/battle/setup');
    request.addFieldInt32("questId", questId);
    request.addFieldInt32("questPhase", questPhase);
    request.addFieldInt64("activeDeckId", activeDeckId);
    request.addFieldInt64("followerId", followerId);
    request.addFieldInt32("followerClassId", followerClassId);
    request.addFieldInt32("followerGrandGraphId", followerGrandGraphId);
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
    request.addFieldInt32("recommendSupportIdx", recommendSupportIdx);
    request.addFieldInt32("followerSupportDeckId", followerSupportDeckId);
    request.addFieldInt32("campaignItemId", campaignItemId);
    request.addFieldInt32("restartWave", restartWave);
    request.addFieldStr("useRewardAddItemIds", jsonEncode(useRewardAddItemIds));
    final resp = await request.beginRequestAndCheckError('battle_setup');
    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity != null) {
      lastBattle = curBattle ?? battleEntity;
      curBattle = battleEntity;
    }
    updateRaidInfo(battleSetupResp: resp);
    return resp;
  }

  @override
  Future<FResponse> battleResume({
    required int64_t battleId,
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> usedTurnList,
  }) async {
    final request = FRequestJP(network: network, path: '/battle/resume');
    request.addFieldInt64("battleId", battleId);
    request.addFieldInt32("questId", questId);
    request.addFieldInt32("questPhase", questPhase);
    request.addFieldStr("routeSelect", jsonEncode(usedTurnList));
    final resp = await request.beginRequestAndCheckError('battle_resume');
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
    required BattleResultType resultType, // 0-none,1-win,2-lose,3-retire
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
    Map<String, Object> recordJson = const {"turnMaxDamage": 0, "knockdownNum": 0, "totalDamageToAliveEnemy": 0},
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
    required int32_t waveNum,
    Map<int32_t, int32_t> battleMissionValueDict = const {},
    Duration? sendDelay,
  }) async {
    final request = FRequestJP(network: network, path: '/battle/result');
    if (sendDelay != null) request.sendDelay = sendDelay;
    final _battleResult = resultType.value, _winResult = winResult.value;

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
      "aliveUniqueIds": aliveUniqueIds,
      // "battleStatus": 1393373180,
      // "voicePlayedList": "[]",
      // "usedTurnList": [0, 0, 1]
    };

    int64_t num1 = 0;
    for (final result in raidResult) {
      num1 += result.getStatusLong();
    }
    int64_t num2 = 0;
    if (superBossResult.isNotEmpty) {
      throw ArgumentError.value(superBossResult, 'superBossResult', 'superBossResult is not supported');
    }
    for (final result in superBossResult) {
      num2 += result.getStatusLong();
    }
    int64_t num3 = 0;

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
    dictionary['reachedWave'] = waveNum;

    List<int> battleMissionTargetIds = battleMissionValueDict.keys.toList();
    battleMissionTargetIds.sort();
    List<int> battleMissionTargetValues = [for (final x in battleMissionTargetIds) battleMissionValueDict[x]!];
    dictionary['battleMissionTargetIds'] = battleMissionTargetIds;
    dictionary['battleMissionTargetValues'] = battleMissionTargetValues;

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

  @override
  Future<FResponse> battleTurn({required int64_t battleId}) async {
    final request = FRequestJP(network: network, path: '/battle/turn');
    request.addFieldInt64("battleId", battleId);
    final resp = await request.beginRequestAndCheckError('battle_turn');
    updateRaidInfo(battleTurnResp: resp);
    return resp;
  }
}
