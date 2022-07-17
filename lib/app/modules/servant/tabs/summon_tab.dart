import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class SvtSummonTab extends StatelessWidget {
  final Servant svt;

  const SvtSummonTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LimitedSummon> summons = [];
    for (final summon in db.gameData.wiki.summons.values) {
      if (summon
              .allCards(svt: true, includeGSSR: true)
              .contains(svt.collectionNo) &&
          summon.startTime.jp != null) {
        summons.add(summon);
      }
    }

    if (summons.isEmpty) {
      return const ListTile(
        title: Text('No related summons'),
      );
    }
    summons.sort2((e) => e.startTime.jp!, reversed: true);
    return ListView.separated(
      itemBuilder: (context, index) => summonTile(context, summons[index]),
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: summons.length,
    );
  }

  Widget summonTile(BuildContext context, LimitedSummon summon) {
    final outdated = summon.isOutdated();
    String subtitle = 'JP: ${summon.startTime.jp?.sec2date().toDateString()}';
    final localDate =
        summon.startTime.ofRegion(db.curUser.region)?.sec2date().toDateString();
    if (localDate != null) {
      subtitle = '$subtitle / ${db.curUser.region.toUpper()}: $localDate';
    }
    return ListTile(
      dense: true,
      title: Text.rich(
        TextSpan(children: [
          if (summon.hasSinglePickupSvt(svt.collectionNo))
            TextSpan(
                text: kStarChar, style: TextStyle(color: Colors.yellow[800])),
          TextSpan(
            text: summon.name.l ?? summon.id,
            style: outdated
                ? TextStyle(color: Theme.of(context).textTheme.caption?.color)
                : null,
          )
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: outdated ? const TextStyle(fontStyle: FontStyle.italic) : null,
      ),
      trailing: db.onUserData(
        (context, snapshot) {
          bool planned = db.curUser.summons.contains(summon.id);
          return IconButton(
            icon: Icon(
              planned ? Icons.favorite : Icons.favorite_outline,
              color: planned ? Colors.redAccent : null,
            ),
            onPressed: () {
              db.curUser.summons.toggle(summon.id);
              db.notifyUserdata();
            },
          );
        },
      ),
      onTap: () {
        router.push(url: summon.route);
      },
    );
  }
}
