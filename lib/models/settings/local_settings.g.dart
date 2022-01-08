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
          alwaysOnTop:
              $checkedConvert('alwaysOnTop', (v) => v as bool? ?? false),
          windowPosition: $checkedConvert('windowPosition',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          launchTimes: $checkedConvert('launchTimes', (v) => v as int? ?? 1),
        );
        return val;
      },
    );

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) =>
    <String, dynamic>{
      'beta': instance.beta,
      'showWindowFab': instance.showWindowFab,
      'alwaysOnTop': instance.alwaysOnTop,
      'windowPosition': instance.windowPosition,
      'launchTimes': instance.launchTimes,
    };
