import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/models.dart';

class BattleBuff {
  List<BuffData> passiveList = [];
  List<BuffData> activeList = [];
  List<BuffData> auraBuffList = [];

  List<BuffData> get allBuffs =>
      [passiveList, activeList, auraBuffList].fold([], (results, buffList) => results..addAll(buffList));

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
  bool isUse = false;
  bool passive = false;
  bool isAct = false;
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

  bool get isOnField => onField == 1;

  BuffData(Buff this.buff, DataVals dataVals) {
    count = dataVals.Count ?? -1;
    turn = dataVals.Turn ?? -1;
    param = dataVals.Value ?? 0;
    buffRate = dataVals.Rate ?? 1000;
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

  bool canStack(int buffGroup) {
    return buffGroup == 0 || buffGroup != buff!.buffGroup;
  }
}
