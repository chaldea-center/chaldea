import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/models/models.dart';
import 'battle.dart';

class BattleSkillInfoData {
  NiceSkill rawSkill;
  BaseSkill? overrideSkill; // SkillRankUp
  BaseSkill get skill => overrideSkill ?? rawSkill;

  // BattleSkillType type = BattleSkillType.none;
  late int index = rawSkill.num;
  int svtUniqueId = 0;

  bool get isPassive => skill.type == SkillType.passive;
  bool isCharge = false;
  int skillId = 0;
  int skillLv = 0;
  int chargeTurn = 0;
  int priority = 0;
  bool isUseSkill = false;
  int strengthStatus = 0;
  int userCommandCodeId = -1;

  BattleSkillInfoData(this.rawSkill) {
    skillId = rawSkill.id;
  }

  void turnEnd() {
    if (chargeTurn > 0) {
      chargeTurn -= 1;
    }
  }

  void activate(final BattleData battleData) {
    if (chargeTurn > 0) {
      return;
    }
    chargeTurn = skill.coolDown[skillLv - 1];
    activateSkill(battleData, skill, skillLv);
  }

  static void activateSkill(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel, {
    final bool isPassive = false,
    final bool notActorSkill = false,
  }) {
    // TODO (battle): account for random skills (check func.svals.ActSet)
    for (final func in skill.functions) {
      executeFunction(battleData, func, skillLevel, isPassive: isPassive, notActorFunction: notActorSkill);
    }
  }
}
