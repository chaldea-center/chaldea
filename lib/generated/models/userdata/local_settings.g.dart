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
          showDebugFab:
              $checkedConvert('showDebugFab', (v) => v as bool? ?? false),
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
          preferredRegions: $checkedConvert(
              'preferredRegions',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecode(_$RegionEnumMap, e))
                  .toList()),
          autoUpdateData:
              $checkedConvert('autoUpdateData', (v) => v as bool? ?? true),
          autoUpdateApp:
              $checkedConvert('autoUpdateApp', (v) => v as bool? ?? true),
          autoRotate: $checkedConvert('autoRotate', (v) => v as bool? ?? true),
          showAccountAtHome:
              $checkedConvert('showAccountAtHome', (v) => v as bool? ?? false),
          autoResetFilter:
              $checkedConvert('autoResetFilter', (v) => v as bool? ?? true),
          useProxy: $checkedConvert('useProxy', (v) => v as bool? ?? false),
          favoritePreferred:
              $checkedConvert('favoritePreferred', (v) => v as bool?),
          classFilterStyle: $checkedConvert(
              'classFilterStyle',
              (v) =>
                  $enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v) ??
                  SvtListClassFilterStyle.auto),
          onlyAppendSkillTwo:
              $checkedConvert('onlyAppendSkillTwo', (v) => v as bool? ?? true),
          sortedSvtTabs: $checkedConvert(
              'sortedSvtTabs',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecodeNullable(_$SvtTabEnumMap, e))
                  .toList()),
          priorityTags: $checkedConvert(
              'priorityTags',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as String),
                  )),
          galleries: $checkedConvert(
              'galleries',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e as bool),
                  )),
          carousel: $checkedConvert(
              'carousel',
              (v) => v == null
                  ? null
                  : CarouselSetting.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          tips: $checkedConvert(
              'tips',
              (v) => v == null
                  ? null
                  : TipsSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          svtFilterData: $checkedConvert(
              'svtFilterData',
              (v) => v == null
                  ? null
                  : SvtFilterData.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          craftFilterData: $checkedConvert(
              'craftFilterData',
              (v) => v == null
                  ? null
                  : CraftFilterData.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        $checkedConvert(
            'useAndroidExternal', (v) => val.useAndroidExternal = v as bool);
        return val;
      },
    );

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) =>
    <String, dynamic>{
      'beta': instance.beta,
      'showWindowFab': instance.showWindowFab,
      'showDebugFab': instance.showDebugFab,
      'alwaysOnTop': instance.alwaysOnTop,
      'windowPosition': instance.windowPosition,
      'launchTimes': instance.launchTimes,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'preferredRegions':
          instance.preferredRegions?.map((e) => _$RegionEnumMap[e]).toList(),
      'autoUpdateData': instance.autoUpdateData,
      'autoUpdateApp': instance.autoUpdateApp,
      'autoRotate': instance.autoRotate,
      'showAccountAtHome': instance.showAccountAtHome,
      'autoResetFilter': instance.autoResetFilter,
      'useProxy': instance.useProxy,
      'favoritePreferred': instance.favoritePreferred,
      'classFilterStyle':
          _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle],
      'onlyAppendSkillTwo': instance.onlyAppendSkillTwo,
      'sortedSvtTabs':
          instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]).toList(),
      'priorityTags':
          instance.priorityTags.map((k, e) => MapEntry(k.toString(), e)),
      'galleries': instance.galleries,
      'carousel': instance.carousel.toJson(),
      'tips': instance.tips.toJson(),
      'useAndroidExternal': instance.useAndroidExternal,
      'svtFilterData': instance.svtFilterData.toJson(),
      'craftFilterData': instance.craftFilterData.toJson(),
      'language': instance.language,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$RegionEnumMap = {
  Region.jp: 'jp',
  Region.cn: 'cn',
  Region.tw: 'tw',
  Region.na: 'na',
  Region.kr: 'kr',
};

const _$SvtListClassFilterStyleEnumMap = {
  SvtListClassFilterStyle.auto: 'auto',
  SvtListClassFilterStyle.singleRow: 'singleRow',
  SvtListClassFilterStyle.singleRowExpanded: 'singleRowExpanded',
  SvtListClassFilterStyle.twoRow: 'twoRow',
  SvtListClassFilterStyle.doNotShow: 'doNotShow',
};

const _$SvtTabEnumMap = {
  SvtTab.plan: 'plan',
  SvtTab.skill: 'skill',
  SvtTab.np: 'np',
  SvtTab.info: 'info',
  SvtTab.illustration: 'illustration',
  SvtTab.sprite: 'sprite',
  SvtTab.summon: 'summon',
  SvtTab.voice: 'voice',
  SvtTab.quest: 'quest',
};

CarouselSetting _$CarouselSettingFromJson(Map json) => $checkedCreate(
      'CarouselSetting',
      json,
      ($checkedConvert) {
        final val = CarouselSetting(
          updateTime: $checkedConvert('updateTime', (v) => v as int?),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CarouselItem.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
          enableMooncell:
              $checkedConvert('enableMooncell', (v) => v as bool? ?? true),
          enableJp: $checkedConvert('enableJp', (v) => v as bool? ?? true),
          enableUs: $checkedConvert('enableUs', (v) => v as bool? ?? true),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) =>
    <String, dynamic>{
      'updateTime': instance.updateTime,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'enabled': instance.enabled,
      'enableMooncell': instance.enableMooncell,
      'enableJp': instance.enableJp,
      'enableUs': instance.enableUs,
    };

CarouselItem _$CarouselItemFromJson(Map json) => $checkedCreate(
      'CarouselItem',
      json,
      ($checkedConvert) {
        final val = CarouselItem(
          image: $checkedConvert('image', (v) => v as String?),
          text: $checkedConvert('text', (v) => v as String?),
          link: $checkedConvert('link', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselItemToJson(CarouselItem instance) =>
    <String, dynamic>{
      'image': instance.image,
      'text': instance.text,
      'link': instance.link,
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
