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
  kr(Language.ko),
  ;

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

mixin DataScriptBase {
  Map<String, dynamic> _source = {};
  Map<String, dynamic> get source => _source;
  void setSource(Map<String, dynamic>? json) => json == null ? null : _source = Map.from(json);
  List<T>? list<T>(String key) => (_source[key] as List<dynamic>?)?.cast();
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

  Bgm({
    required this.id,
    this.name = '',
    this.fileName = "",
    this.notReleased = true,
    this.audioAsset,
  });

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

  StageLink({
    this.questId = 0,
    this.phase = 1,
    this.stage = 1,
  });
  factory StageLink.fromJson(Map<String, dynamic> json) => _$StageLinkFromJson(json);

  Map<String, dynamic> toJson() => _$StageLinkToJson(this);
}

enum CardType {
  none(0),
  arts(1),
  buster(2),
  quick(3),
  extra(4),
  blank(5),
  weak(10),
  strength(11),
  ;

  final int id;
  const CardType(this.id);

  bool get isQAB => [CardType.quick, CardType.arts, CardType.buster].contains(this);
}

final kCardTypeMapping = {for (final card in CardType.values) card.id: card};

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
  // 13
  // 14
  // 15
  // 16
  grandCaster(17, '術'),
  // 18
  // 19
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
  beast(33, '獸'),
  beastVI(34, '獸Ⅵ'),
  beastVIBoss(35, '獸Ⅵ'),
  uOlgaMarieFlare(36),
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
  // ignore: constant_identifier_names
  EXTRA1(1004, 'EXTRA1'),
  // ignore: constant_identifier_names
  EXTRA2(1004, 'EXTRA2'),
  ;

  final int id;
  final String shortName;
  const SvtClass(this.id, [this.shortName = '?']);
}

class SvtClassConverter implements JsonConverter<SvtClass, String> {
  const SvtClassConverter();

  @override
  SvtClass fromJson(String value) {
    for (final cls in _$SvtClassEnumMap.keys) {
      if (_$SvtClassEnumMap[cls] == value) return cls;
    }
    return SvtClass.none;
  }

  @override
  String toJson(SvtClass cls) {
    return _$SvtClassEnumMap[cls] ?? cls.name;
  }

  static int? fromString(String value, Map<int, SvtClassMapping> mapping) {
    for (final cls in SvtClass.values) {
      if (cls.name == value) return cls.id;
    }
    int? pureInt = int.tryParse(value);
    if (pureInt != null && pureInt > 0) return pureInt;
    return mapping.entries.firstWhereOrNull((entry) => entry.value.name == value)?.key;
  }
}

const _kSvtClassRarityMap = {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 3};

extension SvtClassX on SvtClass {
  static const beast = SvtClass.beast;

  SvtClassInfo? get info => db.gameData.constData.classInfo[id];
  int get iconId => info?.iconImageId ?? 12;

  String icon(int svtRarity) => clsIcon(id, svtRarity, iconId);

  static String clsIcon(int clsId, int svtRarity, [int? iconId]) {
    iconId ??= ConstData.classInfo[clsId]?.iconImageId;
    int rarity = _kSvtClassRarityMap[svtRarity] ?? svtRarity;
    rarity = const <int, int>{
          1003: 2,
          17: 3,
        }[iconId] ??
        rarity;
    return Atlas.asset('ClassIcons/class${rarity}_${iconId ?? 12}.png');
  }

  static void routeTo(int id) {
    router.push(url: Routes.svtClassI(id));
  }

  String get lName => Transl.svtClassId(id).l;

  static List<SvtClass> regularAll = [
    ...regular,
    ...extra,
  ];

  static List<SvtClass> regularAllWithBeast = [
    ...regular,
    ...extra,
    SvtClassX.beast,
  ];

  static List<SvtClass> regularAllWithBeasts = [
    ...regularAll,
    ...beasts,
  ];

  static const regular = <SvtClass>[
    SvtClass.saber,
    SvtClass.archer,
    SvtClass.lancer,
    SvtClass.rider,
    SvtClass.caster,
    SvtClass.assassin,
    SvtClass.berserker,
  ];
  static const extra = <SvtClass>[
    SvtClass.ruler,
    SvtClass.avenger,
    SvtClass.alterEgo,
    SvtClass.moonCancer,
    SvtClass.foreigner,
    SvtClass.pretender,
    SvtClass.shielder,
  ];
  static const beasts = <SvtClass>[
    SvtClass.beast,
    SvtClass.beastI,
    SvtClass.beastII,
    SvtClass.beastIIIR,
    SvtClass.beastIIIL,
    SvtClass.beastIV,
    SvtClass.beastUnknown,
    SvtClass.uOlgaMarieAlienGod,
    // SvtClass.uOlgaMarie,
    SvtClass.beastILost,
    SvtClass.beastVI,
    SvtClass.beastVIBoss,
  ];

  static bool match(SvtClass value, SvtClass option) {
    if (option == value) return true;
    if (option == SvtClass.caster) return value == SvtClass.grandCaster;
    if (option == SvtClassX.beast) {
      return beasts.contains(value);
    }
    if (option == SvtClass.EXTRA) {
      return extra.contains(value) || beasts.contains(value);
    }
    if (option == SvtClass.unknown) {
      return !SvtClassX.regularAllWithBeasts.contains(value);
    }
    return false;
  }
}

/// non-JP may not contains the last class
const kSvtClassIdsPlayableAll = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 23, 25, 28, 33];
const kSvtClassIdsPlayableAlways = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 23, 25];
final kSvtClassIds = {for (final v in SvtClass.values) v.id: v};

enum SvtClassSupportGroupType {
  all,
  saber,
  archer,
  lancer,
  rider,
  caster,
  assassin,
  berserker,
  extra,
  mix,
  notSupport,
}

const kSvtClassSupportGroupIds = <int, SvtClassSupportGroupType>{
  0: SvtClassSupportGroupType.all,
  1: SvtClassSupportGroupType.saber,
  2: SvtClassSupportGroupType.archer,
  3: SvtClassSupportGroupType.lancer,
  4: SvtClassSupportGroupType.rider,
  5: SvtClassSupportGroupType.caster,
  6: SvtClassSupportGroupType.assassin,
  7: SvtClassSupportGroupType.berserker,
  8: SvtClassSupportGroupType.extra,
  9: SvtClassSupportGroupType.mix,
  999: SvtClassSupportGroupType.notSupport,
};
final kSvtClassSupportGroupIdsReverse = kSvtClassSupportGroupIds.map((k, v) => MapEntry(v, k));

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
  canBeInBattle(5000),
  notBasedOnServant(5010),
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
  eventGuda5(94000108),
  ;

  final int id;
  const Trait(this.id);

  static bool isEventField(int id) {
    return id ~/ 1000 == 94000;
  }
}

@JsonEnum(alwaysCreate: true)
enum CondType {
  none,
  questClear,
  itemGet,
  useItemEternity,
  useItemTime,
  useItemCount,
  svtLevel,
  svtLimit,
  svtGet,
  svtFriendship,
  svtGroup,
  event,
  date,
  weekday,
  purchaseQpShop,
  purchaseStoneShop,
  warClear,
  flag,
  svtCountStop,
  birthDay,
  eventEnd,
  svtEventJoin,
  missionConditionDetail,
  eventMissionClear,
  eventMissionAchieve,
  questClearNum,
  notQuestGroupClear,
  raidAlive,
  raidDead,
  raidDamage,
  questChallengeNum,
  masterMission,
  questGroupClear,
  superBossDamage,
  superBossDamageAll,
  purchaseShop,
  questNotClear,
  notShopPurchase,
  notSvtGet,
  notEventShopPurchase,
  svtHaving,
  notSvtHaving,
  questChallengeNumEqual,
  questChallengeNumBelow,
  questClearNumEqual,
  questClearNumBelow,
  questClearPhase,
  notQuestClearPhase,
  eventPointGroupWin,
  eventNormaPointClear,
  questAvailable,
  questGroupAvailableNum,
  eventNormaPointNotClear,
  notItemGet,
  costumeGet,
  questResetAvailable,
  svtGetBeforeEventEnd,
  questClearRaw,
  questGroupClearRaw,
  eventGroupPointRatioInTerm,
  eventGroupRankInTerm,
  notEventRaceQuestOrNotAllGroupGoal,
  eventGroupTotalWinEachPlayer,
  eventScriptPlay,
  svtCostumeReleased,
  questNotClearAnd,
  svtRecoverd,
  shopReleased,
  eventPoint,
  eventRewardDispCount,
  equipWithTargetCostume,
  raidGroupDead,
  notSvtGroup,
  notQuestResetAvailable,
  notQuestClearRaw,
  notQuestGroupClearRaw,
  notEventMissionClear,
  notEventMissionAchieve,
  notCostumeGet,
  notSvtCostumeReleased,
  notEventRaceQuestOrNotTargetRankGoal,
  playerGenderType,
  shopGroupLimitNum,
  eventGroupPoint,
  eventGroupPointBelow,
  eventTotalPoint,
  eventTotalPointBelow,
  eventValue,
  eventValueBelow,
  eventFlag,
  eventStatus,
  notEventStatus,
  forceFalse,
  svtHavingLimitMax,
  eventPointBelow,
  svtEquipFriendshipHaving,
  movieNotDownload,
  multipleDate,
  svtFriendshipAbove,
  svtFriendshipBelow,
  movieDownloaded,
  routeSelect,
  notRouteSelect,
  limitCount,
  limitCountAbove,
  limitCountBelow,
  badEndPlay,
  commandCodeGet,
  notCommandCodeGet,
  allUsersBoxGachaCount,
  totalTdLevel,
  totalTdLevelAbove,
  totalTdLevelBelow,
  commonRelease,
  battleResultWin,
  battleResultLose,
  eventValueEqual,
  boardGameTokenHaving,
  boardGameTokenGroupHaving,
  eventFlagOn,
  eventFlagOff,
  questStatusFlagOn,
  questStatusFlagOff,
  eventValueNotEqual,
  limitCountMaxEqual,
  limitCountMaxAbove,
  limitCountMaxBelow,
  boardGameTokenGetNum,
  battleLineWinAbove,
  battleLineLoseAbove,
  battleLineContinueWin,
  battleLineContinueLose,
  battleLineContinueWinBelow,
  battleLineContinueLoseBelow,
  battleGroupWinAvove,
  battleGroupLoseAvove,
  svtLimitClassNum,
  overTimeLimitRaidAlive,
  onTimeLimitRaidDead,
  onTimeLimitRaidDeadNum,
  raidBattleProgressAbove,
  svtEquipRarityLevelNum,
  latestMainScenarioWarClear,
  eventMapValueContains,
  resetBirthDay,
  shopFlagOn,
  shopFlagOff,
  purchaseValidShopGroup,
  svtLevelClassNum,
  svtLevelIdNum,
  limitCountImageEqual,
  limitCountImageAbove,
  limitCountImageBelow,
  eventTypeStartTimeToEndDate,
  existBoxGachaScriptReplaceGiftId,
  notExistBoxGachaScriptReplaceGiftId,
  limitedPeriodVoiceChangeTypeOn,
  startRandomMission,
  randomMissionClearNum,
  progressValueEqual,
  progressValueAbove,
  progressValueBelow,
  randomMissionTotalClearNum,
  weekdays,
  eventFortificationRewardNum,
  questClearBeforeEventStart,
  notQuestClearBeforeEventStart,
  eventTutorialFlagOn,
  eventTutorialFlagOff,
  eventSuperBossValueEqual,
  notEventSuperBossValueEqual,
  allSvtTargetSkillLvNum,
  superBossDamageAbove,
  superBossDamageBelow,
  eventMissionGroupAchieve,
  svtFriendshipClassNumAbove,
  notWarClear,
  svtSkillLvClassNumAbove,
  svtClassLvUpCount,
  svtClassSkillLvUpCount,
  svtClassLimitUpCount,
  svtClassFriendshipCount,
  completeHeelPortrait,
  notCompleteHeelPortrait,
  classBoardSquareReleased,
  svtLevelExchangeSvt,
  svtLimitExchangeSvt,
  skillLvExchangeSvt,
  svtFriendshipExchangeSvt,
  exchangeSvt,
}

@JsonSerializable()
class CommonConsume {
  int id;
  int priority;
  CommonConsumeType type;
  int objectId;
  int num;

  CommonConsume({
    required this.id,
    this.priority = 0,
    required this.type,
    required this.objectId,
    required this.num,
  });

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
  String get route => Routes.commonRelease(id);

  Map<String, dynamic> toJson() => _$CommonReleaseToJson(this);
}
