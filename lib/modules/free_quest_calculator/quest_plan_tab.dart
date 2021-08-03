import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestPlanTab extends StatefulWidget {
  final GLPKSolution? solution;

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
    widget.solution?.countVars.forEach((variable) {
      final Quest? quest = db.gameData.freeQuests[variable.name];
      children.add(Container(
        decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context))),
        child: ValueStatefulBuilder<bool>(
            initValue: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.localizedKey ??
                        Quest.getDailyQuestName(variable.name)),
                    subtitle: buildRichText(variable.detail.entries),
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
                            icon: Icon(Icons.add, color: Colors.redAccent),
                            label: Text(
                              S.of(context).add_to_blacklist,
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                  if (state.value && quest != null) QuestCard(quest: quest),
                ],
              );
            }),
      ));
    });
    children.add(ListTile(
      subtitle: Center(
        child: Text(Localized.freeDropRateChangedHint.localized),
      ),
    ));
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
  Widget buildRichText(Iterable<MapEntry<String, dynamic>> entries) {
    List<InlineSpan> children = [];
    for (final entry in entries) {
      children.add(WidgetSpan(
        child: Opacity(
          opacity: 0.75,
          child: db.getIconImage(entry.key, height: 18),
        ),
      ));
      children.add(TextSpan(text: '*${entry.value} '));
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
