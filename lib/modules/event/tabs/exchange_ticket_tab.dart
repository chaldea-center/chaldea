//@dart=2.9
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/Picker.dart';

class ExchangeTicketTab extends StatefulWidget {
  final bool reverse;
  final String month;

  const ExchangeTicketTab({Key key, this.reverse, this.month})
      : super(key: key);

  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {
  final AutoSizeGroup _autoSizeGroup = AutoSizeGroup();
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.month != null) {}
    // final startDate = DateTime.now().subtract(Duration(days: 31 * 4));
    final tickets = widget.month == null
        ? db.gameData.events.exchangeTickets.values.toList()
        : [db.gameData.events.exchangeTickets[widget.month]];
    // ..retainWhere((e) => DateTime.parse(e.month + '01').isAfter(startDate));
    tickets.sort((a, b) {
      return (a.month).compareTo(b.month) * (widget.reverse ? -1 : 1);
    });
    return StreamBuilder<ItemStatistics>(
      initialData: db.itemStat,
      stream: db.itemStat.onUpdated.stream,
      builder: (context, snapshot) => Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          shrinkWrap: widget.month != null,
          children: divideTiles(
            tickets.map((ticket) {
              bool planned =
                  sum(db.curUser.events.exchangeTicketOf(ticket.month)) > 0;
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 12),
                      title: AutoSizeText(
                        ticket.month,
                        maxLines: 1,
                        maxFontSize: 16,
                        style: TextStyle(
                            color: planned ? Colors.blueAccent : null,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: AutoSizeText(
                        '${ticket.monthJp}\nmax: ${ticket.days}',
                        maxLines: 2,
                        maxFontSize: 14,
                        style: TextStyle(
                            color: planned ? Colors.blueAccent[100] : null),
                        minFontSize: 6,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: buildTrailing(ticket, snapshot.data),
                    ),
                  )
                ],
              );
            }),
            divider: Divider(height: 1, indent: 16),
          ).toList(),
        ),
      ),
    );
  }

  Widget buildTrailing(ExchangeTicket ticket, ItemStatistics statistics) {
    final monthPlan = db.curUser.events.exchangeTicketOf(ticket.month);
    List<Widget> trailingItems = [];
    for (var i = 0; i < 3; i++) {
      final iconKey = ticket.items[i];
      int leftNum = statistics.leftItems[iconKey] ?? 0;
      final int maxValue = ticket.days - sum(monthPlan.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => SplitRoute.push(
              context: context,
              builder: (context, _) => ItemDetailPage(iconKey),
              popDetail: true,
            ),
            child: db.getIconImage(iconKey, width: 42),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2, //body1->bodyText2
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
                  title:
                      Text('${ticket.month} ${Item.localizedNameOf(iconKey)}'),
                  hideHeader: true,
                  cancelText: S.of(context).cancel,
                  confirmText: S.of(context).confirm,
                  adapter: NumberPickerAdapter(
                    data: [
                      NumberPickerColumn(
                        items: List.generate(
                            maxValue + 2, (i) => i == 0 ? 0 : maxValue + 1 - i),
                        initValue: monthPlan[i],
                      ),
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
                  itemExtent: 36,
                ).showDialog(context);
              },
            ),
          )
        ],
      ));
    }
    return FittedBox(
      child: Row(mainAxisSize: MainAxisSize.min, children: trailingItems),
    );
  }
}
