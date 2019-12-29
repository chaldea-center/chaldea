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
  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now().subtract(Duration(days: 31 * 3));
    final tickets = db.gameData.events.exchangeTickets.values.toList()
      ..retainWhere((e) => DateTime.parse(e.monthCn + '01').isAfter(startDate));
    tickets.sort((a, b) {
      return (a.monthCn).compareTo(b.monthCn) * (widget.reverse ? -1 : 1);
    });
    ListTile();
    return ListView(
      children: divideTiles(
        tickets.map((ticket) {
          return CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 8),
            title: Text(ticket.monthCn),
            subtitle: AutoSizeText('JP: ${ticket.monthJp}\nmax: ${ticket.days}',
                maxLines: 2),
            trailing: buildTrailing(ticket),
            constraints: BoxConstraints.expand(height: 72),
            color: MyColors.setting_tile,
          );
        }),
        divider: Divider(height: 1, indent: 16),
      ).toList(),
    );
  }

  Widget buildTrailing(ExchangeTicket ticket) {
    final plan = db.curUser.events.exchangeTickets;
    plan[ticket.monthCn] ??= [0, 0, 0];
    List<Widget> trailing = [];

    for (var i = 0; i < 3; i++) {
      final iconKey = ticket.items[i];
      int leftNum = db.runtimeData.itemStatistics.leftItems[iconKey] ?? 0;
      final maxValue = ticket.days - sum(plan[ticket.monthCn].getRange(0, i));
      trailing.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => SplitRoute.popAndPush(context,
                builder: (context) => ItemDetailPage(iconKey)),
            child: Image(image: db.getIconImage(iconKey), height: 48),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              DropdownButton<int>(
                isDense: true,
                value: plan[ticket.monthCn][i],
                items: List.generate(maxValue + 1, (i) {
                  int v = i == 0 ? 0 : maxValue + 1 - i;
                  return DropdownMenuItem(
                    value: v,
                    child: SizedBox(
                      width: 25,
                      child: Text(
                        v == 0 ? '' : ' $v',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                }),
                onChanged: (v) {
                  setState(() {
                    plan[ticket.monthCn][i] = v;
                    for (var j = 0; j < 3; j++) {
                      plan[ticket.monthCn][j] = min(
                          plan[ticket.monthCn][j],
                          ticket.days -
                              sum(plan[ticket.monthCn].getRange(0, j)));
                    }
                    db.runtimeData.itemStatistics.updateEventItems();
                  });
                },
              ),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.body1,
                child: Text(
                  leftNum.toString(),
                  maxLines: 1,
                  style:
                      TextStyle(color: leftNum >= 0 ? null : Colors.redAccent),
                ),
              )
            ],
          )
        ],
      ));
    }
    return Wrap(
      children: trailing,
    );
  }
}
