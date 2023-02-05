import 'package:chaldea/app/modules/master_mission/solver/scheme.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class TraitEventTab extends StatelessWidget {
  final int id;
  const TraitEventTab(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Event> events = [];
    for (final event in db.gameData.events.values) {
      if (event.id == db.gameData.mappingData.eventTrait[id]?.eventId) {
        events.add(event);
        continue;
      }
      for (final mission in event.missions) {
        final cm = CustomMission.fromEventMission(mission);
        if (cm == null) continue;
        if (cm.conds.any((cond) =>
            const [CustomMissionType.trait, CustomMissionType.questTrait]
                .contains(cond.type) &&
            cond.targetIds.contains(id))) {
          events.add(event);
          break;
        }
      }
    }
    return ListView(
      children: [
        const SizedBox(height: 8),
        Text('${S.current.trait} $id', textAlign: TextAlign.center),
        Text(Transl.trait(id).l, textAlign: TextAlign.center),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(S.current.event_only_trait_hint),
          ),
        ),
        if (events.isNotEmpty)
          TileGroup(
            header: S.current.event,
            children: [
              for (final event in events)
                ListTile(
                  dense: true,
                  title: Text(event.lName.l.setMaxLines(1)),
                  trailing:
                      Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                  onTap: event.routeTo,
                )
            ],
          )
      ],
    );
  }
}
