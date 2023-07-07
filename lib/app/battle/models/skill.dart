import 'dart:async';
import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../interactions/skill_act_select.dart';
import 'battle.dart';

class BattleSkillInfoData {
  // BattleSkillType type = BattleSkillType.none;
  // late int index = rawSkill.num;
  // int svtUniqueId = 0;
  // int priority = 0;
  // bool isUseSkill = false;
  // int userCommandCodeId = -1;

  String get lName => proximateSkill?.lName.l ?? '???';

  BaseSkill? get proximateSkill => _skill;

  int skillNum;
  BaseSkill? baseSkill;
  List<BaseSkill> provisionedSkills;
  int rankUp = 0;
  List<BaseSkill?>? rankUps;
  int _skillLv = 0;
  SkillScript? skillScript;
  int chargeTurn = 0;
  bool isCommandCode;

  BattleSkillInfoData(
    this.baseSkill, {
    List<BaseSkill>? provisionedSkills,
    this.skillNum = -1,
    this.isCommandCode = false,
    int skillLv = 0,
  })  : provisionedSkills = provisionedSkills ?? [],
        _skillLv = skillLv {
    if (baseSkill != null && !this.provisionedSkills.contains(baseSkill)) {
      this.provisionedSkills.add(baseSkill!);
    }
    skillScript = proximateSkill?.script;
  }

  BaseSkill? get _skill => rankUp == 0 || rankUps == null || rankUps!.isEmpty
      ? baseSkill
      : rankUp > rankUps!.length
          ? rankUps!.last
          : rankUps![rankUp - 1];

  set skillLv(int v) => _skillLv = v;

  int get skillLv {
    final maxLv = proximateSkill?.maxLv;
    if (maxLv == null || maxLv == 0) return _skillLv;
    return _skillLv.clamp(1, maxLv);
  }

  void setBaseSkillId(final NiceSkill? newSkill) {
    baseSkill = newSkill;
    skillScript = proximateSkill?.script;
  }

  void setRankUp(final int newRank) {
    rankUp = newRank;
    skillScript = proximateSkill?.script;
  }

  Future<BaseSkill?> getSkill() async {
    return _skill;
  }

  void shortenSkill(final int turns) {
    chargeTurn -= turns;
    chargeTurn = max(0, chargeTurn);
  }

  void extendSkill(final int turns) {
    chargeTurn += turns;
    chargeTurn = min(999, chargeTurn);
  }

  void turnEnd() {
    if (chargeTurn > 0) {
      chargeTurn -= 1;
    }
  }

  bool checkSkillScript(final BattleData battleData) {
    return skillScriptConditionCheck(battleData, skillScript, skillLv);
  }

  static bool skillScriptConditionCheck(
    final BattleData battleData,
    final SkillScript? skillScript,
    final int skillLv,
  ) {
    if (skillScript == null) {
      return true;
    }

    if (skillScript.NP_HIGHER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.npHigher, skillScript.NP_HIGHER![skillLv - 1]);
    } else if (skillScript.NP_LOWER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.npLower, skillScript.NP_LOWER![skillLv - 1]);
    } else if (skillScript.STAR_HIGHER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.starHigher, skillScript.STAR_HIGHER![skillLv - 1]);
    } else if (skillScript.STAR_LOWER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.starLower, skillScript.STAR_LOWER![skillLv - 1]);
    } else if (skillScript.HP_VAL_HIGHER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.hpValHigher, skillScript.HP_VAL_HIGHER![skillLv - 1]);
    } else if (skillScript.HP_VAL_LOWER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.hpValLower, skillScript.HP_VAL_LOWER![skillLv - 1]);
    } else if (skillScript.HP_PER_HIGHER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.hpPerHigher, skillScript.HP_PER_HIGHER![skillLv - 1]);
    } else if (skillScript.HP_PER_LOWER != null) {
      return checkSkillScripCondition(battleData, SkillScriptCond.hpPerLower, skillScript.HP_PER_LOWER![skillLv - 1]);
    }

    return true;
  }

  Future<bool> activate(final BattleData battleData, {final int? effectiveness}) async {
    if (chargeTurn > 0 || battleData.isBattleFinished) {
      return false;
    }
    final curSkill = await getSkill();
    if (curSkill == null) {
      return false;
    }
    chargeTurn = curSkill.coolDown[skillLv - 1];
    skillScript = curSkill.script;
    return await activateSkill(battleData, curSkill, skillLv,
        isCommandCode: isCommandCode, effectiveness: effectiveness);
  }

  static Future<bool> activateSkill(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel, {
    final bool isPassive = false,
    final bool notActorSkill = false,
    final bool isCommandCode = false,
    final int? effectiveness,
    final bool defaultToPlayer = true,
  }) async {
    final actorTraitMatch = battleData.checkTraits(CheckTraitParameters(
      requiredTraits: skill.actIndividuality,
      actor: battleData.activator,
      checkActorTraits: true,
    ));

    bool canActSkill = battleData.delegate?.whetherSkill?.call(battleData.activator, skill) ?? actorTraitMatch;
    if (!canActSkill) {
      return false;
    }

    int? selectedActionIndex;
    if (skill.script != null && skill.script!.SelectAddInfo != null && skill.script!.SelectAddInfo!.isNotEmpty) {
      if (battleData.delegate?.skillActSelect != null) {
        selectedActionIndex = await battleData.delegate!.skillActSelect!(battleData.activator);
      }
      if (selectedActionIndex == null && battleData.mounted) {
        selectedActionIndex = await SkillActSelectDialog.show(battleData, skill, skillLevel);
        battleData.replayDataRecord.skillActSelectSelections.add(selectedActionIndex);
      }
    }

    await FunctionExecutor.executeFunctions(
      battleData,
      skill.functions,
      skillLevel,
      isPassive: isPassive,
      notActorFunction: notActorSkill,
      isCommandCode: isCommandCode,
      selectedActionIndex: selectedActionIndex,
      effectiveness: effectiveness,
      defaultToPlayer: defaultToPlayer,
    );
    if (skill.script?.additionalSkillId != null) {
      final skillId = skill.script!.additionalSkillId!.getOrNull(skillLevel - 1);
      if (skillId != null && skillId != 0) {
        final askillLv = skill.script!.additionalSkillLv?.getOrNull(skillLevel - 1) ?? 1;
        final askill = await AtlasApi.skill(skillId);
        if (askill != null) {
          await activateSkill(battleData, askill, askillLv, isPassive: skill.type == SkillType.passive);
        }
      }
    }
    return true;
  }

  BattleSkillInfoData copy() {
    return BattleSkillInfoData(baseSkill, provisionedSkills: provisionedSkills, skillNum: skillNum)
      ..isCommandCode = isCommandCode
      ..rankUps = rankUps
      ..rankUp = rankUp
      ..skillLv = skillLv
      ..skillScript = skillScript
      ..chargeTurn = chargeTurn;
  }

  static bool checkSkillScripCondition(
    final BattleData battleData,
    final SkillScriptCond cond,
    final int? value,
  ) {
    if (value == null) {
      return true;
    }

    switch (cond) {
      case SkillScriptCond.none:
        return true;
      case SkillScriptCond.npHigher:
        return battleData.activator!.np / 100 >= value;
      case SkillScriptCond.npLower:
        return battleData.activator!.np / 100 <= value;
      case SkillScriptCond.starHigher:
        return battleData.criticalStars >= value;
      case SkillScriptCond.starLower:
        return battleData.criticalStars <= value;
      case SkillScriptCond.hpValHigher:
        return battleData.activator!.hp >= value;
      case SkillScriptCond.hpValLower:
        return battleData.activator!.hp >= value;
      case SkillScriptCond.hpPerHigher:
        return battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) >= value / 1000;
      case SkillScriptCond.hpPerLower:
        return battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) <= value / 1000;
    }
  }
}

enum SkillInfoType {
  none,
  svtSelf,
  svtPassive,
  svtEquip,
  mysticCode,
  commandSpell,
  custom,
}

class CommonCustomSkills {
  const CommonCustomSkills._();

  static const _idBase = 10000000000;

  static final csRepairHp = NiceSkill(
    id: _idBase + 1,
    type: SkillType.active,
    name: '霊基修復',
    unmodifiedDetail: 'サーヴァント1騎のHPを全回復する',
    coolDown: [0],
    functions: [
      NiceFunction(
        funcId: 452,
        funcType: FuncType.gainHpPer,
        funcTargetType: FuncTargetType.ptOne,
        funcTargetTeam: FuncApplyTarget.playerAndEnemy,
        svals: [
          DataVals({
            'Rate': 1000,
            'Value': 1000,
            'Unaffected': 1,
          })
        ],
      )
    ],
  );

  static final csRepairNp = NiceSkill(
    id: _idBase + 9,
    type: SkillType.active,
    name: '宝具解放',
    unmodifiedDetail: 'サーヴァント1騎のNPを100％増加させる',
    coolDown: [0],
    functions: [
      NiceFunction(
        funcId: 464,
        funcType: FuncType.gainNp,
        funcTargetType: FuncTargetType.ptOne,
        funcTargetTeam: FuncApplyTarget.player,
        funcPopupText: 'NP増加',
        svals: [
          DataVals({
            'Rate': 3000,
            'Value': 10000,
            'Unaffected': 1,
          })
        ],
      )
    ],
  );

  static NiceSkill get chargeAllAlliesNP => NiceSkill(
        id: _idBase + 3,
        type: SkillType.active,
        name: S.current.battle_charge_party,
        unmodifiedDetail: S.current.battle_charge_party,
        coolDown: [0],
        functions: [
          NiceFunction(
            funcId: 1,
            funcType: FuncType.gainNp,
            funcTargetType: FuncTargetType.ptAll,
            funcTargetTeam: FuncApplyTarget.playerAndEnemy,
            svals: [
              DataVals({
                'Rate': 5000,
                'Value': 10000,
                'Unaffected': 1,
              })
            ],
          )
        ],
      );

  static BaseSkill get forceInstantDeath => NiceSkill(
        id: _idBase + 101,
        type: SkillType.active,
        name: Transl.funcPopuptextBase('即死').l,
        unmodifiedDetail: '即死',
        coolDown: [0],
        functions: [
          NiceFunction(
            funcId: 7196,
            funcType: FuncType.forceInstantDeath,
            funcTargetType: FuncTargetType.self,
            funcTargetTeam: FuncApplyTarget.playerAndEnemy,
            funcPopupText: '即死',
            svals: [
              DataVals({
                'Rate': 5000,
              })
            ],
          )
        ],
      );

  static BaseSkill get forceInstantDeathDelay => NiceSkill(
        id: _idBase + 101,
        type: SkillType.active,
        name: Transl.buffNames('遅延発動(即死)').l,
        unmodifiedDetail: '自身に「ターン終了時に即死する状態」を付与',
        coolDown: [0],
        functions: [
          NiceFunction(
            funcId: -7195,
            funcType: FuncType.addStateShort,
            funcTargetType: FuncTargetType.self,
            funcTargetTeam: FuncApplyTarget.playerAndEnemy,
            funcPopupText: '遅延発動(即死)',
            buffs: [
              const Buff(
                id: 3631,
                name: "遅延発動(即死)",
                detail: "ターン終了時に即死する状態を付与",
                icon: "https://static.atlasacademy.io/JP/BuffIcons/bufficon_525.png",
                type: BuffType.delayFunction,
                buffGroup: 0,
              )
            ],
            svals: [
              DataVals({
                'Rate': 5000,
                "Turn": 1,
                "Count": -1,
                "Value": 966262,
                "Value2": 1,
              })
            ],
          )
        ],
      );
}
