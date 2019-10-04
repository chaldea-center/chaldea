/// App settings and users data
part of datatypes;

@JsonSerializable()
class AppData {
  // setting page
  @JsonKey(defaultValue: LangCode.chs)
  String language;

  double criticalWidth;

  @JsonKey(defaultValue: 'dataset')
  String gameDataPath;

  @JsonKey(defaultValue: <String, bool>{})
  Map<String, bool> galleries;

  @JsonKey(defaultValue: 'default')
  String curUser;

  // users=[User,...]
  @JsonKey()
  Map<String, User> users = <String, User>{};

  // functions, getters
  List<String> get userIDs => users.values.map((u) => u.name).toList();

  AppData(
      {this.language = LangCode.chs,
      this.criticalWidth,
      this.curUser,
      this.users,
      this.galleries,
      this.gameDataPath = 'dataset'}) {
    curUser ??= 'default';
    users ??= {curUser: User(name: curUser)};
    galleries ??= {};
  }

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

  User({@required this.name, this.server = GameServer.cn});

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
