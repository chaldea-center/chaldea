import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/battle/simulation_preview.dart';
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
  final String? enemyHash;
  final Region? region;
  final bool offline;
  final bool showTrueName;
  final bool? showFace;
  final bool battleOnly;

  QuestPhaseWidget({
    super.key,
    required this.quest,
    required this.phase,
    this.enemyHash,
    this.region,
    this.offline = false,
    this.showTrueName = true,
    this.showFace,
    this.battleOnly = false,
  })  : assert(quest.phases.contains(phase)),
        questPhase = null;

  QuestPhaseWidget.phase({
    super.key,
    required QuestPhase this.questPhase,
    this.region = Region.jp,
    this.offline = false,
    this.showTrueName = true,
    this.showFace,
    this.battleOnly = false,
  })  : quest = questPhase,
        phase = questPhase.phase,
        enemyHash = questPhase.enemyHash;

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
  bool _sumEventItem = true;

  @override
  void initState() {
    super.initState();
    if (quest.isDomusQuest) preferApRate = db.settings.preferApRate;
    _enemyHash = widget.enemyHash;
    _init();
  }

  @override
  void didUpdateWidget(covariant QuestPhaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.quest != widget.quest ||
        oldWidget.phase != widget.phase ||
        oldWidget.questPhase != widget.questPhase ||
        oldWidget.enemyHash != widget.enemyHash ||
        oldWidget.region != widget.region ||
        oldWidget.offline != widget.offline) {
      if (oldWidget.quest != widget.quest || oldWidget.phase != widget.phase || oldWidget.region != widget.region) {
        _enemyHash = widget.enemyHash;
      }
      _init();
    }
  }

  void _init() {
    if (widget.questPhase != null) {
      questPhase = widget.questPhase;
      _enemyHash = questPhase?.enemyHashOrTotal;
    } else {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    questPhase = null;
    if (mounted) setState(() {});

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

  QuestPhase? getCachedData([String? overrideHash = '']) {
    String? hash = overrideHash == '' ? _enemyHash : overrideHash?.trim();
    return AtlasApi.questPhaseCache(quest.id, phase, hash, widget.region ?? Region.jp);
  }

  @override
  Widget build(BuildContext context) {
    QuestPhase? curPhase = questPhase ?? getCachedData();
    List<Widget?> children = [
      getPhaseHeader(phase, curPhase),
    ];
    if (curPhase != null) {
      for (final stage in curPhase.stages) {
        children.add(buildStage(curPhase, stage));
        final stageCutin = stage.cutin;
        if (stageCutin != null && !widget.battleOnly) {
          children.add(_buildStageCutin(context, stageCutin));
        }
      }
      children.addAll([
        buildAiNpc(curPhase),
        buildQuestIndiv(curPhase),
        getFlags(curPhase.flags),
        getOverwriteMysticCode(curPhase),
        getSupportServants(curPhase),
        buildRestriction(curPhase.restrictions),
        ...buildDrops(curPhase),
      ]);
    }

    children.addAll([
      getWarBoard(),
      getPhaseScript(phase),
      getPhasePresent(phase),
    ]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: divideTiles(
        children.whereType<Widget>(),
        divider: const Divider(height: 5, thickness: 0.5),
      ),
    );
  }

  Text _header(String text, [TextStyle? style]) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600).merge(style),
    );
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        AtlasApi.cacheManager.clearFailed();
                      });
                    },
                    child: const Icon(Icons.error_outline),
                  ),
                ),
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
        ],
      );
    }
    String spotJp = effPhase.lSpot.jp;
    String spot = effPhase.lSpot.l;
    String shownSpotName = spotJp == spot || widget.battleOnly ? spot : '$spot/$spotJp';
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
              textScaler: const TextScaler.linear(0.9),
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
                if (effPhase.consumeType.useApOrBp) TextSpan(text: '${effPhase.consumeType.unit} ${effPhase.consume}'),
                for (final itemAmount in effPhase.consumeItem)
                  WidgetSpan(
                    child: Item.iconBuilder(
                      context: context,
                      item: itemAmount.item,
                      text: itemAmount.amount.format(),
                      width: 20,
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
      if (curPhase.enemyHashes.length > 1) {
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
        if (curPhase != null && curPhase.allEnemies.isNotEmpty && !widget.battleOnly)
          IconButton(
            onPressed: () {
              _PhaseSelectCbInfo? found;
              final curRouter = AppRouter.of(context) ?? router;
              for (final info in QuestPhaseWidget._phaseCallbacks) {
                if (info.srcRouter == curRouter) {
                  info.cb(curPhase);
                  found = info;
                  break;
                }
              }
              if (found != null) {
                QuestPhaseWidget._phaseCallbacks.remove(found);
              } else {
                curRouter.pushPage(SimulationPreview(
                  region: widget.region,
                  questPhase: questPhase,
                ));
              }
            },
            icon: const Icon(Icons.calculate, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Theme.of(context).colorScheme.primaryContainer,
            tooltip: S.current.battle_simulation,
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
    const int kMaxHashCount = 100;
    List<String?> shownHashes = [null, ...curPhase.enemyHashes.take(kMaxHashCount)];
    if (!shownHashes.contains(_enemyHash)) {
      shownHashes.add(_enemyHash);
    }

    // final hashsWithNull = [null, ...curPhase.enemyHashes];
    final noHashPhase = getCachedData(null);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Center(
            child: DropdownButton<String?>(
              isDense: true,
              iconSize: 16,
              value: _enemyHash,
              items: List.generate(shownHashes.length, (index) {
                final hash = shownHashes[index];
                String text;
                if (hash == null) {
                  text = S.current.total;
                  final runs = noHashPhase?.drops.getOrNull(0)?.runs;
                  if (runs != null) {
                    text += ' [${S.current.quest_runs(runs)}]';
                  }
                } else {
                  int? count = int.tryParse(hash.substring2(2, 4));
                  String versions = curPhase.enemyHashes.length.toString();
                  if (db.gameData.getQuestPhase(curPhase.id, curPhase.phase) != null &&
                      [100, 101].contains(curPhase.enemyHashes.length)) {
                    versions += '+';
                  }
                  text = S.current.quest_version(index, versions, count ?? "?");
                }
                TextStyle? style = Theme.of(context).textTheme.bodySmall;
                if (hash == null || hash == noHashPhase?.enemyHash) {
                  style ??= const TextStyle();
                  style = style.copyWith(fontWeight: FontWeight.bold);
                }
                return DropdownMenuItem(
                  value: hash,
                  child: Text(text, style: style),
                );
              }),
              onChanged: widget.battleOnly
                  ? null
                  : (v) {
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

  Widget buildStage(QuestPhase curPhase, Stage stage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 32,
          child: Text.rich(
            TextSpan(
              children: divideList(
                [
                  TextSpan(text: '${stage.wave}'),
                  if (stage.enemyFieldPosCount != null) TextSpan(text: '(${stage.enemyFieldPosCount})'),
                  WidgetSpan(
                    child: IconButton(
                      onPressed: () {
                        router.pushPage(WaveInfoPage(questPhase: curPhase, stage: stage, region: widget.region));
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
            questPhase: curPhase,
            stage: stage,
            showTrueName: widget.showTrueName,
            showFace: widget.showFace,
            region: widget.region,
          ),
        )
      ],
    );
  }

  Widget _buildStageCutin(BuildContext context, StageCutin cutin) {
    List<Widget> children = [];
    children.add(Text(
      'Stage Cutin (${S.current.quest_runs(cutin.runs)})',
      style: const TextStyle(
        // fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ));
    if (cutin.skills.isNotEmpty) {
      children.add(Text.rich(SharedBuilder.textButtonSpan(
        context: context,
        text: '${cutin.skills.length} ${S.current.skill}',
        onTap: () {
          showDialog(
            context: context,
            useRootNavigator: false,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Stage Cutin Skills'),
                titlePadding: const EdgeInsets.fromLTRB(16.0, 24.0, 24.0, 0.0),
                children: [
                  for (final skill in cutin.skills)
                    ListTile(
                      dense: true,
                      minLeadingWidth: 24,
                      title: Text(skill.skill.dispName),
                      leading: skill.skill.icon != null ? db.getIconImage(skill.skill.icon, width: 24) : null,
                      trailing: Text(
                        '${(skill.appearCount / cutin.runs * 100).toStringAsPrecision(3)}%'
                        '\n(${skill.appearCount}/${cutin.runs})',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.end,
                      ),
                      onTap: skill.skill.routeTo,
                    ),
                ],
              );
            },
          );
        },
      )));
    }
    if (cutin.drops.isNotEmpty) {
      children.add(_getRayshiftDrops(cutin.drops, false));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget? buildAiNpc(QuestPhase curPhase) {
    final aiNpcs =
        [curPhase.extraDetail?.aiNpc, ...?curPhase.extraDetail?.aiMultiNpc].whereType<QuestPhaseAiNpc>().toList();
    if (aiNpcs.isEmpty) return null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          width: 32,
          child: Text('NPC', textAlign: TextAlign.center),
        ),
        Expanded(
          child: QuestWave(
            questPhase: curPhase,
            stage: null,
            aiNpcs: aiNpcs,
            showTrueName: widget.showTrueName,
            showFace: widget.showFace,
            region: widget.region,
          ),
        )
      ],
    );
  }

  Widget? buildQuestIndiv(QuestPhase curPhase) {
    if (curPhase.individuality.isEmpty || curPhase.flags.contains(QuestFlag.noBattle)) return null;
    return Padding(
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
              format: (trait) {
                return trait.shownName().replaceFirst(RegExp('^[^:]+:'), '').trim();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget? getFlags(List<QuestFlag> flags) {
    if (flags.isEmpty || widget.battleOnly) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _header("Flags "),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: divideList([
                  for (final flag in flags)
                    TextSpan(
                      text: flag.name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '\u200B${match.group(0)}'),
                      style: const TextStyle(fontSize: 12),
                    )
                ], const TextSpan(text: ' / ')),
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget? getOverwriteMysticCode(QuestPhase curPhase) {
    final equips = [curPhase.extraDetail?.overwriteEquipSkills, curPhase.extraDetail?.addEquipSkills]
        .whereType<OverwriteEquipSkills>()
        .toList();
    if (equips.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(S.current.mystic_code),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final equip in equips) ...[
                if ((equip.iconId ?? 0) > 0) db.getIconImage(equip.icon, width: 36, aspectRatio: 1),
                const SizedBox(width: 8),
                for (final equipSkill in equip.skills)
                  FutureBuilder2<int, NiceSkill?>(
                    id: equipSkill.id,
                    loader: () => AtlasApi.skill(equipSkill.id),
                    builder: (context, skill) {
                      if (skill == null) {
                        return Text(
                          equipSkill.id.toString(),
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        );
                      }
                      return db.getIconImage(
                        skill.icon ?? Atlas.common.unknownSkillIcon,
                        width: 24,
                        aspectRatio: 1,
                        onTap: skill.routeTo,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                      );
                    },
                  ),
                Text('  Lv.${equip.skillLv}   '),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget? getSupportServants(QuestPhase curPhase) {
    if (curPhase.supportServants.isEmpty || widget.battleOnly || widget.offline) return null;
    List<Widget> supports = [];
    for (final svt in curPhase.supportServants) {
      supports.add(SupportServantTile(
        svt: svt,
        onTap: () {
          router.pushPage(SupportServantPage(svt, region: widget.region));
        },
        region: widget.region,
        hasLv100: curPhase.supportServants.any((e) => e.lv >= 100),
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

  Widget? buildRestriction(List<QuestPhaseRestriction> restrictions) {
    if (restrictions.isEmpty || widget.battleOnly || widget.offline) return null;
    final shortMsg = restrictions
        .map((e) => _QuestRestriction.getText(restriction: e, all: false, leading: false))
        .firstWhereOrNull((e) => e.isNotEmpty);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () {
          router.pushPage(_QuestRestriction(restrictions: restrictions));
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
    );
  }

  List<Widget> buildDrops(QuestPhase curPhase) {
    List<Widget> children = [];
    if (widget.battleOnly) return children;

    final sheetData = db.gameData.dropData.domusAurea;
    final _questIndex = sheetData.questIds.indexOf(quest.id);

    bool hasMultiEventItem = false;
    Map<int, int> eventItems = {};
    for (final drop in curPhase.drops) {
      final item = db.gameData.items[drop.objectId];
      if (drop.type == GiftType.item &&
          (drop.objectId == Items.qpId || [ItemCategory.event, ItemCategory.other].contains(item?.category))) {
        eventItems.addNum(drop.objectId, 1);
      }
    }
    if (eventItems.values.any((e) => e > 1)) hasMultiEventItem = true;

    if (curPhase.drops.isNotEmpty || _questIndex >= 0) {
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
          if (hasMultiEventItem)
            IconButton(
              icon: Icon(_sumEventItem ? Icons.unfold_more : Icons.unfold_less),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              tooltip: S.current.merge_same_drop,
              onPressed: () {
                setState(() {
                  _sumEventItem = !_sumEventItem;
                });
              },
            )
        ],
      ));
    }
    if (_questIndex >= 0) {
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

    if (curPhase.drops.isNotEmpty) {
      final bool showDropHint = curPhase.dropsFromAllHashes == true && curPhase.enemyHashes.length > 1;
      Widget header = Text.rich(TextSpan(
        text: 'Rayshift Drops (',
        children: [
          TextSpan(text: S.current.quest_runs(curPhase.drops.first.runs)),
          if (showDropHint) const CenterWidgetSpan(child: Icon(Icons.help_outline, size: 18)),
          const TextSpan(text: ')'),
        ],
      ));
      if (showDropHint) {
        header = InkWell(
          child: header,
          onTap: () {
            SimpleCancelOkDialog(
              title: Text(S.current.game_drop),
              content: Text(S.current.drop_from_all_hashes_hint),
              hideCancel: true,
            ).showDialog(context);
          },
        );
      }
      children.add(Column(
        children: [
          const SizedBox(height: 3),
          header,
          if (_enemyHash == null && curPhase.allEnemies.any((e) => e.isRareOrAddition))
            Text(
              S.current.drops_warning_has_rare_enemy,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
              ),
            ),
          const SizedBox(height: 2),
          _getRayshiftDrops(curPhase.drops, hasMultiEventItem && _sumEventItem),
          const SizedBox(height: 3),
        ],
      ));
    }
    return children;
  }

  /// only drops of free quest useApRate
  final double _itemSize = 40.0;
  Widget _getDomusAureaWidget() {
    final dropRates = db.gameData.dropData.domusAurea;
    Map<int, String?> dropTexts = {};
    if (preferApRate) {
      final drops = dropRates.getQuestApRate(widget.quest.id).entries.toList();
      drops.sort((a, b) => Item.compare2(a.key, b.key));
      for (final entry in drops) {
        dropTexts[entry.key] = entry.value > 1000 ? entry.value.toInt().toString() : entry.value.format(maxDigits: 4);
      }
    } else {
      final drops = dropRates.getQuestDropRate(widget.quest.id).entries.toList();
      drops.sort((a, b) => Item.compare2(a.key, b.key));
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
            width: _itemSize,
            option: ImageWithTextOption(fontSize: _itemSize * 0.27, padding: EdgeInsets.zero),
          )
      ],
    );
  }

  Widget _getRayshiftDrops(List<EnemyDrop> drops, bool sumEventItem) {
    drops = List.of(drops);
    drops.sort((a, b) => Item.compare2(a.objectId, b.objectId));
    List<Widget> children = [];
    Widget _singleDrop(EnemyDrop drop) {
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
      return drop.iconBuilder(
        context: context,
        width: _itemSize,
        text: text ?? '-',
        option: ImageWithTextOption(fontSize: _itemSize * 0.27, padding: EdgeInsets.zero),
      );
    }

    if (!sumEventItem) {
      for (final drop in drops) {
        children.add(_singleDrop(drop));
      }
    } else {
      Map<String, List<EnemyDrop>> grouped = {};
      for (final drop in drops) {
        grouped.putIfAbsent('${drop.type}-${drop.objectId}', () => []).add(drop);
      }
      for (final subdrops in grouped.values) {
        final drop = subdrops.first;
        final item = db.gameData.items[drop.objectId];
        bool shouldSum = [ItemCategory.event, ItemCategory.other].contains(item?.category) || subdrops.length > 1;
        if (!shouldSum) {
          children.add(_singleDrop(drop));
          continue;
        }
        double base = Maths.sum(subdrops.map((e) => e.num * e.dropCount / e.runs));
        double bonus = Maths.sum(subdrops.map((e) => e.dropCount / e.runs));
        children.add(drop.iconBuilder(
          width: _itemSize,
          context: context,
          text: '${base.format(maxDigits: 3)}\n+${bonus.format(maxDigits: 3)}b',
          option: ImageWithTextOption(textAlign: TextAlign.end, fontSize: _itemSize * 0.27, padding: EdgeInsets.zero),
        ));
      }
    }
    return Wrap(
      spacing: 3,
      runSpacing: 2,
      children: children,
    );
  }

  Widget? getWarBoard() {
    List<Widget> children = [];
    final warBoards = quest.war?.event?.warBoards ?? [];
    for (final warBoard in warBoards) {
      for (final stage in warBoard.stages) {
        if (quest.id == stage.questId && phase == stage.questPhase) {
          children.add(_header('${S.current.war_board} (COST ${stage.formationCost})'));
          if (stage.boardMessage.isNotEmpty) {
            children.add(Text(stage.boardMessage, style: Theme.of(context).textTheme.bodySmall));
          }
          final gifts = stage.squares.expand((e) => e.treasures).expand((e) => e.gifts);
          if (gifts.isNotEmpty) {
            children.add(Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: [
                for (final gift in gifts) gift.iconBuilder(context: context, width: _itemSize),
              ],
            ));
          }
          break;
        }
      }
    }
    if (children.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget? getPhaseScript(int phase) {
    final scripts = quest.phaseScripts.firstWhereOrNull((e) => e.phase == phase)?.scripts ?? [];
    if (scripts.isEmpty || widget.battleOnly) return null;
    return Padding(
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
    );
  }

  Widget? getPhasePresent(int phase) {
    final present = quest.phasePresents.firstWhereOrNull((e) => e.phase == phase);
    if (present == null) return null;
    if (present.giftIcon == null && present.gifts.isEmpty) return null;
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
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (present.giftIcon != null) db.getIconImage(present.giftIcon, width: 36),
                  ...Gift.listBuilder(context: context, gifts: present.gifts, size: 36),
                ],
              ),
            ),
          )
        ],
      ),
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
