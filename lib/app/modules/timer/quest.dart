import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'base.dart';

class TimerQuestItem with TimerItem {
  final List<Quest> quests;
  final Region region;
  TimerQuestItem(this.quests, this.region);

  static List<TimerQuestItem> group(Iterable<Quest> _quests, Region region) {
    Map<String, List<Quest>> groups = {};
    final quests = _quests.toList();
    if (quests.isEmpty) {
      final now = DateTime.now().timestamp;
      final chaldeaGate = db.gameData.wars[WarId.chaldeaGate];
      if (chaldeaGate != null) {
        quests.addAll(
          chaldeaGate.quests.where((e) => e.openedAt > now - 180 * kSecsPerDay && e.closedAt < now + 60 * kSecsPerDay),
        );
      }
    }
    quests.sortByList((e) => [e.closedAt, e.openedAt, e.id]);
    for (final quest in quests) {
      groups.putIfAbsent([quest.type, quest.id ~/ 100, quest.closedAt].join('-'), () => []).add(quest);
    }
    for (final group in groups.values) {
      group.sortByList((e) => [e.openedAt, e.priority]);
    }
    return groups.values.map((e) => TimerQuestItem(e, region)).toList();
  }

  @override
  int get startedAt => quests.first.openedAt;
  @override
  int get endedAt => quests.last.closedAt;

  @override
  Widget buildItem(BuildContext context, {bool expanded = false}) {
    final quests = this.quests.toList();
    quests.sortByList((e) => [e.priority, e.id]);
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, _) {
        final now = DateTime.now().timestamp;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: const Icon(Icons.flag, size: 24),
          minLeadingWidth: 24,
          horizontalTitleGap: 8,
          title: Text([fmtDate(startedAt), fmtDate(endedAt)].join(" ~ ")),
          subtitle: Text('${quests.length} ${S.current.quest}'),
          trailing: CountDown(endedAt: endedAt.sec2date(), startedAt: startedAt.sec2date(), textAlign: TextAlign.end),
          enabled: endedAt > now,
        );
      },
      contentBuilder: (context) {
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: divideTiles([
                for (final quest in quests)
                  ListTile(
                    dense: true,
                    title: Text(quest.lName.l, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      'AP${quest.consume} Lv.${quest.recommendLv} ${fmtDate(quest.openedAt)}~${fmtDate(quest.closedAt)}',
                    ),
                    onTap: () {
                      quest.routeTo(region: region);
                    },
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
