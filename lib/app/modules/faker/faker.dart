import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/formation/formation_card.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/faker/jp/network.dart';
import 'package:chaldea/models/faker/quiz/crypt_data.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../import_data/import_https_page.dart';
import '../import_data/sniff_details/formation_decks.dart';
import 'history.dart';
import 'option_list.dart';

class FakeGrandOrder extends StatefulWidget {
  final FakerAgent agent;
  const FakeGrandOrder({super.key, required this.agent});

  @override
  State<FakeGrandOrder> createState() => _FakeGrandOrderState();
}

class _FakeGrandOrderState extends State<FakeGrandOrder> {
  late final FakerAgent agent = widget.agent;
  late final mstData = agent.network.mstData;
  UserGameEntity? get userGame => mstData.user;
  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  bool _runningTask = false;
  static final Set<Object> _awakeTasks = {};

  void _lockTask(VoidCallback callback) {
    if (_runningTask) {
      if (mounted) {
        SimpleCancelOkDialog(
          title: Text(S.current.error),
          content: const Text("task is till running"),
          hideCancel: true,
        ).showDialog(context);
      }
      return;
    }
    return callback();
  }

  Future<void> _runTask(Future Function() task) async {
    if (_runningTask) {
      if (mounted) {
        SimpleCancelOkDialog(
          title: Text(S.current.error),
          content: const Text("previous task is till running"),
          hideCancel: true,
        ).showDialog(context);
      }
      return;
    }
    try {
      _runningTask = true;
      EasyLoading.show();
      if (mounted) setState(() {});
      await task();
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('task failed', e, s);
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        EasyLoading.dismiss();
        SimpleCancelOkDialog(
          title: Text(S.current.error),
          scrollable: true,
          content: Text(e is SilentException ? e.message.toString() : e.toString()),
          hideCancel: true,
        ).showDialog(context, barrierDismissible: false);
      } else {
        EasyLoading.showError(e.toString());
      }
    } finally {
      _runningTask = false;
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
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text("Fake/Grand Order")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            if (_runningTask) {
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
    final userGame = this.userGame ?? agent.user.userGame;

    children.add(ListTile(
      dense: true,
      minTileHeight: 48,
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 20,
      leading: Container(
        constraints: const BoxConstraints(maxWidth: 16, maxHeight: 16),
        child: CircularProgressIndicator(
          value: _runningTask ? null : 1.0,
          color: _runningTask ? Colors.red : Colors.green,
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
        if (_runningTask) return;
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
        return ListTile(dense: true, title: Text('Drops (${totalDropStat.totalCount} runs)'));
      },
      contentBuilder: (context) {
        totalDropStat.items.removeWhere((k, v) => v == 0);
        final questDropIds = db.gameData.dropData.freeDrops2[battleOption.questId]?.items.keys.toList() ?? [];
        for (final itemId in questDropIds) {
          totalDropStat.items.putIfAbsent(itemId, () => 0);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (header, dropStats) in [
              ('Total Drop Statistics', totalDropStat),
              ('Current Loop\'s Drop Statistics', curLoopDropStat)
            ])
              ListTile(
                dense: true,
                title: Text.rich(TextSpan(text: "$header (${dropStats.totalCount} runs)  ", children: [
                  SharedBuilder.textButtonSpan(
                    context: context,
                    text: 'clear',
                    onTap: () {
                      setState(() {
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
                _lockTask(() {
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
            _lockTask(() {
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
                _lockTask(() {
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
                    _lockTask(() {
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
              _lockTask(() async {
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
                    _lockTask(() {
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
              _lockTask(() async {
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
                _lockTask(() {
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
                      _lockTask(() {
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
              _lockTask(() {
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
            child: FormationCard(formation: formation.toFormation(mstData: mstData)),
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
                      _lockTask(() {
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
              _lockTask(() {
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
                      _lockTask(() {
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
              _lockTask(() {
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
            _lockTask(() {
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
            _lockTask(() {
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
            _lockTask(() {
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
            _lockTask(() {
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
            _lockTask(() {
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
              _lockTask(() {
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
        //       _lockTask(() {
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
              _lockTask(() {
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
              _lockTask(() {
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
            _runTask(agent.gamedataTop);
          },
          text: 'gamedata',
        ),
        buildButton(
          // enabled: !inBattle,
          onPressed: () {
            SimpleCancelOkDialog(
              title: const Text('Login'),
              onTapOk: () {
                _runTask(agent.loginTop);
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
              await _runTask(() => agent.terminalApSeedExchange(buyCount));
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
                  await _runTask(() => agent.shopPurchaseByStone(id: recover.targetId, num: 1));
                  break;
                case RecoverType.item:
                  await _runTask(() => agent.itemRecover(recoverId: recover.id, num: 1));
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
            _runTask(() => agent.battleSetupWithOptions(battleOption));
          },
          text: 'b.setup',
        ),
        buildButton(
          enabled: loggedIn && inBattle,
          onPressed: () async {
            _runTask(() => agent.battleResultWithOptions(
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
                _runTask(() => _withWakeLock('loop-$hashCode', startLoop));
              },
            ).showDialog(context);
          },
          text: 'Loop ×${battleOption.loopCount}',
        ),
        buildButton(
          onPressed: () {
            _stopLoopFlag = true;
          },
          text: 'Stop',
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            // PopupMenuItem(
            //   child: const Text('gamedata'),
            //   onTap: () {
            //     _runTask(agent.gamedataTop);
            //   },
            // ),
            PopupMenuItem(
              enabled: loggedIn && !inBattle,
              onTap: () {
                _runTask(agent.homeTop);
              },
              child: const Text('home'),
            ),
            PopupMenuItem(
              enabled: loggedIn && !inBattle,
              onTap: () {
                _runTask(() async {
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
                  _runningTask = false;
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
                    _runTask(() => _withWakeLock('seed-wait-$hashCode', () => seedWait(int.parse(s))));
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

  bool _stopLoopFlag = false;
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();

  Future<void> startLoop() async {
    if (agent.curBattle != null) {
      throw SilentException('last battle not finished');
    }
    final battleOption = this.battleOption;
    if (battleOption.loopCount <= 0) {
      throw SilentException('loop count (${battleOption.loopCount}) must >0');
    }
    if (battleOption.targetDrops.values.any((v) => v <= 0)) {
      throw SilentException('loop target drop num must >0');
    }
    if (battleOption.winTargetItemNum.values.any((v) => v <= 0)) {
      throw SilentException('win target drop num must >0');
    }
    if (battleOption.recoverIds.isNotEmpty && battleOption.waitApRecover) {
      throw SilentException('Do not turn on both apple recover and wait AP recover');
    }
    final questPhaseEntity =
        await AtlasApi.questPhase(battleOption.questId, battleOption.questPhase, region: agent.user.region);
    if (questPhaseEntity == null) {
      throw SilentException('quest not found');
    }
    final now = DateTime.now().timestamp;
    if (questPhaseEntity.openedAt > now || questPhaseEntity.closedAt < now) {
      throw SilentException('quest not open');
    }
    if (battleOption.winTargetItemNum.isNotEmpty && !questPhaseEntity.flags.contains(QuestFlag.actConsumeBattleWin)) {
      throw SilentException('Win target drops should be used only if Quest has flag actConsumeBattleWin');
    }
    if (battleOption.useEventDeck != (questPhaseEntity.event != null)) {
      throw SilentException('This quest should "Use Event Deck"');
    }
    int finishedCount = 0, totalCount = battleOption.loopCount;
    List<int> elapseSeconds = [];
    curLoopDropStat.reset();
    EasyLoading.showProgress(finishedCount / totalCount, status: 'Battle $finishedCount/$totalCount');
    while (finishedCount < totalCount) {
      _checkStop();
      _checkSvtKeep();
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption);
      }

      final int startTime = DateTime.now().timestamp;
      final msg =
          'Battle ${finishedCount + 1}/$totalCount, ${Maths.mean(elapseSeconds).round()}s/${(Maths.sum(elapseSeconds) / 60).toStringAsFixed(1)}m';
      logger.t(msg);
      EasyLoading.showProgress((finishedCount + 0.5) / totalCount, status: msg);

      await _ensureEnoughApItem(quest: questPhaseEntity, option: battleOption);

      if (mounted) setState(() {});

      final setupResp = await agent.battleSetupWithOptions(battleOption);
      if (mounted) setState(() {});

      final battleEntity = setupResp.data.mstData.battles.single;
      final curBattleDrops = battleEntity.battleInfo?.getTotalDrops() ?? {};
      logger.t('battle id: ${battleEntity.id}');

      bool shouldRetire = false;
      FResponse resultResp;
      if (battleOption.winTargetItemNum.isNotEmpty) {
        shouldRetire = true;
        for (final (itemId, targetNum) in battleOption.winTargetItemNum.items) {
          if ((curBattleDrops[itemId] ?? 0) >= targetNum) {
            shouldRetire = false;
            break;
          }
        }
      }

      if (shouldRetire) {
        await Future.delayed(const Duration(seconds: 4));
        resultResp = await agent.battleResultWithOptions(
          battleEntity: battleEntity,
          resultType: BattleResultType.cancel,
          actionLogs: "",
        );
      } else {
        final delay = battleOption.battleDuration ?? (agent.network.gameTop.region == Region.cn ? 40 : 20);
        await Future.delayed(Duration(seconds: delay));
        resultResp = await agent.battleResultWithOptions(
          battleEntity: battleEntity,
          resultType: BattleResultType.win,
          actionLogs: battleOption.actionLogs,
        );
        // if win
        totalDropStat.totalCount += 1;
        curLoopDropStat.totalCount += 1;
        Map<int, int> resultBattleDrops;
        final lastBattleResultData = agent.lastBattleResultData;
        if (lastBattleResultData != null && lastBattleResultData.battleId == battleEntity.id) {
          resultBattleDrops = {};
          for (final drop in lastBattleResultData.resultDropInfos) {
            resultBattleDrops.addNum(drop.objectId, drop.num);
          }
        } else {
          resultBattleDrops = curBattleDrops;
          logger.t('last battle result data not found, use cur_battle_drops');
        }
        totalDropStat.items.addDict(resultBattleDrops);
        curLoopDropStat.items.addDict(resultBattleDrops);

        // check total drop target of this loop
        if (battleOption.targetDrops.isNotEmpty) {
          for (final (itemId, targetNum) in battleOption.targetDrops.items.toList()) {
            final curDropNum = curLoopDropStat.items[itemId] ?? 0;
            if (curDropNum > 0) {
              battleOption.targetDrops[itemId] = targetNum - curDropNum;
            }
          }
          final reachedItems =
              battleOption.targetDrops.keys.where((itemId) => battleOption.targetDrops[itemId]! <= 0).toList();
          if (reachedItems.isNotEmpty) {
            throw SilentException(
                'Target drop reaches: ${reachedItems.map((e) => GameCardMixin.anyCardItemName(e).l).join(', ')}');
          }
        }
      }
      resultResp;

      finishedCount += 1;
      battleOption.loopCount -= 1;

      elapseSeconds.add(DateTime.now().timestamp - startTime);
      if (mounted) setState(() {});
      await Future.delayed(const Duration(seconds: 2));
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption);
      }
    }
    logger.t('finished all $finishedCount battles');
    if (mounted) {
      SimpleCancelOkDialog(
        title: const Text('Finished'),
        content: Text('$finishedCount battles'),
        hideCancel: true,
      ).showDialog(context, barrierDismissible: false);
    }
  }

  Future<void> seedWait(final int maxBuyCount) async {
    int boughtCount = 0;
    while (boughtCount < maxBuyCount) {
      const int apUnit = 40, seedUnit = 1;
      final apCount = mstData.user?.calCurAp() ?? 0;
      final seedCount = mstData.getItemNum(Items.blueSaplingId);
      if (seedCount <= 0) {
        throw SilentException('no Blue Sapling left');
      }
      int buyCount = min(maxBuyCount, min(apCount ~/ apUnit, seedCount ~/ seedUnit));
      if (buyCount > 0) {
        await agent.terminalApSeedExchange(buyCount);
        boughtCount += buyCount;
      }
      if (mounted) setState(() {});
      EasyLoading.show(status: 'Seed $boughtCount/$maxBuyCount - waiting...');
      await Future.delayed(const Duration(minutes: 1));
      _checkStop();
    }
  }

  Future<T> _withWakeLock<T>(Object tag, Future<T> Function() task) async {
    try {
      WakelockPlus.enable();
      _awakeTasks.add(tag);
      return await task();
    } finally {
      _awakeTasks.remove(tag);
      if (_awakeTasks.isEmpty) {
        WakelockPlus.disable();
      }
    }
  }

  void _checkStop() {
    if (_stopLoopFlag) {
      _stopLoopFlag = false;
      throw SilentException('Manual Stop');
    }
  }

  void _checkSvtKeep() {
    int svtCount = 0, svtEquipCount = 0;
    for (final userSvt in mstData.userSvt) {
      final svt = db.gameData.entities[userSvt.svtId];
      if (svt == null) continue;
      if (svt.type == SvtType.servantEquip) {
        if (userSvt.dbCE?.flags.contains(SvtFlag.svtEquipFriendShip) == true) {
          // don't count
        } else {
          svtEquipCount += 1;
        }
      } else {
        svtCount += 1;
      }
    }
    final user = mstData.user!;
    if (svtCount >= user.svtKeep) {
      throw SilentException('${S.current.servant}: $svtCount>=${user.svtKeep}');
    }
    if (svtEquipCount >= user.svtEquipKeep) {
      throw SilentException('${S.current.craft_essence}: $svtEquipCount>=${user.svtEquipKeep}');
    }
  }

  void _checkFriendship(AutoBattleOptions option) {
    final svts = mstData.userDeck[battleOption.deckId]!.deckInfo?.svts ?? [];
    for (final svt in svts) {
      if (svt.userSvtId > 0 && (svt.svtId ?? 0) > 0) {
        final dbSvt = db.gameData.servantsById[svt.svtId];
        final svtCollection = mstData.userSvtCollection[svt.svtId];
        if (dbSvt == null) {
          throw SilentException('Unknown Servant ID ${svt.svtId}');
        }
        if (svtCollection == null) {
          throw SilentException('UserServantCollection ${svt.svtId} not found');
        }
        if (dbSvt.type == SvtType.heroine) continue;
        final maxBondLv = 10 + svtCollection.friendshipExceedCount;
        final maxBond = dbSvt.bondGrowth.getOrNull(maxBondLv - 1);
        if (svtCollection.friendship == maxBond) {
          throw SilentException('Svt No.${dbSvt.collectionNo} ${dbSvt.lName.l} reaches max bond Lv.$maxBondLv');
        }
      }
    }
  }

  Future<void> _ensureEnoughApItem({required QuestPhase quest, required AutoBattleOptions option}) async {
    if (quest.consumeType.useItem) {
      for (final item in quest.consumeItem) {
        final own = mstData.getItemNum(item.itemId);
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
        if (recover.recoverType == RecoverType.stone && mstData.user!.stone > 0) {
          await agent.shopPurchaseByStone(id: recover.targetId, num: 1);
          break;
        } else if (recover.recoverType == RecoverType.item) {
          final item = db.gameData.items[recover.targetId];
          if (item == null) continue;
          if (item.type == ItemType.apAdd) {
            final count = ((apConsume - mstData.user!.calCurAp()) / item.value).ceil();
            if (count > 0 && count < mstData.getItemNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          } else if (item.type == ItemType.apRecover) {
            final count =
                ((apConsume - mstData.user!.calCurAp()) / (item.value / 1000 * mstData.user!.actMax).ceil()).ceil();
            if (count > 0 && count < mstData.getItemNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          }
        } else {
          continue;
        }
      }
      if (mstData.user!.calCurAp() >= quest.consume) {
        return;
      }
      if (option.waitApRecover) {
        while (mstData.user!.calCurAp() < quest.consume) {
          if (mounted) setState(() {});
          EasyLoading.show(status: 'Battle - waiting AP recover...');
          await Future.delayed(const Duration(minutes: 1));
        }
        return;
      }
      throw SilentException('AP not enough: ${mstData.user!.calCurAp()}<${quest.consume}');
    }
  }
}

class _DropStatData {
  int totalCount = 0;
  Map<int, int> items = {};
  // Map<int, int> groups = {};

  void reset() {
    totalCount = 0;
    items.clear();
  }
}

class RecoverSelectDialog extends StatelessWidget {
  final List<RecoverEntity> recovers;
  final MasterDataManager? mstData;
  const RecoverSelectDialog({super.key, required this.recovers, this.mstData});

  @override
  Widget build(BuildContext context) {
    final recovers = this.recovers.toList();
    recovers.sort2((e) => -e.priority);
    return ListTileTheme.merge(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 32,
      child: SimpleDialog(
        title: const Text("Recover AP"),
        children: [for (final recover in recovers) buildRecoverItem(context, recover)],
      ),
    );
  }

  Widget buildRecoverItem(BuildContext context, RecoverEntity recover) {
    final userGame = mstData?.user;
    if (mstData != null && userGame == null) {
      return const SimpleCancelOkDialog(title: Text("No user data"));
    }
    switch (recover.recoverType) {
      case RecoverType.commandSpell:
        return const ListTile(
          title: Text('command spell not supported'),
          enabled: false,
        );
      case RecoverType.stone:
        final ownCount = userGame?.stone ?? 0;
        bool enabled = mstData == null ||
            (userGame != null && userGame.stone > 0 && userGame.calCurAp() < userGame.actMax && ownCount > 0);
        return ListTile(
          leading: Item.iconBuilder(context: context, item: null, itemId: Items.stoneId),
          title: Text(Items.stone?.lName.l ?? "Saint Quartz"),
          subtitle: mstData == null ? null : Text("${S.current.item_own}: $ownCount"),
          enabled: enabled,
          onTap: enabled ? () => Navigator.pop(context, recover) : null,
        );
      case RecoverType.item:
        final item = db.gameData.items[recover.targetId];
        final ownCount = mstData?.getItemNum(recover.targetId) ?? 0;
        bool enabled = mstData == null || (userGame != null && ownCount > 0);
        return ListTile(
          leading: Item.iconBuilder(context: context, item: item, itemId: recover.targetId),
          title: Text(item?.lName.l ?? "No.${recover.targetId}"),
          subtitle: mstData == null ? null : Text("${S.current.item_own}: $ownCount"),
          enabled: enabled,
          onTap: enabled ? () => Navigator.pop(context, recover) : null,
        );
    }
  }
}

class ApSeedExchangeCountDialog extends StatefulWidget {
  final MasterDataManager mstData;
  const ApSeedExchangeCountDialog({super.key, required this.mstData});

  @override
  State<ApSeedExchangeCountDialog> createState() => _ApSeedExchangeCountDialogState();
}

class _ApSeedExchangeCountDialogState extends State<ApSeedExchangeCountDialog> {
  int buyCount = 1;

  @override
  Widget build(BuildContext context) {
    const int apUnit = 40, seedUnit = 1;
    final apCount = widget.mstData.user?.calCurAp() ?? 0;
    final seedCount = widget.mstData.getItemNum(Items.blueSaplingId);
    final int maxBuyCount = min(apCount ~/ apUnit, seedCount ~/ seedUnit);
    return AlertDialog(
      title: const Text('Exchange Count'),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: 'AP×$apCount  '),
            CenterWidgetSpan(
              child: Item.iconBuilder(
                context: context,
                item: null,
                itemId: Items.blueSaplingId,
                width: 24,
              ),
            ),
            TextSpan(text: '×$seedCount'),
          ])),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'AP×${apUnit * buyCount}  '),
            CenterWidgetSpan(
              child: Item.iconBuilder(
                context: context,
                item: null,
                itemId: Items.blueSaplingId,
                width: 24,
              ),
            ),
            TextSpan(text: '×${seedUnit * buyCount} → '),
            CenterWidgetSpan(
              child: Item.iconBuilder(
                context: context,
                item: null,
                itemId: Items.blueAppleId,
                width: 24,
              ),
            ),
            TextSpan(text: '×$buyCount'),
          ])),
          if (maxBuyCount >= 1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: buyCount.toDouble(),
                    onChanged: (v) {
                      setState(() {
                        buyCount = v.round().clamp(1, maxBuyCount);
                      });
                    },
                    min: 1.0,
                    max: maxBuyCount.toDouble(),
                    divisions: maxBuyCount > 1 ? maxBuyCount - 1 : null,
                    label: buyCount.toString(),
                  ),
                ),
                Text(maxBuyCount.toString()),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(S.current.cancel),
        ),
        TextButton(
          onPressed: maxBuyCount > 0 && buyCount <= maxBuyCount
              ? () {
                  Navigator.pop(context, buyCount);
                }
              : null,
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}
