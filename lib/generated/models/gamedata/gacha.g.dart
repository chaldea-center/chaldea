// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/gacha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstGacha _$MstGachaFromJson(Map json) => MstGacha(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? "",
  imageId: (json['imageId'] as num?)?.toInt() ?? 0,
  type: json['type'] == null ? 1 : const GachaTypeConverter().fromJson(json['type']),
  freeDrawFlag: (json['freeDrawFlag'] as num?)?.toInt() ?? 0,
  openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
  closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
  detailUrl: json['detailUrl'] as String? ?? "",
  userAdded: json['userAdded'] as bool? ?? false,
);

Map<String, dynamic> _$MstGachaToJson(MstGacha instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageId': instance.imageId,
  'type': const GachaTypeConverter().toJson(instance.type),
  'freeDrawFlag': instance.freeDrawFlag,
  'openedAt': instance.openedAt,
  'closedAt': instance.closedAt,
  'detailUrl': instance.detailUrl,
  'userAdded': instance.userAdded,
};

NiceGacha _$NiceGachaFromJson(Map json) => NiceGacha(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  imageId: (json['imageId'] as num?)?.toInt() ?? 0,
  type: json['type'] == null ? 1 : const GachaTypeConverter().fromJson(json['type']),
  freeDrawFlag: (json['freeDrawFlag'] as num?)?.toInt() ?? 0,
  openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
  closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
  detailUrl: json['detailUrl'] as String? ?? "",
  userAdded: json['userAdded'] as bool? ?? false,
  storyAdjusts:
      (json['storyAdjusts'] as List<dynamic>?)
          ?.map((e) => GachaStoryAdjust.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  gachaSubs:
      (json['gachaSubs'] as List<dynamic>?)
          ?.map((e) => GachaSub.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  featuredSvtIds: (json['featuredSvtIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => GachaRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NiceGachaToJson(NiceGacha instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageId': instance.imageId,
  'type': const GachaTypeConverter().toJson(instance.type),
  'freeDrawFlag': instance.freeDrawFlag,
  'openedAt': instance.openedAt,
  'closedAt': instance.closedAt,
  'detailUrl': instance.detailUrl,
  'userAdded': instance.userAdded,
  'storyAdjusts': instance.storyAdjusts.map((e) => e.toJson()).toList(),
  'gachaSubs': instance.gachaSubs.map((e) => e.toJson()).toList(),
  'featuredSvtIds': instance.featuredSvtIds,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
};

GachaStoryAdjust _$GachaStoryAdjustFromJson(Map json) => GachaStoryAdjust(
  adjustId: (json['adjustId'] as num).toInt(),
  idx: (json['idx'] as num?)?.toInt() ?? 1,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  targetId: (json['targetId'] as num?)?.toInt() ?? 0,
  value: (json['value'] as num?)?.toInt() ?? 0,
  imageId: (json['imageId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GachaStoryAdjustToJson(GachaStoryAdjust instance) => <String, dynamic>{
  'adjustId': instance.adjustId,
  'idx': instance.idx,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'targetId': instance.targetId,
  'value': instance.value,
  'imageId': instance.imageId,
};

GachaSub _$GachaSubFromJson(Map json) => GachaSub(
  id: (json['id'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  imageId: (json['imageId'] as num?)?.toInt() ?? 0,
  adjustAddId: (json['adjustAddId'] as num?)?.toInt() ?? 0,
  openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
  closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  script: (json['script'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
);

Map<String, dynamic> _$GachaSubToJson(GachaSub instance) => <String, dynamic>{
  'id': instance.id,
  'priority': instance.priority,
  'imageId': instance.imageId,
  'adjustAddId': instance.adjustAddId,
  'openedAt': instance.openedAt,
  'closedAt': instance.closedAt,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
  'script': instance.script,
};

GachaRelease _$GachaReleaseFromJson(Map json) => GachaRelease(
  type: json['type'] == null ? CondType.none : const CondTypeConverter().fromJson(json['type'] as String),
  targetId: (json['targetId'] as num?)?.toInt() ?? 0,
  value: (json['value'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GachaReleaseToJson(GachaRelease instance) => <String, dynamic>{
  'type': const CondTypeConverter().toJson(instance.type),
  'targetId': instance.targetId,
  'value': instance.value,
};

const _$GachaTypeEnumMap = {
  GachaType.unknown: 'unknown',
  GachaType.payGacha: 'payGacha',
  GachaType.freeGacha: 'freeGacha',
  GachaType.ticketGacha: 'ticketGacha',
  GachaType.chargeStone: 'chargeStone',
};
