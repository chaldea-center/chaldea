/// App settings and users data
part of datatypes;

@JsonSerializable(checked: true)
class UserData {
  // app settings
  String language;

  bool useMobileNetwork;
  String sliderUpdateTime;
  Map<String, String> sliderUrls;
  Map<String, bool> galleries;
  String serverDomain;
  String previousAppVersion;

  // user-related game data
  String curUserKey;
  Map<String, User> users;

  List<String> get userNames => users.values.map((user) => user.name).toList();

  //test
  @JsonKey(ignore: true)
  double criticalWidth;
  bool testAllowDownload;

  //filters, ItemFilterDat to be done
  SvtFilterData svtFilter;
  CraftFilterData craftFilter;
  CmdCodeFilterData cmdCodeFilter;

  // glpk
  GLPKParams glpkParams;
  List<int> itemAbundantValue;

  @JsonKey(ignore: true)
  StreamController<UserData> onUserUpdated = StreamController.broadcast();

  void broadcastUserUpdate() {
    onUserUpdated.sink.add(this);
  }

  void dispose() {
    onUserUpdated.close();
  }

  UserData({
    this.language,
    this.criticalWidth,
    this.useMobileNetwork,
    this.testAllowDownload,
    this.sliderUpdateTime,
    this.sliderUrls,
    this.galleries,
    this.serverDomain,
    this.previousAppVersion,
    this.curUserKey,
    this.users,
    this.svtFilter,
    this.craftFilter,
    this.cmdCodeFilter,
    this.glpkParams,
    this.itemAbundantValue,
  }) {
    // not initiate language: auto-change language if not set yet.
    String defaultName = 'default';
    useMobileNetwork ??= false;
    testAllowDownload ??= true;
    sliderUrls ??= {};
    galleries ??= {};
    serverDomain ??= kServerRoot;
    users ??= {defaultName: User(name: defaultName)};
    if (!users.containsKey(curUserKey)) {
      curUserKey = users.keys.first;
    }
    svtFilter ??= SvtFilterData();
    craftFilter ??= CraftFilterData();
    cmdCodeFilter ??= CmdCodeFilterData();
    glpkParams ??= GLPKParams();
    itemAbundantValue ??= [0, 0, 0];
  }

  // json_serializable
  factory UserData.fromJson(Map<String, dynamic> data) =>
      _$UserDataFromJson(data);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable(checked: true)
class SvtFilterData {
  /// 0-all, 1-fav, 2-not fav
  int favorite;
  String filterString;
  List<SvtCompare> sortKeys;
  List<bool> sortReversed;
  bool useGrid;

  bool hasDress;
  FilterGroupData skillLevel;
  FilterGroupData rarity;
  FilterGroupData className;
  FilterGroupData obtain;
  FilterGroupData npColor;
  FilterGroupData npType;
  FilterGroupData attribute;
  FilterGroupData alignment1;
  FilterGroupData alignment2;
  FilterGroupData gender;
  FilterGroupData trait;
  FilterGroupData traitSpecial;

  SvtFilterData({
    this.favorite,
    this.sortKeys,
    this.sortReversed,
    this.useGrid,
    this.hasDress,
    this.skillLevel,
    this.rarity,
    this.className,
    this.obtain,
    this.npColor,
    this.npType,
    this.attribute,
    this.alignment1,
    this.alignment2,
    this.gender,
    this.trait,
    this.traitSpecial,
  }) {
    favorite ??= null; //null-all,false-not fav,true-fav
    filterString ??= '';
    sortKeys ??= List.generate(3, (i) => sortKeyData[i]);
    sortReversed ??= List.filled(sortKeys.length, true);
    useGrid ??= false;
    hasDress ??= false;
    skillLevel ??= FilterGroupData();
    rarity ??= FilterGroupData();
    className ??= FilterGroupData();
    obtain ??= FilterGroupData();
    npColor ??= FilterGroupData();
    npType ??= FilterGroupData();
    attribute ??= FilterGroupData();
    alignment1 ??= FilterGroupData();
    alignment2 ??= FilterGroupData();
    gender ??= FilterGroupData();
    trait ??= FilterGroupData();
    traitSpecial ??= FilterGroupData();
  }

  List<FilterGroupData> get groupValues => [
        skillLevel,
        rarity,
        className,
        obtain,
        npColor,
        npType,
        attribute,
        alignment1,
        alignment2,
        gender,
        trait,
        traitSpecial
      ];

  void reset() {
    // sortKeys = List.generate(sortKeys.length, (i) => sortKeyData[i]);
    // sortReversed = List.filled(sortKeys.length, false);
    hasDress = false;
    for (var group in groupValues) {
      group.reset();
    }
  }

  // const data
  static const List<SvtCompare> sortKeyData = SvtCompare.values;
  static const List<String> skillLevelData = ['<999', '≥999', '310'];
  static const List<String> rarityData = ['0', '1', '2', '3', '4', '5'];
  static const List<String> classesData = [
    'Saber',
    'Archer',
    'Lancer',
    'Rider',
    'Caster',
    'Assassin',
    'Berserker',
    'Ruler',
    'Avenger',
    'Alterego',
    'MoonCancer',
    'Foreigner',
    'Shielder',
    'Beast'
  ];
  static const List<String> obtainData = [
    '剧情',
    '活动',
    '无法召唤',
    '常驻',
    '限定',
    '友情点召唤'
  ];
  static const npColorData = ['Quick', 'Arts', 'Buster'];
  static const npTypeData = ['单体', '全体', '辅助'];
  static const attributeData = ['天', '地', '人', '星', '兽'];
  static const alignment1Data = ['秩序', '混沌', '中立'];
  static const alignment2Data = ['善', '恶', '中庸', '新娘', '狂', '夏'];
  static const genderData = ['男性', '女性', '其他'];
  static const traitData = [
    '龙',
    '骑乘',
    '神性',
    '猛兽',
    '王',
    '罗马',
    '亚瑟',
    '阿尔托莉雅脸',
    '所爱之人',
    '希腊神话男性',
    '人类的威胁',
    '阿尔戈号的相关者',
    '魔性',
    '超巨大',
    '天地(拟似除外)',
    '人科',
    '魔兽型',
    '活在当下的人类'
  ];
  static const traitSpecialData = ['EA不特攻', '无特殊特性'];

  // json_serializable
  factory SvtFilterData.fromJson(Map<String, dynamic> data) =>
      _$SvtFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtFilterDataToJson(this);
}

@JsonSerializable(checked: true)
class CraftFilterData {
  String filterString;
  List<CraftCompare> sortKeys;
  List<bool> sortReversed;
  bool useGrid;

  FilterGroupData rarity;
  FilterGroupData category;
  FilterGroupData atkHpType;

  CraftFilterData({
    this.sortKeys,
    this.sortReversed,
    this.useGrid,
    this.rarity,
    this.category,
    this.atkHpType,
  }) {
    filterString ??= '';
    sortKeys ??= List.generate(2, (i) => sortKeyData[i]);
    sortReversed ??= List.filled(sortKeys.length, true);
    useGrid ??= false;
    rarity ??= FilterGroupData();
    category ??= FilterGroupData();
    atkHpType ??= FilterGroupData();
  }

  List<FilterGroupData> get groupValues => [
        rarity,
        category,
        atkHpType,
      ];

  void reset() {
    // sortKeys = List.generate(sortKeys.length, (i) => sortKeyData[i]);
    // sortReversed = List.filled(sortKeys.length, false);
    for (var group in groupValues) {
      group.reset();
    }
  }

  // const data
  static const List<CraftCompare> sortKeyData = CraftCompare.values;
  static const List<String> rarityData = ['1', '2', '3', '4', '5'];

  // category: bin: 0b1111111111
  static const List<String> categoryData = [
    '兑换',
    '活动奖励',
    'EXP卡',
    '剧情限定',
    '情人节',
    '羁绊',
    '纪念',
    '卡池常驻',
    '期间限定'
  ];
  static const atkHpTypeData = ['NONE', 'HP', 'ATK', 'MIX'];

  // json_serializable
  factory CraftFilterData.fromJson(Map<String, dynamic> data) =>
      _$CraftFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CraftFilterDataToJson(this);
}

@JsonSerializable(checked: true)
class CmdCodeFilterData {
  String filterString;
  List<CmdCodeCompare> sortKeys;
  List<bool> sortReversed;
  bool useGrid;

  FilterGroupData rarity;
  FilterGroupData category;

  CmdCodeFilterData({
    this.sortKeys,
    this.sortReversed,
    this.useGrid,
    this.rarity,
    this.category,
  }) {
    filterString ??= '';
    sortKeys ??= List.generate(2, (i) => sortKeyData[i]);
    sortReversed ??= List.filled(sortKeys.length, true);
    useGrid ??= false;
    rarity ??= FilterGroupData();
    category ??= FilterGroupData();
  }

  List<FilterGroupData> get groupValues => [rarity, category];

  void reset() {
    // sortKeys = List.generate(sortKeys.length, (i) => sortKeyData[i]);
    // sortReversed = List.filled(sortKeys.length, false);
    for (var group in groupValues) {
      group.reset();
    }
  }

  // const data
  static const List<CmdCodeCompare> sortKeyData = CmdCodeCompare.values;
  static const List<String> rarityData = ['1', '2', '3', '4', '5'];

  // category: bin: 0b1111111111
  static const List<String> categoryData = ['友情池常驻', '活动奖励'];

  // json_serializable
  factory CmdCodeFilterData.fromJson(Map<String, dynamic> data) =>
      _$CmdCodeFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CmdCodeFilterDataToJson(this);
}

typedef bool CompareFilterKeyCallback(String option, String value);

@JsonSerializable(checked: true)
class FilterGroupData {
  bool matchAll;
  bool invert;
  Map<String, bool> options;

  FilterGroupData({this.matchAll, this.invert, this.options}) {
    matchAll ??= false;
    invert ??= false;
    options ??= {};
  }

  void reset() {
    options.clear();
    matchAll = false;
    invert = false;
  }

  bool _customCompare(
      String _optionKey, String _srcKey, CompareFilterKeyCallback _compare) {
    return _compare == null
        ? _optionKey == _srcKey
        : _compare(_optionKey, _srcKey);
  }

  bool singleValueFilter(String value,
      {CompareFilterKeyCallback compare,
      Map<String, CompareFilterKeyCallback> compares}) {
    // ignore matchAll?
    assert(compare == null || compares == null);
    options.removeWhere((k, v) => v != true);
    if (options.isEmpty) {
      return true;
    }
    bool result;
    if (compare != null || compares != null) {
      result = false;
      for (var option in options.keys) {
        if (_customCompare(option, value, compare ?? compares[option])) {
          result = true;
          break;
        }
      }
    }else{
      result = options.containsKey(value);
    }
    return invert ? !result : result;
  }

  bool listValueFilter(List<String> values,
      {Map<String, CompareFilterKeyCallback> compares}) {
    compares ??= {};
    options.removeWhere((k, v) => v != true);
    if (options.isEmpty) {
      return true;
    }
    bool result;
    if (matchAll) {
      result = true;
      for (String option in options.keys) {
        List<bool> tmp = values
            .map((v) => _customCompare(option, v, compares[option]))
            .toList();
        if (!tmp.contains(true)) {
          result = false;
          break;
        }
      }
    } else {
      result = false;
      for (String option in options.keys) {
        List<bool> tmp = values
            .map((v) => _customCompare(option, v, compares[option]))
            .toList();
        if (tmp.contains(true)) {
          result = true;
          break;
        }
      }
    }
    return invert ? !result : result;
  }

  factory FilterGroupData.fromJson(Map<String, dynamic> data) =>
      _$FilterGroupDataFromJson(data);

  Map<String, dynamic> toJson() => _$FilterGroupDataToJson(this);

  @override
  String toString() {
    return 'FilterGroupData(matchAll=$matchAll, invert=$invert, options=$options)';
  }
}
