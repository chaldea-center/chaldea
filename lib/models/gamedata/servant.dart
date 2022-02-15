import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../db.dart';
import '../userdata/filter_data.dart';
import 'common.dart';
import 'item.dart';
import 'script.dart';
import 'skill.dart';
import 'wiki_data.dart';

part '../../generated/models/gamedata/servant.g.dart';

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
  ServantCoin? coin;
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
    ExtraAssets? extraAssets,
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
    this.relateQuestIds = const [],
    required this.growthCurve,
    required this.atkGrowth,
    required this.hpGrowth,
    required this.bondGrowth,
    this.expGrowth = const [],
    this.expFeed = const [],
    this.bondEquip = 0,
    this.valentineEquip = const [],
    this.valentineScript = const [],
    this.bondEquipOwner,
    this.valentineEquipOwner,
    AscensionAdd? ascensionAdd,
    required this.traitAdd,
    this.svtChange = const [],
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
  })  : extraAssets = extraAssets ?? ExtraAssets(),
        ascensionAdd = ascensionAdd ?? AscensionAdd();

  // todo: support ascension
  String? get icon => extraAssets.faces.ascension?[1];

  String? get charaGraph => extraAssets.charaGraph.ascension?[1];

  String? get borderedIcon => icon?.replaceFirst('.png', '_bordered.png');

  Transl<String, String> get lName => Transl.svtNames(name);

  ServantExtra get extra => db2.gameData.wikiData.servants[collectionNo] ??=
      ServantExtra(collectionNo: collectionNo);

  factory Servant.fromJson(Map<String, dynamic> json) =>
      _$ServantFromJson(json);
}

@JsonSerializable()
class CraftEssence {
  int id;
  int collectionNo;
  String name;
  SvtType type;
  SvtFlag flag;
  int rarity;
  int cost;
  int lvMax;
  ExtraAssets extraAssets;
  int atkBase;
  int atkMax;
  int hpBase;
  int hpMax;
  int growthCurve;
  List<int> atkGrowth;
  List<int> hpGrowth;
  List<int> expGrowth;
  List<int> expFeed;
  int? bondEquipOwner;
  int? valentineEquipOwner;
  List<ValentineScript> valentineScript;
  AscensionAdd ascensionAdd;
  List<NiceSkill> skills;
  NiceLore? profile;

  CraftEssence({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.type,
    required this.flag,
    required this.rarity,
    required this.cost,
    required this.lvMax,
    ExtraAssets? extraAssets,
    required this.atkBase,
    required this.atkMax,
    required this.hpBase,
    required this.hpMax,
    required this.growthCurve,
    required this.atkGrowth,
    required this.hpGrowth,
    this.expGrowth = const [],
    this.expFeed = const [],
    this.bondEquipOwner,
    this.valentineEquipOwner,
    this.valentineScript = const [],
    AscensionAdd? ascensionAdd,
    required this.skills,
    this.profile,
  })  : extraAssets = extraAssets ?? ExtraAssets(),
        ascensionAdd = ascensionAdd ?? AscensionAdd();

  factory CraftEssence.fromJson(Map<String, dynamic> json) =>
      _$CraftEssenceFromJson(json);

  String? get icon => extraAssets.faces.equip?[id];

  String? get charaGraph => extraAssets.charaGraph.equip?[id];

  String? get borderedIcon => icon?.replaceFirst('.png', '_bordered.png');

  Transl<String, String> get lName => Transl.ceNames(name);

  CraftEssenceExtra get extra =>
      db2.gameData.wikiData.craftEssences[collectionNo] ??=
          CraftEssenceExtra(collectionNo: collectionNo);

  CraftATKType get atkType {
    return atkMax > 0
        ? hpMax > 0
            ? CraftATKType.mix
            : CraftATKType.atk
        : hpMax > 0
            ? CraftATKType.hp
            : CraftATKType.none;
  }
}

@JsonSerializable()
class ExtraAssetsUrl {
  final Map<int, String>? ascension;
  final Map<int, String>? story;
  final Map<int, String>? costume;
  final Map<int, String>? equip;
  final Map<int, String>? cc;

  const ExtraAssetsUrl({
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
    this.charaGraph = const ExtraAssetsUrl(),
    this.faces = const ExtraAssetsUrl(),
    this.charaGraphEx = const ExtraAssetsUrl(),
    this.charaGraphName = const ExtraAssetsUrl(),
    this.narrowFigure = const ExtraAssetsUrl(),
    this.charaFigure = const ExtraAssetsUrl(),
    this.charaFigureForm = const {},
    this.charaFigureMulti = const {},
    this.commands = const ExtraAssetsUrl(),
    this.status = const ExtraAssetsUrl(),
    this.equipFace = const ExtraAssetsUrl(),
    this.image = const ExtraAssetsUrl(),
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

// in adapters.dart
@JsonSerializable(constructor: 'typed')
class AscensionAddEntry<T> {
  final Map<int, T> ascension;
  final Map<int, T> costume;

  @protected
  AscensionAddEntry({
    Map<dynamic, dynamic> ascension = const {},
    Map<dynamic, dynamic> costume = const {},
  })  : ascension = ascension.cast(),
        costume = costume.cast();

  AscensionAddEntry.typed({
    this.ascension = const {},
    this.costume = const {},
  });

  AscensionAddEntry<S> cast<S>() {
    // print('casting $S');
    if (S == int || S == double || S == String) {
      return AscensionAddEntry<S>.typed(
        ascension: ascension.cast<int, S>(),
        costume: costume.cast<int, S>(),
      );
    }
    // print([S, S.toString(), List, S == List]);
    // if (S == List) {
    // now only List<NiceTrait>
    // print([ascension.runtimeType]);
    return AscensionAddEntry<S>.typed(
      ascension: ascension.map((key, value) =>
          MapEntry(key, (value as List).cast<NiceTrait>() as S)),
      costume: costume.map((key, value) =>
          MapEntry(key, (value as List).cast<NiceTrait>() as S)),
    );
    // }
    // throw ArgumentError.value(S, 'type', 'Unknown cast type');
  }

  factory AscensionAddEntry.fromJson(Map<String, dynamic> json) =>
      _$AscensionAddEntryFromJson(json, _fromJsonT);

  static T _fromJsonT<T>(Object? obj) {
    // obj: List<dynamic>
    if (obj == null) return null as T;
    if (obj is int || obj is double || obj is String) return obj as T;
    if (obj is List) {
      // now only List<NiceTrait>
      return obj
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() as T;
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
    AscensionAddEntry? individuality,
    AscensionAddEntry? voicePrefix,
    AscensionAddEntry? overWriteServantName,
    AscensionAddEntry? overWriteServantBattleName,
    AscensionAddEntry? overWriteTDName,
    AscensionAddEntry? overWriteTDRuby,
    AscensionAddEntry? overWriteTDFileName,
    AscensionAddEntry? overWriteTDRank,
    AscensionAddEntry? overWriteTDTypeText,
    AscensionAddEntry? lvMax,
  })  : voicePrefix = voicePrefix?.cast<int>() ?? AscensionAddEntry(),
        overWriteServantName =
            overWriteServantName?.cast<String>() ?? AscensionAddEntry(),
        overWriteServantBattleName =
            overWriteServantBattleName?.cast<String>() ?? AscensionAddEntry(),
        overWriteTDName =
            overWriteTDName?.cast<String>() ?? AscensionAddEntry(),
        individuality =
            individuality?.cast<List<NiceTrait>>() ?? AscensionAddEntry(),
        overWriteTDRuby =
            overWriteTDRuby?.cast<String>() ?? AscensionAddEntry(),
        overWriteTDFileName =
            overWriteTDFileName?.cast<String>() ?? AscensionAddEntry(),
        overWriteTDRank =
            overWriteTDRank?.cast<String>() ?? AscensionAddEntry(),
        overWriteTDTypeText =
            overWriteTDTypeText?.cast<String>() ?? AscensionAddEntry(),
        lvMax = lvMax?.cast<int>() ?? AscensionAddEntry();

  // AscensionAdd({
  //   this.individuality = const AscensionAddEntry(),
  //   this.voicePrefix = const AscensionAddEntry(),
  //   this.overWriteServantName = const AscensionAddEntry(),
  //   this.overWriteServantBattleName = const AscensionAddEntry(),
  //   this.overWriteTDName = const AscensionAddEntry(),
  //   this.overWriteTDRuby = const AscensionAddEntry(),
  //   this.overWriteTDFileName = const AscensionAddEntry(),
  //   this.overWriteTDRank = const AscensionAddEntry(),
  //   this.overWriteTDTypeText = const AscensionAddEntry(),
  //   this.lvMax = const AscensionAddEntry(),
  // });

  factory AscensionAdd.fromJson(Map<String, dynamic> json) =>
      _$AscensionAddFromJson(json);
}

@JsonSerializable()
class ServantChange {
  List<int> beforeTreasureDeviceIds;
  List<int> afterTreasureDeviceIds;
  int svtId;
  int priority;
  @JsonKey(fromJson: toEnumCondType)
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
class ServantCoin {
  int summonNum;
  Item item;

  ServantCoin({
    required this.summonNum,
    required this.item,
  });

  factory ServantCoin.fromJson(Map<String, dynamic> json) =>
      _$ServantCoinFromJson(json);
}

@JsonSerializable()
class ServantTrait {
  int idx;
  List<NiceTrait> trait;
  int limitCount;
  @JsonKey(fromJson: toEnumNullCondType)
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
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  List<int> condValues;
  int condValue2;

  LoreCommentAdd({
    required this.idx,
    required this.condType,
    required this.condValues,
    this.condValue2 = 0,
  });

  factory LoreCommentAdd.fromJson(Map<String, dynamic> json) =>
      _$LoreCommentAddFromJson(json);
}

@JsonSerializable()
class LoreComment {
  int id;
  int priority;
  String condMessage;
  String comment;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  List<int>? condValues;
  int condValue2;
  List<LoreCommentAdd> additionalConds;

  LoreComment({
    required this.id,
    this.priority = 0,
    this.condMessage = "",
    this.comment = '',
    required this.condType,
    this.condValues,
    this.condValue2 = 0,
    this.additionalConds = const [],
  });

  factory LoreComment.fromJson(Map<String, dynamic> json) =>
      _$LoreCommentFromJson(json);
}

@JsonSerializable()
class LoreStatus {
  String? strength;
  String? endurance;
  String? agility;
  String? magic;
  String? luck;
  String? np;
  ServantPolicy? policy;
  ServantPersonality? personality;
  String? deity;

  LoreStatus({
    this.strength,
    this.endurance,
    this.agility,
    this.magic,
    this.luck,
    this.np,
    this.policy,
    this.personality,
    this.deity,
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
    this.valueList = const [],
    this.eventId = 0,
  });

  factory VoiceCond.fromJson(Map<String, dynamic> json) =>
      _$VoiceCondFromJson(json);
}

@JsonSerializable()
class VoicePlayCond {
  int condGroup;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int targetId;
  int condValue;
  List<int> condValues;

  VoicePlayCond({
    required this.condGroup,
    required this.condType,
    required this.targetId,
    required this.condValue,
    this.condValues = const [],
  });

  factory VoicePlayCond.fromJson(Map<String, dynamic> json) =>
      _$VoicePlayCondFromJson(json);
}

@JsonSerializable()
class VoiceLine {
  String? name;
  @JsonKey(fromJson: toEnumNullCondType)
  CondType? condType;
  int? condValue;
  int? priority;
  SvtVoiceType? svtVoiceType;
  String overwriteName;
  ScriptLink? summonScript;
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
    this.overwriteName = "",
    this.summonScript,
    this.id = const [],
    this.audioAssets = const [],
    this.delay = const [],
    this.face = const [],
    this.form = const [],
    this.text = const [],
    this.subtitle = "",
    this.conds = const [],
    this.playConds = const [],
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
    this.voiceLines = const [],
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
    this.cv = '',
    required this.illustrator,
    this.stats,
    this.costume = const {},
    this.comments = const [],
    this.voices = const [],
  });

  factory NiceLore.fromJson(Map<String, dynamic> json) =>
      _$NiceLoreFromJson(json);
}

@JsonSerializable()
class ServantScript {
  @JsonKey(name: 'SkillRankUp')
  Map<int, List<int>>? skillRankUp;
  bool? svtBuffTurnExtend;

  ServantScript({
    this.skillRankUp,
    this.svtBuffTurnExtend,
  });

  factory ServantScript.fromJson(Map<String, dynamic> json) =>
      _$ServantScriptFromJson(json);
}

enum SvtType {
  normal,
  heroine,
  combineMaterial,
  enemy,
  enemyCollection,
  servantEquip,
  statusUp,
  svtEquipMaterial,
  enemyCollectionDetail,
  all,
  commandCode,
  svtMaterialTd,
}

enum SvtFlag {
  onlyUseForNpc,
  svtEquipFriendShip,
  ignoreCombineLimitSpecial,
  svtEquipExp,
  svtEquipChocolate,
  normal,
  goetia,
  matDropRateUpCe,
}

enum Attribute {
  human,
  sky,
  earth,
  star,
  beast,
  @JsonValue('void')
  void_,
}
enum ServantPolicy {
  none,
  neutral,
  lawful,
  chaotic,
  unknown,
}
enum ServantPersonality {
  none,
  good,
  madness,
  balanced,
  summer,
  evil,
  goodAndEvil,
  bride,
  unknown,
}

enum VoiceCondType {
  birthDay,
  event,
  friendship,
  svtGet,
  svtGroup,
  questClear,
  notQuestClear,
  levelUp,
  limitCount,
  limitCountCommon,
  countStop,
  isnewWar,
  eventEnd,
  eventNoend,
  eventMissionAction,
  masterMission,
  limitCountAbove,
  eventShopPurchase,
  eventPeriod,
  friendshipAbove,
  spacificShopPurchase,
  friendshipBelow,
  costume,
  levelUpLimitCount,
  levelUpLimitCountAbove,
  levelUpLimitCountBelow,
}

enum SvtVoiceType {
  home,
  groeth,
  firstGet,
  eventJoin,
  eventReward,
  battle,
  treasureDevice,
  masterMission,
  eventShop,
  homeCostume,
  boxGachaTalk,
  battleEntry,
  battleWin,
  eventTowerReward,
  guide,
  eventDailyPoint,
  tddamage,
  treasureBox,
  sum,
}
enum Gender {
  male,
  female,
  unknown,
}
