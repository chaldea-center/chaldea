// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/local_settings.dart';

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
          themeMode: $checkedConvert(
              'themeMode',
              (v) =>
                  $enumDecodeNullable(_$ThemeModeEnumMap, v) ??
                  ThemeMode.system),
          language: $checkedConvert('language', (v) => v as String?),
          autoUpdate: $checkedConvert('autoUpdate', (v) => v as bool? ?? true),
          tips: $checkedConvert(
              'tips',
              (v) => v == null
                  ? null
                  : TipsSetting.fromJson(Map<String, dynamic>.from(v as Map))),
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
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'autoUpdate': instance.autoUpdate,
      'tips': instance.tips.toJson(),
      'language': instance.language,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

TipsSetting _$TipsSettingFromJson(Map json) => $checkedCreate(
      'TipsSetting',
      json,
      ($checkedConvert) {
        final val = TipsSetting(
          starter: $checkedConvert('starter', (v) => v as bool? ?? true),
          servantList: $checkedConvert('servantList', (v) => v as int? ?? 2),
          servantDetail:
              $checkedConvert('servantDetail', (v) => v as int? ?? 2),
        );
        return val;
      },
    );

Map<String, dynamic> _$TipsSettingToJson(TipsSetting instance) =>
    <String, dynamic>{
      'starter': instance.starter,
      'servantList': instance.servantList,
      'servantDetail': instance.servantDetail,
    };
