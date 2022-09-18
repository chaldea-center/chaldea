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
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 2, 8, 2),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: buildTitle(ticket),
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: buildItems(ticket),
            ),
          ),
        )
      ],
    );
  }

  Widget buildTitle(ExchangeTicket ticket) {
    bool planned = db.curUser.ticketOf(ticket.id).enabled;
    bool outdated = ticket.isOutdated();
    Color? _plannedColor = Theme.of(context).colorScheme.secondary;
    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    bool hasReplaced = ticket.replaced.ofRegion(db.curUser.region) != null;
    bool hasAnyReplaced = ticket.replaced.values.any((e) => e != null);

    return InkWell(
      onTap: hasAnyReplaced ? () => _showReplaceDetail(ticket) : null,
      child: Text.rich(TextSpan(children: [
        TextSpan(
          text: ticket.dateStr,
          children: [
            if (hasReplaced)
              const CenterWidgetSpan(child: Icon(Icons.help_outline, size: 18))
          ],
          style: TextStyle(
            color: planned
                ? _plannedColor
                : outdated
                    ? _outdatedColor
                    : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TextSpan(text: '\n'),
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
            ],
            style: TextStyle(
              color: outdated
                  ? _outdatedColor?.withAlpha(200)
                  : Theme.of(context).textTheme.caption?.color,
              fontSize: 12,
            )),
      ])),
    );
  }

  Widget buildItems(ExchangeTicket ticket) {
    final monthPlan = db.curUser.ticketOf(ticket.id);
    List<Widget> trailingItems = [];
    final items = ticket.of(db.curUser.region);
    for (int index = 0; index < items.length; index++) {
      final itemId = items[index];
      final item = db.gameData.items[itemId];
      int leftNum = db.itemCenter.itemLeft[itemId] ?? 0;
      monthPlan[index] = monthPlan[index].clamp2(0, ticket.days);
      final int maxValue =
          ticket.days - Maths.sum(monthPlan.getRange(0, index));
      trailingItems.addAll([
        Item.iconBuilder(
          context: context,
          item: item,
          itemId: itemId,
          width: 36,
          text: (db.curUser.items[itemId] ?? 0).format(),
          textPadding: const EdgeInsets.only(top: 30),
          popDetail: true,
        ),
        SizedBox(
          width: 36,
          child: MaterialButton(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              children: <Widget>[
                Text(monthPlan[index] == 0
                    ? ''
                    : (monthPlan[index] * ticket.multiplier).toString()),
                const Divider(height: 1),
                AutoSizeText(
                  leftNum.format(),
                  maxLines: 1,
                  minFontSize: 6,
                  group: _autoSizeGroup,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: leftNum >= 0 ? Colors.grey : Colors.redAccent),
                )
              ],
            ),
            onPressed: () {
              Picker(
                title: Text('${ticket.dateStr} ${item?.lName.l}'),
                itemExtent: 36,
                height: min(250, MediaQuery.of(context).size.height - 220),
                hideHeader: true,
                cancelText: S.current.cancel,
                confirmText: S.current.confirm,
                backgroundColor: null,
                textStyle: Theme.of(context).textTheme.headline6,
                adapter: NumberPickerAdapter(
                  data: [
                    NumberPickerColumn(
                      items: List.generate(
                          maxValue + 2, (i) => i == 0 ? 0 : maxValue + 1 - i),
                      initValue: monthPlan[index],
                      onFormatValue: (v) {
                        return ticket.multiplier == 1
                            ? v.toString()
                            : '$v×${ticket.multiplier}';
                      },
                    ),
                  ],
                ),
                onConfirm: (picker, values) {
                  monthPlan[index] = picker.getSelectedValues()[0];
                  for (var j = 0; j < 3; j++) {
                    final int v = min(monthPlan[j],
                        ticket.days - Maths.sum(monthPlan.getRange(0, j)));
                    monthPlan[j] = v;
                  }
                  db.itemCenter.updateExchangeTickets();
                },
              ).showDialog(context);
            },
          ),
        )
      ]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingItems,
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
