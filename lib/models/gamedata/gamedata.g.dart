// GENERATED CODE - DO NOT MODIFY BY HAND

part of gamedata;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map json) => GameData(
      version: json['version'] == null
          ? const DataVersion()
          : DataVersion.fromJson(
              Map<String, dynamic>.from(json['version'] as Map)),
      servants: (json['servants'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                Servant.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      craftEssences: (json['craftEssences'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                CraftEssence.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      commandCodes: (json['commandCodes'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                CommandCode.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mysticCodes: (json['mysticCodes'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                MysticCode.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      events: (json['events'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                Event.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      wars: (json['wars'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                NiceWar.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                Item.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      fixedDrops: (json['fixedDrops'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), e as int),
                )),
          ) ??
          const {},
      extraData: json['extraData'] == null
          ? const ExtraData()
          : ExtraData.fromJson(
              Map<String, dynamic>.from(json['extraData'] as Map)),
      exchangeTickets: (json['exchangeTickets'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                ExchangeTicket.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      questPhases: (json['questPhases'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                QuestPhase.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mappingData: json['mappingData'] == null
          ? const MappingData()
          : MappingData.fromJson(
              Map<String, dynamic>.from(json['mappingData'] as Map)),
      constData: json['constData'] == null
          ? const ConstGameData()
          : ConstGameData.fromJson(
              Map<String, dynamic>.from(json['constData'] as Map)),
      dropRateData: json['dropRateData'] == null
          ? const DropRateData()
          : DropRateData.fromJson(
              Map<String, dynamic>.from(json['dropRateData'] as Map)),
    );

ExchangeTicket _$ExchangeTicketFromJson(Map json) => ExchangeTicket(
  key: json['key'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      items: (json['items'] as List<dynamic>).map((e) => e as int).toList(),
    );

ConstGameData _$ConstGameDataFromJson(Map json) => ConstGameData(
      classRelation: (json['classRelation'] as Map?)?.map(
            (k, e) => MapEntry(
                $enumDecode(_$SvtClassEnumMap, k),
                (e as Map).map(
                  (k, e) =>
                      MapEntry($enumDecode(_$SvtClassEnumMap, k), e as int),
                )),
          ) ??
          const {},
      classAttackRate: (json['classAttackRate'] as Map?)?.map(
            (k, e) => MapEntry($enumDecode(_$SvtClassEnumMap, k), e as int),
          ) ??
          const {},
      svtGrailCost: (json['svtGrailCost'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), e as Map),
                )),
          ) ??
          const {},
      userLevel: (json['userLevel'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as Map),
          ) ??
          const {},
      cardInfo: (json['cardInfo'] as Map?)?.map(
            (k, e) => MapEntry(
                $enumDecode(_$CardTypeEnumMap, k),
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), e as Map),
                )),
          ) ??
          const {},
    );

const _$SvtClassEnumMap = {
  SvtClass.saber: 'saber',
  SvtClass.archer: 'archer',
  SvtClass.lancer: 'lancer',
  SvtClass.rider: 'rider',
  SvtClass.caster: 'caster',
  SvtClass.assassin: 'assassin',
  SvtClass.berserker: 'berserker',
  SvtClass.shielder: 'shielder',
  SvtClass.ruler: 'ruler',
  SvtClass.alterEgo: 'alterEgo',
  SvtClass.avenger: 'avenger',
  SvtClass.demonGodPillar: 'demonGodPillar',
  SvtClass.moonCancer: 'moonCancer',
  SvtClass.foreigner: 'foreigner',
  SvtClass.pretender: 'pretender',
  SvtClass.grandCaster: 'grandCaster',
  SvtClass.beastII: 'beastII',
  SvtClass.ushiChaosTide: 'ushiChaosTide',
  SvtClass.beastI: 'beastI',
  SvtClass.beastIIIR: 'beastIIIR',
  SvtClass.beastIIIL: 'beastIIIL',
  SvtClass.beastIV: 'beastIV',
  SvtClass.beastUnknown: 'beastUnknown',
  SvtClass.unknown: 'unknown',
  SvtClass.agarthaPenth: 'agarthaPenth',
  SvtClass.cccFinaleEmiyaAlter: 'cccFinaleEmiyaAlter',
  SvtClass.salemAbby: 'salemAbby',
  SvtClass.ALL: 'ALL',
};

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
};

DataVersion _$DataVersionFromJson(Map json) => DataVersion(
  timestamp: json['timestamp'] as int? ?? 0,
      utc: json['utc'] as String? ?? "",
      minimalApp: json['minimalApp'] == null
          ? const AppVersion(0, 0, 0)
          : DataVersion._parseAppVersion(json['minimalApp'] as String),
      files: (json['files'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                DatFileVersion.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

DatFileVersion _$DatFileVersionFromJson(Map json) => DatFileVersion(
      timestamp: json['timestamp'] as int,
      hash: json['hash'] as String,
    );

MappingData _$MappingDataFromJson(Map json) => MappingData(
      itemNames: (json['itemNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mcNames: (json['mcNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      costumeNames: (json['costumeNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      cvNames: (json['cvNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      illustratorNames: (json['illustratorNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      ccNames: (json['ccNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      svtNames: (json['svtNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      ceNames: (json['ceNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      eventNames: (json['eventNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      warNames: (json['warNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      questNames: (json['questNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      spotNames: (json['spotNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      entityNames: (json['entityNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdTypes: (json['tdTypes'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      bgmNames: (json['bgmNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      summonNames: (json['summonNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      charaNames: (json['charaNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      buffNames: (json['buffNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      buffDetail: (json['buffDetail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      funcPopuptext: (json['funcPopuptext'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillNames: (json['skillNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillDetail: (json['skillDetail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdNames: (json['tdNames'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdRuby: (json['tdRuby'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdDetail: (json['tdDetail'] as Map?)?.map(
            (k, e) => MapEntry(
                k as String,
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      trait: (json['trait'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      mcDetail: (json['mcDetail'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      costumeDetail: (json['costumeDetail'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<String>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillState: (json['skillState'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<Map<int, int>>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      tdState: (json['tdState'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                MappingBase<Map<int, int>>.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

MappingBase<T> _$MappingBaseFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    MappingBase<T>(
      jp: _$nullableGenericFromJson(json['JP'], fromJsonT),
      cn: _$nullableGenericFromJson(json['CN'], fromJsonT),
      tw: _$nullableGenericFromJson(json['TW'], fromJsonT),
      na: _$nullableGenericFromJson(json['NA'], fromJsonT),
      kr: _$nullableGenericFromJson(json['KR'], fromJsonT),
    );

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

DropRateData _$DropRateDataFromJson(Map json) => DropRateData(
      newData: json['newData'] == null
          ? const DropRateSheet()
          : DropRateSheet.fromJson(
              Map<String, dynamic>.from(json['newData'] as Map)),
      legacyData: json['legacyData'] == null
          ? const DropRateSheet()
          : DropRateSheet.fromJson(
              Map<String, dynamic>.from(json['legacyData'] as Map)),
    );

DropRateSheet _$DropRateSheetFromJson(Map json) => DropRateSheet(
      questIds:
          (json['questIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      itemIds:
          (json['itemIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      apCosts:
          (json['apCosts'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      runs: (json['runs'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      sparseMatrix: (json['sparseMatrix'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) =>
                      MapEntry(int.parse(k as String), (e as num).toDouble()),
                )),
          ) ??
          const {},
    );

CommandCode _$CommandCodeFromJson(Map json) => CommandCode(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      rarity: json['rarity'] as int,
      extraAssets: ExtraCCAssets.fromJson(
          Map<String, dynamic>.from(json['extraAssets'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      illustrator: json['illustrator'] as String,
      comment: json['comment'] as String,
    );

NiceTrait _$NiceTraitFromJson(Map json) => NiceTrait(
      id: json['id'] as int,
      name: $enumDecode(_$TraitEnumMap, json['name']),
      negative: json['negative'] as bool?,
    );

const _$TraitEnumMap = {
  Trait.unknown: 'unknown',
  Trait.genderMale: 'genderMale',
  Trait.genderFemale: 'genderFemale',
  Trait.genderUnknown: 'genderUnknown',
  Trait.classSaber: 'classSaber',
  Trait.classLancer: 'classLancer',
  Trait.classArcher: 'classArcher',
  Trait.classRider: 'classRider',
  Trait.classCaster: 'classCaster',
  Trait.classAssassin: 'classAssassin',
  Trait.classBerserker: 'classBerserker',
  Trait.classShielder: 'classShielder',
  Trait.classRuler: 'classRuler',
  Trait.classAlterEgo: 'classAlterEgo',
  Trait.classAvenger: 'classAvenger',
  Trait.classDemonGodPillar: 'classDemonGodPillar',
  Trait.classGrandCaster: 'classGrandCaster',
  Trait.classBeastI: 'classBeastI',
  Trait.classBeastII: 'classBeastII',
  Trait.classMoonCancer: 'classMoonCancer',
  Trait.classBeastIIIR: 'classBeastIIIR',
  Trait.classForeigner: 'classForeigner',
  Trait.classBeastIIIL: 'classBeastIIIL',
  Trait.classBeastUnknown: 'classBeastUnknown',
  Trait.classPretender: 'classPretender',
  Trait.attributeSky: 'attributeSky',
  Trait.attributeEarth: 'attributeEarth',
  Trait.attributeHuman: 'attributeHuman',
  Trait.attributeStar: 'attributeStar',
  Trait.attributeBeast: 'attributeBeast',
  Trait.alignmentLawful: 'alignmentLawful',
  Trait.alignmentChaotic: 'alignmentChaotic',
  Trait.alignmentNeutral: 'alignmentNeutral',
  Trait.alignmentGood: 'alignmentGood',
  Trait.alignmentEvil: 'alignmentEvil',
  Trait.alignmentBalanced: 'alignmentBalanced',
  Trait.alignmentMadness: 'alignmentMadness',
  Trait.alignmentSummer: 'alignmentSummer',
  Trait.basedOnServant: 'basedOnServant',
  Trait.human: 'human',
  Trait.undead: 'undead',
  Trait.artificialDemon: 'artificialDemon',
  Trait.demonBeast: 'demonBeast',
  Trait.daemon: 'daemon',
  Trait.demon: 'demon',
  Trait.soldier: 'soldier',
  Trait.amazoness: 'amazoness',
  Trait.skeleton: 'skeleton',
  Trait.zombie: 'zombie',
  Trait.ghost: 'ghost',
  Trait.automata: 'automata',
  Trait.golem: 'golem',
  Trait.spellBook: 'spellBook',
  Trait.homunculus: 'homunculus',
  Trait.lamia: 'lamia',
  Trait.centaur: 'centaur',
  Trait.werebeast: 'werebeast',
  Trait.chimera: 'chimera',
  Trait.wyvern: 'wyvern',
  Trait.dragonType: 'dragonType',
  Trait.gazer: 'gazer',
  Trait.handOrDoor: 'handOrDoor',
  Trait.demonGodPillar: 'demonGodPillar',
  Trait.oni: 'oni',
  Trait.hand: 'hand',
  Trait.door: 'door',
  Trait.threatToHumanity: 'threatToHumanity',
  Trait.divine: 'divine',
  Trait.humanoid: 'humanoid',
  Trait.dragon: 'dragon',
  Trait.dragonSlayer: 'dragonSlayer',
  Trait.roman: 'roman',
  Trait.wildbeast: 'wildbeast',
  Trait.atalante: 'atalante',
  Trait.saberface: 'saberface',
  Trait.weakToEnumaElish: 'weakToEnumaElish',
  Trait.riding: 'riding',
  Trait.arthur: 'arthur',
  Trait.skyOrEarth: 'skyOrEarth',
  Trait.brynhildsBeloved: 'brynhildsBeloved',
  Trait.undeadOrDaemon: 'undeadOrDaemon',
  Trait.undeadOrDemon: 'undeadOrDemon',
  Trait.demonic: 'demonic',
  Trait.skyOrEarthExceptPseudoAndDemi: 'skyOrEarthExceptPseudoAndDemi',
  Trait.divineOrDaemonOrUndead: 'divineOrDaemonOrUndead',
  Trait.divineOrDemonOrUndead: 'divineOrDemonOrUndead',
  Trait.saberClassServant: 'saberClassServant',
  Trait.superGiant: 'superGiant',
  Trait.king: 'king',
  Trait.greekMythologyMales: 'greekMythologyMales',
  Trait.illya: 'illya',
  Trait.feminineLookingServant: 'feminineLookingServant',
  Trait.argonaut: 'argonaut',
  Trait.associatedToTheArgo: 'associatedToTheArgo',
  Trait.genderCaenisServant: 'genderCaenisServant',
  Trait.hominidaeServant: 'hominidaeServant',
  Trait.blessedByKur: 'blessedByKur',
  Trait.demonicBeastServant: 'demonicBeastServant',
  Trait.canBeInBattle: 'canBeInBattle',
  Trait.notBasedOnServant: 'notBasedOnServant',
  Trait.livingHuman: 'livingHuman',
  Trait.cardArts: 'cardArts',
  Trait.cardBuster: 'cardBuster',
  Trait.cardQuick: 'cardQuick',
  Trait.cardExtra: 'cardExtra',
  Trait.buffPositiveEffect: 'buffPositiveEffect',
  Trait.buffNegativeEffect: 'buffNegativeEffect',
  Trait.buffIncreaseDamage: 'buffIncreaseDamage',
  Trait.buffIncreaseDefence: 'buffIncreaseDefence',
  Trait.buffDecreaseDamage: 'buffDecreaseDamage',
  Trait.buffDecreaseDefence: 'buffDecreaseDefence',
  Trait.buffMentalEffect: 'buffMentalEffect',
  Trait.buffPoison: 'buffPoison',
  Trait.buffCharm: 'buffCharm',
  Trait.buffPetrify: 'buffPetrify',
  Trait.buffStun: 'buffStun',
  Trait.buffBurn: 'buffBurn',
  Trait.buffSpecialResistUp: 'buffSpecialResistUp',
  Trait.buffSpecialResistDown: 'buffSpecialResistDown',
  Trait.buffEvadeAndInvincible: 'buffEvadeAndInvincible',
  Trait.buffSureHit: 'buffSureHit',
  Trait.buffNpSeal: 'buffNpSeal',
  Trait.buffEvade: 'buffEvade',
  Trait.buffInvincible: 'buffInvincible',
  Trait.buffTargetFocus: 'buffTargetFocus',
  Trait.buffGuts: 'buffGuts',
  Trait.skillSeal: 'skillSeal',
  Trait.buffCurse: 'buffCurse',
  Trait.buffAtkUp: 'buffAtkUp',
  Trait.buffPowerModStrUp: 'buffPowerModStrUp',
  Trait.buffDamagePlus: 'buffDamagePlus',
  Trait.buffNpDamageUp: 'buffNpDamageUp',
  Trait.buffCritDamageUp: 'buffCritDamageUp',
  Trait.buffCritRateUp: 'buffCritRateUp',
  Trait.buffAtkDown: 'buffAtkDown',
  Trait.buffPowerModStrDown: 'buffPowerModStrDown',
  Trait.buffDamageMinus: 'buffDamageMinus',
  Trait.buffNpDamageDown: 'buffNpDamageDown',
  Trait.buffCritDamageDown: 'buffCritDamageDown',
  Trait.buffCritRateDown: 'buffCritRateDown',
  Trait.buffDeathResistDown: 'buffDeathResistDown',
  Trait.buffDefenceUp: 'buffDefenceUp',
  Trait.buffMaxHpUpPercent: 'buffMaxHpUpPercent',
  Trait.buffMaxHpDownPercent: 'buffMaxHpDownPercent',
  Trait.buffMaxHpUp: 'buffMaxHpUp',
  Trait.buffMaxHpDown: 'buffMaxHpDown',
  Trait.buffImmobilize: 'buffImmobilize',
  Trait.buffIncreasePoisonEffectiveness: 'buffIncreasePoisonEffectiveness',
  Trait.buffPigify: 'buffPigify',
  Trait.buffCurseEffectUp: 'buffCurseEffectUp',
  Trait.buffTerrorStunChanceAfterTurn: 'buffTerrorStunChanceAfterTurn',
  Trait.buffConfusion: 'buffConfusion',
  Trait.buffOffensiveMode: 'buffOffensiveMode',
  Trait.buffDefensiveMode: 'buffDefensiveMode',
  Trait.buffLockCardsDeck: 'buffLockCardsDeck',
  Trait.buffDisableColorCard: 'buffDisableColorCard',
  Trait.buffChangeField: 'buffChangeField',
  Trait.buffIncreaseDefenceAgainstIndividuality:
      'buffIncreaseDefenceAgainstIndividuality',
  Trait.buffInvinciblePierce: 'buffInvinciblePierce',
  Trait.buffHpRecoveryPerTurn: 'buffHpRecoveryPerTurn',
  Trait.buffNegativeEffectImmunity: 'buffNegativeEffectImmunity',
  Trait.buffNegativeEffectAtTurnEnd: 'buffNegativeEffectAtTurnEnd',
  Trait.attackPhysical: 'attackPhysical',
  Trait.attackProjectile: 'attackProjectile',
  Trait.attackMagical: 'attackMagical',
  Trait.criticalHit: 'criticalHit',
  Trait.faceCard: 'faceCard',
  Trait.cardNP: 'cardNP',
  Trait.kingproteaGrowth: 'kingproteaGrowth',
  Trait.kingproteaProliferation: 'kingproteaProliferation',
  Trait.kingproteaProliferationNPDefense: 'kingproteaProliferationNPDefense',
  Trait.fieldSunlight: 'fieldSunlight',
  Trait.fieldShore: 'fieldShore',
  Trait.fieldForest: 'fieldForest',
  Trait.fieldBurning: 'fieldBurning',
  Trait.fieldCity: 'fieldCity',
  Trait.shadowServant: 'shadowServant',
  Trait.aoeNP: 'aoeNP',
  Trait.giant: 'giant',
  Trait.childServant: 'childServant',
  Trait.buffSpecialInvincible: 'buffSpecialInvincible',
  Trait.buffSkillRankUp: 'buffSkillRankUp',
  Trait.buffSleep: 'buffSleep',
  Trait.nobunaga: 'nobunaga',
  Trait.fieldImaginarySpace: 'fieldImaginarySpace',
  Trait.existenceOutsideTheDomain: 'existenceOutsideTheDomain',
  Trait.curse: 'curse',
  Trait.fieldShoreOrImaginarySpace: 'fieldShoreOrImaginarySpace',
  Trait.shutenOnField: 'shutenOnField',
  Trait.shuten: 'shuten',
  Trait.genji: 'genji',
  Trait.vengeance: 'vengeance',
  Trait.enemyGardenOfSinnersLivingCorpse: 'enemyGardenOfSinnersLivingCorpse',
  Trait.enemyGardenOfSinnersApartmentGhostAndSkeleton:
      'enemyGardenOfSinnersApartmentGhostAndSkeleton',
  Trait.enemyGardenOfSinnersBaseModel: 'enemyGardenOfSinnersBaseModel',
  Trait.enemyGardenOfSinnersVengefulSpiritOfSevenPeople:
      'enemyGardenOfSinnersVengefulSpiritOfSevenPeople',
  Trait.enemySaberEliWerebeastAndHomunculusAndKnight:
      'enemySaberEliWerebeastAndHomunculusAndKnight',
  Trait.enemySaberEliSkeletonAndGhostAndLamia:
      'enemySaberEliSkeletonAndGhostAndLamia',
  Trait.enemySaberEliBugAndGolem: 'enemySaberEliBugAndGolem',
  Trait.enemySeraphEater: 'enemySeraphEater',
  Trait.enemySeraphShapeshifter: 'enemySeraphShapeshifter',
  Trait.enemySeraphTypeI: 'enemySeraphTypeI',
  Trait.enemySeraphTypeSakura: 'enemySeraphTypeSakura',
  Trait.enemyHimejiCastleKnightAndGazerAndMassProduction:
      'enemyHimejiCastleKnightAndGazerAndMassProduction',
  Trait.enemyHimejiCastleDronesAndHomunculusAndAutomata:
      'enemyHimejiCastleDronesAndHomunculusAndAutomata',
  Trait.enemyHimejiCastleSkeletonAndScarecrow:
      'enemyHimejiCastleSkeletonAndScarecrow',
  Trait.enemyGuda3MiniNobu: 'enemyGuda3MiniNobu',
  Trait.enemyDavinciTrueEnemy: 'enemyDavinciTrueEnemy',
  Trait.enemyDavinciFalseEnemy: 'enemyDavinciFalseEnemy',
  Trait.enemyCaseFilesRareEnemy: 'enemyCaseFilesRareEnemy',
  Trait.enemyLasVegasBonusEnemy: 'enemyLasVegasBonusEnemy',
  Trait.enemySummerCampRareEnemy: 'enemySummerCampRareEnemy',
  Trait.enemyLittleBigTenguTsuwamonoEnemy: 'enemyLittleBigTenguTsuwamonoEnemy',
  Trait.eventSaberWars: 'eventSaberWars',
  Trait.eventRashomon: 'eventRashomon',
  Trait.eventOnigashima: 'eventOnigashima',
  Trait.eventOnigashimaRaid: 'eventOnigashimaRaid',
  Trait.eventPrisma: 'eventPrisma',
  Trait.eventPrismaWorldEndMatch: 'eventPrismaWorldEndMatch',
  Trait.eventNeroFest2: 'eventNeroFest2',
  Trait.eventGuda2: 'eventGuda2',
  Trait.eventNeroFest3: 'eventNeroFest3',
  Trait.eventSetsubun: 'eventSetsubun',
  Trait.eventApocrypha: 'eventApocrypha',
  Trait.eventBattleInNewYork1: 'eventBattleInNewYork1',
  Trait.eventOniland: 'eventOniland',
  Trait.eventOoku: 'eventOoku',
  Trait.eventGuda4: 'eventGuda4',
  Trait.eventLasVegas: 'eventLasVegas',
  Trait.eventBattleInNewYork2: 'eventBattleInNewYork2',
  Trait.eventSaberWarsII: 'eventSaberWarsII',
  Trait.eventSummerCamp: 'eventSummerCamp',
  Trait.eventGuda5: 'eventGuda5',
  Trait.cursedBook: 'cursedBook',
  Trait.buffCharmFemale: 'buffCharmFemale',
  Trait.mechanical: 'mechanical',
  Trait.fae: 'fae',
  Trait.hasCostume: 'hasCostume',
  Trait.weakPointsRevealed: 'weakPointsRevealed',
  Trait.chenGongNpBlock: 'chenGongNpBlock',
  Trait.knightsOfTheRound: 'knightsOfTheRound',
  Trait.divineSpirit: 'divineSpirit',
  Trait.buffNullifyBuff: 'buffNullifyBuff',
  Trait.enemyGudaMiniNobu: 'enemyGudaMiniNobu',
  Trait.burningLove: 'burningLove',
  Trait.buffStrongAgainstWildBeast: 'buffStrongAgainstWildBeast',
  Trait.buffStrongAgainstDragon: 'buffStrongAgainstDragon',
  Trait.fairyTaleServant: 'fairyTaleServant',
  Trait.classBeastIV: 'classBeastIV',
  Trait.havingAnimalsCharacteristics: 'havingAnimalsCharacteristics',
};

BuffRelationOverwrite _$BuffRelationOverwriteFromJson(Map json) =>
    BuffRelationOverwrite(
      atkSide: (json['atkSide'] as Map).map(
        (k, e) => MapEntry(
            $enumDecode(_$SvtClassEnumMap, k),
            (e as Map).map(
              (k, e) => MapEntry($enumDecode(_$SvtClassEnumMap, k), e),
            )),
      ),
      defSide: (json['defSide'] as Map).map(
        (k, e) => MapEntry(
            $enumDecode(_$SvtClassEnumMap, k),
            (e as Map).map(
              (k, e) => MapEntry($enumDecode(_$SvtClassEnumMap, k), e),
            )),
      ),
    );

BuffScript _$BuffScriptFromJson(Map json) => BuffScript(
      checkIndvType: json['checkIndvType'] as int?,
      CheckOpponentBuffTypes: (json['CheckOpponentBuffTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BuffTypeEnumMap, e))
          .toList(),
      relationId: json['relationId'] == null
          ? null
          : BuffRelationOverwrite.fromJson(
              Map<String, dynamic>.from(json['relationId'] as Map)),
      ReleaseText: json['ReleaseText'] as String?,
      DamageRelease: json['DamageRelease'] as int?,
      INDIVIDUALITIE: json['INDIVIDUALITIE'] == null
          ? null
          : NiceTrait.fromJson(
              Map<String, dynamic>.from(json['INDIVIDUALITIE'] as Map)),
      UpBuffRateBuffIndiv: (json['UpBuffRateBuffIndiv'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      HP_LOWER: json['HP_LOWER'] as int?,
    );

const _$BuffTypeEnumMap = {
  BuffType.none: 'none',
  BuffType.upCommandatk: 'upCommandatk',
  BuffType.upStarweight: 'upStarweight',
  BuffType.upCriticalpoint: 'upCriticalpoint',
  BuffType.downCriticalpoint: 'downCriticalpoint',
  BuffType.regainNp: 'regainNp',
  BuffType.regainStar: 'regainStar',
  BuffType.regainHp: 'regainHp',
  BuffType.reduceHp: 'reduceHp',
  BuffType.upAtk: 'upAtk',
  BuffType.downAtk: 'downAtk',
  BuffType.upDamage: 'upDamage',
  BuffType.downDamage: 'downDamage',
  BuffType.addDamage: 'addDamage',
  BuffType.subDamage: 'subDamage',
  BuffType.upNpdamage: 'upNpdamage',
  BuffType.downNpdamage: 'downNpdamage',
  BuffType.upDropnp: 'upDropnp',
  BuffType.upCriticaldamage: 'upCriticaldamage',
  BuffType.downCriticaldamage: 'downCriticaldamage',
  BuffType.upSelfdamage: 'upSelfdamage',
  BuffType.downSelfdamage: 'downSelfdamage',
  BuffType.addSelfdamage: 'addSelfdamage',
  BuffType.subSelfdamage: 'subSelfdamage',
  BuffType.avoidance: 'avoidance',
  BuffType.breakAvoidance: 'breakAvoidance',
  BuffType.invincible: 'invincible',
  BuffType.upGrantstate: 'upGrantstate',
  BuffType.downGrantstate: 'downGrantstate',
  BuffType.upTolerance: 'upTolerance',
  BuffType.downTolerance: 'downTolerance',
  BuffType.avoidState: 'avoidState',
  BuffType.donotAct: 'donotAct',
  BuffType.donotSkill: 'donotSkill',
  BuffType.donotNoble: 'donotNoble',
  BuffType.donotRecovery: 'donotRecovery',
  BuffType.disableGender: 'disableGender',
  BuffType.guts: 'guts',
  BuffType.upHate: 'upHate',
  BuffType.addIndividuality: 'addIndividuality',
  BuffType.subIndividuality: 'subIndividuality',
  BuffType.upDefence: 'upDefence',
  BuffType.downDefence: 'downDefence',
  BuffType.upCommandstar: 'upCommandstar',
  BuffType.upCommandnp: 'upCommandnp',
  BuffType.upCommandall: 'upCommandall',
  BuffType.downCommandall: 'downCommandall',
  BuffType.downStarweight: 'downStarweight',
  BuffType.reduceNp: 'reduceNp',
  BuffType.downDropnp: 'downDropnp',
  BuffType.upGainHp: 'upGainHp',
  BuffType.downGainHp: 'downGainHp',
  BuffType.downCommandatk: 'downCommandatk',
  BuffType.downCommanstar: 'downCommanstar',
  BuffType.downCommandnp: 'downCommandnp',
  BuffType.upCriticalrate: 'upCriticalrate',
  BuffType.downCriticalrate: 'downCriticalrate',
  BuffType.pierceInvincible: 'pierceInvincible',
  BuffType.avoidInstantdeath: 'avoidInstantdeath',
  BuffType.upResistInstantdeath: 'upResistInstantdeath',
  BuffType.upNonresistInstantdeath: 'upNonresistInstantdeath',
  BuffType.delayFunction: 'delayFunction',
  BuffType.regainNpUsedNoble: 'regainNpUsedNoble',
  BuffType.deadFunction: 'deadFunction',
  BuffType.upMaxhp: 'upMaxhp',
  BuffType.downMaxhp: 'downMaxhp',
  BuffType.addMaxhp: 'addMaxhp',
  BuffType.subMaxhp: 'subMaxhp',
  BuffType.battlestartFunction: 'battlestartFunction',
  BuffType.wavestartFunction: 'wavestartFunction',
  BuffType.selfturnendFunction: 'selfturnendFunction',
  BuffType.damageFunction: 'damageFunction',
  BuffType.upGivegainHp: 'upGivegainHp',
  BuffType.downGivegainHp: 'downGivegainHp',
  BuffType.commandattackFunction: 'commandattackFunction',
  BuffType.deadattackFunction: 'deadattackFunction',
  BuffType.upSpecialdefence: 'upSpecialdefence',
  BuffType.downSpecialdefence: 'downSpecialdefence',
  BuffType.upDamagedropnp: 'upDamagedropnp',
  BuffType.downDamagedropnp: 'downDamagedropnp',
  BuffType.entryFunction: 'entryFunction',
  BuffType.upChagetd: 'upChagetd',
  BuffType.reflectionFunction: 'reflectionFunction',
  BuffType.upGrantSubstate: 'upGrantSubstate',
  BuffType.downGrantSubstate: 'downGrantSubstate',
  BuffType.upToleranceSubstate: 'upToleranceSubstate',
  BuffType.downToleranceSubstate: 'downToleranceSubstate',
  BuffType.upGrantInstantdeath: 'upGrantInstantdeath',
  BuffType.downGrantInstantdeath: 'downGrantInstantdeath',
  BuffType.gutsRatio: 'gutsRatio',
  BuffType.upDefencecommandall: 'upDefencecommandall',
  BuffType.downDefencecommandall: 'downDefencecommandall',
  BuffType.overwriteBattleclass: 'overwriteBattleclass',
  BuffType.overwriteClassrelatioAtk: 'overwriteClassrelatioAtk',
  BuffType.overwriteClassrelatioDef: 'overwriteClassrelatioDef',
  BuffType.upDamageIndividuality: 'upDamageIndividuality',
  BuffType.downDamageIndividuality: 'downDamageIndividuality',
  BuffType.upDamageIndividualityActiveonly: 'upDamageIndividualityActiveonly',
  BuffType.downDamageIndividualityActiveonly:
      'downDamageIndividualityActiveonly',
  BuffType.upNpturnval: 'upNpturnval',
  BuffType.downNpturnval: 'downNpturnval',
  BuffType.multiattack: 'multiattack',
  BuffType.upGiveNp: 'upGiveNp',
  BuffType.downGiveNp: 'downGiveNp',
  BuffType.upResistanceDelayNpturn: 'upResistanceDelayNpturn',
  BuffType.downResistanceDelayNpturn: 'downResistanceDelayNpturn',
  BuffType.pierceDefence: 'pierceDefence',
  BuffType.upGutsHp: 'upGutsHp',
  BuffType.downGutsHp: 'downGutsHp',
  BuffType.upFuncgainNp: 'upFuncgainNp',
  BuffType.downFuncgainNp: 'downFuncgainNp',
  BuffType.upFuncHpReduce: 'upFuncHpReduce',
  BuffType.downFuncHpReduce: 'downFuncHpReduce',
  BuffType.upDefencecommanDamage: 'upDefencecommanDamage',
  BuffType.downDefencecommanDamage: 'downDefencecommanDamage',
  BuffType.npattackPrevBuff: 'npattackPrevBuff',
  BuffType.fixCommandcard: 'fixCommandcard',
  BuffType.donotGainnp: 'donotGainnp',
  BuffType.fieldIndividuality: 'fieldIndividuality',
  BuffType.donotActCommandtype: 'donotActCommandtype',
  BuffType.upDamageEventPoint: 'upDamageEventPoint',
  BuffType.upDamageSpecial: 'upDamageSpecial',
  BuffType.attackFunction: 'attackFunction',
  BuffType.commandcodeattackFunction: 'commandcodeattackFunction',
  BuffType.donotNobleCondMismatch: 'donotNobleCondMismatch',
  BuffType.donotSelectCommandcard: 'donotSelectCommandcard',
  BuffType.donotReplace: 'donotReplace',
  BuffType.shortenUserEquipSkill: 'shortenUserEquipSkill',
  BuffType.tdTypeChange: 'tdTypeChange',
  BuffType.overwriteClassRelation: 'overwriteClassRelation',
  BuffType.tdTypeChangeArts: 'tdTypeChangeArts',
  BuffType.tdTypeChangeBuster: 'tdTypeChangeBuster',
  BuffType.tdTypeChangeQuick: 'tdTypeChangeQuick',
  BuffType.commandattackBeforeFunction: 'commandattackBeforeFunction',
  BuffType.gutsFunction: 'gutsFunction',
  BuffType.upCriticalRateDamageTaken: 'upCriticalRateDamageTaken',
  BuffType.downCriticalRateDamageTaken: 'downCriticalRateDamageTaken',
  BuffType.upCriticalStarDamageTaken: 'upCriticalStarDamageTaken',
  BuffType.downCriticalStarDamageTaken: 'downCriticalStarDamageTaken',
  BuffType.skillRankUp: 'skillRankUp',
  BuffType.avoidanceIndividuality: 'avoidanceIndividuality',
  BuffType.changeCommandCardType: 'changeCommandCardType',
  BuffType.specialInvincible: 'specialInvincible',
  BuffType.preventDeathByDamage: 'preventDeathByDamage',
  BuffType.commandcodeattackAfterFunction: 'commandcodeattackAfterFunction',
  BuffType.attackBeforeFunction: 'attackBeforeFunction',
  BuffType.donotSkillSelect: 'donotSkillSelect',
  BuffType.buffRate: 'buffRate',
  BuffType.invisibleBattleChara: 'invisibleBattleChara',
};

MasterMission _$MasterMissionFromJson(Map json) => MasterMission(
      id: json['id'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      closedAt: json['closedAt'] as int,
      missions: (json['missions'] as List<dynamic>)
          .map(
              (e) => EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      quests: json['quests'] as List<dynamic>,
    );

BgmRelease _$BgmReleaseFromJson(Map json) => BgmRelease(
      id: json['id'] as int,
      type: $enumDecode(_$CondTypeEnumMap, json['type']),
      condGroup: json['condGroup'] as int,
      targetIds:
          (json['targetIds'] as List<dynamic>).map((e) => e as int).toList(),
      vals: (json['vals'] as List<dynamic>).map((e) => e as int).toList(),
      priority: json['priority'] as int,
      closedMessage: json['closedMessage'] as String,
    );

const _$CondTypeEnumMap = {
  CondType.none: 'none',
  CondType.questClear: 'questClear',
  CondType.itemGet: 'itemGet',
  CondType.useItemEternity: 'useItemEternity',
  CondType.useItemTime: 'useItemTime',
  CondType.useItemCount: 'useItemCount',
  CondType.svtLevel: 'svtLevel',
  CondType.svtLimit: 'svtLimit',
  CondType.svtGet: 'svtGet',
  CondType.svtFriendship: 'svtFriendship',
  CondType.svtGroup: 'svtGroup',
  CondType.event: 'event',
  CondType.date: 'date',
  CondType.weekday: 'weekday',
  CondType.purchaseQpShop: 'purchaseQpShop',
  CondType.purchaseStoneShop: 'purchaseStoneShop',
  CondType.warClear: 'warClear',
  CondType.flag: 'flag',
  CondType.svtCountStop: 'svtCountStop',
  CondType.birthDay: 'birthDay',
  CondType.eventEnd: 'eventEnd',
  CondType.svtEventJoin: 'svtEventJoin',
  CondType.missionConditionDetail: 'missionConditionDetail',
  CondType.eventMissionClear: 'eventMissionClear',
  CondType.eventMissionAchieve: 'eventMissionAchieve',
  CondType.questClearNum: 'questClearNum',
  CondType.notQuestGroupClear: 'notQuestGroupClear',
  CondType.raidAlive: 'raidAlive',
  CondType.raidDead: 'raidDead',
  CondType.raidDamage: 'raidDamage',
  CondType.questChallengeNum: 'questChallengeNum',
  CondType.masterMission: 'masterMission',
  CondType.questGroupClear: 'questGroupClear',
  CondType.superBossDamage: 'superBossDamage',
  CondType.superBossDamageAll: 'superBossDamageAll',
  CondType.purchaseShop: 'purchaseShop',
  CondType.questNotClear: 'questNotClear',
  CondType.notShopPurchase: 'notShopPurchase',
  CondType.notSvtGet: 'notSvtGet',
  CondType.notEventShopPurchase: 'notEventShopPurchase',
  CondType.svtHaving: 'svtHaving',
  CondType.notSvtHaving: 'notSvtHaving',
  CondType.questChallengeNumEqual: 'questChallengeNumEqual',
  CondType.questChallengeNumBelow: 'questChallengeNumBelow',
  CondType.questClearNumEqual: 'questClearNumEqual',
  CondType.questClearNumBelow: 'questClearNumBelow',
  CondType.questClearPhase: 'questClearPhase',
  CondType.notQuestClearPhase: 'notQuestClearPhase',
  CondType.eventPointGroupWin: 'eventPointGroupWin',
  CondType.eventNormaPointClear: 'eventNormaPointClear',
  CondType.questAvailable: 'questAvailable',
  CondType.questGroupAvailableNum: 'questGroupAvailableNum',
  CondType.eventNormaPointNotClear: 'eventNormaPointNotClear',
  CondType.notItemGet: 'notItemGet',
  CondType.costumeGet: 'costumeGet',
  CondType.questResetAvailable: 'questResetAvailable',
  CondType.svtGetBeforeEventEnd: 'svtGetBeforeEventEnd',
  CondType.questClearRaw: 'questClearRaw',
  CondType.questGroupClearRaw: 'questGroupClearRaw',
  CondType.eventGroupPointRatioInTerm: 'eventGroupPointRatioInTerm',
  CondType.eventGroupRankInTerm: 'eventGroupRankInTerm',
  CondType.notEventRaceQuestOrNotAllGroupGoal:
      'notEventRaceQuestOrNotAllGroupGoal',
  CondType.eventGroupTotalWinEachPlayer: 'eventGroupTotalWinEachPlayer',
  CondType.eventScriptPlay: 'eventScriptPlay',
  CondType.svtCostumeReleased: 'svtCostumeReleased',
  CondType.questNotClearAnd: 'questNotClearAnd',
  CondType.svtRecoverd: 'svtRecoverd',
  CondType.shopReleased: 'shopReleased',
  CondType.eventPoint: 'eventPoint',
  CondType.eventRewardDispCount: 'eventRewardDispCount',
  CondType.equipWithTargetCostume: 'equipWithTargetCostume',
  CondType.raidGroupDead: 'raidGroupDead',
  CondType.notSvtGroup: 'notSvtGroup',
  CondType.notQuestResetAvailable: 'notQuestResetAvailable',
  CondType.notQuestClearRaw: 'notQuestClearRaw',
  CondType.notQuestGroupClearRaw: 'notQuestGroupClearRaw',
  CondType.notEventMissionClear: 'notEventMissionClear',
  CondType.notEventMissionAchieve: 'notEventMissionAchieve',
  CondType.notCostumeGet: 'notCostumeGet',
  CondType.notSvtCostumeReleased: 'notSvtCostumeReleased',
  CondType.notEventRaceQuestOrNotTargetRankGoal:
      'notEventRaceQuestOrNotTargetRankGoal',
  CondType.playerGenderType: 'playerGenderType',
  CondType.shopGroupLimitNum: 'shopGroupLimitNum',
  CondType.eventGroupPoint: 'eventGroupPoint',
  CondType.eventGroupPointBelow: 'eventGroupPointBelow',
  CondType.eventTotalPoint: 'eventTotalPoint',
  CondType.eventTotalPointBelow: 'eventTotalPointBelow',
  CondType.eventValue: 'eventValue',
  CondType.eventValueBelow: 'eventValueBelow',
  CondType.eventFlag: 'eventFlag',
  CondType.eventStatus: 'eventStatus',
  CondType.notEventStatus: 'notEventStatus',
  CondType.forceFalse: 'forceFalse',
  CondType.svtHavingLimitMax: 'svtHavingLimitMax',
  CondType.eventPointBelow: 'eventPointBelow',
  CondType.svtEquipFriendshipHaving: 'svtEquipFriendshipHaving',
  CondType.movieNotDownload: 'movieNotDownload',
  CondType.multipleDate: 'multipleDate',
  CondType.svtFriendshipAbove: 'svtFriendshipAbove',
  CondType.svtFriendshipBelow: 'svtFriendshipBelow',
  CondType.movieDownloaded: 'movieDownloaded',
  CondType.routeSelect: 'routeSelect',
  CondType.notRouteSelect: 'notRouteSelect',
  CondType.limitCount: 'limitCount',
  CondType.limitCountAbove: 'limitCountAbove',
  CondType.limitCountBelow: 'limitCountBelow',
  CondType.badEndPlay: 'badEndPlay',
  CondType.commandCodeGet: 'commandCodeGet',
  CondType.notCommandCodeGet: 'notCommandCodeGet',
  CondType.allUsersBoxGachaCount: 'allUsersBoxGachaCount',
  CondType.totalTdLevel: 'totalTdLevel',
  CondType.totalTdLevelAbove: 'totalTdLevelAbove',
  CondType.totalTdLevelBelow: 'totalTdLevelBelow',
  CondType.commonRelease: 'commonRelease',
  CondType.battleResultWin: 'battleResultWin',
  CondType.battleResultLose: 'battleResultLose',
  CondType.eventValueEqual: 'eventValueEqual',
  CondType.boardGameTokenHaving: 'boardGameTokenHaving',
  CondType.boardGameTokenGroupHaving: 'boardGameTokenGroupHaving',
  CondType.eventFlagOn: 'eventFlagOn',
  CondType.eventFlagOff: 'eventFlagOff',
  CondType.questStatusFlagOn: 'questStatusFlagOn',
  CondType.questStatusFlagOff: 'questStatusFlagOff',
  CondType.eventValueNotEqual: 'eventValueNotEqual',
  CondType.limitCountMaxEqual: 'limitCountMaxEqual',
  CondType.limitCountMaxAbove: 'limitCountMaxAbove',
  CondType.limitCountMaxBelow: 'limitCountMaxBelow',
  CondType.boardGameTokenGetNum: 'boardGameTokenGetNum',
  CondType.battleLineWinAbove: 'battleLineWinAbove',
  CondType.battleLineLoseAbove: 'battleLineLoseAbove',
  CondType.battleLineContinueWin: 'battleLineContinueWin',
  CondType.battleLineContinueLose: 'battleLineContinueLose',
  CondType.battleLineContinueWinBelow: 'battleLineContinueWinBelow',
  CondType.battleLineContinueLoseBelow: 'battleLineContinueLoseBelow',
  CondType.battleGroupWinAvove: 'battleGroupWinAvove',
  CondType.battleGroupLoseAvove: 'battleGroupLoseAvove',
  CondType.svtLimitClassNum: 'svtLimitClassNum',
  CondType.overTimeLimitRaidAlive: 'overTimeLimitRaidAlive',
  CondType.onTimeLimitRaidDead: 'onTimeLimitRaidDead',
  CondType.onTimeLimitRaidDeadNum: 'onTimeLimitRaidDeadNum',
  CondType.raidBattleProgressAbove: 'raidBattleProgressAbove',
  CondType.svtEquipRarityLevelNum: 'svtEquipRarityLevelNum',
  CondType.latestMainScenarioWarClear: 'latestMainScenarioWarClear',
  CondType.eventMapValueContains: 'eventMapValueContains',
  CondType.resetBirthDay: 'resetBirthDay',
  CondType.shopFlagOn: 'shopFlagOn',
  CondType.shopFlagOff: 'shopFlagOff',
  CondType.purchaseValidShopGroup: 'purchaseValidShopGroup',
  CondType.svtLevelClassNum: 'svtLevelClassNum',
  CondType.svtLevelIdNum: 'svtLevelIdNum',
  CondType.limitCountImageEqual: 'limitCountImageEqual',
  CondType.limitCountImageAbove: 'limitCountImageAbove',
  CondType.limitCountImageBelow: 'limitCountImageBelow',
  CondType.eventTypeStartTimeToEndDate: 'eventTypeStartTimeToEndDate',
  CondType.existBoxGachaScriptReplaceGiftId: 'existBoxGachaScriptReplaceGiftId',
  CondType.notExistBoxGachaScriptReplaceGiftId:
      'notExistBoxGachaScriptReplaceGiftId',
  CondType.limitedPeriodVoiceChangeTypeOn: 'limitedPeriodVoiceChangeTypeOn',
  CondType.startRandomMission: 'startRandomMission',
  CondType.randomMissionClearNum: 'randomMissionClearNum',
  CondType.progressValueEqual: 'progressValueEqual',
  CondType.progressValueAbove: 'progressValueAbove',
  CondType.progressValueBelow: 'progressValueBelow',
  CondType.randomMissionTotalClearNum: 'randomMissionTotalClearNum',
};

BgmEnitity _$BgmEnitityFromJson(Map json) => BgmEnitity(
      id: json['id'] as int,
      name: json['name'] as String,
      fileName: json['fileName'] as String,
      audioAsset: json['audioAsset'] as String?,
      priority: json['priority'] as int,
      detail: json['detail'] as String,
      notReleased: json['notReleased'] as bool,
      shop: json['shop'] == null
          ? null
          : NiceShop.fromJson(Map<String, dynamic>.from(json['shop'] as Map)),
      logo: json['logo'] as String,
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map((e) => BgmRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Bgm _$BgmFromJson(Map json) => Bgm(
      id: json['id'] as int,
      name: json['name'] as String,
      fileName: json['fileName'] as String,
      notReleased: json['notReleased'] as bool,
      audioAsset: json['audioAsset'] as String?,
    );

CraftEssence _$CraftEssenceFromJson(Map json) => CraftEssence(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      cost: json['cost'] as int,
      lvMax: json['lvMax'] as int,
      extraAssets: ExtraAssets.fromJson(
          Map<String, dynamic>.from(json['extraAssets'] as Map)),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      growthCurve: json['growthCurve'] as int,
      atkGrowth:
          (json['atkGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      hpGrowth:
          (json['hpGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      expGrowth:
          (json['expGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      expFeed: (json['expFeed'] as List<dynamic>).map((e) => e as int).toList(),
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      valentineScript: (json['valentineScript'] as List<dynamic>)
          .map((e) =>
              ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      ascensionAdd: AscensionAdd.fromJson(
          Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      profile: json['profile'] == null
          ? null
          : NiceLore.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map)),
    );

const _$SvtTypeEnumMap = {
  SvtType.normal: 'normal',
  SvtType.heroine: 'heroine',
  SvtType.combineMaterial: 'combineMaterial',
  SvtType.enemy: 'enemy',
  SvtType.enemyCollection: 'enemyCollection',
  SvtType.servantEquip: 'servantEquip',
  SvtType.statusUp: 'statusUp',
  SvtType.svtEquipMaterial: 'svtEquipMaterial',
  SvtType.enemyCollectionDetail: 'enemyCollectionDetail',
  SvtType.all: 'all',
  SvtType.commandCode: 'commandCode',
  SvtType.svtMaterialTd: 'svtMaterialTd',
};

const _$SvtFlagEnumMap = {
  SvtFlag.onlyUseForNpc: 'onlyUseForNpc',
  SvtFlag.svtEquipFriendShip: 'svtEquipFriendShip',
  SvtFlag.ignoreCombineLimitSpecial: 'ignoreCombineLimitSpecial',
  SvtFlag.svtEquipExp: 'svtEquipExp',
  SvtFlag.svtEquipChocolate: 'svtEquipChocolate',
  SvtFlag.normal: 'normal',
  SvtFlag.goetia: 'goetia',
};

ItemSet _$ItemSetFromJson(Map json) => ItemSet(
      id: json['id'] as int,
      purchaseType: $enumDecode(_$PurchaseTypeEnumMap, json['purchaseType']),
      targetId: json['targetId'] as int,
      setNum: json['setNum'] as int,
    );

const _$PurchaseTypeEnumMap = {
  PurchaseType.none: 'none',
  PurchaseType.item: 'item',
  PurchaseType.equip: 'equip',
  PurchaseType.friendGacha: 'friendGacha',
  PurchaseType.servant: 'servant',
  PurchaseType.setItem: 'setItem',
  PurchaseType.quest: 'quest',
  PurchaseType.eventShop: 'eventShop',
  PurchaseType.eventSvtGet: 'eventSvtGet',
  PurchaseType.manaShop: 'manaShop',
  PurchaseType.storageSvt: 'storageSvt',
  PurchaseType.storageSvtequip: 'storageSvtequip',
  PurchaseType.bgm: 'bgm',
  PurchaseType.costumeRelease: 'costumeRelease',
  PurchaseType.bgmRelease: 'bgmRelease',
  PurchaseType.lotteryShop: 'lotteryShop',
  PurchaseType.eventFactory: 'eventFactory',
  PurchaseType.itemAsPresent: 'itemAsPresent',
  PurchaseType.commandCode: 'commandCode',
  PurchaseType.gift: 'gift',
  PurchaseType.eventSvtJoin: 'eventSvtJoin',
  PurchaseType.assist: 'assist',
  PurchaseType.kiaraPunisherReset: 'kiaraPunisherReset',
};

NiceShop _$NiceShopFromJson(Map json) => NiceShop(
      id: json['id'] as int,
      baseShopId: json['baseShopId'] as int,
      shopType: $enumDecode(_$ShopTypeEnumMap, json['shopType']),
      eventId: json['eventId'] as int,
      slot: json['slot'] as int,
      priority: json['priority'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      infoMessage: json['infoMessage'] as String,
      warningMessage: json['warningMessage'] as String,
      payType: $enumDecode(_$PayTypeEnumMap, json['payType']),
      cost: ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      purchaseType: $enumDecode(_$PurchaseTypeEnumMap, json['purchaseType']),
      targetIds:
          (json['targetIds'] as List<dynamic>).map((e) => e as int).toList(),
      itemSet: (json['itemSet'] as List<dynamic>)
          .map((e) => ItemSet.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      setNum: json['setNum'] as int,
      limitNum: json['limitNum'] as int,
      defaultLv: json['defaultLv'] as int,
      defaultLimitCount: json['defaultLimitCount'] as int,
      scriptName: json['scriptName'] as String?,
      script: json['script'] as String?,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
    );

const _$ShopTypeEnumMap = {
  ShopType.none: 'none',
  ShopType.eventItem: 'eventItem',
  ShopType.mana: 'mana',
  ShopType.rarePri: 'rarePri',
  ShopType.svtStorage: 'svtStorage',
  ShopType.svtEquipStorage: 'svtEquipStorage',
  ShopType.stoneFragments: 'stoneFragments',
  ShopType.svtAnonymous: 'svtAnonymous',
  ShopType.bgm: 'bgm',
  ShopType.limitMaterial: 'limitMaterial',
  ShopType.grailFragments: 'grailFragments',
  ShopType.svtCostume: 'svtCostume',
  ShopType.startUpSummon: 'startUpSummon',
};

const _$PayTypeEnumMap = {
  PayType.stone: 'stone',
  PayType.qp: 'qp',
  PayType.friendPoint: 'friendPoint',
  PayType.mana: 'mana',
  PayType.ticket: 'ticket',
  PayType.eventItem: 'eventItem',
  PayType.chargeStone: 'chargeStone',
  PayType.stoneFragments: 'stoneFragments',
  PayType.anonymous: 'anonymous',
  PayType.rarePri: 'rarePri',
  PayType.item: 'item',
  PayType.grailFragments: 'grailFragments',
  PayType.free: 'free',
};

Gift _$GiftFromJson(Map json) => Gift(
      id: json['id'] as int,
      type: $enumDecode(_$GiftTypeEnumMap, json['type']),
      objectId: json['objectId'] as int,
      priority: json['priority'] as int,
      num: json['num'] as int,
    );

const _$GiftTypeEnumMap = {
  GiftType.servant: 'servant',
  GiftType.item: 'item',
  GiftType.friendship: 'friendship',
  GiftType.userExp: 'userExp',
  GiftType.equip: 'equip',
  GiftType.eventSvtJoin: 'eventSvtJoin',
  GiftType.eventSvtGet: 'eventSvtGet',
  GiftType.questRewardIcon: 'questRewardIcon',
  GiftType.costumeRelease: 'costumeRelease',
  GiftType.costumeGet: 'costumeGet',
  GiftType.commandCode: 'commandCode',
  GiftType.eventPointBuff: 'eventPointBuff',
  GiftType.eventBoardGameToken: 'eventBoardGameToken',
};

EventReward _$EventRewardFromJson(Map json) => EventReward(
      groupId: json['groupId'] as int,
      point: json['point'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bgImagePoint: json['bgImagePoint'] as String,
      bgImageGet: json['bgImageGet'] as String,
    );

EventPointGroup _$EventPointGroupFromJson(Map json) => EventPointGroup(
      groupId: json['groupId'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );

EventPointBuff _$EventPointBuffFromJson(Map json) => EventPointBuff(
      id: json['id'] as int,
      funcIds: (json['funcIds'] as List<dynamic>).map((e) => e as int).toList(),
      groupId: json['groupId'] as int,
      eventPoint: json['eventPoint'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      icon: json['icon'] as String,
      background: $enumDecode(_$ItemBGTypeEnumMap, json['background']),
      value: json['value'] as int,
    );

const _$ItemBGTypeEnumMap = {
  ItemBGType.zero: 'zero',
  ItemBGType.bronze: 'bronze',
  ItemBGType.silver: 'silver',
  ItemBGType.gold: 'gold',
  ItemBGType.questClearQPReward: 'questClearQPReward',
};

EventMissionConditionDetail _$EventMissionConditionDetailFromJson(Map json) =>
    EventMissionConditionDetail(
      id: json['id'] as int,
      missionTargetId: json['missionTargetId'] as int,
      missionCondType: json['missionCondType'] as int,
      logicType: json['logicType'] as int,
      targetIds:
          (json['targetIds'] as List<dynamic>).map((e) => e as int).toList(),
      addTargetIds:
          (json['addTargetIds'] as List<dynamic>).map((e) => e as int).toList(),
      targetQuestIndividualities: (json['targetQuestIndividualities']
              as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      conditionLinkType: $enumDecode(
          _$DetailMissionCondLinkTypeEnumMap, json['conditionLinkType']),
      targetEventIds: (json['targetEventIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );

const _$DetailMissionCondLinkTypeEnumMap = {
  DetailMissionCondLinkType.eventStart: 'eventStart',
  DetailMissionCondLinkType.missionStart: 'missionStart',
  DetailMissionCondLinkType.masterMissionStart: 'masterMissionStart',
  DetailMissionCondLinkType.randomMissionStart: 'randomMissionStart',
};

EventMissionCondition _$EventMissionConditionFromJson(Map json) =>
    EventMissionCondition(
      id: json['id'] as int,
      missionProgressType: $enumDecode(
          _$MissionProgressTypeEnumMap, json['missionProgressType']),
      priority: json['priority'] as int,
      missionTargetId: json['missionTargetId'] as int,
      condGroup: json['condGroup'] as int,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      targetIds:
          (json['targetIds'] as List<dynamic>).map((e) => e as int).toList(),
      targetNum: json['targetNum'] as int,
      conditionMessage: json['conditionMessage'] as String,
      closedMessage: json['closedMessage'] as String,
      flag: json['flag'] as int,
      detail: json['detail'] == null
          ? null
          : EventMissionConditionDetail.fromJson(
              Map<String, dynamic>.from(json['detail'] as Map)),
    );

const _$MissionProgressTypeEnumMap = {
  MissionProgressType.none: 'none',
  MissionProgressType.regist: 'regist',
  MissionProgressType.openCondition: 'openCondition',
  MissionProgressType.start: 'start',
  MissionProgressType.clear: 'clear',
  MissionProgressType.achieve: 'achieve',
};

EventMission _$EventMissionFromJson(Map json) => EventMission(
      id: json['id'] as int,
      flag: json['flag'] as int,
      type: $enumDecode(_$MissionTypeEnumMap, json['type']),
      missionTargetId: json['missionTargetId'] as int,
      dispNo: json['dispNo'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      closedAt: json['closedAt'] as int,
      rewardType: $enumDecode(_$MissionRewardTypeEnumMap, json['rewardType']),
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bannerGroup: json['bannerGroup'] as int,
      priority: json['priority'] as int,
      rewardRarity: json['rewardRarity'] as int,
      notfyPriority: json['notfyPriority'] as int,
      presentMessageId: json['presentMessageId'] as int,
      conds: (json['conds'] as List<dynamic>)
          .map((e) => EventMissionCondition.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$MissionTypeEnumMap = {
  MissionType.none: 'none',
  MissionType.event: 'event',
  MissionType.weekly: 'weekly',
  MissionType.daily: 'daily',
  MissionType.extra: 'extra',
  MissionType.limited: 'limited',
  MissionType.complete: 'complete',
  MissionType.random: 'random',
};

const _$MissionRewardTypeEnumMap = {
  MissionRewardType.gift: 'gift',
  MissionRewardType.extra: 'extra',
  MissionRewardType.set: 'set',
};

EventTowerReward _$EventTowerRewardFromJson(Map json) => EventTowerReward(
      floor: json['floor'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      boardMessage: json['boardMessage'] as String,
      rewardGet: json['rewardGet'] as String,
      banner: json['banner'] as String,
    );

EventTower _$EventTowerFromJson(Map json) => EventTower(
      towerId: json['towerId'] as int,
      name: json['name'] as String,
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) =>
              EventTowerReward.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EventLotteryBox _$EventLotteryBoxFromJson(Map json) => EventLotteryBox(
      id: json['id'] as int,
      boxIndex: json['boxIndex'] as int,
      no: json['no'] as int,
      type: json['type'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      maxNum: json['maxNum'] as int,
      isRare: json['isRare'] as bool,
      priority: json['priority'] as int,
      detail: json['detail'] as String,
      icon: json['icon'] as String,
      banner: json['banner'] as String,
    );

EventLottery _$EventLotteryFromJson(Map json) => EventLottery(
      id: json['id'] as int,
      slot: json['slot'] as int,
      payType: $enumDecode(_$PayTypeEnumMap, json['payType']),
      cost: ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      priority: json['priority'] as int,
      limited: json['limited'] as bool,
      boxes: (json['boxes'] as List<dynamic>)
          .map((e) =>
              EventLotteryBox.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

CommonConsume _$CommonConsumeFromJson(Map json) => CommonConsume(
      id: json['id'] as int,
      priority: json['priority'] as int,
      type: $enumDecode(_$CommonConsumeTypeEnumMap, json['type']),
      objectId: json['objectId'] as int,
      num: json['num'] as int,
    );

const _$CommonConsumeTypeEnumMap = {
  CommonConsumeType.item: 'item',
};

EventTreasureBoxGift _$EventTreasureBoxGiftFromJson(Map json) =>
    EventTreasureBoxGift(
      id: json['id'] as int,
      idx: json['idx'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      collateralUpperLimit: json['collateralUpperLimit'] as int,
    );

EventTreasureBox _$EventTreasureBoxFromJson(Map json) => EventTreasureBox(
      slot: json['slot'] as int,
      id: json['id'] as int,
      idx: json['idx'] as int,
      treasureBoxGifts: (json['treasureBoxGifts'] as List<dynamic>)
          .map((e) => EventTreasureBoxGift.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      maxDrawNumOnce: json['maxDrawNumOnce'] as int,
      extraGifts: (json['extraGifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      commonConsume: CommonConsume.fromJson(
          Map<String, dynamic>.from(json['commonConsume'] as Map)),
    );

Event _$EventFromJson(Map json) => Event(
      id: json['id'] as int,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      detail: json['detail'] as String,
      noticeBanner: json['noticeBanner'] as String?,
      banner: json['banner'] as String?,
      icon: json['icon'] as String?,
      bannerPriority: json['bannerPriority'] as int,
      noticeAt: json['noticeAt'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      finishedAt: json['finishedAt'] as int,
      materialOpenedAt: json['materialOpenedAt'] as int,
      warIds: (json['warIds'] as List<dynamic>).map((e) => e as int).toList(),
      shop: (json['shop'] as List<dynamic>)
          .map((e) => NiceShop.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) => EventReward.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pointGroups: (json['pointGroups'] as List<dynamic>)
          .map((e) =>
              EventPointGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pointBuffs: (json['pointBuffs'] as List<dynamic>)
          .map((e) =>
              EventPointBuff.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      missions: (json['missions'] as List<dynamic>)
          .map(
              (e) => EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      towers: (json['towers'] as List<dynamic>)
          .map((e) => EventTower.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      lotteries: (json['lotteries'] as List<dynamic>)
          .map(
              (e) => EventLottery.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      treasureBoxes: (json['treasureBoxes'] as List<dynamic>)
          .map((e) =>
              EventTreasureBox.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$EventTypeEnumMap = {
  EventType.none: 'none',
  EventType.raidBoss: 'raidBoss',
  EventType.pvp: 'pvp',
  EventType.point: 'point',
  EventType.loginBonus: 'loginBonus',
  EventType.combineCampaign: 'combineCampaign',
  EventType.shop: 'shop',
  EventType.questCampaign: 'questCampaign',
  EventType.bank: 'bank',
  EventType.serialCampaign: 'serialCampaign',
  EventType.loginCampaign: 'loginCampaign',
  EventType.loginCampaignRepeat: 'loginCampaignRepeat',
  EventType.eventQuest: 'eventQuest',
  EventType.svtequipCombineCampaign: 'svtequipCombineCampaign',
  EventType.terminalBanner: 'terminalBanner',
  EventType.boxGacha: 'boxGacha',
  EventType.boxGachaPoint: 'boxGachaPoint',
  EventType.loginCampaignStrict: 'loginCampaignStrict',
  EventType.totalLogin: 'totalLogin',
  EventType.comebackCampaign: 'comebackCampaign',
  EventType.locationCampaign: 'locationCampaign',
  EventType.warBoard: 'warBoard',
  EventType.combineCosutumeItem: 'combineCosutumeItem',
  EventType.treasureBox: 'treasureBox',
};

ExtraData _$ExtraDataFromJson(Map json) => ExtraData(
      servants: (json['servants'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                ServantExtra.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      craftEssences: (json['craftEssences'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                CraftEssenceExtra.fromJson(
                    Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      commandCodes: (json['commandCodes'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                CommandCodeExtra.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      events: (json['events'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                EventExtra.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      summons: (json['summons'] as Map?)?.map(
            (k, e) => MapEntry(k as String,
                LimitedSummon.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

ServantExtra _$ServantExtraFromJson(Map json) => ServantExtra(
      collectionNo: json['collectionNo'] as int,
      nameOther:
          (json['nameOther'] as List<dynamic>).map((e) => e as String).toList(),
      obtains: (json['obtains'] as List<dynamic>)
          .map((e) => $enumDecode(_$SvtObtainEnumMap, e))
          .toList(),
      aprilFoolAssets: (json['aprilFoolAssets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aprilFoolProfile: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['aprilFoolProfile'] as Map)),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

const _$SvtObtainEnumMap = {
  SvtObtain.friendPoint: 'friendPoint',
  SvtObtain.story: 'story',
  SvtObtain.permanent: 'permanent',
  SvtObtain.heroine: 'heroine',
  SvtObtain.limited: 'limited',
  SvtObtain.unavailable: 'unavailable',
  SvtObtain.eventReward: 'eventReward',
  SvtObtain.clearReward: 'clearReward',
  SvtObtain.unknown: 'unknown',
};

CraftEssenceExtra _$CraftEssenceExtraFromJson(Map json) => CraftEssenceExtra(
      collectionNo: json['collectionNo'] as int,
      type: $enumDecode(_$CETypeEnumMap, json['type']),
      profile: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['profile'] as Map)),
      characters:
          (json['characters'] as List<dynamic>).map((e) => e as int).toList(),
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

const _$CETypeEnumMap = {
  CEType.exp: 'exp',
  CEType.shop: 'shop',
  CEType.story: 'story',
  CEType.permanent: 'permanent',
  CEType.valentine: 'valentine',
  CEType.limited: 'limited',
  CEType.eventReward: 'eventReward',
  CEType.campaign: 'campaign',
  CEType.bond: 'bond',
  CEType.unknown: 'unknown',
};

CommandCodeExtra _$CommandCodeExtraFromJson(Map json) => CommandCodeExtra(
      collectionNo: json['collectionNo'] as int,
      profile: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['profile'] as Map)),
      characters:
          (json['characters'] as List<dynamic>).map((e) => e as int).toList(),
      unknownCharacters: (json['unknownCharacters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
    );

EventExtraItems _$EventExtraItemsFromJson(Map json) => EventExtraItems(
      id: json['id'] as int,
      detail: json['detail'] as String,
      items: (json['items'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
    );

EventExtra _$EventExtraFromJson(Map json) => EventExtra(
      id: json['id'] as int,
      name: json['name'] as String,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      titleBanner: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['titleBanner'] as Map)),
      noticeLink: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['noticeLink'] as Map)),
      huntingQuestIds: (json['huntingQuestIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      startTime: json['startTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: json['endTime'] == null
          ? null
          : MappingBase<int>.fromJson(
              Map<String, dynamic>.from(json['endTime'] as Map)),
      rarePrism: json['rarePrism'] as int,
      grail: json['grail'] as int,
      crystal: json['crystal'] as int,
      grail2crystal: json['grail2crystal'] as int,
      foukun4: json['foukun4'] as int,
      relatedSummons: (json['relatedSummons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

LimitedSummon _$LimitedSummonFromJson(Map json) => LimitedSummon(
      id: json['id'] as String,
      mcLink: json['mcLink'] as String?,
      fandomLink: json['fandomLink'] as String?,
      name: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['name'] as Map)),
      banner: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['banner'] as Map)),
      noticeLink: MappingBase<String>.fromJson(
          Map<String, dynamic>.from(json['noticeLink'] as Map)),
      startTime: MappingBase<int>.fromJson(
          Map<String, dynamic>.from(json['startTime'] as Map)),
      endTime: MappingBase<int>.fromJson(
          Map<String, dynamic>.from(json['endTime'] as Map)),
      type: $enumDecode(_$SummonTypeEnumMap, json['type']),
      rollCount: json['rollCount'] as int,
      subSummons: (json['subSummons'] as List<dynamic>)
          .map((e) => SubSummon.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$SummonTypeEnumMap = {
  SummonType.story: 'story',
  SummonType.limited: 'limited',
  SummonType.gssr: 'gssr',
  SummonType.gssrsr: 'gssrsr',
  SummonType.unknown: 'unknown',
};

SubSummon _$SubSummonFromJson(Map json) => SubSummon(
      title: json['title'] as String,
      probs: (json['probs'] as List<dynamic>)
          .map((e) => ProbGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

ProbGroup _$ProbGroupFromJson(Map json) => ProbGroup(
      isSvt: json['isSvt'] as bool,
      rarity: json['rarity'] as int,
      weight: (json['weight'] as num).toDouble(),
      display: json['display'] as bool,
      ids: (json['ids'] as List<dynamic>).map((e) => e as int).toList(),
    );

Item _$ItemFromJson(Map json) => Item(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$ItemTypeEnumMap, json['type']),
      uses: (json['uses'] as List<dynamic>)
          .map((e) => $enumDecode(_$ItemUseEnumMap, e))
          .toList(),
      detail: json['detail'] as String,
      individuality: (json['individuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      icon: json['icon'] as String,
      background: $enumDecode(_$ItemBGTypeEnumMap, json['background']),
      priority: json['priority'] as int,
      dropPriority: json['dropPriority'] as int,
    );

const _$ItemTypeEnumMap = {
  ItemType.qp: 'qp',
  ItemType.stone: 'stone',
  ItemType.apRecover: 'apRecover',
  ItemType.apAdd: 'apAdd',
  ItemType.mana: 'mana',
  ItemType.key: 'key',
  ItemType.gachaClass: 'gachaClass',
  ItemType.gachaRelic: 'gachaRelic',
  ItemType.gachaTicket: 'gachaTicket',
  ItemType.limit: 'limit',
  ItemType.skillLvUp: 'skillLvUp',
  ItemType.tdLvUp: 'tdLvUp',
  ItemType.friendPoint: 'friendPoint',
  ItemType.eventPoint: 'eventPoint',
  ItemType.eventItem: 'eventItem',
  ItemType.questRewardQp: 'questRewardQp',
  ItemType.chargeStone: 'chargeStone',
  ItemType.rpAdd: 'rpAdd',
  ItemType.boostItem: 'boostItem',
  ItemType.stoneFragments: 'stoneFragments',
  ItemType.anonymous: 'anonymous',
  ItemType.rarePri: 'rarePri',
  ItemType.costumeRelease: 'costumeRelease',
  ItemType.itemSelect: 'itemSelect',
  ItemType.commandCardPrmUp: 'commandCardPrmUp',
  ItemType.dice: 'dice',
  ItemType.continueItem: 'continueItem',
  ItemType.euqipSkillUseItem: 'euqipSkillUseItem',
  ItemType.svtCoin: 'svtCoin',
  ItemType.friendshipUpItem: 'friendshipUpItem',
};

const _$ItemUseEnumMap = {
  ItemUse.skill: 'skill',
  ItemUse.ascension: 'ascension',
  ItemUse.costume: 'costume',
};

ItemAmount _$ItemAmountFromJson(Map json) => ItemAmount(
      item: Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      amount: json['amount'] as int,
    );

LvlUpMaterial _$LvlUpMaterialFromJson(Map json) => LvlUpMaterial(
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      qp: json['qp'] as int,
    );

MCAssets _$MCAssetsFromJson(Map json) => MCAssets(
      male: json['male'] as String,
      female: json['female'] as String,
    );

ExtraMCAssets _$ExtraMCAssetsFromJson(Map json) => ExtraMCAssets(
      item: MCAssets.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      masterFace: MCAssets.fromJson(
          Map<String, dynamic>.from(json['masterFace'] as Map)),
      masterFigure: MCAssets.fromJson(
          Map<String, dynamic>.from(json['masterFigure'] as Map)),
    );

MysticCode _$MysticCodeFromJson(Map json) => MysticCode(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      extraAssets: ExtraMCAssets.fromJson(
          Map<String, dynamic>.from(json['extraAssets'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      expRequired:
          (json['expRequired'] as List<dynamic>).map((e) => e as int).toList(),
    );

QuestRelease _$QuestReleaseFromJson(Map json) => QuestRelease(
      type: $enumDecode(_$CondTypeEnumMap, json['type']),
      targetId: json['targetId'] as int,
      value: json['value'] as int,
      closedMessage: json['closedMessage'] as String,
    );

QuestPhaseScript _$QuestPhaseScriptFromJson(Map json) => QuestPhaseScript(
      phase: json['phase'] as int,
      scripts: (json['scripts'] as List<dynamic>)
          .map((e) => ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Quest _$QuestFromJson(Map json) => Quest(
  id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      consumeType: $enumDecode(_$ConsumeTypeEnumMap, json['consumeType']),
      consume: json['consume'] as int,
      consumeItem: (json['consumeItem'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      afterClear: $enumDecode(_$QuestAfterClearTypeEnumMap, json['afterClear']),
      recommendLv: json['recommendLv'] as String,
      spotId: json['spotId'] as int,
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String,
      chapterId: json['chapterId'] as int,
      chapterSubId: json['chapterSubId'] as int,
      chapterSubStr: json['chapterSubStr'] as String,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map(
              (e) => QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      phases: (json['phases'] as List<dynamic>).map((e) => e as int).toList(),
      phasesWithEnemies: (json['phasesWithEnemies'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      phaseScripts: (json['phaseScripts'] as List<dynamic>)
          .map((e) =>
              QuestPhaseScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
    );

const _$QuestTypeEnumMap = {
  QuestType.main: 'main',
  QuestType.free: 'free',
  QuestType.friendship: 'friendship',
  QuestType.event: 'event',
  QuestType.heroballad: 'heroballad',
  QuestType.warBoard: 'warBoard',
};

const _$ConsumeTypeEnumMap = {
  ConsumeType.none: 'none',
  ConsumeType.ap: 'ap',
  ConsumeType.rp: 'rp',
  ConsumeType.item: 'item',
  ConsumeType.apAndItem: 'apAndItem',
};

const _$QuestAfterClearTypeEnumMap = {
  QuestAfterClearType.close: 'close',
  QuestAfterClearType.repeatFirst: 'repeatFirst',
  QuestAfterClearType.repeatLast: 'repeatLast',
  QuestAfterClearType.resetInterval: 'resetInterval',
};

QuestMessage _$QuestMessageFromJson(Map json) => QuestMessage(
      idx: json['idx'] as int,
      message: json['message'] as String,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      targetId: json['targetId'] as int,
      targetNum: json['targetNum'] as int,
    );

BasicQuest _$BasicQuestFromJson(Map json) => BasicQuest(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      consumeType: $enumDecode(_$ConsumeTypeEnumMap, json['consumeType']),
      consume: json['consume'] as int,
      spotId: json['spotId'] as int,
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String,
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
    );

SupportServant _$SupportServantFromJson(Map json) => SupportServant(
      id: json['id'] as int,
      priority: json['priority'] as int,
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: json['lv'] as int,
      atk: json['atk'] as int,
      hp: json['hp'] as int,
      traits: (json['traits'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Stage _$StageFromJson(Map json) => Stage(
      wave: json['wave'] as int,
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      enemies: (json['enemies'] as List<dynamic>)
          .map((e) => QuestEnemy.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EnemyDrop _$EnemyDropFromJson(Map json) => EnemyDrop(
  type: $enumDecode(_$GiftTypeEnumMap, json['type']),
      objectId: json['objectId'] as int,
      num: json['num'] as int,
      dropCount: json['dropCount'] as int,
      runs: json['runs'] as int,
      dropExpected: (json['dropExpected'] as num).toDouble(),
      dropVariance: (json['dropVariance'] as num).toDouble(),
    );

QuestEnemy _$QuestEnemyFromJson(Map json) => QuestEnemy(
      deck: $enumDecode(_$DeckTypeEnumMap, json['deck']),
      deckId: json['deckId'] as int,
      userSvtId: json['userSvtId'] as int,
      uniqueId: json['uniqueId'] as int,
      npcId: json['npcId'] as int,
      roleType: $enumDecode(_$EnemyRoleTypeEnumMap, json['roleType']),
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      drops: (json['drops'] as List<dynamic>)
          .map((e) => EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      lv: json['lv'] as int,
      exp: json['exp'] as int,
      atk: json['atk'] as int,
      hp: json['hp'] as int,
      adjustAtk: json['adjustAtk'] as int,
      adjustHp: json['adjustHp'] as int,
      deathRate: json['deathRate'] as int,
      criticalRate: json['criticalRate'] as int,
      recover: json['recover'] as int,
      chargeTurn: json['chargeTurn'] as int,
      traits: (json['traits'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      classPassive: EnemyPassive.fromJson(
          Map<String, dynamic>.from(json['classPassive'] as Map)),
      serverMod: EnemyServerMod.fromJson(
          Map<String, dynamic>.from(json['serverMod'] as Map)),
      enemyScript: EnemyScript.fromJson(
          Map<String, dynamic>.from(json['enemyScript'] as Map)),
    );

const _$DeckTypeEnumMap = {
  DeckType.enemy: 'enemy',
  DeckType.call: 'call',
  DeckType.shift: 'shift',
  DeckType.change: 'change',
  DeckType.transform: 'transform',
  DeckType.skillShift: 'skillShift',
  DeckType.missionTargetSkillShift: 'missionTargetSkillShift',
};

const _$EnemyRoleTypeEnumMap = {
  EnemyRoleType.normal: 'normal',
  EnemyRoleType.danger: 'danger',
  EnemyRoleType.servant: 'servant',
};

EnemyServerMod _$EnemyServerModFromJson(Map json) => EnemyServerMod(
      tdRate: json['tdRate'] as int,
      tdAttackRate: json['tdAttackRate'] as int,
      starRate: json['starRate'] as int,
    );

EnemyScript _$EnemyScriptFromJson(Map json) => EnemyScript(
      deathType:
          $enumDecodeNullable(_$EnemyDeathTypeEnumMap, json['deathType']),
      hpBarType: json['hpBarType'] as int?,
      leader: json['leader'] as bool?,
      call: (json['call'] as List<dynamic>?)?.map((e) => e as int).toList(),
      shift: (json['shift'] as List<dynamic>?)?.map((e) => e as int).toList(),
      shiftClear: (json['shiftClear'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$EnemyDeathTypeEnumMap = {
  EnemyDeathType.escape: 'escape',
  EnemyDeathType.stand: 'stand',
  EnemyDeathType.effect: 'effect',
  EnemyDeathType.wait: 'wait',
};

EnemyPassive _$EnemyPassiveFromJson(Map json) => EnemyPassive(
      classPassive: (json['classPassive'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      addPassive: (json['addPassive'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

QuestPhase _$QuestPhaseFromJson(Map json) => QuestPhase(
  afterClear: $enumDecode(_$QuestAfterClearTypeEnumMap, json['afterClear']),
      recommendLv: json['recommendLv'] as String,
      chapterId: json['chapterId'] as int,
      chapterSubId: json['chapterSubId'] as int,
      chapterSubStr: json['chapterSubStr'] as String,
      closedAt: json['closedAt'] as int,
      consume: json['consume'] as int,
      consumeItem: (json['consumeItem'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      consumeType: $enumDecode(_$ConsumeTypeEnumMap, json['consumeType']),
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      id: json['id'] as int,
      name: json['name'] as String,
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      phaseScripts: (json['phaseScripts'] as List<dynamic>)
          .map((e) =>
              QuestPhaseScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      phases: (json['phases'] as List<dynamic>).map((e) => e as int).toList(),
      phasesWithEnemies: (json['phasesWithEnemies'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map(
              (e) => QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      spotId: json['spotId'] as int,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String,
      phase: json['phase'] as int,
      className: (json['className'] as List<dynamic>)
          .map((e) => $enumDecode(_$SvtClassEnumMap, e))
          .toList(),
      individuality: (json['individuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      qp: json['qp'] as int,
      exp: json['exp'] as int,
      bond: json['bond'] as int,
      battleBgId: json['battleBgId'] as int,
      scripts: (json['scripts'] as List<dynamic>)
          .map((e) => ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map(
              (e) => QuestMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      supportServants: (json['supportServants'] as List<dynamic>)
          .map((e) =>
              SupportServant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      stages: (json['stages'] as List<dynamic>)
          .map((e) => Stage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      drops: (json['drops'] as List<dynamic>)
          .map((e) => EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

ScriptLink _$ScriptLinkFromJson(Map json) => ScriptLink(
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
    );

ValentineScript _$ValentineScriptFromJson(Map json) => ValentineScript(
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
      scriptName: json['scriptName'] as String,
    );

StageLink _$StageLinkFromJson(Map json) => StageLink(
      questId: json['questId'] as int,
      phase: json['phase'] as int,
      stage: json['stage'] as int,
    );

NiceScript _$NiceScriptFromJson(Map json) => NiceScript(
      scriptId: json['scriptId'] as String,
      scriptSizeBytes: json['scriptSizeBytes'] as int,
      script: json['script'] as String,
      quests: (json['quests'] as List<dynamic>)
          .map((e) => Quest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

BasicServant _$BasicServantFromJson(Map json) => BasicServant(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      className: $enumDecode(_$SvtClassEnumMap, json['className']),
      attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
      rarity: json['rarity'] as int,
      atkMax: json['atkMax'] as int,
      hpMax: json['hpMax'] as int,
      face: json['face'] as String,
    );

const _$AttributeEnumMap = {
  Attribute.human: 'human',
  Attribute.sky: 'sky',
  Attribute.earth: 'earth',
  Attribute.star: 'star',
  Attribute.beast: 'beast',
  Attribute.Void: 'void',
};

ExtraAssetsUrl _$ExtraAssetsUrlFromJson(Map json) => ExtraAssetsUrl(
      ascension: (json['ascension'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
      story: (json['story'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
      costume: (json['costume'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
      equip: (json['equip'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
      cc: (json['cc'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), e as String),
      ),
    );

ExtraCCAssets _$ExtraCCAssetsFromJson(Map json) => ExtraCCAssets(
      charaGraph: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['charaGraph'] as Map)),
      faces: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['faces'] as Map)),
    );

ExtraAssets _$ExtraAssetsFromJson(Map json) => ExtraAssets(
      charaGraph: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['charaGraph'] as Map)),
      faces: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['faces'] as Map)),
      charaGraphEx: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['charaGraphEx'] as Map)),
      charaGraphName: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['charaGraphName'] as Map)),
      narrowFigure: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['narrowFigure'] as Map)),
      charaFigure: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['charaFigure'] as Map)),
      charaFigureForm: (json['charaFigureForm'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      charaFigureMulti: (json['charaFigureMulti'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      commands: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['commands'] as Map)),
      status: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['status'] as Map)),
      equipFace: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['equipFace'] as Map)),
      image: ExtraAssetsUrl.fromJson(
          Map<String, dynamic>.from(json['image'] as Map)),
    );

CardDetail _$CardDetailFromJson(Map json) => CardDetail(
      attackIndividuality: (json['attackIndividuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

AscensionAddEntry<T> _$AscensionAddEntryFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    AscensionAddEntry<T>(
      ascension: (json['ascension'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
      ),
      costume: (json['costume'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
      ),
    );

AscensionAdd _$AscensionAddFromJson(Map json) => AscensionAdd(
      individuality: AscensionAddEntry<List<NiceTrait>>.fromJson(
          Map<String, dynamic>.from(json['individuality'] as Map)),
      voicePrefix: AscensionAddEntry<int>.fromJson(
          Map<String, dynamic>.from(json['voicePrefix'] as Map)),
      overWriteServantName: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteServantName'] as Map)),
      overWriteServantBattleName: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteServantBattleName'] as Map)),
      overWriteTDName: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteTDName'] as Map)),
      overWriteTDRuby: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteTDRuby'] as Map)),
      overWriteTDFileName: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteTDFileName'] as Map)),
      overWriteTDRank: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteTDRank'] as Map)),
      overWriteTDTypeText: AscensionAddEntry<String>.fromJson(
          Map<String, dynamic>.from(json['overWriteTDTypeText'] as Map)),
      lvMax: AscensionAddEntry<int>.fromJson(
          Map<String, dynamic>.from(json['lvMax'] as Map)),
    );

ServantChange _$ServantChangeFromJson(Map json) => ServantChange(
      beforeTreasureDeviceIds:
          (json['beforeTreasureDeviceIds'] as List<dynamic>)
              .map((e) => e as int)
              .toList(),
      afterTreasureDeviceIds: (json['afterTreasureDeviceIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      svtId: json['svtId'] as int,
      priority: json['priority'] as int,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      condTargetId: json['condTargetId'] as int,
      condValue: json['condValue'] as int,
      name: json['name'] as String,
      svtVoiceId: json['svtVoiceId'] as int,
      limitCount: json['limitCount'] as int,
      flag: json['flag'] as int,
      battleSvtId: json['battleSvtId'] as int,
    );

ServantAppendPassiveSkill _$ServantAppendPassiveSkillFromJson(Map json) =>
    ServantAppendPassiveSkill(
      num: json['num'] as int,
      priority: json['priority'] as int,
      skill:
          NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
      unlockMaterials: (json['unlockMaterials'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

NiceServantCoin _$NiceServantCoinFromJson(Map json) => NiceServantCoin(
      summonNum: json['summonNum'] as int,
      item: Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
    );

ServantTrait _$ServantTraitFromJson(Map json) => ServantTrait(
      idx: json['idx'] as int,
      trait: (json['trait'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      limitCount: json['limitCount'] as int,
      condType: $enumDecodeNullable(_$CondTypeEnumMap, json['condType']),
      ondId: json['ondId'] as int?,
      condNum: json['condNum'] as int?,
    );

LoreComment _$LoreCommentFromJson(Map json) => LoreComment(
      id: json['id'] as int,
      priority: json['priority'] as int,
      condMessage: json['condMessage'] as String,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      condValues:
          (json['condValues'] as List<dynamic>?)?.map((e) => e as int).toList(),
      condValue2: json['condValue2'] as int,
    );

LoreStatus _$LoreStatusFromJson(Map json) => LoreStatus(
      strength: json['strength'] as String,
      endurance: json['endurance'] as String,
      agility: json['agility'] as String,
      magic: json['magic'] as String,
      luck: json['luck'] as String,
      np: json['np'] as String,
    );

NiceCostume _$NiceCostumeFromJson(Map json) => NiceCostume(
  id: json['id'] as int,
      costumeCollectionNo: json['costumeCollectionNo'] as int,
      battleCharaId: json['battleCharaId'] as int,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      detail: json['detail'] as String,
      priority: json['priority'] as int,
    );

VoiceCond _$VoiceCondFromJson(Map json) => VoiceCond(
      condType: $enumDecode(_$VoiceCondTypeEnumMap, json['condType']),
      value: json['value'] as int,
      valueList:
          (json['valueList'] as List<dynamic>).map((e) => e as int).toList(),
      eventId: json['eventId'] as int,
    );

const _$VoiceCondTypeEnumMap = {
  VoiceCondType.birthDay: 'birthDay',
  VoiceCondType.event: 'event',
  VoiceCondType.friendship: 'friendship',
  VoiceCondType.svtGet: 'svtGet',
  VoiceCondType.svtGroup: 'svtGroup',
  VoiceCondType.questClear: 'questClear',
  VoiceCondType.notQuestClear: 'notQuestClear',
  VoiceCondType.levelUp: 'levelUp',
  VoiceCondType.limitCount: 'limitCount',
  VoiceCondType.limitCountCommon: 'limitCountCommon',
  VoiceCondType.countStop: 'countStop',
  VoiceCondType.isnewWar: 'isnewWar',
  VoiceCondType.eventEnd: 'eventEnd',
  VoiceCondType.eventNoend: 'eventNoend',
  VoiceCondType.eventMissionAction: 'eventMissionAction',
  VoiceCondType.masterMission: 'masterMission',
  VoiceCondType.limitCountAbove: 'limitCountAbove',
  VoiceCondType.eventShopPurchase: 'eventShopPurchase',
  VoiceCondType.eventPeriod: 'eventPeriod',
  VoiceCondType.friendshipAbove: 'friendshipAbove',
  VoiceCondType.spacificShopPurchase: 'spacificShopPurchase',
  VoiceCondType.friendshipBelow: 'friendshipBelow',
  VoiceCondType.costume: 'costume',
  VoiceCondType.levelUpLimitCount: 'levelUpLimitCount',
  VoiceCondType.levelUpLimitCountAbove: 'levelUpLimitCountAbove',
  VoiceCondType.levelUpLimitCountBelow: 'levelUpLimitCountBelow',
};

VoicePlayCond _$VoicePlayCondFromJson(Map json) => VoicePlayCond(
      condGroup: json['condGroup'] as int,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      targetId: json['targetId'] as int,
      condValue: json['condValue'] as int,
      condValues:
          (json['condValues'] as List<dynamic>).map((e) => e as int).toList(),
    );

VoiceLine _$VoiceLineFromJson(Map json) => VoiceLine(
      name: json['name'] as String?,
      condType: $enumDecodeNullable(_$CondTypeEnumMap, json['condType']),
      condValue: json['condValue'] as int?,
      priority: json['priority'] as int?,
      svtVoiceType:
          $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['svtVoiceType']),
      overwriteName: json['overwriteName'] as String,
      summonScript: json['summonScript'],
      id: (json['id'] as List<dynamic>).map((e) => e as String).toList(),
      audioAssets: (json['audioAssets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      delay: (json['delay'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      face: (json['face'] as List<dynamic>).map((e) => e as int).toList(),
      form: (json['form'] as List<dynamic>).map((e) => e as int).toList(),
      text: (json['text'] as List<dynamic>).map((e) => e as String).toList(),
      subtitle: json['subtitle'] as String,
      conds: (json['conds'] as List<dynamic>)
          .map((e) => VoiceCond.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      playConds: (json['playConds'] as List<dynamic>)
          .map((e) =>
              VoicePlayCond.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$SvtVoiceTypeEnumMap = {
  SvtVoiceType.home: 'home',
  SvtVoiceType.groeth: 'groeth',
  SvtVoiceType.firstGet: 'firstGet',
  SvtVoiceType.eventJoin: 'eventJoin',
  SvtVoiceType.eventReward: 'eventReward',
  SvtVoiceType.battle: 'battle',
  SvtVoiceType.treasureDevice: 'treasureDevice',
  SvtVoiceType.masterMission: 'masterMission',
  SvtVoiceType.eventShop: 'eventShop',
  SvtVoiceType.homeCostume: 'homeCostume',
  SvtVoiceType.boxGachaTalk: 'boxGachaTalk',
  SvtVoiceType.battleEntry: 'battleEntry',
  SvtVoiceType.battleWin: 'battleWin',
  SvtVoiceType.eventTowerReward: 'eventTowerReward',
  SvtVoiceType.guide: 'guide',
  SvtVoiceType.eventDailyPoint: 'eventDailyPoint',
  SvtVoiceType.tddamage: 'tddamage',
  SvtVoiceType.treasureBox: 'treasureBox',
  SvtVoiceType.sum: 'sum',
};

VoiceGroup _$VoiceGroupFromJson(Map json) => VoiceGroup(
      svtId: json['svtId'] as int,
      voicePrefix: json['voicePrefix'] as int,
      type: $enumDecode(_$SvtVoiceTypeEnumMap, json['type']),
      voiceLines: (json['voiceLines'] as List<dynamic>)
          .map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

NiceLore _$NiceLoreFromJson(Map json) => NiceLore(
      cv: json['cv'] as String,
      illustrator: json['illustrator'] as String,
      stats: json['stats'] == null
          ? null
          : LoreStatus.fromJson(
              Map<String, dynamic>.from(json['stats'] as Map)),
      costume: (json['costume'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            NiceCostume.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => LoreComment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      voices: (json['voices'] as List<dynamic>)
          .map((e) => VoiceGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

ServantScript _$ServantScriptFromJson(Map json) => ServantScript(
      SkillRankUp: (json['SkillRankUp'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
    );

Servant _$ServantFromJson(Map json) => Servant(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String,
      className: $enumDecode(_$SvtClassEnumMap, json['className']),
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      cost: json['cost'] as int,
      lvMax: json['lvMax'] as int,
      extraAssets: ExtraAssets.fromJson(
          Map<String, dynamic>.from(json['extraAssets'] as Map)),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
      traits: (json['traits'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      starAbsorb: json['starAbsorb'] as int,
      starGen: json['starGen'] as int,
      instantDeathChance: json['instantDeathChance'] as int,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => $enumDecode(_$CardTypeEnumMap, e))
          .toList(),
      hitsDistribution: (json['hitsDistribution'] as Map).map(
        (k, e) => MapEntry($enumDecode(_$CardTypeEnumMap, k),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      cardDetails: (json['cardDetails'] as Map).map(
        (k, e) => MapEntry($enumDecode(_$CardTypeEnumMap, k),
            CardDetail.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      relateQuestIds: (json['relateQuestIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      growthCurve: json['growthCurve'] as int,
      atkGrowth:
          (json['atkGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      hpGrowth:
          (json['hpGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      bondGrowth:
          (json['bondGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      expGrowth:
          (json['expGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      expFeed: (json['expFeed'] as List<dynamic>).map((e) => e as int).toList(),
      bondEquip: json['bondEquip'] as int,
      valentineEquip: (json['valentineEquip'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      valentineScript: (json['valentineScript'] as List<dynamic>)
          .map((e) =>
              ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      ascensionAdd: AscensionAdd.fromJson(
          Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      traitAdd: (json['traitAdd'] as List<dynamic>)
          .map(
              (e) => ServantTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svtChange: (json['svtChange'] as List<dynamic>)
          .map((e) =>
              ServantChange.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      ascensionMaterials: (json['ascensionMaterials'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      skillMaterials: (json['skillMaterials'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      appendSkillMaterials: (json['appendSkillMaterials'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      costumeMaterials: (json['costumeMaterials'] as Map).map(
        (k, e) => MapEntry(int.parse(k as String),
            LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      coin: json['coin'] == null
          ? null
          : NiceServantCoin.fromJson(
              Map<String, dynamic>.from(json['coin'] as Map)),
      script: ServantScript.fromJson(
          Map<String, dynamic>.from(json['script'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      classPassive: (json['classPassive'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      extraPassive: (json['extraPassive'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      appendPassive: (json['appendPassive'] as List<dynamic>)
          .map((e) => ServantAppendPassiveSkill.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      noblePhantasms: (json['noblePhantasms'] as List<dynamic>)
          .map((e) => NiceTd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      profile: json['profile'] == null
          ? null
          : NiceLore.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map)),
    );

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};

Vals _$ValsFromJson(Map json) => Vals(
      Rate: json['Rate'] as int?,
      Turn: json['Turn'] as int?,
      Count: json['Count'] as int?,
      Value: json['Value'] as int?,
      Value2: json['Value2'] as int?,
      UseRate: json['UseRate'] as int?,
      Target: json['Target'] as int?,
      Correction: json['Correction'] as int?,
      ParamAdd: json['ParamAdd'] as int?,
      ParamMax: json['ParamMax'] as int?,
      HideMiss: json['HideMiss'] as int?,
      OnField: json['OnField'] as int?,
      HideNoEffect: json['HideNoEffect'] as int?,
      Unaffected: json['Unaffected'] as int?,
      ShowState: json['ShowState'] as int?,
      AuraEffectId: json['AuraEffectId'] as int?,
      ActSet: json['ActSet'] as int?,
      ActSetWeight: json['ActSetWeight'] as int?,
      ShowQuestNoEffect: json['ShowQuestNoEffect'] as int?,
      CheckDead: json['CheckDead'] as int?,
      RatioHPHigh: json['RatioHPHigh'] as int?,
      RatioHPLow: json['RatioHPLow'] as int?,
      SetPassiveFrame: json['SetPassiveFrame'] as int?,
      ProcPassive: json['ProcPassive'] as int?,
      ProcActive: json['ProcActive'] as int?,
      HideParam: json['HideParam'] as int?,
      SkillID: json['SkillID'] as int?,
      SkillLV: json['SkillLV'] as int?,
      ShowCardOnly: json['ShowCardOnly'] as int?,
      EffectSummon: json['EffectSummon'] as int?,
      RatioHPRangeHigh: json['RatioHPRangeHigh'] as int?,
      RatioHPRangeLow: json['RatioHPRangeLow'] as int?,
      TargetList:
          (json['TargetList'] as List<dynamic>?)?.map((e) => e as int).toList(),
      OpponentOnly: json['OpponentOnly'] as int?,
      StatusEffectId: json['StatusEffectId'] as int?,
      EndBattle: json['EndBattle'] as int?,
      LoseBattle: json['LoseBattle'] as int?,
      AddIndividualty: json['AddIndividualty'] as int?,
      AddLinkageTargetIndividualty:
          json['AddLinkageTargetIndividualty'] as int?,
      SameBuffLimitTargetIndividuality:
          json['SameBuffLimitTargetIndividuality'] as int?,
      SameBuffLimitNum: json['SameBuffLimitNum'] as int?,
      CheckDuplicate: json['CheckDuplicate'] as int?,
      OnFieldCount: json['OnFieldCount'] as int?,
      TargetRarityList: (json['TargetRarityList'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      DependFuncId: json['DependFuncId'] as int?,
      InvalidHide: json['InvalidHide'] as int?,
      OutEnemyNpcId: json['OutEnemyNpcId'] as int?,
      InEnemyNpcId: json['InEnemyNpcId'] as int?,
      OutEnemyPosition: json['OutEnemyPosition'] as int?,
      IgnoreIndividuality: json['IgnoreIndividuality'] as int?,
      StarHigher: json['StarHigher'] as int?,
      ChangeTDCommandType: json['ChangeTDCommandType'] as int?,
      ShiftNpcId: json['ShiftNpcId'] as int?,
      DisplayLastFuncInvalidType: json['DisplayLastFuncInvalidType'] as int?,
      AndCheckIndividualityList:
          (json['AndCheckIndividualityList'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      WinBattleNotRelatedSurvivalStatus:
          json['WinBattleNotRelatedSurvivalStatus'] as int?,
      ForceSelfInstantDeath: json['ForceSelfInstantDeath'] as int?,
      ChangeMaxBreakGauge: json['ChangeMaxBreakGauge'] as int?,
      ParamAddMaxValue: json['ParamAddMaxValue'] as int?,
      ParamAddMaxCount: json['ParamAddMaxCount'] as int?,
      LossHpChangeDamage: json['LossHpChangeDamage'] as int?,
      IncludePassiveIndividuality: json['IncludePassiveIndividuality'] as int?,
      MotionChange: json['MotionChange'] as int?,
      PopLabelDelay: json['PopLabelDelay'] as int?,
      NoTargetNoAct: json['NoTargetNoAct'] as int?,
      CardIndex: json['CardIndex'] as int?,
      CardIndividuality: json['CardIndividuality'] as int?,
      WarBoardTakeOverBuff: json['WarBoardTakeOverBuff'] as int?,
      ParamAddSelfIndividuality:
          (json['ParamAddSelfIndividuality'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      ParamAddOpIndividuality:
          (json['ParamAddOpIndividuality'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      ParamAddFieldIndividuality:
          (json['ParamAddFieldIndividuality'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      ParamAddValue: json['ParamAddValue'] as int?,
      MultipleGainStar: json['MultipleGainStar'] as int?,
      NoCheckIndividualityIfNotUnit:
          json['NoCheckIndividualityIfNotUnit'] as int?,
      ForcedEffectSpeedOne: json['ForcedEffectSpeedOne'] as int?,
      SetLimitCount: json['SetLimitCount'] as int?,
      CheckEnemyFieldSpace: json['CheckEnemyFieldSpace'] as int?,
      TriggeredFuncPosition: json['TriggeredFuncPosition'] as int?,
      DamageCount: json['DamageCount'] as int?,
      DamageRates: (json['DamageRates'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      OnPositions: (json['OnPositions'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      OffPositions: (json['OffPositions'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      TargetIndiv: json['TargetIndiv'] as int?,
      IncludeIgnoreIndividuality: json['IncludeIgnoreIndividuality'] as int?,
      EvenIfWinDie: json['EvenIfWinDie'] as int?,
      CallSvtEffectId: json['CallSvtEffectId'] as int?,
      ForceAddState: json['ForceAddState'] as int?,
      UnSubState: json['UnSubState'] as int?,
      ForceSubState: json['ForceSubState'] as int?,
      IgnoreIndivUnreleaseable: json['IgnoreIndivUnreleaseable'] as int?,
      OnParty: json['OnParty'] as int?,
      ApplySupportSvt: json['ApplySupportSvt'] as int?,
      Individuality: json['Individuality'] as int?,
      EventId: json['EventId'] as int?,
      AddCount: json['AddCount'] as int?,
      RateCount: json['RateCount'] as int?,
      DependFuncVals: json['DependFuncVals'] == null
          ? null
          : Vals.fromJson(
              Map<String, dynamic>.from(json['DependFuncVals'] as Map)),
    );

CommonRelease _$CommonReleaseFromJson(Map json) => CommonRelease(
      id: json['id'] as int,
      priority: json['priority'] as int,
      condGroup: json['condGroup'] as int,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      condId: json['condId'] as int,
      condNum: json['condNum'] as int,
    );

Buff _$BuffFromJson(Map json) => Buff(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      icon: json['icon'] as String?,
      type: $enumDecode(_$BuffTypeEnumMap, json['type']),
      buffGroup: json['buffGroup'] as int,
      script: json['script'],
      vals: (json['vals'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tvals: (json['tvals'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      ckSelfIndv: (json['ckSelfIndv'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      ckOpIndv: (json['ckOpIndv'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      maxRate: json['maxRate'] as int,
    );

FuncGroup _$FuncGroupFromJson(Map json) => FuncGroup(
      eventId: json['eventId'] as int,
      baseFuncId: json['baseFuncId'] as int,
      nameTotal: json['nameTotal'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      priority: json['priority'] as int,
      isDispValue: json['isDispValue'] as bool,
    );

NiceFunction _$NiceFunctionFromJson(Map json) => NiceFunction(
      funcId: json['funcId'] as int,
      funcType: $enumDecode(_$FuncTypeEnumMap, json['funcType']),
      funcTargetType:
          $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
      funcTargetTeam:
          $enumDecode(_$FuncApplyTargetEnumMap, json['funcTargetTeam']),
      funcPopupText: json['funcPopupText'] as String,
      funcPopupIcon: json['funcPopupIcon'] as String?,
      functvals: (json['functvals'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      funcquestTvals: (json['funcquestTvals'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      funcGroup: (json['funcGroup'] as List<dynamic>)
          .map((e) => FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      traitVals: (json['traitVals'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      buffs: (json['buffs'] as List<dynamic>)
          .map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals2: (json['svals2'] as List<dynamic>?)
          ?.map((e) => Vals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals3: (json['svals3'] as List<dynamic>?)
          ?.map((e) => Vals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals4: (json['svals4'] as List<dynamic>?)
          ?.map((e) => Vals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals5: (json['svals5'] as List<dynamic>?)
          ?.map((e) => Vals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      followerVals: (json['followerVals'] as List<dynamic>?)
          ?.map((e) => Vals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$FuncTypeEnumMap = {
  FuncType.none: 'none',
  FuncType.addState: 'addState',
  FuncType.subState: 'subState',
  FuncType.damage: 'damage',
  FuncType.damageNp: 'damageNp',
  FuncType.gainStar: 'gainStar',
  FuncType.gainHp: 'gainHp',
  FuncType.gainNp: 'gainNp',
  FuncType.lossNp: 'lossNp',
  FuncType.shortenSkill: 'shortenSkill',
  FuncType.extendSkill: 'extendSkill',
  FuncType.releaseState: 'releaseState',
  FuncType.lossHp: 'lossHp',
  FuncType.instantDeath: 'instantDeath',
  FuncType.damageNpPierce: 'damageNpPierce',
  FuncType.damageNpIndividual: 'damageNpIndividual',
  FuncType.addStateShort: 'addStateShort',
  FuncType.gainHpPer: 'gainHpPer',
  FuncType.damageNpStateIndividual: 'damageNpStateIndividual',
  FuncType.hastenNpturn: 'hastenNpturn',
  FuncType.delayNpturn: 'delayNpturn',
  FuncType.damageNpHpratioHigh: 'damageNpHpratioHigh',
  FuncType.damageNpHpratioLow: 'damageNpHpratioLow',
  FuncType.cardReset: 'cardReset',
  FuncType.replaceMember: 'replaceMember',
  FuncType.lossHpSafe: 'lossHpSafe',
  FuncType.damageNpCounter: 'damageNpCounter',
  FuncType.damageNpStateIndividualFix: 'damageNpStateIndividualFix',
  FuncType.damageNpSafe: 'damageNpSafe',
  FuncType.callServant: 'callServant',
  FuncType.ptShuffle: 'ptShuffle',
  FuncType.lossStar: 'lossStar',
  FuncType.changeServant: 'changeServant',
  FuncType.changeBg: 'changeBg',
  FuncType.damageValue: 'damageValue',
  FuncType.withdraw: 'withdraw',
  FuncType.fixCommandcard: 'fixCommandcard',
  FuncType.shortenBuffturn: 'shortenBuffturn',
  FuncType.extendBuffturn: 'extendBuffturn',
  FuncType.shortenBuffcount: 'shortenBuffcount',
  FuncType.extendBuffcount: 'extendBuffcount',
  FuncType.changeBgm: 'changeBgm',
  FuncType.displayBuffstring: 'displayBuffstring',
  FuncType.resurrection: 'resurrection',
  FuncType.gainNpBuffIndividualSum: 'gainNpBuffIndividualSum',
  FuncType.setSystemAliveFlag: 'setSystemAliveFlag',
  FuncType.forceInstantDeath: 'forceInstantDeath',
  FuncType.damageNpRare: 'damageNpRare',
  FuncType.gainNpFromTargets: 'gainNpFromTargets',
  FuncType.gainHpFromTargets: 'gainHpFromTargets',
  FuncType.lossHpPer: 'lossHpPer',
  FuncType.lossHpPerSafe: 'lossHpPerSafe',
  FuncType.shortenUserEquipSkill: 'shortenUserEquipSkill',
  FuncType.quickChangeBg: 'quickChangeBg',
  FuncType.shiftServant: 'shiftServant',
  FuncType.damageNpAndCheckIndividuality: 'damageNpAndCheckIndividuality',
  FuncType.absorbNpturn: 'absorbNpturn',
  FuncType.overwriteDeadType: 'overwriteDeadType',
  FuncType.forceAllBuffNoact: 'forceAllBuffNoact',
  FuncType.breakGaugeUp: 'breakGaugeUp',
  FuncType.breakGaugeDown: 'breakGaugeDown',
  FuncType.moveToLastSubmember: 'moveToLastSubmember',
  FuncType.expUp: 'expUp',
  FuncType.qpUp: 'qpUp',
  FuncType.dropUp: 'dropUp',
  FuncType.friendPointUp: 'friendPointUp',
  FuncType.eventDropUp: 'eventDropUp',
  FuncType.eventDropRateUp: 'eventDropRateUp',
  FuncType.eventPointUp: 'eventPointUp',
  FuncType.eventPointRateUp: 'eventPointRateUp',
  FuncType.transformServant: 'transformServant',
  FuncType.qpDropUp: 'qpDropUp',
  FuncType.servantFriendshipUp: 'servantFriendshipUp',
  FuncType.userEquipExpUp: 'userEquipExpUp',
  FuncType.classDropUp: 'classDropUp',
  FuncType.enemyEncountCopyRateUp: 'enemyEncountCopyRateUp',
  FuncType.enemyEncountRateUp: 'enemyEncountRateUp',
  FuncType.enemyProbDown: 'enemyProbDown',
  FuncType.getRewardGift: 'getRewardGift',
  FuncType.sendSupportFriendPoint: 'sendSupportFriendPoint',
  FuncType.movePosition: 'movePosition',
  FuncType.revival: 'revival',
  FuncType.damageNpIndividualSum: 'damageNpIndividualSum',
  FuncType.damageValueSafe: 'damageValueSafe',
  FuncType.friendPointUpDuplicate: 'friendPointUpDuplicate',
  FuncType.moveState: 'moveState',
  FuncType.changeBgmCostume: 'changeBgmCostume',
  FuncType.func126: 'func126',
  FuncType.func127: 'func127',
  FuncType.updateEntryPositions: 'updateEntryPositions',
};

const _$FuncTargetTypeEnumMap = {
  FuncTargetType.self: 'self',
  FuncTargetType.ptOne: 'ptOne',
  FuncTargetType.ptAnother: 'ptAnother',
  FuncTargetType.ptAll: 'ptAll',
  FuncTargetType.enemy: 'enemy',
  FuncTargetType.enemyAnother: 'enemyAnother',
  FuncTargetType.enemyAll: 'enemyAll',
  FuncTargetType.ptFull: 'ptFull',
  FuncTargetType.enemyFull: 'enemyFull',
  FuncTargetType.ptOther: 'ptOther',
  FuncTargetType.ptOneOther: 'ptOneOther',
  FuncTargetType.ptRandom: 'ptRandom',
  FuncTargetType.enemyOther: 'enemyOther',
  FuncTargetType.enemyRandom: 'enemyRandom',
  FuncTargetType.ptOtherFull: 'ptOtherFull',
  FuncTargetType.enemyOtherFull: 'enemyOtherFull',
  FuncTargetType.ptselectOneSub: 'ptselectOneSub',
  FuncTargetType.ptselectSub: 'ptselectSub',
  FuncTargetType.ptOneAnotherRandom: 'ptOneAnotherRandom',
  FuncTargetType.ptSelfAnotherRandom: 'ptSelfAnotherRandom',
  FuncTargetType.enemyOneAnotherRandom: 'enemyOneAnotherRandom',
  FuncTargetType.ptSelfAnotherFirst: 'ptSelfAnotherFirst',
  FuncTargetType.ptSelfBefore: 'ptSelfBefore',
  FuncTargetType.ptSelfAfter: 'ptSelfAfter',
  FuncTargetType.ptSelfAnotherLast: 'ptSelfAnotherLast',
  FuncTargetType.commandTypeSelfTreasureDevice: 'commandTypeSelfTreasureDevice',
  FuncTargetType.fieldOther: 'fieldOther',
  FuncTargetType.enemyOneNoTargetNoAction: 'enemyOneNoTargetNoAction',
  FuncTargetType.ptOneHpLowestValue: 'ptOneHpLowestValue',
  FuncTargetType.ptOneHpLowestRate: 'ptOneHpLowestRate',
};

const _$FuncApplyTargetEnumMap = {
  FuncApplyTarget.player: 'player',
  FuncApplyTarget.enemy: 'enemy',
  FuncApplyTarget.playerAndEnemy: 'playerAndEnemy',
};

ExtraPassive _$ExtraPassiveFromJson(Map json) => ExtraPassive(
      num: json['num'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int,
      condQuestPhase: json['condQuestPhase'] as int,
      condLv: json['condLv'] as int,
      condLimitCount: json['condLimitCount'] as int,
      condFriendshipRank: json['condFriendshipRank'] as int,
      eventId: json['eventId'] as int,
      flag: json['flag'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
    );

SkillScript _$SkillScriptFromJson(Map json) => SkillScript(
      NP_HIGHER:
          (json['NP_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      NP_LOWER:
          (json['NP_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      STAR_HIGHER: (json['STAR_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      STAR_LOWER:
          (json['STAR_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_VAL_HIGHER: (json['HP_VAL_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_VAL_LOWER: (json['HP_VAL_LOWER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_PER_HIGHER: (json['HP_PER_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_PER_LOWER: (json['HP_PER_LOWER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      additionalSkillId: (json['additionalSkillId'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      additionalSkillActorType:
          (json['additionalSkillActorType'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
    );

SkillAdd _$SkillAddFromJson(Map json) => SkillAdd(
      priority: json['priority'] as int,
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map((e) =>
              CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      name: json['name'] as String,
      ruby: json['ruby'] as String,
    );

NiceSkill _$NiceSkillFromJson(Map json) => NiceSkill(
      id: json['id'] as int,
      num: json['num'] as int? ?? -1,
      name: json['name'] as String,
      ruby: json['ruby'] as String,
      detail: json['detail'] as String?,
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecode(_$SkillTypeEnumMap, json['type']),
      strengthStatus: json['strengthStatus'] as int? ?? -1,
      priority: json['priority'] as int? ?? -1,
      condQuestId: json['condQuestId'] as int? ?? -1,
      condQuestPhase: json['condQuestPhase'] as int? ?? -1,
      condLv: json['condLv'] as int? ?? -1,
      condLimitCount: json['condLimitCount'] as int? ?? -1,
      icon: json['icon'] as String?,
      coolDown:
          (json['coolDown'] as List<dynamic>).map((e) => e as int).toList(),
      actIndividuality: (json['actIndividuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      script: SkillScript.fromJson(
          Map<String, dynamic>.from(json['script'] as Map)),
      extraPassive: (json['extraPassive'] as List<dynamic>)
          .map(
              (e) => ExtraPassive.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      skillAdd: (json['skillAdd'] as List<dynamic>)
          .map((e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      functions: (json['functions'] as List<dynamic>)
          .map(
              (e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$SkillTypeEnumMap = {
  SkillType.active: 'active',
  SkillType.passive: 'passive',
};

NpGain _$NpGainFromJson(Map json) => NpGain(
      buster: (json['buster'] as List<dynamic>).map((e) => e as int).toList(),
      arts: (json['arts'] as List<dynamic>).map((e) => e as int).toList(),
      quick: (json['quick'] as List<dynamic>).map((e) => e as int).toList(),
      extra: (json['extra'] as List<dynamic>).map((e) => e as int).toList(),
      defence: (json['defence'] as List<dynamic>).map((e) => e as int).toList(),
      np: (json['np'] as List<dynamic>).map((e) => e as int).toList(),
    );

NiceTd _$NiceTdFromJson(Map json) => NiceTd(
      id: json['id'] as int,
      num: json['num'] as int,
      card: $enumDecode(_$CardTypeEnumMap, json['card']),
      name: json['name'] as String,
      ruby: json['ruby'] as String,
      icon: json['icon'] as String?,
      rank: json['rank'] as String,
      type: json['type'] as String,
      detail: json['detail'] as String?,
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      npDistribution: (json['npDistribution'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      strengthStatus: json['strengthStatus'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int,
      condQuestPhase: json['condQuestPhase'] as int,
      individuality: (json['individuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      script: SkillScript.fromJson(
          Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>)
          .map(
              (e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

NiceMap _$NiceMapFromJson(Map json) => NiceMap(
      id: json['id'] as int,
      mapImage: json['mapImage'] as String?,
      mapImageW: json['mapImageW'] as int,
      mapImageH: json['mapImageH'] as int,
      headerImage: json['headerImage'] as String?,
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
    );

NiceSpot _$NiceSpotFromJson(Map json) => NiceSpot(
      id: json['id'] as int,
      joinSpotIds:
          (json['joinSpotIds'] as List<dynamic>).map((e) => e as int).toList(),
      mapId: json['mapId'] as int,
      name: json['name'] as String,
      image: json['image'] as String?,
      x: json['x'] as int,
      y: json['y'] as int,
      imageOfsX: json['imageOfsX'] as int,
      imageOfsY: json['imageOfsY'] as int,
      nameOfsX: json['nameOfsX'] as int,
      nameOfsY: json['nameOfsY'] as int,
      questOfsX: json['questOfsX'] as int,
      questOfsY: json['questOfsY'] as int,
      nextOfsX: json['nextOfsX'] as int,
      nextOfsY: json['nextOfsY'] as int,
      closedMessage: json['closedMessage'] as String,
      quests: (json['quests'] as List<dynamic>)
          .map((e) => Quest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

WarAdd _$WarAddFromJson(Map json) => WarAdd(
      warId: json['warId'] as int,
      type: $enumDecode(_$WarOverwriteTypeEnumMap, json['type']),
      priority: json['priority'] as int,
      overwriteId: json['overwriteId'] as int,
      overwriteStr: json['overwriteStr'] as String,
      overwriteBanner: json['overwriteBanner'] as String?,
      condType: $enumDecode(_$CondTypeEnumMap, json['condType']),
      targetId: json['targetId'] as int,
      value: json['value'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
    );

const _$WarOverwriteTypeEnumMap = {
  WarOverwriteType.bgm: 'bgm',
  WarOverwriteType.parentWar: 'parentWar',
  WarOverwriteType.banner: 'banner',
  WarOverwriteType.bgImage: 'bgImage',
  WarOverwriteType.svtImage: 'svtImage',
  WarOverwriteType.flag: 'flag',
  WarOverwriteType.baseMapId: 'baseMapId',
  WarOverwriteType.name: 'name',
  WarOverwriteType.longName: 'longName',
  WarOverwriteType.materialParentWar: 'materialParentWar',
  WarOverwriteType.coordinates: 'coordinates',
  WarOverwriteType.effectChangeBlackMark: 'effectChangeBlackMark',
  WarOverwriteType.questBoardSectionImage: 'questBoardSectionImage',
  WarOverwriteType.warForceDisp: 'warForceDisp',
  WarOverwriteType.warForceHide: 'warForceHide',
  WarOverwriteType.startType: 'startType',
  WarOverwriteType.noticeDialogText: 'noticeDialogText',
};

NiceWar _$NiceWarFromJson(Map json) => NiceWar(
      id: json['id'] as int,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
          .toList(),
      age: json['age'] as String,
      name: json['name'] as String,
      longName: json['longName'] as String,
      banner: json['banner'] as String?,
      headerImage: json['headerImage'] as String?,
      priority: json['priority'] as int,
      parentWarId: json['parentWarId'] as int,
      materialParentWarId: json['materialParentWarId'] as int,
      emptyMessage: json['emptyMessage'] as String,
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
      startType: $enumDecode(_$WarStartTypeEnumMap, json['startType']),
      targetId: json['targetId'] as int,
      eventId: json['eventId'] as int,
      eventName: json['eventName'] as String,
      lastQuestId: json['lastQuestId'] as int,
      warAdds: (json['warAdds'] as List<dynamic>)
          .map((e) => WarAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      maps: (json['maps'] as List<dynamic>)
          .map((e) => NiceMap.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      spots: (json['spots'] as List<dynamic>)
          .map((e) => NiceSpot.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$WarStartTypeEnumMap = {
  WarStartType.none: 'none',
  WarStartType.script: 'script',
  WarStartType.quest: 'quest',
};
