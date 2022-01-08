import 'package:json_annotation/json_annotation.dart';

part 'local_settings.g.dart';

@JsonSerializable()
class LocalSettings {
  bool beta;
  bool showWindowFab;
  bool alwaysOnTop;
  List<int>? windowPosition;
  int launchTimes;

  LocalSettings({
    this.beta = false,
    this.showWindowFab = true,
    this.alwaysOnTop = false,
    this.windowPosition,
    this.launchTimes = 1,
  });

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);
}
