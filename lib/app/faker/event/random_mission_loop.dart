import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../option_list.dart';
import '../runtime.dart';
import '../runtimes/event.dart';
import '../user_deck/deck_list.dart';

class RandomMissionLoopPage extends StatefulWidget {
  final FakerRuntime runtime;
  // final Event event;
  const RandomMissionLoopPage({super.key, required this.runtime});

  @override
  State<RandomMissionLoopPage> createState() => _RandomMissionLoopPageState();
}

class _RandomMissionLoopPageState extends State<RandomMissionLoopPage> with FakerRuntimeStateMixin {
  @override
  late final runtime = widget.runtime;
  late final user = runtime.agent.user;
  late final option = user.randomMission;

  //
  late final stat = runtime.agentData.randomMissionStat;

  @override
  void initState() {
    super.initState();
    stat.load(runtime).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${S.current.random_mission} - Loop'), actions: [runtime.buildHistoryButton(context)]),
      body: Column(
        children: [
          battleDetailSection,
          Expanded(
            child: ListView(
              children: [
                ...optionTiles,
                ...optionTiles2,

                // questTiles,
                statTiles,
                ongoingMissions,
              ],
            ),
          ),
          ...buttonBar,
        ],
      ),
    );
  }

  List<Widget> get buttonBar {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    FilledButton buildButton({bool enabled = true, required VoidCallback onPressed, required String text}) {
      return FilledButton.tonal(onPressed: enabled ? onPressed : null, style: buttonStyle, child: Text(text));
    }

    return [
      ListenableBuilder(
        listenable: runtime.runningTask,
        builder: (context, _) {
          return LinearProgressIndicator(
            value: runtime.runningTask.value ? null : 1.0,
            color: runtime.runningTask.value ? Colors.red : Colors.green,
          );
        },
      ),
      Text(
        'AP ${mstData.user?.calCurAp()}  Mission ${mstData.userEventRandomMission.where((e) => e.isInProgress).length}/$kMaxRandomMissionCount'
        '  ${agent.user.lastRequestOptions?.key} ${agent.user.lastRequestOptions?.success}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      SafeArea(
        child: OverflowBar(
          alignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            buildButton(
              enabled: !runtime.runningTask.value,
              onPressed: () {
                runtime.runTask(
                  () => runtime.withWakeLock('loop-random-mission-$hashCode', runtime.event.startRandomMissionLoop),
                );
              },
              text: 'Loop×${option.maxFreeCount}',
            ),
            buildButton(
              onPressed: () {
                agent.network.stopFlag = true;
              },
              text: 'Stop',
            ),
          ],
        ),
      ),
    ];
  }

  Widget get statTiles {
    final freeQuestCounts = {for (final fq in stat.fqs0) fq.id: mstData.userQuest[fq.id]?.clearNum ?? 0};
    final challengeQuestCounts = {for (final cq in stat.cqs0) cq.id: mstData.userQuest[cq.id]?.clearNum ?? 0};
    final allQuestCounts = {...freeQuestCounts, ...challengeQuestCounts};
    Map<int, int> giftCounts = {};
    for (final mm in mstData.userEventRandomMission) {
      final gifts = db.gameData.others.eventMissions[mm.missionId]?.gifts ?? [];
      for (final gift in gifts) {
        giftCounts.addNum(gift.objectId, gift.num * mm.clearNum);
      }
    }
    return TileGroup(
      headerWidget: SHeader.rich(
        TextSpan(
          text: S.current.statistics_title,
          children: [
            SharedBuilder.textButtonSpan(
              context: context,
              text: '  clear',
              onTap: () {
                SimpleConfirmDialog(
                  title: Text(S.current.clear),
                  onTapOk: () {
                    runtime.lockTask(() {
                      option.resetStatData();
                    });
                  },
                ).showDialog(context);
              },
            ),
          ],
        ),
      ),
      children: [
        ...statTilesOf(S.current.current_, stat.curLoopData),
        ...statTilesOf(S.current.total, option),
        ...statTilesOf(
          '${S.current.total}*',
          RandomMissionOption(
            itemWeights: Map.of(option.itemWeights),
            giftItems: giftCounts,
            questCounts: allQuestCounts,
            cqCount: Maths.sum(challengeQuestCounts.values),
            fqCount: Maths.sum(freeQuestCounts.values),
            totalAp: Maths.sum([
              for (final (questId, count) in allQuestCounts.items) (db.gameData.quests[questId]?.consume ?? 0) * count,
            ]),
          ),
        ),
      ],
    );
  }

  List<Widget> statTilesOf(String prefix, RandomMissionOption _option) {
    final maxAp =
        db.gameData.constData.userLevel[mstData.user?.lv ?? db.gameData.constData.constants.maxUserLv]?.maxAp ?? 148;
    final giftItems = Map.of(_option.giftItems)..removeWhere((k, v) => !isNormalItem(k));
    final dropItems = Map.of(_option.dropItems)..removeWhere((k, v) => !isNormalItem(k));
    final giftCount = Maths.sum(giftItems.values),
        dropCount = Maths.sum(dropItems.values),
        totalCount = giftCount + dropCount;
    final totalAp = max(1, _option.totalAp);
    const int kApUnit = 100;
    final giftEff = giftCount / totalAp * kApUnit,
        dropEff = dropCount / totalAp * kApUnit,
        totalEff = giftEff + dropEff;
    final appleCount = _option.totalAp / maxAp;
    return [
      ListTile(
        dense: true,
        title: Text(
          '[$prefix] $giftCount+$dropCount=$totalCount items. '
          '${giftEff.format()}+${dropEff.format()}=${totalEff.format()}/${kApUnit}AP',
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final items in [_option.giftItems, dropItems])
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  for (final (itemId, count) in Item.sortMapByPriority(items, removeZero: false, reversed: true).items)
                    Item.iconBuilder(
                      context: context,
                      item: null,
                      itemId: itemId,
                      width: 32,
                      text: [
                        (count / max(1, _option.totalAp) * kApUnit).format(),
                        count.format(),
                        mstData.getItemOrSvtNum(itemId).format(),
                      ].join('\n'),
                    ),
                ],
              ),
          ],
        ),
      ),
      kDefaultDivider,
      SimpleAccordion(
        headerBuilder: (context, _) {
          final missionCount = Maths.sum(
            stat.randomMissionIds.map((e) => mstData.userEventRandomMission[e]?.clearNum ?? 0),
          );
          return ListTile(
            dense: true,
            title: Text(
              '${_option.fqCount} FQs + ${_option.cqCount} CQs. ${appleCount.toStringAsFixed(1)} Apples. $missionCount missions.',
            ),
          );
        },
        contentBuilder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final questId in _option.questCounts.keys.toList()..sort2((e) => -_option.questCounts[e]!))
                ListTile(
                  dense: true,
                  trailing: Text('${_option.questCounts[questId]}'),
                  title: Text(
                    'Lv.${db.gameData.quests[questId]!.recommendLv} ${db.gameData.quests[questId]!.lDispName}',
                  ),
                ),
            ],
          );
        },
      ),
      kDefaultDivider,
    ];
  }

  List<Widget> get optionTiles {
    List<Widget> _buildQuest(int index, ValueChanged<int> onChanged, bool showBond) {
      final team = user.battleOptions.getOrNull(index);
      final userQuest = mstData.userQuest[team?.questId];
      final userDeck = mstData.userDeck[team?.deckId];

      return [
        ListTile(
          dense: true,
          title: Text('No.${index + 1} - ${team?.name} ${db.gameData.quests[team?.questId]?.lName.l}'),
          subtitle: team == null ? null : Text('clear ${userQuest?.clearNum}  challenge ${userQuest?.challengeNum}'),
          trailing: Icon(Icons.change_circle),
          onTap: () async {
            if (runtime.runningTask.value) return;
            await router.pushPage(
              BattleOptionListPage(
                data: user,
                onSelected: (result) {
                  onChanged(result.index);
                },
              ),
            );
            if (mounted) setState(() {});
          },
        ),
        if (userDeck != null) ..._buildUserDeck(userDeck.deckInfo, showBond),
        Center(
          child: FilledButton(
            onPressed: () {
              runtime.runTask(() async {
                agent.user.curBattleOptionIndex = index;
                final battleOption = agent.user.curBattleOption;
                battleOption.loopCount = 1;
                await runtime.battle.startLoop();
              });
            },
            child: Text(S.current.start),
          ),
        ),
      ];
    }

    return [
      TileGroup(
        header: S.current.free_quest,
        children: _buildQuest(option.fqTeamIndex, (v) => option.fqTeamIndex = v, true),
      ),
      TileGroup(
        header: S.current.high_difficulty_quest,
        children: _buildQuest(option.cqTeamIndex, (v) => option.cqTeamIndex = v, false),
      ),
    ];
  }

  List<Widget> get optionTiles2 {
    return [
      TileGroup(
        header: S.current.options,
        children: [
          ListTile(
            dense: true,
            title: Text('Max Free Quest Count'),
            trailing: TextButton(
              onPressed: () {
                InputCancelOkDialog.number(
                  title: 'Max Free Quest Count',
                  initValue: option.maxFreeCount,
                  keyboardType: TextInputType.number,
                  validate: (v) => v >= 0,
                  onSubmit: (v) {
                    runtime.lockTask(() => option.maxFreeCount = v);
                  },
                ).showDialog(context);
              },
              child: Text(option.maxFreeCount.toString()),
            ),
          ),
          ListTile(
            dense: true,
            title: Text('discardMissionMinLeftNum'),
            trailing: TextButton(
              onPressed: () {
                InputCancelOkDialog.number(
                  title: 'discardMissionMinLeftNum',
                  initValue: option.discardMissionMinLeftNum,
                  keyboardType: TextInputType.number,
                  validate: (v) => v >= 0,
                  onSubmit: (v) {
                    runtime.lockTask(() => option.discardMissionMinLeftNum = v);
                  },
                ).showDialog(context);
              },
              child: Text(option.discardMissionMinLeftNum.toString()),
            ),
          ),
          ListTile(
            dense: true,
            title: Text('discardLoopCount'),
            trailing: TextButton(
              onPressed: () {
                InputCancelOkDialog.number(
                  title: 'discardLoopCount',
                  initValue: option.discardLoopCount,
                  keyboardType: TextInputType.number,
                  validate: (v) => v >= 0,
                  onSubmit: (v) {
                    runtime.lockTask(() => option.discardLoopCount = v);
                  },
                ).showDialog(context);
              },
              child: Text(option.discardLoopCount.toString()),
            ),
          ),
          ListTile(
            dense: true,
            title: Text('${S.current.item} ${S.current.calc_weight}'),
            subtitle: Wrap(
              spacing: 1,
              runSpacing: 2,
              children: [
                for (final itemId in stat.itemIds)
                  Item.iconBuilder(
                    context: context,
                    item: null,
                    itemId: itemId,
                    width: 24,
                    text: option.getItemWeight(itemId).format(),
                  ),
              ],
            ),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () async {
              await router.pushPage(ItemWeightEditPage(mstData: mstData, itemIds: stat.itemIds, option: option));
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            dense: true,
            title: Text(S.current.free_quest),
            subtitle: Text(
              '${option.enabledQuests.isEmpty ? S.current.general_all : option.enabledQuests.length}/${stat.fqs0.length}',
            ),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () async {
              await router.pushPage(RandomMissionEnableQuestPage(mstData: mstData, quests: stat.fqs0, option: option));
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    ];
  }

  Widget get ongoingMissions {
    final missions = [
      for (final userRm in mstData.userEventRandomMission)
        if (stat.eventMissions.containsKey(userRm.missionId))
          (userMission: userRm, mission: stat.eventMissions[userRm.missionId]!),
    ];
    missions.sortByList((e) {
      return [
        stat.lastAddedMissionIds.contains(e.mission.id) ? 0 : 1,
        e.userMission.isInProgress ? 0 : 1,
        -option.getItemWeight(e.mission.gifts.first.objectId),
        -e.mission.gifts.first.objectId,
        -e.mission.id,
      ];
    });
    List<Widget> children = [];
    for (final (:userMission, :mission) in missions) {
      final progresses = mstData.resolveMissionProgress(mission).progresses;
      children.add(
        ListTile(
          dense: true,
          leading: SharedBuilder.giftGrid(context: context, gifts: mission.gifts),
          title: Text(mission.name),
          enabled: userMission.isInProgress,
          selected: stat.lastAddedMissionIds.contains(mission.id),
          minLeadingWidth: 24,
          subtitle: Text('${progresses.map((e) => "${e.progress}/${e.targetNum}").join(",")} ×${userMission.clearNum}'),
          trailing: userMission.isInProgress
              ? IconButton(
                  onPressed: () {
                    SimpleConfirmDialog(
                      title: Text(S.current.remove),
                      onTapOk: () {
                        runtime.runTask(() {
                          return runtime.agent.eventMissionRandomCancel(missionId: userMission.missionId);
                        });
                      },
                    ).showDialog(context);
                  },
                  icon: Icon(Icons.close),
                )
              : null,
        ),
      );
    }
    final vipIds = <int>{
      for (final mission in stat.eventMissions.values)
        if (option.isImportant(mission.gifts.first.objectId)) mission.id,
    };
    final openVipIds = vipIds.intersection(mstData.randomMissionProgress.keys.toSet());

    return TileGroup(
      header:
          '${S.current.ongoing} ${missions.where((e) => e.userMission.isInProgress).length}'
          ' (${openVipIds.length}/${vipIds.length})',
      children: children,
    );
  }

  Widget get questTiles {
    List<Widget> children = [];
    for (final questId in option.questCounts.keys.toList()..sort2((e) => -option.questCounts[e]!)) {
      final quest = db.gameData.quests[questId];
      children.add(
        ListTile(
          dense: true,
          title: Text('${quest!.recommendLv} ${quest.lName.l}'),
          subtitle: Text(quest.lSpot.l),
          trailing: Text([option.questCounts[questId]!, mstData.userQuest[questId]?.clearNum].join('\n')),
          onTap: () => router.push(url: Routes.questI(questId)),
        ),
      );
    }
    return TileGroup(header: S.current.quest, children: children);
  }

  bool isNormalItem(int itemId) => itemId ~/ 100 == 65;

  List<Widget> _buildUserDeck(DeckServantEntity? deckInfo, bool showBond) {
    const int kSvtNumPerRow = 6;
    final svts = deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};

    List<Widget> children = [];
    for (int row = 0; row * kSvtNumPerRow < svts.length; row++) {
      if (showBond) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FormationCard(
              formation: BattleTeamFormationX.fromUserDeck(
                deckInfo: deckInfo,
                mstData: mstData,
                posOffset: row * kSvtNumPerRow,
              ),
              userSvtCollections: mstData.userSvtCollection.lookup,
            ),
          ),
        );
        Widget bondDetail = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...List.generate(kSvtNumPerRow, (index) {
              final int pos = index + 1 + kSvtNumPerRow * row;
              final collection = mstData.userSvtCollection[mstData.userSvt[svtsMap[pos]?.userSvtId]?.svtId];
              final svt = db.gameData.servantsById[collection?.svtId];
              if (collection == null || svt == null || svt.bondGrowth.length < collection.friendshipRank + 1) {
                return const Expanded(flex: 10, child: SizedBox.shrink());
              }
              final bondData = svt.getCurLvBondData(collection.friendshipRank, collection.friendship);
              final bool reachBondLimit = bondData.next == 0;

              String bondText =
                  'Lv.${collection.friendshipRank}/${collection.maxFriendshipRank}'
                  // '\n${collection.friendship}'
                  '\n${-bondData.next}';
              // battle result
              final oldCollection = stat.lastBattleResultData?.oldUserSvtCollection.firstWhereOrNull(
                (e) => e.svtId == collection.svtId,
              );
              if (oldCollection != null) {
                bondText += '\n+${collection.friendship - oldCollection.friendship}';
              }
              return Expanded(
                flex: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      bondText,
                      textAlign: TextAlign.center,
                      maxFontSize: 10,
                      minFontSize: 6,
                      maxLines: bondText.count('\n') + 1,
                      style: reachBondLimit ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
                    ),
                    BondProgress(
                      value: bondData.next,
                      total: bondData.total,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      minHeight: 4,
                    ),
                  ],
                ),
              );
            }),
            const Expanded(flex: 8, child: SizedBox.shrink()),
          ],
        );
        children.add(
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              constraints: const BoxConstraints(maxWidth: 80 * kSvtNumPerRow + 64),
              child: bondDetail,
            ),
          ),
        );
      }
    }
    return children;
  }

  Widget get battleDetailSection {
    final battleEntity = runtime.agentData.curBattle ?? runtime.agentData.lastBattle;
    final lastResult = runtime.agentData.lastBattleResultData;
    List<Widget> children = [];
    if (battleEntity == null) {
      children.add(const ListTile(dense: true, title: Text('No battle')));
    } else {
      Map<int, int> dropItems = battleEntity.battleInfo?.getTotalDrops() ?? {};
      if (lastResult != null &&
          lastResult.battleId == battleEntity.id &&
          lastResult.battleResult != BattleResultType.cancel.value) {
        dropItems.clear();
        for (final drop in lastResult.resultDropInfos) {
          dropItems.addNum(drop.objectId, drop.num);
        }
      }

      children.addAll([
        ListTile(
          dense: true,
          title: Text(db.gameData.quests[battleEntity.questId]?.lDispName ?? 'Quest ${battleEntity.questId}'),
          subtitle: dropItems.isEmpty
              ? null
              : Wrap(
                  children: [
                    for (final itemId in dropItems.keys.toList()..sort((a, b) => Item.compare2(a, b)))
                      Item.iconBuilder(
                        context: context,
                        item: null,
                        itemId: itemId,
                        height: 36,
                        text: [
                          '+${dropItems[itemId]!.format()}',
                          if (!db.gameData.entities.containsKey(itemId))
                            mstData.getItemOrSvtNum(itemId, eventIds: [battleEntity.eventId]).format(),
                        ].join('\n'),
                      ),
                  ],
                ),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.push(url: Routes.questI(battleEntity.questId, battleEntity.questPhase));
          },
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: FormationCard(
        //     formation: BattleTeamFormationX.fromBattleEntity(battleEntity: battleEntity, mstData: mstData),
        //   ),
        // ),
      ]);
    }

    final resultType = BattleResultType.values.firstWhereOrNull((e) => e.value == lastResult?.battleResult);

    return TileGroup(
      header: battleEntity == null
          ? 'Battle Details'
          : 'Battle ${battleEntity.id} - ${runtime.agentData.curBattle == null ? "${resultType?.name}" : "ongoing"}'
                ' (${battleEntity.createdAt.sec2date().toCustomString(year: false)})',
      children: children,
    );
  }
}

class RandomMissionEnableQuestPage extends StatefulWidget {
  final RandomMissionOption option;
  final List<Quest> quests;
  final MasterDataManager mstData;
  const RandomMissionEnableQuestPage({super.key, required this.option, required this.quests, required this.mstData});

  @override
  State<RandomMissionEnableQuestPage> createState() => _RandomMissionEnableQuestPageState();
}

class _RandomMissionEnableQuestPageState extends State<RandomMissionEnableQuestPage> {
  @override
  Widget build(BuildContext context) {
    final quests = widget.quests.toList();
    quests.sort2((e) => e.priority);
    return Scaffold(
      appBar: AppBar(title: Text(S.current.quest)),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final quest = quests[index];
          return CheckboxListTile(
            dense: true,
            secondary: db.getIconImage(quest.spot?.shownImage),
            title: Text(quest.lName.l),
            subtitle: Text('Lv.${quest.recommendLv} ${quest.lSpot.l}'),
            value: widget.option.enabledQuests.contains(quest.id),
            onChanged: (v) {
              setState(() {
                widget.option.enabledQuests.toggle(quest.id);
              });
            },
          );
        },
        itemCount: quests.length,
      ),
    );
  }
}

class ItemWeightEditPage extends StatefulWidget {
  final MasterDataManager mstData;
  final List<int> itemIds;
  final RandomMissionOption option;
  const ItemWeightEditPage({super.key, required this.mstData, required this.itemIds, required this.option});

  @override
  State<ItemWeightEditPage> createState() => _ItemWeightEditPageState();
}

class _ItemWeightEditPageState extends State<ItemWeightEditPage> {
  @override
  Widget build(BuildContext context) {
    final allItemIds = {...widget.itemIds, ...widget.option.itemWeights.keys};
    return Scaffold(
      appBar: AppBar(title: Text('Item Weight')),
      body: ListView(
        children: [
          for (final itemId in allItemIds) buildOne(itemId),
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                """权重:
w≤0: 可被取消任务
0<w<2: 常规权重，可有可无
2≤w: 重点素材，优先获取该部分素材的任务
默认权重：
QP/友情点/魔力棱镜: 0
常规素材: 1
"""
                    .trim(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOne(int itemId) {
    return ListTile(
      leading: Item.iconBuilder(
        context: context,
        item: null,
        itemId: itemId,
        text: [
          widget.mstData.getItemOrSvtNum(itemId).format(),
          (db.itemCenter.itemLeft[itemId] ?? 0).format(),
        ].join('\n'),
      ),
      title: Text(Item.getName(itemId)),
      trailing: TextButton(
        onPressed: () {
          widget.option.itemWeights[itemId];
          InputCancelOkDialog(
            title: Item.getName(itemId),
            initValue: widget.option.getItemWeight(itemId).format(),
            keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
            validate: (s) => double.parse(s).isFinite,
            onSubmit: (s) {
              widget.option.itemWeights[itemId] = double.parse(s);
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        },
        child: Text(widget.option.getItemWeight(itemId).toStringAsFixed(2)),
      ),
    );
  }
}
