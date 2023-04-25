// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseSkill _$BaseSkillFromJson(Map json) => BaseSkill(
      id: json['id'] as int,
      num: json['num'] as int? ?? -1,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecode(_$SkillTypeEnumMap, json['type']),
      icon: json['icon'] as String?,
      coolDown: (json['coolDown'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [0],
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
        (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
          ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$BaseSkillToJson(BaseSkill instance) => <String, dynamic>{
      'id': instance.id,
      'num': instance.num,
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
      id: json['id'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecode(_$SkillTypeEnumMap, json['type']),
      icon: json['icon'] as String?,
      coolDown: (json['coolDown'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
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
        (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
          ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      num: json['num'] as int? ?? 0,
      strengthStatus: json['strengthStatus'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      condLv: json['condLv'] as int? ?? 0,
      condLimitCount: json['condLimitCount'] as int? ?? 0,
      extraPassive: (json['extraPassive'] as List<dynamic>?)
              ?.map((e) => ExtraPassive.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NiceSkillToJson(NiceSkill instance) => <String, dynamic>{
      'num': instance.num,
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
      'strengthStatus': instance.strengthStatus,
      'priority': instance.priority,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condLimitCount': instance.condLimitCount,
      'extraPassive': instance.extraPassive.map((e) => e.toJson()).toList(),
    };

BaseTd _$BaseTdFromJson(Map json) => BaseTd(
      id: json['id'] as int,
      card: $enumDecode(_$CardTypeEnumMap, json['card']),
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      icon: json['icon'] as String?,
      rank: json['rank'] as String,
      type: json['type'] as String,
      effectFlags:
          (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ??
              const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      npDistribution: (json['npDistribution'] as List<dynamic>).map((e) => e as int).toList(),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$BaseTdToJson(BaseTd instance) => <String, dynamic>{
      'id': instance.id,
      'card': _$CardTypeEnumMap[instance.card]!,
      'name': instance.name,
      'ruby': instance.ruby,
      'icon': instance.icon,
      'rank': instance.rank,
      'type': instance.type,
      'effectFlags': instance.effectFlags.map((e) => _$TdEffectFlagEnumMap[e]!).toList(),
      'unmodifiedDetail': instance.unmodifiedDetail,
      'npGain': instance.npGain.toJson(),
      'npDistribution': instance.npDistribution,
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
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

const _$TdEffectFlagEnumMap = {
  TdEffectFlag.support: 'support',
  TdEffectFlag.attackEnemyAll: 'attackEnemyAll',
  TdEffectFlag.attackEnemyOne: 'attackEnemyOne',
};

TdSvt _$TdSvtFromJson(Map json) => TdSvt(
      svtId: json['svtId'] as int,
      num: json['num'] as int? ?? -1,
      priority: json['priority'] as int? ?? 0,
      damage: (json['damage'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      strengthStatus: json['strengthStatus'] as int? ?? 0,
      flag: json['flag'] as int? ?? 0,
      imageIndex: json['imageIndex'] as int? ?? 0,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      condLv: json['condLv'] as int? ?? 0,
      condFriendshipRank: json['condFriendshipRank'] as int? ?? 0,
      motion: json['motion'] as int? ?? 0,
      card: $enumDecodeNullable(_$CardTypeEnumMap, json['card']) ?? CardType.none,
    );

Map<String, dynamic> _$TdSvtToJson(TdSvt instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'num': instance.num,
      'priority': instance.priority,
      'damage': instance.damage,
      'strengthStatus': instance.strengthStatus,
      'flag': instance.flag,
      'imageIndex': instance.imageIndex,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'condLv': instance.condLv,
      'condFriendshipRank': instance.condFriendshipRank,
      'motion': instance.motion,
      'card': _$CardTypeEnumMap[instance.card]!,
    };

NiceTd _$NiceTdFromJson(Map json) => NiceTd(
      id: json['id'] as int,
      num: json['num'] as int,
      card: $enumDecode(_$CardTypeEnumMap, json['card']),
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      icon: json['icon'] as String?,
      rank: json['rank'] as String,
      type: json['type'] as String,
      effectFlags:
          (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ??
              const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      npDistribution: (json['npDistribution'] as List<dynamic>).map((e) => e as int).toList(),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      npSvts: (json['npSvts'] as List<dynamic>?)
              ?.map((e) => TdSvt.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      strengthStatus: json['strengthStatus'] as int? ?? 0,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
    );

Map<String, dynamic> _$NiceTdToJson(NiceTd instance) => <String, dynamic>{
      'card': _$CardTypeEnumMap[instance.card]!,
      'icon': instance.icon,
      'effectFlags': instance.effectFlags.map((e) => _$TdEffectFlagEnumMap[e]!).toList(),
      'npDistribution': instance.npDistribution,
      'id': instance.id,
      'name': instance.name,
      'ruby': instance.ruby,
      'rank': instance.rank,
      'type': instance.type,
      'unmodifiedDetail': instance.unmodifiedDetail,
      'npGain': instance.npGain.toJson(),
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'functions': instance.functions.map((e) => e.toJson()).toList(),
      'npSvts': instance.npSvts.map((e) => e.toJson()).toList(),
      'num': instance.num,
      'strengthStatus': instance.strengthStatus,
      'priority': instance.priority,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
    };

CommonRelease _$CommonReleaseFromJson(Map json) => CommonRelease(
      id: json['id'] as int,
      priority: json['priority'] as int,
      condGroup: json['condGroup'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condId: json['condId'] as int,
      condNum: json['condNum'] as int,
    );

Map<String, dynamic> _$CommonReleaseToJson(CommonRelease instance) => <String, dynamic>{
      'id': instance.id,
      'priority': instance.priority,
      'condGroup': instance.condGroup,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condId': instance.condId,
      'condNum': instance.condNum,
    };

ExtraPassive _$ExtraPassiveFromJson(Map json) => ExtraPassive(
      num: json['num'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      condLv: json['condLv'] as int? ?? 0,
      condLimitCount: json['condLimitCount'] as int? ?? 0,
      condFriendshipRank: json['condFriendshipRank'] as int? ?? 0,
      eventId: json['eventId'] as int? ?? 0,
      flag: json['flag'] as int? ?? 0,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
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
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

SkillScript _$SkillScriptFromJson(Map json) => SkillScript(
      NP_HIGHER: (json['NP_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      NP_LOWER: (json['NP_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      STAR_HIGHER: (json['STAR_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      STAR_LOWER: (json['STAR_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_VAL_HIGHER: (json['HP_VAL_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_VAL_LOWER: (json['HP_VAL_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_PER_HIGHER: (json['HP_PER_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_PER_LOWER: (json['HP_PER_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      additionalSkillId: (json['additionalSkillId'] as List<dynamic>?)?.map((e) => e as int).toList(),
      additionalSkillLv: (json['additionalSkillLv'] as List<dynamic>?)?.map((e) => e as int).toList(),
      additionalSkillActorType: (json['additionalSkillActorType'] as List<dynamic>?)?.map((e) => e as int).toList(),
      tdTypeChangeIDs: (json['tdTypeChangeIDs'] as List<dynamic>?)?.map((e) => e as int).toList(),
      excludeTdChangeTypes: (json['excludeTdChangeTypes'] as List<dynamic>?)?.map((e) => e as int).toList(),
      SelectAddInfo: (json['SelectAddInfo'] as List<dynamic>?)
          ?.map((e) => SkillSelectAddInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$SkillScriptToJson(SkillScript instance) => <String, dynamic>{
      'NP_HIGHER': instance.NP_HIGHER,
      'NP_LOWER': instance.NP_LOWER,
      'STAR_HIGHER': instance.STAR_HIGHER,
      'STAR_LOWER': instance.STAR_LOWER,
      'HP_VAL_HIGHER': instance.HP_VAL_HIGHER,
      'HP_VAL_LOWER': instance.HP_VAL_LOWER,
      'HP_PER_HIGHER': instance.HP_PER_HIGHER,
      'HP_PER_LOWER': instance.HP_PER_LOWER,
      'additionalSkillId': instance.additionalSkillId,
      'additionalSkillLv': instance.additionalSkillLv,
      'additionalSkillActorType': instance.additionalSkillActorType,
      'tdTypeChangeIDs': instance.tdTypeChangeIDs,
      'excludeTdChangeTypes': instance.excludeTdChangeTypes,
      'SelectAddInfo': instance.SelectAddInfo?.map((e) => e.toJson()).toList(),
    };

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
      value: json['value'] as int?,
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
      priority: json['priority'] as int,
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

SkillGroupOverwrite _$SkillGroupOverwriteFromJson(Map json) => SkillGroupOverwrite(
      level: json['level'] as int,
      skillGroupId: json['skillGroupId'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
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
      buster: (json['buster'] as List<dynamic>).map((e) => e as int).toList(),
      arts: (json['arts'] as List<dynamic>).map((e) => e as int).toList(),
      quick: (json['quick'] as List<dynamic>).map((e) => e as int).toList(),
      extra: (json['extra'] as List<dynamic>).map((e) => e as int).toList(),
      np: (json['np'] as List<dynamic>).map((e) => e as int).toList(),
      defence: (json['defence'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$NpGainToJson(NpGain instance) => <String, dynamic>{
      'buster': instance.buster,
      'arts': instance.arts,
      'quick': instance.quick,
      'extra': instance.extra,
      'np': instance.np,
      'defence': instance.defence,
    };
