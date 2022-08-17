import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class LimitEventTab extends StatelessWidget {
  final List<Event> limitEvents;
  final bool reversed;
  final bool showOutdated;
  final bool showSpecialRewards;
  final ScrollController scrollController;

  LimitEventTab({
    Key? key,
    required this.limitEvents,
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Event> events = limitEvents.toList();
    events.removeWhere((event) => event.isEmpty && !event.extra.forceShown);
    if (!showOutdated) {
      events.removeWhere(
          (e) => e.isOutdated() && !db.curUser.limitEventPlanOf(e.id).enabled);
    }

    events.sort2((e) => e.startedAt, reversed: reversed);
    return ListView.builder(
      controller: scrollController,
      itemCount: events.length,
      itemBuilder: (context, index) => buildOne(context, events[index]),
    );
  }

  Widget buildOne(BuildContext context, Event event) {
    final plan = db.curUser.limitEventPlanOf(event.id);
    bool outdated = event.isOutdated();
    final region = db.curUser.region;
    Map<Region, int?> dates = {
      Region.jp: event.startedAt,
      if (region != Region.jp) region: event.extra.startTime.ofRegion(region)
    };
    String subtitle = dates.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key.toUpper()} ${e.value?.sec2date().toDateString()}')
        .join(' / ');

    Color? _outdatedColor = Theme.of(context).textTheme.caption?.color;
    Widget tile = ListTile(
      title: AutoSizeText(
        event.shownName,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (event.extra.extraItems.isNotEmpty ||
              event.lotteries.isNotEmpty ||
              event.treasureBoxes.isNotEmpty)
            Icon(Icons.star, color: Colors.yellow[700]),
          Switch.adaptive(
            value: plan.enabled,
            onChanged: (v) {
              plan.enabled = v;
              event.updateStat();
            },
          )
        ],
      ),
      onTap: () {
        router.popDetailAndPush(url: Routes.eventI(event.id), detail: true);
      },
    );
    if (showSpecialRewards) {
      List<Widget> rewards = [];
      final entries = event.statItemFixed.entries.toList();
      entries.sort((a, b) {
        final ia = db.gameData.items[a.key], ib = db.gameData.items[b.key];
        if (ia != null && ib != null) return ia.priority.compareTo(ib.priority);
        final sa = db.gameData.entities[a.key],
            sb = db.gameData.entities[b.key];
        if (sa != null && sb != null) {
          if (sa.collectionNo != sb.collectionNo) {
            return sb.collectionNo - sa.collectionNo;
          }
          return sa.id - sb.id;
        }
        return sa == null ? 1 : -1;
      });
      for (final entry in entries) {
        if (entry.value <= 0) continue;
        final objectId = entry.key;
        if ([
          Items.grailId,
          Items.crystalId,
          Items.rarePrismId,
          Items.hpFou4,
          Items.atkFou4,
          Items.grailToCrystalId,
        ].contains(objectId)) {
          rewards.add(Item.iconBuilder(
            context: context,
            item: null,
            itemId: objectId,
            width: 32,
            text: entry.value.format(),
          ));
          continue;
        }
        final svt = db.gameData.servantsById[objectId];
        if (svt != null && svt.isUserSvt) {
          rewards.add(svt.iconBuilder(context: context, width: 32));
        }
      }

      if (rewards.isNotEmpty) {
        tile = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile,
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 4),
              child: Wrap(
                spacing: 1,
                children: rewards,
              ),
            )
          ],
        );
      }
    }
    return tile;
  }
}
