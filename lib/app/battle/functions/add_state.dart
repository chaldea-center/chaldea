import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

class AddState {
  AddState._();

  static Future<void> addState(
    final BattleData battleData,
    final Buff buff,
    final DataVals dataVals,
    final List<BattleServantData> targets, {
    final List<NiceTd?>? tdSelections,
    bool isPassive = false,
    final bool notActorPassive = false,
    final bool isCommandCode = false,
  }) async {
    final activator = battleData.activator;
    if (dataVals.ProcActive == 1) {
      isPassive = false;
    } else if (dataVals.ProcPassive == 1) {
      isPassive = true;
    }
    for (int i = 0; i < targets.length; i += 1) {
      final target = targets[i];
      final buffData = BuffData(buff, dataVals)
        ..actorUniqueId = activator?.uniqueId ?? 0
        ..actorName = activator?.lBattleName ?? ''
        ..notActorPassive = notActorPassive
        ..isShortBuff = battleData.curFunc?.funcType == FuncType.addStateShort
        ..irremovable |= isPassive || notActorPassive;

      if (buff.type == BuffType.tdTypeChange) {
        buffData.tdSelection = tdSelections![i];
      } else if (buff.type == BuffType.upDamageEventPoint) {
        final pointBuff = battleData.options.pointBuffs.values.firstWhereOrNull(
            (pointBuff) => pointBuff.funcIds.isEmpty || pointBuff.funcIds.contains(battleData.curFunc?.funcId));
        if (pointBuff == null) {
          continue;
        }
        buffData.param += pointBuff.value;
      }

      battleData.setCurrentBuff(buffData);
      final convertBuff = target
          .getFirstBuffOnActions(battleData, [BuffAction.buffConvert])
          ?.buff
          .script
          ?.convert
          ?.convertBuffs
          .firstOrNull;
      if (convertBuff != null) {
        buffData.buff = convertBuff;
      }

      battleData.setTarget(target);
      if (await shouldAddState(battleData, dataVals, activator, target, isCommandCode) &&
          target.isBuffStackable(buffData.buff.buffGroup) &&
          checkSameBuffLimitNum(target, dataVals)) {
        target.addBuff(
          buffData,
          isPassive: isPassive || notActorPassive,
          isCommandCode: isCommandCode,
        );
        battleData.curFuncResults[target.uniqueId] = true;

        if (buff.type == BuffType.addMaxhp) {
          target.gainHp(battleData, dataVals.Value!);
        } else if (buff.type == BuffType.subMaxhp) {
          target.lossHp(dataVals.Value!);
        } else if (buff.type == BuffType.upMaxhp) {
          target.gainHp(battleData, toModifier(target.maxHp * dataVals.Value!).toInt());
        } else if (buff.type == BuffType.downMaxhp) {
          target.lossHp(toModifier(target.maxHp * dataVals.Value!).toInt());
        }
      }
      battleData.unsetTarget();
      battleData.unsetCurrentBuff();
    }
  }

  static bool checkSameBuffLimitNum(
    final BattleServantData target,
    final DataVals dataVals,
  ) {
    return dataVals.SameBuffLimitNum == null ||
        dataVals.SameBuffLimitNum! >
            target.countBuffWithTrait([NiceTrait(id: dataVals.SameBuffLimitTargetIndividuality!)]);
  }

  static Future<bool> shouldAddState(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
    final bool isCommandCode,
  ) async {
    if (dataVals.ForceAddState == 1 || isCommandCode) {
      return true;
    }

    int functionRate = dataVals.Rate ?? 1000;
    if ((functionRate < 0 || dataVals.TriggeredFuncPosition != null) &&
        battleData.uniqueIdToLastFuncResultMap.values.any((succeeded) => !succeeded)) {
      return false;
    }

    functionRate = functionRate.abs();

    if (await target.hasBuffOnAction(battleData, BuffAction.avoidState)) {
      battleData.battleLogger.debug('${S.current.effect_target}: ${target.lBattleName} - ${S.current.battle_invalid}');
      return false;
    }

    final buffReceiveChance = await target.getBuffValueOnAction(battleData, BuffAction.resistanceState);
    final buffChanceDetails = ConstData.buffActions[BuffAction.grantState]!;
    final buffChance = await activator?.getBuffValueOnAction(battleData, BuffAction.grantState) ??
        capBuffValue(buffChanceDetails, 0, Maths.min(buffChanceDetails.maxRate));

    final activationRate = functionRate + buffChance;
    final resistRate = buffReceiveChance;

    final success = await battleData.canActivateFunction(activationRate - resistRate);

    final resultsString = success
        ? S.current.success
        : resistRate > 0
            ? 'GUARD'
            : 'MISS';

    battleData.battleLogger.debug('${S.current.effect_target}: ${target.lBattleName} - '
        '$resultsString'
        '${battleData.options.tailoredExecution ? '' : ' [($activationRate - $resistRate) vs ${battleData.options.probabilityThreshold}]'}');

    return success;
  }
}
