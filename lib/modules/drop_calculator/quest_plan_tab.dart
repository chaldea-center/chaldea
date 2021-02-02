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
      final quest = db.gameData.freeQuests[variable.name];
      children.add(Container(
        decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context))),
        child: ValueStatefulBuilder<bool>(
            value: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTile(
                    title: Text(variable.name),
                    subtitle: Text(variable.detail.entries
                        .map((e) => '${e.key}*${e.value}')
                        .join(', ')),
                    trailing: Text('${variable.value}*${variable.cost} AP'),
                    onTap: quest == null
                        ? null
                        : () {
                            state.value = !state.value;
                            state.updateState();
                          },
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
