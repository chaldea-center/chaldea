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
  _OptionData({required this.id, required this.war, required this.event, required this.quests});
}

class _FQSelectDropdownState extends State<FQSelectDropdown> {
  int? eventWarId = 308;
  Quest? quest;
  Map<int, _OptionData> options = {};

  bool shouldShow(Quest quest) {
    if (quest.phases.isEmpty) return false;
    if (quest.isLaplaceSharable) return true;
    if (quest.warId == WarId.daily || quest.warId == WarId.chaldeaGate) {
      return quest.isAnyFree;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final optionList = <_OptionData>[];
    for (final war in db.gameData.wars.values) {
      if (war.isMainStory || war.id == WarId.daily || war.id == WarId.chaldeaGate) {
        final quests = war.quests.where(shouldShow).toList();
        if (quests.isNotEmpty) {
          optionList.add(_OptionData(id: war.id, war: war, event: null, quests: quests));
        }
      }
    }
    for (final event in db.gameData.events.values) {
      List<Quest> quests = [];
      if (event.isHuntingEvent) {
        final questIds = db.gameData.others.eventQuestGroups[event.id] ?? [];
        for (final questId in questIds) {
          final quest = db.gameData.quests[questId];
          if (quest != null && quest.isAnyFree) {
            quests.add(quest);
          }
        }
      }
      for (final warId in event.warIds) {
        final war = db.gameData.wars[warId];
        if (warId < 1000 || war == null) continue;
        quests.addAll(war.quests.where(shouldShow));
      }
      if (quests.isNotEmpty) {
        quests.sort2((e) => -e.priority);
        optionList.add(_OptionData(id: event.id, war: null, event: event, quests: quests));
      }
    }

    optionList.sortByList(
      (e) => <int>[e.war != null ? (e.id < 1000 ? 0 : 1) : 2, e.war != null ? -e.id : -(e.event?.startedAt ?? e.id)],
    );

    final initQuest = db.gameData.quests[widget.initQuestId];
    final option = optionList.lastWhereOrNull((option) => option.quests.contains(initQuest));
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
        Flexible(child: eventWarBtn()),
        const SizedBox(width: 8),
        Flexible(child: questBtn()),
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
      items:
          options.values.map((option) {
            final outdated = option.event?.isOutdated(const Duration(days: 1)) == true;
            final ongoing = option.event?.isOnGoing(db.curUser.region) == true;
            String name = option.war?.lShortName ?? option.event?.shownName ?? option.id.toString();
            if (option.war != null) name = 'ꔷ $name';
            return DropdownMenuItem(
              value: option.id,
              child: Text(
                name.setMaxLines(1).breakWord,
                maxLines: 2,
                style: const TextStyle(fontSize: 12).merge(
                  TextStyle(
                    color:
                        ongoing
                            ? Theme.of(context).colorScheme.primary
                            : outdated
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : null,
                    // decoration: option.event != null && !outdated ? TextDecoration.underline : null,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
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
      items:
          quests.map((quest) {
            List<InlineSpan> spans = [
              if (quest.event != null || quest.is90PlusFree)
                TextSpan(text: '${quest.recommendLv} ', style: const TextStyle(fontSize: 10)),
              TextSpan(text: quest.lDispName.setMaxLines(1).breakWord),
            ];
            return DropdownMenuItem(
              value: quest,
              child: Text.rich(
                TextSpan(children: spans),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: quest.is90PlusFree ? Theme.of(context).colorScheme.primary : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),

      onChanged: (v) {
        setState(() {
          quest = v;
          if (v != null) widget.onChanged(v);
        });
      },
    );
  }
}
