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
  actIndividuality: json['actIndividuality'] == null
      ? const []
      : const TraitListConverter().fromJson(json['actIndividuality'] as Object),
  script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  skillAdd:
      (json['skillAdd'] as List<dynamic>?)
          ?.map((e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  aiIds: (json['aiIds'] as Map?)?.map(
    (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
  ),
  groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
      ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  functions:
      (json['functions'] as List<dynamic>?)
          ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  skillSvts:
      (json['skillSvts'] as List<dynamic>?)
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
  'actIndividuality': const TraitListConverter().toJson(instance.actIndividuality),
  'script': instance.script?.toJson(),
  'skillAdd': instance.skillAdd.map((e) => e.toJson()).toList(),
  'aiIds': instance.aiIds?.map((k, e) => MapEntry(_$AiTypeEnumMap[k]!, e)),
  'groupOverwrites': instance.groupOverwrites?.map((e) => e.toJson()).toList(),
  'functions': instance.functions.map((e) => e.toJson()).toList(),
  'skillSvts': instance.skillSvts.map((e) => e.toJson()).toList(),
};

const _$SkillTypeEnumMap = {SkillType.active: 'active', SkillType.passive: 'passive'};

const _$AiTypeEnumMap = {AiType.svt: 'svt', AiType.field: 'field'};

NiceSkill _$NiceSkillFromJson(Map json) => NiceSkill(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? "",
  ruby: json['ruby'] as String? ?? '',
  unmodifiedDetail: json['unmodifiedDetail'] as String?,
  type: $enumDecodeNullable(_$SkillTypeEnumMap, json['type']) ?? SkillType.active,
  icon: json['icon'] as String?,
  coolDown: (json['coolDown'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [0],
  actIndividuality: json['actIndividuality'] == null
      ? const []
      : const TraitListConverter().fromJson(json['actIndividuality'] as Object),
  script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  skillAdd:
      (json['skillAdd'] as List<dynamic>?)
          ?.map((e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  aiIds: (json['aiIds'] as Map?)?.map(
    (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
  ),
  groupOverwrites: (json['groupOverwrites'] as List<dynamic>?)
      ?.map((e) => SkillGroupOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  functions:
      (json['functions'] as List<dynamic>?)
          ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  skillSvts:
      (json['skillSvts'] as List<dynamic>?)
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
  extraPassive:
      (json['extraPassive'] as List<dynamic>?)
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
  'actIndividuality': const TraitListConverter().toJson(instance.actIndividuality),
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
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
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
      (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ?? const [],
  unmodifiedDetail: json['unmodifiedDetail'] as String?,
  npGain: json['npGain'] == null ? null : NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
  individuality: json['individuality'] == null
      ? const []
      : const TraitListConverter().fromJson(json['individuality'] as Object),
  script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  functions:
      (json['functions'] as List<dynamic>?)
          ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  npSvts: (json['npSvts'] as List<dynamic>?)?.map((e) => TdSvt.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
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
  'individuality': const TraitListConverter().toJson(instance.individuality),
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
  card: json['card'] == null ? CardType.none : const CardTypeConverter().fromJson(json['card']),
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
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
  'card': const CardTypeConverter().toJson(instance.card),
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
};

NiceTd _$NiceTdFromJson(Map json) => NiceTd(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? "",
  ruby: json['ruby'] as String? ?? "",
  icon: json['icon'] as String?,
  rank: json['rank'] as String? ?? "",
  type: json['type'] as String? ?? "",
  effectFlags:
      (json['effectFlags'] as List<dynamic>?)?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e)).toList() ?? const [],
  unmodifiedDetail: json['unmodifiedDetail'] as String?,
  npGain: json['npGain'] == null ? null : NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
  individuality: json['individuality'] == null
      ? const []
      : const TraitListConverter().fromJson(json['individuality'] as Object),
  script: json['script'] == null ? null : SkillScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  functions:
      (json['functions'] as List<dynamic>?)
          ?.map((e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  npSvts: (json['npSvts'] as List<dynamic>?)?.map((e) => TdSvt.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
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
  card: json['card'] == null ? CardType.none : const CardTypeConverter().fromJson(json['card']),
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
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
  'card': const CardTypeConverter().toJson(instance.card),
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
  'individuality': const TraitListConverter().toJson(instance.individuality),
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
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
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
  actRarity: (json['actRarity'] as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  SelectAddInfo: (json['SelectAddInfo'] as List<dynamic>?)
      ?.map((e) => SkillSelectAddInfo.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  selectTreasureDeviceInfo: (json['selectTreasureDeviceInfo'] as List<dynamic>?)
      ?.map((e) => SelectTreasureDeviceInfo.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  condBranchSkillInfo: (json['condBranchSkillInfo'] as List<dynamic>?)
      ?.map((e) => CondBranchSkillInfo.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  IgnoreValueUp: json['IgnoreValueUp'],
  IgnoreBattlePointUp: json['IgnoreBattlePointUp'] as List<dynamic>?,
  tdChangeByBattlePoint: (json['tdChangeByBattlePoint'] as List<dynamic>?)
      ?.map((e) => TdChangeByBattlePoint.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
);

Map<String, dynamic> _$SkillScriptToJson(SkillScript instance) => <String, dynamic>{
  'actRarity': ?instance.actRarity,
  'SelectAddInfo': ?instance.SelectAddInfo?.map((e) => e.toJson()).toList(),
  'selectTreasureDeviceInfo': ?instance.selectTreasureDeviceInfo?.map((e) => e.toJson()).toList(),
  'condBranchSkillInfo': ?instance.condBranchSkillInfo?.map((e) => e.toJson()).toList(),
  'IgnoreValueUp': ?instance.IgnoreValueUp,
  'IgnoreBattlePointUp': ?instance.IgnoreBattlePointUp,
  'tdChangeByBattlePoint': ?instance.tdChangeByBattlePoint?.map((e) => e.toJson()).toList(),
};

SkillSelectAddInfo _$SkillSelectAddInfoFromJson(Map json) => SkillSelectAddInfo(
  title: json['title'] as String? ?? '',
  btn:
      (json['btn'] as List<dynamic>?)
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
  conds:
      (json['conds'] as List<dynamic>?)
          ?.map((e) => SkillSelectAddInfoBtnCond.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  image: json['image'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$SkillSelectAddInfoBtnToJson(SkillSelectAddInfoBtn instance) => <String, dynamic>{
  'name': instance.name,
  'conds': instance.conds.map((e) => e.toJson()).toList(),
  'image': instance.image,
  'imageUrl': instance.imageUrl,
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

SelectTreasureDeviceInfo _$SelectTreasureDeviceInfoFromJson(Map json) => SelectTreasureDeviceInfo(
  dialogType: (json['dialogType'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? "",
  messageOnSelected: json['messageOnSelected'] as String? ?? "",
  treasureDevices:
      (json['treasureDevices'] as List<dynamic>?)
          ?.map((e) => SelectTdInfoTdChangeParam.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SelectTreasureDeviceInfoToJson(SelectTreasureDeviceInfo instance) => <String, dynamic>{
  'dialogType': instance.dialogType,
  'title': instance.title,
  'messageOnSelected': instance.messageOnSelected,
  'treasureDevices': instance.treasureDevices.map((e) => e.toJson()).toList(),
};

SelectTdInfoTdChangeParam _$SelectTdInfoTdChangeParamFromJson(Map json) => SelectTdInfoTdChangeParam(
  id: (json['id'] as num?)?.toInt() ?? 0,
  type: json['type'] == null ? CardType.none : const CardTypeConverter().fromJson(json['type']),
  message: json['message'] as String? ?? "",
);

Map<String, dynamic> _$SelectTdInfoTdChangeParamToJson(SelectTdInfoTdChangeParam instance) => <String, dynamic>{
  'id': instance.id,
  'type': const CardTypeConverter().toJson(instance.type),
  'message': instance.message,
};

TdChangeByBattlePoint _$TdChangeByBattlePointFromJson(Map json) => TdChangeByBattlePoint(
  battlePointId: (json['battlePointId'] as num).toInt(),
  phase: (json['phase'] as num).toInt(),
  noblePhantasmId: (json['noblePhantasmId'] as num).toInt(),
);

Map<String, dynamic> _$TdChangeByBattlePointToJson(TdChangeByBattlePoint instance) => <String, dynamic>{
  'battlePointId': instance.battlePointId,
  'phase': instance.phase,
  'noblePhantasmId': instance.noblePhantasmId,
};

CondBranchSkillInfo _$CondBranchSkillInfoFromJson(Map json) => CondBranchSkillInfo(
  condType:
      $enumDecodeNullable(_$BattleBranchSkillCondBranchTypeEnumMap, json['condType']) ??
      BattleBranchSkillCondBranchType.none,
  condValue: (json['condValue'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  skillId: (json['skillId'] as num?)?.toInt() ?? 0,
  detailText: json['detailText'] as String? ?? '',
  iconBuffId: (json['iconBuffId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CondBranchSkillInfoToJson(CondBranchSkillInfo instance) => <String, dynamic>{
  'condType': _$BattleBranchSkillCondBranchTypeEnumMap[instance.condType]!,
  'condValue': instance.condValue,
  'skillId': instance.skillId,
  'detailText': instance.detailText,
  'iconBuffId': instance.iconBuffId,
};

const _$BattleBranchSkillCondBranchTypeEnumMap = {
  BattleBranchSkillCondBranchType.none: 'none',
  BattleBranchSkillCondBranchType.isSelfTarget: 'isSelfTarget',
  BattleBranchSkillCondBranchType.individuality: 'individuality',
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
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
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
  functions:
      (json['functions'] as List<dynamic>?)
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
