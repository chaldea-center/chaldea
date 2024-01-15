import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/descriptors/mission_conds.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerMissionTab extends StatelessWidget {
  final Region region;
  final List<MasterMission> mms;
  const TimerMissionTab({super.key, required this.region, required this.mms});

  @override
  Widget build(BuildContext context) {
    final mms = this.mms.toList();
    final now = DateTime.now().timestamp;
    mms.sortByList((e) => [e.closedAt > now ? -1 : 1, (e.closedAt - now).abs()]);
    return ListView.separated(
      itemBuilder: (context, index) =>
          TimerMissionItem(mms[index], region).buildItem(context, expanded: mms[index].missions.length <= 10),
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemCount: mms.length,
    );
  }
}

class TimerMissionItem with TimerItem {
  final MasterMission mm;
  final Region region;
  TimerMissionItem(this.mm, this.region);

  @override
  int get endedAt => mm.endedAt;

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    final type = mm.missions.firstOrNull?.type;
    Map<int, int> gifts = {};
    for (final mission in mm.missions) {
      for (final gift in mission.gifts) {
        if (gift.isStatItem) {
          gifts.addNum(gift.objectId, gift.num);
        }
      }
    }
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        leading: const FaIcon(FontAwesomeIcons.listCheck, size: 18),
        minLeadingWidth: 24,
        horizontalTitleGap: 8,
        enabled: mm.endedAt > DateTime.now().timestamp,
        title: Text([fmtDate(mm.startedAt), fmtDate(mm.endedAt)].join(' ~ ')),
        subtitle: Text.rich(TextSpan(
          // text: "No.${mm.id}, ",
          children: [
            TextSpan(text: '${mm.missions.length} '),
            if (type != null) TextSpan(text: Transl.enums(type, (enums) => enums.missionType).l),
            const TextSpan(text: ' '),
            for (final (itemId, count) in gifts.items)
              CenterWidgetSpan(
                child: GameCardMixin.anyCardItemBuilder(
                  context: context,
                  id: itemId,
                  text: count.toString(),
                  width: 24,
                ),
              )
          ],
        )),
        trailing: CountDown(
          endedAt: mm.endedAt.sec2date(),
          startedAt: mm.startedAt.sec2date(),
          textAlign: TextAlign.end,
        ),
      ),
      contentBuilder: (context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  mm.routeTo(region: region);
                },
                style: kTextButtonDenseStyle,
                child: Text('>>> ${S.current.details} >>>'),
              ),
              for (final mission in mm.missions) ...[
                const Divider(indent: 8, endIndent: 8, height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: MissionCondsDescriptor(
                    mission: mission,
                    missions: mm.missions,
                    onlyShowClear: true,
                  ),
                )
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
