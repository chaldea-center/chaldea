import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/skill.dart';
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
    final List<Widget> topListChildren = [];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AutoSizeText(widget.questPhase.lName.l, maxLines: 1),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: divideTiles(
                topListChildren,
                divider: const Divider(height: 8, thickness: 2),
              ),
            ),
          ),
          buildMiscRow(),
        ],
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (battleData.mysticCode != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          battleData.mysticCode!.iconBuilder(context: context, width: 72, jumpToDetail: true),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (final skillInfo in battleData.masterSkillInfo) buildSkillInfo(skillInfo),
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
                        Row(
                          children: [
                            const Text('Field Traits ', style: TextStyle(fontWeight: FontWeight.bold)),
                            SharedBuilder.traitList(
                              context: context,
                              traits: battleData.getFieldTraits(),
                              textAlign: TextAlign.left,
                              format: (trait) => trait.shownName(field: false),
                            ),
                          ],
                        ),
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

  Widget buildSkillInfo(final BattleSkillInfoData skillInfo) {
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
          image: db.getIconImage(skillInfo.skill.icon, width: 33, aspectRatio: 1),
          textBuilder: skillInfo.canActivate ? null : cdTextBuilder,
          option: ImageWithTextOption(
            shadowSize: 8,
            textStyle: const TextStyle(fontSize: 20, color: Colors.black),
            shadowColor: Colors.white,
            alignment: AlignmentDirectional.center,
          ),
          onTap: skillInfo.canActivate
              ? () {
                  skillInfo.activate(battleData);
                  if (mounted) setState(() {});
                }
              : null,
        ),
      ),
    );
  }
}
