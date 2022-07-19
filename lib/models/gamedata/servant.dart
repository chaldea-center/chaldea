import 'package:flutter/material.dart';

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../db.dart';
import '../userdata/filter_data.dart';
import '../userdata/userdata.dart';
import '_helper.dart';
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

const kSvtDefAscenRemap = <int, int>{
  9939360: 1, // ダユー
  9943860: 1, // 張角
};

@JsonSerializable()
class BasicServant with GameCardMixin {
  @override
  int id;
  @override
  int collectionNo;
  @override
  String name;
  String? overwriteName;
  SvtType type;
  SvtFlag flag;
  SvtClass className;
  Attribute attribute;
  @override
  int rarity;
  int atkMax;
  int hpMax;
  @protected
  String face;
  Map<int, BasicCostume> costume;

  BasicServant({
    required this.id,
    required this.collectionNo,
    required this.name,
    this.overwriteName,
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
  Transl<String, String> get lName => Transl.svtNames(name);

  @override
  String get icon {
    final _remapId = kSvtDefAscenRemap[id];
    if (_remapId != null) {
      final s = face.replaceFirst(RegExp('$id\\d\\.png\$'), '$id$_remapId.png');
      return s;
    }
    return face;
  }

  @override
  String get borderedIcon {
    if (type == SvtType.combineMaterial || type == SvtType.statusUp) {
      return super.borderedIcon!;
    }
    return icon;
  }

  String get route =>
      collectionNo > 0 ? Routes.servantI(id) : Routes.enemyI(id);

  String get routeIfItem {
    if (Items.specialSvtMat.contains(id)) return Routes.itemI(id);
    return route;
  }

  @override
  void routeTo() {
    router.push(url: route);
  }
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
  String battleName;
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
  List<int> trialQuestIds;
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
    this.ruby = "",
    this.battleName = "",
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
    this.trialQuestIds = const [],
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
  String? get icon => extraAssets.faces.ascension?.values
      .toList()
      .getOrNull(kSvtDefAscenRemap[id] ?? 0);

  @override
  String? get borderedIcon => collectionNo > 0 ||
          (type == SvtType.combineMaterial || type == SvtType.statusUp)
      ? super.borderedIcon
      : icon;

  String? get charaGraph => extraAssets.charaGraph.ascension?[1];

  String? get customIcon {
    if (collectionNo <= 0) return borderedIcon;
    String? _icon = db.userData.customSvtIcon[collectionNo];
    if (_icon != null) return _icon;

    if (db.userData.preferAprilFoolIcon) {
      _icon = aprilFoolBorderedIcon;
      if (_icon != null) return _icon;
    }
    _icon = extraAssets.faces.ascension?[db.userData.svtAscensionIcon] ?? icon;
    return bordered(_icon);
  }

  String? get aprilFoolIcon {
    if (collectionNo <= 0 || collectionNo > 306) return null;
    if ([83, 149, 151, 152, 168, 240].contains(collectionNo)) return null;
    final padded = collectionNo.toString().padLeft(3, '0');
    return '${Hosts.kAtlasAssetHostGlobal}/JP/FFO/Atlas/Sprite/icon_servant_$padded.png';
  }

  String? get aprilFoolBorderedIcon {
    if (aprilFoolIcon == null) return null;
    final padded = collectionNo.toString().padLeft(3, '0');
    return '${Hosts.kAtlasAssetHostGlobal}/JP/FFO/Atlas/Sprite_bordered/icon_servant_${padded}_bordered.png';
  }

  String? get classCard {
    const suffixes = {
      SvtClass.saber: "1@1",
      SvtClass.archer: "1@2",
      SvtClass.lancer: "3@1",
      SvtClass.rider: "3@2",
      SvtClass.caster: "5@1",
      SvtClass.assassin: "5@2",
      SvtClass.berserker: "7@1",
      SvtClass.shielder: "13@1",
      SvtClass.ruler: "7@2",
      SvtClass.alterEgo: "11@2",
      SvtClass.avenger: "11@1",
      SvtClass.moonCancer: "23@1",
      SvtClass.foreigner: "25@1",
      SvtClass.pretender: "27@1",
    };
    final suffix =
        collectionNo == 285 ? "123@1" : suffixes[className] ?? "13@1";
    final color = ['n', 'b', 's', 'g'][GameCardMixin.bsgColor(rarity)];
    return Atlas.asset('ClassCard/class_${color}_$suffix.png');
  }

  @override
  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
    String? overrideIcon,
    String? name,
    bool showName = false,
  }) {
    //
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
      name: name,
      showName: showName,
    );
  }

  @override
  Transl<String, String> get lName =>
      Transl.svtNames(ascensionAdd.overWriteServantName.ascension[0] ?? name);

  Set<String> get allNames {
    return <String>{
      name,
      battleName,
      ...ascensionAdd.overWriteServantName.all.values,
      ...ascensionAdd.overWriteServantBattleName.all.values,
      ...svtChange.map((e) => e.name),
      ...svtChange.map((e) => e.battleName)
    };
  }

  ServantExtra get extra => db.gameData.wiki.servants[collectionNo] ??=
      ServantExtra(collectionNo: collectionNo);

  Set<int> get traitsAll {
    if (_traitsAll != null) return _traitsAll!;
    List<NiceTrait> _traits = [];
    _traits.addAll(traits);
    for (var v in ascensionAdd.individuality.ascension.values) {
      _traits.addAll(v);
    }
    for (var v in ascensionAdd.individuality.costume.values) {
      _traits.addAll(v);
    }
    for (final t in traitAdd) {
      _traits.addAll(t.trait);
    }
    return _traitsAll = _traits.map((e) => e.id).toSet();
  }

  Set<int>? _traitsAll;

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

  Iterable<NiceSkill> eventSkills(int eventId) {
    return extraPassive.where((skill) => skill.functions
        .any((func) => func.svals.getOrNull(0)?.EventId == eventId));
  }

  NiceSkill? getDefaultSkill(List<NiceSkill> skills, Region region) {
    skills = skills.where((e) => e.num > 0).toList();
    final priorities =
        db.gameData.mappingData.skillPriority[id]?.ofRegion(region);
    if (collectionNo == 1) {
      skills = skills.where((e) => priorities?[e.id] != null).toList();
    }
    if (skills.isEmpty) return null;
    if (region == Region.jp) {
      return Maths.findMax<NiceSkill, int>(skills, (e) => e.priority);
    } else {
      return Maths.findMax<NiceSkill, int>(
          skills, (e) => priorities?[e.id] ?? -1);
    }
  }

  SvtStatus get status => db.curUser.svtStatusOf(collectionNo);
  SvtPlan get curPlan => db.curUser.svtPlanOf(collectionNo);
}

@JsonSerializable()
class BasicCraftEssence with GameCardMixin {
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
  int atkMax;
  int hpMax;
  String face;

  BasicCraftEssence({
    required this.id,
    required this.collectionNo,
    required this.name,
    required this.type,
    required this.flag,
    required this.rarity,
    required this.atkMax,
    required this.hpMax,
    required this.face,
  });

  factory BasicCraftEssence.fromJson(Map<String, dynamic> json) =>
      _$BasicCraftEssenceFromJson(json);

  @override
  String get icon => face;

  @override
  Transl<String, String> get lName => Transl.ceNames(name);

  @override
  void routeTo() {
    routeToId(Routes.craftEssence);
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
  String ruby;
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
    this.ruby = "",
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

  @override
  String? get borderedIcon {
    if (collectionNo > 0) return super.borderedIcon;
    return icon;
  }

  String? get charaGraph => extraAssets.charaGraph.equip?[id];

  @override
  Transl<String, String> get lName => Transl.ceNames(name);

  CraftEssenceExtra get extra =>
      db.gameData.wiki.craftEssences[collectionNo] ??=
          CraftEssenceExtra(collectionNo: collectionNo);

  CEObtain get obtain => bondEquipOwner != null
      ? CEObtain.bond
      : valentineEquipOwner != null
          ? CEObtain.valentine
          : extra.obtain;

  CraftATKType get atkType {
    return atkMax > 0
        ? hpMax > 0
            ? CraftATKType.mix
            : CraftATKType.atk
        : hpMax > 0
            ? CraftATKType.hp
            : CraftATKType.none;
  }

  Iterable<NiceSkill> eventSkills(int eventId) {
    return skills.where((skill) => skill.functions
        .any((func) => func.svals.getOrNull(0)?.EventId == eventId));
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

  Map<int, T> get all => {...ascension, ...costume};

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
  String ruby;
  String battleName;
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
    this.ruby = "",
    this.battleName = "",
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
  int? condId;
  int? condNum;

  ServantTrait({
    required this.idx,
    required this.trait,
    required this.limitCount,
    this.condType,
    this.condId,
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

  void routeTo() {
    router.push(url: route);
  }
}

@JsonSerializable()
class VoiceCond {
  VoiceCondType condType;
  int value;
  List<int> valueList;
  int eventId;

  VoiceCond({
    this.condType = VoiceCondType.unknown,
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
    this.svtVoiceType,
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
    this.type = SvtVoiceType.unknown,
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
  unknown,
}

enum SvtVoiceType {
  unknown,
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
  warBoard,
  eventDigging,
  eventExpedition,
  sum,
}

enum Gender {
  male,
  female,
  unknown,
}
