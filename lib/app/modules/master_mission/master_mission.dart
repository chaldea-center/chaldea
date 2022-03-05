import 'package:chaldea/app/modules/descriptors/cond_target_num.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/widgets/simple_accordion.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

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
    masterMission.missions.sort2((e) => e.dispNo);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.master_mission + ' ${masterMission.id}'),
      ),
      body: ListView(
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
          for (final mission in masterMission.missions)
            _oneEventMission(mission)
        ],
      ),
    );
  }

  Widget _oneEventMission(EventMission mission) {
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        title: Text('${mission.dispNo} ${mission.name}'),
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
