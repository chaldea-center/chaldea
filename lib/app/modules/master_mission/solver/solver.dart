import 'package:chaldea/app/tools/glpk_solver.dart';
import 'package:chaldea/models/models.dart';
import 'scheme.dart';

class MissionSolver extends BaseLPSolver {
  // make sure [missions] is a copy
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
    missions = List.of(missions);
    missions
        .removeWhere((mission) => mission.ids.isEmpty || mission.count <= 0);

    List<List<num>> matA = [];
    for (final mission in List.of(missions)) {
      final row = <int>[];
      for (final quest in quests) {
        row.add(countMissionTarget(mission, quest));
      }
      if (row.any((e) => e > 0)) {
        matA.add(row);
      } else {
        print(
            'remove invalid mission: ${mission.type}/${mission.count}/${mission.ids}');
        missions.remove(mission);
      }
    }

    return BasicLPParams(
      colNames: quests.map((e) => e.id).toList(),
      rowNames: missions.map((e) => e.hashCode).toList(),
      matA: matA,
      bVec: missions.map((e) => e.count).toList(),
      cVec: quests.map((e) => e.consume).toList(),
      integer: true,
    );
  }

  static int countMissionTarget(CustomMission mission, QuestPhase quest) {
    final enemies =
        quest.allEnemies.where((e) => e.deck == DeckType.enemy).toList();
    switch (mission.type) {
      case CustomMissionType.trait:
        return enemies
            .where((enemy) => NiceTrait.hasAllTraits(enemy.traits, mission.ids))
            .length;
      case CustomMissionType.questTrait:
        return NiceTrait.hasAnyTrait(quest.individuality, mission.ids) ? 1 : 0;
      case CustomMissionType.quest:
        return mission.ids.contains(quest.id) ? 1 : 0;
      case CustomMissionType.enemy:
        return enemies
            .where((enemy) => mission.ids.contains(enemy.svt.id))
            .length;
      case CustomMissionType.servantClass:
        return enemies
            .where((enemy) =>
                enemy.traits
                    .any((trait) => trait.name == Trait.basedOnServant) &&
                mission.ids.contains(enemy.svt.className.id))
            .length;
      case CustomMissionType.enemyClass:
        return enemies
            .where((enemy) => mission.ids.contains(enemy.svt.className.id))
            .length;
      case CustomMissionType.enemyNotServantClass:
        return enemies
            .where((enemy) =>
                enemy.traits
                    .any((trait) => trait.name == Trait.notBasedOnServant) &&
                mission.ids.contains(enemy.svt.className.id))
            .length;
    }
  }
}
