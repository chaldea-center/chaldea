import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> commandCodeList = [];
  List<BuffData> auraBuffList = [];

  List<BuffData> get allBuffs => [...passiveList, ...activeList, ...commandCodeList];

  bool get isSelectable =>
      allBuffs.every((buff) => !buff.traits.map((trait) => trait.id).contains(Trait.cantBeSacrificed.id));

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return allBuffs.any((buff) => buff.checkTraits(requiredTraits));
  }

  void turnEndShort() {
    allBuffs.forEach((buff) {
      if (buff.isShortBuff) buff.turnPass();
    });
  }

  void turnEndLong() {
    allBuffs.forEach((buff) {
      if (!buff.isShortBuff) buff.turnPass();
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

      if (vals.ParamAddValue != null) {
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
          checkTargetBuff: checkTargetBuff,
          activeOnly: activeOnly,
          ignoreIrremovable: ignoreIrremovable,
          checkIndivType: checkIndvType,
          includeIgnoredTrait: includeIgnoredTrait,
        ) &&
        battleData.checkTraits(
          selfIndv,
          isTarget,
          checkTargetBuff: checkTargetBuff || iTieTrait != null,
          activeOnly: activeOnly,
          ignoreIrremovable: ignoreIrremovable,
          checkIndivType: checkIndvType,
          includeIgnoredTrait: includeIgnoredTrait,
          includeFieldTrait: iTieTrait != null,
        );

    final onFieldCheck = !isOnField || battleData.isActorOnField(actorUniqueId);

    final probabilityCheck = buffRate >= battleData.probabilityThreshold;

    final scriptCheck = checkScript(battleData, targetCheck);

    return targetCheck && onFieldCheck && probabilityCheck && scriptCheck;
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

    if (script.UpBuffRateBuffIndiv != null &&
        battleData.currentBuff != null &&
        battleData.currentBuff!.checkTraits(script.UpBuffRateBuffIndiv!)) {
      return true;
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
    return param != 0
        ? buff.type == BuffType.regainStar || additionalParam != 0 //  use to check skill related buff
            ? param.toString()
            : '${(param / 10).toStringAsFixed(1)} % '
        : '';
  }

  String durationString() {
    final List<String> durationString = [];
    if (count > 0) {
      durationString.add('$count ${S.current.battle_buff_times}');
    }
    if (turn > 0) {
      durationString.add('$turn ${S.current.battle_buff_turns}');
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
