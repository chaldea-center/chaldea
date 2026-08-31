import 'package:chaldea/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'runtime.dart';

/// Configure [AutoBattleOptions.battleMissionValueDict] submitted with each
/// battle result (win) request.
///
/// Candidates are extracted at runtime from [GameTimerData.battleMissionValues],
/// keyed by `detail.targetIds.single` with candidate values `cond.targetNum`.
class BattleMissionValuePage extends StatefulWidget {
  final FakerRuntime runtime;
  final AutoBattleOptions options;
  final QuestPhase questPhase;

  const BattleMissionValuePage({super.key, required this.runtime, required this.options, required this.questPhase});

  @override
  State<BattleMissionValuePage> createState() => _BattleMissionValuePageState();
}

class _BattleMissionValuePageState extends State<BattleMissionValuePage> {
  FakerRuntime get runtime => widget.runtime;
  AutoBattleOptions get options => widget.options;
  QuestPhase get questPhase => widget.questPhase;

  MasterMission? _selectedMasterMission;

  Map<int, List<BattleMissionValueEntry>> get _allEntries => runtime.gameData.timerData.battleMissionValues;

  /// Entries of the selected master mission, grouped by key.
  Map<int, List<BattleMissionValueEntry>> get _missionEntries {
    final mm = _selectedMasterMission;
    if (mm == null) return {};
    return {
      for (final e in _allEntries.entries)
        if (e.value.any((v) => v.masterMission == mm)) e.key: e.value.where((v) => v.masterMission == mm).toList(),
    };
  }

  bool _matchQuest(List<int> targetQuestIndividualities) {
    if (targetQuestIndividualities.isEmpty) return true;
    return NiceTrait.hasAllTraits(questPhase.questIndividuality, targetQuestIndividualities);
  }

  void _editValue(int key) {
    InputCancelOkDialog.number(
      title: 'Value for key $key',
      initValue: options.battleMissionValueDict[key],
      onSubmit: (v) {
        setState(() {
          options.battleMissionValueDict[key] = v;
        });
      },
    ).showDialog(context);
  }

  void _addCustom() {
    InputCancelOkDialog.number(
      title: 'Custom Key',
      hintText: 'battleMissionValue key',
      onSubmit: (key) {
        InputCancelOkDialog.number(
          title: 'Value for key $key',
          initValue: options.battleMissionValueDict[key],
          onSubmit: (v) {
            setState(() {
              options.battleMissionValueDict[key] = v;
            });
          },
        ).showDialog(context);
      },
    ).showDialog(context);
  }

  void _autoFillMax() {
    final dict = options.battleMissionValueDict;
    setState(() {
      for (final e in _missionEntries.entries) {
        if (!e.value.any((v) => _matchQuest(v.targetQuestIndividualities))) continue;
        dict[e.key] = Maths.max(e.value.map((v) => v.targetNum));
      }
    });
  }

  void _clearAll() {
    SimpleConfirmDialog(
      title: const Text('Clear All'),
      onTapOk: () {
        setState(() {
          options.battleMissionValueDict.clear();
        });
      },
    ).showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final validMasterMissionIds = {for (final entry in _allEntries.values.expand((e) => e)) entry.masterMission.id};
    final masterMissions = runtime.gameData.timerData.masterMissions.values
        .where((e) => validMasterMissionIds.contains(e.id))
        .toList();
    masterMissions.sort((a, b) => b.id.compareTo(a.id));

    final missionEntries = _missionEntries;
    final extractedKeys = missionEntries.keys.toSet();
    final customEntries = options.battleMissionValueDict.entries.where((e) => !extractedKeys.contains(e.key)).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle Mission Values'),
        actions: [
          IconButton(
            tooltip: 'Auto Fill (max)',
            onPressed: missionEntries.isEmpty ? null : _autoFillMax,
            icon: const Icon(Icons.auto_fix_high),
          ),
          IconButton(
            tooltip: 'Clear All',
            onPressed: options.battleMissionValueDict.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: ListView(
        children: [
          TileGroup(
            header: S.current.quest,
            children: [
              ListTile(
                dense: true,
                title: const Text('Current Quest'),
                subtitle: Text('${questPhase.lDispName} (${options.questId}/${options.questPhase})'),
                trailing: const Tooltip(message: 'Quest indiv filter active', child: Icon(Icons.check)),
                onTap: questPhase.routeTo,
              ),
            ],
          ),
          TileGroup(
            header: S.current.master_mission,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: DropdownButtonFormField<MasterMission?>(
                  initialValue: _selectedMasterMission,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Not selected')),
                    for (final mm in masterMissions)
                      DropdownMenuItem(value: mm, child: Text('#${mm.id} · ${mm.missions.length} missions')),
                  ],
                  onChanged: (v) => setState(() => _selectedMasterMission = v),
                ),
              ),
            ],
          ),
          if (_selectedMasterMission != null) ...[
            TileGroup(
              header: 'Mission Values',
              children: [
                for (final key in missionEntries.keys.toList()..sort())
                  _buildKeyTile(context, key, missionEntries[key]!),
                if (missionEntries.isEmpty)
                  const ListTile(dense: true, title: Text('No battleMissionValue missions in this MasterMission')),
              ],
            ),
          ],
          TileGroup(
            header: 'Custom Entries',
            children: [
              for (final e in customEntries) _buildCustomTile(e),
              ListTile(
                dense: true,
                title: const Text('Add custom key-value'),
                leading: const Icon(Icons.add),
                onTap: _addCustom,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Non-empty dict will be submitted with each battle result (win) request. '
              'A confirmation dialog is shown when the battle loop starts.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyTile(BuildContext context, int key, List<BattleMissionValueEntry> entries) {
    final dict = options.battleMissionValueDict;
    final int? cur = dict[key];
    final candidates = entries.map((e) => e.targetNum).toSet().toList()..sort();
    final questMatched = entries.any((e) => _matchQuest(e.targetQuestIndividualities));
    final distinctTraits = <int>{for (final e in entries) ...e.targetQuestIndividualities};
    final missionNames = entries.reversed.map((e) => e.mission.name).toSet().toList();

    final subtitleSpans = <InlineSpan>[
      for (final name in missionNames.take(2)) TextSpan(text: '$name\n'),
      if (missionNames.length > 2) TextSpan(text: '... +${missionNames.length - 2} missions\n'),
      if (distinctTraits.isNotEmpty) ...[
        const TextSpan(text: 'Required: '),
        ...SharedBuilder.traitSpans(context: context, traits: distinctTraits.toList(), useAndJoin: true),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text('Key: $key'),
          subtitle: subtitleSpans.isEmpty ? null : Text.rich(TextSpan(children: subtitleSpans)),
          // trailing:
        ),
        ListTile(
          title: Wrap(
            spacing: 8,
            children: [
              for (final v in candidates)
                ChoiceChip(
                  label: Text('$v'),
                  selected: cur == v,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        dict[key] = v;
                      } else {
                        dict.remove(key);
                      }
                    });
                  },
                ),
              // custom value overriding extracted candidates
              if (cur != null && !candidates.contains(cur))
                InputChip(
                  label: Text('custom: $cur'),
                  selected: cur == dict[key],
                  onPressed: () => _editValue(key),
                  onDeleted: () => setState(() => dict.remove(key)),
                ),
              if (!questMatched)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Quest indiv not matched',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit value',
                visualDensity: VisualDensity.compact,
                onPressed: () => _editValue(key),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                onPressed: dict.containsKey(key) ? () => setState(() => dict.remove(key)) : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTile(MapEntry<int, int> entry) {
    final dict = options.battleMissionValueDict;
    return ListTile(
      dense: true,
      title: Text('Key: ${entry.key}'),
      subtitle: Text('Value: ${entry.value}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit value',
            visualDensity: VisualDensity.compact,
            onPressed: () => _editValue(entry.key),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => dict.remove(entry.key)),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
