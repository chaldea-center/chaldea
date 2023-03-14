import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app/app.dart';
import '../db.dart';
import '../userdata/filter_data.dart';
import '../userdata/userdata.dart';
import '_helper.dart';
import 'common.dart';
import 'const_data.dart';
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

  factory BasicCostume.fromJson(Map<String, dynamic> json) => _$BasicCostumeFromJson(json);
}

const kSvtDefAscenRemap = <int, int>{
  9935510: 1, // ゲーティア
  9936700: 1, // アルトリア・ペンドラゴン
  9936701: 1, // アルトリア・ペンドラゴン
  9936870: 1, // イリヤスフィール
  9936880: 1, // クロエ・フォン・アインツベルン
  9936960: 1, // 佐々木小次郎
  9936980: 3, // エミヤ
  9936990: 2, // 天草四郎
  9937000: 1, // アルトリア・ペンドラゴン〔オルタ〕
  9937120: 1, // エルキドゥ
  9937200: 1, // 牛若丸
  9938960: 1, // 真田エミ村
  9938980: 1, // スーパー土方
  9939010: 1, // 新宿のアーチャー
  9939020: 1, // 新宿のアーチャー
  9939150: 2, // 殺生院キアラ
  9939160: 1, // パッションリップ
  9939360: 1, // ダユー
  9939370: 1, // メガロス
  9939570: 1, // メイヴ監獄長
  9939580: 1, // ネロ・クラウディウス
  9939690: 4, // 宝蔵院胤舜
  9939700: 2, // 酒呑童子
  9939710: 2, // 源頼光
  9940370: 1, // 黒聖杯
  9940380: 1, // 火のアイリ
  9940390: 1, // 水のアイリ
  9940400: 1, // 風のアイリ
  9940410: 1, // 土のアイリ
  9940530: 1, // 茨木童子
  9940600: 1, // 丑御前
  9941050: 4, // アビゲイル・ウィリアムズ
  9941170: 3, // アナスタシア
  9941180: 4, // シグルド
  9941400: 1, // ＢＢ
  9941540: 1, // 始皇帝
  9941670: 1, // ブラック・ケツァルマスク
  9941700: 1, // おんせん魔猿
  9941710: 1, // がんたん魔猿
  9941720: 1, // ふろしき魔猿
  9941750: 1, // 衛士長
  9941880: 1, // カーマ
  9941900: 1, // 哪吒
  9942010: 1, // ウィリアム・シェイクスピア
  9942080: 1, // アルジュナ〔オルタ〕
  9942150: 1, // 宮本武蔵
  9942250: 1, // キリシュタリア
  9942410: 1, // タマモキャット
  9942510: 1, // カリギュラ
  9943090: 1, // アルトリア・キャスター
  9943220: 1, // パーシヴァル
  9943280: 1, // パーシヴァル
  9943320: 0, // 妖精騎士ランスロット
  9943330: 2, // メリュジーヌ
  9943410: 1, // カーマ
  9943850: 1, // ドン・キホーテ
  9943860: 1, // 張角
  9943880: 1, // ジェームズ・モリアーティ
  9944220: 2, // 千利休
};

@JsonSerializable(converters: [SvtClassConverter()])
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
  int classId;
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
    this.className = SvtClass.none,
    this.classId = 0,
    required this.attribute,
    required this.rarity,
    required this.atkMax,
    required this.hpMax,
    required this.face,
    this.costume = const {},
  });

  factory BasicServant.fromJson(Map<String, dynamic> json) => _$BasicServantFromJson(json);

  bool get isUserSvt => (type == SvtType.normal || type == SvtType.heroine) && collectionNo > 0;

  @override
  Transl<String, String> get lName => Transl.svtNames(name);

  @override
  String get icon {
    final _remapId = kSvtDefAscenRemap[id];
    if (_remapId != null && face.contains(id.toString())) {
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

  @override
  String get route => collectionNo > 0 ? Routes.servantI(id) : Routes.enemyI(id);

  String get routeIfItem {
    if (Items.specialSvtMat.contains(id)) return Routes.itemI(id);
    return route;
  }
}

@JsonSerializable(converters: [SvtClassConverter()])
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
  int classId;
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
  Map<CardType, CardDetail> cardDetails;
  int atkBase;
  int atkMax;
  int hpBase;
  int hpMax;
  List<int> relateQuestIds;
  List<int> trialQuestIds;
  int growthCurve;
  List<int> bondGrowth;
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
  ServantScript? script;
  List<NiceSkill> skills;
  List<NiceSkill> classPassive;
  List<NiceSkill> extraPassive;
  List<ServantAppendPassiveSkill> appendPassive;
  List<NiceTd> noblePhantasms;
  NiceLore profile;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int originalCollectionNo;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late SvtExpData curveData =
      SvtExpData.from(type: growthCurve, atkBase: atkBase, atkMax: atkMax, hpBase: hpBase, hpMax: hpMax);
  List<int> get atkGrowth => curveData.atk;
  List<int> get hpGrowth => curveData.hp; // [1:]
  List<int> get expGrowth => curveData.exp; // [0:]

  Servant({
    required this.id,
    required this.collectionNo,
    int? originalCollectionNo,
    required this.name,
    this.ruby = "",
    this.battleName = "",
    this.className = SvtClass.none,
    this.classId = 0,
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
    required this.cardDetails,
    required this.atkBase,
    required this.atkMax,
    required this.hpBase,
    required this.hpMax,
    this.relateQuestIds = const [],
    this.trialQuestIds = const [],
    required this.growthCurve,
    this.bondGrowth = const [],
    this.expFeed = const [],
    this.bondEquip = 0,
    this.valentineEquip = const [],
    this.valentineScript = const [],
    this.bondEquipOwner,
    this.valentineEquipOwner,
    AscensionAdd? ascensionAdd,
    this.traitAdd = const [],
    this.svtChange = const [],
    this.ascensionImage = const [],
    this.ascensionMaterials = const {},
    this.skillMaterials = const {},
    this.appendSkillMaterials = const {},
    this.costumeMaterials = const {},
    this.coin,
    this.script,
    this.skills = const [],
    this.classPassive = const [],
    this.extraPassive = const [],
    this.appendPassive = const [],
    this.noblePhantasms = const [],
    NiceLore? profile,
  })  : originalCollectionNo = originalCollectionNo ?? collectionNo,
        extraAssets = extraAssets ?? ExtraAssets(),
        ascensionAdd = ascensionAdd ?? AscensionAdd(),
        profile = profile ?? NiceLore() {
    preprocess();
  }

  Servant copyWith({int? collectionNo}) {
    return Servant(
      id: id,
      collectionNo: collectionNo ?? this.collectionNo,
      originalCollectionNo: originalCollectionNo,
      name: name,
      ruby: ruby,
      battleName: battleName,
      className: className,
      type: type,
      flag: flag,
      rarity: rarity,
      cost: cost,
      lvMax: lvMax,
      extraAssets: extraAssets,
      gender: gender,
      attribute: attribute,
      traits: traits,
      starAbsorb: starAbsorb,
      starGen: starGen,
      instantDeathChance: instantDeathChance,
      cards: cards,
      cardDetails: cardDetails,
      atkBase: atkBase,
      atkMax: atkMax,
      hpBase: hpBase,
      hpMax: hpMax,
      relateQuestIds: relateQuestIds,
      trialQuestIds: trialQuestIds,
      growthCurve: growthCurve,
      bondGrowth: bondGrowth,
      expFeed: expFeed,
      bondEquip: bondEquip,
      valentineEquip: valentineEquip,
      valentineScript: valentineScript,
      bondEquipOwner: bondEquipOwner,
      valentineEquipOwner: valentineEquipOwner,
      ascensionAdd: ascensionAdd,
      traitAdd: traitAdd,
      svtChange: svtChange,
      ascensionImage: ascensionImage,
      ascensionMaterials: ascensionMaterials,
      skillMaterials: skillMaterials,
      appendSkillMaterials: appendSkillMaterials,
      costumeMaterials: costumeMaterials,
      coin: coin,
      script: script,
      skills: skills,
      classPassive: classPassive,
      extraPassive: extraPassive,
      appendPassive: appendPassive,
      noblePhantasms: noblePhantasms,
      profile: profile,
    );
  }

  factory Servant.fromJson(Map<String, dynamic> json) => _$ServantFromJson(json);
  @JsonKey(includeFromJson: false, includeToJson: false)
  late List<List<NiceSkill>> groupedActiveSkills;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late List<List<NiceTd>> groupedNoblePhantasms;

  void preprocess() {
    appendPassive.sort2((e) => e.num * 100 + e.priority);
    // groupedActiveSkills
    Map<int, List<NiceSkill>> dividedSkills = {};
    for (final skill in skills) {
      dividedSkills.putIfAbsent(skill.num, () => []).add(skill);
    }
    groupedActiveSkills = [
      for (final key in dividedSkills.keys.toList()..sort()) dividedSkills[key]!..sort2((e) => e.priority)
    ];
    // groupedNoblePhantasms
    Map<int, List<NiceTd>> dividedTds = {};
    for (final td in noblePhantasms) {
      // Columbus temp td during scenario chapter 11-14
      if (collectionNo == 172 && [402501, 402504].contains(td.id)) continue;
      dividedTds.putIfAbsent(td.num, () => []).add(td);
    }
    groupedNoblePhantasms = [
      for (final key in dividedTds.keys.toList()..sort()) dividedTds[key]!..sort2((e) => e.priority)
    ];
  }

  @override
  String get route => Routes.servantI(collectionNo > 0 ? collectionNo : id);

  bool get isUserSvt => (type == SvtType.normal || type == SvtType.heroine) && originalCollectionNo > 0;

  bool get isNormalSvt => [
        SvtType.normal,
        SvtType.heroine,
        SvtType.enemy,
        SvtType.enemyCollection,
        SvtType.enemyCollectionDetail,
      ].contains(type);

  @override
  String? get icon {
    final _remapId = kSvtDefAscenRemap[id];
    final _icons = <String>[
      ...?extraAssets.faces.ascension?.values,
      ...?extraAssets.faces.equip?.values,
      // ...?extraAssets.faces.cc?.values,
    ];
    String? _icon;
    if (_remapId != null) {
      _icon = _icons.firstWhereOrNull((e) => e.contains(id.toString()) && e.endsWith('$_remapId.png'));
    }
    return _icon ?? _icons.getOrNull(0);
  }

  @override
  String? get borderedIcon => originalCollectionNo > 0 || (type == SvtType.combineMaterial || type == SvtType.statusUp)
      ? super.borderedIcon
      : icon;

  String? get charaGraph => extraAssets.charaGraph.ascension?[1];

  String? get customIcon {
    if (originalCollectionNo <= 0) return borderedIcon;
    String? _icon = db.userData.customSvtIcon[collectionNo];
    if (_icon != null) return _icon;

    if (db.userData.preferAprilFoolIcon) {
      _icon = aprilFoolBorderedIcon;
      if (_icon != null) return _icon;
    }
    int ascension = db.userData.svtAscensionIcon;
    if (db.userData.svtAscensionIcon == -1 && isUserSvt) {
      ascension = status.cur.ascension;
    }

    _icon = extraAssets.faces.ascension?[ascension] ?? icon;
    if (db.gameData.isJustAddedCard(id)) return _icon;
    return bordered(_icon);
  }

  String? get aprilFoolIcon {
    if (originalCollectionNo <= 0 || originalCollectionNo > 306) return null;
    if ([83, 149, 151, 152, 168, 240].contains(originalCollectionNo)) {
      return null;
    }
    final padded = originalCollectionNo.toString().padLeft(3, '0');
    return '${Hosts.kAtlasAssetHostGlobal}/JP/FFO/Atlas/Sprite/icon_servant_$padded.png';
  }

  String? get aprilFoolBorderedIcon {
    if (aprilFoolIcon == null) return null;
    final padded = originalCollectionNo.toString().padLeft(3, '0');
    return '${Hosts.kAtlasAssetHostGlobal}/JP/FFO/Atlas/Sprite_bordered/icon_servant_${padded}_bordered.png';
  }

  String get classCard {
    int imageId = db.gameData.constData.svtClassCardImageIdRemap[collectionNo] ??
        db.gameData.constData.classInfo[className.id]?.imageId ??
        13;
    int subId = 1;
    if (imageId == 9999) imageId = 13;
    if (imageId.isEven) {
      imageId -= 1;
      subId = 2;
    }
    final color = Atlas.classColor(rarity);
    return Atlas.asset('ClassCard/class_${color}_$imageId@$subId.png');
  }

  String get cardBack {
    final color = Atlas.classColor(rarity);
    return Atlas.asset('ClassCard/class_${color}_101@2.png');
  }

  @override
  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    VoidCallback? onTap,
    ImageWithTextOption? option,
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
      onTap: onTap,
      option: option,
      jumpToDetail: jumpToDetail,
      popDetail: popDetail,
      overrideIcon: overrideIcon ?? customIcon,
      name: name,
      showName: showName,
    );
  }

  @override
  Transl<String, String> get lName => Transl.svtNames(ascensionAdd.overWriteServantName.ascension[0] ?? name);

  Transl<String, String> get lAscName {
    int asc = db.userData.svtAscensionIcon == -1 && isUserSvt ? status.cur.ascension : db.userData.svtAscensionIcon;
    String _name = ascensionAdd.overWriteServantName.ascension[asc] ?? name;
    return Transl.svtNames(_name);
  }

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

  ServantExtra get extra {
    if (isNormalSvt && collectionNo > 0) {
      return db.gameData.wiki.servants[originalCollectionNo] ??= ServantExtra(collectionNo: originalCollectionNo);
    }
    return ServantExtra(collectionNo: originalCollectionNo);
  }

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
            if (lvMax + costs[endLv]!.addLvMax > 100) ItemAmount(amount: 30, item: coin!.item)
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
    return extraPassive.where((skill) => skill.functions.any((func) => func.svals.getOrNull(0)?.EventId == eventId));
  }

  NiceSkill? getDefaultSkill(List<NiceSkill> skills, Region region) {
    skills = skills.where((e) => e.num > 0).toList();
    final priorities = db.gameData.mappingData.skillPriority[id]?.ofRegion(region);
    if (originalCollectionNo == 1) {
      skills = skills.where((e) => priorities?[e.id] != null).toList();
    }
    if (skills.isEmpty) return null;
    if (region == Region.jp) {
      return Maths.findMax<NiceSkill, int>(skills, (e) => e.priority);
    } else {
      return Maths.findMax<NiceSkill, int>(skills, (e) => priorities?[e.id] ?? -1);
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

  factory BasicCraftEssence.fromJson(Map<String, dynamic> json) => _$BasicCraftEssenceFromJson(json);

  @override
  String get icon => face;

  @override
  Transl<String, String> get lName => Transl.ceNames(name);

  @override
  String get route => Routes.craftEssenceI(id);
}

@JsonSerializable()
class CraftEssence with GameCardMixin {
  @override
  int id;
  double? sortId; // for CN CEs
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
  List<int> expFeed;
  int? bondEquipOwner;
  int? valentineEquipOwner;
  List<ValentineScript> valentineScript;
  AscensionAdd ascensionAdd;
  List<NiceSkill> skills;
  NiceLore profile;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late SvtExpData curveData =
      SvtExpData.from(type: growthCurve, atkBase: atkBase, atkMax: atkMax, hpBase: hpBase, hpMax: hpMax);
  List<int> get atkGrowth => curveData.atk;
  List<int> get hpGrowth => curveData.hp;
  List<int> get expGrowth => curveData.exp;

  CraftEssence({
    required this.id,
    this.sortId,
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

  factory CraftEssence.fromJson(Map<String, dynamic> json) => _$CraftEssenceFromJson(json);

  @override
  String? get icon => extraAssets.faces.equip?[id];

  @override
  String? get borderedIcon => collectionNo > 0 && !db.gameData.isJustAddedCard(id) ? super.borderedIcon : icon;

  String? get charaGraph => extraAssets.charaGraph.equip?[id];

  @override
  Transl<String, String> get lName => Transl.ceNames(name);

  CraftEssenceExtra get extra =>
      db.gameData.wiki.craftEssences[collectionNo] ??= CraftEssenceExtra(collectionNo: collectionNo);

  CEObtain get obtain {
    switch (flag) {
      case SvtFlag.svtEquipFriendShip:
        return CEObtain.bond;
      case SvtFlag.svtEquipChocolate:
        return CEObtain.valentine;
      case SvtFlag.matDropRateUpCe:
        return CEObtain.drop;
      case SvtFlag.svtEquipExp:
      case SvtFlag.ignoreCombineLimitSpecial:
      case SvtFlag.normal:
      case SvtFlag.goetia:
      case SvtFlag.onlyUseForNpc:
        break;
    }
    return extra.obtain;
  }

  CraftATKType get atkType {
    return atkMax > 0
        ? hpMax > 0
            ? CraftATKType.mix
            : CraftATKType.atk
        : hpMax > 0
            ? CraftATKType.hp
            : CraftATKType.none;
  }

  String get cardBack {
    final color = Atlas.classColor(rarity);
    return Atlas.asset('ClassCard/class_${color}_103.png');
  }

  @override
  String get route => Routes.craftEssenceI(id);

  CraftStatus get status => db.curUser.ceStatusOf(collectionNo);
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

  factory ExtraAssetsUrl.fromJson(Map<String, dynamic> json) => _$ExtraAssetsUrlFromJson(json);
}

@JsonSerializable()
class ExtraCCAssets {
  ExtraAssetsUrl charaGraph;
  ExtraAssetsUrl faces;

  ExtraCCAssets({
    required this.charaGraph,
    required this.faces,
  });

  factory ExtraCCAssets.fromJson(Map<String, dynamic> json) => _$ExtraCCAssetsFromJson(json);
}

@JsonSerializable()
class ExtraAssets extends ExtraCCAssets {
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
    super.charaGraph = const ExtraAssetsUrl(),
    super.faces = const ExtraAssetsUrl(),
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

  factory ExtraAssets.fromJson(Map<String, dynamic> json) => _$ExtraAssetsFromJson(json);
}

@JsonSerializable()
class CardDetail {
  List<int> hitsDistribution;
  List<NiceTrait> attackIndividuality;
  CommandCardAttackType attackType;
  int? damageRate;
  int? attackNpRate;
  int? defenseNpRate;
  int? dropStarRate;

  CardDetail({
    this.hitsDistribution = const [],
    required this.attackIndividuality,
    this.attackType = CommandCardAttackType.one,
    this.damageRate,
    this.attackNpRate,
    this.defenseNpRate,
    this.dropStarRate,
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) => _$CardDetailFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true)
class AscensionAddEntry<T> {
  final Map<int, T> ascension;
  final Map<int, T> costume;

  Map<int, T> get all => {...ascension, ...costume};

  @protected
  const AscensionAddEntry({
    this.ascension = const {},
    this.costume = const {},
  });

  factory AscensionAddEntry.fromJson(Map<String, dynamic> json) => _$AscensionAddEntryFromJson(json, _fromJsonT<T>);

  static T _fromJsonT<T>(Object? obj) {
    if (obj == null) {
      return null as T;
    } else if (obj is int || obj is double || obj is String) {
      return obj as T;
    } else if (T == List<NiceTrait>) {
      return (obj as List<dynamic>).map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList() as T;
    } else if (T == List<CommonRelease>) {
      return (obj as List<dynamic>).map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          as T;
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
  AscensionAddEntry<List<CommonRelease>> charaGraphChangeCommonRelease;
  AscensionAddEntry<List<CommonRelease>> faceChangeCommonRelease;

  AscensionAdd({
    this.individuality = const AscensionAddEntry(),
    this.voicePrefix = const AscensionAddEntry(),
    this.overWriteServantName = const AscensionAddEntry(),
    this.overWriteServantBattleName = const AscensionAddEntry(),
    this.overWriteTDName = const AscensionAddEntry(),
    this.overWriteTDRuby = const AscensionAddEntry(),
    this.overWriteTDFileName = const AscensionAddEntry(),
    this.overWriteTDRank = const AscensionAddEntry(),
    this.overWriteTDTypeText = const AscensionAddEntry(),
    this.lvMax = const AscensionAddEntry(),
    this.charaGraphChange = const AscensionAddEntry(),
    this.faceChange = const AscensionAddEntry(),
    this.charaGraphChangeCommonRelease = const AscensionAddEntry(),
    this.faceChangeCommonRelease = const AscensionAddEntry(),
  });

  factory AscensionAdd.fromJson(Map<String, dynamic> json) => _$AscensionAddFromJson(json);
}

@JsonSerializable()
class ServantChange {
  List<int> beforeTreasureDeviceIds;
  List<int> afterTreasureDeviceIds;
  int svtId;
  int priority;
  @CondTypeConverter()
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

  factory ServantChange.fromJson(Map<String, dynamic> json) => _$ServantChangeFromJson(json);
}

@JsonSerializable()
class ServantLimitImage {
  int limitCount;
  int priority;
  int defaultLimitCount;
  @CondTypeConverter()
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

  factory ServantLimitImage.fromJson(Map<String, dynamic> json) => _$ServantLimitImageFromJson(json);
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

  factory ServantAppendPassiveSkill.fromJson(Map<String, dynamic> json) => _$ServantAppendPassiveSkillFromJson(json);
}

@JsonSerializable()
class ServantCoin {
  int summonNum;
  Item item;

  ServantCoin({
    required this.summonNum,
    required this.item,
  });

  factory ServantCoin.fromJson(Map<String, dynamic> json) => _$ServantCoinFromJson(json);
}

@JsonSerializable()
class ServantTrait {
  int idx;
  List<NiceTrait> trait;
  int limitCount;
  @CondTypeConverter()
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

  factory ServantTrait.fromJson(Map<String, dynamic> json) => _$ServantTraitFromJson(json);
}

@JsonSerializable()
class LoreCommentAdd {
  int idx;
  @CondTypeConverter()
  CondType condType;
  List<int> condValues;
  int condValue2;

  LoreCommentAdd({
    required this.idx,
    required this.condType,
    required this.condValues,
    this.condValue2 = 0,
  });

  factory LoreCommentAdd.fromJson(Map<String, dynamic> json) => _$LoreCommentAddFromJson(json);
}

@JsonSerializable()
class LoreComment {
  int id;
  int priority;
  String condMessage;
  String comment;
  @CondTypeConverter()
  CondType condType;
  List<int>? condValues;
  int condValue2;
  List<LoreCommentAdd> additionalConds;

  LoreComment({
    required this.id,
    this.priority = 0,
    this.condMessage = "",
    this.comment = '',
    this.condType = CondType.none,
    this.condValues,
    this.condValue2 = 0,
    this.additionalConds = const [],
  });

  factory LoreComment.fromJson(Map<String, dynamic> json) => _$LoreCommentFromJson(json);
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

  factory LoreStatus.fromJson(Map<String, dynamic> json) => _$LoreStatusFromJson(json);
}

@JsonSerializable()
class NiceCostume with RouteInfo {
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

  factory NiceCostume.fromJson(Map<String, dynamic> json) => _$NiceCostumeFromJson(json);

  Transl<String, String> get lName => Transl.costumeNames(name);
  Transl<int, String> get lDetail => Transl.costumeDetail(costumeCollectionNo);

  String get face => 'https://static.atlasacademy.io/JP/Faces/f_${battleCharaId}0.png';

  String get icon => face;

  String get borderedIcon => icon.replaceAll('.png', '_bordered.png');

  String get charaGraph => 'https://static.atlasacademy.io/JP/CharaGraph/$battleCharaId/$battleCharaId.png';

  Servant? get owner => db.gameData.others.costumeSvtMap[costumeCollectionNo];

  @override
  String get route => Routes.costumeI(costumeCollectionNo);
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

  factory VoiceCond.fromJson(Map<String, dynamic> json) => _$VoiceCondFromJson(json);
}

@JsonSerializable()
class VoicePlayCond {
  int condGroup;
  @CondTypeConverter()
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

  factory VoicePlayCond.fromJson(Map<String, dynamic> json) => _$VoicePlayCondFromJson(json);
}

@JsonSerializable()
class VoiceLine {
  String? name;
  @CondTypeConverter()
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

  factory VoiceLine.fromJson(Map<String, dynamic> json) => _$VoiceLineFromJson(json);
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

  factory VoiceGroup.fromJson(Map<String, dynamic> json) => _$VoiceGroupFromJson(json);
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

  factory NiceLore.fromJson(Map<String, dynamic> json) => _$NiceLoreFromJson(json);
}

@JsonSerializable()
class ServantScript with DataScriptBase {
  @JsonKey(name: 'SkillRankUp')
  Map<int, List<int>>? skillRankUp;
  bool? svtBuffTurnExtend;

  ServantScript({
    this.skillRankUp,
    this.svtBuffTurnExtend,
  });

  factory ServantScript.fromJson(Map<String, dynamic> json) => _$ServantScriptFromJson(json)..setSource(json);
}

@JsonSerializable()
class SvtScript {
  SvtScriptExtendData? extendData;
  int id;
  int form;
  int faceX;
  int faceY;
  int bgImageId;
  double scale;
  int offsetX;
  int offsetY;
  int offsetXMyroom;
  int offsetYMyroom;

  SvtScript({
    this.extendData,
    required this.id,
    this.form = 0,
    this.faceX = 0,
    this.faceY = 0,
    this.bgImageId = 0,
    this.scale = 1.0,
    this.offsetX = 0,
    this.offsetY = 0,
    this.offsetXMyroom = 0,
    this.offsetYMyroom = 0,
  });

  bool get isHeight1024 => (extendData?.faceSize ?? 256) != 256;
  bool get isHeight768 => (extendData?.faceSize ?? 256) == 256;

  factory SvtScript.fromJson(Map<String, dynamic> json) => _$SvtScriptFromJson(json);
}

@JsonSerializable()
class SvtScriptExtendData {
  int? faceSize; // default 256
  int? myroomForm;
  int? combineResultMultipleForm;
  // conds?: { condType: number; value: number }[];
  // "photoSvtPosition": [-260, 284],
  // "photoSvtScale": 0.85
  List<int>? photoSvtPosition;
  double? photoSvtScale;
  // offsets<x,y>
  // List<int>? TerminalOffset
  // List<int>? BattleBondOffset
  SvtScriptExtendData({
    this.faceSize,
    this.myroomForm,
    this.combineResultMultipleForm,
    this.photoSvtPosition,
    this.photoSvtScale,
  });
  factory SvtScriptExtendData.fromJson(Map<String, dynamic> json) => _$SvtScriptExtendDataFromJson(json);
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
  svtEquipExp, // may be normal for some EXP CEs
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
  eventRecipe,
  eventFortification,
  sum,
}

enum Gender {
  male,
  female,
  unknown,
}

enum CommandCardAttackType {
  one,
  all,
}
