/// run in terminal [flutter packages pub run build_runner watch/build]
library model;

import 'package:chaldea/components/datatype/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'model.g.dart';

/// App settings and users data
@JsonSerializable()
class AppData {
  // setting page
  @JsonKey(defaultValue: LangCode.chs)
  String language = LangCode.chs;

  @JsonKey(defaultValue: [])
  List<String> galleries = [];

  String curUser;

  // users=[User,...]
  @JsonKey(defaultValue: <String, User>{})
  Map<String, User> users = <String, User>{};

  // functions, getters
  List<String> get userIDs=>users.keys.toList();

  AppData({this.language, this.galleries, this.curUser});

  // json_serializable
  factory AppData.fromJson(Map<String, dynamic> data) =>
      _$AppDataFromJson(data);

  Map<String, dynamic> toJson() => _$AppDataToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(nullable: false)
  String id;

  @JsonKey(defaultValue: 'cn')
  String server = 'cn';

  User({@required this.id, this.server});

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
