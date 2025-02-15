import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class TraitFieldTab extends StatefulWidget {
  final List<int> ids;
  const TraitFieldTab(this.ids, {super.key});

  @override
  State<TraitFieldTab> createState() => _TraitFieldTabState();
}

class _TraitFieldTabState extends State<TraitFieldTab> {
  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    final quests =
        db.gameData.questPhases.values
            .where((q) => q.questIndividuality.map((e) => e.id).toSet().intersection(widget.ids.toSet()).isNotEmpty)
            .toList();
    quests.sortByList((e) => [-e.warId, -e.id]);
    if (quests.isEmpty) return const Center(child: Text('No record'));
    return ListView.builder(
      itemCount: quests.length,
      itemBuilder: (context, index) => listItem(context, quests[index]),
    );
  }

  Widget listItem(BuildContext context, QuestPhase quest) {
    return ListTile(
      leading: db.getIconImage(quest.spot?.shownImage),
      title: Text(quest.lDispName),
      subtitle: Text(
        [
          quest.war?.lShortName ?? "Unknown War",
          quest.questIndividuality.map((e) => Transl.trait(e.id).l).join(' / '),
        ].join('\n'),
      ),
      trailing: Text(
        ["Lv.${quest.recommendLv}", "${S.current.bond} ${quest.bond}"].join('\n'),
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.end,
      ),
      dense: true,
      onTap: quest.routeTo,
    );
  }
}
