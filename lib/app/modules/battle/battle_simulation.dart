import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../descriptors/skill_descriptor.dart';
import '../quest/quest.dart';
import 'simulation/battle_log.dart';
import 'simulation/combat_action_selector.dart';
import 'simulation/custom_skill_activator.dart';
import 'simulation/recorder.dart';
import 'simulation/svt_detail.dart';

class BattleSimulationPage extends StatefulWidget {
  final QuestPhase questPhase;
  final Region? region;
  final BattleOptions options;
  final BattleShareData? replayActions;
  final int? replayTeamId;

  BattleSimulationPage({
    super.key,
    required this.questPhase,
    required this.region,
    required this.options,
    this.replayActions,
    this.replayTeamId,
  });

  @override
  State<BattleSimulationPage> createState() => _BattleSimulationPageState();
}

class _BattleSimulationPageState extends State<BattleSimulationPage> {
  final BattleData battleData = BattleData();

  QuestPhase get questPhase => widget.questPhase;

  BattleOptionsRuntime get options => battleData.options;

  BattleShareData getShareData({bool allowNotWin = false}) {
    assert(battleData.isBattleWin || allowNotWin);
    return BattleShareData(
      appBuild: AppInfo.buildNumber,
      quest: BattleQuestInfo.quest(questPhase),
      formation: widget.options.formation.toFormationData(),
      delegate: battleData.replayDataRecord.copy(),
      actions: battleData.recorder.toUploadRecords(),
      options: widget.options.toShareData(),
    );
  }

  @override
  void initState() {
    super.initState();

    battleData
      ..options = widget.options.copy()
      ..context = context;
    battleData.options.manualAllySkillTarget = db.settings.battleSim.manualAllySkillTarget;

    battleData.recorder.determineUploadEligibility(questPhase, widget.options);

    _initBattle();
  }

  Future<void> _initBattle() async {
    await battleData.recordError(
      save: false,
      action: 'battle_init',
      task: () => battleData.init(
        questPhase,
        [...widget.options.formation.onFieldSvtDataList, ...widget.options.formation.backupSvtDataList],
        widget.options.formation.mysticCodeData,
      ),
    );

    final replayActions = widget.replayActions;
    if (replayActions != null) {
      await battleData.replay(replayActions);
      if (widget.replayTeamId != null && widget.replayTeamId != 0) {
        battleData.recorder.messageRich(BattleMessageRecord(
          'Team ${widget.replayTeamId}',
          alignment: Alignment.center,
          style: mounted
              ? const TextStyle(decoration: TextDecoration.underline).merge(Theme.of(context).textTheme.bodySmall)
              : null,
        ));
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(questPhase.lName.l, maxLines: 1),
        actions: [
          PopupMenuButton(itemBuilder: popupMenuItemBuilder),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: buildBody()),
          const SizedBox(height: 4),
          Material(
            elevation: 8,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ResponsiveLayout(
                      horizontalDivider: null,
                      verticalAlign: CrossAxisAlignment.center,
                      children: [
                        Responsive(
                          small: 12,
                          middle: 8,
                          child: buildMiscRow(),
                        ),
                        Responsive(
                          small: 12,
                          middle: 4,
                          child: buildButtonBar(),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry> popupMenuItemBuilder(BuildContext context) {
    List<PopupMenuEntry<dynamic>> items = [
      PopupMenuItem(
        onTap: () {
          router.push(
            url: Routes.questI(questPhase.id),
            child: QuestDetailPage.phase(questPhase: questPhase),
            detail: true,
          );
        },
        child: Text(S.current.quest),
      ),
      PopupMenuItem(
        child: Text(S.current.battle_battle_log),
        onTap: () {
          router.pushPage(BattleLogPage(logger: battleData.battleLogger));
        },
      ),
      PopupMenuItem(
        enabled: false,
        height: 16,
        padding: EdgeInsets.zero,
        child: DividerWithTitle(title: S.current.command_spell),
      ),
      PopupMenuItem(
        child: Text(Transl.skillNames('宝具解放').l),
        onTap: () async {
          await battleData.commandSpellReleaseNP();
          if (mounted) setState(() {});
        },
      ),
      PopupMenuItem(
        child: Text(Transl.skillNames('霊基修復').l),
        onTap: () async {
          await battleData.commandSpellRepairHp();
          if (mounted) setState(() {});
        },
      ),
      // PopupMenuItem(
      //   child: Text(S.current.battle_charge_party),
      //   onTap: () async {
      //     await battleData.chargeAllyNP();
      //     if (mounted) setState(() {});
      //   },
      // ),
      PopupMenuItem(
        enabled: false,
        height: 16,
        padding: EdgeInsets.zero,
        child: DividerWithTitle(title: S.current.custom_skill),
      ),
      PopupMenuItem(
        onTap: onResetSkillCD,
        child: Text(S.current.reset_skill_cd),
      ),
      PopupMenuItem(
        child: Text(S.current.battle_activate_custom_skill),
        onTap: () async {
          await router.pushPage(CustomSkillActivator(battleData: battleData));
          if (mounted) setState(() {});
        },
      ),
      if (AppInfo.isDebugOn) ...[
        PopupMenuItem(
          enabled: false,
          height: 16,
          padding: EdgeInsets.zero,
          child: DividerWithTitle(title: S.current.debug),
        ),
        PopupMenuItem(
          child: const Text('Share Data json'),
          onTap: () {
            copyToClipboard(jsonEncode(getShareData(allowNotWin: true)));
          },
        ),
        PopupMenuItem(
          child: const Text('Share Data gzip'),
          onTap: () {
            copyToClipboard(getShareData(allowNotWin: true).toDataV2());
          },
        ),
      ],
    ];
    return items;
  }

  Widget buildBody() {
    List<Widget> allies = [
      for (int index = 0; index < max(3, battleData.onFieldAllyServants.length); index++)
        buildBattleSvtData(battleData.onFieldAllyServants.getOrNull(index), index)
    ];
    List<Widget> enemies = [
      for (int index = 0; index < max(3, (battleData.onFieldEnemies.length / 3).ceil() * 3); index++)
        buildBattleSvtData(battleData.onFieldEnemies.getOrNull(index), index)
    ];

    Widget allyParty = ResponsiveLayout(verticalAlign: CrossAxisAlignment.start, children: [
      for (final svt in allies) Responsive(small: 4, child: svt),
    ]);
    Widget enemyParty = ResponsiveLayout(
      rowDirection: TextDirection.rtl,
      verticalDirection: VerticalDirection.up,
      verticalAlign: CrossAxisAlignment.start,
      children: [
        for (final enemy in enemies) Responsive(small: 4, child: enemy),
      ],
    );
    if (battleData.isBattleWin) {
      enemyParty = Stack(
        alignment: Alignment.center,
        children: [
          enemyParty,
          Positioned.fill(child: Container(color: Colors.grey.withOpacity(0.2))),
          Text(
            "Battle Win",
            style: TextStyle(
              fontSize: 36,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Text(
          '${S.current.quest_wave} ${battleData.waveCount}/${battleData.niceQuest!.stages.length}'
          '  ${S.current.battle_turn} ${battleData.totalTurnCount}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          '${S.current.battle_enemy_remaining} ${battleData.nonnullEnemies.length + battleData.nonnullBackupEnemies.length}',
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(0.9),
        ),
        const Divider(thickness: 1, height: 8),
        ResponsiveLayout(
          verticalAlign: CrossAxisAlignment.center,
          verticalDivider: const SizedBox(height: 120, child: VerticalDivider()),
          horizontalDivider: const DividerWithTitle(thickness: 1, height: 8, title: '楚河  漢界'),
          children: [
            Responsive(small: 12, middle: 6, child: enemyParty),
            Responsive(small: 12, middle: 6, child: allyParty),
          ],
        ),
        const Divider(thickness: 1, height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text.rich(TextSpan(
            children: [
              TextSpan(text: '${S.current.quest_fields}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                children: SharedBuilder.traitSpans(
                  context: context,
                  traits: battleData.getFieldTraits(),
                  format: (trait) {
                    final name = trait.shownName();
                    if (name.contains(':')) {
                      return name.split(':').skip(1).join(':');
                    }
                    return name;
                  },
                ),
              ),
              const TextSpan(text: ' '),
            ],
          )),
        ),
        const Divider(thickness: 1, height: 8),
        Center(
          child: BattleRecorderPanel(
            battleData: battleData,
            quest: questPhase,
            team: widget.options.formation,
            options: widget.options,
            initShowTeam: widget.replayActions != null,
            initShowQuest: widget.replayActions != null,
          ),
        )
      ],
    );
  }

  Widget buildBattleSvtData(final BattleServantData? svt, final int index) {
    if (svt == null) {
      Widget child = CachedImage(
        imageUrl: 'https://static.atlasacademy.io/JP/Enemys/0.png',
        height: 72,
        placeholder: (context, url) => const SizedBox.shrink(),
      );
      if (!Theme.of(context).isDarkMode) {
        // invert color
        child = ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            //R G  B  A  Const
            -1, 0, 0, 0, 255,
            0, -1, 0, 0, 255,
            0, 0, -1, 0, 255,
            0, 0, 0, 1, 0,
          ]),
          child: child,
        );
      }
      child = Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: child);
      return child;
    }

    final List<Widget> children = [];
    void _onChangeIndex(int? _) {
      if (svt.isPlayer) {
        if (battleData.playerTargetIndex != index) {
          battleData.playerTargetIndex = index;
          db.settings.battleSim.manualAllySkillTarget = battleData.options.manualAllySkillTarget = false;
        } else {
          db.settings.battleSim.manualAllySkillTarget =
              battleData.options.manualAllySkillTarget = !battleData.options.manualAllySkillTarget;
        }
      } else {
        battleData.enemyTargetIndex = index;
      }

      if (mounted) setState(() {});
    }

    children.add(InkWell(
      onTap: () => _onChangeIndex(index),
      child: Text.rich(
        TextSpan(
          children: [
            CenterWidgetSpan(
              child: Radio<int>(
                value: index,
                toggleable: svt.isPlayer,
                groupValue: svt.isPlayer
                    ? (options.manualAllySkillTarget && battleData.isPlayerTurn ? null : battleData.playerTargetIndex)
                    : battleData.enemyTargetIndex,
                onChanged: _onChangeIndex,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                fillColor: svt.isPlayer && options.manualAllySkillTarget && battleData.playerTargetIndex == index
                    ? MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                        // M2 style
                        final _theme = Theme.of(context);
                        if (states.contains(MaterialState.disabled)) {
                          return _theme.disabledColor;
                        }
                        if (states.contains(MaterialState.selected)) {
                          return _theme.colorScheme.secondary;
                        }
                        return _theme.colorScheme.secondary;
                      })
                    : null,
              ),
            ),
            TextSpan(text: svt.lBattleName.breakWord),
          ],
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
        // overflow: TextOverflow.fade,
      ),
    ));
    children.add(BattleSvtAvatar(
      svt: svt,
      size: 72,
      showHpBar: svt.isEnemy,
      onTap: () {
        router.pushPage(BattleSvtDetail(svt: svt, battleData: battleData));
      },
    ));
    if (svt.isPlayer) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int skillIndex = 0; skillIndex < svt.skillInfoList.length; skillIndex++)
            Flexible(
              child: buildSkillInfo(
                skillInfo: svt.skillInfoList[skillIndex],
                isSealed: battleData.isSkillSealed(index, skillIndex),
                isCondFailed: battleData.isSkillCondFailed(index, skillIndex),
                onTap: () async {
                  await battleData.activateSvtSkill(index, skillIndex);
                  if (mounted) setState(() {});
                },
              ),
            )
        ],
      ));
    }

    children.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <String>[
        if (svt.isPlayer) 'ATK: ${svt.atk}',
        'HP: ${svt.hp.format(compact: false, groupSeparator: ",")}',
        if (svt.isEnemy && svt.shiftNpcIds.isNotEmpty)
          List.generate(svt.shiftNpcIds.length, (index) => svt.shiftNpcIds.length - index > svt.shiftIndex ? '◆' : '◇')
              .join(),
        svt.isPlayer
            ? svt.playerSvtData!.td == null
                ? 'NP: -'
                : 'NP: ${(svt.np / 100).toStringAsFixed(2)}'
            : svt.niceEnemy!.chargeTurn != 0 && (svt.niceEnemy?.noblePhantasm.noblePhantasm?.functions.length ?? 0) > 0
                ? '${S.current.info_charge}: ${svt.npLineCount}/${svt.niceEnemy!.chargeTurn}'
                : '${S.current.info_charge}: -',
      ].map((e) => AutoSizeText(e, maxLines: 1, minFontSize: 6, style: Theme.of(context).textTheme.bodySmall)).toList(),
    ));

    children.add(Text.rich(
      TextSpan(children: [
        for (final buff in svt.battleBuff.shownBuffs) WidgetSpan(child: BattleBuffIcon(buff: buff, size: 16)),
      ]),
      maxLines: svt.isPlayer ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    ));

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget buildMiscRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        if (battleData.mysticCode != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Column(
              children: [
                battleData.mysticCode!.iconBuilder(context: context, height: 52, jumpToDetail: true),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < battleData.masterSkillInfo.length; i += 1)
                      buildSkillInfo(
                        skillInfo: battleData.masterSkillInfo[i],
                        isSealed: false,
                        isCondFailed: !battleData.canUseMysticCodeSkillIgnoreCoolDown(i),
                        onTap: () async {
                          await battleData.activateMysticCodeSkill(i);
                          if (mounted) setState(() {});
                        },
                      ),
                  ],
                )
              ],
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderWithTitle(
                leadingText: S.current.battle_probability_threshold,
                min: 0,
                max: 10,
                value: options.threshold ~/ 100,
                label: '${options.threshold ~/ 10}',
                onChange: (v) {
                  options.threshold = v.round() * 100;
                  if (mounted) setState(() {});
                },
                padding: EdgeInsets.zero,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${S.current.critical_star}: '),
                    TextSpan(text: '${battleData.criticalStars.toStringAsFixed(3)}  '),
                  ],
                ),
                // textScaler: const TextScaler.linear(0.9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButtonBar() {
    final normalButtons = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (battleData.options.simulateEnemy)
          Text.rich(
            TextSpan(
              children: divideList([
                for (final isPlayer in [false, true])
                  TextSpan(
                    text: isPlayer ? 'Player Turn' : 'Enemy Turn',
                    style: isPlayer == battleData.isPlayerTurn
                        ? TextStyle(color: Theme.of(context).colorScheme.secondary)
                        : Theme.of(context).textTheme.bodySmall,
                  )
              ], const TextSpan(text: '\n')),
            ),
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(0.8),
          ),
        IconButton(
          onPressed: () async {
            await battleData.skipTurn();
            battleData.recorder.setIllegal(S.current.skip_current_turn);
            EasyLoading.showToast(S.current.skip_current_turn);
            if (mounted) setState(() {});
          },
          icon: Icon(
            Icons.play_arrow,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: S.current.skip_current_turn,
          iconSize: 24,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () async {
            await battleData.skipWave();
            EasyLoading.showToast(S.current.battle_skip_current_wave);
            if (mounted) setState(() {});
          },
          icon: Icon(
            Icons.fast_forward,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: S.current.battle_skip_current_wave,
          iconSize: 24,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () async {
            await battleData.tryAcquire(() async {
              battleData.popSnapshot();
              EasyLoading.showToast(S.current.battle_undo, duration: const Duration(seconds: 1));
            });
            if (mounted) setState(() {});
          },
          icon: Icon(
            Icons.undo,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: S.current.battle_undo,
          iconSize: 24,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          onPressed: () {
            options.tailoredExecution = !options.tailoredExecution;
            EasyLoading.showToast(
                '${S.current.battle_tailored_execution}: ${options.tailoredExecution ? 'On' : 'Off'}');
            if (mounted) setState(() {});
          },
          icon: Icon(
            options.tailoredExecution ? Icons.casino : Icons.casino_outlined,
            color: options.tailoredExecution ? Colors.red : Colors.grey,
          ),
          tooltip: S.current.battle_tailored_execution,
          iconSize: 24,
          constraints: const BoxConstraints(),
        ),
        FilledButton(
          onPressed: battleData.isBattleWin
              ? null
              : () async {
                  if (battleData.isRunning) {
                    EasyLoading.showToast('Previous task is still running');
                    return;
                  }
                  await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: battleData.isPlayerTurn
                        ? (context) => CombatActionSelector(
                              battleData: battleData,
                              onSelected: (combatActions) async {
                                if (combatActions.isNotEmpty) {
                                  await battleData.playerTurn(combatActions);
                                }
                                if (mounted) setState(() {});
                              },
                            )
                        : (context) => EnemyCombatActionSelector(
                              battleData: battleData,
                              onConfirm: (task) async {
                                await task();
                                if (mounted) setState(() {});
                              },
                            ),
                  );
                  if (mounted) setState(() {});
                },
          child: battleData.isBattleWin
              ? Text('Win', style: TextStyle(color: Theme.of(context).colorScheme.secondary))
              : Text(S.current.battle_attack),
        ),
      ],
    );
    if (battleData.isBattleWin && widget.replayActions == null && questPhase.isLaplaceSharable) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => showDialog(context: context, useRootNavigator: false, builder: _buildUploadDialog),
            child: Text(S.current.upload),
          ),
          const SizedBox(height: 4),
          normalButtons,
        ],
      );
    } else {
      return normalButtons;
    }
  }

  Widget _buildUploadDialog(BuildContext context) {
    bool canUpload = false;
    String content;
    final reasons = battleData.recorder.illegalReasons.toSet();
    reasons.addAll(battleData.recorder.checkExtraIllegalReason(battleData.replayDataRecord));

    if (widget.region != null && widget.region != Region.jp) {
      content = 'Only JP quest supports team sharing. (current: ${widget.region!.localName})';
    } else if (!db.settings.secrets.isLoggedIn) {
      content = S.current.login_first_hint;
    } else if (reasons.isNotEmpty) {
      content = S.current.upload_not_eligible_hint;
      for (final reason in battleData.recorder.illegalReasons) {
        content += '\n- $reason';
      }
    } else if (db.runtimeData.secondsRemainUtilNextUpload > 0) {
      content =
          S.current.upload_paused(db.runtimeData.secondsBetweenUpload, db.runtimeData.secondsRemainUtilNextUpload);
    } else if (!questPhase.isLaplaceSharable) {
      content = S.current.quest_disallow_laplace_share_hint;
    } else {
      // okay
      canUpload = true;
      bool hasMultiDamageFunc = false;
      int attackCards = 0;
      int totalAttackCards = 0;
      for (final record in battleData.recorder.records) {
        if (record is BattleAttacksInitiationRecord) {
          totalAttackCards += record.attacks.where((e) => e.cardData.cardType != CardType.extra).length;
        } else if (record is BattleAttackRecord) {
          if ((record.card?.td?.dmgNpFuncCount ?? 0) > 1) {
            hasMultiDamageFunc = true;
          }
          if (record.card?.cardType != CardType.extra) {
            attackCards += 1;
          }
        }
      }

      content = '';
      if (totalAttackCards > attackCards) {
        content += '${S.current.card_not_attack_warning(totalAttackCards - attackCards, totalAttackCards)}\n\n';
      }
      if (hasMultiDamageFunc) {
        content = '${S.current.laplace_upload_td_multi_dmg_func_hint}\n\n';
      }
      content += S.current.upload_team_confirmation;
    }
    content += '\n\n${S.current.save}: ${S.current.team_local}'
        '\n${S.current.upload}: ${S.current.team_shared}';

    final teamData = getShareData();

    return SimpleCancelOkDialog(
      scrollable: true,
      title: Text(S.current.upload),
      content: Text(content, style: const TextStyle(fontSize: 14)),
      hideOk: !canUpload,
      confirmText: S.current.upload,
      onTapOk: () async {
        final insertedId = await showEasyLoading(() => ChaldeaWorkerApi.teamUpload(data: teamData));
        if (insertedId == null) return;
        db.runtimeData.lastUpload = DateTime.now().timestamp;
        ChaldeaWorkerApi.clearTeamCache();
        if (mounted) {
          SimpleCancelOkDialog(
            title: Text(S.current.success),
            content: Text("ID: $insertedId"),
            hideCancel: true,
          ).showDialog(this.context);
        }
      },
      actions: [
        if (canUpload)
          TextButton(
            onPressed: () {
              db.curUser.battleSim.teams.add(teamData);
              Navigator.pop(context);
              EasyLoading.showSuccess(
                  '${S.current.saved}: ${S.current.team_local} ${db.curUser.battleSim.teams.length}');
            },
            child: Text(S.current.save),
          )
      ],
    );
  }

  Widget buildSkillInfo({
    required final BattleSkillInfoData skillInfo,
    required bool isSealed,
    required bool isCondFailed,
    required final VoidCallback onTap,
  }) {
    final cd = skillInfo.chargeTurn;
    Widget cdText = Text(
      cd.toString(),
      style: TextStyle(fontSize: isSealed ? 14 : 18, color: Colors.white.withOpacity(0.8)),
      textScaler: const TextScaler.linear(1),
    );
    if ((isSealed && cd > 0) || (isCondFailed && !isSealed)) {
      cdText = Positioned(right: 0, bottom: 0, child: cdText);
    }

    Widget child = Stack(
      alignment: Alignment.center,
      children: [
        db.getIconImage(skillInfo.proximateSkill?.icon ?? Atlas.common.emptySkillIcon, width: 32, aspectRatio: 1),
        if (isSealed || isCondFailed || cd > 0)
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: 32,
              height: 32,
              color: Colors.black54,
            ),
          ),
        if (cd > 0) cdText,
        if (isSealed)
          Opacity(
            opacity: 0.8,
            child: db.getIconImage(
              'https://static.atlasacademy.io/JP/BuffIcons/bufficon_511.png',
              width: 18,
              aspectRatio: 1,
            ),
          ),
        if (isCondFailed && !isSealed)
          const Text(
            '×',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
      ],
    );

    final pskill = skillInfo.proximateSkill;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isSealed || isCondFailed || cd > 0
            ? null
            : () {
                if (battleData.isPlayerTurn) {
                  onTap();
                } else {
                  EasyLoading.showInfo("Enemy Turn");
                }
              },
        onLongPress: pskill == null
            ? null
            : () {
                SimpleCancelOkDialog(
                  title: Text('${S.current.skill} Lv.${skillInfo.skillLv}'),
                  content: DisableLayoutBuilder(
                    child: SkillDescriptor(
                      skill: pskill,
                      level: skillInfo.skillLv,
                    ),
                  ),
                  scrollable: true,
                  hideCancel: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ).showDialog(context);
              },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 32),
          child: child,
        ),
      ),
    );
  }

  void onResetSkillCD() {
    router.showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.current.reset_skill_cd),
          children: [
            for (final svt in battleData.nonnullPlayers)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: svt.iconBuilder(context: context, width: 36),
                title: Text("${S.current.servant}: ${svt.lBattleName}"),
                onTap: () async {
                  Navigator.pop(context);
                  await battleData.resetPlayerSkillCD(isMysticCode: false, svt: svt);
                  if (mounted) setState(() {});
                },
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: battleData.mysticCode?.iconBuilder(context: context, width: 36),
              title: Text(S.current.mystic_code),
              enabled: battleData.mysticCode != null,
              onTap: () async {
                Navigator.pop(context);
                await battleData.resetPlayerSkillCD(isMysticCode: true, svt: null);
                if (mounted) setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
