// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstEvent _$MstEventFromJson(Map json) => MstEvent(
      id: json['id'] as int,
      type: json['type'] as int,
      name: json['name'] as String? ?? "",
      shortName: json['shortName'] as String? ?? "",
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      finishedAt: json['finishedAt'] as int,
    );

ExtraCharaFigure _$ExtraCharaFigureFromJson(Map json) => ExtraCharaFigure(
      svtId: json['svtId'] as int,
      charaFigureIds: (json['charaFigureIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ExtraCharaFigureToJson(ExtraCharaFigure instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'charaFigureIds': instance.charaFigureIds,
    };

ExtraCharaImage _$ExtraCharaImageFromJson(Map json) => ExtraCharaImage(
      svtId: json['svtId'] as int,
      imageIds: json['imageIds'] as List<dynamic>?,
    );

Map<String, dynamic> _$ExtraCharaImageToJson(ExtraCharaImage instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'imageIds': instance.imageIds,
    };
