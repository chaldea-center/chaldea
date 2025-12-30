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

  FilterGroupData({bool matchAll = false, bool invert = false, Set<T>? options, this.onChanged})
    : _matchAll = matchAll,
      _invert = invert,
      _options = options ?? {};

  FilterGroupData<T> copy() {
    return FilterGroupData(matchAll: _matchAll, invert: _invert, options: options.toSet(), onChanged: onChanged);
  }

  T? get radioValue => throw UnimplementedError();

  bool contain(T v) => options.isEmpty || (invert ? !options.contains(v) : options.contains(v));

  bool isEmptyOrContain(Iterable<T> values) {
    return options.isEmpty || values.every((e) => !options.contains(e));
  }

  bool get isEmpty => options.isEmpty;
  bool get isNotEmpty => options.isNotEmpty;

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

  bool _match(T value, T option, _FilterCompare<T>? compare, Map<T, _FilterCompare<T>>? compares) {
    compare ??= compares?[option] ?? (T v, T o) => v == o;
    return compare.call(value, option);
  }

  bool matchOne(T value, {_FilterCompare<T>? compare, Map<T, _FilterCompare<T>>? compares}) {
    if (options.isEmpty) return true;
    assert(!matchAll, 'When `matchAll` enabled, use `matchList` instead');
    bool result = options.any((option) => _match(value, option, compare, compares));
    return invert ? !result : result;
  }

  bool matchAny(Iterable<T> values, {_FilterCompare<T>? compare, Map<T, _FilterCompare<T>>? compares}) {
    if (options.isEmpty) return true;
    bool result;
    if (matchAll) {
      result = options.every((option) => values.any((v) => _match(v, option, compare, compares)));
    } else {
      result = options.any((option) => values.any((v) => _match(v, option, compare, compares)));
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
    // ignore: avoid-unnecessary-type-assertions
    assert(!(_selected == null && _nonnull && null is! T));
    return _selected;
  }

  @override
  bool get matchAll => false;

  @override
  bool get invert => false;

  @override
  Set<T> get options => {if (_selected != null || _selected is T) _selected as T};

  FilterRadioData([this._selected]) : _nonnull = false, _initValue = null;
  FilterRadioData.nonnull(T selected) : _selected = selected, _nonnull = true, _initValue = selected;

  @override
  FilterRadioData<T> copy() {
    return _nonnull ? FilterRadioData.nonnull(_selected as T) : FilterRadioData(_selected);
  }

  @override
  void toggle(T value) {
    if (value == _selected && !_nonnull) {
      _selected = null;
    } else {
      _selected = value;
    }
  }

  void set(T value) {
    _selected = value;
  }

  @override
  void reset() {
    _selected = _nonnull ? _initValue : null;
  }
}

mixin FilterDataMixin {
  List<FilterGroupData> get groups;
  void reset() {
    for (final group in groups) {
      group.reset();
    }
  }
}

@JsonSerializable()
class LocalDataFilters {
  SvtFilterData svtFilterData;
  SvtFilterData laplaceSvtFilterData;
  CraftFilterData craftFilterData;
  CmdCodeFilterData cmdCodeFilterData;
  MysticCodeFilterData mysticCodeFilterData;
  EventFilterData eventFilterData;
  SummonFilterData summonFilterData;
  SummonFilterData gachaFilterData;
  ScriptReaderFilterData scriptReaderFilterData;

  LocalDataFilters({
    SvtFilterData? svtFilterData,
    SvtFilterData? laplaceSvtFilterData,
    CraftFilterData? craftFilterData,
    CmdCodeFilterData? cmdCodeFilterData,
    MysticCodeFilterData? mysticCodeFilterData,
    EventFilterData? eventFilterData,
    SummonFilterData? summonFilterData,
    SummonFilterData? gachaFilterData,
    ScriptReaderFilterData? scriptReaderFilterData,
  }) : svtFilterData = svtFilterData ?? SvtFilterData(),
       laplaceSvtFilterData = laplaceSvtFilterData ?? SvtFilterData(useGrid: true),
       craftFilterData = craftFilterData ?? CraftFilterData(),
       cmdCodeFilterData = cmdCodeFilterData ?? CmdCodeFilterData(),
       mysticCodeFilterData = mysticCodeFilterData ?? MysticCodeFilterData(),
       eventFilterData = eventFilterData ?? EventFilterData(),
       summonFilterData = summonFilterData ?? SummonFilterData(),
       gachaFilterData = gachaFilterData ?? SummonFilterData(),
       scriptReaderFilterData = scriptReaderFilterData ?? ScriptReaderFilterData();

  factory LocalDataFilters.fromJson(Map<String, dynamic> data) => _$LocalDataFiltersFromJson(data);

  Map<String, dynamic> toJson() => _$LocalDataFiltersToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class SvtFilterData with FilterDataMixin {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  FavoriteState favorite;
  @JsonKey()
  FavoriteState planFavorite;
  @JsonKey()
  List<SvtCompare> sortKeys;
  @JsonKey()
  List<bool?> sortReversed;

  //
  final svtClass = FilterGroupData<SvtClass>();
  final rarity = FilterGroupData<int>();
  final attribute = FilterGroupData<ServantSubAttribute>();

  final miscStatus = FilterRadioData<SvtStatusMiscType>();
  final planCompletion = FilterGroupData<SvtPlanScope>();
  final curStatus = FilterGroupData<SvtStatusState>();
  final priority = FilterGroupData<int>(
    onChanged: () {
      db.itemCenter.updateSvts(all: true);
    },
  );

  final bondCompare = FilterGroupData<CompareOperator>(options: {CompareOperator.lessThan});
  final bondValue = FilterRadioData<int>();
  final region = FilterRadioData<Region>();
  final obtain = FilterGroupData<SvtObtain>();
  final tdCardType = FilterGroupData<int>();
  final tdType = FilterGroupData<TdEffectFlag>();
  final policy = FilterGroupData<ServantPolicy>(); //秩序 混沌 中庸
  final personality = FilterGroupData<ServantPersonality>(); //善 恶 中立 夏 狂...
  final gender = FilterGroupData<Gender>();
  final trait = FilterGroupData<Trait>();
  final cardDeck = FilterGroupData<CardDeckType>();

  final effectScope = FilterGroupData<SvtEffectScope>(options: {SvtEffectScope.active, SvtEffectScope.td});
  final effectTarget = FilterGroupData<EffectTarget>();
  final targetTrait = FilterGroupData<int>();
  final effectType = FilterGroupData<SkillEffect>();
  final freeExchangeSvtEvent = FilterRadioData<Event>();
  bool isEventSvt = false;

  SvtFilterData({
    this.useGrid = false,
    this.favorite = FavoriteState.all,
    this.planFavorite = FavoriteState.all,
    List<SvtCompare?>? sortKeys,
    List<bool?>? sortReversed,
  }) : sortKeys = List.generate(
         SvtCompare.values.length,
         (index) => sortKeys?.getOrNull(index) ?? SvtCompare.collectionNo,
         growable: false,
       ),
       sortReversed = List.generate(
         SvtCompare.values.length,
         (index) => sortReversed?.getOrNull(index),
         growable: false,
       );

  @override
  List<FilterGroupData> get groups => [
    svtClass,
    rarity,
    attribute,
    curStatus,
    planCompletion,
    miscStatus,
    // bondCompare,
    bondValue,
    // priority,
    region,
    obtain,
    tdCardType,
    tdType,
    policy,
    personality,
    gender,
    trait,
    cardDeck,
    effectScope,
    effectTarget,
    targetTrait,
    effectType,
    freeExchangeSvtEvent,
  ];

  @override
  void reset() {
    super.reset();
    effectScope.options = {SvtEffectScope.active, SvtEffectScope.td};
    isEventSvt = false;
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region != Region.jp) {
        region.set(db.curUser.region);
      }
    }
  }

  factory SvtFilterData.fromJson(Map<String, dynamic> data) => _$SvtFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtFilterDataToJson(this);

  static int compareId(
    int a,
    int b, {
    List<SvtCompare>? keys = SvtCompare.kRarityFirstKeys,
    List<bool?>? reversed,
    User? user,
  }) {
    final aa = db.gameData.servantsById[a], bb = db.gameData.servantsById[b];
    if (aa == null && bb == null) return a.compareTo(b);
    return compare(aa, bb, keys: keys, reversed: reversed, user: user);
  }

  static int compare(
    Servant? a,
    Servant? b, {
    List<SvtCompare>? keys = SvtCompare.kRarityFirstKeys,
    List<bool?>? reversed,
    User? user,
  }) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    user ??= db.curUser;

    keys ??= [];
    if (!keys.contains(SvtCompare.collectionNo)) {
      keys = [...keys, SvtCompare.collectionNo];
    }
    int _classSortKey(int clsId) {
      if (db.gameData.constData.classInfo.isNotEmpty) {
        return -(db.gameData.constData.classInfo[clsId]?.priority ?? 0);
      }
      int k = SvtClassX.regularAllWithBeasts.map((e) => e.value).toList().indexOf(clsId);
      return k < 0 ? 999 + clsId : k;
    }

    for (final (i, key) in keys.indexed) {
      int r;
      switch (keys[i]) {
        case SvtCompare.collectionNo:
          r = a.originalCollectionNo - b.originalCollectionNo;
          if (r == 0) r = a.collectionNo - b.collectionNo;
          if (r == 0) r = a.id - b.id;
          break;
        case SvtCompare.className:
          r = _classSortKey(a.classId) - _classSortKey(b.classId);
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
          final aa = user.svtStatusOf(a.collectionNo), bb = user.svtStatusOf(b.collectionNo);
          r = (aa.priority) - (bb.priority);
          break;
        case SvtCompare.tdLv:
          final aa = user.svtStatusOf(a.collectionNo).cur.npLv, bb = user.svtStatusOf(b.collectionNo).cur.npLv;
          r = aa - bb;
          break;
        case SvtCompare.bondLv:
          final aa = user.svtStatusOf(a.collectionNo).bond, bb = user.svtStatusOf(b.collectionNo).bond;
          r = aa - bb;
          break;
      }
      if (r != 0) {
        return (reversed?.getOrNull(i) ?? key.defaultReversed) ? -r : r;
      }
    }
    return 0;
  }
}

/// Craft Essence

enum CraftCompare {
  collectionNo(true),
  rarity(true),
  atk(true),
  hp(true);

  const CraftCompare(this.defaultReversed);
  final bool defaultReversed;

  static const kRarityFirstKeys = [CraftCompare.rarity, CraftCompare.collectionNo];

  String get shownName => switch (this) {
    CraftCompare.collectionNo => S.current.filter_sort_number,
    CraftCompare.rarity => S.current.filter_sort_rarity,
    CraftCompare.atk => 'ATK',
    CraftCompare.hp => 'HP',
  };
}

enum CraftATKType {
  none,
  hp,
  atk,
  mix;

  String get shownName => name.toUpperCase();
}

@JsonSerializable(ignoreUnannotated: true)
class CraftFilterData with FilterDataMixin {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  List<CraftCompare> sortKeys;
  @JsonKey()
  List<bool?> sortReversed;

  // filter
  final rarity = FilterGroupData<int>();
  final region = FilterRadioData<Region>();
  final obtain = FilterGroupData<CEObtain>();
  final atkType = FilterGroupData<CraftATKType>();
  final limitCount = FilterGroupData<int>();
  final status = FilterGroupData<int>();
  final effectTarget = FilterGroupData<EffectTarget>();
  final targetTrait = FilterGroupData<int>();
  final effectType = FilterGroupData<SkillEffect>();
  final isEventEffect = FilterGroupData<bool>();

  CraftFilterData({this.useGrid = false, List<CraftCompare?>? sortKeys, List<bool?>? sortReversed})
    : sortKeys = List.generate(
        CraftCompare.values.length,
        (index) => sortKeys?.getOrNull(index) ?? CraftCompare.collectionNo,
        growable: false,
      ),
      sortReversed = List.generate(
        CraftCompare.values.length,
        (index) => sortReversed?.getOrNull(index),
        growable: false,
      );

  @override
  List<FilterGroupData> get groups => [
    rarity,
    region,
    obtain,
    atkType,
    limitCount,
    status,
    effectTarget,
    targetTrait,
    effectType,
    isEventEffect,
  ];

  @override
  void reset() {
    super.reset();
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region != Region.jp) {
        region.set(db.curUser.region);
      }
    }
  }

  factory CraftFilterData.fromJson(Map<String, dynamic> data) => _$CraftFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CraftFilterDataToJson(this);

  static int compare(
    CraftEssence? a,
    CraftEssence? b, {
    List<CraftCompare>? keys = CraftCompare.kRarityFirstKeys,
    List<bool?>? reversed,
  }) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    keys ??= [];

    if (!keys.contains(CraftCompare.collectionNo)) {
      keys = [...keys, CraftCompare.collectionNo];
    }
    for (final (index, key) in keys.indexed) {
      int r = switch (key) {
        CraftCompare.collectionNo => (a.sortId ?? a.collectionNo).compareTo((b.sortId ?? b.collectionNo)),
        CraftCompare.rarity => a.rarity - b.rarity,
        CraftCompare.atk => a.atkMax - b.atkMax,
        CraftCompare.hp => a.hpMax - b.hpMax,
      };
      if (r != 0) {
        return (reversed?.getOrNull(index) ?? key.defaultReversed) ? -r : r;
      }
    }
    return 0;
  }
}

/// Command Code
enum CmdCodeCompare {
  no,
  rarity;

  String get shownName => switch (this) {
    CmdCodeCompare.no => S.current.filter_sort_number,
    CmdCodeCompare.rarity => S.current.filter_sort_rarity,
  };
}

@JsonSerializable(ignoreUnannotated: true)
class CmdCodeFilterData with FilterDataMixin {
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
  final targetTrait = FilterGroupData<int>();
  final effectType = FilterGroupData<SkillEffect>();
  final status = FilterGroupData<int>();

  CmdCodeFilterData({
    this.useGrid = false,
    this.favorite = false,
    List<CmdCodeCompare?>? sortKeys,
    List<bool?>? sortReversed,
  }) : sortKeys = List.generate(
         CmdCodeCompare.values.length,
         (index) => sortKeys?.getOrNull(index) ?? CmdCodeCompare.values[index],
         growable: false,
       ),
       sortReversed = List.generate(
         CmdCodeCompare.values.length,
         (index) => sortReversed?.getOrNull(index) ?? true,
         growable: false,
       );

  @override
  List<FilterGroupData> get groups => [rarity, region, effectTarget, targetTrait, effectType, status];

  @override
  void reset() {
    super.reset();
    favorite = false;
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region != Region.jp) {
        region.set(db.curUser.region);
      }
    }
  }

  factory CmdCodeFilterData.fromJson(Map<String, dynamic> data) => _$CmdCodeFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$CmdCodeFilterDataToJson(this);

  static int compare(CommandCode a, CommandCode b, {List<CmdCodeCompare>? keys, List<bool>? reversed}) {
    if (keys == null || keys.isEmpty) {
      keys = [CmdCodeCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r = switch (keys[i]) {
        CmdCodeCompare.no => a.collectionNo - b.collectionNo,
        CmdCodeCompare.rarity => a.rarity - b.rarity,
      };
      if (r != 0) {
        return (reversed?.getOrNull(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

@JsonSerializable(ignoreUnannotated: true)
class MysticCodeFilterData with FilterDataMixin {
  @JsonKey()
  bool useGrid;
  @JsonKey()
  bool favorite;
  @JsonKey()
  bool ascending;

  // filter
  final region = FilterRadioData<Region>();
  final effectTarget = FilterGroupData<EffectTarget>();
  final targetTrait = FilterGroupData<int>();
  final effectType = FilterGroupData<SkillEffect>();

  MysticCodeFilterData({this.useGrid = false, this.favorite = false, this.ascending = true});

  @override
  List<FilterGroupData> get groups => [region, effectTarget, targetTrait, effectType];

  @override
  void reset() {
    super.reset();
    favorite = false;
  }

  factory MysticCodeFilterData.fromJson(Map<String, dynamic> data) => _$MysticCodeFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$MysticCodeFilterDataToJson(this);
}

enum FavoriteState {
  all,
  owned,
  other;

  IconData get icon => switch (this) {
    FavoriteState.all => Icons.remove_circle_outline,
    FavoriteState.owned => Icons.favorite,
    FavoriteState.other => Icons.favorite_border,
  };

  String get shownName => switch (this) {
    FavoriteState.all => S.current.general_all,
    FavoriteState.owned => S.current.item_own,
    FavoriteState.other => S.current.general_others,
  };

  bool check(bool favorite) => switch (this) {
    FavoriteState.all => true,
    FavoriteState.owned => favorite,
    FavoriteState.other => !favorite,
  };
}

// event
@JsonSerializable()
class EventFilterData with FilterDataMixin {
  bool reversed;
  bool showOutdated;
  bool showSpecialRewards;
  bool showEmpty;
  bool showMcCampaign;
  bool showBanner;

  // filter
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ongoing = FilterGroupData<Region?>();
  @JsonKey(includeFromJson: false, includeToJson: false)
  final contentType = FilterGroupData<EventCustomType>();
  @JsonKey(includeFromJson: false, includeToJson: false)
  final eventType = FilterGroupData<EventType>();
  @JsonKey(includeFromJson: false, includeToJson: false)
  final campaignType = FilterGroupData<CombineAdjustTarget>();

  EventFilterData({
    this.reversed = false,
    this.showOutdated = false,
    this.showSpecialRewards = false,
    this.showMcCampaign = false,
    this.showEmpty = false,
    this.showBanner = true,
  });

  @override
  void reset() {
    super.reset();
    showSpecialRewards = false;
    showEmpty = false;
  }

  @override
  List<FilterGroupData> get groups => [ongoing, contentType, eventType, campaignType];

  factory EventFilterData.fromJson(Map<String, dynamic> data) => _$EventFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$EventFilterDataToJson(this);
}

enum EventCustomType {
  mainInterlude,
  hunting,
  warBoard,
  lottery,
  mission,
  raid,
  // randomMission,
  shop,
  point,
  tower,
  // treasureBox,
  // digging,
  // cooltime,
  // recipe,
  bulletinBoard,
  exchangeSvt,
  special,
  others,
}

// summon

@JsonSerializable(checked: true, ignoreUnannotated: true)
class SummonFilterData with FilterDataMixin {
  @JsonKey()
  bool favorite;
  @JsonKey()
  bool reversed;
  @JsonKey()
  bool showBanner;
  @JsonKey()
  bool showOutdated;
  @JsonKey()
  bool sortByClosed;

  final category = FilterGroupData<SummonType>();
  final gachaType = FilterGroupData<GachaType>();

  SummonFilterData({
    this.favorite = false,
    this.reversed = true,
    this.showBanner = false,
    this.showOutdated = false,
    this.sortByClosed = false,
  });

  @override
  List<FilterGroupData> get groups => [category, gachaType];

  @override
  void reset() {
    super.reset();
    favorite = false;
    showOutdated = false;
    sortByClosed = false;
  }

  factory SummonFilterData.fromJson(Map<String, dynamic> data) => _$SummonFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$SummonFilterDataToJson(this);
}

@JsonSerializable()
class ScriptReaderFilterData {
  bool scene;
  bool soundEffect;
  bool bgm;
  bool voice;
  bool video;

  bool autoPlayVideo;

  ScriptReaderFilterData({
    this.scene = true,
    this.soundEffect = true,
    this.bgm = true,
    this.voice = true,
    this.video = true,
    this.autoPlayVideo = true,
  });

  void reset() {
    soundEffect = bgm = scene = voice = video = autoPlayVideo = true;
  }

  factory ScriptReaderFilterData.fromJson(Map<String, dynamic> data) => _$ScriptReaderFilterDataFromJson(data);

  Map<String, dynamic> toJson() => _$ScriptReaderFilterDataToJson(this);
}

class EnemyFilterData with FilterDataMixin {
  bool useGrid;
  List<SvtCompare> sortKeys;
  List<bool> sortReversed;

  static const enemyCompares = [SvtCompare.collectionNo, SvtCompare.className, SvtCompare.rarity];

  bool onlyShowQuestEnemy;
  // filter
  final region = FilterRadioData<Region>();
  final svtClass = FilterGroupData<SvtClass>();
  final attribute = FilterGroupData<ServantSubAttribute>();
  final svtType = FilterGroupData<SvtType>();
  final trait = FilterGroupData<int>();

  EnemyFilterData({
    this.useGrid = false,
    this.onlyShowQuestEnemy = false,
    List<SvtCompare?>? sortKeys,
    List<bool?>? sortReversed,
  }) : sortKeys = List.generate(
         enemyCompares.length,
         (index) => sortKeys?.getOrNull(index) ?? enemyCompares[index],
         growable: false,
       ),
       sortReversed = List.generate(
         enemyCompares.length,
         (index) => sortReversed?.getOrNull(index) ?? true,
         growable: false,
       );

  @override
  List<FilterGroupData> get groups => [region, svtClass, attribute, svtType, trait];

  @override
  void reset() {
    super.reset();
    if (db.settings.hideUnreleasedCard) {
      if (db.curUser.region != Region.jp) {
        region.set(db.curUser.region);
      }
    } else if (db.settings.spoilerRegion != Region.jp) {
      region.set(db.settings.spoilerRegion);
    }
  }

  // factory EnemyFilterData.fromJson(Map<String, dynamic> data) =>
  //     _$EnemyFilterDataFromJson(data);

  // Map<String, dynamic> toJson() => _$EnemyFilterDataToJson(this);

  static int compare(BasicServant? a, BasicServant? b, {List<SvtCompare>? keys, List<bool>? reversed}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.collectionNo];
    }
    int _classSortKey(int clsId) {
      final p = db.gameData.constData.classInfo[clsId]?.priority;
      return p ?? -clsId;
    }

    for (var i = 0; i < keys.length; i++) {
      int r = switch (keys[i]) {
        SvtCompare.collectionNo => a.id - b.id,
        SvtCompare.className => _classSortKey(a.classId) - _classSortKey(b.classId),
        SvtCompare.rarity => a.rarity - b.rarity,
        _ => 0,
      };
      if (r != 0) {
        return (reversed?.getOrNull(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

class FfoPartFilterData with FilterDataMixin {
  static const kSortKeys = [SvtCompare.collectionNo, SvtCompare.className, SvtCompare.rarity];

  bool useGrid = false;
  final rarity = FilterGroupData<int>();
  final classType = FilterGroupData<SvtClass>();
  List<SvtCompare> sortKeys = List.of(kSortKeys);
  List<bool> sortReversed = [false, false, true];

  @override
  List<FilterGroupData> get groups => [rarity, classType];

  static int compare(FfoSvt? a, FfoSvt? b, {List<SvtCompare>? keys, List<bool>? reversed}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.collectionNo];
    }
    int _classSortKey(SvtClass? cls) {
      int k = cls == null ? -1 : SvtClassX.regularAll.indexOf(cls);
      return k < 0 ? 999 : k;
    }

    for (var i = 0; i < keys.length; i++) {
      int r = switch (keys[i]) {
        SvtCompare.collectionNo => a.collectionNo - b.collectionNo,
        SvtCompare.className => _classSortKey(a.svtClass) - _classSortKey(b.svtClass),
        SvtCompare.rarity => a.rarity - b.rarity,
        _ => 0,
      };
      if (r != 0) {
        return (reversed?.getOrNull(i) ?? false) ? -r : r;
      }
    }
    return 0;
  }
}

// enums

/// Servant
enum SvtCompare {
  collectionNo(true),
  className(false),
  rarity(true),
  atk(true),
  hp(true),
  priority(true),
  tdLv(true),
  bondLv(true);

  const SvtCompare(this.defaultReversed);
  final bool defaultReversed;

  static const kRarityFirstKeys = <SvtCompare>[SvtCompare.rarity, SvtCompare.className, SvtCompare.collectionNo];
  static const kClassFirstKeys = <SvtCompare>[SvtCompare.className, SvtCompare.rarity, SvtCompare.collectionNo];

  String get showName {
    return switch (this) {
      SvtCompare.collectionNo => S.current.filter_sort_number,
      SvtCompare.className => S.current.svt_class,
      SvtCompare.rarity => S.current.filter_sort_rarity,
      SvtCompare.atk => 'ATK',
      SvtCompare.hp => 'HP',
      SvtCompare.priority => S.current.priority,
      SvtCompare.tdLv => '${S.current.np_short} Lv',
      SvtCompare.bondLv => '${S.current.bond} Lv',
    };
  }
}

enum SvtEffectScope {
  active,
  passive,
  append,
  td;

  String get shownName => switch (this) {
    SvtEffectScope.active => S.current.active_skill_short,
    SvtEffectScope.passive => S.current.passive_skill_short,
    SvtEffectScope.append => S.current.append_skill_short,
    SvtEffectScope.td => S.current.np_short,
  };
}

enum EffectTarget {
  self,
  ptAll, //ptFull
  ptOne,
  ptOther, //ptOtherFull
  enemy,
  enemyAll,
  special;

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

enum SvtPlanScope {
  all,
  ascension,
  active,
  append,
  costume,
  bond,
  misc, //fou, grail, bond
}

enum SvtStatusState {
  asc3,
  asc4,
  active8,
  active9,
  active10,
  appendTwo8,
  appendTwo9,
  // appendTwo10,
  append8,
  append9
  // append10
  ;

  String get shownName => switch (this) {
    asc3 => '<4',
    asc4 => '=4',
    active8 => '<9/9/9',
    active9 => '9/9/9',
    active10 => '10/10/10',
    appendTwo8 => 'A2|<9',
    appendTwo9 => 'A2|≥9',
    // appendTwo10 => 'A2|10',
    append8 => 'A|<9',
    append9 => 'A|≥9',
    // append10 => 'A|≥10',
  };
}

enum SvtStatusMiscType {
  primarySvt,
  secondarySvt,
  grandSvt;

  String get shownName => switch (this) {
    primarySvt => S.current.duplicated_servant_primary,
    secondarySvt => S.current.duplicated_servant_duplicated,
    grandSvt => S.current.grand_servant,
  };
}

enum CompareOperator {
  lessThan('<', -1),
  moreThan('>', 1),
  equal('=', 0);

  final String text;
  final int value;
  const CompareOperator(this.text, this.value);

  bool test<T extends Comparable>(T left, T right) {
    return left.compareTo(right).sign == value;
  }
}

enum SvtBondStage {
  lessThan5('<5'),
  lessThan6('<6'),
  lessThan10('<10'),
  greaterThan10('≤15');

  final String text;
  const SvtBondStage(this.text);

  static SvtBondStage fromBond(int bond) {
    if (bond < 5) return lessThan5;
    if (bond < 6) return lessThan6;
    if (bond < 10) return lessThan10;
    return greaterThan10;
  }
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

enum CardDeckType {
  q1a1b3(1, 1, 3),
  q1a2b2(1, 2, 2),
  q1a3b1(1, 3, 1),
  q2a1b2(2, 1, 2),
  q2a2b1(2, 2, 1),
  q3a1b1(3, 1, 1),
  others(-1, -1, -1);

  const CardDeckType(this.q, this.a, this.b);
  final int q;
  final int a;
  final int b;

  static CardDeckType resolve(List<int> cards) {
    int q = cards.where(CardType.isQuick).length;
    int a = cards.where(CardType.isArts).length;
    int b = cards.where(CardType.isBuster).length;
    return CardDeckType.values.firstWhere((e) => e.q == q && e.a == a && e.b == b, orElse: () => CardDeckType.others);
  }
}
