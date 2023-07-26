import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/chaldea.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/interactions/_delegate.dart';
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
  final BattleActions? replayActions;

  BattleSimulationPage({
    super.key,
    required this.questPhase,
    required this.region,
    required this.options,
    this.replayActions,
  });

  @override
  State<BattleSimulationPage> createState() => _BattleSimulationPageState();
}

class _BattleSimulationPageState extends State<BattleSimulationPage> {
  final BattleData battleData = BattleData();

  QuestPhase get questPhase => widget.questPhase;

  BattleOptionsRuntime get options => battleData.options;

  @override
  void initState() {
    super.initState();

    battleData
      ..options = widget.options.copy()
      ..context = context;

    battleData.recorder.determineUploadEligibility(questPhase, widget.options);

    _initBattle();
  }

  Future<void> _initBattle() async {
    await battleData.recordError(
      save: false,
      action: 'battle_init',
      task: () => battleData.init(
        questPhase,
        [...widget.options.team.onFieldSvtDataList, ...widget.options.team.backupSvtDataList],
        widget.options.team.mysticCodeData,
      ),
    );

    final replayActions = widget.replayActions;
    if (replayActions != null) {
      battleData.delegate = BattleReplayDelegate(replayActions.delegate);
      for (final action in replayActions.actions) {
        await action.replay(battleData);
      }
      battleData.delegate = null;
      battleData.recorder.isUploadEligible = false;
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
        onTap: () async {
          await null;
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
        onTap: () async {
          await null;
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
          await null;
          await battleData.commandSpellReleaseNP();
          if (mounted) setState(() {});
        },
      ),
      PopupMenuItem(
        child: Text(Transl.skillNames('霊基修復').l),
        onTap: () async {
          await null;
          await battleData.commandSpellRepairHp();
          if (mounted) setState(() {});
        },
      ),
      // PopupMenuItem(
      //   child: Text(S.current.battle_charge_party),
      //   onTap: () async {
      //     await null;
      //     battleData.chargeAllyNP();
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
        child: Text(S.current.reset_skill_cd),
        onTap: () async {
          await null;
          if (!mounted) return;
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              final ally = battleData.targetedAlly;
              return SimpleDialog(
                title: Text(S.current.reset_skill_cd),
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                    leading: ally?.iconBuilder(context: context, width: 36),
                    title: Text("${S.current.servant}: ${ally?.lBattleName}"),
                    enabled: ally != null,
                    onTap: () async {
                      Navigator.pop(context);
                      await battleData.resetPlayerSkillCD(false);
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
                      await battleData.resetPlayerSkillCD(true);
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              );
            },
          );
          if (mounted) setState(() {});
        },
      ),
      PopupMenuItem(
        child: Text(S.current.battle_activate_custom_skill),
        onTap: () async {
          await null;
          await router.pushPage(CustomSkillActivator(battleData: battleData));
          if (mounted) setState(() {});
        },
      ),
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

    Widget allyParty, enemyParty;
    allyParty = ResponsiveLayout(verticalAlign: CrossAxisAlignment.start, children: [
      for (final svt in allies) Responsive(small: 4, child: svt),
    ]);
    enemyParty = ResponsiveLayout(
      rowDirection: TextDirection.rtl,
      verticalDirection: VerticalDirection.up,
      verticalAlign: CrossAxisAlignment.start,
      children: [
        for (final enemy in enemies) Responsive(small: 4, child: enemy),
      ],
    );

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
          textScaleFactor: 0.9,
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
            team: widget.options.team,
            initShowTeam: widget.replayActions != null,
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
    void _onChangeIndex(int? v) {
      if (svt.isPlayer) {
        battleData.allyTargetIndex = v!;
      } else {
        battleData.enemyTargetIndex = v!;
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
                groupValue: svt.isPlayer ? battleData.allyTargetIndex : battleData.enemyTargetIndex,
                onChanged: _onChangeIndex,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
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
    final iconImage = svt.isPlayer
        ? svt.niceSvt!.iconBuilder(
            context: context,
            jumpToDetail: false,
            height: 72,
            overrideIcon: svt.niceSvt!.ascendIcon(svt.limitCount),
            option: ImageWithTextOption(
                errorWidget: (context, url, error) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon)))
        : Stack(
            children: [
              CachedImage(
                imageUrl: svt.niceEnemy?.icon,
                height: 72,
                aspectRatio: 1,
                cachedOption: CachedImageOption(
                    errorWidget: (ctx, _, __) => CachedImage(imageUrl: Atlas.common.unknownEnemyIcon)),
              ),
              Positioned(
                left: 2,
                top: 4,
                child: db.getIconImage(SvtClassX.clsIcon(svt.classId, svt.rarity), width: 20),
              ),
            ],
          );
    children.add(InkWell(
      child: iconImage,
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
        if (svt.isPlayer) 'ATK: ${svt.attack}',
        'HP: ${svt.hp}',
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
        for (final buff in svt.battleBuff.shownBuffs) WidgetSpan(child: buildBuffIcon(buff)),
      ]),
      maxLines: 1,
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
                          await battleData.activateMysticCodeSKill(i);
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
                value: options.probabilityThreshold ~/ 100,
                label: '${options.probabilityThreshold ~/ 10}',
                onChange: (v) {
                  options.probabilityThreshold = v.round() * 100;
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
                // textScaleFactor: 0.9,
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
            textScaleFactor: 0.8,
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
          onPressed: () {
            battleData.popSnapshot();
            EasyLoading.showToast(S.current.battle_undo, duration: const Duration(seconds: 1));
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
    if (widget.region != null && widget.region != Region.jp) {
      content = 'Only JP quest supports team sharing. (current: ${widget.region!.localName})';
    } else if (!db.security.isUserLoggedIn) {
      content = S.current.login_first_hint;
    } else if (!battleData.recorder.isUploadEligible) {
      content = S.current.upload_not_eligible_hint;
    } else if (db.runtimeData.secondsRemainUtilNextUpload > 0) {
      content =
          S.current.upload_paused(db.runtimeData.secondsBetweenUpload, db.runtimeData.secondsRemainUtilNextUpload);
    } else if (!questPhase.isLaplaceSharable) {
      content = S.current.quest_disallow_laplace_share_hint;
    } else {
      // okay
      canUpload = true;
      bool hasMultiDamageFunc = false;
      for (final record in battleData.recorder.records) {
        if (record is BattleAttackRecord) {
          final funcs = record.card?.td?.functions ?? [];
          if (funcs.where((func) => func.funcType.isDamageNp).length > 1) {
            hasMultiDamageFunc = true;
            break;
          }
        }
      }
      if (hasMultiDamageFunc) {
        content = '${S.current.laplace_upload_td_multi_dmg_func_hint}\n\n${S.current.upload_team_confirmation}';
      } else {
        content = S.current.upload_team_confirmation;
      }
    }

    return SimpleCancelOkDialog(
      scrollable: true,
      title: Text(S.current.upload),
      content: Text(content),
      hideOk: !canUpload,
      onTapOk: () async {
        final actions = BattleActions(
          actions: battleData.recorder.toUploadRecords(),
          delegate: battleData.replayDataRecord,
        );
        final uploadData = BattleShareData(
          appBuild: AppInfo.buildNumber,
          quest: BattleQuestInfo(
            id: questPhase.id,
            phase: questPhase.phase,
            hash: questPhase.enemyHash,
          ),
          team: widget.options.team.toFormationData(),
          actions: actions,
          disableEvent: widget.options.disableEvent,
        );
        final resp = await showEasyLoading(() => ChaldeaWorkerApi.laplaceUploadTeam(
              ver: BattleShareData.kDataVer,
              questId: questPhase.id,
              phase: questPhase.phase,
              enemyHash: questPhase.enemyHash!,
              record: uploadData.toDataV2(),
            ));
        if (resp.success) {
          db.runtimeData.lastUpload = DateTime.now().timestamp;
          ChaldeaWorkerApi.clearCache((cache) => true);
        }
        resp.showDialog();
      },
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
      textScaleFactor: 1,
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
        onTap: isSealed || isCondFailed || cd > 0 ? null : onTap,
        onLongPress: pskill == null
            ? null
            : () {
                SimpleCancelOkDialog(
                  title: Text(S.current.skill),
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

  Widget buildBuffIcon(final BuffData buff) {
    return DecoratedBox(
      decoration: buff.irremovable
          ? BoxDecoration(
              border: Border.all(color: Theme.of(context).hintColor),
              borderRadius: BorderRadius.circular(2),
            )
          : const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: db.getIconImage(buff.buff.icon, width: 16, height: 16),
      ),
    );
  }
}
