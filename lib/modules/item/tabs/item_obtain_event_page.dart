import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class ItemObtainEventPage extends StatelessWidget {
  final String itemKey;

  const ItemObtainEventPage({Key key, this.itemKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final highlight = TextStyle(color: Colors.blueAccent);
    children.add(SHeader(S.of(context).exchange_ticket));
    db.gameData.events.exchangeTickets.values.forEach((ticket) {
      int itemIndex = ticket.items.indexOf(itemKey);
      if (itemIndex >= 0 && ticket.isNotOutdated()) {
        int itemNum = db.curUser.events.exchangeTickets[ticket.month]
            ?.elementAt(itemIndex);
        children.add(ListTile(
          title: Text(S.of(context).exchange_ticket_short +
              ' ' +
              ticket.month.toString()),
          subtitle: Text(ticket.items.join('/')),
          trailing: Text('${itemNum ?? 0}/${ticket.days}'),
        ));
      }
    });
    children.add(SHeader(S.of(context).main_record));
    db.gameData.events.mainRecords.values.toList()
      ..sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp))
      ..forEach((record) {
        final plan = db.curUser.events.mainRecords[record.name];
        if (record.isNotOutdated()) {
          List<TextSpan> texts = [];
          bool hasDrop = record.drops.containsKey(itemKey),
              hasReward = record.rewardsWithRare.containsKey(itemKey);
          if (hasDrop) {
            texts.add(TextSpan(
                text: S.of(context).main_record_fixed_drop_short +
                    ' ' +
                    record.drops[itemKey].toString(),
                style: plan?.elementAt(0) == true ? highlight : null));
          }
          if (hasDrop && hasReward) {
            texts.add(TextSpan(text: ' / '));
          }
          if (hasReward) {
            texts.add(TextSpan(
                text: S.of(context).main_record_bonus_short +
                    ' ' +
                    record.rewardsWithRare[itemKey].toString(),
                style: plan?.elementAt(1) == true ? highlight : null));
          }
          if (texts.length > 0) {
            children.add(ListTile(
              title: Text(record.localizedChapter),
              subtitle: Text(record.localizedTitle),
              trailing: RichText(
                text: TextSpan(
                  children: texts,
                  style: DefaultTextStyle.of(context).style,
                ),
              ),
            ));
          }
        }
      });
    children.add(SHeader(S.of(context).limited_event));
    db.gameData.events.limitEvents.values.toList()
      ..sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp))
      ..forEach((limitEvent) {
        final plan = db.curUser.events.limitEvents[limitEvent.name];
        final int numShop = limitEvent.itemsWithRare(plan)[itemKey],
            numLottery = (limitEvent.lottery ?? {})[itemKey];
        final bool hasExtra = limitEvent.extra?.containsKey(itemKey) == true;
        if ((numShop != null || numLottery != null || hasExtra) &&
            limitEvent.isNotOutdated()) {
          children.add(ListTile(
            title: AutoSizeText(limitEvent.localizedName, maxFontSize: 15, maxLines: 2),
            trailing: Text(
              [
                if (numShop != null) '$numShop',
                if (numLottery != null)
                  '${S.current.event_lottery_unlimited} $numLottery*${plan?.lottery ?? 0}',
                if (hasExtra)
                  '${S.current.event_item_extra} ${(plan?.extra ?? {})[itemKey] ?? 0}',
              ].join('\n'),
              style: plan?.enable == true ? highlight : null,
              textAlign: TextAlign.right,
            ),
          ));
        }
      });
    return ListView(children: divideTiles(children));
  }
}
