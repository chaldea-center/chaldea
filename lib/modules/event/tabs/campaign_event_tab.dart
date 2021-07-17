import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import '../campaign_detail_page.dart';

class CampaignEventTab extends StatefulWidget {
  final bool reverse;
  final bool showOutdated;

  const CampaignEventTab(
      {Key? key, this.reverse = false, this.showOutdated = false})
      : super(key: key);

  @override
  _CampaignEventTabState createState() => _CampaignEventTabState();
}

class _CampaignEventTabState extends State<CampaignEventTab> {
  late ScrollController _scrollController;

  Map<String, CampaignEvent> get campaigns => db.gameData.events.campaigns;

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
    List<CampaignEvent> events = campaigns.values.toList();
    if (!widget.showOutdated) {
      events.removeWhere((e) =>
          e.isOutdated() && !db.curUser.events.limitEventOf(e.indexKey).enable);
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
        return ListTile(
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
          trailing: event.couldPlan
              ? db.streamBuilder(
                  (context) => Switch.adaptive(
                    value: plan.enable,
                    onChanged: (v) => setState(() {
                      plan.enable = v;
                      db.itemStat.updateEventItems();
                    }),
                  ),
                )
              : null,
          onTap: () {
            SplitRoute.push(
              context: context,
              builder: (context, _) => CampaignDetailPage(event: event),
              popDetail: true,
            );
          },
        );
      },
    );
  }
}
