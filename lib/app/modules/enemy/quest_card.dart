import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../common/filter_group.dart';
import 'stage.dart';
import 'support_servant.dart';

class QuestCard extends StatefulWidget {
  final Quest? quest;
  final int questId;
  final bool? use6th;
  final bool offline;
  final Region region;
  final int? chosenPhase;

  QuestCard({
    Key? key,
    required this.quest,
    int? questId,
    this.use6th,
    this.offline = true,
    this.region = Region.jp,
    this.chosenPhase,
  })  : assert(quest != null || questId != null),
        questId = (quest?.id ?? questId)!,
        super(
          key: key ?? Key('QuestCard_${region.name}_${quest?.id ?? questId}'),
        );

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest? _quest;

  Quest get quest => _quest!;
  bool showTrueName = false;

  // ignore: unused_field
  bool? _use6th;
  bool preferApRate = false;

  bool get use6th => true; //  _use6th ?? db.curUser.freeLPParams.use6th;

  bool get show6th {
    return db.gameData.dropRate.getSheet(true).questIds.contains(widget.questId);
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
    if (quest.warId >= 1000 && quest.openedAt < DateTime.now().subtract(const Duration(days: 30)).timestamp) {
      expireAfter = const Duration(days: 7);
    }

    for (final phase in quest.isMainStoryFree ? [quest.phases.last] : quest.phases) {
      AtlasApi.questPhase(questId, phase, region: region, expireAfter: expireAfter).then((_) {
        if (mounted) setState(() {});
      });
    }
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

    String questName = quest.lName.l;
    String chapter = quest.type == QuestType.main
        ? quest.chapterSubStr.isEmpty && quest.chapterSubId != 0
            ? S.current.quest_chapter_n(quest.chapterSubId)
            : quest.chapterSubStr
        : '';
    if (chapter.isNotEmpty) {
      questName = '$chapter $questName';
    }
    List<String> names = [questName, if (!Transl.isJP && quest.name != quest.lName.l) quest.name]
        .map((e) => e.replaceAll('\n', ' '))
        .toList();
    String shownQuestName;
    if (names.any((s) => s.charWidth > 16)) {
      shownQuestName = names.join('\n');
    } else {
      shownQuestName = names.join('/');
    }
    String warName = Transl.warNames(quest.warLongName).l.replaceAll('\n', ' ');
    String scriptPrefix = '';
    final allScriptIds = quest.allScriptIds;
    if (allScriptIds.isNotEmpty && allScriptIds.last.length > 2) {
      scriptPrefix = allScriptIds.last.substring(0, allScriptIds.last.length - 2);
    }

    final List<Widget> phases = [];
    if (quest.phases.isNotEmpty) {
      if (widget.chosenPhase != null && quest.phases.length >= widget.chosenPhase! && widget.chosenPhase! > 0) {
        phases.add(_buildPhases(widget.chosenPhase!, scriptPrefix, shouldDirectToSim: false));
      } else {
        for (final phase in (quest.isMainStoryFree ? [quest.phases.last] : quest.phases)) {
          phases.add(_buildPhases(phase, scriptPrefix));
        }
      }
    }

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
                  Text(
                    shownQuestName,
                    textScaleFactor: 0.9,
                    textAlign: TextAlign.center,
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
      if (phases.isNotEmpty) ...phases,
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

    return InheritSelectionArea(
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ...divideTiles(
              children.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: e,
                ),
              ),
              divider: const Divider(height: 8, thickness: 2),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPhases(int phase, String scriptPrefix, {final bool shouldDirectToSim = true}) {
    List<Widget> children = [];
    QuestPhase? curPhase;
    if (widget.offline) {
      curPhase = db.gameData.getQuestPhase(quest.id, phase) ?? AtlasApi.questPhaseCache(quest.id, phase, widget.region);
    } else {
      curPhase = AtlasApi.questPhaseCache(quest.id, phase, widget.region);
      if (widget.region == Region.jp) {
        curPhase ??= db.gameData.getQuestPhase(quest.id, phase);
      }
    }

    final header = getPhaseHeader(phase, curPhase, shouldDirectToSim);
    if (curPhase == null) return header;
    children.add(header);

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
                    if (stage.enemyFieldPosCount != null) TextSpan(text: '(${stage.enemyFieldPosCount})'),
                    if (stage.hasExtraInfo())
                      WidgetSpan(
                        child: IconButton(
                          onPressed: () {
                            router.pushPage(WaveInfoPage(stage: stage));
                          },
                          icon: const Icon(Icons.music_note, size: 18),
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

    final aiNpcs =
        [curPhase.extraDetail?.aiNpc, ...?curPhase.extraDetail?.aiMultiNpc].whereType<QuestPhaseAiNpc>().toList();
    if (aiNpcs.isNotEmpty) {
      children.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 32,
            child: Text('NPC', textAlign: TextAlign.center),
          ),
          Expanded(
            child: QuestWave(
              stage: null,
              aiNpcs: aiNpcs,
              showTrueName: showTrueName,
              region: widget.region,
            ),
          )
        ],
      ));
    }

    if (curPhase.individuality.isNotEmpty &&
        (curPhase.stages.isNotEmpty || (curPhase.consume != 0 && curPhase.consumeItem.isNotEmpty))) {
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
    if (!widget.offline && curPhase.restrictions.isNotEmpty) {
      final shortMsg = curPhase.restrictions
          .map((e) => _QuestRestriction.getText(restriction: e, all: false, leading: false))
          .firstWhereOrNull((e) => e.isNotEmpty);
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: InkWell(
          onTap: () {
            router.pushPage(_QuestRestriction(restrictions: curPhase?.restrictions ?? []));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(S.current.quest_restriction),
              Text(shortMsg ?? '??????'),
              const SizedBox(width: double.infinity),
            ],
          ),
        ),
      ));
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
              enabled: false,
              // onFilterChanged: (v, _) {
              //   setState(() {
              //     _use6th = !use6th;
              //   });
              // },
            ),
        ],
      ));
    }
    if (show6th) {
      final sheetData = db.gameData.dropRate.getSheet(use6th);
      int runs = sheetData.runs.getOrNull(sheetData.questIds.indexOf(quest.id)) ?? 0;
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

  Widget getPhaseHeader(int phase, QuestPhase? curPhase, final bool shouldDirectToSim) {
    final effPhase = curPhase ?? (quest.phases.length == 1 ? quest : null);
    final failed = AtlasApi.cacheManager.isFailed('/nice/${widget.region.upper}/quest/${quest.id}/$phase');
    if (effPhase == null) {
      List<Widget> rowChildren = [];
      rowChildren.add(Text('  $phase/${quest.phases.length}  '));
      if (quest.phasesNoBattle.contains(phase)) {
        rowChildren.add(const Expanded(child: Text('No Battle', textAlign: TextAlign.center)));
      } else if (!widget.offline) {
        if (failed) {
          rowChildren.add(
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Center(child: Icon(Icons.error_outline)),
              ),
            ),
          );
        } else {
          rowChildren.add(
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        }
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
    String spotJp = effPhase.lSpot.jp;
    String spot = effPhase.lSpot.l;
    String shownSpotName = spotJp == spot ? spot : '$spot/$spotJp';
    final layer = kLB7SpotLayers[quest.spotId];
    if (layer != null && quest.type == QuestType.free) {
      shownSpotName = '${S.current.map_layer_n(layer)} $shownSpotName';
    }

    bool noConsume = effPhase.consumeType == ConsumeType.ap && effPhase.consume == 0;
    final questSelects = curPhase?.extraDetail?.questSelect;
    List<Widget> headerRows = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              '$phase/${Maths.max(effPhase.phases, 0)}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              shownSpotName,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              textScaleFactor: 0.9,
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Text.rich(
              TextSpan(children: [
                if (effPhase.consumeType != ConsumeType.item) TextSpan(text: 'AP ${effPhase.consume}'),
                for (final itemAmount in effPhase.consumeItem)
                  WidgetSpan(
                    child: Item.iconBuilder(
                      context: context,
                      item: itemAmount.item,
                      text: itemAmount.amount.format(),
                      width: 28,
                    ),
                  )
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Lv.${effPhase.recommendLv}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              '${S.current.bond} ${noConsume ? "-" : curPhase?.bond ?? "?"}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              'EXP ${noConsume ? "-" : curPhase?.exp ?? "?"}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      if (questSelects != null && questSelects.isNotEmpty)
        Text.rich(
          TextSpan(text: '${S.current.branch_quest}: ', children: [
            for (final selectId in questSelects)
              if (selectId != effPhase.id)
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: ' $selectId ',
                  onTap: () => router.push(url: Routes.questI(selectId)),
                )
          ]),
          textAlign: TextAlign.center,
        )
    ];
    Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      children: headerRows,
    );
    final spotImage = effPhase.spot?.shownImage;
    header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: header),
        if (spotImage != null) db.getIconImage(spotImage, height: 42, aspectRatio: 1),
        if (shouldDirectToSim) IconButton(
          onPressed: () {
            router.pushPage(SimulationPreview(
              region: widget.region,
              quest: quest,
              phase: phase,
            ));
          },
          icon: const Icon(Icons.calculate, size: 18),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ],
    );

    if (curPhase == null && !failed) {
      header = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const Padding(
            padding: EdgeInsets.all(4),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    return header;
  }

  List<Widget> getPhaseScript(int phase) {
    final scripts = quest.phaseScripts.firstWhereOrNull((e) => e.phase == phase)?.scripts;
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
                      text: '{${s.shortId()}}',
                      style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),
                      onTap: () {
                        s.routeTo(region: widget.region);
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
    TextSpan _mono(dynamic v, int width) => TextSpan(text: v.toString().padRight(width), style: kMonoStyle);
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
              _mono(svt.lv, curPhase.supportServants.any((e) => e.lv >= 100) ? 3 : 2),
              TextSpan(text: ' ${S.current.np_short} Lv.'),
              _mono(_nullLevel(svt.noblePhantasm.noblePhantasmLv, svt.noblePhantasm.noblePhantasm), 1),
              TextSpan(text: ' ${S.current.skill} Lv.'),
              _mono(
                  '${_nullLevel(svt.skills.skillLv1, svt.skills.skill1)}'
                  '/${_nullLevel(svt.skills.skillLv2, svt.skills.skill2)}'
                  '/${_nullLevel(svt.skills.skillLv3, svt.skills.skill3)}',
                  8),
              const TextSpan(text: '  ')
            ],
            style: svt.script?.eventDeckIndex == null ? null : TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (final ce in svt.equips) ...[
            CenterWidgetSpan(child: ce.equip.iconBuilder(context: context, width: 32)),
            TextSpan(
              children: [
                const TextSpan(text: ' Lv.'),
                _mono(ce.lv, 2),
              ],
              style: ce.limitCount == 4 ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
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

  Widget getRestriction(QuestPhase curPhase) {
    List<Widget> children = [_header(S.current.quest_restriction)];
    for (final restriction in curPhase.restrictions) {
      for (final msg in [restriction.noticeMessage, restriction.dialogMessage, restriction.restriction.name]) {
        if (msg.isNotEmpty && msg != '0') {
          children.add(Text(msg.replaceAll('\n', ' ')));
          break;
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              List<Widget> rows = [];
              for (int index = 0; index < curPhase.restrictions.length; index++) {
                final restriction = curPhase.restrictions[index];
                if (curPhase.restrictions.length > 1) {
                  rows.add(SHeader('${S.current.quest_restriction} ${index + 1}'));
                }
                final messages = <String>{};
                for (final msg in [
                  restriction.title,
                  restriction.noticeMessage,
                  restriction.dialogMessage,
                  restriction.restriction.name
                ]) {
                  if (msg.isEmpty || msg == '0') continue;
                  messages.add(msg.replaceAll('\n', ' '));
                }
                if (messages.isNotEmpty) {
                  rows.add(CustomTableRow.fromTexts(texts: [messages.join('\n')]));
                }
                rows.add(CustomTableRow.fromTexts(texts: [
                  restriction.restriction.type.name,
                  restriction.restriction.rangeType.name,
                  if (restriction.restriction.targetVals.isNotEmpty) restriction.restriction.targetVals.join(', '),
                  if (restriction.restriction.targetVals2.isNotEmpty) restriction.restriction.targetVals2.join(', '),
                ]));
              }
              return SimpleCancelOkDialog(
                title: Text(S.current.quest_restriction),
                content: CustomTable(selectable: true, children: rows),
                scrollable: true,
                hideCancel: true,
              );
            },
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Text _header(String text, [TextStyle? style]) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600).merge(style),
    );
  }

  /// only drops of free quest useApRate
  Widget _getDomusAureaWidget() {
    final dropRates = db.gameData.dropRate.getSheet(use6th);
    Map<int, String?> dropTexts = {};
    if (preferApRate) {
      final drops = dropRates.getQuestApRate(widget.questId).entries.toList();
      drops.sort((a, b) => Item.compare2(a.key, b.key, true));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value > 1000 ? entry.value.toInt().toString() : entry.value.format(maxDigits: 4);
      }
    } else {
      final drops = dropRates.getQuestDropRate(widget.questId).entries.toList();
      drops.sort((a, b) => Item.compare2(a.key, b.key, true));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value.format(percent: true, maxDigits: 3);
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
            option: ImageWithTextOption(fontSize: 42 * 0.27, padding: EdgeInsets.zero),
          )
      ],
    );
  }

  Widget _getRayshiftDrops(List<EnemyDrop> drops) {
    drops = List.of(drops);
    drops.sort((a, b) => Item.compare2(a.objectId, b.objectId, true));
    List<Widget> children = [];
    for (final drop in drops) {
      String? text;
      if (drop.runs != 0) {
        double dropRate = drop.dropCount / drop.runs;
        if (preferApRate) {
          if (quest.consumeType == ConsumeType.ap && quest.consume > 0 && dropRate != 0.0) {
            double apRate = quest.consume / dropRate;
            text = apRate >= 1000 ? apRate.toInt().toString() : apRate.format(precision: 3, maxDigits: 4);
          }
        } else {
          text = dropRate.format(percent: true, maxDigits: 3);
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
        option: ImageWithTextOption(fontSize: 42 * 0.27, padding: EdgeInsets.zero),
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
                  if (quest.giftIcon != null) db.getIconImage(quest.giftIcon, width: 36),
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
    final conds = quest.releaseConditions.where((cond) => !(cond.type == CondType.date && cond.value == 0)).toList();
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
        Text('${S.current.time_start}: ${quest.openedAt.sec2date().toStringShort(omitSec: true)}'),
        Text('${S.current.time_end}: ${quest.closedAt.sec2date().toStringShort(omitSec: true)}'),
      ],
    );
  }
}

class _QuestRestriction extends StatelessWidget {
  final List<QuestPhaseRestriction> restrictions;
  const _QuestRestriction({required this.restrictions});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int index = 0; index < restrictions.length; index++) {
      final restriction = restrictions[index];
      if (restrictions.length > 1) {
        children.add(SHeader('${S.current.quest_restriction} ${index + 1}'));
      }
      final re = restriction.restriction;
      String rangeText = '';
      switch (re.rangeType) {
        case RestrictionRangeType.none:
          break;
        case RestrictionRangeType.equal:
          rangeText += 'Equal(=) ';
          break;
        case RestrictionRangeType.notEqual:
          rangeText += 'NotEqual(≠) ';
          break;
        case RestrictionRangeType.above:
          rangeText += 'Above(>)';
          break;
        case RestrictionRangeType.below:
          rangeText += 'Below(<)';
          break;
        case RestrictionRangeType.between:
          rangeText += 'Between(a≤x≤b)';
          break;
      }
      children.add(CustomTable(
        children: [
          CustomTableRow(children: [
            TableCellData(
              text: getText(restriction: restriction, all: true, leading: true),
              alignment: AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            )
          ]),
          CustomTableRow(children: [
            TableCellData(text: S.current.general_type, isHeader: true),
            TableCellData(text: restriction.restriction.type.name, flex: 3)
          ]),
          CustomTableRow(children: [
            TableCellData(text: 'Value', isHeader: true),
            TableCellData(
              child: Text.rich(TextSpan(text: rangeText, children: [
                if (re.targetVals.isNotEmpty && rangeText.isNotEmpty) const TextSpan(text: ': '),
                ...guessVal(context, re.targetVals, restriction.restriction.type),
                if (re.targetVals2.isNotEmpty) const TextSpan(text: '; '),
                ...guessVal(context, re.targetVals2, restriction.restriction.type),
              ])),
              flex: 3,
            )
          ]),
        ],
      ));
    }
    return Scaffold(
      appBar: AppBar(title: Text(S.current.quest_restriction)),
      body: ListView(children: children),
    );
  }

  List<InlineSpan> guessVal(BuildContext context, List<int> vals, RestrictionType type) {
    return divideList([
      for (final val in vals)
        val > 99
            ? SharedBuilder.textButtonSpan(
                context: context,
                text: val.toString(),
                onTap: () {
                  if (type == RestrictionType.alloutBattleUniqueSvt) {
                    router.push(url: Routes.eventI(val));
                  } else {
                    router.push(url: Routes.traitI(val));
                  }
                },
              )
            : TextSpan(text: val.toString())
    ], const TextSpan(text: ', '));
  }

  static String getText({
    required QuestPhaseRestriction restriction,
    required bool all,
    required bool leading,
  }) {
    final messages = <String>{};
    for (final msg in [restriction.noticeMessage, restriction.dialogMessage, restriction.restriction.name]) {
      if (msg.isNotEmpty && msg != '0') {
        messages.add(msg.replaceAll('\n', ' '));
      }
    }
    if (messages.isEmpty) return '';
    if (all) {
      return messages.map((e) => leading ? '$kULLeading $e' : e).join('\n');
    } else {
      return leading ? '$kULLeading ${messages.first}' : messages.first;
    }
  }
}
