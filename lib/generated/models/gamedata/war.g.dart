// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/war.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NiceWar _$NiceWarFromJson(Map json) => NiceWar(
  id: (json['id'] as num).toInt(),
  coordinates:
      (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList() ??
      const [],
  age: json['age'] as String? ?? "",
  name: json['name'] as String? ?? "",
  longName: json['longName'] as String? ?? "",
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$WarFlagEnumMap, e, unknownValue: WarFlag.none))
          .toList() ??
      const [],
  banner: json['banner'] as String?,
  headerImage: json['headerImage'] as String?,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  parentWarId: (json['parentWarId'] as num?)?.toInt() ?? 0,
  materialParentWarId: (json['materialParentWarId'] as num?)?.toInt() ?? 0,
  parentBlankEarthSpotId: (json['parentBlankEarthSpotId'] as num?)?.toInt() ?? 0,
  emptyMessage: json['emptyMessage'] as String? ?? "",
  bgm: json['bgm'] == null ? null : Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
  scriptId: json['scriptId'] as String?,
  script: json['script'] as String?,
  startType: $enumDecodeNullable(_$WarStartTypeEnumMap, json['startType']) ?? WarStartType.none,
  targetId: (json['targetId'] as num?)?.toInt() ?? 0,
  eventId: (json['eventId'] as num?)?.toInt() ?? 0,
  eventName: json['eventName'] as String? ?? "",
  lastQuestId: (json['lastQuestId'] as num?)?.toInt() ?? 0,
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => WarRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  warAdds:
      (json['warAdds'] as List<dynamic>?)?.map((e) => WarAdd.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => WarGroup.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  maps:
      (json['maps'] as List<dynamic>?)?.map((e) => WarMap.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  spots:
      (json['spots'] as List<dynamic>?)?.map((e) => NiceSpot.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  spotRoads:
      (json['spotRoads'] as List<dynamic>?)
          ?.map((e) => SpotRoad.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  questSelections:
      (json['questSelections'] as List<dynamic>?)
          ?.map((e) => WarQuestSelection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NiceWarToJson(NiceWar instance) => <String, dynamic>{
  'id': instance.id,
  'coordinates': instance.coordinates,
  'age': instance.age,
  'flags': instance.flags.map((e) => _$WarFlagEnumMap[e]!).toList(),
  'banner': instance.banner,
  'headerImage': instance.headerImage,
  'priority': instance.priority,
  'parentWarId': instance.parentWarId,
  'materialParentWarId': instance.materialParentWarId,
  'parentBlankEarthSpotId': instance.parentBlankEarthSpotId,
  'emptyMessage': instance.emptyMessage,
  'bgm': instance.bgm?.toJson(),
  'scriptId': instance.scriptId,
  'script': instance.script,
  'startType': _$WarStartTypeEnumMap[instance.startType]!,
  'targetId': instance.targetId,
  'eventName': instance.eventName,
  'lastQuestId': instance.lastQuestId,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
  'warAdds': instance.warAdds.map((e) => e.toJson()).toList(),
  'groups': instance.groups.map((e) => e.toJson()).toList(),
  'maps': instance.maps.map((e) => e.toJson()).toList(),
  'spots': instance.spots.map((e) => e.toJson()).toList(),
  'spotRoads': instance.spotRoads.map((e) => e.toJson()).toList(),
  'questSelections': instance.questSelections.map((e) => e.toJson()).toList(),
  'eventId': instance.eventId,
  'name': instance.name,
  'longName': instance.longName,
};

const _$WarFlagEnumMap = {
  WarFlag.none: 'none',
  WarFlag.withMap: 'withMap',
  WarFlag.showOnMaterial: 'showOnMaterial',
  WarFlag.folderSortPrior: 'folderSortPrior',
  WarFlag.storyShortcut: 'storyShortcut',
  WarFlag.isEvent: 'isEvent',
  WarFlag.closeAfterClear: 'closeAfterClear',
  WarFlag.mainScenario: 'mainScenario',
  WarFlag.isWarIconLeft: 'isWarIconLeft',
  WarFlag.clearedReturnToTitle: 'clearedReturnToTitle',
  WarFlag.noClearMarkWithClear: 'noClearMarkWithClear',
  WarFlag.noClearMarkWithComplete: 'noClearMarkWithComplete',
  WarFlag.notEntryBannerActive: 'notEntryBannerActive',
  WarFlag.shop: 'shop',
  WarFlag.blackMarkWithClear: 'blackMarkWithClear',
  WarFlag.dispFirstQuest: 'dispFirstQuest',
  WarFlag.effectDisappearBanner: 'effectDisappearBanner',
  WarFlag.whiteMarkWithClear: 'whiteMarkWithClear',
  WarFlag.subFolder: 'subFolder',
  WarFlag.dispEarthPointWithoutMap: 'dispEarthPointWithoutMap',
  WarFlag.isWarIconFree: 'isWarIconFree',
  WarFlag.isWarIconCenter: 'isWarIconCenter',
  WarFlag.noticeBoard: 'noticeBoard',
  WarFlag.changeDispClosedMessage: 'changeDispClosedMessage',
  WarFlag.chapterSubIdJapaneseNumeralsNormal: 'chapterSubIdJapaneseNumeralsNormal',
  WarFlag.caldeagatePriorityDisplay: 'caldeagatePriorityDisplay',
  WarFlag.areaBoardShortcut: 'areaBoardShortcut',
};

const _$WarStartTypeEnumMap = {WarStartType.none: 'none', WarStartType.script: 'script', WarStartType.quest: 'quest'};

WarMap _$WarMapFromJson(Map json) => WarMap(
  id: (json['id'] as num).toInt(),
  mapImage: json['mapImage'] as String?,
  mapImageW: (json['mapImageW'] as num?)?.toInt() ?? 0,
  mapImageH: (json['mapImageH'] as num?)?.toInt() ?? 0,
  mapGimmicks:
      (json['mapGimmicks'] as List<dynamic>?)
          ?.map((e) => MapGimmick.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  headerImage: json['headerImage'] as String?,
  bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
);

Map<String, dynamic> _$WarMapToJson(WarMap instance) => <String, dynamic>{
  'id': instance.id,
  'mapImage': instance.mapImage,
  'mapImageW': instance.mapImageW,
  'mapImageH': instance.mapImageH,
  'mapGimmicks': instance.mapGimmicks.map((e) => e.toJson()).toList(),
  'headerImage': instance.headerImage,
  'bgm': instance.bgm.toJson(),
};

MapGimmick _$MapGimmickFromJson(Map json) => MapGimmick(
  id: (json['id'] as num).toInt(),
  image: json['image'] as String?,
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toInt(),
  depthOffset: (json['depthOffset'] as num?)?.toInt() ?? 0,
  scale: (json['scale'] as num?)?.toInt() ?? 0,
  dispCondType: json['dispCondType'] == null
      ? CondType.none
      : const CondTypeConverter().fromJson(json['dispCondType'] as String),
  dispTargetId: (json['dispTargetId'] as num?)?.toInt() ?? 0,
  dispTargetValue: (json['dispTargetValue'] as num?)?.toInt() ?? 0,
  dispCondType2: json['dispCondType2'] == null
      ? CondType.none
      : const CondTypeConverter().fromJson(json['dispCondType2'] as String),
  dispTargetId2: (json['dispTargetId2'] as num?)?.toInt() ?? 0,
  dispTargetValue2: (json['dispTargetValue2'] as num?)?.toInt() ?? 0,
  startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
  endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MapGimmickToJson(MapGimmick instance) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'x': instance.x,
  'y': instance.y,
  'depthOffset': instance.depthOffset,
  'scale': instance.scale,
  'dispCondType': const CondTypeConverter().toJson(instance.dispCondType),
  'dispTargetId': instance.dispTargetId,
  'dispTargetValue': instance.dispTargetValue,
  'dispCondType2': const CondTypeConverter().toJson(instance.dispCondType2),
  'dispTargetId2': instance.dispTargetId2,
  'dispTargetValue2': instance.dispTargetValue2,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

NiceSpot _$NiceSpotFromJson(Map json) => NiceSpot(
  id: (json['id'] as num).toInt(),
  blankEarth: json['blankEarth'] as bool? ?? false,
  joinSpotIds: (json['joinSpotIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  mapId: (json['mapId'] as num).toInt(),
  name: json['name'] as String,
  image: json['image'] as String?,
  x: json['x'] as num? ?? 0,
  y: json['y'] as num? ?? 0,
  imageOfsX: (json['imageOfsX'] as num?)?.toInt() ?? 0,
  imageOfsY: (json['imageOfsY'] as num?)?.toInt() ?? 0,
  nameOfsX: (json['nameOfsX'] as num?)?.toInt() ?? 0,
  nameOfsY: (json['nameOfsY'] as num?)?.toInt() ?? 0,
  questOfsX: (json['questOfsX'] as num?)?.toInt() ?? 0,
  questOfsY: (json['questOfsY'] as num?)?.toInt() ?? 0,
  nextOfsX: (json['nextOfsX'] as num?)?.toInt() ?? 0,
  nextOfsY: (json['nextOfsY'] as num?)?.toInt() ?? 0,
  closedMessage: json['closedMessage'] as String? ?? "",
  spotAdds:
      (json['spotAdds'] as List<dynamic>?)
          ?.map((e) => SpotAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  quests:
      (json['quests'] as List<dynamic>?)?.map((e) => Quest.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
);

Map<String, dynamic> _$NiceSpotToJson(NiceSpot instance) => <String, dynamic>{
  'id': instance.id,
  'blankEarth': instance.blankEarth,
  'joinSpotIds': instance.joinSpotIds,
  'mapId': instance.mapId,
  'name': instance.name,
  'image': instance.image,
  'x': instance.x,
  'y': instance.y,
  'imageOfsX': instance.imageOfsX,
  'imageOfsY': instance.imageOfsY,
  'nameOfsX': instance.nameOfsX,
  'nameOfsY': instance.nameOfsY,
  'questOfsX': instance.questOfsX,
  'questOfsY': instance.questOfsY,
  'nextOfsX': instance.nextOfsX,
  'nextOfsY': instance.nextOfsY,
  'closedMessage': instance.closedMessage,
  'spotAdds': instance.spotAdds.map((e) => e.toJson()).toList(),
  'quests': instance.quests.map((e) => e.toJson()).toList(),
};

SpotAdd _$SpotAddFromJson(Map json) => SpotAdd(
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  overrideType: $enumDecodeNullable(_$SpotOverwriteTypeEnumMap, json['overrideType']) ?? SpotOverwriteType.none,
  targetId: (json['targetId'] as num?)?.toInt() ?? 0,
  targetText: json['targetText'] as String? ?? "",
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SpotAddToJson(SpotAdd instance) => <String, dynamic>{
  'priority': instance.priority,
  'overrideType': _$SpotOverwriteTypeEnumMap[instance.overrideType]!,
  'targetId': instance.targetId,
  'targetText': instance.targetText,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
};

const _$SpotOverwriteTypeEnumMap = {
  SpotOverwriteType.none: 'none',
  SpotOverwriteType.flag: 'flag',
  SpotOverwriteType.pathPointRatio: 'pathPointRatio',
  SpotOverwriteType.pathPointRatioLimit: 'pathPointRatioLimit',
  SpotOverwriteType.namePanelOffsetX: 'namePanelOffsetX',
  SpotOverwriteType.namePanelOffsetY: 'namePanelOffsetY',
  SpotOverwriteType.name: 'name',
};

SpotRoad _$SpotRoadFromJson(Map json) => SpotRoad(
  id: (json['id'] as num).toInt(),
  warId: (json['warId'] as num).toInt(),
  mapId: (json['mapId'] as num).toInt(),
  image: json['image'] as String,
  srcSpotId: (json['srcSpotId'] as num).toInt(),
  dstSpotId: (json['dstSpotId'] as num).toInt(),
  dispCondType: json['dispCondType'] == null
      ? CondType.none
      : const CondTypeConverter().fromJson(json['dispCondType'] as String),
  dispTargetId: (json['dispTargetId'] as num?)?.toInt() ?? 0,
  dispTargetValue: (json['dispTargetValue'] as num?)?.toInt() ?? 0,
  dispCondType2: json['dispCondType2'] == null
      ? CondType.none
      : const CondTypeConverter().fromJson(json['dispCondType2'] as String),
  dispTargetId2: (json['dispTargetId2'] as num?)?.toInt() ?? 0,
  dispTargetValue2: (json['dispTargetValue2'] as num?)?.toInt() ?? 0,
  activeCondType: json['activeCondType'] == null
      ? CondType.none
      : const CondTypeConverter().fromJson(json['activeCondType'] as String),
  activeTargetId: (json['activeTargetId'] as num?)?.toInt() ?? 0,
  activeTargetValue: (json['activeTargetValue'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SpotRoadToJson(SpotRoad instance) => <String, dynamic>{
  'id': instance.id,
  'warId': instance.warId,
  'mapId': instance.mapId,
  'image': instance.image,
  'srcSpotId': instance.srcSpotId,
  'dstSpotId': instance.dstSpotId,
  'dispCondType': const CondTypeConverter().toJson(instance.dispCondType),
  'dispTargetId': instance.dispTargetId,
  'dispTargetValue': instance.dispTargetValue,
  'dispCondType2': const CondTypeConverter().toJson(instance.dispCondType2),
  'dispTargetId2': instance.dispTargetId2,
  'dispTargetValue2': instance.dispTargetValue2,
  'activeCondType': const CondTypeConverter().toJson(instance.activeCondType),
  'activeTargetId': instance.activeTargetId,
  'activeTargetValue': instance.activeTargetValue,
};

WarAdd _$WarAddFromJson(Map json) => WarAdd(
  warId: (json['warId'] as num).toInt(),
  type: $enumDecodeNullable(_$WarOverwriteTypeEnumMap, json['type']) ?? WarOverwriteType.unknown,
  priority: (json['priority'] as num).toInt(),
  overwriteId: (json['overwriteId'] as num).toInt(),
  overwriteStr: json['overwriteStr'] as String? ?? "",
  overwriteBanner: json['overwriteBanner'] as String?,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  targetId: (json['targetId'] as num?)?.toInt() ?? 0,
  value: (json['value'] as num?)?.toInt() ?? 0,
  startedAt: (json['startedAt'] as num).toInt(),
  endedAt: (json['endedAt'] as num).toInt(),
);

Map<String, dynamic> _$WarAddToJson(WarAdd instance) => <String, dynamic>{
  'warId': instance.warId,
  'type': _$WarOverwriteTypeEnumMap[instance.type]!,
  'priority': instance.priority,
  'overwriteId': instance.overwriteId,
  'overwriteStr': instance.overwriteStr,
  'overwriteBanner': instance.overwriteBanner,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'targetId': instance.targetId,
  'value': instance.value,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

const _$WarOverwriteTypeEnumMap = {
  WarOverwriteType.unknown: 'unknown',
  WarOverwriteType.bgm: 'bgm',
  WarOverwriteType.parentWar: 'parentWar',
  WarOverwriteType.banner: 'banner',
  WarOverwriteType.bgImage: 'bgImage',
  WarOverwriteType.svtImage: 'svtImage',
  WarOverwriteType.flag: 'flag',
  WarOverwriteType.baseMapId: 'baseMapId',
  WarOverwriteType.name: 'name',
  WarOverwriteType.longName: 'longName',
  WarOverwriteType.materialParentWar: 'materialParentWar',
  WarOverwriteType.coordinates: 'coordinates',
  WarOverwriteType.effectChangeBlackMark: 'effectChangeBlackMark',
  WarOverwriteType.questBoardSectionImage: 'questBoardSectionImage',
  WarOverwriteType.warForceDisp: 'warForceDisp',
  WarOverwriteType.warForceHide: 'warForceHide',
  WarOverwriteType.startType: 'startType',
  WarOverwriteType.noticeDialogText: 'noticeDialogText',
  WarOverwriteType.clearMark: 'clearMark',
  WarOverwriteType.effectChangeWhiteMark: 'effectChangeWhiteMark',
  WarOverwriteType.commandSpellIcon: 'commandSpellIcon',
  WarOverwriteType.masterFaceIcon: 'masterFaceIcon',
  WarOverwriteType.priority: 'priority',
};

WarGroup _$WarGroupFromJson(Map json) => WarGroup(
  id: (json['id'] as num).toInt(),
  questAfterClear:
      $enumDecodeNullable(_$QuestAfterClearTypeEnumMap, json['questAfterClear']) ?? QuestAfterClearType.close,
  questType: $enumDecodeNullable(_$QuestTypeEnumMap, json['questType']) ?? QuestType.main,
);

Map<String, dynamic> _$WarGroupToJson(WarGroup instance) => <String, dynamic>{
  'id': instance.id,
  'questAfterClear': _$QuestAfterClearTypeEnumMap[instance.questAfterClear]!,
  'questType': _$QuestTypeEnumMap[instance.questType]!,
};

const _$QuestAfterClearTypeEnumMap = {
  QuestAfterClearType.close: 'close',
  QuestAfterClearType.repeatFirst: 'repeatFirst',
  QuestAfterClearType.repeatLast: 'repeatLast',
  QuestAfterClearType.resetInterval: 'resetInterval',
  QuestAfterClearType.closeDisp: 'closeDisp',
};

const _$QuestTypeEnumMap = {
  QuestType.main: 'main',
  QuestType.free: 'free',
  QuestType.friendship: 'friendship',
  QuestType.event: 'event',
  QuestType.heroballad: 'heroballad',
  QuestType.warBoard: 'warBoard',
  QuestType.autoExecute: 'autoExecute',
};

WarRelease _$WarReleaseFromJson(Map json) => WarRelease(
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condId: (json['condId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  warDisplayType:
      $enumDecodeNullable(_$WarReleaseDisplayTypeEnumMap, json['warDisplayType']) ?? WarReleaseDisplayType.hide,
  closedDialogMessage: json['closedDialogMessage'] as String? ?? "",
);

Map<String, dynamic> _$WarReleaseToJson(WarRelease instance) => <String, dynamic>{
  'priority': instance.priority,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condId': instance.condId,
  'condNum': instance.condNum,
  'warDisplayType': _$WarReleaseDisplayTypeEnumMap[instance.warDisplayType]!,
  'closedDialogMessage': instance.closedDialogMessage,
};

const _$WarReleaseDisplayTypeEnumMap = {
  WarReleaseDisplayType.hide: 'hide',
  WarReleaseDisplayType.open: 'open',
  WarReleaseDisplayType.close: 'close',
  WarReleaseDisplayType.announcement: 'announcement',
};

WarQuestSelection _$WarQuestSelectionFromJson(Map json) => WarQuestSelection(
  quest: Quest.fromJson(Map<String, dynamic>.from(json['quest'] as Map)),
  shortcutBanner: json['shortcutBanner'] as String?,
  priority: (json['priority'] as num).toInt(),
);

Map<String, dynamic> _$WarQuestSelectionToJson(WarQuestSelection instance) => <String, dynamic>{
  'quest': instance.quest.toJson(),
  'shortcutBanner': instance.shortcutBanner,
  'priority': instance.priority,
};
