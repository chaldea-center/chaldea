import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/custom_mission.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chaldea/models/models.dart';

import '../../../descriptors/cond_target_num.dart';
import '../../master_mission/solver/scheme.dart';

class EventMissionsPage extends StatefulWidget {
  final Event event;
  const EventMissionsPage({Key? key, required this.event}) : super(key: key);

  @override
  State<EventMissionsPage> createState() => _EventMissionsPageState();
}

class _EventMissionsPageState extends State<EventMissionsPage> {
  Set<EventMission> selected = {};
  @override
  Widget build(BuildContext context) {
    final missions = widget.event.missions.toList();
    missions.sort2((e) => e.dispNo);
    return Scaffold(
      appBar: AppBar(title: const Text('Event Missions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final customMissions = (selected.toList()..sort2((e) => e.dispNo))
              .map((e) => CustomMission.fromEventMission(e));
          int? warId;
          for (final int id in widget.event.warIds) {
            final war = db2.gameData.wars[id];
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
        child: Text(selected.length.toString()),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) =>
            missionBuilder(context, index, missions),
        separatorBuilder: (_, __) => const Divider(indent: 48, height: 1),
        itemCount: widget.event.missions.length,
      ),
    );
  }

  Widget missionBuilder(
      BuildContext context, int index, List<EventMission> missions) {
    EventMission mission = missions[index];
    final customMission = CustomMission.fromEventMission(mission);
    return SimpleAccordion(
      key: Key('event_mission_${mission.id}'),
      headerBuilder: (context, _) => ListTile(
        leading: Text(mission.dispNo.toString(), textAlign: TextAlign.center),
        title: Text(mission.name),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        trailing: customMission == null
            ? null
            : Checkbox(
                value: selected.contains(mission),
                onChanged: (v) {
                  selected.toggle(mission);
                  setState(() {});
                },
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
                '# ${cond.missionProgressType.name} Condition: ${[
                  mission.name,
                  "???"
                ].contains(cond.conditionMessage) ? "" : cond.conditionMessage}',
                style: Theme.of(context).textTheme.caption,
              ),
              CondTargetNumDescriptor(
                condType: cond.condType,
                targetNum: cond.targetNum,
                targetIds: cond.targetIds,
                detail: cond.detail,
                missions: {for (final m in missions) m.id: m},
              )
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
