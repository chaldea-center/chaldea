import 'package:chaldea/generated/l10n.dart';
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
  List<BattleTeamFormation> formations;
  int curFormationIndex;

  BattleSimSetting({
    this.previousQuestPhase,
    this.preferPlayerData = true,
    Set<int>? pingedCEs,
    Set<int>? pingedSvts,
    PlayerSvtDefaultData? defaultLvs,
    List<BattleTeamFormation>? formations,
    this.curFormationIndex = 0,
  })  : pingedCEs = pingedCEs ?? {18, 28, 34, 48, 1080},
        pingedSvts = pingedSvts ?? {37, 62, 150, 215, 241, 284, 314, 316, 353, 357},
        defaultLvs = defaultLvs ?? PlayerSvtDefaultData(),
        formations = formations ?? [] {
    validate();
  }

  void validate() {
    if (formations.isEmpty) {
      formations.add(BattleTeamFormation());
    }
    curFormationIndex = curFormationIndex.clamp(0, formations.length - 1);
  }

  factory BattleSimSetting.fromJson(Map<String, dynamic> json) => _$BattleSimSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BattleSimSettingToJson(this);

  BattleTeamFormation get curFormation {
    validate();
    return formations[curFormationIndex];
  }

  set(BattleTeamFormation formation) {
    validate();
    formations[curFormationIndex] = formation;
  }
}

@JsonSerializable()
class BattleTeamFormation {
  String? name;

  List<SvtSaveData?> onFieldSvts;
  List<SvtSaveData?> backupSvts;
  MysticCodeSaveData mysticCode;

  BattleTeamFormation({
    this.name,
    List<SvtSaveData?>? onFieldSvts,
    List<SvtSaveData?>? backupSvts,
    MysticCodeSaveData? mysticCode,
  })  : onFieldSvts = List.generate(3, (index) => onFieldSvts?.getOrNull(index)),
        backupSvts = List.generate(3, (index) => backupSvts?.getOrNull(index)),
        mysticCode = mysticCode ?? MysticCodeSaveData();

  factory BattleTeamFormation.fromJson(Map<String, dynamic> json) => _$BattleTeamFormationFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTeamFormationToJson(this);

  String shownName(int index) {
    String text = '${S.current.team} ${index + 1}';
    if (name != null && name!.isNotEmpty) {
      text += ': $name';
    }
    return text;
  }
}

@JsonSerializable()
class SvtSaveData {
  int? svtId;
  int limitCount;
  List<int> skillLvs;
  List<int?> skillIds;
  List<int> appendLvs;
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

  SvtSaveData({
    this.svtId,
    this.limitCount = 4,
    List<int>? skillLvs,
    List<int?>? skillIds,
    List<int>? appendLvs,
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
        additionalPassives = additionalPassives ?? [],
        additionalPassiveLvs = additionalPassiveLvs ?? [],
        cardStrengthens = cardStrengthens ?? [0, 0, 0, 0, 0],
        commandCodeIds = commandCodeIds ?? [null, null, null, null, null];

  factory SvtSaveData.fromJson(Map<String, dynamic> json) => _$SvtSaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$SvtSaveDataToJson(this);
}

@JsonSerializable()
class MysticCodeSaveData {
  int? mysticCodeId;
  int level;

  MysticCodeSaveData({
    this.mysticCodeId = 210,
    this.level = 10,
  });

  factory MysticCodeSaveData.fromJson(Map<String, dynamic> json) => _$MysticCodeSaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$MysticCodeSaveDataToJson(this);
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
