import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../event_base_page.dart';
import '../limit_event_detail_page.dart';

class LimitEventTab extends StatefulWidget {
  final bool reverse;
  final bool showOutdated;
  final bool showSpecialRewards;

  const LimitEventTab(
      {Key? key,
      this.reverse = false,
      this.showOutdated = false,
      this.showSpecialRewards = false})
      : super(key: key);

  @override
  _LimitEventTabState createState() => _LimitEventTabState();
}

class _LimitEventTabState extends State<LimitEventTab> {
  late ScrollController _scrollController;

  Map<String, LimitEvent> get limitEvents => db.gameData.events.limitEvents;

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
    List<LimitEvent> events = limitEvents.values.toList();
    if (!widget.showOutdated) {
      events.removeWhere((e) =>
          e.isOutdated() &&
          !db.curUser.events.limitEventOf(e.indexKey).enabled);
    }
    EventBase.sortEvents(events, reversed: widget.reverse);

    return ListView.separated(
      controller: _scrollController,
      itemCount: events.length,
      separatorBuilder: (context, index) => kDefaultDivider,
      itemBuilder: (context, index) {
        final event = events[index];
        final plan = db.curUser.events.limitEventOf(event.indexKey);
        bool outdated = event.isOutdated();
        String? subtitle;
        if (db.curUser.server == GameServer.cn) {
          subtitle = event.startTimeCn?.split(' ').first;
          if (subtitle != null) {
            subtitle = 'CN ' + subtitle;
          }
        }
        if (subtitle == null) {
          subtitle = 'JP ' + (event.startTimeJp?.split(' ').first ?? '???');
        }
        Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
        Widget tile = ListTile(
          title: AutoSizeText(
            event.localizedName,
            maxFontSize: 16,
            maxLines: 2,
            style: outdated ? TextStyle(color: _outdatedColor) : null,
          ),
          subtitle: AutoSizeText(
            subtitle,
            maxLines: 1,
            style: outdated
                ? TextStyle(color: _outdatedColor?.withAlpha(200))
                : null,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (event.extra.isNotEmpty || event.lottery.isNotEmpty)
                Icon(Icons.star, color: Colors.yellow[700]),
              db.streamBuilder(
                (context) => Switch.adaptive(
                  value: plan.enabled,
                  onChanged: (v) => setState(() {
                    plan.enabled = v;
                    db.itemStat.updateEventItems();
                  }),
                ),
              )
            ],
          ),
          onTap: () {
            SplitRoute.push(
              context,
              LimitEventDetailPage(event: event),
              popDetail: true,
            );
          },
        );
        if (widget.showSpecialRewards) {
          tile = EventBasePage.buildSpecialRewards(context, event, tile);
        }
        return tile;
      },
    );
  }
}
