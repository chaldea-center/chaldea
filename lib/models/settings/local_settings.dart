import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_settings.g.dart';

@JsonSerializable()
class LocalSettings {
  bool beta;
  bool showWindowFab;
  bool alwaysOnTop;
  List<int>? windowPosition;
  int launchTimes;
  @JsonKey(unknownEnumValue: ThemeMode.system)
  ThemeMode? themeMode;
  String? language;
  TipsSetting tips;

  LocalSettings({
    this.beta = false,
    this.showWindowFab = true,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 1,
    this.themeMode,
    this.language,
    TipsSetting? tips,
  }) : tips = tips ?? TipsSetting();

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);

  bool get isResolvedDarkMode {
    return themeMode == ThemeMode.dark ||
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
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
