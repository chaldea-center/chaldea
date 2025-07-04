import 'package:chaldea/utils/atlas.dart';
import 'package:chaldea/utils/extension.dart';
import '../../app/app.dart';
import '../../app/tools/gamedata_loader.dart';
import '../../generated/l10n.dart';
import '../../packages/language.dart';
import '../db.dart';
import '_helper.dart';
import 'const_data.dart';
import 'event.dart';
import 'mappings.dart';

part '../../generated/models/gamedata/common.g.dart';
part 'common_helper.dart';

@JsonEnum(alwaysCreate: true)
enum Region {
  jp(Language.jp),
  cn(Language.chs),
  tw(Language.cht),
  na(Language.en),
  kr(Language.ko);

  final Language language;
  const Region(this.language);

  bool get isJP => this == jp;

  int get eventDelayMonth {
    switch (this) {
      case Region.jp:
        return 12;
      case Region.cn:
        return 12;
      case Region.tw:
        return 22;
      case Region.na:
        return 24;
      // 24 months before JP 2021/07 event
      case Region.kr:
        return 22;
    }
  }

  int get timezone {
    switch (this) {
      case Region.jp:
        return 9;
      case Region.cn:
      case Region.tw:
        return 8;
      case Region.na:
        return -8;
      case Region.kr:
        return 9;
    }
  }

  @override
  String toString() {
    return name.toUpperCase();
  }

  static Region? fromUrl(String url) {
    final r = Uri.tryParse(url)?.pathSegments.getOrNull(0);
    if (r == null) return null;
    return _$RegionEnumMap.entries.firstWhereOrNull((e) => e.value.toLowerCase() == r.toLowerCase())?.key;
  }

  static const validQuestRegions = [Region.jp, Region.na];
}

@JsonSerializable()
class NiceTrait with RouteInfo {
  static final Map<int, NiceTrait> _instances = {};

  final int id;
  final bool negative;

  Trait get name => kTraitIdMapping[id] ?? Trait.unknown;

  const NiceTrait._({required this.id, this.negative = false});

  factory NiceTrait({required int id, bool negative = false}) {
    negative = negative || id < 0;
    id = id.abs();
    return _instances.putIfAbsent(negative ? -id : id, () => NiceTrait._(id: id, negative: negative));
  }

  factory NiceTrait.signed(int sid) => _instances.putIfAbsent(sid, () => NiceTrait._(id: sid.abs(), negative: sid < 0));

  static List<NiceTrait> list(List<int> ids) {
    return ids.map((e) => NiceTrait(id: e)).toList();
  }

  int get signedId => negative ? -id : id;

  @override
  String toString() {
    return '$runtimeType($signedId)';
  }

  String shownName({bool addSvtId = true, bool field = false}) {
    final s = Transl.trait(id, addSvtId: addSvtId, field: field).l;
    if (negative) {
      return '${Transl.special.not()} $s';
    }
    return s;
  }

  static bool hasAllTraits(List<NiceTrait> traits, List<int> targets) {
    assert(targets.isNotEmpty);
    if (targets.isEmpty) return true;
    return targets.every((traitId) => traits.any((trait) => trait.id == traitId));
  }

  static bool hasAnyTrait(List<NiceTrait> traits, List<int> targets) {
    assert(targets.isNotEmpty);
    if (targets.isEmpty) return true;
    return targets.any((traitId) => traits.any((trait) => trait.id == traitId));
  }

  @override
  String get route => Routes.traitI(id);

  @override
  int get hashCode => Object.hashAll(['NiceTrait', id, negative]);

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other.hashCode == hashCode;
  }

  factory NiceTrait.fromJson(Map<String, dynamic> json) => _$NiceTraitFromJson(json);

  Map<String, dynamic> toJson() => _$NiceTraitToJson(this);

  bool get isEventField => id >= 94000000 && id <= 96000000;

  static Set<Trait> upToleranceSubstateBuffTraits = {
    Trait.buffPositiveEffect,
    Trait.buffIncreaseDamage,
    Trait.buffIncreaseDefence,
    Trait.buffAtkUp,
    Trait.buffDefUp,
    Trait.buffCritDamageUp,
    Trait.buffEvade,
    Trait.buffEvadeAndInvincible,
    Trait.buffGuts,
    Trait.buffNpDamageUp,
    Trait.buffCritRateUp,
    Trait.buffSureHit,
  };
}

extension IterableTrait on Iterable<NiceTrait> {
  List<int> toIntList() => map((e) => e.signedId).toList();
}

mixin DataScriptBase {
  Map<String, dynamic> _source = {};
  Map<String, dynamic> get source => _source;
  void setSource(Map<String, dynamic>? json) => json == null ? null : _source = Map.from(json);
  List<T>? toList<T>(String key) => (_source[key] as List<dynamic>?)?.cast();
  int? toInt(String key) => (_source[key] as int?);
  T? getScript<T>(String key) => _source[key] as T?;
}

@JsonSerializable()
class BgmRelease {
  int id;
  @CondTypeConverter()
  CondType type;
  int condGroup;
  List<int> targetIds;
  List<int> vals; // [0], for QuestClear, change to 1 for descriptor
  int priority;
  String closedMessage;

  BgmRelease({
    required this.id,
    required this.type,
    this.condGroup = 0,
    this.targetIds = const [],
    this.vals = const [],
    this.priority = 0,
    this.closedMessage = "",
  });

  factory BgmRelease.fromJson(Map<String, dynamic> json) => _$BgmReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$BgmReleaseToJson(this);
}

@JsonSerializable()
class BgmEntity extends Bgm {
  int priority;
  String detail;
  NiceShop? shop;
  String? logo;
  List<BgmRelease> releaseConditions;

  BgmEntity({
    required super.id,
    super.name,
    super.fileName,
    super.notReleased,
    super.audioAsset,
    this.priority = 0,
    this.detail = "",
    this.shop,
    this.logo,
    this.releaseConditions = const [],
  });

  factory BgmEntity.fromJson(Map<String, dynamic> json) =>
      GameDataLoader.instance.tmp.getBgm(json["id"], () => _$BgmEntityFromJson(json));

  @override
  Map<String, dynamic> toJson() => _$BgmEntityToJson(this);
}

@JsonSerializable()
class Bgm with RouteInfo {
  int id;
  String name;
  String fileName;
  bool notReleased;
  String? audioAsset;

  Bgm({required this.id, this.name = '', this.fileName = "", this.notReleased = true, this.audioAsset});

  Transl<String, String> get lName => Transl.bgmNames(name);

  String get tooltip => name.isEmpty ? fileName : lName.l;

  @override
  String get route => Routes.bgmI(id);

  factory Bgm.fromJson(Map<String, dynamic> json) {
    final tmp = GameDataLoader.instance.tmp;
    if (tmp.enabled) {
      return GameDataLoader.instance.tmp.getBgm(json["id"], () => _$BgmEntityFromJson(json));
    }
    return _$BgmFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BgmToJson(this);
}

@JsonSerializable()
class StageLink {
  int questId;
  int phase;
  int stage;

  StageLink({this.questId = 0, this.phase = 1, this.stage = 1});
  factory StageLink.fromJson(Map<String, dynamic> json) => _$StageLinkFromJson(json);

  Map<String, dynamic> toJson() => _$StageLinkToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum CardType {
  none(0),
  arts(1),
  buster(2),
  quick(3),
  extra(4),
  blank(5),
  weak(10),
  strength(11),
  weakalt1(21),
  weakalt2(22),
  busteralt1(60),
  extra2(104);

  final int value;
  const CardType(this.value);

  static CardType? fromId(int? cardId) {
    return CardType.values.firstWhereOrNull((e) => e.value == cardId);
  }

  bool isQAB() => isQuick() || isArts() || isBuster();

  bool isQuick() => this == quick;
  bool isArts() => this == arts;
  bool isBuster() => this == buster || this == busteralt1;
  bool isExtra() => this == extra || this == extra2;
  bool isWeak() => this == weak || this == weakalt1 || this == weakalt2;
  bool isStrength() => this == strength;

  bool matches(final CardType other) {
    if (other.isArts() && isArts()) return true;
    if (other.isBuster() && isBuster()) return true;
    if (other.isQuick() && isQuick()) return true;
    if (other.isExtra() && isExtra()) return true;
    if (other.isWeak() && isWeak()) return true;
    if (other.isStrength() && isStrength()) return true;

    return this == other;
  }

  Trait? get baseTrait {
    if (isArts()) return Trait.cardArts;
    if (isBuster()) return Trait.cardBuster;
    if (isQuick()) return Trait.cardQuick;
    if (isExtra()) return Trait.cardExtra;
    if (isWeak()) return Trait.cardWeak;
    if (isStrength()) return Trait.cardStrong;
    return null;
  }
}

final kCardTypeMapping = {for (final card in CardType.values) card.value: card};

class CardTypeConverter implements JsonConverter<CardType, dynamic> {
  const CardTypeConverter();

  @override
  CardType fromJson(dynamic value) {
    if (value == null) return CardType.none;
    if (value is String) {
      return deprecatedTypes[value] ?? decodeEnum(_$CardTypeEnumMap, value, CardType.none);
    }
    if (value is int) {
      return kCardTypeMapping[value] ?? CardType.none;
    }
    assert(false, "CardType: unsupported type '${value.runtimeType}($value)'");
    return CardType.none;
  }

  @override
  String toJson(CardType card) {
    return _$CardTypeEnumMap[card] ?? card.name;
  }

  static final Map<String, CardType> deprecatedTypes = {"addattack2": CardType.extra2};
}

@JsonEnum(alwaysCreate: true)
enum SvtClass {
  none(0),
  saber(1, '剣'),
  archer(2, '弓'),
  lancer(3, '槍'),
  rider(4, '騎'),
  caster(5, '術'),
  assassin(6, '殺'),
  berserker(7, '狂'),
  shielder(8, '盾'),
  ruler(9, '裁'),
  alterEgo(10, 'AE'),
  avenger(11, '讐'),
  demonGodPillar(12),

  loreGrandSaber(13, '剣', 1),
  loreGrandArcher(14, '弓', 2),
  loreGrandLancer(15, '槍', 3),
  loreGrandRider(16, '騎', 4),
  loreGrandCaster(17, '術', 5),
  loreGrandAssassin(18, '殺', 6),
  loreGrandBerserker(19, '狂', 7),

  beastII(20, '兽Ⅱ'),
  ushiChaosTide(21),
  beastI(22, '獸I'),
  moonCancer(23, '月'),
  beastIIIR(24, '獸ⅢR'),
  foreigner(25, '降'),
  beastIIIL(26, '獸ⅢL'),
  beastUnknown(27, '獸?'), // LB 5.2 beast
  pretender(28, '偽'),
  beastIV(29, '獸Ⅳ'),
  beastILost(30, '獸I?'),
  uOlgaMarieAlienGod(31, '獸?'),
  uOlgaMarie(32, '?'),
  beastDoraco(33, '獸'),
  beastVI(34, '獸Ⅵ'),
  beastVIBoss(35, '獸Ⅵ'),
  uOlgaMarieFlare(36),
  uOlgaMarieAqua(37),
  beastEresh(38, '獸'),
  uOlgaMarieGround(39),
  unknown(97),
  // 98
  // 99
  // 100
  agarthaPenth(107),
  cccFinaleEmiyaAlter(124),
  salemAbby(125),
  OTHER(1000, 'OTHER'), // ignore: constant_identifier_names
  ALL(1001, 'ALL'), // ignore: constant_identifier_names
  EXTRA(1002, 'EXTRA'), // ignore: constant_identifier_names
  MIX(1003, 'MIX'), // ignore: constant_identifier_names
  EXTRA1(1004, 'EXTRA1'), // ignore: constant_identifier_names
  EXTRA2(1005, 'EXTRA2'), // ignore: constant_identifier_names
  uOlgaMarieFlareCollection(9001),
  uOlgaMarieAquaCollection(9002),
  uOlgaMarieGroundCollection(9003),
  grandSaber(10001, '剣', 1),
  grandArcher(10002, '弓', 2),
  grandLancer(10003, '槍', 3),
  grandRider(10004, '騎', 4),
  grandCaster(10005, '術', 5),
  grandAssassin(10006, '殺', 6),
  grandBerserker(10007, '狂', 7),

  beastAny(33, '獸');

  final int value;
  final String shortName;
  final int? baseClassId;
  const SvtClass(this.value, [this.shortName = '?', this.baseClassId]);
}

class SvtClassConverter implements JsonConverter<SvtClass, String> {
  const SvtClassConverter();

  @override
  SvtClass fromJson(String value) {
    return deprecatedTypes[value] ?? decodeEnum(_$SvtClassEnumMap, value, SvtClass.none);
  }

  @override
  String toJson(SvtClass cls) {
    return _$SvtClassEnumMap[cls] ?? cls.name;
  }

  static int? fromString(String value, Map<int, SvtClassMapping> mapping) {
    for (final cls in SvtClass.values) {
      if (cls.name == value) return cls.value;
    }
    int? pureInt = int.tryParse(value);
    if (pureInt != null && pureInt > 0) return pureInt;
    return mapping.entries.firstWhereOrNull((entry) => entry.value.name == value)?.key;
  }

  static final Map<String, SvtClass> deprecatedTypes = {"beast": SvtClass.beastDoraco};
}

const _kSvtClassRarityMap = {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 3};

extension SvtClassX on SvtClass {
  static const beast = SvtClass.beastAny;

  SvtClassInfo? get info => db.gameData.constData.classInfo[value];
  int get iconId => info?.iconImageId ?? 12;

  String icon(int svtRarity) => clsIcon(value, svtRarity, iconId);

  static String clsIcon(int clsId, int svtRarity, [int? iconId]) {
    if (clsId >= SvtClass.grandSaber.value && clsId <= SvtClass.grandBerserker.value) {
      if (!db.gameData.grandGraphDetails.values.any((e) => e.grandClassId == clsId)) {
        return 'https://static.atlasacademy.io/file/aa-fgo-extract-jp/GrandServantList/DownloadGrandServantListAtlas1/'
            'icon_class_off${(clsId - 10000).toString().padLeft(3, "0")}.png';
      }
    }
    iconId ??= ConstData.classInfo[clsId]?.iconImageId;
    int rarity = _kSvtClassRarityMap[svtRarity] ?? svtRarity;
    rarity = const <int, int>{1003: 2, 17: 3}[iconId] ?? rarity;

    // unused lore grand class
    if (const [13, 14, 15, 16, 18, 19].contains(clsId)) {
      iconId = 12;
      rarity = 2;
    }
    return Atlas.asset('ClassIcons/class${rarity}_${iconId ?? 12}.png');
  }

  static void routeTo(int id) {
    router.push(url: Routes.svtClassI(id));
  }

  String get lName => Transl.svtClassId(value).l;

  static List<SvtClass> regularAll = [...regular, ...extra];

  static List<SvtClass> regularAllWithBeasts = <SvtClass>{...regularAll, ...beasts}.toList();

  static const regular = <SvtClass>[
    SvtClass.saber,
    SvtClass.archer,
    SvtClass.lancer,
    SvtClass.rider,
    SvtClass.caster,
    SvtClass.assassin,
    SvtClass.berserker,
  ];

  static const extraI = <SvtClass>[SvtClass.ruler, SvtClass.avenger, SvtClass.moonCancer, SvtClass.shielder];

  static const extraII = <SvtClass>[SvtClass.alterEgo, SvtClass.foreigner, SvtClass.pretender, SvtClass.beastAny];
  static const extra = <SvtClass>[...extraI, ...extraII];
  static const beasts = <SvtClass>[
    SvtClass.beastDoraco,
    SvtClass.beastEresh,
    SvtClass.beastI,
    SvtClass.beastII,
    SvtClass.beastIIIR,
    SvtClass.beastIIIL,
    SvtClass.beastIV,
    SvtClass.beastUnknown,
    SvtClass.uOlgaMarieAlienGod,
    // SvtClass.uOlgaMarie,
    SvtClass.uOlgaMarieFlare,
    SvtClass.uOlgaMarieAqua,
    SvtClass.uOlgaMarieGround,
    SvtClass.beastILost,
    SvtClass.beastVI,
    SvtClass.beastVIBoss,
    SvtClass.uOlgaMarieFlareCollection,
    SvtClass.uOlgaMarieAquaCollection,
    SvtClass.uOlgaMarieGroundCollection,
  ];
  static const grandClasses = <SvtClass>[
    SvtClass.grandSaber,
    SvtClass.grandArcher,
    SvtClass.grandLancer,
    SvtClass.grandRider,
    SvtClass.grandCaster,
    SvtClass.grandAssassin,
    SvtClass.grandBerserker,
  ];

  static bool match(SvtClass value, SvtClass option) {
    if (option == value) return true;
    if ((value.baseClassId ?? value.value) == (option.baseClassId ?? option.value)) return true;
    if (option == SvtClassX.beast) {
      return beasts.contains(value);
    }
    if (option == SvtClass.EXTRA1) {
      return extraI.contains(value);
    }
    if (option == SvtClass.EXTRA2) {
      return extraII.contains(value) || beasts.contains(value);
    }
    if (option == SvtClass.EXTRA) {
      return extra.contains(value) || beasts.contains(value);
    }
    if (option == SvtClass.ALL) return value != SvtClass.none;
    if (option == SvtClass.unknown) {
      return !SvtClassX.regularAllWithBeasts.contains(value);
    }
    return false;
  }

  static List<SvtClass> resolveClasses(SvtClass svtClass, {required bool expandBeast}) {
    List<SvtClass> svtClasses = switch (svtClass) {
      SvtClass.EXTRA1 => SvtClassX.extraI,
      SvtClass.EXTRA2 => SvtClassX.extraII,
      SvtClass.ALL => [...SvtClassX.regular, ...SvtClassX.extra],
      SvtClass.beastAny => [svtClass],
      SvtClass.none => [],
      _ => [svtClass],
    };
    if (expandBeast) {
      return <SvtClass>{
        for (final x in svtClasses)
          if (x == SvtClass.beastAny) ...beasts else x,
      }.toList();
    } else {
      return svtClasses.toSet().toList();
    }
  }
}

/// non-JP may not contains the last class
Set<int> get kSvtClassIdsPlayableAll => {
  //
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 23, 25, 28, 33, 38,
  ...ConstData.constantStr.playableBeastClassIds,
};
const kSvtClassIdsPlayableAlways = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 23, 25, 28];
final kSvtClassIds = {
  for (final v in SvtClass.values)
    if (v != SvtClass.beastAny) v.value: v,
};

enum SvtClassSupportGroupType {
  all(0),
  saber(1),
  archer(2),
  lancer(3),
  rider(4),
  caster(5),
  assassin(6),
  berserker(7),
  extra(8),
  mix(9),
  recommend(10),
  notSupport(999);

  const SvtClassSupportGroupType(this.value);
  final int value;
}

/// Add new entry to common_helper [kTraitIdMapping]
enum Trait {
  unknown(-1),
  genderMale(1),
  genderFemale(2),
  genderUnknown(3),
  classSaber(100),
  classLancer(101),
  classArcher(102),
  classRider(103),
  classCaster(104),
  classAssassin(105),
  classBerserker(106),
  classShielder(107),
  classRuler(108),
  classAlterEgo(109),
  classAvenger(110),
  classDemonGodPillar(111),
  classGrandCaster(112),
  classBeastI(113),
  classBeastII(114),
  classMoonCancer(115),
  classBeastIIIR(116),
  classForeigner(117),
  classBeastIIIL(118),
  classBeastUnknown(119),
  classPretender(120),
  classBeastIV(121),
  classBeastILost(122),
  classUOlgaMarie(123),
  classBeast(124),
  classBeastVI(125),
  classBeastVIBoss(126),
  classUOlgaMarieFlare(127),
  classUOlgaMarieAqua(128),
  classBeastEresh(129),
  classUOlgaMarieGround(130),
  attributeSky(200),
  attributeEarth(201),
  attributeHuman(202),
  attributeStar(203),
  attributeBeast(204),
  alignmentLawful(300),
  alignmentChaotic(301),
  alignmentNeutral(302),
  alignmentGood(303),
  alignmentEvil(304),
  alignmentBalanced(305),
  alignmentMadness(306),
  alignmentSummer(308),
  alignmentBeast(309),
  servant(1000),
  human(1001),
  undead(1002),
  artificialDemon(1003),
  demonBeast(1004),
  divineDemon(1005), // 神魔, not 神性&魔性
  soldier(1100),
  amazoness(1101),
  skeleton(1102),
  zombie(1103),
  ghost(1104),
  automata(1105),
  golem(1106),
  spellBook(1107),
  homunculus(1108),
  lamia(1110),
  centaur(1111),
  werebeast(1112),
  chimera(1113),
  wyvern(1117),
  dragonType(1118),
  demon(1119),
  handOrDoor(1120),
  demonGodPillar(1121),
  shadow(1122),
  enemyGardenOfSinnersLivingCorpse(1128),
  enemyGardenOfSinnersApartmentGhostAndSkeleton(1129),
  enemyGardenOfSinnersBaseModel(1130),
  enemyGardenOfSinnersVengefulSpiritOfSevenPeople(1131),
  oni(1132),
  hand(1133),
  door(1134),
  enemySaberEliWerebeastAndHomunculusAndKnight(1135),
  enemySaberEliSkeletonAndGhostAndLamia(1136),
  enemySaberEliBugAndGolem(1137),
  enemySeraphEater(1138),
  enemySeraphShapeshifter(1139),
  enemySeraphTypeI(1140),
  enemySeraphTypeSakura(1141),
  enemyHimejiCastleKnightAndGazerAndMassProduction(1155),
  enemyHimejiCastleDronesAndHomunculusAndAutomata(1156),
  enemyHimejiCastleSkeletonAndScarecrow(1157),
  enemyGuda3MiniNobu(1171),
  threatToHumanity(1172),
  fae(1177),
  divine(2000),
  humanoid(2001),
  dragon(2002),
  dragonSlayer(2003),
  roman(2004),
  wildbeast(2005),
  moon(2006),
  saberface(2007),
  weakToEnumaElish(2008),
  riding(2009),
  arthur(2010),
  skyOrEarthServant(2011),
  brynhildsBeloved(2012),
  undeadOrDemon(2018),
  demonic(2019),
  enemyDavinciTrueEnemy(2023),
  enemyDavinciFalseEnemy(2024),
  skyOrEarthExceptPseudoAndDemiServant(2037),
  fieldSunlight(2038),
  fieldShore(2039),
  divineOrDemonOrUndead(2040),
  fieldForest(2073),
  blessedByKur(2074),
  saberClassServant(2075),
  superGiant(2076),
  king(2113),
  greekMythologyMales(2114),
  fieldBurning(2121),
  buffCharmFemale(2191),
  enemyGudaMiniNobu(2221),
  illya(2355),
  feminineLookingServant(2356),
  cursedBook(2385),
  kingproteaProliferation(2386),
  kingproteaInfiniteProliferation(2387),
  fieldCity(2392),
  enemyCaseFilesRareEnemy(2403),
  enemyLasVegasBonusEnemy(2469),
  associatedToTheArgo(2466),
  weakPointsRevealed(2467),
  genderCaenisServant(2615),
  hominidaeServant(2631),
  demonicBeastServant(2632),
  livingHuman(2654),
  enemySummerCampRareEnemy(2663),
  kingproteaProliferationNPDefense(2664),
  giant(2666),
  childServant(2667),
  nobunaga(2721),
  curse(2729),
  fieldImaginarySpace(2730),
  existenceOutsideTheDomain(2731),
  fieldShoreOrImaginarySpace(2732),
  shutenOnField(2733),
  shuten(2734),
  genji(2735),
  enemyLittleBigTenguTsuwamonoEnemy(2749),
  vengeance(2759),
  hasCostume(2780),
  mechanical(2781),
  knightsOfTheRound(2795),
  divineSpirit(2797),
  burningLove(2801),
  buffStrongAgainstDragon(2802),
  buffStrongAgainstWildBeast(2803),
  fairyTaleServant(2810),
  havingAnimalsCharacteristics(2821),
  like(2827),
  exaltation(2828),
  milleniumCastle(2829),
  yuMeiren(2833),
  immuneToPigify(2835),
  protoMerlinNPChargeBlock(2836),
  valkyrie(2837),
  summerModeServant(2838),
  shinsengumiServant(2839),
  ryozanpaku(2840),
  levitating(2847),
  obstacleMaker(2848),
  defender(2849),
  hasGoddessMetamorphosis(2850),
  servantsWithSkyAttribute(2851),
  holdingHolyGrail(2857),
  standardClassServant(2858),
  happyHalloween(2859),
  happyHalloweenFlag(2860),
  manuscriptComplete(2872),
  myFairSoldier(2873),
  elementalsWrath(2880),
  groupServant(2881),
  fsnServant(2883),
  fieldDarkness(2884),
  magicBullet(2885),
  robinCounter(2886),
  robinAllGone(2887),
  protagonistCorrection(2888),
  kuonjiAliceStage3(2903),
  normalAokoBuff(2911),
  kuonjiAliceHasSkill3(2913),
  buffGutsOnInstantDeath(2914),
  magicBulletAtkBuff(2912),
  attackPhysical(3000),
  attackProjectile(3001),
  attackMagical(3002),
  buffPositiveEffect(3004),
  buffNegativeEffect(3005),
  buffIncreaseDamage(3006),
  buffIncreaseDefence(3007),
  buffDecreaseDamage(3008),
  buffDecreaseDefence(3009),
  buffMentalEffect(3010),
  buffPoison(3011),
  buffCharm(3012),
  buffPetrify(3013),
  buffStun(3014),
  buffBurn(3015),
  buffSpecialResistUp(3016),
  buffSpecialResistDown(3017),
  buffEvadeAndInvincible(3018),
  buffSureHit(3019),
  buffNpSeal(3020),
  buffEvade(3021),
  buffInvincible(3022),
  buffTargetFocus(3023),
  buffGuts(3024),
  skillSeal(3025),
  buffCurse(3026),
  buffAtkUp(3027),
  buffPowerModStrUp(3028),
  buffDamagePlus(3029),
  buffNpDamageUp(3030),
  buffCritDamageUp(3031),
  buffCritRateUp(3032),
  buffAtkDown(3033),
  buffPowerModStrDown(3034),
  buffDamageMinus(3035),
  buffNpDamageDown(3036),
  buffCritDamageDown(3037),
  buffCritRateDown(3038),
  buffDeathResistDown(3039),
  buffDefenceUp(3040), // related?
  buffMaxHpUpPercent(3041),
  buffMaxHpDownPercent(3042),
  buffMaxHpUp(3043),
  buffMaxHpDown(3044),
  buffImmobilize(3045),
  buffIncreasePoisonEffectiveness(3046),
  buffPigify(3047),
  buffCurseEffectUp(3048),
  buffTerrorStunChanceAfterTurn(3049),
  buffConfusion(3052),
  buffOffensiveMode(3053),
  buffDefensiveMode(3054),
  buffLockCardsDeck(3055),
  buffDisableColorCard(3056),
  buffChangeField(3057),
  buffDefUp(3058),
  buffInvinciblePierce(3059),
  buffHpRecoveryPerTurn(3060),
  buffNegativeEffectImmunity(3061),
  buffDelayedNegativeEffect(3063), // buffNegativeEffectAtTurnEnd
  buffSpecialInvincible(3064),
  buffSkillRankUp(3065),
  buffSleep(3066),
  chenGongNp(3068),
  buffNullifyBuff(3070),
  cantBeSacrificed(3076),
  buffDamageCut(3085),
  gutsBlock(3086),
  buffBound(3087), // 拘束
  buffMarking(3088),
  buffBuffSuccessRateUp(3090),
  takeruDummyTrait(3091),
  artsBuff(3092),
  busterBuff(3093),
  quickBuff(3094),
  instantDeathFunction(3096),
  forceInstantDeathFunction(3097),
  demeritFunction(3098),
  extraBuff(3100),
  buffSpecialInvinciblePierce(3104),
  cardArts(4001),
  cardBuster(4002),
  cardQuick(4003),
  cardExtra(4004),
  cardWeak(4005),
  cardStrong(4006),
  cardNP(4007),
  faceCard(4008),
  criticalHit(4100),
  aoeNP(4101),
  stNP(4102),
  // 4103, 迎撃宝具-斬り抉る戦神の剣
  quickChain(4104),
  artsChain(4105),
  busterChain(4106),
  mightyChain(4107),
  braveChain(4108),
  chainError(4109),
  canBeInBattle(5000),
  notBasedOnServant(5010),
  isSupport(7000), // constants.INDIVIDUALITY_IS_SUPPORT
  eventSaberWars(94000015),
  eventRashomon(94000037),
  eventOnigashima(94000045),
  eventOnigashimaRaid(94000046),
  eventPrisma(94000047),
  eventPrismaWorldEndMatch(94000048),
  eventNeroFest2(94000049),
  eventGuda2(94000057),
  eventNeroFest3(94000066),
  eventSetsubun(94000071),
  eventApocrypha(94000074),
  eventBattleInNewYork1(94000077),
  eventOniland(94000078),
  eventOoku(94000086),
  eventGuda4(94000089),
  eventLasVegas(94000091),
  eventBattleInNewYork2(94000092),
  eventSaberWarsII(94000095),
  eventSummerCamp(94000107),
  eventGuda5(94000108);

  final int value;
  const Trait(this.value);

  static bool isEventField(int id) {
    final v = id ~/ 1000;
    // return v == 94000 || v == 95000;
    return v == 94000;
  }
}

@JsonEnum(alwaysCreate: true)
enum CondType {
  unknown(-1),
  none(0),
  questClear(1),
  itemGet(2),
  useItemEternity(3),
  useItemTime(4),
  useItemCount(5),
  svtLevel(6),
  svtLimit(7),
  svtGet(8),
  svtFriendship(9),
  svtGroup(10),
  event(11),
  date(12),
  weekday(13),
  purchaseQpShop(14),
  purchaseStoneShop(15),
  warClear(16),
  flag(17),
  svtCountStop(18),
  birthDay(19),
  eventEnd(20),
  svtEventJoin(21),
  missionConditionDetail(22),
  eventMissionClear(23),
  eventMissionAchieve(24),
  questClearNum(25),
  notQuestGroupClear(26),
  raidAlive(27),
  raidDead(28),
  raidDamage(29),
  questChallengeNum(30),
  masterMission(31),
  questGroupClear(32),
  superBossDamage(33),
  superBossDamageAll(34),
  purchaseShop(35),
  questNotClear(36),
  notShopPurchase(37),
  notSvtGet(38),
  notEventShopPurchase(39),
  svtHaving(40),
  notSvtHaving(41),
  questChallengeNumEqual(42),
  questChallengeNumBelow(43),
  questClearNumEqual(44),
  questClearNumBelow(45),
  questClearPhase(46),
  notQuestClearPhase(47),
  eventPointGroupWin(48),
  eventNormaPointClear(49),
  questAvailable(50),
  questGroupAvailableNum(51),
  eventNormaPointNotClear(52),
  notItemGet(53),
  costumeGet(54),
  questResetAvailable(55),
  svtGetBeforeEventEnd(56),
  questClearRaw(57),
  questGroupClearRaw(58),
  eventGroupPointRatioInTerm(59),
  eventGroupRankInTerm(60),
  notEventRaceQuestOrNotAllGroupGoal(61),
  eventGroupTotalWinEachPlayer(62),
  eventScriptPlay(63),
  svtCostumeReleased(64),
  questNotClearAnd(65),
  svtRecoverd(66),
  shopReleased(67),
  eventPoint(68),
  eventRewardDispCount(69),
  equipWithTargetCostume(70),
  raidGroupDead(71),
  notSvtGroup(72),
  notQuestResetAvailable(73),
  notQuestClearRaw(74),
  notQuestGroupClearRaw(75),
  notEventMissionClear(76),
  notEventMissionAchieve(77),
  notCostumeGet(78),
  notSvtCostumeReleased(79),
  notEventRaceQuestOrNotTargetRankGoal(80),
  playerGenderType(81),
  shopGroupLimitNum(82),
  eventGroupPoint(83),
  eventGroupPointBelow(84),
  eventTotalPoint(85),
  eventTotalPointBelow(86),
  eventValue(87),
  eventValueBelow(88),
  eventFlag(89),
  eventStatus(90),
  notEventStatus(91),
  forceFalse(92),
  svtHavingLimitMax(93),
  eventPointBelow(94),
  svtEquipFriendshipHaving(95),
  movieNotDownload(96),
  multipleDate(97),
  svtFriendshipAbove(98),
  svtFriendshipBelow(99),
  movieDownloaded(100),
  routeSelect(101),
  notRouteSelect(102),
  limitCount(103),
  limitCountAbove(104),
  limitCountBelow(105),
  badEndPlay(106),
  commandCodeGet(107),
  notCommandCodeGet(108),
  allUsersBoxGachaCount(109),
  totalTdLevel(110),
  totalTdLevelAbove(111),
  totalTdLevelBelow(112),
  commonRelease(113),
  battleResultWin(114),
  battleResultLose(115),
  eventValueEqual(116),
  boardGameTokenHaving(117),
  boardGameTokenGroupHaving(118),
  eventFlagOn(119),
  eventFlagOff(120),
  questStatusFlagOn(121),
  questStatusFlagOff(122),
  eventValueNotEqual(123),
  limitCountMaxEqual(124),
  limitCountMaxAbove(125),
  limitCountMaxBelow(126),
  boardGameTokenGetNum(127),
  battleLineWinAbove(128),
  battleLineLoseAbove(129),
  battleLineContinueWin(130),
  battleLineContinueLose(131),
  battleLineContinueWinBelow(132),
  battleLineContinueLoseBelow(133),
  battleGroupWinAvove(134),
  battleGroupLoseAvove(135),
  svtLimitClassNum(136),
  overTimeLimitRaidAlive(137),
  onTimeLimitRaidDead(138),
  onTimeLimitRaidDeadNum(139),
  raidBattleProgressAbove(140),
  svtEquipRarityLevelNum(141),
  latestMainScenarioWarClear(142),
  eventMapValueContains(143),
  resetBirthDay(144),
  shopFlagOn(145),
  shopFlagOff(146),
  purchaseValidShopGroup(147),
  svtLevelClassNum(148),
  svtLevelIdNum(149),
  limitCountImageEqual(150),
  limitCountImageAbove(151),
  limitCountImageBelow(152),
  eventTypeStartTimeToEndDate(153),
  existBoxGachaScriptReplaceGiftId(154),
  notExistBoxGachaScriptReplaceGiftId(155),
  limitedPeriodVoiceChangeTypeOn(156),
  startRandomMission(157),
  randomMissionClearNum(158),
  progressValueEqual(159),
  progressValueAbove(160),
  progressValueBelow(161),
  randomMissionTotalClearNum(162),
  weekdays(166),
  eventFortificationRewardNum(167),
  questClearBeforeEventStart(168),
  notQuestClearBeforeEventStart(169),
  eventTutorialFlagOn(170),
  eventTutorialFlagOff(171),
  eventSuperBossValueEqual(172),
  notEventSuperBossValueEqual(173),
  allSvtTargetSkillLvNum(174),
  superBossDamageAbove(175),
  superBossDamageBelow(176),
  eventMissionGroupAchieve(177),
  svtFriendshipClassNumAbove(178),
  notWarClear(179),
  svtSkillLvClassNumAbove(180),
  svtClassLvUpCount(181),
  svtClassSkillLvUpCount(182),
  svtClassLimitUpCount(183),
  svtClassFriendshipCount(184),
  completeHeelPortrait(185),
  notCompleteHeelPortrait(186),
  classBoardSquareReleased(187),
  svtLevelExchangeSvt(188),
  svtLimitExchangeSvt(189),
  skillLvExchangeSvt(190),
  svtFriendshipExchangeSvt(191),
  exchangeSvt(192),
  raidDamageAbove(193),
  raidDamageBelow(194),
  raidGroupDamageAbove(195),
  raidGroupDamageBelow(196),
  raidDamageRateAbove(197),
  raidDamageRateBelow(198),
  raidDamageRateNotAbove(199),
  raidDamageRateNotBelow(200),
  raidGroupDamageRateAbove(201),
  raidGroupDamageRateBelow(202),
  raidGroupDamageRateNotAbove(203),
  raidGroupDamageRateNotBelow(204),
  notQuestGroupClearNum(205),
  raidGroupOpenAbove(206),
  raidGroupOpenBelow(207),
  treasureDeviceAccelerate(208),
  playQuestPhase(209),
  notPlayQuestPhase(210),
  eventStartToEnd(211),
  commonValueAbove(212),
  commonValueBelow(213),
  commonValueEqual(214),
  elapsedTimeAfterQuestClear(215),
  withStartingMember(216),
  latestQuestPhaseEqual(217),
  notLatestQuestPhaseEqual(218),
  purchaseShopNum(219),
  eventTradeTotalNum(220),
  limitedMissionAchieveNumBelow(221),
  limitedMissionAchieveNumAbove(222),
  notSvtVoicePlayed(223),
  battlePointAbove(225),
  battlePointBelow(226),
  beforeSpecifiedDate(228),
  notHaveChargeStone(229),
  haveChargeStone(230),
  battleFunctionTargetAllIndividuality(231),
  battleFunctionTargetOneIndividuality(232),
  beforeQuestClearTime(233),
  afterQuestClearTime(234),
  notBattleFunctionTargetAllIndividuality(235),
  notBattleFunctionTargetOneIndividuality(236),
  eventScriptNotPlay(237),
  eventScriptFlag(238),
  imagePartsGroup(241),
  userLevelAbove(242),
  userLevelBelow(243),
  userLevelEqual(244),
  highestWaveAbove(245),
  highestWaveBelow(246),
  privilegeValid(247),
  privilegeInvalid(248),
  battleActionOpponentIndividuality(249),
  notBattleActionOpponentIndividuality(250),
  treasureDeviceOfSelectedCard(251),
  battleSvtFriendshipAbove(252),
  battleSvtFriendshipBelow(253),
  elapsedTimeAfterSvtGet(254),
  notElapsedTimeAfterQuestClear(255),
  notElapsedTimeAfterSvtGet(256),
  // 257?
  grandSvtSet(258),
  playedMovie(259),
  notPlayedMovie(260),
  notShopGroupLimitNum(263);

  const CondType(this.value);
  final int value;
}

@JsonSerializable()
class CommonConsume {
  int id;
  int priority;
  CommonConsumeType type;
  int objectId;
  int num;

  CommonConsume({required this.id, this.priority = 0, required this.type, required this.objectId, required this.num});

  factory CommonConsume.fromJson(Map<String, dynamic> json) => _$CommonConsumeFromJson(json);

  Map<String, dynamic> toJson() => _$CommonConsumeToJson(this);
}

@JsonSerializable()
class CommonRelease with RouteInfo {
  int id;
  int priority;
  int condGroup;
  @CondTypeConverter()
  CondType condType;
  int condId;
  int condNum;

  CommonRelease({
    required this.id,
    this.priority = 0,
    this.condGroup = 0,
    required this.condType,
    this.condId = 0,
    this.condNum = 0,
  });

  factory CommonRelease.fromJson(Map<String, dynamic> json) => _$CommonReleaseFromJson(json);

  @override
  String get route => Routes.commonReleaseI(id);

  Map<String, dynamic> toJson() => _$CommonReleaseToJson(this);
}
