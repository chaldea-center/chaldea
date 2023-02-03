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
  BuffType fromJson(String value) =>
      decodeEnum(_$BuffTypeEnumMap, value, BuffType.unknown);
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

  Transl<String, String> get lName =>
      Transl.buffNames(name.isEmpty ? type.name : name);
  Transl<String, String> get lDetail => Transl.buffDetail(detail);

  BuffAction get buffAction => type.buffAction;

  static String formatRate(BuffType type, int rate) {
    final base =
        kBuffActionPercentTypes[type.buffAction] ?? kBuffTypePercentType[type];
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

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) =>
      _$BuffRelationOverwriteFromJson(json);
}

@JsonSerializable()
class RelationOverwriteDetail {
  int damageRate;
  ClassRelationOverwriteType type;

  RelationOverwriteDetail({
    required this.damageRate,
    required this.type,
  });

  factory RelationOverwriteDetail.fromJson(Map<String, dynamic> json) =>
      _$RelationOverwriteDetailFromJson(json);
}

@JsonSerializable()
class BuffScript {
  final int? checkIndvType; // 1-AND, default-OR
  @BuffTypeConverter()
  final List<BuffType>? CheckOpponentBuffTypes;
  final BuffRelationOverwrite? relationId;
  final String? ReleaseText;
  final int? DamageRelease; // remove this buff when receive damage
  final NiceTrait? INDIVIDUALITIE; // self indiv?
  final int? INDIVIDUALITIE_COUNT_ABOVE;
  final List<NiceTrait>? UpBuffRateBuffIndiv; // Oberon
  final int? HP_LOWER; // Passionlip
  final BuffConvert? convert;

  const BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.ReleaseText,
    this.DamageRelease,
    this.INDIVIDUALITIE,
    this.INDIVIDUALITIE_COUNT_ABOVE,
    this.UpBuffRateBuffIndiv,
    this.HP_LOWER,
    this.convert,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) =>
      _$BuffScriptFromJson(json);
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
  @JsonKey(ignore: true)
  List<NiceTrait> targetTraits = [];
  @JsonKey(ignore: true)
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
        } else if (target['id'] != null &&
            target.keys
                .every((key) => ['id', 'negative', 'name'].contains(key))) {
          targetTraits.add(NiceTrait.fromJson(Map.from(target)));
        }
      }
    }
  }
  factory BuffConvert.fromJson(Map<String, dynamic> json) =>
      _$BuffConvertFromJson(json);
}

@JsonSerializable()
class BuffConvertScript {
  List<String>? OverwritePopupText;
  BuffConvertScript({
    this.OverwritePopupText,
  });
  factory BuffConvertScript.fromJson(Map<String, dynamic> json) =>
      _$BuffConvertScriptFromJson(json);
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
  unknown, // custom
  none,
  upCommandatk,
  upStarweight,
  upCriticalpoint,
  downCriticalpoint,
  regainNp,
  regainStar,
  regainHp,
  reduceHp,
  upAtk,
  downAtk,
  upDamage,
  downDamage,
  addDamage,
  subDamage,
  upNpdamage,
  downNpdamage,
  upDropnp,
  upCriticaldamage,
  downCriticaldamage,
  upSelfdamage,
  downSelfdamage,
  addSelfdamage,
  subSelfdamage,
  avoidance,
  breakAvoidance,
  invincible,
  upGrantstate,
  downGrantstate,
  upTolerance,
  downTolerance,
  avoidState,
  donotAct,
  donotSkill,
  donotNoble,
  donotRecovery,
  disableGender,
  guts,
  upHate,
  addIndividuality,
  subIndividuality,
  upDefence,
  downDefence,
  upCommandstar,
  upCommandnp,
  upCommandall,
  downCommandall,
  downStarweight,
  reduceNp,
  downDropnp,
  upGainHp,
  downGainHp,
  downCommandatk,
  downCommanstar,
  downCommandnp,
  upCriticalrate,
  downCriticalrate,
  pierceInvincible,
  avoidInstantdeath,
  upResistInstantdeath,
  upNonresistInstantdeath,
  delayFunction,
  regainNpUsedNoble,
  deadFunction,
  upMaxhp,
  downMaxhp,
  addMaxhp,
  subMaxhp,
  battlestartFunction,
  wavestartFunction,
  selfturnendFunction,
  damageFunction,
  upGivegainHp,
  downGivegainHp,
  commandattackFunction,
  deadattackFunction,
  upSpecialdefence,
  downSpecialdefence,
  upDamagedropnp,
  downDamagedropnp,
  entryFunction,
  upChagetd,
  reflectionFunction,
  upGrantSubstate,
  downGrantSubstate,
  upToleranceSubstate,
  downToleranceSubstate,
  upGrantInstantdeath,
  downGrantInstantdeath,
  gutsRatio,
  upDefencecommandall,
  downDefencecommandall,
  overwriteBattleclass,
  overwriteClassrelatioAtk,
  overwriteClassrelatioDef,
  upDamageIndividuality,
  downDamageIndividuality,
  upDamageIndividualityActiveonly,
  downDamageIndividualityActiveonly,
  upNpturnval,
  downNpturnval,
  multiattack,
  upGiveNp,
  downGiveNp,
  upResistanceDelayNpturn,
  downResistanceDelayNpturn,
  pierceDefence,
  upGutsHp,
  downGutsHp,
  upFuncgainNp,
  downFuncgainNp,
  upFuncHpReduce,
  downFuncHpReduce,
  upDefencecommanDamage,
  downDefencecommanDamage,
  npattackPrevBuff,
  fixCommandcard,
  donotGainnp,
  fieldIndividuality,
  donotActCommandtype,
  upDamageEventPoint,
  upDamageSpecial,
  attackFunction,
  commandcodeattackFunction,
  donotNobleCondMismatch,
  donotSelectCommandcard,
  donotReplace,
  shortenUserEquipSkill,
  tdTypeChange,
  overwriteClassRelation,
  tdTypeChangeArts,
  tdTypeChangeBuster,
  tdTypeChangeQuick,
  commandattackBeforeFunction,
  gutsFunction,
  upCriticalRateDamageTaken,
  downCriticalRateDamageTaken,
  upCriticalStarDamageTaken,
  downCriticalStarDamageTaken,
  skillRankUp,
  avoidanceIndividuality,
  changeCommandCardType,
  specialInvincible,
  preventDeathByDamage,
  commandcodeattackAfterFunction,
  attackBeforeFunction,
  donotSkillSelect,
  buffRate,
  invisibleBattleChara,
  counterFunction,
  notTargetSkill,
  hpReduceToRegain,
  selfturnstartFunction,
  overwriteDeadType,
  upActionCount,
  downActionCount,
  shiftGuts,
  shiftGutsRatio,
  masterSkillValueUp,
  buffConvert,
  subFieldIndividuality,
  toFieldChangeField, // 10001
  toFieldAvoidBuff, // 10002
  toFieldSubIndividualityField, // 10003
  ;

  BuffAction get buffAction =>
      db.gameData.constData.buffTypeActionMap[this] ?? BuffAction.unknown;
}

final Map<BuffType, BuffValueTriggerType Function(DataVals)>
    kBuffValueTriggerTypes = {
  BuffType.reflectionFunction: (v) => BuffValueTriggerType(
      BuffType.reflectionFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.attackFunction: (v) => BuffValueTriggerType(BuffType.attackFunction,
      skill: v.Value, level: v.Value2),
  BuffType.commandattackFunction: (v) => BuffValueTriggerType(
      BuffType.commandattackFunction,
      skill: v.Value,
      level: v.Value2,
      rate: v.UseRate),
  BuffType.commandattackBeforeFunction: (v) => BuffValueTriggerType(
      BuffType.commandattackBeforeFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.damageFunction: (v) => BuffValueTriggerType(BuffType.damageFunction,
      skill: v.Value, level: v.Value2),
  BuffType.deadFunction: (v) => BuffValueTriggerType(BuffType.deadFunction,
      skill: v.Value, level: v.Value2),
  BuffType.deadattackFunction: (v) => BuffValueTriggerType(
      BuffType.deadattackFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.delayFunction: (v) => BuffValueTriggerType(BuffType.delayFunction,
      skill: v.Value, level: v.Value2),
  BuffType.npattackPrevBuff: (v) => BuffValueTriggerType(
      BuffType.npattackPrevBuff,
      skill: v.SkillID,
      level: v.SkillLV,
      position: v.Value),
  BuffType.selfturnendFunction: (v) => BuffValueTriggerType(
      BuffType.selfturnendFunction,
      skill: v.Value,
      level: v.Value2,
      rate: v.UseRate),
  BuffType.selfturnstartFunction: (v) => BuffValueTriggerType(
      BuffType.selfturnstartFunction,
      skill: v.Value,
      level: v.Value2,
      rate: v.UseRate),
  BuffType.wavestartFunction: (v) => BuffValueTriggerType(
      BuffType.wavestartFunction,
      skill: v.Value,
      level: v.Value2,
      rate: v.UseRate),
  BuffType.counterFunction: (v) => BuffValueTriggerType(
      BuffType.counterFunction,
      skill: v.CounterId,
      level: v.CounterLv),
  // ?
  BuffType.commandcodeattackFunction: (v) => BuffValueTriggerType(
      BuffType.commandcodeattackFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.commandcodeattackAfterFunction: (v) => BuffValueTriggerType(
      BuffType.commandcodeattackAfterFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.gutsFunction: (v) => BuffValueTriggerType(BuffType.gutsFunction,
      skill: v.Value, level: v.Value2),
  BuffType.attackBeforeFunction: (v) => BuffValueTriggerType(
      BuffType.attackBeforeFunction,
      skill: v.Value,
      level: v.Value2),
  BuffType.entryFunction: (v) => BuffValueTriggerType(BuffType.entryFunction,
      skill: v.Value, level: v.Value2),
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
