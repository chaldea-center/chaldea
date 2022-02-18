import 'package:chaldea/models/userdata/userdata.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../db.dart';
import 'servant.dart';

part '../../generated/models/gamedata/wiki_data.g.dart';

class Transl<K, V> {
  final Map<K, MappingBase<V>> mapping;
  final MappingBase<V>? _m;
  final K key;
  final V _default;

  Transl(this.mapping, this.key, this._default) : _m = mapping[key];

  V get jp => mapping[key]?.jp ?? _default;

  V get cn => mapping[key]?.cn ?? _default;

  V get tw => mapping[key]?.tw ?? _default;

  V get na => mapping[key]?.na ?? _default;

  V get kr => mapping[key]?.kr ?? _default;

  V get l {
    for (final region in db2.settings.resolvedPreferredRegions) {
      final v = mapping[key]?.of(region);
      if (v != null) return v;
    }
    return _default;
  }

  List<V?> get all => [_m?.jp, _m?.cn, _m?.tw, _m?.na, _m?.kr];

  static MappingData get _md => db2.gameData.mappingData;

  static Transl<int, String> trait(int id) => Transl(_md.trait, id, '$id');

  static Transl<String, String> itemNames(String jp) =>
      Transl(_md.itemNames, jp, jp);

  static Transl<String, String> mcNames(String jp) =>
      Transl(_md.mcNames, jp, jp);

  static Transl<String, String> costumeNames(String jp) =>
      Transl(_md.costumeNames, jp, jp);

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

  static Transl<String, String> funcPopuptext(String jp) =>
      Transl(_md.funcPopuptext, jp, jp);

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
  final Map<int, MappingBase<String>> mcDetail; // key: mc id
  final Map<int, MappingBase<String>> costumeDetail; // costume collectionNo
  final Map<int, MappingBase<Map<int, int>>> skillState;
  final Map<int, MappingBase<Map<int, int>>> tdState;

  MappingData({
    Map<dynamic, MappingBase>? itemNames,
    Map<dynamic, MappingBase>? mcNames,
    Map<dynamic, MappingBase>? costumeNames,
    Map<dynamic, MappingBase>? cvNames,
    Map<dynamic, MappingBase>? illustratorNames,
    Map<dynamic, MappingBase>? ccNames,
    Map<dynamic, MappingBase>? svtNames,
    Map<dynamic, MappingBase>? ceNames,
    Map<dynamic, MappingBase>? eventNames,
    Map<dynamic, MappingBase>? warNames,
    Map<dynamic, MappingBase>? questNames,
    Map<dynamic, MappingBase>? spotNames,
    Map<dynamic, MappingBase>? entityNames,
    Map<dynamic, MappingBase>? tdTypes,
    Map<dynamic, MappingBase>? bgmNames,
    Map<dynamic, MappingBase>? summonNames,
    Map<dynamic, MappingBase>? charaNames,
    Map<dynamic, MappingBase>? buffNames,
    Map<dynamic, MappingBase>? buffDetail,
    Map<dynamic, MappingBase>? funcPopuptext,
    Map<dynamic, MappingBase>? skillNames,
    Map<dynamic, MappingBase>? skillDetail,
    Map<dynamic, MappingBase>? tdNames,
    Map<dynamic, MappingBase>? tdRuby,
    Map<dynamic, MappingBase>? tdDetail,
    Map<dynamic, MappingBase>? trait,
    Map<dynamic, MappingBase>? mcDetail,
    Map<dynamic, MappingBase>? costumeDetail,
    Map<dynamic, MappingBase>? skillState,
    Map<dynamic, MappingBase>? tdState,
  })  : itemNames = _cast(itemNames, Region.jp),
        mcNames = _cast(mcNames, Region.jp),
        costumeNames = _cast(costumeNames, Region.jp),
        cvNames = _cast(cvNames, Region.jp),
        illustratorNames = _cast(illustratorNames, Region.jp),
        ccNames = _cast(ccNames, Region.jp),
        svtNames = _cast(svtNames, Region.jp),
        ceNames = _cast(ceNames, Region.jp),
        eventNames = _cast(eventNames, Region.jp),
        warNames = _cast(warNames, Region.jp),
        questNames = _cast(questNames, Region.jp),
        spotNames = _cast(spotNames, Region.jp),
        entityNames = _cast(entityNames, Region.jp),
        tdTypes = _cast(tdTypes, Region.jp),
        bgmNames = _cast(bgmNames, Region.jp),
        summonNames = _cast(summonNames, Region.jp),
        charaNames = _cast(charaNames, Region.cn),
        buffNames = _cast(buffNames, Region.jp),
        buffDetail = _cast(buffDetail, Region.jp),
        funcPopuptext = _cast(funcPopuptext, Region.jp),
        skillNames = _cast(skillNames, Region.jp),
        skillDetail = _cast(skillDetail, Region.jp),
        tdNames = _cast(tdNames, Region.jp),
        tdRuby = _cast(tdRuby, Region.jp),
        tdDetail = _cast(tdDetail, Region.jp),
        trait = _cast(trait),
        mcDetail = _cast(mcDetail),
        costumeDetail = _cast(costumeDetail),
        skillState = _cast(skillState),
        tdState = _cast(tdState) {
    this.skillNames
      ..addAll(this.ceNames)
      ..addAll(this.ccNames);
  }

  static Map<K, MappingBase<V>> _cast<K, V>(Map<dynamic, MappingBase>? data,
      [Region? keyRegion]) {
    if (data == null) return {};
    return data.map((key, value) {
      MapEntry<K, MappingBase<V>> entry;
      if (K == int) {
        entry = MapEntry(int.parse(key as String) as K, value.cast());
      } else {
        entry = MapEntry(key, value.cast());
      }
      if (keyRegion != null) {
        assert(K == V && K == String, 'Only String supported: $K, $V');
        entry.value.update(entry.key as V, keyRegion, true);
      }
      return entry;
    });
  }

  factory MappingData.fromJson(Map<String, dynamic> json) =>
      _$MappingDataFromJson(json);
}

@JsonSerializable(constructor: 'typed')
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

  /// For generator, use dynamic
  @protected
  MappingBase({
    dynamic jp,
    dynamic cn,
    dynamic tw,
    dynamic na,
    dynamic kr,
  })  : jp = jp as T?,
        cn = cn as T?,
        tw = tw as T?,
        na = na as T?,
        kr = kr as T?;

  MappingBase.typed({
    this.jp,
    this.cn,
    this.tw,
    this.na,
    this.kr,
  });

  T? get l {
    for (final region in db2.settings.resolvedPreferredRegions) {
      final v = of(region);
      if (v != null) return v;
    }
    return null;
  }

  T? of(Region region) {
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

  MappingBase<S> cast<S>() {
    if (S == int || S == double || S == String || S == bool) {
      return MappingBase<S>.typed(
        jp: jp as S?,
        cn: cn as S?,
        tw: tw as S?,
        na: na as S?,
        kr: kr as S?,
      );
    }
    // if (S  == Map) {
    // now only Map<int, int>
    return MappingBase<Map<int, int>>.typed(
      jp: (jp as Map?)?.cast<int, int>(),
      cn: (cn as Map?)?.cast<int, int>(),
      tw: (tw as Map?)?.cast<int, int>(),
      na: (na as Map?)?.cast<int, int>(),
      kr: (kr as Map?)?.cast<int, int>(),
    ) as MappingBase<S>;
    // }
    // throw ArgumentError.value(S, 'type', 'Unknown cast type');
  }

  static T _fromJsonT<T>(Object? obj) {
    if (obj == null) return null as T;
    if (obj is int || obj is double || obj is String) return obj as T;
    // Map<int,int>
    if (obj is Map) {
      if (obj.isEmpty) return Map.from(obj) as T;
      if (obj.values.first is int) {
        return <int, int>{for (var e in obj.entries) int.parse(e.key): e.value}
            as T;
      }
    }
    if (obj is List) {
      // List<LoreComment>
      if (obj.isEmpty) return List.from(obj) as T;
      final _first = obj.first;
      if (_first is Map &&
          _first.keys
              .toSet()
              .containsAll(['id', 'priority', 'condMessage', 'condType'])) {
        return obj.map((e) => LoreComment.fromJson(e)).toList() as T;
      }
    }
    return obj as T;
  }
}

@JsonSerializable()
class WikiData {
  final Map<int, ServantExtra> servants;
  final Map<int, CraftEssenceExtra> craftEssences;
  final Map<int, CommandCodeExtra> commandCodes;
  final Map<int, EventExtra> events;

  WikiData({
    this.servants = const {},
    this.craftEssences = const {},
    this.commandCodes = const {},
    this.events = const {},
  });

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
    MappingBase<dynamic>? aprilFoolProfile,
    this.mcLink,
    this.fandomLink,
  }) : aprilFoolProfile = aprilFoolProfile?.cast() ?? MappingBase();

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
    MappingBase? profile,
    this.characters = const [],
    this.unknownCharacters = const [],
    this.mcLink,
    this.fandomLink,
  }) : profile = profile?.cast() ?? MappingBase();

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
    MappingBase? profile,
    this.characters = const [],
    this.unknownCharacters = const [],
    this.mcLink,
    this.fandomLink,
  }) : profile = profile?.cast() ?? MappingBase();

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
    MappingBase? titleBanner,
    MappingBase? noticeLink,
    this.huntingQuestIds = const [],
    this.extraItems = const [],
    MappingBase? startTime,
    MappingBase? endTime,
    this.rarePrism = 0,
    this.grail = 0,
    this.crystal = 0,
    this.grail2crystal = 0,
    this.foukun4 = 0,
    this.relatedSummons = const [],
  })  : titleBanner = titleBanner?.cast() ?? MappingBase(),
        noticeLink = noticeLink?.cast() ?? MappingBase(),
        startTime = startTime?.cast() ?? MappingBase(),
        endTime = endTime?.cast() ?? MappingBase();

  factory EventExtra.fromJson(Map<String, dynamic> json) =>
      _$EventExtraFromJson(json);
}

@JsonSerializable()
class ExchangeTicket {
  final int key;
  final int year;
  final int month;
  final List<int> items;

  ExchangeTicket({
    required this.key,
    required this.year,
    required this.month,
    required this.items,
  });

  factory ExchangeTicket.fromJson(Map<String, dynamic> json) =>
      _$ExchangeTicketFromJson(json);
}

@JsonSerializable()
class FixedDrop {
  final int key;
  final Map<int, int> items;

  FixedDrop({
    required this.key,
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
    MappingBase? name,
    MappingBase? banner,
    MappingBase? noticeLink,
    MappingBase? startTime,
    MappingBase? endTime,
    this.type = SummonType.unknown,
    this.rollCount = 11,
    this.subSummons = const [],
  })  : name = name?.cast() ?? MappingBase(),
        banner = banner?.cast() ?? MappingBase(),
        noticeLink = noticeLink?.cast() ?? MappingBase(),
        startTime = startTime?.cast() ?? MappingBase(),
        endTime = endTime?.cast() ?? MappingBase();

  factory LimitedSummon.fromJson(Map<String, dynamic> json) =>
      _$LimitedSummonFromJson(json);

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
