import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'mappings.dart';

part '../../generated/models/gamedata/wiki_data.g.dart';

@JsonSerializable(createToJson: false)
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

  factory WikiData.fromJson(Map<String, dynamic> json) => _$WikiDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class ServantExtra {
  int collectionNo;
  MappingList<String> nicknames;
  List<SvtObtain> obtains;
  List<String> aprilFoolAssets;
  MappingBase<String> aprilFoolProfile;
  List<String> mcSprites; // filename only
  List<String> fandomSprites;
  String? mcLink;
  String? fandomLink;
  Map<int, List<String>> mcProfiles;
  Map<int, List<String>> fandomProfiles;
  List<BiliVideo> tdAnimations;

  ServantExtra({
    required this.collectionNo,
    MappingList<String>? nicknames,
    this.obtains = const [SvtObtain.unknown],
    this.aprilFoolAssets = const [],
    MappingBase<String>? aprilFoolProfile,
    this.mcSprites = const [],
    this.fandomSprites = const [],
    this.mcLink,
    this.fandomLink,
    this.mcProfiles = const {},
    this.fandomProfiles = const {},
    this.tdAnimations = const [],
  })  : nicknames = nicknames ?? MappingList(),
        aprilFoolProfile = aprilFoolProfile ?? MappingBase();

  factory ServantExtra.fromJson(Map<String, dynamic> json) => _$ServantExtraFromJson(json);
}

@JsonSerializable(createToJson: false)
class BiliVideo {
  int? av;
  int? p;
  String? bv;

  BiliVideo({
    this.av,
    this.p,
    this.bv,
  });

  factory BiliVideo.fromJson(Map<String, dynamic> json) => _$BiliVideoFromJson(json);

  bool get valid => av != null || bv != null;

  String get weburl {
    // https://www.bilibili.com/video/av74352743/?p=271
    String url = 'https://www.bilibili.com/video/';
    if (av != null) {
      url += 'av$av/';
    } else if (bv != null) {
      url += '$bv/';
    }
    if (p != null) {
      url += '?p=$p';
    }
    return url;
  }
}

@JsonSerializable(createToJson: false)
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

  factory CraftEssenceExtra.fromJson(Map<String, dynamic> json) => _$CraftEssenceExtraFromJson(json);
}

@JsonSerializable(createToJson: false)
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

  factory CommandCodeExtra.fromJson(Map<String, dynamic> json) => _$CommandCodeExtraFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventExtraItems {
  int id;
  bool infinite;
  MappingBase<String> detail;
  Map<int, MappingBase<String>> items;

  EventExtraItems({
    required this.id,
    this.infinite = false,
    MappingBase<String>? detail,
    Map<int, MappingBase<String>?> items = const {},
  })  : detail = detail ?? MappingBase(),
        items = items.map((key, value) => MapEntry(key, value ?? MappingBase()));

  factory EventExtraItems.fromJson(Map<String, dynamic> json) => _$EventExtraItemsFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventExtraFixedItems {
  int id;
  MappingBase<String> detail;
  Map<int, int> items;

  EventExtraFixedItems({
    required this.id,
    MappingBase<String>? detail,
    Map<int, int>? items,
  })  : detail = detail ?? MappingBase(),
        items = items ?? {};

  factory EventExtraFixedItems.fromJson(Map<String, dynamic> json) => _$EventExtraFixedItemsFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventExtra {
  int id;
  // String? name;
  String? mcLink;
  String? fandomLink;
  bool? shown;
  MappingBase<String> titleBanner;
  MappingBase<String> officialBanner;
  MappingList<String> extraBanners;
  MappingBase<String> noticeLink;
  List<EventExtraFixedItems> extraFixedItems;
  List<EventExtraItems> extraItems;
  EventExtraScript script;

  MappingBase<int> startTime;
  MappingBase<int> endTime;
  List<String> relatedSummons;

  EventExtra({
    required this.id,
    // this.name,
    this.mcLink,
    this.fandomLink,
    this.shown,
    MappingBase<String>? titleBanner,
    MappingBase<String>? officialBanner,
    MappingList<String>? extraBanners,
    MappingBase<String>? noticeLink,
    this.extraFixedItems = const [],
    this.extraItems = const [],
    EventExtraScript? script,
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
    this.relatedSummons = const [],
  })  : titleBanner = titleBanner ?? MappingBase(),
        officialBanner = officialBanner ?? MappingBase(),
        extraBanners = extraBanners ?? MappingList(),
        noticeLink = noticeLink ?? MappingBase(),
        script = script ?? EventExtraScript(),
        startTime = startTime ?? MappingBase(),
        endTime = endTime ?? MappingBase();

  MappingBase<String> get resolvedBanner => titleBanner.merge(officialBanner);

  List<String> get allBanners {
    List<String?> _banners = [];
    for (final region in Region.values) {
      _banners.add(resolvedBanner.ofRegion(region));
      _banners.addAll(extraBanners.ofRegion(region) ?? []);
    }
    return _banners.whereType<String>().toList();
  }

  factory EventExtra.fromJson(Map<String, dynamic> json) => _$EventExtraFromJson(json);
}

@JsonSerializable(createToJson: false, converters: [RegionConverter()])
class EventExtraScript {
  final int huntingId;
  final Map<Region, String> raidLink;

  EventExtraScript({
    this.huntingId = 0,
    this.raidLink = const {},
  });

  factory EventExtraScript.fromJson(Map<String, dynamic> json) => _$EventExtraScriptFromJson(json);
}

@JsonSerializable(createToJson: false)
class WarExtra {
  int id;
  String? mcLink;
  String? fandomLink;
  MappingBase<String> noticeLink;
  MappingBase<String> titleBanner;
  MappingBase<String> officialBanner;
  MappingList<String> extraBanners;

  WarExtra({
    required this.id,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? noticeLink,
    MappingBase<String>? titleBanner,
    MappingBase<String>? officialBanner,
    MappingList<String>? extraBanners,
  })  : noticeLink = noticeLink ?? MappingBase(),
        titleBanner = titleBanner ?? MappingBase(),
        officialBanner = officialBanner ?? MappingBase(),
        extraBanners = extraBanners ?? MappingList();

  MappingBase<String> get resolvedBanner => titleBanner.merge(officialBanner);

  List<String> get allBanners {
    List<String?> _banners = [];
    for (final region in Region.values) {
      _banners.add(resolvedBanner.ofRegion(region));
      _banners.addAll(extraBanners.ofRegion(region) ?? []);
    }
    return _banners.whereType<String>().toList();
  }

  factory WarExtra.fromJson(Map<String, dynamic> json) => _$WarExtraFromJson(json);
}

@JsonSerializable(createToJson: false)
class ExchangeTicket {
  final int id;
  final int itemId;
  final int year;
  final int month;
  final List<int> items;
  final MappingList<int> replaced;
  final int multiplier;

  ExchangeTicket({
    required this.id,
    required this.itemId,
    required this.year,
    required this.month,
    required this.items,
    MappingList<int>? replaced,
    this.multiplier = 1,
  }) : replaced = replaced ?? MappingList();

  factory ExchangeTicket.fromJson(Map<String, dynamic> json) => _$ExchangeTicketFromJson(json);

  List<int> of(Region region) => replaced.ofRegion(region) ?? items;

  int get monthDiff {
    switch (db.curUser.region) {
      case Region.jp:
        return 0;
      case Region.cn:
        if (year * 100 + month >= 202209) return 12;
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
    return year * 12 + month + (db.curUser.region == Region.jp ? 12 : monthDiff) + 4 < now.year * 12 + now.month;
  }

  DateTime get date {
    final diff = monthDiff;
    return DateTime(year, month + diff);
  }

  String get dateStr {
    final d = date;
    return '${d.year}-${d.month}';
  }

  int get days {
    final d = date;
    return DateUtils.getDaysInMonth(d.year, d.month);
  }

  int get maxCount => days * multiplier;
}

@JsonSerializable(createToJson: false)
class FixedDrop {
  final int id;
  final Map<int, int> items;

  FixedDrop({
    required this.id,
    required this.items,
  });

  factory FixedDrop.fromJson(Map<String, dynamic> json) => _$FixedDropFromJson(json);
}

@JsonSerializable(createToJson: false)
class LimitedSummon with RouteInfo {
  String id;
  String name;
  String name_;
  String? mcLink;
  String? fandomLink;
  MappingBase<String> banner;
  MappingBase<String> officialBanner;
  MappingBase<String> noticeLink;
  MappingBase<int> startTime;
  MappingBase<int> endTime;
  SummonType type;
  int rollCount;
  List<int> puSvt;
  List<int> puCE;
  List<SubSummon> subSummons;

  LimitedSummon({
    required this.id,
    dynamic name,
    String? name_,
    this.mcLink,
    this.fandomLink,
    MappingBase<String>? banner,
    MappingBase<String>? officialBanner,
    MappingBase<String>? noticeLink,
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
    this.type = SummonType.unknown,
    this.rollCount = 11,
    this.puSvt = const [],
    this.puCE = const [],
    this.subSummons = const [],
  })  : name = name is String ? name : (name_ ?? id.toString()),
        name_ = name_ ?? id.toString(),
        banner = banner ?? MappingBase(),
        officialBanner = officialBanner ?? MappingBase(),
        noticeLink = noticeLink ?? MappingBase(),
        startTime = startTime ?? MappingBase(),
        endTime = endTime ?? MappingBase();

  factory LimitedSummon.fromJson(Map<String, dynamic> json) => _$LimitedSummonFromJson(json);

  bool get isLuckyBag => type == SummonType.gssr || type == SummonType.gssrsr;

  Transl<String, String> get lName => Transl.summonNames(name);

  @override
  String get route => Routes.summonI(id);

  MappingBase<String> get resolvedBanner => banner.merge(officialBanner);

  List<int> allCards({
    bool svt = false,
    bool ce = false,
    bool includeHidden = false,
    bool includeGSSR = false,
  }) {
    List<int> cards = [];
    for (final sub in subSummons) {
      for (final prob in sub.probs) {
        if (isLuckyBag && prob.rarity == 5 && prob.isSvt) {
          if (includeGSSR) cards.addAll(prob.ids);
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

  bool hasPickupSvt(int id, {bool includeGSSR = true}) {
    if (subSummons.isNotEmpty) {
      return allCards(svt: true, includeGSSR: includeGSSR).contains(id);
    } else {
      return puSvt.contains(id);
    }
  }

  bool hasPickupCE(int id) {
    if (subSummons.isNotEmpty) {
      return allCards(ce: true).contains(id);
    } else {
      return puCE.contains(id);
    }
  }

  bool hasSinglePickupSvt(int id) {
    for (final data in subSummons) {
      for (final block in data.probs) {
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
      days = db.curUser.region == Region.jp ? 365 + 30 : 30;
      return date.isBefore(DateTime.now().subtract(Duration(days: days)));
    }
    final jpDate = startTime.jp?.sec2date();
    if (jpDate == null) return false;
    days = db.curUser.region.eventDelayMonth * 31;
    return jpDate.isBefore(DateTime.now().subtract(Duration(days: days + 30)));
  }
}

@JsonSerializable(createToJson: false)
class SubSummon {
  String title;
  List<ProbGroup> probs;

  SubSummon({
    required this.title,
    this.probs = const [],
  });

  factory SubSummon.fromJson(Map<String, dynamic> json) => _$SubSummonFromJson(json);

  Iterable<ProbGroup> get svts => probs.where((e) => e.isSvt);
  Iterable<ProbGroup> get crafts => probs.where((e) => !e.isSvt);
}

@JsonSerializable(createToJson: false)
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

  factory ProbGroup.fromJson(Map<String, dynamic> json) => _$ProbGroupFromJson(json);
}

enum SummonType {
  story,
  limited,
  gssr,
  gssrsr,
  unknown,
}

enum SvtObtain {
  permanent,
  story,
  limited,
  eventReward,
  friendPoint,
  clearReward,
  heroine,
  unavailable,
  unknown;

  bool get isSummonable {
    return this == permanent || this == story || this == limited;
  }
}

enum CEObtain {
  permanent,
  story,
  eventReward,
  limited,
  shop,
  bond,
  valentine,
  exp,
  campaign,
  drop,
  regionSpecific,
  unknown,
}
