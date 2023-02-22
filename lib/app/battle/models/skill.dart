import 'package:chaldea/models/models.dart';

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

  BattleSkillInfoData(this.rawSkill);
}
