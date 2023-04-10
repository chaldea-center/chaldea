// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/command_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandCode _$CommandCodeFromJson(Map json) => CommandCode(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      rarity: json['rarity'] as int,
      extraAssets: ExtraCCAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      illustrator: json['illustrator'] as String,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$CommandCodeToJson(CommandCode instance) => <String, dynamic>{
      'id': instance.id,
      'collectionNo': instance.collectionNo,
      'name': instance.name,
      'ruby': instance.ruby,
      'rarity': instance.rarity,
      'extraAssets': instance.extraAssets.toJson(),
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'illustrator': instance.illustrator,
      'comment': instance.comment,
    };

BasicCommandCode _$BasicCommandCodeFromJson(Map json) => BasicCommandCode(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      rarity: json['rarity'] as int,
      face: json['face'] as String,
    );

Map<String, dynamic> _$BasicCommandCodeToJson(BasicCommandCode instance) => <String, dynamic>{
      'id': instance.id,
      'collectionNo': instance.collectionNo,
      'name': instance.name,
      'rarity': instance.rarity,
      'face': instance.face,
    };
