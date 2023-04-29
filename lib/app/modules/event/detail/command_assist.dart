import 'package:chaldea/app/descriptors/skill_descriptor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/misc.dart';

class EventCommandAssistPage extends HookWidget {
  final Event event;
  const EventCommandAssistPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    Map<int, List<EventCommandAssist>> grouped = {};
    for (final assist in event.commandAssists) {
      grouped.putIfAbsent(assist.id, () => []).add(assist);
    }
    final keys = grouped.keys.toList()..sort();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => itemBuilder(context, grouped[keys[index]]!),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: keys.length,
    );
  }

  Widget itemBuilder(BuildContext context, List<EventCommandAssist> assists) {
    final assist = assists.last;
    return SimpleAccordion(
      expanded: true,
      headerBuilder: (context, _) {
        String name = assist.name;
        final match = RegExp(r'^コマンドサポート「(.*)」$').firstMatch(assist.name);
        if (match != null) {
          name = '${S.current.command_assist}「${Transl.svtNames(match.group(1)!).l}」';
        }
        return ListTile(
          dense: true,
          horizontalTitleGap: 8,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          leading: db.getIconImage(assist.image, width: 36),
          // title: Text(Transl.misc2('CommandAssistName', assist.name)),
          title: Text(name),
          trailing: CommandCardWidget(card: assist.assistCard, width: 36),
        );
      },
      contentBuilder: (context) {
        return SkillDescriptor(skill: assist.skill);
      },
    );
  }
}
