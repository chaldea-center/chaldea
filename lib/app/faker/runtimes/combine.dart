import 'dart:math';

import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import '_base.dart';

class FakerRuntimeCombine extends FakerRuntimeBase {
  FakerRuntimeCombine(super.runtime);

  Future<void> svtEquipCombine([int count = 1]) async {
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
      List<UserServantEntity> combineMaterialCEs = mstData.userSvt.where((userSvt) {
        final ce = db.gameData.craftEssencesById[userSvt.svtId];
        if (ce == null || userSvt.isLocked() || userSvt.lv != 1) return false;
        final bool isExp = ce.flags.contains(SvtFlag.svtEquipExp);
        if (ce.rarity > 4) {
          return false;
        } else if (ce.rarity == 4) {
          return gachaOption.feedExp4 && isExp;
        } else if (ce.rarity == 3) {
          if (isExp) {
            return gachaOption.feedExp3;
          }
          return ce.obtain == CEObtain.permanent;
        } else {
          return true;
        }
      }).toList();
      combineMaterialCEs.sort2((e) => -e.createdAt);
      if (combineMaterialCEs.isEmpty) {
        runtime.update();
        return;
      }
      combineMaterialCEs = combineMaterialCEs.take(20).toList();
      await agent.servantEquipCombine(
        baseUserSvtId: targetCE.id,
        materialSvtIds: combineMaterialCEs.map((e) => e.id).toList(),
      );
      count -= 1;
      runtime.data.gachaResultStat.lastEnhanceBaseCE = targetCE;
      runtime.data.gachaResultStat.lastEnhanceMaterialCEs = combineMaterialCEs.toList();
      runtime.data.gachaResultStat.lastEnhanceMaterialCEs.sort((a, b) => CraftFilterData.compare(a.dbCE, b.dbCE));
      runtime.update();
    }
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
}
