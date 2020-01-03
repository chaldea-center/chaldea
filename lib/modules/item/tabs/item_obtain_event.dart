import 'package:chaldea/components/components.dart';

class ItemObtainEventPage extends StatelessWidget {
  final String itemKey;

  const ItemObtainEventPage({Key key, this.itemKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    final highlight = TextStyle(color: Colors.blueAccent);
    children.add(SHeader('素材交换券'));
    db.gameData.events
      ..exchangeTickets.values.forEach((ticket) {
        int itemIndex = ticket.items.indexOf(itemKey);
        if (itemIndex >= 0 && ticket.isNotOutdated()) {
          int itemNum = db.curUser.events.exchangeTickets[ticket.monthCn]
              ?.elementAt(itemIndex);
          children.add(ListTile(
            title: Text('交换券${ticket.monthCn}'),
            subtitle: Text(ticket.items.join('/')),
            trailing: Text('${itemNum ?? 0}/${ticket.days}'),
          ));
        }
      });
    children.add(SHeader('主线掉落与通关奖励'));
    db.gameData.events.mainRecords.values.toList()
      ..sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp))
      ..forEach((record) {
        final plan = db.curUser.events.mainRecords[record.chapter];
        if (record.isNotOutdated()) {
          List<TextSpan> texts = [];
          bool hasDrop = record.drops.containsKey(itemKey),
              hasReward = record.rewards.containsKey(itemKey);
          if (hasDrop) {
            texts.add(TextSpan(
                text: '掉落${record.drops[itemKey]}',
                style: plan?.elementAt(0) == true ? highlight : null));
          }
          if (hasDrop && hasReward) {
            texts.add(TextSpan(text: ' / '));
          }
          if (hasReward) {
            texts.add(TextSpan(
                text: '奖励${record.rewards[itemKey]}',
                style: plan?.elementAt(1) == true ? highlight : null));
          }
          if (texts.length > 0) {
            children.add(ListTile(
              title: Text(record.chapter),
              subtitle: Text(record.title),
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
    children.add(SHeader('限时活动'));
    db.gameData.events.limitEvents.values.toList()
      ..sort((a, b) => a.startTimeJp.compareTo(b.startTimeJp))
      ..forEach((limitEvent) {
        final plan = db.curUser.events.limitEvents[limitEvent.name];
        final int numShop = (limitEvent.items ?? {})[itemKey],
            numLottery = (limitEvent.lottery ?? {})[itemKey];
        final bool hasExtra = limitEvent.extra?.containsKey(itemKey) == true;
        if ((numShop != null || numLottery != null || hasExtra) &&
            limitEvent.isNotOutdated()) {
          children.add(ListTile(
            title: Text(limitEvent.name),
            trailing: Text(
              [
                if (numShop != null) '商店 $numShop',
                if (numLottery != null) '无限池 $numLottery*${plan?.lottery ?? 0}',
                if (hasExtra) 'Extra 1*${(plan?.extra ?? {})[itemKey] ?? 0}',
              ].join(' / '),
              style: plan?.enable == true ? highlight : null,
            ),
          ));
        }
      });
    return ListView(children: divideTiles(children));
  }
}
