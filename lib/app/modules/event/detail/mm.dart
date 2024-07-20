import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventRelatedMMPage extends HookWidget {
  final Event event;
  final List<MstMasterMission> mms;
  const EventRelatedMMPage({super.key, required this.event, required this.mms});

  @override
  Widget build(BuildContext context) {
    final mms = this.mms.toList();
    mms.sort2((e) => e.startedAt);

    String hint = 'Guessed Related Master Mission from start/end time.';
    final eventJp = db.gameData.events[event.id];
    if (eventJp != null) {
      hint += '\nJP event: ';
      hint += [eventJp.startedAt, eventJp.endedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ ');
    }
    final children = [
      SHeader(hint),
      for (final mm in mms) itemBuilder(context, mm),
    ];
    return ListView.separated(
      controller: useScrollController(),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget itemBuilder(BuildContext context, MstMasterMission mm) {
    return ListTile(
      dense: true,
      title: Text([if (mm.missionIconDetailText != null) mm.missionIconDetailText, 'ID ${mm.id}'].join('\n')),
      subtitle: Text([mm.startedAt, mm.endedAt].map((e) => e.sec2date().toDateString()).join(' ~ ')),
      trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
      onTap: mm.routeTo,
    );
  }
}
