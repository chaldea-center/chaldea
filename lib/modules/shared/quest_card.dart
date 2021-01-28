//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;

  const QuestCard({Key? key, required this.quest}) : super(key: key);

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest get quest => widget.quest;
  bool showTrueName = false;

  @override
  Widget build(BuildContext context) {
    String questName = '${quest.name}';
    if (quest.nameJp?.isNotEmpty == true)
      questName = questName + '/' + quest.nameJp;
    String chapter =
        db.gameData.events.mainRecords[quest.chapter]?.localizedName ??
            quest.chapter;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: divideTiles(
            [
              CustomTile(
                title: Center(
                  child: AutoSizeText(
                    '$chapter\n'
                    '$questName\n'
                    '${S.of(context).game_kizuna} ${quest.bondPoint}  '
                    '${S.of(context).game_experience} ${quest.experience}',
                    maxLines: 4,
                    maxFontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    color: showTrueName ? Colors.blue : null,
                  ),
                  onTap: () => setState(() => showTrueName = !showTrueName),
                ),
              ),
              ..._buildBattles(quest.battles)
            ],
            divider: Divider(height: 3, thickness: 0.5),
          ).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildBattles(List<Battle> battles) {
    List<Widget> children = [];
    for (int i = 0; i < battles.length; i++) {
      final battle = battles[i];
      String place = battle.place;
      if (battle.placeJp?.isNotEmpty == true)
        place = place + '/' + battle.placeJp;
      children.add(Row(children: <Widget>[
        Text('  ${i + 1}/${battles.length}  '),
        Expanded(flex: 1, child: Center(child: Text('AP ${battle.ap}'))),
        Expanded(
          flex: 4,
          child: Center(child: AutoSizeText('$place', maxLines: 1)),
        ),
      ]));
      for (int j = 0; j < battle.enemies.length; j++) {
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.ideographic,
          children: <Widget>[
            Text('  ${j + 1}  '),
            Expanded(child: _buildWave(battle.enemies[j]))
          ],
        ));
      }

      final drops = _getDropsWidget(battle);
      if (drops != null)
        children.add(Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(S.current.game_drop + ':  '),
              Expanded(child: drops)
            ],
          ),
        ));
    }

    return children;
  }

  Widget _buildWave(List<Enemy?> enemies) {
    List<Widget> enemyWidgets = enemies.map((enemy) {
      if (enemy == null) return Container();
      List<String> lines = [];
      for (int i = 0; i < enemy.hp.length; i++) {
        final String? name = showTrueName
            ? enemy.name[i]
            : (enemy.shownName[i] ?? enemy.name[i]);
        if (name?.isNotEmpty == true) lines.add(name!);
        lines.add('${enemy.className[i]} ${enemy.hp[i]}');
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lines
            .map((e) => AutoSizeText(e,
                maxFontSize: 14, maxLines: 1, textAlign: TextAlign.center))
            .toList(),
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

  Widget? _getDropsWidget(Battle battle) {
    Map<String, String> dropTexts = {};
    if (widget.quest.isFree) {
      final glpk = db.gameData.glpk;
      int colIndex = glpk.colNames.indexOf(quest.indexKey);

      // not list in glpk
      if (colIndex < 0)
        battle.drops.keys.forEach((element) => dropTexts[element] = '');

      Map<String, double> apRates = {};
      for (var i = 0; i < glpk.rowNames.length; i++) {
        if (glpk.matrix[i][colIndex] > 0) {
          apRates[glpk.rowNames[i]] = glpk.matrix[i][colIndex];
        }
      }
      final entryList = apRates.entries.toList()
        ..sort((a, b) => (a.value - b.value).sign.toInt());
      entryList.forEach((entry) {
        String v = entry.value >= 1000
            ? entry.value.toString()
            : entry.value.toStringAsPrecision(4);
        dropTexts[entry.key] = '${v}AP';
      });
    } else {
      battle.drops.forEach((key, value) => dropTexts[key] = '*$value');
    }
    if (dropTexts.isEmpty) {
      return null;
    }
    return Center(
      child: Wrap(
        spacing: 3,
        runSpacing: 4,
        children: dropTexts.entries
            .map((entry) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    db.getIconImage(entry.key, width: 28),
                    Text(entry.value, style: TextStyle(fontSize: 14))
                  ],
                ))
            .toList(),
      ),
    );
  }
}
