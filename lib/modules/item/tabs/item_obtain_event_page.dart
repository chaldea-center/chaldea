import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/event/tabs/exchange_ticket_tab.dart';

class ItemObtainEventPage extends StatefulWidget {
  final String itemKey;
  final bool favorite;
  final bool filtrateOutdated;

  const ItemObtainEventPage(
      {Key? key,
      required this.itemKey,
      this.favorite = false,
      this.filtrateOutdated = true})
      : super(key: key);

  @override
  _ItemObtainEventPageState createState() => _ItemObtainEventPageState();
}

class _ItemObtainEventPageState extends State<ItemObtainEventPage> {
  List<bool> expandedList = [true, true, true];

  @override
  Widget build(BuildContext context) {
    return db.streamBuilder((context) {
      List<Widget> children = [
        _limitEventAccordion,
        _ticketAccordion,
        _mainRecordAccordion
      ];
      return ListView.separated(
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => kDefaultDivider,
        itemCount: children.length,
      );
    });
  }

  bool _whetherToShow(bool planned, bool outdated) {
    if (planned) return true;
    if (widget.favorite) return false;
    if (widget.filtrateOutdated && outdated) return false;
    return true;
  }

  TextStyle? _textStyle([bool highlight = false, bool outdated = false]) {
    if (!highlight && !outdated) return null;
    return TextStyle(
      color: highlight
          ? Colors.blueAccent
          : outdated
              ? Colors.grey
              : null,
    );
  }

  Widget get _limitEventAccordion {
    List<Widget> children = [];
    final limitEvents = db.gameData.events.limitEvents.values.toList();
    EventBase.sortEvents(limitEvents, reversed: true);
    limitEvents.forEach((event) {
      final plan = db.curUser.events.limitEventOf(event.indexKey);
      List<String> texts = [];
      bool hasEventItems =
          event.itemsWithRare(plan).containsKey(widget.itemKey);
      bool hasLotteryItems = event.lottery.containsKey(widget.itemKey);
      bool hasExtraItems = event.extra.containsKey(widget.itemKey);
      // don't contain this item
      if (!hasEventItems && !hasLotteryItems && !hasExtraItems) {
        return;
      }
      if (!_whetherToShow(plan.enable, event.isOutdated())) {
        return;
      }
      if (hasEventItems)
        texts.add('${S.current.event_title}'
            ' ${event.itemsWithRare(plan)[widget.itemKey]}');
      if (hasLotteryItems) {
        String prefix = event.lotteryLimit > 0
            ? S.current.event_lottery_limited
            : S.current.event_lottery_unlimited;
        prefix = prefix.split(' ').first; // english word too long
        texts.add('$prefix'
            ' ${event.lottery[widget.itemKey]}*${plan.lottery}');
      }
      if (hasExtraItems) {
        texts.add('${S.current.event_item_extra}'
            ' ${plan.extra[widget.itemKey] ?? 0}');
      }
      children.add(ListTile(
        title: AutoSizeText(event.localizedName,
            maxFontSize: 15,
            maxLines: 2,
            style: _textStyle(false, event.isOutdated())),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => LimitEventDetailPage(event: event),
            detail: true,
          );
        },
        trailing: Text(
          texts.join('\n'),
          style: _textStyle(plan.enable, event.isOutdated()),
          textAlign: TextAlign.right,
        ),
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).limited_event),
      children: children,
      expanded: expandedList[0],
    );
  }

  Widget get _ticketAccordion {
    List<Widget> children = [];
    final exchangeTickets = db.gameData.events.exchangeTickets.values.toList();
    // from new to old
    exchangeTickets.sort((a, b) => b.month.compareTo(a.month));
    exchangeTickets.forEach((ticket) {
      int itemIndex = ticket.items.indexOf(widget.itemKey);
      if (itemIndex < 0) {
        return;
      }

      final plan = db.curUser.events.exchangeTicketOf(ticket.month);
      bool planned = sum(plan) > 0;

      if (!_whetherToShow(planned, ticket.isOutdated())) {
        return;
      }

      int itemNum = plan.elementAt(itemIndex);
      children.add(SimpleAccordion(
        expanded: false,
        headerBuilder: (context, _) => ListTile(
          title: Text(
            '${S.current.exchange_ticket_short} ${ticket.month}',
            style: _textStyle(false, ticket.isOutdated()),
          ),
          subtitle: AutoSizeText(ticket.items.join('/'), maxLines: 1),
          trailing: Text(
            '$itemNum/${ticket.days}',
            style: _textStyle(planned, ticket.isOutdated()),
          ),
        ),
        contentBuilder: (context) => ExchangeTicketTab(month: ticket.month),
        expandIconBuilder: (_, __) => Container(),
        disableAnimation: true,
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).exchange_ticket),
      children: children,
      expanded: expandedList[1],
    );
  }

  Widget get _mainRecordAccordion {
    List<Widget> children = [];
    final mainRecords = db.gameData.events.mainRecords.values.toList();
    // new to old
    EventBase.sortEvents(mainRecords, reversed: true);
    mainRecords.forEach((record) {
      bool hasDrop = record.drops.containsKey(widget.itemKey);
      bool hasRewards = record.rewards.containsKey(widget.itemKey);
      if (!hasDrop && !hasRewards) {
        return;
      }
      final plan = db.curUser.events.mainRecordOf(record.indexKey);
      bool planned = plan.contains(true);
      if (!_whetherToShow(planned, record.isOutdated())) {
        return;
      }

      children.add(ListTile(
        title: AutoSizeText(
          record.localizedChapter,
          maxLines: 1,
          style: _textStyle(false, record.isOutdated()),
        ),
        subtitle: AutoSizeText(
          record.localizedTitle,
          maxLines: 1,
          style: _textStyle(false, record.isOutdated())
              ?.copyWith(color: Colors.grey[400]),
        ),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => MainRecordDetailPage(record: record),
            detail: true,
          );
        },
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDrop)
              Text(
                '${S.current.main_record_fixed_drop_short}'
                ' ${record.drops[widget.itemKey]}',
                style: _textStyle(planned, record.isOutdated()),
              ),
            if (hasRewards)
              Text(
                '${S.current.main_record_bonus_short}'
                ' ${record.rewards[widget.itemKey]}',
                style: _textStyle(planned, record.isOutdated()),
              ),
          ],
        ),
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).main_record),
      children: children,
      expanded: expandedList[2],
    );
  }

  Widget _getAccordion(
      {required Widget title,
      required List<Widget> children,
      required bool expanded}) {
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, expanded) => ListTile(
        leading: Icon(Icons.event),
        title: title,
        horizontalTitleGap: 0,
      ),
      contentBuilder: (context) => ListView.separated(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        itemCount: children.length,
        separatorBuilder: (context, index) => kDefaultDivider,
      ),
    );
  }
}
