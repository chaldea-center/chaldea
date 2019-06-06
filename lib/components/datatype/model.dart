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
  String language ;

  @JsonKey(defaultValue: <String,bool>{})
  Map<String,bool> galleries;

  String curUser;

  // users=[User,...]
  @JsonKey(defaultValue: <String, User>{})
  Map<String, User> users = <String, User>{};

  // functions, getters
  List<String> get userIDs=>users.values.map((u)=>u.name).toList();

  AppData({this.language= LangCode.chs, this.galleries, this.curUser});

  // json_serializable
  factory AppData.fromJson(Map<String, dynamic> data) =>
      _$AppDataFromJson(data);

  Map<String, dynamic> toJson() => _$AppDataToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(nullable: false)
  String name;

  @JsonKey(defaultValue: GameServer.cn)
  String server;

  User({@required this.name, this.server=GameServer.cn});

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
