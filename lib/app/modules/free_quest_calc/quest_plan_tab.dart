import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../enemy/quest_card.dart';

class QuestPlanTab extends StatefulWidget {
  final LPSolution? solution;

  const QuestPlanTab({Key? key, this.solution}) : super(key: key);

  @override
  _QuestPlanTabState createState() => _QuestPlanTabState();
}

class _QuestPlanTabState extends State<QuestPlanTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<int> ignoredItems = widget.solution?.getIgnoredKeys() ?? [];
    if (ignoredItems.isNotEmpty) {
      children.add(Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 3,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Ignored:'),
              ...ignoredItems.map((e) => Item.iconBuilder(
                  context: context, item: db2.gameData.items[e], width: 32))
            ],
          ),
        ),
      ));
    }
    widget.solution?.countVars.forEach((variable) {
      final QuestPhase? quest = db2.gameData.getQuestPhase(variable.name);
      children.add(Container(
        decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context))),
        child: ValueStatefulBuilder<bool>(
            key: Key('plan_quest_${variable.name}'),
            initValue: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.lDispName ?? 'Quest ${variable.name}'),
                    subtitle: buildRichDetails(variable.detail.entries),
                    trailing: Text('${variable.value}*${variable.cost} AP'),
                    onTap: () {
                      state.value = !state.value;
                      state.updateState();
                    },
                  ),
                  if (state.value && widget.solution?.params != null)
                    widget.solution!.params!.blacklist.contains(variable.name)
                        ? TextButton.icon(
                            onPressed: () {
                              setState(() {
                                widget.solution!.params!.blacklist
                                    .remove(variable.name);
                              });
                            },
                            icon: Icon(Icons.clear,
                                color: Theme.of(context).colorScheme.secondary),
                            label: Text(
                              S.of(context).remove_from_blacklist,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          )
                        : TextButton.icon(
                            onPressed: () {
                              setState(() {
                                widget.solution!.params!.blacklist
                                    .add(variable.name);
                              });
                            },
                            icon:
                                const Icon(Icons.add, color: Colors.redAccent),
                            label: Text(
                              S.current.add_to_blacklist,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                  if (state.value && quest != null)
                    QuestCard(
                      quest: quest,
                      use6th: widget.solution?.params?.use6th,
                    ),
                ],
              );
            }),
      ));
    });

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            title: Text(
                '${S.current.total_counts}: ${widget.solution?.totalNum ?? "-"}'),
            trailing: Text(
                '${S.current.total_ap}: ${widget.solution?.totalCost ?? "-"}'),
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: children,
          ),
        )
      ],
    );
  }

  // (icon name, display text)
  Widget buildRichDetails(Iterable<MapEntry<int, double>> entries) {
    List<InlineSpan> children = [];
    for (final entry in entries) {
      if (entry.key == Items.bondPointId) {
        children.add(TextSpan(text: S.current.bond));
      } else if (entry.key == Items.expPointId) {
        children.add(const TextSpan(text: 'EXP'));
      } else {
        children.add(WidgetSpan(
          child: Opacity(
            opacity: 0.75,
            child: db2.getIconImage(db2.gameData.items[entry.key]?.borderedIcon,
                height: 18),
          ),
        ));
      }
      String s = entry.value.abs() < 1
          ? entry.value.toStringAsPrecision(1)
          : entry.value.floor().toString();
      children.add(TextSpan(text: '*$s '));
    }
    final textTheme = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        children: children,
        style: textTheme.bodyText2?.copyWith(color: textTheme.caption?.color),
      ),
    );
  }
}
