import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class BattleCEData {
  CraftEssence craftEssence;
  bool isLimitBreak;
  int level;

  BattleCEData(this.craftEssence, this.isLimitBreak, this.level);

  void activateCE(BattleData battleData) {
    if (craftEssence.skills.length == 1) {
      BattleSkillInfoData.activateSkill(battleData, craftEssence.skills[0], 1, notActorSkill: true);
    }

    for (int i = 0; i < craftEssence.skills.length; i += 1) {
      bool shouldActivate = (i % 2 == 0 && !isLimitBreak || i % 2 == 1 && isLimitBreak);
      if (shouldActivate) {
        BattleSkillInfoData.activateSkill(battleData, craftEssence.skills[i], 1, notActorSkill: true);
      }
    }
  }
}