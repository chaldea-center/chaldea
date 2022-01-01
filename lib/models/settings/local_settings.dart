import 'package:json_annotation/json_annotation.dart';

part 'local_settings.g.dart';

@JsonSerializable()
class LocalSettings {
  bool beta;
  bool showWindowFab;

  LocalSettings({this.beta = false, this.showWindowFab = true});

  factory LocalSettings.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingsToJson(this);
}
