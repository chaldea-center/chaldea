import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'simulation/battle_log.dart';
import 'simulation/combat_action_selector.dart';
import 'simulation/custom_skill_activator.dart';
import 'simulation/recorder.dart';
import 'simulation/svt_detail.dart';

class BattleSimulationPage extends StatefulWidget {
  final QuestPhase questPhase;
  final BattleOptions options;

  BattleSimulationPage({
    super.key,
    required this.questPhase,
    required this.options,
  });

  @override
  State<BattleSimulationPage> createState() => _BattleSimulationPageState();
}

class _BattleSimulationPageState extends State<BattleSimulationPage> {
  final BattleData battleData = BattleData();

  BattleOptionsRuntime get options => battleData.options;

  @override
  void initState() {
    super.initState();

    battleData
      ..options = widget.options.copy()
      ..context = context;

    _initBattle();
  }

  Future<void> _initBattle() async {
    await battleData.recordError(
      save: false,
      action: 'battle_init',
      task: () => battleData.init(
        widget.questPhase,
        [...widget.options.onFieldSvtDataList, ...widget.options.backupSvtDataList],
        widget.options.mysticCodeData,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(widget.questPhase.lName.l, maxLines: 1),
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
    List<PopupMenuEntry> items = [
      PopupMenuItem(
        enabled: battleData.niceQuest != null,
        onTap: () async {
          await null;
          battleData.niceQuest?.routeTo();
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
        child: Text('${S.current.command_spell}: ${Transl.skillNames('宝具解放').l}'),
        onTap: () async {
          await null;
          await battleData.commandSpellReleaseNP();
          if (mounted) setState(() {});
        },
      ),
      PopupMenuItem(
        child: Text('${S.current.command_spell}: ${Transl.skillNames('霊基修復').l}'),
        onTap: () async {
          await null;
          await battleData.commandSpellRepairHp();
          if (mounted) setState(() {});
        },
      ),
      PopupMenuItem(
        child: Text(S.current.battle_charge_party),
        onTap: () async {
          await null;
          battleData.chargeAllyNP();
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
        BattleRecorderPanel(battleData: battleData),
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
            overrideIcon: svt.niceSvt!.ascendIcon(svt.ascensionPhase, true),
          )
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
        svt.isPlayer
            ? svt.td == null
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
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: '${S.current.critical_star}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${battleData.criticalStars.toStringAsFixed(3)}  '),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButtonBar() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
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
                  final List<CombatAction?> combatActions = [null, null, null];
                  await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => showCommandCards(context, combatActions),
                  );
                  if (mounted) setState(() {});
                },
          child: battleData.isBattleWin
              ? Text('Win', style: TextStyle(color: Theme.of(context).colorScheme.secondary))
              : Text(S.current.battle_attack),
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
      textScaleFactor: 1,
    );
    if (isSealed && cd > 0) {
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
        if (isCondFailed && !isSealed && cd <= 0)
          const Text(
            '×',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: isSealed || isCondFailed || cd > 0 ? null : onTap,
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

  Widget showCommandCards(BuildContext context, List<CombatAction?> combatActions) {
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_card),
      contentPadding: const EdgeInsets.all(8),
      scrollable: true,
      content: CombatActionSelector(battleData: battleData, combatActions: combatActions),
      onTapOk: () async {
        final List<CombatAction> nonnullActions = [];
        for (final action in combatActions) {
          if (action != null) {
            nonnullActions.add(action);
          }
        }

        if (nonnullActions.isEmpty) {
          return;
        }

        await battleData.playerTurn(nonnullActions);
        if (mounted) setState(() {});
      },
    );
  }
}
