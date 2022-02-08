import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

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
  bool autoUpdate;
  TipsSetting tips;

  LocalSettings({
    this.beta = false,
    this.showWindowFab = true,
    this.showDebugFab = false,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 1,
    this.themeMode = ThemeMode.system,
    String? language,
    this.autoUpdate = true,
    TipsSetting? tips,
  })  : _language = language,
        tips = tips ?? TipsSetting();

  String? get language => _language;

  set language(String? v) {
    Intl.defaultLocale = _language = v;
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
