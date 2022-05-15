import 'package:flutter/material.dart';

import 'package:chaldea/models/gamedata/effect.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
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
  @override
  T? get radioValue => _selected;

  @Deprecated('use radioValue instead`')
  T? get selected => _selected;
  T? _selected;

  @override
  bool get matchAll => false;

  @override
  bool get invert => false;

  @override
  Set<T> get options => Set.unmodifiable([if (_selected != null) _selected!]);

  FilterRadioData([this._selected]);

  @override
  void toggle(T value) {
    _selected = value;
  }

  @override
  void reset() {
    _selected = null;
  }
}

/// Servant
enum SvtCompare { no, className, rarity, atk, hp, priority }

enum SvtEffectScope { active, passive, append, td }

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
  ascension,
  active,
  append,
  costume,
  misc, //fou, grail, bond
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

@JsonSerializable(ignoreUnannotated: true)
class SvtFilterData {
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
  FilterGroupData<SvtClass> svtClass = FilterGroupData();
  FilterGroupData<int> rarity = FilterGroupData();
  FilterGroupData<Attribute> attribute = FilterGroupData();

  // FilterGroupData svtDuplicated= FilterGroupData();

  FilterGroupData<SvtPlanScope> planCompletion = FilterGroupData();

  // FilterGroupData skillLevel;
  FilterGroupData<int> priority = FilterGroupData(onChanged: () {
    db.itemCenter.updateSvts(all: true);
  });
  FilterRadioData<Region> region = FilterRadioData();
  FilterGroupData<SvtObtain> obtain = FilterGroupData();
  FilterGroupData<CardType> npColor = FilterGroupData();
  FilterGroupData<NpDamageType> npType = FilterGroupData();
  FilterGroupData<ServantPolicy> policy = FilterGroupData(); //秩序 混沌 中庸
  FilterGroupData<ServantPersonality> personality =
      FilterGroupData(); //善 恶 中立 夏 狂...
  FilterGroupData<Gender> gender = FilterGroupData();
  FilterGroupData<Trait> trait = FilterGroupData();

  // FilterGroupData special; //not used yet
  FilterGroupData<SvtEffectScope> effectScope =
      FilterGroupData(options: {SvtEffectScope.active, SvtEffectScope.td});
  FilterGroupData<EffectTarget> effectTarget = FilterGroupData();
  FilterGroupData<SkillEffect> effectType = FilterGroupData();

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

  List<FilterGroupData> get _group => [
        svtClass,
        rarity,
        attribute,
        planCompletion,
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

  void reset() {
    for (var value in _group) {
      value.reset();
    }
    effectScope.options = {SvtEffectScope.active, SvtEffectScope.td};
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
      int k = SvtClassX.regularAll.indexOf(cls);
      return k < 0 ? 999 : k;
    }

    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.collectionNo - b.collectionNo;
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

enum CraftATKType { none, hp, atk, mix }

@JsonSerializable(ignoreUnannotated: true)
class CraftFilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  bool favorite;
  @JsonKey()
  List<CraftCompare> sortKeys;
  @JsonKey()
  List<bool> sortReversed;

  // filter
  FilterGroupData<int> rarity = FilterGroupData();
  FilterRadioData<Region> region = FilterRadioData();
  FilterGroupData<CEObtain> obtain = FilterGroupData();
  FilterGroupData<CraftATKType> atkType = FilterGroupData();
  FilterGroupData<int> status = FilterGroupData();
  FilterGroupData<EffectTarget> effectTarget = FilterGroupData();
  FilterGroupData<SkillEffect> effectType = FilterGroupData();

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

  List<FilterGroupData> get _group => [
        rarity,
        region,
        obtain,
        atkType,
        status,
        effectTarget,
        effectType,
      ];

  void reset() {
    favorite = false;
    for (var value in _group) {
      value.reset();
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
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case CraftCompare.no:
          r = a.collectionNo - b.collectionNo;
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

@JsonSerializable(ignoreUnannotated: true)
class CmdCodeFilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  bool favorite;
  @JsonKey()
  List<CmdCodeCompare> sortKeys;
  @JsonKey()
  List<bool> sortReversed;

  // filter
  FilterGroupData<int> rarity = FilterGroupData();
  FilterRadioData<Region> region = FilterRadioData();
  FilterGroupData<EffectTarget> effectTarget = FilterGroupData();
  FilterGroupData<SkillEffect> effectType = FilterGroupData();

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

  List<FilterGroupData> get _group =>
      [rarity, region, effectTarget, effectType];

  void reset() {
    favorite = false;
    for (var value in _group) {
      value.reset();
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

// summon

@JsonSerializable(checked: true)
class SummonFilterData {
  bool favorite;
  bool reversed;
  bool showBanner;
  bool showOutdated;
  @JsonKey(ignore: true)
  FilterGroupData<SummonType> category = FilterGroupData();

  SummonFilterData({
    bool? favorite,
    bool? reversed,
    bool? showBanner,
    bool? showOutdated,
    FilterGroupData? category,
  })  : favorite = favorite ?? false,
        reversed = reversed ?? true,
        showBanner = showBanner ?? false,
        showOutdated = showOutdated ?? false;

  List<FilterGroupData> get groupValues => [category];

  void reset() {
    for (var group in groupValues) {
      group.reset();
    }
    favorite = false;
    showOutdated = false;
  }

  factory SummonFilterData.fromJson(Map<String, dynamic> data) =>
      _$SummonFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SummonFilterDataToJson(this);
}
