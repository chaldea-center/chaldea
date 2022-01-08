part of gamedata;

@JsonSerializable()
class ExtraData {
  final Map<int, ServantExtra> servants;
  final Map<int, CraftEssenceExtra> craftEssences;
  final Map<int, CommandCodeExtra> commandCodes;
  final Map<int, EventExtra> events;
  final Map<String, LimitedSummon> summons;

  const ExtraData({
    this.servants = const {},
    this.craftEssences = const {},
    this.commandCodes = const {},
    this.events = const {},
    this.summons = const {},
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) =>
      _$ExtraDataFromJson(json);
}

@JsonSerializable()
class ServantExtra {
  int collectionNo;
  List<String> nameOther;
  List<SvtObtain> obtains;
  List<String> aprilFoolAssets;
  MappingBase<String> aprilFoolProfile;
  // MappingBase<List<LoreComment>> profileComment;
  String? mcLink;
  String? fandomLink;

  ServantExtra({
    required this.collectionNo,
    required this.nameOther,
    required this.obtains,
    required this.aprilFoolAssets,
    required this.aprilFoolProfile,
    // required this.profileComment,
    this.mcLink,
    this.fandomLink,
  });

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
    required this.type,
    required this.profile,
    required this.characters,
    required this.unknownCharacters,
    this.mcLink,
    this.fandomLink,
  });

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
    required this.profile,
    required this.characters,
    required this.unknownCharacters,
    this.mcLink,
    this.fandomLink,
  });

  factory CommandCodeExtra.fromJson(Map<String, dynamic> json) =>
      _$CommandCodeExtraFromJson(json);
}

@JsonSerializable()
class EventExtraItems {
  int id;
  String detail;
  Map<int, String> items;

  EventExtraItems({
    required this.id,
    required this.detail,
    required this.items,
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
    required this.titleBanner,
    required this.noticeLink,
    required this.huntingQuestIds,
    MappingBase<int>? startTime,
    MappingBase<int>? endTime,
    required this.rarePrism,
    required this.grail,
    required this.crystal,
    required this.grail2crystal,
    required this.foukun4,
    required this.relatedSummons,
  })  : startTime = startTime ?? MappingBase<int>(),
        endTime = endTime ?? MappingBase<int>();

  factory EventExtra.fromJson(Map<String, dynamic> json) =>
      _$EventExtraFromJson(json);
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
    required this.name,
    required this.banner,
    required this.noticeLink,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.rollCount,
    required this.subSummons,
  });

  factory LimitedSummon.fromJson(Map<String, dynamic> json) =>
      _$LimitedSummonFromJson(json);
}

@JsonSerializable()
class SubSummon {
  String title;
  List<ProbGroup> probs;

  SubSummon({
    required this.title,
    required this.probs,
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
    required this.ids,
  });

  factory ProbGroup.fromJson(Map<String, dynamic> json) =>
      _$ProbGroupFromJson(json);
}

enum SummonType { story, limited, gssr, gssrsr, unknown }

enum SvtObtain {
  friendPoint,
  story,
  permanent,
  heroine,
  limited,
  unavailable,
  eventReward,
  clearReward,
  unknown
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
  unknown
}
