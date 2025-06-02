// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/mystic_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MysticCode _$MysticCodeFromJson(Map json) => MysticCode(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  detail: json['detail'] as String,
  extraAssets: ExtraMCAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
  skills: (json['skills'] as List<dynamic>)
      .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  expRequired: (json['expRequired'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  costumes:
      (json['costumes'] as List<dynamic>?)
          ?.map((e) => MysticCodeCostume.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MysticCodeToJson(MysticCode instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'detail': instance.detail,
  'extraAssets': instance.extraAssets.toJson(),
  'skills': instance.skills.map((e) => e.toJson()).toList(),
  'expRequired': instance.expRequired,
  'costumes': instance.costumes.map((e) => e.toJson()).toList(),
};

MCAssets _$MCAssetsFromJson(Map json) => MCAssets(male: json['male'] as String, female: json['female'] as String);

Map<String, dynamic> _$MCAssetsToJson(MCAssets instance) => <String, dynamic>{
  'male': instance.male,
  'female': instance.female,
};

ExtraMCAssets _$ExtraMCAssetsFromJson(Map json) => ExtraMCAssets(
  item: MCAssets.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
  masterFace: MCAssets.fromJson(Map<String, dynamic>.from(json['masterFace'] as Map)),
  masterFigure: MCAssets.fromJson(Map<String, dynamic>.from(json['masterFigure'] as Map)),
);

Map<String, dynamic> _$ExtraMCAssetsToJson(ExtraMCAssets instance) => <String, dynamic>{
  'item': instance.item.toJson(),
  'masterFace': instance.masterFace.toJson(),
  'masterFigure': instance.masterFigure.toJson(),
};

MysticCodeCostume _$MysticCodeCostumeFromJson(Map json) => MysticCodeCostume(
  id: (json['id'] as num).toInt(),
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  extraAssets: ExtraMCAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
);

Map<String, dynamic> _$MysticCodeCostumeToJson(MysticCodeCostume instance) => <String, dynamic>{
  'id': instance.id,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
  'extraAssets': instance.extraAssets.toJson(),
};
