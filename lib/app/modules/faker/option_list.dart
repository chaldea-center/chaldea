import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';

class BattleOptionListPage extends StatefulWidget {
  final AutoLoginData data;
  const BattleOptionListPage({super.key, required this.data});

  @override
  State<BattleOptionListPage> createState() => _BattleOptionListPageState();
}

class _BattleOptionListPageState extends State<BattleOptionListPage> {
  late final data = widget.data;
  bool sorting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configs'),
        actions: [
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
          )
        ],
      ),
      body: sorting
          ? ReorderableListView(
              children: [
                for (final (index, option) in data.battleOptions.indexed) buildOne(index, option),
              ],
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
          : ListView(
              children: [
                for (final (index, option) in data.battleOptions.indexed) buildOne(index, option),
              ],
            ),
    );
  }

  Widget buildOne(int index, AutoBattleOptions option) {
    final quest = db.gameData.quests[option.questId];
    final subtitle = '${quest?.lDispName.setMaxLines(1) ?? option.questId}'
        ' @${quest?.war?.lShortName.setMaxLines(1)}';

    return RadioListTile<int>(
      key: ObjectKey(option),
      value: index,
      dense: true,
      groupValue: data.curBattleOptionIndex,
      onChanged: sorting
          ? null
          : (v) {
              setState(() {
                if (v != null) {
                  data.curBattleOptionIndex = v;
                }
              });
            },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text('No.${index + 1} ${option.name.isEmpty ? "<no name>" : option.name}'),
      subtitle: Text(subtitle),
      secondary: sorting
          ? null
          : Wrap(
              children: [
                IconButton(
                  onPressed: () {
                    InputCancelOkDialog(
                      title: S.current.rename,
                      text: option.name,
                      onSubmit: (s) {
                        option.name = s.trim();
                        if (mounted) setState(() {});
                      },
                    ).showDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: S.current.rename,
                ),
                IconButton(
                  onPressed: data.battleOptions.length <= 1
                      ? null
                      : () {
                          SimpleCancelOkDialog(
                            title: Text(S.current.delete),
                            onTapOk: () {
                              data.battleOptions.remove(option);
                              data.curBattleOptionIndex; // update index
                              if (mounted) setState(() {});
                            },
                          ).showDialog(context);
                        },
                  icon: const Icon(Icons.delete),
                  tooltip: S.current.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
    );
  }
}
