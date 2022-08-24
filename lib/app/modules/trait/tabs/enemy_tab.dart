import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import '../../enemy/quest_enemy_summary.dart';

class TraitEnemyTab extends StatelessWidget {
  final int id;
  const TraitEnemyTab(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<QuestEnemy> allEnemies = [];
    for (final quest in db.gameData.questPhases.values) {
      allEnemies.addAll(quest.allEnemies
          .where((enemy) => enemy.traits.any((e) => e.id == id)));
    }
    Map<int, List<QuestEnemy>> grouped = {};
    for (final enemy in allEnemies) {
      grouped.putIfAbsent(enemy.svt.id, () => []).add(enemy);
    }
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
              style: Theme.of(context).textTheme.caption,
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
            'No.${enemy.svt.id} ${Transl.svtClass(enemy.svt.className).l}'
          ].join('\n')),
          dense: true,
          onTap: () {
            router.pushPage(
                QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
          },
        );
      },
      itemCount: svtIds.length + 1,
    );
  }
}