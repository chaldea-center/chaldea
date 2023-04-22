import '../../utils/extension.dart';
import '../gamedata/skill.dart';
import '_helper.dart';

part '../../generated/models/userdata/battle.g.dart';

@JsonSerializable()
class BattleSimSetting {
  String? previousQuestPhase;
  bool preferPlayerData;
  Set<int> pingedCEs;
  Set<int> pingedSvts;
  PlayerSvtDefaultData defaultLvs;
  List<Formation> formations;

  BattleSimSetting({
    this.previousQuestPhase,
    this.preferPlayerData = true,
    Set<int>? pingedCEs,
    Set<int>? pingedSvts,
    PlayerSvtDefaultData? defaultLvs,
    List<Formation>? formations,
  })  : pingedCEs = pingedCEs ?? {18, 28, 34, 48, 1080},
        pingedSvts = pingedSvts ?? {37, 62, 150, 215, 241, 284, 314, 316, 353, 357},
        defaultLvs = defaultLvs ?? PlayerSvtDefaultData(),
        formations = formations ?? [];

  factory BattleSimSetting.fromJson(Map<String, dynamic> json) => _$BattleSimSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BattleSimSettingToJson(this);
}

@JsonSerializable()
class Formation {
  String? name;

  List<StoredSvtData> onFieldSvtDataList;
  List<StoredSvtData> backupSvtDataList;
  StoredMysticCodeData mysticCodeData;

  Formation({
    this.name,
    List<StoredSvtData>? onFieldSvtDataList,
    List<StoredSvtData>? backupSvtDataList,
    StoredMysticCodeData? mysticCodeData,
  })  : onFieldSvtDataList = onFieldSvtDataList ?? [],
        backupSvtDataList = backupSvtDataList ?? [],
        mysticCodeData = mysticCodeData ?? StoredMysticCodeData();

  factory Formation.fromJson(Map<String, dynamic> json) => _$FormationFromJson(json);

  Map<String, dynamic> toJson() => _$FormationToJson(this);
}

@JsonSerializable()
class StoredSvtData {
  int? svtId;
  int limitCount;
  List<int> skillLvs;
  List<int?> skillIds;
  List<int> appendLvs;
  List<int> extraPassiveIds;
  List<BaseSkill> additionalPassives;
  List<int> additionalPassiveLvs;
  int tdLv;
  int? tdId;

  int lv;
  int atkFou;
  int hpFou;

  // for support or custom
  int? fixedAtk;
  int? fixedHp;

  int? ceId;
  bool ceLimitBreak;
  int ceLv;

  bool isSupportSvt;

  List<int> cardStrengthens;
  List<int?> commandCodeIds;

  StoredSvtData({
    this.svtId,
    this.limitCount = 4,
    List<int>? skillLvs,
    List<int?>? skillIds,
    List<int>? appendLvs,
    List<int>? extraPassiveIds,
    List<BaseSkill>? additionalPassives,
    List<int>? additionalPassiveLvs,
    this.tdLv = 5,
    this.tdId,
    this.lv = 1,
    this.atkFou = 1000,
    this.hpFou = 1000,
    this.fixedAtk,
    this.fixedHp,
    this.ceId,
    this.ceLimitBreak = false,
    this.ceLv = 0,
    this.isSupportSvt = false,
    List<int>? cardStrengthens,
    List<int?>? commandCodeIds,
  })  : skillLvs = skillLvs ?? [10, 10, 10],
        skillIds = skillIds ?? [null, null, null],
        appendLvs = appendLvs ?? [0, 0, 0],
        extraPassiveIds = extraPassiveIds ?? [],
        additionalPassives = additionalPassives ?? [],
        additionalPassiveLvs = additionalPassiveLvs ?? [],
        cardStrengthens = cardStrengthens ?? [0, 0, 0, 0, 0],
        commandCodeIds = commandCodeIds ?? [null, null, null, null, null];

  factory StoredSvtData.fromJson(Map<String, dynamic> json) => _$StoredPlayerSvtDataFromJson(json);

  Map<String, dynamic> toJson() => _$StoredPlayerSvtDataToJson(this);
}

@JsonSerializable()
class StoredMysticCodeData {
  int? mysticCodeId;
  int level;

  StoredMysticCodeData({
    this.mysticCodeId,
    this.level = 10,
  });

  factory StoredMysticCodeData.fromJson(Map<String, dynamic> json) => _$StoredMysticCodeDataFromJson(json);

  Map<String, dynamic> toJson() => _$StoredMysticCodeDataToJson(this);
}

@JsonSerializable()
class PlayerSvtDefaultData {
  bool useMaxLv;
  int lv;
  bool useDefaultTdLv;
  int tdLv;
  int limitCount;
  int activeSkillLv;
  List<int> appendLvs;

  // Not exposed to user yet
  int atkFou; // 0-100-200
  int hpFou;
  List<int> cardStrengthens;

  PlayerSvtDefaultData({
    this.lv = 90,
    this.useMaxLv = true,
    this.tdLv = 5,
    this.useDefaultTdLv = true,
    this.limitCount = 4,
    this.activeSkillLv = 10,
    List<int>? appendLvs,
    this.atkFou = 100,
    this.hpFou = 100,
    List<int>? cardStrengthens,
  })  : appendLvs = List.generate(3, (index) => appendLvs?.getOrNull(index) ?? 0),
        cardStrengthens = List.generate(5, (index) => cardStrengthens?.getOrNull(index) ?? 0) {
    validate();
  }

  factory PlayerSvtDefaultData.fromJson(Map<String, dynamic> json) => _$PlayerSvtDefaultDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerSvtDefaultDataToJson(this);

  void validate() {
    lv = lv.clamp(1, 120);
    tdLv = tdLv.clamp(1, 5);
    limitCount = limitCount.clamp(0, 4);
    atkFou = atkFou.clamp(0, 200);
    hpFou = hpFou.clamp(0, 200);
    activeSkillLv = activeSkillLv.clamp(1, 10);
    for (int index = 0; index < appendLvs.length; index++) {
      appendLvs[index] = appendLvs[index].clamp(0, 10);
    }
    for (int index = 0; index < cardStrengthens.length; index++) {
      cardStrengthens[index] = cardStrengthens[index].clamp(0, 25);
    }
  }
}
