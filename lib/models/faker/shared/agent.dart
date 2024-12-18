import 'dart:math';
import 'dart:typed_data';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'network.dart';

abstract class FakerAgent<TRequest extends FRequestBase, TUser extends AutoLoginData,
    TNetworkManager extends NetworkManagerBase<TRequest, TUser>> {
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

  Future<FResponse> followerList(
      {required int32_t questId, required int32_t questPhase, required bool isEnfoceRefresh});

  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num});

  Future<FResponse> shopPurchase({required int32_t id, required int32_t num, int32_t anotherPayFlag = 0});

  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num});

  Future<FResponse> eventMissionClearReward({required List<int32_t> missionIds});

  Future<FResponse> userPresentReceive(
      {required List<int64_t> presentIds, required int32_t itemSelectIdx, required int32_t itemSelectNum});
  Future<FResponse> userPresentList();

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

  Future<FResponse> boxGachaDraw({required int32_t gachaId, required int32_t num});
  Future<FResponse> boxGachaReset({required int32_t gachaId});

  Future<FResponse> sellServant({required List<int64_t> servantUserIds, required List<int64_t> commandCodeUserIds});

  // cardCombine
  Future<FResponse> servantCombine({
    required int64_t baseUserSvtId,
    required List<int64_t> materialSvtIds,
    required int32_t useQp,
    required int32_t getExp,
  });
  Future<FResponse> servantEquipCombine({required int64_t baseUserSvtId, required List<int64_t> materialSvtIds});

  Future<FResponse> userStatusFlagSet({required List<int32_t> onFlagNumbers, required List<int32_t> offFlagNumbers});

  Future<FResponse> deckSetup({required int64_t activeDeckId, required UserDeckEntity userDeck});

  Future<FResponse> eventDeckSetup({
    required UserEventDeckEntity userEventDeck,
    required int32_t eventId,
    required int32_t questId,
    required int32_t phase,
    int32_t restartWave = 0,
  });

  Future<FResponse> battleScenario(
      {required int32_t questId, required int32_t questPhase, required List<int32_t> routeSelect});

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
  });

  Future<FResponse> battleResume({
    required int64_t battleId,
    required int32_t questId,
    required int32_t questPhase,
    required List<int32_t> usedTurnList,
  });

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
  });

  // raid
  Future<FResponse> battleTurn({required int64_t battleId});

  // extended

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
      final consume = options.isApHalf ? quest.consume ~/ 2 : quest.consume;
      if (curAp < consume) {
        throw Exception('AP not enough: $curAp<${questPhaseEntity.consume}');
      }
    }
    if (questPhaseEntity.consumeType.useItem) {
      for (final item in questPhaseEntity.consumeItem) {
        final itemNum = mstData.getItemOrSvtNum(item.itemId);
        if (itemNum < item.amount) {
          throw Exception('Item not enough: $itemNum<${item.amount}');
        }
      }
    }

    int campaignItemId = 0;
    if (options.useCampaignItem) {
      List<(UserItemEntity, Item)> campaignItems = [];
      final now = DateTime.now().timestamp;
      for (final userItem in mstData.userItem) {
        if (userItem.num <= 0) continue;
        final jpItem = db.gameData.items[userItem.itemId];
        if (jpItem != null && jpItem.type != ItemType.friendshipUpItem) continue;
        final item = region == Region.jp ? jpItem : await AtlasApi.item(userItem.itemId, region: region);
        if (item == null || item.type != ItemType.friendshipUpItem) continue;
        if (item.startedAt < now && item.endedAt > now) {
          campaignItems.add((userItem, item));
        }
      }
      if (campaignItems.isEmpty) {
        throw Exception('no valid Teapot item found');
      }
      print("Teapot count: ${{for (final x in campaignItems) x.$1.itemId: x.$1.num}}");

      campaignItems.sort2((e) => e.$2.endedAt);
      campaignItemId = campaignItems.first.$1.itemId;
    }

    if (questPhaseEntity.flags.contains(QuestFlag.noBattle)) {
      if (questPhaseEntity.stages.isNotEmpty) {
        throw SilentException('Has noBattle flag, but does have ${questPhaseEntity.stages.length} stage(s).');
      }
      return battleScenario(
        questId: questPhaseEntity.id,
        questPhase: questPhaseEntity.phase,
        routeSelect: [],
      );
    }

    int activeDeckId, followerId, followerClassId, followerType, followerSupportDeckId;
    int userEquipId = 0;

    if (questPhaseEntity.flags.contains(QuestFlag.userEventDeck)) {
      activeDeckId = questPhaseEntity.extraDetail?.useEventDeckNo ?? 1;
    } else {
      activeDeckId = options.deckId;
    }

    if (questPhaseEntity.isNpcOnly) {
      if (questPhaseEntity.flags.contains(QuestFlag.noSupportList)) {
        followerId = 0;
        followerClassId = 0;
        followerType = 0;
        followerSupportDeckId = 0;
      } else {
        final npc = questPhaseEntity.supportServants.firstWhereOrNull((e) => e.script?.eventDeckIndex == null);
        followerId = npc?.id ?? 0;
        followerClassId = 0;
        followerType = FollowerType.npc.value;
        followerSupportDeckId = 0;
      }
    } else if (questPhaseEntity.extraDetail?.waveSetup == 1) {
      if (!questPhaseEntity.flags.contains(QuestFlag.eventDeckNoSupport) ||
          !questPhaseEntity.flags.contains(QuestFlag.userEventDeck)) {
        throw SilentException('WaveSetup quest must have eventDeckNoSupport and userEventDeck flag');
      }
      activeDeckId = 0;
      followerId = 0;
      followerClassId = 0;
      followerType = 0;
      followerSupportDeckId = 0;
      int? eventId = db.gameData.others.eventQuestGroups.entries
          .firstWhereOrNull((e) => e.value.contains(questPhaseEntity.id))
          ?.key;
      if (eventId == null) {
        throw SilentException('Quest related event not found');
      }
      final deckNo = questPhaseEntity.extraDetail?.useEventDeckNo ?? 1;
      final eventDeck = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, deckNo)];
      if (eventDeck == null) {
        throw SilentException('UserEventDeck(eventId=$eventId,deckNo=$deckNo) not found');
      }
      userEquipId = eventDeck.deckInfo!.userEquipId;
    } else {
      final notSuppportedFlags = const {
        QuestFlag.noSupportList,
        QuestFlag.eventDeckNoSupport,
        QuestFlag.notSingleSupportOnly
      }.intersection(questPhaseEntity.flags.toSet());
      if (notSuppportedFlags.isNotEmpty) {
        throw SilentException('Finding support but not supported flags: $notSuppportedFlags');
      }
      final (follower, followerSvt) = await _getValidSupport(
        questId: options.questId,
        questPhase: options.questPhase,
        useEventDeck: options.useEventDeck ?? db.gameData.others.shouldUseEventDeck(options.questId),
        enforceRefreshSupport: options.enfoceRefreshSupport,
        supportSvtIds: options.supportSvtIds.toList(),
        supportEquipIds: options.supportCeIds.toList(),
        supportEquipMaxLimitBreak: options.supportCeMaxLimitBreak,
      );
      followerId = follower.userId;
      followerClassId = followerSvt.classId;
      followerType = follower.type;
      followerSupportDeckId = followerSvt.supportDeckId;
    }

    return battleSetup(
      questId: options.questId,
      questPhase: options.questPhase,
      activeDeckId: activeDeckId,
      followerId: followerId,
      followerClassId: followerClassId,
      followerType: followerType,
      followerSupportDeckId: followerSupportDeckId,
      campaignItemId: campaignItemId,
      userEquipId: userEquipId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required int questId,
    required int questPhase,
    required bool useEventDeck,
    required bool enforceRefreshSupport,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
    required bool supportEquipMaxLimitBreak,
  }) async {
    int refreshCount = 0;
    List<FollowerInfo> followers = [];
    if (network.gameTop.region == Region.cn && !enforceRefreshSupport) {
      final oldUserFollower =
          network.mstData.userFollower.firstWhereOrNull((e) => e.expireAt > DateTime.now().timestamp + 300);
      if (oldUserFollower != null) {
        followers = oldUserFollower.followerInfo;
      }
    }
    while (true) {
      if (refreshCount > 0) followers.clear();
      if (followers.isEmpty) {
        if (refreshCount > 0 && refreshCount >= db.settings.fakerSettings.maxFollowerListRetryCount) {
          throw Exception('After $refreshCount times refresh, no support svt is valid');
        }
        final resp = await followerList(
            questId: questId, questPhase: questPhase, isEnfoceRefresh: enforceRefreshSupport || refreshCount > 0);
        if (refreshCount > 0) {
          await Future.delayed(const Duration(seconds: 5));
        }
        followers = resp.data.mstData.userFollower.first.followerInfo;
      }
      refreshCount += 1;
      // some may cause param error, shuffle to avoid keep selecting the same support
      followers = followers.toList();
      followers.shuffle();
      for (final follower in followers) {
        // skip FollowerType.follow
        if (follower.type != FollowerType.friend.value && follower.type != FollowerType.notFriend.value) {
          continue;
        }
        for (final svt in useEventDeck ? follower.eventUserSvtLeaderHash : follower.userSvtLeaderHash) {
          if (supportSvtIds.isNotEmpty && !supportSvtIds.contains(svt.svtId)) {
            continue;
          }
          if (supportEquipIds.isNotEmpty && !supportEquipIds.contains(svt.equipTarget1?.svtId)) {
            continue;
          }
          if (supportEquipMaxLimitBreak && svt.equipTarget1?.limitCount != 4) continue;
          return (follower, svt);
        }
      }
    }
  }

  Future<FResponse> battleResultWithOptions({
    required BattleEntity battleEntity,
    required BattleResultType resultType,
    required String actionLogs,
    List<int> usedTurnArray = const [],
  }) async {
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
      final quest =
          await AtlasApi.questPhase(battleEntity.questId, battleEntity.questPhase, region: network.gameTop.region);
      final _usedTurnArray = List.generate(stageCount, (index) {
        int baseTurn = index == stageCount - 1 ? 1 : 0;
        final enemyCount = battleEntity.battleInfo!.enemyDeck.getOrNull(index)?.svts.length;
        if (enemyCount != null) {
          final posCount = quest?.stages.getOrNull(index)?.enemyFieldPosCountReal ?? 3;
          baseTurn += (enemyCount / posCount).ceil().clamp(1, 10) - 1;
        }
        return baseTurn;
      });
      usedTurnArray = [
        for (final (index, v) in _usedTurnArray.indexed) (usedTurnArray.getOrNull(index) ?? 0).clamp(v, 999),
      ];
      final totalTurns = Maths.sum(usedTurnArray.map((e) => max(1, e)));
      if (actionLogs.isEmpty) {
        actionLogs = List<String>.generate(totalTurns, (i) => const ['1B2B3B', '1B1D2C', '1B1C2B'][i % 3]).join('');
      }
      if (!RegExp(r'^' + (r'[123][BCD]' * totalTurns * 3) + r'$').hasMatch(actionLogs)) {
        throw Exception('Invalid action logs or not match turn length: $usedTurnArray, $actionLogs');
      }
      List<BattleRaidResult> raidResults = [];
      final enemies = battleEntity.battleInfo?.enemyDeck.expand((e) => e.svts).toList() ?? [];
      final userSvtIdMap = {
        for (final userSvt in battleEntity.battleInfo?.userSvt ?? <BattleUserServantData>[]) userSvt.id: userSvt,
      };
      for (final enemy in enemies) {
        final raidDay1 = enemy.enemyScript?['raid'] as int?;
        if (raidDay1 == null) continue;
        final userSvt = userSvtIdMap[enemy.userSvtId]!;
        final raidDay =
            battleEntity.battleInfo?.raidInfo.firstWhereOrNull((e) => e.uniqueId == enemy.uniqueId)?.day ?? -1;
        if (raidDay1 != raidDay) {
          throw SilentException('raid day mismatch: $raidDay1 != $raidDay');
        }
        raidResults.add(BattleRaidResult(
          uniqueId: enemy.uniqueId,
          day: raidDay,
          addDamage: userSvt.hp,
        ));
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
        raidResult: raidResults,
        aliveUniqueIds: [],
      );
    } else {
      throw Exception('resultType=$resultType not supported');
    }
  }

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

// UserPresentBoxWindow.PRESENT_OVERFLOW_TYPE
enum PresentOverflowType {
  none(0),
  svt(1),
  svtEquip(2),
  item(3),
  commandCode(4),
  ;

  const PresentOverflowType(this.value);
  final int value;
}

class EventRaidInfoRecord {
  EventRaidEntity? eventRaid;
  List<({int timestamp, BattleRaidInfo raidInfo, int? battleId})> history = [];
}
