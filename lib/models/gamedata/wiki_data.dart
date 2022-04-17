import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/userdata/userdata.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:chaldea/utils/extension.dart';
import '../db.dart';
import 'mappings.dart';

part '../../generated/models/gamedata/wiki_data.g.dart';

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
  MappingList<String> nicknames;
  List<SvtObtain> obtains;
  List<String> aprilFoolAssets;
  MappingBase<String> aprilFoolProfile;
  String? mcLink;
  String? fandomLink;

  ServantExtra({
    required this.collectionNo,
    MappingList<String>? nicknames,
    this.obtains = const [],
    this.aprilFoolAssets = const [],
    MappingBase<String>? aprilFoolProfile,
    this.mcLink,
    this.fandomLink,
  })  : nicknames = nicknames ?? MappingList(),
        aprilFoolProfile = aprilFoolProfile ?? MappingBase();

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
  MappingBase<String> detail;
  Map<int, String> items;

  EventExtraItems({
    required this.id,
    MappingBase<String>? detail,
    this.items = const {},
  }) : detail = detail ?? MappingBase();

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
  int huntingId;
  List<int> huntingQuestIds;
  List<EventExtraItems> extraItems;

  MappingBase<int> startTime;
  MappingBase<int> endTime;
  List<String> relatedSummons;

  EventExtra({
    required this.id,
    required this.name,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? titleBanner,
    MappingBase<String>? noticeLink,
    this.huntingId = 0,
    this.huntingQuestIds = const [],
    this.extraItems = const [],
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
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
    switch (db.curUser.region) {
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
    final date = startTime.ofRegion(db.curUser.region)?.sec2date();
    int days;
    if (date != null) {
      days = db.curUser.region == Region.jp ? 365 : 30;
      return date.isBefore(DateTime.now().subtract(Duration(days: days)));
    }
    final jpDate = startTime.jp?.sec2date();
    if (jpDate == null) return false;
    switch (db.curUser.region) {
      case Region.jp:
        days = 300;
        break;
      case Region.cn:
        days = 365;
        break;
      case Region.tw:
        days = 624;
        break;
      case Region.na:
        days = 724;
        break;
      case Region.kr:
        days = 728;
        break;
    }
    return jpDate.isBefore(DateTime.now().subtract(Duration(days: days + 30)));
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
