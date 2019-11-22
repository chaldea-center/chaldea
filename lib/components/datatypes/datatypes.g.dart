// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CraftEssential _$CraftEssentialFromJson(Map<String, dynamic> json) {
  return CraftEssential(
    no: json['no'] as int,
    rarity: json['rarity'] as int,
    name: json['name'] as String,
    nameJp: json['nameJp'] as String,
    mcLink: json['mcLink'] as String,
    icon: json['icon'] as String,
    illust: json['illust'] as String,
    illustrator:
        (json['illustrator'] as List)?.map((e) => e as String)?.toList(),
    cost: json['cost'] as int,
    hpMin: json['hpMin'] as int,
    hpMax: json['hpMax'] as int,
    atkMin: json['atkMin'] as int,
    atkMax: json['atkMax'] as int,
    skillIcon: json['skillIcon'] as String,
    skill: json['skill'] as String,
    skillMax: json['skillMax'] as String,
    eventIcons: (json['eventIcons'] as List)?.map((e) => e as String)?.toList(),
    eventSkills:
        (json['eventSkills'] as List)?.map((e) => e as String)?.toList(),
    description: json['description'] as String,
    descriptionJp: json['descriptionJp'] as String,
    category: json['category'] as int,
    characters: (json['characters'] as List)?.map((e) => e as String)?.toList(),
    bond: json['bond'] as int,
    valentine: json['valentine'] as int,
  );
}

Map<String, dynamic> _$CraftEssentialToJson(CraftEssential instance) =>
    <String, dynamic>{
      'no': instance.no,
      'rarity': instance.rarity,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'mcLink': instance.mcLink,
      'icon': instance.icon,
      'illust': instance.illust,
      'illustrator': instance.illustrator,
      'cost': instance.cost,
      'hpMin': instance.hpMin,
      'hpMax': instance.hpMax,
      'atkMin': instance.atkMin,
      'atkMax': instance.atkMax,
      'skillIcon': instance.skillIcon,
      'skill': instance.skill,
      'skillMax': instance.skillMax,
      'eventIcons': instance.eventIcons,
      'eventSkills': instance.eventSkills,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'category': instance.category,
      'characters': instance.characters,
      'bond': instance.bond,
      'valentine': instance.valentine,
    };

Events _$EventsFromJson(Map<String, dynamic> json) {
  return Events(
    limitEvents: (json['limitEvents'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : LimitEvent.fromJson(e as Map<String, dynamic>)),
    ),
    mainRecords: (json['mainRecords'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : MainRecord.fromJson(e as Map<String, dynamic>)),
    ),
    exchangeTickets: (json['exchangeTickets'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k,
          e == null
              ? null
              : ExchangeTicket.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
    };

LimitEvent _$LimitEventFromJson(Map<String, dynamic> json) {
  return LimitEvent(
    name: json['name'] as String,
    link: json['link'] as String,
    startTimeJp: json['startTimeJp'] as String,
    endTimeJp: json['endTimeJp'] as String,
    startTimeCn: json['startTimeCn'] as String,
    endTimeCn: json['endTimeCn'] as String,
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

Map<String, dynamic> _$LimitEventToJson(LimitEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'link': instance.link,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'qp': instance.qp,
      'items': instance.items,
      'category': instance.category,
      'hunting': instance.hunting,
      'lottery': instance.lottery,
    };

MainRecord _$MainRecordFromJson(Map<String, dynamic> json) {
  return MainRecord(
    name: json['name'] as String,
    startTimeJp: json['startTimeJp'] as String,
    drops: (json['drops'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    rewards: (json['rewards'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$MainRecordToJson(MainRecord instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startTimeJp': instance.startTimeJp,
      'drops': instance.drops,
      'rewards': instance.rewards,
    };

ExchangeTicket _$ExchangeTicketFromJson(Map<String, dynamic> json) {
  return ExchangeTicket(
    days: json['days'] as int,
    monthJp: json['monthJp'] as String,
    monthCn: json['monthCn'] as String,
    items: (json['items'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ExchangeTicketToJson(ExchangeTicket instance) =>
    <String, dynamic>{
      'days': instance.days,
      'monthJp': instance.monthJp,
      'monthCn': instance.monthCn,
      'items': instance.items,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    servants: (json['servants'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(int.parse(k),
          e == null ? null : Servant.fromJson(e as Map<String, dynamic>)),
    ),
    crafts: (json['crafts'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          int.parse(k),
          e == null
              ? null
              : CraftEssential.fromJson(e as Map<String, dynamic>)),
    ),
    items: (json['items'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Item.fromJson(e as Map<String, dynamic>)),
    ),
    icons: (json['icons'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : GameIcon.fromJson(e as Map<String, dynamic>)),
    ),
    events: json['events'] == null
        ? null
        : Events.fromJson(json['events'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'crafts': instance.crafts?.map((k, e) => MapEntry(k.toString(), e)),
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
        ?.map((e) => e == null
            ? null
            : SvtProfileData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    bondCraft: json['bondCraft'] as int,
    valentineCraft: json['valentineCraft'] as int,
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
      'bondCraft': instance.bondCraft,
      'valentineCraft': instance.valentineCraft,
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

SvtProfileData _$SvtProfileDataFromJson(Map<String, dynamic> json) {
  return SvtProfileData(
    profile: json['profile'] as String,
    profileJp: json['profileJp'] as String,
    condition: json['condition'] as String,
  );
}

Map<String, dynamic> _$SvtProfileDataToJson(SvtProfileData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'profileJp': instance.profileJp,
      'condition': instance.condition,
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
    limitEvents: (json['limitEvents'] as Map)?.map(
      (k, e) => MapEntry(
          k as String,
          e == null
              ? null
              : LimitEventPlan.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    ),
    mainRecords: (json['mainRecords'] as Map)?.map(
      (k, e) =>
          MapEntry(k as String, (e as List)?.map((e) => e as bool)?.toList()),
    ),
    exchangeTickets: (json['exchangeTickets'] as Map)?.map(
      (k, e) =>
          MapEntry(k as String, (e as List)?.map((e) => e as int)?.toList()),
    ),
  );
}

Map<String, dynamic> _$PlansToJson(Plans instance) => <String, dynamic>{
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items,
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
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

LimitEventPlan _$LimitEventPlanFromJson(Map<String, dynamic> json) {
  return LimitEventPlan(
    enable: json['enable'] as bool,
    rerun: json['rerun'] as bool,
    lottery: json['lottery'] as int,
    hunting: (json['hunting'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'hunting': instance.hunting,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return UserData(
    language: json['language'] as String,
    gameDataPath: json['gameDataPath'] as String,
    useMobileNetwork: json['useMobileNetwork'] as bool,
    sliderUrls: (json['sliderUrls'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    galleries: (json['galleries'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    curUser: json['curUser'] as String,
    users: (json['users'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : User.fromJson(e as Map<String, dynamic>)),
    ),
    svtFilter: json['svtFilter'] == null
        ? null
        : SvtFilterData.fromJson(json['svtFilter'] as Map<String, dynamic>),
    craftFilter: json['craftFilter'] == null
        ? null
        : CraftFilterData.fromJson(json['craftFilter'] as Map<String, dynamic>),
  )..testAllowDownload = json['testAllowDownload'] as bool;
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'language': instance.language,
      'gameDataPath': instance.gameDataPath,
      'useMobileNetwork': instance.useMobileNetwork,
      'sliderUrls': instance.sliderUrls,
      'galleries': instance.galleries,
      'curUser': instance.curUser,
      'users': instance.users,
      'testAllowDownload': instance.testAllowDownload,
      'svtFilter': instance.svtFilter,
      'craftFilter': instance.craftFilter,
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

CraftFilterData _$CraftFilterDataFromJson(Map<String, dynamic> json) {
  return CraftFilterData(
    sortKeys: (json['sortKeys'] as List)?.map((e) => e as String)?.toList(),
    sortDirections:
        (json['sortDirections'] as List)?.map((e) => e as bool)?.toList(),
    useGrid: json['useGrid'] as bool,
    rarity: json['rarity'] == null
        ? null
        : FilterGroupData.fromJson(json['rarity'] as Map<String, dynamic>),
    category: json['category'] == null
        ? null
        : FilterGroupData.fromJson(json['category'] as Map<String, dynamic>),
    atkHpType: json['atkHpType'] == null
        ? null
        : FilterGroupData.fromJson(json['atkHpType'] as Map<String, dynamic>),
  )..filterString = json['filterString'] as String;
}

Map<String, dynamic> _$CraftFilterDataToJson(CraftFilterData instance) =>
    <String, dynamic>{
      'filterString': instance.filterString,
      'sortKeys': instance.sortKeys,
      'sortDirections': instance.sortDirections,
      'useGrid': instance.useGrid,
      'rarity': instance.rarity,
      'category': instance.category,
      'atkHpType': instance.atkHpType,
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
