import 'dart:math';

import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import '_base.dart';

class FakerRuntimeCombine extends FakerRuntimeBase {
  FakerRuntimeCombine(super.runtime);

  Future<void> svtEquipCombine({required int targetUserSvtId, required List<int> combineMaterials}) async {
    final target = mstData.userSvt[targetUserSvtId];
    final targetCE = target?.dbCE;
    if (target == null) {
      throw SilentException('Unknown target CE userSvtId: $targetUserSvtId');
    }
    if (targetCE == null) {
      throw SilentException('Unknown target CE: $targetUserSvtId');
    }
    for (final userSvtId in combineMaterials) {
      if (userSvtId == targetUserSvtId) {
        throw SilentException('Combine material should not be same as target: $userSvtId');
      }
      final userSvt = mstData.userSvt[userSvtId];
      if (userSvt == null) {
        throw SilentException('Unknown material CE userSvtId: $userSvtId');
      }
      final ce = userSvt.dbCE;
      if (ce == null) {
        throw SilentException('Unknown material CE: $userSvtId');
      }
      if (userSvt.isLocked()) {
        throw SilentException('Unlock CE first: $userSvtId');
      }
      if (userSvt.isChoice()) {
        throw SilentException('CE in choice! $userSvtId');
      }
    }
    await agent.servantEquipCombine(baseUserSvtId: targetUserSvtId, materialSvtIds: combineMaterials.toList());
  }

  Future<void> loopSvtEquipCombine([int count = 1]) async {
    final gachaOption = agent.user.gacha;
    runtime.displayToast('Combine Craft Essence ...');
    while (count > 0) {
      final targetCEs = mstData.userSvt.where((userSvt) {
        final ce = db.gameData.craftEssencesById[userSvt.svtId];
        if (ce == null) return false;
        if (!userSvt.isLocked()) return false;
        final maxLv = userSvt.maxLv;
        if (maxLv == null || userSvt.lv >= maxLv - 1) return false;
        if (gachaOption.ceEnhanceBaseUserSvtIds.contains(userSvt.id)) return true;
        if (gachaOption.ceEnhanceBaseSvtIds.contains(userSvt.svtId)) {
          return userSvt.limitCount == 4;
        }
        return false;
      }).toList();
      if (targetCEs.isEmpty) {
        throw SilentException('No valid Target Craft Essence');
      }
      targetCEs.sort2((e) => e.lv);
      final targetCE = targetCEs.first;
      List<UserServantEntity> combineMaterialCEs = getMaterialSvtEquips(
        baseUserSvtId: targetCE.id,
        includeExp3: gachaOption.feedExp3,
        includeExp4: gachaOption.feedExp4,
      );
      if (combineMaterialCEs.isEmpty) {
        runtime.update();
        return;
      }
      await agent.servantEquipCombine(
        baseUserSvtId: targetCE.id,
        materialSvtIds: combineMaterialCEs.map((e) => e.id).toList(),
      );
      count -= 1;
      runtime.agentData.gachaResultStat.lastEnhanceBaseCE = targetCE;
      runtime.agentData.gachaResultStat.lastEnhanceMaterialCEs = combineMaterialCEs.toList();
      runtime.agentData.gachaResultStat.lastEnhanceMaterialCEs.sort((a, b) => CraftFilterData.compare(a.dbCE, b.dbCE));
      runtime.update();
    }
  }

  List<UserServantEntity> getMaterialSvtEquips({
    int baseUserSvtId = 0,
    bool includeExp3 = false,
    bool includeExp4 = false,
  }) {
    List<UserServantEntity> materialCEs = mstData.userSvt.where((userSvt) {
      if (userSvt.id == baseUserSvtId) return false;
      final ce = db.gameData.craftEssencesById[userSvt.svtId];
      if (ce == null || userSvt.isLocked() || userSvt.isChoice() || userSvt.lv != 1) return false;
      final bool isExp = ce.flags.contains(SvtFlag.svtEquipExp);
      if (ce.rarity > 4) {
        return false;
      } else if (ce.rarity == 4) {
        return includeExp4 && isExp;
      } else if (ce.rarity == 3) {
        if (isExp) {
          return includeExp3;
        }
        return ce.obtain == CEObtain.permanent;
      } else {
        if (ce.collectionNo <= 10) return false; // won't in FP gacha
        return true;
      }
    }).toList();
    materialCEs.sort2((e) => -e.createdAt);
    materialCEs = materialCEs.take(20).toList();
    return materialCEs;
  }

  //
  Future<void> svtCombine({int? loopCount}) async {
    final options = agent.user.svtCombine;
    while ((loopCount ?? options.loopCount) > 0) {
      final UserServantEntity? baseUserSvt = mstData.userSvt[options.baseUserSvtId];
      if (baseUserSvt == null) throw SilentException('user svt ${options.baseUserSvtId} not found');
      final baseSvt = baseUserSvt.dbSvt;
      if (baseSvt == null) throw SilentException('svt ${baseUserSvt.svtId} not found');
      if (baseSvt.rarity == 0 || baseSvt.type != SvtType.normal || baseSvt.collectionNo == 0) {
        throw SilentException('Invalid base svt');
      }
      final maxLv = baseUserSvt.maxLv;
      if (maxLv == null || baseUserSvt.lv >= maxLv) {
        throw SilentException('Lv.${baseUserSvt.lv}>=maxLv $maxLv');
      }
      List<UserServantEntity> candidateMaterialSvts = mstData.userSvt.where((userSvt) {
        final svt = userSvt.dbEntity;
        if (svt == null || svt.type != SvtType.combineMaterial) return false;
        if (userSvt.isLocked() || userSvt.lv != 1) return false;
        if (!options.svtMaterialRarities.contains(svt.rarity)) return false;
        return true;
      }).toList();
      candidateMaterialSvts.sort2((e) => e.dbEntity?.rarity ?? 999);

      List<int> materialSvtIds = [];
      final curLvExp = baseSvt.expGrowth.getOrNull(baseUserSvt.lv - 1),
          nextAsenExp = baseSvt.expGrowth.getOrNull((baseUserSvt.maxLv ?? baseSvt.lvMax) - 1);
      if (curLvExp == null || nextAsenExp == null || curLvExp >= nextAsenExp || curLvExp > baseUserSvt.exp) {
        throw SilentException('no valid exp data found: $curLvExp <= ${baseUserSvt.exp} <= $nextAsenExp');
      }
      int needExp = nextAsenExp - baseUserSvt.exp;
      int totalGetExp = 0, totalUseQp = 0;
      for (final userSvt in candidateMaterialSvts) {
        final svt = userSvt.dbEntity!;
        final sameClass = svt.classId == SvtClass.ALL.value || svt.classId == baseSvt.classId;
        int getExp = (1000 * (pow(3, svt.rarity - 1)) * (sameClass ? 1.2 : 1)).round();
        int useQp = ((100 + (baseUserSvt.lv - 1) * 30) * ([1, 1.5, 2, 4, 6][baseSvt.rarity - 1])).round();
        if (totalGetExp >= needExp || materialSvtIds.length >= options.maxMaterialCount) break;
        if (options.doubleExp) getExp *= 2;
        totalGetExp += getExp;
        totalUseQp += useQp;
        materialSvtIds.add(userSvt.id);
      }

      if (materialSvtIds.isEmpty) {
        throw SilentException('No valid 种火 found');
      }

      await agent.servantCombine(
        baseUserSvtId: options.baseUserSvtId,
        materialSvtIds: materialSvtIds,
        useQp: totalUseQp,
        getExp: totalGetExp,
      );
      if (loopCount != null) {
        loopCount -= 1;
      } else {
        options.loopCount -= 1;
      }
      runtime.update();
    }
  }

  Future<void> svtStatusUp() async {
    final options = agent.user.svtCombine;
    final UserServantEntity? baseUserSvt = mstData.userSvt[options.baseUserSvtId];
    if (baseUserSvt == null) throw SilentException('user svt ${options.baseUserSvtId} not found');
    final svt = baseUserSvt.dbSvt;
    if (svt == null) throw SilentException('svt ${baseUserSvt.svtId} not found');
    int needHpAdjust = max(0, 100 - baseUserSvt.adjustHp), needAtkAdjust = max(0, 100 - baseUserSvt.adjustAtk);
    if (needHpAdjust <= 0 && needAtkAdjust <= 0) throw SilentException('Already fou3 max');

    List<UserServantEntity> candidateMaterialSvts = mstData.userSvt.where((userSvt) {
      final fouSvt = userSvt.dbEntity;
      if (fouSvt == null || fouSvt.type != SvtType.statusUp) return false;
      if (userSvt.isLocked() || userSvt.lv != 1) return false;
      if (fouSvt.rarity > 3) return false;
      if (!options.svtMaterialRarities.contains(fouSvt.rarity)) return false;
      if (fouSvt.classId != SvtClass.ALL.value && fouSvt.classId != svt.classId) return false;
      return true;
    }).toList();
    candidateMaterialSvts.sortByList((e) => [e.dbEntity?.rarity ?? 999, -e.createdAt]);

    List<int> materialUserSvtIds = [];
    int totalUseQp = 0;
    for (final userSvt in candidateMaterialSvts) {
      if (materialUserSvtIds.length >= options.maxMaterialCount) break;
      if (needHpAdjust <= 0 && needAtkAdjust <= 0) break;
      final fouSvt = userSvt.dbEntity!;
      bool isAddHp = userSvt.svtId ~/ 100000 == 95, isAddAtk = userSvt.svtId ~/ 100000 == 96;
      int addValue = const {1: 1, 2: 2, 3: 5, 4: 2, 5: 10}[fouSvt.rarity]!;
      int useQp = ((100 + (baseUserSvt.lv - 1) * 30) * ([1, 1.5, 2, 4, 6][svt.rarity - 1])).round();
      if (isAddHp && needHpAdjust > 0) {
        materialUserSvtIds.add(userSvt.id);
        needHpAdjust -= addValue;
        totalUseQp += useQp;
      } else if (isAddAtk && needAtkAdjust > 0) {
        materialUserSvtIds.add(userSvt.id);
        needAtkAdjust -= addValue;
        totalUseQp += useQp;
      }
    }

    if (materialUserSvtIds.isEmpty) {
      throw SilentException('No valid foukun found');
    }

    await agent.servantCombine(
      baseUserSvtId: options.baseUserSvtId,
      materialSvtIds: materialUserSvtIds,
      useQp: totalUseQp,
      getExp: 10 * materialUserSvtIds.length,
    );
    runtime.update();
  }
}
