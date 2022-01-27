// ignore_for_file: non_constant_identifier_names

part of gamedata;

@JsonSerializable()
class BasicServant {
  int id;
  int collectionNo;
  String name;
  SvtType type;
  SvtFlag flag;
  SvtClass className;
  Attribute attribute;
  int rarity;
  int atkMax;
  int hpMax;
  String face;

  BasicServant({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.type,
    required this.flag,
    required this.className,
    required this.attribute,
    required this.rarity,
    required this.atkMax,
    required this.hpMax,
    required this.face,
  });

  factory BasicServant.fromJson(Map<String, dynamic> json) =>
      _$BasicServantFromJson(json);
}

@JsonSerializable()
class ExtraAssetsUrl {
  Map<int, String>? ascension;
  Map<int, String>? story;
  Map<int, String>? costume;
  Map<int, String>? equip;
  Map<int, String>? cc;

  ExtraAssetsUrl({
    this.ascension,
    this.story,
    this.costume,
    this.equip,
    this.cc,
  });

  factory ExtraAssetsUrl.fromJson(Map<String, dynamic> json) =>
      _$ExtraAssetsUrlFromJson(json);
}

@JsonSerializable()
class ExtraCCAssets {
  ExtraAssetsUrl charaGraph;
  ExtraAssetsUrl faces;

  ExtraCCAssets({
    required this.charaGraph,
    required this.faces,
  });

  factory ExtraCCAssets.fromJson(Map<String, dynamic> json) =>
      _$ExtraCCAssetsFromJson(json);
}

@JsonSerializable()
class ExtraAssets implements ExtraCCAssets {
  @override
  ExtraAssetsUrl charaGraph;
  @override
  ExtraAssetsUrl faces;
  ExtraAssetsUrl charaGraphEx;
  ExtraAssetsUrl charaGraphName;
  ExtraAssetsUrl narrowFigure;
  ExtraAssetsUrl charaFigure;
  Map<int, ExtraAssetsUrl> charaFigureForm;
  Map<int, ExtraAssetsUrl> charaFigureMulti;
  ExtraAssetsUrl commands;
  ExtraAssetsUrl status;
  ExtraAssetsUrl equipFace;
  ExtraAssetsUrl image;

  ExtraAssets({
    required this.charaGraph,
    required this.faces,
    required this.charaGraphEx,
    required this.charaGraphName,
    required this.narrowFigure,
    required this.charaFigure,
    required this.charaFigureForm,
    required this.charaFigureMulti,
    required this.commands,
    required this.status,
    required this.equipFace,
    required this.image,
  });

  factory ExtraAssets.fromJson(Map<String, dynamic> json) =>
      _$ExtraAssetsFromJson(json);
}

@JsonSerializable()
class CardDetail {
  List<NiceTrait> attackIndividuality;

  CardDetail({
    required this.attackIndividuality,
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) =>
      _$CardDetailFromJson(json);
}

@JsonSerializable()
class AscensionAddEntry<T> {
  Map<int, T> ascension;
  Map<int, T> costume;

  AscensionAddEntry({
    required this.ascension,
    required this.costume,
  });

  factory AscensionAddEntry.fromJson(Map<String, dynamic> json) =>
      _$AscensionAddEntryFromJson(json, _fromJsonT);

  static T _fromJsonT<T>(Object? obj) {
    if (obj == null) return null as T;
    if (obj is int || obj is double || obj is String) return obj as T;
    if (obj is List) {
      if (obj.isEmpty) return List<NiceTrait>.from(obj) as T;
      if (obj[0] is Map && obj[0]['id'] != null && obj[0]['name'] != null) {
        return obj
            .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() as T;
      }
    }
    throw FormatException('unknown type: ${obj.runtimeType}');
  }
}

@JsonSerializable()
class AscensionAdd {
  AscensionAddEntry<List<NiceTrait>> individuality;
  AscensionAddEntry<int> voicePrefix;
  AscensionAddEntry<String> overWriteServantName;
  AscensionAddEntry<String> overWriteServantBattleName;
  AscensionAddEntry<String> overWriteTDName;
  AscensionAddEntry<String> overWriteTDRuby;
  AscensionAddEntry<String> overWriteTDFileName;
  AscensionAddEntry<String> overWriteTDRank;
  AscensionAddEntry<String> overWriteTDTypeText;
  AscensionAddEntry<int> lvMax;

  AscensionAdd({
    required this.individuality,
    required this.voicePrefix,
    required this.overWriteServantName,
    required this.overWriteServantBattleName,
    required this.overWriteTDName,
    required this.overWriteTDRuby,
    required this.overWriteTDFileName,
    required this.overWriteTDRank,
    required this.overWriteTDTypeText,
    required this.lvMax,
  });

  factory AscensionAdd.fromJson(Map<String, dynamic> json) =>
      _$AscensionAddFromJson(json);
}

@JsonSerializable()
class ServantChange {
  List<int> beforeTreasureDeviceIds;
  List<int> afterTreasureDeviceIds;
  int svtId;
  int priority;
  CondType condType;
  int condTargetId;
  int condValue;
  String name;
  int svtVoiceId;
  int limitCount;
  int flag;
  int battleSvtId;

  ServantChange({
    required this.beforeTreasureDeviceIds,
    required this.afterTreasureDeviceIds,
    required this.svtId,
    required this.priority,
    required this.condType,
    required this.condTargetId,
    required this.condValue,
    required this.name,
    required this.svtVoiceId,
    required this.limitCount,
    required this.flag,
    required this.battleSvtId,
  });

  factory ServantChange.fromJson(Map<String, dynamic> json) =>
      _$ServantChangeFromJson(json);
}

@JsonSerializable()
class ServantAppendPassiveSkill {
  int num;
  int priority;
  NiceSkill skill;
  List<ItemAmount> unlockMaterials;

  ServantAppendPassiveSkill({
    required this.num,
    required this.priority,
    required this.skill,
    required this.unlockMaterials,
  });

  factory ServantAppendPassiveSkill.fromJson(Map<String, dynamic> json) =>
      _$ServantAppendPassiveSkillFromJson(json);
}

@JsonSerializable()
class NiceServantCoin {
  int summonNum;
  Item item;

  NiceServantCoin({
    required this.summonNum,
    required this.item,
  });

  factory NiceServantCoin.fromJson(Map<String, dynamic> json) =>
      _$NiceServantCoinFromJson(json);
}

@JsonSerializable()
class ServantTrait {
  int idx;
  List<NiceTrait> trait;
  int limitCount;
  CondType? condType;
  int? ondId;
  int? condNum;

  ServantTrait({
    required this.idx,
    required this.trait,
    required this.limitCount,
    this.condType,
    this.ondId,
    this.condNum,
  });

  factory ServantTrait.fromJson(Map<String, dynamic> json) =>
      _$ServantTraitFromJson(json);
}

@JsonSerializable()
class LoreCommentAdd {
  int idx;
  CondType condType;
  List<int> condValues;
  int condValue2;

  LoreCommentAdd({
    required this.idx,
    required this.condType,
    required this.condValues,
    required this.condValue2,
  });

  factory LoreCommentAdd.fromJson(Map<String, dynamic> json) =>
      _$LoreCommentAddFromJson(json);
}

@JsonSerializable()
class LoreComment {
  int id;
  int priority;
  String condMessage;
  CondType condType;
  List<int>? condValues;
  int condValue2;
  List<LoreCommentAdd> additionalConds;

  LoreComment({
    required this.id,
    required this.priority,
    required this.condMessage,
    required this.condType,
    this.condValues,
    required this.condValue2,
    required this.additionalConds,
  });

  factory LoreComment.fromJson(Map<String, dynamic> json) =>
      _$LoreCommentFromJson(json);
}

@JsonSerializable()
class LoreStatus {
  String strength;
  String endurance;
  String agility;
  String magic;
  String luck;
  String np;
  ServantPolicy policy;
  ServantPersonality personality;
  String deity;

  LoreStatus({
    required this.strength,
    required this.endurance,
    required this.agility,
    required this.magic,
    required this.luck,
    required this.np,
    required this.policy,
    required this.personality,
    required this.deity,
  });

  factory LoreStatus.fromJson(Map<String, dynamic> json) =>
      _$LoreStatusFromJson(json);
}

@JsonSerializable()
class NiceCostume {
  int id;
  int costumeCollectionNo;
  int battleCharaId;
  String name;
  String shortName;
  String detail;
  int priority;

  NiceCostume({
    required this.id,
    required this.costumeCollectionNo,
    required this.battleCharaId,
    required this.name,
    required this.shortName,
    required this.detail,
    required this.priority,
  });

  factory NiceCostume.fromJson(Map<String, dynamic> json) =>
      _$NiceCostumeFromJson(json);
}

@JsonSerializable()
class VoiceCond {
  VoiceCondType condType;
  int value;
  List<int> valueList;
  int eventId;

  VoiceCond({
    required this.condType,
    required this.value,
    required this.valueList,
    required this.eventId,
  });

  factory VoiceCond.fromJson(Map<String, dynamic> json) =>
      _$VoiceCondFromJson(json);
}

@JsonSerializable()
class VoicePlayCond {
  int condGroup;
  CondType condType;
  int targetId;
  int condValue;
  List<int> condValues;

  VoicePlayCond({
    required this.condGroup,
    required this.condType,
    required this.targetId,
    required this.condValue,
    required this.condValues,
  });

  factory VoicePlayCond.fromJson(Map<String, dynamic> json) =>
      _$VoicePlayCondFromJson(json);
}

@JsonSerializable()
class VoiceLine {
  String? name;
  CondType? condType;
  int? condValue;
  int? priority;
  SvtVoiceType? svtVoiceType;
  String overwriteName;
  dynamic summonScript;
  List<String> id;
  List<String> audioAssets;
  List<double> delay;
  List<int> face;
  List<int> form;
  List<String> text;
  String subtitle;
  List<VoiceCond> conds;
  List<VoicePlayCond> playConds;

  VoiceLine({
    this.name,
    this.condType,
    this.condValue,
    this.priority,
    required this.svtVoiceType,
    required this.overwriteName,
    required this.summonScript,
    required this.id,
    required this.audioAssets,
    required this.delay,
    required this.face,
    required this.form,
    required this.text,
    required this.subtitle,
    required this.conds,
    required this.playConds,
  });

  factory VoiceLine.fromJson(Map<String, dynamic> json) =>
      _$VoiceLineFromJson(json);
}

@JsonSerializable()
class VoiceGroup {
  int svtId;
  int voicePrefix;
  SvtVoiceType type;
  List<VoiceLine> voiceLines;

  VoiceGroup({
    required this.svtId,
    required this.voicePrefix,
    required this.type,
    required this.voiceLines,
  });

  factory VoiceGroup.fromJson(Map<String, dynamic> json) =>
      _$VoiceGroupFromJson(json);
}

@JsonSerializable()
class NiceLore {
  String cv;
  String illustrator;
  LoreStatus? stats;
  Map<int, NiceCostume> costume;
  List<LoreComment> comments;
  List<VoiceGroup> voices;

  NiceLore({
    required this.cv,
    required this.illustrator,
    this.stats,
    required this.costume,
    required this.comments,
    required this.voices,
  });

  factory NiceLore.fromJson(Map<String, dynamic> json) =>
      _$NiceLoreFromJson(json);
}

@JsonSerializable()
class ServantScript {
  Map<int, List<int>>? SkillRankUp;

  ServantScript({
    this.SkillRankUp,
  });

  factory ServantScript.fromJson(Map<String, dynamic> json) =>
      _$ServantScriptFromJson(json);
}

@JsonSerializable()
class Servant {
  int id;
  int collectionNo;
  String name;
  String ruby;
  SvtClass className;
  SvtType type;
  SvtFlag flag;
  int rarity;
  int cost;
  int lvMax;
  ExtraAssets extraAssets;
  Gender gender;
  Attribute attribute;
  List<NiceTrait> traits;
  int starAbsorb;
  int starGen;
  int instantDeathChance;
  List<CardType> cards;
  Map<CardType, List<int>> hitsDistribution;
  Map<CardType, CardDetail> cardDetails;
  int atkBase;
  int atkMax;
  int hpBase;
  int hpMax;
  List<int> relateQuestIds;
  int growthCurve;
  List<int> atkGrowth;
  List<int> hpGrowth;
  List<int> bondGrowth;
  List<int> expGrowth;
  List<int> expFeed;
  int bondEquip;
  List<int> valentineEquip;
  List<ValentineScript> valentineScript;
  int? bondEquipOwner;
  int? valentineEquipOwner;
  AscensionAdd ascensionAdd;
  List<ServantTrait> traitAdd;
  List<ServantChange> svtChange;
  Map<int, LvlUpMaterial> ascensionMaterials;
  Map<int, LvlUpMaterial> skillMaterials;
  Map<int, LvlUpMaterial> appendSkillMaterials;
  Map<int, LvlUpMaterial> costumeMaterials;
  NiceServantCoin? coin;
  ServantScript script;
  List<NiceSkill> skills;
  List<NiceSkill> classPassive;
  List<NiceSkill> extraPassive;
  List<ServantAppendPassiveSkill> appendPassive;
  List<NiceTd> noblePhantasms;
  NiceLore? profile;

  Servant({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.ruby,
    required this.className,
    required this.type,
    required this.flag,
    required this.rarity,
    required this.cost,
    required this.lvMax,
    required this.extraAssets,
    required this.gender,
    required this.attribute,
    required this.traits,
    required this.starAbsorb,
    required this.starGen,
    required this.instantDeathChance,
    required this.cards,
    required this.hitsDistribution,
    required this.cardDetails,
    required this.atkBase,
    required this.atkMax,
    required this.hpBase,
    required this.hpMax,
    required this.relateQuestIds,
    required this.growthCurve,
    required this.atkGrowth,
    required this.hpGrowth,
    required this.bondGrowth,
    required this.expGrowth,
    required this.expFeed,
    required this.bondEquip,
    required this.valentineEquip,
    required this.valentineScript,
    this.bondEquipOwner,
    this.valentineEquipOwner,
    required this.ascensionAdd,
    required this.traitAdd,
    required this.svtChange,
    required this.ascensionMaterials,
    required this.skillMaterials,
    required this.appendSkillMaterials,
    required this.costumeMaterials,
    this.coin,
    required this.script,
    required this.skills,
    required this.classPassive,
    required this.extraPassive,
    required this.appendPassive,
    required this.noblePhantasms,
    this.profile,
  });

  factory Servant.fromJson(Map<String, dynamic> json) =>
      _$ServantFromJson(json);
}
