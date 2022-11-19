part of 'common.dart';

CondType toEnumCondType(Object value) {
  return $enumDecode(_$CondTypeEnumMap, value, unknownValue: CondType.none);
}

CondType? toEnumNullCondType(Object? value) {
  return $enumDecodeNullable(_$CondTypeEnumMap, value);
}

extension TraitX on Trait {
  int? get id => kTraitIdMappingReverse[this];
}

// utils
const kTraitIdMapping = <int, Trait>{
  1: Trait.genderMale,
  2: Trait.genderFemale,
  3: Trait.genderUnknown,
  100: Trait.classSaber,
  101: Trait.classLancer,
  102: Trait.classArcher,
  103: Trait.classRider,
  104: Trait.classCaster,
  105: Trait.classAssassin,
  106: Trait.classBerserker,
  107: Trait.classShielder,
  108: Trait.classRuler,
  109: Trait.classAlterEgo,
  110: Trait.classAvenger,
  111: Trait.classDemonGodPillar,
  112: Trait.classGrandCaster,
  113: Trait.classBeastI,
  114: Trait.classBeastII,
  115: Trait.classMoonCancer,
  116: Trait.classBeastIIIR,
  117: Trait.classForeigner,
  118: Trait.classBeastIIIL,
  119: Trait.classBeastUnknown,
  120: Trait.classPretender,
  121: Trait.classBeastIV,
  200: Trait.attributeSky,
  201: Trait.attributeEarth,
  202: Trait.attributeHuman,
  203: Trait.attributeStar,
  204: Trait.attributeBeast,
  300: Trait.alignmentLawful,
  301: Trait.alignmentChaotic,
  302: Trait.alignmentNeutral,
  303: Trait.alignmentGood,
  304: Trait.alignmentEvil,
  305: Trait.alignmentBalanced,
  306: Trait.alignmentMadness,
  308: Trait.alignmentSummer,
  1000: Trait.basedOnServant,
  //  # can be NPC or enemy but use a servant's data
  1001: Trait.human,
  //  # Sanson's 3rd skill
  1002: Trait.undead,
  //  # Scathach's 3rd skill
  1003: Trait.artificialDemon,
  1004: Trait.demonBeast,
  1005: Trait.demon,
  1100: Trait.soldier,
  1101: Trait.amazoness,
  1102: Trait.skeleton,
  1103: Trait.zombie,
  1104: Trait.ghost,
  1105: Trait.automata,
  1106: Trait.golem,
  1107: Trait.spellBook,
  1108: Trait.homunculus,
  1110: Trait.lamia,
  1111: Trait.centaur,
  1112: Trait.werebeast,
  1113: Trait.chimera,
  1117: Trait.wyvern,
  1118: Trait.dragonType,
  1119: Trait.gazer,
  1120: Trait.handOrDoor,
  1121: Trait.demonGodPillar,
  1122: Trait.shadowServant,
  1128: Trait.enemyGardenOfSinnersLivingCorpse,
  1129: Trait.enemyGardenOfSinnersApartmentGhostAndSkeleton,
  1130: Trait.enemyGardenOfSinnersBaseModel,
  1131: Trait.enemyGardenOfSinnersVengefulSpiritOfSevenPeople,
  1132: Trait.oni,
  1133: Trait.hand,
  1134: Trait.door,
  1135: Trait.enemySaberEliWerebeastAndHomunculusAndKnight,
  1136: Trait.enemySaberEliSkeletonAndGhostAndLamia,
  1137: Trait.enemySaberEliBugAndGolem,
  1138: Trait.enemySeraphEater,
  1139: Trait.enemySeraphShapeshifter,
  1140: Trait.enemySeraphTypeI,
  1141: Trait.enemySeraphTypeSakura,
  1155: Trait.enemyHimejiCastleKnightAndGazerAndMassProduction,
  1156: Trait.enemyHimejiCastleDronesAndHomunculusAndAutomata,
  1157: Trait.enemyHimejiCastleSkeletonAndScarecrow,
  1171: Trait.enemyGuda3MiniNobu,
  1172: Trait.threatToHumanity,
  1177: Trait.fae,
  2000: Trait.divine,
  2001: Trait.humanoid,
  2002: Trait.dragon,
  2003: Trait.dragonSlayer,
  2004: Trait.roman,
  2005: Trait.wildbeast,
  2006: Trait.atalante,
  2007: Trait.saberface,
  2008: Trait.weakToEnumaElish,
  2009: Trait.riding,
  2010: Trait.arthur,
  2011: Trait.skyOrEarthServant,
  // # Tesla's NP
  2012: Trait.brynhildsBeloved,
  2018: Trait.undeadOrDemon,
  // # Amakusa bond CE
  2019: Trait.demonic,
  2023: Trait.enemyDavinciTrueEnemy,
  2024: Trait.enemyDavinciFalseEnemy,
  2037: Trait.skyOrEarthExceptPseudoAndDemiServant,
  // # Raikou's 3rd skill
  2038: Trait.fieldSunlight,
  2039: Trait.fieldShore,
  2040: Trait.divineOrDemonOrUndead,
  // # Ruler Martha's 3rd skill
  2073: Trait.fieldForest,
  2074: Trait.blessedByKur,
  // # Eresh's 3rd skill add this individuality
  2075: Trait.saberClassServant,
  // # MHXA NP
  2076: Trait.superGiant,
  2113: Trait.king,
  2114: Trait.greekMythologyMales,
  2121: Trait.fieldBurning,
  2191: Trait.buffCharmFemale,
  // # Charm buffs that come from females; Fion 2nd skill
  2221: Trait.enemyGudaMiniNobu,
  2355: Trait.illya,
  2356: Trait.feminineLookingServant,
  // # Teach's 3rd skill
  2385: Trait.cursedBook,
  // # Murasaki Valentine
  2386: Trait.kingproteaProliferation,
  2387: Trait.kingproteaInfiniteProliferation,
  2392: Trait.fieldCity,
  2403: Trait.enemyCaseFilesRareEnemy,
  2469: Trait.enemyLasVegasBonusEnemy,
  2466: Trait.associatedToTheArgo,
  2467: Trait.weakPointsRevealed,
  // # Paris 1st skill
  2615: Trait.genderCaenisServant,
  // # Phantom's 2nd skill
  2631: Trait.hominidaeServant,
  // # used in TamaVitch's fight
  2632: Trait.demonicBeastServant,
  // # used in TamaVitch's fight
  2654: Trait.livingHuman,
  // # Voyager's NP
  2663: Trait.enemySummerCampRareEnemy,
  2664: Trait.kingproteaProliferationNPDefense,
  2666: Trait.giant,
  2667: Trait.childServant,
  // # Summer Illya's 2nd skill
  2721: Trait.nobunaga,
  // # Nobukatsu's skill
  2729: Trait.curse,
  // # Van Gogh passive
  2730: Trait.fieldImaginarySpace,
  2731: Trait.existenceOutsideTheDomain,
  2732: Trait.fieldShoreOrImaginarySpace,
  // # Nemo's 3rd skill and bond CE
  2733: Trait.shutenOnField,
  // # Ibaraki strengthened 2nd skill
  2734: Trait.shuten,
  // # Ibaraki strengthened 2nd skill
  2735: Trait.genji,
  2749: Trait.enemyLittleBigTenguTsuwamonoEnemy,
  2759: Trait.vengeance,
  // # Taira 2nd skill and NP
  2780: Trait.hasCostume,
  2781: Trait.mechanical,
  2795: Trait.knightsOfTheRound,
  2797: Trait.divineSpirit,
  2801: Trait.burningLove,
  // # Summer Kama 3rd skill
  2802: Trait.buffStrongAgainstDragon,
  2803: Trait.buffStrongAgainstWildBeast,
  2810: Trait.fairyTaleServant,
  2821: Trait.havingAnimalsCharacteristics,
  2827: Trait.like,
  2828: Trait.exaltation,
  2829: Trait.milleniumCastle,
  2833: Trait.yuMeiren,
  2835: Trait.immuneToPigify,
  2836: Trait.protoMerlinNPChargeBlock,
  2837: Trait.valkyrie,
  2838: Trait.summerModeServant,
  2839: Trait.shinsengumiServant,
  2840: Trait.ryozanpaku,
// # 2xxx: CQ or Story quests buff
  3000: Trait.attackPhysical,
  // # Normal attack, including NP
  3001: Trait.attackProjectile,
  3002: Trait.attackMagical,
  3004: Trait.buffPositiveEffect,
  3005: Trait.buffNegativeEffect,
  // # mutually exclusive with 3004
  3006: Trait.buffIncreaseDamage,
  // # catch all damage: atk, np, powermod, ...
  3007: Trait.buffIncreaseDefence,
  // # catch all defence, including evade
  3008: Trait.buffDecreaseDamage,
  3009: Trait.buffDecreaseDefence,
  // # including death resist down and card color resist down
  3010: Trait.buffMentalEffect,
  // # charm, terror, confusion
  3011: Trait.buffPoison,
  3012: Trait.buffCharm,
  3013: Trait.buffPetrify,
  3014: Trait.buffStun,
  // # including Pigify
  3015: Trait.buffBurn,
  3016: Trait.buffSpecialResistUp,
  // # Unused stuffs
  3017: Trait.buffSpecialResistDown,
  // # Unused stuffs
  3018: Trait.buffEvadeAndInvincible,
  3019: Trait.buffSureHit,
  3020: Trait.buffNpSeal,
  3021: Trait.buffEvade,
  3022: Trait.buffInvincible,
  3023: Trait.buffTargetFocus,
  3024: Trait.buffGuts,
  3025: Trait.skillSeal,
  3026: Trait.buffCurse,
  3027: Trait.buffAtkUp,
  // # Likely not the best name for this
  3028: Trait.buffPowerModStrUp,
  3029: Trait.buffDamagePlus,
  3030: Trait.buffNpDamageUp,
  3031: Trait.buffCritDamageUp,
  3032: Trait.buffCritRateUp,
  3033: Trait.buffAtkDown,
  3034: Trait.buffPowerModStrDown,
  3035: Trait.buffDamageMinus,
  3036: Trait.buffNpDamageDown,
  3037: Trait.buffCritDamageDown,
  3038: Trait.buffCritRateDown,
  3039: Trait.buffDeathResistDown,
  3040: Trait.buffDefenceUp,
  3041: Trait.buffMaxHpUpPercent,
  3042: Trait.buffMaxHpDownPercent,
  3043: Trait.buffMaxHpUp,
  3044: Trait.buffMaxHpDown,
  3045: Trait.buffImmobilize,
  // # Including Petrify, Bound, Pigify, Stun
  3046: Trait.buffIncreasePoisonEffectiveness,
  3047: Trait.buffPigify,
  3048: Trait.buffCurseEffectUp,
  3049: Trait.buffTerrorStunChanceAfterTurn,
  3052: Trait.buffConfusion,
  3053: Trait.buffOffensiveMode,
  // # Unused
  3054: Trait.buffDefensiveMode,
  // # Unused
  3055: Trait.buffLockCardsDeck,
  // # Summer BB
  3056: Trait.buffDisableColorCard,
  3057: Trait.buffChangeField,
  3058: Trait.buffDefUp,
  // # Unsure
  3059: Trait.buffInvinciblePierce,
  3060: Trait.buffHpRecoveryPerTurn,
  3061: Trait.buffNegativeEffectImmunity,
  3063: Trait.buffDelayedNegativeEffect,
  3064: Trait.buffSpecialInvincible,
  3065: Trait.buffSkillRankUp,
  3066: Trait.buffSleep,
  3068: Trait.chenGongNpBlock,
  3070: Trait.buffNullifyBuff,
// # 6016: No detail
// # 6021: No detail
// # 6022: No detail
// # 10xxx: CCC Kiara buff
  4001: Trait.cardArts,
  4002: Trait.cardBuster,
  4003: Trait.cardQuick,
  4004: Trait.cardExtra,
  4007: Trait.cardNP,
  4008: Trait.faceCard,
  // # Normal Buster, Arts, Quick, Extra Attack
  4100: Trait.criticalHit,
  4101: Trait.aoeNP,
  4102: Trait.stNP,
  5000: Trait.canBeInBattle,
  // # can be NPC, enemy or playable servant i.e. not CE
  5010: Trait.notBasedOnServant,
  94000015: Trait.eventSaberWars,
  94000037: Trait.eventRashomon,
  94000045: Trait.eventOnigashima,
  94000046: Trait.eventOnigashimaRaid,
  94000047: Trait.eventPrisma,
  94000048: Trait.eventPrismaWorldEndMatch,
  94000049: Trait.eventNeroFest2,
  94000057: Trait.eventGuda2,
  94000066: Trait.eventNeroFest3,
  94000071: Trait.eventSetsubun,
  94000074: Trait.eventApocrypha,
  94000077: Trait.eventBattleInNewYork1,
  94000078: Trait.eventOniland,
  94000086: Trait.eventOoku,
  94000089: Trait.eventGuda4,
  94000091: Trait.eventLasVegas,
  94000092: Trait.eventBattleInNewYork2,
  94000095: Trait.eventSaberWarsII,
  94000107: Trait.eventSummerCamp,
  94000108: Trait.eventGuda5,
};

final kTraitIdMappingReverse = () {
  final reversed = kTraitIdMapping.map((key, value) => MapEntry(value, key));
  assert(() {
    List<Trait> invalid = [];
    for (final trait in Trait.values) {
      if (!reversed.containsKey(trait) && trait != Trait.unknown) {
        invalid.add(trait);
      }
    }
    if (invalid.isNotEmpty) {
      throw ArgumentError.value(
          invalid.toString(), null, 'Not in trait-id (reversed) mapping');
    }
    return true;
  }());
  return reversed;
}();
