import 'dart:async';
import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
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

  List<BaseSkill> provisionedSkills;
  int rankUp = 0;
  List<BaseSkill?>? rankUps;
  NiceSkill? baseSkill;

  BaseSkill? get _skill => rankUp == 0 || rankUps == null || rankUps!.isEmpty
      ? baseSkill
      : rankUp > rankUps!.length
          ? rankUps!.last
          : rankUps![rankUp - 1];
  int skillLv = 0;
  SkillScript? skillScript;
  int chargeTurn = 0;
  bool isCommandCode;

  BattleSkillInfoData(this.provisionedSkills, this.baseSkill, {this.isCommandCode = false}) {
    if (baseSkill != null && !provisionedSkills.contains(baseSkill)) {
      provisionedSkills.add(baseSkill!);
    }
    skillScript = proximateSkill?.script;
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

  Future<void> activate(final BattleData battleData, {final int? effectiveness}) async {
    if (chargeTurn > 0 || battleData.isBattleFinished) {
      return;
    }
    final curSkill = await getSkill();
    if (curSkill == null) {
      return;
    }
    chargeTurn = curSkill.coolDown[skillLv - 1];
    skillScript = curSkill.script;
    await activateSkill(battleData, curSkill, skillLv, isCommandCode: isCommandCode, effectiveness: effectiveness);
  }

  static Future<void> activateSkill(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel, {
    final bool isPassive = false,
    final bool notActorSkill = false,
    final bool isCommandCode = false,
    final int? effectiveness,
  }) async {
    if (!battleData.checkTraits(skill.actIndividuality, false)) {
      return;
    }

    int? selectedActionIndex;
    if (skill.script != null && skill.script!.SelectAddInfo != null) {
      if (battleData.context != null) {
        await getSelectedIndex(battleData, skill, skillLevel).then((value) => selectedActionIndex = value);
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
    );
  }

  BattleSkillInfoData copy() {
    return BattleSkillInfoData(provisionedSkills, baseSkill)
      ..isCommandCode = isCommandCode
      ..rankUps = rankUps
      ..rankUp = rankUp
      ..skillLv = skillLv
      ..skillScript = skillScript
      ..chargeTurn = chargeTurn;
  }

  static Future<int> getSelectedIndex(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel,
  ) async {
    final selectAddInfo = skill.script!.SelectAddInfo![skillLevel - 1];
    final buttons = selectAddInfo.btn;
    final transl = Transl.miscScope('SelectAddInfo');
    return await showDialog(
      context: battleData.context!,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        return SimpleCancelOkDialog(
          title: Text(S.current.battle_select_effect),
          contentPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: divideTiles([
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '${transl('Optional').l}: ${transl(selectAddInfo.title).l}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                ...List.generate(buttons.length, (index) {
                  final button = buttons[index];
                  final textWidget = Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '${transl('Option').l} ${index + 1}: ${transl(button.name).l}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                  return button.conds.every((cond) => !checkSkillScripCondition(battleData, cond.cond, cond.value))
                      ? textWidget
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(index);
                            battleData.logger
                                .action('${S.current.battle_select_effect}: ${transl('Option').l} ${index + 1}');
                          },
                          child: textWidget,
                        );
                })
              ]),
            ),
          ),
          hideOk: true,
          hideCancel: true,
        );
      },
    );
  }

  static bool checkSkillScripCondition(
    final BattleData battleData,
    final SkillScriptCond cond,
    final int? value,
  ) {
    switch (cond) {
      case SkillScriptCond.none:
        return true;
      case SkillScriptCond.npHigher:
        return battleData.activator!.np >= value!;
      case SkillScriptCond.npLower:
        return battleData.activator!.np <= value!;
      case SkillScriptCond.starHigher:
        return battleData.criticalStars >= value!;
      case SkillScriptCond.starLower:
        return battleData.criticalStars <= value!;
      case SkillScriptCond.hpValHigher:
        return battleData.activator!.hp >= value!;
      case SkillScriptCond.hpValLower:
        return battleData.activator!.hp >= value!;
      case SkillScriptCond.hpPerHigher:
        return battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) >= value! / 1000;
      case SkillScriptCond.hpPerLower:
        return battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) <= value! / 1000;
    }
  }
}
