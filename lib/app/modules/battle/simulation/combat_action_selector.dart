import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
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
    for (final svt in battleData.nonnullAllies) {
      final tdIcon = buildTdIcon(svt);
      final cards = svt.getCards(battleData);
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
      child: SliderWithTitle(
        padding: EdgeInsets.zero,
        leadingText: S.current.battle_random,
        min: ConstData.constants.attackRateRandomMin,
        max: ConstData.constants.attackRateRandomMax - 1,
        value: battleData.options.fixedRandom,
        label: toModifier(battleData.options.fixedRandom).toStringAsFixed(3),
        onChange: (v) {
          battleData.options.fixedRandom = v.round();
          if (mounted) setState(() {});
        },
      ),
    ));
    children.add(Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CheckboxWithLabel(
          value: battleData.options.isAfter7thAnni,
          label: Text('${S.current.battle_after_7th} (QAB Chain)'),
          onChanged: (v) {
            setState(() {
              battleData.options.isAfter7thAnni = v!;
            });
          },
        ),
      ],
    ));
    children.add(Text(
      S.current.battle_select_critical_card_hint,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textScaleFactor: 0.9,
    ));

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
        if (!svt.canCommandCard(battleData)) ...[
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
      onTap: () {
        final cardIndex = getCardIndex(svt, card);
        if (cardIndex != -1) {
          final combatAction = combatActions[cardIndex]!;
          if (combatAction.cardData.cardType.isQAB) {
            if (combatAction.cardData.isCritical) {
              combatActions[cardIndex] = null;
            } else {
              combatAction.cardData.isCritical = true;
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
    final isCritical = combatActions.getOrNull(attackIndex)?.cardData.isCritical ?? false;
    cardIcon = wrapAttackIndex(cardIcon, attackIndex, isCritical);
    return cardIcon;
  }

  Widget buildTdIcon(BattleServantData svt) {
    final curTd = svt.getCurrentNP(battleData);
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
      onTap: () async {
        final canCharge = svt.playerSvtData?.td != null && !(svt.isEnemy && svt.niceEnemy!.chargeTurn == 0);
        if (canCharge && !svt.isNpFull(battleData)) {
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
            onTapOk: () {
              battleData.pushSnapshot();
              if (svt.isPlayer) {
                svt.np = ConstData.constants.fullTdPoint;
              } else {
                svt.npLineCount = svt.niceEnemy!.chargeTurn;
              }
              battleData.battleLogger.action(msg);
              battleData.recorder.message(S.current.charge_np_to(dispCount), svt);
              if (mounted) setState(() {});
            },
          ).showDialog(context);
        }
        if (!svt.isNpFull(battleData)) {
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

          combatActions[nextIndex] = CombatAction(svt, svt.getNPCard(battleData)!);
          if (mounted) setState(() {});
        }
      },
      child: tdIcon,
    );
    tdIcon = wrapAttackIndex(Padding(padding: const EdgeInsets.all(1), child: tdIcon), getNpCardIndex(svt), false);
    return tdIcon;
  }

  Widget wrapAttackIndex(Widget child, int? index, bool isCritical) {
    String text = '';
    bool selected = index != null && index >= 0;
    if (selected) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final color = isCritical ? colorScheme.error : colorScheme.primary;

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
            textScaleFactor: 0.8,
            maxLines: 1,
          ),
        )
      ],
    );
  }

  int getNpCardIndex(final BattleServantData svt) {
    return combatActions
        .map((action) => action != null && action.cardData.isNP ? action.actor : null)
        .toList()
        .indexOf(svt);
  }

  int getCardIndex(final BattleServantData svt, final CommandCardData cardData) {
    return combatActions
        .map((action) => action != null && action.cardData.cardIndex == cardData.cardIndex && !action.cardData.isNP
            ? action.actor
            : null)
        .toList()
        .indexOf(svt);
  }
}
