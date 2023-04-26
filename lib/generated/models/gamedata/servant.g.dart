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

Map<String, dynamic> _$BasicCostumeToJson(BasicCostume instance) => <String, dynamic>{
      'id': instance.id,
      'costumeCollectionNo': instance.costumeCollectionNo,
      'battleCharaId': instance.battleCharaId,
      'shortName': instance.shortName,
    };

BasicServant _$BasicServantFromJson(Map json) => BasicServant(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      overwriteName: json['overwriteName'] as String?,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      classId: json['classId'] as int? ?? 0,
      attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
      rarity: json['rarity'] as int,
      atkMax: json['atkMax'] as int,
      hpMax: json['hpMax'] as int,
      face: json['face'] as String,
      costume: (json['costume'] as Map?)?.map(
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
      'flag': _$SvtFlagEnumMap[instance.flag]!,
      'classId': instance.classId,
      'attribute': _$AttributeEnumMap[instance.attribute]!,
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
      classId: json['classId'] as int? ?? 0,
      type: $enumDecode(_$SvtTypeEnumMap, json['type']),
      flag: $enumDecode(_$SvtFlagEnumMap, json['flag']),
      rarity: json['rarity'] as int,
      cost: json['cost'] as int,
      lvMax: json['lvMax'] as int,
      extraAssets: json['extraAssets'] == null
          ? null
          : ExtraAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      attribute: $enumDecode(_$AttributeEnumMap, json['attribute']),
      traits: (json['traits'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      starAbsorb: json['starAbsorb'] as int,
      starGen: json['starGen'] as int,
      instantDeathChance: json['instantDeathChance'] as int,
      cards: (json['cards'] as List<dynamic>).map((e) => $enumDecode(_$CardTypeEnumMap, e)).toList(),
      cardDetails: (json['cardDetails'] as Map).map(
        (k, e) => MapEntry($enumDecode(_$CardTypeEnumMap, k), CardDetail.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      relateQuestIds: (json['relateQuestIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      trialQuestIds: (json['trialQuestIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      growthCurve: json['growthCurve'] as int,
      bondGrowth: (json['bondGrowth'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      expFeed: (json['expFeed'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      bondEquip: json['bondEquip'] as int? ?? 0,
      valentineEquip: (json['valentineEquip'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      valentineScript: (json['valentineScript'] as List<dynamic>?)
              ?.map((e) => ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      ascensionAdd: json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      traitAdd: (json['traitAdd'] as List<dynamic>?)
              ?.map((e) => ServantTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      svtChange: (json['svtChange'] as List<dynamic>?)
              ?.map((e) => ServantChange.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ascensionImage: (json['ascensionImage'] as List<dynamic>?)
              ?.map((e) => ServantLimitImage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ascensionMaterials: (json['ascensionMaterials'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      skillMaterials: (json['skillMaterials'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      appendSkillMaterials: (json['appendSkillMaterials'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      costumeMaterials: (json['costumeMaterials'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), LvlUpMaterial.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      coin: json['coin'] == null ? null : ServantCoin.fromJson(Map<String, dynamic>.from(json['coin'] as Map)),
      script: json['script'] == null ? null : ServantScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      classPassive: (json['classPassive'] as List<dynamic>?)
              ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      extraPassive: (json['extraPassive'] as List<dynamic>?)
              ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      appendPassive: (json['appendPassive'] as List<dynamic>?)
              ?.map((e) => ServantAppendPassiveSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      noblePhantasms: (json['noblePhantasms'] as List<dynamic>?)
              ?.map((e) => NiceTd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      profile: json['profile'] == null ? null : NiceLore.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
    );

Map<String, dynamic> _$ServantToJson(Servant instance) => <String, dynamic>{
      'id': instance.id,
      'collectionNo': instance.collectionNo,
      'name': instance.name,
      'ruby': instance.ruby,
      'battleName': instance.battleName,
      'classId': instance.classId,
      'type': _$SvtTypeEnumMap[instance.type]!,
      'flag': _$SvtFlagEnumMap[instance.flag]!,
      'rarity': instance.rarity,
      'cost': instance.cost,
      'lvMax': instance.lvMax,
      'extraAssets': instance.extraAssets.toJson(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'attribute': _$AttributeEnumMap[instance.attribute]!,
      'traits': instance.traits.map((e) => e.toJson()).toList(),
      'starAbsorb': instance.starAbsorb,
      'starGen': instance.starGen,
      'instantDeathChance': instance.instantDeathChance,
      'cards': instance.cards.map((e) => _$CardTypeEnumMap[e]!).toList(),
      'cardDetails': instance.cardDetails.map((k, e) => MapEntry(_$CardTypeEnumMap[k]!, e.toJson())),
      'atkBase': instance.atkBase,
      'atkMax': instance.atkMax,
      'hpBase': instance.hpBase,
      'hpMax': instance.hpMax,
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
      'ascensionAdd': instance.ascensionAdd.toJson(),
      'traitAdd': instance.traitAdd.map((e) => e.toJson()).toList(),
      'svtChange': instance.svtChange.map((e) => e.toJson()).toList(),
      'ascensionImage': instance.ascensionImage.map((e) => e.toJson()).toList(),
      'ascensionMaterials': instance.ascensionMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'skillMaterials': instance.skillMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'appendSkillMaterials': instance.appendSkillMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'costumeMaterials': instance.costumeMaterials.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'coin': instance.coin?.toJson(),
      'script': instance.script?.toJson(),
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'classPassive': instance.classPassive.map((e) => e.toJson()).toList(),
      'extraPassive': instance.extraPassive.map((e) => e.toJson()).toList(),
      'appendPassive': instance.appendPassive.map((e) => e.toJson()).toList(),
      'noblePhantasms': instance.noblePhantasms.map((e) => e.toJson()).toList(),
      'profile': instance.profile.toJson(),
    };

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

Map<String, dynamic> _$BasicCraftEssenceToJson(BasicCraftEssence instance) => <String, dynamic>{
      'id': instance.id,
      'collectionNo': instance.collectionNo,
      'name': instance.name,
      'type': _$SvtTypeEnumMap[instance.type]!,
      'flag': _$SvtFlagEnumMap[instance.flag]!,
      'rarity': instance.rarity,
      'atkMax': instance.atkMax,
      'hpMax': instance.hpMax,
      'face': instance.face,
    };

CraftEssence _$CraftEssenceFromJson(Map json) => CraftEssence(
      id: json['id'] as int,
      sortId: (json['sortId'] as num?)?.toDouble(),
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
          : ExtraAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
      atkBase: json['atkBase'] as int,
      atkMax: json['atkMax'] as int,
      hpBase: json['hpBase'] as int,
      hpMax: json['hpMax'] as int,
      growthCurve: json['growthCurve'] as int,
      expFeed: (json['expFeed'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      bondEquipOwner: json['bondEquipOwner'] as int?,
      valentineEquipOwner: json['valentineEquipOwner'] as int?,
      valentineScript: (json['valentineScript'] as List<dynamic>?)
              ?.map((e) => ValentineScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ascensionAdd: json['ascensionAdd'] == null
          ? null
          : AscensionAdd.fromJson(Map<String, dynamic>.from(json['ascensionAdd'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      profile: json['profile'] == null ? null : NiceLore.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
    );

Map<String, dynamic> _$CraftEssenceToJson(CraftEssence instance) => <String, dynamic>{
      'id': instance.id,
      'sortId': instance.sortId,
      'collectionNo': instance.collectionNo,
      'name': instance.name,
      'ruby': instance.ruby,
      'type': _$SvtTypeEnumMap[instance.type]!,
      'flag': _$SvtFlagEnumMap[instance.flag]!,
      'rarity': instance.rarity,
      'cost': instance.cost,
      'lvMax': instance.lvMax,
      'extraAssets': instance.extraAssets.toJson(),
      'atkBase': instance.atkBase,
      'atkMax': instance.atkMax,
      'hpBase': instance.hpBase,
      'hpMax': instance.hpMax,
      'growthCurve': instance.growthCurve,
      'expFeed': instance.expFeed,
      'bondEquipOwner': instance.bondEquipOwner,
      'valentineEquipOwner': instance.valentineEquipOwner,
      'valentineScript': instance.valentineScript.map((e) => e.toJson()).toList(),
      'ascensionAdd': instance.ascensionAdd.toJson(),
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'profile': instance.profile.toJson(),
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

Map<String, dynamic> _$ExtraAssetsUrlToJson(ExtraAssetsUrl instance) => <String, dynamic>{
      'ascension': instance.ascension?.map((k, e) => MapEntry(k.toString(), e)),
      'story': instance.story?.map((k, e) => MapEntry(k.toString(), e)),
      'costume': instance.costume?.map((k, e) => MapEntry(k.toString(), e)),
      'equip': instance.equip?.map((k, e) => MapEntry(k.toString(), e)),
      'cc': instance.cc?.map((k, e) => MapEntry(k.toString(), e)),
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
      charaGraph: json['charaGraph'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraph'] as Map)),
      faces: json['faces'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['faces'] as Map)),
      charaGraphEx: json['charaGraphEx'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphEx'] as Map)),
      charaGraphName: json['charaGraphName'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphName'] as Map)),
      narrowFigure: json['narrowFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['narrowFigure'] as Map)),
      charaFigure: json['charaFigure'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaFigure'] as Map)),
      charaFigureForm: (json['charaFigureForm'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      charaFigureMulti: (json['charaFigureMulti'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      commands: json['commands'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['commands'] as Map)),
      status: json['status'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['status'] as Map)),
      equipFace: json['equipFace'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['equipFace'] as Map)),
      image: json['image'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['image'] as Map)),
      spriteModel: json['spriteModel'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['spriteModel'] as Map)),
      charaGraphChange: json['charaGraphChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
      narrowFigureChange: json['narrowFigureChange'] == null
          ? const ExtraAssetsUrl()
          : ExtraAssetsUrl.fromJson(Map<String, dynamic>.from(json['narrowFigureChange'] as Map)),
      facesChange: json['facesChange'] == null
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
      hitsDistribution: (json['hitsDistribution'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      attackIndividuality: (json['attackIndividuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      attackType: $enumDecodeNullable(_$CommandCardAttackTypeEnumMap, json['attackType']) ?? CommandCardAttackType.one,
      damageRate: json['damageRate'] as int?,
      attackNpRate: json['attackNpRate'] as int?,
      defenseNpRate: json['defenseNpRate'] as int?,
      dropStarRate: json['dropStarRate'] as int?,
    );

Map<String, dynamic> _$CardDetailToJson(CardDetail instance) => <String, dynamic>{
      'hitsDistribution': instance.hitsDistribution,
      'attackIndividuality': instance.attackIndividuality.map((e) => e.toJson()).toList(),
      'attackType': _$CommandCardAttackTypeEnumMap[instance.attackType]!,
      'damageRate': instance.damageRate,
      'attackNpRate': instance.attackNpRate,
      'defenseNpRate': instance.defenseNpRate,
      'dropStarRate': instance.dropStarRate,
    };

const _$CommandCardAttackTypeEnumMap = {
  CommandCardAttackType.one: 'one',
  CommandCardAttackType.all: 'all',
};

AscensionAddEntry<T> _$AscensionAddEntryFromJson<T>(
  Map json,
  T Function(Object? json) fromJsonT,
) =>
    AscensionAddEntry<T>(
      ascension: (json['ascension'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
          ) ??
          const {},
      costume: (json['costume'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), fromJsonT(e)),
          ) ??
          const {},
    );

Map<String, dynamic> _$AscensionAddEntryToJson<T>(
  AscensionAddEntry<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'ascension': instance.ascension.map((k, e) => MapEntry(k.toString(), toJsonT(e))),
      'costume': instance.costume.map((k, e) => MapEntry(k.toString(), toJsonT(e))),
    };

AscensionAdd _$AscensionAddFromJson(Map json) => AscensionAdd(
      individuality: json['individuality'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<NiceTrait>>.fromJson(Map<String, dynamic>.from(json['individuality'] as Map)),
      voicePrefix: json['voicePrefix'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<int>.fromJson(Map<String, dynamic>.from(json['voicePrefix'] as Map)),
      overWriteServantName: json['overWriteServantName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteServantName'] as Map)),
      overWriteServantBattleName: json['overWriteServantBattleName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteServantBattleName'] as Map)),
      overWriteTDName: json['overWriteTDName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDName'] as Map)),
      overWriteTDRuby: json['overWriteTDRuby'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDRuby'] as Map)),
      overWriteTDFileName: json['overWriteTDFileName'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDFileName'] as Map)),
      overWriteTDRank: json['overWriteTDRank'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDRank'] as Map)),
      overWriteTDTypeText: json['overWriteTDTypeText'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['overWriteTDTypeText'] as Map)),
      lvMax: json['lvMax'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<int>.fromJson(Map<String, dynamic>.from(json['lvMax'] as Map)),
      charaGraphChange: json['charaGraphChange'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['charaGraphChange'] as Map)),
      faceChange: json['faceChange'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<String>.fromJson(Map<String, dynamic>.from(json['faceChange'] as Map)),
      charaGraphChangeCommonRelease: json['charaGraphChangeCommonRelease'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<CommonRelease>>.fromJson(
              Map<String, dynamic>.from(json['charaGraphChangeCommonRelease'] as Map)),
      faceChangeCommonRelease: json['faceChangeCommonRelease'] == null
          ? const AscensionAddEntry()
          : AscensionAddEntry<List<CommonRelease>>.fromJson(
              Map<String, dynamic>.from(json['faceChangeCommonRelease'] as Map)),
    );

Map<String, dynamic> _$AscensionAddToJson(AscensionAdd instance) => <String, dynamic>{
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
      beforeTreasureDeviceIds: (json['beforeTreasureDeviceIds'] as List<dynamic>).map((e) => e as int).toList(),
      afterTreasureDeviceIds: (json['afterTreasureDeviceIds'] as List<dynamic>).map((e) => e as int).toList(),
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
      limitCount: json['limitCount'] as int,
      priority: json['priority'] as int? ?? 0,
      defaultLimitCount: json['defaultLimitCount'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: json['condTargetId'] as int,
      condNum: json['condNum'] as int,
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
      num: json['num'] as int,
      priority: json['priority'] as int,
      skill: NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
      unlockMaterials: (json['unlockMaterials'] as List<dynamic>)
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
      summonNum: json['summonNum'] as int,
      item: Item.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
    );

Map<String, dynamic> _$ServantCoinToJson(ServantCoin instance) => <String, dynamic>{
      'summonNum': instance.summonNum,
      'item': instance.item.toJson(),
    };

ServantTrait _$ServantTraitFromJson(Map json) => ServantTrait(
      idx: json['idx'] as int,
      trait:
          (json['trait'] as List<dynamic>).map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      limitCount: json['limitCount'] as int,
      condType: _$JsonConverterFromJson<String, CondType>(json['condType'], const CondTypeConverter().fromJson),
      condId: json['condId'] as int?,
      condNum: json['condNum'] as int?,
    );

Map<String, dynamic> _$ServantTraitToJson(ServantTrait instance) => <String, dynamic>{
      'idx': instance.idx,
      'trait': instance.trait.map((e) => e.toJson()).toList(),
      'limitCount': instance.limitCount,
      'condType': _$JsonConverterToJson<String, CondType>(instance.condType, const CondTypeConverter().toJson),
      'condId': instance.condId,
      'condNum': instance.condNum,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

LoreCommentAdd _$LoreCommentAddFromJson(Map json) => LoreCommentAdd(
      idx: json['idx'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condValues: (json['condValues'] as List<dynamic>).map((e) => e as int).toList(),
      condValue2: json['condValue2'] as int? ?? 0,
    );

Map<String, dynamic> _$LoreCommentAddToJson(LoreCommentAdd instance) => <String, dynamic>{
      'idx': instance.idx,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condValues': instance.condValues,
      'condValue2': instance.condValue2,
    };

LoreComment _$LoreCommentFromJson(Map json) => LoreComment(
      id: json['id'] as int,
      priority: json['priority'] as int? ?? 0,
      condMessage: json['condMessage'] as String? ?? "",
      comment: json['comment'] as String? ?? '',
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condValues: (json['condValues'] as List<dynamic>?)?.map((e) => e as int).toList(),
      condValue2: json['condValue2'] as int? ?? 0,
      additionalConds: (json['additionalConds'] as List<dynamic>?)
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
      value: json['value'] as int,
      valueList: (json['valueList'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      eventId: json['eventId'] as int? ?? 0,
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
      condGroup: json['condGroup'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: json['targetId'] as int,
      condValue: json['condValue'] as int,
      condValues: (json['condValues'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
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
      condType: _$JsonConverterFromJson<String, CondType>(json['condType'], const CondTypeConverter().fromJson),
      condValue: json['condValue'] as int?,
      priority: json['priority'] as int?,
      svtVoiceType: $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['svtVoiceType']),
      overwriteName: json['overwriteName'] as String? ?? "",
      summonScript: json['summonScript'] == null
          ? null
          : ScriptLink.fromJson(Map<String, dynamic>.from(json['summonScript'] as Map)),
      id: (json['id'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      audioAssets: (json['audioAssets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      delay: (json['delay'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? const [],
      face: (json['face'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      form: (json['form'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      text: (json['text'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      subtitle: json['subtitle'] as String? ?? "",
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) => VoiceCond.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      playConds: (json['playConds'] as List<dynamic>?)
              ?.map((e) => VoicePlayCond.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$VoiceLineToJson(VoiceLine instance) => <String, dynamic>{
      'name': instance.name,
      'condType': _$JsonConverterToJson<String, CondType>(instance.condType, const CondTypeConverter().toJson),
      'condValue': instance.condValue,
      'priority': instance.priority,
      'svtVoiceType': _$SvtVoiceTypeEnumMap[instance.svtVoiceType],
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
  SvtVoiceType.sum: 'sum',
};

VoiceGroup _$VoiceGroupFromJson(Map json) => VoiceGroup(
      svtId: json['svtId'] as int,
      voicePrefix: json['voicePrefix'] as int? ?? 0,
      type: $enumDecodeNullable(_$SvtVoiceTypeEnumMap, json['type']) ?? SvtVoiceType.unknown,
      voiceLines: (json['voiceLines'] as List<dynamic>?)
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
      costume: (json['costume'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), NiceCostume.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => LoreComment.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voices: (json['voices'] as List<dynamic>?)
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
        (k, e) => MapEntry(int.parse(k as String), (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      svtBuffTurnExtend: json['svtBuffTurnExtend'] as bool?,
    );

Map<String, dynamic> _$ServantScriptToJson(ServantScript instance) => <String, dynamic>{
      'SkillRankUp': instance.skillRankUp?.map((k, e) => MapEntry(k.toString(), e)),
      'svtBuffTurnExtend': instance.svtBuffTurnExtend,
    };

SvtScript _$SvtScriptFromJson(Map json) => SvtScript(
      extendData: json['extendData'] == null
          ? null
          : SvtScriptExtendData.fromJson(Map<String, dynamic>.from(json['extendData'] as Map)),
      id: json['id'] as int,
      form: json['form'] as int? ?? 0,
      faceX: json['faceX'] as int? ?? 0,
      faceY: json['faceY'] as int? ?? 0,
      bgImageId: json['bgImageId'] as int? ?? 0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      offsetX: json['offsetX'] as int? ?? 0,
      offsetY: json['offsetY'] as int? ?? 0,
      offsetXMyroom: json['offsetXMyroom'] as int? ?? 0,
      offsetYMyroom: json['offsetYMyroom'] as int? ?? 0,
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
    };

SvtScriptExtendData _$SvtScriptExtendDataFromJson(Map json) => SvtScriptExtendData(
      faceSize: json['faceSize'] as int?,
      myroomForm: json['myroomForm'] as int?,
      combineResultMultipleForm: json['combineResultMultipleForm'] as int?,
      photoSvtPosition: (json['photoSvtPosition'] as List<dynamic>?)?.map((e) => e as int).toList(),
      photoSvtScale: (json['photoSvtScale'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SvtScriptExtendDataToJson(SvtScriptExtendData instance) => <String, dynamic>{
      'faceSize': instance.faceSize,
      'myroomForm': instance.myroomForm,
      'combineResultMultipleForm': instance.combineResultMultipleForm,
      'photoSvtPosition': instance.photoSvtPosition,
      'photoSvtScale': instance.photoSvtScale,
    };
