import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> auraBuffList = [];

  List<BuffData> get allBuffs => [...passiveList, ...activeList];

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
}

class BuffData {
  Buff buff;

  // ignore: unused_field
  DataVals? _vals;

  //
  int count = -1;
  int turn = -1;
  int param = 0;
  int additionalParam = 0;
  bool isUsed = false;
  bool passive = false;

  bool get isActive => count != 0 && turn != 0;
  bool isDecide = false;
  List<int> vals = [];
  int buffRate = 1000;
  int paramAdd = 0;
  int paramMax = 0;
  int onField = 0;
  int auraEffectId = -1;
  int actorUniqueId = 0;
  int ratioHpHigh = 0;
  int ratioHpLow = 0;
  int ratioRangeHigh = 0;
  int ratioRangeLow = 0;
  int userCommandCodeId = -1;
  bool isActiveCC = false;
  List<int> targetSkill = [];
  int state = 0;
  bool irremovable = false;
  bool isShortBuff = false;

  // may not need this field.
  // Intent is to check should remove passive when transforming servants to only remove actor's passive
  // Default to Hyde's passive not ever added, which means we don't do any passive cleaning logic in transform script
  bool notActorPassive = false;

  bool get isOnField => onField == 1;

  BuffData(this.buff, DataVals dataVals) {
    count = dataVals.Count ?? -1;
    turn = dataVals.Turn ?? -1;
    param = dataVals.Value ?? 0;
    additionalParam = dataVals.Value2 ?? 0;
    buffRate = dataVals.UseRate ?? 1000;
    ratioHpHigh = dataVals.RatioHPHigh ?? 0;
    ratioHpLow = dataVals.RatioHPLow ?? 0;
    ratioRangeHigh = dataVals.RatioHPRangeHigh ?? 0;
    ratioRangeLow = dataVals.RatioHPRangeLow ?? 0;
    irremovable = dataVals.UnSubState == 1; // need more sample
    onField = dataVals.OnField ?? 0;

    if (dataVals.SkillID != null) {
      param = dataVals.SkillID!;
      additionalParam = dataVals.SkillLV!;
    }
  }

  List<NiceTrait> get traits => buff.vals;

  bool checkTraits(final Iterable<NiceTrait> requiredTraits) {
    return containsAnyTraits(traits, requiredTraits);
  }

  bool shouldApplyAsTarget(final BattleData battleData) {
    return battleData.checkActivatorTraits(buff.ckOpIndv) && battleData.checkTargetTraits(buff.ckSelfIndv);
  }

  bool shouldApplyAsActivator(final BattleData battleData) {
    return battleData.checkTargetTraits(buff.ckOpIndv) && battleData.checkActivatorTraits(buff.ckSelfIndv);
  }

  bool shouldApplyBuff(final BattleData battleData, final bool isTarget) {
    final targetCheck =
        (isTarget && shouldApplyAsTarget(battleData)) || (!isTarget && shouldApplyAsActivator(battleData));

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
}
