// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/buff/buff_detail.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../../app/tools/gamedata_loader.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'const_data.dart';
import 'mappings.dart';
import 'vals.dart';

part '../../generated/models/gamedata/buff.g.dart';

@JsonSerializable()
class Buff with RouteInfo {
  final int id;
  final String name;
  final String detail;
  final String? icon;
  @BuffTypeConverter()
  final BuffType type;
  final int buffGroup;
  final BuffScript script;
  Map<String, dynamic> get originalScript => script.source;
  final List<NiceTrait> vals;
  final List<NiceTrait> tvals; // not for game play
  final List<NiceTrait> ckSelfIndv;
  final List<NiceTrait> ckOpIndv;
  final int maxRate; // don't set default value in api-c

  Buff({
    required this.id,
    required this.name,
    required this.detail,
    this.icon,
    this.type = BuffType.unknown,
    this.buffGroup = 0,
    BuffScript? script,
    Map<String, dynamic>? originalScript,
    this.vals = const [],
    this.tvals = const [],
    this.ckSelfIndv = const [],
    this.ckOpIndv = const [],
    this.maxRate = 0,
  }) : script = (script ?? BuffScript())..setSource(originalScript);

  @override
  String get route => Routes.buffI(id);
  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? BuffDetailPage(buff: this, region: region),
      popDetails: popDetails,
    );
  }

  Transl<String, String> get lName => Transl.buffNames(name.isEmpty ? type.name : name);
  Transl<String, String> get lDetail => Transl.buffDetail(detail);

  List<BuffAction> get buffActions => type.buffActions;

  static String formatRate(BuffType type, int rate) {
    int? base = type.percentBase;
    if (base == null) return rate.toString();
    return rate.format(percent: true, base: base);
  }

  factory Buff.fromJson(Map<String, dynamic> json) {
    return GameDataLoader.instance.tmp.getBuff(json["id"] as int, () => _$BuffFromJson(json));
  }

  Map<String, dynamic> toJson() => _$BuffToJson(this);

  int? get percentBase => type.percentBase;
}

@JsonSerializable()
class BuffRelationOverwrite {
  @protected
  final Map<String, Map<String, RelationOverwriteDetail>> atkSide;
  @protected
  final Map<String, Map<String, RelationOverwriteDetail>> defSide;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final Map<int, Map<int, RelationOverwriteDetail>> atkSide2 = _resolve(atkSide);
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final Map<int, Map<int, RelationOverwriteDetail>> defSide2 = _resolve(defSide);

  BuffRelationOverwrite({
    this.atkSide = const {},
    this.defSide = const {},
  });

  static Map<int, Map<int, RelationOverwriteDetail>> _resolve(Map<String, Map<String, RelationOverwriteDetail>> src) {
    final Map<int, Map<int, RelationOverwriteDetail>> dest = {};
    for (final (cls1, details) in src.items) {
      final clsId1 = SvtClassConverter.fromString(cls1, db.gameData.mappingData.enums.svtClass);
      if (clsId1 == null) continue;
      final v = dest[clsId1] = {};
      for (final (cls2, detail) in details.items) {
        final clsId2 = SvtClassConverter.fromString(cls2, db.gameData.mappingData.enums.svtClass);
        if (clsId2 == null) continue;
        v[clsId2] = detail;
      }
    }
    return dest;
  }

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) => _$BuffRelationOverwriteFromJson(json);

  Map<String, dynamic> toJson() => _$BuffRelationOverwriteToJson(this);
}

@JsonSerializable()
class RelationOverwriteDetail {
  int damageRate;
  ClassRelationOverwriteType type;

  RelationOverwriteDetail({
    required this.damageRate,
    required this.type,
  });

  factory RelationOverwriteDetail.fromJson(Map<String, dynamic> json) => _$RelationOverwriteDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RelationOverwriteDetailToJson(this);
}

@JsonSerializable(includeIfNull: false)
class BuffScript with DataScriptBase {
  int? checkIndvType; // 1-AND, default-OR
  bool get checkIndvTypeAnd => checkIndvType == 1 || checkIndvType == 3;

  @BuffTypeConverter()
  List<BuffType>? CheckOpponentBuffTypes;
  BuffRelationOverwrite? relationId;
  NiceTrait? INDIVIDUALITIE; // self indiv?
  int? INDIVIDUALITIE_COUNT_ABOVE; // used together with INDIVIDUALITIE
  List<NiceTrait>? INDIVIDUALITIE_AND;
  List<NiceTrait>? INDIVIDUALITIE_OR;
  List<NiceTrait>? UpBuffRateBuffIndiv; // Oberon
  NiceTrait? TargetIndiv;
  BuffConvert? convert;

  String? get ReleaseText => source['ReleaseText'];
  int? get DamageRelease => toInt('DamageRelease'); // remove this buff when receive damage
  int? get HP_LOWER => toInt('HP_LOWER'); // Passionlip
  int? get HP_HIGHER => toInt('HP_HIGHER'); // buff 5297
  String? get CounterMessage => source['CounterMessage'];
  String? get avoidanceText => source['avoidanceText'];
  String? get gutsText => source['gutsText'];
  String? get missText => source['missText'];
  int? get AppId => toInt('AppId');
  int? get IncludeIgnoreIndividuality => toInt('IncludeIgnoreIndividuality');
  int? get ProgressSelfTurn => toInt('ProgressSelfTurn');
  int? get extendLowerLimit => toInt('extendLowerLimit');

  int? get IndvAddBuffPassive => toInt('IndvAddBuffPassive');
  List<int>? get ckSelfCountIndividuality => toList('ckSelfCountIndividuality');
  List<int>? get ckOpCountIndividuality => toList('ckOpCountIndividuality');
  int? get ckIndvCountAbove => toInt('ckIndvCountAbove');
  int? get ckIndvCountBelow => toInt('ckIndvCountBelow');

  BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.INDIVIDUALITIE,
    this.INDIVIDUALITIE_COUNT_ABOVE,
    this.INDIVIDUALITIE_AND,
    this.INDIVIDUALITIE_OR,
    this.UpBuffRateBuffIndiv,
    this.TargetIndiv,
    this.convert,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) => _$BuffScriptFromJson(json);

  Map<String, dynamic> toJson() => _$BuffScriptToJson(this);
}

/// Convert [targets] to [convertBuffs]
@JsonSerializable(includeIfNull: false)
class BuffConvert {
  BuffConvertLimitType targetLimit;
  BuffConvertType convertType;
  //  list[int] | list[NiceTrait] | list[dict[str, Any]=Buff]
  List<dynamic> targets;
  List<Buff> convertBuffs;
  BuffConvertScript? script;
  int effectId;

  // parsed targets
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<NiceTrait> targetTraits = [];
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Buff> targetBuffs = [];

  BuffConvert({
    this.targetLimit = BuffConvertLimitType.all,
    this.convertType = BuffConvertType.none,
    this.targets = const [],
    this.convertBuffs = const [],
    this.script,
    this.effectId = 0,
  }) {
    for (final target in targets) {
      if (target is Map) {
        if (target['detail'] != null) {
          // nice buff or basic buff
          targetBuffs.add(Buff.fromJson(Map.from(target)));
        } else if (target['id'] != null) {
          targetTraits.add(NiceTrait.fromJson(Map.from(target)));
        }
      }
    }
  }
  factory BuffConvert.fromJson(Map<String, dynamic> json) => _$BuffConvertFromJson(json);

  Map<String, dynamic> toJson() => _$BuffConvertToJson(this);
}

@JsonSerializable()
class BuffConvertScript {
  List<String>? OverwritePopupText;
  BuffConvertScript({
    this.OverwritePopupText,
  });
  factory BuffConvertScript.fromJson(Map<String, dynamic> json) => _$BuffConvertScriptFromJson(json);

  Map<String, dynamic> toJson() => _$BuffConvertScriptToJson(this);
}

enum BuffConvertType {
  none,
  buff,
  individuality,
}

enum BuffConvertLimitType {
  all,
  self,
}

enum ClassRelationOverwriteType {
  overwriteForce,
  overwriteMoreThanTarget,
  overwriteLessThanTarget,
}

class BuffTypeConverter extends JsonConverter<BuffType, String> {
  const BuffTypeConverter();

  @override
  BuffType fromJson(String value) {
    return deprecatedTypes[value] ?? decodeEnum(_$BuffTypeEnumMap, value, BuffType.unknown);
  }

  @override
  String toJson(BuffType obj) => _$BuffTypeEnumMap[obj] ?? obj.name;

  static Map<String, BuffType> deprecatedTypes = {
    "commandattackFunction": BuffType.commandattackAfterFunction,
    "upDefencecommanDamage": BuffType.upDefenceCommanddamage,
    "downDefencecommanDamage": BuffType.downDefenceCommanddamage,
    "attackFunction": BuffType.attackAfterFunction,
    "commandcodeattackFunction": BuffType.commandcodeattackBeforeFunction,
  };
}

@JsonEnum(alwaysCreate: true)
enum BuffType {
  unknown(-1), // custom
  none(0),
  upCommandatk(1),
  upStarweight(2),
  upCriticalpoint(3),
  downCriticalpoint(4),
  regainNp(5),
  regainStar(6),
  regainHp(7),
  reduceHp(8),
  upAtk(9),
  downAtk(10),
  upDamage(11),
  downDamage(12),
  addDamage(13),
  subDamage(14),
  upNpdamage(15),
  downNpdamage(16),
  upDropnp(17),
  upCriticaldamage(18),
  downCriticaldamage(19),
  upSelfdamage(20),
  downSelfdamage(21),
  addSelfdamage(22),
  subSelfdamage(23),
  avoidance(24),
  breakAvoidance(25),
  invincible(26),
  upGrantstate(27),
  downGrantstate(28),
  upTolerance(29),
  downTolerance(30),
  avoidState(31),
  donotAct(32),
  donotSkill(33),
  donotNoble(34),
  donotRecovery(35),
  disableGender(36),
  guts(37),
  upHate(38),
  addIndividuality(40),
  subIndividuality(41),
  upDefence(42),
  downDefence(43),
  upCommandstar(50),
  upCommandnp(51),
  upCommandall(52),
  downCommandall(60),
  downStarweight(61),
  reduceNp(62),
  downDropnp(63),
  upGainHp(64),
  downGainHp(65),
  downCommandatk(66),
  downCommanstar(67),
  downCommandnp(68),
  upCriticalrate(70),
  downCriticalrate(71),
  pierceInvincible(72),
  avoidInstantdeath(73),
  upResistInstantdeath(74),
  upNonresistInstantdeath(75),
  delayFunction(76),
  regainNpUsedNoble(77),
  deadFunction(78),
  upMaxhp(79),
  downMaxhp(80),
  addMaxhp(81),
  subMaxhp(82),
  battlestartFunction(83),
  wavestartFunction(84),
  selfturnendFunction(85),
  damageFunction(86),
  upGivegainHp(87),
  downGivegainHp(88),
  // @Deprecated('use `commandattackAfterFunction`')
  // commandattackFunction(89),
  commandattackAfterFunction(89),
  deadattackFunction(90),
  upSpecialdefence(91),
  downSpecialdefence(92),
  upDamagedropnp(93),
  downDamagedropnp(94),
  entryFunction(95),
  upChagetd(96),
  reflectionFunction(97),
  upGrantSubstate(98),
  downGrantSubstate(99),
  upToleranceSubstate(100),
  downToleranceSubstate(101),
  upGrantInstantdeath(102),
  downGrantInstantdeath(103),
  gutsRatio(104),
  upDefencecommandall(105),
  downDefencecommandall(106),
  overwriteBattleclass(107),
  overwriteClassrelatioAtk(108),
  overwriteClassrelatioDef(109),
  upDamageIndividuality(110),
  downDamageIndividuality(111),
  upDamageIndividualityActiveonly(112),
  downDamageIndividualityActiveonly(113),
  upNpturnval(114),
  downNpturnval(115),
  multiattack(116),
  upGiveNp(117),
  downGiveNp(118),
  upResistanceDelayNpturn(119),
  downResistanceDelayNpturn(120),
  pierceDefence(121),
  upGutsHp(122),
  downGutsHp(123),
  upFuncgainNp(124),
  downFuncgainNp(125),
  upFuncHpReduce(126),
  downFuncHpReduce(127),
  // @Deprecated('use `upDefenceCommanddamage`')
  // upDefencecommanDamage(128),
  upDefenceCommanddamage(128),
  // @Deprecated('use `downDefenceCommanddamage`')
  // downDefencecommanDamage(129),
  downDefenceCommanddamage(129),
  npattackPrevBuff(130),
  fixCommandcard(131),
  donotGainnp(132),
  fieldIndividuality(133),
  donotActCommandtype(134),
  upDamageEventPoint(135),
  upDamageSpecial(136),
  // @Deprecated('use `attackAfterFunction`')
  // attackFunction(137),
  attackAfterFunction(137),
  // @Deprecated('use `commandcodeattackBeforeFunction`')
  // commandcodeattackFunction(138),
  commandcodeattackBeforeFunction(138),
  donotNobleCondMismatch(139),
  donotSelectCommandcard(140),
  donotReplace(141),
  shortenUserEquipSkill(142),
  tdTypeChange(143),
  overwriteClassRelation(144),
  tdTypeChangeArts(145),
  tdTypeChangeBuster(146),
  tdTypeChangeQuick(147),
  commandattackBeforeFunction(148),
  gutsFunction(149),
  upCriticalRateDamageTaken(150),
  downCriticalRateDamageTaken(151),
  upCriticalStarDamageTaken(152),
  downCriticalStarDamageTaken(153),
  skillRankUp(154),
  avoidanceIndividuality(155),
  changeCommandCardType(156),
  specialInvincible(157),
  preventDeathByDamage(158),
  commandcodeattackAfterFunction(159),
  attackBeforeFunction(160),
  donotSkillSelect(161),
  buffRate(162),
  invisibleBattleChara(163),
  counterFunction(165),
  notTargetSkill(166),
  hpReduceToRegain(167),
  selfturnstartFunction(168),
  overwriteDeadType(169),
  upActionCount(170),
  downActionCount(171),
  shiftGuts(172),
  shiftGutsRatio(173),
  masterSkillValueUp(174),
  buffConvert(175),
  subFieldIndividuality(176),
  commandcodeattackBeforeFunctionMainOnly(177),
  commandcodeattackAfterFunctionMainOnly(178),
  commandattackBeforeFunctionMainOnly(179),
  commandattackAfterFunctionMainOnly(180),
  attackBeforeFunctionMainOnly(181),
  attackAfterFunctionMainOnly(182),
  warBoardNotAttacked(183),
  warBoardIgnoreDefeatpoint(184),
  skillAfterFunction(185),
  treasureDeviceAfterFunction(186),
  skillAfterFunctionMainOnly(187),
  treasureDeviceAfterFunctionMainOnly(188),
  toFieldChangeField(10001),
  toFieldAvoidBuff(10002),
  toFieldSubIndividualityField(10003),
  ;

  final int id;
  const BuffType(this.id);

  List<BuffAction> get buffActions => db.gameData.constData.buffTypeActionMap[this] ?? [];
  int? get percentBase {
    int? base = kBuffTypePercentType[this];
    for (final action in buffActions) {
      base ??= kBuffActionPercentTypes[action];
    }
    return base;
  }

  bool get isTdTypeChange => const [
        tdTypeChange,
        tdTypeChangeArts,
        tdTypeChangeBuster,
        tdTypeChangeQuick,
      ].contains(this);
}

final Map<BuffType, BuffValueTriggerType Function(DataVals)> kBuffValueTriggerTypes = {
  BuffType.reflectionFunction: (v) =>
      BuffValueTriggerType(BuffType.reflectionFunction, skill: v.Value, level: v.Value2),
  BuffType.attackAfterFunction: (v) =>
      BuffValueTriggerType(BuffType.attackAfterFunction, skill: v.Value, level: v.Value2),
  BuffType.commandattackAfterFunction: (v) =>
      BuffValueTriggerType(BuffType.commandattackAfterFunction, skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.commandattackBeforeFunction: (v) =>
      BuffValueTriggerType(BuffType.commandattackBeforeFunction, skill: v.Value, level: v.Value2),
  BuffType.damageFunction: (v) => BuffValueTriggerType(BuffType.damageFunction, skill: v.Value, level: v.Value2),
  BuffType.deadFunction: (v) => BuffValueTriggerType(BuffType.deadFunction, skill: v.Value, level: v.Value2),
  BuffType.deadattackFunction: (v) =>
      BuffValueTriggerType(BuffType.deadattackFunction, skill: v.Value, level: v.Value2),
  BuffType.delayFunction: (v) => BuffValueTriggerType(BuffType.delayFunction, skill: v.Value, level: v.Value2),
  BuffType.npattackPrevBuff: (v) =>
      BuffValueTriggerType(BuffType.npattackPrevBuff, skill: v.SkillID, level: v.SkillLV, position: v.Value),
  BuffType.selfturnendFunction: (v) =>
      BuffValueTriggerType(BuffType.selfturnendFunction, skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.selfturnstartFunction: (v) =>
      BuffValueTriggerType(BuffType.selfturnstartFunction, skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.wavestartFunction: (v) =>
      BuffValueTriggerType(BuffType.wavestartFunction, skill: v.Value, level: v.Value2, rate: v.UseRate),
  BuffType.counterFunction: (v) =>
      BuffValueTriggerType(BuffType.counterFunction, skill: v.CounterId, level: v.CounterLv),
  // ?
  BuffType.commandcodeattackBeforeFunction: (v) =>
      BuffValueTriggerType(BuffType.commandcodeattackBeforeFunction, skill: v.Value, level: v.Value2),
  BuffType.commandcodeattackAfterFunction: (v) =>
      BuffValueTriggerType(BuffType.commandcodeattackAfterFunction, skill: v.Value, level: v.Value2),
  BuffType.gutsFunction: (v) => BuffValueTriggerType(BuffType.gutsFunction, skill: v.Value, level: v.Value2),
  BuffType.attackBeforeFunction: (v) =>
      BuffValueTriggerType(BuffType.attackBeforeFunction, skill: v.Value, level: v.Value2),
  BuffType.entryFunction: (v) => BuffValueTriggerType(BuffType.entryFunction, skill: v.Value, level: v.Value2),
};

class BuffValueTriggerType {
  final BuffType buffType;
  final int? skill;
  int? level;
  final int? rate;
  final int? position;
  BuffValueTriggerType(
    this.buffType, {
    required this.skill,
    required this.level,
    this.rate,
    this.position,
  });
}
