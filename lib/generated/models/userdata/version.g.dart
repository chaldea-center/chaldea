// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionConstraints _$VersionConstraintsFromJson(Map json) =>
    $checkedCreate('VersionConstraints', json, ($checkedConvert) {
      final val = VersionConstraints(
        maxTimestamp: $checkedConvert('maxTimestamp', (v) => (v as num?)?.toInt()),
        minTimestamp: $checkedConvert('minTimestamp', (v) => (v as num?)?.toInt()),
        maxVersion: $checkedConvert('maxVersion', (v) => v == null ? null : AppVersion.fromJson(v as String)),
        minVersion: $checkedConvert('minVersion', (v) => v == null ? null : AppVersion.fromJson(v as String)),
      );
      return val;
    });

Map<String, dynamic> _$VersionConstraintsToJson(VersionConstraints instance) => <String, dynamic>{
  'maxTimestamp': instance.maxTimestamp,
  'minTimestamp': instance.minTimestamp,
  'maxVersion': instance.maxVersion?.toJson(),
  'minVersion': instance.minVersion?.toJson(),
};

VersionConstraintsSetting _$VersionConstraintsSettingFromJson(Map json) =>
    $checkedCreate('VersionConstraintsSetting', json, ($checkedConvert) {
      final val = VersionConstraintsSetting(
        app: $checkedConvert(
          'app',
          (v) => v == null ? null : VersionConstraints.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
        laplace: $checkedConvert(
          'laplace',
          (v) => v == null ? null : VersionConstraints.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
        sniff: $checkedConvert(
          'sniff',
          (v) => v == null ? null : VersionConstraints.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
      );
      return val;
    });

Map<String, dynamic> _$VersionConstraintsSettingToJson(VersionConstraintsSetting instance) => <String, dynamic>{
  'app': instance.app?.toJson(),
  'laplace': instance.laplace?.toJson(),
  'sniff': instance.sniff?.toJson(),
};
