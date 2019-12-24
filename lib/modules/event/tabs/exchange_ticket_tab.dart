import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

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
    return ListView(
      children: divideTiles(
        tickets.map((ticket) {
          final plan = db.curUser.exchangeTickets;
          plan[ticket.monthCn] ??= [0, 0, 0];
          List<Widget> trailing = [];
          for (var i = 0; i < 3; i++) {
            final iconKey = ticket.items[i];
            final maxValue =
                ticket.days - sum(plan[ticket.monthCn].getRange(0, i));
            trailing
              ..add(Image(image: db.getIconFile(iconKey), height: 48))
              ..add(buildDropDownMenu(
                  value: plan[ticket.monthCn][i],
                  maxValue: maxValue,
                  onChanged: (v) {
                    setState(() {
                      plan[ticket.monthCn][i] = v;
                      for (var j = 0; j < 3; j++) {
                        plan[ticket.monthCn][j] = min(
                            plan[ticket.monthCn][j],
                            ticket.days -
                                sum(plan[ticket.monthCn].getRange(0, j)));
                      }
                    });
                  }));
          }
          return CustomTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 8),
            title: Text(ticket.monthCn),
            subtitle: AutoSizeText('JP: ${ticket.monthJp}\nmax: ${ticket.days}',
                maxLines: 2),
            color: MyColors.setting_tile,
            trailing: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 48),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: trailing),
            ),
          );
        }),
        divider: Divider(height: 1, indent: 16),
      ).toList(),
    );
  }

  Widget buildCheckedItem(String iconKey, bool checked) {
    // not used, Item with check icon
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Image(image: db.getIconFile(iconKey), height: 48),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        DropdownButton<int>(
          isDense: true,
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
          onChanged: onChanged,
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.body1,
          child: Text('1230', maxLines: 1),
        )
      ],
    );
  }
}
