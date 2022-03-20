import 'package:chaldea/app/tools/glpk_solver.dart';
import 'package:chaldea/models/models.dart';

import 'scheme.dart';

class MissionSolver extends BaseLPSolver {
  Future<Map<int, int>> solve({
    required List<QuestPhase> quests,
    required List<CustomMission> missions,
  }) async {
    final result =
        await callSolver(convertLP(quests: quests, missions: missions));
    return result.map((key, value) => MapEntry(key, value.round()));
  }

  BasicLPParams convertLP({
    required List<QuestPhase> quests,
    required List<CustomMission> missions,
  }) {
    missions
        .removeWhere((mission) => mission.ids.isEmpty || mission.count <= 0);
    List<int> colNames = quests.map((e) => e.id).toList();
    List<int> rowNames = missions.map((e) => e.hashCode).toList();
    List<num> bVec = missions.map((e) => e.count).toList();
    List<num> cVec = quests.map((e) => e.consume).toList();

    List<List<num>> AMat = [];
    for (final mission in missions) {
      final row = <int>[];
      for (final quest in quests) {
        int count = 0;
        switch (mission.type) {
          case MissionTargetType.trait:
            count = quest.allEnemies
                .where((enemy) =>
                    NiceTrait.hasAllTraits(enemy.traits, mission.ids))
                .length;
            break;
          case MissionTargetType.questTrait:
            count =
                NiceTrait.hasAnyTrait(quest.individuality, mission.ids) ? 1 : 0;
            break;
          case MissionTargetType.quest:
            count = mission.ids.contains(quest.id) ? 1 : 0;
            break;
          case MissionTargetType.enemy:
            count = quest.allEnemies
                .where((enemy) => mission.ids.contains(enemy.svt.id))
                .length;
            break;
          case MissionTargetType.servantClass:
            count = quest.allEnemies
                .where((enemy) =>
                    enemy.traits
                        .any((trait) => trait.name == Trait.basedOnServant) &&
                    mission.ids.contains(enemy.svt.className.id))
                .length;
            break;
          case MissionTargetType.enemyClass:
            count = quest.allEnemies
                .where((enemy) => mission.ids.contains(enemy.svt.className.id))
                .length;
            break;
          case MissionTargetType.enemyNotServantClass:
            count = quest.allEnemies
                .where((enemy) =>
                    enemy.traits.any(
                        (trait) => trait.name == Trait.notBasedOnServant) &&
                    mission.ids.contains(enemy.svt.className.id))
                .length;
            break;
        }
        row.add(count);
      }
      AMat.add(row);
    }

    return BasicLPParams(
      colNames: colNames,
      rowNames: rowNames,
      AMat: AMat,
      bVec: bVec,
      cVec: cVec,
      integer: true,
    );
  }
}
