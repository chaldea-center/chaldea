import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class LimitEventTab extends StatelessWidget {
  final List<Event> limitEvents;
  final bool reversed;
  final bool showOutdated;
  final bool showSpecialRewards;
  final bool showEmpty;
  final bool showBanner;

  LimitEventTab({
    super.key,
    required this.limitEvents,
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    this.showEmpty = false,
    this.showBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Event> events = limitEvents.where((event) {
      if (event.extra.shown != null) return event.extra.shown!;
      return showEmpty || !event.isEmpty;
    }).toList();

    if (!showOutdated) {
      events.removeWhere((e) => e.isOutdated() && !db.curUser.limitEventPlanOf(e.id).enabled);
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

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget buildOne(BuildContext context, Event event, bool highlight) {
    final plan = db.curUser.limitEventPlanOf(event.id);
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
      dense: true,
      selected: highlight,
      horizontalTitleGap: 16,
      leading: showBanner
          ? CachedImage(
              imageUrl: event.extra.allBanners.firstOrNull,
              aspectRatio: 8 / 3,
              cachedOption: CachedImageOption(
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            )
          : null,
      title: AutoSizeText.rich(
        TextSpan(children: [
          if (<Region>{db.curUser.region, Region.jp}.any((e) => event.isOnGoing(e)))
            const TextSpan(text: '● ', style: TextStyle(color: Colors.green)),
          TextSpan(text: event.shownName),
        ]),
        maxFontSize: 13,
        maxLines: 2,
        style: outdated ? TextStyle(color: _outdatedColor) : null,
      ),
      subtitle: AutoSizeText(
        subtitle,
        maxLines: 1,
        style: TextStyle(
          color: outdated ? _outdatedColor?.withAlpha(100) : null,
          decoration: highlight ? TextDecoration.underline : null,
        ),
        textScaleFactor: 0.9,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (event.isInfinite) Icon(Icons.star, color: Colors.yellow[700]),
          if (!event.isEmpty)
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
        router.popDetailAndPush(context: context, url: Routes.eventI(event.id), detail: true);
      },
    );
    if (showSpecialRewards) {
      List<Widget> rewards = [];
      final entries = event.statItemFixed.entries.toList();
      entries.sort((a, b) {
        final ia = db.gameData.items[a.key], ib = db.gameData.items[b.key];
        if (ia != null && ib != null) return ia.priority.compareTo(ib.priority);
        final sa = db.gameData.entities[a.key], sb = db.gameData.entities[b.key];
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
          rewards.add(svt.iconBuilder(context: context, width: 32, text: entry.value.format()));
        }
        final svtTd = db.gameData.entities[objectId];
        if (svtTd != null && svtTd.type == SvtType.svtMaterialTd) {
          rewards.add(svtTd.iconBuilder(context: context, width: 32, text: entry.value.format()));
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
