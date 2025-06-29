import 'dart:math';
import 'dart:typed_data';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/basic.dart';
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

  Future<FResponse> userPresentReceive({
    required List<int64_t> presentIds,
    required int32_t itemSelectIdx,
    required int32_t itemSelectNum,
  });
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
  Future<FResponse> servantLimitCombine({required int64_t baseUserSvtId});
  Future<FResponse> servantLevelExceed({required int64_t baseUserSvtId});

  Future<FResponse> servantEquipCombine({required int64_t baseUserSvtId, required List<int64_t> materialSvtIds});

  Future<FResponse> commandCodeUnlock({required int32_t servantId, required int32_t idx});

  Future<FResponse> userStatusFlagSet({required List<int32_t> onFlagNumbers, required List<int32_t> offFlagNumbers});

  Future<FResponse> deckSetup({required int64_t activeDeckId, required UserDeckEntity userDeck});

  Future<FResponse> eventDeckSetup({
    required UserEventDeckEntity userEventDeck,
    required int32_t eventId,
    required int32_t questId,
    required int32_t phase,
    int32_t restartWave = 0,
  });

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

    final notSuppportedFlags = const {
      QuestFlag.notSingleSupportOnly,
      QuestFlag.superBoss,
      QuestFlag.branch,
      QuestFlag.branchHaving,
      QuestFlag.branchScenario,
    }.intersection(questPhaseEntity.flags.toSet());
    if (notSuppportedFlags.isNotEmpty) {
      throw SilentException('Finding support but not supported flags: $notSuppportedFlags');
    }

    if (questPhaseEntity.extraDetail?.questSelect?.isNotEmpty == true) {
      throw SilentException('questSelect not supported');
    }

    if (questPhaseEntity.restrictions.any(
      (restriction) => restriction.restriction.type == RestrictionType.dataLostBattleUniqueSvt,
    )) {
      throw SilentException('DATA LOST battle not supported');
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
      // should check campaign time rather item endedAt
      List<(UserItemEntity, Item)> campaignItems = [];
      final now = DateTime.now().timestamp;

      Future<void> _checkAddCampaignItem(int itemId) async {
        final userItem = mstData.userItem[itemId];
        if (userItem == null || userItem.num <= 0) return;
        final jpItem = db.gameData.items[userItem.itemId];
        if (jpItem != null && jpItem.type != ItemType.friendshipUpItem) return;
        final item = region == Region.jp ? jpItem : await AtlasApi.item(userItem.itemId, region: region);
        if (item == null || item.type != ItemType.friendshipUpItem) return;
        if (item.startedAt < now && item.endedAt > now) {
          campaignItems.add((userItem, item));
        }
      }

      if (options.campaignItemId != 0) {
        await _checkAddCampaignItem(options.campaignItemId);
      } else {
        for (final userItem in mstData.userItem) {
          await _checkAddCampaignItem(userItem.itemId);
        }
      }
      if (campaignItems.isEmpty) {
        throw Exception('no valid Teapot item found');
      }
      print("Teapot count: ${{for (final x in campaignItems) x.$1.itemId: x.$1.num}}");

      campaignItems.sort2((e) => e.$2.endedAt);
      campaignItemId = campaignItems.first.$1.itemId;
    }

    if (questPhaseEntity.isNoBattle) {
      if (!questPhaseEntity.flags.contains(QuestFlag.noBattle)) {
        throw SilentException('No stage, but don not have noBattle flag.');
      }
      return battleScenario(questId: questPhaseEntity.id, questPhase: questPhaseEntity.phase, routeSelect: []);
    }
    int eventId =
        db.gameData.others.eventQuestGroups.entries
            .firstWhereOrNull((e) => e.value.contains(questPhaseEntity.id))
            ?.key ??
        0;

    int activeDeckId, followerId, followerClassId, followerType, followerSupportDeckId, followerGrandGraphId = 0;
    int userEquipId = 0;

    if (questPhaseEntity.isUseUserEventDeck()) {
      activeDeckId = questPhaseEntity.extraDetail?.useEventDeckNo ?? 1;
      final eventDeck = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, activeDeckId)];
      if (eventDeck == null) {
        throw SilentException('UserEventDeck(eventId=$eventId,deckNo=$activeDeckId) not found');
      }
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
      final eventDeck = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, activeDeckId)]!;
      userEquipId = eventDeck.deckInfo!.userEquipId;
    } else if (questPhaseEntity.flags.contains(QuestFlag.eventDeckNoSupport) ||
        questPhaseEntity.flags.contains(QuestFlag.noSupportList)) {
      followerId = 0;
      followerClassId = 0;
      followerType = 0;
      followerSupportDeckId = 0;
    } else {
      final bool isUseGrandBoard = questPhaseEntity.isUseGrandBoard;
      final (follower, followerSvt) = await _getValidSupport(
        questPhaseEntity: questPhaseEntity,
        useEventDeck: options.useEventDeck ?? db.gameData.others.shouldUseEventDeck(options.questId),
        enforceRefreshSupport: options.enfoceRefreshSupport,
        supportSvtIds: options.supportSvtIds.toList(),
        supportEquipIds: options.supportEquipIds.toList(),
        grandSupportEquipIds: options.grandSupportEquipIds.toList(),
        supportEquipMaxLimitBreak: options.supportCeMaxLimitBreak,
        isUseGrandBoard: isUseGrandBoard,
      );
      followerId = follower.userId;
      followerClassId = followerSvt.classId;
      followerType = follower.type;
      followerSupportDeckId = followerSvt.supportDeckId;
      followerGrandGraphId = followerSvt.grandGraphId;
    }

    return battleSetup(
      questId: options.questId,
      questPhase: options.questPhase,
      activeDeckId: activeDeckId,
      followerId: followerId,
      followerClassId: followerClassId,
      followerType: followerType,
      followerSupportDeckId: followerSupportDeckId,
      followerGrandGraphId: followerGrandGraphId,
      campaignItemId: campaignItemId,
      userEquipId: userEquipId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required QuestPhase questPhaseEntity,
    required bool useEventDeck,
    required bool enforceRefreshSupport,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
    required List<int> grandSupportEquipIds,
    required bool supportEquipMaxLimitBreak,
    required bool isUseGrandBoard,
  }) async {
    int refreshCount = 0;
    List<FollowerInfo> followers = [];
    if (network.gameTop.region == Region.cn && !enforceRefreshSupport) {
      final oldUserFollower = network.mstData.userFollower.firstWhereOrNull(
        (e) => e.expireAt > DateTime.now().timestamp + 300,
      );
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
          questId: questPhaseEntity.id,
          questPhase: questPhaseEntity.phase,
          isEnfoceRefresh: enforceRefreshSupport || refreshCount > 0,
        );
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
        for (var svtInfo in useEventDeck ? follower.eventUserSvtLeaderHash : follower.userSvtLeaderHash) {
          if (supportSvtIds.isNotEmpty && !supportSvtIds.contains(svtInfo.svtId)) {
            continue;
          }

          if (isUseGrandBoard && svtInfo.grandSvt == 1) {
            svtInfo = follower.userSvtGrandHash.firstWhereOrNull((e) => e.userSvtId == svtInfo.userSvtId) ?? svtInfo;
          }
          Set<int> followerEquipIds = {
            if (!supportEquipMaxLimitBreak || svtInfo.equipTarget1?.limitCount == 4) svtInfo.equipTarget1?.svtId,
            if (isUseGrandBoard) ...[
              if (!supportEquipMaxLimitBreak || svtInfo.equipTarget2?.limitCount == 4) svtInfo.equipTarget2?.svtId,
              if (!supportEquipMaxLimitBreak || svtInfo.equipTarget3?.limitCount == 4) svtInfo.equipTarget3?.svtId,
            ],
          }.whereType<int>().toSet();
          if (followerEquipIds.isEmpty) continue;
          if (followerEquipIds.isNotEmpty) {
            if (supportEquipIds.toSet().intersection(followerEquipIds).isEmpty) continue;
            if (grandSupportEquipIds.isNotEmpty) {
              if (grandSupportEquipIds.toSet().intersection(supportEquipIds.toSet()).isNotEmpty) {
                throw SilentException("Grand Servant's CE option should not be the same as normal CE");
              }
              if (grandSupportEquipIds.toSet().intersection(followerEquipIds).isEmpty) continue;
            }
          }
          // grand duel
          final dbSvt = db.gameData.servantsById[svtInfo.svtId];
          if (dbSvt == null) continue;
          final traits = dbSvt
              .getIndividuality(questPhaseEntity.logicEvent?.id, svtInfo.dispLimitCount)
              .map((e) => e.id)
              .toSet();
          if (!questPhaseEntity.restrictions.every((restriction) {
            if (restriction.restriction.type == RestrictionType.individuality) {
              final hasTrait = restriction.restriction.targetVals.toSet().intersection(traits).isNotEmpty;
              return switch (restriction.restriction.rangeType) {
                RestrictionRangeType.equal => hasTrait,
                RestrictionRangeType.notEqual => !hasTrait,
                _ => true,
              };
            }
            return true;
          })) {
            continue;
          }

          return (follower, svtInfo);
        }
      }
    }
  }

  Future<FResponse> battleResultWithOptions({
    required BattleEntity battleEntity,
    required BattleResultType resultType,
    required String actionLogs,
    List<int> usedTurnArray = const [],
    bool checkSkillShift = true,
    Duration? sendDelay,
  }) async {
    final battleInfo = battleEntity.battleInfo!;
    final stageCount = battleInfo.enemyDeck.length;
    if (resultType == BattleResultType.cancel) {
      return battleResult(
        battleId: battleEntity.id,
        resultType: BattleResultType.cancel,
        winResult: BattleWinResultType.none,
        action: BattleDataActionList(logs: "", dt: battleInfo.enemyDeck.first.svts.map((e) => e.uniqueId).toList()),
        usedTurnArray: List.generate(stageCount, (i) => i == 0 ? 1 : 0),
        aliveUniqueIds: battleInfo.enemyDeck.expand((e) => e.svts).map((e) => e.uniqueId).toList(),
        waveNum: 1,
        sendDelay: sendDelay,
      );
    } else if (resultType == BattleResultType.win) {
      final quest = await AtlasApi.questPhase(
        battleEntity.questId,
        battleEntity.questPhase,
        region: network.gameTop.region,
      );
      final _usedTurnArray = List.generate(stageCount, (index) {
        int baseTurn = index == stageCount - 1 ? 1 : 0;
        final enemyCount = battleInfo.enemyDeck.getOrNull(index)?.svts.length;
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
      final enemies = battleInfo.enemyDeck.expand((e) => e.svts).toList();
      final userSvtIdMap = {for (final userSvt in battleInfo.userSvt) userSvt.id: userSvt};
      for (final enemy in enemies) {
        final raidDay1 = enemy.enemyScript?['raid'] as int?;
        if (raidDay1 == null) continue;
        final userSvt = userSvtIdMap[enemy.userSvtId]!;
        final raidDay = battleInfo.raidInfo.firstWhereOrNull((e) => e.uniqueId == enemy.uniqueId)?.day ?? -1;
        if (raidDay1 != raidDay) {
          throw SilentException('raid day mismatch: $raidDay1 != $raidDay');
        }
        raidResults.add(BattleRaidResult(uniqueId: enemy.uniqueId, day: raidDay, addDamage: userSvt.hp));
      }
      final callDeckEnemies = battleInfo.callDeck.expand((e) => e.svts).toList();
      List<int> calledEnemyUniqueIdArray = callDeckEnemies
          .where((e) => e.dropInfos.isNotEmpty)
          .map((e) => e.uniqueId)
          .toList();
      calledEnemyUniqueIdArray = callDeckEnemies.map((e) => e.uniqueId).toList();
      // final itemDroppedSkillShiftEnemies =
      //     battleInfo.shiftDeck.expand((e) => e.svts).where((e) => e.dropInfos.isNotEmpty).toList();
      final skillShiftEnemies = [
        ...battleInfo.enemyDeck,
        ...battleInfo.callDeck,
        ...battleInfo.shiftDeck,
      ].expand((e) => e.svts).where((e) => e.enemyScript?.containsKey('skillShift') == true).toList();
      if (skillShiftEnemies.isNotEmpty && checkSkillShift) {
        throw SilentException('skillShift not supported');
      }
      return battleResult(
        battleId: battleEntity.id,
        resultType: BattleResultType.win,
        winResult: BattleWinResultType.normal,
        action: BattleDataActionList(
          logs: actionLogs,
          dt: battleInfo.enemyDeck.last.svts.map((e) => e.uniqueId).toList(),
        ),
        usedTurnArray: usedTurnArray,
        raidResult: raidResults,
        aliveUniqueIds: [],
        calledEnemyUniqueIdArray: calledEnemyUniqueIdArray,
        waveNum: stageCount,
        // skillShiftUniqueIdArray: itemDroppedSkillShiftEnemies.map((e) => e.uniqueId).toList(),
        // skillShiftNpcSvtIdArray: itemDroppedSkillShiftEnemies.map((e) => e.npcId).toList(),
        sendDelay: sendDelay,
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
