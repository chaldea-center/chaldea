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

ExtraCharaImage _$ExtraCharaImageFromJson(Map json) => ExtraCharaImage(
      svtId: (json['svtId'] as num).toInt(),
      imageIds: json['imageIds'] as List<dynamic>?,
    );

Map<String, dynamic> _$ExtraCharaImageToJson(ExtraCharaImage instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'imageIds': instance.imageIds,
    };
