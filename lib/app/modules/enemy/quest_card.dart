import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';
import '../script/script_reader.dart';
import 'quest_enemy.dart';
import 'support_servant.dart';

class QuestCard extends StatefulWidget {
  final Quest? quest;
  final int questId;
  final bool? use6th;
  final bool offline;
  final Region region;

  QuestCard({
    Key? key,
    required this.quest,
    int? questId,
    this.use6th,
    this.offline = true,
    this.region = Region.jp,
  })  : assert(quest != null || questId != null),
        questId = (quest?.id ?? questId)!,
        super(
            key:
                key ?? Key('QuestCard_${region.name}_${quest?.id ?? questId}'));

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest? _quest;

  Quest get quest => _quest!;
  bool showTrueName = false;
  bool? _use6th;
  bool preferApRate = false;

  bool get use6th => _use6th ?? db.curUser.freeLPParams.use6th;

  bool get show6th {
    return db.gameData.dropRate
        .getSheet(true)
        .questIds
        .contains(widget.questId);
  }

  void _init() {
    _quest = widget.quest ?? db.gameData.quests[widget.questId];
    if (_quest == null && !widget.offline) {
      AtlasApi.quest(widget.questId).then((value) {
        if (value != null) {
          _quest = value;
          if (!widget.offline) _fetchAllPhases();
        }
        if (mounted) setState(() {});
      });
    }
    if (!widget.offline) _fetchAllPhases();
  }

  @override
  void initState() {
    super.initState();
    _use6th = widget.use6th;
    _init();
    if (_quest?.isDomusQuest == true) preferApRate = db.settings.preferApRate;
    showTrueName = !Transl.isJP;
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
    return _cachedPhaseData['${widget.region.name}/${widget.questId}/$phase'];
  }

  @override
  void didUpdateWidget(covariant QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.use6th != widget.use6th) {
      _use6th = widget.use6th;
    }
    if (oldWidget.offline != widget.offline ||
        oldWidget.region != widget.region ||
        oldWidget.quest != widget.quest ||
        oldWidget.questId != widget.questId) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quest == null) {
      return Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            AutoSizeText(
              'Quest ${widget.questId}',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.offline)
              TextButton(
                onPressed: () {
                  router.push(
                    url: Routes.questI(widget.questId),
                    child: QuestDetailPage(
                      quest: _quest,
                      id: widget.questId,
                      region: widget.region,
                    ),
                    detail: true,
                  );
                },
                child: Text('>>> ${S.current.quest_detail_btn} >>>'),
              ),
          ],
        ),
      );
    }
    QuestPhase? questPhase;
    for (final phase in quest.phases) {
      questPhase ??=
          _getCachedPhase(phase) ?? db.gameData.getQuestPhase(quest.id);
      if (questPhase != null) break;
    }

    String questName = quest.lName.l;
    String chapter = quest.type == QuestType.main
        ? quest.chapterSubStr.isEmpty && quest.chapterSubId != 0
            ? S.current.quest_chapter_n(quest.chapterSubId)
            : quest.chapterSubStr
        : '';
    if (chapter.isNotEmpty) {
      questName = '$chapter $questName';
    }
    List<String> names = [
      questName,
      if (!Transl.isJP && quest.name != quest.lName.l) quest.name
    ].map((e) => e.replaceAll('\n', ' ')).toList();
    String shownQuestName;
    if (names.any((s) => s.charWidth > 16)) {
      shownQuestName = names.join('\n');
    } else {
      shownQuestName = names.join('/');
    }
    String warName = Transl.warNames(quest.warLongName).l.replaceAll('\n', ' ');

    List<Widget> children = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 36),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: quest.war?.routeTo,
                    child: AutoSizeText(
                      warName,
                      maxLines: 2,
                      maxFontSize: 14,
                      minFontSize: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CopyLongPress(
                    text: shownQuestName,
                    child: SelectableText(
                      shownQuestName,
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: IconButton(
              onPressed: () => setState(() => showTrueName = !showTrueName),
              icon: Icon(
                Icons.remove_red_eye_outlined,
                color: showTrueName ? Theme.of(context).indicatorColor : null,
              ),
              tooltip: showTrueName ? 'Show Display Name' : 'Show True Name',
              padding: EdgeInsets.zero,
              iconSize: 20,
            ),
          )
        ],
      ),
      if (quest.phases.isNotEmpty)
        for (final phase
            in (quest.isMainStoryFree ? [quest.phases.last] : quest.phases))
          _buildPhases(phase),
      if (quest.gifts.isNotEmpty || quest.giftIcon != null) _questRewards(),
      if (!widget.offline) releaseConditions(),
      if (widget.offline)
        TextButton(
          onPressed: () {
            router.push(
              url: Routes.questI(quest.id),
              child: QuestDetailPage(quest: quest, region: widget.region),
              detail: true,
            );
          },
          child: Text('>>> ${S.current.quest_detail_btn} >>>'),
        ),
    ];

    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ...divideTiles(
            children.map(
              (e) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: e,
              ),
            ),
            divider: const Divider(height: 8, thickness: 2),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPhases(int phase) {
    List<Widget> children = [];
    QuestPhase? curPhase;
    if (widget.offline) {
      curPhase = db.gameData.getQuestPhase(quest.id, phase);
    } else {
      curPhase = _getCachedPhase(phase);
      if (widget.region == Region.jp) {
        curPhase ??= db.gameData.getQuestPhase(quest.id, phase);
      }
    }
    if (curPhase == null) {
      List<Widget> rowChildren = [];
      rowChildren.add(Text('  $phase/${quest.phases.length}  '));
      if (quest.phasesNoBattle.contains(phase)) {
        rowChildren.add(const Expanded(
            child: Text('No Battle', textAlign: TextAlign.center)));
      } else if (!widget.offline) {
        rowChildren.add(
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      } else {
        rowChildren.add(const Text('-', textAlign: TextAlign.center));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
          ...getPhaseScript(phase)
        ],
      );
    }
    String spotJp = curPhase.spotName;
    String spot = curPhase.lSpot.l;
    final spotImage = curPhase.spot?.shownImage;
    final shownSpotName = spotJp == spot ? spot : '$spot/$spotJp';
    bool noConsume =
        curPhase.consumeType == ConsumeType.ap && curPhase.consume == 0;
    final questSelects = curPhase.extraDetail?.questSelect;
    List<Widget> headerRows = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '${curPhase.phase}/${Maths.max(curPhase.phases, 0)}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: CopyLongPress(
              text: shownSpotName,
              child: SelectableText(
                shownSpotName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                textScaleFactor: 0.9,
              ),
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text.rich(
              TextSpan(children: [
                if (curPhase.consumeType != ConsumeType.item)
                  TextSpan(text: 'AP ${curPhase.consume}'),
                for (final itemAmount in curPhase.consumeItem)
                  WidgetSpan(
                    child: Item.iconBuilder(
                      context: context,
                      item: itemAmount.item,
                      text: itemAmount.amount.format(),
                      width: 36,
                    ),
                  )
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Lv.${curPhase.recommendLv}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Expanded(
            child: Text(
              '${S.current.bond} ${noConsume ? "-" : curPhase.bond}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Expanded(
            child: Text(
              'EXP ${noConsume ? "-" : curPhase.exp}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      ),
      if (questSelects != null && questSelects.isNotEmpty)
        Text.rich(
          TextSpan(text: '${S.current.branch_quest}: ', children: [
            for (final selectId in questSelects)
              if (selectId != curPhase.id)
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: ' $selectId ',
                  onTap: () => router.push(url: Routes.questI(selectId)),
                )
          ]),
          textAlign: TextAlign.center,
        )
    ];
    if (spotImage == null) {
      children.addAll(headerRows);
    } else {
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Column(children: headerRows)),
          db.getIconImage(spotImage, height: 42, aspectRatio: 1),
        ],
      ));
    }
    for (int j = 0; j < curPhase.stages.length; j++) {
      final stage = curPhase.stages[j];
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Text.rich(
              TextSpan(
                children: divideList(
                  [
                    TextSpan(text: '${j + 1}'),
                    if (stage.enemyFieldPosCount != null)
                      TextSpan(text: '(${stage.enemyFieldPosCount})'),
                    if (stage.bgm.id != 0)
                      WidgetSpan(
                        child: IconButton(
                          onPressed: () {
                            stage.bgm.routeTo();
                          },
                          icon: const Icon(Icons.music_note, size: 18),
                          tooltip: stage.bgm.tooltip,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      )
                  ],
                  const TextSpan(text: '\n'),
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: QuestWave(
              stage: stage,
              showTrueName: showTrueName,
              region: widget.region,
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
            _header(S.current.quest_fields),
            Expanded(
              child: SharedBuilder.traitList(
                context: context,
                traits: curPhase.individuality,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ));
    }
    if (!widget.offline && curPhase.supportServants.isNotEmpty) {
      children.add(getSupportServants(curPhase));
    }

    if (show6th || curPhase.drops.isNotEmpty) {
      children.add(Wrap(
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _header('${S.current.game_drop}:'),
          FilterGroup<bool>(
            options: const [true, false],
            values: FilterRadioData.nonnull(preferApRate),
            optionBuilder: (v) => Text(v ? 'AP' : S.current.drop_rate),
            combined: true,
            onFilterChanged: (v, _) {
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
              onFilterChanged: (v, _) {
                setState(() {
                  _use6th = !use6th;
                });
              },
            ),
        ],
      ));
    }
    if (show6th) {
      final sheetData = db.gameData.dropRate.getSheet(use6th);
      int runs =
          sheetData.runs.getOrNull(sheetData.questIds.indexOf(quest.id)) ?? 0;
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          Text('${S.current.fgo_domus_aurea} ($runs runs)'),
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
    children.addAll(getPhaseScript(phase));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: divideTiles(
        children,
        divider: const Divider(height: 5, thickness: 0.5),
      ),
    );
  }

  List<Widget> getPhaseScript(int phase) {
    final scripts =
        quest.phaseScripts.firstWhereOrNull((e) => e.phase == phase)?.scripts;
    if (scripts == null || scripts.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _header(S.current.script_story),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final s in scripts)
                    Text.rich(SharedBuilder.textButtonSpan(
                      context: context,
                      text: '[${s.scriptId}]',
                      onTap: () {
                        router.pushPage(
                            ScriptReaderPage(script: s, region: widget.region));
                      },
                    ))
                ],
              ),
            )
          ],
        ),
      )
    ];
  }

  Widget getSupportServants(QuestPhase curPhase) {
    TextSpan _mono(dynamic v, int width) =>
        TextSpan(text: v.toString().padRight(width), style: kMonoStyle);
    String _nullLevel(int lv, dynamic skill) {
      return skill == null ? '-' : lv.toString();
    }

    List<Widget> supports = [];
    for (final svt in curPhase.supportServants) {
      Widget support = Text.rich(
        TextSpan(children: [
          CenterWidgetSpan(
            child: svt.svt.iconBuilder(
              context: context,
              width: 32,
              onTap: () {
                router.pushPage(SupportServantPage(svt, region: widget.region));
              },
            ),
          ),
          TextSpan(
            children: [
              const TextSpan(text: ' Lv.'),
              _mono(svt.lv, 2),
              TextSpan(text: ' ${S.current.np_short} Lv.'),
              _mono(
                  _nullLevel(svt.noblePhantasm.noblePhantasmLv,
                      svt.noblePhantasm.noblePhantasm),
                  1),
              TextSpan(text: ' ${S.current.skill} Lv.'),
              _mono(
                  '${_nullLevel(svt.skills.skillLv1, svt.skills.skill1)}'
                  '/${_nullLevel(svt.skills.skillLv2, svt.skills.skill2)}'
                  '/${_nullLevel(svt.skills.skillLv3, svt.skills.skill3)}',
                  8),
              const TextSpan(text: '  ')
            ],
            style: svt.script?.eventDeckIndex == null
                ? null
                : TextStyle(color: Theme.of(context).errorColor),
          ),
          for (final ce in svt.equips) ...[
            CenterWidgetSpan(
                child: ce.equip.iconBuilder(context: context, width: 32)),
            TextSpan(
              children: [
                const TextSpan(text: ' Lv.'),
                _mono(ce.lv, 2),
              ],
              style: ce.limitCount == 4
                  ? TextStyle(color: Theme.of(context).errorColor)
                  : null,
            ),
          ]
        ]),
        textScaleFactor: 0.9,
      );
      supports.add(InkWell(
        child: support,
        onTap: () {
          router.pushPage(SupportServantPage(svt, region: widget.region));
        },
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(
            '${S.current.support_servant}${curPhase.isNpcOnly ? " (${S.current.support_servant_forced})" : ""}',
          ),
          ...supports,
        ],
      ),
    );
  }

  Text _header(String text, [TextStyle? style]) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600).merge(style),
    );
  }

  int _compareItem(int a, int b) {
    final itemA = db.gameData.items[a], itemB = db.gameData.items[b];
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
    final dropRates = db.gameData.dropRate.getSheet(use6th);
    Map<int, String?> dropTexts = {};
    if (preferApRate) {
      final drops = dropRates.getQuestApRate(widget.questId).entries.toList();
      drops.sort((a, b) => _compareItem(a.key, b.key));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value > 1000
            ? entry.value.toInt().toString()
            : entry.value.format(maxDigits: 4);
      }
    } else {
      final drops = dropRates.getQuestDropRate(widget.questId).entries.toList();
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
                : apRate.format(precision: 3, maxDigits: 3);
          }
        } else {
          text = dropRate.format(percent: true, precision: 3, maxDigits: 3);
        }
      }
      if (text != null) {
        if (drop.num == 1) {
          text = ' \n$text';
        } else {
          text = '×${drop.num.format(minVal: 999)}\n$text';
        }
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
          _header(S.current.quest_reward_short),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 1,
                runSpacing: 1,
                children: [
                  if (quest.giftIcon != null)
                    db.getIconImage(quest.giftIcon, width: 36),
                  for (final gift in quest.gifts)
                    gift.iconBuilder(
                      context: context,
                      width: 36,
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget releaseConditions() {
    final conds = quest.releaseConditions
        .where((cond) => !(cond.type == CondType.date && cond.value == 0))
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _header(S.current.quest_condition)),
        for (final cond in conds)
          CondTargetValueDescriptor(
            condType: cond.type,
            target: cond.targetId,
            value: cond.value,
            missions: db.gameData.wars[quest.warId]?.event?.missions ?? [],
          ),
        Text(
            '${S.current.time_start}: ${quest.openedAt.sec2date().toStringShort(omitSec: true)}'),
        Text(
            '${S.current.time_end}: ${quest.closedAt.sec2date().toStringShort(omitSec: true)}'),
      ],
    );
  }
}

class QuestWave extends StatelessWidget {
  final Stage stage;
  final bool showTrueName;
  final Region? region;

  const QuestWave({
    super.key,
    required this.stage,
    this.showTrueName = false,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final npcs = {
      for (final enemy in stage.enemies) enemy.npcId: enemy,
    };
    Set<int> _usedNpcIds = {};

    Widget _buildEnemyWithShift(QuestEnemy? enemy, {bool showDeck = false}) {
      if (enemy == null) return const SizedBox();
      List<Widget> parts = [];
      parts.add(QuestEnemyWidget(
        enemy: enemy,
        showTrueName: showTrueName,
        showDeck: showDeck,
        region: region,
      ));
      if (enemy.enemyScript?.shift != null) {
        for (final shift in enemy.enemyScript!.shift!) {
          final shiftEnemy = npcs[shift];
          if (shiftEnemy == null || shiftEnemy.deck != DeckType.shift) continue;
          parts.add(QuestEnemyWidget(
            enemy: shiftEnemy,
            showTrueName: showTrueName,
            showDeck: showDeck,
            region: region,
          ));
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

    List<Widget> _buildDeck(Iterable<QuestEnemy?> enemies,
        {bool showDeck = false, bool needSort = false}) {
      List<QuestEnemy?> _enemies;
      if (needSort) {
        _enemies = List.filled(
          enemies.fold(0, (p, e) => max(p, e?.deckId ?? 0)),
          null,
          growable: true,
        );
        for (final e in enemies) {
          if (e != null) {
            assert(_enemies[e.deckId - 1] == null);
            _enemies[e.deckId - 1] = e;
          }
        }
        // for (int i = 0; i < _enemies.length ~/ 3; i++) {
        //   if (_enemies.sublist(i * 3, i * 3 + 3).every((e) => e == null)) {
        //     _enemies.removeRange(i * 3, i * 3 + 3);
        //   }
        // }
      } else {
        _enemies = enemies.toList();
      }

      return [
        for (int i = 0; i < _enemies.length / 3; i++)
          Row(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              for (int j in [0, 1, 2])
                Expanded(
                  child: _buildEnemyWithShift(_enemies.getOrNull(i * 3 + j),
                      showDeck: showDeck),
                ),
            ],
          ),
      ];
    }

    // building
    List<Widget> children = [];
    // enemy deck
    final _enemyDeck =
        stage.enemies.where((e) => e.deck == DeckType.enemy).toList();
    children.addAll(_buildDeck(_enemyDeck, needSort: true));
    for (final e in _enemyDeck) {
      _usedNpcIds.add(e.npcId);
      _usedNpcIds.addAll(e.enemyScript?.shift ?? []);
    }
    // call deck
    final _callDeck =
        stage.enemies.where((e) => e.deck == DeckType.call).toList();
    if (_callDeck.isNotEmpty) {
      children.add(const Text('- Call Deck -', textAlign: TextAlign.center));
      children.addAll(_buildDeck(_callDeck, needSort: true));
    }
    _usedNpcIds.addAll(_callDeck.map((e) => e.npcId));
    // others
    final _unknownDeck =
        stage.enemies.where((e) => !_usedNpcIds.contains(e.npcId));
    if (_unknownDeck.isNotEmpty) {
      children.add(const Text('- Unknown Deck -', textAlign: TextAlign.center));
      children.addAll(_buildDeck(_unknownDeck, showDeck: true));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class QuestEnemyWidget extends StatelessWidget {
  final QuestEnemy enemy;
  final bool showTrueName;
  final bool showDeck;
  final Region? region;

  const QuestEnemyWidget({
    super.key,
    required this.enemy,
    this.showTrueName = false,
    this.showDeck = false,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    String displayName = showTrueName ? enemy.svt.lName.l : enemy.lShownName;

    Widget face = db.getIconImage(
      enemy.svt.icon,
      width: 42,
      placeholder: (_) => const SizedBox(),
    );

    if (enemy.misc?.displayType == 2 && !showTrueName) {
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
        db.getIconImage(enemy.svt.className.icon(enemy.svt.rarity), width: 20),
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
        router.push(child: QuestEnemyDetail(enemy: enemy, region: region));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          face,
          LayoutBuilder(builder: (context, constraints) {
            return AutoSizeText(
              [
                displayName,
                if (showDeck) '[${enemy.deck.name}]',
                if (enemy.deck != DeckType.enemy) '*'
              ].join(),
              textAlign: TextAlign.center,
              textScaleFactor: 0.8,
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
