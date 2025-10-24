import 'dart:typed_data';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import 'network.dart';

abstract class FakerAgent<
  TRequest extends FRequestBase,
  TUser extends AutoLoginData,
  TNetworkManager extends NetworkManagerBase<TRequest, TUser>
> {
  final TNetworkManager network;
  FakerAgent({required this.network});

  TUser get user => network.user;
  UserGameEntity? get userGame => network.mstData.user ?? user.userGame;

  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  FResponse? lastResp;

  Map<int, Map<int, EventRaidInfoRecord>> raidRecords = {};
  EventRaidInfoRecord getRaidRecord(int eventId, int day) =>
      raidRecords.putIfAbsent(eventId, () => {}).putIfAbsent(day, () => EventRaidInfoRecord());

  Future<FResponse> gamedataTop({bool checkAppUpdate = true});

  Future<FResponse> loginTop();

  Future<FResponse> homeTop();

  Future<FResponse> followerList({
    required int32_t questId,
    required int32_t questPhase,
    required bool isEnfoceRefresh,
  });

  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num});

  Future<FResponse> shopPurchase({required int32_t id, required int32_t num, int32_t anotherPayFlag = 0});

  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num});

  Future<FResponse> eventMissionClearReward({required List<int32_t> missionIds});

  Future<FResponse> eventMissionRandomCancel({required int32_t missionId});

  Future<FResponse> eventTradeStart({
    required int32_t eventId,
    required int32_t tradeStoreIdx,
    required int32_t tradeGoodsId,
    required int32_t tradeGoodsNum,
    required int32_t itemId,
  });

  Future<FResponse> eventTradeReceive({
    required int32_t eventId,
    required List<int32_t> tradeStoreIdxs,
    required int32_t receiveNum,
    required int32_t cancelTradeFlag,
  });

  Future<FResponse> userPresentReceive({
    required List<int64_t> presentIds,
    required int32_t itemSelectIdx,
    required int32_t itemSelectNum,
  });
  Future<FResponse> userPresentList();
  Future<FResponse> userPresentHistory();

  Future<FResponse> gachaDraw({
    required int32_t gachaId,
    required int32_t num,
    // required int32_t warId,
    int32_t ticketItemId = 0,
    int32_t shopIdIdx = 1,
    required int32_t gachaSubId,
    List<int32_t> storyAdjustIds = const [],
    String selectBonusListData = "",
  });
  Future<FResponse> gachaHistory({required int32_t gachaId}); // userGachaDrawHistory

  Future<FResponse> boxGachaDraw({required int32_t gachaId, required int32_t num});
  Future<FResponse> boxGachaReset({required int32_t gachaId});

  Future<FResponse> sellServant({required List<int64_t> servantUserIds, required List<int64_t> commandCodeUserIds});

  // card
  Future<FResponse> cardFavorite({
    required int64_t targetUsrSvtId,
    required int32_t imageLimitCount,
    required int32_t dispLimitCount,
    required int32_t commandCardLimitCount,
    required int32_t iconLimitCount,
    required int32_t portraitLimitCount,
    required bool isFavorite,
    required bool isLock,
    required bool isChoice,
    required int32_t commonFlag,
    required int32_t battleVoice,
    required int32_t randomSettingOwn,
    required int32_t randomSettingSupport,
    required int32_t limitCountSupport,
    required bool isPush,
  });

  Future<FResponse> cardFavoriteWith({
    required int64_t targetUsrSvtId,
    int32_t? imageLimitCount,
    int32_t? dispLimitCount,
    int32_t? commandCardLimitCount,
    int32_t? iconLimitCount,
    int32_t? portraitLimitCount,
    bool? isFavorite,
    bool? isLock,
    bool? isChoice,
    int32_t? commonFlag,
    int32_t? battleVoice,
    int32_t? randomSettingOwn,
    int32_t? randomSettingSupport,
    int32_t? limitCountSupport,
    bool? isPush,
  }) {
    final userSvt = network.mstData.userSvt[targetUsrSvtId] ?? network.mstData.userSvtStorage[targetUsrSvtId];
    if (userSvt == null) {
      throw SilentException('User svt $targetUsrSvtId not found');
    }
    final collection = network.mstData.userSvtCollection[userSvt.svtId];
    if (collection == null) {
      throw SilentException('Svt collection ${userSvt.svtId} not found');
    }
    final userGame = network.mstData.user!;

    return cardFavorite(
      targetUsrSvtId: targetUsrSvtId,
      imageLimitCount: imageLimitCount ?? userSvt.imageLimitCount,
      dispLimitCount: dispLimitCount ?? userSvt.dispLimitCount,
      commandCardLimitCount: commandCardLimitCount ?? userSvt.commandCardLimitCount,
      iconLimitCount: iconLimitCount ?? userSvt.iconLimitCount,
      portraitLimitCount: portraitLimitCount ?? userSvt.portraitLimitCount,
      isFavorite: isFavorite ?? targetUsrSvtId == userGame.favoriteUserSvtId,
      isLock: isLock ?? userSvt.isLocked(),
      isChoice: isChoice ?? userSvt.isChoice(),
      commonFlag: commonFlag ?? collection.svtCommonFlag,
      battleVoice: battleVoice ?? userSvt.battleVoice,
      randomSettingOwn: randomSettingOwn ?? userSvt.randomLimitCount,
      randomSettingSupport: randomSettingSupport ?? userSvt.randomLimitCountSupport,
      limitCountSupport: limitCountSupport ?? userSvt.limitCountSupport,
      isPush: isPush ?? targetUsrSvtId == userGame.pushUserSvtId,
    );
  }

  Future<FResponse> cardStatusSync({
    required List<int64_t> changeUserSvtIds,
    required List<int64_t> revokeUserSvtIds,
    bool isStorage = false,
    bool isLock = false,
    bool isChoice = false,
  });
  Future<FResponse> servantCombine({
    required int64_t baseUserSvtId,
    required List<int64_t> materialSvtIds,
    required int32_t useQp,
    required int32_t getExp,
  });
  Future<FResponse> servantLimitCombine({required int64_t baseUserSvtId});
  Future<FResponse> servantLevelExceed({required int64_t baseUserSvtId});
  Future<FResponse> servantFriendshipExceed({required int64_t baseUserSvtId});
  Future<FResponse> servantSkillCombine({
    required int64_t baseUsrSvtId,
    required int32_t selectSkillIndex,
    required int32_t selectSkillId,
  });
  Future<FResponse> appendSkillCombine({
    required int64_t baseUsrSvtId,
    required int32_t skillNum,
    required int32_t currentSkillLv,
  });
  Future<FResponse> storageTakein({required List<int64_t> userSvtIds});
  Future<FResponse> storageTakeout({required List<int64_t> userSvtIds});

  Future<FResponse> servantEquipCombine({required int64_t baseUserSvtId, required List<int64_t> materialSvtIds});

  Future<FResponse> commandCodeUnlock({required int32_t servantId, required int32_t idx});

  Future<FResponse> userStatusFlagSet({required List<int32_t> onFlagNumbers, required List<int32_t> offFlagNumbers});

  Future<FResponse> classBoardReleaseSquare({required int32_t classBoardBaseId, required int32_t squareId});
  Future<FResponse> classBoardReleaseLock({required int32_t classBoardBaseId, required int32_t squareId});

  Future<FResponse> deckSetup({required int64_t activeDeckId, required UserDeckEntity userDeck});
  Future<FResponse> userFormationSetup({required int32_t deckNo, required int64_t userEquipId});
  Future<FResponse> eventDeckSetup({
    required UserEventDeckEntity? userEventDeck, // original, but only userEventDeck.deckInfo used
    required DeckServantEntity? deckInfo,
    required int32_t eventId,
    required int32_t questId,
    required int32_t phase,
    int32_t restartWave = 0,
    List<GrandSvtInfo> grandSvtInfos = const [],
  });
  Future<FResponse> deckEditName({required int64_t deckId, required String deckName});

  Future<FResponse> battleScenario({
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> routeSelect,
  });

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
  });

  Future<FResponse> battleResume({
    required int64_t battleId,
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> usedTurnList,
  });

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
    // custom
    Duration? sendDelay,
  });
  // public void beginRequest(int[] dataLostUniqueIdArray, BattleWaveInfoData[] waveInfos, int waveNum) { }

  // raid
  Future<FResponse> battleTurn({required int64_t battleId});

  // extended

  Future<FResponse> terminalApSeedExchange(int32_t buyCount) {
    // TerminalApSeedExchangeManager__OnSelectExchangeItems
    // shop 13000000
    // item_103 + 40AP
    return shopPurchase(id: 13000000, num: buyCount, anotherPayFlag: 0);
  }

  void updateRaidInfo({FResponse? homeResp, FResponse? battleSetupResp, FResponse? battleTurnResp}) {
    final now = DateTime.now().timestamp;
    // home top
    if (homeResp != null) {
      for (final eventRaid in homeResp.data.mstData.mstEventRaid) {
        getRaidRecord(eventRaid.eventId, eventRaid.day).eventRaid = eventRaid;
      }
      for (final raid in homeResp.data.mstData.totalEventRaid) {
        final record = getRaidRecord(raid.eventId, raid.day);
        record.history.add((
          timestamp: homeResp.data.serverTime?.timestamp ?? now,
          raidInfo: BattleRaidInfo(
            day: raid.day,
            uniqueId: 0,
            maxHp: record.eventRaid?.maxHp ?? 0,
            totalDamage: raid.totalDamage,
          ),
          battleId: null,
        ));
      }
    }
    // battle setup
    final battleEntity = battleSetupResp?.data.mstData.battles.firstOrNull;
    final setupRaidInfos = battleEntity?.battleInfo?.raidInfo ?? [];
    if (battleEntity != null && setupRaidInfos.isNotEmpty) {
      for (final raid in setupRaidInfos) {
        getRaidRecord(battleEntity.eventId, raid.day).history.add((
          timestamp: battleSetupResp?.data.serverTime?.timestamp ?? now,
          raidInfo: raid,
          battleId: battleEntity.id,
        ));
      }
    }
    // battle turn
    final turnSuccess = battleTurnResp?.data.getResponseNull('battle_turn')?.success;
    if (battleTurnResp != null && turnSuccess != null) {
      final raidInfos = (turnSuccess['raidInfo'] as List?) ?? [];
      final battleId = int.tryParse(battleTurnResp.request.params['battleId'] ?? '');
      if (battleId != null) {
        int? eventId;
        for (final (eId, records) in raidRecords.items) {
          if (records.values.expand((e) => e.history).any((e) => e.battleId == battleId)) {
            eventId = eId;
            break;
          }
        }
        if (eventId != null) {
          for (final rawRaid in raidInfos) {
            final raid = BattleRaidInfo.fromJson(Map<String, dynamic>.from(rawRaid as Map));
            getRaidRecord(eventId, raid.day).history.add((
              timestamp: battleTurnResp.data.serverTime?.timestamp ?? now,
              raidInfo: raid,
              battleId: battleId,
            ));
          }
        }
      }
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
    return {"svtId": svtId, "followerType": followerType, "seqId": seqId, "addCount": addCount};
  }
}

class BattleDataActionList {
  // commandhistory(uniqueId+commadtype): 1B2B3B1B1D2C1B1C2B
  String logs;
  // current wave's enemy info("u"+uniqueId): u13u14u15
  List<int> dt;
  String hd;
  String data;

  BattleDataActionList({required this.logs, required this.dt, this.hd = "", this.data = ""});
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

// UserPresentBoxWindow.PRESENT_OVERFLOW_TYPE
enum PresentOverflowType {
  none(0),
  svt(1),
  svtEquip(2),
  item(3),
  commandCode(4);

  const PresentOverflowType(this.value);
  final int value;
}

class EventRaidInfoRecord {
  EventRaidEntity? eventRaid;
  List<({int timestamp, BattleRaidInfo raidInfo, int? battleId})> history = [];
}
