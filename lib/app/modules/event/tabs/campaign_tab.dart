import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class CampaignEventTab extends StatelessWidget {
  final List<Event> campaignEvents;
  final bool reversed;
  final bool showOutdated;

  CampaignEventTab({super.key, required this.campaignEvents, this.reversed = false, this.showOutdated = false});

  @override
  Widget build(BuildContext context) {
    List<Event> events = campaignEvents.toList();
    if (!showOutdated) {
      events.removeWhere((e) => e.isOutdated());
    }
    events.sort2((e) => e.startedAt, reversed: reversed);
    List<Widget> children = [];

    if (db.curUser.region != Region.jp) {
      for (final event in events) {
        if (event.isOnGoing(db.curUser.region)) {
          children.add(buildOne(context, event, true));
        }
      }
    }
    for (final event in events) {
      children.add(buildOne(context, event, false));
    }

    return ListView.builder(itemCount: children.length, itemBuilder: (context, index) => children[index]);
  }

  Widget buildOne(BuildContext context, Event event, bool highlight) {
    bool outdated = event.isOutdated();
    final region = db.curUser.region;
    Map<Region, int?> dates = {
      Region.jp: event.startedAt,
      if (region != Region.jp) region: event.extra.startTime.ofRegion(region),
    };
    String subtitle = dates.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key.upper} ${e.value?.sec2date().toDateString()}')
        .join(' / ');

    Color? _outdatedColor = Theme.of(context).textTheme.bodySmall?.color;
    Widget tile = ListTile(
      dense: true,
      selected: highlight,
      title: AutoSizeText.rich(
        TextSpan(
          children: [
            if (event.isOnGoing(null)) const TextSpan(text: '● ', style: TextStyle(color: Colors.green)),
            TextSpan(text: event.shownName),
          ],
        ),
        maxFontSize: 14,
        maxLines: 2,
        style: outdated ? TextStyle(color: _outdatedColor) : null,
      ),
      subtitle: AutoSizeText(
        subtitle,
        maxLines: 1,
        style: TextStyle(
          color: outdated ? _outdatedColor?.withAlpha(200) : null,
          decoration: highlight ? TextDecoration.underline : null,
        ),
        textScaleFactor: 0.9,
      ),
      onTap: () {
        router.popDetailAndPush(context: context, url: Routes.eventI(event.id), detail: true);
      },
    );
    return tile;
  }
}
