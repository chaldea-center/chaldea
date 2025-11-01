import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/descriptors/mission_conds.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerMissionItem with TimerItem {
  final MasterMission mm;
  final Region region;
  TimerMissionItem(this.mm, this.region);

  @override
  int get startedAt => mm.startedAt;
  @override
  int get endedAt => mm.endedAt;

  @override
  bool get defaultExpanded => mm.missions.length <= 10;

  static List<TimerMissionItem> group(Iterable<MasterMission> mms, Region region) {
    return [for (final mm in mms) TimerMissionItem(mm, region)];
  }

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
      expanded: type == MissionType.extra ? false : expanded,
      headerBuilder: (context, _) => ListTile(
        dense: true,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        leading: const FaIcon(FontAwesomeIcons.listCheck, size: 18),
        minLeadingWidth: 24,
        horizontalTitleGap: 8,
        enabled: mm.endedAt > DateTime.now().timestamp,
        title: Text(
          [
            ?mm.lMissionIconDetailText,
            [fmtDate(mm.startedAt), fmtDate(mm.endedAt)].join(' ~ '),
          ].join('\n'),
        ),
        subtitle: Text.rich(
          TextSpan(
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
                ),
            ],
          ),
        ),
        trailing: CountDown(
          endedAt: mm.endedAt.sec2date(),
          startedAt: mm.startedAt.sec2date(),
          textAlign: TextAlign.end,
        ),
      ),
      contentBuilder: (context) {
        final missions = mm.missions.toList();
        missions.sort2((e) => e.dispNo);
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
              for (final mission in missions) ...[
                const Divider(indent: 8, endIndent: 8, height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: MissionCondsDescriptor(mission: mission, missions: missions, onlyShowClear: true),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
