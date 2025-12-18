import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/faker.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '_base.dart';

class FakerRuntimeBattle extends FakerRuntimeBase {
  FakerRuntimeBattle(super.runtime);

  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  Future<void> startLoop({bool dialog = true}) async {
    if (runtime.agentData.curBattle != null) {
      throw SilentException('last battle not finished');
    }
    final battleOption = this.battleOption;
    if (battleOption.loopCount <= 0) {
      throw SilentException('loop count (${battleOption.loopCount}) must >0');
    }
    // if (battleOption.targetDrops.values.any((v) => v < 0)) {
    //   throw SilentException('loop target drop num must >=0 (0=always)');
    // }
    if (battleOption.winTargetItemNum.values.any((v) => v <= 0)) {
      throw SilentException('win target drop num must >0');
    }
    if (battleOption.recoverIds.isNotEmpty && battleOption.waitApRecover) {
      throw SilentException('Do not turn on both apple recover and wait AP recover');
    }
    final questPhaseEntity = await AtlasApi.questPhase(
      battleOption.questId,
      battleOption.questPhase,
      region: agent.user.region,
    );
    if (questPhaseEntity == null) {
      throw SilentException('quest not found');
    }
    if (battleOption.loopCount > 1 &&
        !(questPhaseEntity.afterClear == QuestAfterClearType.repeatLast &&
            battleOption.questPhase == questPhaseEntity.phases.lastOrNull)) {
      throw SilentException('Not repeatable quest or phase');
    }
    if (battleOption.winTargetItemNum.isNotEmpty && !questPhaseEntity.flags.contains(QuestFlag.actConsumeBattleWin)) {
      throw SilentException('Win target drops should be used only if Quest has flag actConsumeBattleWin');
    }
    final shouldUseEventDeck = db.gameData.others.isNeedUseEventQuestSupport(questPhaseEntity.id);
    if (battleOption.useEventSupport != null && battleOption.useEventSupport != shouldUseEventDeck) {
      if (!runtime.mounted) {
        throw SilentException('This quest should set "Use Event Deck"=$shouldUseEventDeck');
      }
      final confirm = await runtime.showLocalDialog(
        SimpleConfirmDialog(
          title: Text('Use Event Support'),
          content: Text('Supposed: $shouldUseEventDeck\nSetting: ${battleOption.useEventSupport}'),
        ),
      );
      if (confirm != true) {
        throw SilentException('Mismatch event support setting.\nSupposed: $shouldUseEventDeck');
      }
    }
    int finishedCount = 0, totalCount = battleOption.loopCount;
    List<int> elapseSeconds = [];
    runtime.agentData.curLoopDropStat.reset();
    agent.network.lastTaskStartedAt = 0;
    runtime.displayToast('Battle $finishedCount/$totalCount', progress: finishedCount / totalCount);
    while (finishedCount < totalCount) {
      runtime.checkStop();
      runtime.checkSvtKeep();
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption, questPhaseEntity);
      }

      final int startTime = DateTime.now().timestamp;
      final msg =
          'Battle ${finishedCount + 1}/$totalCount, ${Maths.mean(elapseSeconds).round()}s/${(Maths.sum(elapseSeconds) / 60).toStringAsFixed(1)}m';
      logger.t(msg);
      runtime.displayToast(msg, progress: (finishedCount + 0.5) / totalCount);

      await _ensureEnoughApItem(quest: questPhaseEntity, option: battleOption);

      runtime.update();
      FResponse setupResp = await battleSetupWithOptions(battleOption);
      runtime.update();

      FResponse resultResp;
      if (setupResp.data.mstData.battles.isEmpty) {
        if (setupResp.request.normKey.contains('scenario')) {
          // do nothing
          resultResp = setupResp;
        } else {
          throw SilentException('[${setupResp.request.key}] battle data not found');
        }
      } else {
        final battleEntity = setupResp.data.mstData.battles.single;
        final curBattleDrops = battleEntity.battleInfo?.getTotalDrops() ?? {};
        logger.t('battle id: ${battleEntity.id}');

        bool shouldRetire = false;
        if (battleOption.winTargetItemNum.isNotEmpty) {
          shouldRetire = true;
          for (final (itemId, targetNum) in battleOption.winTargetItemNum.items) {
            if ((curBattleDrops[itemId] ?? 0) >= targetNum) {
              shouldRetire = false;
              break;
            }
          }
        }

        if (questPhaseEntity.flags.contains(QuestFlag.raid)) {
          await agent.battleTurn(battleId: battleEntity.id);
        }

        if (shouldRetire) {
          resultResp = await battleResultWithOptions(
            battleEntity: battleEntity,
            resultType: BattleResultType.cancel,
            options: battleOption,
            sendDelay: const Duration(seconds: 1),
          );
        } else {
          final delay = battleOption.battleDuration ?? (agent.network.gameTop.region == Region.cn ? 40 : 20);
          resultResp = await battleResultWithOptions(
            battleEntity: battleEntity,
            resultType: BattleResultType.win,
            options: battleOption,
            sendDelay: Duration(seconds: delay),
          );
          // if win
          runtime.agentData.totalDropStat.totalCount += 1;
          runtime.agentData.curLoopDropStat.totalCount += 1;
          Map<int, int> resultBattleDrops;
          final lastBattleResultData = runtime.agentData.lastBattleResultData;
          if (lastBattleResultData != null && lastBattleResultData.battleId == battleEntity.id) {
            resultBattleDrops = {};
            for (final drop in lastBattleResultData.resultDropInfos) {
              resultBattleDrops.addNum(drop.objectId, drop.num);
            }
            for (final reward in lastBattleResultData.rewardInfos) {
              runtime.agentData.battleTotalRewards.addNum(reward.objectId, reward.num);
            }
            for (final reward in lastBattleResultData.friendshipRewardInfos) {
              runtime.agentData.battleTotalRewards.addNum(reward.objectId, reward.num);
            }
          } else {
            resultBattleDrops = curBattleDrops;
            logger.t('last battle result data not found, use cur_battle_drops');
          }
          runtime.agentData.totalDropStat.items.addDict(resultBattleDrops);
          runtime.agentData.curLoopDropStat.items.addDict(resultBattleDrops);
          runtime.agentData.battleTotalRewards.addDict(resultBattleDrops);

          // check total drop target of this loop
          if (battleOption.targetDrops.isNotEmpty) {
            for (final (itemId, targetNum) in battleOption.targetDrops.items.toList()) {
              final dropNum = resultBattleDrops[itemId];
              if (dropNum == null || dropNum <= 0) continue;
              battleOption.targetDrops[itemId] = targetNum - dropNum;
            }
            final reachedItems = battleOption.targetDrops.keys
                .where((itemId) => resultBattleDrops.containsKey(itemId) && battleOption.targetDrops[itemId]! <= 0)
                .toList();
            if (reachedItems.isNotEmpty) {
              throw SilentException(
                'Target drop reaches: ${reachedItems.map((e) => GameCardMixin.anyCardItemName(e).l).join(', ')}',
              );
            }
          }
        }
      }

      final userQuest = mstData.userQuest[questPhaseEntity.id];
      if (userQuest != null && userQuest.clearNum == 0 && questPhaseEntity.phases.contains(userQuest.questPhase + 1)) {
        battleOption.questPhase = userQuest.questPhase + 1;
      }
      for (final item in resultResp.data.mstData.userItem) {
        runtime.agentData.battleTotalRewards.addNum(item.itemId, 0);
      }

      finishedCount += 1;
      battleOption.loopCount -= 1;

      elapseSeconds.add(DateTime.now().timestamp - startTime);
      runtime.update();
      if (questPhaseEntity.flags.contains(QuestFlag.raid) && finishedCount % 5 == 1) {
        // update raid info
        await agent.homeTop();
      }
      runtime.update();
      await Future.delayed(const Duration(milliseconds: 100));
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption, questPhaseEntity);
      }
    }
    logger.t('finished all $finishedCount battles');
    if (dialog) {
      runtime.showLocalDialog(
        SimpleConfirmDialog(title: const Text('Finished'), content: Text('$finishedCount battles'), showCancel: false),
        barrierDismissible: false,
      );
    }
  }

  Future<FResponse> battleSetupWithOptions(AutoBattleOptions options) async {
    final region = agent.network.user.region;
    final quest = db.gameData.quests[options.questId];
    final mstData = agent.network.mstData;
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

    final notSupportedFlags = const {
      QuestFlag.notSingleSupportOnly,
      QuestFlag.superBoss,
      QuestFlag.branch,
      QuestFlag.branchHaving,
      QuestFlag.branchScenario,
    }.intersection(questPhaseEntity.flags.toSet());
    if (notSupportedFlags.isNotEmpty) {
      throw SilentException('Finding support but not supported flags: $notSupportedFlags');
    }

    await _checkQuestCondition(questPhaseEntity, options.checkQuestCondition);

    if (questPhaseEntity.restrictions.any(
      (restriction) => restriction.restriction.type == RestrictionType.dataLostBattleUniqueSvt,
    )) {
      throw SilentException('DATA LOST battle not supported');
    }

    final curAp = mstData.user!.calCurAp();
    if (questPhaseEntity.consumeType.useAp) {
      final consume = options.isApHalf ? questPhaseEntity.consume ~/ 2 : questPhaseEntity.consume;
      if (curAp < consume) {
        throw Exception('AP not enough: $curAp<$consume');
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

    for (final script in questPhaseEntity.scripts) {
      final routes = script.getRouteSelects();
      if (routes.isNotEmpty) {
        throw SilentException('Script ${script.shortId()} has ${routes.length} route selects: $routes');
      }
    }

    int questSelect = 0;
    final questSelects = questPhaseEntity.extraDetail?.questSelect ?? [];
    if (questSelects.isNotEmpty) {
      if (!runtime.mounted) {
        throw SilentException('questSelect: $questSelects, not mounted');
      }
      final select = await runtime.showLocalDialog<int>(_QuestSelectBranchDialog(questSelects: questSelects));
      if (select == null) {
        throw SilentException('questSelect: $questSelects, canceled');
      }
      questSelect = select;
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
      await agent.battleSetupScenario(questId: questPhaseEntity.id, questPhase: questPhaseEntity.phase);
      await Future.delayed(Duration(seconds: 10));
      return agent.battleScenario(questId: questPhaseEntity.id, questPhase: questPhaseEntity.phase, routeSelect: []);
    }
    int eventId =
        db.gameData.others.eventQuestGroups.entries
            .firstWhereOrNull((e) => e.value.contains(questPhaseEntity.id))
            ?.key ??
        0;

    int activeDeckId, followerId, followerClassId, followerType, followerSupportDeckId, followerGrandGraphId = 0;
    int userEquipId = 0;

    UserDeckEntityBase? myDeck;
    if (questPhaseEntity.isUseUserEventDeck()) {
      activeDeckId = questPhaseEntity.extraDetail?.useEventDeckNo ?? 1;
      myDeck = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, activeDeckId)];
      if (myDeck == null) {
        throw SilentException('UserEventDeck(eventId=$eventId,deckNo=$activeDeckId) not found');
      }
    } else {
      activeDeckId = options.deckId;
      myDeck = mstData.userDeck[activeDeckId];
      if (myDeck == null) {
        throw SilentException('UserDeck($activeDeckId) not found');
      }
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
        useEventSupport: options.useEventSupport ?? db.gameData.others.isNeedUseEventQuestSupport(options.questId),
        myDeck: myDeck,
        enforceRefreshSupport: options.enfoceRefreshSupport,
        supportSvtIds: options.supportSvtIds.toList(),
        supportEquipIds: options.supportEquipIds.toList(),
        grandSupportEquipIds: options.grandSupportEquipIds.toList(),
        supportEquipMaxLimitBreak: options.supportEquipMaxLimitBreak,
        isUseGrandBoard: isUseGrandBoard,
      );
      followerId = follower.userId;
      followerClassId = followerSvt.classId;
      followerType = follower.type;
      followerSupportDeckId = followerSvt.supportDeckId;
      followerGrandGraphId = followerSvt.grandGraphId;
    }

    return agent.battleSetup(
      questId: options.questId,
      questPhase: options.questPhase,
      activeDeckId: activeDeckId,
      followerId: followerId,
      followerClassId: followerClassId,
      followerType: followerType,
      followerSupportDeckId: followerSupportDeckId,
      followerGrandGraphId: followerGrandGraphId,
      enemySelect: questSelect,
      questSelect: questSelect,
      campaignItemId: campaignItemId,
      userEquipId: userEquipId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required QuestPhase questPhaseEntity,
    required bool useEventSupport,
    required UserDeckEntityBase myDeck,
    required bool enforceRefreshSupport,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
    required List<int> grandSupportEquipIds,
    required bool supportEquipMaxLimitBreak,
    required bool isUseGrandBoard,
  }) async {
    int refreshCount = 0;
    List<FollowerInfo> followers = [];
    if (agent.network.gameTop.region == Region.cn && !enforceRefreshSupport) {
      final oldUserFollower = agent.network.mstData.userFollower.firstWhereOrNull(
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
        final resp = await agent.followerList(
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
        for (var svtInfo in useEventSupport ? follower.eventUserSvtLeaderHash : follower.userSvtLeaderHash) {
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
            if (isUseGrandBoard && grandSupportEquipIds.isNotEmpty) {
              if (grandSupportEquipIds.toSet().intersection(supportEquipIds.toSet()).isNotEmpty) {
                throw SilentException("Grand Servant's CE option should not be the same as normal CE");
              }
              if (grandSupportEquipIds.toSet().intersection(followerEquipIds).isEmpty) continue;
            }
          }
          final dbSvt = db.gameData.servantsById[svtInfo.svtId];
          if (dbSvt == null) continue;

          // grand duel etc.
          final traits = dbSvt.getIndividuality(questPhaseEntity.logicEventId, svtInfo.dispLimitCount).toSet();
          if (!questPhaseEntity.restrictions.every((restriction) {
            if (restriction.restriction.type == RestrictionType.individuality) {
              return Restriction.checkSvtIndiv(
                restriction.restriction.rangeType,
                restriction.restriction.targetVals,
                traits.toList(),
              );
            } else if (restriction.restriction.type == RestrictionType.uniqueSvtOnly) {
              if (myDeck.deckInfo?.svts.any((e) => e.svtId == svtInfo.svtId) ?? true) return false;
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
    required AutoBattleOptions options,
    Duration? sendDelay,
  }) async {
    final battleInfo = battleEntity.battleInfo!;
    final stageCount = battleInfo.enemyDeck.length;
    if (resultType == BattleResultType.cancel) {
      return agent.battleResult(
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
      await _checkSkillShift(battleEntity, battleOption);

      final quest = await AtlasApi.questPhase(
        battleEntity.questId,
        battleEntity.questPhase,
        region: agent.network.gameTop.region,
      );
      if (quest == null) {
        throw SilentException('quest not found');
      }
      final _usedTurnArray = List.generate(stageCount, (index) {
        int baseTurn = index == stageCount - 1 ? 1 : 0;
        final enemyCount = battleInfo.enemyDeck.getOrNull(index)?.svts.length;
        if (enemyCount != null) {
          final posCount = quest.stages.getOrNull(index)?.enemyFieldPosCountReal ?? 3;
          baseTurn += (enemyCount / posCount).ceil().clamp(1, 10) - 1;
        }
        return baseTurn;
      });
      final usedTurnArray = [
        for (final (index, v) in _usedTurnArray.indexed) (options.usedTurnArray.getOrNull(index) ?? 0).clamp(v, 999),
      ];
      final totalTurns = Maths.sum(usedTurnArray.map((e) => max(1, e)));
      String actionLogs = options.actionLogs;
      if (actionLogs.isEmpty) {
        actionLogs = List<String>.generate(totalTurns, (i) => const ['1B2B3B', '1B1D2C', '1B1C2B'][i % 3]).join('');
      }
      if (!RegExp(r'^' + (r'[123][BCD]' * totalTurns * 3) + r'$').hasMatch(actionLogs)) {
        throw Exception('Invalid action logs or not match turn length: $usedTurnArray, $actionLogs');
      }
      final userSvtIdMap = battleInfo.userSvtMap;
      final enemies = battleInfo.enemyDeck.expand((e) => e.svts).toList();

      List<BattleRaidResult> raidResults = [];
      for (final enemy in enemies) {
        final raidDay1 = enemy.enemyScript?.raid;
        if (raidDay1 == null) continue;
        final userSvt = userSvtIdMap[enemy.userSvtId]!;
        final raidDay = battleInfo.raidInfo.firstWhereOrNull((e) => e.uniqueId == enemy.uniqueId)?.day ?? -1;
        if (raidDay1 != raidDay) {
          throw SilentException('raid day mismatch: $raidDay1 != $raidDay');
        }
        raidResults.add(BattleRaidResult(uniqueId: enemy.uniqueId, day: raidDay, addDamage: userSvt.hp));
      }

      // alive
      List<int> aliveUniqueIds = [];
      if (options.customAliveUniqueId) {
        if (!runtime.mounted) throw SilentException('Need custom alive uniqueIds but not mounted');
        final _aliveUniqueIds = await runtime.showLocalDialog<List<int>>(
          _AliveEnemySelectDialog(battleInfo: battleInfo, questPhase: quest),
          barrierDismissible: false,
        );
        if (_aliveUniqueIds == null) {
          throw SilentException('cancel alive uniqueId selection');
        }
        aliveUniqueIds = _aliveUniqueIds;
      }

      // call deck
      final callDeckEnemies = battleInfo.callDeck.expand((e) => e.svts).toList();
      List<int> calledEnemyUniqueIdArray = callDeckEnemies
          .where((e) => e.dropInfos.isNotEmpty)
          .map((e) => e.uniqueId)
          .toList();
      calledEnemyUniqueIdArray = callDeckEnemies.map((e) => e.uniqueId).toList();

      // skillShift
      final skillShiftEnemies = [
        ...battleInfo.enemyDeck,
        ...battleInfo.callDeck,
        ...battleInfo.shiftDeck,
      ].expand((e) => e.svts).where((e) => e.isSkillShift()).toList();
      if (skillShiftEnemies.isNotEmpty && !options.enableSkillShift) {
        throw SilentException('skillShift not enabled');
      }
      final itemDroppedSkillShiftEnemies = skillShiftEnemies
          .where((e) => options.skillShiftEnemyUniqueIds.contains(e.uniqueId))
          .toList();
      if (skillShiftEnemies.isNotEmpty &&
          itemDroppedSkillShiftEnemies.length != options.skillShiftEnemyUniqueIds.length) {
        throw SilentException(
          'valid skillShift uniqueIds: ${skillShiftEnemies.map((e) => e.uniqueId).toSet()}, '
          'but received ${options.skillShiftEnemyUniqueIds}',
        );
      }

      return agent.battleResult(
        battleId: battleEntity.id,
        resultType: BattleResultType.win,
        winResult: BattleWinResultType.normal,
        action: BattleDataActionList(
          logs: actionLogs,
          dt: battleInfo.enemyDeck.last.svts.map((e) => e.uniqueId).toList(),
        ),
        usedTurnArray: usedTurnArray,
        raidResult: raidResults,
        aliveUniqueIds: aliveUniqueIds,
        calledEnemyUniqueIdArray: calledEnemyUniqueIdArray,
        waveNum: stageCount,
        skillShiftUniqueIdArray: itemDroppedSkillShiftEnemies.map((e) => e.uniqueId).toList(),
        skillShiftNpcSvtIdArray: itemDroppedSkillShiftEnemies.map((e) => e.npcId).toList(),
        sendDelay: sendDelay,
      );
    } else {
      throw Exception('resultType=$resultType not supported');
    }
  }

  Future<void> _checkQuestCondition(QuestPhase questPhase, bool checkCond) async {
    final now = DateTime.now().timestamp;
    if (questPhase.openedAt > now || questPhase.closedAt < now) {
      throw SilentException('quest not open');
    }

    if (checkCond) {
      for (final release in questPhase.releaseOverwrites) {
        if (release.startedAt > now || now > release.endedAt) continue;
        if (runtime.condCheck.isCondOpen(release.condType, release.condId, release.condNum) ?? false) {
          return;
        }
      }

      for (final release in questPhase.releaseConditions) {
        if (!(runtime.condCheck.isCondOpen(release.type, release.targetId, release.value) ?? false)) {
          throw SilentException(
            'Condition failed: ${release.type.name}-${release.targetId}-${release.value}\n${release.closedMessage}'
                .trim(),
          );
        }
      }
    }
  }

  Future<bool> _checkSkillShift(BattleEntity battleEntity, AutoBattleOptions options) async {
    final battleInfo = battleEntity.battleInfo;
    if (battleInfo == null) {
      throw SilentException("battle ${battleEntity.id}: null battleInfo");
    }
    final skillShiftEnemies = {
      for (final deck in [...battleInfo.enemyDeck, ...battleInfo.callDeck, ...battleInfo.shiftDeck])
        for (final svt in deck.svts)
          if (svt.isSkillShift()) '${svt.uniqueId}-${svt.npcId}': svt,
    };

    if (skillShiftEnemies.isEmpty) {
      options.skillShiftEnemyUniqueIds.clear();
      return true;
    }

    if (!options.enableSkillShift) {
      throw SilentException('skillShift not enabled: ${skillShiftEnemies.length} skillShift enemies');
    }

    if (!runtime.mounted) {
      throw SilentException('found skillShift but not mounted');
    }

    final skillShiftEnemyUniqueIds = await runtime.showLocalDialog<List<int>?>(
      _SkillShiftEnemySelectDialog(
        battleInfo: battleInfo,
        skillShiftEnemies: skillShiftEnemies.values.toList(),
        skillShiftEnemyUniqueIds: options.skillShiftEnemyUniqueIds,
      ),
    );
    if (skillShiftEnemyUniqueIds == null) {
      throw SilentException('cancel skillShift');
    }

    final itemDroppedSkillShiftEnemies = skillShiftEnemies.values
        .where((e) => skillShiftEnemyUniqueIds.contains(e.uniqueId))
        .toList();
    if (itemDroppedSkillShiftEnemies.length != skillShiftEnemyUniqueIds.length) {
      throw SilentException(
        'valid skillShift uniqueId-npcId: ${skillShiftEnemies.keys.toList()}, '
        'but received $skillShiftEnemyUniqueIds',
      );
    }

    options.skillShiftEnemyUniqueIds = skillShiftEnemyUniqueIds.toList();
    return true;
  }

  Future<void> seedWait(final int maxBuyCount) async {
    int boughtCount = 0;
    while (boughtCount < maxBuyCount) {
      const int apUnit = 40, seedUnit = 1;
      final apCount = mstData.user?.calCurAp() ?? 0;
      final seedCount = mstData.getItemOrSvtNum(Items.blueSaplingId);
      if (seedCount <= 0) {
        throw SilentException('no Blue Sapling left');
      }
      int buyCount = Maths.min([maxBuyCount, apCount ~/ apUnit, seedCount ~/ seedUnit]);
      if (buyCount > 0) {
        await agent.terminalApSeedExchange(buyCount);
        boughtCount += buyCount;
      }
      runtime.update();
      runtime.displayToast('Seed $boughtCount/$maxBuyCount - waiting...');
      await Future.delayed(const Duration(minutes: 1));
      runtime.checkStop();
    }
  }

  Future<void> _ensureEnoughApItem({required QuestPhase quest, required AutoBattleOptions option}) async {
    if (quest.consumeType.useItem) {
      for (final item in quest.consumeItem) {
        final own = mstData.getItemOrSvtNum(item.itemId);
        if (own < item.amount) {
          throw SilentException('Consume Item not enough: ${item.itemId}: $own<${item.amount}');
        }
      }
    }
    if (quest.consumeType.useAp) {
      final apConsume = option.isApHalf ? quest.consume ~/ 2 : quest.consume;
      if (mstData.user!.calCurAp() >= apConsume) {
        return;
      }
      for (final recoverId in option.recoverIds) {
        final recover = mstRecovers[recoverId];
        if (recover == null) continue;
        int dt = mstData.user!.actRecoverAt - DateTime.now().timestamp;
        if ((recover.id == 1 || recover.id == 2) && option.waitApRecoverGold && dt > 300 && dt % 300 < 240) {
          final waitUntil = DateTime.now().timestamp + dt % 300 + 2;
          while (true) {
            final now = DateTime.now().timestamp;
            if (now >= waitUntil) break;
            runtime.displayToast('Wait ${waitUntil - now} seconds...');
            await Future.delayed(Duration(seconds: min(5, waitUntil - now)));
            runtime.checkStop();
          }
        }
        if (recover.recoverType == RecoverType.stone && mstData.user!.stone > 0) {
          await agent.shopPurchaseByStone(id: recover.targetId, num: 1);
          break;
        } else if (recover.recoverType == RecoverType.item) {
          final item = db.gameData.items[recover.targetId];
          if (item == null) continue;
          if (item.type == ItemType.apAdd) {
            final count = ((apConsume - mstData.user!.calCurAp()) / item.value).ceil();
            if (count > 0 && count < mstData.getItemOrSvtNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          } else if (item.type == ItemType.apRecover) {
            final count = ((apConsume - mstData.user!.calCurAp()) / (item.value / 1000 * mstData.user!.actMax).ceil())
                .ceil();
            if (count > 0 && count <= mstData.getItemOrSvtNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          }
        } else {
          continue;
        }
      }
      if (mstData.user!.calCurAp() >= apConsume) {
        return;
      }
      if (option.waitApRecover) {
        while (mstData.user!.calCurAp() < apConsume) {
          runtime.update();
          runtime.displayToast('Battle - waiting AP recover...');
          await Future.delayed(const Duration(minutes: 1));
          runtime.checkStop();
        }
        return;
      }
      throw SilentException('AP not enough: ${mstData.user!.calCurAp()}<$apConsume');
    }
  }

  void _checkFriendship(AutoBattleOptions option, QuestPhase questPhase) {
    final deck = questPhase.isUseUserEventDeck()
        ? mstData.userEventDeck[UserEventDeckEntity.createPK(
            questPhase.logicEventId ?? 0,
            questPhase.extraDetail?.useEventDeckNo ?? 1,
          )]
        : mstData.userDeck[battleOption.deckId];
    final svts = deck?.deckInfo?.svts ?? [];
    for (final svt in svts) {
      if (svt.userSvtId > 0) {
        final userSvt = mstData.userSvt[svt.userSvtId];
        if (userSvt == null) {
          throw SilentException('UserSvt ${svt.userSvtId} not found');
        }
        final dbSvt = db.gameData.servantsById[userSvt.svtId];
        if (dbSvt == null) {
          throw SilentException('Unknown Servant ID ${userSvt.svtId}');
        }
        final svtCollection = mstData.userSvtCollection[userSvt.svtId];
        if (svtCollection == null) {
          throw SilentException('UserServantCollection ${userSvt.svtId} not found');
        }
        if (svtCollection.friendshipRank >= svtCollection.maxFriendshipRank) {
          throw SilentException(
            'Svt No.${dbSvt.collectionNo} ${dbSvt.lName.l} reaches max bond Lv.${svtCollection.maxFriendshipRank}',
          );
        }
      }
    }
  }
}

class _AliveEnemySelectDialog extends StatefulWidget {
  final BattleInfoData battleInfo;
  final QuestPhase questPhase;

  const _AliveEnemySelectDialog({required this.battleInfo, required this.questPhase});

  @override
  State<_AliveEnemySelectDialog> createState() => __AliveEnemySelectDialogState();
}

class __AliveEnemySelectDialogState extends State<_AliveEnemySelectDialog> {
  late final battleInfo = widget.battleInfo;
  late final questPhase = widget.questPhase;
  late final userSvtMap = battleInfo.userSvtMap;

  final Set<int> _aliveUniqueIds = {};

  @override
  Widget build(BuildContext context) {
    Set<BattleDeckServantData> stageEnemies = {};
    final callEnemies = {for (final svt in battleInfo.callDeck.expand((e) => e.svts)) svt.npcId: svt};
    final shiftEnemies = {for (final svt in battleInfo.shiftDeck.expand((e) => e.svts)) svt.npcId: svt};

    void _addEnemy(BattleDeckServantData? enemy) {
      if (enemy == null || stageEnemies.contains(enemy)) return;
      if (enemy.uniqueId == 0) return;
      stageEnemies.add(enemy);

      final callNpcIds = {...?enemy.enemyScript?.call};
      for (final npcId in callNpcIds) {
        _addEnemy(callEnemies[npcId]);
      }
      final shiftNpcIds = {...?enemy.enemyScript?.shift, ...?enemy.enemyScript?.skillShift};
      for (final npcId in shiftNpcIds) {
        _addEnemy(shiftEnemies[npcId]);
      }
    }

    for (final enemy in battleInfo.enemyDeck.last.svts) {
      _addEnemy(enemy);
    }
    for (final npcId in questPhase.stages.lastOrNull?.call ?? <int>[]) {
      _addEnemy(callEnemies[npcId]);
    }

    return AlertDialog(
      scrollable: true,
      title: Text('${_aliveUniqueIds.length}/${stageEnemies.length} Alive Unique Ids'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [for (final enemy in stageEnemies) buildEnemy(enemy)]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _aliveUniqueIds.toList());
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  Widget buildEnemy(BattleDeckServantData enemy) {
    final userSvt = userSvtMap[enemy.userSvtId];
    final svt = db.gameData.entities[userSvt?.svtId];
    return CheckboxListTile.adaptive(
      value: _aliveUniqueIds.contains(enemy.uniqueId),
      secondary: svt?.iconBuilder(context: context),
      title: Text(enemy.name ?? svt?.lName.l ?? 'npcId ${enemy.npcId}'),
      subtitle: Text('id=${enemy.id} uniqueId=${enemy.uniqueId} npcId=${enemy.npcId}'),
      controlAffinity: ListTileControlAffinity.trailing,
      onChanged: (value) {
        setState(() {
          _aliveUniqueIds.toggle(enemy.uniqueId);
        });
      },
    );
  }
}

class _SkillShiftEnemySelectDialog extends StatefulWidget {
  final BattleInfoData battleInfo;
  final List<BattleDeckServantData> skillShiftEnemies;
  final List<int> skillShiftEnemyUniqueIds;
  const _SkillShiftEnemySelectDialog({
    required this.battleInfo,
    required this.skillShiftEnemies,
    required this.skillShiftEnemyUniqueIds,
  });

  @override
  State<_SkillShiftEnemySelectDialog> createState() => __SkillShiftEnemySelectDialogState();
}

class __SkillShiftEnemySelectDialogState extends State<_SkillShiftEnemySelectDialog> {
  late final skillShiftEnemies = widget.skillShiftEnemies.toList();
  late Set<int> selectedUniqueIds = skillShiftEnemies.map((e) => e.uniqueId).toSet();
  late final userSvtMap = widget.battleInfo.userSvtMap;

  @override
  void initState() {
    super.initState();
    final intersection = selectedUniqueIds.intersection(widget.skillShiftEnemyUniqueIds.toSet());
    if (intersection.isNotEmpty) {
      selectedUniqueIds = intersection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('skillShift enemies'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final enemy in skillShiftEnemies) buildEnemy(enemy)],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, [
              for (final enemy in skillShiftEnemies)
                if (selectedUniqueIds.contains(enemy.uniqueId)) enemy.uniqueId,
            ]);
          },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  Widget buildEnemy(BattleDeckServantData enemy) {
    final userSvt = userSvtMap[enemy.userSvtId];
    final svt = db.gameData.entities[userSvt?.svtId];
    return CheckboxListTile.adaptive(
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
      value: selectedUniqueIds.contains(enemy.uniqueId),
      secondary: svt?.iconBuilder(context: context, width: 32),
      title: Text(enemy.name ?? svt?.lName.l ?? userSvt?.svtId.toString() ?? 'UNKNOWN'),
      subtitle: Text('uniqueId ${enemy.uniqueId} npcId ${enemy.npcId}, id ${enemy.id} userSvtId ${enemy.userSvtId}'),
      onChanged: (v) {
        setState(() {
          selectedUniqueIds.toggle(enemy.uniqueId);
        });
      },
    );
  }
}

class _QuestSelectBranchDialog extends StatelessWidget {
  final List<int> questSelects;
  const _QuestSelectBranchDialog({required this.questSelects});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select Branch'),
      children: [
        for (final (index, questId) in questSelects.indexed)
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, index);
            },
            child: Text('No.$index - $questId'),
          ),
      ],
    );
  }
}
