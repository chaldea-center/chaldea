import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';
import 'dart:ui' as ui;

import 'filter_group.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final bool? use6th;

  QuestCard({Key? key, required this.quest, this.use6th})
      : super(key: Key('QuestCard_${quest.id}'));

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest get quest => widget.quest;
  bool showTrueName = false;
  bool? _use6th;

  bool get use6th =>
      quest.type == QuestType.free && (_use6th ?? db2.curUser.use6thDropRate);

  bool get show6th {
    return db2.gameData.dropRate.getSheet(true).questIds.contains(quest.id);
  }

  @override
  void initState() {
    super.initState();
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
    QuestPhase? questPhase;
    if (quest is QuestPhase) {
      questPhase = quest as QuestPhase;
    } else {
      questPhase = db2.gameData.getQuestPhase(quest.id);
    }
    List<String> names = [
      quest.lName.l,
      if (!Transl.isJP && quest.name != quest.lName.l) quest.name
    ];
    String questName;
    if (names.any((s) => s.charWidth > 16)) {
      questName = names.join('\n');
    } else {
      questName = names.join('/');
    }
    String warName = Transl.warNames(quest.warLongName).l.replaceAll('\n', ' ');
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
                      warName,
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
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    AutoSizeText(
                      '${S.current.game_kizuna} ${questPhase?.bond ?? "?"}  '
                      '${S.current.game_experience} ${questPhase?.exp ?? "?"}',
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
            ..._buildPhases(quest.phases),
            if (quest.type != QuestType.free)
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
                        'Data of quest may not be accurate. ',
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

  List<Widget> _buildPhases(List<int> phases) {
    List<Widget> children = [];
    for (int i = 0; i < phases.length; i++) {
      final curPhase = db2.gameData.getQuestPhase(quest.id, phases[i]);
      if (curPhase == null) continue;
      String spotJp = curPhase.spotName;
      String spot = curPhase.lSpot.l;

      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: <Widget>[
          Text('  ${i + 1}/${phases.length}  '),
          Expanded(
              flex: 1, child: Center(child: Text('AP ${curPhase.consume}'))),
          Expanded(
            flex: 4,
            child: Center(
              child: AutoSizeText(
                spotJp == spot ? spot : '$spot/$spotJp',
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
      ));
      for (int j = 0; j < curPhase.stages.length; j++) {
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('   ${j + 1}   '),
            Expanded(child: _buildWave(curPhase.stages[j].enemies))
          ],
        ));
      }

      if (curPhase.individuality.isNotEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('Fields'),
              Expanded(
                child: Center(
                  child: Text(curPhase.individuality
                      .map((e) => e.showName)
                      .join(' / ')),
                ),
              )
            ],
          ),
        ));
      }
      List<MapEntry<int, int>> drops =
          curPhase.gifts.map((e) => MapEntry(e.objectId, e.num)).toList();
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.current.game_drop +
                      (show6th
                          ? Language.isJP
                              ? '\n(AP)'
                              : '(AP)'
                          : ''),
                  textAlign: TextAlign.center,
                ),
                if (show6th)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: FilterOption(
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
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: _getDropsWidget(drops, show6th),
              ),
            )
          ],
        ),
      ));
    }
    if (quest.gifts.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(S.current.game_rewards),
            Expanded(
                child: Center(
                    child: _getDropsWidget(
                        {
                          for (final gift in quest.gifts)
                            gift.objectId: gift.num
                        }.entries.toList(),
                        false)))
          ],
        ),
      ));
    }

    if (quest.releaseConditions.isNotEmpty == true) {
      children.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(S.of(context).quest_condition,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(quest.releaseConditions.length.toString() + ' conditions',
              textAlign: TextAlign.center)
        ],
      ));
    }

    return children;
  }

  Widget _buildWave(List<QuestEnemy> enemies) {
    List<QuestEnemy?> enemyDeck = [];
    List<QuestEnemy> callDeck = [];
    Map<int, QuestEnemy> shiftDeck = {};
    List<QuestEnemy> unknownDeck = [];

    void _insertEnemy(QuestEnemy enemy) {
      assert(enemy.deck == DeckType.enemy);
      if (enemyDeck.length <= enemy.deckId) {
        enemyDeck.length = enemy.deckId;
      }
      assert(enemyDeck[enemy.deckId - 1] == null);
      enemyDeck[enemy.deckId - 1] = enemy;
    }

    Widget _buildEnemy(QuestEnemy enemy) {
      final mp = db2.gameData.mappingData;
      String displayName = showTrueName ? enemy.svt.name : enemy.name;
      displayName = mp.svtNames[displayName]?.l ??
          mp.entityNames[displayName]?.l ??
          displayName;
      Widget face = db2.getIconImage(enemy.svt.face);
      if (enemy.misc.displayType == 2 && !showTrueName) {
        face = Stack(
          alignment: Alignment.center,
          children: [
            face,
            ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 4.5,
                  sigmaY: 4.5,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ],
        );
      }
      final clsHP = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          db2.getIconImage(enemy.svt.className.icon(enemy.svt.rarity),
              width: 20),
          Flexible(
            child: AutoSizeText(
              '${enemy.svt.className.shortName} ${enemy.hp}',
              maxFontSize: 12,
              // ensure HP is shown completely
              minFontSize: 1,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          )
        ],
      );
      return InkWell(
        onTap: () {
          // goto enemy page
          if (enemy.svt.collectionNo > 0) {
            router.push(url: Routes.servantI(enemy.svt.collectionNo));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: face,
            ),
            LayoutBuilder(builder: (context, constraints) {
              print(constraints.maxWidth);
              return AutoSizeText(
                displayName,
                textAlign: TextAlign.center,
                maxFontSize: constraints.maxWidth < 120 ? 14 : 24,
                maxLines: constraints.maxWidth < 120 ? 2 : 1,
              );
            }),
            clsHP
          ],
        ),
      );
    }

    Widget _buildEnemyWithShift(QuestEnemy? enemy) {
      if (enemy == null) return const SizedBox();
      List<Widget> parts = [];
      parts.add(_buildEnemy(enemy));
      if (enemy.enemyScript.shift != null) {
        for (final shift in enemy.enemyScript.shift!) {
          final shiftEnemy = shiftDeck[shift]!;
          parts.add(_buildEnemy(shiftEnemy));
        }
      }
      if (parts.length == 1) return parts.first;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: parts,
      );
    }

    for (final enemy in enemies) {
      switch (enemy.deck) {
        case DeckType.enemy:
          _insertEnemy(enemy);
          break;
        case DeckType.call:
          callDeck.add(enemy);
          break;
        case DeckType.shift:
          shiftDeck[enemy.npcId] = enemy;
          break;
        case DeckType.change:
        case DeckType.transform:
        case DeckType.skillShift:
        case DeckType.missionTargetSkillShift:
          unknownDeck.add(enemy);
          break;
      }
    }
    List<Widget> positions = [];
    int enemyDeckLength = (enemyDeck.length / 3).ceil() * 3;
    for (int i = 0; i < enemyDeckLength; i++) {
      final enemy = enemyDeck.getOrNull(i);
      positions.add(_buildEnemyWithShift(enemy));
    }
    int callDeckLength = (callDeck.length / 3).ceil() * 3;
    for (int i = 0; i < callDeckLength; i++) {
      final enemy = callDeck.getOrNull(i);
      positions.add(_buildEnemyWithShift(enemy));
    }
    int unknownDeckLength = (unknownDeck.length / 3).ceil() * 3;
    for (int i = 0; i < unknownDeckLength; i++) {
      final enemy = unknownDeck.getOrNull(i);
      positions.add(_buildEnemyWithShift(enemy));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(positions.length ~/ 3, (i) {
        return Row(
          textDirection: TextDirection.rtl,
          children: <Widget>[
            Expanded(child: positions[i * 3]),
            Expanded(child: positions[i * 3 + 1]),
            Expanded(child: positions[i * 3 + 2]),
          ],
        );
      }),
    );
  }

  /// only drops of free quest useApRate
  Widget _getDropsWidget(List<MapEntry<int, int>> items, bool useDropRate) {
    // <item, shownText>
    Map<int, String?> dropTexts = {};
    if (useDropRate) {
      final dropRates = db2.gameData.dropRate.getSheet(use6th);
      Map<int, double> sheetApRates = dropRates.getQuestApRate(quest.id);
      print(sheetApRates);
      // not list in glpk
      if (sheetApRates.isNotEmpty) {
        final entryList = sheetApRates.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        for (final entry in entryList) {
          String v = entry.value >= 1000
              ? entry.value.toInt().toString()
              : entry.value.toStringAsPrecision(4);
          dropTexts[entry.key] =
              formatNumber(double.parse(v), groupSeparator: '', precision: 4);
        }
      } else {
        items.forEach((entry) => dropTexts[entry.key] = null);
      }
    } else {
      items.forEach((entry) => dropTexts[entry.key] = entry.value.toString());
    }
    return Wrap(
      spacing: 3,
      runSpacing: 4,
      children: dropTexts.entries
          .map((entry) => GameCardMixin.anyCardItemBuilder(
                context: context,
                id: entry.key,
                text: entry.value,
                width: 42,
              ))
          .toList(),
    );
  }
}
