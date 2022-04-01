// ignore_for_file: non_constant_identifier_names
import 'dart:ui';

import 'package:chaldea/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../app/tools/gamedata_loader.dart';
import '../db.dart';
import 'common.dart';
import 'wiki_data.dart';

part 'func.dart';
part 'vals.dart';
part '../../generated/models/gamedata/skill.g.dart';

abstract class SkillOrTd {
  String get name;
  Transl<String, String> get lName;
  String get ruby;
  String? get unmodifiedDetail;
  String? get lDetail;
  List<NiceFunction> get functions;
}

@JsonSerializable()
class BaseSkill implements SkillOrTd {
  int id;
  @override
  String name;
  @override
  String ruby;
  @override
  String? unmodifiedDetail; // String? detail;
  SkillType type;
  String? icon;
  List<int> coolDown;
  List<NiceTrait> actIndividuality;
  SkillScript script;
  List<ExtraPassive> extraPassive;
  List<SkillAdd> skillAdd;
  Map<AiType, List<int>>? aiIds;
  @override
  List<NiceFunction> functions;

  BaseSkill({
    required this.id,
    required this.name,
    this.ruby = '',
    // this.detail,
    this.unmodifiedDetail,
    required this.type,
    this.icon,
    this.coolDown = const [],
    this.actIndividuality = const [],
    SkillScript? script,
    this.extraPassive = const [],
    this.skillAdd = const [],
    this.aiIds,
    required this.functions,
  }) : script = script ?? SkillScript();

  factory BaseSkill.fromJson(Map<String, dynamic> json) =>
      _$BaseSkillFromJson(json);

  @override
  Transl<String, String> get lName => Transl.skillNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    String content = Transl.skillDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l;
    return content.replaceAll('{0}', 'Lv.').replaceFirstMapped(
      RegExp(r'\[servantName (\d+)\]'),
      (match) {
        final svt = db2.gameData.servantsById[int.parse(match.group(1)!)];
        if (svt != null) {
          return '${svt.name}(${Transl.svtClass(svt.className.id).l})';
        }
        return match.group(0).toString();
      },
    );
  }
}

@JsonSerializable()
class NiceSkill extends BaseSkill {
  int num;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;

  NiceSkill({
    required int id,
    required String name,
    String ruby = '',
    String? unmodifiedDetail,
    required SkillType type,
    String? icon,
    List<int> coolDown = const [],
    List<NiceTrait> actIndividuality = const [],
    SkillScript? script,
    List<ExtraPassive> extraPassive = const [],
    List<SkillAdd> skillAdd = const [],
    Map<AiType, List<int>>? aiIds,
    List<NiceFunction> functions = const [],
    this.num = 0,
    this.strengthStatus = 0,
    this.priority = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
  }) : super(
          id: id,
          name: name,
          ruby: ruby,
          unmodifiedDetail: unmodifiedDetail,
          type: type,
          icon: icon,
          coolDown: coolDown,
          actIndividuality: actIndividuality,
          script: script ?? SkillScript(),
          extraPassive: extraPassive,
          skillAdd: skillAdd,
          aiIds: aiIds,
          functions: functions,
        );

  factory NiceSkill.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseSkill = GameDataLoader
          .instance!.gameJson!['baseSkills']![json['id'].toString()]!;
      json.addAll(Map.from(baseSkill));
    }
    return _$NiceSkillFromJson(json);
  }
}

@JsonSerializable()
class NiceTd implements SkillOrTd {
  int id;
  int num;
  CardType card;
  @override
  String name;
  @override
  String ruby;
  String? icon;
  String rank;
  String type;

  // String? detail;
  @override
  String? unmodifiedDetail;
  NpGain npGain;
  List<int> npDistribution;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  List<NiceTrait> individuality;
  SkillScript script;
  @override
  List<NiceFunction> functions;

  NiceTd({
    required this.id,
    required this.num,
    required this.card,
    required this.name,
    required this.ruby,
    this.icon,
    required this.rank,
    required this.type,
    // this.detail,
    this.unmodifiedDetail,
    required this.npGain,
    required this.npDistribution,
    this.strengthStatus = 0,
    required this.priority,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    required this.individuality,
    required this.script,
    required this.functions,
  });

  factory NiceTd.fromJson(Map<String, dynamic> json) => _$NiceTdFromJson(json);

  NpDamageType? _damageType;

  NpDamageType get damageType {
    if (_damageType != null) return _damageType!;
    for (var func in functions) {
      if (func.funcTargetTeam == FuncApplyTarget.enemy) continue;
      if (EnumUtil.shortString(func.funcType).startsWith('damageNp')) {
        if (func.funcTargetType == FuncTargetType.enemyAll) {
          _damageType = NpDamageType.aoe;
        } else if (func.funcTargetType == FuncTargetType.enemy) {
          _damageType = NpDamageType.indiv;
        } else {
          throw 'Unknown damageType: ${func.funcTargetType}';
        }
      }
    }
    return _damageType ??= NpDamageType.none;
  }

  @override
  Transl<String, String> get lName => Transl.tdNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    return Transl.tdDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l
        .replaceAll('{0}', 'Lv.');
  }
}

enum NpDamageType { none, indiv, aoe }

@JsonSerializable()
class CommonRelease {
  int id;
  int priority;
  int condGroup;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int condId;
  int condNum;

  CommonRelease({
    required this.id,
    required this.priority,
    required this.condGroup,
    required this.condType,
    required this.condId,
    required this.condNum,
  });

  factory CommonRelease.fromJson(Map<String, dynamic> json) =>
      _$CommonReleaseFromJson(json);
}

@JsonSerializable()
class BuffScript {
  int? checkIndvType;
  List<BuffType>? CheckOpponentBuffTypes;
  BuffRelationOverwrite? relationId;
  String? ReleaseText;
  int? DamageRelease;
  NiceTrait? INDIVIDUALITIE;
  List<NiceTrait>? UpBuffRateBuffIndiv;
  int? HP_LOWER;

  BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.ReleaseText,
    this.DamageRelease,
    this.INDIVIDUALITIE,
    this.UpBuffRateBuffIndiv,
    this.HP_LOWER,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) =>
      _$BuffScriptFromJson(json);
}

@JsonSerializable()
class FuncGroup {
  int eventId;
  int baseFuncId;
  String nameTotal;
  String name;
  String? icon;
  int priority;
  bool isDispValue;

  FuncGroup({
    required this.eventId,
    required this.baseFuncId,
    required this.nameTotal,
    required this.name,
    this.icon,
    required this.priority,
    required this.isDispValue,
  });

  factory FuncGroup.fromJson(Map<String, dynamic> json) =>
      _$FuncGroupFromJson(json);
}

@JsonSerializable()
class BaseFunction {
  int funcId;
  FuncType funcType;
  FuncTargetType funcTargetType;
  FuncApplyTarget funcTargetTeam;
  String funcPopupText;
  String? funcPopupIcon;
  List<NiceTrait> functvals;
  List<NiceTrait> funcquestTvals;
  List<FuncGroup> funcGroup;
  List<NiceTrait> traitVals;
  List<Buff> buffs;

  BaseFunction({
    required this.funcId,
    this.funcType = FuncType.none,
    required this.funcTargetType,
    required this.funcTargetTeam,
    this.funcPopupText = "",
    this.funcPopupIcon,
    this.functvals = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
  });

  factory BaseFunction.fromJson(Map<String, dynamic> json) =>
      _$BaseFunctionFromJson(json);
}

@JsonSerializable()
class ExtraPassive {
  int num;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;
  int condFriendshipRank;
  int eventId;
  int flag;
  int startedAt;
  int endedAt;

  ExtraPassive({
    required this.num,
    required this.priority,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
    this.condFriendshipRank = 0,
    this.eventId = 0,
    this.flag = 0,
    required this.startedAt,
    required this.endedAt,
  });

  factory ExtraPassive.fromJson(Map<String, dynamic> json) =>
      _$ExtraPassiveFromJson(json);
}

@JsonSerializable()
class SkillScript {
  List<int>? NP_HIGHER;
  List<int>? NP_LOWER;
  List<int>? STAR_HIGHER;
  List<int>? STAR_LOWER;
  List<int>? HP_VAL_HIGHER;
  List<int>? HP_VAL_LOWER;
  List<int>? HP_PER_HIGHER;
  List<int>? HP_PER_LOWER;
  List<int>? additionalSkillId;
  List<int>? additionalSkillActorType;

  SkillScript({
    this.NP_HIGHER,
    this.NP_LOWER,
    this.STAR_HIGHER,
    this.STAR_LOWER,
    this.HP_VAL_HIGHER,
    this.HP_VAL_LOWER,
    this.HP_PER_HIGHER,
    this.HP_PER_LOWER,
    this.additionalSkillId,
    this.additionalSkillActorType,
  });

  factory SkillScript.fromJson(Map<String, dynamic> json) =>
      _$SkillScriptFromJson(json);
}

@JsonSerializable()
class SkillAdd {
  int priority;
  List<CommonRelease> releaseConditions;
  String name;
  String ruby;

  SkillAdd({
    required this.priority,
    required this.releaseConditions,
    required this.name,
    required this.ruby,
  });

  factory SkillAdd.fromJson(Map<String, dynamic> json) =>
      _$SkillAddFromJson(json);
}

@JsonSerializable()
class NpGain {
  List<int> buster;
  List<int> arts;
  List<int> quick;
  List<int> extra;
  List<int> defence;
  List<int> np;

  NpGain({
    required this.buster,
    required this.arts,
    required this.quick,
    required this.extra,
    required this.defence,
    required this.np,
  });

  factory NpGain.fromJson(Map<String, dynamic> json) => _$NpGainFromJson(json);
}

@JsonSerializable()
class BuffRelationOverwrite {
  Map<SvtClass, Map<SvtClass, dynamic>> atkSide;
  Map<SvtClass, Map<SvtClass, dynamic>> defSide;

  BuffRelationOverwrite({
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

List<BuffType> toEnumListBuffType(List<dynamic> json) {
  return json.map((e) => $enumDecode(_$BuffTypeEnumMap, e)).toList();
}

enum BuffType {
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
}

enum FuncType {
  none,
  addState,
  subState,
  damage,
  damageNp,
  gainStar,
  gainHp,
  gainNp,
  lossNp,
  shortenSkill,
  extendSkill,
  releaseState,
  lossHp,
  instantDeath,
  damageNpPierce,
  damageNpIndividual,
  addStateShort,
  gainHpPer,
  damageNpStateIndividual,
  hastenNpturn,
  delayNpturn,
  damageNpHpratioHigh,
  damageNpHpratioLow,
  cardReset,
  replaceMember,
  lossHpSafe,
  damageNpCounter,
  damageNpStateIndividualFix,
  damageNpSafe,
  callServant,
  ptShuffle,
  lossStar,
  changeServant,
  changeBg,
  damageValue,
  withdraw,
  fixCommandcard,
  shortenBuffturn,
  extendBuffturn,
  shortenBuffcount,
  extendBuffcount,
  changeBgm,
  displayBuffstring,
  resurrection,
  gainNpBuffIndividualSum,
  setSystemAliveFlag,
  forceInstantDeath,
  damageNpRare,
  gainNpFromTargets,
  gainHpFromTargets,
  lossHpPer,
  lossHpPerSafe,
  shortenUserEquipSkill,
  quickChangeBg,
  shiftServant,
  damageNpAndCheckIndividuality,
  absorbNpturn,
  overwriteDeadType,
  forceAllBuffNoact,
  breakGaugeUp,
  breakGaugeDown,
  moveToLastSubmember,
  expUp,
  qpUp,
  dropUp,
  friendPointUp,
  eventDropUp,
  eventDropRateUp,
  eventPointUp,
  eventPointRateUp,
  transformServant,
  qpDropUp,
  servantFriendshipUp,
  userEquipExpUp,
  classDropUp,
  enemyEncountCopyRateUp,
  enemyEncountRateUp,
  enemyProbDown,
  getRewardGift,
  sendSupportFriendPoint,
  movePosition,
  revival,
  damageNpIndividualSum,
  damageValueSafe,
  friendPointUpDuplicate,
  moveState,
  changeBgmCostume,
  func126,
  func127,
  updateEntryPositions,
  buddyPointUp,
}

enum FuncTargetType {
  self,
  ptOne,
  ptAnother,
  ptAll,
  enemy,
  enemyAnother,
  enemyAll,
  ptFull,
  enemyFull,
  ptOther,
  ptOneOther,
  ptRandom,
  enemyOther,
  enemyRandom,
  ptOtherFull,
  enemyOtherFull,
  ptselectOneSub,
  ptselectSub,
  ptOneAnotherRandom,
  ptSelfAnotherRandom,
  enemyOneAnotherRandom,
  ptSelfAnotherFirst,
  ptSelfBefore,
  ptSelfAfter,
  ptSelfAnotherLast,
  commandTypeSelfTreasureDevice,
  fieldOther,
  enemyOneNoTargetNoAction,
  ptOneHpLowestValue,
  ptOneHpLowestRate,
}

enum FuncApplyTarget {
  player,
  enemy,
  playerAndEnemy,
}

enum SkillType {
  active,
  passive,
}

enum ClassRelationOverwriteType {
  overwriteForce,
  overwriteMoreThanTarget,
  overwriteLessThanTarget,
}

enum AiType {
  svt,
  field,
}
