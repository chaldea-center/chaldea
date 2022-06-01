import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/custom_mission.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../descriptors/mission_conds.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final customMissions = (selected.toList()..sort2((e) => e.dispNo))
              .map((e) => CustomMission.fromEventMission(e));
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
        child: Text(selected.length.toString()),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Menu - ${S.current.switch_region}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            );
          }
          return missionBuilder(context, index - 1, missions);
        },
        separatorBuilder: (_, __) => const Divider(indent: 48, height: 1),
        itemCount: widget.event.missions.length + 1,
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
        padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
        child: MissionCondsDescriptor(mission: mission, missions: missions),
      ),
    );
  }
}
