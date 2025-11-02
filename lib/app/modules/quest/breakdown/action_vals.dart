import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

typedef ActionVal = ({QuestAfterActionCommand command, String value});

class _ResultData {
  int phase = 0;
  List<ActionVal> questBeforeVals = [];
  List<ActionVal> questAfterVals = [];
  List<ActionVal> phaseBeforeVals = [];
  List<ActionVal> phaseAfterVals = [];
}

class QuestActionValsPage extends StatefulWidget {
  final int questId;
  final int phase;
  final Region region;
  const QuestActionValsPage({super.key, required this.questId, required this.phase, required this.region});

  @override
  State<QuestActionValsPage> createState() => _QuestActionValsPageState();
}

class _QuestActionValsPageState extends State<QuestActionValsPage>
    with RegionBasedState<_ResultData, QuestActionValsPage> {
  late final questId = widget.questId;
  late int phase = widget.phase;
  late List<int> phases = db.gameData.quests[widget.questId]?.phases.toList() ?? [];

  _ResultData result = _ResultData();

  @override
  void initState() {
    super.initState();
    region = widget.region;
    doFetchData();
  }

  List<ActionVal> parseVals(List? vals) {
    if (vals == null) return [];
    int count = vals.length ~/ 2;
    return [
      for (int index = 0; index < count; index++)
        (command: QuestAfterActionCommand.fromValue(int.parse(vals[index * 2])), value: vals[index * 2 + 1]),
    ];
  }

  @override
  Future<_ResultData?> fetchData(Region? r, {Duration? expireAfter}) async {
    if (widget.questId == 0) return null;
    final phase = this.phase;
    try {
      final entity = await AtlasApi.rawQuest(widget.questId, phase, region: r ?? Region.jp, expireAfter: expireAfter);
      final _result = _ResultData()
        ..phase = phase
        ..questBeforeVals = parseVals(entity?["mstQuest"]?["beforeActionVals"])
        ..questAfterVals = parseVals(entity?["mstQuest"]?["afterActionVals"])
        ..phaseBeforeVals = parseVals(entity?["mstQuestPhaseDetail"]?["beforeActionVals"])
        ..phaseAfterVals = parseVals(entity?["mstQuestPhaseDetail"]?["afterActionVals"]);
      return _result;
    } catch (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('parse action vals failed', e, s);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quest = db.gameData.quests[questId];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Action Vals'),
        actions: [
          IconButton(
            onPressed: () => doFetchData(expireAfter: Duration.zero),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Quest $questId\n${quest?.lNameWithChapter ?? ""}'.trim(), textAlign: TextAlign.center),
            ),
          ),
          FilterGroup<int>(
            options: {0, ...phases, phase}.toList(),
            values: FilterRadioData.nonnull(phase),
            combined: true,
            onFilterChanged: (optionData, lastChanged) {
              setState(() {
                phase = optionData.radioValue ?? phase;
              });
              doFetchData();
            },
          ),
          Expanded(child: buildBody(context)),
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, _ResultData data) {
    return ListView(
      children: [
        if (phase != 0) ...[
          buildGroup('[phase] Before', data.phaseBeforeVals),
          buildGroup('[phase] After', data.phaseAfterVals),
        ],
        buildGroup('[quest] Before', data.questBeforeVals),
        buildGroup('[quest] After', data.questAfterVals),
      ],
    );
  }

  Widget buildGroup(String title, List<ActionVal> vals) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(title: Text(title)),
            if (vals.isNotEmpty) kDefaultDivider,
            ...divideList([
              for (final (index, val) in vals.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. ${val.command.name}'),
                      const SizedBox(height: 4),
                      Text('     ${val.value}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
            ], kIndentDivider),
          ],
        ),
      ),
    );
  }
}
