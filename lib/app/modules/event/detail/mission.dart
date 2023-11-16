import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/master_mission/solver/custom_mission.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../descriptors/cond_target_num.dart';
import '../../../descriptors/mission_conds.dart';
import '../../master_mission/solver/scheme.dart';

class EventMissionsPage extends StatefulWidget {
  final Event event;
  final List<EventMission> missions;
  final VoidCallback? onSwitchRegion;
  const EventMissionsPage({super.key, required this.event, required this.missions, this.onSwitchRegion});

  @override
  State<EventMissionsPage> createState() => _EventMissionsPageState();
}

class _EventMissionsPageState extends State<EventMissionsPage> {
  Set<EventMission> selected = {};

  @override
  Widget build(BuildContext context) {
    final missions = widget.missions.toList();
    missions.sort2((e) => e.dispNo);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final customMissions =
              (selected.toList()..sort2((e) => e.dispNo)).map((e) => CustomMission.fromEventMission(e));
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildHeader(context);
          }
          return missionBuilder(context, index - 1, missions);
        },
        separatorBuilder: (_, index) => index == 0 ? const Divider(height: 1) : const Divider(indent: 48, height: 1),
        itemCount: missions.length + 1,
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(children: [
      if (widget.onSwitchRegion != null)
        TextButton(onPressed: widget.onSwitchRegion, child: Text(S.current.switch_region)),
      SwitchListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        value: db.settings.display.describeEventMission,
        title: Text(S.current.describe_mission),
        onChanged: (v) {
          setState(() {
            db.settings.display.describeEventMission = v;
          });
        },
      )
    ]);
  }

  Widget missionBuilder(BuildContext context, int index, List<EventMission> missions) {
    EventMission mission = missions[index];
    final customMission = CustomMission.fromEventMission(mission);

    final clearConds = mission.conds.where((e) => e.missionProgressType == MissionProgressType.clear).toList();
    final clearCond = db.settings.display.describeEventMission && clearConds.length == 1 ? clearConds.single : null;

    return SimpleAccordion(
      key: Key('event_mission_${mission.id}'),
      headerBuilder: (context, _) => ListTile(
        leading: Text(mission.dispNo.toString(), textAlign: TextAlign.center),
        title: clearCond != null
            ? CondTargetNumDescriptor(
                condType: clearCond.condType,
                targetNum: clearCond.targetNum,
                targetIds: clearCond.targetIds,
                details: clearCond.details,
                missions: missions,
                eventId: widget.event.id,
                textScaleFactor: 0.8,
                unknownMsg: mission.name,
              )
            : Text(mission.name, textScaler: const TextScaler.linear(0.8)),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsetsDirectional.only(start: 16),
        minLeadingWidth: 32,
        trailing: customMission == null
            ? null
            : Checkbox(
                visualDensity: VisualDensity.compact,
                value: selected.contains(mission),
                onChanged: (v) {
                  selected.toggle(mission);
                  setState(() {});
                },
              ),
      ),
      contentBuilder: (context) {
        Widget child = MissionCondsDescriptor(
          mission: mission,
          missions: missions,
          eventId: widget.event.id,
        );
        if (clearCond != null) {
          child = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '~~~ ${S.current.mission} ~~~',
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(0.9),
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              Text(mission.name, textScaler: const TextScaler.linear(0.8)),
              const Divider(height: 8),
              child,
            ],
          );
        }
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 24, end: 16),
          child: child,
        );
      },
    );
  }
}
