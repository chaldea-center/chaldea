import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'solver/custom_mission.dart';
import 'solver/scheme.dart';

class MasterMissionListPage extends StatefulWidget {
  MasterMissionListPage({super.key});

  @override
  _MasterMissionListPageState createState() => _MasterMissionListPageState();
}

class _MasterMissionListPageState extends State<MasterMissionListPage> {
  final Map<Region, List<MstMasterMission>> _allRegionMissions = {};
  late Region _region;
  String? errorMsg;
  bool showOutdated = false;
  final typeOptions = FilterGroupData<MissionType?>();
  Set<int> selected = {};

  final _allMissionTypes = const <MissionType?>[
    MissionType.weekly,
    MissionType.limited,
    MissionType.daily,
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
    final missions = <int, MstMasterMission>{};
    final remoteMissions = await AtlasApi.masterMissions(region: region, expireAfter: force ? Duration.zero : null);
    if (remoteMissions == null || remoteMissions.isEmpty) {
      errorMsg = 'Nothing found';
    } else {
      if (region == Region.jp) {
        missions.addAll(db.gameData.masterMissions);
      }
      missions.addAll({for (final mm in remoteMissions) mm.id: mm});
      _allRegionMissions[region] = missions.values.toList();
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
    final allMissions = List.of(_allRegionMissions[_region] ?? <MasterMission>[]);
    final now = DateTime.now().timestamp;
    final curWeekly =
        allMissions.firstWhereOrNull((mm) => mm.type == MissionType.weekly && mm.startedAt <= now && mm.endedAt > now);
    final missions = allMissions.where((mission) {
      if (selected.contains(mission.id)) return true;
      if (!showOutdated) {
        if (mission.endedAt < now) return false;
        if (curWeekly != null &&
            mission.type == MissionType.weekly &&
            mission.startedAt > kNeverClosedTimestamp &&
            mission.id < curWeekly.id) {
          // skipped, won't use
          return false;
        }
        // legacy daily mm didn't update end time
        if (mission.type == MissionType.daily && mission is! MasterMission) return false;
      }
      return typeOptions.matchOne(_allMissionTypes.contains(mission.type) ? mission.type : null);
    }).toList();
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
                    style: TextStyle(color: SharedBuilder.appBarForeground(context)),
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
            icon: Icon(showOutdated ? Icons.timer_off_outlined : Icons.timer_outlined),
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
                : allMissions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        child: ListView.builder(
                          itemBuilder: (context, index) => _oneMasterMission(missions[index]),
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

  Widget buttonBar(List<MstMasterMission> mms) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      overflowButtonSpacing: 4,
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
          onPressed: () => solveMultiple(mms),
          child: Text(selected.isEmpty ? S.current.general_custom : S.current.drop_calc_solve),
        )
      ],
    );
  }

  Widget _oneMasterMission(MstMasterMission mm) {
    String title = 'ID ${mm.id}: ';
    if (mm is MasterMission) {
      title += '${mm.missions.length} ';
    }
    title += Transl.enums(mm.type, (enums) => enums.missionType).l;

    final now = DateTime.now().timestamp;
    return ListTile(
      key: Key('master_mission_${mm.id}'),
      title: Text(title, textScaler: const TextScaler.linear(0.9)),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(_showTime(mm.startedAt), textScaler: const TextScaler.linear(0.9)),
          ),
          const Text(' ~ '),
          Flexible(
            child: Text(_showTime(mm.endedAt), textScaler: const TextScaler.linear(0.9)),
          ),
        ],
      ),
      trailing: Checkbox(
        value: selected.contains(mm.id),
        onChanged: (v) {
          setState(() {
            selected.toggle(mm.id);
          });
        },
      ),
      selected: mm.startedAt <= now && mm.endedAt > now,
      onTap: () {
        mm.routeTo(region: _region);
      },
    );
  }

  String _showTime(int t) {
    return DateTime.fromMillisecondsSinceEpoch(t * 1000).toStringShort(omitSec: true);
  }

  Future<void> solveMultiple(List<MstMasterMission> mms) async {
    List<CustomMission> customMissions = [];
    final hasRaw = !mms.every((e) => e is MasterMission);
    if (hasRaw) EasyLoading.show();
    for (final mm in mms) {
      if (!selected.contains(mm.id)) continue;
      MasterMission? mm2;
      if (mm is MasterMission) {
        mm2 = mm;
      } else {
        mm2 = await AtlasApi.masterMission(mm.id, region: _region);
      }
      if (mm2 == null) continue;
      for (final m in mm2.missions) {
        final cm = CustomMission.fromEventMission(m);
        if (cm != null) customMissions.add(cm);
      }
    }
    if (hasRaw) EasyLoading.dismiss();
    router.push(child: CustomMissionPage(initMissions: customMissions));
  }
}
