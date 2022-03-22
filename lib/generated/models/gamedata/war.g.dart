// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/war.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NiceWar _$NiceWarFromJson(Map json) => NiceWar(
      id: json['id'] as int,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList(),
      age: json['age'] as String,
      name: json['name'] as String,
      longName: json['longName'] as String,
      flags: json['flags'] == null
          ? const []
          : toEnumListWarFlag(json['flags'] as List),
      banner: json['banner'] as String?,
      headerImage: json['headerImage'] as String?,
      priority: json['priority'] as int,
      parentWarId: json['parentWarId'] as int? ?? 0,
      materialParentWarId: json['materialParentWarId'] as int? ?? 0,
      emptyMessage: json['emptyMessage'] as String? ?? "クエストがありません",
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
      startType: $enumDecode(_$WarStartTypeEnumMap, json['startType']),
      targetId: json['targetId'] as int,
      eventId: json['eventId'] as int? ?? 0,
      eventName: json['eventName'] as String? ?? "",
      lastQuestId: json['lastQuestId'] as int,
      warAdds: (json['warAdds'] as List<dynamic>?)
              ?.map((e) => WarAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      maps: (json['maps'] as List<dynamic>?)
              ?.map(
                  (e) => NiceMap.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      spots: (json['spots'] as List<dynamic>?)
              ?.map(
                  (e) => NiceSpot.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      spotRoads: (json['spotRoads'] as List<dynamic>?)
              ?.map(
                  (e) => SpotRoad.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

const _$WarStartTypeEnumMap = {
  WarStartType.none: 'none',
  WarStartType.script: 'script',
  WarStartType.quest: 'quest',
};

NiceMap _$NiceMapFromJson(Map json) => NiceMap(
      id: json['id'] as int,
      mapImage: json['mapImage'] as String?,
      mapImageW: json['mapImageW'] as int,
      mapImageH: json['mapImageH'] as int,
      headerImage: json['headerImage'] as String?,
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
    );

NiceSpot _$NiceSpotFromJson(Map json) => NiceSpot(
      id: json['id'] as int,
      joinSpotIds: (json['joinSpotIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      mapId: json['mapId'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      x: json['x'] as int,
      y: json['y'] as int,
      imageOfsX: json['imageOfsX'] as int? ?? 0,
      imageOfsY: json['imageOfsY'] as int? ?? 0,
      nameOfsX: json['nameOfsX'] as int? ?? 0,
      nameOfsY: json['nameOfsY'] as int? ?? 0,
      questOfsX: json['questOfsX'] as int? ?? 0,
      questOfsY: json['questOfsY'] as int? ?? 0,
      nextOfsX: json['nextOfsX'] as int? ?? 0,
      nextOfsY: json['nextOfsY'] as int? ?? 0,
      closedMessage: json['closedMessage'] as String? ?? "",
      quests: (json['quests'] as List<dynamic>?)
              ?.map((e) => Quest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

SpotRoad _$SpotRoadFromJson(Map json) => SpotRoad(
      id: json['id'] as int,
      warId: json['warId'] as int,
      mapId: json['mapId'] as int,
      image: json['image'] as String,
      srcSpotId: json['srcSpotId'] as int,
      dstSpotId: json['dstSpotId'] as int,
      dispCondType: toEnumCondType(json['dispCondType'] as Object),
      dispTargetId: json['dispTargetId'] as int,
      dispTargetValue: json['dispTargetValue'] as int,
      dispCondType2: toEnumCondType(json['dispCondType2'] as Object),
      dispTargetId2: json['dispTargetId2'] as int,
      dispTargetValue2: json['dispTargetValue2'] as int,
      activeCondType: toEnumCondType(json['activeCondType'] as Object),
      activeTargetId: json['activeTargetId'] as int,
      activeTargetValue: json['activeTargetValue'] as int,
    );

WarAdd _$WarAddFromJson(Map json) => WarAdd(
      warId: json['warId'] as int,
      type: $enumDecode(_$WarOverwriteTypeEnumMap, json['type']),
      priority: json['priority'] as int,
      overwriteId: json['overwriteId'] as int,
      overwriteStr: json['overwriteStr'] as String? ?? "",
      overwriteBanner: json['overwriteBanner'] as String?,
      condType: toEnumCondType(json['condType'] as Object),
      targetId: json['targetId'] as int,
      value: json['value'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
    );

const _$WarOverwriteTypeEnumMap = {
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
};
