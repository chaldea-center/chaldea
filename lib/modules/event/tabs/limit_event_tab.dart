import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../limit_event_detail_page.dart';

class LimitEventTab extends StatefulWidget {
  @override
  _LimitEventTabState createState() => _LimitEventTabState();
}

class _LimitEventTabState extends State<LimitEventTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final eventNames = db.gameData.events.limitEvents.keys.toList();
    return ListView.separated(
      itemCount: eventNames.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final event = db.gameData.events.limitEvents[eventNames[index]];
        return CustomTile(
          title: AutoSizeText(event.name??'null?$event', maxLines: 1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (event.hunting != null || event.lottery != null)
                Icon(
                  Icons.star,
                  color: Colors.yellow[700],
                ),
              Switch.adaptive(
                  value: db.curPlan.limitEvents[event.name]?.enable ?? false,
                  onChanged: (v) => setState(() {
                        db.curPlan.limitEvents
                            .putIfAbsent(event.name, () => LimitEventPlan())
                            .enable = v;
                      }))
            ],
          ),
          onTap: () {
            SplitRoute.popAndPush(context,
                builder: (context) => EventDetailPage(name: event.name));
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
