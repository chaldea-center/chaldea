part of datatypes;

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
  sprite,
  summon,
  voice,
  quest,
}

@JsonSerializable(checked: true)
class AppSetting {
  String? language;
  @JsonKey(unknownEnumValue: ThemeMode.system)
  ThemeMode? themeMode;
  bool? favoritePreferred;
  bool autoResetFilter;
  @JsonKey(unknownEnumValue: SvtListClassFilterStyle.auto)
  SvtListClassFilterStyle classFilterStyle;
  bool autoUpdateApp;
  bool autoUpdateDataset;
  bool autorotate;
  int downloadSource;
  bool svtPlanSliderMode;
  @JsonKey(unknownEnumValue: SvtTab.plan)
  List<SvtTab> sortedSvtTabs;
  Map<String, String> priorityTags;
  bool showAccountAtHome;

  AppSetting({
    this.language,
    this.themeMode,
    this.favoritePreferred,
    bool? autoResetFilter,
    int? downloadSource,
    bool? autoUpdateApp,
    bool? autoUpdateDataset,
    bool? autorotate,
    SvtListClassFilterStyle? classFilterStyle,
    bool? svtPlanSliderMode,
    List<SvtTab?>? sortedSvtTabs,
    Map<String, String>? priorityTags,
    bool? showAccountAtHome,
  })  : autoResetFilter = autoResetFilter ?? true,
        downloadSource = fixValidRange(downloadSource ?? GitSource.server.index,
            0, GitSource.values.length),
        autoUpdateApp = autoUpdateApp ?? true,
        autoUpdateDataset = autoUpdateDataset ?? true,
        autorotate = autorotate ?? false,
        classFilterStyle = classFilterStyle ?? SvtListClassFilterStyle.auto,
        svtPlanSliderMode = svtPlanSliderMode ?? false,
        sortedSvtTabs = sortedSvtTabs?.whereType<SvtTab>().toList() ??
            List.of(SvtTab.values),
        priorityTags = priorityTags ?? {},
        showAccountAtHome = showAccountAtHome ?? false {
    // gitee disabled
    if (this.downloadSource == 2) {
      this.downloadSource = 0;
    }
    validateSvtTabs();
  }

  void validateSvtTabs() {
    if (sortedSvtTabs.toSet().length != SvtTab.values.length) {
      sortedSvtTabs = List.of(SvtTab.values);
    }
  }

  GitSource get gitSource =>
      GitSource.values.getOrNull(downloadSource) ?? GitSource.values.first;

  bool get isResolvedDarkMode {
    return themeMode == ThemeMode.dark ||
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
  }

  factory AppSetting.fromJson(Map<String, dynamic> data) =>
      _$AppSettingFromJson(data);

  Map<String, dynamic> toJson() => _$AppSettingToJson(this);
}

@JsonSerializable(checked: true)
class CarouselSetting {
  int? updateTime;

  /// img_url: link, or text:link
  Map<String, String> urls;
  bool enabled;
  bool enableMooncell;
  bool enableJp;
  bool enableUs;
  @JsonKey(ignore: true)
  bool needUpdate = false;

  CarouselSetting({
    this.updateTime,
    Map<String, String>? urls,
    bool? enabled,
    bool? enableMooncell,
    bool? enableJp,
    bool? enableUs,
  })
      : urls = urls ?? {},
        enabled = enabled ?? true,
        enableMooncell = enableMooncell ?? true,
        enableJp = enableJp ?? true,
        enableUs = enableUs ?? true;

  bool get shouldUpdate {
    if (updateTime == null) return true;
    if (urls.isEmpty && (enableMooncell || enableJp || enableUs)) return true;
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
