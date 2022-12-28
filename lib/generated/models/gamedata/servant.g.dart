// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/servant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicCostume _$BasicCostumeFromJson(Map json) => BasicCostume(
      id: json['id'] as int,
      costumeCollectionNo: json['costumeCollectionNo'] as int,
      battleCharaId: json['battleCharaId'] as int,
      shortName: json['shortName'] as String,
    );

BasicServant _$BasicServantFromJson(Map json) => BasicServant(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      overwriteName: json['overwriteName'] as String?,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      className: json['className'] == null
          ? SvtClass.none
          : const SvtClassConverter().fromJson(json['className'] as String),
      attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
      rarity: json['rarity'] as int,
      atkMax: json['atkMax'] as int,
      hpMax: json['hpMax'] as int,
      face: json['face'] as String,
      costume: (json['costume'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                BasicCostume.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
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
  SvtFlag.matDropRateUpCe: 'matDropRateUpCe',
};

const _$AttributeEnumMap = {
  Attribute.human: 'human',
  Attribute.sky: 'sky',
  Attribute.earth: 'earth',
  Attribute.star: 'star',
  Attribute.beast: 'beast',
  Attribute.void_: 'void',
};

Servant _$ServantFromJson(Map json) => Servant(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      battleName: json['battleName'] as String? ?? "",
      className: json['className'] == null
          ? SvtClass.none
          : const SvtClassConverter().fromJson(json['className'] as String),
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      cost: json['cost'] as int,
      lvMax: json['lvMax'] as int,
      extraAssets: json['extraAssets'] == null
          ? null
          : ExtraAssets.fromJson(
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
      cardDetails: (json['cardDetails'] as Map).map(
        (k, e) => MapEntry($enumDecode(_$CardTypeEnumMap, k),
            CardDetail.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      relateQuestIds: (json['relateQuestIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      trialQuestIds: (json['trialQuestIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      growthCurve: json['growthCurve'] as int,
      atkGrowth:
          (json['atkGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      hpGrowth:
          (json['hpGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      bondGrowth:
          (json['bondGrowth'] as List<dynamic>).map((e) => e as int).toList(),
      expGrowth: (json['expGrowth'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      expFeed:
          (json['expFeed'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      bondEquip: json['bondEquip'] as int? ?? 0,
      valentineEquip: (json['valentineEquip'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      valentineScript: (json['valentineScript'] as List<dynamic>?)
              ?.map((e) =>
                  ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      ascensionAdd: json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(
              Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      traitAdd: (json['traitAdd'] as List<dynamic>)
          .map(
              (e) => ServantTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svtChange: (json['svtChange'] as List<dynamic>?)
              ?.map((e) =>
                  ServantChange.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ascensionImage: (json['ascensionImage'] as List<dynamic>?)
              ?.map((e) => ServantLimitImage.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
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
          : ServantCoin.fromJson(
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

BasicCraftEssence _$BasicCraftEssenceFromJson(Map json) => BasicCraftEssence(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      atkMax: json['atkMax'] as int,
      hpMax: json['hpMax'] as int,
      face: json['face'] as String,
    );

CraftEssence _$CraftEssenceFromJson(Map json) => CraftEssence(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      cost: json['cost'] as int,
      lvMax: json['lvMax'] as int,
      extraAssets: json['extraAssets'] == null
          ? null
          : ExtraAssets.fromJson(
              Map<String, dynamic>.from(json['extraAssets'] as Map)),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      growthCurve: json['growthCurve'] as int,
      atkGrowth: (json['atkGrowth'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      hpGrowth:
          (json['hpGrowth'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      expGrowth: (json['expGrowth'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      expFeed:
          (json['expFeed'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      valentineScript: (json['valentineScript'] as List<dynamic>?)
              ?.map((e) =>
                  ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ascensionAdd: json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(
              Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      profile: json['profile'] == null
          ? null
          : NiceLore.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map)),
    );

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
      charaGraph: json['charaGraph'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['charaGraph'] as Map)),
      faces: json['faces'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['faces'] as Map)),
      charaGraphEx: json['charaGraphEx'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['charaGraphEx'] as Map)),
      charaGraphName: json['charaGraphName'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['charaGraphName'] as Map)),
      narrowFigure: json['narrowFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['narrowFigure'] as Map)),
      charaFigure: json['charaFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['charaFigure'] as Map)),
      charaFigureForm: (json['charaFigureForm'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      charaFigureMulti: (json['charaFigureMulti'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      commands: json['commands'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['commands'] as Map)),
      status: json['status'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['status'] as Map)),
      equipFace: json['equipFace'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['equipFace'] as Map)),
      image: json['image'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['image'] as Map)),
      spriteModel: json['spriteModel'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['spriteModel'] as Map)),
      charaGraphChange: json['charaGraphChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
      narrowFigureChange: json['narrowFigureChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['narrowFigureChange'] as Map)),
      facesChange: json['facesChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(
              Map<String, dynamic>.from(json['facesChange'] as Map)),
    );

CardDetail _$CardDetailFromJson(Map json) => CardDetail(
      hitsDistribution: (json['hitsDistribution'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      attackIndividuality: (json['attackIndividuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      attackType: $enumDecodeNullable(
              _$CommandCardAttackTypeEnumMap, json['attackType']) ??
          CommandCardAttackType.one,
    );

const _$CommandCardAttackTypeEnumMap = {
  CommandCardAttackType.one: 'one',
  CommandCardAttackType.all: 'all',
};

AscensionAddEntry<T> _$AscensionAddEntryFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    AscensionAddEntry<T>.typed(
      ascension: (json['ascension'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
          ) ??
          const {},
      costume: (json['costume'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
          ) ??
          const {},
    );

AscensionAdd _$AscensionAddFromJson(Map json) => AscensionAdd(
      individuality: json['individuality'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['individuality'] as Map)),
      voicePrefix: json['voicePrefix'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['voicePrefix'] as Map)),
      overWriteServantName: json['overWriteServantName'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteServantName'] as Map)),
      overWriteServantBattleName: json['overWriteServantBattleName'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(Map<String, dynamic>.from(
              json['overWriteServantBattleName'] as Map)),
      overWriteTDName: json['overWriteTDName'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteTDName'] as Map)),
      overWriteTDRuby: json['overWriteTDRuby'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteTDRuby'] as Map)),
      overWriteTDFileName: json['overWriteTDFileName'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteTDFileName'] as Map)),
      overWriteTDRank: json['overWriteTDRank'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteTDRank'] as Map)),
      overWriteTDTypeText: json['overWriteTDTypeText'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['overWriteTDTypeText'] as Map)),
      lvMax: json['lvMax'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['lvMax'] as Map)),
      charaGraphChange: json['charaGraphChange'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
      faceChange: json['faceChange'] == null
          ? null
          : AscensionAddEntry<dynamic>.fromJson(
              Map<String, dynamic>.from(json['faceChange'] as Map)),
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
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int,
      condValue: json['condValue'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      battleName: json['battleName'] as String? ?? "",
      svtVoiceId: json['svtVoiceId'] as int,
      limitCount: json['limitCount'] as int,
      flag: json['flag'] as int,
      battleSvtId: json['battleSvtId'] as int,
    );

ServantLimitImage _$ServantLimitImageFromJson(Map json) => ServantLimitImage(
      limitCount: json['limitCount'] as int,
      priority: json['priority'] as int? ?? 0,
      defaultLimitCount: json['defaultLimitCount'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int,
      condNum: json['condNum'] as int,
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

ServantCoin _$ServantCoinFromJson(Map json) => ServantCoin(
      summonNum: json['summonNum'] as int,
      item: Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
    );

ServantTrait _$ServantTraitFromJson(Map json) => ServantTrait(
      idx: json['idx'] as int,
      trait: (json['trait'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      limitCount: json['limitCount'] as int,
      condType: _$JsonConverterFromJson<String, CondType>(
          json['condType'], const CondTypeConverter().fromJson),
      condId: json['condId'] as int?,
      condNum: json['condNum'] as int?,
    );

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

LoreCommentAdd _$LoreCommentAddFromJson(Map json) => LoreCommentAdd(
      idx: json['idx'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condValues:
          (json['condValues'] as List<dynamic>).map((e) => e as int).toList(),
      condValue2: json['condValue2'] as int? ?? 0,
    );

LoreComment _$LoreCommentFromJson(Map json) => LoreComment(
      id: json['id'] as int,
      priority: json['priority'] as int? ?? 0,
      condMessage: json['condMessage'] as String? ?? "",
      comment: json['comment'] as String? ?? '',
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condValues:
          (json['condValues'] as List<dynamic>?)?.map((e) => e as int).toList(),
      condValue2: json['condValue2'] as int? ?? 0,
      additionalConds: (json['additionalConds'] as List<dynamic>?)
              ?.map((e) =>
                  LoreCommentAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

LoreStatus _$LoreStatusFromJson(Map json) => LoreStatus(
      strength: json['strength'] as String?,
      endurance: json['endurance'] as String?,
      agility: json['agility'] as String?,
      magic: json['magic'] as String?,
      luck: json['luck'] as String?,
      np: json['np'] as String?,
      policy: $enumDecodeNullable(_$ServantPolicyEnumMap, json['policy']),
      personality:
          $enumDecodeNullable(_$ServantPersonalityEnumMap, json['personality']),
      deity: json['deity'] as String?,
    );

const _$ServantPolicyEnumMap = {
  ServantPolicy.none: 'none',
  ServantPolicy.neutral: 'neutral',
  ServantPolicy.lawful: 'lawful',
  ServantPolicy.chaotic: 'chaotic',
  ServantPolicy.unknown: 'unknown',
};

const _$ServantPersonalityEnumMap = {
  ServantPersonality.none: 'none',
  ServantPersonality.good: 'good',
  ServantPersonality.madness: 'madness',
  ServantPersonality.balanced: 'balanced',
  ServantPersonality.summer: 'summer',
  ServantPersonality.evil: 'evil',
  ServantPersonality.goodAndEvil: 'goodAndEvil',
  ServantPersonality.bride: 'bride',
  ServantPersonality.unknown: 'unknown',
};

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
      condType: $enumDecodeNullable(_$VoiceCondTypeEnumMap, json['condType']) ??
          VoiceCondType.unknown,
      value: json['value'] as int,
      valueList: (json['valueList'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      eventId: json['eventId'] as int? ?? 0,
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
  VoiceCondType.unknown: 'unknown',
};

VoicePlayCond _$VoicePlayCondFromJson(Map json) => VoicePlayCond(
      condGroup: json['condGroup'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: json['targetId'] as int,
      condValue: json['condValue'] as int,
      condValues: (json['condValues'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );

VoiceLine _$VoiceLineFromJson(Map json) => VoiceLine(
      name: json['name'] as String?,
      condType: _$JsonConverterFromJson<String, CondType>(
          json['condType'], const CondTypeConverter().fromJson),
      condValue: json['condValue'] as int?,
      priority: json['priority'] as int?,
      svtVoiceType:
          $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['svtVoiceType']),
      overwriteName: json['overwriteName'] as String? ?? "",
      summonScript: json['summonScript'] == null
          ? null
          : ScriptLink.fromJson(
              Map<String, dynamic>.from(json['summonScript'] as Map)),
      id: (json['id'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      audioAssets: (json['audioAssets'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      delay: (json['delay'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      face: (json['face'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      form: (json['form'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      text:
          (json['text'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      subtitle: json['subtitle'] as String? ?? "",
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceCond.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      playConds: (json['playConds'] as List<dynamic>?)
              ?.map((e) =>
                  VoicePlayCond.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

const _$SvtVoiceTypeEnumMap = {
  SvtVoiceType.unknown: 'unknown',
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
  SvtVoiceType.warBoard: 'warBoard',
  SvtVoiceType.eventDigging: 'eventDigging',
  SvtVoiceType.eventExpedition: 'eventExpedition',
  SvtVoiceType.eventRecipe: 'eventRecipe',
  SvtVoiceType.eventFortification: 'eventFortification',
  SvtVoiceType.sum: 'sum',
};

VoiceGroup _$VoiceGroupFromJson(Map json) => VoiceGroup(
      svtId: json['svtId'] as int,
      voicePrefix: json['voicePrefix'] as int? ?? 0,
      type: $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['type']) ??
          SvtVoiceType.unknown,
      voiceLines: (json['voiceLines'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

NiceLore _$NiceLoreFromJson(Map json) => NiceLore(
      cv: json['cv'] as String? ?? '',
      illustrator: json['illustrator'] as String? ?? '',
      stats: json['stats'] == null
          ? null
          : LoreStatus.fromJson(
              Map<String, dynamic>.from(json['stats'] as Map)),
      costume: (json['costume'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String),
                NiceCostume.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) =>
                  LoreComment.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voices: (json['voices'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

ServantScript _$ServantScriptFromJson(Map json) => ServantScript(
      skillRankUp: (json['SkillRankUp'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      svtBuffTurnExtend: json['svtBuffTurnExtend'] as bool?,
    );
