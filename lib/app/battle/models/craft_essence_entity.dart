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
    final skills = craftEssence.getActivatedSkills(isLimitBreak);
    for (final skillNum in skills.keys) {
      for (final skill in skills[skillNum]!) {
        await BattleSkillInfoData.activateSkill(battleData, skill, 1, notActorSkill: true);
      }
    }
  }
}
