import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/builders.dart';

enum _QuestLv {
  all,
  lv90,
  lv90plus,
  ;

  String get shownName => switch (this) {
        all => S.current.general_all,
        lv90 => "Lv.90",
        lv90plus => "Lv.90+",
      };
}

class FreeQuestOverview extends StatefulWidget {
  final List<Quest> quests;
  final bool isMainStory;

  const FreeQuestOverview({super.key, required this.quests, required this.isMainStory});

  @override
  State<FreeQuestOverview> createState() => _FreeQuestOverviewState();
}

class _FreeQuestOverviewState extends State<FreeQuestOverview> {
  late List<Quest> quests = widget.quests.toList();
  Map<int, QuestPhase> phases = {};
  Map<int, List<Quest>> spots = {};
  bool _loading = false;
  bool _fixFirstCol = false;
  _QuestLv minLv = _QuestLv.all;
  List<_QuestLv> validLvs = [_QuestLv.all];
  bool hasDifferentEnemyCount = false;
  bool useMaxEnemyCountHash = false;

  @override
  void initState() {
    super.initState();
    if (widget.quests.where((q) => (q.recommendLvInt ?? 999) > 90).length > 3) {
      minLv = _QuestLv.lv90plus;
    } else if (widget.quests.where((q) => (q.recommendLvInt ?? 999) >= 90).length > 5) {
      minLv = _QuestLv.lv90;
    }
    loadData();
  }

  Future<void> loadData() async {
    _loading = true;
    final prevPhases = Map.of(phases);
    phases.clear();
    spots.clear();
    quests = widget.quests.toList();

    for (final quest in quests) {
      spots.putIfAbsent(quest.spotId, () => []).add(quest);
    }

    bool has90 = quests.any((q) => q.recommendLv == '90');
    bool has90plus = quests.any((q) => q.is90PlusFree);
    validLvs = [
      _QuestLv.all,
      if (has90) _QuestLv.lv90,
      if (has90plus) _QuestLv.lv90plus,
    ];
    if (!validLvs.contains(minLv)) minLv = validLvs.first;

    if (minLv == _QuestLv.lv90) {
      quests.removeWhere((quest) => (quest.recommendLvInt ?? 999) < 90);
    } else if (minLv == _QuestLv.lv90plus) {
      quests.removeWhere((quest) => (quest.recommendLvInt ?? 999) <= 90);
    }

    if (mounted) setState(() {});
    await Future.wait(quests.reversed.map((quest) async {
      if (quest.phases.isEmpty) return null;
      final prevPhase = prevPhases[quest.id];
      String? enemyHash;
      if (useMaxEnemyCountHash && prevPhase != null && prevPhase.enemyHashes.length > 1) {
        enemyHash = prevPhase.enemyHashes.last;
      }
      final phase = await AtlasApi.questPhase(quest.id, quest.phases.last, hash: enemyHash);
      if (phase != null) phases[quest.id] = phase;
      if (mounted) setState(() {});
    }).toList());
    hasDifferentEnemyCount =
        phases.values.any((phase) => phase.enemyHashes.map((e) => int.parse(e.substring(2, 4))).toSet().length > 1);
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = getInfo();
    int maxCount = Maths.max(
        data.map((info) => Maths.max([info.domusItems.length, info.eventItems.length, info.normalItems.length])), 0);
    maxCount = maxCount.clamp(3, 8);
    final hasEventItem = data.any((e) => e.phase == null || e.eventItems.isNotEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.free_quest),
        actions: [
          if (hasDifferentEnemyCount)
            IconButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        useMaxEnemyCountHash = !useMaxEnemyCountHash;
                      });
                      loadData();
                    },
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  db.getIconImage(AssetURL.i.buffIcon(1014), width: 24, height: 24),
                  Icon(useMaxEnemyCountHash ? Icons.check : Icons.clear,
                      color: Theme.of(context).colorScheme.error, size: 24),
                ],
              ),
            ),
          if (validLvs.length > 1)
            SharedBuilder.appBarDropdown<_QuestLv>(
              context: context,
              items: [
                for (final lv in validLvs)
                  DropdownMenuItem(
                    value: lv,
                    child: Text(lv.shownName),
                  ),
              ],
              value: minLv,
              onChanged: (v) {
                setState(() {
                  minLv = v ?? minLv;
                });
                loadData();
              },
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _fixFirstCol = !_fixFirstCol;
              });
            },
            icon: const Icon(Icons.view_column),
            tooltip: 'Fixed 1st Column',
          )
        ],
      ),
      body: Column(
        children: [
          // ListTile(
          //   dense: true,
          //   title: Text(S.current.switch_region),
          //   subtitle: Text('${phases.length}/${widget.quests.length}'),
          // ),
          Flexible(
            fit: FlexFit.tight,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: SafeArea(
                child: DataTable2(
                  columns: [
                    DataColumn2(
                      label: Text('${S.current.quest} (${phases.length}/${widget.quests.length})'),
                      fixedWidth: 150,
                    ),
                    const DataColumn2(label: Text('Lv/AP', textScaler: TextScaler.linear(0.9)), fixedWidth: 56),
                    DataColumn2(label: Text(S.current.svt_class), fixedWidth: 90),
                    if (widget.isMainStory) ...[
                      DataColumn2(
                          label: Text(S.current.quest_runs("").trim(), textScaler: const TextScaler.linear(0.9)),
                          fixedWidth: 48),
                      DataColumn2(label: Text(S.current.fgo_domus_aurea), size: ColumnSize.L),
                      DataColumn2(
                          label: Text(S.current.quest_runs("").trim(), textScaler: const TextScaler.linear(0.9)),
                          fixedWidth: 48),
                      const DataColumn2(label: Text("Rayshift"), size: ColumnSize.L),
                    ] else ...[
                      DataColumn2(
                          label: Text(S.current.quest_runs("").trim(), textScaler: const TextScaler.linear(0.9)),
                          fixedWidth: 48),
                      if (hasEventItem) DataColumn2(label: Text(S.current.item), size: ColumnSize.L),
                      DataColumn2(label: Text(S.current.item), size: ColumnSize.L),
                    ],
                  ],
                  rows: data.map((info) => buildRow(info, maxCount, hasEventItem)).toList(),
                  fixedLeftColumns: _fixFirstCol ? 1 : 0,
                  fixedTopRows: 1,
                  minWidth: (maxCount * 2 * iconWidth) * 1.1 + 180 + 90 + 48 + 48 + 48,
                  columnSpacing: 8,
                  headingRowHeight: 36,
                  horizontalMargin: 8,
                  smRatio: 0.5,
                ),
              ),
            ),
          ),
          kDefaultDivider,
          // settings(),
        ],
      ),
    );
  }

  DataRow buildRow(_DropInfo info, int countPerLine, bool hasEventItem) {
    List<DataCell> cells = [];
    final quest = info.quest, phase = info.phase;
    final effQuest = phase ?? quest;
    String name;
    if (spots.length > 1) {
      name = quest.lSpot.l;
      if ((spots[quest.spotId]?.length ?? 0) > 1) {
        name += ' (${quest.lName.l})';
      }
    } else {
      name = quest.lName.l;
    }

    final highlightStyle = TextStyle(color: quest.is90PlusFree ? Theme.of(context).colorScheme.primaryContainer : null);

    cells.add(DataCell(
      AutoSizeText(
        name,
        textScaleFactor: 0.9,
        maxLines: 2,
        minFontSize: 10,
        style: highlightStyle,
      ),
      onTap: quest.routeTo,
    ));

    cells.add(DataCell(AutoSizeText(
      [
        'Lv.${(effQuest).recommendLv}',
        if (effQuest.consumeType.useApOrBp) '${effQuest.consume}${effQuest.consumeType.unit}',
      ].join('\n'),
      maxLines: 2,
      minFontSize: 10,
      style: Theme.of(context).textTheme.bodySmall?.merge(highlightStyle),
    )));

    Widget wrap(Iterable<Widget> children) {
      if (children.isEmpty) return const SizedBox.shrink();
      return Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: children.toList());
    }

    DataCell clsIcons;
    List<int> clsIconIds = phase?.className.map((e) => e.value).toList() ??
        db.gameData.questPhaseDetails[quest.id * 100 + (quest.phases.lastOrNull ?? 0)]?.classIds ??
        [];

    clsIcons = DataCell(Text.rich(TextSpan(children: [
      for (final clsId in clsIconIds)
        CenterWidgetSpan(child: db.getIconImage(SvtClassX.clsIcon(clsId, 5), width: 24, aspectRatio: 1)),
      const TextSpan(text: '\n'),
      phase == null && _loading
          ? const CenterWidgetSpan(child: CupertinoActivityIndicator(radius: 6))
          : TextSpan(
              text: phase?.stages.map((e) => e.enemies.length).join('-') ?? '-',
              style: Theme.of(context).textTheme.bodySmall,
            ),
    ])));

    cells.add(clsIcons);

    void _addItems(Map<int, Widget> items) {
      final ids = items.keys.toList();
      ids.sort((a, b) => Item.compare2(a, b));
      cells.add(DataCell(wrap(ids.map((e) => items[e]!))));
    }

    void _addRuns(int runs) {
      cells.add(DataCell(Center(
        child: AutoSizeText(
          runs > 0 ? runs.toString() : '-',
          maxLines: 1,
          minFontSize: 10,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      )));
    }

    int lines;
    if (widget.isMainStory) {
      _addRuns(info.domusRuns);
      _addItems(info.domusItems);
      _addRuns(info.rayshiftRuns);
      _addItems(info.normalItems);
      lines = (max(info.domusItems.length, info.normalItems.length) / countPerLine).ceil();
    } else {
      _addRuns(info.rayshiftRuns);
      if (hasEventItem) _addItems(info.eventItems);
      _addItems(info.normalItems);
      lines = (max(info.eventItems.length, info.normalItems.length) / countPerLine).ceil();
    }

    if (lines < 1) lines = 1;
    return DataRow2(
      cells: cells,
      specificRowHeight: 48.0 * lines,
    );
  }

  final iconWidth = 36.0;

  List<_DropInfo> getInfo() {
    List<_DropInfo> data = [];
    final quests = this.quests.toList();
    quests.sort2((e) => -e.priority);
    quests.sortByList((e) => [kLB7SpotLayers[e.spotId] ?? 0, -e.priority]);
    for (final quest in quests) {
      final info = _DropInfo(quest);
      data.add(info);
      // domus
      final drops = db.gameData.dropData.domusAurea.getQuestDropRate(quest.id);
      // drops.removeWhere((id, value) => db.gameData.items[id]?.category != ItemCategory.normal);
      info.domusRuns = db.gameData.dropData.domusAurea.getQuestRuns(quest.id);
      for (final id in drops.keys) {
        if (quest.warId != WarId.ordealCall && db.gameData.items[id]?.category != ItemCategory.normal) continue;
        info.domusItems[id] = Item.iconBuilder(
          context: context,
          item: null,
          itemId: id,
          width: iconWidth,
          text: drops[id]!.format(percent: true, maxDigits: 3),
        );
      }

      // rayshift
      final phase = info.phase = phases[quest.id];
      if (phase == null) continue;
      Map<int, List<EnemyDrop>> allDrops = {};
      for (final drop in phase.drops) {
        allDrops.putIfAbsent(drop.objectId, () => []).add(drop);
      }

      for (final id in allDrops.keys) {
        final drops = allDrops[id]!;
        double base = Maths.sum(drops.map((e) => e.num * e.dropCount / e.runs));
        double bonus = Maths.sum(drops.map((e) => e.dropCount / e.runs));
        final ce = db.gameData.craftEssencesById[id];
        if (ce != null) {
          if (!ce.flags.contains(SvtFlag.svtEquipExp)) {
            info.eventItems[id] = ce.iconBuilder(
              context: context,
              width: iconWidth,
              text: base.format(percent: true, maxDigits: 3),
            );
          }
          continue;
        }

        final item = db.gameData.items[id];
        if (item == null) continue;
        switch (item.category) {
          case ItemCategory.normal:
            info.normalItems[id] = Item.iconBuilder(
              context: context,
              item: item,
              width: iconWidth,
              text: base.format(percent: true, maxDigits: 3),
            );
            break;
          case ItemCategory.event:
          case ItemCategory.other:
            info.eventItems[id] = Item.iconBuilder(
              context: context,
              item: item,
              width: iconWidth,
              text: '${base.format(maxDigits: 3)}\n+${bonus.format(maxDigits: 3)}b',
              option: ImageWithTextOption(textAlign: TextAlign.end),
            );
            break;
          case ItemCategory.special:
          case ItemCategory.ascension:
          case ItemCategory.skill:
          case ItemCategory.eventAscension:
          case ItemCategory.coin:
            if (id == Items.qpId) {
              if (base > 10000) {
                info.normalItems[id] = Item.iconBuilder(
                  context: context,
                  item: item,
                  width: iconWidth,
                  text: base.format(),
                );
              }
            } else if (quest.warId == WarId.ordealCall) {
              info.normalItems[id] = Item.iconBuilder(
                context: context,
                item: item,
                width: iconWidth,
                text: base.format(percent: true, maxDigits: 3),
              );
            }
            break;
        }
      }
    }
    return data;
  }
}

class _DropInfo {
  final Quest quest;
  QuestPhase? phase;
  int domusRuns = 0;
  Map<int, Widget> domusItems = {};
  Map<int, Widget> eventItems = {};
  Map<int, Widget> normalItems = {};
  _DropInfo(this.quest);

  int get rayshiftRuns => phase?.drops.firstOrNull?.runs ?? 0;
}
