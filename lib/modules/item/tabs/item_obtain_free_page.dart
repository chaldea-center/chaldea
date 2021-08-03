import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class ItemObtainFreeTab extends StatefulWidget {
  final String itemKey;

  const ItemObtainFreeTab({Key? key, required this.itemKey}) : super(key: key);

  @override
  _ItemObtainFreeTabState createState() => _ItemObtainFreeTabState();
}

class _ItemObtainFreeTabState extends State<ItemObtainFreeTab> {
  bool sortByAP = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(S.current.quest),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildSortRadio(true),
              buildSortRadio(false),
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
            child: ListView(
                children: divideTiles([
          ...buildQuests(),
          ListTile(
            subtitle: Center(
              child: Text(
                Localized.freeDropRateChangedHint.localized,
              ),
            ),
          )
        ])))
      ],
    );
  }

  Widget buildSortRadio(bool value) {
    return RadioWithLabel(
      value: value,
      groupValue: sortByAP,
      label: Text(
        value ? S.current.ap_efficiency : S.current.drop_rate,
        style: value == sortByAP
            ? null
            : TextStyle(color: Theme.of(context).textTheme.caption?.color),
      ),
      onChanged: (v) => setState(() => sortByAP = v ?? sortByAP),
    );
  }

  List<Widget> buildQuests() {
    final glpk = db.gameData.glpk;
    int rowIndex = glpk.rowNames.indexOf(widget.itemKey);
    if (rowIndex < 0) {
      return [ListTile(title: Text(S.of(context).item_no_free_quests))];
    }
    final apRates = glpk.matrix[rowIndex];
    List<List> tmp = [];
    for (var i = 0; i < glpk.jpMaxColNum; i++) {
      if (apRates[i] > 0) {
        String questName = glpk.colNames[i];
        final apRate = apRates[i], dropRate = glpk.costs[i] / apRates[i];
        final dropRateString = (dropRate * 100).toStringAsFixed(2),
            apRateString = apRate.toStringAsFixed(2);
        final quest = db.gameData.freeQuests[questName];

        final child = ValueStatefulBuilder<bool>(
            initValue: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.localizedKey ??
                        Quest.getDailyQuestName(questName)),
                    subtitle: Text('cost ${glpk.costs[i]}AP.  ' +
                        (sortByAP
                            ? '${S.current.drop_rate} $dropRateString%.'
                            : '${S.current.ap_efficiency} $apRateString AP.')),
                    trailing: Text(
                        sortByAP ? '$apRateString AP' : '$dropRateString%'),
                    onTap: quest == null
                        ? null
                        : () => state.setState(() {
                              state.value = !state.value;
                            }),
                  ),
                  if (state.value && quest != null) QuestCard(quest: quest)
                ],
              );
            });
        tmp.add([apRate, dropRate, child]);
      }
    }

    tmp.sort((a, b) {
      return ((sortByAP ? a[0] - b[0] : b[1] - a[1]) as double).sign.toInt();
    });
    return tmp.map((e) => e.last as Widget).toList();
  }
}
