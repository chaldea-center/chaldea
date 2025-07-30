// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstEvent _$MstEventFromJson(Map json) => MstEvent(
  id: (json['id'] as num).toInt(),
  type: (json['type'] as num).toInt(),
  name: json['name'] as String? ?? "",
  shortName: json['shortName'] as String? ?? "",
  startedAt: (json['startedAt'] as num).toInt(),
  endedAt: (json['endedAt'] as num).toInt(),
  finishedAt: (json['finishedAt'] as num).toInt(),
);

ExtraCharaFigure _$ExtraCharaFigureFromJson(Map json) => ExtraCharaFigure(
  svtId: (json['svtId'] as num).toInt(),
  charaFigureIds: (json['charaFigureIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$ExtraCharaFigureToJson(ExtraCharaFigure instance) => <String, dynamic>{
  'svtId': instance.svtId,
  'charaFigureIds': instance.charaFigureIds,
};

ExtraCharaImage _$ExtraCharaImageFromJson(Map json) =>
    ExtraCharaImage(svtId: (json['svtId'] as num).toInt(), imageIds: json['imageIds'] as List<dynamic>?);

Map<String, dynamic> _$ExtraCharaImageToJson(ExtraCharaImage instance) => <String, dynamic>{
  'svtId': instance.svtId,
  'imageIds': instance.imageIds,
};

MstViewEnemy _$MstViewEnemyFromJson(Map json) => MstViewEnemy(
  questId: (json['questId'] as num).toInt(),
  enemyId: (json['enemyId'] as num).toInt(),
  name: json['name'] as String,
  classId: (json['classId'] as num).toInt(),
  svtId: (json['svtId'] as num).toInt(),
  limitCount: (json['limitCount'] as num).toInt(),
  iconId: (json['iconId'] as num).toInt(),
  displayType: (json['displayType'] as num).toInt(),
  missionIds: (json['missionIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  impossibleKill: (json['impossibleKill'] as num?)?.toInt() ?? 0,
  enemyScript: json['enemyScript'],
  npcSvtId: (json['npcSvtId'] as num).toInt(),
);

Map<String, dynamic> _$MstViewEnemyToJson(MstViewEnemy instance) => <String, dynamic>{
  'questId': instance.questId,
  'enemyId': instance.enemyId,
  'name': instance.name,
  'classId': instance.classId,
  'svtId': instance.svtId,
  'limitCount': instance.limitCount,
  'iconId': instance.iconId,
  'displayType': instance.displayType,
  'missionIds': instance.missionIds,
  'impossibleKill': instance.impossibleKill,
  'enemyScript': instance.enemyScript,
  'npcSvtId': instance.npcSvtId,
};

UserDeckFormationCond _$UserDeckFormationCondFromJson(Map json) => UserDeckFormationCond(
  targetVals: (json['targetVals'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  targetVals2: (json['targetVals2'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  id: (json['id'] as num).toInt(),
  type: (json['type'] as num?)?.toInt() ?? 0,
  rangeType: (json['rangeType'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserDeckFormationCondToJson(UserDeckFormationCond instance) => <String, dynamic>{
  'targetVals': instance.targetVals,
  'targetVals2': instance.targetVals2,
  'id': instance.id,
  'type': instance.type,
  'rangeType': instance.rangeType,
};

MstQuestHint _$MstQuestHintFromJson(Map json) => MstQuestHint(
  questId: (json['questId'] as num).toInt(),
  questPhase: (json['questPhase'] as num).toInt(),
  title: json['title'] as String? ?? '',
  message: json['message'] as String? ?? '',
  leftIndent: (json['leftIndent'] as num?)?.toInt() ?? 0,
  openType: (json['openType'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MstQuestHintToJson(MstQuestHint instance) => <String, dynamic>{
  'questId': instance.questId,
  'questPhase': instance.questPhase,
  'title': instance.title,
  'message': instance.message,
  'leftIndent': instance.leftIndent,
  'openType': instance.openType,
};

MstSvtFilter _$MstSvtFilterFromJson(Map json) => MstSvtFilter(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? "",
  svtIds: (json['svtIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
  endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MstSvtFilterToJson(MstSvtFilter instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'svtIds': instance.svtIds,
  'priority': instance.priority,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

MstEventSvtFatigue _$MstEventSvtFatigueFromJson(Map json) => MstEventSvtFatigue(
  eventId: (json['eventId'] as num).toInt(),
  svtId: (json['svtId'] as num?)?.toInt() ?? 0,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  fatigueTime: (json['fatigueTime'] as num?)?.toInt() ?? 0,
  commonReleaseId: (json['commonReleaseId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MstEventSvtFatigueToJson(MstEventSvtFatigue instance) => <String, dynamic>{
  'eventId': instance.eventId,
  'svtId': instance.svtId,
  'priority': instance.priority,
  'fatigueTime': instance.fatigueTime,
  'commonReleaseId': instance.commonReleaseId,
};

MstStaffPhoto _$MstStaffPhotoFromJson(Map json) => MstStaffPhoto(
  id: (json['id'] as num).toInt(),
  staffName: json['staffName'] as String? ?? "",
  spriteName: json['spriteName'] as String? ?? "",
  dispOrder: (json['dispOrder'] as num?)?.toInt() ?? 0,
  condType: (json['condType'] as num?)?.toInt() ?? 0,
  condId: (json['condId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  extendData: (json['extendData'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
);

Map<String, dynamic> _$MstStaffPhotoToJson(MstStaffPhoto instance) => <String, dynamic>{
  'id': instance.id,
  'staffName': instance.staffName,
  'spriteName': instance.spriteName,
  'dispOrder': instance.dispOrder,
  'condType': instance.condType,
  'condId': instance.condId,
  'condNum': instance.condNum,
  'extendData': instance.extendData,
};

MstStaffPhotoCostume _$MstStaffPhotoCostumeFromJson(Map json) => MstStaffPhotoCostume(
  staffPhotoId: (json['staffPhotoId'] as num?)?.toInt() ?? 0,
  idx: (json['idx'] as num?)?.toInt() ?? 0,
  dispOrder: (json['dispOrder'] as num?)?.toInt() ?? 0,
  spriteName: json['spriteName'] as String? ?? "",
  imageId: (json['imageId'] as num?)?.toInt() ?? 0,
  faceId: (json['faceId'] as num?)?.toInt() ?? 0,
  costumeName: json['costumeName'] as String? ?? "",
  condType: (json['condType'] as num?)?.toInt() ?? 0,
  condId: (json['condId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  extendData: (json['extendData'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
);

Map<String, dynamic> _$MstStaffPhotoCostumeToJson(MstStaffPhotoCostume instance) => <String, dynamic>{
  'staffPhotoId': instance.staffPhotoId,
  'idx': instance.idx,
  'dispOrder': instance.dispOrder,
  'spriteName': instance.spriteName,
  'imageId': instance.imageId,
  'faceId': instance.faceId,
  'costumeName': instance.costumeName,
  'condType': instance.condType,
  'condId': instance.condId,
  'condNum': instance.condNum,
  'extendData': instance.extendData,
};

RegionInfo _$RegionInfoFromJson(Map json) => RegionInfo(
  hash: json['hash'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  serverHash: json['serverHash'] as String,
  serverTimestamp: (json['serverTimestamp'] as num).toInt(),
  dataVer: (json['dataVer'] as num?)?.toInt(),
  dateVer: (json['dateVer'] as num?)?.toInt(),
  assetbundle: json['assetbundle'] == null ? null : RegionAssetBundle.fromJson(json['assetbundle'] as Map),
);

Map<String, dynamic> _$RegionInfoToJson(RegionInfo instance) => <String, dynamic>{
  'hash': instance.hash,
  'timestamp': instance.timestamp,
  'serverHash': instance.serverHash,
  'serverTimestamp': instance.serverTimestamp,
  'dataVer': instance.dataVer,
  'dateVer': instance.dateVer,
  'assetbundle': instance.assetbundle?.toJson(),
};

RegionAssetBundle _$RegionAssetBundleFromJson(Map json) => RegionAssetBundle(
  folderName: json['folderName'] as String,
  animalName: json['animalName'] as String,
  zooName: json['zooName'] as String,
);

Map<String, dynamic> _$RegionAssetBundleToJson(RegionAssetBundle instance) => <String, dynamic>{
  'folderName': instance.folderName,
  'animalName': instance.animalName,
  'zooName': instance.zooName,
};
