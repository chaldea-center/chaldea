import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

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
    bool planned = db.curUser.summons.contains(summon.id);
    return ListTile(
      title: Row(
        children: [
          if (summon.hasSinglePickupSvt(svt.collectionNo))
            Icon(Icons.star, color: Colors.yellow[800], size: 18),
          Flexible(
            child: AutoSizeText(
              summon.name.l ?? summon.id,
              maxLines: 2,
              style: TextStyle(
                color: summon.isOutdated()
                    ? Theme.of(context).textTheme.caption?.color
                    : null,
              ),
              maxFontSize: 14,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          planned ? Icons.favorite : Icons.favorite_outline,
          color: planned ? Colors.redAccent : null,
        ),
        onPressed: () {
          db.curUser.summons.toggle(summon.id);
          db.notifyUserdata();
        },
      ),
      onTap: () {
        router.push(url: summon.route);
      },
    );
  }
}
