import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../models/db.dart';

class TransformServant {
  TransformServant._();

  static Future<void> transformServant(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        if (target.isPlayer) {
          await _transformAlly(battleData, dataVals, target);
        } else {
          await _transformEnemy(battleData, dataVals, target);
        }

        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }

  static Future<void> _transformAlly(BattleData battleData, DataVals dataVals, BattleServantData target) async {
    final targetSvtId = dataVals.Value!;
    Servant? targetSvt =
        db.gameData.servantsById[targetSvtId] ?? await showEasyLoading(() => AtlasApi.svt(targetSvtId), mask: true);
    if (targetSvt == null) {
      battleData.battleLogger.error('${S.current.not_found}: $targetSvtId');
      return;
    }

    target.niceSvt = targetSvt;
    final limitCount = dataVals.SetLimitCount;
    if (limitCount != null) {
      target.playerSvtData!.limitCount = limitCount;
    }

    // build new skills
    final List<BattleSkillInfoData> newSkillInfos = [];
    for (final skillNum in kActiveSkillNums) {
      final newSkills = (targetSvt.groupedActiveSkills[skillNum] ?? []).toList();
      final hideActives =
          ConstData.getSvtLimitHides(targetSvtId, limitCount).expand((e) => e.activeSkills[skillNum] ?? []).toList();
      newSkills.removeWhere((niceSkill) => hideActives.contains(niceSkill.id));

      final oldInfoData = target.skillInfoList.firstWhereOrNull((infoData) => infoData.skillNum == skillNum);
      BaseSkill? baseSkill = newSkills.firstWhereOrNull((skill) => skill.id == oldInfoData?.skill?.id);
      baseSkill ??=
          newSkills.lastWhereOrNull((skill) => skill.strengthStatus == oldInfoData?.skill?.svt.strengthStatus);
      baseSkill ??=
          newSkills.fold(null, (prev, next) => prev == null || prev.svt.priority <= prev.svt.priority ? next : prev);

      final newInfoData = BattleSkillInfoData(
        baseSkill,
        provisionedSkills: newSkills,
        skillNum: skillNum,
        type: SkillInfoType.svtSelf,
        skillLv: target.playerSvtData!.skillLvs.length >= skillNum ? target.playerSvtData!.skillLvs[skillNum - 1] : 1,
      );
      if (oldInfoData != null) {
        newInfoData.chargeTurn = oldInfoData.chargeTurn;
      }
      newSkillInfos.add(newInfoData);
    }

    target.skillInfoList = newSkillInfos;

    // build new Td
    final curTd = target.playerSvtData!.td;
    final newTds = (targetSvt.groupedNoblePhantasms[curTd?.svt.num ?? 1] ?? []).toList();
    final hideTds = ConstData.getSvtLimitHides(targetSvtId, limitCount).expand((e) => e.tds).toList();
    newTds.removeWhere((niceTd) => hideTds.contains(niceTd.id));
    NiceTd? newTd = newTds.firstWhereOrNull((td) => td.id == curTd?.id);
    newTd ??= newTds.lastWhereOrNull((td) => td.strengthStatus == curTd?.strengthStatus);
    newTd ??= newTds.fold(null, (prev, next) => prev == null || prev.priority <= next.priority ? next : prev);

    target.playerSvtData!.td = newTd;
  }

  static Future<void> _transformEnemy(BattleData battleData, DataVals dataVals, BattleServantData target) async {
    final targetSvtId = dataVals.Value!;
    final targetEnemy = battleData.enemyDecks[DeckType.transform]?.firstWhereOrNull((enemy) => enemy.id == targetSvtId);
    if (targetEnemy == null) {
      battleData.battleLogger.error('${S.current.not_found}: $targetSvtId');
      return;
    }

    target.niceEnemy = targetEnemy;
    target.skillInfoList = [
      BattleSkillInfoData(targetEnemy.skills.skill1,
          skillNum: 1, skillLv: targetEnemy.skills.skillLv1, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(targetEnemy.skills.skill2,
          skillNum: 2, skillLv: targetEnemy.skills.skillLv2, type: SkillInfoType.svtSelf),
      BattleSkillInfoData(targetEnemy.skills.skill3,
          skillNum: 3, skillLv: targetEnemy.skills.skillLv3, type: SkillInfoType.svtSelf),
    ];
  }
}
