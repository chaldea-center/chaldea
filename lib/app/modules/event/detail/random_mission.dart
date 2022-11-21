import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/custom_mission.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../descriptors/mission_conds.dart';
import '../../master_mission/solver/scheme.dart';

class EventRandomMissionsPage extends StatefulWidget {
  final Event event;
  const EventRandomMissionsPage({super.key, required this.event});

  @override
  State<EventRandomMissionsPage> createState() =>
      _EventRandomMissionsPageState();
}

class _EventRandomMissionsPageState extends State<EventRandomMissionsPage> {
  Set<EventRandomMission> selected = {};
  Event get event => widget.event;
  Map<int, EventMission> allMissions = {};
  @override
  void initState() {
    super.initState();
    allMissions = {for (final m in event.missions) m.id: m};
  }

  @override
  Widget build(BuildContext context) {
    Map<int, List<EventRandomMission>> groups = {};
    for (final mission in widget.event.randomMissions) {
      groups.putIfAbsent(mission.condNum, () => []).add(mission);
    }
    final ranks = groups.keys.toList()..sort();

    return DefaultTabController(
      length: ranks.length,
      child: Column(
        children: [
          FixedHeight.tabBar(Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(' ${S.current.detective_rank}: '),
              Expanded(
                  child: TabBar(
                isScrollable: true,
                tabs: [
                  for (final rank in ranks)
                    Tab(
                      child: Text.rich(
                        TextSpan(children: [
                          CenterWidgetSpan(child: rankIcon(rank, width: 24)),
                          TextSpan(text: ' ${rankText(rank)}')
                        ]),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                ],
              )),
            ],
          )),
          Expanded(
            child: TabBarView(children: [
              for (final rank in ranks) oneRankGroup(rank, groups[rank]!)
            ]),
          )
        ],
      ),
    );
  }

  Widget oneRankGroup(int rank, List<EventRandomMission> missions) {
    return Scaffold(
      floatingActionButton: getFAB(rank),
      body: ListView.separated(
        itemBuilder: (context, index) =>
            missionBuilder(context, missions[index]),
        separatorBuilder: (_, __) => const Divider(indent: 48, height: 1),
        itemCount: missions.length,
      ),
    );
  }

  Widget missionBuilder(
      BuildContext context, EventRandomMission randomMission) {
    final mission = allMissions[randomMission.missionId];
    final customMission = CustomMission.fromEventMission(mission);
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        leading: Text.rich(
          TextSpan(children: [
            CenterWidgetSpan(
                child: rankIcon(randomMission.missionRank, width: 24)),
            TextSpan(text: ' ${mission?.dispNo}')
          ]),
          textAlign: TextAlign.center,
        ),
        title: Text(mission?.name ?? randomMission.missionId.toString(),
            textScaleFactor: 0.75),
        horizontalTitleGap: 8,
        minLeadingWidth: 24,
        contentPadding: const EdgeInsetsDirectional.only(start: 8),
        trailing: customMission == null
            ? null
            : Checkbox(
                visualDensity: VisualDensity.compact,
                value: selected.contains(randomMission),
                onChanged: (v) {
                  selected.toggle(randomMission);
                  setState(() {});
                },
              ),
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
        child: mission == null
            ? Text('Mission ${randomMission.missionId} Not Found')
            : MissionCondsDescriptor(
                mission: mission, missions: widget.event.missions),
      ),
    );
  }

  Widget getFAB(int rank) {
    return FloatingActionButton(
      onPressed: () {
        final randomMissions =
            selected.where((e) => e.condNum == rank).toList();
        randomMissions
            .sort2((e) => allMissions[e.missionId]?.dispNo ?? e.missionId);

        final customMissions = [
          for (final m in randomMissions)
            if (allMissions.containsKey(m.missionId)) allMissions[m.missionId]!
        ];

        int? warId;
        for (final int id in widget.event.warIds) {
          final war = db.gameData.wars[id];
          if (war == null) continue;
          if (war.quests.any((quest) => quest.isAnyFree)) {
            warId = id;
            break;
          }
        }
        router.push(
          child: CustomMissionPage(
            initMissions: customMissions.whereType<CustomMission>().toList(),
            initWarId: warId,
          ),
        );
      },
      child: Text(selected.where((e) => e.condNum == rank).length.toString()),
    );
  }

  Widget rankIcon(int rank, {double? width}) {
    final rankStr = (rank + 1).toString().padLeft(2, '0');
    final url =
        'https://static.atlasacademy.io/JP/EventReward/mission_board_rank_${widget.event.id}$rankStr.png';
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        //R G  B  A  Const
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 3, 0,
      ]),
      child: CachedImage(imageUrl: url, width: width),
    );
  }

  String rankText(int rank) {
    return ['E', 'D', 'C', 'B', 'A', 'EX'].getOrNull(rank) ?? rank.toString();
  }
}
