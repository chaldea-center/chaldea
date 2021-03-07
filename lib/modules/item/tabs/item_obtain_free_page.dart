//@dart=2.12
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio<bool>(
              value: true,
              groupValue: sortByAP,
              onChanged: (v) => setState(() => sortByAP = v ?? sortByAP),
            ),
            GestureDetector(
              onTap: () => setState(() => sortByAP = true),
              child: Text(S.of(context).ap_efficiency),
            ),
            Radio<bool>(
              value: false,
              groupValue: sortByAP,
              onChanged: (v) => setState(() => sortByAP = v ?? sortByAP),
            ),
            GestureDetector(
              onTap: () => setState(() => sortByAP = false),
              child: Text(S.of(context).drop_rate),
            ),
          ],
        ),
        Divider(height: 1),
        Expanded(child: ListView(children: divideTiles(buildQuests())))
      ],
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
            value: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTile(
                    title: Text(quest?.localizedKey ?? questName),
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
