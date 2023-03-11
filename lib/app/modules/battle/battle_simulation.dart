import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
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
          DecoratedBox(
            decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 0.5))),
            child: SafeArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ButtonBar(
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Start Simulation'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
