import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/app/routes/routes.dart';
import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '../userdata/filter_data.dart';
import 'common.dart';
import 'game_card.dart';
import 'item.dart';
import 'mappings.dart';
import 'script.dart';
import 'skill.dart';
import 'wiki_data.dart';

part '../../generated/models/gamedata/servant.g.dart';

@JsonSerializable()
class BasicCostume {
  int id;
  int costumeCollectionNo;
  int battleCharaId;
  String shortName;

  BasicCostume({
    required this.id,
    required this.costumeCollectionNo,
    required this.battleCharaId,
    required this.shortName,
  });

  factory BasicCostume.fromJson(Map<String, dynamic> json) =>
      _$BasicCostumeFromJson(json);
}

@JsonSerializable()
class BasicServant with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  SvtType type;
  SvtFlag flag;
  SvtClass className;
  Attribute attribute;
  @override
  int rarity;
  int atkMax;
  int hpMax;
  String face;
  Map<int, BasicCostume> costume;

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
    this.costume = const {},
  });

  factory BasicServant.fromJson(Map<String, dynamic> json) =>
      _$BasicServantFromJson(json);

  @override
  Transl<String, String> get lName => Transl.entityNames(name);

  @override
  String get icon => face;

  @override
  String? get borderedIcon {
    if (type == SvtType.combineMaterial || type == SvtType.statusUp) {
      return super.borderedIcon;
    }
    return icon;
  }

  @override
  void routeTo() => routeToId(Routes.servant);
}

@JsonSerializable()
class Servant with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  String ruby;
  SvtClass className;
  SvtType type;
  SvtFlag flag;
  @override
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
  List<ServantLimitImage> ascensionImage;
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
  NiceLore profile;

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
    this.ascensionImage = const [],
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
    NiceLore? profile,
  })  : extraAssets = extraAssets ?? ExtraAssets(),
        ascensionAdd = ascensionAdd ?? AscensionAdd(),
        profile = profile ?? NiceLore() {
    preprocess();
  }

  factory Servant.fromJson(Map<String, dynamic> json) =>
      _$ServantFromJson(json);
  @JsonKey(ignore: true)
  late List<List<NiceSkill>> groupedActiveSkills;
  @JsonKey(ignore: true)
  late List<List<NiceTd>> groupedNoblePhantasms;

  void preprocess() {
    appendPassive.sort2((e) => e.num * 100 + e.priority);
    // groupedActiveSkills
    Map<int, List<NiceSkill>> dividedSkills = {};
    for (final skill in skills) {
      dividedSkills.putIfAbsent(skill.num, () => []).add(skill);
    }
    groupedActiveSkills = [
      for (final key in dividedSkills.keys.toList()..sort())
        dividedSkills[key]!..sort2((e) => e.priority)
    ];
    // groupedNoblePhantasms
    Map<int, List<NiceTd>> dividedTds = {};
    for (final td in noblePhantasms) {
      dividedTds.putIfAbsent(td.num, () => []).add(td);
    }
    groupedNoblePhantasms = [
      for (final key in dividedTds.keys.toList()..sort())
        dividedTds[key]!..sort2((e) => e.priority)
    ];
  }

  String get route => '${Routes.servant}/$collectionNo';

  @override
  void routeTo() => routeToId(Routes.servant);

  bool get isUserSvt =>
      (type == SvtType.normal || type == SvtType.heroine) && collectionNo > 0;

  @override
  String? get icon =>
      extraAssets.faces.ascension?[1] ??
      extraAssets.faces.ascension?.values.toList().getOrNull(0);

  String? get charaGraph => extraAssets.charaGraph.ascension?[1];

  String? get customIcon {
    final _icon = db.userData.customSvtIcon[collectionNo] ??
        extraAssets.faces.ascension?[db.userData.svtAscensionIcon] ??
        icon;
    return bordered(_icon);
  }

  @override
  Widget iconBuilder(
      {required BuildContext context,
      double? width,
      double? height,
      double? aspectRatio = 132 / 144,
      String? text,
      EdgeInsets? padding,
      EdgeInsets? textPadding,
      VoidCallback? onTap,
      bool jumpToDetail = true,
      bool popDetail = false,
      String? overrideIcon}) {
    return super.iconBuilder(
      context: context,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text,
      padding: padding,
      textPadding: textPadding,
      onTap: onTap,
      jumpToDetail: jumpToDetail,
      popDetail: popDetail,
      overrideIcon: overrideIcon ?? customIcon,
    );
  }

  @override
  Transl<String, String> get lName =>
      Transl.svtNames(ascensionAdd.overWriteServantName.ascension[0] ?? name);

  ServantExtra get extra => db.gameData.wiki.servants[collectionNo] ??=
      ServantExtra(collectionNo: collectionNo);

  Set<Trait> get traitsAll {
    if (_traitsAll != null) return _traitsAll!;
    List<NiceTrait> _traits = [];
    _traits.addAll(traits);
    for (var v in ascensionAdd.individuality.ascension.values) {
      _traits.addAll(v);
    }
    for (var v in ascensionAdd.individuality.costume.values) {
      _traits.addAll(v);
    }
    return _traitsAll = _traits.map((e) => e.name).toSet();
  }

  Set<Trait>? _traitsAll;

  int grailedLv(int grails) {
    final costs = db.gameData.constData.svtGrailCost[rarity]?[grails];
    if (costs == null) return lvMax;
    return costs.addLvMax + lvMax;
  }

  Map<int, LvlUpMaterial> get grailUpMaterials {
    Map<int, LvlUpMaterial> materials = {};
    final costs = db.gameData.constData.svtGrailCost[rarity];
    if (costs != null) {
      for (final endLv in costs.keys) {
        materials[endLv - 1] = LvlUpMaterial(
          items: [
            ItemAmount(amount: 1, item: Items.grail),
            if (lvMax + costs[endLv]!.addLvMax > 100)
              ItemAmount(amount: 30, item: coin!.item)
          ],
          qp: costs[endLv]!.qp,
        );
      }
    }
    return materials;
  }

  void updateStat() {
    db.itemCenter.updateSvts(svts: [this]);
  }
}

@JsonSerializable()
class CraftEssence with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  SvtType type;
  SvtFlag flag;
  @override
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
  NiceLore profile;

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
    this.atkGrowth = const [],
    this.hpGrowth = const [],
    this.expGrowth = const [],
    this.expFeed = const [],
    this.bondEquipOwner,
    this.valentineEquipOwner,
    this.valentineScript = const [],
    AscensionAdd? ascensionAdd,
    required this.skills,
    NiceLore? profile,
  })  : extraAssets = extraAssets ?? ExtraAssets(),
        ascensionAdd = ascensionAdd ?? AscensionAdd(),
        profile = profile ?? NiceLore();

  factory CraftEssence.fromJson(Map<String, dynamic> json) =>
      _$CraftEssenceFromJson(json);

  @override
  String? get icon => extraAssets.faces.equip?[id];

  String? get charaGraph => extraAssets.charaGraph.equip?[id];

  @override
  Transl<String, String> get lName => Transl.ceNames(name);

  CraftEssenceExtra get extra =>
      db.gameData.wiki.craftEssences[collectionNo] ??=
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

  String get route => '${Routes.craftEssence}/$collectionNo';

  @override
  void routeTo() => routeToId(Routes.craftEssence);
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

  Iterable<String> get allUrls sync* {
    if (ascension != null) yield* ascension!.values;
    if (costume != null) yield* costume!.values;
    if (equip != null) yield* equip!.values;
    if (cc != null) yield* cc!.values;
    if (story != null) yield* story!.values;
  }

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
  ExtraAssetsUrl spriteModel;
  ExtraAssetsUrl charaGraphChange;
  ExtraAssetsUrl narrowFigureChange;
  ExtraAssetsUrl facesChange;

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
    this.spriteModel = const ExtraAssetsUrl(),
    this.charaGraphChange = const ExtraAssetsUrl(),
    this.narrowFigureChange = const ExtraAssetsUrl(),
    this.facesChange = const ExtraAssetsUrl(),
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

// TODO: manually convert List<NiceTrait>
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
  AscensionAddEntry<String> charaGraphChange;
  AscensionAddEntry<String> faceChange;
  // AscensionAddEntry<List<CommonRelease>> charaGraphChangeCommonRelease;
  // AscensionAddEntry<List<CommonRelease>> faceChangeCommonRelease;

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
    AscensionAddEntry? charaGraphChange,
    AscensionAddEntry? faceChange,
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
        lvMax = lvMax?.cast<int>() ?? AscensionAddEntry(),
        charaGraphChange =
            charaGraphChange?.cast<String>() ?? AscensionAddEntry(),
        faceChange = faceChange?.cast<String>() ?? AscensionAddEntry();

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
class ServantLimitImage {
  int limitCount;
  int priority;
  int defaultLimitCount;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int condTargetId;
  int condNum;

  ServantLimitImage({
    required this.limitCount,
    this.priority = 0,
    required this.defaultLimitCount,
    required this.condType,
    required this.condTargetId,
    required this.condNum,
  });

  factory ServantLimitImage.fromJson(Map<String, dynamic> json) =>
      _$ServantLimitImageFromJson(json);
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

  Transl<String, String> get lName => Transl.costumeNames(name);
  Transl<int, String> get lDetail => Transl.costumeDetail(costumeCollectionNo);

  String get face =>
      'https://static.atlasacademy.io/JP/Faces/f_${battleCharaId}0.png';

  String get icon => face;

  String get borderedIcon => icon.replaceAll('.png', '_bordered.png');

  String get charaGraph =>
      'https://static.atlasacademy.io/JP/CharaGraph/$battleCharaId/$battleCharaId.png';

  Servant? get owner => db.gameData.others.costumeSvtMap[costumeCollectionNo];

  String get route => Routes.costumeI(costumeCollectionNo);
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
    this.voicePrefix = 0,
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
    this.illustrator = '',
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
