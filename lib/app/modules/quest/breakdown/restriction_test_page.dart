import 'dart:convert';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/quest/quest_list.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

import 'restriction.dart';

class QuestRestrictionTestPage extends StatefulWidget {
  const QuestRestrictionTestPage({super.key});

  @override
  State<QuestRestrictionTestPage> createState() => _QuestRestrictionTestPageState();
}

class _QuestRestrictionTestPageState extends State<QuestRestrictionTestPage> {
  List<RestrictionReviewCase> _cases = [];
  bool _loading = true;
  Object? _error;
  int? _type;
  int? _range;
  int? _vals;
  int? _vals2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tables = await Future.wait([
        for (final table in ['mstRestriction', 'mstQuestRestriction', 'mstCommonRelease'])
          AtlasApi.mstData(table, (json) => json, region: Region.jp, expireAfter: refresh ? Duration.zero : null),
      ]);
      if (tables.any((table) => table == null)) throw StateError(S.current.error_no_data_found);
      final cases = RestrictionReviewCase.fromRaw(
        restrictions: tables[0]!,
        questRestrictions: tables[1]!,
        commonReleases: tables[2]!,
      );
      if (!mounted) return;
      setState(() {
        _cases = cases;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _matches(RestrictionReviewCase entry) {
    return entry.matches(type: _type, range: _range, vals: _vals, vals2: _vals2);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _cases.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.quest_restriction} (JP)'),
        actions: [
          IconButton(
            onPressed: _loading ? null : () => _loadData(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_error'),
                    RefreshButton(onPressed: () => _loadData(refresh: true)),
                  ],
                ),
              ),
            )
          : visible.isEmpty
          ? Center(child: Text(S.current.error_no_data_found))
          : InheritSelectionArea(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: visible.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) => _buildCase(visible[index]),
              ),
            ),
      bottomNavigationBar: _buildFilters(visible.length),
    );
  }

  Widget _buildCase(RestrictionReviewCase entry) {
    final re = entry.restriction;
    final questIds = entry.questIds;
    final typeName = RestrictionType.fromValue(entry.rawType)?.name ?? 'unknown';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '#${re.id}  type=${entry.rawType} ($typeName)\n'
                'rangeType=${entry.rawRange} (${re.rangeType.name})\n'
                'vals=${re.targetVals}  vals2=${re.targetVals2}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              onPressed: () => _showMessages(entry),
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'title / name / msg',
            ),
            IconButton(
              onPressed: questIds.isEmpty
                  ? null
                  : () => router.pushPage(QuestListPage.ids(ids: questIds, title: 'Restriction #${re.id}')),
              icon: Badge(label: Text('${questIds.length}'), child: const Icon(Icons.list_alt)),
              tooltip: '${S.current.quest} (${questIds.length})',
            ),
          ],
        ),
        const SizedBox(height: 4),
        QuestRestrictionDescriptor(restriction: QuestPhaseRestriction(restriction: re), showReleaseHint: false),
      ],
    );
  }

  void _showMessages(RestrictionReviewCase entry) {
    final re = entry.restriction;
    final messageGroups = <String, List<RestrictionReviewQuest>>{};
    for (final quest in entry.questRestrictions) {
      final restriction = quest.restriction;
      final key = jsonEncode([restriction.title, restriction.noticeMessage, restriction.dialogMessage, quest.script]);
      messageGroups.putIfAbsent(key, () => []).add(quest);
    }
    SimpleConfirmDialog(
      title: Text('Restriction #${re.id}'),
      showCancel: false,
      scrollable: true,
      content: InheritSelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('name: ${re.name}'),
            for (final quests in messageGroups.values) ...[
              const Divider(),
              Text(quests.map((quest) => '${quest.questId} / phase ${quest.phase}').join(', ')),
              for (final (field, message) in [
                ('title', quests.first.restriction.title),
                ('noticeMessage', quests.first.restriction.noticeMessage),
                ('dialogMessage', quests.first.restriction.dialogMessage),
              ])
                if (message.isNotEmpty) Text('$field:\n$message'),
              if (quests.first.script.isNotEmpty) Text('script: ${jsonEncode(quests.first.script)}'),
            ],
          ],
        ),
      ),
    ).showDialog(context);
  }

  Widget _buildFilters(int visibleCount) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('$visibleCount / ${_cases.length} restrictions', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: width,
                        child: _dropdown('type', _type, _cases.map((entry) => entry.rawType), (value) {
                          setState(() => _type = value);
                        }, label: (value) => '$value ${RestrictionType.fromValue(value)?.name ?? 'unknown'}'),
                      ),
                      SizedBox(
                        width: width,
                        child: _dropdown('range', _range, _cases.map((entry) => entry.rawRange), (value) {
                          setState(() => _range = value);
                        }, label: (value) => '$value ${RestrictionRangeType.values[value].name}'),
                      ),
                      SizedBox(
                        width: width,
                        child: _dropdown('vals.length', _vals, _cases.map((entry) => entry.shape.vals), (value) {
                          setState(() => _vals = value);
                        }),
                      ),
                      SizedBox(
                        width: width,
                        child: _dropdown('vals2.length', _vals2, _cases.map((entry) => entry.shape.vals2), (value) {
                          setState(() => _vals2 = value);
                        }),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String title,
    int? selected,
    Iterable<int> values,
    ValueChanged<int?> onChanged, {
    String Function(int)? label,
  }) {
    final options = {...values, ?selected}.toList()..sort();
    return InputDecorator(
      decoration: InputDecoration(
        labelText: title,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selected,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: null, child: Text(S.current.general_all)),
            for (final value in options)
              DropdownMenuItem(
                value: value,
                child: Text(label?.call(value) ?? '$value', overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: _loading ? null : onChanged,
        ),
      ),
    );
  }
}

typedef RestrictionReviewShape = ({int type, int range, int vals, int vals2});

class RestrictionReviewQuest {
  final int questId;
  final int phase;
  final QuestPhaseRestriction restriction;
  final Map<String, dynamic> script;

  const RestrictionReviewQuest({
    required this.questId,
    required this.phase,
    required this.restriction,
    required this.script,
  });
}

class RestrictionReviewCase {
  final Restriction restriction;
  final int rawType;
  final int rawRange;
  final List<RestrictionReviewQuest> questRestrictions;

  const RestrictionReviewCase({
    required this.restriction,
    required this.rawType,
    required this.rawRange,
    this.questRestrictions = const [],
  });

  RestrictionReviewShape get shape =>
      (type: rawType, range: rawRange, vals: restriction.targetVals.length, vals2: restriction.targetVals2.length);

  List<int> get questIds => {for (final quest in questRestrictions) quest.questId}.toList()..sort();

  bool matches({int? type, int? range, int? vals, int? vals2}) {
    final shape = this.shape;
    return (type == null || type == shape.type) &&
        (range == null || range == shape.range) &&
        (vals == null || vals == shape.vals) &&
        (vals2 == null || vals2 == shape.vals2);
  }

  static List<RestrictionReviewCase> fromRaw({
    required List<Map<String, dynamic>> restrictions,
    required List<Map<String, dynamic>> questRestrictions,
    required List<Map<String, dynamic>> commonReleases,
  }) {
    final questsByRestriction = <int, List<Map<String, dynamic>>>{};
    for (final quest in questRestrictions) {
      questsByRestriction.putIfAbsent(quest['restrictionId'] as int, () => []).add(quest);
    }
    final releasesById = <int, List<CommonRelease>>{};
    for (final raw in commonReleases) {
      final release = CommonRelease(
        id: raw['id'] as int,
        priority: raw['priority'] as int? ?? 0,
        condGroup: raw['condGroup'] as int? ?? 0,
        condType: CondType.fromId(raw['condType'] as int) ?? CondType.unknown,
        condId: raw['condId'] as int? ?? 0,
        condNum: raw['condNum'] as int? ?? 0,
      );
      releasesById.putIfAbsent(release.id, () => []).add(release);
    }
    final result = <RestrictionReviewCase>[];
    for (final raw in restrictions) {
      final typeValue = raw['type'] as int;
      final rangeValue = raw['rangeType'] as int;
      final nice = Restriction(
        id: raw['id'] as int,
        name: raw['name'] as String? ?? '',
        type: RestrictionType.fromValue(typeValue) ?? RestrictionType.none,
        rangeType: _enumByIndex(RestrictionRangeType.values, rangeValue),
        targetVals: List<int>.from(raw['targetVals'] as List? ?? []),
        targetVals2: List<int>.from(raw['targetVals2'] as List? ?? []),
      );
      final quests = questsByRestriction[nice.id] ?? [];
      final references = <RestrictionReviewQuest>[];
      for (final quest in quests) {
        final script = Map<String, dynamic>.from(quest['script'] as Map? ?? const {});
        final releaseId = script['commonReleaseId'] as int?;
        if (releaseId != null && !releasesById.containsKey(releaseId)) {
          throw FormatException('Missing commonReleaseId=$releaseId for restriction ${nice.id}');
        }
        references.add(
          RestrictionReviewQuest(
            questId: quest['questId'] as int,
            phase: quest['phase'] as int,
            script: script,
            restriction: QuestPhaseRestriction(
              restriction: nice,
              frequencyType: _enumByIndex(FrequencyType.values, quest['frequencyType'] as int? ?? 0),
              title: quest['title'] as String? ?? '',
              dialogMessage: quest['dialogMessage'] as String? ?? '',
              noticeMessage: quest['noticeMessage'] as String? ?? '',
              script: releaseId == null
                  ? null
                  : QuestPhaseRestrictionScript(releaseConditions: releasesById[releaseId]),
            ),
          ),
        );
      }
      result.add(
        RestrictionReviewCase(
          restriction: nice,
          rawType: typeValue,
          rawRange: rangeValue,
          questRestrictions: references,
        ),
      );
    }
    result.sort((a, b) {
      final byType = a.rawType.compareTo(b.rawType);
      if (byType != 0) return byType;
      final byRange = a.rawRange.compareTo(b.rawRange);
      return byRange != 0 ? byRange : a.restriction.id.compareTo(b.restriction.id);
    });
    return result;
  }

  static T _enumByIndex<T extends Enum>(List<T> values, int value) {
    if (value < 0 || value >= values.length) throw FormatException('Unknown ${T.toString()} value: $value');
    return values[value];
  }
}
