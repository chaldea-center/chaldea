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

  LocalSettings({
    this.beta = false,
    this.showWindowFab = true,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 1,
    this.themeMode,
    this.language,
  });

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);

  bool get isResolvedDarkMode {
    return themeMode == ThemeMode.dark ||
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
  }
}
