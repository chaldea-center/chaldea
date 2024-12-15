import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventTradePage extends HookWidget {
  final Event event;
  const EventTradePage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final trades = event.tradeGoods.toList();
    trades.sort2((e) => e.id);
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, trades[index]),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: trades.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventTradeGoods trade) {
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          horizontalTitleGap: 8,
          leading: trade.goodsIcon == null ? null : db.getIconImage(trade.goodsIcon, width: 32),
          title: Text(trade.lName, textScaler: const TextScaler.linear(0.9)),
          subtitle: Wrap(
            spacing: 2,
            runSpacing: 2,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('(${getTradeTime(trade.tradeTime, trade.maxTradeTime)})  '),
              for (final consume in trade.consumes) ...[
                Item.iconBuilder(
                  context: context,
                  item: db.gameData.items[consume.objectId],
                  width: 24,
                  icon: db.gameData.items[consume.objectId]?.icon,
                ),
                Text('${consume.num.format()} ', textScaler: const TextScaler.linear(0.9)),
              ],
            ],
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.start,
              children: [
                for (final gift in trade.gifts)
                  gift.iconBuilder(
                    context: context,
                    width: 32,
                    showOne: true,
                  ),
                if (trade.eventPointItem != null && trade.eventPointNum != 0)
                  Item.iconBuilder(
                    context: context,
                    item: trade.eventPointItem,
                    width: 32,
                    icon: trade.eventPointItem?.icon,
                    text: trade.eventPointNum.format(compact: false, groupSeparator: ','),
                  )
              ],
            ),
          ),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [
          if (trade.releaseConditions.isNotEmpty || trade.closedMessage.isNotEmpty)
            TileGroup(
              header: S.current.condition,
              children: [
                if (trade.closedMessage.isNotEmpty)
                  ListTile(
                    dense: true,
                    title: Text(
                      '(${trade.closedMessage})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                for (final release in trade.releaseConditions)
                  CondTargetValueDescriptor.commonRelease(
                    commonRelease: release,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
              ],
            ),
          if (trade.pickups.isNotEmpty)
            TileGroup(
              header: 'Pickups',
              children: [
                for (final pickup in trade.pickups)
                  ListTile(
                    dense: true,
                    title: Text([pickup.startedAt, pickup.endedAt]
                        .map((e) => e.sec2date().toStringShort(omitSec: true))
                        .join(' ~ ')),
                    subtitle: Text('Time ×${pickup.tradeTimeRate.format(percent: true, base: 10)}'
                        '  (${getTradeTime(trade.tradeTime, trade.maxTradeTime, pickup.tradeTimeRate)})'),
                  )
              ],
            )
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }

  String getTradeTime(int tradeTime, int maxTradeTime, [int timeRate = 1000]) {
    final duration = Duration(seconds: tradeTime * timeRate ~/ 1000);
    final hours = duration.inHours, minutes = duration.inMinutes % 60, seconds = duration.inSeconds % 60;
    String timeText = '${hours}h';
    if (minutes != 0 || seconds != 0) {
      timeText += '${minutes}m';
      if (seconds != 0) {
        timeText += '${seconds}s';
      }
    }
    timeText += '×${(maxTradeTime / tradeTime).format()}';
    return timeText;
  }
}
