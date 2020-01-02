import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';

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
      ..retainWhere((e) => DateTime.parse(e.monthCn + '01').isAfter(startDate));
    tickets.sort((a, b) {
      return (a.monthCn).compareTo(b.monthCn) * (widget.reverse ? -1 : 1);
    });

    return ListView(
      children: divideTiles(
        tickets.map((ticket) {
          TextStyle plannedStyle;
          if (sum(db.curUser.events.exchangeTickets[ticket.monthCn] ?? []) >
              0) {
            plannedStyle = TextStyle(color: Colors.blueAccent);
          }
          return ListTile(
            title: Text(ticket.monthCn, style: plannedStyle),
            subtitle: AutoSizeText(
              'JP: ${ticket.monthJp}\nmax: ${ticket.days}',
              maxLines: 2,
              style: plannedStyle,
              minFontSize: 6,
            ),
            trailing: buildTrailing(ticket),
          );
        }),
        divider: Divider(height: 1, indent: 16),
      ).toList(),
    );
  }

  Widget buildTrailing(ExchangeTicket ticket) {
    final monthPlan = db.curUser.events.exchangeTickets
        .putIfAbsent(ticket.monthCn, () => [0, 0, 0]);
    List<Widget> trailingItems = [];

    for (var i = 0; i < 3; i++) {
      final iconKey = ticket.items[i];
      int leftNum = db.runtimeData.itemStatistics.leftItems[iconKey] ?? 0;
      final maxValue = ticket.days - sum(monthPlan.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => SplitRoute.popAndPush(context,
                builder: (context) => ItemDetailPage(iconKey)),
            child: Image(
              image: db.getIconImage(iconKey),
              width: 42,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              DropdownButton<int>(
                isDense: true,
                icon: Text(
                  '▼ ',
                  style: TextStyle(color: Colors.black54, fontSize: 8),
                ),
                value: monthPlan[i],
                items: List.generate(maxValue + 1, (i) {
                  int v = i == 0 ? 0 : maxValue + 1 - i;
                  return DropdownMenuItem(
                    value: v,
                    child: Text(v == 0 ? '0' : ' $v'),
                  );
                }),
                selectedItemBuilder: (context) =>
                    List.generate(maxValue + 1, (i) {
                  int v = i == 0 ? 0 : maxValue + 1 - i;
                  return SizedBox(
                    width: 25,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: Center(
                        child: AutoSizeText(
                          '${v == 0 ? '' : v}',
                          maxLines: 1,
                          maxFontSize: 16,
                          minFontSize: 6,
                          group: _autoSizeGroup,
                        ),
                      ),
                    ),
                  );
                }),
                onChanged: (v) {
                  setState(() {
                    monthPlan[i] = v;
                    for (var j = 0; j < 3; j++) {
                      monthPlan[j] = min(monthPlan[j],
                          ticket.days - sum(monthPlan.getRange(0, j)));
                    }
                    db.runtimeData.itemStatistics.updateEventItems();
                  });
                },
              ),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.body1,
                child: AutoSizeText(
                  leftNum.toString(),
                  maxLines: 1,
                  group: _autoSizeGroup,
                  style: TextStyle(
                      color: leftNum >= 0 ? Colors.grey : Colors.redAccent),
                ),
              )
            ],
          )
        ],
      ));
    }
    return Wrap(spacing: 4, children: trailingItems);
  }
}
