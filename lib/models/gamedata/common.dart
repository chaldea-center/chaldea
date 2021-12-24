// ignore_for_file: non_constant_identifier_names

part of gamedata;

@JsonSerializable()
class NiceTrait {
  int id;
  Trait name;
  bool? negative;

  NiceTrait({
    required this.id,
    required this.name,
    this.negative,
  });

  factory NiceTrait.fromJson(Map<String, dynamic> json) =>
      _$NiceTraitFromJson(json);
}

@JsonSerializable()
class BuffRelationOverwrite {
  Map<SvtClass, Map<SvtClass, dynamic>> atkSide;
  Map<SvtClass, Map<SvtClass, dynamic>> defSide;

  BuffRelationOverwrite({
    required this.atkSide,
    required this.defSide,
  });

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) =>
      _$BuffRelationOverwriteFromJson(json);
}

@JsonSerializable()
class BuffScript {
  int? checkIndvType;
  List<BuffType>? CheckOpponentBuffTypes;
  BuffRelationOverwrite? relationId;
  String? ReleaseText;
  int? DamageRelease;
  NiceTrait? INDIVIDUALITIE;
  List<NiceTrait>? UpBuffRateBuffIndiv;
  int? HP_LOWER;

  BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.ReleaseText,
    this.DamageRelease,
    this.INDIVIDUALITIE,
    this.UpBuffRateBuffIndiv,
    this.HP_LOWER,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) =>
      _$BuffScriptFromJson(json);
}

@JsonSerializable()
class MasterMission {
  int id;
  int startedAt;
  int endedAt;
  int closedAt;
  List<EventMission> missions;
  List<dynamic> quests;

  MasterMission({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.closedAt,
    required this.missions,
    required this.quests,
  });

  factory MasterMission.fromJson(Map<String, dynamic> json) =>
      _$MasterMissionFromJson(json);
}

@JsonSerializable()
class BgmRelease {
  int id;
  CondType type;
  int condGroup;
  List<int> targetIds;
  List<int> vals;
  int priority;
  String closedMessage;

  BgmRelease({
    required this.id,
    required this.type,
    required this.condGroup,
    required this.targetIds,
    required this.vals,
    required this.priority,
    required this.closedMessage,
  });

  factory BgmRelease.fromJson(Map<String, dynamic> json) =>
      _$BgmReleaseFromJson(json);
}

@JsonSerializable()
class BgmEnitity {
  int id;
  String name;
  String fileName;
  String? audioAsset;
  int priority;
  String detail;
  bool notReleased;
  NiceShop? shop;
  String logo;
  List<BgmRelease> releaseConditions;

  BgmEnitity({
    required this.id,
    required this.name,
    required this.fileName,
    this.audioAsset,
    required this.priority,
    required this.detail,
    required this.notReleased,
    this.shop,
    required this.logo,
    required this.releaseConditions,
  });

  factory BgmEnitity.fromJson(Map<String, dynamic> json) =>
      _$BgmEnitityFromJson(json);
}

@JsonSerializable()
class Bgm {
  int id;
  String name;
  String fileName;
  bool notReleased;
  String? audioAsset;

  Bgm({
    required this.id,
    required this.name,
    required this.fileName,
    required this.notReleased,
    this.audioAsset,
  });

  factory Bgm.fromJson(Map<String, dynamic> json) => _$BgmFromJson(json);
}
