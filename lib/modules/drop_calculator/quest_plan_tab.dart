//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestPlanTab extends StatefulWidget {
  final GLPKSolution? solution;

  const QuestPlanTab({Key? key, this.solution}) : super(key: key);

  @override
  _QuestPlanTabState createState() => _QuestPlanTabState();
}

class _QuestPlanTabState extends State<QuestPlanTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    widget.solution?.countVars?.forEach((variable) {
      final Quest? quest = db.gameData.freeQuests[variable.name];
      children.add(Container(
        decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context))),
        child: ValueStatefulBuilder<bool>(
            value: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CustomTile(
                    title: Text(
                        quest?.localizedKey(variable.name) ?? variable.name),
                    subtitle: Text(variable.detail.entries
                        .map((e) => '${Item.localizedNameOf(e.key)}*${e.value}')
                        .join(', ')),
                    trailing: Text('${variable.value}*${variable.cost} AP'),
                    onTap: () {
                      state.value = !state.value;
                      state.updateState();
                    },
                  ),
                  if (state.value && widget.solution?.params != null)
                    widget.solution!.params.blacklist.contains(variable.name)
                        ? TextButton.icon(
                            onPressed: () {
                              setState(() {
                                widget.solution!.params.blacklist
                                    .remove(variable.name);
                              });
                            },
                            icon: Icon(Icons.clear, color: Colors.black),
                            label: Text(
                              S.of(context).remove_from_blacklist,
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : TextButton.icon(
                            onPressed: () {
                              setState(() {
                                widget.solution!.params.blacklist
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
        Expanded(child: ListView(children: children))
      ],
    );
  }
}
