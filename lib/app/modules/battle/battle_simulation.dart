import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/quest/quest_card.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/widgets/widgets.dart';

class SimulationPreview extends StatefulWidget {
  final Region region;
  final Quest? quest;
  final int? phase;

  const SimulationPreview({
    super.key,
    this.region = Region.jp,
    this.quest,
    this.phase,
  });

  @override
  State<SimulationPreview> createState() => _SimulationPreviewState();
}

class _SimulationPreviewState extends State<SimulationPreview> {
  Quest? quest;

  late TextEditingController questIdTextController;
  late TextEditingController phaseTextController;

  @override
  void initState() {
    super.initState();

    quest = widget.quest;
    questIdTextController = TextEditingController(text: widget.quest != null ? widget.quest!.id.toString() : '');
    phaseTextController = TextEditingController(text: widget.phase != null ? widget.phase!.toString() : '1');
  }

  @override
  void dispose() {
    super.dispose();

    questIdTextController.dispose();
    phaseTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topListChildren = [];
    topListChildren.add(
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Quest ID: '),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: TextFormField(
                controller: questIdTextController,
              ),
            ),
          ),
          const Text('Phase: '),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: TextFormField(
                controller: phaseTextController,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _fetchQuestPhase();
            },
            child: const Text('Fetch'),
          ),
        ],
      ),
    );

    final phase = int.tryParse(phaseTextController.text);
    if (quest == null || phase == null) {
      final questId = int.tryParse(questIdTextController.text);
      topListChildren.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('The quest phase either is not provided or is invalid.'),
            Text('$questId + $phase'),
          ],
        ),
      );
    } else {
      topListChildren.add(QuestCard(
        region: widget.region,
        offline: false,
        quest: quest,
        displayPhases: [phase.clamp(1, quest!.phases.length)],
        battleOnly: true,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AutoSizeText('Battle Simulation', maxLines: 1),
        centerTitle: false,
      ),
      body: ListView(
        children: topListChildren,
      ),
    );
  }

  void _fetchQuestPhase() async {
    final questId = int.tryParse(questIdTextController.text);
    final phase = int.tryParse(phaseTextController.text);
    if (questId == null || phase == null) {
      quest = null;
    } else {
      await AtlasApi.quest(questId, region: widget.region).then((fetchedQuest) => quest = fetchedQuest);
      if (widget.region == Region.jp) {
        quest ??= db.gameData.getQuestPhase(questId, phase);
      }
    }
    if (mounted) setState(() {});
  }
}
