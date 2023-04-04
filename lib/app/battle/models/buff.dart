import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/descriptors/func/vals.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> commandCodeList = [];
  List<BuffData> auraBuffList = [];

  List<BuffData> get allBuffs => [...passiveList, ...activeList, ...commandCodeList];

  List<BuffData> get shownBuffs => [
        for (final buff in passiveList)
          if (buff.vals.SetPassiveFrame == 1 || (buff.vals.ShowState ?? 0) >= 1) buff,
        ...activeList,
      ];

  bool get isSelectable =>
      allBuffs.every((buff) => !buff.traits.map((trait) => trait.id).contains(Trait.cantBeSacrificed.id));

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return allBuffs.any((buff) => buff.checkTraits(requiredTraits));
  }

  void turnEndShort() {
    allBuffs.forEach((buff) {
      if (buff.isShortBuff && buff.shouldDecreaseTurn) buff.turnPass();
    });
  }

  void turnEndLong() {
    allBuffs.forEach((buff) {
      if (!buff.isShortBuff && buff.shouldDecreaseTurn) buff.turnPass();
    });
  }

  void clearPassive(final int uniqueId) {
    passiveList.removeWhere((buff) => buff.actorUniqueId == uniqueId);
  }

  BattleBuff copy() {
    final copy = BattleBuff()
      ..passiveList = passiveList.map((e) => e.copy()).toList()
      ..activeList = activeList.map((e) => e.copy()).toList()
      ..commandCodeList = commandCodeList.map((e) => e.copy()).toList()
      ..auraBuffList = auraBuffList.map((e) => e.copy()).toList();
    return copy;
  }
}

class BuffData {
  Buff buff;
  DataVals vals;

  int buffRate = 1000;
  int count = -1;
  int turn = -1;
  bool shouldDecreaseTurn = false;
  int param = 0;
  int additionalParam = 0;
  NiceTd? tdSelection;

  bool get isActive => count != 0 && turn != 0;

  int actorUniqueId = 0;
  String actorName = '';
  bool isUsed = false;
  bool isShortBuff = false;

  bool passive = false;
  bool irremovable = false;

  // ignore: unused_field
  bool isDecide = false;
  int userCommandCodeId = -1;
  List<int> targetSkill = [];
  int state = 0;
  int auraEffectId = -1;
  bool isActiveCC = false;

  // may not need this field.
  // Intent is to check should remove passive when transforming servants to only remove actor's passive
  // Default to Hyde's passive not ever added, which means we don't do any passive cleaning logic in transform script
  bool notActorPassive = false;

  bool get isOnField => vals.OnField == 1;

  BuffData(this.buff, this.vals) {
    count = vals.Count ?? -1;
    turn = vals.Turn ?? -1;
    param = vals.Value ?? 0;
    additionalParam = vals.Value2 ?? 0;
    buffRate = vals.UseRate ?? 1000;
    irremovable = vals.UnSubState == 1; // need more sample

    if (vals.SkillID != null) {
      param = vals.SkillID!;
      additionalParam = vals.SkillLV!;
    }
  }

  BuffData.makeCopy(this.buff, this.vals);

  List<NiceTrait> get traits => [
        ...buff.vals,
        if (vals.AddIndividualty != null && vals.AddIndividualty! > 0) NiceTrait(id: vals.AddIndividualty!)
      ];

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return containsAnyTraits(traits, requiredTraits);
  }

  static final List<BuffType> activeOnlyTypes = [
    BuffType.upDamageIndividualityActiveonly,
    BuffType.downDamageIndividualityActiveonly,
  ];

  static final List<BuffType> buffTraitCheckTypes = [
    BuffType.upDamageIndividuality,
    BuffType.downDamageIndividuality,
    ...activeOnlyTypes,
    BuffType.preventDeathByDamage,
  ];

  int getValue(final BattleData battleData, final bool isTarget) {
    int addValue = 0;
    if (vals.ParamAddValue != null) {
      int addCount = 0;
      if (vals.ParamAddSelfIndividuality != null) {
        final targetTraits = vals.ParamAddSelfIndividuality!.map((e) => NiceTrait(id: e)).toList();
        addCount += isTarget
            ? battleData.target!.countTrait(battleData, targetTraits)
            : battleData.activator!.countTrait(battleData, targetTraits);
      }
      if (vals.ParamAddOpIndividuality != null) {
        final targetTraits = vals.ParamAddOpIndividuality!.map((e) => NiceTrait(id: e)).toList();
        addCount += isTarget
            ? battleData.activator!.countTrait(battleData, targetTraits)
            : battleData.target!.countTrait(battleData, targetTraits);
      }
      if (vals.ParamAddMaxCount != null) {
        addCount = min(addCount, vals.ParamAddMaxCount!);
      }

      addValue = addCount * vals.ParamAddValue!;

      if (vals.ParamAddMaxValue != null) {
        addValue = min(addValue, vals.ParamAddMaxValue!);
      }
    }

    int baseParam = param;
    if (vals.RatioHPLow != null || vals.RatioHPHigh != null) {
      final lowerBound = vals.RatioHPHigh ?? 0;
      final upperBound = vals.RatioHPLow ?? 0;
      final addition = upperBound - lowerBound;
      final maxHpRatio = vals.RatioHPRangeHigh ?? 1000;
      final minHpRatio = vals.RatioHPRangeLow ?? 0;
      final currentHpRatio = ((battleData.activator!.hp / battleData.activator!.getMaxHp(battleData)) * 1000).toInt();

      final appliedBase = currentHpRatio > maxHpRatio ? 0 : lowerBound;
      final additionPercent = (maxHpRatio - currentHpRatio.clamp(minHpRatio, maxHpRatio)) / (maxHpRatio - minHpRatio);

      baseParam += appliedBase + (addition * additionPercent).toInt();
    }

    return baseParam + addValue;
  }

  bool shouldApplyBuff(final BattleData battleData, final bool isTarget) {
    final int? checkIndvType = buff.script?.checkIndvType;
    final int? includeIgnoredTrait = buff.script?.IncludeIgnoreIndividuality;
    final bool checkTargetBuff = buffTraitCheckTypes.contains(buff.type);
    final bool activeOnly = activeOnlyTypes.contains(buff.type);
    final bool ignoreIrremovable = vals.IgnoreIndivUnreleaseable == 1;
    final NiceTrait? iTieTrait = buff.script?.INDIVIDUALITIE;
    final List<NiceTrait> selfIndv = buff.ckSelfIndv.toList();
    if (iTieTrait != null) selfIndv.add(iTieTrait);
    final targetCheck = battleData.checkTraits(
          buff.ckOpIndv,
          !isTarget,
          checkTargetBuff: checkTargetBuff || buff.script?.CheckOpponentBuffTypes != null,
          activeOnly: activeOnly,
          ignoreIrremovable: ignoreIrremovable,
          checkIndivType: checkIndvType,
          includeIgnoredTrait: includeIgnoredTrait,
        ) &&
        battleData.checkTraits(
          selfIndv,
          isTarget,
          checkTargetBuff: checkTargetBuff,
          activeOnly: activeOnly,
          ignoreIrremovable: ignoreIrremovable,
          checkIndivType: checkIndvType,
          includeIgnoredTrait: includeIgnoredTrait,
          individualitie: iTieTrait != null,
        );

    final onFieldCheck = !isOnField || battleData.isActorOnField(actorUniqueId);

    final scriptCheck = checkScript(battleData, targetCheck);

    return targetCheck && onFieldCheck && scriptCheck;
  }

  Future<bool> shouldActivateBuff(final BattleData battleData, final bool isTarget) async {
    final probabilityCheck = await battleData.canActivate(
        buffRate,
        '${battleData.activator?.lBattleName ?? S.current.battle_no_source}'
        ' - ${buff.lName.l}');

    if (buffRate < 1000) {
      battleData.battleLogger.debug('${battleData.activator?.lBattleName ?? S.current.battle_no_source}'
          ' - ${buff.lName.l}: ${probabilityCheck ? S.current.success : S.current.failed}'
          '${battleData.tailoredExecution ? '' : ' [$buffRate vs ${battleData.probabilityThreshold}]'}');
    }

    return shouldApplyBuff(battleData, isTarget) && probabilityCheck;
  }

  bool checkScript(final BattleData battleData, final bool isTarget) {
    if (buff.script == null) {
      return true;
    }

    final script = buff.script!;

    if (vals.OnFieldCount == -1) {
      final includeIgnoredTrait = script.IncludeIgnoreIndividuality! == 1;
      final List<BattleServantData> allies =
          battleData.activator?.isPlayer ?? true ? battleData.nonnullAllies : battleData.nonnullEnemies;

      if (allies
          .where((svt) =>
              svt != battleData.activator &&
              svt.checkTrait(battleData, script.TargetIndiv!, checkBuff: includeIgnoredTrait))
          .isNotEmpty) {
        return false;
      }
    }

    if (script.UpBuffRateBuffIndiv != null && battleData.currentBuff != null) {
      if (!battleData.currentBuff!.checkTraits(script.UpBuffRateBuffIndiv!)) {
        return false;
      }
    }

    if (script.HP_HIGHER != null && battleData.activator != null) {
      final int hpRatio = (battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) * 1000).toInt();
      if (hpRatio < script.HP_HIGHER!) {
        return false;
      }
    }

    if (script.HP_LOWER != null && battleData.activator != null) {
      final int hpRatio = (battleData.activator!.hp / battleData.activator!.getMaxHp(battleData) * 1000).toInt();
      if (hpRatio > script.HP_LOWER!) {
        return false;
      }
    }

    if (script.convert != null &&
        battleData.currentBuff != null &&
        script.convert!.convertType == BuffConvertType.buff) {
      final Map<String, dynamic> targetBuffs = script.convert!.targets.first;
      final int buffId = targetBuffs.values.first;
      if (buffId != battleData.currentBuff!.buff.id) {
        return false;
      }
    }

    return true;
  }

  bool canStack(final int buffGroup) {
    return buffGroup == 0 || buffGroup != buff.buffGroup;
  }

  void setUsed() {
    isUsed = true;
  }

  void useOnce() {
    isUsed = false;
    if (count > 0) {
      count -= 1;
    }
  }

  void turnPass() {
    if (vals.ParamAdd != null) {
      param += vals.ParamAdd!;
      param = param.clamp(0, vals.ParamMax!);
    }
    if (turn > 0) {
      turn -= 1;
    }
  }

  String effectString() {
    return '${buffRate != 1000 ? '${(buffRate / 10).toStringAsFixed(1)} %' : ''} '
        '${buff.lName.l} '
        '${buff.ckSelfIndv.isNotEmpty ? '${S.current.battle_require_self_traits} '
            '${buff.ckSelfIndv.map((trait) => trait.shownName())} ' : ''}'
        '${buff.ckOpIndv.isNotEmpty ? '${S.current.battle_require_opponent_traits} '
            '${buff.ckOpIndv.map((trait) => trait.shownName())} ' : ''}'
        '${getParamString()}'
        '${isOnField ? S.current.battle_require_actor_on_field(actorName) : ''}';
  }

  String getParamString() {
    final List<String> effectString = [];
    ValDsc.describeBuff(effectString, buff, vals, inList: false, ignoreCount: true);
    return effectString.join(' ');
  }

  String durationString() {
    final List<String> durationString = [];
    if (count > 0) {
      durationString.add(Transl.special.funcValCountTimes(count));
    }
    if (turn > 0) {
      durationString.add(Transl.special.funcValTurns(turn));
    }
    if (durationString.isEmpty) {
      durationString.add(S.current.battle_buff_permanent);
    }

    return durationString.join(', ');
  }

  BuffData copy() {
    final BuffData copy = BuffData.makeCopy(buff, vals)
      ..buffRate = buffRate
      ..count = count
      ..turn = turn
      ..shouldDecreaseTurn = shouldDecreaseTurn
      ..param = param
      ..additionalParam = additionalParam
      ..tdSelection = tdSelection
      ..actorUniqueId = actorUniqueId
      ..actorName = actorName
      ..isUsed = isUsed
      ..irremovable = irremovable
      ..passive = passive
      ..isShortBuff = isShortBuff;
    return copy;
  }
}
