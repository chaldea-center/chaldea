import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/Picker.dart';

class ExchangeTicketTab extends StatefulWidget {
  /// If only show ONE month
  final String? month;
  final bool reverse;
  final bool showOutdated;

  const ExchangeTicketTab({
    Key? key,
    this.month,
    this.reverse = false,
    this.showOutdated = false,
  }) : super(key: key);

  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab> {
  final AutoSizeGroup _autoSizeGroup = AutoSizeGroup();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.month != null) {
      final ticket = db.gameData.events.exchangeTickets[widget.month];
      if (ticket == null) {
        return ListTile(title: Text('${widget.month} NOT FOUND'));
      }
      return db.streamBuilder((context) => buildOneMonth(ticket));
    }
    final tickets = db.gameData.events.exchangeTickets.values.toList();
    if (!widget.showOutdated) {
      tickets.removeWhere((ticket) {
        if (!ticket.isOutdated()) return false;
        final plan = db.curUser.events.exchangeTicketOf(ticket.month);
        if (plan.any((e) => e > 0)) return false;
        return true;
      });
    }
    tickets.sort((a, b) {
      return (a.month).compareTo(b.month) * (widget.reverse ? -1 : 1);
    });
    return db.streamBuilder(
      (context) => Scrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          shrinkWrap: widget.month != null,
          children: divideTiles(
            tickets.map((ticket) => buildOneMonth(ticket)),
            divider: Divider(height: 1, indent: 16),
          ).toList(),
        ),
      ),
    );
  }

  Widget buildOneMonth(ExchangeTicket ticket) {
    bool planned = sum(db.curUser.events.exchangeTicketOf(ticket.month)) > 0;
    bool outdated = ticket.isOutdated();
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
                color: planned
                    ? Colors.blueAccent
                    : outdated
                        ? Colors.grey
                        : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: AutoSizeText(
              '${ticket.monthJp}\nmax: ${ticket.days}',
              maxLines: 2,
              maxFontSize: 14,
              style: TextStyle(
                  color: planned
                      ? Colors.blueAccent[100]
                      : outdated
                          ? Colors.grey[400]
                          : null),
              minFontSize: 6,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: buildTrailing(ticket, db.itemStat),
          ),
        )
      ],
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
              builder: (context, _) => ItemDetailPage(itemKey: iconKey),
              // if month specified, it's a widget somewhere, don't pop detail
              // if month is null, it's a tab of events in master layout
              popDetail: widget.month == null,
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
                        .bodyText2!, //body1->bodyText2
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
                  itemExtent: 36,
                  height: min(200, MediaQuery.of(context).size.height - 220),
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
