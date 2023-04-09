import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';

class BattleCEData {
  CraftEssence craftEssence;
  bool isLimitBreak;
  int level;

  int get atk => craftEssence.atkGrowth[level - 1];

  int get hp => craftEssence.hpGrowth[level - 1];

  BattleCEData(this.craftEssence, this.isLimitBreak, this.level);

  Future<void> activateCE(final BattleData battleData) async {
    final Map<int, List<NiceSkill>> dividedSkills = {};
    for (final skill in craftEssence.skills) {
      dividedSkills.putIfAbsent(skill.num, () => []).add(skill);
    }

    final priority = isLimitBreak ? 2 : 1;
    for (final skillNum in dividedSkills.keys.toList()..sort()) {
      final skillsForNum = dividedSkills[skillNum]!;
      final skillToUse = skillsForNum.firstWhereOrNull((skill) => skill.priority == priority) ?? skillsForNum.first;
      await BattleSkillInfoData.activateSkill(battleData, skillToUse, 1, notActorSkill: true);
    }
  }
}
