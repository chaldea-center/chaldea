/// App settings and users data
part of datatypes;

@JsonSerializable()
class UserData {
  // app settings
  String language;
  double criticalWidth;
  String gameDataPath;
  bool useMobileNetwork;
  Map<String, String> sliderUrls;
  Map<String, bool> galleries;

  // user-related game data
  String curUserName;
  Map<String, User> users;

  //filters, ItemFilterDat to be done
  SvtFilterData svtFilter;
  SvtFilterData itemFilter;

  UserData(
      {this.language,
      this.criticalWidth,
      this.gameDataPath,
      this.sliderUrls,
      this.galleries,
      this.curUserName,
      this.users,
      this.svtFilter}) {
    // not initiate language: auto-change language if not set yet.
    String defaultName = 'default';
    gameDataPath ??= 'dataset';
    sliderUrls ??= {};
    galleries ??= {};
    users ??= {defaultName: User(name: defaultName)};
    if (!users.containsKey(curUserName)) {
      curUserName = users.keys.first;
    }
    svtFilter ??= SvtFilterData();
  }

  // json_serializable
  factory UserData.fromJson(Map<String, dynamic> data) =>
      _$UserDataFromJson(data);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class SvtFilterData {
  bool favorite;
  String filterString;
  List<String> sortKeys;
  List<bool> sortDirections;
  bool useGrid;

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

  SvtFilterData(
      {this.favorite,
      this.sortKeys,
      this.sortDirections,
      this.useGrid,
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
      this.traitSpecial}) {
    favorite ??= false;
    filterString ??= '';
    sortKeys ??= List.generate(3, (i) => sortKeyData[i]);
    sortDirections ??= List.filled(sortKeys.length, true);
    useGrid ??= false;
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
    sortKeys = List.generate(2, (i) => sortKeyData[i]);
    sortDirections = List.filled(sortKeys.length, false);

    for (var group in groupValues) {
      group.reset();
    }
  }

  // const data
  static const List<String> sortKeyData = ['序号', '星级', '职阶'];
  static const List<String> rarityData = const ['0', '1', '2', '3', '4', '5'];
  static const List<String> classesData = [
    'Saber',
    'Archer',
    'Lancer',
    'Rider',
    'Caster',
    'Assassin',
    'Berserker',
    'Shielder',
    'Ruler',
    'Avenger',
    'Alterego',
    'MoonCancer',
    'Foreigner',
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
    '拟似/亚从者'
  ];
  static const traitSpecialData = ['EA不特攻', '无特殊特性'];

  // json_serializable
  factory SvtFilterData.fromJson(Map<String, dynamic> data) =>
      _$SvtFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtFilterDataToJson(this);
}

typedef bool CompareFilterKeyCallback(String option, String value);

@JsonSerializable()
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
  }

  bool _customCompare(
      String _optionKey, String _srcKey, CompareFilterKeyCallback _compare) {
    return _compare == null
        ? _optionKey == _srcKey
        : _compare(_optionKey, _srcKey);
  }

  bool singleValueFilter(String value,
      {Map<String, CompareFilterKeyCallback> compares}) {
    // ignore matchAll?
    options.removeWhere((k, v) => v != true);
    if (options.isEmpty) {
      return true;
    }
    bool result;
    if (compares == null) {
      result = options.containsKey(value);
    } else {
      result = false;
      for (var option in options.keys) {
        if (_customCompare(option, value, compares[option])) {
          result = true;
          break;
        }
      }
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

  // json_serializable
  factory FilterGroupData.fromJson(Map<String, dynamic> data) =>
      _$FilterGroupDataFromJson(data);

  Map<String, dynamic> toJson() => _$FilterGroupDataToJson(this);

  @override
  String toString() {
    return 'Data($matchAll, $invert, $options)';
  }
}
