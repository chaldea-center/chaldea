part of datatypes;

@JsonSerializable(checked: true)
class SvtFilterData {
  /// 0-all, 1-fav, 2-not fav
  int favorite;
  int planFavorite;

  FilterGroupData display;
  List<SvtCompare> sortKeys;
  List<bool> sortReversed;

  bool hasDress;
  FilterGroupData svtDuplicated;

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
  FilterGroupData special; //not used yet
  FilterGroupData effectScope;
  FilterGroupData effects;

  bool get useGrid => display.isRadioVal('Grid');

  SvtFilterData({
    int? favorite,
    int? planFavorite,
    FilterGroupData? display,
    List<SvtCompare>? sortKeys,
    List<bool>? sortReversed,
    bool? hasDress,
    FilterGroupData? svtDuplicated,
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
    FilterGroupData? special,
    FilterGroupData? effectScope,
    FilterGroupData? effects,
  })  : favorite = favorite ?? 0,
        planFavorite = planFavorite ?? 0,
        display = display ?? FilterGroupData(options: {'List': true}),
        sortKeys = sortKeys ?? List.generate(3, (i) => sortKeyData[i]),
        sortReversed = sortReversed ?? List.generate(3, (index) => true),
        hasDress = hasDress ?? false,
        svtDuplicated = svtDuplicated ?? FilterGroupData(),
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
        special = special ?? FilterGroupData(),
        effectScope = effectScope ?? FilterGroupData(),
        effects = effects ?? FilterGroupData() {
    this.favorite = fixValidRange(this.favorite, 0, 2);
    this.planFavorite = fixValidRange(this.planFavorite, 0, 2);
    fillListValue(this.sortKeys, 3, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 3, (_) => true);
  }

  List<FilterGroupData> get groupValues => [
        // display,  // don't reset list/grid view
        svtDuplicated,
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
        special,
        effects,
        // traitSpecial
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
    //
    'Saber', 'Archer', 'Lancer', 'Rider', 'Caster', 'Assassin', 'Berserker',
    'Shielder',
    'Ruler', 'Avenger', 'MoonCancer', 'Alterego', 'Foreigner', 'Pretender',
    'Beast'
  ];
  static const List<String> regularClassesData = [
    //
    'Saber', 'Archer', 'Lancer', 'Rider', 'Caster', 'Assassin', 'Berserker',
  ];

  static List<String> get extraClassesData =>
      [
        //
        'Shielder',
        'Ruler', 'Avenger', 'MoonCancer', 'Alterego', 'Foreigner', 'Pretender',
        'Beast',
      ];
  static const List<String> obtainData = [
    //
    '剧情', '活动', '无法召唤', '常驻', '限定', '友情点召唤'
  ];
  static const npColorData = ['Quick', 'Arts', 'Buster'];
  static const npTypeData = ['单体', '全体', '辅助'];
  static const attributeData = ['天', '地', '人', '星', '兽'];
  static const alignment1Data = ['秩序', '混沌', '中立'];
  static const alignment2Data = ['善', '恶', '中庸', '新娘', '狂', '夏'];
  static const genderData = ['男性', '女性', '其他'];
  static const traitData = [
    //
    '龙', '骑乘', '神性', '人型', '猛兽', '王', '罗马', '亚瑟', '阿尔托莉雅脸',
    'EA不特攻', '所爱之人', '希腊神话系男性', '人类的威胁', '阿耳戈船相关人员', '魔性',
    '超巨大', '天地(拟似除外)', '人科', '魔兽型', '活在当下的人类', '巨人', '孩童从者',
    '领域外生命', '鬼', '源氏', '机械', '妖精', '圆桌骑士'
  ];
  static const buffScope = ['0', '1', '2']; // active skill, NP, passive skill

  // json_serializable
  factory SvtFilterData.fromJson(Map<String, dynamic> data) =>
      _$SvtFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtFilterDataToJson(this);
}

@JsonSerializable(checked: true)
class CraftFilterData {
  FilterGroupData display;
  List<CraftCompare> sortKeys;
  List<bool> sortReversed;

  FilterGroupData rarity;
  FilterGroupData category;
  FilterGroupData atkHpType;
  FilterGroupData status;
  FilterGroupData effects;

  bool get useGrid => display.isRadioVal('Grid');

  CraftFilterData({
    FilterGroupData? display,
    List<CraftCompare>? sortKeys,
    List<bool>? sortReversed,
    FilterGroupData? rarity,
    FilterGroupData? category,
    FilterGroupData? atkHpType,
    FilterGroupData? status,
    FilterGroupData? effects,
  })  : display = display ?? FilterGroupData(options: {'List': true}),
        sortKeys = sortKeys ?? List.generate(2, (index) => sortKeyData[index]),
        sortReversed = sortReversed ?? List.filled(2, true, growable: true),
        rarity = rarity ?? FilterGroupData(),
        category = category ?? FilterGroupData(),
        atkHpType = atkHpType ?? FilterGroupData(),
        status = status ?? FilterGroupData(),
        effects = effects ?? FilterGroupData() {
    fillListValue(this.sortKeys, 2, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 2, (_) => true);
  }

  List<FilterGroupData> get groupValues =>
      [
        // display,
        rarity,
        category,
        atkHpType,
        status,
        effects,
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
    //
    '兑换', '活动奖励', 'EXP卡', '剧情限定', '情人节', '羁绊', '纪念',
    '卡池常驻', '期间限定'
  ];
  static const atkHpTypeData = ['NONE', 'HP', 'ATK', 'MIX'];
  static const statusTexts = ['未遭遇', '已遭遇', '已契约'];

  // json_serializable
  factory CraftFilterData.fromJson(Map<String, dynamic> data) =>
      _$CraftFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CraftFilterDataToJson(this);
}

@JsonSerializable(checked: true)
class CmdCodeFilterData {
  FilterGroupData display;
  List<CmdCodeCompare> sortKeys;
  List<bool> sortReversed;

  FilterGroupData rarity;
  FilterGroupData category;
  FilterGroupData effects;

  bool get useGrid => display.isRadioVal('Grid');

  CmdCodeFilterData({
    FilterGroupData? display,
    List<CmdCodeCompare>? sortKeys,
    List<bool>? sortReversed,
    FilterGroupData? rarity,
    FilterGroupData? category,
    FilterGroupData? effects,
  })  : display = display ?? FilterGroupData(options: {'List': true}),
        sortKeys = sortKeys ?? List.generate(2, (index) => sortKeyData[index]),
        sortReversed = sortReversed ?? List.filled(2, true, growable: true),
        rarity = rarity ?? FilterGroupData(),
        category = category ?? FilterGroupData(),
        effects = effects ?? FilterGroupData() {
    fillListValue(this.sortKeys, 2, (i) => sortKeyData[i]);
    fillListValue(this.sortReversed, 2, (_) => true);
  }

  List<FilterGroupData> get groupValues => [rarity, category, effects];

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
  static const List<String> categoryData = ['友情池常驻', '活动奖励'];

  // json_serializable
  factory CmdCodeFilterData.fromJson(Map<String, dynamic> data) =>
      _$CmdCodeFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CmdCodeFilterDataToJson(this);
}

@JsonSerializable(checked: true)
class SummonFilterData {
  bool favorite;
  bool reversed;
  bool showBanner;
  bool showOutdated;
  FilterGroupData category;

  SummonFilterData({
    bool? favorite,
    bool? reversed,
    bool? showBanner,
    bool? showOutdated,
    FilterGroupData? category,
  })  : favorite = favorite ?? false,
        reversed = reversed ?? false,
        showBanner = showBanner ?? false,
        showOutdated = showOutdated ?? false,
        category = category ?? FilterGroupData();

  List<FilterGroupData> get groupValues => [category];

  void reset() {
    for (var group in groupValues) {
      group.reset();
    }
    favorite = false;
    showOutdated = false;
  }

  static const List<String> categoryData = ['0', '1', '2', '3'];

  factory SummonFilterData.fromJson(Map<String, dynamic> data) =>
      _$SummonFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SummonFilterDataToJson(this);
}

typedef CompareFilterKeyCallback = bool? Function(String option, String? value);

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

  FilterGroupData.radio([String? selected])
      : options = {if (selected != null) selected: true},
        invert = false,
        matchAll = false;

  bool isRadioVal(String v) => options[v] == true;

  bool isEmpty(Iterable<String> keys) {
    return keys.map((e) => options[e] ?? false).toSet().length == 1;
  }

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

  bool singleValueFilter(
    dynamic value, {
    CompareFilterKeyCallback? defaultCompare,
    Map<String, CompareFilterKeyCallback> compares = const {},
  }) {
    // ignore matchAll?
    options.removeWhere((k, v) => v != true);
    if (options.isEmpty) {
      return true;
    }
    bool result;
    if (defaultCompare != null || compares.isNotEmpty) {
      result = false;
      for (var option in options.keys) {
        if (_customCompare(option, value, compares[option] ?? defaultCompare)) {
          result = true;
          break;
        }
      }
    } else {
      result = options.containsKey(value);
    }
    return invert ? !result : result;
  }

  bool listValueFilter(
    List<String> values, {
    CompareFilterKeyCallback? defaultCompare,
    Map<String, CompareFilterKeyCallback> compares = const {},
  }) {
    options.removeWhere((k, v) => v != true);
    if (options.isEmpty) {
      return true;
    }
    bool result;
    if (matchAll) {
      result = true;
      for (String option in options.keys) {
        List<bool> tmp = values
            .map((v) =>
                _customCompare(option, v, compares[option] ?? defaultCompare))
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
            .map((v) =>
                _customCompare(option, v, compares[option] ?? defaultCompare))
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
