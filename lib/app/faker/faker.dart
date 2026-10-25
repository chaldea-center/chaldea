import 'dart:convert';
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
import 'package:chaldea/app/modules/craft_essence/craft_list.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/faker.dart';
import 'package:chaldea/models/faker/quiz/crypt_data.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/alarm.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/notification.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '_shared/faker_ui.dart';
import '_shared/history.dart';
import 'battle_mission_value_page.dart';
import 'details/dialogs.dart';
import 'details/dump_clean.dart';
import 'details/login_result.dart';
import 'event/raids.dart';
import 'home/reminders.dart';
import 'option_list.dart';
import 'present_box/present_box.dart';
import 'runtime.dart';
import 'user_deck/deck_list.dart';

class FakeGrandOrder extends StatefulWidget {
  final AutoLoginData user;
  final bool autoLogin;
  const FakeGrandOrder({super.key, required this.user, this.autoLogin = false});

  @override
  State<FakeGrandOrder> createState() => _FakeGrandOrderState();
}

class _FakeGrandOrderState extends State<FakeGrandOrder> with FakerRuntimeStateMixin {
  @override
  final bool autoManageDependencies = false;
  FakerRuntime? _runtime;
  @override
  FakerRuntime get runtime => _runtime!;

  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  /// Collapse progress of the pinned status header (0 expanded, 1 collapsed),
  /// published to the app bar crossfade. The delegate reports progress during
  /// its own build, so the value is written from a post-frame hook; listeners
  /// rebuild only the title/ring subtrees instead of the whole page.
  final ValueNotifier<double> _headerCollapse = ValueNotifier<double>(0);

  void _onHeaderProgress(double progress) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _headerCollapse.value != progress) {
        _headerCollapse.value = progress;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _runtime?.removeDependency(this);
    _headerCollapse.dispose();
    super.dispose();
  }

  Future<void> init() async {
    try {
      // ignore: use_build_context_synchronously
      final runtime = await FakerRuntime.init(widget.user, this);
      if (runtime.hasMultiRoots && mounted) {
        SimpleConfirmDialog(
          title: Text(S.current.warning),
          content: Text('Another window is already open.'),
          showCancel: false,
        ).showDialog(context);
      }
      await runtime.loadInitData();
      _runtime = runtime;
      _onChangeQuest();
      if (widget.autoLogin && !runtime.mstData.isLoggedIn && agent.user.lastRequestOptions?.success != false) {
        _startLogin();
      }
    } catch (e, s) {
      if (mounted) {
        SimpleConfirmDialog(
          title: Text(S.current.error),
          content: Text(e.toString()),
          scrollable: true,
        ).showDialog(context);
      }
      logger.e('init FakerState failed', e, s);
    }
    if (mounted) setState(() {});
  }

  (int, int) _lastQuestKey = (0, 0);
  void _onChangeQuest() async {
    final cache = AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase, null, runtime.region);
    if (cache == null) {
      if (mounted) setState(() {});
      await AtlasApi.questPhase(battleOption.questId, battleOption.questPhase, region: runtime.region);
    }
    if (mounted) setState(() {});
  }

  int getEventIdByQuest(int? questId) {
    if (questId == null) return 0;
    final event = db.gameData.quests[questId]?.war?.eventReal;
    if (event != null) return event.id;
    for (final (eventId, questIds) in db.gameData.others.eventQuestGroups.items) {
      if (questIds.contains(questId) && eventId != 0) {
        return eventId;
      }
    }
    return 0;
  }

  String _describeQuest(int questId, int phase, String? enemyCounts) {
    final quest = db.gameData.quests[questId];
    if (quest == null) return '$questId/$phase';
    final phaseDetail = db.gameData.questPhaseDetails[questId * 100 + phase];
    return [
      // if (quest.warId == WarId.ordealCall || (quest.warId > 1000 && (quest.isAnyFree || quest.isAnyRaid)))
      'Lv.${(phaseDetail?.recommendLv ?? quest.recommendLv)}',
      ?enemyCounts,
      (quest.isMainStoryFree ? quest.lDispName : quest.lNameWithChapter).setMaxLines(1),
      'P$phase',
      if (quest.war != null) '@${quest.war?.lShortName.setMaxLines(1)}',
    ].join(' ');
  }

  /// Quest id and phase are metadata the player only verifies, so they sit as
  /// chips one line tall instead of taking a card row of their own.
  Widget _questValueChip(String label, {VoidCallback? onPressed}) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// One `label value` pair of the misc info strip; an [onTap] marks an
  /// editable value with the primary color.
  Widget _infoText(String label, String value, {VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    final text = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          TextSpan(
            text: value,
            style: onTap == null ? null : TextStyle(color: colors.primary),
          ),
        ],
      ),
      style: Theme.of(context).textTheme.bodySmall,
    );
    return onTap == null ? text : InkWell(onTap: onTap, child: text);
  }

  /// Phase is picked from the quest's own phase list; typing it by hand only
  /// produced values the agent then rejected.
  Future<void> _pickQuestPhase() async {
    final quest = db.gameData.quests[battleOption.questId];
    if (quest == null) return;
    final phase = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Quest Phase'),
        children: [
          for (final phase in quest.phases)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, phase),
              child: Row(
                children: [
                  Expanded(child: Text('Phase $phase')),
                  if (phase == battleOption.questPhase) const Icon(Icons.check, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
    if (phase == null || !mounted) return;
    runtime.lockTask(() async {
      battleOption.questPhase = phase;
      if (mounted) setState(() {});
      await AtlasApi.questPhase(battleOption.questId, battleOption.questPhase, region: runtime.region);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _runtime == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Fake/Grand Order")),
        body: kIsWeb ? const Center(child: Text('Not supported')) : const Center(child: CircularProgressIndicator()),
      );
    }
    if (_lastQuestKey != (battleOption.questId, battleOption.questPhase)) {
      _lastQuestKey = (battleOption.questId, battleOption.questPhase);
      _onChangeQuest();
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            if (runtime.runningTask.value) {
              SimpleConfirmDialog(
                title: Text(S.current.warning),
                content: const Text("Task is still running! Cannot exit!"),
                showCancel: false,
              ).showDialog(context);
              return;
            }
            final confirm = await const SimpleConfirmDialog(title: Text("Exit?")).showDialog(context);
            if (confirm == true && context.mounted) Navigator.pop(context);
          },
        ),
        title: appBarTitle,
        actions: [appBarStatus, runtime.buildHistoryButton(context), runtime.buildMenuButton(context)],
      ),
      body: PopScope(canPop: false, child: FakerTileTheme(child: body)),
    );
  }

  Widget get body {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: _StatusHeaderDelegate(
                      row: statusRow,
                      items: statusItems,
                      tabBar: tabBar,
                      onProgress: _onHeaderProgress,
                    ),
                  ),
                ),
              ],
              body: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: TabBarView(children: [_tabView(battleTab), _tabView(optionsTab), _tabView(miscTab)]),
              ),
            ),
          ),
          const Divider(height: 1),
          buttonBar,
        ],
      ),
    );
  }

  Widget get tabBar {
    return FixedHeight.tabBar(
      TabBar(
        tabs: const [
          Tab(text: 'Battle'),
          Tab(text: 'Options'),
          Tab(text: 'Misc'),
        ],
      ),
    );
  }

  /// Wraps one tab's rows in a sliver scroll view. [SliverOverlapInjector]
  /// reserves the pinned header's height, otherwise the rows scroll underneath it.
  Widget _tabView(List<Widget> children) {
    return Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverList(delegate: SliverChildListDelegate(children)),
        ],
      ),
    );
  }

  List<Widget> get battleTab {
    return [
      optionSelector,
      const Divider(height: 8),
      FakerReminders(runtime: runtime),
      battleDetailSection,
      battleSetupOptionSection,
    ];
  }

  List<Widget> get optionsTab {
    return [
      optionSelector,
      const Divider(height: 8),
      battleResultOptionSection,
      battleLoopOptionSection,
      uncommonSettingSection,
    ];
  }

  List<Widget> get miscTab {
    return [miscInfoSection, accountSettingSection, globalSettingSection];
  }

  /// Swaps the page title for the collapsed status title in two stages, so the
  /// two never sit on top of each other at a readable opacity.
  Widget get appBarTitle {
    // The old title is gone by 0.55 while the new one starts at 0.45; across
    // that window both stay at 0.18 or below.
    const double fadeInStart = 0.45, fadeOutEnd = 0.55;
    return ValueListenableBuilder<double>(
      valueListenable: _headerCollapse,
      builder: (context, progress, _) {
        final oldOpacity = (1 - progress / fadeOutEnd).clamp(0.0, 1.0);
        final newOpacity = ((progress - fadeInStart) / (1 - fadeInStart)).clamp(0.0, 1.0);
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Opacity(opacity: oldOpacity, child: const Text("Fake/Grand Order")),
            if (newOpacity > 0) Opacity(opacity: newOpacity, child: collapsedAppBarTitle),
          ],
        );
      },
    );
  }

  Widget get appBarStatus {
    final userGame = mstData.user ?? agent.user.userGame;
    return ValueListenableBuilder<double>(
      valueListenable: _headerCollapse,
      builder: (context, progress, _) {
        if (progress <= 0) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Opacity(
              opacity: progress,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userGame != null)
                    TimerUpdate(
                      builder: (context, _) => Text(
                        '${userGame.calCurAp()}/${userGame.actMax}'
                        '\n${Duration(seconds: (userGame.actRecoverAt - DateTime.now().timestamp)).toString().split('.').first}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  runtime.buildCircularProgress(
                    context: context,
                    showElapsed: true,
                    size: 16,
                    padding: .symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shown instead of the page title once the status card has collapsed.
  Widget get collapsedAppBarTitle {
    final userGame = mstData.user ?? agent.user.userGame;
    return Text(
      '[${agent.user.serverName}] ${userGame?.displayName ?? "not login"}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get statusRow {
    final userGame = mstData.user ?? agent.user.userGame;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() {}),
            child: runtime.buildCircularProgress(context: context, showElapsed: true, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${agent.user.serverName}] ${userGame?.displayName ?? "not login"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                statusInfo,
              ],
            ),
          ),
          if (userGame != null)
            TimerUpdate(
              builder: (context, time) {
                return Tooltip(
                  message: userGame.actRecoverAt.sec2date().toCustomString(year: false),
                  child: SelectionContainer.disabled(
                    child: Text(
                      '${userGame.calCurAp()}/${userGame.actMax}'
                      '\n${Duration(seconds: (userGame.actRecoverAt - DateTime.now().timestamp)).toString().split('.').first}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget get statusInfo {
    final userGame = mstData.user ?? agent.user.userGame;
    List<InlineSpan> info = [TextSpan(text: userGame?.friendCode ?? '')];
    if (mstData.isLoggedIn) {
      void onTapPresentBox() => router.pushPage(UserPresentBoxManagePage(runtime: runtime));
      info.addAll([
        TextSpan(text: '  '),
        CenterWidgetSpan(
          child: db.getIconImage(
            "https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/OrdealCall/TerminalAtlas/status_icongift_open.png",
            width: 20,
            onTap: onTapPresentBox,
          ),
        ),
        TextSpan(
          text: ' ${mstData.userPresentBox.length}/${runtime.gameData.timerData.constants.maxPresentBoxNum}',
          style: mstData.userPresentBox.length > runtime.gameData.timerData.constants.maxPresentBoxNum - 20
              ? TextStyle(color: Colors.amber)
              : null,
          recognizer: TapGestureRecognizer()..onTap = onTapPresentBox,
        ),
      ]);
    }

    if (runtime.agentData.loginResultHistory.isNotEmpty) {
      void onTapBonus() => router.pushPage(LoginResultPage(runtime: runtime));
      info.addAll([
        TextSpan(text: '  '),
        CenterWidgetSpan(
          child: db.getIconImage(
            "https://static.atlasacademy.io/file/aa-fgo-extract-jp/Terminal/OrdealCall/CommonUIAtlas/icon_play.png",
            width: 18,
            onTap: onTapBonus,
          ),
        ),
        TextSpan(
          text:
              ' ${runtime.agentData.loginResultHistory.firstOrNull?.length}'
              '(${Maths.sum(runtime.agentData.loginResultHistory.map((e) => e.length))})',
          recognizer: TapGestureRecognizer()..onTap = onTapBonus,
        ),
      ]);
    }

    return Text.rich(
      TextSpan(children: info),
      style: const TextStyle(fontSize: 12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get statusItems {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final itemId in <int>{
            Items.stoneId,
            ...Items.loginSaveItems,
            ...?db.gameData.quests[battleOption.questId]?.consumeItem.map((e) => e.itemId),
          })
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Item.iconBuilder(context: context, item: null, itemId: itemId, width: 20),
                  Text(
                    '×${mstData.getItemOrSvtNum(itemId, defaultValue: agent.user.userItems[itemId] ?? 0)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
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
        _onChangeQuest();
      },
    );
  }

  Widget get miscInfoSection {
    final gameTop = agent.network.gameTop;
    List<Widget> children = [
      // Versions are read-only metadata, so they stay one wrapped text strip
      // instead of earning a card each.
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Wrap(
          spacing: 16,
          runSpacing: 2,
          children: [
            _infoText(
              'AppVer',
              gameTop.appVer,
              onTap: () {
                InputCancelOkDialog(
                  title: 'App Version',
                  validate: (s) => AppVersion.tryParse(s) != null,
                  initValue: gameTop.appVer,
                  onSubmit: (s) {
                    final v = AppVersion.tryParse(s);
                    if (v != null && mounted) {
                      setState(() {
                        gameTop.appVer = s;
                      });
                    }
                  },
                ).showDialog(context);
              },
            ),
            _infoText('DataVer', '${gameTop.dataVer}'),
            _infoText('DateVer', gameTop.dateVer.sec2date().toCustomString(year: true, second: false)),
          ],
        ),
      ),
    ];
    final userGame = runtime.agent.userGame;
    if (userGame != null) {
      final curLv = ConstData.userLevel[userGame.lv];
      final nextLv = ConstData.userLevel[userGame.lv + 1];
      final exp = userGame.exp - (curLv?.requiredExp ?? 0);
      final expTotal = nextLv == null ? 0 : nextLv.requiredExp - (curLv?.requiredExp ?? 0);
      final expLeft = nextLv == null ? null : nextLv.requiredExp - userGame.exp;
      children.add(
        ListTile(
          dense: true,
          title: const Text('Master Lv'),
          trailing: Text(
            [
              'Lv.${userGame.lv}',
              if (expLeft != null) 'NEXT ${expLeft.format(compact: false, groupSeparator: ',')}',
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
      if (expTotal > 0) {
        children.add(
          BondProgress(value: exp, total: expTotal, padding: const EdgeInsets.symmetric(horizontal: 16), minHeight: 4),
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
              '${S.current.command_code_short} ${cardCounts.ccCount}/${runtime.gameData.timerData.constants.maxUserCommandCode}',
              if (cardCounts.unknownCount != 0) '${S.current.unknown} ${cardCounts.unknownCount}',
            ].join('  '),
          ),
        ),
      );
    }
    return TileGroup(header: 'Misc Info', children: children);
  }

  Widget get battleDetailSection {
    final battleEntity = runtime.agentData.curBattle ?? runtime.agentData.lastBattle;
    final lastResult = runtime.agentData.lastBattleResultData;
    final resultType = BattleResultType.values.firstWhereOrNull((e) => e.value == lastResult?.battleResult);
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
      children.add(
        SimpleAccordion(
          headerBuilder: (context, _) {
            final resultName = lastResult != null && lastResult.battleId == battleEntity.id ? resultType?.name : null;
            return ListTile(
              dense: true,
              title: Text(
                _describeQuest(
                  battleEntity.questId,
                  battleEntity.questPhase,
                  battleEntity.battleInfo?.enemyDeck.map((e) => e.svts.length).join('-'),
                ),
              ),
              subtitle: Text([?resultName, if (dropItems.isNotEmpty) '${dropItems.length} drops'].join(' · ')),
              trailing: IconButton(
                tooltip: 'Open quest',
                visualDensity: VisualDensity.compact,
                onPressed: () => router.push(url: Routes.questI(battleEntity.questId, battleEntity.questPhase)),
                icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
              ),
            );
          },
          contentBuilder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FormationCard(
                    formation: BattleTeamFormationX.fromBattleEntity(battleEntity: battleEntity, mstData: mstData),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
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
                ),
              ],
            );
          },
        ),
      );
    }
    children.add(
      SimpleAccordion(
        headerBuilder: (context, _) {
          return ListTile(
            dense: true,
            title: Text('Drop Statistics (${runtime.agentData.totalDropStat.totalCount} runs)'),
            subtitle: runtime.agentData.battleTotalRewards.isEmpty
                ? null
                : Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: (runtime.agentData.battleTotalRewards.keys.toList()..sort(Item.compare)).map((itemId) {
                      return GameCardMixin.anyCardItemBuilder(
                        context: context,
                        id: itemId,
                        width: 30,
                        text: [
                          '+${runtime.agentData.battleTotalRewards[itemId]?.format()}',
                          mstData
                              .getItemOrSvtNum(
                                itemId,
                                eventIds: [battleEntity?.eventId ?? 0, getEventIdByQuest(battleOption.questId)],
                              )
                              .format(),
                        ].join('\n'),
                      );
                    }).toList(),
                  ),
          );
        },
        contentBuilder: (context) {
          runtime.agentData.totalDropStat.items.removeWhere((k, v) => v == 0);
          final questDropIds = db.gameData.dropData.freeDrops2[battleOption.questId]?.items.keys.toList() ?? [];
          for (final itemId in questDropIds.followedBy(battleOption.targetDrops.keys)) {
            runtime.agentData.totalDropStat.items.putIfAbsent(itemId, () => 0);
          }
          final _questPhase = AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase);
          if (_questPhase != null) {
            for (final drop in _questPhase.drops) {
              final ce = db.gameData.craftEssencesById[drop.objectId];
              if (ce != null && ce.rarity == 5) {
                runtime.agentData.totalDropStat.items.putIfAbsent(drop.objectId, () => 0);
              }
            }
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (header, dropStats) in [
                ('Total', runtime.agentData.totalDropStat),
                ('Current Loop', runtime.agentData.curLoopDropStat),
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
                              if (dropStats == runtime.agentData.totalDropStat) {
                                runtime.agentData.battleTotalRewards.clear();
                              }
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
                          '+${dropStats.items[itemId]!.format()}',
                          if (dropStats.totalCount > 0) prob > 1 ? prob.format() : prob.format(percent: true),
                          db.gameData.craftEssencesById.containsKey(itemId)
                              ? (mstData.userSvt.where((e) => e.svtId == itemId).length.toString())
                              : mstData
                                    .getItemOrSvtNum(
                                      itemId,
                                      eventIds: [battleEntity?.eventId ?? 0, getEventIdByQuest(battleOption.questId)],
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
                    child: runtime.buildCircularProgress(
                      context: context,
                      activeColor: Colors.grey,
                      inactiveColor: saveData.success ? Colors.green : Colors.red,
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
                      onPressed: runtime.runningTask.value
                          ? null
                          : () async {
                              final confirm = await SimpleConfirmDialog(
                                title: Text("Send"),
                                content: Text('request:${saveData.key}\nsuccess: ${saveData.success}'),
                              ).showDialog(context);
                              if (confirm != true) return;
                              runtime.runTask(() async {
                                final resp = await agent.network.requestStartDirect(saveData);
                                if (context.mounted) {
                                  SimpleConfirmDialog(
                                    title: Text("Request Result"),
                                    content: Text(
                                      "status: ${resp.rawResponse.statusCode}\n"
                                      "responses:\n${resp.data.responses.map((e) => ' - ${e.nid} ${e.resCode}').join('\n')}",
                                    ),
                                    showCancel: false,
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
      header: battleEntity == null
          ? 'Battle Details'
          : 'Battle ${battleEntity.id} - ${runtime.agentData.curBattle == null ? "${resultType?.name}" : "ongoing"}'
                ' (${battleEntity.createdAt.sec2date().toCustomString(year: false)})',
      children: children,
    );
  }

  Widget _buildRaidTile(BattleEntity? battleEntity) {
    int? eventId, day;
    if (battleEntity != null) {
      eventId = battleEntity.eventId;
      day = battleEntity.battleInfo?.raidInfo.firstOrNull?.day;
    }
    if (day == null) {
      final quest = db.gameData.quests[battleOption.questId];
      if (quest != null && quest.flags.contains(QuestFlag.raid)) {
        eventId = quest.logicEventId;
      }
    }

    Widget? title, subtitle;
    if (eventId != null && day != null) {
      final mstRaid = mstData.mstEventRaid[EventRaidEntity.createPK(eventId, day)];
      final record = runtime.agentData.getRaidRecord(eventId, day).history.lastOrNull;
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
        onPressed: eventId == 0
            ? null
            : () {
                router.pushPage(EventRaidsPage(runtime: runtime, eventId: eventId ?? 0, day: day));
              },
        icon: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      ),
    );
  }

  Widget get battleLoopOptionSection {
    return TileGroup(
      header: 'Loop Options',
      children: [
        ValueCardRow(
          cards: [
            ValueCard(
              label: 'Battle Count',
              value: battleOption.loopCount.toString(),
              onTap: () {
                runtime.lockTask(() {
                  InputCancelOkDialog.number(
                    title: 'Battle Count',
                    initValue: battleOption.loopCount,
                    validate: (v) => v > 0,
                    onSubmit: (v) {
                      battleOption.loopCount = v;
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                });
              },
            ),
          ],
        ),
        const Divider(indent: 16, endIndent: 16, height: 1),
        AddRemoveList<int>(
          inline: true,
          title: const Text('Apples for recover (ordered)'),
          items: battleOption.recoverIds,
          spacing: 4,
          runSpacing: 4,
          onAdd: () async {
            final recover = await RecoverSelectDialog(
              recovers: apRecovers,
              mstData: mstData,
              validateCount: false,
              title: 'Recover AP (Option)',
            ).showDialog<RecoverEntity>(context);
            if (recover != null && !battleOption.recoverIds.contains(recover.id)) {
              battleOption.recoverIds.add(recover.id);
            }
            if (mounted) setState(() {});
          },
          onRemove: (recoverId) {
            setState(() {
              battleOption.recoverIds.remove(recoverId);
            });
          },
          itemBuilder: (context, recoverId, handle) => GestureDetector(
            onTap: handle.tap,
            onLongPress: handle.longPress,
            child: CachedImage(
              imageUrl: apRecovers.firstWhereOrNull((e) => e.id == recoverId)?.icon,
              width: 32,
              height: 32 * 144 / 132,
            ),
          ),
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
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.waitApRecoverGold,
          title: const Text("Wait AP changed before eating Golden Fruit"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.waitApRecoverGold = v;
              });
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.goldApplePrior,
          title: const Text("Prefer to eat Golden Fruit right after AP changed"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.goldApplePrior = v;
              });
            });
          },
        ),
        const Divider(indent: 16, endIndent: 16, height: 1),
        AddRemoveList<int>(
          inline: true,
          title: const Text("Target drops (stop current loop if reach any)"),
          items: battleOption.targetDrops.keys.toList()..sort(Item.compare),
          spacing: 2,
          runSpacing: 2,
          onAdd: () async {
            runtime.lockTask(() async {
              final itemIdStr = await InputCancelOkDialog.number(
                title: 'Item id or CE id',
                validate: (v) => v > 0,
              ).showDialog<String>(context);
              if (itemIdStr == null) return;
              final itemId = int.parse(itemIdStr);
              final itemName = db.gameData.craftEssencesById[itemId]?.lName.l ?? db.gameData.items[itemId]?.lName.l;
              if (itemName == null) {
                EasyLoading.showError("Invalid id");
                return;
              }
              if (!mounted) return;
              final itemNumStr = await InputCancelOkDialog.number(
                title: 'Stop if "$itemName" total drop num ≥',
                validate: (v) => v >= 0,
              ).showDialog<String>(context);
              if (itemNumStr == null) return;
              final itemNum = int.parse(itemNumStr);
              if (itemNum < 0) return;
              battleOption.targetDrops[itemId] = itemNum;
              if (mounted) setState(() {});
            });
          },
          onRemove: (itemId) {
            runtime.lockTask(() {
              setState(() {
                battleOption.targetDrops.remove(itemId);
              });
            });
          },
          onSecondary: (itemId) {
            InputCancelOkDialog.number(
              title: 'Target Num of "${GameCardMixin.anyCardItemName(itemId).l}"',
              initValue: battleOption.targetDrops[itemId],
              validate: (v) => v >= 0,
              onSubmit: (v) {
                runtime.lockTask(() {
                  if (mounted) {
                    setState(() {
                      battleOption.targetDrops[itemId] = v;
                    });
                  }
                });
              },
            ).showDialog(context);
          },
          itemBuilder: (context, itemId, handle) => GestureDetector(
            onTap: handle.tap,
            onLongPress: handle.longPress,
            child: GameCardMixin.anyCardItemBuilder(
              context: context,
              id: itemId,
              width: 42,
              text: battleOption.targetDrops[itemId]!.toString(),
              onTap: handle.tap,
            ),
          ),
        ),
        const Divider(indent: 16, endIndent: 16, height: 1),
        AddRemoveList<int>(
          inline: true,
          // title: const Text("Target drop (retire/cancel if no target drop)"),
          title: const Text("Win target drops (win battle if reaches any, otherwise retire/cancel)"),
          items: battleOption.winTargetItemNum.keys.toList()..sort(Item.compare),
          spacing: 2,
          runSpacing: 2,
          onAdd: () async {
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
              final itemNumStr = await InputCancelOkDialog.number(
                title: 'Win if "$itemName" drop num ≥',
                validate: (v) => v > 0,
              ).showDialog<String>(context);
              if (itemNumStr == null) return;
              final itemNum = int.parse(itemNumStr);
              if (itemNum <= 0) return;
              battleOption.winTargetItemNum[itemId] = itemNum;
              if (mounted) setState(() {});
            });
          },
          onRemove: (itemId) {
            runtime.lockTask(() {
              setState(() {
                battleOption.winTargetItemNum.remove(itemId);
              });
            });
          },
          onSecondary: (itemId) {
            InputCancelOkDialog.number(
              title: 'Win Target Num of "${GameCardMixin.anyCardItemName(itemId).l}"',
              initValue: battleOption.winTargetItemNum[itemId],
              validate: (v) => v > 0,
              onSubmit: (v) {
                runtime.lockTask(() {
                  if (mounted) {
                    setState(() {
                      battleOption.winTargetItemNum[itemId] = v;
                    });
                  }
                });
              },
            ).showDialog(context);
          },
          itemBuilder: (context, itemId, handle) => GestureDetector(
            onTap: handle.tap,
            onLongPress: handle.longPress,
            child: GameCardMixin.anyCardItemBuilder(
              context: context,
              id: itemId,
              width: 42,
              text: battleOption.winTargetItemNum[itemId]?.toString(),
              onTap: handle.tap,
            ),
          ),
        ),
      ],
    );
  }

  Widget get battleSetupOptionSection {
    final List<Widget> children = [];
    final quest = db.gameData.quests[battleOption.questId];
    final questPhase =
        AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase, null, runtime.region) ??
        AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase);

    final userQuest = mstData.userQuest[battleOption.questId];
    final now = DateTime.now().timestamp;

    // Quest Info, Lottery / box gacha progress shown as quest subtitle
    String? questInfoText;
    if (userQuest != null) {
      questInfoText =
          'phase ${userQuest.questPhase}/${quest?.phases.length ?? '-'}  '
          'clear ${userQuest.clearNum}  challenge ${userQuest.challengeNum}';
      List<EventLottery> lotteries = quest?.logicEvent?.lotteries ?? [];
      if (lotteries.isEmpty && quest?.warId == 8407) {
        lotteries = (runtime.gameData.timerData.events[80586] ?? db.gameData.events[80586])?.lotteries ?? [];
      }
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

    children.addAll([
      ListTile(
        dense: true,
        title: Text(_describeQuest(battleOption.questId, battleOption.questPhase, null)),
        subtitle: questInfoText == null ? null : Text(questInfoText),
        onTap: () => router.push(url: Routes.questI(battleOption.questId, battleOption.questPhase)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: .center,
            children: [
              _questValueChip(
                'ID ${battleOption.questId}',
                onPressed: () {
                  runtime.lockTask(() {
                    InputCancelOkDialog.number(
                      title: 'Quest ID',
                      initValue: battleOption.questId,
                      onSubmit: (questId) async {
                        if (await runtime.battle.selectQuest(questId)) {
                          _onChangeQuest();
                        }
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  });
                },
              ),
              _questValueChip(
                'phase ${battleOption.questPhase}/${quest != null && quest.phases.isNotEmpty ? Maths.max(quest.phases) : "-"}',
                onPressed: quest == null || quest.phases.isEmpty ? null : _pickQuestPhase,
              ),
            ],
          ),
        ),
      ),
    ]);

    // Ongoing AP/item campaigns applying to the selected quest
    List<Event> campaigns = [];
    for (final event in runtime.gameData.timerData.events.values) {
      if (event.startedAt > now || event.endedAt <= now) continue;
      for (final campaign in event.campaigns) {
        switch (campaign.target) {
          case .questApFirstTime || .questItemFirstTime:
            if (userQuest != null && userQuest.clearNum > 0) {
              continue;
            }
            break;
          case .questAp:
            break;
          default:
            continue;
        }

        if (!event.isCampaignQuest(battleOption.questId)) continue;

        campaigns.add(event);
        break;
      }
    }
    if (campaigns.isNotEmpty) {
      children.add(
        ListTile(
          dense: true,
          title: Text(campaigns.map((e) => e.lName.l).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${campaigns.length} ${S.current.event_campaign}'),
          onTap: () {
            SimpleDialog(
              title: Text(S.current.event_campaign),
              children: [
                for (final campaign in campaigns)
                  SimpleDialogOption(
                    onPressed: campaign.routeTo,
                    child: Text.rich(
                      TextSpan(
                        text: '[${campaign.id}] ${campaign.lName.l}\n',
                        children: [
                          TextSpan(
                            text: campaign.endedAt.sec2date().toStringShort(omitSec: true),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ).showDialog(context);
          },
        ),
      );
    }

    // User Deck
    children.addAll(getUserDeckSection(quest, questPhase));

    // Support
    children.addAll([
      DividerWithTitle(title: S.current.support_servant_short, indent: 16),
      AddRemoveList<int>(
        inline: true,
        title: Text(S.current.support_servant),
        items: battleOption.supportSvtIds.toList(),
        emptyState: Text(S.current.general_any),
        onAdd: () {
          runtime.lockTask(() {
            router.pushPage(
              ServantListPage(
                pinged: db.settings.gameplay.pinnedSvtIds.toList(),
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
        onRemove: (svtId) {
          runtime.lockTask(() {
            battleOption.supportSvtIds.remove(svtId);
            if (mounted) setState(() {});
          });
        },
        onSecondary: (svtId) => db.gameData.servantsById[svtId]?.routeTo(),
        itemBuilder: (context, svtId, handle) => GestureDetector(
          onTap: handle.tap,
          onLongPress: handle.longPress,
          child: GameCardMixin.cardIconBuilder(
            context: context,
            icon: db.gameData.servantsById[svtId]?.borderedIcon ?? Atlas.common.emptySvtIcon,
            width: 36,
          ),
        ),
      ),

      const Divider(indent: 16, endIndent: 16, height: 1),
      AddRemoveList<int>(
        inline: true,
        title: Text(
          '${S.current.craft_essence_short} (${S.current.max_limit_break} ${battleOption.supportEquipMaxLimitBreak})',
        ),
        items: battleOption.supportEquipIds.toList(),
        emptyState: Text(S.current.general_any),
        onAdd: () {
          runtime.lockTask(() {
            router.pushPage(
              CraftListPage(
                pinnedGroups: db.settings.gameplay.pinnedSvtEquipGroups(quest, null),
                onSelected: (ce) {
                  if (ce.collectionNo <= 0) {
                    EasyLoading.showError('Not playable');
                    return;
                  }
                  battleOption.supportEquipIds.add(ce.id);
                  if (mounted) setState(() {});
                },
              ),
            );
          });
        },
        onRemove: (ceId) {
          runtime.lockTask(() {
            battleOption.supportEquipIds.remove(ceId);
            if (mounted) setState(() {});
          });
        },
        onSecondary: (ceId) => db.gameData.craftEssencesById[ceId]?.routeTo(),
        itemBuilder: (context, ceId, handle) => GestureDetector(
          onTap: handle.tap,
          onLongPress: handle.longPress,
          child: GameCardMixin.cardIconBuilder(
            context: context,
            icon: db.gameData.craftEssencesById[ceId]?.borderedIcon ?? Atlas.common.emptyCeIcon,
            width: 36,
          ),
        ),
      ),
    ]);

    if (questPhase?.isUseGrandBoard == true || quest?.war?.parentWarId == WarId.grandBoardWar) {
      children.add(const Divider(indent: 16, endIndent: 16, height: 1));
      children.add(
        AddRemoveList<int>(
          inline: true,
          title: Text('$kStarChar2 ${S.current.grand_servant} - ${S.current.craft_essence_short}'),
          items: battleOption.grandSupportEquipIds.toList(),
          emptyState: Text(S.current.general_any),
          onAdd: () {
            runtime.lockTask(() {
              router.pushPage(
                CraftListPage(
                  pinnedGroups: db.settings.gameplay.pinnedSvtEquipGroups(quest, null),
                  onSelected: (ce) {
                    if (ce.collectionNo <= 0) {
                      EasyLoading.showError('Not playable');
                      return;
                    }
                    battleOption.grandSupportEquipIds.add(ce.id);
                    if (mounted) setState(() {});
                  },
                ),
              );
            });
          },
          onRemove: (ceId) {
            runtime.lockTask(() {
              battleOption.grandSupportEquipIds.remove(ceId);
              if (mounted) setState(() {});
            });
          },
          onSecondary: (ceId) => db.gameData.craftEssencesById[ceId]?.routeTo(),
          itemBuilder: (context, ceId, handle) => GestureDetector(
            onTap: handle.tap,
            onLongPress: handle.longPress,
            child: GameCardMixin.cardIconBuilder(
              context: context,
              icon: db.gameData.craftEssencesById[ceId]?.borderedIcon ?? Atlas.common.emptyCeIcon,
              width: 36,
            ),
          ),
        ),
      );
    }
    if (questPhase != null && questPhase.supportServants.isNotEmpty) {
      children.add(
        ListTile(
          dense: true,
          title: Text(
            "${questPhase.supportServants.length} Guest Supports (${questPhase.flags.where((e) => e.name.toLowerCase().contains('support') && e != QuestFlag.supportSelectAfterScript).map((e) => e.name).join('/')})",
          ),
          subtitle: DropdownButton<int>(
            isDense: true,
            isExpanded: true,
            value: questPhase.supportServants.any((e) => e.id == battleOption.npcSupportId)
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
      );
    }

    // Campaign Item
    // Active teapots (campaign items) the user currently holds
    List<(Item, UserItemEntity)> teapots = [
      for (final teapot in runtime.gameData.teapots.values)
        if (teapot.startedAt <= now && teapot.endedAt >= now)
          if ((mstData.userItem[teapot.id]?.num ?? 0) > 0) (teapot, mstData.userItem[teapot.id]!),
    ];
    teapots.sort2((e) => e.$1.startedAt);
    if (mstData.userItem.isNotEmpty && !teapots.any((e) => e.$1.id == battleOption.campaignItemId)) {
      battleOption.campaignItemId = 0;
    }

    children.add(DividerWithTitle(title: Transl.itemNames('星見のティーポット').l));
    children.add(
      SwitchListTile.adaptive(
        dense: true,
        value: battleOption.useCampaignItem,
        secondary: Item.iconBuilder(context: context, item: null, itemId: Items.teapotId, jumpToDetail: false),
        title: Text(Transl.itemNames('星見のティーポット').l),
        subtitle: teapots.isEmpty
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
              battleOption.useCampaignItem = v;
            });
          });
        },
      ),
    );
    if (mstData.userItem.isNotEmpty && teapots.isNotEmpty) {
      children.add(
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
                        CenterWidgetSpan(
                          child: Item.iconBuilder(context: context, item: teapot, width: 28),
                        ),
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
            onChanged: battleOption.useCampaignItem
                ? (v) {
                    runtime.lockTask(() {
                      if (v != null) battleOption.campaignItemId = v;
                    });
                  }
                : null,
          ),
        ),
      );
    }

    // AP Half
    children.add(const Divider());
    children.add(
      SwitchListTile.adaptive(
        dense: true,
        value: battleOption.isApHalf,
        title: const Text("During AP Half Event"),
        onChanged: (v) {
          runtime.lockTask(() {
            setState(() {
              battleOption.isApHalf = v;
            });
          });
        },
      ),
    );
    return TileGroup(
      headerWidget: SHeader.rich(
        TextSpan(
          text: 'Battle Setup  ',
          children: [
            if (battleOption.useCampaignItem)
              CenterWidgetSpan(child: db.getIconImage(AssetURL.i.items(Items.teapotId), width: 24, height: 24)),
          ],
        ),
      ),
      children: children,
    );
  }

  Widget get battleResultOptionSection {
    // Only these two are meaningful for the settle request; a value persisted
    // by an older build (none / lose / interruption) would break the dropdown.
    const resultTypes = [BattleResultType.win, BattleResultType.cancel];
    return TileGroup(
      header: 'Battle Result Options',
      children: [
        ValueCardRow(
          cards: [
            ValueCard<BattleResultType>(
              label: 'Result Type',
              optionValue: resultTypes.contains(battleOption.resultType)
                  ? battleOption.resultType
                  : BattleResultType.win,
              options: resultTypes,
              optionLabel: (type) => type.name,
              onSelected: (v) {
                runtime.lockTask(() {
                  setState(() {
                    battleOption.resultType = v;
                  });
                });
              },
            ),
            // Editable but not consumed yet: settling a battle still hardcodes
            // `winResult`, so changing this value has no effect on the request.
            ValueCard<BattleWinResultType>(
              label: 'Win Type',
              optionValue: battleOption.winType,
              options: BattleWinResultType.values,
              optionLabel: (type) => type.name,
              onSelected: (v) {
                runtime.lockTask(() {
                  setState(() {
                    battleOption.winType = v;
                  });
                });
              },
            ),
          ],
        ),
        ValueCardRow(
          cards: [
            ValueCard(
              label: 'Each wave turns',
              value: battleOption.usedTurnArray.isEmpty ? 'empty' : battleOption.usedTurnArray.join(','),
              onTap: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Each wave turns',
                    initValue: battleOption.usedTurnArray.join(','),
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
            ),
            ValueCard(
              label: 'Action Logs',
              value: battleOption.actionLogs.isEmpty ? 'empty' : battleOption.actionLogs,
              onTap: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Action Logs',
                    initValue: battleOption.actionLogs,
                    onSubmit: (s) {
                      battleOption.actionLogs = s;
                      if (mounted) setState(() {});
                    },
                  ).showDialog(context);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget get uncommonSettingSection {
    final logicEventId = db.gameData.quests[battleOption.questId]?.logicEventId;
    return TileGroup(
      header: 'Other Options',
      children: [
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
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.supportEquipMaxLimitBreak,
          title: Text('${S.current.support_servant} - ${S.current.craft_essence_short} ${S.current.max_limit_break}'),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.supportEquipMaxLimitBreak = v;
              });
            });
          },
        ),
        CheckboxListTile.adaptive(
          dense: true,
          value: battleOption.useEventSupport,
          tristate: true,
          title: Text("${S.current.support_servant_short} - Use Event Support"),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Event ${logicEventId ?? 0}, ',
                  recognizer: logicEventId == null
                      ? null
                      : (TapGestureRecognizer()..onTap = () => router.push(url: Routes.eventI(logicEventId))),
                ),
                TextSpan(text: 'Supposed: ${db.gameData.others.isNeedUseEventQuestSupport(battleOption.questId)}'),
              ],
            ),
          ),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.useEventSupport = v;
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
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.checkQuestCondition,
          title: const Text("Check quest release condition"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.checkQuestCondition = v;
              });
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.customAliveUniqueId,
          title: const Text("Custom Alive UniqueIds"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.customAliveUniqueId = v;
              });
            });
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.enableSkillShift,
          title: const Text("Enable skillShift"),
          subtitle: Text('uniqueIds: ${battleOption.skillShiftEnemyUniqueIds}'),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.enableSkillShift = v;
              });
            });
          },
        ),
        ListTile(
          dense: true,
          title: const Text("Battle Mission Values"),
          subtitle: Text(
            battleOption.battleMissionValueDict.isEmpty
                ? 'empty'
                : battleOption.battleMissionValueDict.entries.map((e) => '${e.key}:${e.value}').join(', '),
          ),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () async {
            final questPhase =
                AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase, null, runtime.region) ??
                AtlasApi.questPhaseCache(battleOption.questId, battleOption.questPhase);
            if (questPhase == null) {
              EasyLoading.showToast('Quest phase cache not found, please set quest first');
              return;
            }
            await router.pushPage(
              BattleMissionValuePage(runtime: runtime, options: battleOption, questPhase: questPhase),
            );
            if (mounted) setState(() {});
          },
        ),
        SwitchListTile.adaptive(
          dense: true,
          value: battleOption.sendFriendRequest,
          title: const Text("Send Friend Request"),
          onChanged: (v) {
            runtime.lockTask(() {
              setState(() {
                battleOption.sendFriendRequest = v;
              });
            });
          },
        ),
        ValueCardRow(
          cards: [
            ValueCard(
              label: 'Battle Duration (s)',
              value: battleOption.battleDuration?.toString() ?? S.current.general_default,
              onTap: () {
                runtime.lockTask(() {
                  InputCancelOkDialog(
                    title: 'Battle Duration',
                    initValue: battleOption.battleDuration?.toString(),
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
            ),
          ],
        ),
      ],
    );
  }

  Widget get accountSettingSection {
    final fakerSettings = db.settings.fakerSettings;
    return TileGroup(
      header: 'Settings',
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
                  LocalNotificationUtil.plugin.cancel(id: notification.id);
                }
              }
              await AlarmX.stopAll();
            }
          },
        ),
        if (AlarmX.isSupported)
          SwitchListTile.adaptive(
            dense: true,
            value: fakerSettings.apRecoveredAlarm,
            title: const Text('AP Fully Recovered Alarm (Global)'),
            onChanged: (v) async {
              setState(() {
                fakerSettings.apRecoveredAlarm = v;
              });
              if (v) {
                await agent.network.setLocalNotification();
              } else {
                await AlarmX.stopAll();
              }
            },
          ),
        AddRemoveList<int>(
          inline: true,
          title: const Text('Notify when AP recovered at'),
          items: agent.user.recoveredAps.toList()..sort2((e) => e == 0 ? 999 : e),
          spacing: 4,
          runSpacing: 4,
          onAdd: () {
            InputCancelOkDialog.number(
              title: 'AP',
              helperText: '0 = Max AP (${(mstData.user ?? agent.user.userGame)?.actMax})',
              validate: (v) {
                return v >= 0 && v < 200 && v < Maths.max(ConstData.userLevel.values.map((e) => e.maxAp));
              },
              onSubmit: (v) {
                agent.user.recoveredAps.add(v);
                agent.network.setLocalNotification();
                if (mounted) setState(() {});
              },
            ).showDialog(context);
          },
          onRemove: (ap) {
            setState(() {
              agent.user.recoveredAps.remove(ap);
              agent.network.setLocalNotification(removedAps: [ap]);
            });
          },
          itemBuilder: (context, ap, handle) => GestureDetector(
            onTap: handle.tap,
            onLongPress: handle.longPress,
            child: Chip(
              label: Text(ap == 0 ? (agent.user.userGame?.actMax.toString() ?? 'Full') : ap.toString()),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
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
                              subtitle: Text(
                                [if (kDebugMode) 'id ${notification.id}', '${notification.body}'].join('\n'),
                              ),
                            ),
                        ], const Divider(height: 1)),
                      );
                    },
                  );
                },
                child: const Text('Notifications'),
              ),
              if (AlarmX.isSupported)
                TextButton(
                  onPressed: () async {
                    final alarms = await AlarmX.getAlarms();
                    if (alarms.isEmpty) {
                      EasyLoading.showInfo('No alarm');
                      return;
                    }
                    alarms.sort2((e) => e.id);
                    router.showDialog(
                      builder: (context) {
                        return SimpleDialog(
                          title: Text('${alarms.length} Alarms'),
                          children: divideList([
                            for (final alarm in alarms)
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                title: Text(alarm.notificationSettings.title),
                                subtitle: Text(
                                  [if (kDebugMode) 'id ${alarm.id}', alarm.notificationSettings.body].join('\n'),
                                ),
                              ),
                          ], const Divider(height: 1)),
                        );
                      },
                    );
                  },
                  child: const Text('Alarms'),
                ),
            ],
          ),
        ),
        const Divider(),
        AddRemoveList<int>(
          inline: true,
          title: const Text('Limited-Time Shop hints'),
          items: agent.user.shopTargetIds.toList(),
          spacing: 4,
          runSpacing: 4,
          onAdd: () {
            if (runtime.runningTask.value) return;
            InputCancelOkDialog.number(
              title: 'Item id or Card id',
              onSubmit: (targetId) {
                if (!db.gameData.entities.containsKey(targetId) &&
                    !db.gameData.commandCodesById.containsKey(targetId) &&
                    !db.gameData.items.containsKey(targetId) &&
                    !runtime.gameData.teapots.containsKey(targetId)) {
                  EasyLoading.showError("Invalid item id or card id");
                  return;
                }
                runtime.lockTask(() {
                  agent.user.shopTargetIds.add(targetId);
                  if (mounted) setState(() {});
                });
              },
            ).showDialog(context);
          },
          onRemove: (targetId) {
            runtime.lockTask(() {
              agent.user.shopTargetIds.remove(targetId);
              if (mounted) setState(() {});
            });
          },
          itemBuilder: (context, targetId, handle) => GestureDetector(
            onLongPress: handle.longPress,
            // No secondary action here, so let the card fall back to opening
            // the item's detail page on tap.
            child: GameCardMixin.anyCardItemBuilder(context: context, id: targetId, width: 36),
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
              InputCancelOkDialog.number(
                title: 'Max refresh count of Support list',
                initValue: fakerSettings.maxFollowerListRetryCount,
                keyboardType: TextInputType.number,
                validate: (v) => v > 0,
                onSubmit: (v) {
                  fakerSettings.maxFollowerListRetryCount = v;
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
        SwitchListTile.adaptive(
          dense: true,
          value: fakerSettings.animateProgressIndicator,
          title: const Text('Animated circle progress indicator'),
          onChanged: (v) async {
            setState(() {
              fakerSettings.animateProgressIndicator = v;
            });
          },
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
            onPressed: runtime.runningTask.value
                ? null
                : () {
                    router.pushPage(
                      DumpRespCleanPage(fakerBaseDir: agent.network.fakerBaseDir, fakerDir: agent.network.fakerDir),
                    );
                  },
            child: const Text('Clear dumps'),
          ),
        ),
      ],
    );
  }

  Widget get buttonBar {
    final bool loggedIn = mstData.isLoggedIn, inBattle = runtime.agentData.curBattle != null;

    final List<Widget> tools = [
      buildCompactButton(
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
      if (inBattle)
        buildCompactButton(
          enabled: loggedIn,
          onPressed: () async {
            runtime.runTask(() async {
              final battleEntity = runtime.agentData.curBattle!;
              await runtime.battle.battleResultWithOptions(
                battleEntity: battleEntity,
                resultType: battleOption.resultType,
                options: battleOption,
              );
            });
          },
          text: 'b.result',
        )
      else
        buildCompactButton(
          enabled: loggedIn,
          onPressed: () async {
            runtime.runTask(() => runtime.battle.battleSetupWithOptions(battleOption));
          },
          text: 'b.setup',
        ),
      buildCompactButton(
        onPressed: () async {
          if (agent.user.lastRequestOptions?.success == false) {
            final confirm = await SimpleConfirmDialog(
              title: Text(S.current.warning),
              content: Text("Last request not sent, still login?", style: TextStyle(color: Colors.red)),
            ).showDialog(context);
            if (confirm != true) return;
          }
          if (mounted) {
            await SimpleConfirmDialog(title: const Text('Login'), onTapOk: _startLogin).showDialog(context);
          }
        },
        text: 'login',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    ];

    final List<Widget> primary = [
      buildCompactButton(onPressed: () => agent.network.stopFlag = true, text: 'Stop'),
      FilledButton(
        onPressed: loggedIn && !inBattle
            ? () {
                InputCancelOkDialog.number(
                  title: 'Start Looping Battle',
                  autofocus: battleOption.loopCount <= 0,
                  initValue: battleOption.loopCount == 0 ? 1 : battleOption.loopCount,
                  validate: (v) => v > 0,
                  onSubmit: (v) {
                    battleOption.loopCount = v;
                    runtime.runTask(() => runtime.withWakeLock('loop-$hashCode', runtime.battle.startLoop));
                  },
                ).showDialog(context);
              }
            : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(96, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text([if (battleOption.useCampaignItem) '🫖', 'Loop ×${battleOption.loopCount}'].join('')),
      ),
      PopupMenuButton(
        itemBuilder: (context) => <PopupMenuEntry>[
          // Connection and AP resources
          PopupMenuItem(
            onTap: () {
              runtime.runTask(agent.gamedataTop);
            },
            child: const Text('gamedata'),
          ),
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
              _recoverAp();
            },
            child: const Text('recover'),
          ),
          const PopupMenuDivider(),
          // Single battle steps
          PopupMenuItem(
            enabled: loggedIn,
            onTap: () async {
              InputCancelOkDialog.number(
                title: 'Seed Count (waiting)',
                validate: (v) => v > 0,
                onSubmit: (v) {
                  runtime.runTask(() => runtime.withWakeLock('seed-wait-$hashCode', () => runtime.battle.seedWait(v)));
                },
              ).showDialog(context);
            },
            child: const Text('Seed-wait'),
          ),
          PopupMenuItem(
            enabled: !runtime.runningTask.value && inBattle,
            onTap: () async {
              runtime.runTask(() async {
                runtime.agentData.curBattle = null;
              });
            },
            child: const Text('Clear Battle'),
          ),
          const PopupMenuDivider(),
          // Destructive actions
          PopupMenuItem(
            child: const Text('Break'),
            onTap: () {
              if (mounted) {
                runtime.runningTask.value = false;
                agent.network.breakAndClearTask();
              }
            },
          ),
          PopupMenuItem(
            child: const Text('Stop Loop'),
            onTap: () {
              if (mounted) {
                runtime.battle.stopLoopFlag = true;
              }
            },
          ),
          const PopupMenuDivider(),
          // Diagnostics and debug
          if (agent is FakerAgentJP)
            PopupMenuItem(
              child: const Text('SessionId'),
              onTap: () {
                InputCancelOkDialog(
                  title: 'SessionId (${agent.network.gameTop.region.upper})',
                  initValue: agent.network.cookies['SessionId'],
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
                  initValue: (agent as FakerAgentCN).usk,
                  onSubmit: (s) {
                    if (s.trim().isEmpty) return;
                    (agent as FakerAgentCN).usk = CryptData.encryptMD5Usk(s);
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
            ),
          if (kDebugMode) PopupMenuItem(onTap: _testFunc, child: const Text('Test')),
        ],
      ),
    ];

    final message = ValueListenableBuilder(
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
            SimpleConfirmDialog(
              title: Text('Message'),
              scrollable: true,
              showCancel: false,
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
    );

    // The tool row only holds pre-battle actions, so it folds away while a task
    // runs and leaves the control row next to the thumb.
    return ValueListenableBuilder<bool>(
      valueListenable: runtime.runningTask,
      builder: (context, running, _) => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: FakerActionBar(groups: [if (!running) tools, primary], message: message),
      ),
    );
  }

  Future<void> _recoverAp() async {
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
  }

  String? _hideEventDeck;
  List<Widget> getUserDeckSection(Quest? quest, QuestPhase? questPhase) {
    final formation = mstData.userDeck[battleOption.deckId];
    final normalDeckTile = ListTile(
      dense: true,
      title: Text("Deck ${battleOption.deckId}"),
      subtitle: formation == null ? const Text("Unknown deck") : Text('${formation.deckNo} - ${formation.name}'),
      trailing: const Icon(Icons.change_circle),
      onTap: mstData.userDeck.isEmpty
          ? null
          : () {
              router.pushPage(
                UserDeckListPage(
                  runtime: runtime,
                  mstData: mstData,
                  activeDeckId: battleOption.deckId,
                  onSelected: (v) {
                    runtime.lockTask(() {
                      battleOption.deckId = v.id;
                    });
                    if (mounted) setState(() {});
                  },
                  enableEdit: true,
                ),
              );
            },
    );

    if ((questPhase ?? quest)?.isUseUserEventDeck() != true) {
      return [kIndentDivider, normalDeckTile, ..._buildUserDeck(formation?.deckInfo, questPhase)];
    }

    final eventId = quest?.logicEventId ?? 0;
    final eventDeckNo = questPhase?.extraDetail?.useEventDeckNo ?? 1;
    final eventFormation = mstData.userEventDeck[UserEventDeckEntity.createPK(eventId, eventDeckNo)];
    final eventDeckTile = ListTile(
      dense: true,
      title: Text("Event Deck ${eventFormation?.deckNo ?? eventDeckNo}"),
      subtitle: Text('Event ${eventFormation?.eventId ?? eventId}'),
      trailing: const Icon(Icons.change_circle),
      onTap: mstData.userEventDeck.isEmpty
          ? null
          : () {
              router.pushPage(
                UserDeckListPage(
                  runtime: runtime,
                  mstData: mstData,
                  eventDeckParam: (
                    eventId: eventId,
                    deckNo: eventDeckNo,
                    questId: battleOption.questId,
                    phase: battleOption.questPhase,
                    questPhase: questPhase,
                  ),
                  enableEdit: true,
                ),
              );
            },
    );
    final eventDeckKey = '$eventId-$eventDeckNo';
    final showNormalDeck = _hideEventDeck == eventDeckKey;
    final highlightStyle = TextStyle(color: Theme.of(context).colorScheme.primary);
    return [
      DividerWithTitle(
        titleWidget: InkWell(
          onTap: () {
            setState(() {
              if (showNormalDeck) {
                _hideEventDeck = null;
              } else {
                _hideEventDeck = eventDeckKey;
              }
            });
          },
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Event Deck', style: showNormalDeck ? null : highlightStyle),
                TextSpan(text: ' / '),
                TextSpan(text: 'Normal Deck', style: showNormalDeck ? highlightStyle : null),
              ],
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
      showNormalDeck ? normalDeckTile : eventDeckTile,
      ..._buildUserDeck((showNormalDeck ? formation : eventFormation)?.deckInfo, questPhase),
    ];
  }

  List<Widget> _buildUserDeck(DeckServantEntity? deckInfo, QuestPhase? questPhase) {
    const int kSvtNumPerRow = 6;
    final svts = deckInfo?.svts ?? [];
    final svtsMap = {for (final svt in svts) svt.id: svt};

    List<Widget> children = [];
    for (int row = 0; row < max(1, (svts.length / kSvtNumPerRow).ceil()); row++) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FormationCard(
            formation: BattleTeamFormationX.fromUserDeck(
              deckInfo: deckInfo,
              mstData: mstData,
              posOffset: row * kSvtNumPerRow,
              questPhase: questPhase,
            ),
            userSvtCollections: mstData.userSvtCollection.lookup,
            questPhase: questPhase,
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
            final oldCollection = runtime.agentData.lastBattleWinResultData?.oldUserSvtCollection.firstWhereOrNull(
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
                    value: bondData.elapsed,
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
            constraints: const BoxConstraints(maxWidth: FormationCard.kContentWidth),
            child: bondDetail,
          ),
        ),
      );
    }
    return children;
  }

  Future<void> _testFunc() async {
    if (mounted) setState(() {});
  }

  Future<void> _startLogin() async {
    return runtime.runTask(() async {
      final loginResp = await agent.loginTop();
      await agent.homeTop();
      final jsonData = loginResp.data.rawMap;
      final friendCode = mstData.user?.friendCode;
      if (jsonData != null && friendCode != null) {
        for (final user in db.userData.users) {
          if (user.lastImportId == friendCode) {
            final fp = File(joinPaths(db.paths.userDir, 'sniff', user.id));
            await fp.parent.create(recursive: true);
            await fp.writeAsString(jsonEncode(jsonData));
          }
        }
      }
    });
  }
}

/// Pins only the tab bar once scrolled: [maxExtent] also shows the account row
/// and the item row, [minExtent] leaves them to the app bar title.
class _StatusHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StatusHeaderDelegate({required this.row, required this.items, required this.tabBar, required this.onProgress});

  static const double kRowHeight = 56;
  static const double kItemsHeight = 28;
  static const double kTabHeight = 32;

  final Widget row;
  final Widget items;
  final Widget tabBar;
  final ValueChanged<double> onProgress;

  double _progress = -1;

  double get _collapsible => kRowHeight + kItemsHeight;

  @override
  double get maxExtent => _collapsible + kTabHeight;

  @override
  double get minExtent => kTabHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / _collapsible).clamp(0.0, 1.0);
    final fading = 1 - progress;
    final colors = Theme.of(context).colorScheme;
    if (progress != _progress) {
      _progress = progress;
      onProgress(progress);
    }
    return Material(
      color: colors.surfaceContainer,
      child: SizedBox(
        height: maxExtent - shrinkOffset,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, height: kRowHeight, child: row),
              if (progress < 1)
                Positioned(
                  top: kRowHeight,
                  left: 0,
                  right: 0,
                  height: kItemsHeight,
                  child: Opacity(opacity: fading, child: items),
                ),
              Positioned(
                top: _collapsible * fading,
                left: 0,
                right: 0,
                height: kTabHeight,
                child: Material(color: colors.surface, child: tabBar),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StatusHeaderDelegate oldDelegate) => true;
}
