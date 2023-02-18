import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FreeQuestOverview extends StatefulWidget {
  final List<Quest> quests;
  final bool isMainStory;
  const FreeQuestOverview(
      {super.key, required this.quests, required this.isMainStory});

  @override
  State<FreeQuestOverview> createState() => _FreeQuestOverviewState();
}

class _FreeQuestOverviewState extends State<FreeQuestOverview> {
  Map<int, QuestPhase> phases = {};
  Map<int, List<Quest>> spots = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    _loading = true;
    phases.clear();
    if (mounted) setState(() {});
    for (final quest in widget.quests) {
      spots.putIfAbsent(quest.spotId, () => []).add(quest);
    }
    await Future.wait(widget.quests.map((quest) async {
      if (quest.phases.isEmpty) return null;
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
    int maxCount = Maths.max(data.map((info) => Maths.max([
          info.domusItems.length,
          info.eventItems.length,
          info.normalItems.length
        ])));
    maxCount = maxCount.clamp(3, 8);
    return Scaffold(
      appBar: AppBar(title: Text(S.current.free_quest)),
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
                      label: Text(
                          '${S.current.quest} (${phases.length}/${widget.quests.length})'),
                      fixedWidth: 150,
                    ),
                    const DataColumn2(
                        label: Text('Lv/AP', textScaleFactor: 0.9),
                        fixedWidth: 48),
                    DataColumn2(
                        label: Text(S.current.svt_class), fixedWidth: 64),
                    DataColumn2(
                        label: Text(widget.isMainStory
                            ? S.current.fgo_domus_aurea
                            : S.current.item),
                        size: ColumnSize.L),
                    DataColumn2(
                        label: Text(
                            widget.isMainStory ? 'Rayshift' : S.current.item),
                        size: ColumnSize.L),
                  ],
                  rows: data.map((info) => buildRow(info, maxCount)).toList(),
                  fixedLeftColumns: 1,
                  fixedTopRows: 1,
                  minWidth: (maxCount * 2 * iconWidth) * 1.1 + 180 + 64 + 48,
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

    cells.add(DataCell(
      AutoSizeText(
        name,
        textScaleFactor: 0.9,
        maxLines: 2,
        minFontSize: 10,
      ),
      onTap: quest.routeTo,
    ));

    cells.add(DataCell(AutoSizeText(
      [
        'Lv.${(phase ?? quest).recommendLv}',
        if ((phase ?? quest).consumeType == ConsumeType.ap)
          '${(phase ?? quest).consume}AP'
      ].join('\n'),
      maxLines: 2,
      minFontSize: 10,
      style: Theme.of(context).textTheme.bodySmall,
    )));

    Widget wrap(Iterable<Widget> children) {
      if (children.isEmpty) return const SizedBox.shrink();
      return Wrap(children: children.toList());
    }

    DataCell clsIcons;
    if (phase == null) {
      clsIcons = DataCell(
        _loading
            ? const CupertinoActivityIndicator(radius: 8)
            : const Text(' - '),
        placeholder: true,
      );
    } else {
      clsIcons = DataCell(wrap(phase.className
          .take(2)
          .map((e) => db.getIconImage(e.icon(5), width: 26, aspectRatio: 1))));
    }
    cells.add(clsIcons);

    void _addItems(Map<int, Widget> items) {
      final ids = items.keys.toList();
      ids.sort((a, b) => Item.compare2(a, b, true));
      cells.add(DataCell(wrap(ids.map((e) => items[e]!))));
    }

    final items1 = widget.isMainStory ? info.domusItems : info.eventItems;
    final items2 = info.normalItems;
    _addItems(items1);
    _addItems(items2);
    int lines = (max(items1.length, items2.length) / countPerLine).ceil();
    if (lines < 1) lines = 1;
    return DataRow2(
      cells: cells,
      specificRowHeight: 48.0 * lines,
    );
  }

  final iconWidth = 36.0;

  List<_DropInfo> getInfo() {
    List<_DropInfo> data = [];
    final quests = widget.quests.toList();
    quests.sort2((e) => -e.priority);
    quests.sortByList((e) => [kLB7SpotLayers[e.spotId] ?? 0, -e.priority]);
    for (final quest in quests) {
      final info = _DropInfo(quest);
      data.add(info);
      // domus
      final drops =
          db.gameData.dropRate.getSheet(true).getQuestDropRate(quest.id);
      drops.removeWhere((id, value) =>
          db.gameData.items[id]?.category != ItemCategory.normal);
      for (final id in drops.keys) {
        if (db.gameData.items[id]?.category != ItemCategory.normal) continue;
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
              text:
                  '${base.format(maxDigits: 3)}\n+${bonus.format(maxDigits: 3)}B',
              option: ImageWithTextOption(textAlign: TextAlign.end),
            );
            break;
          case ItemCategory.special:
          case ItemCategory.ascension:
          case ItemCategory.skill:
          case ItemCategory.eventAscension:
          case ItemCategory.coin:
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
  Map<int, Widget> domusItems = {};
  Map<int, Widget> eventItems = {};
  Map<int, Widget> normalItems = {};
  _DropInfo(this.quest);
}
