import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_num.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/simple_accordion.dart';
import 'solver/custom_mission.dart';
import 'solver/scheme.dart';

class MasterMissionPage extends StatefulWidget {
  final MasterMission masterMission;

  MasterMissionPage({Key? key, required this.masterMission}) : super(key: key);

  @override
  _MasterMissionPageState createState() => _MasterMissionPageState();
}

class _MasterMissionPageState extends State<MasterMissionPage> {
  MasterMission get masterMission => widget.masterMission;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.master_mission + ' ${masterMission.id}'),
      ),
      body: Column(
        children: [
          Expanded(child: missionList()),
          kDefaultDivider,
          SafeArea(
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final customMissions = masterMission.missions
                        .map((e) => CustomMission.fromEventMission(e))
                        .whereType<CustomMission>()
                        .toList();
                    router.push(
                        child: CustomMissionPage(initMissions: customMissions));
                  },
                  icon: const Icon(Icons.search),
                  label: Text(S.current.drop_calc_solve),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget missionList() {
    masterMission.missions.sort2((e) => e.dispNo);
    Map<MissionType, int> categorized = {};
    for (final mission in masterMission.missions) {
      categorized.addNum(mission.type, 1);
    }
    return ListView(
      children: [
        ListTile(
          title: const Text('Start'),
          trailing: Text(masterMission.startedAt.toDateTimeString()),
        ),
        ListTile(
          title: const Text('End'),
          trailing: Text(masterMission.endedAt.toDateTimeString()),
        ),
        ListTile(
          title: const Text('Close'),
          trailing: Text(masterMission.closedAt.toDateTimeString()),
        ),
        ListTile(
          title: const Text('Missions'),
          trailing: Text(categorized.entries
              .map((e) => '${e.value} ${e.key.name}')
              .join('\n')),
        ),
        const Divider(thickness: 1),
        for (final mission in masterMission.missions) _oneEventMission(mission)
      ],
    );
  }

  Widget _oneEventMission(EventMission mission) {
    final customMission = CustomMission.fromEventMission(mission);
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        title: Text('${mission.dispNo}. ${mission.name}'),
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        trailing: customMission == null
            ? null
            : IconButton(
                onPressed: () {
                  router.push(
                      child: CustomMissionPage(initMissions: [customMission]));
                },
                icon: const Icon(Icons.search),
                color: Theme.of(context).colorScheme.secondary,
              ),
      ),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final cond in mission.conds) ...[
              Text(
                '${cond.missionProgressType.name} Condition: ${cond.conditionMessage == mission.name ? "" : cond.conditionMessage}',
                style: Theme.of(context).textTheme.caption,
              ),
              CondTargetNumDescriptor(
                condType: cond.condType,
                targetNum: cond.targetNum,
                targetIds: cond.targetIds,
                detail: cond.detail,
                missions: {for (final m in masterMission.missions) m.id: m},
              )
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
