import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/enemy/quest_card.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'scheme.dart';
import 'solver.dart';

class MissionSolutionTab extends StatefulWidget {
  final MissionSolution? solution;
  final bool showResult;
  const MissionSolutionTab({Key? key, this.solution, this.showResult = true})
      : super(key: key);

  @override
  State<MissionSolutionTab> createState() => _MissionSolutionTabState();
}

class _MissionSolutionTabState extends State<MissionSolutionTab> {
  late ScrollController _scrollController;
  MissionSolution get solution => widget.solution!;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solution == null) return const SizedBox();
    int battleCount = 0;
    int apCount = 0;
    if (widget.showResult) {
      battleCount = Maths.sum(solution.result.values);
      apCount = Maths.sum(solution.result.keys
          .map((e) => solution.quests[e]!.consume * solution.result[e]!));
    }
    List<int> questIds = [];
    Map<int, int> targetCounts = {};

    if (widget.showResult) {
      questIds = solution.result.keys.toList();
      questIds.sort2((e) => -solution.result[e]!);
    } else {
      for (final quest in solution.quests.values) {
        int targetCount = 0;
        for (final mission in solution.missions) {
          targetCount += MissionSolver.countMissionTarget(mission, quest);
        }
        if (targetCount > 0) targetCounts[quest.id] = targetCount;
      }
      questIds = targetCounts.keys.toList();
      questIds.sort2((questId) => -targetCounts[questId]!);
    }

    final listView = ListView.separated(
      controller: _scrollController,
      itemBuilder: (context, index) {
        final id = questIds[index];
        return _oneQuest(id,
            widget.showResult ? solution.result[id]! : targetCounts[id] ?? 0);
      },
      separatorBuilder: (context, index) => kDefaultDivider,
      itemCount: questIds.length,
    );
    return Column(children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 16),
        child: widget.showResult
            ? ListTile(
                title: Text(
                    S.current.solution_total_battles_ap(battleCount, apCount)),
                trailing: Text(S.current.solution_battle_count),
              )
            : ListTile(
                title: Text(S.current.master_mission_related_quest),
                trailing: Text(S.current.solution_target_count),
              ),
      ),
      Expanded(child: listView)
    ]);
  }

  Widget _oneQuest(int questId, int count) {
    final quest = solution.quests[questId]!;
    return SimpleAccordion(
      key: Key('quest_$questId'),
      headerTileColor: Theme.of(context).cardColor,
      headerBuilder: (context, expanded) {
        final name = quest.lDispName, nameJp = quest.dispName;
        return ListTile(
          title: Text(quest.lDispName),
          subtitle: Text('${quest.consume}AP  ${name == nameJp ? '' : nameJp}'),
          trailing: Text('${widget.showResult ? '×' : '+'} $count'),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [];
        for (final mission in solution.missions) {
          int count = MissionSolver.countMissionTarget(mission, quest);
          if (count <= 0) continue;
          children.add(ListTile(
            title: mission.buildDescriptor(context),
            subtitle: mission.originDetail?.isNotEmpty == true
                ? Text(mission.originDetail!)
                : null,
            trailing: Text('+ $count'),
            minVerticalPadding: 0,
            visualDensity: VisualDensity.compact,
            dense: true,
          ));
        }
        children = divideTiles(children,
            divider: const Divider(indent: 16, endIndent: 16));
        children.add(QuestCard(quest: quest, region: solution.region));
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}
