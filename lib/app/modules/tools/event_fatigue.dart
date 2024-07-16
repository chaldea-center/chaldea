import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventFatigueListPage extends StatefulWidget {
  const EventFatigueListPage({super.key});

  @override
  State<EventFatigueListPage> createState() => _EventFatigueListPageState();
}

class _EventFatigueListPageState extends State<EventFatigueListPage>
    with RegionBasedState<List<MstEventSvtFatigue>, EventFatigueListPage> {
  List<MstEventSvtFatigue> get fatigues => data!;

  @override
  void initState() {
    super.initState();
    region = Region.jp;
    doFetchData();
  }

  @override
  Future<List<MstEventSvtFatigue>?> fetchData(Region? r, {Duration? expireAfter}) async {
    return AtlasApi.mstData(
        'mstEventSvtFatigue', (json) => (json as List).map((e) => MstEventSvtFatigue.fromJson(e)).toList(),
        region: r ?? Region.jp, expireAfter: expireAfter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fatigue Events"),
        actions: [
          dropdownRegion(),
          // popupMenu,
        ],
      ),
      body: buildBody(context),
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstEventSvtFatigue> fatigueList) {
    final fatigues = <int, List<MstEventSvtFatigue>>{};
    for (final fatigue in fatigueList) {
      fatigues.putIfAbsent(fatigue.eventId, () => []).add(fatigue);
    }
    final eventIds = fatigues.keys.toList();
    eventIds.sort2((e) => db.gameData.events[e]?.startedAt ?? e, reversed: true);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: eventIds.length,
      itemBuilder: (context, index) {
        final eventId = eventIds[index];
        return ListTile(
          title: Text(db.gameData.events[eventId]?.lName.l.setMaxLines(1) ?? 'Event $eventId'),
          subtitle: Text('No.$eventId'),
          trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
          onTap: () {
            router.pushPage(_EventSvtFatigueDetailPage(fatigues: fatigues[eventId]!, region: region ?? Region.jp));
          },
        );
      },
    );
  }
}

class _EventSvtFatigueDetailPage extends StatelessWidget {
  final List<MstEventSvtFatigue> fatigues;
  final Region region;
  const _EventSvtFatigueDetailPage({required this.fatigues, required this.region});

  @override
  Widget build(BuildContext context) {
    // key: priority-duration-releaseId
    final eventId = fatigues.first.eventId;
    final groups = <(int, int, int), List<MstEventSvtFatigue>>{};
    for (final fatigue in fatigues) {
      groups.putIfAbsent((fatigue.priority, fatigue.fatigueTime, fatigue.commonReleaseId), () => []).add(fatigue);
    }
    final keys = groups.keys.toList();
    keys.sortByList((e) => [-e.$1, e.$2, -e.$3]);
    return Scaffold(
      appBar: AppBar(
        title: Text('Fatigues: ${db.gameData.events[eventId]?.lShortName.l.setMaxLines(1) ?? eventId}'),
        actions: [
          IconButton(
            onPressed: () {
              router.push(url: Routes.eventI(eventId));
            },
            icon: const Icon(Icons.flag),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final (priority, time, releaseId) = keys[index];
          final group = groups[keys[index]]!..sort((a, b) => SvtFilterData.compareId(a.svtId, b.svtId));

          List<Widget> children = [
            ListTile(
              dense: true,
              title: Text('Fatigue Time: ${getDuration(time)}'),
              trailing: releaseId == 0
                  ? null
                  : TextButton(
                      onPressed: () {
                        router.push(url: Routes.commonReleaseI(releaseId));
                      },
                      child: Text('${S.current.condition} $releaseId'),
                    ),
            ),
            const Divider(indent: 16, endIndent: 16),
            if (group.any((e) => e.svtId == 0))
              ListTile(
                title: Text('${S.current.general_all} ${S.current.servant}'),
              ),
          ];
          group.removeWhere((e) => e.svtId == 0);
          if (group.isNotEmpty) {
            children.add(GridView.extent(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              maxCrossAxisExtent: 48,
              childAspectRatio: 132 / 144,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: group.map((fatigue) {
                return db.gameData.servantsById[fatigue.svtId]?.iconBuilder(context: context) ??
                    AutoSizeText('${fatigue.svtId}');
              }).toList(),
            ));
          }

          return TileGroup(
            header: '${S.current.priority} $priority',
            children: [
              ...children,
            ],
          );
        },
        itemCount: keys.length,
      ),
    );
  }

  String getDuration(int t) {
    final duration = Duration(seconds: t);
    final hours = duration.inHours, minutes = duration.inMinutes % 60, seconds = duration.inSeconds % 60;
    String timeText = '${hours}h';
    if (minutes != 0 || seconds != 0) {
      timeText += '${minutes}m';
      if (seconds != 0) {
        timeText += '${seconds}s';
      }
    }
    return timeText;
  }
}
