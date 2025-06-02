import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerGachaTab extends StatelessWidget {
  final Region region;
  final List<NiceGacha> gachas;
  final TimerFilterData filterData;
  const TimerGachaTab({super.key, required this.region, required this.gachas, required this.filterData});

  @override
  Widget build(BuildContext context) {
    final groups = filterData.getSorted(gachas.map((e) => TimerGachaItem(e, region)).toList());
    return ListView.separated(
      itemBuilder: (context, index) => groups[index].buildItem(context, expanded: true),
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemCount: groups.length,
    );
  }
}

class TimerGachaItem with TimerItem {
  final NiceGacha gacha;
  final Region region;
  TimerGachaItem(this.gacha, this.region);

  @override
  int get startedAt => gacha.openedAt;
  @override
  int get endedAt => gacha.closedAt;

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder:
          (context, _) => ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.only(start: 16),
            enabled: gacha.closedAt > DateTime.now().timestamp,
            title: Text(gacha.lName.setMaxLines(2)),
            subtitle: Text([fmtDate(gacha.openedAt), fmtDate(gacha.closedAt)].join(' ~ ')),
            trailing: CountDown(
              endedAt: gacha.closedAt.sec2date(),
              startedAt: gacha.openedAt.sec2date(),
              textAlign: TextAlign.end,
            ),
          ),
      contentBuilder: (context) {
        List<Widget> children = [
          GachaBanner(region: region, imageId: gacha.imageId),
          TextButton(onPressed: () => gacha.routeTo(region: region), child: Text(S.current.details)),
        ];
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}
