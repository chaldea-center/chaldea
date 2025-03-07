// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/api/recognizer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemResult _$ItemResultFromJson(Map json) => $checkedCreate('ItemResult', json, ($checkedConvert) {
  final val = ItemResult(
    key: $checkedConvert('key', (v) => v as String),
    startAt: $checkedConvert('startAt', (v) => (v as num).toInt()),
    endedAt: $checkedConvert('endedAt', (v) => (v as num).toInt()),
    details: $checkedConvert(
      'details',
      (v) => (v as List<dynamic>).map((e) => ItemDetail.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ItemResultToJson(ItemResult instance) => <String, dynamic>{
  'key': instance.key,
  'startAt': instance.startAt,
  'endedAt': instance.endedAt,
  'details': instance.details.map((e) => e.toJson()).toList(),
};

ItemDetail _$ItemDetailFromJson(Map json) => $checkedCreate('ItemDetail', json, ($checkedConvert) {
  final val = ItemDetail(
    itemId: $checkedConvert('itemId', (v) => (v as num).toInt()),
    count: $checkedConvert('count', (v) => (v as num).toInt()),
    thumb: $checkedConvert('thumb', (v) => v as String),
    numberThumb: $checkedConvert('numberThumb', (v) => v as String),
    imageId: $checkedConvert('imageId', (v) => (v as num).toInt()),
    score: $checkedConvert('score', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$ItemDetailToJson(ItemDetail instance) => <String, dynamic>{
  'itemId': instance.itemId,
  'count': instance.count,
  'thumb': instance.thumb,
  'numberThumb': instance.numberThumb,
  'imageId': instance.imageId,
  'score': instance.score,
};

SkillResult _$SkillResultFromJson(Map json) => $checkedCreate('SkillResult', json, ($checkedConvert) {
  final val = SkillResult(
    key: $checkedConvert('key', (v) => v as String),
    startAt: $checkedConvert('startAt', (v) => (v as num).toInt()),
    endedAt: $checkedConvert('endedAt', (v) => (v as num).toInt()),
    details: $checkedConvert(
      'details',
      (v) => (v as List<dynamic>).map((e) => SkillDetail.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SkillResultToJson(SkillResult instance) => <String, dynamic>{
  'key': instance.key,
  'startAt': instance.startAt,
  'endedAt': instance.endedAt,
  'details': instance.details.map((e) => e.toJson()).toList(),
};

SkillDetail _$SkillDetailFromJson(Map json) => $checkedCreate('SkillDetail', json, ($checkedConvert) {
  final val = SkillDetail(
    svtId: $checkedConvert('svtId', (v) => (v as num).toInt()),
    ascension: $checkedConvert('ascension', (v) => (v as num?)?.toInt() ?? 0),
    skill1: $checkedConvert('skill1', (v) => (v as num).toInt()),
    skill2: $checkedConvert('skill2', (v) => (v as num).toInt()),
    skill3: $checkedConvert('skill3', (v) => (v as num).toInt()),
    thumb: $checkedConvert('thumb', (v) => v as String),
    imageId: $checkedConvert('imageId', (v) => (v as num).toInt()),
    score: $checkedConvert('score', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$SkillDetailToJson(SkillDetail instance) => <String, dynamic>{
  'svtId': instance.svtId,
  'ascension': instance.ascension,
  'skill1': instance.skill1,
  'skill2': instance.skill2,
  'skill3': instance.skill3,
  'thumb': instance.thumb,
  'imageId': instance.imageId,
  'score': instance.score,
};
