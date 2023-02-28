import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> auraBuffList = [];

  List<BuffData> get allBuffs => [...passiveList, ...activeList];

  bool get isSelectable =>
      allBuffs.any((buff) => buff.traits.map((trait) => trait.id).contains(Trait.cantBeSacrificed.id));

  List<BuffData> collectBuffPerAction(BuffAction buffAction) {
    final actionDetails = db.gameData.constData.buffActions[buffAction];
    if (actionDetails == null) {
      return [];
    }
    List<BuffType> buffTypes = [];
    buffTypes.addAll(actionDetails.plusTypes);
    buffTypes.addAll(actionDetails.minusTypes);

    return collectBuffPerType(buffTypes);
  }

  List<BuffData> collectBuffPerType(Iterable<BuffType> buffTypes) {
    List<BuffData> collectedBuffs = [];
    for (BuffData buffData in allBuffs) {
      if (buffTypes.contains(buffData.buff!.type)) {
        collectedBuffs.add(buffData);
      }
    }

    return collectedBuffs;
  }
}

class BuffData {
  Buff? buff;

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

  BuffData(Buff this.buff, DataVals dataVals) {
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
  }

  List<NiceTrait> get traits => buff?.vals ?? [];

  bool shouldApplyAsTarget(BattleData battleData) {
    return checkTrait(battleData.getActivatorTraits(), buff!.ckOpIndv) &&
        checkTrait(battleData.getTargetTraits(), buff!.ckSelfIndv);
  }

  bool shouldApplyAsActivator(BattleData battleData) {
    return checkTrait(battleData.getTargetTraits(), buff!.ckOpIndv) &&
        checkTrait(battleData.getActivatorTraits(), buff!.ckSelfIndv);
  }

  bool shouldApplyBuff(BattleData battleData, bool isTarget) {
    final targetCheck =
        (isTarget && shouldApplyAsTarget(battleData)) || (!isTarget && shouldApplyAsActivator(battleData));

    final onFieldCheck = !isOnField || battleData.isActorOnField(actorUniqueId);

    final probabilityCheck = buffRate >= battleData.probabilityThreshold;

    final scriptCheck = checkScript(battleData, targetCheck);

    return targetCheck && onFieldCheck && probabilityCheck && scriptCheck;
  }

  bool checkScript(BattleData battleData, bool isTarget) {
    if (buff!.script == null) {
      return true;
    }

    // TODO (battle): conditional buffs check scripts here
    return true;
  }

  bool canStack(int buffGroup) {
    return buffGroup == 0 || buffGroup != buff!.buffGroup;
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
}
