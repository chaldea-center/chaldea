import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../common/filter_group.dart';
import 'quest_enemy.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final bool? use6th;
  final bool offline;
  final Region region;

  QuestCard({
    Key? key,
    required this.quest,
    this.use6th,
    this.offline = true,
    this.region = Region.jp,
  }) : super(key: Key('QuestCard_${quest.id}'));

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest get quest => widget.quest;
  bool showTrueName = false;
  bool? _use6th;
  bool preferApRate = false;

  bool get use6th => _use6th ?? db2.curUser.use6thDropRate;

  bool get show6th {
    return db2.gameData.dropRate.getSheet(true).questIds.contains(quest.id);
  }

  @override
  void initState() {
    super.initState();
    _use6th = widget.use6th;
    if (quest.isDomusQuest) preferApRate = db2.settings.preferApRate;
    if (!widget.offline) _fetchAllPhases();
  }

  Future<void> _fetchAllPhases() async {
    final questId = quest.id;
    final region = widget.region;
    Duration? expireAfter;
    if (quest.warId >= 1000 &&
        quest.openedAt <
            DateTime.now().subtract(const Duration(days: 30)).timestamp) {
      expireAfter = const Duration(days: 7);
    }

    for (final phase
        in quest.isMainStoryFree ? [quest.phases.last] : quest.phases) {
      AtlasApi.questPhase(questId, phase,
              region: region, expireAfter: expireAfter)
          .then((phaseData) {
        if (phaseData != null) {
          _cachedPhaseData['${region.name}/$questId/$phase'] = phaseData;
          if (mounted) setState(() {});
        }
      });
    }
  }

  static final Map<String, QuestPhase> _cachedPhaseData = {};

  QuestPhase? _getCachedPhase(int phase) {
    return _cachedPhaseData['${widget.region.name}/${quest.id}/$phase'];
  }

  @override
  void didUpdateWidget(covariant QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.use6th != widget.use6th) {
      _use6th = widget.use6th;
    }
    if (oldWidget.offline != widget.offline ||
        oldWidget.region != widget.region ||
        oldWidget.quest != widget.quest) {
      _fetchAllPhases();
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestPhase? questPhase;
    for (final phase in quest.phases) {
      questPhase ??=
          _getCachedPhase(phase) ?? db2.gameData.getQuestPhase(quest.id);
      if (questPhase != null) break;
    }

    String questName = quest.lName.l;
    if (quest.type == QuestType.main) {
      String chapter = quest.chapterSubStr.isEmpty
          ? '第${quest.chapterSubId}节'
          : quest.chapterSubStr;
      questName = chapter + ' ' + questName;
    }
    List<String> names = [
      questName,
      if (!Transl.isJP && quest.name != quest.lName.l) quest.name
    ];
    String shownQuestName;
    if (names.any((s) => s.charWidth > 16)) {
      shownQuestName = names.join('\n');
    } else {
      shownQuestName = names.join('/');
    }
    String warName = Transl.warNames(quest.warLongName).l.replaceAll('\n', ' ');

    List<Widget> children = [
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
                shownQuestName,
                maxLines: 2,
                maxFontSize: 14,
                minFontSize: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              AutoSizeText(
                'Lv.${quest.recommendLv}  '
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
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 8),
        trailing: IconButton(
          onPressed: () => setState(() => showTrueName = !showTrueName),
          icon: Icon(
            Icons.remove_red_eye_outlined,
            color: showTrueName ? Theme.of(context).indicatorColor : null,
          ),
          tooltip: showTrueName ? 'Show Display Name' : 'Show True Name',
        ),
      ),
      if (quest.phases.isNotEmpty)
        for (final phase
            in (quest.isMainStoryFree ? [quest.phases.last] : quest.phases))
          _buildPhases(phase),
      if (quest.gifts.isNotEmpty) _questRewards(),
      if (quest.releaseConditions.isNotEmpty) _releaseConditions(),
      if (!quest.isMainStoryFree)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  'Let me know if any mistake.',
                  style: Theme.of(context).textTheme.caption,
                ),
              )
            ],
          ),
        ),
      if (widget.offline)
        TextButton(
          onPressed: () {
            router.push(
              url: Routes.questI(quest.id),
              child: QuestDetailPage(quest: quest, region: widget.region),
              detail: true,
            );
          },
          child: const Text('>>> detail >>>'),
        ),
    ];

    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: divideTiles(
          children.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: e,
            ),
          ),
          divider: const Divider(height: 8, thickness: 2),
        ).toList(),
      ),
    );
  }

  Widget _buildPhases(int phase) {
    List<Widget> children = [];
    QuestPhase? curPhase;
    if (widget.offline) {
      curPhase = db2.gameData.getQuestPhase(quest.id, phase);
    } else {
      curPhase = _getCachedPhase(phase);
      if (widget.region == Region.jp) {
        curPhase ??= db2.gameData.getQuestPhase(quest.id, phase);
      }
    }
    if (curPhase == null) {
      children.add(Text('  $phase/${widget.quest.phases.length}  '));
      if (widget.quest.phasesNoBattle.contains(phase)) {
        children.add(const Expanded(
            child: Text('No Battle', textAlign: TextAlign.center)));
      } else if (!widget.offline) {
        children.add(
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else {
        children.add(const Text('-', textAlign: TextAlign.center));
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }
    String spotJp = curPhase.spotName;
    String spot = curPhase.lSpot.l;

    children.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: <Widget>[
        Text('  ${curPhase.phase}/${curPhase.phases.length}  '),
        Expanded(flex: 1, child: Center(child: Text('AP ${curPhase.consume}'))),
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
          SizedBox(
            width: 32,
            child: AutoSizeText(
              (j + 1).toString(),
              textAlign: TextAlign.center,
              maxLines: 1,
              minFontSize: 3,
            ),
          ),
          Expanded(
            child: QuestWave(
              stage: curPhase.stages[j],
              showTrueName: showTrueName,
            ),
          )
        ],
      ));
    }

    if (curPhase.individuality.isNotEmpty &&
        (curPhase.stages.isNotEmpty ||
            (curPhase.consume != 0 && curPhase.consumeItem.isNotEmpty))) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('Fields'),
            Expanded(
              child: SharedBuilder.traitList(
                  context: context, traits: curPhase.individuality),
            )
          ],
        ),
      ));
    }
    if (show6th || curPhase.drops.isNotEmpty) {
      children.add(Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(S.current.game_drop + ':'),
          FilterGroup<bool>(
            options: const [true, false],
            values: FilterRadioData(preferApRate),
            optionBuilder: (v) => Text(v ? 'AP' : S.current.drop_rate),
            combined: true,
            onFilterChanged: (v) {
              setState(() {
                preferApRate = v.radioValue ?? preferApRate;
              });
            },
          ),
          if (show6th)
            FilterGroup<bool>(
              options: const [true],
              values: FilterRadioData(use6th ? true : null),
              optionBuilder: (v) => const Text('6th'),
              combined: true,
              onFilterChanged: (v) {
                setState(() {
                  _use6th = !use6th;
                });
              },
            ),
        ],
      ));
    }
    if (show6th) {
      final sheetData = db2.gameData.dropRate.getSheet(use6th);
      int runs =
          sheetData.runs.getOrNull(sheetData.questIds.indexOf(quest.id)) ?? 0;
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          Text(S.current.fgo_domus_aurea + ' ($runs runs)'),
          const SizedBox(height: 2),
          _getDomusAureaWidget(),
          const SizedBox(height: 3),
        ],
      ));
    }

    if (curPhase.drops.isNotEmpty) {
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          Text('Rayshift Drops (${curPhase.drops.first.runs} runs)'),
          const SizedBox(height: 2),
          _getRayshiftDrops(curPhase.drops),
          const SizedBox(height: 3),
        ],
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: divideTiles(
        children,
        divider: const Divider(height: 5, thickness: 0.5),
      ),
    );
  }

  int _compareItem(int a, int b) {
    final itemA = db2.gameData.items[a], itemB = db2.gameData.items[b];
    if (itemA != null && itemB != null) {
      return itemB.priority.compareTo(itemA.priority);
    } else if (itemA == null && itemB == null) {
      return b.compareTo(a);
    } else {
      return itemA == null ? 1 : -1;
    }
  }

  /// only drops of free quest useApRate
  Widget _getDomusAureaWidget() {
    final dropRates = db2.gameData.dropRate.getSheet(use6th);
    Map<int, String?> dropTexts = {};
    if (preferApRate) {
      final drops = dropRates.getQuestApRate(widget.quest.id).entries.toList();
      drops.sort((a, b) => _compareItem(a.key, b.key));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value > 1000
            ? entry.value.toInt().toString()
            : entry.value.format(maxDigits: 4);
      }
    } else {
      final drops =
          dropRates.getQuestDropRate(widget.quest.id).entries.toList();
      drops.sort((a, b) => _compareItem(a.key, b.key));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value.format(percent: true, maxDigits: 4);
      }
    }
    if (dropTexts.isEmpty) return const Text('-');
    return Wrap(
      spacing: 3,
      runSpacing: 2,
      children: [
        for (final entry in dropTexts.entries)
          GameCardMixin.anyCardItemBuilder(
            context: context,
            id: entry.key,
            text: entry.value,
            width: 42,
          )
      ],
    );
  }

  Widget _getRayshiftDrops(List<EnemyDrop> drops) {
    drops = List.of(drops);
    drops.sort((a, b) => _compareItem(a.objectId, b.objectId));
    List<Widget> children = [];
    for (final drop in drops) {
      String? text;
      if (drop.runs != 0) {
        double dropRate = drop.dropCount / drop.runs;

        if (preferApRate) {
          if (quest.consumeType == ConsumeType.ap &&
              quest.consume > 0 &&
              dropRate != 0.0) {
            double apRate = quest.consume / dropRate;
            text = apRate >= 1000
                ? apRate.toInt().toString()
                : apRate.format(precision: 4, maxDigits: 4);
          }
        } else {
          text = dropRate.format(percent: true, maxDigits: 4);
        }
      }
      if (text != null) {
        text = '×${drop.num.format()}\n$text';
      }
      children.add(GameCardMixin.anyCardItemBuilder(
        context: context,
        id: drop.objectId,
        width: 42,
        text: text ?? '-',
        textPadding: const EdgeInsets.only(top: 20),
      ));
    }
    return Wrap(
      spacing: 3,
      runSpacing: 2,
      children: children,
    );
  }

  Widget _questRewards() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(S.current.game_rewards),
          Expanded(
            child: Center(
              child: SharedBuilder.giftGrid(
                context: context,
                gifts: quest.gifts,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _releaseConditions() {
    return Column(
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
    );
  }
}

class QuestWave extends StatelessWidget {
  final Stage stage;
  final bool showTrueName;

  const QuestWave({
    Key? key,
    required this.stage,
    this.showTrueName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    Widget _buildEnemyWithShift(QuestEnemy? enemy) {
      if (enemy == null) return const SizedBox();
      List<Widget> parts = [];
      parts.add(QuestEnemyWidget(enemy: enemy, showTrueName: showTrueName));
      if (enemy.enemyScript.shift != null) {
        for (final shift in enemy.enemyScript.shift!) {
          final shiftEnemy = shiftDeck[shift]!;
          parts.add(
              QuestEnemyWidget(enemy: shiftEnemy, showTrueName: showTrueName));
        }
      }
      if (parts.length == 1) return parts.first;
      return Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: parts,
          ),
        ),
      );
    }

    for (final enemy in stage.enemies) {
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
}

class QuestEnemyWidget extends StatelessWidget {
  final QuestEnemy enemy;
  final bool showTrueName;
  const QuestEnemyWidget({
    Key? key,
    required this.enemy,
    this.showTrueName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mp = db2.gameData.mappingData;
    String displayName = showTrueName ? enemy.svt.name : enemy.name;
    displayName = mp.svtNames[displayName]?.l ??
        mp.entityNames[displayName]?.l ??
        displayName;

    Widget face = Image.network(
      enemy.svt.face,
      width: 42,
      height: 42,
      errorBuilder: (_, __, ___) => const SizedBox(),
    );

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
                width: 44,
                height: 44,
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
        db2.getIconImage(enemy.svt.className.icon(enemy.svt.rarity), width: 20),
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
        // if (enemy.svt.collectionNo > 0) {
        //   router.push(url: Routes.servantI(enemy.svt.collectionNo));
        // }
        router.push(child: QuestEnemyDetail(enemy: enemy));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          face,
          LayoutBuilder(builder: (context, constraints) {
            return AutoSizeText(
              displayName + (enemy.deck != DeckType.enemy ? "*" : ""),
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
}
