import '../../utils/extension.dart';
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
