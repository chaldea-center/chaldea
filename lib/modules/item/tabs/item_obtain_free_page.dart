import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/quest_card.dart';

class ItemObtainFreeTab extends StatefulWidget {
  final String itemKey;

  const ItemObtainFreeTab({Key key, this.itemKey}) : super(key: key);

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
            Radio(
                value: true,
                groupValue: sortByAP,
                onChanged: (v) => setState(() => sortByAP = v)),
            Text('AP效率'),
            Radio(
                value: false,
                groupValue: sortByAP,
                onChanged: (v) => setState(() => sortByAP = v)),
            Text('掉率'),
          ],
        ),
        Divider(height: 1),
        Expanded(
            child: ListView(
          children: divideTiles(getQuests()),
        ))
      ],
    );
  }

  List<Widget> getQuests() {
    final glpk = db.gameData.glpk;
    int rowIndex = glpk.rowNames.indexOf(widget.itemKey);
    if (rowIndex < 0) {
      return [ListTile(title: Text('no free'))];
    }
    final apRates = glpk.matrix[rowIndex];
    List<List> tmp = [];
    for (var i = 0; i < glpk.colNames.length; i++) {
      if (apRates[i] > 0) {
        String name = glpk.colNames[i];
        final apRate = apRates[i], dropRate = glpk.coeff[i] / apRates[i];
        final quest = db.gameData.freeQuests[name];
        String title = quest?.placeCn ?? name;
        if (['后山', '群岛'].contains(title)) {
          // 下总国后山&四章群岛 two quests
          title = '$title-${quest.nameCn}';
        }
        final child = ValueStatefulBuilder(
            value: false,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomTile(
                    title: Text(title),
                    subtitle: Text('cost ${glpk.coeff[i]}AP.  ' +
                        (sortByAP
                            ? '掉率 ${(dropRate * 100).toStringAsFixed(2)}%.'
                            : '效率 ${apRate}AP/个.')),
                    trailing: Text(sortByAP
                        ? '${apRate}AP/个'
                        : '${(dropRate * 100).toStringAsFixed(2)}%'),
                    onTap: quest == null
                        ? null
                        : () {
                            state.setState(() {
                              state.value = !state.value;
                            });
                          },
                  ),
                  if (state.value) QuestCard(quest: quest)
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
