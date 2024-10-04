import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/faker/quiz/crypt_data.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/notification.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../import_data/import_https_page.dart';
import '../import_data/sniff_details/formation_decks.dart';
import 'details/dialogs.dart';
import 'history.dart';
import 'option_list.dart';
import 'state.dart';

class FakeGrandOrder extends StatefulWidget {
  final AutoLoginData user;
  const FakeGrandOrder({super.key, required this.user});

  @override
  State<FakeGrandOrder> createState() => _FakeGrandOrderState();
}

class _FakeGrandOrderState extends State<FakeGrandOrder> {
  FakerRuntime? _runtime;
  FakerRuntime get runtime => _runtime!;

  late final FakerAgent agent = runtime.agent;
  late final mstData = agent.network.mstData;
  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _runtime?.dispose();
    super.dispose();
  }

  Future<void> init() async {
    try {
      // ignore: use_build_context_synchronously
      _runtime = await FakerRuntime.init(widget.user, this);
    } catch (e, s) {
      if (mounted) {
        SimpleCancelOkDialog(
          title: Text(S.current.error),
          content: Text(e.toString()),
          scrollable: true,
        ).showDialog(context);
      }
      logger.e('init FakerState failed', e, s);
    }
    if (mounted) setState(() {});
  }

  String _describeQuest(int questId, int phase, String? enemyCounts) {
    final quest = db.gameData.quests[questId];
    if (quest == null) return '$questId/$phase';
    final phaseDetail = db.gameData.questPhaseDetails[questId * 100 + phase];
    return [
      if (quest.warId == WarId.ordealCall || (quest.warId > 1000 && quest.isAnyFree))
        'Lv.${(phaseDetail?.recommendLv ?? quest.recommendLv)}',
      if (enemyCounts != null) enemyCounts,
      quest.lDispName.setMaxLines(1),
      if (quest.war != null) '@${quest.war?.lShortName.setMaxLines(1)}',
    ].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _runtime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Fake/Grand Order")),
        body: kIsWeb ? const Center(child: Text('Not supported')) : const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            if (runtime.runningTask.value) {
              SimpleCancelOkDialog(
                title: Text(S.current.warning),
                content: const Text("Task is still running! Cannot exit!"),
                hideCancel: true,
              ).showDialog(context);
              return;
            }
            final confirm = await const SimpleCancelOkDialog(title: Text("Exit?")).showDialog(context);
            if (confirm == true && context.mounted) Navigator.pop(context);
          },
        ),
        title: const Text("Fake/Grand Order"),
        actions: [
          IconButton(
            onPressed: () {
              router.pushPage(FakerHistoryViewer(agent: agent));
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: mstData.user == null ? null : () => router.pushPage(ImportHttpPage(mstData: mstData)),
            icon: const Icon(Icons.import_export),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: Column(
          children: [
            headerInfo,
            // const Divider(),
            Expanded(
              child: ListView(
                children: [
                  optionSelector,
                  const Divider(height: 8),
                  battleDetailSection,
                  battleSetupOptionSection,
                  battleResultOptionSection,
                  battleLoopOptionSection,
                  gameInfoSection,
                  ...otherSettingSection,
                ],
              ),
            ),
            const Divider(height: 1),
            buttonBar,
          ],
        ),
      ),
    );
  }

  Widget get headerInfo {
    List<Widget> children = [];
    final userGame = mstData.user ?? agent.user.userGame;

    children.add(ListTile(
      dense: true,
      minTileHeight: 48,
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 20,
      leading: Container(
        constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
        child: ValueListenableBuilder(
          valueListenable: runtime.runningTask,
          builder: (context, running, _) => CircularProgressIndicator(
            value: running ? null : 1.0,
            color: running ? Colors.red : Colors.green,
          ),
        ),
      ),
      title: Text('[${agent.user.serverName}] ${userGame?.name ?? "not login"}'),
      subtitle: Text('${userGame?.friendCode ?? ""} (${agent.user.internalId})'),
      trailing: userGame == null
          ? null
          : TimerUpdate(builder: (context, time) {
              return Text(
                '${userGame.calCurAp()}/${userGame.actMax}\n${Duration(seconds: (userGame.actRecoverAt - DateTime.now().timestamp)).toString().split('.').first}',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 12),
              );
            }),
    ));

    children.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: AlignmentDirectional.centerStart,
      child: Text.rich(TextSpan(children: [
        TextSpan(children: [
          CenterWidgetSpan(child: Item.iconBuilder(context: context, item: null, itemId: Items.stoneId, width: 20)),
          TextSpan(text: '×${userGame?.stone ?? 0}  '),
        ]),
        for (final itemId in <int>{
          ...Items.loginSaveItems,
          ...?db.gameData.quests[battleOption.questId]?.consumeItem.map((e) => e.itemId)
        })
          TextSpan(children: [
            CenterWidgetSpan(child: Item.iconBuilder(context: context, item: null, itemId: itemId, width: 20)),
            TextSpan(text: '×${mstData.getItemNum(itemId, agent.user.userItems[itemId] ?? 0)}  '),
          ])
      ])),
    ));

    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget get optionSelector {
    final option = agent.user.curBattleOption;
    final quest = db.gameData.quests[option.questId];
    return ListTile(
      dense: true,
      selected: true,
      leading: db.getIconImage(quest?.spot?.shownImage),
      title: Text('No.${agent.user.curBattleOptionIndex + 1}  ${option.name}'),
      subtitle: Text(_describeQuest(option.questId, option.questPhase, null)),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: () async {
        if (runtime.runningTask.value) return;
        await router.pushPage(BattleOptionListPage(data: agent.user));
        if (mounted) setState(() {});
      },
    );
  }

  Widget get gameInfoSection {
    final gameTop = agent.network.gameTop;
    return TileGroup(
      header: 'Game Info',
      children: [
        ListTile(
          dense: true,
          title: Text('AppVer=${gameTop.appVer}  DataVer=${gameTop.dataVer}'
              '\nDateVer=${gameTop.dateVer.sec2date().toStringShort(omitSec: true)}'),
        ),
      ],
    );
  }

  Widget get battleDetailSection {
    final battleEntity = agent.curBattle ?? agent.lastBattle;
    List<Widget> children = [];
    if (battleEntity == null) {
      children.add(const ListTile(dense: true, title: Text('No battle')));
    } else {
      Map<int, int> dropItems = battleEntity.battleInfo?.getTotalDrops() ?? {};
      if (agent.lastBattleResultData != null && agent.lastBattleResultData!.battleId == battleEntity.id) {
        dropItems.clear();
        for (final drop in agent.lastBattleResultData!.resultDropInfos) {
          dropItems.addNum(drop.objectId, drop.num);
        }
      }
      children.addAll([
        ListTile(
          dense: true,
          title: Text('Quest ${battleEntity.questId}/${battleEntity.questPhase}'),
          subtitle: Text(
            _describeQuest(battleEntity.questId, battleEntity.questPhase,
                battleEntity.battleInfo?.enemyDeck.map((e) => e.svts.length).join('-')),
          ),
          onTap: () {
            router.push(url: Routes.questI(battleEntity.questId, battleEntity.questPhase));
          },
        ),
        ListTile(
          dense: true,
          title: const Text('Drops'),
          subtitle: Wrap(
            children: [
              for (final itemId in dropItems.keys.toList()..sort((a, b) => Item.compare2(a, b)))
                db.gameData.craftEssencesById.containsKey(itemId)
                    ? db.gameData.craftEssencesById[itemId]!.iconBuilder(
                        context: context,
                        height: 36,
                        text: '+${dropItems[itemId]!.format()}',
                      )
                    : Item.iconBuilder(
                        context: context,
                        item: null,
                        itemId: itemId,
                        height: 36,
                        text: [
                          '+${dropItems[itemId]!.format()}',
                          mstData.getItemNum(itemId).format(),
                        ].join('\n'),
                      ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FormationCard(formation: cvtFormation(battleEntity)),
        ),
      ]);
    }
    children.add(SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          title: Text('Drops Statistics (${runtime.totalDropStat.totalCount} runs)'),
          subtitle: runtime.shownItemIds.isEmpty
              ? null
              : Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: (runtime.shownItemIds.toList()..sort(Item.compare)).map((itemId) {
                    return GameCardMixin.anyCardItemBuilder(
                      context: context,
                      id: itemId,
                      width: 30,
                      text: mstData.getItemNum(itemId).format(),
                    );
                  }).toList(),
                ),
        );
      },
      contentBuilder: (context) {
        runtime.totalDropStat.items.removeWhere((k, v) => v == 0);
        final questDropIds = db.gameData.dropData.freeDrops2[battleOption.questId]?.items.keys.toList() ?? [];
        for (final itemId in questDropIds) {
          runtime.totalDropStat.items.putIfAbsent(itemId, () => 0);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (header, dropStats) in [
              ('Total', runtime.totalDropStat),
              ('Current Loop', runtime.curLoopDropStat)
            ])
              ListTile(
                dense: true,
                title: Text.rich(TextSpan(text: "$header (${dropStats.totalCount} runs)  ", children: [
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: 'clear',
                    onTap: () {
                      setState(() {
                        if (dropStats == runtime.totalDropStat) runtime.shownItemIds.clear();
                        dropStats.reset();
                      });
                    },
                  )
                ])),
                subtitle: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: (dropStats.items.keys.toList()..sort(Item.compare)).map((itemId) {
                    double prob = 0;
                    if (dropStats.totalCount > 0) {
                      prob = dropStats.items[itemId]! / dropStats.totalCount;
                    }
                    return GameCardMixin.anyCardItemBuilder(
                      context: context,
                      id: itemId,
                      width: 42,
                      text: [
                        dropStats.items[itemId]!.format(),
                        if (dropStats.totalCount > 0) prob > 1 ? prob.format() : prob.format(percent: true),
                        db.gameData.craftEssencesById.containsKey(itemId)
                            ? (mstData.userSvt.where((e) => e.svtId == itemId).length.toString())
                            : mstData.getItemNum(itemId).format(),
                      ].join('\n'),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    ));

    return TileGroup(
      header: battleEntity == null
          ? 'Battle Details'
          : 'Battle ${battleEntity.id} - ${agent.curBattle == null ? "ended" : "ongoing"}'
              ' (${battleEntity.createdAt.sec2date().toStringShort()})',
      children: children,
    );
  }

  BattleTeamFormation cvtFormation(BattleEntity battleEntity) {
    final userSvts = {
      for (final svt in battleEntity.battleInfo?.userSvt ?? <BattleUserServantData>[]) svt.id: svt,
    };
    final userEquip = mstData.userEquip[battleEntity.battleInfo?.userEquipId];
    return BattleTeamFormation.fromList(
      mysticCode: MysticCodeSaveData(
        mysticCodeId: userEquip?.equipId,
        level: userEquip?.lv ?? 0,
      ),
      svts: List.generate(6, (i) {
        final svt = battleEntity.battleInfo?.myDeck?.svts.getOrNull(i);
        final userSvt = userSvts[svt?.userSvtId], userCE = userSvts[svt?.userSvtEquipIds?.firstOrNull];
        final dbSvt = db.gameData.servantsById[userSvt?.svtId];
        if (userSvt == null) return null;
        final appendId2Num = {
          for (final passive in dbSvt?.appendPassive ?? <ServantAppendPassiveSkill>[]) passive.skill.id: passive.num,
        };
        final appendPassive2Lvs = <int, int>{
          for (final (index, skillId) in (userSvt.appendPassiveSkillIds ?? <int>[]).indexed)
            if (appendId2Num.containsKey(skillId))
              appendId2Num[skillId]!: userSvt.appendPassiveSkillLvs?.getOrNull(index) ?? 0,
        };
        bool ceMLB = false;
        if (userCE != null) {
          if (userCE.limitCount == 0) {
            // may be zero even if MLB for support svt
            final skill =
                db.gameData.craftEssencesById[userCE.svtId]?.skills.firstWhereOrNull((e) => e.id == userCE.skillId1);
            if (skill != null && skill.condLimitCount == 4) {
              ceMLB = true;
            }
          } else {
            ceMLB = userCE.limitCount == 4;
          }
        }

        return SvtSaveData(
          svtId: userSvt.svtId,
          limitCount: userSvt.dispLimitCount,
          skillLvs: [userSvt.skillLv1, userSvt.skillLv2, userSvt.skillLv3],
          skillIds: [userSvt.skillId1, userSvt.skillId2, userSvt.skillId3],
          appendLvs: kAppendSkillNums.map((skillNum) => appendPassive2Lvs[skillNum + 99] ?? 0).toList(),
          tdId: 0,
          tdLv: userSvt.treasureDeviceLv ?? 0,
          lv: userSvt.lv,
          // atkFou,
          // hpFou,
          // fixedAtk,
          // fixedHp,
          ceId: userCE?.svtId,
          ceLimitBreak: ceMLB,
          ceLv: userCE?.lv ?? 1,
          supportType: SupportSvtType.fromFollowerType(svt?.followerType ?? 0),
          cardStrengthens: null,
          commandCodeIds: null,
        );
      }),
    );
  }

  Widget get battleLoopOptionSection {
    return TileGroup(
      header: 'Loop Options',
      children: [
        ListTile(
          dense: true,
          title: const Text('Battle Count'),
          trailing: TextButton(
              onPressed: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Battle Count',
                    text: battleOption.loopCount.toString(),
                    keyboardType: TextInputType.number,
                    validate: (s) => (int.tryParse(s) ?? -1) > 0,
                    onSubmit: (s) {
                      battleOption.loopCount = int.parse(s);
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                });
              },
              child: Text(battleOption.loopCount.toString())),
        ),
        ListTile(
          dense: true,
          title: const Text('Apples for recover (ordered)'),
          subtitle: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final recoverId in battleOption.recoverIds)
                CachedImage(
                  imageUrl: apRecovers.firstWhereOrNull((e) => e.id == recoverId)?.icon,
                  width: 32,
                  height: 32 * 144 / 132,
                  onTap: () {
                    battleOption.recoverIds.remove(recoverId);
                    setState(() {});
                  },
                ),
            ],
          ),
          trailing: IconButton(
              onPressed: () async {
                final recover =
                    await const RecoverSelectDialog(recovers: apRecovers).showDialog<RecoverEntity>(context);
                if (recover != null && !battleOption.recoverIds.contains(recover.id)) {
                  battleOption.recoverIds.add(recover.id);
                }
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add_circle)),
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.waitApRecover,
          title: const Text("Wait AP recover"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.waitApRecover = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        ListTile(
          dense: true,
          title: const Text('Battle Duration(seconds)'),
          trailing: TextButton(
              onPressed: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Battle Duration',
                    text: battleOption.battleDuration?.toString(),
                    keyboardType: TextInputType.number,
                    validate: (s) => (int.tryParse(s) ?? -1) > (agent.user.region == Region.cn ? 40 : 20),
                    onSubmit: (s) {
                      battleOption.battleDuration = int.parse(s);
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                });
              },
              child: Text(battleOption.battleDuration?.toString() ?? S.current.general_default)),
        ),
        ListTile(
          dense: true,
          title: const Text("Target drops (stop current loop if reach any)"),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              for (final itemId in battleOption.targetDrops.keys.toList()..sort(Item.compare))
                GameCardMixin.anyCardItemBuilder(
                  context: context,
                  id: itemId,
                  width: 42,
                  text: battleOption.targetDrops[itemId]!.toString(),
                  onTap: () {
                    runtime.lockTask(() {
                      setState(() {
                        battleOption.targetDrops.remove(itemId);
                      });
                    });
                  },
                ),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              runtime.lockTask(() async {
                final itemIdStr = await InputCancelOkDialog(
                  title: 'Item id or CE id',
                  keyboardType: TextInputType.number,
                  validate: (s) => (int.tryParse(s) ?? -1) > 0,
                ).showDialog<String>(context);
                if (itemIdStr == null) return;
                final itemId = int.parse(itemIdStr);
                final itemName = db.gameData.craftEssencesById[itemId]?.lName.l ?? db.gameData.items[itemId]?.lName.l;
                if (itemName == null) {
                  EasyLoading.showError("Invalid id");
                  return;
                }
                if (!mounted) return;
                final itemNumStr = await InputCancelOkDialog(
                  title: 'Stop if "$itemName" total drop num ≥',
                  keyboardType: TextInputType.number,
                  validate: (s) => (int.tryParse(s) ?? -1) > 0,
                ).showDialog<String>(context);
                if (itemNumStr == null) return;
                final itemNum = int.parse(itemNumStr);
                if (itemNum <= 0) return;
                battleOption.targetDrops[itemId] = itemNum;
                if (mounted) setState(() {});
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        ListTile(
          dense: true,
          // title: const Text("Target drop (retire/lose if no target drop)"),
          title: const Text("Win target drops (win battle if reaches any, otherwise retire/lose)"),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              for (final itemId in battleOption.winTargetItemNum.keys.toList()..sort(Item.compare))
                GameCardMixin.anyCardItemBuilder(
                  context: context,
                  id: itemId,
                  width: 42,
                  text: battleOption.winTargetItemNum[itemId]!.toString(),
                  onTap: () {
                    runtime.lockTask(() {
                      setState(() {
                        battleOption.winTargetItemNum.remove(itemId);
                      });
                    });
                  },
                ),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              runtime.lockTask(() async {
                final itemIdStr = await InputCancelOkDialog(
                  title: 'Item id or CE id',
                  keyboardType: TextInputType.number,
                  validate: (s) => (int.tryParse(s) ?? -1) > 0,
                ).showDialog<String>(context);
                if (itemIdStr == null) return;
                final itemId = int.parse(itemIdStr);
                final itemName = db.gameData.craftEssencesById[itemId]?.lName.l ?? db.gameData.items[itemId]?.lName.l;
                if (itemName == null) {
                  EasyLoading.showError("Invalid id");
                  return;
                }
                if (!mounted) return;
                final itemNumStr = await InputCancelOkDialog(
                  title: 'Win if "$itemName" drop num ≥',
                  keyboardType: TextInputType.number,
                  validate: (s) => (int.tryParse(s) ?? -1) > 0,
                ).showDialog<String>(context);
                if (itemNumStr == null) return;
                final itemNum = int.parse(itemNumStr);
                if (itemNum <= 0) return;
                battleOption.winTargetItemNum[itemId] = itemNum;
                if (mounted) setState(() {});
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
      ],
    );
  }

  Widget get battleSetupOptionSection {
    final quest = db.gameData.quests[battleOption.questId];
    final formation = mstData.userDeck[battleOption.deckId];
    String subtitle = _describeQuest(battleOption.questId, battleOption.questPhase, null);
    final userQuest = mstData.userQuest[battleOption.questId];
    if (userQuest != null) {
      subtitle += '\nP${userQuest.questPhase} clear ${userQuest.clearNum}';
    }
    return TileGroup(
      header: 'Battle Setup',
      children: [
        ListTile(
          dense: true,
          title: const Text("Quest ID"),
          subtitle: Text(subtitle),
          onTap: quest?.routeTo,
          trailing: TextButton(
              onPressed: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Quest ID',
                    text: battleOption.questId.toString(),
                    keyboardType: TextInputType.number,
                    onSubmit: (s) {
                      final questId = int.tryParse(s);
                      final quest = db.gameData.quests[questId];
                      if (questId != null &&
                          quest != null &&
                          !quest.flags.contains(QuestFlag.raid) &&
                          !quest.flags.contains(QuestFlag.superBoss)) {
                        battleOption.questId = questId;
                        if (quest.phases.length == 1) {
                          battleOption.questPhase = quest.phases.single;
                        }
                      } else {
                        EasyLoading.showError('Invalid Quest');
                      }
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                });
              },
              child: Text(battleOption.questId.toString())),
        ),
        ListTile(
          dense: true,
          title: const Text("Quest Phase"),
          subtitle: Text('phases: ${quest?.phases.join('/') ?? '-'}'),
          trailing: TextButton(
              onPressed: quest == null
                  ? null
                  : () {
                      runtime.lockTask(() {
                        InputCancelOkDialog(
                          title: 'Quest Phase',
                          keyboardType: TextInputType.number,
                          onSubmit: (s) {
                            final phase = int.tryParse(s);
                            if (phase != null && quest.phases.contains(phase)) {
                              battleOption.questPhase = phase;
                            } else {
                              EasyLoading.showError('Invalid Phase');
                            }
                            if (mounted) setState(() {});
                          },
                        ).showDialog(context);
                      });
                    },
              child: Text(battleOption.questPhase.toString())),
        ),
        ListTile(
          dense: true,
          title: Text("Formation Deck - ${battleOption.deckId}"),
          subtitle: formation == null ? const Text("Unknown deck") : Text('${formation.deckNo} - ${formation.name}'),
          trailing: IconButton(
            onPressed: () {
              runtime.lockTask(() {
                router.pushPage(UserFormationDecksPage(
                  mstData: mstData,
                  onSelected: (v) {
                    battleOption.deckId = v.id;
                    if (mounted) setState(() {});
                  },
                ));
              });
            },
            icon: const Icon(Icons.change_circle),
          ),
        ),
        if (formation != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FormationCard(
              formation: formation.toFormation(mstData: mstData),
              userSvtCollections: mstData.userSvtCollection.dict,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              constraints: const BoxConstraints(maxWidth: 80 * 6 + 64),
              child: Builder(
                builder: (context) {
                  final svts = formation.deckInfo?.svts ?? [];
                  final svtsMap = {for (final svt in svts) svt.id: svt};
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...List.generate(6, (index) {
                        final collection =
                            mstData.userSvtCollection[mstData.userSvt[svtsMap[index + 1]?.userSvtId]?.svtId];
                        final svt = db.gameData.servantsById[collection?.svtId];
                        if (collection == null ||
                            svt == null ||
                            svt.bondGrowth.length < collection.friendshipRank + 1) {
                          return const Expanded(flex: 10, child: SizedBox.shrink());
                        }
                        final prevBondTotal =
                                collection.friendshipRank == 0 ? 0 : svt.bondGrowth[collection.friendshipRank - 1],
                            curBondTotal = svt.bondGrowth[collection.friendshipRank];
                        final bool reachBondLimit = collection.friendship >= curBondTotal;
                        final int bondA = collection.friendship - prevBondTotal,
                            bondB = curBondTotal - collection.friendship;

                        String bondText =
                            'Bond\nLv.${collection.friendshipRank}/${10 + collection.friendshipExceedCount}'
                            // '\n${collection.friendship}'
                            '\n${-bondB}';
                        // battle result
                        final oldCollection = agent.lastBattleResultData?.oldUserSvtCollection
                            .firstWhereOrNull((e) => e.svtId == collection.svtId);
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
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Expanded(flex: bondA, child: Container(height: 4, color: Colors.blue)),
                                  Expanded(flex: bondB, child: Container(height: 4, color: Colors.red)),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const Expanded(flex: 8, child: SizedBox.shrink()),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        DividerWithTitle(title: S.current.support_servant_short, indent: 16),
        ListTile(
          dense: true,
          title: Text(S.current.support_servant),
          subtitle: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (battleOption.supportSvtIds.isEmpty) Text(S.current.general_any),
              for (final svtId in battleOption.supportSvtIds)
                GestureDetector(
                  onLongPress: () {
                    db.gameData.servantsById[svtId]?.routeTo();
                  },
                  child: GameCardMixin.cardIconBuilder(
                    context: context,
                    icon: db.gameData.servantsById[svtId]?.borderedIcon ?? Atlas.common.emptySvtIcon,
                    width: 36,
                    onTap: () {
                      runtime.lockTask(() {
                        battleOption.supportSvtIds.remove(svtId);
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                )
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              runtime.lockTask(() {
                router.pushPage(ServantListPage(
                  pinged: db.curUser.battleSim.pingedSvts.toList(),
                  showSecondaryFilter: true,
                  onSelected: (svt) {
                    if (!svt.isUserSvt) {
                      EasyLoading.showError('Not playable');
                      return;
                    }
                    battleOption.supportSvtIds.add(svt.id);
                    if (mounted) setState(() {});
                  },
                ));
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        ListTile(
          dense: true,
          title: Text('${S.current.support_servant} - ${S.current.craft_essence_short}'),
          subtitle: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              if (battleOption.supportCeIds.isEmpty) Text(S.current.general_any),
              for (final ceId in battleOption.supportCeIds)
                GestureDetector(
                  onLongPress: () {
                    db.gameData.craftEssencesById[ceId]?.routeTo();
                  },
                  child: GameCardMixin.cardIconBuilder(
                    context: context,
                    icon: db.gameData.craftEssencesById[ceId]?.borderedIcon ?? Atlas.common.emptyCeIcon,
                    width: 36,
                    onTap: () {
                      runtime.lockTask(() {
                        battleOption.supportCeIds.remove(ceId);
                        if (mounted) setState(() {});
                      });
                    },
                  ),
                )
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              runtime.lockTask(() {
                router.pushPage(CraftListPage(
                  pinged: db.curUser.battleSim.pingedCEsWithEventAndBond(quest, null).toList(),
                  onSelected: (ce) {
                    if (ce.collectionNo <= 0) {
                      EasyLoading.showError('Not playable');
                      return;
                    }
                    battleOption.supportCeIds.add(ce.id);
                    if (mounted) setState(() {});
                  },
                ));
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.supportCeMaxLimitBreak,
          title: Text('${S.current.support_servant} - ${S.current.craft_essence_short} ${S.current.max_limit_break}'),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.supportCeMaxLimitBreak = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.useEventDeck,
          title: Text("${S.current.support_servant_short} - Use Event Deck"),
          subtitle: Text("Supposed: ${db.gameData.quests[battleOption.questId]?.event != null ? 'Yes' : 'No'}"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.useEventDeck = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.enfoceRefreshSupport,
          title: const Text("Force Refresh Support"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.enfoceRefreshSupport = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        const Divider(),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.useCampaignItem,
          secondary: Item.iconBuilder(context: context, item: null, itemId: 94065901, jumpToDetail: false),
          title: Text(Transl.itemNames('星見のティーポット').l),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.useCampaignItem = v;
              });
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.isApHalf,
          title: const Text("During AP Half Event"),
          onChanged: (v) {
            setState(() {
              battleOption.isApHalf = v;
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.stopIfBondLimit,
          title: const Text("Stop if Bond Limit"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.stopIfBondLimit = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        ListTile(
          dense: true,
          title: Text('${mstData.userFollower.firstOrNull?.followerInfo.length} Follower Info(s)'),
          trailing: Text(
            '~${mstData.userFollower.firstOrNull?.expireAt.sec2date().toStringShort()}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget get battleResultOptionSection {
    return TileGroup(
      header: 'Battle Result Options',
      children: [
        ListTile(
          dense: true,
          title: const Text('Result Type'),
          trailing: DropdownButton<BattleResultType>(
            isDense: true,
            value: battleOption.resultType,
            alignment: AlignmentDirectional.centerEnd,
            items: [
              for (final type in [BattleResultType.win, BattleResultType.cancel])
                DropdownMenuItem(value: type, child: Text(type.name)),
            ],
            onChanged: (v) {
              runtime.lockTask(() {
                setState(() {
                  if (v != null) battleOption.resultType = v;
                });
              });
            },
          ),
        ),
        // ListTile(
        //   dense: true,
        //   title: const Text('Win Type'),
        //   trailing: DropdownButton<BattleWinResultType>(
        //     isDense: true,
        //     value: battleOptions.winType,
        //     alignment: AlignmentDirectional.centerEnd,
        //     items: [
        //       for (final type in BattleWinResultType.values) DropdownMenuItem(value: type, child: Text(type.name)),
        //     ],
        //     onChanged: (v) {
        //       runtime.lockTask(() {
        //         setState(() {
        //           if (v != null) battleOptions.winType = v;
        //         });
        //       });
        //     },
        //   ),
        // ),
        ListTile(
          dense: true,
          title: const Text('Each wave turns'),
          trailing: TextButton(
            onPressed: () {
              runtime.lockTask(() {
                InputCancelOkDialog(
                  title: 'Each wave turns',
                  text: battleOption.usedTurnArray.join(','),
                  onSubmit: (s) {
                    try {
                      if (s.isEmpty) {
                        battleOption.usedTurnArray = [];
                      } else {
                        final turns = s.split(RegExp(r'[,/]')).map(int.parse).toList();
                        battleOption.usedTurnArray = turns;
                      }
                    } catch (e) {
                      EasyLoading.showError(e.toString());
                      return;
                    }
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              });
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(battleOption.usedTurnArray.isEmpty ? 'empty' : battleOption.usedTurnArray.toString()),
            ),
          ),
        ),
        ListTile(
          dense: true,
          title: const Text('Action Logs'),
          trailing: TextButton(
            onPressed: () {
              runtime.lockTask(() {
                InputCancelOkDialog(
                  title: 'Action Logs',
                  text: battleOption.actionLogs,
                  onSubmit: (s) {
                    battleOption.actionLogs = s;
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              });
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(battleOption.actionLogs.isEmpty ? 'empty' : battleOption.actionLogs),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> get otherSettingSection {
    final fakerSettings = db.settings.fakerSettings;
    return [
      TileGroup(
        header: 'Notifications',
        children: [
          SwitchListTile.adaptive(
            dense: true,
            value: fakerSettings.apRecoveredNotification,
            title: const Text('AP Recovered Notification (Global)'),
            onChanged: (v) async {
              setState(() {
                fakerSettings.apRecoveredNotification = v;
              });
              if (v) {
                await LocalNotificationUtil.requestPermissions();
                await agent.network.setLocalNotification();
              } else {
                final notifications = await LocalNotificationUtil.plugin.getActiveNotifications();
                for (final notification in notifications) {
                  if (notification.id != null && LocalNotificationUtil.isUserApFullId(notification.id!)) {
                    LocalNotificationUtil.plugin.cancel(notification.id!);
                  }
                }
              }
            },
          ),
          ListTile(
            dense: true,
            title: const Text('Notify when AP recovered at'),
            subtitle: FilterGroup<int>(
              padding: const EdgeInsets.only(top: 4),
              options: agent.user.recoveredAps.toList()..sort2((e) => e == 0 ? 999 : e),
              values: FilterGroupData(),
              optionBuilder: (v) =>
                  v == 0 ? Text(agent.user.userGame?.actMax.toString() ?? 'Full') : Text(v.toString()),
              onFilterChanged: (_, lastChanged) {
                setState(() {
                  if (lastChanged != null) {
                    agent.user.recoveredAps.remove(lastChanged);
                    agent.network.setLocalNotification();
                  }
                });
              },
            ),
            trailing: IconButton(
              onPressed: () {
                InputCancelOkDialog(
                  title: 'AP',
                  keyboardType: TextInputType.number,
                  helperText: '0 = AP full (${(mstData.user ?? agent.user.userGame)?.actMax})',
                  validate: (s) {
                    int v = int.tryParse(s) ?? -1;
                    return v >= 0 && v < 200 && v < Maths.max(ConstData.userLevel.values.map((e) => e.maxAp));
                  },
                  onSubmit: (s) {
                    agent.user.recoveredAps.add(int.parse(s));
                    agent.network.setLocalNotification();
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
              icon: const Icon(Icons.add),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final actives = await LocalNotificationUtil.plugin.getActiveNotifications();
                final pendings = await LocalNotificationUtil.plugin.pendingNotificationRequests();
                if (actives.isEmpty && pendings.isEmpty) {
                  EasyLoading.showInfo('No notifications');
                  return;
                }
                router.showDialog(builder: (context) {
                  return SimpleDialog(
                    title: const Text('Notifications'),
                    children: [
                      if (actives.isNotEmpty) SHeader('${actives.length} Active Notifications'),
                      ...divideList(
                        [
                          for (final notification in actives..sort2((e) => e.id ?? 0))
                            ListTile(
                              dense: true,
                              title: Text(notification.title ?? 'no title'),
                              subtitle: Text('id ${notification.id}\n${notification.body}'),
                            ),
                        ],
                        const Divider(height: 1),
                        top: true,
                        bottom: true,
                      ),
                      if (actives.isNotEmpty) SHeader('${pendings.length} Pending Notifications'),
                      ...divideList(
                        [
                          for (final notification in pendings..sort2((e) => e.id))
                            ListTile(
                              dense: true,
                              title: Text(notification.title ?? 'no title'),
                              subtitle: Text('id ${notification.id}\n${notification.body}'),
                            ),
                        ],
                        const Divider(height: 1),
                        top: true,
                        bottom: true,
                      )
                    ],
                  );
                });
              },
              child: const Text('Active/Pending Notifications'),
            ),
          ),
        ],
      ),
      TileGroup(
        header: 'Global Settings',
        children: [
          ListTile(
            dense: true,
            title: const Text('Max refresh count of Support list'),
            trailing: TextButton(
                onPressed: () {
                  InputCancelOkDialog(
                    title: 'Max refresh count of Support list',
                    text: fakerSettings.maxFollowerListRetryCount.toString(),
                    keyboardType: TextInputType.number,
                    validate: (s) => (int.tryParse(s) ?? -1) > 0,
                    onSubmit: (s) {
                      fakerSettings.maxFollowerListRetryCount = int.parse(s);
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                },
                child: Text(fakerSettings.maxFollowerListRetryCount.toString())),
          ),
          const Divider(),
          SwitchListTile.adaptive(
            dense: true,
            value: fakerSettings.dumpResponse,
            title: const Text('Dump Responses'),
            onChanged: (v) {
              setState(() {
                fakerSettings.dumpResponse = v;
              });
            },
          ),
          Center(
            child: TextButton(
              onPressed: () {
                SimpleCancelOkDialog(
                  title: const Text('Clear Dumps'),
                  onTapOk: () async {
                    try {
                      EasyLoading.show(status: 'clearing');
                      int deleted = 0;
                      final folder = Directory(db.paths.tempFakerDir);
                      final t = DateTime.now().subtract(const Duration(hours: 1));
                      await for (final file in folder.list(recursive: true)) {
                        if (file is File) {
                          final stat = await file.stat();
                          if (stat.modified.isBefore(t)) {
                            await file.delete();
                            deleted += 1;
                          }
                        }
                      }
                      EasyLoading.showInfo('$deleted deleted');
                    } catch (e, s) {
                      logger.e('clear dumps failed', e, s);
                      EasyLoading.showError(e.toString());
                    }
                  },
                ).showDialog(context);
              },
              child: const Text('Clear dumps'),
            ),
          )
        ],
      )
    ];
  }

  Widget get buttonBar {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    FilledButton buildButton({
      bool enabled = true,
      required VoidCallback onPressed,
      required String text,
    }) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: buttonStyle,
        child: Text(text),
      );
    }

    final bool loggedIn = mstData.user != null, inBattle = agent.curBattle != null;

    List<List<Widget>> btnGroups = [
      [
        buildButton(
          onPressed: () {
            runtime.runTask(agent.gamedataTop);
          },
          text: 'gamedata',
        ),
        buildButton(
          // enabled: !inBattle,
          onPressed: () {
            SimpleCancelOkDialog(
              title: const Text('Login'),
              onTapOk: () {
                runtime.runTask(agent.loginTop);
              },
            ).showDialog(context);
          },
          text: 'login',
        ),
        buildButton(
          enabled: loggedIn && !inBattle,
          onPressed: () async {
            final buyCount = await ApSeedExchangeCountDialog(mstData: mstData).showDialog<int>(context);
            if (buyCount != null) {
              await runtime.runTask(() => agent.terminalApSeedExchange(buyCount));
            }
            if (mounted) setState(() {});
          },
          text: 'seed',
        ),
      ],
      [
        buildButton(
          enabled: loggedIn && !inBattle,
          onPressed: () async {
            final recover = await showDialog<RecoverEntity>(
              context: context,
              useRootNavigator: false,
              builder: (context) => RecoverSelectDialog(recovers: apRecovers, mstData: mstData),
            );
            if (recover != null) {
              switch (recover.recoverType) {
                case RecoverType.commandSpell:
                  EasyLoading.showError('Recover by command spell not supported');
                  break;
                case RecoverType.stone:
                  await runtime.runTask(() => agent.shopPurchaseByStone(id: recover.targetId, num: 1));
                  break;
                case RecoverType.item:
                  await runtime.runTask(() => agent.itemRecover(recoverId: recover.id, num: 1));
                  break;
              }
            }
            if (mounted) setState(() {});
          },
          text: 'recover',
        ),
        buildButton(
          enabled: loggedIn && !inBattle,
          onPressed: () async {
            runtime.runTask(() => agent.battleSetupWithOptions(battleOption));
          },
          text: 'b.setup',
        ),
        buildButton(
          enabled: loggedIn && inBattle,
          onPressed: () async {
            runtime.runTask(() => agent.battleResultWithOptions(
                  battleEntity: agent.curBattle!,
                  resultType: battleOption.resultType,
                  actionLogs: battleOption.actionLogs,
                ));
          },
          text: 'b.result',
        ),
      ],
      [
        buildButton(
          enabled: loggedIn && !inBattle,
          onPressed: () {
            InputCancelOkDialog(
              title: 'Start Looping Battle',
              keyboardType: TextInputType.number,
              autofocus: battleOption.loopCount <= 0,
              text: battleOption.loopCount.toString(),
              validate: (s) => (int.tryParse(s) ?? -1) > 0,
              onSubmit: (s) {
                battleOption.loopCount = int.parse(s);
                runtime.runTask(() => runtime.withWakeLock('loop-$hashCode', runtime.startLoop));
              },
            ).showDialog(context);
          },
          text: 'Loop ×${battleOption.loopCount}',
        ),
        buildButton(
          onPressed: () {
            agent.network.stopFlag = true;
          },
          text: 'Stop',
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            // PopupMenuItem(
            //   child: const Text('gamedata'),
            //   onTap: () {
            //     runtime.runTask(agent.gamedataTop);
            //   },
            // ),
            PopupMenuItem(
              enabled: loggedIn && !inBattle,
              onTap: () {
                runtime.runTask(agent.homeTop);
              },
              child: const Text('home'),
            ),
            PopupMenuItem(
              enabled: loggedIn && !inBattle,
              onTap: () {
                runtime.runTask(() async {
                  final dir = Directory(agent.network.fakerDir);
                  final files = dir
                      .listSync(followLinks: false)
                      .whereType<File>()
                      .where((e) => e.path.endsWith('.json') && e.path.contains('battle') && e.path.contains('setup'))
                      .toList();
                  final modified = DateTime.now().subtract(const Duration(days: 2));
                  files.removeWhere((e) => e.statSync().modified.isBefore(modified));
                  files.sort2((e) => e.path, reversed: true);
                  if (files.isEmpty) {
                    EasyLoading.showError('not found');
                    return;
                  }
                  final data = FateTopLogin.parseAny(jsonDecode(files.first.readAsStringSync()));
                  agent.curBattle = data.mstData.battles.firstOrNull ?? agent.curBattle;
                });
              },
              child: const Text('loadBattle'),
            ),
            PopupMenuItem(
              child: const Text('Break'),
              onTap: () {
                if (mounted) {
                  runtime.runningTask.value = false;
                  agent.network.clearTask();
                }
              },
            ),
            PopupMenuItem(
              enabled: loggedIn,
              onTap: () async {
                InputCancelOkDialog(
                  title: 'Seed Count (waiting)',
                  keyboardType: TextInputType.number,
                  validate: (s) => (int.tryParse(s) ?? -1) > 0,
                  onSubmit: (s) {
                    runtime.runTask(
                        () => runtime.withWakeLock('seed-wait-$hashCode', () => runtime.seedWait(int.parse(s))));
                  },
                ).showDialog(context);
              },
              child: const Text('Seed-wait'),
            ),
            if (agent is FakerAgentJP)
              PopupMenuItem(
                child: const Text('SessionId'),
                onTap: () {
                  InputCancelOkDialog(
                    title: 'SessionId (${agent.network.gameTop.region.upper})',
                    text: agent.network.cookies['SessionId'],
                    onSubmit: (s) {
                      if (s.trim().isEmpty) return;
                      agent.network.cookies['SessionId'] = s;
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                },
              ),
            if (agent is FakerAgentCN)
              PopupMenuItem(
                child: const Text('sgusk'),
                onTap: () {
                  InputCancelOkDialog(
                    title: 'sgusk (${agent.network.gameTop.region.upper})',
                    text: (agent as FakerAgentCN).usk,
                    onSubmit: (s) {
                      if (s.trim().isEmpty) return;
                      (agent as FakerAgentCN).usk = CryptData.encryptMD5Usk(s);
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                },
              ),
            if (kDebugMode)
              PopupMenuItem(
                child: const Text('Test'),
                onTap: () async {
                  // (agent as FakerAgentCN).usk = CryptData.encryptMD5Usk('842b691bbc2ef299367a');
                },
              )
          ],
        ),
      ],
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final btns in btnGroups)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: btns,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
