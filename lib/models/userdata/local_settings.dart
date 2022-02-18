import 'package:chaldea/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../../packages/language.dart';
import '_helper.dart';
import 'filter_data.dart';
import 'userdata.dart';

export 'filter_data.dart';

part '../../generated/models/userdata/local_settings.g.dart';

@JsonSerializable()
class LocalSettings {
  bool beta;
  bool showWindowFab;
  bool showDebugFab;
  bool alwaysOnTop;
  List<int>? windowPosition;
  int launchTimes;
  ThemeMode themeMode;
  String? _language;
  List<Region>? preferredRegions;
  bool autoUpdateData; // dataset
  bool autoUpdateApp;
  bool autoRotate;
  bool showAccountAtHome;
  bool autoResetFilter;
  bool useProxy;
  FavoriteState? favoritePreferred;
  SvtListClassFilterStyle classFilterStyle;
  bool onlyAppendSkillTwo;
  bool planPageFullScreen = false;
  SvtPlanInputMode svtPlanInputMode;

  List<SvtTab> sortedSvtTabs;
  Map<int, String> priorityTags;
  Map<String, bool> galleries;
  CarouselSetting carousel;
  TipsSetting tips;

  // TODO: move to persist storage
  bool useAndroidExternal = false;

  // filters
  SvtFilterData svtFilterData;
  CraftFilterData craftFilterData;

  LocalSettings({
    this.beta = false,
    this.showWindowFab = true,
    this.showDebugFab = false,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 1,
    this.themeMode = ThemeMode.system,
    String? language,
    List<Region>? preferredRegions,
    this.autoUpdateData = true,
    this.autoUpdateApp = true,
    this.autoRotate = true,
    this.showAccountAtHome = false,
    this.autoResetFilter = true,
    this.useProxy = false,
    this.favoritePreferred,
    this.classFilterStyle = SvtListClassFilterStyle.auto,
    this.onlyAppendSkillTwo = true,
    this.planPageFullScreen = false,
    this.svtPlanInputMode = SvtPlanInputMode.dropdown,
    List<SvtTab?>? sortedSvtTabs,
    Map<int, String>? priorityTags,
    Map<String, bool>? galleries,
    CarouselSetting? carousel,
    TipsSetting? tips,
    SvtFilterData? svtFilterData,
    CraftFilterData? craftFilterData,
  })  : _language = language,
        preferredRegions = preferredRegions == null
            ? null
            : (List.of(Region.values)
              ..sort2(
                  (e) => preferredRegions.indexOf(e) % Region.values.length)),
        sortedSvtTabs = sortedSvtTabs?.whereType<SvtTab>().toList() ??
            List.of(SvtTab.values),
        priorityTags = priorityTags ?? {},
        galleries = galleries ?? {},
        carousel = carousel ?? CarouselSetting(),
        tips = tips ?? TipsSetting(),
        svtFilterData = svtFilterData ?? SvtFilterData(),
        craftFilterData = craftFilterData ?? CraftFilterData();

  String? get language => _language;

  set language(String? v) {
    Intl.defaultLocale = _language = v;
  }

  List<Region> get resolvedPreferredRegions {
    if (preferredRegions != null) return preferredRegions!;
    switch (Language.getLanguage(_language)) {
      case Language.jp:
        return [Region.jp, Region.cn, Region.na, Region.tw, Region.kr];
      case Language.chs:
        return [Region.cn, Region.tw, Region.jp, Region.na, Region.kr];
      case Language.cht:
        return [Region.tw, Region.cn, Region.jp, Region.na, Region.kr];
      case Language.ko:
        return [Region.kr, Region.na, Region.jp, Region.cn, Region.tw];
      default:
        return [Region.na, Region.jp, Region.cn, Region.tw, Region.kr];
    }
  }

  void validateSvtTabs() {
    sortedSvtTabs = List.of(SvtTab.values)
      ..sort((a, b) =>
          (sortedSvtTabs.indexOf(a)).compareTo(sortedSvtTabs.indexOf(b)));
  }

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);

  bool get isResolvedDarkMode {
    if (themeMode == ThemeMode.system) {
      return SchedulerBinding.instance!.window.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }
}

@JsonSerializable()
class CarouselSetting {
  int? updateTime;

  /// img_url: link, or text:link
  List<CarouselItem> items;
  bool enabled;
  bool enableMooncell;
  bool enableJp;
  bool enableUs;
  @JsonKey(ignore: true)
  bool needUpdate = false;

  CarouselSetting({
    this.updateTime,
    List<CarouselItem>? items,
    this.enabled = true,
    this.enableMooncell = true,
    this.enableJp = true,
    this.enableUs = true,
  }) : items = items ?? [];

  bool get shouldUpdate {
    if (updateTime == null) return true;
    if (items.isEmpty && (enableMooncell || enableJp || enableUs)) return true;
    DateTime lastTime =
            DateTime.fromMillisecondsSinceEpoch(updateTime! * 1000).toUtc(),
        now = DateTime.now().toUtc();
    int hours = now.difference(lastTime).inHours;
    if (hours > 24 || hours < 0) return true;
    // update at 17:00(+08), 18:00(+09) => 9:00(+00)
    int hour = (9 - lastTime.hour) % 24 + lastTime.hour;
    final time1 =
        DateTime.utc(lastTime.year, lastTime.month, lastTime.day, hour, 10);
    if (now.isAfter(time1)) return true;
    return false;
  }

  factory CarouselSetting.fromJson(Map<String, dynamic> data) =>
      _$CarouselSettingFromJson(data);

  Map<String, dynamic> toJson() => _$CarouselSettingToJson(this);
}

@JsonSerializable()
class CarouselItem {
  String? image;
  String? text;
  String? link;
  @JsonKey(ignore: true)
  BoxFit? fit;

  CarouselItem({
    this.image,
    this.text,
    this.link,
    this.fit,
  });

  factory CarouselItem.fromJson(Map<String, dynamic> data) =>
      _$CarouselItemFromJson(data);

  Map<String, dynamic> toJson() => _$CarouselItemToJson(this);
}

/// true: should should show
/// n>0: show tips after n times entrance
/// n<=0: don't show tips
@JsonSerializable()
class TipsSetting {
  bool starter;
  int servantList;
  int servantDetail;

  TipsSetting({
    this.starter = true,
    this.servantList = 2,
    this.servantDetail = 2,
  });

  factory TipsSetting.fromJson(Map<String, dynamic> json) =>
      _$TipsSettingFromJson(json);

  Map<String, dynamic> toJson() => _$TipsSettingToJson(this);
}

enum SvtListClassFilterStyle {
  auto,
  singleRow,
  singleRowExpanded, // scrollable
  twoRow,
  doNotShow,
}
enum SvtTab {
  plan,
  skill,
  np,
  info,
  illustration,
  relatedCards,
  summon,
  voice,
  quest,
}

enum SvtPlanInputMode { dropdown, slider, input }
