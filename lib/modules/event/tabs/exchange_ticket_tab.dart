import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/item/item_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/Picker.dart';

class ExchangeTicketTab extends StatefulWidget {
  /// If only show ONE month
  final String? monthJp;
  final bool reverse;
  final bool showOutdated;

  const ExchangeTicketTab({
    Key? key,
    this.monthJp,
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
    if (widget.monthJp != null) {
      final ticket = db.gameData.events.exchangeTickets[widget.monthJp];
      if (ticket == null) {
        return ListTile(title: Text('${widget.monthJp} NOT FOUND'));
      }
      return db.streamBuilder((context) => buildOneMonth(ticket));
    }
    final tickets = db.gameData.events.exchangeTickets.values.toList();
    if (!widget.showOutdated) {
      tickets.removeWhere((ticket) {
        if (!ticket.isOutdated()) return false;
        final plan = db.curUser.events.exchangeTicketOf(ticket.monthJp);
        if (plan.enabled) return false;
        return true;
      });
    }
    tickets.sort(
        (a, b) => a.dateJp.compareTo(b.dateJp) * (widget.reverse ? -1 : 1));
    return db.streamBuilder(
      (context) => ListView(
        controller: _scrollController,
        shrinkWrap: widget.monthJp != null,
        children: divideTiles(
          [
            hintText,
            for (var ticket in tickets) buildOneMonth(ticket),
          ],
          divider: Divider(height: 1, indent: 16),
        ).toList(),
      ),
    );
  }

  Widget get hintText {
    String curServer = db.curUser.server.localized;
    return Card(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Text(
            LocalizedText.of(
                chs: '月份采用$curServer\n在设置中可更改所在服务器',
                jpn: '現在のサーバー：$curServer\n[設定]で変更できます ',
                eng: 'Current Server: $curServer\nchange it in Settings'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }

  Widget buildOneMonth(ExchangeTicket ticket) {
    bool planned = db.curUser.events.exchangeTicketOf(ticket.monthJp).enabled;
    bool outdated = ticket.isOutdated();
    Color? _plannedColor = Theme.of(context).colorScheme.secondary;
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 12),
            title: AutoSizeText(
              ticket.dateToStr(),
              maxLines: 1,
              maxFontSize: 16,
              style: TextStyle(
                color: planned
                    ? _plannedColor
                    : outdated
                        ? _outdatedColor
                        : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: AutoSizeText(
              db.curUser.server == GameServer.jp
                  ? 'max: ${ticket.days}'
                  : 'JP ${ticket.monthJp}\nmax: ${ticket.days}',
              maxLines: 2,
              maxFontSize: 12,
              style: TextStyle(
                  color: planned
                      ? _plannedColor.withAlpha(200)
                      : outdated
                          ? _outdatedColor?.withAlpha(200)
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
    final monthPlan = db.curUser.events.exchangeTicketOf(ticket.monthJp);
    List<Widget> trailingItems = [];
    for (var i = 0; i < 3; i++) {
      final iconKey = ticket.items[i];
      int leftNum = statistics.leftItems[iconKey] ?? 0;
      monthPlan.setAt(i, fixValidRange(monthPlan.items[i], 0, ticket.days));
      final int maxValue = ticket.days - sum(monthPlan.items.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () => SplitRoute.push(
              context,
              ItemDetailPage(itemKey: iconKey),
              // if month specified, it's a widget somewhere, don't pop detail
              // if month is null, it's a tab of events in master layout
              popDetail: widget.monthJp == null,
            ),
            child: db.getIconImage(iconKey, width: 42),
          ),
          SizedBox(
            width: 36,
            child: MaterialButton(
              padding: EdgeInsets.symmetric(),
              child: Column(
                children: <Widget>[
                  Text(monthPlan.items[i] == 0
                      ? ''
                      : monthPlan.items[i].toString()),
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
                  title: Text(
                      '${ticket.dateToStr()} ${Item.localizedNameOf(iconKey)}'),
                  itemExtent: 36,
                  height: min(200, MediaQuery.of(context).size.height - 220),
                  hideHeader: true,
                  cancelText: S.of(context).cancel,
                  confirmText: S.of(context).confirm,
                  backgroundColor: null,
                  textStyle: Theme.of(context).textTheme.headline6,
                  adapter: NumberPickerAdapter(
                    data: [
                      NumberPickerColumn(
                        items: List.generate(
                            maxValue + 2, (i) => i == 0 ? 0 : maxValue + 1 - i),
                        initValue: monthPlan.items[i],
                      ),
                    ],
                  ),
                  onConfirm: (picker, values) {
                    monthPlan.items[i] = picker.getSelectedValues()[0];
                    for (var j = 0; j < 3; j++) {
                      final int v = min(monthPlan.items[j],
                          ticket.days - sum(monthPlan.items.getRange(0, j)));
                      monthPlan.setAt(j, v);
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
