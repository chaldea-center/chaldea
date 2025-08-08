import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import '../interactions/td_type_change_selector.dart';

class AddState {
  AddState._();

  static Future<void> addState(
    final BattleData battleData,
    final Buff buff,
    final int funcId,
    final DataVals dataVals,
    final BattleServantData? activator,
    final List<BattleServantData> targets, {
    final bool isShortBuff = false,
    final SelectTreasureDeviceInfo? selectTreasureDeviceInfo,
    final SkillType? skillType,
    final SkillInfoType? skillInfoType,
  }) async {
    final isClassPassive = skillInfoType == SkillInfoType.svtClassPassive;
    final isCommandCode = skillInfoType == SkillInfoType.commandCode;

    // skillInfoType != null means it's from a proper skill. Otherwise the concept of passive doesn't apply
    // e.g. from trigger buffs
    bool isPassive = skillType == SkillType.passive && skillInfoType != null;
    if (dataVals.ProcActive == 1) {
      isPassive = false;
    } else if (dataVals.ProcPassive == 1) {
      isPassive = true;
    }
    for (final target in targets) {
      final buffData = BuffData(
        buff: buff,
        vals: dataVals,
        addOrder: battleData.getNextAddOrder(),
        activatorUniqueId: activator?.uniqueId,
        activatorName: activator?.lBattleName,
        passive: isPassive,
        skillInfoType: skillInfoType,
      );

      // Processing logicTurn related logic
      if (isShortBuff) {
        buffData.logicTurn -= 1;
      }
      // enemy Bazett may not contains niceSvt
      if (target.niceSvt?.script?.svtBuffTurnExtend == true || target.svtId == 1001100) {
        if (ConstData.constantStr.extendTurnBuffType.contains(buff.type.value)) {
          buffData.logicTurn += 1;
        }
      }

      final isOpponentTurn = target.isPlayer != battleData.isPlayerTurn;
      if (isOpponentTurn) {
        if (dataVals.ExtendBuffHalfTurnInOpponentTurn == 1) buffData.logicTurn += 1;
        if (dataVals.ShortenBuffHalfTurnInOpponentTurn == 1) buffData.logicTurn -= 1;
      } else {
        if (dataVals.ExtendBuffHalfTurnInPartyTurn == 1) buffData.logicTurn += 1;
        if (dataVals.ShortenBuffHalfTurnInPartyTurn == 1) buffData.logicTurn -= 1;
      }

      // Processing special logic for certain buff types
      if (buff.type.isTdTypeChange) {
        buffData.tdTypeChange = await getTypeChangeTd(battleData, target, buff, selectTreasureDeviceInfo);
      } else if (buff.type == BuffType.upDamageEventPoint) {
        final pointBuff = battleData.options.pointBuffs.values.firstWhereOrNull(
          (pointBuff) => pointBuff.funcIds.isEmpty || pointBuff.funcIds.contains(funcId),
        );
        if (pointBuff == null) {
          continue;
        }
        buffData.param += pointBuff.value;
      } else if (buff.type == BuffType.overwriteBattleclass) {
        // it is unclear what this will do for now, the only example is when TargetEnemyClass is set to 1
        final targetEnemyClassId = battleData.getTargetedEnemy(target)?.logicalClassId;
        if (dataVals.TargetEnemyClass == 1) {
          if (targetEnemyClassId == target.logicalClassId ||
              !ConstData.constantStr.enableOverwriteClassIds.contains(targetEnemyClassId)) {
            continue;
          }
          buffData.param = targetEnemyClassId!;
        }
      }

      buffData.shortenMaxCountEachSkill = dataVals.ShortenMaxCountEachSkill?.toList();

      // convert Buff checks
      for (final convertBuff in collectBuffsPerAction(target.battleBuff.validBuffs, BuffAction.buffConvert)) {
        Buff? convertedBuff;
        final convert = convertBuff.buff.script.convert;
        if (convert != null) {
          switch (convert.convertType) {
            case BuffConvertType.none:
              break;
            case BuffConvertType.buff:
              for (final (index, targetBuff) in convert.targetBuffs.indexed) {
                if (targetBuff.id == buff.id) {
                  convertedBuff = convert.convertBuffs[index];
                  break;
                }
              }
              break;
            case BuffConvertType.individuality:
              for (final (index, targetIndiv) in convert.targetIndividualities.indexed) {
                if (buff.vals.any((e) => e.signedId == targetIndiv.signedId)) {
                  convertedBuff = convert.convertBuffs[index];
                  break;
                }
              }
              break;
          }
          if (convertedBuff != null) {
            buffData.buff = convertedBuff;
            convertBuff.setUsed(target, battleData);
          }
        }
      }

      final isStackable = target.isBuffStackable(buffData.buff.buffGroup) && checkSameBuffLimitNum(target, dataVals);
      if (isStackable &&
          await shouldAddState(battleData, dataVals, activator, target, buffData, isCommandCode, isClassPassive)) {
        target.addBuff(buffData, isPassive: isPassive, isCommandCode: isCommandCode);
        battleData.setFuncResult(target.uniqueId, true);

        target.postAddStateProcessing(buff, dataVals);
      }
    }
  }

  static bool checkSameBuffLimitNum(final BattleServantData target, final DataVals dataVals) {
    return dataVals.SameBuffLimitNum == null ||
        dataVals.SameBuffLimitNum! >
            target.countBuffWithTrait([NiceTrait(id: dataVals.SameBuffLimitTargetIndividuality!)]);
  }

  static Future<bool> shouldAddState(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
    final BuffData buffData,
    final bool isCommandCode,
    final bool isSvtClassPassive,
  ) async {
    if (dataVals.ForceAddState == 1 || isCommandCode) {
      return true;
    }

    int functionRate = dataVals.Rate ?? 1000;
    if (functionRate < 0 && battleData.functionResults.lastOrNull?[target.uniqueId] != true) {
      return false;
    }

    functionRate = functionRate.abs();

    // based on https://discord.com/channels/839788731108032532/1098222580755861545/1278033086981865646
    // svtClassPassive should ignore all avoidState buffs
    if (!isSvtClassPassive) {
      final hasAvoidState = await target.hasBuff(
        battleData,
        BuffAction.avoidState,
        opponent: activator,
        addTraits: buffData.getTraits(),
      );
      if (hasAvoidState) {
        battleData.battleLogger.debug(
          '${S.current.effect_target}: ${target.lBattleName} - ${S.current.battle_invalid}',
        );
        return false;
      }
    }

    final buffReceiveChance = await target.getBuffValue(
      battleData,
      BuffAction.resistanceState,
      opponent: activator,
      addTraits: buffData.getTraits(),
    );
    final buffChance =
        await activator?.getBuffValue(
          battleData,
          BuffAction.grantState,
          opponent: target,
          addTraits: buffData.getTraits(),
        ) ??
        0;

    final activationRate = functionRate + buffChance;
    final resistRate = buffReceiveChance;

    final success = await battleData.canActivateFunction(activationRate - resistRate);

    final resultsString = success
        ? S.current.success
        : resistRate > 0
        ? 'GUARD'
        : 'MISS';

    battleData.battleLogger.debug(
      '${S.current.effect_target}: ${target.lBattleName} - '
      '$resultsString'
      '${battleData.options.tailoredExecution ? '' : ' [($activationRate - $resistRate) vs ${battleData.options.threshold}]'}',
    );

    return success;
  }

  static Future<NiceTd?> getTypeChangeTd(
    BattleData battleData,
    BattleServantData svt,
    Buff buff,
    SelectTreasureDeviceInfo? selectTreasureDeviceInfo,
  ) async {
    final NiceTd? baseTd = svt.getBaseTD();
    if (baseTd == null) return null;
    if (!buff.type.isTdTypeChange) return null;
    final excludeTypes = baseTd.script?.excludeTdChangeTypes;
    final tdTypeChangeIDs = baseTd.script?.tdTypeChangeIDs;
    if (tdTypeChangeIDs == null || tdTypeChangeIDs.isEmpty) return null;

    // hardcoding since there's no NP with extra card type
    final validCardIndex = <int>[CardType.arts.value, CardType.buster.value, CardType.quick.value];

    if (excludeTypes != null && excludeTypes.isNotEmpty) {
      validCardIndex.removeWhere((e) => excludeTypes.contains(e));
    }
    validCardIndex.retainWhere((e) => e <= tdTypeChangeIDs.length);
    if (validCardIndex.isEmpty) return null;

    // in UI, Q/A/B order
    int? targetTdIndex;
    if (buff.type == BuffType.tdTypeChangeArts) {
      targetTdIndex = CardType.arts.value;
    } else if (buff.type == BuffType.tdTypeChangeBuster) {
      targetTdIndex = CardType.buster.value;
    } else if (buff.type == BuffType.tdTypeChangeQuick) {
      targetTdIndex = CardType.quick.value;
    } else if (buff.type == BuffType.tdTypeChange) {
      if (battleData.delegate?.tdTypeChange != null) {
        targetTdIndex = await battleData.delegate!.tdTypeChange!(svt, validCardIndex);
      } else if (battleData.mounted) {
        selectTreasureDeviceInfo ??= svt.getBaseTD()?.script?.selectTreasureDeviceInfo?.getOrNull(svt.tdLv - 1);
        targetTdIndex = await TdTypeChangeSelector.show(
          battleData,
          tdTypeChangeIDs,
          validCardIndex,
          selectTreasureDeviceInfo,
        );
        if (targetTdIndex != null) {
          battleData.replayDataRecord.tdTypeChanges.add(targetTdIndex);
        }
      }
    }
    NiceTd? targetTd;
    if (targetTdIndex != null && validCardIndex.contains(targetTdIndex)) {
      // start from Q/A/B=1/2/3 -> index 0/1/2
      final tdId = tdTypeChangeIDs.getOrNull(targetTdIndex - 1);
      if (tdId == null) return null;

      final List<NiceTd?> tds = svt.isPlayer
          ? (svt.playerSvtData?.svt?.noblePhantasms ?? [])
          : (svt.niceSvt?.noblePhantasms ?? [svt.niceEnemy?.noblePhantasm.noblePhantasm]);
      targetTd = tds.lastWhereOrNull((e) => e?.id == tdId);
      targetTd ??= await showEasyLoading(() => AtlasApi.td(tdId, svtId: svt.svtId), mask: true);
    }
    return targetTd;
  }
}
