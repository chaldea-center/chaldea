// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandCode _$CommandCodeFromJson(Map<String, dynamic> json) {
  return CommandCode(
    no: json['no'] as int,
    rarity: json['rarity'] as int,
    name: json['name'] as String,
    nameJp: json['nameJp'] as String,
    mcLink: json['mcLink'] as String,
    icon: json['icon'] as String,
    illust: json['illust'] as String,
    illustrators:
        (json['illustrators'] as List)?.map((e) => e as String)?.toList(),
    skillIcon: json['skillIcon'] as String,
    skill: json['skill'] as String,
    description: json['description'] as String,
    descriptionJp: json['descriptionJp'] as String,
    obtain: json['obtain'] as String,
    characters: (json['characters'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$CommandCodeToJson(CommandCode instance) =>
    <String, dynamic>{
      'no': instance.no,
      'rarity': instance.rarity,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'mcLink': instance.mcLink,
      'icon': instance.icon,
      'illust': instance.illust,
      'illustrators': instance.illustrators,
      'skillIcon': instance.skillIcon,
      'skill': instance.skill,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'obtain': instance.obtain,
      'characters': instance.characters,
    };

CraftEssential _$CraftEssentialFromJson(Map<String, dynamic> json) {
  return CraftEssential(
    no: json['no'] as int,
    rarity: json['rarity'] as int,
    name: json['name'] as String,
    nameJp: json['nameJp'] as String,
    mcLink: json['mcLink'] as String,
    icon: json['icon'] as String,
    illust: json['illust'] as String,
    illustrators:
        (json['illustrators'] as List)?.map((e) => e as String)?.toList(),
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
      'illustrators': instance.illustrators,
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
    extra: (json['extra'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
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
      'extra': instance.extra,
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
    version: json['version'] as String,
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
    cmdCodes: (json['cmdCodes'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(int.parse(k),
          e == null ? null : CommandCode.fromJson(e as Map<String, dynamic>)),
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
    freeQuests: (json['freeQuests'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : Quest.fromJson(e as Map<String, dynamic>)),
    ),
    glpk: json['glpk'] == null
        ? null
        : GLPKData.fromJson(json['glpk'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'version': instance.version,
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'crafts': instance.crafts?.map((k, e) => MapEntry(k.toString(), e)),
      'cmdCodes': instance.cmdCodes?.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items,
      'icons': instance.icons,
      'events': instance.events,
      'freeQuests': instance.freeQuests,
      'glpk': instance.glpk,
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

GLPKData _$GLPKDataFromJson(Map<String, dynamic> json) {
  return GLPKData(
    colNames: (json['colNames'] as List)?.map((e) => e as String)?.toList(),
    rowNames: (json['rowNames'] as List)?.map((e) => e as String)?.toList(),
    coeff: (json['coeff'] as List)?.map((e) => e as num)?.toList(),
    matrix: (json['matrix'] as List)
        ?.map((e) => (e as List)?.map((e) => e as num)?.toList())
        ?.toList(),
    cnMaxColNum: json['cnMaxColNum'] as int,
  );
}

Map<String, dynamic> _$GLPKDataToJson(GLPKData instance) => <String, dynamic>{
      'colNames': instance.colNames,
      'rowNames': instance.rowNames,
      'coeff': instance.coeff,
      'matrix': instance.matrix,
      'cnMaxColNum': instance.cnMaxColNum,
    };

GLPKParams _$GLPKParamsFromJson(Map<String, dynamic> json) {
  return GLPKParams(
    minCoeff: json['minCoeff'] as int,
    maxSortOrder: json['maxSortOrder'] as int,
    coeffPrio: json['coeffPrio'] as bool,
    maxColNum: json['maxColNum'] as int,
    objRows: (json['objRows'] as List)?.map((e) => e as String)?.toList(),
    objNums: (json['objNums'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$GLPKParamsToJson(GLPKParams instance) =>
    <String, dynamic>{
      'minCoeff': instance.minCoeff,
      'maxSortOrder': instance.maxSortOrder,
      'coeffPrio': instance.coeffPrio,
      'maxColNum': instance.maxColNum,
      'objRows': instance.objRows,
      'objNums': instance.objNums,
    };

GLPKSolution _$GLPKSolutionFromJson(Map<String, dynamic> json) {
  return GLPKSolution(
    totalEff: json['totalEff'] as int,
    totalNum: json['totalNum'] as int,
    variables: (json['variables'] as List)
        ?.map((e) =>
            e == null ? null : GLPKVariable.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$GLPKSolutionToJson(GLPKSolution instance) =>
    <String, dynamic>{
      'totalEff': instance.totalEff,
      'totalNum': instance.totalNum,
      'variables': instance.variables,
    };

GLPKVariable _$GLPKVariableFromJson(Map<String, dynamic> json) {
  return GLPKVariable(
    name: json['name'] as String,
    value: json['value'] as int,
    coeff: json['coeff'] as int,
    detail: (json['detail'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$GLPKVariableToJson(GLPKVariable instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'coeff': instance.coeff,
      'detail': instance.detail,
    };

Quest _$QuestFromJson(Map<String, dynamic> json) {
  return Quest(
    chapter: json['chapter'] as String,
    nameJp: json['nameJp'] as String,
    nameCn: json['nameCn'] as String,
    level: json['level'] as int,
    bondPoint: json['bondPoint'] as int,
    experience: json['experience'] as int,
    qp: json['qp'] as int,
    battles: (json['battles'] as List)
        ?.map((e) =>
            e == null ? null : Battle.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'chapter': instance.chapter,
      'nameJp': instance.nameJp,
      'nameCn': instance.nameCn,
      'level': instance.level,
      'bondPoint': instance.bondPoint,
      'experience': instance.experience,
      'qp': instance.qp,
      'battles': instance.battles,
    };

Battle _$BattleFromJson(Map<String, dynamic> json) {
  return Battle(
    ap: json['ap'] as int,
    placeJp: json['placeJp'] as String,
    placeCn: json['placeCn'] as String,
    enemies: (json['enemies'] as List)
        ?.map((e) => (e as List)
            ?.map((e) =>
                e == null ? null : Enemy.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$BattleToJson(Battle instance) => <String, dynamic>{
      'ap': instance.ap,
      'placeJp': instance.placeJp,
      'placeCn': instance.placeCn,
      'enemies': instance.enemies,
    };

Enemy _$EnemyFromJson(Map<String, dynamic> json) {
  return Enemy(
    name: json['name'] as String,
    shownName: json['shownName'] as String,
    className: json['className'] as String,
    rank: json['rank'] as int,
    hp: json['hp'] as int,
  );
}

Map<String, dynamic> _$EnemyToJson(Enemy instance) => <String, dynamic>{
      'name': instance.name,
      'shownName': instance.shownName,
      'className': instance.className,
      'rank': instance.rank,
      'hp': instance.hp,
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
    bondPoints: (json['bondPoints'] as List)?.map((e) => e as int)?.toList(),
    profiles: (json['profiles'] as List)
        ?.map((e) => e == null
            ? null
            : SvtProfileData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    bondCraft: json['bondCraft'] as int,
    valentineCraft:
        (json['valentineCraft'] as List)?.map((e) => e as int)?.toList(),
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
      'bondPoints': instance.bondPoints,
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
    servants: (json['servants'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(int.parse(k),
          e == null ? null : ServantStatus.fromJson(e as Map<String, dynamic>)),
    ),
    curPlanNo: json['curPlanNo'] as int,
    servantPlans: (json['servantPlans'] as List)
        ?.map((e) => (e as Map<String, dynamic>)?.map(
              (k, e) => MapEntry(
                  int.parse(k),
                  e == null
                      ? null
                      : ServantPlan.fromJson(e as Map<String, dynamic>)),
            ))
        ?.toList(),
    items: (json['items'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    events: json['events'] == null
        ? null
        : EventPlans.fromJson(json['events'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'server': instance.server,
      'servants': instance.servants?.map((k, e) => MapEntry(k.toString(), e)),
      'curPlanNo': instance.curPlanNo,
      'servantPlans': instance.servantPlans
          ?.map((e) => e?.map((k, e) => MapEntry(k.toString(), e)))
          ?.toList(),
      'items': instance.items,
      'events': instance.events,
    };

ServantStatus _$ServantStatusFromJson(Map<String, dynamic> json) {
  return ServantStatus(
    curVal: json['curVal'] == null
        ? null
        : ServantPlan.fromJson(json['curVal'] as Map<String, dynamic>),
    skillEnhanced:
        (json['skillEnhanced'] as List)?.map((e) => e as bool)?.toList(),
    treasureDeviceEnhanced: json['treasureDeviceEnhanced'] as int,
    treasureDeviceLv: json['treasureDeviceLv'] as int,
  );
}

Map<String, dynamic> _$ServantStatusToJson(ServantStatus instance) =>
    <String, dynamic>{
      'curVal': instance.curVal,
      'skillEnhanced': instance.skillEnhanced,
      'treasureDeviceEnhanced': instance.treasureDeviceEnhanced,
      'treasureDeviceLv': instance.treasureDeviceLv,
    };

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) {
  return ServantPlan(
    favorite: json['favorite'] as bool,
    ascension: json['ascension'] as int,
    skills: (json['skills'] as List)?.map((e) => e as int)?.toList(),
    dress: (json['dress'] as List)?.map((e) => e as int)?.toList(),
    grail: json['grail'] as int,
  );
}

Map<String, dynamic> _$ServantPlanToJson(ServantPlan instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'ascension': instance.ascension,
      'skills': instance.skills,
      'dress': instance.dress,
      'grail': instance.grail,
    };

EventPlans _$EventPlansFromJson(Map<String, dynamic> json) {
  return EventPlans(
    limitEvents: (json['limitEvents'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k,
          e == null
              ? null
              : LimitEventPlan.fromJson(e as Map<String, dynamic>)),
    ),
    mainRecords: (json['mainRecords'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, (e as List)?.map((e) => e as bool)?.toList()),
    ),
    exchangeTickets: (json['exchangeTickets'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, (e as List)?.map((e) => e as int)?.toList()),
    ),
  );
}

Map<String, dynamic> _$EventPlansToJson(EventPlans instance) =>
    <String, dynamic>{
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
    };

LimitEventPlan _$LimitEventPlanFromJson(Map<String, dynamic> json) {
  return LimitEventPlan(
    enable: json['enable'] as bool,
    rerun: json['rerun'] as bool,
    lottery: json['lottery'] as int,
    extra: (json['hunting'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'hunting': instance.extra,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return UserData(
    language: json['language'] as String,
    useMobileNetwork: json['useMobileNetwork'] as bool,
    testAllowDownload: json['testAllowDownload'] as bool,
    sliderUrls: (json['sliderUrls'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
    galleries: (json['galleries'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    serverDomain: json['serverDomain'] as String,
    curUsername: json['curUsername'] as String,
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
    cmdCodeFilter: json['cmdCodeFilter'] == null
        ? null
        : CmdCodeFilterData.fromJson(
            json['cmdCodeFilter'] as Map<String, dynamic>),
    glpkParams: json['glpkParams'] == null
        ? null
        : GLPKParams.fromJson(json['glpkParams'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'language': instance.language,
      'useMobileNetwork': instance.useMobileNetwork,
      'sliderUrls': instance.sliderUrls,
      'galleries': instance.galleries,
      'serverDomain': instance.serverDomain,
      'curUsername': instance.curUsername,
      'users': instance.users,
      'testAllowDownload': instance.testAllowDownload,
      'svtFilter': instance.svtFilter,
      'craftFilter': instance.craftFilter,
      'cmdCodeFilter': instance.cmdCodeFilter,
      'glpkParams': instance.glpkParams,
    };

SvtFilterData _$SvtFilterDataFromJson(Map<String, dynamic> json) {
  return SvtFilterData(
    favorite: json['favorite'] as bool,
    sortKeys: (json['sortKeys'] as List)
        ?.map((e) => _$enumDecodeNullable(_$SvtCompareEnumMap, e))
        ?.toList(),
    sortReversed:
        (json['sortReversed'] as List)?.map((e) => e as bool)?.toList(),
    useGrid: json['useGrid'] as bool,
    hasDress: json['hasDress'] as bool,
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
      'sortKeys':
          instance.sortKeys?.map((e) => _$SvtCompareEnumMap[e])?.toList(),
      'sortReversed': instance.sortReversed,
      'useGrid': instance.useGrid,
      'hasDress': instance.hasDress,
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

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$SvtCompareEnumMap = {
  SvtCompare.no: 'no',
  SvtCompare.className: 'className',
  SvtCompare.rarity: 'rarity',
  SvtCompare.atk: 'atk',
  SvtCompare.hp: 'hp',
};

CraftFilterData _$CraftFilterDataFromJson(Map<String, dynamic> json) {
  return CraftFilterData(
    sortKeys: (json['sortKeys'] as List)
        ?.map((e) => _$enumDecodeNullable(_$CraftCompareEnumMap, e))
        ?.toList(),
    sortReversed:
        (json['sortReversed'] as List)?.map((e) => e as bool)?.toList(),
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
      'sortKeys':
          instance.sortKeys?.map((e) => _$CraftCompareEnumMap[e])?.toList(),
      'sortReversed': instance.sortReversed,
      'useGrid': instance.useGrid,
      'rarity': instance.rarity,
      'category': instance.category,
      'atkHpType': instance.atkHpType,
    };

const _$CraftCompareEnumMap = {
  CraftCompare.no: 'no',
  CraftCompare.rarity: 'rarity',
  CraftCompare.atk: 'atk',
  CraftCompare.hp: 'hp',
};

CmdCodeFilterData _$CmdCodeFilterDataFromJson(Map<String, dynamic> json) {
  return CmdCodeFilterData(
    sortKeys: (json['sortKeys'] as List)
        ?.map((e) => _$enumDecodeNullable(_$CmdCodeCompareEnumMap, e))
        ?.toList(),
    sortReversed:
        (json['sortReversed'] as List)?.map((e) => e as bool)?.toList(),
    useGrid: json['useGrid'] as bool,
    rarity: json['rarity'] == null
        ? null
        : FilterGroupData.fromJson(json['rarity'] as Map<String, dynamic>),
    obtain: json['obtain'] == null
        ? null
        : FilterGroupData.fromJson(json['obtain'] as Map<String, dynamic>),
  )..filterString = json['filterString'] as String;
}

Map<String, dynamic> _$CmdCodeFilterDataToJson(CmdCodeFilterData instance) =>
    <String, dynamic>{
      'filterString': instance.filterString,
      'sortKeys':
          instance.sortKeys?.map((e) => _$CmdCodeCompareEnumMap[e])?.toList(),
      'sortReversed': instance.sortReversed,
      'useGrid': instance.useGrid,
      'rarity': instance.rarity,
      'obtain': instance.obtain,
    };

const _$CmdCodeCompareEnumMap = {
  CmdCodeCompare.no: 'no',
  CmdCodeCompare.rarity: 'rarity',
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
