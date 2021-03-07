//@dart=2.12
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtSummonTab extends SvtTabBaseWidget {
  SvtSummonTab({
    Key? key,
    ServantDetailPageState? parent,
    Servant? svt,
    ServantStatus? status,
  }) : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtSummonTabState createState() =>
      _SvtSummonTabState(parent: parent, svt: svt, plan: status);
}

class _SvtSummonTabState extends SvtTabBaseState<SvtSummonTab> {
  _SvtSummonTabState(
      {ServantDetailPageState? parent, Servant? svt, ServantStatus? plan})
      : super(parent: parent, svt: svt, status: plan);

  List<Summon> shownSummons = [];

  @override
  void initState() {
    super.initState();
    db.gameData.summons.forEach((key, summon) {
      if (summon.luckyBag > 0) {
        if (summon.allSvts(svt.info.rarity == 5).contains(svt.no)) {
          shownSummons.add(summon);
        }
      } else if (summon.classPickUp) {
        if (summon.allSvts(true).contains(svt.no)) {
          shownSummons.add(summon);
        }
      } else {
        if (summon.allSvts().contains(svt.no)) {
          shownSummons.add(summon);
        }
      }
    });
    shownSummons = shownSummons.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (shownSummons.isEmpty) {
      return ListTile(title: Text('无关联卡池'));
    }

    return ListView.separated(
      itemBuilder: (context, index) => summonTile(shownSummons[index]),
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: shownSummons.length,
    );
  }

  Widget summonTile(Summon summon) {
    bool planned = db.curUser.plannedSummons.contains(summon.indexKey);
    return ListTile(
      title: Row(
        children: [
          if (summon.hasSinglePickupSvt(svt.no))
            Icon(Icons.star, color: Colors.yellow[800], size: 18),
          Flexible(
            child: AutoSizeText(
              summon.localizedName,
              maxLines: 2,
              style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
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
          if (planned) {
            db.curUser.plannedSummons.remove(summon.indexKey);
          } else {
            db.curUser.plannedSummons.add(summon.indexKey);
          }
          db.onAppUpdate();
        },
      ),
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => SummonDetailPage(summon: summon),
        );
      },
    );
  }
}
