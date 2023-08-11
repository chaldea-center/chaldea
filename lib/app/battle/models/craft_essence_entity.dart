import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';

class BattleCEData {
  CraftEssence craftEssence;
  bool isLimitBreak;
  int level;

  int get atk => craftEssence.atkGrowth.getOrNull(level - 1) ?? 0;

  int get hp => craftEssence.hpGrowth.getOrNull(level - 1) ?? 0;

  BattleCEData(this.craftEssence, this.isLimitBreak, this.level) {
    if (level > craftEssence.atkGrowth.length) {
      level = craftEssence.atkGrowth.length;
    }
  }

  Future<void> activateCE(final BattleData battleData) async {
    final skillGroups = craftEssence.getActivatedSkills(isLimitBreak);
    // eventId: <CE.skill.num, pointBuff.groupId>
    const lvPointBuffSkillNumMap = {
      // summer 2023
      80442: {
        6: 8044201,
        3: 8044202,
        2: 8044203,
        4: 8044204,
        5: 8044205,
      },
    };
    final eventId = battleData.niceQuest?.war?.eventId;
    final event = battleData.niceQuest?.war?.event;
    final bool hasLvPointBuff = event?.pointBuffs.any((e) => e.lv > 0) == true;
    for (final skillNum in skillGroups.keys) {
      final skills = skillGroups[skillNum]!.toList();
      if (hasLvPointBuff && skillNum > 1) {
        final buffGroupId = lvPointBuffSkillNumMap[event?.id]?[skillNum];
        int lv = battleData.options.pointBuffs[buffGroupId]?.lv ?? 0;
        final eventSkills = skills
            .where((skill) => skill.functions.any((func) => func.funcGroup.any((g) => g.eventId == eventId)))
            .toList();
        if (lv > 0 && eventSkills.isNotEmpty) {
          lv = lv.clamp2(1, eventSkills.length);
          final targetSkill = eventSkills.getOrNull((lv - 1).clamp(0, eventSkills.length - 1));
          if (targetSkill != null) {
            await BattleSkillInfoData.activateSkill(battleData, targetSkill, 1, notActorSkill: true);
          }
        }
      } else {
        for (final skill in skills) {
          await BattleSkillInfoData.activateSkill(battleData, skill, 1, notActorSkill: true);
        }
      }
    }
  }
}
