part of '../state.dart';

const int kMaxRandomMissionCount = 20;

extension FakerRandomMission on FakerRuntime {
  RandomMissionOption get _option => agent.user.randomMission;

  Future<void> startRandomMissionLoop() async {
    if (_option.maxFreeCount <= 0) return;
    if (randomMissionStat.cqs0.length != 1) {
      throw Exception('${randomMissionStat.cqs0.length} CQ, need 1.');
    }
    final cq0 = randomMissionStat.cqs0.single;

    QuestPhase cq = (await AtlasApi.questPhase(cq0.id, cq0.phases.single))!;
    final fqs = [for (final fq in randomMissionStat.fqs0) (await AtlasApi.questPhase(fq.id, fq.phases.last))!];

    final bestIds = <int>{
      for (final mission in randomMissionStat.eventMissions.values)
        if (_option.getItemWeight(mission.gifts.first.objectId) >= 2) mission.id,
    };
    randomMissionStat.curLoopData = RandomMissionOption();
    for (final _ in range(_option.maxFreeCount)) {
      for (final i in range(max(1, _option.discardLoopCount))) {
        if (i > 0) {
          await _discardMission(2);
        }
        while (mstData.randomMissionProgress.length <= kMaxRandomMissionCount - 2) {
          await _procQuest(cq, true);
          if (mstData.randomMissionProgress.length == kMaxRandomMissionCount - 1) {
            await _discardMission(1);
          }
        }
        // if (discardNum == 0) break;
        final openIds = bestIds.intersection(mstData.randomMissionProgress.keys.toSet());
        final openRate = openIds.length / bestIds.length;
        print('important: ${openIds.length}/${bestIds.length}=${openRate.toStringAsFixed(2)}');
        if (openRate > 0.6) break;
        await Future.delayed(Duration(seconds: 2));
      }
      final nextQuest = _findNextFreeQuest(fqs);
      await _procQuest(nextQuest, false);
    }
  }

  Future<int> _discardMission(int maxCount) async {
    final randomMissionProgress = mstData.randomMissionProgress;
    final removeItemIds = _option.itemWeights.entries.where((e) => e.value <= 0).map((e) => e.key).toList();
    List<int> removeMissionIds = randomMissionProgress.keys.where((e) {
      final mission = randomMissionStat.eventMissions[e];
      return mission != null && mission.gifts.every((e) => removeItemIds.contains(e.objectId));
    }).toList();
    removeMissionIds.sortByList((e) {
      final mission = randomMissionStat.eventMissions[e]!;
      return <int>[
        (_option.getItemWeight(mission.gifts.first.objectId) * 100).toInt(),
        mission.clearConds.first.targetNum,
        randomMissionProgress[e]!,
      ];
    });
    if (removeMissionIds.length > _option.discardMissionMinLeftNum) {
      removeMissionIds = removeMissionIds
          .take(removeMissionIds.length - _option.discardMissionMinLeftNum)
          .take(maxCount)
          .toList();
    }
    for (final missionId in removeMissionIds) {
      await agent.eventMissionRandomCancel(missionId: missionId);
    }
    return removeItemIds.length;
  }

  Future<void> _procQuest(Quest quest, bool isCQ) async {
    if (quest.flags.contains(QuestFlag.dropFirstTimeOnly) != isCQ || (quest.consume == 5) != isCQ) {
      throw SilentException('Quest ${quest.id}(${quest.lName.l}), isCQ=$isCQ.');
    }
    final battleOptionIndex = isCQ ? _option.cqTeamIndex : _option.fqTeamIndex;
    if (battleOptionIndex < 0 || battleOptionIndex >= agent.user.battleOptions.length) {
      throw SilentException('Invalid battleOptionIndex=$battleOptionIndex (0~${agent.user.battleOptions.length - 1})');
    }
    agent.user.curBattleOptionIndex = battleOptionIndex;
    final battleOption = agent.user.curBattleOption;
    battleOption
      ..questId = quest.id
      ..questPhase = quest.phases.last
      ..loopCount = 1;
    final startTime = DateTime.now().timestamp;
    final beforeClearNums = {for (final m in mstData.userEventRandomMission) m.missionId: m.clearNum};
    final beforeMissionIds = mstData.randomMissionProgress.keys.toSet();
    await startLoop(dialog: false);
    final afterClearNums = {for (final m in mstData.userEventRandomMission) m.missionId: m.clearNum};
    final afterMissionIds = mstData.randomMissionProgress.keys.toSet();
    randomMissionStat.lastAddedMissionIds = afterMissionIds.difference(beforeMissionIds);

    void addStuff(void Function(RandomMissionOption o) change) {
      change(_option);
      change(randomMissionStat.curLoopData);
    }

    for (final (missionId, afterNum) in afterClearNums.items) {
      final beforeNum = beforeClearNums[missionId];
      if (beforeNum == null) continue;
      final addCount = afterNum - beforeNum;
      if (addCount > 0) {
        if (addCount != 1) {
          logger.w('Random mission $missionId addCount=$addCount>1');
        }
        final gifts = randomMissionStat.eventMissions[missionId]?.gifts ?? [];
        for (final gift in gifts) {
          addStuff((o) => o.giftItems.addNum(gift.objectId, gift.num));
        }
      }
    }

    final battleEntity = agent.lastBattle;
    final battleResultData = agent.lastBattleResultData;
    if (battleEntity == null) {
      throw SilentException('Battle data not found');
    }
    if (battleResultData == null || battleResultData.battleId != battleEntity.id) {
      throw SilentException('Battle result data not found');
    }
    if (battleEntity.createdAt < startTime - 2) {
      throw SilentException('createdAt is before start time: ${battleEntity.createdAt}-$startTime');
    }
    addStuff((o) => o.totalAp += quest.consume);
    addStuff((o) => o.questCounts.addNum(quest.id, 1));

    if (isCQ) {
      addStuff((o) => o.cqCount += 1);
    } else {
      randomMissionStat.lastBattleResultData = battleResultData;
      addStuff((o) => o.fqCount += 1);
      _option.maxFreeCount -= 1;
    }
    for (final drop in battleResultData.resultDropInfos) {
      addStuff((o) => o.dropItems.addNum(drop.objectId, drop.num));
    }
  }

  QuestPhase _findNextFreeQuest(List<QuestPhase> quests) {
    final missionProgresses = mstData.randomMissionProgress;
    final stats = quests.where((e) => e.recommendLevel >= QuestLevel.k90pp).map((quest) {
      int completeNum = 0;
      double score = 0.0, score2 = 0.0;
      for (final (missionId, progress) in missionProgresses.items) {
        final mission = randomMissionStat.eventMissions[missionId]!;
        final customMission = CustomMission.fromEventMission(mission);
        if (customMission == null) continue;
        final int addCount = MissionSolver.countMissionTarget(customMission, quest);
        if (addCount <= 0) continue;
        double addProgress;
        if (progress + addCount >= customMission.count) {
          completeNum += 1;
          // addProgress = 1;
          addProgress = (customMission.count - progress) / customMission.count;
        } else {
          addProgress = progress / customMission.count;
        }
        score += Maths.sum(mission.gifts.map((e) => _option.getItemWeight(e.objectId) * e.num * addProgress));
        score2 += Maths.sum(
          mission.gifts
              .where((e) => _option.getItemWeight(e.objectId) >= 2)
              .map((e) => _option.getItemWeight(e.objectId) * e.num * addProgress),
        );
      }
      return (quest: quest, completeNum: completeNum, score: score, score2: score2);
    }).toList();
    stats.sortByList((e) => [-e.score2, -e.score, -e.completeNum, -e.quest.id]);
    if (stats.first.completeNum < 2) {
      stats.sortByList((e) => [-e.completeNum, -e.score, -e.quest.id]);
    }
    // final random = Random();
    // if (stats.length > 3 && random.nextDouble() < 0.1) {
    //   return stats[random.nextInt(3)].quest;
    // }
    return stats.first.quest;
  }
}
