import 'package:flutter/foundation.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import '../utils/battle_utils.dart';

class PlayerSvtData {
  Servant? svt;
  int limitCount = 4;
  List<int> skillLvs = [10, 10, 10];
  List<NiceSkill?> skills = [null, null, null];
  List<int> appendLvs = [0, 0, 0];
  List<NiceSkill> extraPassives = [];
  Set<int> disabledExtraSkills = {};
  List<BaseSkill> additionalPassives = [];
  List<int> additionalPassiveLvs = [];
  int tdLv = 5;
  NiceTd? td;

  int lv = 1; // -1=mlb, 90, 100, 120, 0=no ATK/HP
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

  PlayerSvtData.svt(Servant this.svt) {
    skills = kActiveSkillNums.map((e) => svt!.groupedActiveSkills[e]?.first).toList();
    td = svt!.groupedNoblePhantasms[1]?.first;
  }

  void fromUserSvt({
    required Servant svt,
    required SvtStatus status,
    required SvtPlan plan,
  }) {
    this
      ..limitCount = plan.ascension
      ..lv = svt.grailedLv(plan.grail)
      ..tdLv = plan.npLv.clamp(1, 5)
      ..skillLvs = plan.skills.toList()
      ..appendLvs = plan.appendSkills.toList()
      ..atkFou = plan.fouAtk > 0 ? 1000 + plan.fouAtk * 20 : plan.fouAtk3 * 50
      ..hpFou = plan.fouHp > 0 ? 1000 + plan.fouHp * 20 : plan.fouHp3 * 50
      ..cardStrengthens = List.generate(svt.cards.length, (index) {
        return (status.cmdCardStrengthen?.getOrNull(index) ?? 0) * 20;
      })
      ..commandCodes = List.generate(svt.cards.length, (index) {
        return db.gameData.commandCodes[status.getCmdCode(index)];
      });
  }

  void updateRankUps([Region region = Region.jp]) {
    final svt = this.svt;
    if (svt == null) return;
    final tds = BattleUtils.getShownTds(svt, limitCount);
    if (region != Region.jp) {
      final releasedTds =
          tds.where((td) => db.gameData.mappingData.tdPriority[svt.id]?.ofRegion(region)?[td.id] != null).toList();
      td = releasedTds.lastOrNull ?? tds.lastOrNull;
    } else {
      td = tds.lastOrNull;
    }

    for (final skillNum in kActiveSkillNums) {
      final validSkills = BattleUtils.getShownSkills(svt, limitCount, skillNum);
      if (region != Region.jp) {
        final releaseSkills = validSkills
            .where((skill) => db.gameData.mappingData.skillPriority[svt.id]?.ofRegion(region)?[skill.id] != null)
            .toList();
        skills[skillNum - 1] = releaseSkills.lastOrNull ?? validSkills.lastOrNull;
      } else {
        skills[skillNum - 1] = validSkills.lastOrNull;
      }
    }
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

  PlayerSvtData copy() {
    return PlayerSvtData.base()
      ..svt = svt
      ..limitCount = limitCount
      ..skillLvs = skillLvs.toList()
      ..skills = skills.toList()
      ..appendLvs = appendLvs.toList()
      ..extraPassives = extraPassives.toList()
      ..disabledExtraSkills = disabledExtraSkills.toSet()
      ..additionalPassives = additionalPassives.toList()
      ..additionalPassiveLvs = additionalPassiveLvs.toList()
      ..tdLv = tdLv
      ..td = td
      ..lv = lv
      ..atkFou = atkFou
      ..hpFou = hpFou
      ..fixedAtk = fixedAtk
      ..fixedHp = fixedHp
      ..ce = ce
      ..ceLimitBreak = ceLimitBreak
      ..ceLv = ceLv
      ..isSupportSvt = isSupportSvt
      ..cardStrengthens = cardStrengthens.toList()
      ..commandCodes = commandCodes.toList();
  }

  static Future<PlayerSvtData> fromStoredData(final SvtSaveData? storedData) async {
    if (storedData == null) return PlayerSvtData.base();
    final svt = db.gameData.servantsById[storedData.svtId];
    final PlayerSvtData playerSvtData = PlayerSvtData.base()
      ..svt = svt
      ..limitCount = storedData.limitCount
      ..skillLvs = storedData.skillLvs.toList()
      ..appendLvs = storedData.appendLvs.toList()
      ..disabledExtraSkills = storedData.disabledExtraSkills.toSet()
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

      playerSvtData.additionalPassives.clear();
      playerSvtData.additionalPassiveLvs.clear();
      for (int index = 0; index < storedData.additionalPassives.length; index++) {
        final storedSkill = storedData.additionalPassives[index];
        final targetSkill =
            db.gameData.baseSkills[storedSkill.id] ?? await AtlasApi.skill(storedSkill.id) ?? storedSkill;

        int lv = storedData.additionalPassiveLvs.getOrNull(index) ?? targetSkill.maxLv;
        lv = lv.clamp(1, targetSkill.maxLv);
        playerSvtData.additionalPassives.add(targetSkill);
        playerSvtData.additionalPassiveLvs.add(lv);
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
      disabledExtraSkills: disabledExtraSkills.toSet(),
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

  void loadStoredData(final MysticCodeSaveData storedData) {
    mysticCode = db.gameData.mysticCodes[storedData.mysticCodeId];
    level = storedData.level;
  }

  MysticCodeData copy() {
    return MysticCodeData()
      ..mysticCode = mysticCode
      ..level = level;
  }
}

// won't change in entire battle
class BattleOptionsEnv {
  bool disableEvent = false;
  // <groupId, pointBuff>
  Map<int, EventPointBuff> pointBuffs = {};

  BattleOptionsEnv copy() {
    return BattleOptionsEnv()
      ..disableEvent = disableEvent
      ..pointBuffs = Map.of(pointBuffs);
  }
}

class BattleOptionsRuntime extends BattleOptionsEnv {
  int fixedRandom = ConstData.constants.attackRateRandomMin;
  int probabilityThreshold = 1000;
  bool isAfter7thAnni = true;
  bool tailoredExecution = false;

  @override
  BattleOptionsRuntime copy() {
    return BattleOptionsRuntime()
      ..disableEvent = disableEvent
      ..pointBuffs = Map.of(pointBuffs)
      ..fixedRandom = fixedRandom
      ..probabilityThreshold = probabilityThreshold
      ..isAfter7thAnni = isAfter7thAnni
      ..tailoredExecution = tailoredExecution;
  }
}

// only used before simulation started and initiation
class BattleTeamSetup {
  final List<PlayerSvtData> onFieldSvtDataList;
  final List<PlayerSvtData> backupSvtDataList;

  final MysticCodeData mysticCodeData;
  Region playerRegion;

  BattleTeamSetup({
    List<PlayerSvtData?>? onFieldSvtDataList,
    List<PlayerSvtData?>? backupSvtDataList,
    MysticCodeData? mysticCodeData,
    this.playerRegion = Region.jp,
  })  : onFieldSvtDataList = List.generate(3, (index) => onFieldSvtDataList?.getOrNull(index) ?? PlayerSvtData.base()),
        backupSvtDataList = List.generate(3, (index) => backupSvtDataList?.getOrNull(index) ?? PlayerSvtData.base()),
        mysticCodeData = mysticCodeData ?? MysticCodeData();

  List<PlayerSvtData> get allSvts => [...onFieldSvtDataList, ...backupSvtDataList];
  // db.settings.battleSim.autoAdd7KnightsTrait
  bool get isDracoInTeam {
    for (final svt in allSvts) {
      if (svt.svt?.id == 3300100) {
        return true;
      }
    }
    return false;
  }

  BattleTeamSetup copy() {
    return BattleTeamSetup(
      onFieldSvtDataList: onFieldSvtDataList.map((e) => e.copy()).toList(),
      backupSvtDataList: backupSvtDataList.map((e) => e.copy()).toList(),
      mysticCodeData: mysticCodeData.copy(),
      playerRegion: playerRegion,
    );
  }
}

class BattleOptions extends BattleOptionsRuntime {
  BattleTeamSetup team = BattleTeamSetup();

  @override
  BattleOptions copy() {
    return BattleOptions()
      ..disableEvent = disableEvent
      ..pointBuffs = Map.of(pointBuffs)
      ..fixedRandom = fixedRandom
      ..probabilityThreshold = probabilityThreshold
      ..isAfter7thAnni = isAfter7thAnni
      ..tailoredExecution = tailoredExecution
      ..team = team.copy();
  }
}
