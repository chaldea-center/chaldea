// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    servants: (json['servants'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(int.parse(k),
          e == null ? null : Servant.fromJson(e as Map<String, dynamic>)),
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
    events: (json['events'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Event.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'crafts': instance.crafts,
      'items': instance.items,
      'icons': instance.icons,
      'events': instance.events,
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
    treasureDevice: (json['treasureDevice'] as List)
        ?.map((e) => e == null
            ? null
            : TreasureDevice.fromJson(e as Map<String, dynamic>))
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
    profiles: (json['profiles'] as List)
        ?.map((e) =>
            e == null ? null : ProfileData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ServantToJson(Servant instance) => <String, dynamic>{
      'no': instance.no,
      'mcLink': instance.mcLink,
      'icon': instance.icon,
      'info': instance.info,
      'treasureDevice': instance.treasureDevice,
      'activeSkills': instance.activeSkills,
      'passiveSkills': instance.passiveSkills,
      'itemCost': instance.itemCost,
      'profiles': instance.profiles,
    };

ServantBaseInfo _$ServantBaseInfoFromJson(Map<String, dynamic> json) {
  return ServantBaseInfo(
    obtain: json['obtain'] as String,
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
    nameJp: json['nameJp'] as String,
    nameEn: json['nameEn'] as String,
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
    cards: (json['cards'] as List)?.map((e) => e as String)?.toList(),
    cardHits: (json['cardHits'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    cardHitsDamage: (json['cardHitsDamage'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, (e as List)?.map((e) => e as int)?.toList()),
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
      'obtain': instance.obtain,
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
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'illustName': instance.illustName,
      'nicknames': instance.nicknames,
      'cv': instance.cv,
      'alignments': instance.alignments,
      'traits': instance.traits,
      'ability': instance.ability,
      'illust': instance.illust,
      'cards': instance.cards,
      'cardHits': instance.cardHits,
      'cardHitsDamage': instance.cardHitsDamage,
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

TreasureDevice _$TreasureDeviceFromJson(Map<String, dynamic> json) {
  return TreasureDevice(
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

Map<String, dynamic> _$TreasureDeviceToJson(TreasureDevice instance) =>
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
    category: json['category'] as int,
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

Event _$EventFromJson(Map<String, dynamic> json) {
  return Event(
    name: json['name'] as String,
    link: json['link'] as String,
    grail: json['grail'] as int,
    crystal: json['crystal'] as int,
    grail2crystal: json['grail2crystal'] as int,
    qp: json['qp'] as int,
    items: (json['items'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    category: json['category'] as String,
    hunting: (json['hunting'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(k, (e as num)?.toDouble()),
            ))
        ?.toList(),
    lottery: (json['lottery'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'name': instance.name,
      'link': instance.link,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'qp': instance.qp,
      'items': instance.items,
      'category': instance.category,
      'hunting': instance.hunting,
      'lottery': instance.lottery,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) {
  return ProfileData(
    loreText: json['loreText'] as String,
    loreTextJp: json['loreTextJp'] as String,
    condition: json['condition'] as String,
  );
}

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'loreText': instance.loreText,
      'loreTextJp': instance.loreTextJp,
      'condition': instance.condition,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return UserData(
    language: json['language'] as String,
    criticalWidth: (json['criticalWidth'] as num)?.toDouble(),
    gameDataPath: json['gameDataPath'] as String,
    sliderUrls: (json['sliderUrls'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    galleries: (json['galleries'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    curUserName: json['curUserName'] as String,
    users: (json['users'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
    ),
    svtFilter: json['svtFilter'] == null
        ? null
        : SvtFilterData.fromJson(json['svtFilter'] as Map<String, dynamic>),
  )
    ..useMobileNetwork = json['useMobileNetwork'] as bool
    ..itemFilter = json['itemFilter'] == null
        ? null
        : SvtFilterData.fromJson(json['itemFilter'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'language': instance.language,
      'criticalWidth': instance.criticalWidth,
      'gameDataPath': instance.gameDataPath,
      'useMobileNetwork': instance.useMobileNetwork,
      'sliderUrls': instance.sliderUrls,
      'galleries': instance.galleries,
      'curUserName': instance.curUserName,
      'users': instance.users,
      'svtFilter': instance.svtFilter,
      'itemFilter': instance.itemFilter,
    };

SvtFilterData _$SvtFilterDataFromJson(Map<String, dynamic> json) {
  return SvtFilterData(
    favorite: json['favorite'] as bool,
    sortKeys: (json['sortKeys'] as List)?.map((e) => e as String)?.toList(),
    sortDirections:
        (json['sortDirections'] as List)?.map((e) => e as bool)?.toList(),
    useGrid: json['useGrid'] as bool,
    rarity: json['rarity'] == null
        ? null
        : FilterGroupData.fromJson(json['rarity'] as Map<String, dynamic>),
    className: json['className'] == null
        ? null
        : FilterGroupData.fromJson(json['className'] as Map<String, dynamic>),
    obtain: json['obtain'] == null
        ? null
        : FilterGroupData.fromJson(json['obtain'] as Map<String, dynamic>),
    npColor: json['npColor'] == null
        ? null
        : FilterGroupData.fromJson(json['npColor'] as Map<String, dynamic>),
    npType: json['npType'] == null
        ? null
        : FilterGroupData.fromJson(json['npType'] as Map<String, dynamic>),
    attribute: json['attribute'] == null
        ? null
        : FilterGroupData.fromJson(json['attribute'] as Map<String, dynamic>),
    alignment1: json['alignment1'] == null
        ? null
        : FilterGroupData.fromJson(json['alignment1'] as Map<String, dynamic>),
    alignment2: json['alignment2'] == null
        ? null
        : FilterGroupData.fromJson(json['alignment2'] as Map<String, dynamic>),
    gender: json['gender'] == null
        ? null
        : FilterGroupData.fromJson(json['gender'] as Map<String, dynamic>),
    trait: json['trait'] == null
        ? null
        : FilterGroupData.fromJson(json['trait'] as Map<String, dynamic>),
    traitSpecial: json['traitSpecial'] == null
        ? null
        : FilterGroupData.fromJson(
            json['traitSpecial'] as Map<String, dynamic>),
  )..filterString = json['filterString'] as String;
}

Map<String, dynamic> _$SvtFilterDataToJson(SvtFilterData instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'filterString': instance.filterString,
      'sortKeys': instance.sortKeys,
      'sortDirections': instance.sortDirections,
      'useGrid': instance.useGrid,
      'rarity': instance.rarity,
      'className': instance.className,
      'obtain': instance.obtain,
      'npColor': instance.npColor,
      'npType': instance.npType,
      'attribute': instance.attribute,
      'alignment1': instance.alignment1,
      'alignment2': instance.alignment2,
      'gender': instance.gender,
      'trait': instance.trait,
      'traitSpecial': instance.traitSpecial,
    };

FilterGroupData _$FilterGroupDataFromJson(Map<String, dynamic> json) {
  return FilterGroupData(
    matchAll: json['matchAll'] as bool,
    invert: json['invert'] as bool,
    options: (json['options'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
  );
}

Map<String, dynamic> _$FilterGroupDataToJson(FilterGroupData instance) =>
    <String, dynamic>{
      'matchAll': instance.matchAll,
      'invert': instance.invert,
      'options': instance.options,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] as String,
    server: json['server'] as String,
    plans: json['plans'] == null
        ? null
        : Plans.fromJson(json['plans'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'server': instance.server,
      'plans': instance.plans,
    };

Plans _$PlansFromJson(Map json) {
  return Plans(
    servants: (json['servants'] as Map)?.map(
      (k, e) => MapEntry(
          int.parse(k as String),
          e == null
              ? null
              : ServantPlan.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    ),
    items: (json['items'] as Map)?.map(
      (k, e) => MapEntry(k as String, e as int),
    ),
  )..events = (json['events'] as Map)?.map(
      (k, e) => MapEntry(
          k as String,
          e == null
              ? null
              : EventPlan.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    );
}

Map<String, dynamic> _$PlansToJson(Plans instance) => <String, dynamic>{
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items,
      'events': instance.events,
    };

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) {
  return ServantPlan(
    ascensionLv: (json['ascensionLv'] as List)?.map((e) => e as int)?.toList(),
    skillLv: (json['skillLv'] as List)
        ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
        ?.toList(),
    dressLv: (json['dressLv'] as List)
        ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
        ?.toList(),
    grailLv: (json['grailLv'] as List)?.map((e) => e as int)?.toList(),
    skillEnhanced:
        (json['skillEnhanced'] as List)?.map((e) => e as bool)?.toList(),
    treasureDeviceEnhanced: json['treasureDeviceEnhanced'] as int,
    treasureDeviceLv: json['treasureDeviceLv'] as int,
    favorite: json['favorite'] as bool,
  );
}

Map<String, dynamic> _$ServantPlanToJson(ServantPlan instance) =>
    <String, dynamic>{
      'ascensionLv': instance.ascensionLv,
      'skillLv': instance.skillLv,
      'dressLv': instance.dressLv,
      'grailLv': instance.grailLv,
      'skillEnhanced': instance.skillEnhanced,
      'treasureDeviceEnhanced': instance.treasureDeviceEnhanced,
      'treasureDeviceLv': instance.treasureDeviceLv,
      'favorite': instance.favorite,
    };

EventPlan _$EventPlanFromJson(Map<String, dynamic> json) {
  return EventPlan(
    enable: json['enable'] as bool,
    rerun: json['rerun'] as bool,
    lottery: json['lottery'] as int,
    hunting: (json['hunting'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$EventPlanToJson(EventPlan instance) => <String, dynamic>{
      'enable': instance.enable,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'hunting': instance.hunting,
    };
