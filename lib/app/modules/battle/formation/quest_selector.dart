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

class _OptionData {
  int id;
  NiceWar? war;
  Event? event;
  List<Quest> quests;
  _OptionData({
    required this.id,
    required this.war,
    required this.event,
    required this.quests,
  });
}

class _FQSelectDropdownState extends State<FQSelectDropdown> {
  int? eventWarId = 308;
  Quest? quest;
  Map<int, _OptionData> options = {};

  bool shouldShow(Quest quest) {
    if (quest.isLaplaceSharable) return true;
    if (quest.warId == WarId.daily) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    final optionList = <_OptionData>[];
    for (final war in db.gameData.wars.values) {
      if (war.isMainStory || war.id == WarId.daily) {
        final quests = war.quests.where(shouldShow).toList();
        if (quests.isNotEmpty) {
          optionList.add(_OptionData(id: war.id, war: war, event: null, quests: quests));
        }
      }
    }
    for (final event in db.gameData.events.values) {
      List<Quest> quests = [];
      if (event.extra.huntingQuestIds.isNotEmpty) {
        quests.addAll([
          for (final questId in event.extra.huntingQuestIds)
            if (db.gameData.quests.containsKey(questId)) db.gameData.quests[questId]!,
        ]);
      }
      for (final warId in event.warIds) {
        final war = db.gameData.wars[warId];
        if (warId < 1000 || war == null) continue;
        quests.addAll(war.quests.where(shouldShow));
      }
      if (quests.isNotEmpty) {
        optionList.add(_OptionData(id: event.id, war: null, event: event, quests: quests));
      }
    }

    optionList.sortByList((e) => <int>[
          e.war != null ? 0 : 1,
          e.war != null ? -e.id : -(e.event?.startedAt ?? e.id),
        ]);

    final initQuest = db.gameData.quests[widget.initQuestId];
    final option = optionList.firstWhereOrNull((option) => option.quests.contains(initQuest));
    if (option != null) {
      eventWarId = option.id;
      quest = initQuest;
    } else {
      eventWarId = optionList.firstOrNull?.id;
    }
    options = {for (final option in optionList) option.id: option};
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
        const Text('① '),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: eventWarBtn(),
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

  Widget eventWarBtn() {
    return DropdownButton<int>(
      // isDense: true,
      isExpanded: true,
      value: eventWarId,
      hint: Text('${S.current.event}/${S.current.war}', style: const TextStyle(fontSize: 14)),
      items: [
        for (final option in options.values)
          DropdownMenuItem(
            value: option.id,
            child: Text(
              (option.war?.lShortName ?? option.event?.lShortName.l ?? option.id.toString()).setMaxLines(1).breakWord,
              maxLines: 2,
              style: const TextStyle(fontSize: 12).merge(option.event?.isOutdated(const Duration(days: 1)) == true
                  ? TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)
                  : null),
              overflow: TextOverflow.ellipsis,
            ),
          )
      ],
      onChanged: (v) {
        setState(() {
          eventWarId = v;
        });
      },
    );
  }

  Widget questBtn() {
    final quests = options[eventWarId]?.quests ?? [];
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
