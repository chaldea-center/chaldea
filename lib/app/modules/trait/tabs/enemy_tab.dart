import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import '../../enemy/quest_enemy_summary.dart';

class TraitEnemyTab extends StatelessWidget {
  final int id;
  const TraitEnemyTab(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    Map<int, List<QuestEnemy>> grouped = ReverseGameData.questEnemies((e) => e.traits.any((t) => t.id == id));
    final svtIds = grouped.keys.toList()..sort();
    if (svtIds.isEmpty) return const Center(child: Text('No record'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              S.current.only_show_main_story_enemy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        final enemies = grouped[svtIds[index - 1]]!;
        final enemy = enemies.first;
        return ListTile(
          leading: enemy.svt.iconBuilder(context: context, jumpToDetail: false),
          title: Text(enemy.svt.lName.l),
          subtitle: Text([
            if (!Transl.isJP) enemy.svt.name,
            'No.${enemy.svt.id} ${Transl.svtClassId(enemy.svt.classId).l}'
          ].join('\n')),
          dense: true,
          onTap: () {
            router.pushPage(QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
          },
        );
      },
      itemCount: svtIds.length + 1,
    );
  }
}
