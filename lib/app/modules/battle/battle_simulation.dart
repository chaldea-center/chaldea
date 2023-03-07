import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/enemy/stage.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

import 'package:chaldea/widgets/widgets.dart';

class SimulationPreview extends StatefulWidget {
  final Region region;

  const SimulationPreview({
    super.key,
    this.region = Region.jp,
  });

  @override
  State<SimulationPreview> createState() => _SimulationPreviewState();
}

class _SimulationPreviewState extends State<SimulationPreview> {
  QuestPhase? _questPhase;

  QuestPhase get questPhase => _questPhase!;
  late TextEditingController questIdTextController;
  late TextEditingController phaseTextController;

  @override
  void initState() {
    super.initState();

    questIdTextController = TextEditingController();
    phaseTextController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    super.dispose();

    questIdTextController.dispose();
    phaseTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topColumnChildren = [];
    topColumnChildren.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Quest ID: '),
        SizedBox(
          width: 200,
          child: TextFormField(
            controller: questIdTextController,
          ),
        ),
        const Text('Phase ID: '),
        SizedBox(
          width: 30,
          child: TextFormField(
            controller: phaseTextController,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _fetchQuestPhase();
          },
          child: const Text('Fetch Quest Phase'),
        ),
      ],
    ));

    if (_questPhase == null) {
      final questId = int.tryParse(questIdTextController.text);
      final phase = int.tryParse(phaseTextController.text);
      topColumnChildren.add(const Text('The quest phase either is not provided or is invalid.'));
      topColumnChildren.add(Text('$questId + $phase'));
    } else {
      for (int j = 0; j < questPhase.stages.length; j++) {
        final stage = questPhase.stages[j];
        topColumnChildren.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 32,
              child: Text.rich(
                TextSpan(
                  children: divideList(
                    [
                      TextSpan(text: '${j + 1}'),
                      if (stage.enemyFieldPosCount != null) TextSpan(text: '(${stage.enemyFieldPosCount})'),
                      if (stage.hasExtraInfo())
                        WidgetSpan(
                          child: IconButton(
                            onPressed: () {
                              router.pushPage(WaveInfoPage(stage: stage));
                            },
                            icon: const Icon(Icons.music_note, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        )
                    ],
                    const TextSpan(text: '\n'),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: QuestWave(
                stage: stage,
                showTrueName: false,
                region: widget.region,
              ),
            )
          ],
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Battle Simulation', maxLines: 1),
        centerTitle: false,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: topColumnChildren,
      ),
    );
  }

  void _fetchQuestPhase() async {
    final questId = int.tryParse(questIdTextController.text);
    final phase = int.tryParse(phaseTextController.text);
    if (questId == null || phase == null) {
      _questPhase = null;
    } else {
      await AtlasApi.questPhase(questId, phase, region: widget.region).then((questPhase) => _questPhase = questPhase);
      if (widget.region == Region.jp) {
        _questPhase ??= db.gameData.getQuestPhase(questId, phase);
      }
    }
    if (mounted) setState(() {});
  }
}
