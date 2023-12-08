import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/battle/simulation/recorder.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class CombatActionSelector extends StatefulWidget {
  final BattleData battleData;
  final Function(List<CombatAction> actions) onSelected;

  CombatActionSelector({super.key, required this.battleData, required this.onSelected});

  @override
  State<CombatActionSelector> createState() => _CombatActionSelectorState();
}

class _CombatActionSelectorState extends State<CombatActionSelector> {
  BattleData get battleData => widget.battleData;

  final double cardSize = 48;

  final List<CombatAction?> combatActions = List.filled(3, null);

  @override
  Widget build(BuildContext context) {
    if (battleData.targetedEnemy == null || battleData.targetedPlayer == null) {
      return SimpleCancelOkDialog(
        title: Text(S.current.warning),
        content: Text(S.current.battle_targeted_required_hint),
        hideCancel: true,
      );
    }
    final validActions = combatActions.whereType<CombatAction>().toList();
    return SimpleCancelOkDialog(
      title: Text(S.current.battle_select_card),
      contentPadding: const EdgeInsets.all(8),
      scrollable: true,
      content: buildContent(),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: validActions.isEmpty
              ? null
              : () {
                  widget.onSelected(validActions);
                  Navigator.pop(context, validActions);
                },
          child: Text(S.current.confirm),
        )
      ],
    );
  }

  Widget buildContent() {
    List<Widget> children = [
      Row(
        children: [
          SizedBox(
            width: cardSize,
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
    for (final svt in battleData.nonnullPlayers) {
      final tdIcon = buildTdIcon(svt);
      final cards = svt.getCards();
      List<Widget> cells = [tdIcon, const SizedBox(width: 4)];
      for (int index = 0; index < max(5, cards.length); index++) {
        final card = cards.getOrNull(index);
        if (card == null) {
          cells.add(const Flexible(child: SizedBox.shrink()));
        } else {
          cells.add(Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: buildCardIcon(svt, card),
            ),
          ));
        }
      }
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: cells,
      ));
    }
    children.add(ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SliderWithPrefix(
        titled: true,
        label: S.current.battle_random,
        min: ConstData.constants.attackRateRandomMin,
        max: ConstData.constants.attackRateRandomMax - 1,
        value: battleData.options.random,
        valueFormatter: (v) => toModifier(v).toStringAsFixed(3),
        onChange: (v) {
          battleData.options.random = ((v / 10).round() * 10)
              .clamp(ConstData.constants.attackRateRandomMin, ConstData.constants.attackRateRandomMax - 1);
          if (mounted) setState(() {});
        },
        onEdit: (v) {
          battleData.options.random =
              v.round().clamp(ConstData.constants.attackRateRandomMin, ConstData.constants.attackRateRandomMax - 1);
          if (mounted) setState(() {});
        },
      ),
    ));
    children.add(ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardSize * 7),
      child: Text(
        S.current.battle_select_critical_card_hint,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
        textScaler: const TextScaler.linear(0.9),
      ),
    ));
    if (battleData.nonnullPlayers.any((svt) => (svt.playerSvtData?.td?.dmgNpFuncCount ?? 0) > 1)) {
      children.add(ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardSize * 7),
        child: Text(
          S.current.laplace_upload_td_multi_dmg_func_hint,
          textScaler: const TextScaler.linear(0.8),
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget buildCardIcon(BattleServantData svt, CommandCardData card) {
    final commandCode = card.commandCode;
    Widget cardIcon = Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Center(child: CommandCardWidget(card: card.cardType, width: cardSize)),
        ),
        if (commandCode != null)
          Positioned(
            top: 0,
            right: 0,
            child: commandCode.iconBuilder(
              context: context,
              width: cardSize * 0.5,
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
              textStyle: TextStyle(fontSize: cardSize * 0.25, color: Colors.white),
              shadowColor: Colors.grey.shade700,
              shadowSize: 3,
            ),
          ),
        if (!svt.canCommandCard(card)) ...[
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: cardSize,
              height: cardSize,
              color: Colors.black54,
            ),
          ),
          Text('×', style: TextStyle(fontSize: cardSize * 0.8, color: Colors.white))
        ]
      ],
    );
    cardIcon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final cardIndex = getCardIndex(svt, card);
        if (cardIndex != -1) {
          final combatAction = combatActions[cardIndex]!;
          if (combatAction.cardData.cardType.isQAB) {
            if (combatAction.cardData.critical) {
              combatActions[cardIndex] = null;
            } else {
              combatAction.cardData.critical = true;
            }
          } else {
            combatActions[cardIndex] = null;
          }
        } else {
          final nextIndex = combatActions.indexOf(null);
          if (nextIndex == -1) {
            return;
          }
          combatActions[nextIndex] = CombatAction(svt, card);
        }
        if (mounted) setState(() {});
      },
      child: cardIcon,
    );
    final attackIndex = getCardIndex(svt, card);
    final critical = combatActions.getOrNull(attackIndex)?.cardData.critical ?? false;
    cardIcon = wrapAttackIndex(cardIcon, attackIndex, critical);
    return cardIcon;
  }

  Widget buildTdIcon(BattleServantData svt) {
    final curTd = svt.getCurrentNP();
    final tdValid = svt.canSelectNP(battleData);
    Widget tdIcon = svt.niceSvt!.iconBuilder(
      context: context,
      // width: tdWidth,
      height: cardSize,
      overrideIcon: svt.niceSvt!.ascendIcon(svt.limitCount),
      jumpToDetail: false,
    );
    tdIcon = Stack(
      alignment: Alignment.center,
      children: [
        tdIcon,
        if (curTd?.svt.card.isQAB == true) ...[
          Positioned(
            bottom: 0,
            child: Image.asset(
              'res/assets/card_icon_${curTd?.svt.card.name}.png',
              width: cardSize * 0.8,
            ),
          ),
          Positioned(
            bottom: cardSize * 0.5 * 0.2,
            child: Image.asset(
              'res/assets/card_txt_${curTd?.svt.card.name}.png',
              width: cardSize * 0.8,
            ),
          ),
        ],
        if (!tdValid) ...[
          AspectRatio(
            aspectRatio: 132 / 144,
            child: Container(
              width: cardSize,
              height: cardSize * 144 / 132,
              color: Colors.black54,
            ),
          ),
          Text('×', style: TextStyle(fontSize: cardSize * 0.8, color: Colors.white))
        ]
      ],
    );
    tdIcon = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: cardSize),
      child: tdIcon,
    );
    tdIcon = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final canCharge = svt.playerSvtData?.td != null && !(svt.isEnemy && svt.niceEnemy!.chargeTurn == 0);
        if (canCharge && !svt.isNpFull()) {
          int dispCount;
          if (svt.isPlayer) {
            dispCount = ConstData.constants.fullTdPoint ~/ 100;
          } else {
            dispCount = svt.niceEnemy!.chargeTurn;
          }
          final msg = '${S.current.charge_np_to(dispCount)}: ${svt.fieldIndex + 1}-${svt.lBattleName}';
          await SimpleCancelOkDialog(
            title: Text(S.current.np_not_enough),
            content: Text(msg),
            onTapOk: () async {
              await battleData.recordError(
                save: true,
                action: 'force-player-td-full',
                task: () async {
                  if (svt.isPlayer) {
                    svt.np = ConstData.constants.fullTdPoint;
                  } else {
                    svt.npLineCount = svt.niceEnemy!.chargeTurn;
                  }
                  battleData.battleLogger.action(msg);
                  battleData.recorder.setIllegal(msg);
                  battleData.recorder.message(S.current.charge_np_to(dispCount), target: svt);
                },
              );
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }
        if (!svt.isNpFull()) {
          return;
        }
        if (!svt.canSelectNP(battleData)) {
          return;
        }

        final npIndex = getNpCardIndex(svt);
        if (npIndex != -1) {
          combatActions[npIndex] = null;
          if (mounted) setState(() {});
        } else {
          final nextIndex = combatActions.indexOf(null);
          if (nextIndex == -1) {
            return;
          }

          combatActions[nextIndex] = CombatAction(svt, svt.getNPCard()!);
          if (mounted) setState(() {});
        }
      },
      child: tdIcon,
    );
    tdIcon = wrapAttackIndex(Padding(padding: const EdgeInsets.all(1), child: tdIcon), getNpCardIndex(svt), false);
    return tdIcon;
  }

  Widget wrapAttackIndex(Widget child, int? index, bool critical) {
    String text = '';
    bool selected = index != null && index >= 0;
    if (selected) {
      text = {
            1: '1st',
            2: '2nd',
            3: '3rd',
          }[index + 1] ??
          '${index + 1}th';
      if (critical) {
        // text += ' ${S.current.critical_attack}';
      }
    }
    final colorScheme = Theme.of(context).colorScheme;
    final color = critical ? colorScheme.error : colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: selected ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
        ),
        SizedBox(
          height: 20,
          child: Text(
            text,
            style: TextStyle(color: color),
            textScaler: const TextScaler.linear(0.8),
            maxLines: 1,
          ),
        )
      ],
    );
  }

  int getNpCardIndex(final BattleServantData svt) {
    return combatActions
        .map((action) => action != null && action.cardData.isTD ? action.actor : null)
        .toList()
        .indexOf(svt);
  }

  int getCardIndex(final BattleServantData svt, final CommandCardData cardData) {
    return combatActions
        .map((action) => action != null && action.cardData.cardIndex == cardData.cardIndex && !action.cardData.isTD
            ? action.actor
            : null)
        .toList()
        .indexOf(svt);
  }
}

class EnemyCombatActionSelector extends StatefulWidget {
  final BattleData battleData;
  final Function(Future Function() task) onConfirm;

  const EnemyCombatActionSelector({super.key, required this.battleData, required this.onConfirm});

  @override
  State<EnemyCombatActionSelector> createState() => _EnemyCombatActionSelectorState();
}

class _EnemyCombatActionSelectorState extends State<EnemyCombatActionSelector> {
  BattleData get battleData => widget.battleData;

  BattleServantData? selectedEnemy;
  BattleServantData? selectedCounter;
  int? actionIndex;
  bool critical = false;
  Future<void> Function()? onConfirm;

  @override
  void initState() {
    super.initState();
    final enemies = battleData.nonnullEnemies;
    if (enemies.length == 1) {
      selectedEnemy = enemies.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((battleData.nonnullEnemies.isNotEmpty && battleData.targetedEnemy == null) ||
        (battleData.nonnullPlayers.isNotEmpty && battleData.targetedPlayer == null)) {
      return SimpleCancelOkDialog(
        title: Text(S.current.warning),
        content: Text(S.current.battle_targeted_required_hint),
        hideCancel: true,
      );
    }

    int optionIndex = -1;
    Widget buildRadio({
      required Widget title,
      Widget? subtitle,
      required Future<void> Function() onSelected,
      bool enabled = true,
    }) {
      optionIndex += 1;
      return RadioListTile<int>(
        dense: true,
        value: optionIndex,
        groupValue: actionIndex,
        title: title,
        subtitle: subtitle,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: enabled
            ? (v) {
                setState(() {
                  actionIndex = v;
                  onConfirm = onSelected;
                });
              }
            : null,
      );
    }

    List<Widget> children = [
      ...getEnemySelector(),
      const Divider(height: 16),
    ];

    children.add(buildRadio(
      title: Text(S.current.end_enemy_turn),
      onSelected: () async {
        await battleData.endEnemyActions();
      },
    ));
    final enemy = selectedEnemy;
    if (enemy != null) {
      if (enemy.skillInfoList.any((e) => e.proximateSkill != null)) {
        children.add(DividerWithTitle(title: S.current.active_skill));
      }
      for (int index = 0; index < 3; index++) {
        final skill = enemy.skillInfoList.getOrNull(index);
        final baseSkill = skill?.proximateSkill;
        if (skill != null && baseSkill != null) {
          children.add(buildRadio(
            title: Text('${S.current.skill} ${index + 1} ${baseSkill.lName.l}'),
            onSelected: () async {
              await enemy.activateSkill(battleData, index);
            },
          ));
        }
      }
      final svt = enemy.niceSvt;
      if (svt != null) {
        children.add(DividerWithTitle(title: S.current.battle_command_card));
        for (final cardType in svt.cardDetails.keys) {
          if (cardType == CardType.extra) continue;
          final detail = svt.cardDetails[cardType]!;
          String name = cardType.name.toTitle();
          if (cardType == CardType.strength) {
            name += ' (${S.current.critical_attack})';
          }
          children.add(buildRadio(
            title: Text(name),
            onSelected: () async {
              final cardData = CommandCardData(cardType, detail)
                ..cardIndex = 1
                ..isTD = false
                ..traits = ConstData.cardInfo[cardType]?[1]?.individuality.toList() ?? [];
              if (cardType.isQAB) {
                cardData.critical = critical;
              } else if (cardType == CardType.strength) {
                cardData.critical = true;
              } else if (cardType == CardType.weak) {
                cardData.critical = false;
              }
              await battleData.playEnemyCard(CombatAction(enemy, cardData));
            },
          ));
        }
        if (svt.cardDetails.keys.any((e) => e.isQAB)) {
          children.add(CheckboxListTile(
            dense: true,
            value: critical,
            title: Text(S.current.critical_attack),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() {
                critical = v ?? critical;
              });
            },
          ));
        }
        final td = enemy.niceEnemy?.noblePhantasm.noblePhantasm;
        if (td != null && td.functions.isNotEmpty) {
          children.add(const Divider());
          Widget tile = buildRadio(
            title: Text('${S.current.np_short} ${td.nameWithRank}'),
            subtitle: Text('${S.current.info_charge}: ${enemy.npValueText}'),
            onSelected: () async {
              final card = enemy.getNPCard();
              if (card != null) {
                await battleData.playEnemyCard(CombatAction(enemy, card));
              }
            },
            enabled: enemy.canNP(),
          );

          final chargeTurn = enemy.niceEnemy?.chargeTurn ?? 0;
          if (enemy.npLineCount < chargeTurn) {
            tile = GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    return SimpleCancelOkDialog(
                      title: Text(S.current.np_not_enough),
                      content: Text(S.current.charge_np_to(chargeTurn)),
                      onTapOk: () async {
                        await battleData.recordError(
                          save: true,
                          action: 'force-enemy-td-full',
                          task: () async {
                            final msg =
                                '${S.current.charge_np_to(chargeTurn)}: ${enemy.fieldIndex + 1}-${enemy.lBattleName}';
                            battleData.pushSnapshot();
                            enemy.npLineCount = chargeTurn;
                            battleData.battleLogger.action(msg);
                            battleData.recorder.setIllegal(msg);
                            battleData.recorder.message(S.current.charge_np_to(chargeTurn), target: enemy);
                          },
                        );
                        if (mounted) setState(() {});
                      },
                    );
                  },
                );
              },
              child: tile,
            );
          }
          children.add(tile);
        }
      }
    }

    return SimpleCancelOkDialog(
      scrollable: true,
      title: Text(S.current.select),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 20.0, 0, 24.0),
      content: ListTileTheme.merge(
        horizontalTitleGap: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
      hideOk: true,
      actions: [
        TextButton(
          onPressed: onConfirm == null
              ? null
              : () async {
                  Navigator.pop(context);
                  widget.onConfirm(onConfirm!);
                },
          child: Text(S.current.confirm),
        ),
      ],
    );
  }

  List<Widget> getEnemySelector() {
    List<Widget> children = [];
    final rowCount = (battleData.onFieldEnemies.length / 3).ceil();
    for (int row = 0; row < rowCount; row++) {
      List<Widget> rowChildren = [];
      for (int index = 0; index < 3; index++) {
        final enemy = battleData.onFieldEnemies.getOrNull(row * 3 + index);
        Widget child;
        if (enemy == null) {
          child = const SizedBox.shrink();
        } else {
          child = enemy.iconBuilder(
            context: context,
            battleData: battleData,
            onTap: () {
              setState(() {
                if (selectedEnemy != enemy) {
                  actionIndex = null;
                  onConfirm = null;
                  critical = false;
                }
                selectedEnemy = enemy;
                selectedCounter = null;
              });
            },
          );
          child = Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selectedEnemy == enemy ? Colors.red : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          );
        }
        rowChildren.add(SizedBox(width: 64, child: child));
      }
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: rowChildren.reversed.toList(),
      ));
    }
    children = children.reversed.toList();

    List<Widget> counterActors = [];

    for (final svt in battleData.nonnullPlayers) {
      final counterBuff = svt.battleBuff.validBuffs.lastWhereOrNull((buff) => buff.vals.CounterId != null);
      if (counterBuff == null) continue;
      counterActors.add(RadioListTile<BattleServantData>(
        dense: true,
        value: svt,
        groupValue: selectedCounter,
        title: Text(counterBuff.buff.lName.l),
        subtitle: Text(svt.lBattleName),
        secondary: svt.iconBuilder(context: context),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (v) {
          setState(() {
            selectedCounter = svt;
            selectedEnemy = null;
            onConfirm = () => battleData.activateCounter(svt);
          });
        },
      ));
    }
    if (counterActors.isNotEmpty && battleData.nonnullEnemies.isNotEmpty) {
      children.insertAll(0, [...counterActors, kDefaultDivider]);
    }

    return children;
  }
}
