import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../generated/l10n.dart';
import '../enemy/quest_card.dart';

class QuestPlanTab extends StatefulWidget {
  final LPSolution? solution;

  const QuestPlanTab({super.key, this.solution});

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
              Text(S.current.ignore),
              const SizedBox(width: 4),
              ...ignoredItems.map((e) => Item.iconBuilder(context: context, item: db.gameData.items[e], width: 32))
            ],
          ),
        ),
      ));
    }
    for (final v in widget.solution?.countVars ?? []) {
      children.add(buildQuest(v));
    }
    if (widget.solution?.countVars.isNotEmpty == true) {
      children.add(SFooter(S.current.fq_plan_decimal_hint));
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
          child: ListTile(
            title: Text('${S.current.total_counts}: ${widget.solution?.totalNum ?? "-"}'),
            trailing: Text('${S.current.total_ap}: ${widget.solution?.totalCost ?? "-"}'),
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

  Widget buildQuest(LPVariable variable) {
    final questId = variable.name;
    final Quest? quest = db.gameData.getQuestPhase(questId) ?? db.gameData.quests[questId];
    Widget child = ValueStatefulBuilder<bool>(
      key: Key('plan_quest_$questId'),
      initValue: false,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomTile(
              title: Text(quest?.lDispName ?? 'Quest $questId'),
              subtitle: buildRichDetails(variable.detail.entries),
              trailing: Text('${variable.value}*${variable.cost} AP'),
              onTap: () {
                state.value = !state.value;
                state.updateState();
              },
            ),
            if (state.value && widget.solution?.params != null)
              widget.solution!.params!.blacklist.contains(questId)
                  ? TextButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.solution!.params!.blacklist.remove(questId);
                        });
                      },
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary),
                      label: Text(
                        S.current.remove_from_blacklist,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.solution!.params!.blacklist.add(questId);
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.redAccent),
                      label: Text(
                        S.current.add_to_blacklist,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
            if (state.value)
              QuestCard(
                quest: quest,
                questId: questId,
                use6th: widget.solution?.params?.use6th,
              ),
          ],
        );
      },
    );
    return Container(
      decoration: BoxDecoration(border: Border(bottom: Divider.createBorderSide(context))),
      child: child,
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
        children.add(CenterWidgetSpan(
          child: Opacity(
            opacity: 0.75,
            child: db.getIconImage(db.gameData.items[entry.key]?.borderedIcon, height: 18),
          ),
        ));
      }
      String s = entry.value.abs() < 1 ? entry.value.toStringAsPrecision(1) : entry.value.floor().toString();
      children.add(TextSpan(text: '×$s '));
    }
    return Text.rich(
      TextSpan(children: children),
    );
  }
}
