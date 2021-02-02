//@dart=2.12
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class QuestEfficiencyTab extends StatefulWidget {
  final GLPKSolution? solution;

  const QuestEfficiencyTab({Key? key, required this.solution})
      : super(key: key);

  @override
  _QuestEfficiencyTabState createState() => _QuestEfficiencyTabState();
}

class _QuestEfficiencyTabState extends State<QuestEfficiencyTab> {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    widget.solution?.weightVars?.forEach((variable) {
      final String questKey = variable.name;
      final Map<String, double> drops = variable.detail as Map<String, double>;
      final Quest? quest = db.gameData.freeQuests[questKey];
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
                    title: Text(questKey),
                    subtitle: Text(drops.entries.map((e) {
                      String v = e.value.toStringAsFixed(3);
                      while (v.contains('.') && v[v.length - 1] == '0') {
                        v = v.substring(0, v.length - 1);
                      }
                      return '${e.key}*$v';
                    }).join(', ')),
                    trailing: Text(sum(drops.values).toStringAsFixed(3)),
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
      children: [
        ListTile(
          onTap: () {},
          title: Text(S.of(context).quest),
          trailing: Text(S.of(context).efficiency),
        ),
        Expanded(child: ListView(children: children))
      ],
    );
  }
}
