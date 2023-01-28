import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'master_mission.dart';
import 'solver/custom_mission.dart';
import 'solver/scheme.dart';

class MasterMissionListPage extends StatefulWidget {
  MasterMissionListPage({super.key});

  @override
  _MasterMissionListPageState createState() => _MasterMissionListPageState();
}

class _MasterMissionListPageState extends State<MasterMissionListPage> {
  final Map<Region, List<MasterMission>> _allRegionMissions = {};
  late Region _region;
  String? errorMsg;
  bool showOutdated = false;
  final typeOptions = FilterGroupData<MissionType?>();
  Set<int> selected = {};

  final _allMissionTypes = const <MissionType?>[
    MissionType.weekly,
    MissionType.limited,
    null,
  ];

  Future<void> _resolveMissions(Region region, {bool force = false}) async {
    errorMsg = null;
    _allRegionMissions.remove(region);
    if (mounted) {
      setState(() {
        selected.clear();
      });
    }
    final missions = await AtlasApi.masterMissions(
        region: region, expireAfter: force ? Duration.zero : null);
    if (missions == null || missions.isEmpty) {
      errorMsg = 'Nothing found';
    } else {
      _allRegionMissions[region] = missions;
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _region = db.curUser.region;
    _resolveMissions(_region);
  }

  @override
  Widget build(BuildContext context) {
    final missions = List.of(_allRegionMissions[_region] ?? <MasterMission>[]);
    missions.retainWhere((mission) {
      if (selected.contains(mission.id)) return true;
      if (!showOutdated) {
        if (mission.endedAt < DateTime.now().timestamp) return false;
      }
      return typeOptions.matchAny(mission.missions
          .map((e) => _allMissionTypes.contains(e.type) ? e.type : null));
    });
    missions.sort((a, b) {
      if (a.startedAt == b.startedAt) return a.id.compareTo(b.id);
      return a.startedAt.compareTo(b.startedAt);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.master_mission),
        actions: [
          DropdownButton<Region>(
            value: _region,
            items: [
              for (final region in Region.values)
                DropdownMenuItem(
                  value: region,
                  child: Text(region.localName),
                ),
            ],
            icon: Icon(
              Icons.arrow_drop_down,
              color: SharedBuilder.appBarForeground(context),
            ),
            selectedItemBuilder: (context) => [
              for (final region in Region.values)
                DropdownMenuItem(
                  child: Text(
                    region.localName,
                    style: TextStyle(
                        color: SharedBuilder.appBarForeground(context)),
                  ),
                )
            ],
            onChanged: (v) {
              setState(() {
                if (v != null) {
                  _region = v;
                  _resolveMissions(v);
                }
              });
            },
            underline: const SizedBox(),
          ),
          IconButton(
            onPressed: () {
              setState(() {});
              showOutdated = !showOutdated;
            },
            tooltip: S.current.outdated,
            icon: Icon(
                showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
          ),
          IconButton(
            onPressed: () {
              _resolveMissions(_region, force: true);
            },
            tooltip: S.current.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: errorMsg != null
                ? Center(
                    child: RefreshButton(
                      text: errorMsg,
                      onPressed: () {
                        _resolveMissions(_region, force: true);
                      },
                    ),
                  )
                : missions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return _oneMasterMission(missions[index]);
                          },
                          itemCount: missions.length,
                        ),
                        onRefresh: () => _resolveMissions(_region, force: true),
                      ),
          ),
          SafeArea(child: buttonBar(missions))
        ],
      ),
    );
  }

  Widget buttonBar(List<MasterMission> mms) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<MissionType?>(
          options: _allMissionTypes,
          values: typeOptions,
          combined: true,
          optionBuilder: (v) {
            if (v == null) return Text(S.current.general_others);
            return Text(Transl.enums(v, (enums) => enums.missionType).l);
          },
          onFilterChanged: (v, _) {
            setState(() {});
          },
        ),
        ElevatedButton(
          onPressed: () {
            List<CustomMission> customMissions = [];
            for (final mm in mms) {
              if (!selected.contains(mm.id)) continue;
              for (final m in mm.missions) {
                final cm = CustomMission.fromEventMission(m);
                if (cm != null) customMissions.add(cm);
              }
            }
            router.push(child: CustomMissionPage(initMissions: customMissions));
          },
          child: Text(selected.isEmpty
              ? S.current.custom_mission
              : S.current.drop_calc_solve),
        )
      ],
    );
  }

  Widget _oneMasterMission(MasterMission masterMission) {
    Map<MissionType, int> categorized = {};
    for (final mission in masterMission.missions) {
      categorized.addNum(mission.type, 1);
    }
    String subtitle = 'ID ${masterMission.id}: ';
    categorized.forEach((key, value) {
      subtitle +=
          ' $value ${Transl.enums(key, (enums) => enums.missionType).l}';
    });
    final now = DateTime.now().timestamp;
    return ListTile(
      key: Key('master_mission_${masterMission.id}'),
      title: Text(subtitle, textScaleFactor: 0.9),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child:
                Text(_showTime(masterMission.startedAt), textScaleFactor: 0.9),
          ),
          const Text(' ~ '),
          Flexible(
            child: Text(_showTime(masterMission.endedAt), textScaleFactor: 0.9),
          ),
        ],
      ),
      trailing: Checkbox(
        value: selected.contains(masterMission.id),
        onChanged: (v) {
          setState(() {
            selected.toggle(masterMission.id);
          });
        },
      ),
      selected: showOutdated &&
          masterMission.startedAt <= now &&
          masterMission.endedAt > now,
      onTap: () {
        router.push(
          child:
              MasterMissionPage(masterMission: masterMission, region: _region),
          detail: true,
        );
      },
    );
  }

  String _showTime(int t) {
    return DateTime.fromMillisecondsSinceEpoch(t * 1000)
        .toStringShort(omitSec: true);
  }
}
