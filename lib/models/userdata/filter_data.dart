import 'package:flutter/material.dart';

import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/modules/ffo/schema.dart';
import '../../generated/l10n.dart';
import '../db.dart';
import '_helper.dart';
import 'userdata.dart';

part '../../generated/models/userdata/filter_data.g.dart';

typedef _FilterCompare<T> = bool Function(T value, T option);

class FilterGroupData<T> {
  bool _matchAll;

  bool get matchAll => _matchAll;

  set matchAll(bool matchAll) {
    _matchAll = matchAll;
    onChanged?.call();
  }

  bool _invert;

  bool get invert => _invert;

  set invert(bool invert) {
    _invert = invert;
    onChanged?.call();
  }

  Set<T> _options;

  Set<T> get options => _options;

  set options(Set<T> options) {
    _options = Set.from(options);
    onChanged?.call();
  }

  VoidCallback? onChanged;

  FilterGroupData({
    bool matchAll = false,
    bool invert = false,
    Set<T>? options,
    this.onChanged,
  })  : _matchAll = matchAll,
        _invert = invert,
        _options = options ?? {};

  T? get radioValue => throw UnimplementedError();

  bool contain(T v) =>
      options.isEmpty || (invert ? !options.contains(v) : options.contains(v));

  bool isEmpty(Iterable<T> values) {
    return options.isEmpty || values.every((e) => !options.contains(e));
  }

  bool isAll(Iterable<T> values) {
    return values.every((e) => options.contains(e));
  }

  void toggle(T value) {
    options.toggle(value);
    onChanged?.call();
  }

  void reset() {
    matchAll = invert = false;
    options.clear();
    onChanged?.call();
  }

  bool _match(
    T value,
    T option,
    _FilterCompare<T>? compare,
    Map<T, _FilterCompare<T>>? compares,
  ) {
    compare ??= compares?[option] ?? (T v, T o) => v == o;
    return compare.call(value, option);
  }

  bool matchOne(
    T value, {
    _FilterCompare<T>? compare,
    Map<T, _FilterCompare<T>>? compares,
  }) {
    if (options.isEmpty) return true;
    assert(!matchAll, 'When `matchAll` enabled, use `matchList` instead');
    bool result =
        options.any((option) => _match(value, option, compare, compares));
    return invert ? !result : result;
  }

  bool matchAny(
    Iterable<T> values, {
    _FilterCompare<T>? compare,
    Map<T, _FilterCompare<T>>? compares,
  }) {
    if (options.isEmpty) return true;
    bool result;
    if (matchAll) {
      result = options.every(
          (option) => values.any((v) => _match(v, option, compare, compares)));
    } else {
      result = options.any(
          (option) => values.any((v) => _match(v, option, compare, compares)));
    }
    return invert ? !result : result;
  }
}

class FilterRadioData<T> extends FilterGroupData<T> {
  T? _selected;
  final bool _nonnull;
  final T? _initValue;

  @override
  T? get radioValue {
    assert(!(_selected == null && _nonnull && null is! T));
    return _selected;
  }

  @override
  bool get matchAll => false;

  @override
  bool get invert => false;

  @override
  Set<T> get options => {if (_selected != null) _selected!};

  FilterRadioData([this._selected])
      : _nonnull = false,
        _initValue = null;
  FilterRadioData.nonnull(T selected)
      : _selected = selected,
        _nonnull = true,
        _initValue = selected;

  @override
  void toggle(T value) {
    if (value == _selected && !_nonnull) {
      _selected = null;
    } else {
      _selected = value;
    }
  }

  @override
  void reset() {
    _selected = _nonnull ? _initValue : null;
  }
}

/// Servant
enum SvtCompare { no, className, rarity, atk, hp, priority }

extension SvtCompareX on SvtCompare {
  String get showName {
    switch (this) {
      case SvtCompare.no:
        return S.current.filter_sort_number;
      case SvtCompare.className:
        return S.current.filter_sort_class;
      case SvtCompare.rarity:
        return S.current.filter_sort_rarity;
      case SvtCompare.atk:
        return 'ATK';
      case SvtCompare.hp:
        return 'HP';
      case SvtCompare.priority:
        return S.current.priority;
    }
  }
}

enum SvtEffectScope { active, passive, append, td }

extension SvtEffectScopeX on SvtEffectScope {
  String get shownName {
    switch (this) {
      case SvtEffectScope.active:
        return S.current.active_skill_short;
      case SvtEffectScope.passive:
        return S.current.passive_skill_short;
      case SvtEffectScope.append:
        return S.current.append_skill_short;
      case SvtEffectScope.td:
        return S.current.np_short;
    }
  }
}

enum EffectTarget {
  self,
  ptAll, //ptFull
  ptOne,
  ptOther, //ptOtherFull
  enemy,
  enemyAll,
  special,
}

enum SvtPlanScope {
  all,
  ascension,
  active,
  append,
  costume,
  misc, //fou, grail, bond
}

enum SvtSkillLevelState {
  normal,
  max9,
  max10,
}

const _funcEffectMapping = {
  FuncTargetType.self: EffectTarget.self,
  FuncTargetType.ptAll: EffectTarget.ptAll,
  FuncTargetType.ptFull: EffectTarget.ptAll,
  FuncTargetType.ptOne: EffectTarget.ptOne,
  FuncTargetType.ptOther: EffectTarget.ptOther,
  FuncTargetType.ptOtherFull: EffectTarget.ptOther,
  FuncTargetType.enemy: EffectTarget.enemy,
  FuncTargetType.enemyAll: EffectTarget.enemyAll,
};

extension EffectTargetX on EffectTarget {
  static const List<EffectTarget> svtTargets = EffectTarget.values;
  static EffectTarget fromFunc(FuncTargetType funcTarget) {
    return _funcEffectMapping[funcTarget] ?? EffectTarget.special;
  }

  String get shownName {
    for (final entry in _funcEffectMapping.entries) {
      if (entry.value == this) {
        return Transl.funcTargetType(entry.key).l;
      }
    }
    return S.current.general_special;
  }
}

abstract class _FilterData {
  List<FilterGroupData> get groups;
  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

@JsonSerializable(ignoreUnannotated: true)
class SvtFilterData with _FilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  FavoriteState favorite;
  @JsonKey()
  FavoriteState planFavorite;
  @JsonKey()
  List<SvtCompare> sortKeys;
  @JsonKey()
  List<bool> sortReversed;

  //
  final svtClass = FilterGroupData<SvtClass>();
  final rarity = FilterGroupData<int>();
  final attribute = FilterGroupData<Attribute>();

  final svtDuplicated = FilterRadioData<bool>();
  final planCompletion = FilterGroupData<SvtPlanScope>();
  final activeSkillLevel = FilterGroupData<SvtSkillLevelState>();
  final priority = FilterGroupData<int>(onChanged: () {
    db.itemCenter.updateSvts(all: true);
  });
  final region = FilterRadioData<Region>();
  final obtain = FilterGroupData<SvtObtain>();
  final npColor = FilterGroupData<CardType>();
  final npType = FilterGroupData<TdEffectFlag>();
  final policy = FilterGroupData<ServantPolicy>(); //秩序 混沌 中庸
  final personality = FilterGroupData<ServantPersonality>(); //善 恶 中立 夏 狂...
  final gender = FilterGroupData<Gender>();
  final trait = FilterGroupData<Trait>();

  final effectScope = FilterGroupData<SvtEffectScope>(
      options: {SvtEffectScope.active, SvtEffectScope.td});
  final effectTarget = FilterGroupData<EffectTarget>();
  final effectType = FilterGroupData<SkillEffect>();

  SvtFilterData({
    this.useGrid = false,
    this.favorite = FavoriteState.all,
    this.planFavorite = FavoriteState.all,
    List<SvtCompare?>? sortKeys,
    List<bool>? sortReversed,
  })  : sortKeys = List.generate(SvtCompare.values.length,
            (index) => sortKeys?.getOrNull(index) ?? SvtCompare.values[index],
            growable: false),
        sortReversed = List.generate(SvtCompare.values.length,
            (index) => sortReversed?.getOrNull(index) ?? true,
            growable: false);

  @override
  List<FilterGroupData> get groups => [
        svtClass,
        rarity,
        attribute,
        activeSkillLevel,
        planCompletion,
        svtDuplicated,
        // priority,
        region,
        obtain,
        npColor,
        npType,
        policy,
        personality,
        gender,
        trait,
        effectScope,
        effectTarget,
        effectType,
      ];

  @override
  void reset() {
    super.reset();
    effectScope.options = {SvtEffectScope.active, SvtEffectScope.td};
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region == Region.jp) {
        region.reset();
      } else {
        region.toggle(db.curUser.region);
      }
    }
  }

  factory SvtFilterData.fromJson(Map<String, dynamic> data) =>
      _$SvtFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtFilterDataToJson(this);

  static int compare(Servant? a, Servant? b,
      {List<SvtCompare>? keys, List<bool>? reversed, User? user}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    int _classSortKey(SvtClass cls) {
      if (db.gameData.constData.classInfo.isNotEmpty) {
        return -(db.gameData.constData.classInfo[cls.id]?.priority ?? 0);
      }
      int k = SvtClassX.regularWithBeast.indexOf(cls);
      return k < 0 ? 999 : k;
    }

    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.originalCollectionNo - b.originalCollectionNo;
          if (r == 0) r = a.collectionNo - b.collectionNo;
          if (r == 0) r = a.id - b.id;
          break;
        case SvtCompare.className:
          r = _classSortKey(a.className) - _classSortKey(b.className);
          break;
        case SvtCompare.rarity:
          r = a.rarity - b.rarity;
          break;
        case SvtCompare.atk:
          r = (a.atkMax) - (b.atkMax);
          break;
        case SvtCompare.hp:
          r = (a.hpMax) - (b.hpMax);
          break;
        case SvtCompare.priority:
          final aa = user?.svtStatusOf(a.collectionNo),
              bb = user?.svtStatusOf(b.collectionNo);
          r = (aa?.priority ?? 1) - (bb?.priority ?? 1);
          break;
      }
      if (r != 0) {
        return (reversed?.elementAt(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

/// Craft Essence

enum CraftCompare { no, rarity, atk, hp }

extension CraftCompareX on CraftCompare {
  String get shownName {
    switch (this) {
      case CraftCompare.no:
        return S.current.filter_sort_number;
      case CraftCompare.rarity:
        return S.current.filter_sort_rarity;
      case CraftCompare.atk:
        return 'ATK';
      case CraftCompare.hp:
        return 'HP';
    }
  }
}

enum CraftATKType { none, hp, atk, mix }

@JsonSerializable(ignoreUnannotated: true)
class CraftFilterData with _FilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  bool favorite;
  @JsonKey()
  List<CraftCompare> sortKeys;
  @JsonKey()
  List<bool> sortReversed;

  // filter
  final rarity = FilterGroupData<int>();
  final region = FilterRadioData<Region>();
  final obtain = FilterGroupData<CEObtain>();
  final atkType = FilterGroupData<CraftATKType>();
  final status = FilterGroupData<int>();
  final effectTarget = FilterGroupData<EffectTarget>();
  final effectType = FilterGroupData<SkillEffect>();

  CraftFilterData({
    this.useGrid = false,
    this.favorite = false,
    List<CraftCompare?>? sortKeys,
    List<bool>? sortReversed,
  })  : sortKeys = List.generate(CraftCompare.values.length,
            (index) => sortKeys?.getOrNull(index) ?? CraftCompare.values[index],
            growable: false),
        sortReversed = List.generate(CraftCompare.values.length,
            (index) => sortReversed?.getOrNull(index) ?? true,
            growable: false);

  @override
  List<FilterGroupData> get groups => [
        rarity,
        region,
        obtain,
        atkType,
        status,
        effectTarget,
        effectType,
      ];

  @override
  void reset() {
    super.reset();
    favorite = false;
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region == Region.jp) {
        region.options.clear();
      } else {
        region.toggle(db.curUser.region);
      }
    }
  }

  factory CraftFilterData.fromJson(Map<String, dynamic> data) =>
      _$CraftFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CraftFilterDataToJson(this);

  static int compare(CraftEssence a, CraftEssence b,
      {List<CraftCompare>? keys, List<bool>? reversed}) {
    if (keys == null || keys.isEmpty) {
      keys = [CraftCompare.no];
    }
    const _idRemap = {102022: 1461.5};
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case CraftCompare.no:
          r = ((_idRemap[a.collectionNo] ?? a.collectionNo) -
                  (_idRemap[b.collectionNo] ?? b.collectionNo))
              .round();
          break;
        case CraftCompare.rarity:
          r = a.rarity - b.rarity;
          break;
        case CraftCompare.atk:
          r = a.atkMax - b.atkMax;
          break;
        case CraftCompare.hp:
          r = a.hpMax - b.hpMax;
          break;
      }
      if (r != 0) {
        return (reversed?.elementAt(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

/// Command Code
enum CmdCodeCompare { no, rarity }

extension CmdCodeCompareX on CmdCodeCompare {
  String get shownName {
    switch (this) {
      case CmdCodeCompare.no:
        return S.current.filter_sort_number;
      case CmdCodeCompare.rarity:
        return S.current.filter_sort_rarity;
    }
  }
}

@JsonSerializable(ignoreUnannotated: true)
class CmdCodeFilterData with _FilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  bool favorite;
  @JsonKey()
  List<CmdCodeCompare> sortKeys;
  @JsonKey()
  List<bool> sortReversed;

  // filter
  final rarity = FilterGroupData<int>();
  final region = FilterRadioData<Region>();
  final effectTarget = FilterGroupData<EffectTarget>();
  final effectType = FilterGroupData<SkillEffect>();

  CmdCodeFilterData({
    this.useGrid = false,
    this.favorite = false,
    List<CmdCodeCompare?>? sortKeys,
    List<bool>? sortReversed,
  })  : sortKeys = List.generate(
            CmdCodeCompare.values.length,
            (index) =>
                sortKeys?.getOrNull(index) ?? CmdCodeCompare.values[index],
            growable: false),
        sortReversed = List.generate(CmdCodeCompare.values.length,
            (index) => sortReversed?.getOrNull(index) ?? true,
            growable: false);

  @override
  List<FilterGroupData> get groups =>
      [rarity, region, effectTarget, effectType];

  @override
  void reset() {
    super.reset();
    favorite = false;
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region == Region.jp) {
        region.options.clear();
      } else {
        region.toggle(db.curUser.region);
      }
    }
  }

  factory CmdCodeFilterData.fromJson(Map<String, dynamic> data) =>
      _$CmdCodeFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CmdCodeFilterDataToJson(this);

  static int compare(CommandCode a, CommandCode b,
      {List<CmdCodeCompare>? keys, List<bool>? reversed}) {
    if (keys == null || keys.isEmpty) {
      keys = [CmdCodeCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case CmdCodeCompare.no:
          r = a.collectionNo - b.collectionNo;
          break;
        case CmdCodeCompare.rarity:
          r = a.rarity - b.rarity;
          break;
      }
      if (r != 0) {
        return (reversed?.elementAt(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

enum FavoriteState {
  all,
  owned,
  other,
}

extension FavoriteStateX on FavoriteState {
  IconData get icon {
    switch (this) {
      case FavoriteState.all:
        return Icons.remove_circle_outline;
      case FavoriteState.owned:
        return Icons.favorite;
      case FavoriteState.other:
        return Icons.favorite_border;
    }
  }

  String get shownName {
    switch (this) {
      case FavoriteState.all:
        return S.current.general_all;
      case FavoriteState.owned:
        return S.current.item_own;
      case FavoriteState.other:
        return S.current.general_others;
    }
  }

  bool check(bool favorite) {
    switch (this) {
      case FavoriteState.all:
        return true;
      case FavoriteState.owned:
        return favorite;
      case FavoriteState.other:
        return !favorite;
    }
  }
}

// event
@JsonSerializable()
class EventFilterData with _FilterData {
  bool reversed;
  bool showOutdated;
  bool showSpecialRewards;
  bool showEmpty;

  // filter
  @JsonKey(ignore: true)
  final contentType = FilterGroupData<EventCustomType>();
  @JsonKey(ignore: true)
  final eventType = FilterGroupData<EventType>();
  @JsonKey(ignore: true)
  final campaignType = FilterGroupData<CombineAdjustTarget>();

  EventFilterData({
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    this.showEmpty = false,
  });

  @override
  void reset() {
    super.reset();
    showSpecialRewards = false;
    showEmpty = false;
  }

  @override
  List<FilterGroupData> get groups => [contentType, eventType, campaignType];

  factory EventFilterData.fromJson(Map<String, dynamic> data) =>
      _$EventFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$EventFilterDataToJson(this);
}

enum EventCustomType {
  mainInterlude,
  hunting,
  warBoard,
  lottery,
  mission,
  point,
  tower,
  treasureBox,
  digging,
  cooltime,
  bulletinBoard,
  recipe,
}

// summon

@JsonSerializable(checked: true)
class SummonFilterData with _FilterData {
  bool favorite;
  bool reversed;
  bool showBanner;
  bool showOutdated;
  @JsonKey(ignore: true)
  final category = FilterGroupData<SummonType>();

  SummonFilterData({
    bool? favorite,
    bool? reversed,
    bool? showBanner,
    bool? showOutdated,
  })  : favorite = favorite ?? false,
        reversed = reversed ?? true,
        showBanner = showBanner ?? false,
        showOutdated = showOutdated ?? false;

  @override
  List<FilterGroupData> get groups => [category];

  @override
  void reset() {
    super.reset();
    favorite = false;
    showOutdated = false;
  }

  factory SummonFilterData.fromJson(Map<String, dynamic> data) =>
      _$SummonFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SummonFilterDataToJson(this);
}

@JsonSerializable()
class ScriptReaderFilterData {
  bool scene;
  bool soundEffect;
  bool bgm;
  bool voice;

  ScriptReaderFilterData({
    this.scene = true,
    this.soundEffect = true,
    this.bgm = true,
    this.voice = true,
  });

  void reset() {
    soundEffect = bgm = scene = voice = true;
  }

  factory ScriptReaderFilterData.fromJson(Map<String, dynamic> data) =>
      _$ScriptReaderFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$ScriptReaderFilterDataToJson(this);
}

class EnemyFilterData with _FilterData {
  bool useGrid;
  List<SvtCompare> sortKeys;
  List<bool> sortReversed;

  static const enemyCompares = [
    SvtCompare.no,
    SvtCompare.className,
    SvtCompare.rarity
  ];

  bool onlyShowQuestEnemy;
  // filter
  final svtClass = FilterGroupData<SvtClass>();
  final attribute = FilterGroupData<Attribute>();
  final svtType = FilterGroupData<SvtType>();
  final trait = FilterGroupData<Trait>();

  EnemyFilterData({
    this.useGrid = false,
    this.onlyShowQuestEnemy = true,
    List<SvtCompare?>? sortKeys,
    List<bool>? sortReversed,
  })  : sortKeys = List.generate(enemyCompares.length,
            (index) => sortKeys?.getOrNull(index) ?? enemyCompares[index],
            growable: false),
        sortReversed = List.generate(enemyCompares.length,
            (index) => sortReversed?.getOrNull(index) ?? true,
            growable: false);

  @override
  List<FilterGroupData> get groups => [svtClass, attribute, svtType, trait];

  // factory EnemyFilterData.fromJson(Map<String, dynamic> data) =>
  //     _$EnemyFilterDataFromJson(data);

  // Map<String, dynamic> toJson() => _$EnemyFilterDataToJson(this);

  static int compare(BasicServant? a, BasicServant? b,
      {List<SvtCompare>? keys, List<bool>? reversed}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    int _classSortKey(SvtClass cls) {
      int k = SvtClass.values.indexOf(cls);
      return k < 0 ? 999 : k;
    }

    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.id - b.id;
          break;
        case SvtCompare.className:
          r = _classSortKey(a.className) - _classSortKey(b.className);
          break;
        case SvtCompare.rarity:
          r = a.rarity - b.rarity;
          break;
        default:
          r = 0;
      }
      if (r != 0) {
        return (reversed?.elementAt(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

class FfoPartFilterData with _FilterData {
  static const kSortKeys = [
    SvtCompare.no,
    SvtCompare.className,
    SvtCompare.rarity
  ];

  bool useGrid = false;
  final rarity = FilterGroupData<int>();
  final classType = FilterGroupData<SvtClass>();
  List<SvtCompare> sortKeys = List.of(kSortKeys);
  List<bool> sortReversed = [false, false, true];

  @override
  List<FilterGroupData> get groups => [rarity, classType];

  static int compare(FfoSvt? a, FfoSvt? b,
      {List<SvtCompare>? keys, List<bool>? reversed}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    int _classSortKey(SvtClass? cls) {
      int k = cls == null ? -1 : SvtClassX.regularAll.indexOf(cls);
      return k < 0 ? 999 : k;
    }

    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.collectionNo - b.collectionNo;
          break;
        case SvtCompare.className:
          r = _classSortKey(a.svtClass) - _classSortKey(b.svtClass);
          break;
        case SvtCompare.rarity:
          r = a.rarity - b.rarity;
          break;
        default:
          r = 0;
      }
      if (r != 0) {
        return (reversed?.elementAt(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}
