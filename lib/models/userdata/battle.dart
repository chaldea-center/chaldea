import 'dart:convert';

import 'package:archive/archive.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/url.dart';
import '../../utils/atlas.dart';
import '../../utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'filter_data.dart';

part '../../generated/models/userdata/battle.g.dart';

void _removeEmptyList(Map<String, dynamic> data, List<String> keys,
    {bool removeAllNull = false, bool removeAllZero = false}) {
  for (final key in keys) {
    if (!data.containsKey(key)) continue;
    final value = data[key];
    bool remove = false;
    if (value == null) {
      remove = true;
    } else if (value is List) {
      if (value.isEmpty) {
        remove = true;
      } else if (removeAllNull && value.every((e) => e == null)) {
        remove = true;
      } else if (removeAllZero && value.every((e) => e == 0)) {
        remove = true;
      }
    }
    if (remove) {
      data.remove(key);
    }
  }
}

@JsonSerializable(converters: [RegionConverter()])
class BattleSimUserData {
  Set<int> pingedCEs;
  Set<int> pingedSvts;
  // questId, teamIds
  Map<int, Set<int>> favoriteTeams;
  @protected
  List<BattleTeamFormation> formations;
  List<BattleShareData> teams;

  BattleSimUserData({
    Set<int>? pingedCEs,
    Set<int>? pingedSvts,
    Map<int, Set<int>>? favoriteTeams,
    List<BattleTeamFormation>? formations,
    List<BattleShareData>? teams,
  })  : pingedCEs = pingedCEs ?? {18, 28, 34, 48, 1080},
        pingedSvts = pingedSvts ?? {215, 284, 314, 316, 357},
        favoriteTeams = favoriteTeams ?? {},
        formations = formations ?? [],
        teams = teams ?? [] {
    if (teams == null && formations != null) {
      this.teams.addAll(formations.map((e) => BattleShareData(quest: null, formation: e)));
    }
    validate();
  }

  void validate() {
    // when migrating, check [formations] isEmpty
    // if (formations.isEmpty) {
    //   formations.add(BattleTeamFormation());
    // }
  }
  bool isTeamFavorite(int? questId, int teamId) {
    if (questId != null) {
      return favoriteTeams[questId]?.contains(teamId) == true;
    } else {
      return favoriteTeams.values.any((ids) => ids.contains(teamId));
    }
  }

  Set<int> pingedCEsWithEventAndBond(final QuestPhase? questPhase, final Servant? svt) {
    final event = questPhase?.war?.event;
    Set<int> pinged = pingedCEs.toSet();
    if (event != null) {
      for (final ce in db.gameData.craftEssences.values) {
        if (pinged.contains(ce.collectionNo)) continue;
        if (ce.skills.any((skill) => skill.isEventSkill(event))) {
          pinged.add(ce.collectionNo);
        }
      }
    }
    final bondCE = db.gameData.craftEssencesById[svt?.bondEquip];
    if (bondCE != null && bondCE.collectionNo > 0) {
      pinged.add(bondCE.collectionNo);
    }
    return pinged;
  }

  factory BattleSimUserData.fromJson(Map<String, dynamic> json) => _$BattleSimUserDataFromJson(json);

  Map<String, dynamic> toJson() => _$BattleSimUserDataToJson(this);
}

@JsonSerializable(converters: [RegionConverter()])
class BattleSimSetting {
  // settings
  Region? playerRegion;
  PreferPlayerSvtDataSource playerDataSource;

  // save data
  String? previousQuestPhase;
  PlayerSvtDefaultData defaultLvs;
  BattleShareData curTeam;
  // filters
  SvtFilterData svtFilterData;
  CraftFilterData craftFilterData;

  TdDamageOptions tdDmgOptions;

  bool recordScreenshotJpg;
  int recordScreenshotRatio; // 10-30
  bool recordShowTwoColumn;

  bool manualAllySkillTarget;

  BattleSimSetting({
    this.playerRegion,
    this.playerDataSource = PreferPlayerSvtDataSource.none,
    this.previousQuestPhase,
    PlayerSvtDefaultData? defaultLvs,
    BattleShareData? curTeam,
    SvtFilterData? svtFilterData,
    CraftFilterData? craftFilterData,
    TdDamageOptions? tdDmgOptions,
    this.recordScreenshotJpg = false,
    this.recordScreenshotRatio = 10,
    this.recordShowTwoColumn = false,
    this.manualAllySkillTarget = false,
  })  : defaultLvs = defaultLvs ?? PlayerSvtDefaultData(),
        curTeam = curTeam ?? BattleShareData(quest: null, formation: BattleTeamFormation()),
        svtFilterData = svtFilterData ?? SvtFilterData(useGrid: true),
        craftFilterData = craftFilterData ?? CraftFilterData(useGrid: true),
        tdDmgOptions = tdDmgOptions ?? TdDamageOptions() {
    validate();
    this.craftFilterData.obtain.options =
        CEObtain.values.toSet().difference({CEObtain.valentine, CEObtain.exp, CEObtain.campaign});
  }

  void validate() {
    //
  }

  factory BattleSimSetting.fromJson(Map<String, dynamic> json) => _$BattleSimSettingFromJson(json);

  Map<String, dynamic> toJson() => _$BattleSimSettingToJson(this);
}

@JsonSerializable(includeIfNull: false)
class BattleShareData {
  static const int kMinBuild = 933; //2.4.1
  static const int kDataVer = 2;
  int? minBuild;
  int? appBuild; // app ver for uploaded data
  BattleQuestInfo? quest;
  BattleShareDataOption options;
  @JsonKey(name: 'team')
  BattleTeamFormation formation;
  BattleReplayDelegateData? delegate;
  List<BattleRecordData> actions;

  BattleShareData({
    this.minBuild,
    this.appBuild,
    required this.quest,
    BattleShareDataOption? options,
    required this.formation,
    this.delegate,
    List<BattleRecordData>? actions,
  })  : options = options ?? BattleShareDataOption(),
        actions = actions ?? [];

  factory BattleShareData.fromJson(Map<String, dynamic> json) => _$BattleShareDataFromJson(json);

  Map<String, dynamic> toJson() {
    // final team2 = BattleTeamFormation.fromJson(formation.toJson());
    // for (final svt in [...team2.onFieldSvts, ...team2.backupSvts]) {
    //   svt?.customPassives.clear();
    //   svt?.customPassiveLvs.clear();
    // }
    return _$BattleShareDataToJson(BattleShareData(
      minBuild: kMinBuild,
      appBuild: appBuild ?? AppInfo.buildNumber,
      quest: quest,
      options: options,
      formation: formation,
      delegate: delegate,
      actions: actions,
    ));
  }

  BattleShareData copy() {
    return BattleShareData.fromJson(toJson());
  }

  Uri toUriV2() {
    String data = toDataV2();
    Uri shareUri = Uri.parse(ChaldeaUrl.deepLink('/laplace/share'));
    shareUri = shareUri.replace(queryParameters: {
      "data": data,
      if (quest != null) ...{
        "questId": quest!.id.toString(),
        "phase": quest!.phase.toString(),
        if (quest!.enemyHash != null) "enemyHash": quest!.enemyHash,
      }
    });
    return shareUri;
  }

  String toDataV2() {
    final shareData = jsonEncode(this);
    String data = base64UrlEncode(GZipEncoder().encode(utf8.encode(shareData), level: Deflate.BEST_COMPRESSION)!);
    return 'G$data';
  }

  // keep 4 bytes for format in the future
  static BattleShareData? parseUri(Uri uri) {
    final content = uri.queryParameters['data'];
    if (content == null) return null;
    return parse(content);
  }

  static BattleShareData? parse(String content) {
    if (content.length < 4) return null;
    final method = content.substring(0, 1);
    // final ver = v.substring(1, 2);
    if (method == 'G') {
      return _parseGzip(content.substring(1));
    } else if (content.startsWith('H4s')) {
      // old format
      return _parseGzip(content);
    }
    return null;
  }

  static BattleShareData _parseGzip(String encoded) {
    final data = jsonDecode(utf8.decode(GZipDecoder().decodeBytes(base64Decode(encoded))));
    return BattleShareData.fromJson(data);
  }

  //

  bool usedMysticCodeSkill(final int checkIndex) {
    return actions.any((action) => action.usedMysticCode(checkIndex));
  }

  bool containsTdCardType(final CardType cardType) {
    return actions.any((action) => action.containsTdCardType(cardType));
  }

  int get critsCount => actions.fold(0, (sum, action) => sum + action.countCrits());

  int get normalAttackCount => actions.fold(0, (sum, action) => sum + action.countNormalAttacks());
}

@JsonSerializable()
class BattleShareDataOption {
  bool mightyChain;
  bool? disableEvent;
  Map<int, int>? pointBuffs; // <groupId, pointBuffId>
  bool? simulateAi;
  Set<int>? enemyRateUp; // indiv

  BattleShareDataOption({
    this.mightyChain = true,
    this.disableEvent,
    this.pointBuffs,
    this.simulateAi,
    this.enemyRateUp,
  });

  factory BattleShareDataOption.fromJson(Map<String, dynamic> json) => _$BattleShareDataOptionFromJson(json);

  Map<String, dynamic> toJson() => _$BattleShareDataOptionToJson(this);
}

@JsonSerializable(includeIfNull: false, converters: [RegionConverter()])
class BattleQuestInfo {
  int id;
  int phase;
  String? enemyHash;
  Region? region;

  BattleQuestInfo({
    required this.id,
    required this.phase,
    required this.enemyHash,
    this.region,
  });

  BattleQuestInfo.quest(QuestPhase quest, {this.region})
      : id = quest.id,
        phase = quest.phase,
        enemyHash = quest.enemyHash;

  String toUrl() {
    String url = '$id/$phase';
    if (enemyHash != null) {
      url += '?hash=$enemyHash';
    }
    if (region == Region.jp || region == Region.na) {
      url = '${region?.upper}/$url';
    }
    return url;
  }

  factory BattleQuestInfo.fromJson(Map<String, dynamic> json) => _$BattleQuestInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BattleQuestInfoToJson(this);

  static BattleQuestInfo? fromQuery(Map<String, String> query) {
    final id = int.tryParse(query['questId'] ?? "");
    final phase = int.tryParse(query['phase'] ?? "") ?? db.gameData.quests[id]?.phases.lastOrNull;
    final enemyHash = query['enemyHash'];
    if (id != null && phase != null) {
      return BattleQuestInfo(id: id, phase: phase, enemyHash: enemyHash);
    }
    return null;
  }
}

@JsonSerializable()
class BattleTeamFormation {
  String? name;
  MysticCodeSaveData mysticCode;
  List<SvtSaveData?> onFieldSvts;
  List<SvtSaveData?> backupSvts;

  BattleTeamFormation({
    this.name,
    MysticCodeSaveData? mysticCode,
    List<SvtSaveData?>? onFieldSvts,
    List<SvtSaveData?>? backupSvts,
  })  : mysticCode = mysticCode ?? MysticCodeSaveData(),
        onFieldSvts = List.generate(3, (index) => onFieldSvts?.getOrNull(index)),
        backupSvts = List.generate(3, (index) => backupSvts?.getOrNull(index));

  factory BattleTeamFormation.fromJson(Map<String, dynamic> json) => _$BattleTeamFormationFromJson(json);

  Map<String, dynamic> toJson() => _$BattleTeamFormationToJson(this);

  BattleTeamFormation copy() => BattleTeamFormation.fromJson(toJson());

  List<SvtSaveData?> get allSvts => [...onFieldSvts, ...backupSvts];

  String shownName(int index) {
    String text = '${S.current.team} ${index + 1}';
    if (name != null && name!.isNotEmpty) {
      text += ': $name';
    }
    return text;
  }

  List<int> get allCardIds {
    Set<int> ids = {};
    for (final svt in allSvts) {
      final svtId = svt?.svtId;
      if (svt != null && svtId != null && svtId > 0) {
        ids.add(svtId);
        if (svt.ceId != null) {
          ids.add(svt.ceId!);
        }
      }
    }
    return ids.toList();
  }
}

@JsonSerializable(includeIfNull: false)
class SvtSaveData {
  int? svtId;
  int limitCount;
  List<int?> skillIds;
  List<int> skillLvs;
  List<int> appendLvs;
  int? tdId;
  int tdLv;

  int lv;
  int atkFou;
  int hpFou;

  // for support or custom
  int? fixedAtk;
  int? fixedHp;

  int? ceId;
  bool ceLimitBreak;
  int ceLv;

  SupportSvtType supportType;

  List<int> cardStrengthens;
  List<int?> commandCodeIds;
  Set<int> disabledExtraSkills;
  List<BaseSkill> customPassives;
  List<int> customPassiveLvs;

  SvtSaveData({
    this.svtId,
    this.limitCount = 4,
    List<int>? skillLvs,
    List<int?>? skillIds,
    List<int>? appendLvs,
    this.tdId = 0,
    this.tdLv = 5,
    this.lv = 1,
    this.atkFou = 1000,
    this.hpFou = 1000,
    this.fixedAtk,
    this.fixedHp,
    this.ceId,
    this.ceLimitBreak = false,
    this.ceLv = 0,
    this.supportType = SupportSvtType.none,
    List<int>? cardStrengthens,
    List<int?>? commandCodeIds,
    Set<int>? disabledExtraSkills,
    List<BaseSkill>? customPassives,
    List<int>? customPassiveLvs,
  })  : skillLvs = skillLvs ?? [10, 10, 10],
        skillIds = List.generate(3, (index) => skillIds?.getOrNull(index)),
        appendLvs = List.generate(3, (index) => appendLvs?.getOrNull(index) ?? 0),
        cardStrengthens = List.generate(5, (index) => cardStrengthens?.getOrNull(index) ?? 0),
        commandCodeIds = List.generate(5, (index) => commandCodeIds?.getOrNull(index)),
        disabledExtraSkills = disabledExtraSkills ?? {},
        customPassives = List<BaseSkill>.from(customPassives ?? []),
        customPassiveLvs = customPassiveLvs ?? [];

  factory SvtSaveData.fromJson(Map<String, dynamic> json) => _$SvtSaveDataFromJson(json);

  Map<String, dynamic> toJson() {
    if (svtId == null || svtId == 0) return {};
    final data = _$SvtSaveDataToJson(this);
    _removeEmptyList(
      data,
      ['appendLvs', 'cardStrengthens', 'commandCodeIds', 'disabledExtraSkills', 'customPassives', 'customPassiveLvs'],
      removeAllNull: true,
      removeAllZero: true,
    );
    return data;
  }
}

@JsonSerializable()
class MysticCodeSaveData {
  int? mysticCodeId;
  int level;

  MysticCodeSaveData({
    this.mysticCodeId,
    this.level = 0,
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
  int cd;
  SkillType skillType;
  List<CustomFuncData> effects;
  bool buffOnly;
  bool hasTurnCount;

  CustomSkillData({
    this.skillId,
    this.name = '',
    this.cd = 0,
    this.skillType = SkillType.passive,
    List<CustomFuncData>? effects,
    this.buffOnly = false,
    this.hasTurnCount = true,
  }) : effects = effects ?? [];

  factory CustomSkillData.fromJson(Map<String, dynamic> json) => _$CustomSkillDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomSkillDataToJson(this);

  int getSkillId() {
    return skillId = -(1000000 + DateTime.now().timestamp % 1000000);
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
      coolDown: [cd >= 0 ? cd : 0],
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
  static CustomFuncData _debuff(int funcId, int buffId, [bool hasValue = true]) =>
      CustomFuncData(funcId: funcId, buffId: buffId, useValue: hasValue, target: FuncTargetType.enemyAll);

  static CustomFuncData get gainNp => CustomFuncData(funcId: -476);
  static CustomFuncData get gainStar => CustomFuncData(funcId: -460);
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
  static CustomFuncData get downDef => _debuff(-197, 148);
  static CustomFuncData get downQuick => _debuff(-1596, 504);
  static CustomFuncData get downArts => _debuff(-1602, 505);
  static CustomFuncData get downBuster => _debuff(-1608, 506);

  static List<CustomFuncData> get allTypes => [
        gainNp,
        gainStar,
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
        downDef,
        downQuick,
        downArts,
        downBuster,
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
        downDef,
        downQuick,
        downArts,
        downBuster,
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
  bool fixedOC = false;
  Region region = Region.jp;
  // CE & MC
  int? ceId;
  int ceLv = 0;
  bool ceMLB = true;
  int? mcId;
  int mcLv = 10;

  CustomSkillData extraBuffs;
  int random = 1000;
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
    this.random = 1000,
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

enum SupportSvtType {
  none,
  friend,
  npc,
  ;

  bool get isSupport => this != SupportSvtType.none;

  String get shownName {
    switch (this) {
      case SupportSvtType.none:
        return S.current.item_own;
      case SupportSvtType.friend:
        return S.current.support_servant_short;
      case SupportSvtType.npc:
        return 'NPC';
    }
  }
}

@JsonSerializable()
class BattleReplayDelegateData {
  List<int?> actWeightSelections;
  List<int?> skillActSelectSelections;
  @JsonKey(unknownEnumValue: CardType.none)
  List<CardType> tdTypeChanges;
  List<int?> ptRandomIndexes;
  List<bool> canActivateDecisions;
  List<int> damageSelections;
  List<List<int>> replaceMemberIndexes; // [(x,y)]

  BattleReplayDelegateData({
    List<int?>? actWeightSelections,
    List<int?>? skillActSelectSelections,
    List<CardType>? tdTypeChanges,
    List<int?>? ptRandomIndexes,
    List<bool>? canActivateDecisions,
    List<int>? damageSelections,
    List<List<int>>? replaceMemberIndexes,
  })  : actWeightSelections = actWeightSelections ?? [],
        skillActSelectSelections = skillActSelectSelections ?? [],
        tdTypeChanges = tdTypeChanges ?? [],
        ptRandomIndexes = ptRandomIndexes ?? [],
        canActivateDecisions = canActivateDecisions ?? [],
        damageSelections = damageSelections ?? [],
        replaceMemberIndexes = replaceMemberIndexes ?? [];

  factory BattleReplayDelegateData.fromJson(Map<String, dynamic> json) => _$BattleReplayDelegateDataFromJson(json);

  Map<String, dynamic> toJson() {
    final data = _$BattleReplayDelegateDataToJson(this);
    data.removeWhere((key, value) => value is List && value.isEmpty);
    return data;
  }

  BattleReplayDelegateData copy() {
    return BattleReplayDelegateData.fromJson(toJson());
  }
}

@JsonSerializable()
class BattleActionOptions {
  int playerTarget;
  int enemyTarget;
  int random;
  int threshold;
  // for upload data, this is not allowed
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool tailoredExecution;

  BattleActionOptions({
    this.playerTarget = 0,
    this.enemyTarget = 0,
    this.random = 900,
    this.threshold = 1000,
    this.tailoredExecution = false,
  });

  factory BattleActionOptions.fromJson(Map<String, dynamic> json) => _$BattleActionOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$BattleActionOptionsToJson(this);
}

enum BattleRecordDataType { base, skill, attack }

@JsonSerializable(includeIfNull: false)
class BattleRecordData {
  BattleRecordDataType type;
  int? svt;
  int? skill;
  List<BattleAttackRecordData>? attacks;
  BattleActionOptions options;

  BattleRecordData({BattleActionOptions? options})
      : type = BattleRecordDataType.base,
        options = options ?? BattleActionOptions();

  BattleRecordData.skill({
    this.svt,
    this.skill,
    BattleActionOptions? options,
  })  : type = BattleRecordDataType.skill,
        options = options ?? BattleActionOptions();

  BattleRecordData.attack({
    List<BattleAttackRecordData>? attacks,
    BattleActionOptions? options,
  })  : type = BattleRecordDataType.attack,
        attacks = attacks ?? [],
        options = options ?? BattleActionOptions();

  factory BattleRecordData.fromJson(Map<String, dynamic> json) => _$BattleRecordDataFromJson(json);

  Map<String, dynamic> toJson() => _$BattleRecordDataToJson(this);

  bool usedMysticCode(final int checkIndex) {
    return type == BattleRecordDataType.skill && svt == null && skill == checkIndex;
  }

  bool containsTdCardType(final CardType cardType) {
    if (attacks == null || attacks!.isEmpty) {
      return false;
    }
    return attacks!.any((cardAction) => cardAction.isTD && cardAction.cardType == cardType);
  }

  int countCrits() {
    if (attacks == null || attacks!.isEmpty) {
      return 0;
    }
    return attacks!.fold(0, (sum, cardAction) => cardAction.critical ? sum + 1 : sum);
  }

  int countNormalAttacks() {
    if (attacks == null || attacks!.isEmpty) {
      return 0;
    }
    return attacks!.fold(0, (sum, cardAction) => !cardAction.isTD ? sum + 1 : sum);
  }
}

@JsonSerializable()
class BattleAttackRecordData {
  int svt;
  int? card;
  bool isTD;
  bool critical;
  CardType cardType;

  BattleAttackRecordData({
    this.svt = 0,
    this.card,
    this.isTD = false,
    this.critical = false,
    this.cardType = CardType.none,
  });

  factory BattleAttackRecordData.fromJson(Map<String, dynamic> json) => _$BattleAttackRecordDataFromJson(json);

  Map<String, dynamic> toJson() => _$BattleAttackRecordDataToJson(this);
}
