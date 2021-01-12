import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExchangeTicketTab extends StatefulWidget {
  final bool reverse;

  const ExchangeTicketTab({Key key, this.reverse}) : super(key: key);

  @override
  _ExchangeTicketTabState createState() => _ExchangeTicketTabState();
}

class _ExchangeTicketTabState extends State<ExchangeTicketTab>
    with DefaultScrollBarMixin {
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
    final startDate = DateTime.now().subtract(Duration(days: 31 * 4));
    final tickets = db.gameData.events.exchangeTickets.values.toList()
      ..retainWhere((e) => DateTime.parse(e.month + '01').isAfter(startDate));
    tickets.sort((a, b) {
      return (a.month).compareTo(b.month) * (widget.reverse ? -1 : 1);
    });
    return StreamBuilder<ItemStatistics>(
      initialData: db.itemStat,
      stream: db.itemStat.onUpdated.stream,
      builder: (context, snapshot) => wrapDefaultScrollBar(
        controller: _scrollController,
        child: ListView(
          children: divideTiles(
            tickets.map((ticket) {
              TextStyle plannedStyle = sum(
                          db.curUser.events.exchangeTickets[ticket.month] ??
                              <int>[]) >
                      0
                  ? TextStyle(color: Colors.blueAccent)
                  : TextStyle();
              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      flex: 1,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 12),
                        title: AutoSizeText(ticket.month,
                            maxLines: 1,
                            maxFontSize: 16,
                            style: plannedStyle.copyWith(
                                fontWeight: FontWeight.w600)),
                        subtitle: AutoSizeText(
                          '${ticket.monthJp}\nmax: ${ticket.days}',
                          maxLines: 2,
                          maxFontSize: 14,
                          style: plannedStyle.copyWith(
                              fontStyle: FontStyle.italic),
                          minFontSize: 6,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildTrailing(ticket, snapshot.data),
                      ))
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
    final monthPlan = db.curUser.events.exchangeTickets
        .putIfAbsent(ticket.month, () => [0, 0, 0]);
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
//                  height: 400,
                  itemExtent: 36,
                ).showModal(context);
              },
            ),
          )
        ],
      ));
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: Row(mainAxisSize: MainAxisSize.min, children: trailingItems),
    );
  }

  Widget buildAll(List<ExchangeTicket> tickets, ItemStatistics statistics) {
    return StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: tickets.length * 4,
        itemBuilder: (context, index) {
          final ticket = tickets[index ~/ 4];
          final monthPlan = db.curUser.events.exchangeTickets
              .putIfAbsent(ticket.month, () => [0, 0, 0]);

          TextStyle plannedStyle;
          if (sum(db.curUser.events.exchangeTickets[ticket.month] ?? <int>[]) >
              0) {
            plannedStyle = TextStyle(color: Colors.blueAccent);
          } else {
            plannedStyle = TextStyle();
          }

          if (index % 4 == 0) {
            // month text
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(ticket.month,
                        maxLines: 1,
                        maxFontSize: 16,
                        style:
                            plannedStyle.copyWith(fontWeight: FontWeight.bold)),
                    AutoSizeText(
                      '${ticket.monthJp}\nmax: ${ticket.days}',
                      maxLines: 2,
                      maxFontSize: 14,
                      style: plannedStyle.copyWith(fontStyle: FontStyle.italic),
                      minFontSize: 6,
                    )
                  ],
                ),
              ),
            );
          } else {
            // 3 items
            int itemIndex = index % 4 - 1;
            final iconKey = ticket.items[itemIndex];
            int leftNum = statistics.leftItems[iconKey] ?? 0;
            final maxValue =
                ticket.days - sum(monthPlan.getRange(0, itemIndex));
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => SplitRoute.push(
                      context: context,
                      builder: (context, _) => ItemDetailPage(iconKey),
                      popDetail: true,
                    ),
                    child: Image(image: db.getIconImage(iconKey), width: 42),
                  ),
                  SizedBox(
                    width: 36,
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(monthPlan[itemIndex] == 0
                              ? ''
                              : monthPlan[itemIndex].toString()),
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
                                  color: leftNum >= 0
                                      ? Colors.grey
                                      : Colors.redAccent),
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
                                  initValue: monthPlan[itemIndex]),
                            ],
                          ),
                          onConfirm: (picker, values) {
                            monthPlan[itemIndex] =
                                picker.getSelectedValues()[0];
                            for (var j = 0; j < 3; j++) {
                              monthPlan[j] = min(monthPlan[j],
                                  ticket.days - sum(monthPlan.getRange(0, j)));
                            }
                            statistics.updateEventItems();
                          },
                          height: 400,
                          itemExtent: 36,
                        ).showModal(context);
                      },
                    ),
                  )
                ],
              ),
            );
          }
        },
        staggeredTileBuilder: (index) => StaggeredTile.count(1, 0.8));
  }
}
