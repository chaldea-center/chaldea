import 'package:chaldea/generated/l10n.dart';
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
  bool autoResetFilter;
  bool useProxy;
  FavoriteState? favoritePreferred;
  bool preferApRate;

  Map<int, String> priorityTags;
  Map<String, bool> galleries;
  DisplaySettings display;
  CarouselSetting carousel;
  TipsSetting tips;

  // TODO: move to persist storage
  bool useAndroidExternal = false;

  // filters
  SvtFilterData svtFilterData;
  CraftFilterData craftFilterData;
  CmdCodeFilterData cmdCodeFilterData;
  SummonFilterData summonFilterData;

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
    this.autoResetFilter = true,
    this.useProxy = false,
    this.favoritePreferred,
    this.preferApRate = true,
    Map<int, String>? priorityTags,
    Map<String, bool>? galleries,
    DisplaySettings? display,
    CarouselSetting? carousel,
    TipsSetting? tips,
    SvtFilterData? svtFilterData,
    CraftFilterData? craftFilterData,
    CmdCodeFilterData? cmdCodeFilterData,
    SummonFilterData? summonFilterData,
  })  : _language = language,
        preferredRegions = preferredRegions == null
            ? null
            : (List.of(Region.values)
              ..sort2(
                  (e) => preferredRegions.indexOf(e) % Region.values.length)),
        priorityTags = priorityTags ?? {},
        galleries = galleries ?? {},
        display = display ?? DisplaySettings(),
        carousel = carousel ?? CarouselSetting(),
        tips = tips ?? TipsSetting(),
        svtFilterData = svtFilterData ?? SvtFilterData(),
        craftFilterData = craftFilterData ?? CraftFilterData(),
        cmdCodeFilterData = cmdCodeFilterData ?? CmdCodeFilterData(),
        summonFilterData = summonFilterData ?? SummonFilterData();

  String? get language => _language;

  Future<S> setLanguage(Language lang) {
    _language = Intl.defaultLocale = lang.code;
    return S.load(lang.locale, override: true);
  }

  List<Region> get resolvedPreferredRegions {
    if (preferredRegions != null && preferredRegions!.isNotEmpty) {
      return preferredRegions!;
    }
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
    display.sortedSvtTabs = List.of(SvtTab.values)
      ..sort2((a) => display.sortedSvtTabs.indexOf(a));
  }

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);

  bool get isResolvedDarkMode {
    if (themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }
}

@JsonSerializable()
class DisplaySettings {
  bool showAccountAtHome;
  SvtPlanInputMode svtPlanInputMode;
  ItemDetailViewType itemDetailViewType;
  ItemDetailSvtSort itemDetailSvtSort;
  bool itemQuestsSortByAp;
  bool autoTurnOnPlanNotReach = false;
  SvtListClassFilterStyle classFilterStyle;
  bool onlyAppendSkillTwo;
  bool planPageFullScreen = false;
  bool eventsShowOutdated;
  bool eventsReversed;
  List<SvtTab> sortedSvtTabs;

  DisplaySettings({
    this.showAccountAtHome = false,
    this.svtPlanInputMode = SvtPlanInputMode.dropdown,
    this.itemDetailViewType = ItemDetailViewType.separated,
    this.itemDetailSvtSort = ItemDetailSvtSort.collectionNo,
    this.itemQuestsSortByAp = true,
    this.autoTurnOnPlanNotReach = false,
    this.classFilterStyle = SvtListClassFilterStyle.auto,
    this.onlyAppendSkillTwo = true,
    this.planPageFullScreen = false,
    this.eventsShowOutdated = false,
    this.eventsReversed = true,
    List<SvtTab?>? sortedSvtTabs,
  }) : sortedSvtTabs = sortedSvtTabs?.whereType<SvtTab>().toList() ??
            List.of(SvtTab.values);

  factory DisplaySettings.fromJson(Map<String, dynamic> data) =>
      _$DisplaySettingsFromJson(data);

  Map<String, dynamic> toJson() => _$DisplaySettingsToJson(this);
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

enum ItemDetailViewType {
  separated,
  grid,
  list,
}

enum ItemDetailSvtSort {
  collectionNo,
  clsName,
  rarity,
}
