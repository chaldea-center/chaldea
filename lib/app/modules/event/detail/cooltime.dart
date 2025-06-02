import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventCooltimePage extends HookWidget {
  final Event event;
  const EventCooltimePage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final allRewards = event.cooltime?.rewards ?? [];
    if (allRewards.isEmpty) return const SizedBox();
    final grouped = <int, List<EventCooltimeReward>>{};
    for (final reward in allRewards) {
      grouped.putIfAbsent(reward.spotId, () => []).add(reward);
    }
    for (final rewards in grouped.values) {
      rewards.sort2((e) => e.lv);
    }
    final keys = grouped.keys.toList();
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, grouped[keys[index]]!),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemCount: keys.length,
    );
  }

  Widget itemBuilder(BuildContext context, List<EventCooltimeReward> rewards) {
    final first = rewards.first;
    assert(
      rewards.every(
        (e) =>
            e.name == first.name &&
            e.upperLimitGiftNum == first.upperLimitGiftNum &&
            e.gifts.length == 1 &&
            e.gifts.first.objectId == first.gifts.first.objectId &&
            e.gifts.first.num == first.gifts.first.num,
      ),
    );
    final spot = db.gameData.spots[rewards.first.spotId];
    final maxPointRate = Maths.max(rewards.map((e) => e.addEventPointRate), 0);
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 8),
          horizontalTitleGap: 8,
          dense: true,
          leading: spot?.shownImage == null ? null : db.getIconImage(spot?.shownImage),
          title: Text(Transl.spotNames(first.name).l),
          subtitle: Text(
            '${_fmtCooltime(rewards.first.cooltime)}→${_fmtCooltime(rewards.last.cooltime)},'
            ' +${(maxPointRate / 1000).toStringAsFixed(1)}',
          ),
          trailing: Text.rich(
            TextSpan(
              children: [
                for (final gift in first.gifts) CenterWidgetSpan(child: gift.iconBuilder(context: context, width: 28)),
                TextSpan(text: '×${first.upperLimitGiftNum.format()}'),
              ],
            ),
            textScaler: const TextScaler.linear(0.9),
          ),
        );
      },
      contentBuilder: (context) {
        return CustomTable(
          children: [
            if (rewards.isNotEmpty)
              for (final cond in rewards.first.releaseConditions)
                CustomTableRow.fromChildren(children: [CondTargetValueDescriptor.commonRelease(commonRelease: cond)]),
            CustomTableRow.fromTexts(texts: const ['Lv.', 'Cooltime', 'Point Rate', 'Cost'], isHeader: true),
            for (final reward in rewards) buildRow(context, reward),
          ],
        );
      },
    );
  }

  Widget buildRow(BuildContext context, EventCooltimeReward reward) {
    Widget? itemCost;
    assert(reward.releaseConditions.length == 1, '${reward.name} Lv.${reward.lv}');
    final cond = reward.releaseConditions.firstOrNull;
    if (cond != null && cond.condType == CondType.questClear) {
      final quest = db.gameData.quests[cond.condId];
      if (quest != null && quest.consumeItem.isNotEmpty) {
        quest.consumeItem;
        itemCost = Wrap(
          children: [
            for (final itemAmount in quest.consumeItem)
              Item.iconBuilder(
                context: context,
                item: itemAmount.item,
                itemId: itemAmount.itemId,
                text: itemAmount.amount.format(),
                width: 28,
              ),
          ],
        );
      }
    }
    return CustomTableRow(
      children: [
        TableCellData(text: reward.lv.toString()),
        TableCellData(text: _fmtCooltime(reward.cooltime)),
        TableCellData(text: '+${(reward.addEventPointRate / 1000).toStringAsFixed(1)}'),
        TableCellData(child: itemCost ?? const SizedBox.shrink()),
      ],
    );
  }

  String _fmtCooltime(int sec) {
    return '${(sec / 3600).format()}h';
  }
}
