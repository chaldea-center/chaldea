import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerGachaItem with TimerItem {
  final NiceGacha gacha;
  final Region region;
  TimerGachaItem(this.gacha, this.region);

  @override
  int get startedAt => gacha.openedAt;
  @override
  int get endedAt => gacha.closedAt;

  static List<TimerGachaItem> group(Iterable<NiceGacha> gachas, Region region) {
    return [for (final gacha in gachas) TimerGachaItem(gacha, region)];
  }

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        enabled: gacha.closedAt > DateTime.now().timestamp,
        title: Text(gacha.lName.setMaxLines(2)),
        subtitle: Text.rich(
          TextSpan(
            text: '${fmtDate(gacha.openedAt)} ~ ${fmtDate(gacha.closedAt)} ',
            children: [
              for (final svtId in gacha.featuredSvtIds..sort(SvtFilterData.compareId))
                CenterWidgetSpan(
                  child: db.gameData.servantsById[svtId]?.iconBuilder(context: context, width: 28) ?? Text('$svtId'),
                ),
            ],
          ),
        ),
        trailing: CountDown(
          endedAt: gacha.closedAt.sec2date(),
          startedAt: gacha.openedAt.sec2date(),
          textAlign: TextAlign.end,
        ),
      ),
      contentBuilder: (context) {
        List<Widget> children = [
          GachaBanner(region: region, imageId: gacha.imageId),
          TextButton(
            onPressed: () => gacha.routeTo(region: region),
            child: Text(S.current.details),
          ),
        ];
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}
