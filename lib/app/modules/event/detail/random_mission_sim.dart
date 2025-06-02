import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/app/modules/master_mission/solver/solver.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/simple_accordion.dart';

const int kMaxMissionCount = 20;
const int kAppleAp = 147;

/// 假设：
///   - 无活动素材加成
///   - 优先找素材奖励多的，然后找完成任务数多的free本
///   -
///
class RandomMissionSimulationPage extends StatefulWidget {
  final Event event;
  const RandomMissionSimulationPage({super.key, required this.event});

  @override
  State<RandomMissionSimulationPage> createState() => _RandomMissionSimulationPageState();
}

class _RandomMissionSimulationPageState extends State<RandomMissionSimulationPage> {
  late final event = widget.event;
  late final List<int> randomMissionIds;
  final Map<int, EventMission> eventMissions = {};
  final Map<int, (int type, List<int> targetIds, int count)> missionConds = {};
  late final allQuests = db.gameData.wars[event.warIds.firstOrNull]?.quests ?? [];
  // late final _cqs = allQuests.where((e) => e.consume == 5 && e.afterClear == QuestAfterClearType.repeatLast).toList();
  late final _cqs = [db.gameData.quests[94064001]!];
  late final _fqs = allQuests.where((e) => e.isAnyFree && e.consume > 0).toList();

  // late final eventMissions = {for (final mission in event.missions) mission.id: mission};

  final List<_SimStatData> history = [];
  final random = Random();
  bool _running = false;
  bool _stopFlag = false;

  @override
  void initState() {
    super.initState();
    final maxRank = Maths.max(event.randomMissions.map((e) => e.condNum), 0);
    randomMissionIds = event.randomMissions.where((e) => e.condNum == maxRank).map((e) => e.missionId).toList();
    randomMissionIds.sort();
    for (final mission in event.missions) {
      if (!randomMissionIds.contains(mission.id)) continue;
      eventMissions[mission.id] = mission;
      final cond = mission.conds.firstWhere((e) => e.missionProgressType == MissionProgressType.clear);
      final detail = cond.details.first;
      missionConds[mission.id] = (detail.missionCondType, detail.targetIds.toList(), cond.targetNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    const int kApPer = 100;
    return Scaffold(
      appBar: AppBar(
        title: Text("Random Mission - ${history.length}"),
        actions: [
          IconButton(
            onPressed: () async {
              if (_running) {
                _stopFlag = true;
                return;
              }
              try {
                _running = true;

                for (final x in range(3, 10)) {
                  // for (final x in range(1, 11)) {
                  for (final y in range(2, 3)) {
                    if (_stopFlag) {
                      return;
                    }
                    final data = _SimStatData();
                    data.discardLoop = x;
                    data.discardMissionMinLeftNum = y;
                    await _startSimulation(data);
                    history.sort2((data) {
                      return -Maths.sum(
                        data.giftItems.entries.where((e) => data.getScore(e.key) >= 2).map((e) => e.value),
                      );
                    });
                    if (mounted) setState(() {});
                  }
                }
              } catch (e, s) {
                logger.e('random mission monte carlo failed', e, s);
                EasyLoading.showError(e.toString());
              } finally {
                _running = false;
                if (mounted) setState(() {});
              }

              // InputCancelOkDialog(
              //   title: 'Discard Mission Min Left Num',
              //   keyboardType: TextInputType.number,
              //   text: history.lastOrNull?.discardMissionMinLeftNum.toString() ?? '0',
              //   validate: (s) => int.parse(s) >= 0,
              //   onSubmit: (s) async {
              //     if (_running) return;
              //     try {
              //       _running = true;
              //       final data = _SimStatData();
              //       data.discardMissionMinLeftNum = int.parse(s);
              //       await _startSimulation(data);
              //     } catch (e, s) {
              //       logger.e('random mission monte carlo failed', e, s);
              //       EasyLoading.showError(e.toString());
              //     } finally {
              //       _running = false;
              //       if (mounted) setState(() {});
              //     }
              //   },
              // ).showDialog(context);
            },
            icon: Icon(Icons.play_circle),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final data = history[index];
          return SimpleAccordion(
            expanded: true,
            headerBuilder: (context, _) {
              final itemCount = Maths.sum(data.giftItems.entries.where((e) => e.key > 100).map((e) => e.value));
              final importantItemCount = Maths.sum(
                data.giftItems.entries.where((e) => e.key > 100 && (data.getScore(e.key)) >= 2).map((e) => e.value),
              );
              return ListTile(
                dense: true,
                title: Text(
                  '${data.cqCount} CQs ${data.fqCount} FQs. ${data.ap} AP. ${Maths.sum(data.missionCounts.values)} missions.'
                  '\n$itemCount($importantItemCount) items. ${(itemCount / data.ap * kApPer).toStringAsFixed(3)} item/${kApPer}AP.',
                ),
                // subtitle: Text('${data.elapse.toStringX()}  ${data.startedAt.toTimeString()}'),
                trailing: Text('l=${data.discardLoop}\nm=${data.discardMissionMinLeftNum}'),
              );
            },
            contentBuilder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 1,
                      runSpacing: 1,
                      children: [
                        for (final (itemId, count) in Item.sortMapByPriority(
                          data.giftItems,
                          reversed: true,
                          removeZero: false,
                        ).items)
                          Item.iconBuilder(
                            context: context,
                            item: null,
                            itemId: itemId,
                            width: 36,
                            text: [
                              (data.getScore(itemId)).format(),
                              count == 0 ? '-' : (data.ap / count).format(),
                              (count / data.ap * kApPer).format(),
                              count.format(),
                            ].join('\n'),
                          ),
                      ],
                    ),
                  ),
                  for (final questId in data.questCounts.keys.toList()..sort2((e) => -data.questCounts[e]!))
                    ListTile(
                      dense: true,
                      trailing: Text('${data.questCounts[questId]}'),
                      onTap: () => router.push(url: Routes.questI(questId)),
                      title: Text(
                        'A ${db.gameData.quests[questId]!.recommendLv} ${db.gameData.quests[questId]!.lDispName}',
                      ),
                    ),
                  // Divider(),
                  // for (final missionId in randomMissionIds.toList()..sort2((e) => -(data.missionCounts[e] ?? 0)))
                  //   ListTile(
                  //     dense: true,
                  //     trailing: Text('${data.missionCounts[missionId] ?? 0}'),
                  //     title: Text('B ${eventMissions[missionId]!.name}'),
                  //     tileColor: Colors.blue.withAlpha(50),
                  //   ),
                  // Divider(),
                  // for (final (missionId, count) in data.missionProgresses.items)
                  //   ListTile(
                  //     dense: true,
                  //     trailing: Text('$count'),
                  //     title: Text('C ${eventMissions[missionId]!.name}'),
                  //   ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _startSimulation(_SimStatData data) async {
    if (_cqs.length != 1) {
      throw Exception('${_cqs.length} CQ, need 1.');
    }
    final cq0 = _cqs.single;

    EasyLoading.showProgress(0, status: 'starting...');
    // int kCircleCount = data.kCircleCount;
    int kMaxAppleCount = data.kMaxAppleCount;

    int kToastStep = kMaxAppleCount ~/ 10;
    QuestPhase cq = (await AtlasApi.questPhase(cq0.id, cq0.phases.single))!;
    final fqs = [for (final fq in _fqs) (await AtlasApi.questPhase(fq.id, fq.phases.last))!];
    for (final missionId in randomMissionIds) {
      for (final gift in eventMissions[missionId]!.gifts) {
        data.giftItems.addNum(gift.objectId, 0);
      }
    }

    // loop
    EasyLoading.showProgress(0, status: 'Running 0/$kMaxAppleCount...');
    final importantMissionIds = eventMissions.values
        .where((e) => (data.getScore(e.gifts.first.objectId)) >= 2)
        .map((e) => e.id)
        .toSet();
    while (data.ap < kMaxAppleCount * kAppleAp) {
      for (final i in range(data.discardLoop)) {
        if (i > 0) discardMission(data);
        while (data.missionProgresses.length <= kMaxMissionCount - 2) {
          // 打一次高难本，+2任务
          procQuest(cq, data);
          assignMission(2, data);
        }
        // if (discardNum == 0) break;
        final ongoingImportantMissionIds = importantMissionIds.intersection(data.missionProgresses.keys.toSet());
        if (ongoingImportantMissionIds.length / importantMissionIds.length > 0.9) break;
      }
      final nextQuest = findNextFreeQuest(fqs, data);
      // print('run FQ Lv.${nextQuest.recommendLv} ${nextQuest.lName.l}');
      procQuest(nextQuest, data);
      assignMission(2, data);
      int usedApple = data.ap ~/ kAppleAp;
      if (usedApple > 0 && usedApple % kToastStep == 0) {
        // print(index / kCircleCount);
        EasyLoading.showProgress(usedApple / kMaxAppleCount, status: 'Running $usedApple/$kMaxAppleCount...');
        await Future.delayed(Duration.zero);
      }
    }
    EasyLoading.showSuccess('Finished');
    data.elapse = DateTime.now().difference(data.startedAt);
    history.add(data);
  }

  void assignMission(int count, _SimStatData data) {
    for (final _ in range(count)) {
      if (data.missionProgresses.length >= kMaxMissionCount) continue;
      final validMissionIds = randomMissionIds.where((e) => !data.missionProgresses.containsKey(e)).toList();
      if (validMissionIds.isEmpty) {
        assert(() {
          throw Exception('No mission available.');
        }());
        continue;
      }
      data.missionProgresses[validMissionIds[random.nextInt(validMissionIds.length)]] = 0;
    }
  }

  int discardMission(_SimStatData data) {
    final removeItemIds = data.itemScores.keys.where((e) => data.itemScores[e]! <= 0).toList();
    List<int> removeMissionIds = data.missionProgresses.keys.where((e) {
      final mission = eventMissions[e]!;
      return mission.gifts.every((e) => removeItemIds.contains(e.objectId));
    }).toList();
    removeMissionIds.sortByList((e) {
      final mission = eventMissions[e]!;
      return <int>[
        ((data.getScore(mission.gifts.first.objectId)) * 100).toInt(),
        mission.clearConds.first.targetNum,
        data.missionProgresses[e]!,
      ];
    });
    if (removeMissionIds.length > data.discardMissionMinLeftNum) {
      removeMissionIds = removeMissionIds
          .take(removeMissionIds.length - data.discardMissionMinLeftNum)
          .take(2)
          .toList();
    }
    data.missionProgresses.removeWhere((e, v) => removeMissionIds.contains(e));
    return removeItemIds.length;
  }

  // enemyIndividualityKillNum(2),
  // targetQuestItemGetTotal(8),
  // allQuestItemGetTotal(12),
  // battleSvtClassSpecificNum(18),
  void procQuest(QuestPhase quest, _SimStatData data) {
    final bool isCQ = quest.flags.contains(QuestFlag.dropFirstTimeOnly);
    final team = isCQ ? data.cqTeam : data.fqTeam;
    for (final missionId in data.missionProgresses.keys.toList()) {
      int progress = data.missionProgresses[missionId]!;
      final mission = eventMissions[missionId]!;
      final cond = mission.clearConds.first;
      final detail = cond.details.first;
      final detailCondType = EventMissionCondDetailType.parseId(detail.missionCondType)!;
      // if (detailCondType == null) continue;
      if (detailCondType == EventMissionCondDetailType.targetQuestItemGetTotal ||
          detailCondType == EventMissionCondDetailType.allQuestItemGetTotal) {
        if (quest.flags.contains(QuestFlag.dropFirstTimeOnly) || isCQ) continue;
        for (final drop in quest.drops) {
          if (!detail.targetIds.contains(drop.objectId)) continue;
          double dropRate = drop.dropCount / drop.runs;
          progress += (dropRate.toInt() + (random.nextDouble() < (dropRate % 1.0) ? 1 : 0)) * drop.num;
        }
      } else if (detailCondType == EventMissionCondDetailType.battleSvtClassSpecificNum) {
        if (team.any((e) => detail.targetIds.contains(e.value))) {
          progress += 1;
        }
      } else {
        final customMission = CustomMission.fromEventMission(mission);
        if (customMission == null) continue;
        progress += MissionSolver.countMissionTarget(customMission, quest);
      }
      if (progress >= cond.targetNum) {
        // receive gift
        data.missionProgresses.remove(missionId);
        for (final gift in mission.gifts) {
          data.giftItems.addNum(gift.objectId, gift.num);
        }
        data.missionCounts.addNum(missionId, 1);
      } else {
        data.missionProgresses[missionId] = progress;
      }
    }
    if (data.missionProgresses.length + 2 > kMaxMissionCount) {
      print('Exceed mission count [${isCQ ? "CQ" : "FQ"}]: ${data.missionProgresses.length}+2>$kMaxMissionCount');
    }
    data.questCounts.addNum(quest.id, 1);
    if (isCQ) {
      data.cqCount += 1;
    } else {
      data.fqCount += 1;
    }
    data.ap += quest.consume;
  }

  QuestPhase findNextFreeQuest(List<QuestPhase> quests, _SimStatData data) {
    final stats = quests.where((e) => (e.recommendLv) == '90++').map((quest) {
      int completeNum = 0;
      double score = 0.0, score2 = 0.0;
      for (final (missionId, progress) in data.missionProgresses.items) {
        final mission = eventMissions[missionId]!;
        final customMission = CustomMission.fromEventMission(mission);
        if (data.getScore(mission.gifts.first.objectId) <= 0) continue;
        if (customMission == null) continue;
        final int addCount = MissionSolver.countMissionTarget(customMission, quest);
        if (addCount <= 0) continue;
        double addProgress;
        if (progress + addCount >= customMission.count) {
          completeNum += 1;
          // addProgress = 1;
          addProgress = (customMission.count - progress) / customMission.count;
          // addProgress *= 0.5;
        } else {
          addProgress = progress / customMission.count;
        }
        score += Maths.sum(mission.gifts.map((e) => max(0, data.getScore(e.objectId)) * e.num * addProgress));
        score2 += Maths.sum(
          mission.gifts
              .where((e) => data.getScore(e.objectId) >= 2)
              .map((e) => max(0, data.getScore(e.objectId)) * e.num * addProgress),
        );
      }
      return (quest: quest, completeNum: completeNum, score: score, score2: score2);
    }).toList();
    stats.sortByList((e) => [-e.score2, -e.score, -e.completeNum, -e.quest.id]);
    if (stats.first.completeNum < 2) {
      stats.sortByList((e) => [-e.completeNum, -e.score, -e.quest.id]);
    }
    if (stats.length > 2 && random.nextDouble() < 0.1) {
      return stats[random.nextInt(2)].quest;
    }
    return stats.first.quest;
  }
}

class _SimStatData {
  DateTime startedAt = DateTime.now();
  Duration elapse = Duration.zero;
  // quest stat
  Map<int, int> questCounts = {};
  int cqCount = 0;
  int fqCount = 0;
  int ap = 0;
  // item stat
  Map<int, int> giftItems = {};
  // mission stat
  Map<int, int> missionCounts = {};
  // runtime;
  Map<int, int> missionProgresses = {};

  // config
  double getScore(int itemId) => itemScores[itemId] ?? 1.0;
  final itemScores = <int, double>{
    1: -2.0, // QP
    4: -1.0, // 友情点
    3: -3.0, // 魔力棱镜
    6549: 0.8, // 赦免的小钟
    6503: 0.8, // 英雄之证
    6502: 0.2, // 世界树之种
    6505: 0.5, // 虚影之尘
    6545: 2.5, // 神脉灵子x
    6543: 1.8, // 光银之冠
    6520: 2.1, // 血之泪石
    6539: 2.5, // 晓光炉心
    6517: 0.1, // 蛮神心脏
    6548: 2.5, // 鬼炎鬼灯x
  };
  final cqTeam = [SvtClass.alterEgo, SvtClass.avenger];
  final fqTeam = [SvtClass.berserker, SvtClass.alterEgo, SvtClass.lancer, SvtClass.alterEgo, SvtClass.berserker];
  // final int kCircleCount = 100000;
  final int kMaxAppleCount = 1000;
  int discardMissionMinLeftNum = 2;
  int discardLoop = 1;
}
