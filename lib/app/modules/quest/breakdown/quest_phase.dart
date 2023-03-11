import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/battle_simulation.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../enemy/support_servant.dart';
import 'stage.dart';

typedef _QuestPhaseSelectCallback = void Function(QuestPhase quest);

class QuestPhaseWidget extends StatefulWidget {
  final Quest quest;
  final QuestPhase? questPhase;
  final int phase;
  final Region? region;
  final bool offline;
  final bool showTrueName;
  final bool battleOnly;

  QuestPhaseWidget({
    super.key,
    required this.quest,
    required this.phase,
    this.region,
    this.offline = false,
    this.showTrueName = true,
    this.battleOnly = false,
  })  : assert(quest.phases.contains(phase)),
        questPhase = null;

  QuestPhaseWidget.phase({
    super.key,
    required QuestPhase this.questPhase,
    this.region = Region.jp,
    this.offline = false,
    this.showTrueName = true,
    this.battleOnly = false,
  })  : quest = questPhase,
        phase = questPhase.phase;

  @override
  State<QuestPhaseWidget> createState() => _QuestPhaseWidgetState();

  // select quest callback
  static final List<_PhaseSelectCbInfo> _phaseCallbacks = [];

  static void addPhaseSelectCallback(_QuestPhaseSelectCallback cb) {
    removePhaseSelectCallback(cb);
    _phaseCallbacks.add(_PhaseSelectCbInfo(router, cb));
  }

  static void removePhaseSelectCallback(_QuestPhaseSelectCallback cb) {
    final index = _phaseCallbacks.lastIndexWhere((info) => info.cb == cb);
    if (index >= 0) _phaseCallbacks.removeAt(index);
  }
}

class _QuestPhaseWidgetState extends State<QuestPhaseWidget> {
  Quest get quest => widget.quest;
  int get phase => widget.phase;

  QuestPhase? questPhase;
  String? _enemyHash;
  bool preferApRate = false;

  @override
  void initState() {
    super.initState();
    if (quest.isDomusQuest) preferApRate = db.settings.preferApRate;
    _init();
  }

  @override
  void didUpdateWidget(covariant QuestPhaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.quest != widget.quest ||
        oldWidget.phase != widget.phase ||
        oldWidget.questPhase != widget.questPhase ||
        oldWidget.region != widget.region ||
        oldWidget.offline != widget.offline) {
      _init();
    }
  }

  void _init() async {
    _fetchData();
  }

  Future<void> _fetchData() async {
    questPhase = null;
    if (mounted) setState(() {});
    questPhase = widget.questPhase;
    if (questPhase != null) return;

    final questId = quest.id;
    final phase = widget.phase;
    final hash = _enemyHash;
    final region = widget.region ?? Region.jp;

    Duration? expireAfter;
    if (quest.warId >= 1000 && quest.openedAt < DateTime.now().subtract(const Duration(days: 30)).timestamp) {
      expireAfter = const Duration(days: 7);
    }

    final data = await AtlasApi.questPhase(questId, phase, hash: hash, region: region, expireAfter: expireAfter);
    if (data != null &&
        questId == widget.quest.id &&
        phase == widget.phase &&
        hash == _enemyHash &&
        region == (widget.region ?? Region.jp)) {
      questPhase = data;
    }
    if (mounted) setState(() {});
  }

  QuestPhase? getCachedData() {
    QuestPhase? curPhase;
    if (widget.offline) {
      curPhase = db.gameData.getQuestPhase(quest.id, phase) ??
          AtlasApi.questPhaseCache(quest.id, phase, _enemyHash, widget.region ?? Region.jp);
    } else {
      curPhase = AtlasApi.questPhaseCache(quest.id, phase, _enemyHash, widget.region ?? Region.jp);
      if (widget.region == Region.jp) {
        curPhase ??= db.gameData.getQuestPhase(quest.id, phase);
      }
    }
    return curPhase;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    QuestPhase? curPhase = questPhase ?? getCachedData();

    final header = getPhaseHeader(phase, curPhase);
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
              showTrueName: widget.showTrueName,
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
              showTrueName: widget.showTrueName,
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
                format: (trait) => trait.shownName(field: false),
              ),
            )
          ],
        ),
      ));
    }
    if (!widget.battleOnly && !widget.offline && curPhase.supportServants.isNotEmpty) {
      children.add(getSupportServants(curPhase));
    }
    if (!widget.battleOnly && !widget.offline && curPhase.restrictions.isNotEmpty) {
      final shortMsg = curPhase.restrictions
          .map((e) => _QuestRestriction.getText(restriction: e, all: false, leading: false))
          .firstWhereOrNull((e) => e.isNotEmpty);
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: InkWell(
          onTap: () {
            router.pushPage(_QuestRestriction(restrictions: curPhase.restrictions));
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
    final sheetData = db.gameData.dropData.domusAurea;
    final _questIndex = sheetData.questIds.indexOf(quest.id);
    if (!widget.battleOnly && (curPhase.drops.isNotEmpty || _questIndex >= 0)) {
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
        ],
      ));
    }
    if (!widget.battleOnly && _questIndex >= 0) {
      int runs = sheetData.runs.getOrNull(_questIndex) ?? 0;
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          Text('${S.current.fgo_domus_aurea} (${S.current.quest_runs(runs)})'),
          const SizedBox(height: 2),
          _getDomusAureaWidget(),
          const SizedBox(height: 3),
        ],
      ));
    }

    if (!widget.battleOnly && curPhase.drops.isNotEmpty) {
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          Text('Rayshift Drops (${S.current.quest_runs(curPhase.drops.first.runs)})'),
          const SizedBox(height: 2),
          _getRayshiftDrops(curPhase.drops),
          const SizedBox(height: 3),
        ],
      ));
    }
    if (!widget.battleOnly) {
      children.addAll(getPhaseScript(phase));
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

  Widget getPhaseHeader(int phase, QuestPhase? curPhase) {
    final effPhase = curPhase ?? (quest.phases.length == 1 ? quest : null);
    final failed =
        AtlasApi.cacheManager.isFailed(AtlasApi.questPhaseUrl(quest.id, phase, _enemyHash, widget.region ?? Region.jp));
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

    bool noConsume = effPhase.flags.contains(QuestFlag.noBattle) ||
        (effPhase.consumeType == ConsumeType.ap && effPhase.consume == 0);
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
                if (effPhase.consumeType.useAp) TextSpan(text: 'AP ${effPhase.consume}'),
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
    if (curPhase != null) {
      if (_enemyHash != null && !curPhase.enemyHashes.contains(_enemyHash)) {
        _enemyHash = null;
      }
      if (curPhase.enemyHashes.length > 1 && !widget.battleOnly) {
        headerRows.add(getQuestVersionDropdown(curPhase));
      }
    }
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
        if (curPhase != null && curPhase.stages.isNotEmpty && !widget.battleOnly)
          IconButton(
            onPressed: () {
              _PhaseSelectCbInfo? found;
              for (final info in QuestPhaseWidget._phaseCallbacks) {
                if (info.srcRouter == router) {
                  info.cb(curPhase);
                  found = info;
                  break;
                }
              }
              if (found != null) {
                QuestPhaseWidget._phaseCallbacks.remove(found);
              } else {
                router.pushPage(SimulationPreview(
                  region: widget.region,
                  questPhase: questPhase,
                ));
              }
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

  Widget getQuestVersionDropdown(QuestPhase curPhase) {
    if (_enemyHash != null && !curPhase.enemyHashes.contains(_enemyHash)) {
      _enemyHash = null;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Center(
            child: DropdownButton<String>(
              isDense: true,
              iconSize: 16,
              value: _enemyHash ?? curPhase.enemyHash,
              items: List.generate(curPhase.enemyHashes.length, (index) {
                final hash = curPhase.enemyHashes[index];
                int? count = int.tryParse(hash.substring2(2, 4));
                String text = S.current.quest_version(index + 1, curPhase.enemyHashes.length, count ?? "?");
                return DropdownMenuItem(
                  value: hash,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
              onChanged: (v) {
                _enemyHash = v;
                _fetchData();
                setState(() {});
              },
            ),
          ),
        )
      ],
    );
  }

  Text _header(String text, [TextStyle? style]) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600).merge(style),
    );
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

  /// only drops of free quest useApRate
  Widget _getDomusAureaWidget() {
    final dropRates = db.gameData.dropData.domusAurea;
    Map<int, String?> dropTexts = {};
    if (preferApRate) {
      final drops = dropRates.getQuestApRate(widget.quest.id).entries.toList();
      drops.sort((a, b) => Item.compare2(a.key, b.key, true));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value > 1000 ? entry.value.toInt().toString() : entry.value.format(maxDigits: 4);
      }
    } else {
      final drops = dropRates.getQuestDropRate(widget.quest.id).entries.toList();
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
          if (quest.consume > 0 && dropRate != 0.0) {
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

class _PhaseSelectCbInfo {
  final AppRouterDelegate srcRouter;
  final _QuestPhaseSelectCallback cb;
  _PhaseSelectCbInfo(this.srcRouter, this.cb);
}
