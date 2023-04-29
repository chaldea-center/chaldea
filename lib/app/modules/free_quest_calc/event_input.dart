import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../tools/glpk_solver.dart';

bool _isPercentTypeBonus(int itemId) {
  return db.gameData.items[itemId]?.type == ItemType.eventPoint;
}

String _fmtNum(double value) {
  return value.format(minVal: 999, maxDigits: 3);
}

class EventItemInputTab extends StatefulWidget {
  final int warId;
  final Map<int, int>? objectiveCounts;
  final ValueChanged<LPSolution>? onSolved;

  EventItemInputTab({super.key, required this.warId, this.objectiveCounts, this.onSolved});

  @override
  _EventItemInputTabState createState() => _EventItemInputTabState();
}

class _EventItemInputTabState extends State<EventItemInputTab> {
  late final _scrollController = ScrollController();

  late EventItemCalcParams params;

  // category - itemKey
  final solver = BaseLPSolver();
  bool running = false;
  Set<int> eventItemIds = {};

  @override
  void initState() {
    super.initState();
    // update userdata at last
    solver.ensureEngine();
    getData();
  }

  @override
  void dispose() {
    solver.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void getData() {
    params = db.settings.eventItemCalc.putIfAbsent(widget.warId, () => EventItemCalcParams());
    if (widget.objectiveCounts != null) {
      // Only event shop pass objectiveCounts yet
      // don't clear event point data
      params.itemCounts.removeWhere((key, value) => !_isPercentTypeBonus(key));
      params.itemCounts.addAll(widget.objectiveCounts!);
    }
    eventItemIds.clear();
    final war = db.gameData.wars[widget.warId];
    if (war == null) return;
    for (final quest in war.quests) {
      if (quest.isAnyFree && quest.consumeType.useAp && quest.consume > 0) {
        final drops = db.gameData.dropData.freeDrops2[quest.id];
        if (drops == null) continue;
        final eventDrops = QuestDropData(runs: drops.runs, items: {}, groups: {});
        for (final itemId in drops.items.keys) {
          final item = db.gameData.items[itemId];
          if (item == null || item.category != ItemCategory.event) continue;
          eventItemIds.add(itemId);
          eventDrops.items[itemId] = drops.items[itemId]!;
          eventDrops.groups[itemId] = drops.groups[itemId] ?? drops.runs;
        }
        if (eventDrops.items.isNotEmpty) {
          sortDict(eventDrops.items, compare: (a, b) => b.value - a.value, inPlace: true);
          final detail = params.quests.putIfAbsent(quest.id, () => QuestBonusPlan());
          detail
            ..questId = quest.id
            ..ap = quest.consume
            ..drops = eventDrops;
          detail.bonus.removeWhere((key, value) => !eventDrops.items.containsKey(key));
        }
      }
    }
    sortDict(params.quests, compare: (a, b) => b.value.questId - a.value.questId, inPlace: true);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    final itemIds = eventItemIds.toList();
    itemIds.sort(Item.compare2);

    children.add(TileGroup(
      header: S.current.demands,
      children: [
        if (itemIds.isEmpty) const ListTile(title: Text('No event item found')),
        for (final itemId in itemIds) _buildItemDemand(itemId),
      ],
    ));

    children.add(TileGroup(
      header: S.current.event_bonus,
      children: [
        if (params.quests.isEmpty) const ListTile(title: Text('No valid quest found')),
        for (final detail in params.quests.values) _buildQuestBonus(detail),
      ],
    ));
    return Column(
      children: <Widget>[
        Expanded(child: ListView(children: children)),
        kDefaultDivider,
        SafeArea(child: _buildButtonBar()),
      ],
    );
  }

  Widget _buildItemDemand(int itemId) {
    return ListTile(
      dense: true,
      leading: Item.iconBuilder(context: context, item: null, itemId: itemId, width: 36),
      title: Text(Item.getName(itemId)),
      // subtitle: const Text('Bonus: +x, Target 10'),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text((params.itemCounts[itemId] ?? 0).toString()),
          const SizedBox(width: 8),
          const Icon(Icons.edit_note),
        ],
      ),
      onTap: () {
        InputCancelOkDialog(
          title: '${S.current.demands}: ${Item.getName(itemId)}',
          text: params.itemCounts[itemId]?.toString(),
          validate: (s) => s.trim().isEmpty || int.tryParse(s) != null,
          onSubmit: (s) {
            params.itemCounts[itemId] = int.tryParse(s) ?? 0;
            if (mounted) setState(() {});
          },
        ).showDialog(context);
      },
    );
  }

  Widget _buildQuestBonus(QuestBonusPlan detail) {
    final quest = db.gameData.quests[detail.questId];
    final spotImage = quest?.spot?.shownImage;
    List<InlineSpan> spans = [];
    if (quest != null) {
      spans.add(TextSpan(text: 'Lv.${quest.recommendLv} ${quest.lSpot.l}\n'));
    }
    final bonusStyle = TextStyle(color: Theme.of(context).colorScheme.secondary);
    for (final itemId in detail.drops.items.keys) {
      final base = detail.drops.getBase(itemId);
      final group = detail.drops.getGroup(itemId);
      final bonus = detail.bonus[itemId] ?? 0;
      final percent = _isPercentTypeBonus(itemId);
      spans.add(TextSpan(children: [
        CenterWidgetSpan(
          child: Opacity(
            opacity: 0.75,
            child: Item.iconBuilder(
              context: context,
              item: null,
              itemId: itemId,
              width: 18,
              jumpToDetail: false,
            ),
          ),
        ),
        percent
            ? TextSpan(
                text: '${_fmtNum(base)}×(1+',
                children: [
                  TextSpan(text: bonus.toString(), style: bonusStyle),
                  const TextSpan(text: '%)'),
                ],
              )
            : TextSpan(
                text: ' ${_fmtNum(base)}+${_fmtNum(group)}×',
                children: [TextSpan(text: bonus.toString(), style: bonusStyle)],
              ),
        const TextSpan(text: '  ')
      ]));
    }
    return ListTile(
      dense: true,
      leading: spotImage == null ? null : db.getIconImage(spotImage, width: 32),
      title: Text(
        quest?.lName.l ?? 'Quest ${detail.questId}',
        style: detail.enabled ? null : TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).disabledColor),
      ),
      subtitle: Text.rich(TextSpan(children: spans)),
      isThreeLine: quest != null,
      trailing: const Icon(Icons.edit_note),
      horizontalTitleGap: 8,
      onTap: () async {
        await _QuestBonusEditDialog(detail).showDialog(context);
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: <Widget>[
            FilledButton(
              onPressed: running ? null : solve,
              child: Text(S.current.drop_calc_solve),
            ),
          ],
        ),
      ],
    );
  }

  void solve() async {
    setState(() {
      running = true;
    });
    EasyLoading.show();

    final itemIds = params.itemCounts.keys.where((key) => params.itemCounts[key]! > 0).toList();
    final details = params.quests.values
        .where((detail) => detail.enabled && detail.drops.items.keys.any((itemId) => itemIds.contains(itemId)))
        .toList();
    if (itemIds.isEmpty || details.isEmpty) {
      EasyLoading.showInfo(S.current.input_invalid_hint);
      return;
    }
    List<List<double>> matA = [];
    for (final itemId in itemIds) {
      final percent = _isPercentTypeBonus(itemId);
      List<double> row = [];
      for (final detail in details) {
        final a = percent
            ? detail.drops.getBase(itemId) * (1 + detail.getBonus(itemId) / 100)
            : detail.drops.getBase(itemId) + detail.drops.getGroup(itemId) * detail.getBonus(itemId);
        row.add(a);
      }
      matA.add(row);
    }
    try {
      final lpParams = BasicLPParams(
        colNames: details.map((e) => e.questId).toList(),
        rowNames: itemIds.toList(),
        matA: matA,
        bVec: itemIds.map((e) => params.itemCounts[e]!).toList(),
        cVec: details.map((e) => e.ap).toList(),
      );
      print([lpParams.rowNames, lpParams.bVec]);
      final result = await solver.callSolver(lpParams);
      final solution = LPSolution(destination: 1, originalItems: itemIds, totalNum: 0, totalCost: 0);
      // solution.params = params;
      for (final questId in result.keys) {
        final countFloat = result[questId]!;

        int count = countFloat.ceil();
        final detail = params.quests[questId]!;
        int col = details.indexOf(detail);
        assert(col >= 0);
        solution.totalNum = solution.totalNum! + count;
        solution.totalCost = solution.totalCost! + count * detail.ap;
        Map<int, double> _drops = {};
        for (final itemId in detail.drops.items.keys) {
          int row = itemIds.indexOf(itemId);
          if (row < 0) continue;
          final a = matA[row][col];
          if (a > 0) {
            _drops[itemId] = a * count;
          }
        }
        solution.countVars.add(LPVariable<int>(
          name: questId,
          value: count,
          cost: detail.ap,
          detail: _drops,
        ));
      }
      solution.sortCountVars();
      EasyLoading.dismiss();
      if (widget.onSolved != null) {
        widget.onSolved!(solution);
      }
    } catch (e, s) {
      logger.e('solve event item failed', e, s);
      EasyLoading.showError(e.toString());
    } finally {
      running = false;
      if (mounted) setState(() {});
    }
  }
}

class _QuestBonusEditDialog extends StatefulWidget {
  final QuestBonusPlan detail;
  const _QuestBonusEditDialog(this.detail);

  @override
  State<_QuestBonusEditDialog> createState() => __QuestBonusEditDialogState();
}

class __QuestBonusEditDialogState extends State<_QuestBonusEditDialog> {
  QuestBonusPlan get detail => widget.detail;

  @override
  Widget build(BuildContext context) {
    return SimpleCancelOkDialog(
      hideCancel: true,
      scrollable: true,
      title: Text(
        S.current.event_bonus,
        // textScaleFactor: 0.8,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(Quest.getName(detail.questId)),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () => router.push(url: Routes.questI(detail.questId)),
          ),
          kDefaultDivider,
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: detail.enabled,
            title: Text(S.current.enable),
            onChanged: (v) {
              setState(() {
                detail.enabled = v;
              });
            },
          ),
          kDefaultDivider,
          for (final itemId in detail.drops.items.keys) buildItem(itemId),
        ],
      ),
    );
  }

  Widget buildItem(int itemId) {
    final base = detail.drops.getBase(itemId);
    final group = detail.drops.getGroup(itemId);
    final bonus = detail.bonus[itemId] ?? 0;
    final percent = _isPercentTypeBonus(itemId);

    return ListTile(
      dense: true,
      leading: Item.iconBuilder(
        context: context,
        item: null,
        itemId: itemId,
        // width: 24,
      ),
      title: Text(Item.getName(itemId), maxLines: 1),
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 0,
      subtitle: Text(percent ? '${_fmtNum(base)}×(1+$bonus%)' : '${_fmtNum(base)}+${_fmtNum(group)}×$bonus'),
      trailing: SizedBox(
        width: 50,
        child: TextFormField(
          initialValue: bonus.toString(),
          decoration: InputDecoration(
            suffixText: percent ? '%' : null,
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (s) {
            s = s.trim();
            int? v = s.isEmpty ? 0 : int.tryParse(s);
            setState(() {
              if (v != null && v >= 0) detail.bonus[itemId] = v;
            });
          },
        ),
      ),
    );
  }
}
