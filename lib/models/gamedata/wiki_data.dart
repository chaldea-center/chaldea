import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/userdata/userdata.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:chaldea/utils/extension.dart';
import '../db.dart';
import 'servant.dart';
import 'skill.dart';

part '../../generated/models/gamedata/wiki_data.g.dart';

class Transl<K, V> {
  final Map<K, MappingBase<V>> mappings;
  final MappingBase<V>? _m;
  final K key;
  final V _default;

  Transl(this.mappings, this.key, this._default) : _m = mappings[key];

  V get jp => mappings[key]?.jp ?? _default;

  V get cn => mappings[key]?.cn ?? _default;

  V get tw => mappings[key]?.tw ?? _default;

  V get na => mappings[key]?.na ?? _default;

  V get kr => mappings[key]?.kr ?? _default;

  MappingBase<V>? get m => mappings[key];

  static bool get isJP =>
      db2.settings.resolvedPreferredRegions.first == Region.jp;

  static get isCN => db2.settings.resolvedPreferredRegions.first == Region.cn;

  static get isEN => db2.settings.resolvedPreferredRegions.first == Region.na;

  V get l {
    for (final region in db2.settings.resolvedPreferredRegions) {
      final v = mappings[key]?.ofRegion(region);
      if (v != null) return v;
    }
    return _default;
  }

  List<V?> get all => [_m?.jp, _m?.cn, _m?.tw, _m?.na, _m?.kr];

  @override
  String toString() {
    return '$runtimeType($key)';
  }

  static MappingData get _md => db2.gameData.mappingData;

  Transl.fromMapping(this.key, MappingBase<V> m, this._default)
      : _m = m,
        mappings = {key: m};

  static Transl<int, String> trait(int id) => Transl(_md.trait, id, '$id');
  static Transl<int, String> svtClass(int id) =>
      Transl(_md.svtClass, id, '$id');

  static Transl<String, String> itemNames(String jp) =>
      Transl(_md.itemNames, jp, jp);

  static Transl<String, String> mcNames(String jp) =>
      Transl(_md.mcNames, jp, jp);

  static Transl<String, String> costumeNames(String jp) =>
      Transl(_md.costumeNames, jp, jp);

  static Transl<int, String> costumeDetail(int id) =>
      Transl(_md.costumeDetail, id, db2.gameData.costumes[id]?.detail ?? '???');

  static Transl<String, String> cvNames(String jp) =>
      Transl(_md.cvNames, jp, jp);

  static Transl<String, String> illustratorNames(String jp) =>
      Transl(_md.illustratorNames, jp, jp);

  static Transl<String, String> ccNames(String jp) =>
      Transl(_md.ccNames, jp, jp);

  static Transl<String, String> svtNames(String jp) =>
      Transl(_md.svtNames, jp, jp);

  static Transl<String, String> ceNames(String jp) =>
      Transl(_md.ceNames, jp, jp);

  static Transl<String, String> eventNames(String jp) =>
      Transl(_md.eventNames, jp, jp);

  static Transl<String, String> warNames(String jp) =>
      Transl(_md.warNames, jp, jp);

  static Transl<String, String> questNames(String jp) =>
      Transl(_md.questNames, jp, jp);

  static Transl<String, String> spotNames(String jp) =>
      Transl(_md.spotNames, jp, jp);

  static Transl<String, String> entityNames(String jp) =>
      Transl(_md.entityNames, jp, jp);

  static Transl<String, String> tdTypes(String jp) =>
      Transl(_md.tdTypes, jp, jp);

  static Transl<String, String> bgmNames(String jp) =>
      Transl(_md.bgmNames, jp, jp);

  static Transl<String, String> summonNames(String jp) =>
      Transl(_md.summonNames, jp, jp);

  static Transl<String, String> charaNames(String cn) =>
      Transl(_md.charaNames, cn, cn);

  static Transl<String, String> buffNames(String jp) =>
      Transl(_md.buffNames, jp, jp);

  static Transl<String, String> buffDetail(String jp) =>
      Transl(_md.buffDetail, jp, jp);

  static Transl<String, String> funcPopuptext(String jp, [FuncType? type]) {
    if ({'', '-', 'なし', 'None', 'none'}.contains(jp) && type != null) {
      return Transl(_md.funcPopuptext, type.name, type.name);
    }
    return Transl(_md.funcPopuptext, jp, jp);
  }

  static Transl<String, String> skillNames(String jp) =>
      Transl(_md.skillNames, jp, jp);

  static Transl<String, String> skillDetail(String jp) =>
      Transl(_md.skillDetail, jp, jp);

  static Transl<String, String> tdNames(String jp) =>
      Transl(_md.tdNames, jp, jp);

  static Transl<String, String> tdRuby(String jp) => Transl(_md.tdRuby, jp, jp);

  static Transl<String, String> tdDetail(String jp) =>
      Transl(_md.tdDetail, jp, jp);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MappingData {
  final Map<String, MappingBase<String>> itemNames;
  final Map<String, MappingBase<String>> mcNames;
  final Map<String, MappingBase<String>> costumeNames;
  final Map<String, MappingBase<String>> cvNames;
  final Map<String, MappingBase<String>> illustratorNames;
  final Map<String, MappingBase<String>> ccNames;
  final Map<String, MappingBase<String>> svtNames;
  final Map<String, MappingBase<String>> ceNames;
  final Map<String, MappingBase<String>> eventNames;
  final Map<String, MappingBase<String>> warNames;
  final Map<String, MappingBase<String>> questNames;
  final Map<String, MappingBase<String>> spotNames;
  final Map<String, MappingBase<String>> entityNames;
  final Map<String, MappingBase<String>> tdTypes;
  final Map<String, MappingBase<String>> bgmNames;
  final Map<String, MappingBase<String>> summonNames; //
  final Map<String, MappingBase<String>> charaNames; // key: cn
  final Map<String, MappingBase<String>> buffNames;
  final Map<String, MappingBase<String>> buffDetail;
  final Map<String, MappingBase<String>> funcPopuptext;
  final Map<String, MappingBase<String>> skillNames;
  final Map<String, MappingBase<String>> skillDetail;
  final Map<String, MappingBase<String>> tdNames;
  final Map<String, MappingBase<String>> tdRuby;
  final Map<String, MappingBase<String>> tdDetail;
  final Map<int, MappingBase<String>> trait; // key: trait id
  final Map<int, MappingBase<String>> svtClass; // key: class id
  final Map<int, MappingBase<String>> mcDetail; // key: mc id
  final Map<int, MappingBase<String>> costumeDetail; // costume collectionNo
  final Map<int, MappingDict<int>> skillState;
  final Map<int, MappingDict<int>> tdState;
  final MappingList<int> svtRelease;
  final MappingList<int> ceRelease;
  final MappingList<int> ccRelease;

  MappingData({
    this.itemNames = const {},
    this.mcNames = const {},
    this.costumeNames = const {},
    this.cvNames = const {},
    this.illustratorNames = const {},
    this.ccNames = const {},
    this.svtNames = const {},
    this.ceNames = const {},
    this.eventNames = const {},
    this.warNames = const {},
    this.questNames = const {},
    this.spotNames = const {},
    this.entityNames = const {},
    this.tdTypes = const {},
    this.bgmNames = const {},
    this.summonNames = const {},
    this.charaNames = const {},
    this.buffNames = const {},
    this.buffDetail = const {},
    this.funcPopuptext = const {},
    Map<String, MappingBase<String>>? skillNames,
    this.skillDetail = const {},
    this.tdNames = const {},
    this.tdRuby = const {},
    this.tdDetail = const {},
    this.trait = const {},
    this.svtClass = const {},
    this.mcDetail = const {},
    this.costumeDetail = const {},
    this.skillState = const {},
    this.tdState = const {},
    MappingList<int>? svtRelease,
    MappingList<int>? ceRelease,
    MappingList<int>? ccRelease,
  })  : skillNames = skillNames ?? {},
        svtRelease = svtRelease ?? MappingList(),
        ceRelease = ceRelease ?? MappingList(),
        ccRelease = ccRelease ?? MappingList() {
    _updateRegion(itemNames, Region.jp);
    _updateRegion(mcNames, Region.jp);
    _updateRegion(costumeNames, Region.jp);
    _updateRegion(cvNames, Region.jp);
    _updateRegion(illustratorNames, Region.jp);
    _updateRegion(ccNames, Region.jp);
    _updateRegion(svtNames, Region.jp);
    _updateRegion(ceNames, Region.jp);
    _updateRegion(eventNames, Region.jp);
    _updateRegion(warNames, Region.jp);
    _updateRegion(questNames, Region.jp);
    _updateRegion(spotNames, Region.jp);
    _updateRegion(entityNames, Region.jp);
    _updateRegion(tdTypes, Region.jp);
    _updateRegion(bgmNames, Region.jp);
    _updateRegion(summonNames, Region.cn);
    _updateRegion(charaNames, Region.cn);
    _updateRegion(buffNames, Region.jp);
    _updateRegion(buffDetail, Region.jp);
    _updateRegion(funcPopuptext, Region.jp);

    this.skillNames
      ..addAll(ceNames)
      ..addAll(ccNames);
    _updateRegion(this.skillNames, Region.jp);
    _updateRegion(skillDetail, Region.jp);
    _updateRegion(tdNames, Region.jp);
    _updateRegion(tdRuby, Region.jp);
    _updateRegion(tdDetail, Region.jp);
  }

  static void _updateRegion<T>(Map<T, MappingBase<T>> mapping, Region region) {
    mapping.forEach((key, value) {
      value.update(key, region);
    });
  }

  factory MappingData.fromJson(Map<String, dynamic> json) =>
      _$MappingDataFromJson(json);
}

/// Shortcut for [MappingBase]
class M {
  const M._();

  static T of<T>({T? jp, T? cn, T? tw, T? na, T? kr, T? k}) {
    return MappingBase(jp: jp, cn: cn, tw: tw, na: na, kr: kr).l ?? k!;
  }
}

T _fromJsonT<T>(Object? obj) {
  return obj as T;
}

@JsonSerializable(genericArgumentFactories: true)
class MappingBase<T> {
  @JsonKey(name: 'JP')
  T? jp;
  @JsonKey(name: 'CN')
  T? cn;
  @JsonKey(name: 'TW')
  T? tw;
  @JsonKey(name: 'NA')
  T? na;
  @JsonKey(name: 'KR')
  T? kr;

  List<T?> get values => [jp, cn, tw, na, kr];

  MappingBase({
    this.jp,
    this.cn,
    this.tw,
    this.na,
    this.kr,
  });

  T? get l {
    for (final region in db2.settings.resolvedPreferredRegions) {
      final v = ofRegion(region);
      if (v != null) return v;
    }
    return null;
  }

  T? ofRegion(Region region) {
    switch (region) {
      case Region.jp:
        return jp;
      case Region.cn:
        return cn;
      case Region.tw:
        return tw;
      case Region.na:
        return na;
      case Region.kr:
        return kr;
    }
  }

  static T? of<T>({T? jp, T? cn, T? tw, T? na, T? kr}) {
    return MappingBase(jp: jp, cn: cn, tw: tw, na: na, kr: kr).l;
  }

  void update(T? value, Region region, [bool skipExist = false]) {
    switch (region) {
      case Region.jp:
        jp = skipExist ? jp ?? value : value;
        break;
      case Region.cn:
        cn = skipExist ? cn ?? value : value;
        break;
      case Region.tw:
        tw = skipExist ? tw ?? value : value;
        break;
      case Region.na:
        na = skipExist ? na ?? value : value;
        break;
      case Region.kr:
        kr = skipExist ? kr ?? value : value;
        break;
    }
  }

  factory MappingBase.fromJson(Map<String, dynamic> json) =>
      _$MappingBaseFromJson(json, _fromJsonT);

  MappingBase<T> copyWith({
    T? jp,
    T? cn,
    T? tw,
    T? na,
    T? kr,
  }) {
    return MappingBase<T>(
      jp: jp ?? this.jp,
      cn: cn ?? this.cn,
      tw: tw ?? this.tw,
      na: na ?? this.na,
      kr: kr ?? this.kr,
    );
  }
}

@JsonSerializable(genericArgumentFactories: true)
class MappingList<T> extends MappingBase<List<T>> {
  MappingList({
    List<T>? jp,
    List<T>? cn,
    List<T>? tw,
    List<T>? na,
    List<T>? kr,
  }) : super(jp: jp, cn: cn, tw: tw, na: na, kr: kr);

  factory MappingList.fromJson(Map<String, dynamic> json) =>
      _$MappingListFromJson(json, _fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class MappingDict<V> extends MappingBase<Map<int, V>> {
  MappingDict({
    Map<int, V>? jp,
    Map<int, V>? cn,
    Map<int, V>? tw,
    Map<int, V>? na,
    Map<int, V>? kr,
  }) : super(jp: jp, cn: cn, tw: tw, na: na, kr: kr);

  factory MappingDict.fromJson(Map<String, dynamic> json) =>
      _$MappingDictFromJson(json, _fromJsonT);
}

@JsonSerializable()
class WikiData {
  final Map<int, ServantExtra> servants;
  final Map<int, CraftEssenceExtra> craftEssences;
  final Map<int, CommandCodeExtra> commandCodes;
  final Map<int, EventExtra> events;
  final Map<int, WarExtra> wars;
  final Map<String, LimitedSummon> summons;
  final Map<int, int> webcrowMapping;

  WikiData({
    Map<int, ServantExtra>? servants,
    Map<int, CraftEssenceExtra>? craftEssences,
    Map<int, CommandCodeExtra>? commandCodes,
    Map<int, EventExtra>? events,
    Map<int, WarExtra>? wars,
    Map<String, LimitedSummon>? summons,
    this.webcrowMapping = const {},
  })  : servants = servants ?? {},
        craftEssences = craftEssences ?? {},
        commandCodes = commandCodes ?? {},
        events = events ?? {},
        summons = summons ?? {},
        wars = wars ?? {};

  factory WikiData.fromJson(Map<String, dynamic> json) =>
      _$WikiDataFromJson(json);
}

@JsonSerializable()
class ServantExtra {
  int collectionNo;
  List<String> nameOther;
  List<SvtObtain> obtains;
  List<String> aprilFoolAssets;
  MappingBase<String> aprilFoolProfile;
  String? mcLink;
  String? fandomLink;

  ServantExtra({
    required this.collectionNo,
    this.nameOther = const [],
    this.obtains = const [],
    this.aprilFoolAssets = const [],
    MappingBase<String>? aprilFoolProfile,
    this.mcLink,
    this.fandomLink,
  }) : aprilFoolProfile = aprilFoolProfile ?? MappingBase();

  factory ServantExtra.fromJson(Map<String, dynamic> json) =>
      _$ServantExtraFromJson(json);
}

@JsonSerializable()
class CraftEssenceExtra {
  int collectionNo;
  CEObtain obtain;
  MappingBase<String> profile;
  List<int> characters;
  List<String> unknownCharacters;
  String? mcLink;
  String? fandomLink;

  CraftEssenceExtra({
    required this.collectionNo,
    this.obtain = CEObtain.unknown,
    MappingBase<String>? profile,
    this.characters = const [],
    this.unknownCharacters = const [],
    this.mcLink,
    this.fandomLink,
  }) : profile = profile ?? MappingBase();

  factory CraftEssenceExtra.fromJson(Map<String, dynamic> json) =>
      _$CraftEssenceExtraFromJson(json);
}

@JsonSerializable()
class CommandCodeExtra {
  int collectionNo;
  MappingBase<String> profile;
  List<int> characters;
  List<String> unknownCharacters;
  String? mcLink;
  String? fandomLink;

  CommandCodeExtra({
    required this.collectionNo,
    MappingBase<String>? profile,
    this.characters = const [],
    this.unknownCharacters = const [],
    this.mcLink,
    this.fandomLink,
  }) : profile = profile ?? MappingBase();

  factory CommandCodeExtra.fromJson(Map<String, dynamic> json) =>
      _$CommandCodeExtraFromJson(json);
}

@JsonSerializable()
class EventExtraItems {
  int id;
  String? detail;
  Map<int, String> items;

  EventExtraItems({
    required this.id,
    this.detail,
    this.items = const {},
  });

  factory EventExtraItems.fromJson(Map<String, dynamic> json) =>
      _$EventExtraItemsFromJson(json);
}

@JsonSerializable()
class EventExtra {
  int id;
  String name;
  String? mcLink;
  String? fandomLink;
  MappingBase<String> titleBanner;
  MappingBase<String> noticeLink;
  List<int> huntingQuestIds;
  List<EventExtraItems> extraItems;

  MappingBase<int> startTime;
  MappingBase<int> endTime;
  int rarePrism;
  int grail;
  int crystal;
  int grail2crystal;
  int foukun4;
  List<String> relatedSummons;

  EventExtra({
    required this.id,
    required this.name,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? titleBanner,
    MappingBase<String>? noticeLink,
    this.huntingQuestIds = const [],
    this.extraItems = const [],
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
    this.rarePrism = 0,
    this.grail = 0,
    this.crystal = 0,
    this.grail2crystal = 0,
    this.foukun4 = 0,
    this.relatedSummons = const [],
  })  : titleBanner = titleBanner ?? MappingBase(),
        noticeLink = noticeLink ?? MappingBase(),
        startTime = startTime ?? MappingBase(),
        endTime = endTime ?? MappingBase();

  factory EventExtra.fromJson(Map<String, dynamic> json) =>
      _$EventExtraFromJson(json);
}

@JsonSerializable()
class WarExtra {
  int id;
  String? mcLink;
  String? fandomLink;
  MappingBase<String> titleBanner;
  MappingBase<String> noticeLink;

  WarExtra({
    required this.id,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? titleBanner,
    MappingBase<String>? noticeLink,
  })  : titleBanner = titleBanner ?? MappingBase(),
        noticeLink = noticeLink ?? MappingBase();

  factory WarExtra.fromJson(Map<String, dynamic> json) =>
      _$WarExtraFromJson(json);
}

@JsonSerializable()
class ExchangeTicket {
  final int id;
  final int year;
  final int month;
  final List<int> items;

  ExchangeTicket({
    required this.id,
    required this.year,
    required this.month,
    required this.items,
  });

  factory ExchangeTicket.fromJson(Map<String, dynamic> json) =>
      _$ExchangeTicketFromJson(json);

  int get monthDiff {
    switch (db2.curUser.region) {
      case Region.jp:
        return 0;
      case Region.cn:
        return 15;
      case Region.tw:
        return 24;
      case Region.na:
      case Region.kr:
        return 24;
    }
  }

  bool isOutdated() {
    final now = DateTime.now();
    return year * 12 + month + monthDiff + 4 < now.year * 12 + now.month;
  }

  DateTime get date {
    final diff = monthDiff;
    return DateTime(year, month + diff);
  }

  int get days {
    final d = date;
    return DateUtils.getDaysInMonth(d.year, d.month);
  }

  String get dateStr {
    final d = date;
    return '${d.year}-${d.month}';
  }
}

@JsonSerializable()
class FixedDrop {
  final int id;
  final Map<int, int> items;

  FixedDrop({
    required this.id,
    required this.items,
  });

  factory FixedDrop.fromJson(Map<String, dynamic> json) =>
      _$FixedDropFromJson(json);
}

@JsonSerializable()
class LimitedSummon {
  String id;
  String? mcLink;
  String? fandomLink;
  MappingBase<String> name;
  MappingBase<String> banner;
  MappingBase<String> noticeLink;
  MappingBase<int> startTime;
  MappingBase<int> endTime;
  SummonType type;
  int rollCount;
  List<SubSummon> subSummons;

  LimitedSummon({
    required this.id,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? name,
    MappingBase<String>? banner,
    MappingBase<String>? noticeLink,
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
    this.type = SummonType.unknown,
    this.rollCount = 11,
    this.subSummons = const [],
  })  : name = name ?? MappingBase(),
        banner = banner ?? MappingBase(),
        noticeLink = noticeLink ?? MappingBase(),
        startTime = startTime ?? MappingBase(),
        endTime = endTime ?? MappingBase();

  factory LimitedSummon.fromJson(Map<String, dynamic> json) =>
      _$LimitedSummonFromJson(json);

  bool get isLuckyBag => type == SummonType.gssr || type == SummonType.gssrsr;

  String get lName => name.l ?? id;

  String get route => Routes.summonI(id);

  List<int> allCards({
    bool svt = false,
    bool ce = false,
    bool includeHidden = false,
    bool includeGSSR = true,
  }) {
    List<int> cards = [];
    for (final sub in subSummons) {
      for (final prob in sub.probs) {
        if (includeGSSR && prob.rarity == 5) {
          cards.addAll(prob.ids);
          continue;
        }
        if (!prob.display && !includeHidden) continue;
        if ((prob.isSvt && svt) || (!prob.isSvt && ce)) {
          cards.addAll(prob.ids);
        }
      }
    }
    return cards;
  }

  bool hasSinglePickupSvt(int id) {
    for (var data in subSummons) {
      for (var block in data.probs) {
        if (block.ids.length == 1 && block.ids.single == id) {
          return true;
        }
      }
    }
    return false;
  }

  Iterable<int> get shownSvts {
    return {
      for (final s in subSummons)
        for (final block in s.svts)
          if (block.display) ...block.ids
    };
  }

  bool isOutdated() {
    final date = startTime.ofRegion(db2.curUser.region)?.sec2date();
    if (date == null) return false;
    return date.isBefore(DateTime.now()
        .subtract(Duration(days: db2.curUser.region == Region.jp ? 365 : 100)));
  }
}

@JsonSerializable()
class SubSummon {
  String title;
  List<ProbGroup> probs;

  SubSummon({
    required this.title,
    this.probs = const [],
  });

  factory SubSummon.fromJson(Map<String, dynamic> json) =>
      _$SubSummonFromJson(json);

  Iterable<ProbGroup> get svts => probs.where((e) => e.isSvt);
  Iterable<ProbGroup> get crafts => probs.where((e) => !e.isSvt);
}

@JsonSerializable()
class ProbGroup {
  bool isSvt;
  int rarity;
  double weight;
  bool display;
  List<int> ids;

  ProbGroup({
    required this.isSvt,
    required this.rarity,
    required this.weight,
    required this.display,
    this.ids = const [],
  }) : assert(ids.isNotEmpty);

  factory ProbGroup.fromJson(Map<String, dynamic> json) =>
      _$ProbGroupFromJson(json);
}

enum SummonType {
  story,
  limited,
  gssr,
  gssrsr,
  unknown,
}

enum SvtObtain {
  friendPoint,
  story,
  permanent,
  heroine,
  limited,
  unavailable,
  eventReward,
  clearReward,
  unknown,
}

enum CEObtain {
  exp,
  shop,
  story,
  permanent,
  valentine,
  limited,
  eventReward,
  campaign,
  bond,
  unknown,
}
