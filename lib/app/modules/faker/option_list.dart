import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

class BattleOptionListPage extends StatefulWidget {
  final AutoLoginData data;
  final ValueChanged<({int index, AutoBattleOptions option})>? onSelected;
  const BattleOptionListPage({super.key, required this.data, this.onSelected});

  @override
  State<BattleOptionListPage> createState() => _BattleOptionListPageState();
}

class _BattleOptionListPageState extends State<BattleOptionListPage> {
  late final data = widget.data;
  bool sorting = false;

  bool get canEdit => widget.onSelected == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configs'),
        actions: canEdit
            ? [
                IconButton(
                  onPressed: () {
                    data.battleOptions.add(AutoBattleOptions());
                    data.curBattleOptionIndex = data.battleOptions.length - 1;
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  tooltip: S.current.add,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      sorting = !sorting;
                    });
                  },
                  icon: Icon(sorting ? Icons.done : Icons.sort),
                  tooltip: S.current.sort_order,
                ),
              ]
            : [],
      ),
      body: sorting && canEdit
          ? ReorderableListView(
              children: [for (final (index, option) in data.battleOptions.indexed) buildOne(index, option)],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  final selectedItem = data.curBattleOption;
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = data.battleOptions.removeAt(oldIndex);
                  data.battleOptions.insert(newIndex, item);
                  data.curBattleOptionIndex = data.battleOptions.indexOf(selectedItem);
                });
              },
            )
          : ListView(children: [for (final (index, option) in data.battleOptions.indexed) buildOne(index, option)]),
    );
  }

  String _describeQuest(int questId, int phase) {
    final quest = db.gameData.quests[questId];
    if (quest == null) return '$questId/$phase';
    final phaseDetail = db.gameData.questPhaseDetails[questId * 100 + phase];
    return [
      if (quest.warId == WarId.ordealCall || (quest.warId > 1000 && quest.isAnyFree))
        'Lv.${(phaseDetail?.recommendLv ?? quest.recommendLv)}',
      quest.lDispName.setMaxLines(1),
      if (quest.war != null) '@${quest.war?.lShortName.setMaxLines(1)}',
    ].join(' ');
  }

  Widget buildOne(int index, AutoBattleOptions option) {
    return RadioListTile<int>(
      key: ObjectKey(option),
      value: index,
      dense: true,
      groupValue: canEdit ? data.curBattleOptionIndex : null,
      onChanged: sorting
          ? null
          : (v) {
              if (widget.onSelected != null) {
                widget.onSelected!((index: index, option: option));
                Navigator.pop(context, (index: index, option: option));
              } else {
                setState(() {
                  if (v != null) {
                    data.curBattleOptionIndex = v;
                  }
                });
              }
            },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text('No.${index + 1} ${option.name.isEmpty ? "<no name>" : option.name}'),
      subtitle: Text(_describeQuest(option.questId, option.questPhase)),
      secondary: sorting || !canEdit
          ? null
          : Wrap(
              children: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(S.current.rename),
                      onTap: () {
                        InputCancelOkDialog(
                          title: S.current.rename,
                          text: option.name,
                          onSubmit: (s) {
                            option.name = s.trim();
                            if (mounted) setState(() {});
                          },
                        ).showDialog(this.context);
                      },
                    ),
                    PopupMenuItem(
                      child: Text(S.current.copy),
                      onTap: () {
                        data.battleOptions.add(AutoBattleOptions.fromJson(jsonDecode(jsonEncode(option))));
                        if (mounted) setState(() {});
                      },
                    ),
                    PopupMenuItem(
                      child: Text(S.current.delete),
                      onTap: () {
                        SimpleConfirmDialog(
                          title: Text(S.current.delete),
                          onTapOk: () {
                            data.battleOptions.remove(option);
                            data.curBattleOptionIndex; // update index
                            if (mounted) setState(() {});
                          },
                        ).showDialog(this.context);
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
