import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/app/modules/master_mission/solver/solver.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import '_base.dart';

const int kMaxRandomMissionCount = 20;

class FakerRuntimeEvent extends FakerRuntimeBase {
  FakerRuntimeEvent(super.runtime);

  // random mission
  late final randomMissionStat = runtime.agentData.randomMissionStat;
  late final _randomMissionOption = agent.user.randomMission;

  Future<void> startRandomMissionLoop() async {
    if (_randomMissionOption.maxFreeCount <= 0) return;
    if (randomMissionStat.cqs0.length != 1) {
      throw Exception('${randomMissionStat.cqs0.length} CQ, need 1.');
    }
    final cq0 = randomMissionStat.cqs0.single;

    QuestPhase cq = (await AtlasApi.questPhase(cq0.id, cq0.phases.single))!;
    final fqs = [for (final fq in randomMissionStat.fqs0) (await AtlasApi.questPhase(fq.id, fq.phases.last))!];

    final bestIds = <int>{
      for (final mission in randomMissionStat.eventMissions.values)
        if (_randomMissionOption.getItemWeight(mission.gifts.first.objectId) >= 2) mission.id,
    };
    randomMissionStat.curLoopData = RandomMissionOption();
    for (final _ in range(_randomMissionOption.maxFreeCount)) {
      for (final i in range(max(1, _randomMissionOption.discardLoopCount))) {
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
    final removeItemIds = _randomMissionOption.itemWeights.entries
        .where((e) => e.value <= 0)
        .map((e) => e.key)
        .toList();
    List<int> removeMissionIds = randomMissionProgress.keys.where((e) {
      final mission = randomMissionStat.eventMissions[e];
      return mission != null && mission.gifts.every((e) => removeItemIds.contains(e.objectId));
    }).toList();
    removeMissionIds.sortByList((e) {
      final mission = randomMissionStat.eventMissions[e]!;
      return <int>[
        (_randomMissionOption.getItemWeight(mission.gifts.first.objectId) * 100).toInt(),
        mission.clearConds.first.targetNum,
        randomMissionProgress[e]!,
      ];
    });
    if (removeMissionIds.length > _randomMissionOption.discardMissionMinLeftNum) {
      removeMissionIds = removeMissionIds
          .take(removeMissionIds.length - _randomMissionOption.discardMissionMinLeftNum)
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
    final battleOptionIndex = isCQ ? _randomMissionOption.cqTeamIndex : _randomMissionOption.fqTeamIndex;
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
    await runtime.battle.startLoop(dialog: false);
    final afterClearNums = {for (final m in mstData.userEventRandomMission) m.missionId: m.clearNum};
    final afterMissionIds = mstData.randomMissionProgress.keys.toSet();
    randomMissionStat.lastAddedMissionIds = afterMissionIds.difference(beforeMissionIds);

    void addStuff(void Function(RandomMissionOption o) change) {
      change(_randomMissionOption);
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

    final battleEntity = runtime.agentData.lastBattle;
    final battleResultData = runtime.agentData.lastBattleResultData;
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
      _randomMissionOption.maxFreeCount -= 1;
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
        score += Maths.sum(
          mission.gifts.map((e) => _randomMissionOption.getItemWeight(e.objectId) * e.num * addProgress),
        );
        score2 += Maths.sum(
          mission.gifts
              .where((e) => _randomMissionOption.getItemWeight(e.objectId) >= 2)
              .map((e) => _randomMissionOption.getItemWeight(e.objectId) * e.num * addProgress),
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

  // box gacha
  Future<void> boxGachaDraw({
    required EventLottery lottery,
    required int drawNumOnce,
    required Ref<int> loopCount,
  }) async {
    final boxGachaId = lottery.id;
    while (loopCount.value > 0) {
      final userBoxGacha = mstData.userBoxGacha[boxGachaId];
      if (userBoxGacha == null) throw SilentException('BoxGacha $boxGachaId not in user data');
      final maxNum = lottery.getMaxNum(userBoxGacha.boxIndex);
      if (userBoxGacha.isReset && userBoxGacha.drawNum == maxNum) {
        await agent.boxGachaReset(gachaId: boxGachaId);
        runtime.update();
        continue;
      }
      // if (userBoxGacha.isReset) throw SilentException('isReset=true, not tested');
      int drawNum = min(drawNumOnce, maxNum - userBoxGacha.drawNum);
      if (userBoxGacha.resetNum <= 10 && drawNum > 10) {
        throw SilentException('Cannot draw $drawNum times in first 10 lotteries');
      }
      final ownItemCount = mstData.userItem[lottery.cost.itemId]?.num ?? 0;
      if (ownItemCount < lottery.cost.amount) {
        throw SilentException('Item noy enough: $ownItemCount');
      }
      drawNum = min(drawNum, ownItemCount ~/ lottery.cost.amount);
      if (drawNum <= 0 || drawNum > 100) {
        throw SilentException('Invalid draw num: $drawNum');
      }
      if (mstData.userPresentBox.length >= (runtime.gameData.timerData.constants.maxPresentBoxNum - 10)) {
        throw SilentException('Present Box Full');
      }
      await agent.boxGachaDraw(gachaId: boxGachaId, num: drawNum);
      loopCount.value -= 1;
      runtime.update();
    }
  }
}
