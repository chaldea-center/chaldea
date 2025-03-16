import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
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
import 'card_enhance/svt_cc.dart';
import 'card_enhance/svt_combine.dart';
import 'details/box_gacha.dart';
import 'details/dialogs.dart';
import 'details/raids.dart';
import 'details/trade.dart';
import 'gacha/gacha_draw.dart';
import 'history.dart';
import 'mission/mission_receive.dart';
import 'option_list.dart';
import 'present_box/present_box.dart';
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
    _runtime?.dispose(this);
    super.dispose();
  }

  Future<void> init() async {
    try {
      // ignore: use_build_context_synchronously
      final runtime = await FakerRuntime.init(widget.user, this);
      if (runtime.hasMultiRoots && mounted) {
        SimpleCancelOkDialog(
          title: Text(S.current.warning),
          content: Text('Another window is already open.'),
          hideCancel: true,
        ).showDialog(context);
      }
      await runtime.loadInitData();
      _runtime = runtime;
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

  int getEventIdByQuest(int? questId) {
    return db.gameData.quests[questId]?.logicEvent?.id ?? 0;
  }

  String _describeQuest(int questId, int phase, String? enemyCounts) {
    final quest = db.gameData.quests[questId];
    if (quest == null) return '$questId/$phase';
    final phaseDetail = db.gameData.questPhaseDetails[questId * 100 + phase];
    return [
      // if (quest.warId == WarId.ordealCall || (quest.warId > 1000 && (quest.isAnyFree || quest.isAnyRaid)))
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
    final bool isLoggedIn = mstData.user != null;
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
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(ImportHttpPage(mstData: mstData));
                    },
                    child: Text(S.current.general_import),
                  ),
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(UserPresentBoxManagePage(runtime: runtime));
                    },
                    child: Text(S.current.present_box),
                  ),
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(GachaDrawPage(runtime: runtime));
                    },
                    child: Text(S.current.gacha),
                  ),
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(UserEventMissionReceivePage(runtime: runtime));
                    },
                    child: Text(S.current.master_mission),
                  ),
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(SvtCombinePage(runtime: runtime));
                    },
                    child: Text('从者强化'),
                  ),
                  PopupMenuItem(
                    enabled: isLoggedIn,
                    onTap: () {
                      router.pushPage(UserSvtCommandCodePage(runtime: runtime));
                    },
                    child: Text('指令卡/纹章'),
                  ),
                  if (mstData.userEventTrade.isNotEmpty)
                    PopupMenuItem(
                      enabled: isLoggedIn,
                      onTap: () async {
                        router.pushPage(UserEventTradePage(runtime: runtime));
                      },
                      child: Text(S.current.event_trade),
                    ),
                  if (mstData.userBoxGacha.isNotEmpty)
                    PopupMenuItem(
                      enabled: isLoggedIn,
                      onTap: () async {
                        router.pushPage(BoxGachaDrawPage(runtime: runtime));
                      },
                      child: Text(S.current.event_lottery),
                    ),
                  PopupMenuItem(
                    child: Text("Reload"),
                    onTap: () {
                      runtime.runTask(runtime.gameData.reset);
                    },
                  ),
                ],
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: ListTileTheme.merge(
          dense: true,
          visualDensity: VisualDensity.compact,
          // minVerticalPadding: 0,
          // minTileHeight: 52,
          child: body,
        ),
      ),
    );
  }

  Widget get body {
    return Column(
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
              uncommonSettingSection,
              miscInfoSection,
              notificationSettingSection,
              globalSettingSection,
            ],
          ),
        ),
        const Divider(height: 1),
        buttonBar,
      ],
    );
  }

  Widget get headerInfo {
    List<Widget> children = [];
    final userGame = mstData.user ?? agent.user.userGame;
    List<InlineSpan> subtitle = [TextSpan(text: userGame?.friendCode ?? '')];
    if (mstData.user != null) {
      onTapPresentBox() => router.pushPage(UserPresentBoxManagePage(runtime: runtime));
      subtitle.addAll([
        TextSpan(text: '  '),
        CenterWidgetSpan(
          child: db.getIconImage(
            "https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/OrdealCall/TerminalAtlas/status_icongift_open.png",
            width: 24,
            onTap: onTapPresentBox,
          ),
        ),
        TextSpan(
          text: ' ${mstData.userPresentBox.length}/${runtime.gameData.constants.maxPresentBoxNum}',
          style:
              mstData.userPresentBox.length > runtime.gameData.constants.maxPresentBoxNum - 20
                  ? TextStyle(color: Colors.amber)
                  : null,
          recognizer: TapGestureRecognizer()..onTap = onTapPresentBox,
        ),
      ]);
    }
    children.add(
      ListTile(
        dense: true,
        minTileHeight: 48,
        visualDensity: VisualDensity.compact,
        minLeadingWidth: 20,
        leading: Container(
          constraints: const BoxConstraints(maxWidth: 20, maxHeight: 20),
          child: ValueListenableBuilder(
            valueListenable: runtime.runningTask,
            builder:
                (context, running, _) => GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: running ? null : 1.0,
                        color: running ? Colors.red : Colors.green,
                      ),
                      if (running)
                        TimerUpdate(
                          builder: (context, t) {
                            final startedAt = agent.network.lastTaskStartedAt;
                            final dt = min(99, t.timestamp - startedAt);
                            if (startedAt <= 0 || dt < 0) return const SizedBox.shrink();
                            return Text(dt.toString(), style: TextStyle(fontSize: 10), textAlign: TextAlign.center);
                          },
                        ),
                    ],
                  ),
                ),
          ),
        ),
        title: Text('[${agent.user.serverName}] ${userGame?.name ?? "not login"}'),
        subtitle: Text.rich(TextSpan(children: subtitle)),
        trailing:
            userGame == null
                ? null
                : TimerUpdate(
                  builder: (context, time) {
                    return Tooltip(
                      message: userGame.actRecoverAt.sec2date().toCustomString(year: false),
                      child: SelectionContainer.disabled(
                        child: Text(
                          '${userGame.calCurAp()}/${userGame.actMax}\n${Duration(seconds: (userGame.actRecoverAt - DateTime.now().timestamp)).toString().split('.').first}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );

    children.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                children: [
                  CenterWidgetSpan(
                    child: Item.iconBuilder(context: context, item: null, itemId: Items.stoneId, width: 20),
                  ),
                  TextSpan(text: '×${userGame?.stone ?? 0}  '),
                ],
              ),
              for (final itemId in <int>{
                ...Items.loginSaveItems,
                ...?db.gameData.quests[battleOption.questId]?.consumeItem.map((e) => e.itemId),
              })
                TextSpan(
                  children: [
                    CenterWidgetSpan(child: Item.iconBuilder(context: context, item: null, itemId: itemId, width: 20)),
                    TextSpan(
                      text: '×${mstData.getItemOrSvtNum(itemId, defaultValue: agent.user.userItems[itemId] ?? 0)}  ',
                    ),
                  ],
                ),
            ],
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );

    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
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

  Widget get miscInfoSection {
    final gameTop = agent.network.gameTop;
    final trailingStyle = TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize);
    List<Widget> children = [
      ListTile(
        dense: true,
        title: Text(
          'AppVer=${gameTop.appVer}  DataVer=${gameTop.dataVer}'
          '\nDateVer=${gameTop.dateVer.sec2date().toStringShort(omitSec: true)}',
        ),
      ),
    ];
    final userGame = runtime.agent.userGame;
    if (userGame != null) {
      final curLv = ConstData.userLevel[userGame.lv];
      final nextLv = ConstData.userLevel[userGame.lv + 1];
      children.add(
        ListTile(
          dense: true,
          title: const Text('Master Lv'),
          trailing: Text(
            ['Lv.${userGame.lv}', if (nextLv != null) userGame.exp - nextLv.requiredExp].join('\n'),
            textAlign: TextAlign.end,
            style: trailingStyle,
          ),
        ),
      );
      if (curLv != null && nextLv != null && userGame.exp >= curLv.requiredExp && userGame.exp <= nextLv.requiredExp) {
        children.add(
          BondProgress(
            value: userGame.exp - curLv.requiredExp,
            total: nextLv.requiredExp - curLv.requiredExp,
            padding: EdgeInsets.symmetric(horizontal: 16),
            minHeight: 4,
          ),
        );
      }

      final cardCounts = mstData.countSvtKeep();
      children.add(
        ListTile(
          dense: true,
          title: Text(
            [
              '${S.current.servant} ${cardCounts.svtCount}/${userGame.svtKeep}',
              '${S.current.craft_essence_short} ${cardCounts.svtEquipCount}/${userGame.svtEquipKeep}',
              '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.constants.maxUserCommandCode}',
              if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
            ].join('  '),
          ),
        ),
      );
    }
    return TileGroup(header: 'Misc Info', children: children);
  }

  Widget get battleDetailSection {
    final battleEntity = agent.curBattle ?? agent.lastBattle;
    final lastResult = agent.lastBattleResultData;
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
          title: Text(
            _describeQuest(
              battleEntity.questId,
              battleEntity.questPhase,
              battleEntity.battleInfo?.enemyDeck.map((e) => e.svts.length).join('-'),
            ),
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FormationCard(formation: cvtFormation(battleEntity)),
        ),
      ]);
    }
    children.add(
      SimpleAccordion(
        headerBuilder: (context, _) {
          return ListTile(
            dense: true,
            title: Text('Drop Statistics (${runtime.totalDropStat.totalCount} runs)'),
            subtitle:
                runtime.totalRewards.isEmpty
                    ? null
                    : Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children:
                          (runtime.totalRewards.keys.toList()..sort(Item.compare)).map((itemId) {
                            return GameCardMixin.anyCardItemBuilder(
                              context: context,
                              id: itemId,
                              width: 30,
                              text: [
                                '+${runtime.totalRewards[itemId]?.format()}',
                                mstData
                                    .getItemOrSvtNum(
                                      itemId,
                                      eventIds: [
                                        getEventIdByQuest(battleEntity?.eventId),
                                        getEventIdByQuest(battleOption.questId),
                                      ],
                                    )
                                    .format(),
                              ].join('\n'),
                            );
                          }).toList(),
                    ),
          );
        },
        contentBuilder: (context) {
          runtime.totalDropStat.items.removeWhere((k, v) => v == 0);
          final questDropIds = db.gameData.dropData.freeDrops2[battleOption.questId]?.items.keys.toList() ?? [];
          for (final itemId in questDropIds.followedBy(battleOption.targetDrops.keys)) {
            runtime.totalDropStat.items.putIfAbsent(itemId, () => 0);
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (header, dropStats) in [
                ('Total', runtime.totalDropStat),
                ('Current Loop', runtime.curLoopDropStat),
              ])
                ListTile(
                  dense: true,
                  title: Text.rich(
                    TextSpan(
                      text: "$header (${dropStats.totalCount} runs)  ",
                      children: [
                        SharedBuilder.textButtonSpan(
                          context: context,
                          text: 'clear',
                          onTap: () {
                            setState(() {
                              if (dropStats == runtime.totalDropStat) runtime.totalRewards.clear();
                              dropStats.reset();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  subtitle: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children:
                        (dropStats.items.keys.toList()..sort(Item.compare)).map((itemId) {
                          double prob = 0;
                          if (dropStats.totalCount > 0) {
                            prob = dropStats.items[itemId]! / dropStats.totalCount;
                          }
                          return GameCardMixin.anyCardItemBuilder(
                            context: context,
                            id: itemId,
                            width: 42,
                            text: [
                              '+${dropStats.items[itemId]!.format()}',
                              if (dropStats.totalCount > 0) prob > 1 ? prob.format() : prob.format(percent: true),
                              db.gameData.craftEssencesById.containsKey(itemId)
                                  ? (mstData.userSvt.where((e) => e.svtId == itemId).length.toString())
                                  : mstData
                                      .getItemOrSvtNum(
                                        itemId,
                                        eventIds: [
                                          getEventIdByQuest(battleEntity?.eventId),
                                          getEventIdByQuest(battleOption.questId),
                                        ],
                                      )
                                      .format(),
                            ].join('\n'),
                          );
                        }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );

    if (battleEntity?.battleInfo?.raidInfo.isNotEmpty == true ||
        db.gameData.quests[battleOption.questId]?.flags.contains(QuestFlag.raid) == true) {
      children.add(_buildRaidTile(battleEntity));
    }

    final resultType = BattleResultType.values.firstWhereOrNull((e) => e.value == lastResult?.battleResult);

    // request options
    final saveData = agent.user.lastRequestOptions;
    if (saveData != null) {
      children.add(Divider(indent: 16, endIndent: 16, height: 1));
      children.add(
        ListenableBuilder(
          listenable: agent.network,
          builder: (context, _) {
            return SimpleAccordion(
              headerBuilder: (context, _) {
                return ListTile(
                  dense: true,
                  title: Text(saveData.key),
                  subtitle: Text(saveData.createdAt.sec2date().toStringShort()),
                  trailing: SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(
                      value: runtime.runningTask.value ? null : 1,
                      color: runtime.runningTask.value ? Colors.grey : (saveData.success ? Colors.green : Colors.red),
                    ),
                  ),
                );
              },
              contentBuilder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(saveData.url),
                      onLongPress: () {
                        copyToClipboard(saveData.url, toast: true);
                      },
                    ),
                    ListTile(
                      dense: true,
                      title: Text(saveData.formData, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        showRequestDataFormatDialog(context, saveData.formData);
                      },
                    ),
                    FilledButton(
                      onPressed:
                          runtime.runningTask.value
                              ? null
                              : () async {
                                final confirm = await SimpleCancelOkDialog(
                                  title: Text("Send"),
                                  content: Text('request:${saveData.key}\nSuccess: ${saveData.success}'),
                                ).showDialog(context);
                                if (confirm != true) return;
                                runtime.runTask(() async {
                                  final resp = await agent.network.requestStartDirect(saveData);
                                  if (context.mounted) {
                                    SimpleCancelOkDialog(
                                      title: Text("Request Result"),
                                      content: Text(
                                        "status: ${resp.rawResponse.statusCode}\n"
                                        "responses:\n${resp.data.responses.map((e) => ' - ${e.nid} ${e.resCode}').join('\n')}",
                                      ),
                                      hideCancel: true,
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            router.pushPage(FakerHistoryViewer(agent: agent));
                                          },
                                          child: Text(S.current.history),
                                        ),
                                      ],
                                    ).showDialog(context);
                                  }
                                });
                              },
                      child: Text('Re-send'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    }

    return TileGroup(
      header:
          battleEntity == null
              ? 'Battle Details'
              : 'Battle ${battleEntity.id} - ${agent.curBattle == null ? "${resultType?.name}" : "ongoing"}'
                  ' (${battleEntity.createdAt.sec2date().toCustomString(year: false)})',
      children: children,
    );
  }

  Widget _buildRaidTile(BattleEntity? battleEntity) {
    int? eventId, day;
    if (battleEntity != null) {
      eventId = battleEntity.eventId;
      day = battleEntity.battleInfo?.raidInfo.firstOrNull?.day;
    } else {
      final quest = db.gameData.quests[battleOption.questId];
      if (quest != null && quest.flags.contains(QuestFlag.raid)) {
        eventId = quest.logicEvent?.id;
      }
    }

    Widget? title, subtitle;
    if (eventId != null && day != null) {
      final mstRaid = mstData.mstEventRaid[EventRaidEntity.createPK(eventId, day)];
      final record = agent.getRaidRecord(eventId, day).history.lastOrNull;
      title = Text(
        [
          'Raid day $day ${mstRaid?.name ?? ""}',
          if (record != null)
            '${record.raidInfo.totalDamage.format(compact: false, groupSeparator: ",")}'
                '/${record.raidInfo.maxHp.format(compact: false, groupSeparator: ",")}'
                '  (${record.raidInfo.rate.format(percent: true)})',
        ].join('\n'),
      );
      if (record != null) {
        subtitle = BondProgress(
          value: record.raidInfo.totalDamage,
          total: max(record.raidInfo.maxHp, record.raidInfo.maxHp),
          minHeight: 4,
        );
      }
    } else {
      title = Text('Raids');
    }

    return ListTile(
      dense: true,
      title: title,
      subtitle: subtitle,
      trailing: IconButton(
        onPressed:
            eventId == 0
                ? null
                : () {
                  router.pushPage(RaidsPage(runtime: runtime, eventId: eventId ?? 0));
                },
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      ),
    );
  }

  BattleTeamFormation cvtFormation(BattleEntity battleEntity) {
    final userSvts = {for (final svt in battleEntity.battleInfo?.userSvt ?? <BattleUserServantData>[]) svt.id: svt};
    final userEquip = mstData.userEquip[battleEntity.battleInfo?.userEquipId];
    return BattleTeamFormation.fromList(
      mysticCode: MysticCodeSaveData(mysticCodeId: userEquip?.equipId, level: userEquip?.lv ?? 0),
      svts: List.generate(6, (i) {
        final svt = battleEntity.battleInfo?.myDeck?.svts.getOrNull(i);
        final userSvt = userSvts[svt?.userSvtId], userCE = userSvts[svt?.userSvtEquipIds?.firstOrNull];
        final dbSvt = db.gameData.servantsById[userSvt?.svtId];
        if (userSvt != null) {
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
              final skill = db.gameData.craftEssencesById[userCE.svtId]?.skills.firstWhereOrNull(
                (e) => e.id == userCE.skillId1,
              );
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
            tdId: userSvt.treasureDeviceId,
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
        }
        return null;
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
            child: Text(battleOption.loopCount.toString()),
          ),
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
              final recover = await const RecoverSelectDialog(recovers: apRecovers).showDialog<RecoverEntity>(context);
              if (recover != null && !battleOption.recoverIds.contains(recover.id)) {
                battleOption.recoverIds.add(recover.id);
              }
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.waitApRecover,
          title: const Text("Wait AP recover"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.waitApRecover = v!;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.waitApRecoverGold,
          title: const Text("Recover Golden Fruit right after AP changed"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.waitApRecoverGold = v!;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        ListTile(
          dense: true,
          title: const Text("Target drops (stop current loop if reach any)"),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              for (final itemId in battleOption.targetDrops.keys.toList()..sort(Item.compare))
                GestureDetector(
                  onLongPress: () {
                    runtime.lockTask(() {
                      setState(() {
                        battleOption.targetDrops.remove(itemId);
                      });
                    });
                  },
                  child: GameCardMixin.anyCardItemBuilder(
                    context: context,
                    id: itemId,
                    width: 42,
                    text: battleOption.targetDrops[itemId]!.toString(),
                    onTap: () {
                      InputCancelOkDialog(
                        title: 'Target Num of "${GameCardMixin.anyCardItemName(itemId).l}"',
                        text: battleOption.targetDrops[itemId]?.toString(),
                        validate: (s) => (int.tryParse(s) ?? -1) >= 0,
                        keyboardType: TextInputType.number,
                        onSubmit: (s) {
                          runtime.lockTask(() {
                            if (mounted) {
                              setState(() {
                                battleOption.targetDrops[itemId] = int.parse(s);
                              });
                            }
                          });
                        },
                      ).showDialog(context);
                    },
                  ),
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
                  validate: (s) => (int.tryParse(s) ?? -1) >= 0,
                ).showDialog<String>(context);
                if (itemNumStr == null) return;
                final itemNum = int.parse(itemNumStr);
                if (itemNum < 0) return;
                battleOption.targetDrops[itemId] = itemNum;
                if (mounted) setState(() {});
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        ListTile(
          dense: true,
          // title: const Text("Target drop (retire/cancel if no target drop)"),
          title: const Text("Win target drops (win battle if reaches any, otherwise retire/cancel)"),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              for (final itemId in battleOption.winTargetItemNum.keys.toList()..sort(Item.compare))
                GestureDetector(
                  onLongPress: () {
                    runtime.lockTask(() {
                      setState(() {
                        battleOption.winTargetItemNum.remove(itemId);
                      });
                    });
                  },
                  child: GameCardMixin.anyCardItemBuilder(
                    context: context,
                    id: itemId,
                    width: 42,
                    text: battleOption.winTargetItemNum[itemId]?.toString(),
                    onTap: () {
                      InputCancelOkDialog(
                        title: 'Win Target Num of "${GameCardMixin.anyCardItemName(itemId).l}"',
                        text: battleOption.winTargetItemNum[itemId]?.toString(),
                        validate: (s) => (int.tryParse(s) ?? -1) > 0,
                        keyboardType: TextInputType.number,
                        onSubmit: (s) {
                          runtime.lockTask(() {
                            if (mounted) {
                              setState(() {
                                battleOption.winTargetItemNum[itemId] = int.parse(s);
                              });
                            }
                          });
                        },
                      ).showDialog(context);
                    },
                  ),
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
    final questPhase =
        AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase, null, runtime.region) ??
        AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase);
    final formation = mstData.userDeck[battleOption.deckId];

    final eventId = quest?.logicEvent?.id ?? 0;
    final eventDeckNo = questPhase?.extraDetail?.useEventDeckNo ?? 1;
    final eventFormation = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, eventDeckNo)];
    final userQuest = mstData.userQuest[battleOption.questId];
    final now = DateTime.now().timestamp;
    List<(Item, UserItemEntity)> teapots = [
      for (final teapot in runtime.gameData.teapots.values)
        if (teapot.startedAt <= now && teapot.endedAt >= now)
          if ((mstData.userItem[teapot.id]?.num ?? 0) > 0) (teapot, mstData.userItem[teapot.id]!),
    ];
    teapots.sort2((e) => e.$1.startedAt);
    if (mstData.userItem.isNotEmpty && !teapots.any((e) => e.$1.id == battleOption.campaignItemId)) {
      battleOption.campaignItemId = 0;
    }

    String? questInfoText;
    if (userQuest != null) {
      questInfoText = 'phase ${userQuest.questPhase}  clear ${userQuest.clearNum}  challenge ${userQuest.challengeNum}';
      final lotteries = quest?.logicEvent?.lotteries ?? [];
      for (final lottery in lotteries) {
        final userBoxGacha = mstData.userBoxGacha[lottery.id];
        if (lottery.limited || userBoxGacha == null) continue;
        final boxPerLottery = Maths.sum(
          lottery.boxes.where((e) => e.boxIndex == userBoxGacha.boxIndex).map((e) => e.maxNum),
        );
        String countInfo = '';
        double count;
        if (userBoxGacha.isReset) {
          countInfo = '${userBoxGacha.resetNum}';
          count = userBoxGacha.resetNum.toDouble();
        } else {
          countInfo = '(${userBoxGacha.resetNum - 1} + ${userBoxGacha.drawNum}/$boxPerLottery)';
          count = userBoxGacha.resetNum - 1 + userBoxGacha.drawNum / boxPerLottery;
        }
        final ownItemNum = mstData.userItem[lottery.cost.itemId]?.num ?? 0;
        final notGachaLotteryCount = ownItemNum / (lottery.cost.amount * boxPerLottery);
        countInfo += '+${notGachaLotteryCount.format(compact: false, precision: 1)}';
        countInfo += '=${(count + notGachaLotteryCount).format(compact: false, precision: 1)}';
        questInfoText = '$questInfoText\n${S.current.event_lottery} $countInfo';
      }
    }

    return TileGroup(
      header: 'Battle Setup',
      children: [
        ListTile(
          dense: true,
          title: Text(_describeQuest(battleOption.questId, battleOption.questPhase, null)),
          subtitle: questInfoText == null ? null : Text(questInfoText),
          onTap: () => router.push(url: Routes.questI(battleOption.questId, battleOption.questPhase)),
          trailing: TextButton(
            onPressed: () {
              runtime.lockTask(() {
                InputCancelOkDialog(
                  title: 'Quest ID',
                  text: battleOption.questId.toString(),
                  keyboardType: TextInputType.number,
                  onSubmit: (s) async {
                    final questId = int.tryParse(s);
                    Quest? quest = db.gameData.quests[questId];
                    if (questId != null && questId > 0) {
                      quest ??= await showEasyLoading(() => AtlasApi.quest(questId, region: agent.user.region));
                    }
                    if (questId != null && quest != null && !quest.flags.contains(QuestFlag.superBoss)) {
                      battleOption.questId = questId;
                      final userQuest = mstData.userQuest[questId];
                      if (mstData.user != null) {
                        if (userQuest != null && userQuest.clearNum > 0) {
                          battleOption.questPhase = userQuest.questPhase;
                        } else {
                          battleOption.questPhase =
                              quest.phases.firstWhereOrNull((e) => e > (userQuest?.questPhase ?? 0)) ??
                              battleOption.questPhase;
                        }
                      }
                      if (quest.phases.isNotEmpty && !quest.phases.contains(battleOption.questPhase)) {
                        battleOption.questPhase = quest.phases.first;
                      }
                      if (mounted) setState(() {});
                      await AtlasApi.questPhase(questId, battleOption.questPhase, region: runtime.region);
                      if (mounted) setState(() {});
                    } else {
                      EasyLoading.showError('Invalid Quest');
                    }
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              });
            },
            child: Text(battleOption.questId.toString()),
          ),
        ),
        ListTile(
          dense: true,
          title: const Text("Quest Phase"),
          subtitle: Text('phases: ${quest?.phases.join('/') ?? '-'}'),
          trailing: TextButton(
            onPressed:
                quest == null
                    ? null
                    : () {
                      runtime.lockTask(() {
                        InputCancelOkDialog(
                          title: 'Quest Phase',
                          keyboardType: TextInputType.number,
                          onSubmit: (s) async {
                            final phase = int.tryParse(s);
                            if (phase != null && quest.phases.contains(phase)) {
                              battleOption.questPhase = phase;
                            } else {
                              EasyLoading.showError('Invalid Phase');
                            }
                            if (mounted) setState(() {});
                            await AtlasApi.questPhase(
                              battleOption.questId,
                              battleOption.questPhase,
                              region: runtime.region,
                            );
                            if (mounted) setState(() {});
                          },
                        ).showDialog(context);
                      });
                    },
            child: Text(battleOption.questPhase.toString()),
          ),
        ),
        ListTile(
          dense: true,
          title: Text("Deck ${battleOption.deckId}"),
          subtitle: formation == null ? const Text("Unknown deck") : Text('${formation.deckNo} - ${formation.name}'),
          trailing: const Icon(Icons.change_circle),
          onTap: () {
            router.pushPage(
              UserFormationDecksPage(
                mstData: mstData,
                selectedDeckId: battleOption.deckId,
                onSelected: (v) {
                  runtime.lockTask(() {
                    battleOption.deckId = v.id;
                  });
                  if (mounted) setState(() {});
                },
              ),
            );
          },
        ),
        if (formation != null) ..._buildUserDeck(formation.deckInfo),
        if ((questPhase ?? quest)?.isUseUserEventDeck() == true) ...[
          ListTile(
            dense: true,
            title: Text("Event Deck ${eventFormation?.deckNo ?? eventDeckNo}"),
            subtitle: eventFormation?.eventId == 0 ? null : Text('Event $eventId'),
            trailing: const Icon(Icons.change_circle),
            onTap: () {
              router.pushPage(UserFormationDecksPage(mstData: mstData, eventId: eventId));
            },
          ),
          if (eventFormation != null) ..._buildUserDeck(eventFormation.deckInfo),
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
                ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              runtime.lockTask(() {
                router.pushPage(
                  ServantListPage(
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
                  ),
                );
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
                ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              runtime.lockTask(() {
                router.pushPage(
                  CraftListPage(
                    pinged: db.curUser.battleSim.pingedCEsWithEventAndBond(quest, null).toList(),
                    onSelected: (ce) {
                      if (ce.collectionNo <= 0) {
                        EasyLoading.showError('Not playable');
                        return;
                      }
                      battleOption.supportCeIds.add(ce.id);
                      if (mounted) setState(() {});
                    },
                  ),
                );
              });
            },
            icon: const Icon(Icons.add_circle),
          ),
        ),
        if (questPhase != null && questPhase.supportServants.isNotEmpty)
          ListTile(
            dense: true,
            title: Text(
              "${questPhase.supportServants.length} Guest Supports (${questPhase.flags.where((e) => e.name.toLowerCase().contains('support') && e != QuestFlag.supportSelectAfterScript).map((e) => e.name).join('/')})",
            ),
            subtitle: DropdownButton<int>(
              isDense: true,
              isExpanded: true,
              value:
                  questPhase.supportServants.any((e) => e.id == battleOption.npcSupportId)
                      ? battleOption.npcSupportId
                      : 0,
              items: [
                DropdownMenuItem(value: 0, child: Text("Do not use support")),
                for (final support in questPhase.supportServants)
                  DropdownMenuItem(
                    value: support.id,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          CenterWidgetSpan(child: support.svt.iconBuilder(context: context, width: 24)),
                          TextSpan(text: ' Lv.${support.lv} ${support.skills2.skillLvs.join("/")} ${support.lName.l}'),
                        ],
                      ),
                    ),
                  ),
              ],
              onChanged: (v) {
                runtime.lockTask(() {
                  battleOption.npcSupportId = v ?? 0;
                });
              },
            ),
          ),
        DividerWithTitle(title: Transl.itemNames('星見のティーポット').l),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.useCampaignItem,
          secondary: Item.iconBuilder(context: context, item: null, itemId: 94065901, jumpToDetail: false),
          title: Text(Transl.itemNames('星見のティーポット').l),
          subtitle:
              teapots.isEmpty
                  ? null
                  : Text.rich(
                    TextSpan(
                      children: [
                        for (final teapot in teapots)
                          TextSpan(
                            text:
                                '×${teapot.$2.num}'
                                '(${teapot.$1.endedAt.sec2date().toCustomString(year: false, second: false)})  ',
                          ),
                      ],
                    ),
                  ),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.useCampaignItem = v!;
              });
            });
          },
        ),
        if (mstData.userItem.isNotEmpty && teapots.isNotEmpty)
          ListTile(
            dense: true,
            leading: Text('> '),
            minLeadingWidth: 20,
            title: DropdownButton<int>(
              // isDense: true,
              underline: SizedBox.shrink(),
              isExpanded: true,
              value: battleOption.campaignItemId,
              items: [
                DropdownMenuItem(value: 0, child: Text('auto select')),
                for (final (teapot, userItem) in teapots)
                  DropdownMenuItem(
                    value: teapot.id,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          CenterWidgetSpan(child: Item.iconBuilder(context: context, item: teapot, width: 28)),
                          TextSpan(text: ' ${teapot.lName.l} ×${userItem.num} '),
                          TextSpan(
                            text: ' (${teapot.endedAt.sec2date().toCustomString(year: false, second: false)}) ',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              onChanged:
                  battleOption.useCampaignItem
                      ? (v) {
                        runtime.lockTask(() {
                          if (v != null) battleOption.campaignItemId = v;
                        });
                      }
                      : null,
            ),
          ),
        const Divider(),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.isApHalf,
          title: const Text("During AP Half Event"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.isApHalf = v!;
              });
            });
          },
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
                        final turns = s.split(RegExp(r'[,/\- ]+')).map(int.parse).toList();
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

  Widget get uncommonSettingSection {
    return TileGroup(
      header: 'Other Options',
      children: [
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.stopIfBondLimit,
          title: const Text("Stop if Bond Limit"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.stopIfBondLimit = v!;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.supportCeMaxLimitBreak,
          title: Text('${S.current.support_servant} - ${S.current.craft_essence_short} ${S.current.max_limit_break}'),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.supportCeMaxLimitBreak = v!;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.useEventDeck,
          tristate: true,
          title: Text("${S.current.support_servant_short} - Use Event Deck"),
          subtitle: Text("Supposed: ${db.gameData.quests[battleOption.questId]?.logicEvent != null ? 'Yes' : 'No'}"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.useEventDeck = v;
              });
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.enfoceRefreshSupport,
          title: const Text("Force Refresh Support"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.enfoceRefreshSupport = v!;
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
                  validate: (s) => s.isEmpty || (int.tryParse(s) ?? -1) > (agent.user.region == Region.jp ? 20 : 40),
                  onSubmit: (s) {
                    if (s.isEmpty) {
                      battleOption.battleDuration = null;
                    } else {
                      battleOption.battleDuration = int.parse(s);
                    }
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              });
            },
            child: Text(battleOption.battleDuration?.toString() ?? S.current.general_default),
          ),
        ),
      ],
    );
  }

  Widget get notificationSettingSection {
    final fakerSettings = db.settings.fakerSettings;
    return TileGroup(
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
              final notifications = await LocalNotificationUtil.plugin.pendingNotificationRequests();
              for (final notification in notifications) {
                if (LocalNotificationUtil.isUserApId(notification.id)) {
                  LocalNotificationUtil.plugin.cancel(notification.id);
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
            optionBuilder: (v) => v == 0 ? Text(agent.user.userGame?.actMax.toString() ?? 'Full') : Text(v.toString()),
            onFilterChanged: (_, lastChanged) {
              setState(() {
                if (lastChanged != null) {
                  agent.user.recoveredAps.remove(lastChanged);
                  agent.network.setLocalNotification(removedAps: [lastChanged]);
                }
              });
            },
          ),
          trailing: IconButton(
            onPressed: () {
              InputCancelOkDialog(
                title: 'AP',
                keyboardType: TextInputType.number,
                helperText: '0 = Max AP (${(mstData.user ?? agent.user.userGame)?.actMax})',
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
              final pendings = await LocalNotificationUtil.plugin.pendingNotificationRequests();
              if (pendings.isEmpty) {
                EasyLoading.showInfo('No notifications');
                return;
              }
              pendings.sort2((e) => e.id);
              router.showDialog(
                builder: (context) {
                  return SimpleDialog(
                    title: Text('${pendings.length} Pending Notifications'),
                    children: divideList([
                      for (final notification in pendings)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 24),
                          title: Text(notification.title ?? 'no title'),
                          subtitle: Text([if (kDebugMode) 'id ${notification.id}', '${notification.body}'].join('\n')),
                        ),
                    ], const Divider(height: 1)),
                  );
                },
              );
            },
            child: const Text('Pending Notifications'),
          ),
        ),
      ],
    );
  }

  Widget get globalSettingSection {
    final fakerSettings = db.settings.fakerSettings;
    return TileGroup(
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
            child: Text(fakerSettings.maxFollowerListRetryCount.toString()),
          ),
        ),
        const Divider(),
        SwitchListTile.adaptive(
          dense: true,
          value: fakerSettings.showProgressToast,
          title: const Text('Show progress toasts'),
          onChanged: (v) async {
            setState(() {
              fakerSettings.showProgressToast = v;
            });
            if (!v) {
              runtime.dismissToast();
            }
          },
        ),
        const Divider(),
        CheckboxListTile.adaptive(
          dense: true,
          value: fakerSettings.dumpResponse,
          title: const Text('Dump Responses'),
          onChanged: (v) {
            setState(() {
              fakerSettings.dumpResponse = v!;
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

    FilledButton buildButton({bool enabled = true, required VoidCallback onPressed, required String text}) {
      return FilledButton.tonal(onPressed: enabled ? onPressed : null, style: buttonStyle, child: Text(text));
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
                runtime.runTask(() async {
                  await agent.loginTop();
                  await agent.homeTop();
                });
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
            runtime.runTask(
              () => agent.battleResultWithOptions(
                battleEntity: agent.curBattle!,
                resultType: battleOption.resultType,
                actionLogs: battleOption.actionLogs,
              ),
            );
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
              text: (battleOption.loopCount == 0 ? 1 : battleOption.loopCount).toString(),
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
          itemBuilder:
              (context) => [
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
                // PopupMenuItem(
                //   enabled: loggedIn && !inBattle,
                //   onTap: () {
                //     runtime.runTask(() async {
                //       final dir = Directory(agent.network.fakerDir);
                //       final files = dir
                //           .listSync(followLinks: false)
                //           .whereType<File>()
                //           .where((e) => e.path.endsWith('.json') && e.path.contains('battle') && e.path.contains('setup'))
                //           .toList();
                //       final modified = DateTime.now().subtract(const Duration(days: 2));
                //       files.removeWhere((e) => e.statSync().modified.isBefore(modified));
                //       files.sort2((e) => e.path, reversed: true);
                //       if (files.isEmpty) {
                //         EasyLoading.showError('not found');
                //         return;
                //       }
                //       final data = FateTopLogin.parseAny(jsonDecode(files.first.readAsStringSync()));
                //       agent.curBattle = data.mstData.battles.firstOrNull ?? agent.curBattle;
                //     });
                //   },
                //   child: const Text('loadBattle'),
                // ),
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
                          () => runtime.withWakeLock('seed-wait-$hashCode', () => runtime.seedWait(int.parse(s))),
                        );
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
                PopupMenuItem(
                  enabled: !runtime.runningTask.value && inBattle,
                  onTap: () async {
                    runtime.runTask(() async {
                      runtime.agent.curBattle = null;
                    });
                  },
                  child: const Text('Clear Battle'),
                ),
                if (kDebugMode)
                  PopupMenuItem(
                    child: const Text('Test'),
                    onTap: () async {
                      runtime.runTask(() => Future.delayed(Duration(seconds: 15)));
                    },
                  ),
              ],
        ),
      ],
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
            valueListenable: runtime.activeToast,
            builder: (context, msg, _) {
              if (msg == null) return const SizedBox.shrink();
              Widget child = Text(
                msg,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              );
              return InkWell(
                onTap: () {
                  SimpleCancelOkDialog(
                    title: Text('Message'),
                    scrollable: true,
                    hideCancel: true,
                    content: Text(msg),
                  ).showDialog(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: child,
                ),
              );
            },
          ),
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

  List<Widget> _buildUserDeck(DeckServantEntity? deckInfo) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FormationCard(
          formation: UserDeckEntityX.toFormation(deckInfo: deckInfo, mstData: mstData),
          userSvtCollections: mstData.userSvtCollection.dict,
        ),
      ),
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          constraints: const BoxConstraints(maxWidth: 80 * 6 + 64),
          child: Builder(
            builder: (context) {
              final svts = deckInfo?.svts ?? [];
              final svtsMap = {for (final svt in svts) svt.id: svt};
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...List.generate(6, (index) {
                    final collection = mstData.userSvtCollection[mstData.userSvt[svtsMap[index + 1]?.userSvtId]?.svtId];
                    final svt = db.gameData.servantsById[collection?.svtId];
                    if (collection == null || svt == null || svt.bondGrowth.length < collection.friendshipRank + 1) {
                      return const Expanded(flex: 10, child: SizedBox.shrink());
                    }
                    final (bondA, bondB) = svt.getPastNextBonds(collection.friendshipRank, collection.friendship);
                    final bool reachBondLimit = bondB == 0;

                    String bondText =
                        'Lv.${collection.friendshipRank}/${10 + collection.friendshipExceedCount}'
                        // '\n${collection.friendship}'
                        '\n${-bondB}';
                    // battle result
                    final oldCollection = agent.lastBattleResultData?.oldUserSvtCollection.firstWhereOrNull(
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
                            value: bondA,
                            total: bondA + bondB,
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
            },
          ),
        ),
      ),
    ];
  }
}
