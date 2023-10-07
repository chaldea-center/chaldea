import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/api/cache.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FreeQuestOverview extends StatefulWidget {
  final List<Quest> quests;
  final bool isMainStory;
  final bool show90plusButton;
  const FreeQuestOverview({super.key, required this.quests, required this.isMainStory, required this.show90plusButton});

  @override
  State<FreeQuestOverview> createState() => _FreeQuestOverviewState();
}

class _FreeQuestOverviewState extends State<FreeQuestOverview> {
  late List<Quest> quests = widget.quests.toList();
  Map<int, QuestPhase> phases = {};
  Map<int, List<Quest>> spots = {};
  bool _loading = false;
  bool _fixFirstCol = false;
  late bool _only90plus = widget.show90plusButton;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    _loading = true;
    phases.clear();
    spots.clear();
    quests = widget.quests.toList();
    if (_only90plus) {
      quests.retainWhere((quest) => quest.recommendLv.startsWith('90'));
      if (quests.any((quest) => quest.recommendLv.startsWith('90+'))) {
        quests.retainWhere((quest) => quest.recommendLv.startsWith('90+'));
      }
    }
    if (mounted) setState(() {});
    for (final quest in quests) {
      spots.putIfAbsent(quest.spotId, () => []).add(quest);
    }
    await Future.wait(quests.reversed.map((quest) async {
      if (quest.phases.isEmpty) return null;
      if (quest.warId > 1000) {
        final phaseOld = await AtlasApi.questPhase(quest.id, quest.phases.last, expireAfter: kExpireCacheOnly);
        if (phaseOld != null) phases[quest.id] = phaseOld;
        if (mounted) setState(() {});
      }
      final phase = await AtlasApi.questPhase(quest.id, quest.phases.last);
      if (phase != null) phases[quest.id] = phase;
      if (mounted) setState(() {});
    }).toList());
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = getInfo();
    int maxCount = Maths.max(
        data.map((info) => Maths.max([info.domusItems.length, info.eventItems.length, info.normalItems.length])));
    maxCount = maxCount.clamp(3, 8);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.free_quest),
        actions: [
          if (widget.show90plusButton)
            IconButton(
              onPressed: () {
                setState(() {
                  _only90plus = !_only90plus;
                });
                loadData();
                EasyLoading.showToast('Only 90+: ${_only90plus ? 'On' : 'Off'}');
              },
              icon: const Icon(Icons.filter_9_plus),
              isSelected: _only90plus,
              tooltip: 'Only show 90+',
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
                    const DataColumn2(label: Text('Lv/AP', textScaleFactor: 0.9), fixedWidth: 56),
                    DataColumn2(label: Text(S.current.svt_class), fixedWidth: 64),
                    if (widget.isMainStory) ...[
                      DataColumn2(label: Text(S.current.quest_runs("").trim(), textScaleFactor: 0.9), fixedWidth: 48),
                      DataColumn2(label: Text(S.current.fgo_domus_aurea), size: ColumnSize.L),
                      DataColumn2(label: Text(S.current.quest_runs("").trim(), textScaleFactor: 0.9), fixedWidth: 48),
                      const DataColumn2(label: Text("Rayshift"), size: ColumnSize.L),
                    ] else ...[
                      DataColumn2(label: Text(S.current.quest_runs("").trim(), textScaleFactor: 0.9), fixedWidth: 48),
                      DataColumn2(label: Text(S.current.item), size: ColumnSize.L),
                      DataColumn2(label: Text(S.current.item), size: ColumnSize.L),
                    ],
                  ],
                  rows: data.map((info) => buildRow(info, maxCount)).toList(),
                  fixedLeftColumns: _fixFirstCol ? 1 : 0,
                  fixedTopRows: 1,
                  minWidth: (maxCount * 2 * iconWidth) * 1.1 + 180 + 64 + 48 + 48 + 48,
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

  DataRow buildRow(_DropInfo info, int countPerLine) {
    List<DataCell> cells = [];
    final quest = info.quest, phase = info.phase;
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
        'Lv.${(phase ?? quest).recommendLv}',
        if ((phase ?? quest).consumeType.useAp) '${(phase ?? quest).consume}AP',
      ].join('\n'),
      maxLines: 2,
      minFontSize: 10,
      style: Theme.of(context).textTheme.bodySmall?.merge(highlightStyle),
    )));

    Widget wrap(Iterable<Widget> children) {
      if (children.isEmpty) return const SizedBox.shrink();
      return Wrap(children: children.toList());
    }

    DataCell clsIcons;
    if (phase == null) {
      clsIcons = DataCell(
        _loading ? const CupertinoActivityIndicator(radius: 8) : const Text(' - '),
        placeholder: true,
      );
    } else {
      clsIcons =
          DataCell(wrap(phase.className.take(2).map((e) => db.getIconImage(e.icon(5), width: 26, aspectRatio: 1))));
    }
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
      _addItems(info.eventItems);
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
          if (ce.flag != SvtFlag.svtEquipExp) {
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
            if (quest.warId == WarId.ordealCall && id != Items.qpId) {
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
