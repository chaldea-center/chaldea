import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;

  const QuestCard({Key key, @required this.quest})
      : assert(quest != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: divideTiles(
            [
              for (var i = 0; i < quest.battles.length; i++) ...[
                Center(
                  child: AutoSizeText(
                    '${quest.chapter}\n'
                    '${quest.battles[i].placeCn}-${quest.nameCn}\n'
                    '${quest.battles[i].placeJp}-${quest.nameJp}\n'
                    '羁绊 ${quest.bondPoint}  '
                    '经验 ${quest.experience}',
                    maxLines: 4,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (quest.battles.length > 1)
                  Center(child: Text('Session ${i + 1}')),
                for (var j = 0; j < quest.battles[i].enemies.length; j++)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.ideographic,
                      children: <Widget>[
                        Text('  ${j + 1}  '),
                        Expanded(child: _buildWave(quest.battles[i].enemies[j]))
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('掉落: '),
                      Expanded(
                          child: AutoSizeText(
                        getDropsText(),
                        maxFontSize: 14,
                      ))
                    ],
                  ),
                )
              ]
            ],
            divider: Divider(height: 1, thickness: 0.5),
          ).toList(),
        ),
      ),
    );
  }

  String getDropsText() {
    final glpk = db.gameData.glpk;
    final colIndex = glpk.colNames.indexOf(quest.nameJp);
    if (colIndex < 0) {
      return 'no drops.';
    }
    Map<String, double> apRates = {};
    for (var i = 0; i < glpk.rowNames.length; i++) {
      if (glpk.matrix[i][colIndex] > 0) {
        apRates[glpk.rowNames[i]] = glpk.matrix[i][colIndex];
      }
    }
    final entryList = apRates.entries.toList()
      ..sort((a, b) => (a.value - b.value).sign.toInt());
    return entryList.map((e) => '${e.key} ${e.value}AP').join(', ');
  }

  Widget _buildWave(List<Enemy> enemies) {
    List<Widget> enemyWidgets = enemies.map((enemy) {
      return enemy == null
          ? Container()
          : AutoSizeText(
              '${enemy.shownName}\n'
              '${enemy.className} ${enemy.hp}',
              maxFontSize: 14,
              maxLines: 2,
              textAlign: TextAlign.center,
            );
    }).toList();
    while (enemyWidgets.length % 3 != 0) {
      enemyWidgets.add(Container());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(enemyWidgets.length ~/ 3, (i) {
        return Row(
          children: <Widget>[
            Expanded(child: enemyWidgets[i * 3 + 2]),
            Expanded(child: enemyWidgets[i * 3 + 1]),
            Expanded(child: enemyWidgets[i * 3]),
          ],
        );
      }),
    );
  }
}
