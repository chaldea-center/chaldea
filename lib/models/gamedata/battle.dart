import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';

class PlayerSvtData {
  Servant? svt;
  int limitCount = 4;
  List<int> skillLvs = [10, 10, 10];
  List<NiceSkill?> skills = [null, null, null];
  List<int> appendLvs = [0, 0, 0];
  List<NiceSkill> extraPassives = [];
  List<BaseSkill> additionalPassives = [];
  List<int> additionalPassiveLvs = [];
  int tdLv = 5;
  NiceTd? td;

  int lv = 1; // -1=mlb, 90, 100, 120
  int atkFou = 1000;
  int hpFou = 1000;

  // for support or custom
  int? fixedAtk;
  int? fixedHp;

  CraftEssence? ce;
  bool ceLimitBreak = false;
  int ceLv = 0;

  bool isSupportSvt = false;

  List<int> cardStrengthens = [0, 0, 0, 0, 0];
  List<CommandCode?> commandCodes = [null, null, null, null, null];

  PlayerSvtData.base();

  @visibleForTesting
  PlayerSvtData.id(final int svtId) {
    svt = db.gameData.servantsById[svtId]!;
    skills = kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.first).toList();
    td = svt!.groupedNoblePhantasms[1]?.first;
  }

  PlayerSvtData.svt(this.svt) {
    skills = kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.first).toList();
    td = svt!.groupedNoblePhantasms[1]?.first;
  }

  @visibleForTesting
  void setSkillStrengthenLvs(final List<int> skillStrengthenLvs) {
    skills =
        kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.getOrNull(skillStrengthenLvs[e - 1] - 1)).toList();
  }

  void setNpStrengthenLv(final int npStrengthenLv) {
    td = svt!.groupedNoblePhantasms[1]?[npStrengthenLv - 1];
  }

  void addCustomPassive(BaseSkill skill, int lv) {
    if (skill.maxLv <= 0) return;
    additionalPassives.add(skill);
    additionalPassiveLvs.add(lv);
  }

  static Future<PlayerSvtData> fromStoredData(final StoredSvtData storedData) async {
    final PlayerSvtData playerSvtData = PlayerSvtData.base()
      ..svt = db.gameData.servantsById[storedData.svtId]
      ..limitCount = storedData.limitCount
      ..skillLvs = storedData.skillLvs.toList()
      ..appendLvs = storedData.appendLvs.toList()
      ..additionalPassives = storedData.additionalPassives.toList()
      ..additionalPassiveLvs = storedData.additionalPassiveLvs.toList()
      ..tdLv = storedData.tdLv
      ..lv = storedData.lv
      ..atkFou = storedData.atkFou
      ..hpFou = storedData.hpFou
      ..fixedAtk = storedData.fixedAtk
      ..fixedHp = storedData.fixedHp
      ..ceLimitBreak = storedData.ceLimitBreak
      ..ceLv = storedData.ceLv
      ..isSupportSvt = storedData.isSupportSvt
      ..cardStrengthens = storedData.cardStrengthens.toList();

    if (playerSvtData.svt != null) {
      playerSvtData.skills = [];
      for (final skillId in storedData.skillIds) {
        if (skillId == null) {
          playerSvtData.skills.add(null);
          continue;
        }

        NiceSkill? storedSkill = playerSvtData.svt!.skills.firstWhereOrNull((svtSkill) => svtSkill.id == skillId);
        if (storedSkill == null) {
          EasyLoading.show();
          storedSkill = await AtlasApi.skill(skillId);
          EasyLoading.dismiss();
        }
        playerSvtData.skills.add(storedSkill);
      }

      playerSvtData.extraPassives = [];
      for (final skillId in storedData.extraPassiveIds) {
        NiceSkill? storedSkill = playerSvtData.svt!.extraPassive.firstWhereOrNull((svtSkill) => svtSkill.id == skillId);
        if (storedSkill == null) {
          EasyLoading.show();
          storedSkill = await AtlasApi.skill(skillId);
          EasyLoading.dismiss();
        }
        if (storedSkill != null) {
          playerSvtData.extraPassives.add(storedSkill);
        }
      }

      if (storedData.tdId != null) {
        playerSvtData.td = playerSvtData.svt!.noblePhantasms.firstWhereOrNull((td) => td.id == storedData.tdId);
        if (playerSvtData.td == null) {
          EasyLoading.show();
          playerSvtData.td = await AtlasApi.td(storedData.tdId!);
          EasyLoading.dismiss();
        }
      }

      playerSvtData.commandCodes = [];
      for (final commandCodeId in storedData.commandCodeIds) {
        if (commandCodeId == null) {
          playerSvtData.commandCodes.add(null);
          continue;
        }

        CommandCode? storedCommandCode = db.gameData.commandCodesById[commandCodeId];
        playerSvtData.commandCodes.add(storedCommandCode);
      }
    }

    if (storedData.ceId != null) {
      playerSvtData.ce = db.gameData.craftEssencesById[storedData.ceId];
    }

    return playerSvtData;
  }

  StoredSvtData toStoredData() {
    return StoredSvtData(
      svtId: isSupportSvt ? null : svt?.id,
      limitCount: limitCount,
      skillLvs: skillLvs,
      skillIds: skills.map((skill) => skill?.id).toList(),
      appendLvs: appendLvs,
      extraPassiveIds: extraPassives.map((extraPassive) => extraPassive.id).toList(),
      additionalPassives: additionalPassives,
      additionalPassiveLvs: additionalPassiveLvs,
      tdLv: tdLv,
      tdId: td?.id,
      lv: lv,
      atkFou: atkFou,
      hpFou: hpFou,
      fixedAtk: fixedAtk,
      fixedHp: fixedHp,
      ceId: ce?.id,
      ceLimitBreak: ceLimitBreak,
      ceLv: ceLv,
      isSupportSvt: isSupportSvt,
      cardStrengthens: cardStrengthens,
      commandCodeIds: commandCodes.map((commandCode) => commandCode?.id).toList(),
    );
  }
}

// Follower.Type
enum SupportSvtType {
  none,
  friend,
  notFriend,
  npc,
  npcNoTd,
}

class MysticCodeData {
  MysticCode? mysticCode = db.gameData.mysticCodes[210];
  int level = 10;

  StoredMysticCodeData toStoredData() {
    return StoredMysticCodeData(mysticCodeId: mysticCode?.id, level: level);
  }

  void fromStoredData(final StoredMysticCodeData storedData) {
    mysticCode = db.gameData.mysticCodes[storedData.mysticCodeId];
    level = storedData.level;
  }
}
