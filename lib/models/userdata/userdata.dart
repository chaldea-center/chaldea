library userdata;

import 'package:json_annotation/json_annotation.dart';

part 'userdata.g.dart';

@JsonSerializable()
class UserData {
  String name;
  DateTime updated;

  UserData({required this.name, required this.updated});

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
