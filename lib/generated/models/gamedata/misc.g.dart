// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/misc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstMyRoomAdd _$MstMyRoomAddFromJson(Map json) => MstMyRoomAdd(
  id: (json['id'] as num).toInt(),
  type: (json['type'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  overwriteId: (json['overwriteId'] as num).toInt(),
  condType: (json['condType'] as num).toInt(),
  condValue: (json['condValue'] as num).toInt(),
  condValue2: (json['condValue2'] as num).toInt(),
  startedAt: (json['startedAt'] as num).toInt(),
  endedAt: (json['endedAt'] as num).toInt(),
);

Map<String, dynamic> _$MstMyRoomAddToJson(MstMyRoomAdd instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'priority': instance.priority,
  'overwriteId': instance.overwriteId,
  'condType': instance.condType,
  'condValue': instance.condValue,
  'condValue2': instance.condValue2,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

MstMyRoomAddBgDiff _$MstMyRoomAddBgDiffFromJson(Map json) => MstMyRoomAddBgDiff(
  overwriteId: (json['overwriteId'] as num).toInt(),
  type: (json['type'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  objectId: (json['objectId'] as num).toInt(),
  condType: (json['condType'] as num).toInt(),
  condId: (json['condId'] as num).toInt(),
  condValue: (json['condValue'] as num).toInt(),
);

Map<String, dynamic> _$MstMyRoomAddBgDiffToJson(MstMyRoomAddBgDiff instance) => <String, dynamic>{
  'overwriteId': instance.overwriteId,
  'type': instance.type,
  'priority': instance.priority,
  'objectId': instance.objectId,
  'condType': instance.condType,
  'condId': instance.condId,
  'condValue': instance.condValue,
};

NiceOpeningMovie _$NiceOpeningMovieFromJson(Map json) => NiceOpeningMovie(
  id: (json['id'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? "",
  movie: json['movie'] as String? ?? "",
  eventId: (json['eventId'] as num?)?.toInt() ?? 0,
  materialPosType:
      $enumDecodeNullable(
        _$NiceOpeningMovieMaterialPosTypeEnumMap,
        json['materialPosType'],
        unknownValue: NiceOpeningMovieMaterialPosType.none,
      ) ??
      NiceOpeningMovieMaterialPosType.none,
  materialPosValue: (json['materialPosValue'] as num?)?.toInt() ?? 0,
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  materialReleaseConditions:
      (json['materialReleaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  playTime: (json['playTime'] as num?)?.toInt() ?? 0,
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$NiceOpeningMovieFlagEnumMap, e, unknownValue: NiceOpeningMovieFlag.none))
          .toList() ??
      const [],
  startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
  endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
  script: json['script'] == null
      ? null
      : NiceOpeningMovieScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
);

Map<String, dynamic> _$NiceOpeningMovieToJson(NiceOpeningMovie instance) => <String, dynamic>{
  'id': instance.id,
  'priority': instance.priority,
  'name': instance.name,
  'movie': instance.movie,
  'eventId': instance.eventId,
  'materialPosType': _$NiceOpeningMovieMaterialPosTypeEnumMap[instance.materialPosType]!,
  'materialPosValue': instance.materialPosValue,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
  'materialReleaseConditions': instance.materialReleaseConditions.map((e) => e.toJson()).toList(),
  'playTime': instance.playTime,
  'flags': instance.flags.map((e) => _$NiceOpeningMovieFlagEnumMap[e]!).toList(),
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
  'script': instance.script.toJson(),
};

const _$NiceOpeningMovieMaterialPosTypeEnumMap = {
  NiceOpeningMovieMaterialPosType.none: 'none',
  NiceOpeningMovieMaterialPosType.mainRecordTop: 'mainRecordTop',
  NiceOpeningMovieMaterialPosType.storyBottom: 'storyBottom',
  NiceOpeningMovieMaterialPosType.questScript: 'questScript',
};

const _$NiceOpeningMovieFlagEnumMap = {
  NiceOpeningMovieFlag.none: 'none',
  NiceOpeningMovieFlag.displaySeekBar: 'displaySeekBar',
};

NiceOpeningMovieScript _$NiceOpeningMovieScriptFromJson(Map json) => NiceOpeningMovieScript(
  timing: $enumDecodeNullable(
    _$NiceOpeningMovieTimingEnumMap,
    json['timing'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
);

Map<String, dynamic> _$NiceOpeningMovieScriptToJson(NiceOpeningMovieScript instance) => <String, dynamic>{
  'timing': _$NiceOpeningMovieTimingEnumMap[instance.timing],
};

const _$NiceOpeningMovieTimingEnumMap = {
  NiceOpeningMovieTiming.all: 'all',
  NiceOpeningMovieTiming.title: 'title',
  NiceOpeningMovieTiming.terminalNoticeAfter: 'terminalNoticeAfter',
  NiceOpeningMovieTiming.blankEarthActionEnd: 'blankEarthActionEnd',
  NiceOpeningMovieTiming.blankEarthSpotOpen: 'blankEarthSpotOpen',
  NiceOpeningMovieTiming.areaBoardTap: 'areaBoardTap',
  NiceOpeningMovieTiming.grandQuestClassSelectSetup: 'grandQuestClassSelectSetup',
  NiceOpeningMovieTiming.movieTiming20251220: 'movieTiming20251220',
  NiceOpeningMovieTiming.titleLoginAfter: 'titleLoginAfter',
};
