// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/servant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicServant _$BasicServantFromJson(Map json) => BasicServant(
  id: (json['id'] as num).toInt(),
  collectionNo: (json['collectionNo'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? "",
  overwriteName: json['overwriteName'] as String?,
  type: $enumDecodeNullable(_$SvtTypeEnumMap, json['type']) ?? SvtType.normal,
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SvtFlagEnumMap, e, unknownValue: SvtFlag.unknown))
          .toList() ??
      const [],
  classId: (json['classId'] as num?)?.toInt() ?? 0,
  attribute: $enumDecodeNullable(_$ServantSubAttributeEnumMap, json['attribute']) ?? ServantSubAttribute.none,
  rarity: (json['rarity'] as num?)?.toInt() ?? 0,
  atkMax: (json['atkMax'] as num?)?.toInt() ?? 0,
  hpMax: (json['hpMax'] as num?)?.toInt() ?? 0,
  face: json['face'] as String,
  costume:
      (json['costume'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), BasicCostume.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
);

Map<String, dynamic> _$BasicServantToJson(BasicServant instance) => <String, dynamic>{
  'id': instance.id,
  'collectionNo': instance.collectionNo,
  'name': instance.name,
  'overwriteName': instance.overwriteName,
  'type': _$SvtTypeEnumMap[instance.type]!,
  'flags': instance.flags.map((e) => _$SvtFlagEnumMap[e]!).toList(),
  'classId': instance.classId,
  'attribute': _$ServantSubAttributeEnumMap[instance.attribute]!,
  'rarity': instance.rarity,
  'atkMax': instance.atkMax,
  'hpMax': instance.hpMax,
  'face': instance.face,
  'costume': instance.costume.map((k, e) => MapEntry(k.toString(), e.toJson())),
};

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
  SvtFlag.unknown: 'unknown',
  SvtFlag.onlyUseForNpc: 'onlyUseForNpc',
  SvtFlag.svtEquipFriendShip: 'svtEquipFriendShip',
  SvtFlag.ignoreCombineLimitSpecial: 'ignoreCombineLimitSpecial',
  SvtFlag.svtEquipExp: 'svtEquipExp',
  SvtFlag.svtEquipChocolate: 'svtEquipChocolate',
  SvtFlag.svtEquipManaExchange: 'svtEquipManaExchange',
  SvtFlag.svtEquipCampaign: 'svtEquipCampaign',
  SvtFlag.svtEquipEvent: 'svtEquipEvent',
  SvtFlag.svtEquipEventReward: 'svtEquipEventReward',
};

const _$ServantSubAttributeEnumMap = {
  ServantSubAttribute.default_: 'default',
  ServantSubAttribute.none: 'none',
  ServantSubAttribute.human: 'human',
  ServantSubAttribute.sky: 'sky',
  ServantSubAttribute.earth: 'earth',
  ServantSubAttribute.star: 'star',
  ServantSubAttribute.beast: 'beast',
  ServantSubAttribute.void_: 'void',
};

Servant _$ServantFromJson(Map json) => Servant(
  id: (json['id'] as num).toInt(),
  collectionNo: (json['collectionNo'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? "",
  ruby: json['ruby'] as String? ?? "",
  battleName: json['battleName'] as String? ?? "",
  classId: (json['classId'] as num?)?.toInt() ?? 0,
  type: $enumDecodeNullable(_$SvtTypeEnumMap, json['type']) ?? SvtType.normal,
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SvtFlagEnumMap, e, unknownValue: SvtFlag.unknown))
          .toList() ??
      const [],
  rarity: (json['rarity'] as num?)?.toInt() ?? 0,
  cost: (json['cost'] as num?)?.toInt() ?? 0,
  lvMax: (json['lvMax'] as num?)?.toInt() ?? 0,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']) ?? Gender.unknown,
  attribute: $enumDecodeNullable(_$ServantSubAttributeEnumMap, json['attribute']) ?? ServantSubAttribute.none,
  atkBase: (json['atkBase'] as num?)?.toInt() ?? 0,
  atkMax: (json['atkMax'] as num?)?.toInt() ?? 0,
  hpBase: (json['hpBase'] as num?)?.toInt() ?? 0,
  hpMax: (json['hpMax'] as num?)?.toInt() ?? 0,
  extraAssets:
      json['extraAssets'] == null ? null : ExtraAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
  traits:
      (json['traits'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  criticalWeight: (json['starAbsorb'] as num?)?.toInt() ?? 0,
  starGen: (json['starGen'] as num?)?.toInt() ?? 0,
  instantDeathChance: (json['instantDeathChance'] as num?)?.toInt() ?? 0,
  cards: (json['cards'] as List<dynamic>?)?.map(const CardTypeConverter().fromJson).toList() ?? const [],
  cardDetails:
      (json['cardDetails'] as Map?)?.map(
        (k, e) =>
            MapEntry(const CardTypeConverter().fromJson(k), CardDetail.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  relateQuestIds: (json['relateQuestIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  trialQuestIds: (json['trialQuestIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  growthCurve: (json['growthCurve'] as num?)?.toInt() ?? 0,
  bondGrowth: (json['bondGrowth'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  expFeed: (json['expFeed'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  bondEquip: (json['bondEquip'] as num?)?.toInt() ?? 0,
  valentineEquip: (json['valentineEquip'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  valentineScript:
      (json['valentineScript'] as List<dynamic>?)
          ?.map((e) => ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  bondEquipOwner: (json['bondEquipOwner'] as num?)?.toInt(),
  valentineEquipOwner: (json['valentineEquipOwner'] as num?)?.toInt(),
  limits:
      (Servant._readLimits(json, 'limits') as List<dynamic>?)
          ?.map((e) => SvtLimitEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
  ascensionAdd:
      json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
  traitAdd:
      (json['traitAdd'] as List<dynamic>?)
          ?.map((e) => ServantTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  svtChange:
      (json['svtChange'] as List<dynamic>?)
          ?.map((e) => ServantChange.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  ascensionImage:
      (json['ascensionImage'] as List<dynamic>?)
          ?.map((e) => ServantLimitImage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  overwrites:
      (json['overwrites'] as List<dynamic>?)
          ?.map((e) => SvtOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  ascensionMaterials:
      (json['ascensionMaterials'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  skillMaterials:
      (json['skillMaterials'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  appendSkillMaterials:
      (json['appendSkillMaterials'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  costumeMaterials:
      (json['costumeMaterials'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  coin: json['coin'] == null ? null : ServantCoin.fromJson(Map<String, dynamic>.from(json['coin'] as Map)),
  script: json['script'] == null ? null : ServantScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  charaScripts:
      (json['charaScripts'] as List<dynamic>?)
          ?.map((e) => SvtScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  battlePoints:
      (json['battlePoints'] as List<dynamic>?)
          ?.map((e) => BattlePoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  skills:
      (json['skills'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  classPassive:
      (json['classPassive'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  extraPassive:
      (json['extraPassive'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  appendPassive:
      (json['appendPassive'] as List<dynamic>?)
          ?.map((e) => ServantAppendPassiveSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  noblePhantasms:
      (json['noblePhantasms'] as List<dynamic>?)
          ?.map((e) => NiceTd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  profile: json['profile'] == null ? null : NiceLore.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
  face: json['face'] as String? ?? "",
  overwriteName: json['overwriteName'] as String?,
  costume:
      (json['costume'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), BasicCostume.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
);

Map<String, dynamic> _$ServantToJson(Servant instance) => <String, dynamic>{
  'id': instance.id,
  'collectionNo': instance.collectionNo,
  'name': instance.name,
  'overwriteName': instance.overwriteName,
  'type': _$SvtTypeEnumMap[instance.type]!,
  'flags': instance.flags.map((e) => _$SvtFlagEnumMap[e]!).toList(),
  'classId': instance.classId,
  'attribute': _$ServantSubAttributeEnumMap[instance.attribute]!,
  'rarity': instance.rarity,
  'atkMax': instance.atkMax,
  'hpMax': instance.hpMax,
  'ruby': instance.ruby,
  'battleName': instance.battleName,
  'cost': instance.cost,
  'lvMax': instance.lvMax,
  'extraAssets': instance.extraAssets.toJson(),
  'gender': _$GenderEnumMap[instance.gender]!,
  'traits': instance.traits.map((e) => e.toJson()).toList(),
  'starAbsorb': instance.criticalWeight,
  'starGen': instance.starGen,
  'instantDeathChance': instance.instantDeathChance,
  'cards': instance.cards.map(const CardTypeConverter().toJson).toList(),
  'cardDetails': instance.cardDetails.map((k, e) => MapEntry(const CardTypeConverter().toJson(k), e.toJson())),
  'atkBase': instance.atkBase,
  'hpBase': instance.hpBase,
  'relateQuestIds': instance.relateQuestIds,
  'trialQuestIds': instance.trialQuestIds,
  'growthCurve': instance.growthCurve,
  'bondGrowth': instance.bondGrowth,
  'expFeed': instance.expFeed,
  'bondEquip': instance.bondEquip,
  'valentineEquip': instance.valentineEquip,
  'valentineScript': instance.valentineScript.map((e) => e.toJson()).toList(),
  'bondEquipOwner': instance.bondEquipOwner,
  'valentineEquipOwner': instance.valentineEquipOwner,
  'limits': instance.limits.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'ascensionAdd': instance.ascensionAdd.toJson(),
  'traitAdd': instance.traitAdd.map((e) => e.toJson()).toList(),
  'svtChange': instance.svtChange.map((e) => e.toJson()).toList(),
  'ascensionImage': instance.ascensionImage.map((e) => e.toJson()).toList(),
  'overwrites': instance.overwrites.map((e) => e.toJson()).toList(),
  'ascensionMaterials': instance.ascensionMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'skillMaterials': instance.skillMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'appendSkillMaterials': instance.appendSkillMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'costumeMaterials': instance.costumeMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'coin': instance.coin?.toJson(),
  'script': instance.script?.toJson(),
  'charaScripts': instance.charaScripts.map((e) => e.toJson()).toList(),
  'battlePoints': instance.battlePoints.map((e) => e.toJson()).toList(),
  'skills': instance.skills.map((e) => e.toJson()).toList(),
  'classPassive': instance.classPassive.map((e) => e.toJson()).toList(),
  'extraPassive': instance.extraPassive.map((e) => e.toJson()).toList(),
  'appendPassive': instance.appendPassive.map((e) => e.toJson()).toList(),
  'noblePhantasms': instance.noblePhantasms.map((e) => e.toJson()).toList(),
  'profile': instance.profile.toJson(),
  'face': instance.face,
  'costume': instance.costume.map((k, e) => MapEntry(k.toString(), e.toJson())),
};

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female', Gender.unknown: 'unknown'};

BasicCraftEssence _$BasicCraftEssenceFromJson(Map json) => BasicCraftEssence(
  id: (json['id'] as num).toInt(),
  collectionNo: (json['collectionNo'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  type: $enumDecodeNullable(_$SvtTypeEnumMap, json['type']) ?? SvtType.servantEquip,
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SvtFlagEnumMap, e, unknownValue: SvtFlag.unknown))
          .toList() ??
      const [],
  rarity: (json['rarity'] as num?)?.toInt() ?? 0,
  atkMax: (json['atkMax'] as num?)?.toInt() ?? 0,
  hpMax: (json['hpMax'] as num?)?.toInt() ?? 0,
  face: json['face'] as String?,
);

Map<String, dynamic> _$BasicCraftEssenceToJson(BasicCraftEssence instance) => <String, dynamic>{
  'id': instance.id,
  'collectionNo': instance.collectionNo,
  'name': instance.name,
  'type': _$SvtTypeEnumMap[instance.type]!,
  'flags': instance.flags.map((e) => _$SvtFlagEnumMap[e]!).toList(),
  'rarity': instance.rarity,
  'atkMax': instance.atkMax,
  'hpMax': instance.hpMax,
  'face': instance.face,
};

CraftEssence _$CraftEssenceFromJson(Map json) => CraftEssence(
  id: (json['id'] as num).toInt(),
  sortId: (json['sortId'] as num?)?.toDouble(),
  collectionNo: (json['collectionNo'] as num?)?.toInt() ?? 0,
  name: json['name'] as String,
  ruby: json['ruby'] as String? ?? "",
  type: $enumDecodeNullable(_$SvtTypeEnumMap, json['type']) ?? SvtType.servantEquip,
  flags:
      (json['flags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SvtFlagEnumMap, e, unknownValue: SvtFlag.unknown))
          .toList() ??
      const [],
  rarity: (json['rarity'] as num?)?.toInt() ?? 0,
  cost: (json['cost'] as num?)?.toInt() ?? 0,
  lvMax: (json['lvMax'] as num?)?.toInt() ?? 0,
  extraAssets:
      json['extraAssets'] == null ? null : ExtraAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
  atkBase: (json['atkBase'] as num?)?.toInt() ?? 0,
  atkMax: (json['atkMax'] as num?)?.toInt() ?? 0,
  hpBase: (json['hpBase'] as num?)?.toInt() ?? 0,
  hpMax: (json['hpMax'] as num?)?.toInt() ?? 0,
  growthCurve: (json['growthCurve'] as num?)?.toInt() ?? 0,
  expFeed: (json['expFeed'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  bondEquipOwner: (json['bondEquipOwner'] as num?)?.toInt(),
  valentineEquipOwner: (json['valentineEquipOwner'] as num?)?.toInt(),
  valentineScript:
      (json['valentineScript'] as List<dynamic>?)
          ?.map((e) => ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  ascensionAdd:
      json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
  script: json['script'] == null ? null : ServantScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  skills:
      (json['skills'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  profile: json['profile'] == null ? null : NiceLore.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
  face: json['face'] as String? ?? "",
);

Map<String, dynamic> _$CraftEssenceToJson(CraftEssence instance) => <String, dynamic>{
  'id': instance.id,
  'collectionNo': instance.collectionNo,
  'name': instance.name,
  'type': _$SvtTypeEnumMap[instance.type]!,
  'flags': instance.flags.map((e) => _$SvtFlagEnumMap[e]!).toList(),
  'rarity': instance.rarity,
  'atkMax': instance.atkMax,
  'hpMax': instance.hpMax,
  'sortId': instance.sortId,
  'ruby': instance.ruby,
  'cost': instance.cost,
  'lvMax': instance.lvMax,
  'extraAssets': instance.extraAssets.toJson(),
  'atkBase': instance.atkBase,
  'hpBase': instance.hpBase,
  'growthCurve': instance.growthCurve,
  'expFeed': instance.expFeed,
  'bondEquipOwner': instance.bondEquipOwner,
  'valentineEquipOwner': instance.valentineEquipOwner,
  'valentineScript': instance.valentineScript.map((e) => e.toJson()).toList(),
  'ascensionAdd': instance.ascensionAdd.toJson(),
  'script': instance.script?.toJson(),
  'skills': instance.skills.map((e) => e.toJson()).toList(),
  'profile': instance.profile.toJson(),
  'face': instance.face,
};

ExtraAssetsUrl _$ExtraAssetsUrlFromJson(Map json) => ExtraAssetsUrl(
  ascension: (json['ascension'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
  story: (json['story'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
  costume: (json['costume'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
  equip: (json['equip'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
  cc: (json['cc'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
  imagePartsGroup: (json['imagePartsGroup'] as Map?)?.map((k, e) => MapEntry(k as String, e as String)),
);

Map<String, dynamic> _$ExtraAssetsUrlToJson(ExtraAssetsUrl instance) => <String, dynamic>{
  'ascension': instance.ascension?.map((k, e) => MapEntry(k.toString(), e)),
  'story': instance.story?.map((k, e) => MapEntry(k.toString(), e)),
  'costume': instance.costume?.map((k, e) => MapEntry(k.toString(), e)),
  'equip': instance.equip?.map((k, e) => MapEntry(k.toString(), e)),
  'cc': instance.cc?.map((k, e) => MapEntry(k.toString(), e)),
  'imagePartsGroup': instance.imagePartsGroup,
};

ExtraCCAssets _$ExtraCCAssetsFromJson(Map json) => ExtraCCAssets(
  charaGraph: ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraph'] as Map)),
  faces: ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['faces'] as Map)),
);

Map<String, dynamic> _$ExtraCCAssetsToJson(ExtraCCAssets instance) => <String, dynamic>{
  'charaGraph': instance.charaGraph.toJson(),
  'faces': instance.faces.toJson(),
};

ExtraAssets _$ExtraAssetsFromJson(Map json) => ExtraAssets(
  charaGraph:
      json['charaGraph'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraph'] as Map)),
  faces:
      json['faces'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['faces'] as Map)),
  charaGraphEx:
      json['charaGraphEx'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphEx'] as Map)),
  charaGraphName:
      json['charaGraphName'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphName'] as Map)),
  narrowFigure:
      json['narrowFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['narrowFigure'] as Map)),
  charaFigure:
      json['charaFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaFigure'] as Map)),
  charaFigureForm:
      (json['charaFigureForm'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  charaFigureMulti:
      (json['charaFigureMulti'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  charaFigureMultiCombine:
      (json['charaFigureMultiCombine'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  charaFigureMultiLimitUp:
      (json['charaFigureMultiLimitUp'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  commands:
      json['commands'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['commands'] as Map)),
  status:
      json['status'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['status'] as Map)),
  equipFace:
      json['equipFace'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['equipFace'] as Map)),
  image:
      json['image'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['image'] as Map)),
  spriteModel:
      json['spriteModel'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['spriteModel'] as Map)),
  charaGraphChange:
      json['charaGraphChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
  narrowFigureChange:
      json['narrowFigureChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['narrowFigureChange'] as Map)),
  facesChange:
      json['facesChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['facesChange'] as Map)),
);

Map<String, dynamic> _$ExtraAssetsToJson(ExtraAssets instance) => <String, dynamic>{
  'charaGraph': instance.charaGraph.toJson(),
  'faces': instance.faces.toJson(),
  'charaGraphEx': instance.charaGraphEx.toJson(),
  'charaGraphName': instance.charaGraphName.toJson(),
  'narrowFigure': instance.narrowFigure.toJson(),
  'charaFigure': instance.charaFigure.toJson(),
  'charaFigureForm': instance.charaFigureForm.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'charaFigureMulti': instance.charaFigureMulti.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'charaFigureMultiCombine': instance.charaFigureMultiCombine.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'charaFigureMultiLimitUp': instance.charaFigureMultiLimitUp.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'commands': instance.commands.toJson(),
  'status': instance.status.toJson(),
  'equipFace': instance.equipFace.toJson(),
  'image': instance.image.toJson(),
  'spriteModel': instance.spriteModel.toJson(),
  'charaGraphChange': instance.charaGraphChange.toJson(),
  'narrowFigureChange': instance.narrowFigureChange.toJson(),
  'facesChange': instance.facesChange.toJson(),
};

CardDetail _$CardDetailFromJson(Map json) => CardDetail(
  hitsDistribution: (json['hitsDistribution'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  attackIndividuality:
      (json['attackIndividuality'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  attackType: $enumDecodeNullable(_$CommandCardAttackTypeEnumMap, json['attackType']) ?? CommandCardAttackType.one,
  damageRate: (json['damageRate'] as num?)?.toInt(),
  attackNpRate: (json['attackNpRate'] as num?)?.toInt(),
  defenseNpRate: (json['defenseNpRate'] as num?)?.toInt(),
  dropStarRate: (json['dropStarRate'] as num?)?.toInt(),
  positionDamageRates: (json['positionDamageRates'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
  positionDamageRatesSlideType: $enumDecodeNullable(
    _$SvtCardPositionDamageRatesSlideTypeEnumMap,
    json['positionDamageRatesSlideType'],
  ),
);

Map<String, dynamic> _$CardDetailToJson(CardDetail instance) => <String, dynamic>{
  'hitsDistribution': instance.hitsDistribution,
  'attackIndividuality': instance.attackIndividuality.map((e) => e.toJson()).toList(),
  'attackType': _$CommandCardAttackTypeEnumMap[instance.attackType]!,
  'damageRate': instance.damageRate,
  'attackNpRate': instance.attackNpRate,
  'defenseNpRate': instance.defenseNpRate,
  'dropStarRate': instance.dropStarRate,
  'positionDamageRates': instance.positionDamageRates,
  'positionDamageRatesSlideType': _$SvtCardPositionDamageRatesSlideTypeEnumMap[instance.positionDamageRatesSlideType],
};

const _$CommandCardAttackTypeEnumMap = {CommandCardAttackType.one: 'one', CommandCardAttackType.all: 'all'};

const _$SvtCardPositionDamageRatesSlideTypeEnumMap = {
  SvtCardPositionDamageRatesSlideType.none: 'none',
  SvtCardPositionDamageRatesSlideType.front: 'front',
  SvtCardPositionDamageRatesSlideType.back: 'back',
};

SvtLimitEntity _$SvtLimitEntityFromJson(Map json) => SvtLimitEntity(
  limitCount: (json['limitCount'] as num).toInt(),
  rarity: (json['rarity'] as num?)?.toInt(),
  lvMax: (json['lvMax'] as num?)?.toInt(),
  hpBase: (json['hpBase'] as num?)?.toInt(),
  hpMax: (json['hpMax'] as num?)?.toInt(),
  atkBase: (json['atkBase'] as num?)?.toInt(),
  atkMax: (json['atkMax'] as num?)?.toInt(),
  criticalWeight: (json['criticalWeight'] as num?)?.toInt(),
  strength: json['strength'] as String?,
  endurance: json['endurance'] as String?,
  agility: json['agility'] as String?,
  magic: json['magic'] as String?,
  luck: json['luck'] as String?,
  np: json['np'] as String?,
  deity: json['deity'] as String?,
  policy: $enumDecodeNullable(_$ServantPolicyEnumMap, json['policy']),
  personality: $enumDecodeNullable(_$ServantPersonalityEnumMap, json['personality']),
);

Map<String, dynamic> _$SvtLimitEntityToJson(SvtLimitEntity instance) => <String, dynamic>{
  'limitCount': instance.limitCount,
  'rarity': instance.rarity,
  'lvMax': instance.lvMax,
  'hpBase': instance.hpBase,
  'hpMax': instance.hpMax,
  'atkBase': instance.atkBase,
  'atkMax': instance.atkMax,
  'criticalWeight': instance.criticalWeight,
  'strength': instance.strength,
  'endurance': instance.endurance,
  'agility': instance.agility,
  'magic': instance.magic,
  'luck': instance.luck,
  'np': instance.np,
  'deity': instance.deity,
  'policy': _$ServantPolicyEnumMap[instance.policy],
  'personality': _$ServantPersonalityEnumMap[instance.personality],
};

const _$ServantPolicyEnumMap = {
  ServantPolicy.none: 'none',
  ServantPolicy.neutral: 'neutral',
  ServantPolicy.chaotic: 'chaotic',
  ServantPolicy.lawful: 'lawful',
  ServantPolicy.unknown: 'unknown',
};

const _$ServantPersonalityEnumMap = {
  ServantPersonality.none: 'none',
  ServantPersonality.good: 'good',
  ServantPersonality.evil: 'evil',
  ServantPersonality.madness: 'madness',
  ServantPersonality.balanced: 'balanced',
  ServantPersonality.goodAndEvil: 'goodAndEvil',
  ServantPersonality.bride: 'bride',
  ServantPersonality.summer: 'summer',
  ServantPersonality.beast: 'beast',
  ServantPersonality.unknown: 'unknown',
};

AscensionAddEntry<T> _$AscensionAddEntryFromJson<T>(Map json, T Function(Object? json) fromJsonT) =>
    AscensionAddEntry<T>(
      ascension: (json['ascension'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), fromJsonT(e))) ?? const {},
      costume: (json['costume'] as Map?)?.map((k, e) => MapEntry(int.parse(k as String), fromJsonT(e))) ?? const {},
    );

Map<String, dynamic> _$AscensionAddEntryToJson<T>(AscensionAddEntry<T> instance, Object? Function(T value) toJsonT) =>
    <String, dynamic>{
      'ascension': instance.ascension.map((k, e) => MapEntry(k.toString(), toJsonT(e))),
      'costume': instance.costume.map((k, e) => MapEntry(k.toString(), toJsonT(e))),
    };

AscensionAdd _$AscensionAddFromJson(Map json) => AscensionAdd(
  attribute:
      json['attribute'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<ServantSubAttribute>.fromJson(Map<String, dynamic>.from(json['attribute'] as Map)),
  individuality:
      json['individuality'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<NiceTrait>>.fromJson(Map<String, dynamic>.from(json['individuality'] as Map)),
  voicePrefix:
      json['voicePrefix'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<int>.fromJson(Map<String, dynamic>.from(json['voicePrefix'] as Map)),
  overWriteServantName:
      json['overWriteServantName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteServantName'] as Map)),
  overWriteServantBattleName:
      json['overWriteServantBattleName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteServantBattleName'] as Map)),
  overWriteTDName:
      json['overWriteTDName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDName'] as Map)),
  overWriteTDRuby:
      json['overWriteTDRuby'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDRuby'] as Map)),
  overWriteTDFileName:
      json['overWriteTDFileName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDFileName'] as Map)),
  overWriteTDRank:
      json['overWriteTDRank'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDRank'] as Map)),
  overWriteTDTypeText:
      json['overWriteTDTypeText'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDTypeText'] as Map)),
  lvMax:
      json['lvMax'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<int>.fromJson(Map<String, dynamic>.from(json['lvMax'] as Map)),
  charaGraphChange:
      json['charaGraphChange'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
  faceChange:
      json['faceChange'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['faceChange'] as Map)),
  charaGraphChangeCommonRelease:
      json['charaGraphChangeCommonRelease'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<CommonRelease>>.fromJson(
            Map<String, dynamic>.from(json['charaGraphChangeCommonRelease'] as Map),
          ),
  faceChangeCommonRelease:
      json['faceChangeCommonRelease'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<CommonRelease>>.fromJson(
            Map<String, dynamic>.from(json['faceChangeCommonRelease'] as Map),
          ),
);

Map<String, dynamic> _$AscensionAddToJson(AscensionAdd instance) => <String, dynamic>{
  'attribute': instance.attribute.toJson(),
  'individuality': instance.individuality.toJson(),
  'voicePrefix': instance.voicePrefix.toJson(),
  'overWriteServantName': instance.overWriteServantName.toJson(),
  'overWriteServantBattleName': instance.overWriteServantBattleName.toJson(),
  'overWriteTDName': instance.overWriteTDName.toJson(),
  'overWriteTDRuby': instance.overWriteTDRuby.toJson(),
  'overWriteTDFileName': instance.overWriteTDFileName.toJson(),
  'overWriteTDRank': instance.overWriteTDRank.toJson(),
  'overWriteTDTypeText': instance.overWriteTDTypeText.toJson(),
  'lvMax': instance.lvMax.toJson(),
  'charaGraphChange': instance.charaGraphChange.toJson(),
  'faceChange': instance.faceChange.toJson(),
  'charaGraphChangeCommonRelease': instance.charaGraphChangeCommonRelease.toJson(),
  'faceChangeCommonRelease': instance.faceChangeCommonRelease.toJson(),
};

ServantChange _$ServantChangeFromJson(Map json) => ServantChange(
  beforeTreasureDeviceIds: (json['beforeTreasureDeviceIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  afterTreasureDeviceIds: (json['afterTreasureDeviceIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  svtId: (json['svtId'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  condType: const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num).toInt(),
  condValue: (json['condValue'] as num).toInt(),
  name: json['name'] as String,
  ruby: json['ruby'] as String? ?? "",
  battleName: json['battleName'] as String? ?? "",
  svtVoiceId: (json['svtVoiceId'] as num).toInt(),
  limitCount: (json['limitCount'] as num).toInt(),
  flag: (json['flag'] as num).toInt(),
  battleSvtId: (json['battleSvtId'] as num).toInt(),
);

Map<String, dynamic> _$ServantChangeToJson(ServantChange instance) => <String, dynamic>{
  'beforeTreasureDeviceIds': instance.beforeTreasureDeviceIds,
  'afterTreasureDeviceIds': instance.afterTreasureDeviceIds,
  'svtId': instance.svtId,
  'priority': instance.priority,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condValue': instance.condValue,
  'name': instance.name,
  'ruby': instance.ruby,
  'battleName': instance.battleName,
  'svtVoiceId': instance.svtVoiceId,
  'limitCount': instance.limitCount,
  'flag': instance.flag,
  'battleSvtId': instance.battleSvtId,
};

ServantLimitImage _$ServantLimitImageFromJson(Map json) => ServantLimitImage(
  limitCount: (json['limitCount'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  defaultLimitCount: (json['defaultLimitCount'] as num).toInt(),
  condType: const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num).toInt(),
  condNum: (json['condNum'] as num).toInt(),
);

Map<String, dynamic> _$ServantLimitImageToJson(ServantLimitImage instance) => <String, dynamic>{
  'limitCount': instance.limitCount,
  'priority': instance.priority,
  'defaultLimitCount': instance.defaultLimitCount,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condNum': instance.condNum,
};

ServantAppendPassiveSkill _$ServantAppendPassiveSkillFromJson(Map json) => ServantAppendPassiveSkill(
  num: (json['num'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  skill: NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
  unlockMaterials:
      (json['unlockMaterials'] as List<dynamic>)
          .map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
);

Map<String, dynamic> _$ServantAppendPassiveSkillToJson(ServantAppendPassiveSkill instance) => <String, dynamic>{
  'num': instance.num,
  'priority': instance.priority,
  'skill': instance.skill.toJson(),
  'unlockMaterials': instance.unlockMaterials.map((e) => e.toJson()).toList(),
};

ServantCoin _$ServantCoinFromJson(Map json) => ServantCoin(
  summonNum: (json['summonNum'] as num).toInt(),
  item: Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
);

Map<String, dynamic> _$ServantCoinToJson(ServantCoin instance) => <String, dynamic>{
  'summonNum': instance.summonNum,
  'item': instance.item.toJson(),
};

ServantTrait _$ServantTraitFromJson(Map json) => ServantTrait(
  idx: (json['idx'] as num).toInt(),
  trait:
      (json['trait'] as List<dynamic>?)?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  limitCount: (json['limitCount'] as num?)?.toInt() ?? -1,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condId: (json['condId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
  eventId: (json['eventId'] as num?)?.toInt() ?? 0,
  startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
  endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ServantTraitToJson(ServantTrait instance) => <String, dynamic>{
  'idx': instance.idx,
  'trait': instance.trait.map((e) => e.toJson()).toList(),
  'limitCount': instance.limitCount,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condId': instance.condId,
  'condNum': instance.condNum,
  'eventId': instance.eventId,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

LoreCommentAdd _$LoreCommentAddFromJson(Map json) => LoreCommentAdd(
  idx: (json['idx'] as num).toInt(),
  condType: const CondTypeConverter().fromJson(json['condType'] as String),
  condValues: (json['condValues'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  condValue2: (json['condValue2'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LoreCommentAddToJson(LoreCommentAdd instance) => <String, dynamic>{
  'idx': instance.idx,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condValues': instance.condValues,
  'condValue2': instance.condValue2,
};

LoreComment _$LoreCommentFromJson(Map json) => LoreComment(
  id: (json['id'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  condMessage: json['condMessage'] as String? ?? "",
  comment: json['comment'] as String? ?? '',
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condValues: (json['condValues'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
  condValue2: (json['condValue2'] as num?)?.toInt() ?? 0,
  additionalConds:
      (json['additionalConds'] as List<dynamic>?)
          ?.map((e) => LoreCommentAdd.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LoreCommentToJson(LoreComment instance) => <String, dynamic>{
  'id': instance.id,
  'priority': instance.priority,
  'condMessage': instance.condMessage,
  'comment': instance.comment,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condValues': instance.condValues,
  'condValue2': instance.condValue2,
  'additionalConds': instance.additionalConds.map((e) => e.toJson()).toList(),
};

LoreStatus _$LoreStatusFromJson(Map json) => LoreStatus(
  strength: json['strength'] as String?,
  endurance: json['endurance'] as String?,
  agility: json['agility'] as String?,
  magic: json['magic'] as String?,
  luck: json['luck'] as String?,
  np: json['np'] as String?,
  policy: $enumDecodeNullable(_$ServantPolicyEnumMap, json['policy']),
  personality: $enumDecodeNullable(_$ServantPersonalityEnumMap, json['personality']),
  deity: json['deity'] as String?,
);

Map<String, dynamic> _$LoreStatusToJson(LoreStatus instance) => <String, dynamic>{
  'strength': instance.strength,
  'endurance': instance.endurance,
  'agility': instance.agility,
  'magic': instance.magic,
  'luck': instance.luck,
  'np': instance.np,
  'policy': _$ServantPolicyEnumMap[instance.policy],
  'personality': _$ServantPersonalityEnumMap[instance.personality],
  'deity': instance.deity,
};

BasicCostume _$BasicCostumeFromJson(Map json) => BasicCostume(
  id: (json['id'] as num).toInt(),
  costumeCollectionNo: (json['costumeCollectionNo'] as num?)?.toInt() ?? 0,
  battleCharaId: (json['battleCharaId'] as num).toInt(),
  name: json['name'] as String? ?? "",
  shortName: json['shortName'] as String? ?? "",
);

Map<String, dynamic> _$BasicCostumeToJson(BasicCostume instance) => <String, dynamic>{
  'id': instance.id,
  'costumeCollectionNo': instance.costumeCollectionNo,
  'battleCharaId': instance.battleCharaId,
  'name': instance.name,
  'shortName': instance.shortName,
};

NiceCostume _$NiceCostumeFromJson(Map json) => NiceCostume(
  id: (json['id'] as num).toInt(),
  costumeCollectionNo: (json['costumeCollectionNo'] as num?)?.toInt() ?? 0,
  battleCharaId: (json['battleCharaId'] as num).toInt(),
  name: json['name'] as String? ?? "",
  shortName: json['shortName'] as String? ?? "",
  detail: json['detail'] as String? ?? "",
  priority: (json['priority'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NiceCostumeToJson(NiceCostume instance) => <String, dynamic>{
  'id': instance.id,
  'costumeCollectionNo': instance.costumeCollectionNo,
  'battleCharaId': instance.battleCharaId,
  'name': instance.name,
  'shortName': instance.shortName,
  'detail': instance.detail,
  'priority': instance.priority,
};

VoiceCond _$VoiceCondFromJson(Map json) => VoiceCond(
  condType: $enumDecodeNullable(_$VoiceCondTypeEnumMap, json['condType']) ?? VoiceCondType.unknown,
  value: (json['value'] as num).toInt(),
  valueList: (json['valueList'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  eventId: (json['eventId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VoiceCondToJson(VoiceCond instance) => <String, dynamic>{
  'condType': _$VoiceCondTypeEnumMap[instance.condType]!,
  'value': instance.value,
  'valueList': instance.valueList,
  'eventId': instance.eventId,
};

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
  condGroup: (json['condGroup'] as num).toInt(),
  condType: const CondTypeConverter().fromJson(json['condType'] as String),
  targetId: (json['targetId'] as num).toInt(),
  condValue: (json['condValue'] as num).toInt(),
  condValues: (json['condValues'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
);

Map<String, dynamic> _$VoicePlayCondToJson(VoicePlayCond instance) => <String, dynamic>{
  'condGroup': instance.condGroup,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'targetId': instance.targetId,
  'condValue': instance.condValue,
  'condValues': instance.condValues,
};

VoiceLine _$VoiceLineFromJson(Map json) => VoiceLine(
  name: json['name'] as String?,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condValue: (json['condValue'] as num?)?.toInt() ?? 0,
  priority: (json['priority'] as num?)?.toInt(),
  svtVoiceType: $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['svtVoiceType']) ?? SvtVoiceType.unknown,
  overwriteName: json['overwriteName'] as String? ?? "",
  summonScript:
      json['summonScript'] == null ? null : ScriptLink.fromJson(Map<String, dynamic>.from(json['summonScript'] as Map)),
  id: (json['id'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  audioAssets: (json['audioAssets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  delay: (json['delay'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? const [],
  face: (json['face'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  form: (json['form'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  text: (json['text'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  subtitle: json['subtitle'] as String? ?? "",
  conds:
      (json['conds'] as List<dynamic>?)?.map((e) => VoiceCond.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  playConds:
      (json['playConds'] as List<dynamic>?)
          ?.map((e) => VoicePlayCond.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$VoiceLineToJson(VoiceLine instance) => <String, dynamic>{
  'name': instance.name,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condValue': instance.condValue,
  'priority': instance.priority,
  'svtVoiceType': _$SvtVoiceTypeEnumMap[instance.svtVoiceType]!,
  'overwriteName': instance.overwriteName,
  'summonScript': instance.summonScript?.toJson(),
  'id': instance.id,
  'audioAssets': instance.audioAssets,
  'delay': instance.delay,
  'face': instance.face,
  'form': instance.form,
  'text': instance.text,
  'subtitle': instance.subtitle,
  'conds': instance.conds.map((e) => e.toJson()).toList(),
  'playConds': instance.playConds.map((e) => e.toJson()).toList(),
};

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
  SvtVoiceType.eventTrade: 'eventTrade',
  SvtVoiceType.sum: 'sum',
};

VoiceGroup _$VoiceGroupFromJson(Map json) => VoiceGroup(
  svtId: (json['svtId'] as num).toInt(),
  voicePrefix: (json['voicePrefix'] as num?)?.toInt() ?? 0,
  type: $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['type']) ?? SvtVoiceType.unknown,
  voiceLines:
      (json['voiceLines'] as List<dynamic>?)
          ?.map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$VoiceGroupToJson(VoiceGroup instance) => <String, dynamic>{
  'svtId': instance.svtId,
  'voicePrefix': instance.voicePrefix,
  'type': _$SvtVoiceTypeEnumMap[instance.type]!,
  'voiceLines': instance.voiceLines.map((e) => e.toJson()).toList(),
};

NiceLore _$NiceLoreFromJson(Map json) => NiceLore(
  cv: json['cv'] as String? ?? '',
  illustrator: json['illustrator'] as String? ?? '',
  stats: json['stats'] == null ? null : LoreStatus.fromJson(Map<String, dynamic>.from(json['stats'] as Map)),
  costume:
      (json['costume'] as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), NiceCostume.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => LoreComment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  voices:
      (json['voices'] as List<dynamic>?)
          ?.map((e) => VoiceGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$NiceLoreToJson(NiceLore instance) => <String, dynamic>{
  'cv': instance.cv,
  'illustrator': instance.illustrator,
  'stats': instance.stats?.toJson(),
  'costume': instance.costume.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'comments': instance.comments.map((e) => e.toJson()).toList(),
  'voices': instance.voices.map((e) => e.toJson()).toList(),
};

ServantScript _$ServantScriptFromJson(Map json) => ServantScript(
  skillRankUp: (json['SkillRankUp'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
  ),
  svtBuffTurnExtend: json['svtBuffTurnExtend'] as bool?,
  maleImage:
      json['maleImage'] == null ? null : ExtraAssets.fromJson(Map<String, dynamic>.from(json['maleImage'] as Map)),
);

Map<String, dynamic> _$ServantScriptToJson(ServantScript instance) => <String, dynamic>{
  'SkillRankUp': instance.skillRankUp?.map((k, e) => MapEntry(k.toString(), e)),
  'svtBuffTurnExtend': instance.svtBuffTurnExtend,
  'maleImage': instance.maleImage?.toJson(),
};

SvtScript _$SvtScriptFromJson(Map json) => SvtScript(
  extendData:
      json['extendData'] == null
          ? null
          : SvtScriptExtendData.fromJson(Map<String, dynamic>.from(json['extendData'] as Map)),
  id: (json['id'] as num).toInt(),
  form: (json['form'] as num?)?.toInt() ?? 0,
  faceX: (json['faceX'] as num?)?.toInt() ?? 0,
  faceY: (json['faceY'] as num?)?.toInt() ?? 0,
  bgImageId: (json['bgImageId'] as num?)?.toInt() ?? 0,
  scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  offsetX: (json['offsetX'] as num?)?.toInt() ?? 0,
  offsetY: (json['offsetY'] as num?)?.toInt() ?? 0,
  offsetXMyroom: (json['offsetXMyroom'] as num?)?.toInt() ?? 0,
  offsetYMyroom: (json['offsetYMyroom'] as num?)?.toInt() ?? 0,
  svtId: (json['svtId'] as num?)?.toInt(),
  limitCount: (json['limitCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$SvtScriptToJson(SvtScript instance) => <String, dynamic>{
  'extendData': instance.extendData?.toJson(),
  'id': instance.id,
  'form': instance.form,
  'faceX': instance.faceX,
  'faceY': instance.faceY,
  'bgImageId': instance.bgImageId,
  'scale': instance.scale,
  'offsetX': instance.offsetX,
  'offsetY': instance.offsetY,
  'offsetXMyroom': instance.offsetXMyroom,
  'offsetYMyroom': instance.offsetYMyroom,
  'svtId': instance.svtId,
  'limitCount': instance.limitCount,
};

SvtScriptExtendData _$SvtScriptExtendDataFromJson(Map json) => SvtScriptExtendData(
  faceSize: json['faceSize'],
  myroomForm: (json['myroomForm'] as num?)?.toInt(),
  combineResultMultipleForm: (json['combineResultMultipleForm'] as num?)?.toInt(),
  photoSvtPosition: (json['photoSvtPosition'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
  photoSvtScale: (json['photoSvtScale'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SvtScriptExtendDataToJson(SvtScriptExtendData instance) => <String, dynamic>{
  'faceSize': instance.faceSize,
  'myroomForm': instance.myroomForm,
  'combineResultMultipleForm': instance.combineResultMultipleForm,
  'photoSvtPosition': instance.photoSvtPosition,
  'photoSvtScale': instance.photoSvtScale,
};

SvtOverwriteValue _$SvtOverwriteValueFromJson(Map json) => SvtOverwriteValue(
  noblePhantasm:
      json['noblePhantasm'] == null ? null : NiceTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
);

Map<String, dynamic> _$SvtOverwriteValueToJson(SvtOverwriteValue instance) => <String, dynamic>{
  'noblePhantasm': instance.noblePhantasm?.toJson(),
};

SvtOverwrite _$SvtOverwriteFromJson(Map json) => SvtOverwrite(
  type: $enumDecodeNullable(_$ServantOverwriteTypeEnumMap, json['type']) ?? ServantOverwriteType.none,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  condType: json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
  condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
  condValue: (json['condValue'] as num?)?.toInt() ?? 0,
  overwriteValue:
      json['overwriteValue'] == null
          ? null
          : SvtOverwriteValue.fromJson(Map<String, dynamic>.from(json['overwriteValue'] as Map)),
);

Map<String, dynamic> _$SvtOverwriteToJson(SvtOverwrite instance) => <String, dynamic>{
  'type': _$ServantOverwriteTypeEnumMap[instance.type]!,
  'priority': instance.priority,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condTargetId': instance.condTargetId,
  'condValue': instance.condValue,
  'overwriteValue': instance.overwriteValue?.toJson(),
};

const _$ServantOverwriteTypeEnumMap = {
  ServantOverwriteType.none: 'none',
  ServantOverwriteType.treasureDevice: 'treasureDevice',
};

BattlePoint _$BattlePointFromJson(Map json) => BattlePoint(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  flags: (json['flags'] as List<dynamic>?)?.map((e) => $enumDecode(_$BattlePointFlagEnumMap, e)).toList() ?? const [],
  phases:
      (json['phases'] as List<dynamic>?)
          ?.map((e) => BattlePointPhase.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BattlePointToJson(BattlePoint instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'flags': instance.flags.map((e) => _$BattlePointFlagEnumMap[e]!).toList(),
  'phases': instance.phases.map((e) => e.toJson()).toList(),
};

const _$BattlePointFlagEnumMap = {
  BattlePointFlag.none: 'none',
  BattlePointFlag.notTargetOtherPlayer: 'notTargetOtherPlayer',
  BattlePointFlag.hideUiGaugeAllTime: 'hideUiGaugeAllTime',
  BattlePointFlag.hideUiGaugeWhenCantAddPoint: 'hideUiGaugeWhenCantAddPoint',
  BattlePointFlag.hideUiGaugeWhenCantAddPointAndFollowerSupport: 'hideUiGaugeWhenCantAddPointAndFollowerSupport',
};

BattlePointPhase _$BattlePointPhaseFromJson(Map json) => BattlePointPhase(
  phase: (json['phase'] as num).toInt(),
  value: (json['value'] as num).toInt(),
  name: json['name'] as String? ?? '',
  effectId: (json['effectId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BattlePointPhaseToJson(BattlePointPhase instance) => <String, dynamic>{
  'phase': instance.phase,
  'value': instance.value,
  'name': instance.name,
  'effectId': instance.effectId,
};
