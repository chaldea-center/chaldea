import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class CampaignEventTab extends StatelessWidget {
  final List<Event> campaignEvents;
  final bool reversed;
  final bool showOutdated;

  CampaignEventTab({
    super.key,
    required this.campaignEvents,
    this.reversed = false,
    this.showOutdated = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Event> events = campaignEvents.toList();
    if (!showOutdated) {
      events.removeWhere((e) => e.isOutdated());
    }
    events.sort2((e) => e.startedAt, reversed: reversed);
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) => buildOne(context, events[index]),
    );
  }

  Widget buildOne(BuildContext context, Event event) {
    bool outdated = event.isOutdated();
    final region = db.curUser.region;
    Map<Region, int?> dates = {
      Region.jp: event.startedAt,
      if (region != Region.jp) region: event.extra.startTime.ofRegion(region)
    };
    String subtitle = dates.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key.upper} ${e.value?.sec2date().toDateString()}')
        .join(' / ');

    Color? _outdatedColor = Theme.of(context).textTheme.bodySmall?.color;
    Widget tile = ListTile(
      title: AutoSizeText.rich(
        TextSpan(children: [
          if (event.isOnGoing(null))
            const TextSpan(text: '● ', style: TextStyle(color: Colors.green)),
          TextSpan(text: event.shownName)
        ]),
        maxFontSize: 14,
        maxLines: 2,
        style: outdated ? TextStyle(color: _outdatedColor) : null,
      ),
      subtitle: AutoSizeText(
        subtitle,
        maxLines: 1,
        style:
            outdated ? TextStyle(color: _outdatedColor?.withAlpha(200)) : null,
        textScaleFactor: 0.9,
      ),
      onTap: () {
        router.popDetailAndPush(url: Routes.eventI(event.id), detail: true);
      },
    );
    return tile;
  }
}
