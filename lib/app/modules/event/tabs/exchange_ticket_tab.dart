import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

class ExchangeTicketTab extends StatefulWidget {
  /// If only show ONE month
  final int? id;
  final bool reversed;
  final bool showOutdated;

  const ExchangeTicketTab({
    Key? key,
    this.id,
    this.reversed = false,
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
    if (widget.id != null) {
      final ticket = db2.gameData.exchangeTickets[widget.id];
      if (ticket == null) {
        return ListTile(title: Text('${widget.id} NOT FOUND'));
      }
      return db2.onUserData((context, _) => buildOneMonth(ticket));
    }
    final tickets = db2.gameData.exchangeTickets.values.toList();

    return db2.onUserData((context, _) {
      if (!widget.showOutdated) {
        tickets.removeWhere((ticket) {
          if (!ticket.isOutdated()) return false;
          final plan = db2.curUser.ticketOf(ticket.id);
          if (plan.enabled) return false;
          return true;
        });
      }
      tickets.sort2((e) => e.id, reversed: widget.reversed);
      return ListView(
        controller: _scrollController,
        children: [
          hintText,
          for (var ticket in tickets) buildOneMonth(ticket),
        ],
      );
    });
  }

  Widget get hintText {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            '${S.current.game_server}: ${db2.curUser.region.toUpper()}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }

  Widget buildOneMonth(ExchangeTicket ticket) {
    bool planned = db2.curUser.ticketOf(ticket.id).enabled;
    bool outdated = ticket.isOutdated();
    Color? _plannedColor = Theme.of(context).colorScheme.secondary;
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: 12),
            title: AutoSizeText(
              ticket.dateStr,
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
              db2.curUser.region == Region.jp
                  ? 'max: ${ticket.days}'
                  : 'JP ${ticket.year}-${ticket.month}\nmax: ${ticket.days}',
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
            child: buildTrailing(ticket),
          ),
        )
      ],
    );
  }

  Widget buildTrailing(ExchangeTicket ticket) {
    final monthPlan = db2.curUser.ticketOf(ticket.id);
    List<Widget> trailingItems = [];
    for (int i = 0; i < 3; i++) {
      final itemId = ticket.items[i];
      final item = db2.gameData.items[itemId];
      int leftNum = db2.itemCenter.itemLeft[itemId] ?? 0;
      monthPlan.counts[i] = monthPlan.counts[i].clamp2(0, ticket.days);
      final int maxValue =
          ticket.days - Maths.sum(monthPlan.counts.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              router.push(url: Routes.itemI(itemId), detail: true);
            },
            child: db2.getIconImage(Item.getIcon(itemId), width: 42),
          ),
          SizedBox(
            width: 36,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(),
              child: Column(
                children: <Widget>[
                  Text(monthPlan.counts[i] == 0
                      ? ''
                      : monthPlan.counts[i].toString()),
                  const Divider(height: 1),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyText2!,
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
                  title: Text('${ticket.dateStr} ${item?.lName.l}'),
                  itemExtent: 36,
                  height: min(250, MediaQuery.of(context).size.height - 220),
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
                        initValue: monthPlan.counts[i],
                      ),
                    ],
                  ),
                  onConfirm: (picker, values) {
                    monthPlan.counts[i] = picker.getSelectedValues()[0];
                    for (var j = 0; j < 3; j++) {
                      final int v = min(
                          monthPlan.counts[j],
                          ticket.days -
                              Maths.sum(monthPlan.counts.getRange(0, j)));
                      monthPlan.counts[j] = v;
                    }
                    db2.itemCenter.updateExchangeTickets();
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
