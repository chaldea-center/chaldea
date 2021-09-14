import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/enemy/enemy_detail_page.dart';
import 'package:chaldea/modules/servant/servant_detail_page.dart';

import 'filter_page.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final bool? use6th;

  QuestCard({Key? key, required this.quest, this.use6th})
      : super(key: Key(quest.indexKey ?? quest.name));

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest get quest => widget.quest;
  bool showTrueName = false;
  bool? _use6th;

  bool get use6th => quest.isFree && (_use6th ?? db.curUser.use6thDropRate);

  bool get show6th {
    return quest.isFree &&
        db.gameData.planningData
            .getDropRate(true)
            .colNames
            .contains(quest.indexKey);
  }

  @override
  void initState() {
    super.initState();
    showTrueName = !Language.isCN;
    _use6th = widget.use6th;
  }

  @override
  void didUpdateWidget(covariant QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.use6th != widget.use6th) {
      _use6th = widget.use6th;
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: divideTiles([
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
              trailing: IconButton(
                onPressed: () => setState(() => showTrueName = !showTrueName),
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: showTrueName ? Theme.of(context).indicatorColor : null,
                ),
                tooltip: showTrueName ? 'Show Display Name' : 'Show True Name',
              ),
            ),
            ..._buildBattles(quest.battles),
            if (!quest.isFree)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).textTheme.caption?.color,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        LocalizedText.of(
                          chs: '非Free本的关卡配置仅供参考，数据可能解析不完全',
                          jpn: 'jpn',
                          eng: 'Data of quest may not be accurate. ',
                        ),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    )
                  ],
                ),
              )
          ], divider: const Divider(height: 3, thickness: 0.5))
              .toList(),
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
      if (shownPlace == '迦勒底之门') {
        shownPlace =
            LocalizedText.of(chs: '迦勒底之门', jpn: 'カルデアゲート', eng: 'Chaldea Gate');
      }
      children.add(Row(children: <Widget>[
        Text('  ${i + 1}/${battles.length}  '),
        Expanded(flex: 1, child: Center(child: Text('AP ${battle.ap}'))),
        Expanded(
          flex: 4,
          child: Center(
            child: AutoSizeText(
              shownPlace,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w600),
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

      if (battle.drops.isNotEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(S.current.game_drop + (quest.isFree ? '(AP): ' : ': ')),
                  if (show6th)
                    FilterOption(
                      selected: use6th,
                      value: '6th',
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text('6th'),
                      ),
                      onChanged: (v) => setState(() {
                        _use6th = v;
                      }),
                      shrinkWrap: true,
                    ),
                ],
              ),
              Expanded(
                child: Center(
                  child: _getDropsWidget(battle.drops, quest.isFree),
                ),
              )
            ],
          ),
        ));
      }
    }
    if (quest.rewards.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
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
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: enhanceIcon),
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
                style: const TextStyle(fontWeight: FontWeight.w500)),
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
    '他': 'Alterego',
    '降': 'Foreigner',
    // '月外分盾伪'
  };

  Widget _getClassIcon(String? clsName) {
    if (!_clasIcons.containsKey(clsName)) return Container();
    return db.getIconImage('金卡${_clasIcons[clsName]}', width: 16);
  }

  String _localizeClassName(String? clsName) {
    if (clsName == null) return '';
    if (Language.isCN) {
      return clsName;
    } else {
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
            '他': '分',
            '降': '降',
          }[clsName] ??
          clsName;
    }
  }

  Widget _buildWave(List<Enemy?> enemies) {
    List<Widget> enemyWidgets = enemies.map((enemy) {
      if (enemy == null) return Container();
      List<Widget> children = [];
      for (int i = 0; i < enemy.hp.length; i++) {
        List<Widget> lines = [];
        VoidCallback? onTap;

        final String? name = getEnemyName(showTrueName
            ? enemy.name[i]
            : (enemy.shownName[i] ?? enemy.name[i]));
        final enemyInfo = EnemyDetail.of(enemy.name[i]);
        if (enemyInfo != null) {
          if (enemyInfo.icon != null) {
            lines.add(CachedImage(
              imageUrl: enemyInfo.icon,
              width: 36,
              height: 36,
              placeholder: (_, __) => Container(),
            ));
          }
          onTap =
              () => SplitRoute.push(context, EnemyDetailPage(enemy: enemyInfo));
        } else {
          final svt = db.gameData.servants.values.firstWhereOrNull((e) =>
              <String>[e.mcLink, ...e.info.namesOther].contains(enemy.name[i]));
          if (svt != null) {
            // add mask
            Widget shadowSvt = svt.iconBuilder(
                context: context, height: 36, jumpToDetail: false);
            if (!showTrueName && enemy.shownName[i] == '影从者') {
              shadowSvt = Stack(
                alignment: Alignment.center,
                children: [
                  shadowSvt,
                  ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 4.5,
                        sigmaY: 4.5,
                      ),
                      child: Container(
                        width: 36 / 144 * 132,
                        height: 36,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              );
            }
            lines.add(shadowSvt);
            onTap = () => SplitRoute.push(context, ServantDetailPage(svt));
          }
        }
        if (name?.isNotEmpty == true) {
          lines.add(AutoSizeText(name!,
              maxFontSize: 14,
              maxLines: Language.isCN ? 1 : 2,
              textAlign: TextAlign.center));
        }
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
        Widget child = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lines,
        );
        if (onTap != null) {
          child = InkWell(
            onTap: onTap,
            child: child,
          );
        }
        children.add(child);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
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
  /// TODO: if provide drop rate data, [items] here should not be used
  Widget _getDropsWidget(Map<String, int> items, bool useDropRate) {
    // <item, shownText>
    Map<String, String> dropTexts = {};
    if (useDropRate) {
      final dropRates = db.gameData.planningData.getDropRate(use6th);
      int colIndex = dropRates.colNames.indexOf(quest.indexKey ?? '-');

      // not list in glpk
      if (colIndex < 0) {
        items.keys.forEach((element) => dropTexts[element] = '');
      } else {
        Map<String, double> apRates = {};
        for (var i = 0; i < dropRates.rowNames.length; i++) {
          if (colIndex >= 0 && dropRates.matrix[i][colIndex] > 0) {
            apRates[dropRates.rowNames[i]] =
                dropRates.costs[colIndex] / dropRates.matrix[i][colIndex];
          }
        }
        final entryList = apRates.entries.toList()
          ..sort((a, b) => (a.value - b.value).sign.toInt());
        entryList.forEach((entry) {
          String v = entry.value >= 1000
              ? entry.value.toInt().toString()
              : entry.value.toStringAsPrecision(4);
          dropTexts[entry.key] =
              formatNumber(double.parse(v), groupSeparator: '', precision: 4);
        });
      }
    } else {
      items.forEach((key, value) => dropTexts[key] = value.toString());
    }
    return Wrap(
      spacing: 3,
      runSpacing: 4,
      children: dropTexts.entries
          .map((entry) => Item.iconBuilder(
              context: context,
              itemKey: entry.key,
              width: 40,
              text: entry.value))
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
