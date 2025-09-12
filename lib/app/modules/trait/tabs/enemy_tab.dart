import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import '../../enemy/quest_enemy_summary.dart';

class TraitEnemyTab extends StatefulWidget {
  final List<int> ids;
  const TraitEnemyTab(this.ids, {super.key});

  @override
  State<TraitEnemyTab> createState() => _TraitEnemyTabState();
}

class _TraitEnemyTabState extends State<TraitEnemyTab> {
  bool useGrid = false;

  @override
  Widget build(BuildContext context) {
    Map<int, List<QuestEnemy>> grouped = ReverseGameData.questEnemies(
      (e) => widget.ids.every((id) => e.traits.contains(id)),
    );
    final svtIds = grouped.keys.toList()..sort();
    if (svtIds.isEmpty) return const Center(child: Text('No record'));
    return CustomScrollView(
      slivers: [
        SliverList.list(
          children: [
            const SizedBox(height: 8),
            Center(
              child: FilterGroup.display(
                useGrid: useGrid,
                onChanged: (v) {
                  if (v != null) useGrid = v;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              S.current.only_show_main_story_enemy,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
          ],
        ),
        useGrid
            ? SliverGrid.extent(
                maxCrossAxisExtent: 56,
                childAspectRatio: 132 / 144,
                children: [for (final svtId in svtIds) gridItem(context, grouped[svtId]!)],
              )
            : SliverList.builder(
                itemBuilder: (context, index) => listItem(context, grouped[svtIds[index]]!),
                itemCount: svtIds.length,
              ),
      ],
    );
  }

  Widget listItem(BuildContext context, List<QuestEnemy> enemies) {
    final enemy = enemies.first;
    return ListTile(
      leading: enemy.svt.iconBuilder(context: context, jumpToDetail: false),
      title: Text(enemy.svt.lName.l),
      subtitle: Text(
        [if (!Transl.isJP) enemy.svt.name, 'No.${enemy.svt.id} ${Transl.svtClassId(enemy.svt.classId).l}'].join('\n'),
      ),
      dense: true,
      onTap: () {
        router.pushPage(QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
      },
    );
  }

  Widget gridItem(BuildContext context, List<QuestEnemy> enemies) {
    final enemy = enemies.first;
    return enemy.iconBuilder(
      context: context,
      padding: const EdgeInsets.all(2),
      onTap: () {
        router.pushPage(QuestEnemySummaryPage(svt: enemy.svt, enemies: enemies));
      },
    );
  }
}
