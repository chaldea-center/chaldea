import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import '../utils/battle_utils.dart';

class PlayerSvtData {
  Servant? svt;
  int limitCount = 4;
  List<int> skillLvs = List.filled(kActiveSkillNums.length, 10);
  List<NiceSkill?> skills = List.filled(kActiveSkillNums.length, null);
  List<int> appendLvs = List.filled(kAppendSkillNums.length, 0);
  List<NiceSkill> extraPassives = [];
  Set<int> disabledExtraSkills = {};
  Set<int> allowedExtraSkills = {};
  List<BaseSkill> customPassives = [];
  List<int> customPassiveLvs = [];
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

  SupportSvtType supportType = SupportSvtType.none;

  List<int> cardStrengthens = [0, 0, 0, 0, 0];
  List<CommandCode?> commandCodes = [null, null, null, null, null];

  bool grandSvt = false;

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

  PreferPlayerSvtDataSource onSelectServant(
    Servant selectedSvt, {
    PreferPlayerSvtDataSource? source,
    Region? region,
    int? jpTime,
  }) {
    source ??= db.settings.battleSim.playerDataSource;
    svt = selectedSvt;
    if (supportType == SupportSvtType.npc) {
      supportType = SupportSvtType.none;
    }
    fixedAtk = fixedHp = null;
    grandSvt = false;
    final status = db.curUser.svtStatusOf(selectedSvt.collectionNo);
    final plan =
        source == PreferPlayerSvtDataSource.target ? db.curUser.svtPlanOf(selectedSvt.collectionNo) : status.cur;

    if (!source.isNone && status.cur.favorite && selectedSvt.collectionNo > 0) {
      fromUserSvt(svt: selectedSvt, status: status, plan: plan);
    } else {
      source = PreferPlayerSvtDataSource.none;
      final defaults = db.settings.battleSim.defaultLvs;
      int defaultLv, defaultTdLv;
      if (defaults.useMaxLv) {
        defaultLv = selectedSvt.lvMax;
      } else {
        defaultLv = defaults.lv.clamp(1, min(120, selectedSvt.atkGrowth.length));
      }
      if (defaults.useDefaultTdLv) {
        if (selectedSvt.rarity <= 3 ||
            selectedSvt.obtains.any((e) => const [SvtObtain.eventReward, SvtObtain.friendPoint].contains(e))) {
          defaultTdLv = 5;
        } else if (selectedSvt.rarity == 4) {
          defaultTdLv = 2;
        } else {
          defaultTdLv = 1;
        }
      } else {
        defaultTdLv = defaults.tdLv;
      }
      this
        ..limitCount = defaults.limitCount
        ..lv = defaultLv
        ..tdLv = defaultTdLv
        ..skillLvs = List.generate(kActiveSkillNums.length, (index) => defaults.activeSkillLv)
        ..appendLvs = defaults.appendLvs.toList()
        ..allowedExtraSkills.clear()
        ..atkFou = defaults.atkFou * 10
        ..hpFou = defaults.hpFou * 10
        ..cardStrengthens = [0, 0, 0, 0, 0]
        ..commandCodes = [null, null, null, null, null];
    }

    extraPassives = selectedSvt.extraPassive.toList();

    updateRankUps(region: region, jpTime: jpTime);
    return source;
  }

  void fromUserSvt({required Servant svt, required SvtStatus status, required SvtPlan plan, int? limitCount}) {
    this
      ..grandSvt = false
      ..limitCount = limitCount ?? plan.ascension
      ..lv = svt.grailedLv(plan.grail)
      ..tdLv = plan.npLv.clamp(1, 5)
      ..skillLvs = plan.skills.toList()
      ..appendLvs = plan.appendSkills.toList()
      ..allowedExtraSkills.clear()
      ..atkFou = plan.fouAtk > 0 ? 1000 + plan.fouAtk * 20 : plan.fouAtk3 * 50
      ..hpFou = plan.fouHp > 0 ? 1000 + plan.fouHp * 20 : plan.fouHp3 * 50
      ..cardStrengthens = List.generate(svt.cards.length, (index) {
        return (status.cmdCardStrengthen?.getOrNull(index) ?? 0) * 20;
      })
      ..commandCodes = List.generate(svt.cards.length, (index) {
        return db.gameData.commandCodes[status.getCmdCode(index)];
      });
  }

  void updateRankUps({Region? region, int? jpTime}) {
    final svt = this.svt;
    if (svt == null) return;
    // td
    final tds = BattleUtils.getShownTds(svt, limitCount);
    td = null;
    if (tds.isNotEmpty) {
      if (region == Region.jp) {
        td = tds.last;
      } else if (region != null) {
        final releasedTds =
            tds.where((td) => db.gameData.mappingData.tdPriority[svt.id]?.ofRegion(region)?[td.id] != null).toList();
        td = releasedTds.lastOrNull ?? tds.last;
      } else if (jpTime != null) {
        // null: at jp quest time
        List<NiceTd> releasedTds = [];
        for (NiceTd tmpTd in tds) {
          NiceTd tdBefore = tmpTd;
          final changes = svt.svtChange.toList();
          changes.sort2((e) => e.priority);
          for (final change in changes.reversed) {
            int index = change.afterTreasureDeviceIds.indexOf(tmpTd.id);
            if (index >= 0 && change.beforeTreasureDeviceIds.length > index) {
              final beforeId = change.beforeTreasureDeviceIds[index];
              tdBefore = svt.noblePhantasms.firstWhereOrNull((e) => e.id == beforeId) ?? tdBefore;
            }
          }
          final quest = db.gameData.quests[tdBefore.condQuestId];
          if (quest == null || quest.openedAt <= jpTime) {
            releasedTds.add(tmpTd);
          }
        }
        td = releasedTds.lastOrNull ?? tds.last;
      } else {
        td = tds.last;
      }
    }

    // skill
    skills.fillRange(0, skills.length, null);
    for (final skillNum in kActiveSkillNums) {
      final validSkills = BattleUtils.getShownSkills(svt, limitCount, skillNum);
      if (validSkills.isEmpty) continue;
      if (region == Region.jp) {
        skills[skillNum - 1] = validSkills.last;
      } else if (region != null) {
        final releaseSkills =
            validSkills
                .where((skill) => db.gameData.mappingData.skillPriority[svt.id]?.ofRegion(region)?[skill.id] != null)
                .toList();
        skills[skillNum - 1] = releaseSkills.lastOrNull ?? validSkills.last;
      } else if (jpTime != null) {
        List<NiceSkill> releasedSkills = [];
        for (final skill in validSkills) {
          final quest = db.gameData.quests[skill.condQuestId];
          if (quest == null || quest.openedAt <= jpTime) {
            releasedSkills.add(skill);
          }
        }
        skills[skillNum - 1] = releasedSkills.lastOrNull ?? validSkills.last;
      } else {
        skills[skillNum - 1] = validSkills.last;
      }
    }
  }

  void onSelectCE(final CraftEssence selectedCE) {
    ce = selectedCE;
    final status = db.curUser.ceStatusOf(selectedCE.collectionNo);
    if (!db.settings.battleSim.playerDataSource.isNone &&
        selectedCE.collectionNo > 0 &&
        status.status == CraftStatus.owned) {
      ceLv = status.lv;
      ceLimitBreak = status.limitCount == 4;
    } else {
      ceLimitBreak = db.settings.battleSim.defaultLvs.ceMaxLimitBreak;
      int? lvMin = {1: 6, 2: 9, 3: 11, 4: 13, 5: 15}[selectedCE.rarity];
      ceLv =
          db.settings.battleSim.defaultLvs.ceMaxLv
              ? selectedCE.lvMax
              : ceLimitBreak && lvMin != null && lvMin <= selectedCE.lvMax && ceLv < lvMin
              ? lvMin
              : 1;
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
    customPassives.add(skill);
    customPassiveLvs.add(lv);
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
      ..allowedExtraSkills = allowedExtraSkills.toSet()
      ..customPassives = List<BaseSkill>.of(customPassives)
      ..customPassiveLvs = customPassiveLvs.toList()
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
      ..supportType = supportType
      ..cardStrengthens = cardStrengthens.toList()
      ..commandCodes = commandCodes.toList()
      ..grandSvt = grandSvt;
  }

  static Future<PlayerSvtData> fromStoredData(final SvtSaveData? storedData) async {
    if (storedData == null) return PlayerSvtData.base();
    Servant? svt = db.gameData.servantsById[storedData.svtId];
    if (svt == null && storedData.svtId != null && storedData.svtId != 0) {
      svt = await showEasyLoading(() => AtlasApi.svt(storedData.svtId!));
    }
    final PlayerSvtData playerSvtData =
        PlayerSvtData.base()
          ..svt = svt
          ..limitCount = storedData.limitCount
          ..skillLvs = storedData.skillLvs.toList()
          ..appendLvs = storedData.appendLvs.toList()
          ..disabledExtraSkills = storedData.disabledExtraSkills.toSet()
          ..allowedExtraSkills = storedData.allowedExtraSkills.toSet()
          ..customPassives = List<BaseSkill>.of(storedData.customPassives)
          ..customPassiveLvs = storedData.customPassiveLvs.toList()
          ..tdLv = storedData.tdLv
          ..lv = storedData.lv
          ..atkFou = storedData.atkFou
          ..hpFou = storedData.hpFou
          ..fixedAtk = storedData.fixedAtk
          ..fixedHp = storedData.fixedHp
          ..ceLimitBreak = storedData.ceLimitBreak
          ..ceLv = storedData.ceLv
          ..supportType = storedData.supportType
          ..cardStrengthens = storedData.cardStrengthens.toList()
          ..grandSvt = storedData.grandSvt;

    if (svt != null) {
      playerSvtData.skills = List.generate(kActiveSkillNums.length, (index) => null);
      for (int index = 0; index < kActiveSkillNums.length; index++) {
        NiceSkill? targetSkill;
        final skillId = storedData.skillIds.getOrNull(index);
        if (skillId != null && skillId != 0) {
          targetSkill = svt.skills.lastWhereOrNull((skill) => skill.id == skillId);
          targetSkill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
        }
        playerSvtData.skills[index] = targetSkill;
      }

      playerSvtData.extraPassives = svt.extraPassive.toList();

      playerSvtData.customPassives.clear();
      playerSvtData.customPassiveLvs.clear();
      for (int index = 0; index < storedData.customPassives.length; index++) {
        final storedSkill = storedData.customPassives[index];
        final targetSkill =
            db.gameData.baseSkills[storedSkill.id] ??
            (storedSkill.id == 0 ? null : await showEasyLoading(() => AtlasApi.skill(storedSkill.id), mask: true)) ??
            storedSkill;

        int lv = storedData.customPassiveLvs.getOrNull(index) ?? targetSkill.maxLv;
        lv = lv.clamp(1, targetSkill.maxLv);
        playerSvtData.customPassives.add(targetSkill);
        playerSvtData.customPassiveLvs.add(lv);
      }

      if (storedData.tdId != null && storedData.tdId != 0) {
        playerSvtData.td = playerSvtData.svt!.noblePhantasms.lastWhereOrNull((td) => td.id == storedData.tdId);
        playerSvtData.td ??= await showEasyLoading(() => AtlasApi.td(storedData.tdId!), mask: true);
      }

      playerSvtData.commandCodes = [];
      for (final commandCodeId in storedData.commandCodeIds) {
        CommandCode? storedCommandCode = db.gameData.commandCodesById[commandCodeId];
        playerSvtData.commandCodes.add(storedCommandCode);
      }
    }

    if (storedData.ceId != null && storedData.ceId != 0) {
      playerSvtData.ce = db.gameData.craftEssencesById[storedData.ceId];
      playerSvtData.ce ??= await showEasyLoading(() => AtlasApi.ce(storedData.ceId!));
    }

    return playerSvtData;
  }

  SvtSaveData? toStoredData() {
    if (supportType == SupportSvtType.npc) return null;
    return SvtSaveData(
      svtId: svt?.id,
      limitCount: limitCount,
      skillLvs: skillLvs.toList(),
      skillIds: skills.map((skill) => skill?.id).toList(),
      appendLvs: appendLvs.toList(),
      disabledExtraSkills: disabledExtraSkills.toSet(),
      allowedExtraSkills: allowedExtraSkills.toSet(),
      customPassives: customPassives.toList(),
      customPassiveLvs: customPassiveLvs.toList(),
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
      supportType: supportType,
      cardStrengthens: cardStrengthens.toList(),
      commandCodeIds: commandCodes.map((commandCode) => commandCode?.id).toList(),
    );
  }
}

class MysticCodeData {
  MysticCode? mysticCode = db.gameData.mysticCodes[210];
  int level = 10;

  bool get enabled => mysticCode != null && level > 0;

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
  bool mightyChain = true;
  bool disableEvent = false;
  bool simulateAi = false;
  bool simulateEnemy = false;
  // <groupId, pointBuff>
  Map<int, EventPointBuff> pointBuffs = {};
  Set<int> enemyRateUp = {};

  BattleOptionsEnv copy() {
    return BattleOptionsEnv()
      ..mightyChain = mightyChain
      ..disableEvent = disableEvent
      ..simulateAi = simulateAi
      ..simulateEnemy = simulateEnemy
      ..pointBuffs = Map.of(pointBuffs)
      ..enemyRateUp = enemyRateUp.toSet();
  }

  void fromShareData(BattleShareDataOption src) {
    this
      ..mightyChain = src.mightyChain
      ..disableEvent = src.disableEvent ?? disableEvent
      ..simulateAi = src.simulateAi ?? simulateAi
      ..simulateEnemy = false
      ..enemyRateUp = src.enemyRateUp?.toSet() ?? {};

    pointBuffs.clear();
    for (final (groupId, pointBuffId) in (src.pointBuffs ?? <int, int>{}).items) {
      final pointBuff = db.gameData.others.eventPointBuffs[pointBuffId];
      if (pointBuff != null) {
        pointBuffs[groupId] = pointBuff;
      }
    }
  }

  BattleShareDataOption toShareData() {
    return BattleShareDataOption(
      mightyChain: mightyChain,
      disableEvent: disableEvent,
      simulateAi: simulateAi,
      pointBuffs: pointBuffs.isEmpty ? null : pointBuffs.map((key, value) => MapEntry(key, value.id)),
      enemyRateUp: enemyRateUp.isEmpty ? null : enemyRateUp.toSet(),
    );
  }
}

class BattleOptionsRuntime extends BattleOptionsEnv {
  int random = ConstData.constants.attackRateRandomMin;
  int threshold = 1000;
  bool tailoredExecution = false;
  bool manualAllySkillTarget = false;
  bool cardDeckSimulation = false;

  @override
  BattleOptionsRuntime copy() {
    return BattleOptionsRuntime()
      ..mightyChain = mightyChain
      ..disableEvent = disableEvent
      ..simulateAi = simulateAi
      ..simulateEnemy = simulateEnemy
      ..pointBuffs = Map.of(pointBuffs)
      ..enemyRateUp = enemyRateUp.toSet()
      ..random = random
      ..threshold = threshold
      ..tailoredExecution = tailoredExecution
      ..manualAllySkillTarget = manualAllySkillTarget
      ..cardDeckSimulation = cardDeckSimulation;
  }
}

// only used before simulation started and initiation
class BattleTeamSetup {
  final List<PlayerSvtData> onFieldSvtDataList;
  final List<PlayerSvtData> backupSvtDataList;

  final MysticCodeData mysticCodeData;

  BattleTeamSetup({
    List<PlayerSvtData?>? onFieldSvtDataList,
    List<PlayerSvtData?>? backupSvtDataList,
    MysticCodeData? mysticCodeData,
  }) : onFieldSvtDataList = List.generate(3, (index) => onFieldSvtDataList?.getOrNull(index) ?? PlayerSvtData.base()),
       backupSvtDataList = List.generate(3, (index) => backupSvtDataList?.getOrNull(index) ?? PlayerSvtData.base()),
       mysticCodeData = mysticCodeData ?? MysticCodeData();

  List<PlayerSvtData> get allSvts => [...onFieldSvtDataList, ...backupSvtDataList];

  int get totalCost {
    int cost = 0;
    for (final svt in allSvts) {
      if (svt.svt == null || svt.supportType != SupportSvtType.none) continue;
      cost +=
          svt.svt!.ascensionAdd.getAscended(svt.limitCount, (attr) => attr.overwriteRarity, svt.svt!.costume) ??
          svt.svt!.cost;
      if (svt.ce != null) cost += svt.ce!.cost;
    }
    return cost;
  }

  BattleTeamSetup copy() {
    return BattleTeamSetup(
      onFieldSvtDataList: onFieldSvtDataList.map((e) => e.copy()).toList(),
      backupSvtDataList: backupSvtDataList.map((e) => e.copy()).toList(),
      mysticCodeData: mysticCodeData.copy(),
    );
  }

  void clear() {
    onFieldSvtDataList.setRange(0, onFieldSvtDataList.length, List.generate(3, (index) => PlayerSvtData.base()));
    backupSvtDataList.setRange(0, backupSvtDataList.length, List.generate(3, (index) => PlayerSvtData.base()));
  }

  BattleTeamFormation toFormationData() {
    return BattleTeamFormation(
      onFieldSvts: onFieldSvtDataList.map((e) => e.isEmpty ? null : e.toStoredData()).toList(),
      backupSvts: backupSvtDataList.map((e) => e.isEmpty ? null : e.toStoredData()).toList(),
      mysticCode: mysticCodeData.toStoredData(),
    );
  }
}

class BattleOptions extends BattleOptionsRuntime {
  BattleTeamSetup formation = BattleTeamSetup();

  @override
  BattleOptions copy() {
    return BattleOptions()
      ..mightyChain = mightyChain
      ..disableEvent = disableEvent
      ..simulateAi = simulateAi
      ..simulateEnemy = simulateEnemy
      ..pointBuffs = Map.of(pointBuffs)
      ..enemyRateUp = enemyRateUp.toSet()
      ..random = random
      ..threshold = threshold
      ..tailoredExecution = tailoredExecution
      ..manualAllySkillTarget = manualAllySkillTarget
      ..formation = formation.copy();
  }
}
