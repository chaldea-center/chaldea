import 'dart:async';
import 'dart:math';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../interactions/skill_act_select.dart';
import '../utils/battle_logger.dart';
import 'battle.dart';

class BattleSkillInfoData {
  SkillInfoType type;
  // late int index = rawSkill.num;
  // int svtUniqueId = 0;
  // int priority = 0;
  // bool isUseSkill = false;
  // int userCommandCodeId = -1;

  String get lName => skill?.lName.l ?? '???';

  final int skillNum;
  final BaseSkill? _baseSkill;
  final List<BaseSkill> _provisionedSkills;
  int rankUp = 0;
  List<BaseSkill?>? rankUps;
  int _skillLv = 0;
  SkillScript? skillScript;
  int chargeTurn = 0;

  BattleSkillInfoData(
    this._baseSkill, {
    required this.type,
    List<BaseSkill>? provisionedSkills,
    this.skillNum = -1,
    int skillLv = 0,
  }) : _provisionedSkills = provisionedSkills ?? [],
       _skillLv = skillLv {
    if (_baseSkill != null && !_provisionedSkills.contains(_baseSkill)) {
      _provisionedSkills.add(_baseSkill);
    }
    skillScript = skill?.script;
  }

  BaseSkill? get skill => rankUp == 0 || rankUps == null || rankUps!.isEmpty
      ? _baseSkill
      : rankUp > rankUps!.length
      ? rankUps!.last
      : rankUps![rankUp - 1];

  set skillLv(int v) => _skillLv = v;

  int get skillLv {
    final maxLv = skill?.maxLv;
    if (maxLv == null || maxLv == 0) return _skillLv;
    return _skillLv.clamp(1, maxLv);
  }

  void setRankUp(final int newRank) {
    rankUp = newRank;
    skillScript = skill?.script;
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

  static bool checkSkillScript(
    final BattleData battleData,
    final BattleServantData? activator,
    final SkillScript? skillScript,
    final int skillLv,
  ) {
    if (skillScript == null) {
      return true;
    }

    final actRarity = skillScript.actRarity?.getOrNull(skillLv - 1);
    if (actRarity != null && !actRarity.contains(activator?.rarity)) {
      return false;
    }

    final npHigher = skillScript.NP_HIGHER?.getOrNull(skillLv - 1);
    if (npHigher != null && !checkSkillScriptCondition(battleData, activator, SkillScriptCond.npHigher, npHigher)) {
      return false;
    }

    final npLower = skillScript.NP_LOWER?.getOrNull(skillLv - 1);
    if (npLower != null && !checkSkillScriptCondition(battleData, activator, SkillScriptCond.npLower, npLower)) {
      return false;
    }

    final starHigher = skillScript.STAR_HIGHER?.getOrNull(skillLv - 1);
    if (starHigher != null &&
        !checkSkillScriptCondition(battleData, activator, SkillScriptCond.starHigher, starHigher)) {
      return false;
    }

    final starLower = skillScript.STAR_LOWER?.getOrNull(skillLv - 1);
    if (starLower != null && !checkSkillScriptCondition(battleData, activator, SkillScriptCond.starLower, starLower)) {
      return false;
    }

    final hpValHigher = skillScript.HP_VAL_HIGHER?.getOrNull(skillLv - 1);
    if (hpValHigher != null &&
        !checkSkillScriptCondition(battleData, activator, SkillScriptCond.hpValHigher, hpValHigher)) {
      return false;
    }

    final hpValLower = skillScript.HP_VAL_LOWER?.getOrNull(skillLv - 1);
    if (hpValLower != null &&
        !checkSkillScriptCondition(battleData, activator, SkillScriptCond.hpValLower, hpValLower)) {
      return false;
    }

    final hpPerHigher = skillScript.HP_PER_HIGHER?.getOrNull(skillLv - 1);
    if (hpPerHigher != null &&
        !checkSkillScriptCondition(battleData, activator, SkillScriptCond.hpPerHigher, hpPerHigher)) {
      return false;
    }

    final hpPerLower = skillScript.HP_PER_LOWER?.getOrNull(skillLv - 1);
    if (hpPerLower != null &&
        !checkSkillScriptCondition(battleData, activator, SkillScriptCond.hpPerLower, hpPerLower)) {
      return false;
    }

    return true;
  }

  Future<bool> activate(
    final BattleData battleData, {
    BattleServantData? activator,
    CommandCardData? card,
    bool defaultToPlayer = true,
    BattleSkillParams? param,
    bool isTransform = false,
  }) async {
    final curSkill = skill;
    if (curSkill == null) {
      return false;
    }
    if (activator?.isEnemy != true) {
      chargeTurn = curSkill.coolDown[skillLv - 1];
    }
    skillScript = curSkill.script;

    final actorTraitMatch = checkSignedIndividualities2(
      myTraits: activator?.getTraits() ?? [],
      requiredTraits: curSkill.actIndividuality,
    );

    final scriptCheck = checkSkillScript(battleData, activator, skillScript, skillLv);

    bool canActSkill = battleData.delegate?.whetherSkill?.call(activator, curSkill) ?? actorTraitMatch && scriptCheck;
    if (!canActSkill) {
      return false;
    }

    if (curSkill.type == SkillType.active) {
      await activator?.activateBuff(battleData, BuffAction.functionSkillBefore);
    }

    final targetedAlly = battleData.getTargetedAlly(activator, defaultToPlayer: defaultToPlayer);
    final targetedEnemy = battleData.getTargetedEnemy(activator, defaultToPlayer: defaultToPlayer);
    final Set<BattleServantData> wouldAffectTargets = {};
    List<NiceFunction> resultFunctions = curSkill.functions;

    // not check branch skill's script
    final branchSkills = skillScript?.condBranchSkillInfo ?? [];
    if (branchSkills.isNotEmpty) {
      for (final branch in branchSkills) {
        if (branch.skillId <= 0) continue;
        switch (branch.condType) {
          case BattleBranchSkillCondBranchType.none:
            break;
          case BattleBranchSkillCondBranchType.isSelfTarget:
            if (activator == null) continue;
            assert(targetedAlly != null);
            if (((branch.condValue.firstOrNull ?? 0) != 0) != (activator.uniqueId == targetedAlly?.uniqueId)) {
              continue;
            }
            break;
          case BattleBranchSkillCondBranchType.individuality:
            if (!Individuality.checkSignedIndivPartialMatch(
              self: activator?.getTraits(),
              signedTarget: branch.condValue,
            )) {
              continue;
            }
            break;
        }
        final branchSkill = await AtlasApi.baseSkill(branch.skillId);
        if (branchSkill == null) {
          battleData.battleLogger.error(
            'Skill ${skill?.id} condBranchSkillInfo: branch skill ${branch.skillId} not found',
          );
        } else {
          resultFunctions = branchSkill.functions;
        }
        break;
      }
    }

    for (final func in resultFunctions) {
      if (!FunctionExecutor.validateFunctionTargetTeam(func, activator?.isPlayer ?? defaultToPlayer)) continue;

      wouldAffectTargets.addAll(
        await FunctionExecutor.acquireFunctionTarget(
          battleData,
          func.funcTargetType,
          activator,
          targetedAlly: targetedAlly,
          targetedEnemy: targetedEnemy,
          defaultToPlayer: defaultToPlayer,
        ),
      );
    }
    for (final svt in wouldAffectTargets) {
      await svt.activateBuff(battleData, BuffAction.functionSkillTargetedBefore, skillInfo: this);
    }

    int? selectedActionIndex;
    if (skillScript != null && skillScript!.SelectAddInfo != null && skillScript!.SelectAddInfo!.isNotEmpty) {
      if (battleData.delegate?.skillActSelect != null) {
        selectedActionIndex = await battleData.delegate!.skillActSelect!(activator);
      } else if (battleData.mounted) {
        selectedActionIndex = await SkillActSelectDialog.show(battleData, activator, curSkill, skillLv);
        battleData.replayDataRecord.skillActSelectSelections.add(selectedActionIndex);
      }
    }
    param?.selectAddIndex = selectedActionIndex;
    int effectiveness = 1000;
    if (type == SkillInfoType.masterEquip) {
      final highestValuePerGroup = <int, int>{};
      for (final svt in battleData.nonnullPlayers) {
        effectiveness += await svt.getBuffValue(
          battleData,
          BuffAction.masterSkillValueUp,
          highestValuePerGroup: highestValuePerGroup,
        );
      }
    }

    await FunctionExecutor.executeFunctions(
      battleData,
      resultFunctions,
      skillLv,
      activator: activator,
      targetedAlly: targetedAlly,
      targetedEnemy: targetedEnemy,
      card: card,
      script: skillScript,
      skillType: curSkill.type,
      skillInfoType: type,
      selectedActionIndex: selectedActionIndex,
      effectiveness: effectiveness,
      defaultToPlayer: defaultToPlayer,
      param: param,
      isTransform: isTransform,
    );

    if (curSkill.type == SkillType.active) {
      await activator?.activateBuff(battleData, BuffAction.functionSkillAfter);
      await activator?.activateBuff(battleData, BuffAction.functionSkillAfterMainOnly);
    }
    for (final svt in wouldAffectTargets) {
      if (type == SkillInfoType.commandSpell) {
        final csId = resultFunctions.firstOrNull?.svals.firstOrNull?.CommandSpellId;
        if (csId == 1 || csId == 9) {
          await svt.activateBuff(battleData, BuffAction.functionClassboardCommandSpellAfter, skillInfo: this);
        }
      }
    }

    for (final svt in battleData.nonnullActors) {
      await svt.activateBuff(
        battleData,
        BuffAction.functionedFunction,
        receivedFunctionsList: svt.receivedFunctionsList,
      );
    }
    return true;
  }

  BattleSkillInfoData copy() {
    return BattleSkillInfoData(_baseSkill, type: type, provisionedSkills: _provisionedSkills, skillNum: skillNum)
      ..rankUps = rankUps
      ..rankUp = rankUp
      ..skillLv = skillLv
      ..skillScript = skillScript
      ..chargeTurn = chargeTurn;
  }

  static bool checkSkillScriptCondition(
    final BattleData battleData,
    final BattleServantData? activator,
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
        return activator != null && activator.np / 100 >= value;
      case SkillScriptCond.npLower:
        return activator != null && activator.np / 100 <= value;
      case SkillScriptCond.starHigher:
        return battleData.criticalStars >= value;
      case SkillScriptCond.starLower:
        return battleData.criticalStars <= value;
      case SkillScriptCond.hpValHigher:
        return activator != null && activator.hp >= value;
      case SkillScriptCond.hpValLower:
        return activator != null && activator.hp >= value;
      case SkillScriptCond.hpPerHigher:
        return activator != null && activator.hp / activator.maxHp >= value / 1000;
      case SkillScriptCond.hpPerLower:
        return activator != null && activator.hp / activator.maxHp <= value / 1000;
    }
  }
}

// public enum BattleSkillInfoData.TYPE
// {
// 	NONE = 0,
// 	MASTER_EQUIP = 1,
// 	MASTER_COMMAND = 2,
// 	SERVANT_CLASS = 10,
// 	SERVANT_SELF = 11,
// 	SERVANT_EQUIP = 12,
// 	TEMP = 20,
// 	BOOST = 21,
// 	COMMAND_CODE = 22,
// 	COMMAND_ASSIST = 23,
// 	TEMP_EFFECT_SQUARE = 100,
// 	WARBOARD_PARTY_SKILL = 101,
// }
enum SkillInfoType {
  none,
  masterEquip,
  commandSpell,
  svtClassPassive,
  svtOtherPassive,
  svtSelf,
  svtEquip,
  commandCode,
  fieldAi,
  svtAi,
  custom,
  skillAdditional,
  classBoardSkill,
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
        funcTargetTeam: FuncApplyTarget.all,
        svals: [
          DataVals({'Rate': 1000, 'Value': 1000, 'Unaffected': 1, "CommandSpellId": 1}),
        ],
      ),
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
          DataVals({'Rate': 3000, 'Value': 10000, 'Unaffected': 1, "CommandSpellId": 9}),
        ],
      ),
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
        funcTargetTeam: FuncApplyTarget.all,
        svals: [
          DataVals({'Rate': 5000, 'Value': 10000, 'Unaffected': 1, "CommandSpellId": 1001}),
        ],
      ),
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
        funcTargetTeam: FuncApplyTarget.all,
        funcPopupText: '即死',
        svals: [
          DataVals({'Rate': 5000}),
        ],
      ),
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
        funcTargetTeam: FuncApplyTarget.all,
        funcPopupText: '遅延発動(即死)',
        buffs: [
          Buff(
            id: 3631,
            name: "遅延発動(即死)",
            detail: "ターン終了時に即死する状態を付与",
            icon: "https://static.atlasacademy.io/JP/BuffIcons/bufficon_525.png",
            type: BuffType.delayFunction,
            buffGroup: 0,
          ),
        ],
        svals: [
          DataVals({'Rate': 5000, "Turn": 1, "Count": -1, "Value": 966262, "Value2": 1}),
        ],
      ),
    ],
  );
}
