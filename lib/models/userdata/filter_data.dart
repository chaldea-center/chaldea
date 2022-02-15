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
    List<T> values, {
    _FilterCompare<T>? compare,
    Map<T, _FilterCompare<T>>? compares,
  }) {
    if (options.isEmpty) return true;
    bool result;
    if (matchAll) {
      result =
          options.every((option) => _match(option, option, compare, compares));
    } else {
      result =
          options.any((option) => _match(option, option, compare, compares));
    }
    return invert ? !result : result;
  }
}

class FilterRadioData<T> extends FilterGroupData<T> {
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

@JsonSerializable(ignoreUnannotated: true)
class SvtFilterData {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  FavoriteState favorite;
  FilterGroupData<SvtClass> svtClass = FilterGroupData();
  FilterGroupData<int> rarity = FilterGroupData();
  FilterGroupData<Attribute> attribute = FilterGroupData();
  FilterGroupData<Trait> trait = FilterGroupData();

  SvtFilterData({
    this.useGrid = false,
    this.favorite = FavoriteState.all,
  });

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
