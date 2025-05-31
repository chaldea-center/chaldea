import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/models.dart';
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

  BattleCEData copy() {
    return BattleCEData(craftEssence, isLimitBreak, level);
  }

  Future<void> activateCE(final BattleData battleData, final BattleServantData activator) async {
    final skillGroups = craftEssence.getActivatedSkills(isLimitBreak);
    final eventId = battleData.niceQuest?.war?.eventId;
    final event = battleData.niceQuest?.war?.event;
    final bool hasLvPointBuff = event?.pointBuffs.any((e) => e.lv > 0) == true;
    for (final skillNum in skillGroups.keys) {
      final skills = skillGroups[skillNum]!.toList();
      if (hasLvPointBuff && skillNum > 1) {
        final buffGroupId =
            ConstData.eventPointBuffGroupSkillNumMap[event?.id]?.entries
                .firstWhereOrNull((e) => e.value == skillNum)
                ?.key;
        int lv = battleData.options.pointBuffs[buffGroupId]?.lv ?? 0;
        final eventSkills =
            skills
                .where((skill) => skill.functions.any((func) => func.funcGroup.any((g) => g.eventId == eventId)))
                .toList();
        if (lv > 0 && eventSkills.isNotEmpty) {
          lv = lv.clamp2(1, eventSkills.length);
          final targetSkill = eventSkills.getOrNull((lv - 1).clamp(0, eventSkills.length - 1));
          if (targetSkill != null) {
            final skillInfo = BattleSkillInfoData(targetSkill, type: SkillInfoType.svtEquip);
            await skillInfo.activate(battleData, activator: activator);
          }
        }
      } else {
        for (final skill in skills) {
          final skillInfo = BattleSkillInfoData(skill, type: SkillInfoType.svtEquip);
          await skillInfo.activate(battleData, activator: activator);
        }
      }
    }
  }
}
