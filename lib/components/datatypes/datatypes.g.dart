// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppData _$AppDataFromJson(Map<String, dynamic> json) {
  return AppData(
    language: json['language'] as String ?? 'chs',
    galleries: (json['galleries'] as Map<String, dynamic>)?.map(
          (k, e) => MapEntry(k, e as bool),
        ) ??
        {},
    curUser: json['curUser'] as String,
  )..users = (json['users'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(
            k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
      ) ??
      {};
}

Map<String, dynamic> _$AppDataToJson(AppData instance) => <String, dynamic>{
      'language': instance.language,
      'galleries': instance.galleries,
      'curUser': instance.curUser,
      'users': instance.users,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] as String,
    server: json['server'] as String ?? 'cn',
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'server': instance.server,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    servants: (json['servants'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Servant.fromJson(e as Map<String, dynamic>)),
    ),
    crafts: (json['crafts'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'servants': instance.servants,
      'crafts': instance.crafts,
    };

Servant _$ServantFromJson(Map<String, dynamic> json) {
  return Servant(
    no: json['no'] as int,
    mcLink: json['mcLink'] as String,
    icon: json['icon'] as String,
    info: json['info'] == null
        ? null
        : ServantBaseInfo.fromJson(json['info'] as Map<String, dynamic>),
    nobelPhantasm: (json['nobelPhantasm'] as List)
        ?.map((e) => e == null
            ? null
            : NobelPhantasm.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    activeSkills: (json['activeSkills'] as List)
        ?.map((e) => (e as List)
            ?.map((e) =>
                e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
    passiveSkills: (json['passiveSkills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    itemCost: json['itemCost'] == null
        ? null
        : ItemCost.fromJson(json['itemCost'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ServantToJson(Servant instance) => <String, dynamic>{
      'no': instance.no,
      'mcLink': instance.mcLink,
      'icon': instance.icon,
      'info': instance.info,
      'nobelPhantasm': instance.nobelPhantasm,
      'activeSkills': instance.activeSkills,
      'passiveSkills': instance.passiveSkills,
      'itemCost': instance.itemCost,
    };

ServantBaseInfo _$ServantBaseInfoFromJson(Map<String, dynamic> json) {
  return ServantBaseInfo(
    get: json['get'] as String,
    rarity: json['rarity'] as int,
    rarity2: json['rarity2'] as int,
    weight: json['weight'] as String,
    height: json['height'] as String,
    gender: json['gender'] as String,
    illustrator: json['illustrator'] as String,
    className: json['className'] as String,
    attribute: json['attribute'] as String,
    isHumanoid: json['isHumanoid'] as bool,
    isWeakToEA: json['isWeakToEA'] as bool,
    name: json['name'] as String,
    illustName: json['illustName'] as String,
    nicknames: (json['nicknames'] as List)?.map((e) => e as String)?.toList(),
    cv: (json['cv'] as List)?.map((e) => e as String)?.toList(),
    alignments: (json['alignments'] as List)?.map((e) => e as String)?.toList(),
    traits: (json['traits'] as List)?.map((e) => e as String)?.toList(),
    ability: (json['ability'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    illust: (json['illust'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(k, e as String),
            ))
        ?.toList(),
    cards: (json['cards'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as Map<String, dynamic>),
    ),
    npRate: (json['npRate'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    atkMin: json['atkMin'] as int,
    hpMin: json['hpMin'] as int,
    atkMax: json['atkMax'] as int,
    hpMax: json['hpMax'] as int,
    atk90: json['atk90'] as int,
    hp90: json['hp90'] as int,
    atk100: json['atk100'] as int,
    hp100: json['hp100'] as int,
    starRate: json['starRate'] as int,
    deathRate: json['deathRate'] as int,
    criticalRate: json['criticalRate'] as int,
  );
}

Map<String, dynamic> _$ServantBaseInfoToJson(ServantBaseInfo instance) =>
    <String, dynamic>{
      'get': instance.get,
      'rarity': instance.rarity,
      'rarity2': instance.rarity2,
      'weight': instance.weight,
      'height': instance.height,
      'gender': instance.gender,
      'illustrator': instance.illustrator,
      'className': instance.className,
      'attribute': instance.attribute,
      'isHumanoid': instance.isHumanoid,
      'isWeakToEA': instance.isWeakToEA,
      'name': instance.name,
      'illustName': instance.illustName,
      'nicknames': instance.nicknames,
      'cv': instance.cv,
      'alignments': instance.alignments,
      'traits': instance.traits,
      'ability': instance.ability,
      'illust': instance.illust,
      'cards': instance.cards,
      'npRate': instance.npRate,
      'atkMin': instance.atkMin,
      'hpMin': instance.hpMin,
      'atkMax': instance.atkMax,
      'hpMax': instance.hpMax,
      'atk90': instance.atk90,
      'hp90': instance.hp90,
      'atk100': instance.atk100,
      'hp100': instance.hp100,
      'starRate': instance.starRate,
      'deathRate': instance.deathRate,
      'criticalRate': instance.criticalRate,
    };

NobelPhantasm _$NobelPhantasmFromJson(Map<String, dynamic> json) {
  return NobelPhantasm(
    state: json['state'] as String,
    openTime: json['openTime'] as String,
    openCondition: json['openCondition'] as String,
    opeQuest: json['opeQuest'] as String,
    name: json['name'] as String,
    nameJP: json['nameJP'] as String,
    upperName: json['upperName'] as String,
    upperNameJP: json['upperNameJP'] as String,
    color: json['color'] as String,
    category: json['category'] as String,
    rank: json['rank'] as String,
    typeText: json['typeText'] as String,
    effect: (json['effect'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList(),
  );
}

Map<String, dynamic> _$NobelPhantasmToJson(NobelPhantasm instance) =>
    <String, dynamic>{
      'state': instance.state,
      'openTime': instance.openTime,
      'openCondition': instance.openCondition,
      'opeQuest': instance.opeQuest,
      'name': instance.name,
      'nameJP': instance.nameJP,
      'upperName': instance.upperName,
      'upperNameJP': instance.upperNameJP,
      'color': instance.color,
      'category': instance.category,
      'rank': instance.rank,
      'typeText': instance.typeText,
      'effect': instance.effect,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) {
  return Skill(
    state: json['state'] as String,
    openTime: json['openTime'] as String,
    openCondition: json['openCondition'] as String,
    openQuest: json['openQuest'] as String,
    name: json['name'] as String,
    rank: json['rank'] as String,
    icon: json['icon'] as String,
    cd: json['cd'] as int,
    effects: (json['effects'] as List)
        ?.map((e) =>
            e == null ? null : Effect.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
      'state': instance.state,
      'openTime': instance.openTime,
      'openCondition': instance.openCondition,
      'openQuest': instance.openQuest,
      'name': instance.name,
      'rank': instance.rank,
      'icon': instance.icon,
      'cd': instance.cd,
      'effects': instance.effects,
    };

Effect _$EffectFromJson(Map<String, dynamic> json) {
  return Effect(
    description: json['description'] as String,
    target: json['target'] as String,
    valueType: json['valueType'] as String,
    lvData: json['lvData'] as List,
  );
}

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'description': instance.description,
      'target': instance.target,
      'valueType': instance.valueType,
      'lvData': instance.lvData,
    };

ItemCost _$ItemCostFromJson(Map<String, dynamic> json) {
  return ItemCost(
    ascension: (json['ascension'] as List)
        ?.map((e) => (e as List)
            ?.map((e) =>
                e == null ? null : Item.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
    skill: (json['skill'] as List)
        ?.map((e) => (e as List)
            ?.map((e) =>
                e == null ? null : Item.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
    dressName: (json['dressName'] as List)?.map((e) => e as String)?.toList(),
    dress: (json['dress'] as List)
        ?.map((e) => (e as List)
            ?.map((e) =>
                e == null ? null : Item.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$ItemCostToJson(ItemCost instance) => <String, dynamic>{
      'ascension': instance.ascension,
      'skill': instance.skill,
      'dressName': instance.dressName,
      'dress': instance.dress,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    name: json['name'] as String,
    num: json['num'] as int,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'num': instance.num,
    };

Plans _$PlansFromJson(Map json) {
  return Plans(
    servants: (json['servants'] as Map)?.map(
      (k, e) => MapEntry(
          k as String,
          e == null
              ? null
              : ServantPlan.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    ),
    items: (json['items'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    ),
  );
}

Map<String, dynamic> _$PlansToJson(Plans instance) => <String, dynamic>{
      'servants': instance.servants,
      'items': instance.items,
    };

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) {
  return ServantPlan(
    curSkillLv: (json['curSkillLv'] as List)?.map((e) => e as int)?.toList() ??
        [1, 1, 1],
    targetSkillLv:
        (json['targetSkillLv'] as List)?.map((e) => e as int)?.toList() ??
            [1, 1, 1],
    skillEnhanced:
        (json['skillEnhanced'] as List)?.map((e) => e as bool)?.toList() ??
            [true, true, true],
    curAscensionLv: json['curAscensionLv'] as int ?? 0,
    targetAscensionLv: json['targetAscensionLv'] as int ?? 0,
    curGrail: json['curGrail'] as int ?? 0,
    targetGrail: json['targetGrail'] as int ?? 0,
    npLv: json['npLv'] as int ?? 1,
    npEnhanced: json['npEnhanced'] as bool ?? false,
    favorite: json['favorite'] as bool ?? false,
  );
}

Map<String, dynamic> _$ServantPlanToJson(ServantPlan instance) =>
    <String, dynamic>{
      'curSkillLv': instance.curSkillLv,
      'targetSkillLv': instance.targetSkillLv,
      'skillEnhanced': instance.skillEnhanced,
      'curAscensionLv': instance.curAscensionLv,
      'targetAscensionLv': instance.targetAscensionLv,
      'curGrail': instance.curGrail,
      'targetGrail': instance.targetGrail,
      'npLv': instance.npLv,
      'npEnhanced': instance.npEnhanced,
      'favorite': instance.favorite,
    };
