import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../summon/gacha/mc_prob_edit.dart';
import 'base.dart';

class TimerGachaTab extends StatelessWidget {
  final Region region;
  final List<MstGacha> gachas;
  const TimerGachaTab({super.key, required this.region, required this.gachas});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().timestamp;
    final gachas = this.gachas.toList();
    gachas.sortByList((e) => [e.closedAt > now ? -1 : 1, (e.closedAt - now).abs()]);
    return ListView.separated(
      itemBuilder: (context, index) => TimerGachaItem(gachas[index], region).buildItem(context, expanded: true),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: gachas.length,
    );
  }
}

class TimerGachaItem with TimerItem {
  final MstGacha gacha;
  final Region region;
  TimerGachaItem(this.gacha, this.region);

  @override
  int get endedAt => gacha.closedAt;

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        enabled: gacha.closedAt > DateTime.now().timestamp,
        title: Text(gacha.name.setMaxLines(2)),
        subtitle: Text([fmtDate(gacha.openedAt), fmtDate(gacha.closedAt)].join(' ~ ')),
        trailing: CountDown(
          endedAt: gacha.closedAt.sec2date(),
          startedAt: gacha.openedAt.sec2date(),
          textAlign: TextAlign.end,
        ),
      ),
      contentBuilder: (context) {
        final htmlUrl = gacha.getHtmlUrl(region);
        List<Widget> children = [GachaBanner(region: region, imageId: gacha.imageId)];
        if ((region == Region.jp || region == Region.na) && htmlUrl != null) {
          final enabled = gacha.openedAt < DateTime.now().timestamp;
          children.add(Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: enabled ? () => launch(htmlUrl, external: false) : null,
                child: Text(S.current.open_in_browser),
              ),
              if (region == Region.jp)
                TextButton(
                  onPressed: enabled ? () => router.pushPage(MCGachaProbEditPage(gacha: gacha)) : null,
                  child: Text('${S.current.probability}/${S.current.simulator}'),
                )
            ],
          ));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}
