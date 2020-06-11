import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/Picker.dart';

class ExchangeTicketTab extends StatefulWidget {
  final bool reverse;

  const ExchangeTicketTab({Key key, this.reverse}) : super(key: key);

  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {
  final AutoSizeGroup _autoSizeGroup = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now().subtract(Duration(days: 31 * 4));
    final tickets = db.gameData.events.exchangeTickets.values.toList()
      ..retainWhere((e) => DateTime.parse(e.month + '01').isAfter(startDate));
    tickets.sort((a, b) {
      return (a.month).compareTo(b.month) * (widget.reverse ? -1 : 1);
    });

    return ListView(
      children: divideTiles(
        tickets.map((ticket) {
          TextStyle plannedStyle;
          if (sum(db.curUser.events.exchangeTickets[ticket.month] ?? []) >
              0) {
            plannedStyle = TextStyle(color: Colors.blueAccent);
          }
          return ListTile(
            title: Text(ticket.month, style: plannedStyle),
            subtitle: AutoSizeText(
              'JP: ${ticket.monthJp}\nmax: ${ticket.days}',
              maxLines: 2,
              style: plannedStyle,
              minFontSize: 6,
            ),
            trailing: StreamBuilder<ItemStatistics>(
                initialData: db.itemStat,
                stream: db.itemStat.onUpdated.stream,
                builder: (context, snapshot) =>
                    buildTrailing(ticket, snapshot.data)),
          );
        }),
        divider: Divider(height: 1, indent: 16),
      ).toList(),
    );
  }

  Widget buildTrailing(ExchangeTicket ticket, ItemStatistics statistics) {
    final monthPlan = db.curUser.events.exchangeTickets
        .putIfAbsent(ticket.month, () => [0, 0, 0]);
    List<Widget> trailingItems = [];
    for (var i = 0; i < 3; i++) {
      final iconKey = ticket.items[i];
      int leftNum = statistics.leftItems[iconKey] ?? 0;
      final maxValue = ticket.days - sum(monthPlan.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => SplitRoute.popAndPush(context,
                builder: (context) => ItemDetailPage(iconKey)),
            child: Image(image: db.getIconImage(iconKey), width: 42),
          ),
          SizedBox(
            width: 36,
            child: MaterialButton(
              padding: EdgeInsets.symmetric(),
              child: Column(
                children: <Widget>[
                  Text(monthPlan[i] == 0 ? '' : monthPlan[i].toString()),
                  Divider(height: 1),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyText2,//body1->bodyText2
                    child: AutoSizeText(
                      leftNum.toString(),
                      maxLines: 1,
                      group: _autoSizeGroup,
                      style: TextStyle(
                          color: leftNum >= 0 ? Colors.grey : Colors.redAccent),
                    ),
                  )
                ],
              ),
              onPressed: () {
                Picker(
                  adapter: NumberPickerAdapter(
                    data: [
                      NumberPickerColumn(
                          items: List.generate(maxValue + 2,
                              (i) => i == 0 ? 0 : maxValue + 1 - i),
                          initValue: monthPlan[i]),
                    ],
                  ),
                  onConfirm: (picker, values) {
                    monthPlan[i] = picker.getSelectedValues()[0];
                    for (var j = 0; j < 3; j++) {
                      monthPlan[j] = min(monthPlan[j],
                          ticket.days - sum(monthPlan.getRange(0, j)));
                    }
                    statistics.updateEventItems();
                  },
                  height: 250,
                  itemExtent: 36,
                ).showModal(context);
              },
            ),
          )
        ],
      ));
    }
    return Wrap(spacing: 4, children: trailingItems);
  }
}
