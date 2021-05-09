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
  late bool showTrueName;

  @override
  void initState() {
    super.initState();
    showTrueName = !Language.isCN;
  }

  @override
  Widget build(BuildContext context) {
    String questName = [
      quest.localizedName,
      if (!Language.isJP &&
          quest.nameJp != null &&
          quest.nameJp != quest.localizedName)
        quest.nameJp!
    ].join('/');
    String chapter = Localized.chapter.of(quest.chapter);
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: divideTiles(
            [
              CustomTile(
                title: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        chapter,
                        maxLines: 2,
                        maxFontSize: 14,
                        minFontSize: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      AutoSizeText(
                        questName,
                        maxLines: 2,
                        maxFontSize: 14,
                        minFontSize: 6,
                        textAlign: TextAlign.center,
                        // style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      AutoSizeText(
                        '${S.of(context).game_kizuna} ${quest.bondPoint}  '
                        '${S.of(context).game_experience} ${quest.experience}',
                        maxLines: 1,
                        maxFontSize: 14,
                        minFontSize: 6,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                trailing: InkWell(
                  child: Tooltip(
                    message:
                        showTrueName ? 'Show Display Name' : 'Show True Name',
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      color: showTrueName
                          ? Theme.of(context).accentColor
                          : Theme.of(context).hintColor,
                    ),
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
    Battle? lastBattle;
    for (int i = 0; i < battles.length; i++) {
      final battle = battles[i];
      String? place = battle.place ?? lastBattle?.place;
      String? placeJp = battle.placeJp ?? lastBattle?.placeJp;
      String? placeEn = battle.placeEn ?? lastBattle?.placeJp;
      lastBattle = battle;
      String shownPlace =
          LocalizedText.of(chs: place ?? '', jpn: placeJp, eng: placeEn);
      if (placeJp != null && placeJp != shownPlace) shownPlace += '/' + placeJp;
      if (shownPlace == '迦勒底之门')
        shownPlace =
            LocalizedText.of(chs: '迦勒底之门', jpn: 'カルデアゲート', eng: 'Chaldea Gate');
      children.add(Row(children: <Widget>[
        Text('  ${i + 1}/${battles.length}  '),
        Expanded(flex: 1, child: Center(child: Text('AP ${battle.ap}'))),
        Expanded(
          flex: 4,
          child: Center(
            child: AutoSizeText(
              shownPlace,
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]));
      for (int j = 0; j < battle.enemies.length; j++) {
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('   ${j + 1}   '),
            Expanded(child: _buildWave(battle.enemies[j]))
          ],
        ));
      }

      if (battle.drops.isNotEmpty)
        children.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(S.current.game_drop + ':  '),
              Expanded(
                child: Center(
                  child: _getDropsWidget(battle.drops, quest.isFree),
                ),
              )
            ],
          ),
        ));
    }
    if (quest.rewards.isNotEmpty) {
      children.add(Padding(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(S.current.game_rewards + ':  '),
            Expanded(
                child: Center(child: _getDropsWidget(quest.rewards, false)))
          ],
        ),
      ));
    }
    if (quest.enhancement?.isNotEmpty == true) {
      Widget? enhanceIcon;
      if (quest.enhancement!.startsWith('宝具')) {
        enhanceIcon = db.getIconImage('宝具强化', height: 30);
      } else if (quest.enhancement!.startsWith('技能')) {
        enhanceIcon = db.getIconImage('技能强化', height: 30);
      }
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (enhanceIcon != null)
            Padding(
                padding: EdgeInsets.symmetric(vertical: 3), child: enhanceIcon),
          Flexible(child: AutoSizeText(quest.enhancement!, maxLines: 2))
        ],
      ));
    }

    if (quest.conditions?.isNotEmpty == true) {
      children.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(S.of(context).quest_condition,
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(quest.conditions!, textAlign: TextAlign.center)
        ],
      ));
    }
    return children;
  }

  final _clasIcons = {
    '剑': 'Saber',
    '弓': 'Archer',
    '枪': 'Lancer',
    '骑': 'Rider',
    '术': 'Caster',
    '杀': 'Assassin',
    '狂': 'Berserker',
    '仇': 'Avenger',
    '裁': 'Ruler',
    '月': 'MoonCancer',
    '分': 'Alterego',
    '降': 'Foreigner',
    // '月外分盾'
  };

  Widget _getClassIcon(String clsName) {
    if (!_clasIcons.containsKey(clsName)) return Container();
    return db.getIconImage('金卡${_clasIcons[clsName]}', width: 16);
  }

  String _localizeClassName(String clsName) {
    if (Language.isCN)
      return clsName;
    else
      return {
            '剑': '剣',
            '弓': '弓',
            '枪': '槍',
            '骑': '騎',
            '术': '術',
            '杀': '殺',
            '狂': '狂',
            '仇': '讐',
            '裁': '裁',
            '月': '月',
            '分': '分',
            '降': '降',
          }[clsName] ??
          clsName;
  }

  Widget _buildWave(List<Enemy?> enemies) {
    List<Widget> enemyWidgets = enemies.map((enemy) {
      if (enemy == null) return Container();
      List<Widget> lines = [];
      for (int i = 0; i < enemy.hp.length; i++) {
        final String? name = getEnemyName(showTrueName
            ? enemy.name[i]
            : (enemy.shownName[i] ?? enemy.name[i]));
        if (name?.isNotEmpty == true)
          lines.add(AutoSizeText(name!,
              maxFontSize: 14,
              maxLines: Language.isCN ? 1 : 2,
              textAlign: TextAlign.center));
        lines.add(Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_clasIcons.containsKey(enemy.className[i]))
              _getClassIcon(enemy.className[i]),
            Flexible(
              child: AutoSizeText(
                '${_localizeClassName(enemy.className[i])} ${enemy.hp[i]}',
                maxFontSize: 12,
                // ensure HP is shown completely
                minFontSize: 1,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: lines,
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

  /// only drops of free quest useApRate
  Widget _getDropsWidget(Map<String, int> items, bool useApRate) {
    Map<String, String> dropTexts = {};
    if (useApRate) {
      final glpk = db.gameData.glpk;
      int colIndex = glpk.colNames.indexOf(quest.indexKey ?? '-');

      // not list in glpk
      if (colIndex < 0)
        items.keys.forEach((element) => dropTexts[element] = '');

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
      items.forEach((key, value) => dropTexts[key] = '*$value');
    }
    return Wrap(
      spacing: 3,
      runSpacing: 4,
      children: dropTexts.entries
          .map((entry) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  db.getIconImage(entry.key, height: 30),
                  Text(entry.value, style: TextStyle(fontSize: 14))
                ],
              ))
          .toList(),
    );
  }

  static String? getEnemyName(String? name) {
    if (name == null) return null;
    name =
        name.split(' ').first.replaceFirst(RegExp(r'(?<=[^a-zA-Z])[A-D]$'), '');
    String name2 = Localized.enemy.of(name);
    if (name == name2) {
      name2 = db.gameData.servants.values
              .firstWhereOrNull((svt) => svt.mcLink == name)
              ?.info
              .localizedName ??
          name2;
    }
    return name2;
  }
}
