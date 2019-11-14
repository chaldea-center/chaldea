import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class ExchangeTicketTab extends StatefulWidget {
  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {
  @override
  Widget build(BuildContext context) {
    final tickets = db.curPlan.exchangeTickets;
    List<Widget> children = [];
    db.gameData.events.exchangeTickets.forEach((monthCn, ticketInfo) {
      tickets[monthCn] ??= [0, 0, 0];
      List<Widget> trailing = [];
      for (var i = 0; i < 3; i++) {
        final iconKey = ticketInfo.items[i];
        final maxValue = ticketInfo.days - sum(tickets[monthCn].getRange(0, i));
        trailing
          ..add(Image.file(db.getIconFile(iconKey), height: 48))
          ..add(buildDropDownMenu(
              value: tickets[monthCn][i],
              maxValue: maxValue,
              onChanged: (v) {
                setState(() {
                  tickets[monthCn][i] = v;
                  for (var j = 0; j < 3; j++) {
                    tickets[monthCn][j] = min(tickets[monthCn][j],
                        ticketInfo.days - sum(tickets[monthCn].getRange(0, j)));
                  }
                });
              }));
      }
      children.add(CustomTile(
        contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 8),
        title: Text('$monthCn'),
        subtitle: AutoSizeText(
          'max ${ticketInfo.days}\n${ticketInfo.monthJp}(JP)',
          maxLines: 2,
        ),
        color: MyColors.setting_tile,
        trailing: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 40),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: trailing),
        ),
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
