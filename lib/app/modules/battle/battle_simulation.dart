import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'details/battle_log.dart';

class BattleSimulationPage extends StatefulWidget {
  final QuestPhase questPhase;
  final List<PlayerSvtData> onFieldSvtDataList;
  final List<PlayerSvtData> backupSvtDataList;
  final MysticCodeData mysticCodeData;
  final int fixedRandom;
  final int probabilityThreshold;
  final bool isAfter7thAnni;

  BattleSimulationPage({
    super.key,
    required this.questPhase,
    required this.onFieldSvtDataList,
    required this.backupSvtDataList,
    required this.mysticCodeData,
    required this.fixedRandom,
    required this.probabilityThreshold,
    required this.isAfter7thAnni,
  });

  @override
  State<BattleSimulationPage> createState() => _BattleSimulationPageState();
}

class _BattleSimulationPageState extends State<BattleSimulationPage> {
  final BattleData battleData = BattleData();

  @override
  void initState() {
    super.initState();

    battleData
      ..probabilityThreshold = widget.probabilityThreshold
      ..fixedRandom = widget.fixedRandom
      ..isAfter7thAnni = widget.isAfter7thAnni
      ..context = context;

    _initBattle();
  }

  Future<void> _initBattle() async {
    await battleData.init(
        widget.questPhase, [...widget.onFieldSvtDataList, ...widget.backupSvtDataList], widget.mysticCodeData);
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
          Expanded(child: buildSvts()),
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
        child: Text(S.current.battle_battle_log),
        onTap: () async {
          await null;
          router.pushPage(BattleLogPage(logger: battleData.logger));
        },
      ),
      PopupMenuItem(
        child: Text(S.current.battle_charge_party),
        onTap: () {
          battleData.chargeAllyNP();
          if (mounted) setState(() {});
        },
      ),
      const PopupMenuItem(enabled: false, child: Text('Custom Skill')),
    ];
    return items;
  }

  Widget buildSvts() {
    List<Widget> allies = [
      for (int index = 0; index < max(3, battleData.onFieldAllyServants.length); index++)
        buildBattleSvtData(battleData.onFieldAllyServants.getOrNull(index), index)
    ];
    List<Widget> enemies = [
      for (int index = 0; index < max(3, (battleData.onFieldEnemies.length / 3).ceil()); index++)
        buildBattleSvtData(battleData.onFieldEnemies.getOrNull(index), index)
    ];

    Widget allyParty, enemyParty;
    allyParty = ResponsiveLayout(children: [
      for (final svt in allies) Responsive(small: 4, child: svt),
    ]);
    enemyParty = ResponsiveLayout(children: [
      for (final enemy in enemies) Responsive(small: 4, child: enemy),
    ]);

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
      ],
    );
  }

  Widget buildBattleSvtData(final BattleServantData? svt, final int index) {
    if (svt == null) {
      return const SizedBox.shrink();
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
                child: db.getIconImage(svt.svtClass.icon(svt.rarity), width: 20),
              ),
            ],
          );
    children.add(InkWell(
      child: iconImage,
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            return SimpleCancelOkDialog(
              title: Text(S.current.battle_buff_details),
              contentPadding: const EdgeInsets.all(8),
              content: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: divideTiles([
                    for (final buff in svt.battleBuff.allBuffs)
                      ListTile(
                        horizontalTitleGap: 5,
                        minVerticalPadding: 0,
                        leading: buildBuffIcon(buff),
                        title: Text(buff.effectString()),
                        trailing: Text(buff.durationString()),
                      )
                  ]),
                ),
              ),
              hideCancel: true,
            );
          },
        );
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
                canUseSkill: battleData.canUseSvtSkillIgnoreCoolDown(index, skillIndex),
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
            ? 'NP: ${(svt.np / 100).toStringAsFixed(2)}'
            : '${S.current.info_charge}: ${svt.npLineCount}/${svt.niceEnemy!.chargeTurn}',
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
                        canUseSkill: battleData.canUseMysticCodeSkillIgnoreCoolDown(i),
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
              ServantOptionEditPage.buildSlider(
                leadingText: S.current.battle_probability_threshold,
                min: 0,
                max: 10,
                value: battleData.probabilityThreshold ~/ 100,
                label: '${battleData.probabilityThreshold ~/ 10}',
                onChange: (v) {
                  battleData.probabilityThreshold = v.round() * 100;
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
              Text.rich(TextSpan(
                children: [
                  TextSpan(text: '${S.current.quest_fields}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    children: SharedBuilder.traitSpans(
                      context: context,
                      traits: battleData.getFieldTraits(),
                      format: (trait) => trait.shownName().split(':').skip(1).join(':'),
                    ),
                  )
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
            battleData.undo();
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
            battleData.tailoredExecution = !battleData.tailoredExecution;
            EasyLoading.showToast(
                '${S.current.battle_tailored_execution}: ${battleData.tailoredExecution ? 'On' : 'Off'}');
            if (mounted) setState(() {});
          },
          icon: Icon(
            battleData.tailoredExecution ? Icons.casino : Icons.casino_outlined,
            color: battleData.tailoredExecution ? Colors.red : Colors.grey,
          ),
          tooltip: S.current.battle_tailored_execution,
          iconSize: 24,
          constraints: const BoxConstraints(),
        ),
        FilledButton(
          onPressed: () {
            showDialog(context: context, useRootNavigator: false, builder: showCommandCards);
          },
          child: Text(S.current.battle_attack),
        )
      ],
    );
  }

  Widget buildSkillInfo({
    required final BattleSkillInfoData skillInfo,
    required bool canUseSkill,
    required final VoidCallback onTap,
  }) {
    final cd = skillInfo.chargeTurn;
    final _canUseSkill = canUseSkill && cd <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: _canUseSkill ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            db.getIconImage(skillInfo.proximateSkill?.icon ?? Atlas.common.emptySkillIcon, width: 24, aspectRatio: 1),
            if (!_canUseSkill) ...[
              Container(
                width: 24,
                height: 24,
                color: Colors.black54,
                child: Center(
                  child: Text(
                    !canUseSkill ? '×' : cd.toString(),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textScaleFactor: 1,
                  ),
                ),
              ),
            ],
          ],
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

  Widget showCommandCards(BuildContext context) {
    final List<CombatAction?> combatActions = [null, null, null];
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

class CombatActionSelector extends StatefulWidget {
  final BattleData battleData;
  final List<CombatAction?> combatActions;

  CombatActionSelector({super.key, required this.battleData, required this.combatActions});

  @override
  State<CombatActionSelector> createState() => _CombatActionSelectorState();
}

class _CombatActionSelectorState extends State<CombatActionSelector> {
  BattleData get battleData => widget.battleData;

  final double cardWidth = 48;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Row(
        children: [
          SizedBox(
            width: cardWidth,
            child: Text(
              S.current.np_short,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              S.current.battle_command_card,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      )
    ];
    for (final svt in battleData.nonnullAllies) {
      final tdIcon = buildTdIcon(svt);
      final cards = svt.getCards(battleData);
      List<Widget> cells = [tdIcon];
      for (int index = 0; index < max(5, cards.length); index++) {
        final card = cards.getOrNull(index);
        if (card == null) {
          cells.add(const Flexible(child: SizedBox.shrink()));
        } else {
          cells.add(Flexible(child: buildCardIcon(svt, card, index)));
        }
      }
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: cells,
      ));
    }
    children.add(ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ServantOptionEditPage.buildSlider(
        padding: EdgeInsets.zero,
        leadingText: S.current.battle_random,
        min: ConstData.constants.attackRateRandomMin,
        max: ConstData.constants.attackRateRandomMax - 1,
        value: battleData.fixedRandom,
        label: toModifier(battleData.fixedRandom).toStringAsFixed(3),
        onChange: (v) {
          battleData.fixedRandom = v.round();
          if (mounted) setState(() {});
        },
      ),
    ));
    children.add(Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CheckboxWithLabel(
          value: battleData.isAfter7thAnni,
          label: Text('${S.current.battle_after_7th} (QAB Chain)'),
          onChanged: (v) {
            setState(() {
              battleData.isAfter7thAnni = v!;
            });
          },
        ),
      ],
    ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget buildCardIcon(BattleServantData svt, CommandCardData card, int cardId) {
    final commandCode = svt.playerSvtData?.commandCodes[cardId];
    Widget cardIcon = Stack(
      alignment: Alignment.center,
      children: [
        CommandCardWidget(card: card.cardType, width: cardWidth),
        if (commandCode != null)
          Positioned(
            top: 0,
            right: 0,
            child: commandCode.iconBuilder(
              context: context,
              width: cardWidth * 0.5,
              jumpToDetail: false,
              overrideIcon: commandCode.icon,
            ),
          ),
        if (card.cardStrengthen != 0)
          Positioned(
            bottom: 5,
            right: 8,
            child: ImageWithText.paintOutline(
              text: card.cardStrengthen.toString(),
              textStyle: TextStyle(fontSize: cardWidth * 0.25, color: Colors.white),
              shadowColor: Colors.grey.shade700,
              shadowSize: 3,
            ),
          ),
        if (!svt.canCommandCard(battleData)) ...[
          Container(
            width: cardWidth,
            height: cardWidth,
            color: Colors.black54,
          ),
          Text('×', style: TextStyle(fontSize: cardWidth * 0.8, color: Colors.white))
        ]
      ],
    );
    cardIcon = GestureDetector(
      onTap: () {
        final cardIndex = getCardIndex(svt, card, widget.combatActions);
        if (cardIndex != -1) {
          final combatAction = widget.combatActions[cardIndex];
          if (combatAction!.cardData.isCritical) {
            widget.combatActions[cardIndex] = null;
          } else {
            combatAction.cardData.isCritical = true;
          }
        } else {
          final nextIndex = widget.combatActions.indexOf(null);
          if (nextIndex == -1) {
            return;
          }
          widget.combatActions[nextIndex] = CombatAction(svt, card);
        }
        if (mounted) setState(() {});
      },
      child: cardIcon,
    );
    final attackIndex = getCardIndex(svt, card, widget.combatActions);
    final isCritical = widget.combatActions.getOrNull(attackIndex)?.cardData.isCritical ?? false;
    cardIcon = wrapAttackIndex(cardIcon, attackIndex, isCritical);
    return cardIcon;
  }

  Widget buildTdIcon(BattleServantData svt) {
    final curTd = svt.getCurrentNP(battleData);
    final tdValid = svt.canSelectNP(battleData);
    Widget tdIcon = svt.niceSvt!.iconBuilder(
      context: context,
      // width: tdWidth,
      height: cardWidth,
      overrideIcon: svt.niceSvt!.ascendIcon(svt.ascensionPhase, true),
      jumpToDetail: false,
    );
    tdIcon = Stack(
      alignment: Alignment.center,
      children: [
        tdIcon,
        if (curTd?.card.isQAB == true) ...[
          Positioned(
            bottom: 0,
            child: Image.asset(
              'res/assets/card_icon_${curTd?.card.name}.png',
              width: cardWidth * 0.8,
            ),
          ),
          Positioned(
            bottom: cardWidth * 0.5 * 0.2,
            child: Image.asset(
              'res/assets/card_txt_${curTd?.card.name}.png',
              width: cardWidth * 0.8,
            ),
          ),
        ],
        if (!tdValid) ...[
          Container(
            width: cardWidth,
            height: cardWidth * 144 / 132,
            color: Colors.black54,
          ),
          Text('×', style: TextStyle(fontSize: cardWidth * 0.8, color: Colors.white))
        ]
      ],
    );
    tdIcon = GestureDetector(
      onTap: () {
        if (!svt.canSelectNP(battleData)) {
          return;
        }

        final npIndex = getNpCardIndex(svt, widget.combatActions);
        if (npIndex != -1) {
          widget.combatActions[npIndex] = null;
          if (mounted) setState(() {});
        } else {
          final nextIndex = widget.combatActions.indexOf(null);
          if (nextIndex == -1) {
            return;
          }

          widget.combatActions[nextIndex] = CombatAction(svt, svt.getNPCard(battleData)!);
          if (mounted) setState(() {});
        }
      },
      child: tdIcon,
    );
    tdIcon = wrapAttackIndex(tdIcon, getNpCardIndex(svt, widget.combatActions), false);
    return tdIcon;
  }

  Widget wrapAttackIndex(Widget child, int? index, bool isCritical) {
    String text = '';
    if (index != null && index >= 0) {
      text = {
            1: '1st',
            2: '2nd',
            3: '3rd',
          }[index + 1] ??
          '${index + 1}th';
      if (isCritical) {
        // text += ' ${S.current.critical_attack}';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(
          height: 20,
          child: Text(
            text,
            style: isCritical ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
            textScaleFactor: 0.8,
            maxLines: 1,
          ),
        )
      ],
    );
  }

  int getNpCardIndex(final BattleServantData svt, final List<CombatAction?> combatActions) {
    return combatActions
        .map((action) => action != null && action.cardData.isNP ? action.actor : null)
        .toList()
        .indexOf(svt);
  }

  int getCardIndex(
    final BattleServantData svt,
    final CommandCardData cardData,
    final List<CombatAction?> combatActions,
  ) {
    return combatActions
        .map((action) => action != null && action.cardData.cardIndex == cardData.cardIndex && !action.cardData.isNP
            ? action.actor
            : null)
        .toList()
        .indexOf(svt);
  }
}
