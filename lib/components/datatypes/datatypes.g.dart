// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    servants: (json['servants'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Servant.fromJson(e as Map<String, dynamic>)),
    ),
    crafts: (json['crafts'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    items: (json['items'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Item.fromJson(e as Map<String, dynamic>)),
    ),
    icons: (json['icons'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : GameIcon.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'servants': instance.servants,
      'crafts': instance.crafts,
      'items': instance.items,
      'icons': instance.icons,
    };

GameIcon _$GameIconFromJson(Map<String, dynamic> json) {
  return GameIcon(
    filename: json['filename'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$GameIconToJson(GameIcon instance) => <String, dynamic>{
      'filename': instance.filename,
      'url': instance.url,
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
    enhanced: json['enhanced'] as bool,
    state: json['state'] as String,
    openTime: json['openTime'] as String,
    openCondition: json['openCondition'] as String,
    opeQuest: json['opeQuest'] as String,
    name: json['name'] as String,
    nameJp: json['nameJp'] as String,
    upperName: json['upperName'] as String,
    upperNameJp: json['upperNameJp'] as String,
    color: json['color'] as String,
    category: json['category'] as String,
    rank: json['rank'] as String,
    typeText: json['typeText'] as String,
    effects: (json['effects'] as List)
        ?.map((e) =>
            e == null ? null : Effect.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NobelPhantasmToJson(NobelPhantasm instance) =>
    <String, dynamic>{
      'enhanced': instance.enhanced,
      'state': instance.state,
      'openTime': instance.openTime,
      'openCondition': instance.openCondition,
      'opeQuest': instance.opeQuest,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'upperName': instance.upperName,
      'upperNameJp': instance.upperNameJp,
      'color': instance.color,
      'category': instance.category,
      'rank': instance.rank,
      'typeText': instance.typeText,
      'effects': instance.effects,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) {
  return Skill(
    state: json['state'] as String,
    openTime: json['openTime'] as String,
    openCondition: json['openCondition'] as String,
    openQuest: json['openQuest'] as String,
    enhanced: json['enhanced'] as bool,
    name: json['name'] as String,
    nameJp: json['nameJp'] as String,
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
      'enhanced': instance.enhanced,
      'name': instance.name,
      'nameJp': instance.nameJp,
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
    dressNameJp:
        (json['dressNameJp'] as List)?.map((e) => e as String)?.toList(),
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
      'dress': instance.dress,
      'dressName': instance.dressName,
      'dressNameJp': instance.dressNameJp,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    id: json['id'] as int,
    name: json['name'] as String,
    rarity: json['rarity'] as int ?? 0,
    category: json['category'] as String,
    num: json['num'] as int ?? 0,
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rarity': instance.rarity,
      'category': instance.category,
      'num': instance.num,
    };

AppData _$AppDataFromJson(Map<String, dynamic> json) {
  return AppData(
    language: json['language'] as String ?? 'chs',
    criticalWidth: (json['criticalWidth'] as num)?.toDouble(),
    curUser: json['curUser'] as String ?? 'default',
    users: (json['users'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
    ),
    galleries: (json['galleries'] as Map<String, dynamic>)?.map(
          (k, e) => MapEntry(k, e as bool),
        ) ??
        {},
    gameDataPath: json['gameDataPath'] as String ?? 'dataset',
  );
}

Map<String, dynamic> _$AppDataToJson(AppData instance) => <String, dynamic>{
      'language': instance.language,
      'criticalWidth': instance.criticalWidth,
      'gameDataPath': instance.gameDataPath,
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
    ascensionLv:
        (json['ascensionLv'] as List)?.map((e) => e as int)?.toList() ?? [0, 0],
    skillLv: (json['skillLv'] as List)
            ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
            ?.toList() ??
        [
          [1, 1],
          [1, 1],
          [1, 1]
        ],
    dressLv: (json['dressLv'] as List)
            ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
            ?.toList() ??
        [],
    grailLv:
        (json['grailLv'] as List)?.map((e) => e as int)?.toList() ?? [0, 0],
    skillEnhanced:
        (json['skillEnhanced'] as List)?.map((e) => e as bool)?.toList(),
    npEnhanced: json['npEnhanced'] as bool,
    npLv: json['npLv'] as int ?? 1,
    favorite: json['favorite'] as bool ?? false,
  );
}

Map<String, dynamic> _$ServantPlanToJson(ServantPlan instance) =>
    <String, dynamic>{
      'ascensionLv': instance.ascensionLv,
      'skillLv': instance.skillLv,
      'dressLv': instance.dressLv,
      'grailLv': instance.grailLv,
      'skillEnhanced': instance.skillEnhanced,
      'npEnhanced': instance.npEnhanced,
      'npLv': instance.npLv,
      'favorite': instance.favorite,
    };
