import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../limit_event_detail_page.dart';

class LimitEventTab extends StatefulWidget {
  final bool reverse;

  const LimitEventTab({Key key, this.reverse = false}) : super(key: key);

  @override
  _LimitEventTabState createState() => _LimitEventTabState();
}

class _LimitEventTabState extends State<LimitEventTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final events = db.gameData.events.limitEvents.values.toList();
    events.sort((a, b) {
      return (a.startTimeJp).compareTo(b.startTimeJp) *
          (widget.reverse ? -1 : 1);
    });
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final event = events[index];
        final plan = db.curPlan.limitEvents;
        return CustomTile(
          title: AutoSizeText(event.name, maxLines: 1),
          subtitle: AutoSizeText(event.startTimeJp ?? 'null', maxLines: 1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (event.extra != null || event.lottery != null)
                Icon(Icons.star, color: Colors.yellow[700]),
              Switch.adaptive(
                  value: plan[event.name]?.enable ?? false,
                  onChanged: (v) => setState(() {
                        plan
                            .putIfAbsent(event.name, () => LimitEventPlan())
                            .enable = v;
                      }))
            ],
          ),
          onTap: () {
            SplitRoute.popAndPush(context,
                builder: (context) => LimitEventDetailPage(name: event.name));
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
