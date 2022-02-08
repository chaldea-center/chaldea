import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'servant.dart';

part '../../generated/models/gamedata/wiki_data.g.dart';

@JsonSerializable()
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
  final Map<String, MappingBase<String>> summonNames;
  final Map<String, MappingBase<String>> charaNames;
  final Map<String, MappingBase<String>> buffNames;
  final Map<String, MappingBase<String>> buffDetail;
  final Map<String, MappingBase<String>> funcPopuptext;
  final Map<String, MappingBase<String>> skillNames;
  final Map<String, MappingBase<String>> skillDetail;
  final Map<String, MappingBase<String>> tdNames;
  final Map<String, MappingBase<String>> tdRuby;
  final Map<String, MappingBase<String>> tdDetail;
  final Map<int, MappingBase<String>> trait;
  final Map<int, MappingBase<String>> mcDetail;
  final Map<int, MappingBase<String>> costumeDetail;
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
  })  : itemNames = _cast(itemNames),
        mcNames = _cast(mcNames),
        costumeNames = _cast(costumeNames),
        cvNames = _cast(cvNames),
        illustratorNames = _cast(illustratorNames),
        ccNames = _cast(ccNames),
        svtNames = _cast(svtNames),
        ceNames = _cast(ceNames),
        eventNames = _cast(eventNames),
        warNames = _cast(warNames),
        questNames = _cast(questNames),
        spotNames = _cast(spotNames),
        entityNames = _cast(entityNames),
        tdTypes = _cast(tdTypes),
        bgmNames = _cast(bgmNames),
        summonNames = _cast(summonNames),
        charaNames = _cast(charaNames),
        buffNames = _cast(buffNames),
        buffDetail = _cast(buffDetail),
        funcPopuptext = _cast(funcPopuptext),
        skillNames = _cast(skillNames),
        skillDetail = _cast(skillDetail),
        tdNames = _cast(tdNames),
        tdRuby = _cast(tdRuby),
        tdDetail = _cast(tdDetail),
        trait = _cast(trait),
        mcDetail = _cast(mcDetail),
        costumeDetail = _cast(costumeDetail),
        skillState = _cast(skillState),
        tdState = _cast(tdState);

  static Map<K, MappingBase<V>> _cast<K, V>(Map<dynamic, MappingBase>? data) {
    return data?.map((key, value) {
          if (K == int && key is String) {
            return MapEntry(int.parse(key) as K, value.cast());
          }
          return MapEntry(key, value.cast());
        }) ??
        {};
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
  CEType type;
  MappingBase<String> profile;
  List<int> characters;
  List<String> unknownCharacters;
  String? mcLink;
  String? fandomLink;

  CraftEssenceExtra({
    required this.collectionNo,
    this.type = CEType.unknown,
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

enum CEType {
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
