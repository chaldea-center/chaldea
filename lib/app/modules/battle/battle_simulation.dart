import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/widgets/widgets.dart';

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
      ..init(widget.questPhase, [...widget.onFieldSvtDataList, ...widget.backupSvtDataList], widget.mysticCodeData)
      ..probabilityThreshold = widget.probabilityThreshold
      ..fixedRandom = widget.fixedRandom
      ..isAfter7thAnni = widget.isAfter7thAnni;
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(widget.questPhase.lName.l, maxLines: 1),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) => buildSvts(constraints),
            ),
          ),
          buildMiscRow(),
        ],
      ),
    );
  }

  Widget buildSvts(final BoxConstraints boxConstraint) {
    final List<Widget> topListChildren = [];
    if (boxConstraint.maxWidth >= 600) {
      topListChildren.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < battleData.onFieldAllyServants.length; i += 1)
            Expanded(child: buildBattleSvtData(battleData.onFieldAllyServants[i], i)),
        ],
      ));
      topListChildren.add(const Divider(height: 8, thickness: 2));
      for (int i = 0; i < (battleData.onFieldEnemies.length + 2) ~/ 3; i += 1) {
        final List<Widget> rowChildren = [];
        for (int j = 2; j >= 0; j -= 1) {
          final index = j + i * 3;
          rowChildren.add(
            Expanded(
              child: buildBattleSvtData(
                  battleData.onFieldEnemies.length > index ? battleData.onFieldEnemies[index] : null, index),
            ),
          );
        }
        topListChildren.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ));
      }
    } else {
      topListChildren.add(const Center(
          child: Text(
        'Ally Servants',
        style: TextStyle(fontWeight: FontWeight.bold),
      )));
      for (int i = 0; i < battleData.onFieldAllyServants.length; i += 1) {
        topListChildren.add(buildBattleSvtData(battleData.onFieldAllyServants[i], i));
      }
      topListChildren.add(const Divider(height: 8, thickness: 2));
      topListChildren.add(const Center(
          child: Text(
        'Enemies',
        style: TextStyle(fontWeight: FontWeight.bold),
      )));
      for (int i = 0; i < battleData.onFieldEnemies.length; i += 1) {
        topListChildren.add(buildBattleSvtData(battleData.onFieldEnemies[i], i));
      }
    }

    return ListView(children: topListChildren);
  }

  Widget buildBattleSvtData(final BattleServantData? svt, final int index) {
    if (svt == null) {
      return const SizedBox();
    }

    final List<Widget> children = [];
    children.add(Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
              child: Radio<int>(
                value: index,
                groupValue: svt.isPlayer ? battleData.allyTargetIndex : battleData.enemyTargetIndex,
                onChanged: (final int? v) {
                  if (svt.isPlayer) {
                    battleData.allyTargetIndex = v!;
                  } else {
                    battleData.enemyTargetIndex = v!;
                  }
                  if (mounted) setState(() {});
                },
              ),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
              text: svt.isPlayer
                  ? Transl.svtNames(ServantSelector.getSvtBattleName(svt.niceSvt!, svt.ascensionPhase)).l
                  : svt.niceEnemy!.lShownName),
        ],
      ),
      textAlign: TextAlign.center,
    ));
    final iconImage = svt.isPlayer
        ? svt.niceSvt!.iconBuilder(
            context: context,
            jumpToDetail: false,
            width: 100,
            overrideIcon: ServantSelector.getSvtAscensionBorderedIconUrl(svt.niceSvt!, svt.ascensionPhase),
          )
        : svt.niceEnemy!.iconBuilder(
            context: context,
            jumpToDetail: false,
            width: 100,
          );
    children.add(InkWell(
      child: iconImage,
      onTap: () async {
        await null;
        if (!mounted) return;
        await showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) {
            return SimpleCancelOkDialog(
              title: const Text('Buff Details'),
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
      onLongPress: () {},
    ));
    if (svt.isPlayer) {
      children.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < svt.skillInfoList.length; i += 1)
              buildSkillInfo(
                  skillInfo: svt.skillInfoList[i],
                  onTap: () {
                    battleData.activateSvtSkill(index, i);
                    if (mounted) setState(() {});
                  }),
          ],
        ),
      ));
    }
    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        db.getIconImage(svt.svtClass.icon(svt.rarity), width: 40),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'ATK: ${svt.attack}',
                minFontSize: 8,
              ),
              AutoSizeText('HP: ${svt.hp}', minFontSize: 8),
              if (svt.isPlayer)
                AutoSizeText('NP: ${(svt.np / 100).toStringAsFixed(2)}%', minFontSize: 8)
              else
                AutoSizeText('NP: ${svt.npLineCount}/${svt.niceEnemy!.chargeTurn}', minFontSize: 8),
            ],
          ),
        )
      ],
    ));

    children.add(Text.rich(TextSpan(children: [
      for (final buff in svt.battleBuff.allBuffs) WidgetSpan(child: buildBuffIcon(buff)),
    ])));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.fromBorderSide(
            Divider.createBorderSide(context, width: 4, color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget buildMiscRow() {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 0.5))),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ServantOptionEditPage.buildSlider(
                leadingText: 'Probability Threshold',
                min: 0,
                max: 10,
                value: battleData.probabilityThreshold ~/ 100,
                label: '${battleData.probabilityThreshold ~/ 10} %',
                onChange: (v) {
                  battleData.probabilityThreshold = v.round() * 100;
                  if (mounted) setState(() {});
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (battleData.mysticCode != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          battleData.mysticCode!.iconBuilder(context: context, width: 72, jumpToDetail: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < battleData.masterSkillInfo.length; i += 1)
                                buildSkillInfo(
                                    skillInfo: battleData.masterSkillInfo[i],
                                    onTap: () {
                                      battleData.activateMysticCodeSKill(i);
                                      if (mounted) setState(() {});
                                    }),
                            ],
                          )
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(
                          children: [
                            const TextSpan(text: 'Critical Star: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '${battleData.criticalStars.toStringAsFixed(3)}  '),
                            const TextSpan(text: 'Stage: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '${battleData.waveCount}/${battleData.niceQuest!.stages.length}  '),
                            const TextSpan(text: 'Enemy Remaining: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '${battleData.nonnullEnemies.length + battleData.nonnullBackupEnemies.length}  '),
                            const TextSpan(text: 'Turn: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '${battleData.totalTurnCount}'),
                          ],
                        )),
                        Text.rich(TextSpan(
                          children: [
                            const TextSpan(text: 'Field Traits ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              children: SharedBuilder.traitSpans(
                                context: context,
                                traits: battleData.getFieldTraits(),
                                format: (trait) => trait.shownName(field: false),
                              ),
                            )
                          ],
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                showCommandCards();
                              },
                              icon: const Icon(
                                FontAwesomeIcons.meteor,
                                size: 30,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await null;
                                if (!mounted) return;
                                await showDialog(
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (context) {
                                    return BattleLogViewer(logs: battleData.logger.logs);
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.list_alt,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                battleData.chargeAllyNP();
                                if (mounted) setState(() {});
                              },
                              icon: Icon(
                                Icons.battery_charging_full,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                battleData.skipWave();
                                if (mounted) setState(() {});
                              },
                              icon: Icon(
                                Icons.fast_forward,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                battleData.undo();
                                if (mounted) setState(() {});
                              },
                              icon: Icon(
                                Icons.undo,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSkillInfo({required final BattleSkillInfoData skillInfo, required final VoidCallback onTap}) {
    final cd = skillInfo.chargeTurn;
    Widget cdTextBuilder(final TextStyle style) {
      return Text.rich(
        TextSpan(style: style, text: cd.toString()),
        textScaleFactor: 1,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onLongPress: () {},
        child: ImageWithText(
          image: db.getIconImage(skillInfo.skill.icon, width: 35, aspectRatio: 1),
          textBuilder: skillInfo.canActivate ? null : cdTextBuilder,
          option: ImageWithTextOption(
            shadowSize: 8,
            textStyle: const TextStyle(fontSize: 20, color: Colors.black),
            shadowColor: Colors.white,
            alignment: AlignmentDirectional.center,
          ),
          onTap: skillInfo.canActivate ? onTap : null,
        ),
      ),
    );
  }

  Widget buildBuffIcon(final BuffData buff) {
    return DecoratedBox(
      decoration: buff.irremovable
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.black87, width: 1),
            )
          : const BoxDecoration(),
      child: db.getIconImage(buff.buff.icon, width: 18, height: 18),
    );
  }

  void showCommandCards() async {
    await null;
    if (!mounted) return;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        final List<CombatAction?> combatActions = [null, null, null];

        return SimpleCancelOkDialog(
          title: const Text('Select Card'),
          contentPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            child: CombatActionSelector(battleData: battleData, combatActions: combatActions),
          ),
          onTapOk: () {
            final List<CombatAction> nonnullActions = [];
            for (final action in combatActions) {
              if (action != null) {
                nonnullActions.add(action);
              }
            }

            if (nonnullActions.isEmpty) {
              return;
            }

            battleData.playerTurn(nonnullActions);
            if (mounted) setState(() {});
          },
        );
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
  @override
  Widget build(final BuildContext context) {
    final List<Widget> npCardColumn = [];
    final List<Widget> commandCardColumn = [];
    npCardColumn.add(const Text('NP Card'));
    commandCardColumn.add(const Text('Command Cards'));

    Widget unableTextBuilder(final TextStyle style) {
      return Text.rich(
        TextSpan(style: style, text: 'X'),
        textScaleFactor: 1,
      );
    }

    for (final svt in widget.battleData.nonnullAllies) {
      npCardColumn.add(Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          child: ImageWithText(
            image: svt.niceSvt!.iconBuilder(
              context: context,
              jumpToDetail: false,
              height: 100,
              overrideIcon: ServantSelector.getSvtAscensionBorderedIconUrl(svt.niceSvt!, svt.ascensionPhase),
            ),
            textBuilder: svt.canNP(widget.battleData) ? null : unableTextBuilder,
            option: ImageWithTextOption(
              shadowSize: 20,
              textStyle: const TextStyle(fontSize: 72, color: Colors.black),
              shadowColor: Colors.white,
              alignment: AlignmentDirectional.center,
            ),
            onTap: () {
              if (!svt.canNP(widget.battleData)) {
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

                widget.combatActions[nextIndex] = CombatAction(svt, svt.getNPCard()!);
                if (mounted) setState(() {});
              }
            },
          ),
          onLongPress: () {},
        ),
      ));
      final npIndex = getNpCardIndex(svt, widget.combatActions);
      npCardColumn.add(Text(npIndex == -1 ? '' : 'Card ${npIndex + 1}'));

      final cards = svt.getCards();
      commandCardColumn.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          cards.length,
          (index) {
            final cardData = cards[index];
            final commandCode = svt.playerSvtData?.commandCodes[index];
            return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: InkWell(
                  child: ImageWithText(
                    image: Stack(children: [
                      CommandCardWidget(card: cardData.cardType, width: 100),
                      if (cardData.cardStrengthen != 0)
                        Text(
                          cardData.cardStrengthen.toString(),
                          style: const TextStyle(
                              fontSize: 18, shadows: [Shadow(color: Colors.white, offset: Offset(3, 3))]),
                        ),
                      if (commandCode != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: commandCode.iconBuilder(
                            context: context,
                            width: 50,
                            jumpToDetail: false,
                            overrideIcon: commandCode.icon,
                          ),
                        ),
                    ]),
                    textBuilder: svt.canCommandCard(widget.battleData) ? null : unableTextBuilder,
                    option: ImageWithTextOption(
                      shadowSize: 20,
                      textStyle: const TextStyle(fontSize: 72, color: Colors.black),
                      shadowColor: Colors.white,
                      alignment: AlignmentDirectional.center,
                    ),
                    onTap: () {
                      if (!svt.canCommandCard(widget.battleData)) {
                        return;
                      }
                      final cardIndex = getCardIndex(svt, cardData, widget.combatActions);
                      if (cardIndex != -1) {
                        final combatAction = widget.combatActions[cardIndex];
                        if (combatAction!.cardData.isCritical) {
                          widget.combatActions[cardIndex] = null;
                        } else {
                          combatAction.cardData.isCritical = true;
                        }
                        if (mounted) setState(() {});
                      } else {
                        final nextIndex = widget.combatActions.indexOf(null);
                        if (nextIndex == -1) {
                          return;
                        }

                        widget.combatActions[nextIndex] = CombatAction(svt, cardData);
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                  onLongPress: () {},
                ),
              ),
              getCardIndexWidget(svt, cardData, widget.combatActions),
            ]);
          },
        ),
      ));
    }

    npCardColumn.add(Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: widget.battleData.isAfter7thAnni,
              onChanged: (final bool? v) {
                widget.battleData.isAfter7thAnni = v!;
                if (mounted) setState(() {});
              },
            ),
            const Text('Before 7th'),
          ],
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: widget.battleData.isAfter7thAnni,
              onChanged: (final bool? v) {
                widget.battleData.isAfter7thAnni = v!;
                if (mounted) setState(() {});
              },
            ),
            const Text('After 7th'),
          ],
        )
      ],
    ));
    commandCardColumn.add(ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Row(
        children: [
          Expanded(
            child: ServantOptionEditPage.buildSlider(
              leadingText: 'Random',
              min: ConstData.constants.attackRateRandomMin,
              max: ConstData.constants.attackRateRandomMax,
              value: widget.battleData.fixedRandom,
              label: toModifier(widget.battleData.fixedRandom).toStringAsFixed(3),
              onChange: (v) {
                widget.battleData.fixedRandom = v.round();
                if (mounted) setState(() {});
              },
            ),
          ),
        ],
      ),
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: npCardColumn,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: commandCardColumn,
        ),
      ],
    );
  }

  static int getNpCardIndex(final BattleServantData svt, final List<CombatAction?> combatActions) {
    return combatActions
        .map((action) => action != null && action.cardData.isNP ? action.actor : null)
        .toList()
        .indexOf(svt);
  }

  static int getCardIndex(
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

  static Widget getCardIndexWidget(
    final BattleServantData svt,
    final CommandCardData cardData,
    final List<CombatAction?> combatActions,
  ) {
    final cardIndex = getCardIndex(svt, cardData, combatActions);
    return cardIndex != -1
        ? combatActions[cardIndex]!.cardData.isCritical
            ? Text(
                'Crit ${cardIndex + 1}',
                style: const TextStyle(color: Colors.red),
              )
            : Text('Card ${cardIndex + 1}')
        : const Text('');
  }
}

class BattleLogViewer extends StatefulWidget {
  final List<BattleLog> logs;

  const BattleLogViewer({super.key, required this.logs});

  @override
  State<BattleLogViewer> createState() => _BattleLogViewerState();
}

class _BattleLogViewerState extends State<BattleLogViewer> {
  BattleLogType shownType = BattleLogType.action;

  @override
  Widget build(BuildContext context) {
    final List<Widget> filterActions = [];
    filterActions.add(TextButton(
      onPressed: () {
        shownType = BattleLogType.values[(shownType.index + 1) % BattleLogType.values.length];
        if (mounted) setState(() {});
      },
      child: Text(shownType.name.toUpperCase()),
    ));

    final List<Widget> children = [];
    children.addAll(
      widget.logs.where((log) => log.type.index >= shownType.index).map(
            (log) => ListTile(
              leading: Text(log.type.name.toUpperCase()),
              title: Text(log.log),
            ),
          ),
    );

    return SimpleCancelOkDialog(
      title: const Text('Battle Log'),
      contentPadding: const EdgeInsets.all(8),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: divideTiles(children),
        ),
      ),
      actions: filterActions,
      hideCancel: true,
    );
  }
}
