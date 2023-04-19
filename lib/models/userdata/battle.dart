import '_helper.dart';

part '../../generated/models/userdata/battle.g.dart';

@JsonSerializable()
class BattleSimSetting {
  String? previousQuestPhase;
  bool preferPlayerData;
  Set<int> pingedCEs;
  Set<int> pingedSvts;
  PlayerSvtDefaultData defaultLvs;

  BattleSimSetting({
    this.previousQuestPhase,
    this.preferPlayerData = true,
    Set<int>? pingedCEs,
    Set<int>? pingedSvts,
    PlayerSvtDefaultData? defaultLvs,
  })  : pingedCEs = pingedCEs ?? {18, 28, 34, 48, 1080},
        pingedSvts = pingedSvts ?? {37, 62, 150, 215, 241, 284, 314, 316, 353, 357},
        defaultLvs = defaultLvs ?? PlayerSvtDefaultData();

  factory BattleSimSetting.fromJson(Map<String, dynamic> json) => _$BattleSimSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BattleSimSettingToJson(this);
}

@JsonSerializable()
class PlayerSvtDefaultData {
  int limitCount;
  List<int> skillLvs;
  List<int> appendLvs;
  int? tdLv;
  int? lv; // null=mlb
  int atkFou;
  int hpFou;
  List<int> cardStrengthens;

  PlayerSvtDefaultData({
    this.limitCount = 4,
    List<int>? skillLvs,
    List<int>? appendLvs,
    this.tdLv = 5,
    this.lv,
    this.atkFou = 1000,
    this.hpFou = 1000,
    List<int>? cardStrengthens,
  })  : skillLvs = skillLvs ?? [10, 10, 10],
        appendLvs = appendLvs ?? [0, 0, 0],
        cardStrengthens = cardStrengthens ?? [0, 0, 0, 0, 0];

  factory PlayerSvtDefaultData.fromJson(Map<String, dynamic> json) => _$PlayerSvtDefaultDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerSvtDefaultDataToJson(this);
}
