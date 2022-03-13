import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/material.dart';

import 'master_mission.dart';

class MasterMissionListPage extends StatefulWidget {
  MasterMissionListPage({Key? key}) : super(key: key);

  @override
  _MasterMissionListPageState createState() => _MasterMissionListPageState();
}

class _MasterMissionListPageState extends State<MasterMissionListPage> {
  final Map<Region, List<MasterMission>> _allRegionMissions = {};
  late Region _region;
  String? errorMsg;
  bool showOutdated = false;

  void _resolveMissions(Region region) async {
    errorMsg = null;
    final missions = await AtlasApi.masterMissions(region: region);
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
    _region = db2.curUser.region;
    _resolveMissions(_region);
  }

  @override
  Widget build(BuildContext context) {
    final missions = List.of(_allRegionMissions[_region] ?? <MasterMission>[]);
    if (!showOutdated) {
      final now = DateTime.now().timestamp;
      missions.removeWhere((e) => e.endedAt < now);
    }
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
            items: Region.values
                .map((region) => DropdownMenuItem(
                    value: region, child: Text(region.toUpper())))
                .toList(),
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
            tooltip: 'Outdated',
            icon: Icon(showOutdated ? Icons.timer_off : Icons.timer),
          )
        ],
      ),
      body: errorMsg != null
          ? Center(child: Text(errorMsg!))
          : missions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('Custom Missions'),
                        onTap: () {},
                      );
                    }
                    return _oneMasterMission(missions[index - 1]);
                  },
                  itemCount: missions.length + 1,
                ),
    );
  }

  Widget _oneMasterMission(MasterMission masterMission) {
    Map<MissionType, int> categorized = {};
    for (final mission in masterMission.missions) {
      categorized.addNum(mission.type, 1);
    }
    String subtitle = 'ID ${masterMission.id}: ';
    categorized.forEach((key, value) {
      subtitle += ' $value ${key.name}';
    });
    final now = DateTime.now().timestamp;
    return ListTile(
      key: Key('master_mission_${masterMission.id}'),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Text(_showTime(masterMission.startedAt))),
          const Text(' ~ '),
          Flexible(child: Text(_showTime(masterMission.endedAt))),
        ],
      ),
      subtitle: Text(subtitle),
      selected: masterMission.startedAt <= now && masterMission.endedAt > now,
      onTap: () {
        router.push(
          child: MasterMissionPage(masterMission: masterMission),
          detail: true,
        );
      },
    );
  }

  String _showTime(int t) {
    return DateTime.fromMillisecondsSinceEpoch(t * 1000).toStringShort();
  }
}
