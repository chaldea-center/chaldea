import 'dart:math';

import 'package:chaldea/components/components.dart';

class ExchangeTicketTab extends StatefulWidget {
  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {

  @override
  Widget build(BuildContext context) {
    final tickets=db.curPlan.exchangeTickets;
    List<Widget> children = [];
    db.gameData.events.exchangeTickets.forEach((monthCn, ticketInfo) {
      tickets[monthCn] ??= [0, 0, 0];
      children.add(CustomTile(
        title: Text('$monthCn'),
        subtitle: Text('max ${ticketInfo.days}\n'
            '${ticketInfo.monthJp}(JP)'),
        color: MyColors.setting_tile,
        trailing: Expanded(
            flex: 3,
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.end,
              children: List.generate(3, (i) {
                final iconKey = ticketInfo.items[i];
                final maxValue =
                    ticketInfo.days - sum(tickets[monthCn].getRange(0, i));
                return Wrap(
                  children: <Widget>[
                    Image.file(db.getIconFile(iconKey), height: 40),
                    buildDropDownMenu(
                        value: tickets[monthCn][i],
                        maxValue: maxValue,
                        onChanged: (v) {
                          setState(() {
                            tickets[monthCn][i] = v;
                            for (var j = 0; j < 3; j++) {
                              tickets[monthCn][j] = min(
                                  tickets[monthCn][j],
                                  ticketInfo.days -
                                      sum(tickets[monthCn].getRange(0, j)));
                            }
                          });
                        })
                  ],
                );
              }).toList(),
            )),
      ));
    });
    return ListView(
      children: children.reversed.toList(),
    );
  }

  Widget buildCheckedItem(String iconKey, bool checked) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Image.file(db.getIconFile(iconKey), height: 48),
        if (checked)
          Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: Icon(Icons.check_circle, color: Colors.blue),
          ),
      ],
    );
  }

  Widget buildDropDownMenu(
      {@required int value, @required int maxValue, void onChanged(int)}) {
    return DropdownButton<int>(
        value: value,
        items: List.generate(maxValue + 1, (i) {
          int v = i == 0 ? 0 : maxValue + 1 - i;
          return DropdownMenuItem(
            value: v,
            child: SizedBox(
              width: 20,
              child: Text(
                v == 0 ? '' : v.toString(),
                textAlign: TextAlign.right,
              ),
            ),
          );
        }),
        onChanged: onChanged);
  }
}
