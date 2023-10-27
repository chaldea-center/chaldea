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
    Set<int> validQuests = {};
    for (final quest in war.quests) {
      if (!(quest.isAnyFree && quest.consumeType.useAp && quest.consume > 0)) {
        continue;
      }
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
        if (params.bonusPlans.every((e) => e.questId != quest.id)) {
          params.bonusPlans.add(QuestBonusPlan(questId: quest.id));
        }
        final _plans = params.bonusPlans.where((e) => e.questId == quest.id).toList();
        for (final plan in _plans) {
          plan.ap = quest.consume;
          plan.drops = drops;
          plan.bonus.removeWhere((key, value) => !eventDrops.items.containsKey(key));
        }
        validQuests.add(quest.id);
      }
    }
    params.bonusPlans = {for (final e in params.bonusPlans) '${e.questId}-${e.index}': e}.values.toList();
    params.bonusPlans.removeWhere((e) => !validQuests.contains(e.questId));
    params.bonusPlans.sort2((e) => -e.questId);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    final itemIds = eventItemIds.toList();
    itemIds.sort(Item.compare2);

    children.add(TileGroup(
      headerWidget: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16.0, top: 8.0, bottom: 4.0, end: 8.0),
        child: Row(children: [
          Text(S.current.item),
          const Spacer(),
          Text('${S.current.demands}  /  ${S.current.item_own}  '),
        ]),
      ),
      children: [
        if (itemIds.isEmpty) const ListTile(title: Text('No event item found')),
        for (final itemId in itemIds) _buildItemDemand(itemId),
      ],
    ));

    children.add(TileGroup(
      header: S.current.event_bonus,
      children: [
        if (params.bonusPlans.isEmpty) const ListTile(title: Text('No valid quest found')),
        for (final plan in params.bonusPlans) _buildQuestBonus(plan),
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
      subtitle: Text(((params.itemCounts[itemId] ?? 0) - (db.curUser.items[itemId] ?? 0)).toString()),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              InputCancelOkDialog(
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                title: '${S.current.demands}: ${Item.getName(itemId)}',
                text: params.itemCounts[itemId]?.toString(),
                validate: (s) => s.trim().isEmpty || int.tryParse(s) != null,
                onSubmit: (s) {
                  params.itemCounts[itemId] = int.tryParse(s) ?? 0;
                  if (mounted) setState(() {});
                },
              ).showDialog(context);
            },
            child: Text((params.itemCounts[itemId] ?? 0).toString()),
          ),
          TextButton(
            onPressed: () {
              InputCancelOkDialog(
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                title: '${S.current.item_own}: ${Item.getName(itemId)}',
                text: db.curUser.items[itemId]?.toString(),
                validate: (s) => s.trim().isEmpty || int.tryParse(s) != null,
                onSubmit: (s) {
                  db.curUser.items[itemId] = int.tryParse(s) ?? 0;
                  if (mounted) setState(() {});
                },
              ).showDialog(context);
            },
            child: Text((db.curUser.items[itemId] ?? 0).toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestBonus(QuestBonusPlan plan) {
    final quest = db.gameData.quests[plan.questId];
    final spotImage = quest?.spot?.shownImage;
    List<InlineSpan> spans = [];
    if (quest != null) {
      spans.add(TextSpan(text: 'Lv.${quest.recommendLv} ${quest.lSpot.l}\n'));
    }
    final bonusStyle = TextStyle(color: Theme.of(context).colorScheme.secondary);
    for (final itemId in plan.drops.items.keys) {
      if (!eventItemIds.contains(itemId)) continue;
      final base = plan.drops.getBase(itemId);
      final group = plan.drops.getGroup(itemId);
      final bonus = plan.bonus[itemId] ?? 0;
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
    String questName = Quest.getName(plan.questId);
    if (plan.index != 0) questName += ' @${plan.index}';
    return ListTile(
      dense: true,
      leading: spotImage == null ? null : db.getIconImage(spotImage, width: 32),
      title: Text(
        questName,
        style: plan.enabled ? null : TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).disabledColor),
      ),
      subtitle: Text.rich(TextSpan(children: spans)),
      isThreeLine: quest != null,
      trailing: const Icon(Icons.edit_note),
      horizontalTitleGap: 8,
      onTap: () async {
        await _QuestBonusEditDialog(
          plan: plan,
          onCopy: () {
            params.bonusPlans.add(plan
                .copy(Maths.max(params.bonusPlans.where((e) => e.questId == plan.questId).map((e) => e.index)) + 1));
            params.bonusPlans.sort2((e) => -e.questId);
            if (mounted) setState(() {});
          },
          onDelete: () {
            if (plan.index != 0) params.bonusPlans.remove(plan);
            if (mounted) setState(() {});
          },
        ).showDialog(context);
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
              onPressed: running
                  ? null
                  : () async {
                      setState(() {
                        running = false;
                      });
                      await solve();
                      running = false;
                      if (mounted) setState(() {});
                    },
              child: Text(S.current.drop_calc_solve),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> solve() async {
    setState(() {
      running = true;
    });
    EasyLoading.show();

    final itemIds = params.itemCounts.keys.where((key) => params.itemCounts[key]! > 0).toList();
    final plans = params.bonusPlans
        .where((plan) => plan.enabled && plan.drops.items.keys.any((itemId) => itemIds.contains(itemId)))
        .toList();
    if (itemIds.isEmpty || plans.isEmpty) {
      EasyLoading.showInfo(S.current.input_invalid_hint);
      running = false;
      return;
    }
    List<List<double>> matA = [];
    for (final itemId in itemIds) {
      final percent = _isPercentTypeBonus(itemId);
      List<double> row = [];
      for (final detail in plans) {
        final a = percent
            ? detail.drops.getBase(itemId) * (1 + detail.getBonus(itemId) / 100)
            : detail.drops.getBase(itemId) + detail.drops.getGroup(itemId) * detail.getBonus(itemId);
        row.add(a);
      }
      matA.add(row);
    }
    try {
      final lpParams = BasicLPParams(
        colNames: List.generate(plans.length, (index) => index),
        rowNames: itemIds.toList(),
        matA: matA,
        bVec: itemIds.map((e) => params.itemCounts[e]!).toList(),
        cVec: plans.map((e) => e.ap).toList(),
      );
      print([lpParams.rowNames, lpParams.bVec]);
      // key=index
      final result = await solver.callSolver(lpParams);
      final solution = LPSolution(destination: 1, originalItems: itemIds, totalNum: 0, totalCost: 0);
      // solution.params = params;
      for (final col in result.keys) {
        final countFloat = result[col]!;

        int count = countFloat.ceil();
        final plan = plans[col];
        solution.totalNum = solution.totalNum! + count;
        solution.totalCost = solution.totalCost! + count * plan.ap;
        Map<int, double> _drops = {};
        for (final itemId in plan.drops.items.keys) {
          int row = itemIds.indexOf(itemId);
          if (row < 0) continue;
          final a = matA[row][col];
          if (a > 0) {
            _drops[itemId] = a * count;
          }
        }
        solution.countVars.add(LPVariable<int>(
          name: plan.questId,
          displayName: plan.index == 0 ? null : '${Quest.getName(plan.questId)} @${plan.index}',
          value: count,
          cost: plan.ap,
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
    }
  }
}

class _QuestBonusEditDialog extends StatefulWidget {
  final QuestBonusPlan plan;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _QuestBonusEditDialog({required this.plan, required this.onCopy, required this.onDelete});

  @override
  State<_QuestBonusEditDialog> createState() => __QuestBonusEditDialogState();
}

class __QuestBonusEditDialogState extends State<_QuestBonusEditDialog> {
  QuestBonusPlan get plan => widget.plan;

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
            title: Text(Quest.getName(plan.questId)),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () => router.push(url: Routes.questI(plan.questId)),
          ),
          kDefaultDivider,
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: plan.enabled,
            title: Text(S.current.enable),
            onChanged: (v) {
              setState(() {
                plan.enabled = v;
              });
            },
          ),
          kDefaultDivider,
          for (final itemId in plan.drops.items.keys) buildItem(itemId),
        ],
      ),
      actions: [
        if (plan.index != 0)
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete();
              },
              child: Text(
                S.current.remove,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onCopy();
          },
          child: Text(S.current.copy),
        ),
      ],
    );
  }

  Widget buildItem(int itemId) {
    final base = plan.drops.getBase(itemId);
    final group = plan.drops.getGroup(itemId);
    final bonus = plan.bonus[itemId] ?? 0;
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
              if (v != null && v >= 0) plan.bonus[itemId] = v;
            });
          },
        ),
      ),
    );
  }
}
