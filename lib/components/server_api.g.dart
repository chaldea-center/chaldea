// GENERATED CODE - DO NOT MODIFY BY HAND

part of server_api;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SvtRecResults _$SvtRecResultsFromJson(Map<String, dynamic> json) =>
    SvtRecResults(
      uuid: json['uuid'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => OneSvtRecResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SvtRecResultsToJson(SvtRecResults instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'results': instance.results,
    };

OneSvtRecResult _$OneSvtRecResultFromJson(Map<String, dynamic> json) =>
    OneSvtRecResult(
      svtNo: json['svtNo'] as int?,
      maxLv: json['maxLv'] as int?,
      skill1: json['skill1'] as int?,
      skill2: json['skill2'] as int?,
      skill3: json['skill3'] as int?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$OneSvtRecResultToJson(OneSvtRecResult instance) =>
    <String, dynamic>{
      'svtNo': instance.svtNo,
      'maxLv': instance.maxLv,
      'skill1': instance.skill1,
      'skill2': instance.skill2,
      'skill3': instance.skill3,
      'image': instance.image,
    };
