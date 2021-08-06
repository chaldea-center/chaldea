import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/campaign_detail_page.dart';
import 'package:chaldea/modules/event/limit_event_detail_page.dart';
import 'package:chaldea/modules/event/main_record_detail_page.dart';
import 'package:chaldea/modules/event/tabs/exchange_ticket_tab.dart';

class ItemObtainEventPage extends StatefulWidget {
  final String itemKey;
  final bool filtrateOutdated;

  const ItemObtainEventPage(
      {Key? key, required this.itemKey, this.filtrateOutdated = true})
      : super(key: key);

  @override
  _ItemObtainEventPageState createState() => _ItemObtainEventPageState();
}

class _ItemObtainEventPageState extends State<ItemObtainEventPage> {
  List<bool> expandedList = [true, true, true, true];

  @override
  Widget build(BuildContext context) {
    return db.streamBuilder((context) {
      List<Widget> children = [
        _limitEventAccordion,
        _ticketAccordion,
        _mainRecordAccordion,
        _campaignAccordion,
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

  bool _hasItemIn(Map<String, dynamic> map) {
    final v = map[widget.itemKey];
    return v != null && v != 0;
  }

  Widget get _limitEventAccordion {
    List<Widget> children = [];
    final limitEvents = db.gameData.events.limitEvents.values
        .where((event) => _whetherToShow(
            db.curUser.events.limitEventOf(event.indexKey).enabled,
            event.isOutdated()))
        .toList();
    EventBase.sortEvents(limitEvents, reversed: false);
    int count = 0;
    limitEvents.forEach((event) {
      final plan = db.curUser.events.limitEventOf(event.indexKey);
      List<String> texts = [];
      bool hasEventItems = _hasItemIn(event.itemsWithRare(plan));
      bool hasLotteryItems = _hasItemIn(event.lottery);
      bool hasExtraItems = event.extra[widget.itemKey] != null;
      if (hasEventItems) {
        texts.add('${S.current.event_title}'
            ' ${event.itemsWithRare(plan)[widget.itemKey]}');
      }
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
      if (texts.isEmpty) return;
      count += event.getItems(plan)[widget.itemKey] ?? 0;
      children.add(ListTile(
        title: AutoSizeText(event.localizedName,
            maxFontSize: 15,
            maxLines: 2,
            style: _textStyle(false, event.isOutdated())),
        onTap: () {
          SplitRoute.push(
            context,
            LimitEventDetailPage(event: event),
            detail: true,
          );
        },
        trailing: Text(
          texts.join('\n'),
          style: _textStyle(plan.enabled, event.isOutdated()),
          textAlign: TextAlign.right,
        ),
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).limited_event),
      trailing: Text(count.toString()),
      children: children,
      expanded: expandedList[0],
    );
  }

  Widget get _ticketAccordion {
    List<Widget> children = [];
    final exchangeTickets = db.gameData.events.exchangeTickets.values.toList();
    exchangeTickets.sort((a, b) => a.curDate.compareTo(b.curDate));
    int count = 0;
    exchangeTickets.forEach((ticket) {
      int itemIndex = ticket.items.indexOf(widget.itemKey);
      if (itemIndex < 0) {
        return;
      }

      final plan = db.curUser.events.exchangeTicketOf(ticket.monthJp);
      // bool planned = sum(plan) > 0;

      if (!_whetherToShow(plan.enabled, ticket.isOutdated())) {
        return;
      }

      int itemNum = plan.items[itemIndex];
      count += itemNum;
      children.add(SimpleAccordion(
        expanded: false,
        headerBuilder: (context, _) => ListTile(
          title: Text(
            '${S.current.exchange_ticket_short} ${ticket.dateToStr()}',
            style: _textStyle(false, ticket.isOutdated()),
          ),
          subtitle: AutoSizeText(ticket.items.join('/'), maxLines: 1),
          trailing: Text(
            '$itemNum/${ticket.days}',
            style: _textStyle(plan.enabled, ticket.isOutdated()),
          ),
        ),
        contentBuilder: (context) => ExchangeTicketTab(monthJp: ticket.monthJp),
        expandIconBuilder: (_, __) => Container(),
        disableAnimation: true,
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).exchange_ticket),
      trailing: Text(count.toString()),
      children: children,
      expanded: expandedList[1],
    );
  }

  Widget get _mainRecordAccordion {
    List<Widget> children = [];
    final mainRecords = db.gameData.events.mainRecords.values.toList();
    EventBase.sortEvents(mainRecords, reversed: false);
    int count = 0;
    mainRecords.forEach((record) {
      bool hasDrop = record.drops.containsKey(widget.itemKey);
      bool hasRewards = record.rewards.containsKey(widget.itemKey);
      if (!hasDrop && !hasRewards) {
        return;
      }
      final plan = db.curUser.events.mainRecordOf(record.indexKey);
      if (!_whetherToShow(plan.enabled, record.isOutdated())) {
        return;
      }
      count += record.getItems(plan)[widget.itemKey] ?? 0;
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
            context,
            MainRecordDetailPage(record: record),
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
                style: _textStyle(plan.enabled, record.isOutdated()),
              ),
            if (hasRewards)
              Text(
                '${S.current.main_record_bonus_short}'
                ' ${record.rewards[widget.itemKey]}',
                style: _textStyle(plan.enabled, record.isOutdated()),
              ),
          ],
        ),
      ));
    });
    return _getAccordion(
      title: Text(S.of(context).main_record),
      trailing: Text(count.toString()),
      children: children,
      expanded: expandedList[2],
    );
  }

  Widget get _campaignAccordion {
    List<Widget> children = [];
    final campaigns = db.gameData.events.campaigns.values
        .where((event) => _whetherToShow(
        db.curUser.events.campaignEventPlanOf(event.indexKey).enabled,
            event.isOutdated()))
        .toList();
    EventBase.sortEvents(campaigns, reversed: false);
    int count = 0;
    campaigns.forEach((event) {
      final plan = db.curUser.events.campaignEventPlanOf(event.indexKey);
      List<String> texts = [];
      bool hasEventItems = _hasItemIn(event.itemsWithRare(plan));
      if (hasEventItems) {
        texts.add('${S.current.event_title}'
            ' ${event.itemsWithRare(plan)[widget.itemKey]}');
      }
      if (texts.isEmpty) return;
      count += event.getItems(plan)[widget.itemKey] ?? 0;
      children.add(ListTile(
        title: AutoSizeText(event.localizedName,
            maxFontSize: 15,
            maxLines: 2,
            style: _textStyle(false, event.isOutdated())),
        onTap: () {
          SplitRoute.push(
            context,
            CampaignDetailPage(event: event),
            detail: true,
          );
        },
        trailing: Text(
          texts.join('\n'),
          style: _textStyle(plan.enabled, event.isOutdated()),
          textAlign: TextAlign.right,
        ),
      ));
    });
    return _getAccordion(
      title: Text(S.current.campaign_event),
      trailing: Text(count.toString()),
      children: children,
      expanded: expandedList[3],
    );
  }

  Widget _getAccordion({
    required Widget title,
    Widget? trailing,
    required List<Widget> children,
    required bool expanded,
  }) {
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, expanded) => ListTile(
        leading: Icon(Icons.event),
        title: title,
        trailing: trailing,
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
