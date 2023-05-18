import 'package:chaldea/generated/l10n.dart';
import '../../utils/atlas.dart';
import '../../utils/extension.dart';
import '../db.dart';
import '../gamedata/common.dart';
import '../gamedata/const_data.dart';
import '../gamedata/mappings.dart';
import '../gamedata/quest.dart';
import '../gamedata/skill.dart';
import '_helper.dart';

part '../../generated/models/userdata/battle.g.dart';

@JsonSerializable()
class BattleSimSetting {
  // settings
  PreferPlayerSvtDataSource playerDataSource;
  Set<int> pingedCEs;
  Set<int> pingedSvts;
  bool autoAdd7KnightsTrait;

  // save data
  String? previousQuestPhase;
  PlayerSvtDefaultData defaultLvs;
  List<BattleTeamFormation> formations;
  int curFormationIndex;

  TdDamageOptions tdDmgOptions;

  BattleSimSetting({
    this.playerDataSource = PreferPlayerSvtDataSource.none,
    Set<int>? pingedCEs,
    Set<int>? pingedSvts,
    this.autoAdd7KnightsTrait = true,
    this.previousQuestPhase,
    PlayerSvtDefaultData? defaultLvs,
    List<BattleTeamFormation>? formations,
    this.curFormationIndex = 0,
    TdDamageOptions? tdDmgOptions,
  })  : pingedCEs = pingedCEs ?? {18, 28, 34, 48, 1080},
        pingedSvts = pingedSvts ?? {37, 62, 150, 215, 241, 284, 314, 316, 353, 357},
        defaultLvs = defaultLvs ?? PlayerSvtDefaultData(),
        formations = formations ?? [],
        tdDmgOptions = tdDmgOptions ?? TdDamageOptions() {
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
  Set<int> disabledExtraSkills;
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
    Set<int>? disabledExtraSkills,
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
        disabledExtraSkills = disabledExtraSkills ?? {},
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

  bool ceMaxLimitBreak;
  bool ceMaxLv;

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
    this.ceMaxLimitBreak = false,
    this.ceMaxLv = false,
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

@JsonSerializable()
class CustomSkillData {
  int? skillId;
  String name;
  SkillType skillType;
  List<CustomFuncData> effects;
  bool buffOnly;
  bool hasTurnCount;

  CustomSkillData({
    this.skillId,
    this.name = '',
    this.skillType = SkillType.passive,
    List<CustomFuncData>? effects,
    this.buffOnly = false,
    this.hasTurnCount = true,
  }) : effects = effects ?? [];

  factory CustomSkillData.fromJson(Map<String, dynamic> json) => _$CustomSkillDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomSkillDataToJson(this);

  int getSkillId() {
    return skillId = -(100000000 + DateTime.now().timestamp % 100000000);
  }

  NiceSkill? buildSkill() {
    List<NiceFunction> funcs = [];
    for (final effect in effects) {
      final func = effect.buildFunc(hasTurnCount);
      if (func == null) continue;
      if (buffOnly && func.buffs.isEmpty) continue;
      funcs.add(func);
    }
    if (funcs.isEmpty) return null;
    name = name.trim();
    final skill = NiceSkill(
      id: getSkillId(),
      name: name.isEmpty ? '${S.current.skill} ${getSkillId()}' : name,
      type: skillType,
      icon: Atlas.common.unknownSkillIcon,
      functions: funcs,
      priority: 99999,
    );
    return skill;
  }
}

@JsonSerializable()
class CustomFuncData {
  int? funcId; // funcId = -1 * originalFuncId
  int? buffId;

  int turn;
  int count;
  int rate;

  int value;
  bool enabled; // for no value, sureHit

  bool useValue;

  FuncTargetType target;

  CustomFuncData({
    this.funcId,
    this.buffId,
    this.turn = -1,
    this.count = -1,
    this.rate = 5000,
    this.value = 0,
    this.enabled = false,
    this.useValue = true,
    this.target = FuncTargetType.self,
  });

  factory CustomFuncData.fromJson(Map<String, dynamic> json) => _$CustomFuncDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomFuncDataToJson(this);

  bool get isValid => buff != null && baseFunc != null && (useValue ? value != 0 : enabled);
  //
  Buff? get buff => db.gameData.baseBuffs[buffId];
  BaseFunction? get baseFunc => db.gameData.baseFunctions[funcId?.abs()];

  String? get icon {
    return buff?.icon ?? baseFunc?.funcPopupIcon;
  }

  String get popupText {
    final _text = buff?.name ?? baseFunc?.funcPopupText;
    if (_text == null) return 'Func $funcId';
    return Transl.funcPopuptextBase(_text).l;
  }

  int? get percentBase => buff?.percentBase ?? kFuncValPercentType[baseFunc?.funcType];

  String getValueText(bool addPercent) {
    final base = percentBase;
    if (base == null || base == 0) return value.toString();
    String valueText = (value / base).format(compact: false);
    if (addPercent) valueText += '%';
    return valueText;
  }

  int? parseValue(String text) {
    final base = percentBase;
    if (base != null) {
      text = text.replaceAll('%', '').trim();
      final v = text.isEmpty ? 0.0 : double.tryParse(text);
      if (v == null) return null;
      return (v * base).toInt();
    } else {
      return text.isEmpty ? 0 : int.tryParse(text);
    }
  }

  NiceFunction? buildFunc(bool hasTurnCount) {
    final func = baseFunc;
    Buff? buff = this.buff;
    if (func == null) return null;
    if (buffId != null && buff == null) return null;
    if ((useValue && value == 0) || (!useValue && !enabled)) {
      return null;
    }
    Map<String, dynamic> vals = {
      'Rate': rate,
      if (useValue) 'Value': value,
      if (buff != null) 'Turn': hasTurnCount ? turn : -1,
      if (buff != null) 'Count': hasTurnCount ? count : -1,
    };

    return NiceFunction(
      funcId: -func.funcId,
      funcType: func.funcType,
      funcTargetType: target,
      funcTargetTeam: FuncApplyTarget.playerAndEnemy,
      funcPopupText: func.funcPopupText,
      funcPopupIcon: func.funcPopupIcon,
      functvals: func.functvals.toList(),
      traitVals: func.traitVals.toList(),
      buffs: [if (buff != null) buff],
      svals: [DataVals(vals)],
    );
  }

  // common used

  static CustomFuncData _buff(int funcId, int buffId, [bool hasValue = true]) =>
      CustomFuncData(funcId: funcId, buffId: buffId, useValue: hasValue);

  static CustomFuncData get gainNp => CustomFuncData(funcId: -460);
  static CustomFuncData get upDamage => _buff(-1077, 129);
  static CustomFuncData get upAtk => _buff(-146, 126);
  static CustomFuncData get upQuick => _buff(-100, 100);
  static CustomFuncData get upArts => _buff(-109, 101);
  static CustomFuncData get upBuster => _buff(-118, 102);
  static CustomFuncData get upNpDamage => _buff(-247, 138);
  static CustomFuncData get upChargeTd => _buff(-753, 227);
  static CustomFuncData get upCriticaldamage => _buff(-199, 142);
  static CustomFuncData get upDropNp => _buff(-336, 140);
  static CustomFuncData get upCriticalpoint => _buff(-295, 117);
  static CustomFuncData get breakAvoidance => _buff(-288, 154, false);
  static CustomFuncData get pierceInvincible => _buff(-510, 189, false);

  static List<CustomFuncData> get allTypes => [
        gainNp,
        upDamage,
        upAtk,
        upQuick,
        upArts,
        upBuster,
        upNpDamage,
        upChargeTd,
        upCriticaldamage,
        upDropNp,
        upCriticalpoint,
        breakAvoidance,
        pierceInvincible,
      ];

  static List<CustomFuncData> get tdDmgTypes => [
        upDamage,
        upAtk,
        upQuick,
        upArts,
        upBuster,
        upNpDamage,
        upDropNp,
        upCriticalpoint,
      ];
}

@JsonSerializable(converters: [_QuestEnemyConverter(), RegionConverter()])
class TdDamageOptions {
  QuestEnemy enemy;
  List<int> supports = [];

  // only use some fields
  // DamageParameters params = DamageParameters();
  int enemyCount = 1;
  PreferPlayerSvtDataSource usePlayerSvt = PreferPlayerSvtDataSource.none;
  bool addDebuffImmune = true;
  bool addDebuffImmuneEnemy = false;
  bool upResistSubState = true; // 5000
  bool enableActiveSkills = true;
  bool twiceActiveSkill = false;
  bool enableAppendSkills = false;
  // bool includeRefundAfterTd = true; // 重蓄力
  SvtLv svtLv = SvtLv.maxLv;
  int tdR3 = 5;
  int tdR4 = 2;
  int tdR5 = 1;
  int oc = 1;
  bool fixedOC = true;
  Region region = Region.jp;
  // CE & MC
  int? ceId;
  int ceLv = 0;
  bool ceMLB = true;
  int? mcId;
  int mcLv = 10;

  CustomSkillData extraBuffs;
  int fixedRandom = 1000;
  int probabilityThreshold = 1000;

  bool forceDamageNpSe;
  int? damageNpIndivSumCount;
  bool damageNpHpRatioMax;

  TdDamageOptions({
    QuestEnemy? enemy,
    List<int>? supports,
    this.enemyCount = 1,
    this.usePlayerSvt = PreferPlayerSvtDataSource.none,
    this.addDebuffImmune = true,
    this.addDebuffImmuneEnemy = false,
    this.upResistSubState = true,
    this.enableActiveSkills = true,
    this.twiceActiveSkill = false,
    this.enableAppendSkills = false,
    this.svtLv = SvtLv.maxLv,
    this.tdR3 = 5,
    this.tdR4 = 2,
    this.tdR5 = 1,
    this.oc = 1,
    this.fixedOC = true,
    this.region = Region.jp,
    this.ceId,
    this.ceLv = 0,
    this.ceMLB = true,
    this.mcId,
    this.mcLv = 10,
    CustomSkillData? extraBuffs,
    this.fixedRandom = 1000,
    this.probabilityThreshold = 1000,
    this.forceDamageNpSe = false,
    this.damageNpIndivSumCount,
    this.damageNpHpRatioMax = false,
  })  : enemy = enemy ?? QuestEnemy.blankEnemy(),
        supports = supports ?? [],
        extraBuffs = extraBuffs ?? CustomSkillData(buffOnly: true, hasTurnCount: false);

  void initBuffs() {
    final buffMap = {
      for (final e in extraBuffs.effects) e.buffId: e,
    };
    List<CustomFuncData> effects = [];
    for (final effect in CustomFuncData.tdDmgTypes) {
      final prevData = buffMap[effect.buffId];
      if (prevData == null) {
        effects.add(effect);
      } else {
        prevData
          ..funcId = effect.funcId
          ..buffId = effect.buffId
          ..useValue = effect.useValue
          ..target = FuncTargetType.self;
        effects.add(prevData);
      }
    }
    extraBuffs
      ..skillType = SkillType.passive
      ..hasTurnCount = false
      ..buffOnly = true
      ..effects = effects;
  }

  static const List<int> optionalSupports = [37, 62, 150, 215, 241, 284, 314, 316, 353, 357];

  factory TdDamageOptions.fromJson(Map<String, dynamic> json) => _$TdDamageOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TdDamageOptionsToJson(this);
}

class _QuestEnemyConverter extends JsonConverter<QuestEnemy, Map> {
  const _QuestEnemyConverter();
  @override
  QuestEnemy fromJson(Map json) => QuestEnemy.fromJson(Map.from(json));

  @override
  Map toJson(QuestEnemy enemy) => enemy.toJson();
}

enum SvtLv {
  maxLv(null), // Mash's at 70 by default
  lv90(90),
  lv100(100),
  lv120(120),
  ;

  const SvtLv(this.lv);
  final int? lv;
}

enum PreferPlayerSvtDataSource {
  none,
  current,
  target,
  ;

  bool get isNone => this == PreferPlayerSvtDataSource.none;
}
