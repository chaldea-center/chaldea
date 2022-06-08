import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:intl/intl.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import '../../packages/language.dart';
import '_helper.dart';
import 'filter_data.dart';
import 'userdata.dart';

export 'filter_data.dart';

part '../../generated/models/userdata/local_settings.g.dart';

@JsonSerializable()
class LocalSettings {
  bool beta;
  bool showDebugFab;
  bool alwaysOnTop;
  List<int>? windowPosition;
  int launchTimes;
  int lastBackup;
  ThemeMode themeMode;
  String? _language;
  List<Region>? preferredRegions;
  bool autoUpdateData; // dataset
  bool autoUpdateApp;
  bool proxyServer;
  bool autoRotate;
  bool autoResetFilter;
  bool hideUnreleasedCard;
  FavoriteState? favoritePreferred;
  bool preferApRate;
  Region? preferredQuestRegion;

  Map<int, String> priorityTags;
  Map<String, bool> galleries;
  DisplaySettings display;
  CarouselSetting carousel;
  GithubSetting github;
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
    this.showDebugFab = false,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 0,
    this.lastBackup = 0,
    this.themeMode = ThemeMode.system,
    String? language,
    List<Region>? preferredRegions,
    this.autoUpdateData = true,
    this.proxyServer = false,
    this.autoUpdateApp = true,
    this.autoRotate = true,
    this.autoResetFilter = true,
    this.hideUnreleasedCard = false,
    this.favoritePreferred,
    this.preferApRate = true,
    this.preferredQuestRegion,
    Map<int, String>? priorityTags,
    Map<String, bool>? galleries,
    DisplaySettings? display,
    CarouselSetting? carousel,
    GithubSetting? github,
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
        github = github ?? GithubSetting(),
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
        return [Region.jp, Region.na, Region.cn, Region.tw, Region.kr];
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
  bool showWindowFab;
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
  List<SvtPlanDetail> hideSvtPlanDetails;

  DisplaySettings({
    this.showAccountAtHome = true,
    this.showWindowFab = true,
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
    List<SvtPlanDetail?>? hideSvtPlanDetails,
  })  : sortedSvtTabs = sortedSvtTabs?.whereType<SvtTab>().toList() ??
            List.of(SvtTab.values),
        hideSvtPlanDetails =
            hideSvtPlanDetails?.whereType<SvtPlanDetail>().toList() ?? [] {
    validateSvtTabs();
  }
  void validateSvtTabs() {
    sortedSvtTabs = List.of(SvtTab.values)
      ..sort2((a) {
        int index = sortedSvtTabs.indexOf(a);
        return index >= 0 ? index : SvtTab.values.indexOf(a);
      });
    hideSvtPlanDetails.remove(SvtPlanDetail.activeSkill);
    hideSvtPlanDetails.remove(SvtPlanDetail.appendSkill);
  }

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

@JsonSerializable()
class GithubSetting {
  String owner;
  String repo;
  String path;
  @JsonKey(fromJson: _readToken, toJson: _writeToken)
  String token;
  String branch;
  String? sha;
  bool indent;

  GithubSetting({
    this.owner = '',
    this.repo = '',
    this.path = '',
    this.token = '',
    this.branch = '',
    this.sha,
    this.indent = false,
  });

  factory GithubSetting.fromJson(Map<String, dynamic> data) =>
      _$GithubSettingFromJson(data);

  Map<String, dynamic> toJson() => _$GithubSettingToJson(this);

  static String _writeToken(String token) {
    return base64Encode(utf8.encode(token).reversed.toList());
  }

  static String _readToken(String token) {
    return utf8.decode(base64Decode(token).reversed.toList());
  }
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
  lore,
  illustration,
  relatedCards,
  summon,
  voice,
  quest,
}

enum SvtPlanDetail {
  ascension,
  activeSkill,
  appendSkill,
  costume,
  coin,
  grail,
  noblePhantasm,
  fou4,
  fou3,
  bondLimit,
  commandCode,
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
