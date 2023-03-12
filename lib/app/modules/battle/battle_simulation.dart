import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
import 'package:chaldea/app/modules/battle/svt_option_editor.dart';
import 'package:chaldea/app/modules/common/builders.dart';
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
    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio<int>(
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
        AutoSizeText(svt.isPlayer
            ? Transl.svtNames(ServantSelector.getSvtBattleName(svt.niceSvt!, svt.ascensionPhase)).l
            : svt.niceEnemy!.lShownName),
      ],
    ));
    final iconImage = svt.isPlayer
        ? svt.niceSvt!.iconBuilder(
            context: context,
            jumpToDetail: false,
            width: 72,
            overrideIcon: ServantSelector.getSvtAscensionBorderedIconUrl(svt.niceSvt!, svt.ascensionPhase),
          )
        : svt.niceEnemy!.iconBuilder(
            context: context,
            jumpToDetail: false,
            width: 72,
          );
    children.add(iconImage);
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
                AutoSizeText('NP: ${svt.np ~/ 100}.${svt.np ~/ 10 % 10}${svt.np % 10}%', minFontSize: 8)
              else
                AutoSizeText('NP: ${svt.npLineCount}/${svt.niceEnemy!.chargeTurn}', minFontSize: 8),
            ],
          ),
        )
      ],
    ));

    children.add(Text.rich(TextSpan(children: [
      for (final buff in svt.battleBuff.allBuffs) buildBuffIcon(buff),
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
    final criticalStar = (battleData.criticalStars * 1000).toInt();
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
                            TextSpan(
                                text: '${criticalStar ~/ 1000}.'
                                    '${criticalStar ~/ 100 % 10}${criticalStar ~/ 10 % 10}${criticalStar % 10}  '),
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

  WidgetSpan buildBuffIcon(final BuffData buff) {
    return WidgetSpan(
      child: DecoratedBox(
        decoration: buff.irremovable
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.black87, width: 1),
              )
            : const BoxDecoration(),
        child: db.getIconImage(buff.buff.icon, width: 18, height: 18),
      ),
    );
  }
}
