import 'package:flutter/foundation.dart';

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

  bool get isEmpty => svt == null && ce == null;

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

  static Future<PlayerSvtData> fromStoredData(final SvtSaveData? storedData) async {
    if (storedData == null) return PlayerSvtData.base();
    final svt = db.gameData.servantsById[storedData.svtId];
    final PlayerSvtData playerSvtData = PlayerSvtData.base()
      ..svt = svt
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

    if (svt != null) {
      playerSvtData.skills = [];
      for (int index = 0; index < kActiveSkillNums.length; index++) {
        NiceSkill? targetSkill;
        final skillId = storedData.skillIds.getOrNull(index);
        if (skillId != null) {
          targetSkill = svt.skills.lastWhereOrNull((skill) => skill.id == skillId);
          targetSkill ??= await AtlasApi.skill(skillId);
        }
        playerSvtData.skills.add(targetSkill);
      }

      playerSvtData.extraPassives = svt.extraPassive.toList();

      for (final storedSkill in storedData.additionalPassives) {
        final targetSkill =
            db.gameData.baseSkills[storedSkill.id] ?? await AtlasApi.skill(storedSkill.id) ?? storedSkill;
        playerSvtData.additionalPassives.add(targetSkill);
      }

      if (storedData.tdId != null) {
        playerSvtData.td = playerSvtData.svt!.noblePhantasms.lastWhereOrNull((td) => td.id == storedData.tdId);
        playerSvtData.td ??= await AtlasApi.td(storedData.tdId!);
      }

      playerSvtData.commandCodes = [];
      for (final commandCodeId in storedData.commandCodeIds) {
        CommandCode? storedCommandCode = db.gameData.commandCodesById[commandCodeId];
        playerSvtData.commandCodes.add(storedCommandCode);
      }
    }

    if (storedData.ceId != null) {
      playerSvtData.ce = db.gameData.craftEssencesById[storedData.ceId];
    }

    return playerSvtData;
  }

  SvtSaveData? toStoredData() {
    if (isSupportSvt) return null;
    return SvtSaveData(
      svtId: isSupportSvt ? null : svt?.id,
      limitCount: limitCount,
      skillLvs: skillLvs.toList(),
      skillIds: skills.map((skill) => skill?.id).toList(),
      appendLvs: appendLvs.toList(),
      additionalPassives: additionalPassives.toList(),
      additionalPassiveLvs: additionalPassiveLvs.toList(),
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
      cardStrengthens: cardStrengthens.toList(),
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

  MysticCodeSaveData toStoredData() {
    return MysticCodeSaveData(mysticCodeId: mysticCode?.id, level: level);
  }

  void fromStoredData(final MysticCodeSaveData storedData) {
    mysticCode = db.gameData.mysticCodes[storedData.mysticCodeId];
    level = storedData.level;
  }
}
