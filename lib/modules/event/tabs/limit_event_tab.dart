//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../limit_event_detail_page.dart';

class LimitEventTab extends StatefulWidget {
  final bool reverse;
  final bool showOutdated;

  const LimitEventTab(
      {Key? key, this.reverse = false, this.showOutdated = false})
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
          e.isOutdated() && !db.curUser.events.limitEventOf(e.indexKey).enable);
    }
    EventBase.sortEvents(events, reversed: widget.reverse);

    return Scrollbar(
      controller: _scrollController,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: events.length,
        separatorBuilder: (context, index) => kDefaultDivider,
        itemBuilder: (context, index) {
          final event = events[index];
          final plan = db.curUser.events.limitEventOf(event.indexKey);
          bool outdated = event.isOutdated();
          return ListTile(
            title: AutoSizeText(
              event.localizedName,
              maxFontSize: 16,
              maxLines: 2,
              style: outdated ? TextStyle(color: Colors.grey) : null,
            ),
            subtitle: AutoSizeText(
              event.startTimeJp.split(' ').first,
              maxLines: 1,
              style: outdated ? TextStyle(color: Colors.grey[400]) : null,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (event.extra?.isNotEmpty == true ||
                    event.lottery?.isNotEmpty == true)
                  Icon(Icons.star, color: Colors.yellow[700]),
                db.itemStat.wrapStreamBuilder(
                  (context, _) => Switch.adaptive(
                    value: plan.enable,
                    onChanged: (v) => setState(() {
                      plan.enable = v;
                      db.itemStat.updateEventItems();
                    }),
                  ),
                )
              ],
            ),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) => LimitEventDetailPage(event: event),
                popDetail: true,
              );
            },
          );
        },
      ),
    );
  }
}
