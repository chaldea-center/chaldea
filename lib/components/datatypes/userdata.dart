/// App settings and users data
part of datatypes;

@JsonSerializable(checked: true)
class UserData {
  // app settings
  String? language;

  String? sliderUpdateTime;
  Map<String, String> sliderUrls;
  Map<String, bool> galleries;
  String? serverRoot;
  int updateSource;

  // user-related game data
  String curUserKey;

  Map<String, User> users;

  List<String> get userNames => users.values.map((user) => user.name).toList();

  //filters, ItemFilterDat to be done
  SvtFilterData svtFilter;
  CraftFilterData craftFilter;
  CmdCodeFilterData cmdCodeFilter;

  // glpk
  GLPKParams glpkParams;
  List<int> itemAbundantValue;

  UserData({
    this.language,
    this.sliderUpdateTime,
    Map<String, String>? sliderUrls,
    Map<String, bool>? galleries,
    this.serverRoot,
    int? updateSource,
    String? curUserKey,
    Map<String, User>? users,
    SvtFilterData? svtFilter,
    CraftFilterData? craftFilter,
    CmdCodeFilterData? cmdCodeFilter,
    GLPKParams? glpkParams,
    List<int>? itemAbundantValue,
  })  : sliderUrls = sliderUrls ?? {},
        galleries = galleries ?? {},
        updateSource =
            fixValidRange(updateSource ?? 0, 0, GitSource.values.length),
        curUserKey = curUserKey ?? 'default',
        users = users ?? {},
        svtFilter = svtFilter ?? SvtFilterData(),
        craftFilter = craftFilter ?? CraftFilterData(),
        cmdCodeFilter = cmdCodeFilter ?? CmdCodeFilterData(),
        glpkParams = glpkParams ?? GLPKParams(),
        itemAbundantValue =
            itemAbundantValue ?? List.generate(3, (index) => 0) {
    // not initiate language: auto-change language if not set yet.
    if (this.users.isEmpty) {
      String defaultName = 'default';
      this.users[defaultName] = User(name: defaultName);
    }
    if (!this.users.containsKey(curUserKey)) {
      this.curUserKey = this.users.keys.first;
    }
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
  FilterGroupData planCompletion;
  FilterGroupData skillLevel;
  FilterGroupData priority;
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
    int? favorite,
    List<SvtCompare>? sortKeys,
    List<bool>? sortReversed,
    bool? useGrid,
    bool? hasDress,
    FilterGroupData? planCompletion,
    FilterGroupData? skillLevel,
    FilterGroupData? priority,
    FilterGroupData? rarity,
    FilterGroupData? className,
    FilterGroupData? obtain,
    FilterGroupData? npColor,
    FilterGroupData? npType,
    FilterGroupData? attribute,
    FilterGroupData? alignment1,
    FilterGroupData? alignment2,
    FilterGroupData? gender,
    FilterGroupData? trait,
    FilterGroupData? traitSpecial,
  })  : filterString = '',
        favorite = favorite ?? 0,
        sortKeys = sortKeys ?? List.generate(3, (i) => sortKeyData[i]),
        sortReversed = sortReversed ?? List.generate(3, (index) => true),
        useGrid = useGrid ?? false,
        hasDress = hasDress ?? false,
        planCompletion = planCompletion ?? FilterGroupData(),
        skillLevel = skillLevel ?? FilterGroupData(),
        priority = priority ?? FilterGroupData(),
        rarity = rarity ?? FilterGroupData(),
        className = className ?? FilterGroupData(),
        obtain = obtain ?? FilterGroupData(),
        npColor = npColor ?? FilterGroupData(),
        npType = npType ?? FilterGroupData(),
        attribute = attribute ?? FilterGroupData(),
        alignment1 = alignment1 ?? FilterGroupData(),
        alignment2 = alignment2 ?? FilterGroupData(),
        gender = gender ?? FilterGroupData(),
        trait = trait ?? FilterGroupData(),
        traitSpecial = traitSpecial ?? FilterGroupData() {
    this.favorite = fixValidRange(this.favorite, 0, 2);
    fillListValue(this.sortKeys, 3, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 3, (_) => true);
  }

  List<FilterGroupData> get groupValues => [
        skillLevel,
        planCompletion,
        priority,
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
  static const List<String> planCompletionData = ['0', '1'];
  static const List<String> priorityData = ['1', '2', '3', '4', '5'];

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
    '活在当下的人类',
    '巨人',
    '孩童从者',
    '领域外生命',
    '鬼',
    '源氏'
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
    List<CraftCompare>? sortKeys,
    List<bool>? sortReversed,
    bool? useGrid,
    FilterGroupData? rarity,
    FilterGroupData? category,
    FilterGroupData? atkHpType,
  })  : filterString = '',
        sortKeys = sortKeys ?? List.generate(2, (index) => sortKeyData[index]),
        sortReversed = sortReversed ?? List.filled(2, true, growable: true),
        useGrid = useGrid ?? false,
        rarity = rarity ?? FilterGroupData(),
        category = category ?? FilterGroupData(),
        atkHpType = atkHpType ?? FilterGroupData() {
    fillListValue(this.sortKeys, 2, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 2, (_) => true);
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
    List<CmdCodeCompare>? sortKeys,
    List<bool>? sortReversed,
    bool? useGrid,
    FilterGroupData? rarity,
    FilterGroupData? category,
  })  : filterString = '',
        sortKeys = sortKeys ?? List.generate(2, (index) => sortKeyData[index]),
        sortReversed = sortReversed ?? List.filled(2, true, growable: true),
        useGrid = useGrid ?? false,
        rarity = rarity ?? FilterGroupData(),
        category = category ?? FilterGroupData() {
    fillListValue(this.sortKeys, 2, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 2, (_) => true);
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

typedef bool? CompareFilterKeyCallback(String option, String? value);

@JsonSerializable(checked: true)
class FilterGroupData {
  bool matchAll;
  bool invert;
  Map<String, bool> options;

  FilterGroupData({
    bool? matchAll,
    bool? invert,
    Map<String, bool>? options,
  })  : matchAll = matchAll ?? false,
        invert = invert ?? false,
        options = options ?? {};

  void reset() {
    options.clear();
    matchAll = false;
    invert = false;
  }

  bool _customCompare(String _optionKey, String? _srcKey,
      [CompareFilterKeyCallback? _compare]) {
    return _compare == null
        ? _optionKey == _srcKey
        : _compare(_optionKey, _srcKey) ?? false;
  }

  bool singleValueFilter(String? value,
      {CompareFilterKeyCallback? compare,
      Map<String, CompareFilterKeyCallback>? compares}) {
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
        if (_customCompare(option, value, compare ?? compares![option])) {
          result = true;
          break;
        }
      }
    } else {
      result = options.containsKey(value);
    }
    return invert ? !result : result;
  }

  bool listValueFilter(List<String> values,
      {Map<String, CompareFilterKeyCallback>? compares}) {
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
            .map((v) => _customCompare(option, v, compares![option]))
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
            .map((v) => _customCompare(option, v, compares![option]))
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
