import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

const kExtendTurnBuffTypes = <int>[
  // /export/JP/NiceConstantStr.json
  1, 9, 11, 13, 15, 18, 25, 50, 51, 52, 70, 72, 89, 90, 110, 112, 116, 121, 137, 144, 148, 160, 162
];

class AddState {
  AddState._();

  static Future<void> addState(
    final BattleData battleData,
    final Buff buff,
    final int funcId,
    final DataVals dataVals,
    final List<BattleServantData> targets, {
    final List<NiceTd?>? tdSelections,
    bool isPassive = false,
    final bool isShortBuff = false,
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
        ..actorUniqueId = activator?.uniqueId
        ..actorName = activator?.lBattleName
        ..notActorPassive = notActorPassive
        ..irremovable |= isPassive || notActorPassive;
      if (isShortBuff) {
        buffData.logicTurn -= 1;
      }
      // enemy Bazett may not contains niceSvt
      if (target.niceSvt?.script?.svtBuffTurnExtend == true || target.svtId == 1001100) {
        if (kExtendTurnBuffTypes.contains(buff.type.id)) {
          buffData.logicTurn += 1;
        }
      }

      if (buff.type == BuffType.tdTypeChange) {
        buffData.tdSelection = tdSelections![i];
      } else if (buff.type == BuffType.tdTypeChangeArts ||
          buff.type == BuffType.tdTypeChangeQuick ||
          buff.type == BuffType.tdTypeChangeBuster) {
        final baseTd = target.getBaseTD();
        final changeCardType = {
          BuffType.tdTypeChangeArts: CardType.arts,
          BuffType.tdTypeChangeBuster: CardType.buster,
          BuffType.tdTypeChangeQuick: CardType.quick,
        }[buff.type]!;
        if (baseTd != null) {
          final changeTdIds = baseTd.script?.tdTypeChangeIDs ?? [];
          final List<NiceTd> localTds = [];
          if (target.isPlayer) {
            localTds.addAll(target.niceSvt!.noblePhantasms);
          } else {
            final td = target.niceEnemy!.noblePhantasm.noblePhantasm;
            if (td != null) localTds.add(td);
          }

          /// for Summer Barghest, tdTypeChangeIDs=[changeTdid, baseTdId], both are Arts
          for (final tdId in changeTdIds) {
            NiceTd? td = localTds.firstWhereOrNull((e) => e.id == tdId);
            // todo: add svtId
            td ??= await AtlasApi.td(tdId);
            if (td != null && td.card == changeCardType) {
              buffData.tdSelection = td;
              break;
            }
          }
        }
      } else if (buff.type == BuffType.upDamageEventPoint) {
        final pointBuff = battleData.options.pointBuffs.values
            .firstWhereOrNull((pointBuff) => pointBuff.funcIds.isEmpty || pointBuff.funcIds.contains(funcId));
        if (pointBuff == null) {
          continue;
        }
        buffData.param += pointBuff.value;
      }

      await battleData.withBuff(buffData, () async {
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

        await battleData.withTarget(target, () async {
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
              target.gainHp(battleData, toModifier(target.getMaxHp(battleData) * dataVals.Value!).toInt());
            } else if (buff.type == BuffType.downMaxhp) {
              target.lossHp(toModifier(target.getMaxHp(battleData) * dataVals.Value!).toInt());
            }
          }
        });
      });
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
    if (functionRate < 0 && battleData.uniqueIdToFuncResultsList.lastOrNull?[target.uniqueId] != true) {
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
