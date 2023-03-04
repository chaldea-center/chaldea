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

class BuffTypeConverter extends JsonConverter<BuffType, String> {
  const BuffTypeConverter();
  @override
  BuffType fromJson(String value) => decodeEnum(_$BuffTypeEnumMap, value, BuffType.unknown);
  @override
  String toJson(BuffType obj) => _$BuffTypeEnumMap[obj] ?? obj.name;
}

@JsonSerializable()
class Buff with RouteInfo {
  final int id;
  final String name;
  final String detail;
  final String? icon;
  @BuffTypeConverter()
  final BuffType type;
  final int buffGroup;
  final BuffScript? script;
  final List<NiceTrait> vals;
  // final List<NiceTrait> tvals; // not for game play
  final List<NiceTrait> ckSelfIndv;
  final List<NiceTrait> ckOpIndv;
  final int maxRate; // don't set default value in api-c

  const Buff.create({
    required this.id,
    required this.name,
    required this.detail,
    this.icon,
    this.type = BuffType.unknown,
    this.buffGroup = 0,
    this.script,
    this.vals = const [],
    // this.tvals = const [],
    this.ckSelfIndv = const [],
    this.ckOpIndv = const [],
    this.maxRate = 0,
  });

  factory Buff({
    required int id,
    required String name,
    required String detail,
    String? icon,
    BuffType type = BuffType.unknown,
    int buffGroup = 0,
    BuffScript? script,
    List<NiceTrait> vals = const [],
    // List<NiceTrait> tvals = const [],
    List<NiceTrait> ckSelfIndv = const [],
    List<NiceTrait> ckOpIndv = const [],
    int maxRate = 0,
  }) =>
      GameDataLoader.instance.tmp.getBuff(
          id,
          () => Buff.create(
                id: id,
                name: name,
                detail: detail,
                icon: icon,
                type: type,
                buffGroup: buffGroup,
                script: script,
                vals: vals,
                // tvals: tvals,
                ckSelfIndv: ckSelfIndv,
                ckOpIndv: ckOpIndv,
                maxRate: maxRate,
              ));

  factory Buff.fromJson(Map<String, dynamic> json) => _$BuffFromJson(json);

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

  BuffAction get buffAction => type.buffAction;

  static String formatRate(BuffType type, int rate) {
    final base = kBuffActionPercentTypes[type.buffAction] ?? kBuffTypePercentType[type];
    if (base == null) return rate.toString();
    return rate.format(percent: true, base: base);
  }
}

@JsonSerializable(converters: [SvtClassConverter()])
class BuffRelationOverwrite {
  final Map<SvtClass, Map<SvtClass, RelationOverwriteDetail>> atkSide;
  final Map<SvtClass, Map<SvtClass, RelationOverwriteDetail>> defSide;

  const BuffRelationOverwrite({
    required this.atkSide,
    required this.defSide,
  });

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) => _$BuffRelationOverwriteFromJson(json);
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
}

@JsonSerializable()
class BuffScript with DataScriptBase {
  int? checkIndvType; // 1-AND, default-OR
  @BuffTypeConverter()
  List<BuffType>? CheckOpponentBuffTypes;
  BuffRelationOverwrite? relationId;
  NiceTrait? INDIVIDUALITIE; // self indiv?
  List<NiceTrait>? UpBuffRateBuffIndiv; // Oberon
  NiceTrait? TargetIndiv;
  BuffConvert? convert;

  String? ReleaseText;
  int? DamageRelease; // remove this buff when receive damage
  int? INDIVIDUALITIE_COUNT_ABOVE;
  int? HP_LOWER; // Passionlip
  int? HP_HIGHER; // buff 5297
  String? CounterMessage;
  String? avoidanceText;
  String? gutsText;
  String? missText;
  int? AppId;
  int? IncludeIgnoreIndividuality;
  int? ProgressSelfTurn;
  int? extendLowerLimit;

  BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.ReleaseText,
    this.DamageRelease,
    this.INDIVIDUALITIE,
    this.INDIVIDUALITIE_COUNT_ABOVE,
    this.UpBuffRateBuffIndiv,
    this.HP_LOWER,
    this.HP_HIGHER,
    this.CounterMessage,
    this.avoidanceText,
    this.gutsText,
    this.missText,
    this.AppId,
    this.IncludeIgnoreIndividuality,
    this.ProgressSelfTurn,
    this.TargetIndiv,
    this.extendLowerLimit,
    this.convert,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) => _$BuffScriptFromJson(json)..setSource(json);
}

/// Convert [targets] to [convertBuffs]
@JsonSerializable()
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
        } else if (target['id'] != null && target.keys.every((key) => ['id', 'negative', 'name'].contains(key))) {
          targetTraits.add(NiceTrait.fromJson(Map.from(target)));
        }
      }
    }
  }
  factory BuffConvert.fromJson(Map<String, dynamic> json) => _$BuffConvertFromJson(json);
}

@JsonSerializable()
class BuffConvertScript {
  List<String>? OverwritePopupText;
  BuffConvertScript({
    this.OverwritePopupText,
  });
  factory BuffConvertScript.fromJson(Map<String, dynamic> json) => _$BuffConvertScriptFromJson(json);
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
  commandattackFunction(89),
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
  upDefencecommanDamage(128),
  downDefencecommanDamage(129),
  npattackPrevBuff(130),
  fixCommandcard(131),
  donotGainnp(132),
  fieldIndividuality(133),
  donotActCommandtype(134),
  upDamageEventPoint(135),
  upDamageSpecial(136),
  attackFunction(137),
  commandcodeattackFunction(138),
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
  toFieldChangeField(10001),
  toFieldAvoidBuff(10002),
  toFieldSubIndividualityField(10003),
  ;

  final int id;
  const BuffType(this.id);

  BuffAction get buffAction => db.gameData.constData.buffTypeActionMap[this] ?? BuffAction.unknown;
}

final Map<BuffType, BuffValueTriggerType Function(DataVals)> kBuffValueTriggerTypes = {
  BuffType.reflectionFunction: (v) =>
      BuffValueTriggerType(BuffType.reflectionFunction, skill: v.Value, level: v.Value2),
  BuffType.attackFunction: (v) => BuffValueTriggerType(BuffType.attackFunction, skill: v.Value, level: v.Value2),
  BuffType.commandattackFunction: (v) =>
      BuffValueTriggerType(BuffType.commandattackFunction, skill: v.Value, level: v.Value2, rate: v.UseRate),
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
  BuffType.commandcodeattackFunction: (v) =>
      BuffValueTriggerType(BuffType.commandcodeattackFunction, skill: v.Value, level: v.Value2),
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
