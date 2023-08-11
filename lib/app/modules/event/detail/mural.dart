import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class EventMuralPage extends HookWidget {
  final Event event;
  const EventMuralPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final murals = event.murals.toList();
    if (murals.isEmpty) return const SizedBox();
    return ListView.separated(
      controller: useScrollController(),
      itemBuilder: (context, index) => itemBuilder(context, murals[index]),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: murals.length,
    );
  }

  Widget itemBuilder(BuildContext context, EventMural mural) {
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          title: Text(mural.message),
          subtitle: Text('No.${mural.id}  ${mural.num}'),
        );
      },
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mural.condQuestId != 0)
              CondTargetValueDescriptor(
                condType: CondType.questClearPhase,
                target: mural.condQuestId,
                value: mural.condQuestPhase,
              ),
          ],
        );
      },
    );
  }
}
