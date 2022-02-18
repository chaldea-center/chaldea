import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

import 'userdata.dart';

part '../../generated/models/userdata/filter_data.g.dart';

typedef _FilterCompare<T> = bool Function(T value, T option);

class FilterGroupData<T> {
  bool matchAll;
  bool invert;
  Set<T> options;

  FilterGroupData({
    this.matchAll = false,
    this.invert = false,
    Set<T>? options,
  }) : options = options ?? {};

  T? get radioValue => throw UnimplementedError();

  bool isEmpty(Iterable<T> values) {
    return options.isEmpty || values.every((e) => !options.contains(e));
  }

  bool isAll(Iterable<T> values) {
    return values.every((e) => options.contains(e));
  }

  void toggle(T value) {
    options.toggle(value);
  }

  void reset() {
    matchAll = invert = false;
    options.clear();
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

  // FilterGroupData planCompletion;
  // FilterGroupData skillLevel;
  FilterGroupData<int> priority = FilterGroupData();
  FilterGroupData<SvtObtain> obtain = FilterGroupData();
  FilterGroupData<CardType> npColor = FilterGroupData();
  FilterGroupData<NpDamageType> npType = FilterGroupData();
  FilterGroupData<Trait> alignment1 = FilterGroupData(); //秩序 混沌 中庸
  FilterGroupData<Trait> alignment2 = FilterGroupData(); //善 恶 中立 夏 狂...
  FilterGroupData<Gender> gender = FilterGroupData();
  FilterGroupData<Trait> trait = FilterGroupData();
  // FilterGroupData special; //not used yet
  // FilterGroupData effectScope;
  // FilterGroupData effectTarget;
  // FilterGroupData effects;

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

  List<FilterGroupData> get _group => [svtClass, rarity, attribute, trait];

  void reset() {
    favorite = FavoriteState.all;
    for (var value in _group) {
      value.reset();
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
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.collectionNo - b.collectionNo;
          if (r == 0) r = a.id - b.id;
          break;
        case SvtCompare.className:
          r = SvtClassX.regularAll.indexOf(a.className) -
              SvtClassX.regularAll.indexOf(b.className);
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
  FilterGroupData<CEObtain> obtain = FilterGroupData();
  FilterGroupData<CraftATKType> atkType = FilterGroupData();
  FilterGroupData<CraftStatus> status = FilterGroupData();

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

  List<FilterGroupData> get _group => [rarity];

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

enum FavoriteState {
  all,
  owned,
  planned,
  other,
}
