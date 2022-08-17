import 'dart:math';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_picker/Picker.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

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
  late final _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id != null) {
      final ticket = db.gameData.exchangeTickets[widget.id];
      if (ticket == null) {
        return ListTile(title: Text('${widget.id} NOT FOUND'));
      }
      return db.onUserData((context, _) => buildOneMonth(ticket));
    }
    final tickets = db.gameData.exchangeTickets.values.toList();

    return db.onUserData((context, _) {
      if (!widget.showOutdated) {
        tickets.removeWhere((ticket) {
          if (!ticket.isOutdated()) return false;
          final plan = db.curUser.ticketOf(ticket.id);
          if (plan.enabled) return false;
          return true;
        });
      }
      tickets.sort2((e) => e.id, reversed: widget.reversed);
      return ListView.builder(
        controller: _scrollController,
        itemCount: tickets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return hintText;
          return buildOneMonth(tickets[index - 1]);
        },
      );
    });
  }

  Widget get hintText {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            '${S.current.game_server}: ${db.curUser.region.localName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }

  Widget buildOneMonth(ExchangeTicket ticket) {
    bool planned = db.curUser.ticketOf(ticket.id).enabled;
    bool outdated = ticket.isOutdated();
    Color? _plannedColor = Theme.of(context).colorScheme.secondary;
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    bool hasReplaced = ticket.replaced.ofRegion(db.curUser.region) != null;
    bool hasAnyReplaced = ticket.replaced.values.any((e) => e != null);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 2,
          child: ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: 12),
            title: Text.rich(
              TextSpan(text: ticket.dateStr, children: [
                if (hasReplaced)
                  const CenterWidgetSpan(
                      child: Icon(Icons.help_outline, size: 18))
              ]),
              style: TextStyle(
                color: planned
                    ? _plannedColor
                    : outdated
                        ? _outdatedColor
                        : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text.rich(
              TextSpan(
                  text: db.curUser.region == Region.jp
                      ? 'max: ${ticket.days}'
                      : 'JP ${ticket.year}-${ticket.month}\nmax: ${ticket.days}',
                  children: [
                    if (ticket.multiplier != 1)
                      TextSpan(
                        text: ' ×${ticket.multiplier}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ]),
              style: TextStyle(
                color: outdated ? _outdatedColor?.withAlpha(200) : null,
                fontSize: 12,
              ),
            ),
            onTap: hasAnyReplaced ? () => _showReplaceDetail(ticket) : null,
          ),
        ),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: buildTrailing(ticket),
          ),
        )
      ],
    );
  }

  Widget buildTrailing(ExchangeTicket ticket) {
    final monthPlan = db.curUser.ticketOf(ticket.id);
    List<Widget> trailingItems = [];
    for (int i = 0; i < 3; i++) {
      final itemId = ticket.of(db.curUser.region)[i];
      final item = db.gameData.items[itemId];
      int leftNum = db.itemCenter.itemLeft[itemId] ?? 0;
      monthPlan.counts[i] = monthPlan.counts[i].clamp2(0, ticket.days);
      final int maxValue =
          ticket.days - Maths.sum(monthPlan.counts.getRange(0, i));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Item.iconBuilder(
            context: context,
            item: item,
            itemId: itemId,
            width: 42,
            text: (db.curUser.items[itemId] ?? 0).format(),
            textPadding: const EdgeInsets.only(top: 36),
            popDetail: true,
          ),
          SizedBox(
            width: 36,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(),
              child: Column(
                children: <Widget>[
                  Text(monthPlan.counts[i] == 0
                      ? ''
                      : (monthPlan.counts[i] * ticket.multiplier).toString()),
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
                        onFormatValue: (v) {
                          return ticket.multiplier == 1
                              ? v.toString()
                              : '$v×${ticket.multiplier}';
                        },
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
                    db.itemCenter.updateExchangeTickets();
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

  void _showReplaceDetail(ExchangeTicket ticket) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        List<Widget> children = [];
        for (final region in Region.values) {
          final items = region == Region.jp
              ? ticket.items
              : ticket.replaced.ofRegion(region);
          if (items == null) continue;
          children.add(ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
            title: Text(region.localName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final itemId in items)
                  Item.iconBuilder(
                      context: context, item: null, itemId: itemId),
              ],
            ),
          ));
        }
        return SimpleDialog(
          title: Text.rich(TextSpan(
            text: ticket.dateStr,
            children: [
              TextSpan(
                text: '\nJP ${ticket.year}-${ticket.month}',
                style: Theme.of(context).textTheme.caption,
              )
            ],
          )),
          children: children,
        );
      },
    );
  }
}
