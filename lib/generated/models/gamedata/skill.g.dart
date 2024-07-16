// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseSkill _$BaseSkillFromJson(Map json) => BaseSkill(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecodeNullable(_$SkillTypeEnumMap, json['type']) ?? SkillType.active,
      icon: json['icon'] as String?,
      coolDown: (json['coolDown'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [0],
      actIndividuality: (json['actIndividuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      skillAdd: (json['skillAdd'] as List<dynamic>?)
              ?.map((e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      aiIds: (json['aiIds'] as Map?)?.map(
        (k, e) =>
            MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
      groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
          ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skillSvts: (json['skillSvts'] as List<dynamic>?)
              ?.map((e) => SkillSvt.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BaseSkillToJson(BaseSkill instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ruby': instance.ruby,
      'unmodifiedDetail': instance.unmodifiedDetail,
      'type': _$SkillTypeEnumMap[instance.type]!,
      'icon': instance.icon,
      'coolDown': instance.coolDown,
      'actIndividuality': instance.actIndividuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'skillAdd': instance.skillAdd.map((e) => e.toJson()).toList(),
      'aiIds': instance.aiIds?.map((k, e) => MapEntry(_$AiTypeEnumMap[k]!, e)),
      'groupOverwrites': instance.groupOverwrites?.map((e) => e.toJson()).toList(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
      'skillSvts': instance.skillSvts.map((e) => e.toJson()).toList(),
    };

const _$SkillTypeEnumMap = {
  SkillType.active: 'active',
  SkillType.passive: 'passive',
};

const _$AiTypeEnumMap = {
  AiType.svt: 'svt',
  AiType.field: 'field',
};

NiceSkill _$NiceSkillFromJson(Map json) => NiceSkill(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecodeNullable(_$SkillTypeEnumMap, json['type']) ?? SkillType.active,
      icon: json['icon'] as String?,
      coolDown: (json['coolDown'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [0],
      actIndividuality: (json['actIndividuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      skillAdd: (json['skillAdd'] as List<dynamic>?)
              ?.map((e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      aiIds: (json['aiIds'] as Map?)?.map(
        (k, e) =>
            MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
      groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
          ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skillSvts: (json['skillSvts'] as List<dynamic>?)
              ?.map((e) => SkillSvt.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      svtId: (json['svtId'] as num?)?.toInt() ?? 0,
      num: (json['num'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      strengthStatus: (json['strengthStatus'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      condLv: (json['condLv'] as num?)?.toInt() ?? 0,
      condLimitCount: (json['condLimitCount'] as num?)?.toInt() ?? 0,
      extraPassive: (json['extraPassive'] as List<dynamic>?)
              ?.map((e) => ExtraPassive.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NiceSkillToJson(NiceSkill instance) => <String, dynamic>{
      'extraPassive': instance.extraPassive.map((e) => e.toJson()).toList(),
      'svtId': instance.svtId,
      'num': instance.num,
      'priority': instance.priority,
      'strengthStatus': instance.strengthStatus,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condLimitCount': instance.condLimitCount,
      'id': instance.id,
      'name': instance.name,
      'ruby': instance.ruby,
      'unmodifiedDetail': instance.unmodifiedDetail,
      'type': _$SkillTypeEnumMap[instance.type]!,
      'icon': instance.icon,
      'coolDown': instance.coolDown,
      'actIndividuality': instance.actIndividuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'skillAdd': instance.skillAdd.map((e) => e.toJson()).toList(),
      'aiIds': instance.aiIds?.map((k, e) => MapEntry(_$AiTypeEnumMap[k]!, e)),
      'groupOverwrites': instance.groupOverwrites?.map((e) => e.toJson()).toList(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
      'skillSvts': instance.skillSvts.map((e) => e.toJson()).toList(),
    };

SkillSvt _$SkillSvtFromJson(Map json) => SkillSvt(
      svtId: (json['svtId'] as num?)?.toInt() ?? 0,
      num: (json['num'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      script: json['script'] as Map?,
      strengthStatus: (json['strengthStatus'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      condLv: (json['condLv'] as num?)?.toInt() ?? 0,
      condLimitCount: (json['condLimitCount'] as num?)?.toInt() ?? 0,
      eventId: (json['eventId'] as num?)?.toInt() ?? 0,
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => SvtSkillRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SkillSvtToJson(SkillSvt instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'num': instance.num,
      'priority': instance.priority,
      'script': instance.script,
      'strengthStatus': instance.strengthStatus,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condLimitCount': instance.condLimitCount,
      'eventId': instance.eventId,
      'flag': instance.flag,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

BaseTd _$BaseTdFromJson(Map json) => BaseTd(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      ruby: json['ruby'] as String? ?? "",
      icon: json['icon'] as String?,
      rank: json['rank'] as String? ?? "",
      type: json['type'] as String? ?? "",
      effectFlags:
          (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ??
              const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: json['npGain'] == null ? null : NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      npSvts:
          (json['npSvts'] as List<dynamic>?)?.map((e) => TdSvt.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );

Map<String, dynamic> _$BaseTdToJson(BaseTd instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ruby': instance.ruby,
      'icon': instance.icon,
      'rank': instance.rank,
      'type': instance.type,
      'effectFlags': instance.effectFlags.map((e) => _$TdEffectFlagEnumMap[e]!).toList(),
      'unmodifiedDetail': instance.unmodifiedDetail,
      'npGain': instance.npGain.toJson(),
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
      'npSvts': instance.npSvts.map((e) => e.toJson()).toList(),
    };

const _$TdEffectFlagEnumMap = {
  TdEffectFlag.support: 'support',
  TdEffectFlag.attackEnemyAll: 'attackEnemyAll',
  TdEffectFlag.attackEnemyOne: 'attackEnemyOne',
};

TdSvt _$TdSvtFromJson(Map json) => TdSvt(
      svtId: (json['svtId'] as num?)?.toInt() ?? 0,
      num: (json['num'] as num?)?.toInt() ?? 1,
      npNum: (json['npNum'] as num?)?.toInt() ?? 1,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      damage: (json['damage'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      strengthStatus: (json['strengthStatus'] as num?)?.toInt() ?? 0,
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      imageIndex: (json['imageIndex'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      condLv: (json['condLv'] as num?)?.toInt() ?? 0,
      condFriendshipRank: (json['condFriendshipRank'] as num?)?.toInt() ?? 0,
      card: $enumDecodeNullable(_$CardTypeEnumMap, json['card']) ?? CardType.none,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => SvtSkillRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TdSvtToJson(TdSvt instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'num': instance.num,
      'npNum': instance.npNum,
      'priority': instance.priority,
      'damage': instance.damage,
      'strengthStatus': instance.strengthStatus,
      'flag': instance.flag,
      'imageIndex': instance.imageIndex,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condFriendshipRank': instance.condFriendshipRank,
      'card': _$CardTypeEnumMap[instance.card]!,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
};

NiceTd _$NiceTdFromJson(Map json) => NiceTd(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      ruby: json['ruby'] as String? ?? "",
      icon: json['icon'] as String?,
      rank: json['rank'] as String? ?? "",
      type: json['type'] as String? ?? "",
      effectFlags:
          (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ??
              const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: json['npGain'] == null ? null : NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      npSvts:
          (json['npSvts'] as List<dynamic>?)?.map((e) => TdSvt.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      svtId: (json['svtId'] as num?)?.toInt() ?? 0,
      num: (json['num'] as num?)?.toInt() ?? 1,
      npNum: (json['npNum'] as num?)?.toInt() ?? 1,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      damage: (json['npDistribution'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      strengthStatus: (json['strengthStatus'] as num?)?.toInt() ?? 0,
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      imageIndex: (json['imageIndex'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      condLv: (json['condLv'] as num?)?.toInt() ?? 0,
      condFriendshipRank: (json['condFriendshipRank'] as num?)?.toInt() ?? 0,
      card: $enumDecodeNullable(_$CardTypeEnumMap, json['card']) ?? CardType.none,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => SvtSkillRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NiceTdToJson(NiceTd instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'num': instance.num,
      'npNum': instance.npNum,
      'priority': instance.priority,
      'npDistribution': instance.damage,
      'strengthStatus': instance.strengthStatus,
      'flag': instance.flag,
      'imageIndex': instance.imageIndex,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condFriendshipRank': instance.condFriendshipRank,
      'card': _$CardTypeEnumMap[instance.card]!,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'id': instance.id,
      'name': instance.name,
      'ruby': instance.ruby,
      'icon': instance.icon,
      'rank': instance.rank,
      'type': instance.type,
      'effectFlags': instance.effectFlags.map((e) => _$TdEffectFlagEnumMap[e]!).toList(),
      'unmodifiedDetail': instance.unmodifiedDetail,
      'npGain': instance.npGain.toJson(),
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
      'npSvts': instance.npSvts.map((e) => e.toJson()).toList(),
    };

ExtraPassive _$ExtraPassiveFromJson(Map json) => ExtraPassive(
      num: (json['num'] as num).toInt(),
      priority: (json['priority'] as num).toInt(),
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      condLv: (json['condLv'] as num?)?.toInt() ?? 0,
      condLimitCount: (json['condLimitCount'] as num?)?.toInt() ?? 0,
      condFriendshipRank: (json['condFriendshipRank'] as num?)?.toInt() ?? 0,
      eventId: (json['eventId'] as num?)?.toInt() ?? 0,
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
    );

Map<String, dynamic> _$ExtraPassiveToJson(ExtraPassive instance) => <String, dynamic>{
      'num': instance.num,
      'priority': instance.priority,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condLimitCount': instance.condLimitCount,
      'condFriendshipRank': instance.condFriendshipRank,
      'eventId': instance.eventId,
      'flag': instance.flag,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

SkillScript _$SkillScriptFromJson(Map json) => SkillScript(
      NP_HIGHER: (json['NP_HIGHER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      NP_LOWER: (json['NP_LOWER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      STAR_HIGHER: (json['STAR_HIGHER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      STAR_LOWER: (json['STAR_LOWER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      HP_VAL_HIGHER: (json['HP_VAL_HIGHER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      HP_VAL_LOWER: (json['HP_VAL_LOWER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      HP_PER_HIGHER: (json['HP_PER_HIGHER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      HP_PER_LOWER: (json['HP_PER_LOWER'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      actRarity: (json['actRarity'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
      battleStartRemainingTurn:
          (json['battleStartRemainingTurn'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      additionalSkillId: (json['additionalSkillId'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      additionalSkillLv: (json['additionalSkillLv'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      additionalSkillActorType:
          (json['additionalSkillActorType'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      SelectAddInfo: (json['SelectAddInfo'] as List<dynamic>?)
          ?.map((e) => SkillSelectAddInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tdTypeChangeIDs: (json['tdTypeChangeIDs'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      excludeTdChangeTypes: (json['excludeTdChangeTypes'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      IgnoreValueUp: json['IgnoreValueUp'],
    );

Map<String, dynamic> _$SkillScriptToJson(SkillScript instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('NP_HIGHER', instance.NP_HIGHER);
  writeNotNull('NP_LOWER', instance.NP_LOWER);
  writeNotNull('STAR_HIGHER', instance.STAR_HIGHER);
  writeNotNull('STAR_LOWER', instance.STAR_LOWER);
  writeNotNull('HP_VAL_HIGHER', instance.HP_VAL_HIGHER);
  writeNotNull('HP_VAL_LOWER', instance.HP_VAL_LOWER);
  writeNotNull('HP_PER_HIGHER', instance.HP_PER_HIGHER);
  writeNotNull('HP_PER_LOWER', instance.HP_PER_LOWER);
  writeNotNull('actRarity', instance.actRarity);
  writeNotNull('battleStartRemainingTurn', instance.battleStartRemainingTurn);
  writeNotNull('additionalSkillId', instance.additionalSkillId);
  writeNotNull('additionalSkillLv', instance.additionalSkillLv);
  writeNotNull('additionalSkillActorType', instance.additionalSkillActorType);
  writeNotNull('SelectAddInfo', instance.SelectAddInfo?.map((e) => e.toJson()).toList());
  writeNotNull('tdTypeChangeIDs', instance.tdTypeChangeIDs);
  writeNotNull('excludeTdChangeTypes', instance.excludeTdChangeTypes);
  writeNotNull('IgnoreValueUp', instance.IgnoreValueUp);
  return val;
}

SkillSelectAddInfo _$SkillSelectAddInfoFromJson(Map json) => SkillSelectAddInfo(
      title: json['title'] as String? ?? '',
      btn: (json['btn'] as List<dynamic>?)
              ?.map((e) => SkillSelectAddInfoBtn.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SkillSelectAddInfoToJson(SkillSelectAddInfo instance) => <String, dynamic>{
      'title': instance.title,
      'btn': instance.btn.map((e) => e.toJson()).toList(),
    };

SkillSelectAddInfoBtn _$SkillSelectAddInfoBtnFromJson(Map json) => SkillSelectAddInfoBtn(
      name: json['name'] as String? ?? '',
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) => SkillSelectAddInfoBtnCond.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SkillSelectAddInfoBtnToJson(SkillSelectAddInfoBtn instance) => <String, dynamic>{
      'name': instance.name,
      'conds': instance.conds.map((e) => e.toJson()).toList(),
    };

SkillSelectAddInfoBtnCond _$SkillSelectAddInfoBtnCondFromJson(Map json) => SkillSelectAddInfoBtnCond(
      cond: $enumDecodeNullable(_$SkillScriptCondEnumMap, json['cond']) ?? SkillScriptCond.none,
      value: (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SkillSelectAddInfoBtnCondToJson(SkillSelectAddInfoBtnCond instance) => <String, dynamic>{
      'cond': _$SkillScriptCondEnumMap[instance.cond]!,
      'value': instance.value,
    };

const _$SkillScriptCondEnumMap = {
  SkillScriptCond.none: 'NONE',
  SkillScriptCond.npHigher: 'NP_HIGHER',
  SkillScriptCond.npLower: 'NP_LOWER',
  SkillScriptCond.starHigher: 'STAR_HIGHER',
  SkillScriptCond.starLower: 'STAR_LOWER',
  SkillScriptCond.hpValHigher: 'HP_VAL_HIGHER',
  SkillScriptCond.hpValLower: 'HP_VAL_LOWER',
  SkillScriptCond.hpPerHigher: 'HP_PER_HIGHER',
  SkillScriptCond.hpPerLower: 'HP_PER_LOWER',
};

SkillAdd _$SkillAddFromJson(Map json) => SkillAdd(
      priority: (json['priority'] as num).toInt(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      name: json['name'] as String,
      ruby: json['ruby'] as String,
    );

Map<String, dynamic> _$SkillAddToJson(SkillAdd instance) => <String, dynamic>{
      'priority': instance.priority,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'ruby': instance.ruby,
    };

SvtSkillRelease _$SvtSkillReleaseFromJson(Map json) => SvtSkillRelease(
      idx: (json['idx'] as num?)?.toInt() ?? 1,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
      condNum: (json['condNum'] as num?)?.toInt() ?? 0,
      condGroup: (json['condGroup'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SvtSkillReleaseToJson(SvtSkillRelease instance) => <String, dynamic>{
      'idx': instance.idx,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condTargetId': instance.condTargetId,
      'condNum': instance.condNum,
      'condGroup': instance.condGroup,
    };

SkillGroupOverwrite _$SkillGroupOverwriteFromJson(Map json) => SkillGroupOverwrite(
      level: (json['level'] as num).toInt(),
      skillGroupId: (json['skillGroupId'] as num).toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
      icon: json['icon'] as String?,
      unmodifiedDetail: json['unmodifiedDetail'] as String? ?? '',
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SkillGroupOverwriteToJson(SkillGroupOverwrite instance) => <String, dynamic>{
      'level': instance.level,
      'skillGroupId': instance.skillGroupId,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'icon': instance.icon,
      'unmodifiedDetail': instance.unmodifiedDetail,
      'functions': instance.functions.map((e) => e.toJson()).toList(),
    };

NpGain _$NpGainFromJson(Map json) => NpGain(
      buster: (json['buster'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      arts: (json['arts'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      quick: (json['quick'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      extra: (json['extra'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      np: (json['np'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      defence: (json['defence'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    );

Map<String, dynamic> _$NpGainToJson(NpGain instance) => <String, dynamic>{
      'buster': instance.buster,
      'arts': instance.arts,
      'quick': instance.quick,
      'extra': instance.extra,
      'np': instance.np,
      'defence': instance.defence,
    };
