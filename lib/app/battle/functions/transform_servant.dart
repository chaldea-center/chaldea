import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../models/db.dart';

class TransformServant {
  TransformServant._();

  static Future<bool> transformServant(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
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
        target.ascensionPhase = dataVals.SetLimitCount!;
        target.skillInfoList[2].baseSkill = svt?.skills.firstWhereOrNull((e) => e.id == 888575);
        target.td = svt?.noblePhantasms.firstWhereOrNull((e) => e.id == 304802);
      } else {
        Servant? targetSvt;
        try {
          targetSvt = await AtlasApi.svt(targetSvtId);
        } catch (e) {
          logger.e('Exception while fetch AtlasApi for servant $targetSvtId', e);
        }
        if (targetSvt == null) {
          battleData.battleLogger.debug('${S.current.not_found}: $targetSvtId');
        } else {
          target.niceSvt = targetSvt;

          final List<BattleSkillInfoData> newSkillInfos = [];
          for (final skillNum in kActiveSkillNums) {
            final newSkills = targetSvt.groupedActiveSkills[skillNum];
            if (newSkills == null || newSkills.isEmpty) continue;

            final oldInfoData =
                target.skillInfoList.firstWhereOrNull((infoData) => infoData.baseSkill?.num == skillNum);
            final baseSkill =
                newSkills.firstWhereOrNull((skill) => skill.id == oldInfoData?.baseSkill?.id) ?? newSkills.last;
            final newInfoData = BattleSkillInfoData(newSkills, baseSkill);
            newInfoData.skillLv = target.playerSvtData != null && target.playerSvtData!.skillLvs.length >= skillNum
                ? target.playerSvtData!.skillLvs[skillNum - 1]
                : 1;
            if (oldInfoData != null) {
              newInfoData.chargeTurn = oldInfoData.chargeTurn;
            }
            newSkillInfos.add(newInfoData);
          }
          target.skillInfoList = newSkillInfos;

          if (!targetSvt.noblePhantasms.contains(target.td)) {
            target.td = targetSvt.noblePhantasms.last;
          }
        }
      }
      battleData.unsetTarget();
    }

    return true;
  }
}
