import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/models/models.dart';
import 'battle.dart';

class BattleSkillInfoData {
  NiceSkill rawSkill;
  BaseSkill? overrideSkill; // SkillRankUp
  BaseSkill get skill => overrideSkill ?? rawSkill;

  // BattleSkillType type = BattleSkillType.none;
  // late int index = rawSkill.num;
  // int svtUniqueId = 0;
  // int priority = 0;
  // bool isUseSkill = false;
  // int userCommandCodeId = -1;

  bool get isPassive => skill.type == SkillType.passive;

  bool get canActivate => chargeTurn == 0;

  int skillId = 0;
  int skillLv = 0;
  int chargeTurn = 0;
  int strengthStatus = 0;
  bool isCommandCode;

  BattleSkillInfoData(this.rawSkill, {this.isCommandCode = false}) {
    skillId = rawSkill.id;
  }

  void turnEnd() {
    if (chargeTurn > 0) {
      chargeTurn -= 1;
    }
  }

  void activate(final BattleData battleData) {
    if (chargeTurn > 0 || battleData.isBattleFinished) {
      return;
    }
    chargeTurn = skill.coolDown[skillLv - 1];
    activateSkill(battleData, skill, skillLv, isCommandCode: isCommandCode);
  }

  static void activateSkill(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel, {
    final bool isPassive = false,
    final bool notActorSkill = false,
    final bool isCommandCode = false,
  }) {
    if (!battleData.checkActivatorTraits(skill.actIndividuality)) {
      return;
    }

    // TODO (battle): account for random skills (check func.svals.ActSet)
    for (final func in skill.functions) {
      FunctionExecutor.executeFunction(
        battleData,
        func,
        skillLevel,
        isPassive: isPassive,
        notActorFunction: notActorSkill,
        isCommandCode: isCommandCode,
      );
    }
  }

  BattleSkillInfoData copy() {
    return BattleSkillInfoData(rawSkill)
      ..overrideSkill = overrideSkill
      ..isCommandCode = isCommandCode
      ..skillId = skillId
      ..skillLv = skillLv
      ..chargeTurn = chargeTurn
      ..strengthStatus = strengthStatus;
  }
}
