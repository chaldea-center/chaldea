import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/skill.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/vals.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';

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
        target.ascensionPhase = dataVals.SetLimitCount!;
        target.skillInfoList[2].baseSkillId = 888575;
        target.npId = 304802;
      } else {
        Servant? targetSvt;
        try {
          targetSvt = await AtlasApi.svt(targetSvtId);
        } catch (e) {
          logger.e('Exception while fetch AtlasApi for servant $targetSvtId', e);
        }
        if (targetSvt == null) {
          battleData.logger.debug('${S.current.not_found}: $targetSvtId');
        } else {
          target.niceSvt = targetSvt;
          for (int i = 0; i < targetSvt.groupedActiveSkills.length; i += 1) {
            final skills = targetSvt.groupedActiveSkills[i];
            if (target.skillInfoList.length <= i) {
              target.skillInfoList.add(BattleSkillInfoData(skills, skills.last.id));
            } else {
              final curSkillInfo = target.skillInfoList[i];
              curSkillInfo.provisionedSkills = skills;
              if (curSkillInfo.proximateSkill == null) {
                curSkillInfo.setBaseSkillId(skills.last.id);
              }
            }
          }
          for (int i = targetSvt.groupedActiveSkills.length; i < target.skillInfoList.length; i += 1) {
            target.skillInfoList[i].baseSkillId = 0;
          }
          if (targetSvt.noblePhantasms.firstWhereOrNull((e) => e.id == target.npId) == null) {
            target.npId = targetSvt.noblePhantasms.last.id;
          }
        }
      }
      battleData.unsetTarget();
    }

    return true;
  }
}