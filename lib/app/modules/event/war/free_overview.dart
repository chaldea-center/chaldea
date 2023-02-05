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
  const FreeQuestOverview({super.key, required this.quests});

  @override
  State<FreeQuestOverview> createState() => _FreeQuestOverviewState();
}

class _FreeQuestOverviewState extends State<FreeQuestOverview> {
  Map<int, QuestPhase> phases = {};
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
    await Future.wait(widget.quests.map((quest) async {
      if (quest.phases.isEmpty) return null;
      await Future.delayed(const Duration(milliseconds: 800));
      final phase = await AtlasApi.questPhase(quest.id, quest.phases.last);
      if (phase != null) phases[quest.id] = phase;
      if (mounted) setState(() {});
    }).toList());
    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              child: DataTable2(
                columns: [
                  DataColumn2(
                    label: Text(
                        '${S.current.quest} (${phases.length}/${widget.quests.length})'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(label: Text(S.current.svt_class), fixedWidth: 48),
                  const DataColumn2(
                      label: Text('Event Item'), size: ColumnSize.L),
                  const DataColumn2(
                      label: Text('Normal Items'), size: ColumnSize.L),
                ],
                rows: widget.quests.map((e) => buildRow(e)).toList(),
                fixedLeftColumns: 1,
                fixedTopRows: 1,
                minWidth: 800,
                columnSpacing: 8,
                headingRowHeight: 36,
                horizontalMargin: 8,
                smRatio: 0.5,
              ),
            ),
          ),
          kDefaultDivider,
          // settings(),
        ],
      ),
    );
  }
  // Widget settings(){
  //   return null;
  // }

  DataRow buildRow(Quest quest) {
    final phase = phases[quest.id];
    final header = DataCell(
      AutoSizeText(
        quest.lName.l,
        textScaleFactor: 0.9,
        maxLines: 2,
        minFontSize: 10,
      ),
      onTap: quest.routeTo,
    );
    if (phase == null) {
      return DataRow2(cells: [
        header,
        const DataCell(Text(''), placeholder: true),
        for (final _ in [0, 2])
          DataCell(
            _loading
                ? const CupertinoActivityIndicator(radius: 8)
                : const Text('NO DATA'),
            placeholder: true,
          ),
      ]);
    }
    Map<int, List<EnemyDrop>> allDrops = {};
    for (final drop in phase.drops) {
      allDrops.putIfAbsent(drop.objectId, () => []).add(drop);
    }
    final ids = allDrops.keys.toList();
    ids.sort2((e) => db.gameData.items[e]?.dropPriority ?? e, reversed: true);
    List<Widget> eventItems = [], normalItems = [];
    for (final objectId in ids) {
      final drops = allDrops[objectId]!;
      final ce = db.gameData.craftEssencesById[objectId];
      if (ce != null) {
        if (ce.flag != SvtFlag.svtEquipExp) {
          eventItems.add(ce.iconBuilder(context: context, width: 36));
        }
        continue;
      }
      final item = db.gameData.items[objectId];
      if (item != null) {
        switch (item.category) {
          case ItemCategory.normal:
            normalItems.add(Item.iconBuilder(
              context: context,
              item: item,
              width: 36,
              text: Maths.sum(drops.map((e) => e.num * e.dropCount / e.runs))
                  .format(percent: true, maxDigits: 3),
            ));
            break;
          case ItemCategory.event:
          case ItemCategory.other:
            double base =
                Maths.sum(drops.map((e) => e.num * e.dropCount / e.runs));
            double bonus = Maths.sum(drops.map((e) => e.dropCount / e.runs));
            eventItems.add(Item.iconBuilder(
              context: context,
              item: item,
              width: 36,
              text:
                  '${base.format(maxDigits: 3)}\n+${bonus.format(maxDigits: 3)}B',
              option: ImageWithTextOption(textAlign: TextAlign.end),
            ));
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
    Widget wrap(List<Widget> children) {
      if (children.isEmpty) return const SizedBox();
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Wrap(children: children),
      );
    }

    return DataRow2(cells: [
      header,
      DataCell(wrap(phase.className
          .take(2)
          .map((e) => db.getIconImage(e.icon(5), width: 26))
          .toList())),
      DataCell(wrap(eventItems)),
      DataCell(wrap(normalItems)),
    ]);
  }
}
