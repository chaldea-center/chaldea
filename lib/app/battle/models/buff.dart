import 'package:chaldea/app/battle/models/battle.dart';
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

  bool get isActive => count != 0 && turn != 0;

  int actorUniqueId = 0;
  String actorName = '';
  bool isUsed = false;
  bool isShortBuff = false;

  bool passive = false;
  bool irremovable = false;

  // ignore: unused_field
  bool isDecide = false;
  int paramAdd = 0;
  int paramMax = 0;
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
  }

  BuffData.makeCopy(this.buff, this.vals);

  List<NiceTrait> get traits => [
        ...buff.vals,
        if (vals.AddIndividualty != null && vals.AddIndividualty! > 0) NiceTrait(id: vals.AddIndividualty!)
      ];

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return containsAnyTraits(traits, requiredTraits);
  }

  bool shouldApplyBuff(final BattleData battleData, final bool isTarget) {
    final int? checkIndvType = buff.script?.checkIndvType;
    final targetCheck = isTarget
        ? battleData.checkActivatorTraits(buff.ckOpIndv, checkIndivType: checkIndvType) &&
            battleData.checkTargetTraits(buff.ckSelfIndv, checkIndivType: checkIndvType)
        : battleData.checkTargetTraits(buff.ckOpIndv, checkIndivType: checkIndvType) &&
            battleData.checkActivatorTraits(buff.ckSelfIndv, checkIndivType: checkIndvType);

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
      ..actorUniqueId = actorUniqueId
      ..actorName = actorName
      ..isUsed = isUsed
      ..irremovable = irremovable
      ..passive = passive
      ..isShortBuff = isShortBuff;
    return copy;
  }
}
