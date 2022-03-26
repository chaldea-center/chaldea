import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

class SvtSummonTab extends StatelessWidget {
  final Servant svt;

  const SvtSummonTab({Key? key, required this.svt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LimitedSummon> summons = [];
    for (final summon in db2.gameData.wiki.summons.values) {
      if (summon.allCards(svt: true).contains(svt.collectionNo)) {
        summons.add(summon);
      }
    }

    if (summons.isEmpty) {
      return const ListTile(
        title: Text('No related summons'),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) => summonTile(summons[index]),
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: summons.length,
    );
  }

  Widget summonTile(LimitedSummon summon) {
    bool planned = db2.curUser.summons.contains(summon.id);
    return ListTile(
      title: Row(
        children: [
          if (summon.hasSinglePickupSvt(svt.collectionNo))
            Icon(Icons.star, color: Colors.yellow[800], size: 18),
          Flexible(
            child: AutoSizeText(
              summon.name.l ?? summon.id,
              maxLines: 2,
              // style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
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
          db2.curUser.summons.toggle(summon.id);
          db2.notifyUserdata();
        },
      ),
      onTap: () {
        // SplitRoute.push(context, SummonDetailPage(summon: summon));
      },
    );
  }
}
