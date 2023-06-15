import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/descriptors/cond_target_value.dart';
import 'package:chaldea/app/modules/quest/quest.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'breakdown/quest_phase.dart';

/// [QuestCard] has a default [LocalKey], Make sure no same quest is shown twice, or provide a unique key.
class QuestCard extends StatefulWidget {
  final Quest? quest;
  final int questId;
  final bool offline;
  final Region? region;
  final bool battleOnly;
  final List<int>? displayPhases;
  final List<QuestPhase> preferredPhases;

  QuestCard({
    Key? key,
    required this.quest,
    int? questId,
    this.offline = true,
    this.region,
    this.battleOnly = false,
    this.displayPhases,
    this.preferredPhases = const [],
  })  : assert(quest != null || questId != null),
        questId = (quest?.id ?? questId)!,
        super(
          key: key ?? Key('QuestCard_${region?.name}_${quest?.id ?? questId}'),
        );

  @override
  _QuestCardState createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  Quest? _quest;
  Region? _region;

  Quest get quest => _quest!;
  bool showTrueName = false;

  @override
  void initState() {
    super.initState();
    showTrueName = !Transl.isJP;
    _init();
  }

  void _init() async {
    if (widget.quest != null) {
      _quest = widget.quest;
      _region = null;
    }
    if (_quest == null) {
      _quest = db.gameData.quests[widget.questId];
      if (_quest != null) _region = Region.jp;
    }
    if (_quest == null) {
      _quest ??= await AtlasApi.quest(widget.questId, region: widget.region ?? Region.jp);
      if (_quest != null) _region = widget.region ?? Region.jp;
    }
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offline != widget.offline ||
        oldWidget.region != widget.region ||
        oldWidget.quest != widget.quest ||
        oldWidget.questId != widget.questId) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quest == null) {
      return Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            AutoSizeText(
              'Quest ${widget.questId}',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.offline)
              TextButton(
                onPressed: () {
                  router.push(
                    url: Routes.questI(widget.questId),
                    child: QuestDetailPage(
                      quest: _quest,
                      id: widget.questId,
                      region: _region,
                    ),
                    detail: true,
                  );
                },
                child: Text('>>> ${S.current.quest_detail_btn} >>>'),
              ),
          ],
        ),
      );
    }

    String questName = quest.lNameWithChapter;

    List<String> names = [questName, if (!Transl.isJP && quest.name != quest.lName.l) quest.name]
        .map((e) => e.replaceAll('\n', ' '))
        .toList();
    String shownQuestName;
    if (names.any((s) => s.charWidth > 16)) {
      shownQuestName = names.join('\n');
    } else {
      shownQuestName = names.join('/');
    }
    String warName = Transl.warNames(quest.warLongName).l.replaceAll('\n', ' ');

    List<Widget> phaseWidgets = [];
    final displayPhases = widget.displayPhases ?? (quest.isMainStoryFree ? [quest.phases.last] : quest.phases);
    for (final phase in displayPhases) {
      final phaseData = widget.preferredPhases.firstWhereOrNull((qh) => qh.id == quest.id && qh.phase == phase);
      if (phaseData != null) {
        phaseWidgets.add(QuestPhaseWidget.phase(
          questPhase: phaseData,
          region: widget.region,
          offline: widget.offline,
          showTrueName: showTrueName,
          battleOnly: widget.battleOnly,
        ));
      } else {
        phaseWidgets.add(QuestPhaseWidget(
          quest: quest,
          phase: phase,
          region: widget.region,
          offline: widget.offline,
          showTrueName: showTrueName,
          battleOnly: widget.battleOnly,
        ));
      }
    }

    List<Widget> children = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 36),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: widget.battleOnly ? null : quest.war?.routeTo,
                    child: AutoSizeText(
                      warName,
                      maxLines: 2,
                      maxFontSize: 14,
                      minFontSize: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    shownQuestName,
                    textScaleFactor: 0.9,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: IconButton(
              onPressed: () => setState(() => showTrueName = !showTrueName),
              icon: Icon(
                Icons.remove_red_eye_outlined,
                color: showTrueName ? Theme.of(context).indicatorColor : null,
              ),
              tooltip: showTrueName ? 'Show Display Name' : 'Show True Name',
              padding: EdgeInsets.zero,
              iconSize: 20,
            ),
          )
        ],
      ),
      ...phaseWidgets,
      if (!widget.battleOnly && (quest.gifts.isNotEmpty || quest.giftIcon != null)) _questRewards(),
      if (!widget.battleOnly && !widget.offline) releaseConditions(),
      if (widget.offline && !widget.battleOnly)
        TextButton(
          onPressed: () {
            router.push(
              url: Routes.questI(quest.id),
              child: QuestDetailPage(quest: quest, region: widget.region),
              detail: true,
            );
          },
          child: Text('>>> ${S.current.quest_detail_btn} >>>'),
        ),
    ];

    return InheritSelectionArea(
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ...divideTiles(
              children.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: e,
                ),
              ),
              divider: const Divider(height: 8, thickness: 2),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Text _header(String text, [TextStyle? style]) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600).merge(style),
    );
  }

  Widget _questRewards() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _header(S.current.quest_reward_short),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 1,
                runSpacing: 1,
                children: [
                  if (quest.giftIcon != null) db.getIconImage(quest.giftIcon, width: 36),
                  for (final gift in quest.gifts)
                    gift.iconBuilder(
                      context: context,
                      width: 36,
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget releaseConditions() {
    final conds = quest.releaseConditions.where((cond) => !(cond.type == CondType.date && cond.value == 0)).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _header(S.current.quest_condition)),
        for (final cond in conds)
          CondTargetValueDescriptor(
            condType: cond.type,
            target: cond.targetId,
            value: cond.value,
            missions: db.gameData.wars[quest.warId]?.event?.missions ?? [],
          ),
        Text('${S.current.time_start}: ${quest.openedAt.sec2date().toStringShort(omitSec: true)}'),
        Text('${S.current.time_end}: ${quest.closedAt.sec2date().toStringShort(omitSec: true)}'),
      ],
    );
  }
}
