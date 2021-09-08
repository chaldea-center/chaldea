/// App settings and users data
part of datatypes;

@JsonSerializable(checked: true)
class UserData {
  static const int modelVersion = 2;

  final int version;

  // app settings
  AppSetting appSetting;
  CarouselSetting carouselSetting;
  Map<String, bool> galleries;

  // user-related game data
  String _curUserKey;
  Map<String, User> users;

  //filters, ItemFilterDat to be done
  SvtFilterData svtFilter;
  CraftFilterData craftFilter;
  CmdCodeFilterData cmdCodeFilter;
  SummonFilterData summonFilter;

  // glpk
  List<int> itemAbundantValue;

  UserData({
    int? version,
    AppSetting? appSetting,
    CarouselSetting? carouselSetting,
    Map<String, bool>? galleries,
    String? curUserKey,
    Map<String, User>? users,
    SvtFilterData? svtFilter,
    CraftFilterData? craftFilter,
    CmdCodeFilterData? cmdCodeFilter,
    SummonFilterData? summonFilter,
    List<int>? itemAbundantValue,
  })
      : version = modelVersion,
        appSetting = appSetting ?? AppSetting(),
        carouselSetting = carouselSetting ?? CarouselSetting(),
        galleries = galleries ?? {},
        _curUserKey = curUserKey ?? 'default',
        users = users ?? {},
        svtFilter = svtFilter ?? SvtFilterData(),
        craftFilter = craftFilter ?? CraftFilterData(),
        cmdCodeFilter = cmdCodeFilter ?? CmdCodeFilterData(),
        summonFilter = summonFilter ?? SummonFilterData(),
        itemAbundantValue =
            itemAbundantValue ?? List.generate(3, (index) => 0) {
    // not initiate language: auto-change language if not set yet.
    if (this.users.isEmpty) {
      String defaultName = 'default';
      this.users[defaultName] = User(name: defaultName);
    }
    if (!this.users.containsKey(_curUserKey)) {
      _curUserKey = this.users.keys.first;
    }
    this.users.forEach((key, value) {
      value.key = key;
    });
  }

  List<String> get userNames => users.values.map((user) => user.name).toList();

  String get curUserKey => _curUserKey;

  set curUserKey(String key) {
    if (users.containsKey(key)) {
      _curUserKey = key;
      db.gameData.updateUserDuplicatedServants();
      validate();
    }
  }

  User get curUser {
    if (users.isEmpty) {
      users['default'] = User(key: 'default', name: 'default');
    }
    if (!users.containsKey(curUserKey)) {
      curUserKey = users.keys.first;
    }
    return users[curUserKey]!;
  }

  void validate() {
    if (db.gameData.servants.isNotEmpty) {
      curUser.servants.removeWhere((key, value) =>
      db.gameData.unavailableSvts.contains(key) ||
          db.gameData.servantsWithUser[key] == null);
      curUser.servantPlans.forEach((plans) {
        plans.removeWhere((key, value) =>
        db.gameData.unavailableSvts.contains(key) ||
            db.gameData.servantsWithUser[key] == null);
      });
      curUser.crafts
          .removeWhere((key, value) => !const [0, 1, 2].contains(value));
    }
  }

  void resetFiltersIfNeed() {
    // can also call *.reset()
    if (appSetting.autoResetFilter) {
      svtFilter.reset();
      craftFilter.reset();
      cmdCodeFilter.reset();
    }
    if (appSetting.favoritePreferred != null) {
      svtFilter.favorite = appSetting.favoritePreferred! ? 1 : 0;
    }
  }

  factory UserData.fromJson(Map<String, dynamic> data) {
    final userData = _$UserDataFromJson(data);
    if (data['version'] == null || data['version'] == 1) {
      // 2021/08/03 support append skill unlock
      logger.d('appendSkill: convert v1 to v2');
      for (final user in userData.users.values) {
        for (final status in user.servants.values) {
          status.curVal.appendSkills =
              status.curVal.appendSkills.map((e) => e == 1 ? 0 : e).toList();
        }
        for (final svtPlans in user.servantPlans) {
          for (final plan in svtPlans.values) {
            plan.appendSkills =
                plan.appendSkills.map((e) => e == 1 ? 0 : e).toList();
          }
        }
      }
    }
    return userData;
  }

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
