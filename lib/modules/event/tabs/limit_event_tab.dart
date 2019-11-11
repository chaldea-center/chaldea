import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../event_detail_page.dart';

class LimitEventTab extends StatefulWidget {
  @override
  _LimitEventTabState createState() => _LimitEventTabState();
}

class _LimitEventTabState extends State<LimitEventTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final eventNames = db.gameData.events.keys.toList();
    return ListView.separated(
      itemCount: eventNames.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final event = db.gameData.events[eventNames[index]];
        return CustomTile(
          title: AutoSizeText(event.name, maxLines: 1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (event.hunting != null || event.lottery != null)
                Icon(
                  Icons.star,
                  color: Colors.yellow[700],
                ),
              Switch.adaptive(
                  value: db.curPlan.events[event.name]?.enable ?? false,
                  onChanged: (v) => setState(() {
                        db.curPlan.events
                            .putIfAbsent(event.name, () => EventPlan())
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
