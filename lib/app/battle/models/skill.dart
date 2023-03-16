import 'dart:async';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';
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

  int skillId = 0;
  int skillLv = 0;
  int chargeTurn = 0;
  int strengthStatus = 0;
  bool isCommandCode;

  BattleSkillInfoData(this.rawSkill, {this.isCommandCode = false}) {
    skillId = rawSkill.id;
  }

  void shortenSkill(final int turns) {
    chargeTurn -= turns;
    chargeTurn = chargeTurn.clamp(0, skill.coolDown[skillLv - 1]);
  }

  void turnEnd() {
    if (chargeTurn > 0) {
      chargeTurn -= 1;
    }
  }

  Future<void> activate(final BattleData battleData) async {
    if (chargeTurn > 0 || battleData.isBattleFinished) {
      return;
    }
    chargeTurn = skill.coolDown[skillLv - 1];
    await activateSkill(battleData, skill, skillLv, isCommandCode: isCommandCode);
  }

  static Future<void> activateSkill(
    final BattleData battleData,
    final BaseSkill skill,
    final int skillLevel, {
    final bool isPassive = false,
    final bool notActorSkill = false,
    final bool isCommandCode = false,
  }) async {
    if (!battleData.checkActivatorTraits(skill.actIndividuality)) {
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
    );
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
                                .debug('${S.current.battle_select_effect}: ${transl('Option').l} ${index + 1}');
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
