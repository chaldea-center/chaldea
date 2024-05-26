import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class ExchangeTicketTab extends StatefulWidget {
  /// If only show ONE month
  final int? id;
  final bool reversed;
  final bool showOutdated;

  const ExchangeTicketTab({
    super.key,
    this.id,
    this.reversed = false,
    this.showOutdated = false,
  });

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
      return ListView.separated(
        controller: _scrollController,
        itemCount: tickets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return hintText;
          return buildOneMonth(tickets[index - 1]);
        },
        separatorBuilder: (context, _) => const Divider(
          height: 8,
          indent: 12,
        ),
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  Widget buildOneMonth(ExchangeTicket ticket) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
            child: LayoutBuilder(
              builder: (context, constraints) => buildItems(ticket, constraints.maxWidth),
            ),
          ),
        )
      ],
    );
  }

  Widget buildTitle(ExchangeTicket ticket) {
    final plan = db.curUser.ticketOf(ticket.id);
    bool planned = plan.enabled;
    bool outdated = ticket.isOutdated();
    Color? _plannedColor = AppTheme(context).tertiary;
    Color? _outdatedColor = Theme.of(context).textTheme.bodySmall?.color;
    bool hasAnyReplaced = ticket.replaced.values.any((e) => e != null);
    bool isThisMonth = DateUtils.isSameMonth(ticket.date, DateTime.now());

    String maxHint = 'max: ${ticket.days}';
    if (isThisMonth) {
      final curMonthDayLeft = ticket.days - DateTime.now().day + 1;
      maxHint += '($curMonthDayLeft)';
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) => _showReplaceDetail(context, ticket),
        );
      },
      onLongPress: () {
        if (plan.enabled) {
          SimpleCancelOkDialog(
            title: Text(S.current.clear),
            onTapOk: () {
              plan.clear();
              db.itemCenter.updateExchangeTickets();
            },
          ).showDialog(context);
        }
      },
      child: Text.rich(TextSpan(children: [
        TextSpan(
          text: ticket.dateStr,
          children: [if (hasAnyReplaced) const CenterWidgetSpan(child: Icon(Icons.help_outline, size: 18))],
          style: TextStyle(
            color: planned
                ? _plannedColor
                : outdated
                    ? _outdatedColor
                    : null,
            fontWeight: outdated ? null : FontWeight.w600,
          ),
        ),
        const TextSpan(text: '\n'),
        TextSpan(
            text: db.curUser.region == Region.jp ? maxHint : 'JP ${ticket.year}-${ticket.month}\n$maxHint',
            children: [
              if (ticket.multiplier != 1)
                TextSpan(
                  text: ' ×${ticket.multiplier}',
                  style: TextStyle(
                    color: AppTheme(context).tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                )
            ],
            style: TextStyle(
              color: isThisMonth ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            )),
      ])),
    );
  }

  Widget buildItems(ExchangeTicket ticket, double width) {
    final monthPlan = db.curUser.ticketOf(ticket.id);
    List<Widget> trailingItems = [];
    final items = ticket.of(db.curUser.region);
    if (items.isEmpty) return const SizedBox.shrink();
    for (int index = 0; index < items.length; index++) {
      final itemId = items[index];
      final item = db.gameData.items[itemId];
      int leftNum = db.itemCenter.itemLeft[itemId] ?? 0;
      monthPlan[index] = monthPlan[index].clamp2(0, ticket.days);
      final int maxValue = ticket.days - Maths.sum(monthPlan.getRange(0, index));
      trailingItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Item.iconBuilder(
            context: context,
            item: item,
            itemId: itemId,
            width: 36,
            text: (db.curUser.items[itemId] ?? 0).format(),
            option: ImageWithTextOption(fontSize: 36 * 0.27),
            popDetail: SplitRoute.of(context)?.detail == false,
          ),
          SizedBox(
            width: 36,
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(),
              child: Column(
                children: <Widget>[
                  Text(monthPlan[index] == 0 ? '' : (monthPlan[index] * ticket.multiplier).toString()),
                  const Divider(height: 1),
                  AutoSizeText(
                    leftNum.format(),
                    maxLines: 1,
                    minFontSize: 6,
                    group: _autoSizeGroup,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: leftNum >= 0 ? Colors.grey : Colors.redAccent),
                  )
                ],
              ),
              onPressed: () {
                final values = List.generate(maxValue + 2, (i) => i == 0 ? 0 : maxValue + 1 - i);
                SingleCupertinoPicker(
                  title: Text('${ticket.dateStr} ${item?.lName.l}'),
                  initialItem: values.indexOf(monthPlan[index]).clamp2(0),
                  builder: (context) => [
                    for (final v in values)
                      Center(child: Text(ticket.multiplier == 1 ? v.toString() : '$v×${ticket.multiplier}')),
                  ],
                  itemExtent: 36,
                  onSelected: (idx) {
                    monthPlan[index] = values[idx];
                    for (var j = 0; j < 3; j++) {
                      final int v = min(monthPlan[j], ticket.days - Maths.sum(monthPlan.getRange(0, j)));
                      monthPlan[j] = v;
                    }
                    db.itemCenter.updateExchangeTickets();
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
            ),
          )
        ],
      ));
    }
    Widget child = Wrap(
      alignment: WrapAlignment.end,
      children: trailingItems,
    );
    if (items.length <= 3 && items.isNotEmpty) {
      child = FittedBox(
        fit: BoxFit.scaleDown,
        child: child,
      );
    } else if (width < 72 * 5) {
      child = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 72 * 4 - 2),
        child: child,
      );
    }
    return child;
  }

  Widget _showReplaceDetail(BuildContext coontext, ExchangeTicket ticket) {
    final item = db.gameData.items[ticket.itemId];
    List<Widget> children = [];
    for (final region in Region.values) {
      final items = ticket.of(region);
      children.add(ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        title: Text(region.localName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final itemId in items) Item.iconBuilder(context: context, item: null, itemId: itemId),
          ],
        ),
      ));
    }
    return SimpleDialog(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: item == null ? null : Item.iconBuilder(context: context, item: item),
        minLeadingWidth: 36,
        title: Text.rich(TextSpan(
          text: ticket.dateStr,
          children: [
            TextSpan(
              text: '\nJP ${ticket.year}-${ticket.month}',
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        )),
        trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
        onTap: () {
          router.push(url: Routes.itemI(ticket.itemId));
        },
      ),
      children: children,
    );
  }
}
