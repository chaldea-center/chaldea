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
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    for (final target in targets) {
      if (target.isEnemy) {
        continue;
      }

      battleData.setTarget(target);
      final targetSvtId = dataVals.Value!;
      if (targetSvtId == 304800) {
        // lazy transform svt 312
        final svt = db.gameData.servantsById[targetSvtId];
        target.playerSvtData!.limitCount = dataVals.SetLimitCount!;
        target.skillInfoList[2].baseSkill = svt?.skills.firstWhereOrNull((e) => e.id == 888575);
        target.playerSvtData!.td = svt?.noblePhantasms.firstWhereOrNull((e) => e.id == 304802);
      } else {
        Servant? targetSvt =
            db.gameData.servantsById[targetSvtId] ?? await showEasyLoading(() => AtlasApi.svt(targetSvtId), mask: true);
        if (targetSvt == null) {
          battleData.battleLogger.debug('${S.current.not_found}: $targetSvtId');
        } else {
          target.niceSvt = targetSvt;

          final List<BattleSkillInfoData> newSkillInfos = [];
          for (final skillNum in kActiveSkillNums) {
            final newSkills = targetSvt.groupedActiveSkills[skillNum];
            if (newSkills == null || newSkills.isEmpty) continue;

            final oldInfoData = target.skillInfoList.firstWhereOrNull((infoData) => infoData.skillNum == skillNum);
            final baseSkill =
                newSkills.firstWhereOrNull((skill) => skill.id == oldInfoData?.baseSkill?.id) ?? newSkills.last;
            final newInfoData = BattleSkillInfoData(baseSkill, provisionedSkills: newSkills, skillNum: skillNum);
            newInfoData.skillLv = target.playerSvtData != null && target.playerSvtData!.skillLvs.length >= skillNum
                ? target.playerSvtData!.skillLvs[skillNum - 1]
                : 1;
            if (oldInfoData != null) {
              newInfoData.chargeTurn = oldInfoData.chargeTurn;
            }
            newSkillInfos.add(newInfoData);
          }
          target.skillInfoList = newSkillInfos;

          if (!targetSvt.noblePhantasms.contains(target.playerSvtData!.td)) {
            target.playerSvtData!.td = targetSvt.noblePhantasms.last;
          }
        }
      }
      battleData.curFuncResults[target.uniqueId] = true;
      battleData.unsetTarget();
    }
  }
}
