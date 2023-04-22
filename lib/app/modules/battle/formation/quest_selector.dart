import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FQSelectDropdown extends StatefulWidget {
  final int? initQuestId;
  final ValueChanged<Quest> onChanged;

  const FQSelectDropdown({super.key, this.initQuestId, required this.onChanged});

  @override
  State<FQSelectDropdown> createState() => _FQSelectDropdownState();
}

class _FQSelectDropdownState extends State<FQSelectDropdown> {
  int? warId = 308;
  Quest? quest;
  Map<int, NiceWar> wars = {};

  @override
  void initState() {
    super.initState();
    quest = db.gameData.quests[widget.initQuestId];
    warId = quest?.warId ?? warId;
    final warList = db.gameData.wars.values.where((e) => e.quests.any((q) => q.isAnyFree)).toList();
    warList.sort2((e) => e.id < 1000 ? 1000 - e.id : kNeverClosedTimestamp - (e.event?.startedAt ?? e.id));
    wars = {for (final war in warList) war.id: war};
    if (wars[warId] == null) {
      warId = wars.keys.firstOrNull;
      quest = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      // alignment: WrapAlignment.center,
      // spacing: 8,
      children: [
        const SizedBox(width: 16),
        const Text('③ '),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: warBtn(),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: questBtn(),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget warBtn() {
    return DropdownButton<int>(
      // isDense: true,
      isExpanded: true,
      value: warId,
      hint: Text(S.current.war, style: const TextStyle(fontSize: 14)),
      items: [
        for (final war in wars.values)
          DropdownMenuItem(
            value: war.id,
            child: Text(
              (war.id < 1000 ? war.lShortName : war.event?.lShortName.l ?? war.lShortName).setMaxLines(1).breakWord,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )
      ],
      onChanged: (v) {
        setState(() {
          warId = v;
        });
      },
    );
  }

  Widget questBtn() {
    final quests = wars[warId]?.quests.where((q) => q.isAnyFree && q.phases.isNotEmpty).toList() ?? [];
    if (!quests.contains(quest)) quest = null;
    return DropdownButton<Quest>(
      // isDense: true,
      isExpanded: true,
      value: quest,
      hint: Text(S.current.quest, style: const TextStyle(fontSize: 14)),
      items: [
        for (final quest in quests)
          DropdownMenuItem(
            value: quest,
            child: Text(
              quest.lDispName.setMaxLines(1).breakWord,
              maxLines: 1,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          )
      ],
      onChanged: (v) {
        setState(() {
          quest = v;
          if (v != null) widget.onChanged(v);
        });
      },
    );
  }
}
