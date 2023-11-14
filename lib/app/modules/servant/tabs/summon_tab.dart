import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SvtSummonTab extends StatefulWidget {
  final Servant svt;

  const SvtSummonTab({super.key, required this.svt});

  @override
  State<SvtSummonTab> createState() => _SvtSummonTabState();
}

class _SvtSummonTabState extends State<SvtSummonTab> {
  bool includeGSSR = true;

  @override
  Widget build(BuildContext context) {
    List<LimitedSummon> summons = [];
    for (final summon in db.gameData.wiki.summons.values) {
      if (summon.allCards(svt: true, includeGSSR: includeGSSR).contains(widget.svt.collectionNo) &&
          summon.startTime.jp != null) {
        summons.add(summon);
      }
    }
    summons.sort2((e) => e.startTime.jp!, reversed: true);
    final children = [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        children: [
          for (final include in [true, false])
            RadioWithLabel<bool>(
              value: include,
              groupValue: includeGSSR,
              label: Text(include ? '${S.current.lucky_bag} ✓' : '${S.current.lucky_bag} ×'),
              onChanged: (v) {
                if (v != null) {
                  includeGSSR = v;
                }
                setState(() {});
              },
            ),
        ],
      ),
      if (summons.isEmpty) const ListTile(title: Text('No related summons')),
      for (final summon in summons) summonTile(context, summon)
    ];
    return ListView.separated(
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: children.length,
    );
  }

  Widget summonTile(BuildContext context, LimitedSummon summon) {
    final outdated = db.curUser.region != Region.jp && summon.isOutdated();
    String subtitle = 'JP: ${summon.startTime.jp?.sec2date().toDateString()}';
    final localDate = summon.startTime.ofRegion(db.curUser.region)?.sec2date().toDateString();
    if (db.curUser.region != Region.jp && localDate != null) {
      subtitle = '$subtitle / ${db.curUser.region.upper}: $localDate';
    }
    return ListTile(
      dense: true,
      title: Text.rich(
        TextSpan(children: [
          if (summon.hasSinglePickupSvt(widget.svt.collectionNo))
            TextSpan(text: kStarChar, style: TextStyle(color: Colors.yellow[800])),
          TextSpan(
            text: summon.lName.l,
            style: outdated ? TextStyle(color: Theme.of(context).textTheme.bodySmall?.color) : null,
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
