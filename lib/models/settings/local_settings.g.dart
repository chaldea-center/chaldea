// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalSettings _$LocalSettingsFromJson(Map json) => $checkedCreate(
      'LocalSettings',
      json,
      ($checkedConvert) {
        final val = LocalSettings(
          beta: $checkedConvert('beta', (v) => v as bool? ?? false),
          showWindowFab:
              $checkedConvert('showWindowFab', (v) => v as bool? ?? true),
        );
        return val;
      },
    );

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) =>
    <String, dynamic>{
      'beta': instance.beta,
      'showWindowFab': instance.showWindowFab,
    };
