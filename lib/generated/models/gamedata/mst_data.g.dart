// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/mst_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FateTopLogin _$FateTopLoginFromJson(Map json) => FateTopLogin(
  responses:
      (json['response'] as List<dynamic>?)
          ?.map((e) => FateResponseDetail.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  cache: (json['cache'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
  sign: json['sign'] as String?,
);

FateResponseDetail _$FateResponseDetailFromJson(Map json) => FateResponseDetail(
  resCode: json['resCode'] as String?,
  success: json['success'] as Map?,
  fail: json['fail'] as Map?,
  nid: json['nid'] as String?,
  usk: json['usk'] as String?,
  encryptApi: (json['encryptApi'] as List<dynamic>?)?.map((e) => e as String).toList(),
);
