// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandCode _$CommandCodeFromJson(Map<String, dynamic> json) {
  return $checkedNew('CommandCode', json, () {
    final val = CommandCode(
      no: $checkedConvert(json, 'no', (v) => v as int),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illust: $checkedConvert(json, 'illust', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp: $checkedConvert(json, 'descriptionJp', (v) => v as String),
      obtain: $checkedConvert(json, 'obtain', (v) => v as String),
      characters: $checkedConvert(json, 'characters',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
    );
    return val;
  });
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
  return $checkedNew('CraftEssential', json, () {
    final val = CraftEssential(
      no: $checkedConvert(json, 'no', (v) => v as int),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illust: $checkedConvert(json, 'illust', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      cost: $checkedConvert(json, 'cost', (v) => v as int),
      hpMin: $checkedConvert(json, 'hpMin', (v) => v as int),
      hpMax: $checkedConvert(json, 'hpMax', (v) => v as int),
      atkMin: $checkedConvert(json, 'atkMin', (v) => v as int),
      atkMax: $checkedConvert(json, 'atkMax', (v) => v as int),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      skillMax: $checkedConvert(json, 'skillMax', (v) => v as String),
      eventIcons: $checkedConvert(json, 'eventIcons',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      eventSkills: $checkedConvert(json, 'eventSkills',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp: $checkedConvert(json, 'descriptionJp', (v) => v as String),
      category: $checkedConvert(json, 'category', (v) => v as int),
      characters: $checkedConvert(json, 'characters',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      bond: $checkedConvert(json, 'bond', (v) => v as int),
      valentine: $checkedConvert(json, 'valentine', (v) => v as int),
    );
    return val;
  });
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
  return $checkedNew('Events', json, () {
    final val = Events(
      limitEvents: $checkedConvert(
          json,
          'limitEvents',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : LimitEvent.fromJson(e as Map<String, dynamic>)),
              )),
      mainRecords: $checkedConvert(
          json,
          'mainRecords',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : MainRecord.fromJson(e as Map<String, dynamic>)),
              )),
      exchangeTickets: $checkedConvert(
          json,
          'exchangeTickets',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : ExchangeTicket.fromJson(e as Map<String, dynamic>)),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
    };

LimitEvent _$LimitEventFromJson(Map<String, dynamic> json) {
  return $checkedNew('LimitEvent', json, () {
    final val = LimitEvent(
      name: $checkedConvert(json, 'name', (v) => v as String),
      link: $checkedConvert(json, 'link', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      qp: $checkedConvert(json, 'qp', (v) => v as int),
      items: $checkedConvert(
          json,
          'items',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      category: $checkedConvert(json, 'category', (v) => v as String),
      extra: $checkedConvert(
          json,
          'extra',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
      lottery: $checkedConvert(
          json,
          'lottery',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
    );
    return val;
  });
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
  return $checkedNew('MainRecord', json, () {
    final val = MainRecord(
      name: $checkedConvert(json, 'name', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String),
      drops: $checkedConvert(
          json,
          'drops',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      rewards: $checkedConvert(
          json,
          'rewards',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$MainRecordToJson(MainRecord instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startTimeJp': instance.startTimeJp,
      'drops': instance.drops,
      'rewards': instance.rewards,
    };

ExchangeTicket _$ExchangeTicketFromJson(Map<String, dynamic> json) {
  return $checkedNew('ExchangeTicket', json, () {
    final val = ExchangeTicket(
      days: $checkedConvert(json, 'days', (v) => v as int),
      monthJp: $checkedConvert(json, 'monthJp', (v) => v as String),
      monthCn: $checkedConvert(json, 'monthCn', (v) => v as String),
      items: $checkedConvert(
          json, 'items', (v) => (v as List)?.map((e) => e as String)?.toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$ExchangeTicketToJson(ExchangeTicket instance) =>
    <String, dynamic>{
      'days': instance.days,
      'monthJp': instance.monthJp,
      'monthCn': instance.monthCn,
      'items': instance.items,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('GameData', json, () {
    final val = GameData(
      version: $checkedConvert(json, 'version', (v) => v as String),
      servants: $checkedConvert(
          json,
          'servants',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    int.parse(k),
                    e == null
                        ? null
                        : Servant.fromJson(e as Map<String, dynamic>)),
              )),
      crafts: $checkedConvert(
          json,
          'crafts',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    int.parse(k),
                    e == null
                        ? null
                        : CraftEssential.fromJson(e as Map<String, dynamic>)),
              )),
      cmdCodes: $checkedConvert(
          json,
          'cmdCodes',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    int.parse(k),
                    e == null
                        ? null
                        : CommandCode.fromJson(e as Map<String, dynamic>)),
              )),
      items: $checkedConvert(
          json,
          'items',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : Item.fromJson(e as Map<String, dynamic>)),
              )),
      icons: $checkedConvert(
          json,
          'icons',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : GameIcon.fromJson(e as Map<String, dynamic>)),
              )),
      events: $checkedConvert(json, 'events',
          (v) => v == null ? null : Events.fromJson(v as Map<String, dynamic>)),
      freeQuests: $checkedConvert(
          json,
          'freeQuests',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : Quest.fromJson(e as Map<String, dynamic>)),
              )),
      glpk: $checkedConvert(
          json,
          'glpk',
          (v) =>
              v == null ? null : GLPKData.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
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
  return $checkedNew('GameIcon', json, () {
    final val = GameIcon(
      filename: $checkedConvert(json, 'filename', (v) => v as String),
      url: $checkedConvert(json, 'url', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$GameIconToJson(GameIcon instance) => <String, dynamic>{
      'filename': instance.filename,
      'url': instance.url,
    };

ItemCost _$ItemCostFromJson(Map<String, dynamic> json) {
  return $checkedNew('ItemCost', json, () {
    final val = ItemCost(
      ascension: $checkedConvert(
          json,
          'ascension',
          (v) => (v as List)
              ?.map((e) => (e as List)
                  ?.map((e) => e == null
                      ? null
                      : Item.fromJson(e as Map<String, dynamic>))
                  ?.toList())
              ?.toList()),
      skill: $checkedConvert(
          json,
          'skill',
          (v) => (v as List)
              ?.map((e) => (e as List)
                  ?.map((e) => e == null
                      ? null
                      : Item.fromJson(e as Map<String, dynamic>))
                  ?.toList())
              ?.toList()),
      dressName: $checkedConvert(json, 'dressName',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      dressNameJp: $checkedConvert(json, 'dressNameJp',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      dress: $checkedConvert(
          json,
          'dress',
          (v) => (v as List)
              ?.map((e) => (e as List)
                  ?.map((e) => e == null
                      ? null
                      : Item.fromJson(e as Map<String, dynamic>))
                  ?.toList())
              ?.toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$ItemCostToJson(ItemCost instance) => <String, dynamic>{
      'ascension': instance.ascension,
      'skill': instance.skill,
      'dress': instance.dress,
      'dressName': instance.dressName,
      'dressNameJp': instance.dressNameJp,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return $checkedNew('Item', json, () {
    final val = Item(
      id: $checkedConvert(json, 'id', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int) ?? 0,
      category: $checkedConvert(json, 'category', (v) => v as int),
      num: $checkedConvert(json, 'num', (v) => v as int) ?? 0,
    );
    return val;
  });
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
  return $checkedNew('GLPKParams', json, () {
    final val = GLPKParams(
      minCoeff: $checkedConvert(json, 'minCoeff', (v) => v as int),
      maxSortOrder: $checkedConvert(json, 'maxSortOrder', (v) => v as int),
      coeffPrio: $checkedConvert(json, 'coeffPrio', (v) => v as bool),
      maxColNum: $checkedConvert(json, 'maxColNum', (v) => v as int),
      objRows: $checkedConvert(json, 'objRows',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      objNums: $checkedConvert(
          json, 'objNums', (v) => (v as List)?.map((e) => e as int)?.toList()),
    );
    return val;
  });
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
  return $checkedNew('Quest', json, () {
    final val = Quest(
      chapter: $checkedConvert(json, 'chapter', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameCn: $checkedConvert(json, 'nameCn', (v) => v as String),
      level: $checkedConvert(json, 'level', (v) => v as int),
      bondPoint: $checkedConvert(json, 'bondPoint', (v) => v as int),
      experience: $checkedConvert(json, 'experience', (v) => v as int),
      qp: $checkedConvert(json, 'qp', (v) => v as int),
      battles: $checkedConvert(
          json,
          'battles',
          (v) => (v as List)
              ?.map((e) =>
                  e == null ? null : Battle.fromJson(e as Map<String, dynamic>))
              ?.toList()),
    );
    return val;
  });
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
  return $checkedNew('Battle', json, () {
    final val = Battle(
      ap: $checkedConvert(json, 'ap', (v) => v as int),
      placeJp: $checkedConvert(json, 'placeJp', (v) => v as String),
      placeCn: $checkedConvert(json, 'placeCn', (v) => v as String),
      enemies: $checkedConvert(
          json,
          'enemies',
          (v) => (v as List)
              ?.map((e) => (e as List)
                  ?.map((e) => e == null
                      ? null
                      : Enemy.fromJson(e as Map<String, dynamic>))
                  ?.toList())
              ?.toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$BattleToJson(Battle instance) => <String, dynamic>{
      'ap': instance.ap,
      'placeJp': instance.placeJp,
      'placeCn': instance.placeCn,
      'enemies': instance.enemies,
    };

Enemy _$EnemyFromJson(Map<String, dynamic> json) {
  return $checkedNew('Enemy', json, () {
    final val = Enemy(
      name: $checkedConvert(json, 'name', (v) => v as String),
      shownName: $checkedConvert(json, 'shownName', (v) => v as String),
      className: $checkedConvert(json, 'className', (v) => v as String),
      rank: $checkedConvert(json, 'rank', (v) => v as int),
      hp: $checkedConvert(json, 'hp', (v) => v as int),
    );
    return val;
  });
}

Map<String, dynamic> _$EnemyToJson(Enemy instance) => <String, dynamic>{
      'name': instance.name,
      'shownName': instance.shownName,
      'className': instance.className,
      'rank': instance.rank,
      'hp': instance.hp,
    };

Servant _$ServantFromJson(Map<String, dynamic> json) {
  return $checkedNew('Servant', json, () {
    final val = Servant(
      no: $checkedConvert(json, 'no', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      info: $checkedConvert(
          json,
          'info',
          (v) => v == null
              ? null
              : ServantBaseInfo.fromJson(v as Map<String, dynamic>)),
      treasureDevice: $checkedConvert(
          json,
          'treasureDevice',
          (v) => (v as List)
              ?.map((e) => e == null
                  ? null
                  : TreasureDevice.fromJson(e as Map<String, dynamic>))
              ?.toList()),
      activeSkills: $checkedConvert(
          json,
          'activeSkills',
          (v) => (v as List)
              ?.map((e) => (e as List)
                  ?.map((e) => e == null
                      ? null
                      : Skill.fromJson(e as Map<String, dynamic>))
                  ?.toList())
              ?.toList()),
      passiveSkills: $checkedConvert(
          json,
          'passiveSkills',
          (v) => (v as List)
              ?.map((e) =>
                  e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
              ?.toList()),
      itemCost: $checkedConvert(
          json,
          'itemCost',
          (v) =>
              v == null ? null : ItemCost.fromJson(v as Map<String, dynamic>)),
      bondPoints: $checkedConvert(json, 'bondPoints',
          (v) => (v as List)?.map((e) => e as int)?.toList()),
      profiles: $checkedConvert(
          json,
          'profiles',
          (v) => (v as List)
              ?.map((e) => e == null
                  ? null
                  : SvtProfileData.fromJson(e as Map<String, dynamic>))
              ?.toList()),
      bondCraft: $checkedConvert(json, 'bondCraft', (v) => v as int),
      valentineCraft: $checkedConvert(json, 'valentineCraft',
          (v) => (v as List)?.map((e) => e as int)?.toList()),
    );
    return val;
  });
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
  return $checkedNew('ServantBaseInfo', json, () {
    final val = ServantBaseInfo(
      obtain: $checkedConvert(json, 'obtain', (v) => v as String),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      rarity2: $checkedConvert(json, 'rarity2', (v) => v as int),
      weight: $checkedConvert(json, 'weight', (v) => v as String),
      height: $checkedConvert(json, 'height', (v) => v as String),
      gender: $checkedConvert(json, 'gender', (v) => v as String),
      illustrator: $checkedConvert(json, 'illustrator', (v) => v as String),
      className: $checkedConvert(json, 'className', (v) => v as String),
      attribute: $checkedConvert(json, 'attribute', (v) => v as String),
      isHumanoid: $checkedConvert(json, 'isHumanoid', (v) => v as bool),
      isWeakToEA: $checkedConvert(json, 'isWeakToEA', (v) => v as bool),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String),
      illustName: $checkedConvert(json, 'illustName', (v) => v as String),
      nicknames: $checkedConvert(json, 'nicknames',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      cv: $checkedConvert(
          json, 'cv', (v) => (v as List)?.map((e) => e as String)?.toList()),
      alignments: $checkedConvert(json, 'alignments',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      traits: $checkedConvert(json, 'traits',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      ability: $checkedConvert(
          json,
          'ability',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
      illust: $checkedConvert(
          json,
          'illust',
          (v) => (v as List)
              ?.map((e) => (e as Map<String, dynamic>)?.map(
                    (k, e) => MapEntry(k, e as String),
                  ))
              ?.toList()),
      cards: $checkedConvert(
          json, 'cards', (v) => (v as List)?.map((e) => e as String)?.toList()),
      cardHits: $checkedConvert(
          json,
          'cardHits',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      cardHitsDamage: $checkedConvert(
          json,
          'cardHitsDamage',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) =>
                    MapEntry(k, (e as List)?.map((e) => e as int)?.toList()),
              )),
      npRate: $checkedConvert(
          json,
          'npRate',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      atkMin: $checkedConvert(json, 'atkMin', (v) => v as int),
      hpMin: $checkedConvert(json, 'hpMin', (v) => v as int),
      atkMax: $checkedConvert(json, 'atkMax', (v) => v as int),
      hpMax: $checkedConvert(json, 'hpMax', (v) => v as int),
      atk90: $checkedConvert(json, 'atk90', (v) => v as int),
      hp90: $checkedConvert(json, 'hp90', (v) => v as int),
      atk100: $checkedConvert(json, 'atk100', (v) => v as int),
      hp100: $checkedConvert(json, 'hp100', (v) => v as int),
      starRate: $checkedConvert(json, 'starRate', (v) => v as int),
      deathRate: $checkedConvert(json, 'deathRate', (v) => v as int),
      criticalRate: $checkedConvert(json, 'criticalRate', (v) => v as int),
    );
    return val;
  });
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
  return $checkedNew('TreasureDevice', json, () {
    final val = TreasureDevice(
      enhanced: $checkedConvert(json, 'enhanced', (v) => v as bool),
      state: $checkedConvert(json, 'state', (v) => v as String),
      openTime: $checkedConvert(json, 'openTime', (v) => v as String),
      openCondition: $checkedConvert(json, 'openCondition', (v) => v as String),
      opeQuest: $checkedConvert(json, 'opeQuest', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      upperName: $checkedConvert(json, 'upperName', (v) => v as String),
      upperNameJp: $checkedConvert(json, 'upperNameJp', (v) => v as String),
      color: $checkedConvert(json, 'color', (v) => v as String),
      category: $checkedConvert(json, 'category', (v) => v as String),
      rank: $checkedConvert(json, 'rank', (v) => v as String),
      typeText: $checkedConvert(json, 'typeText', (v) => v as String),
      effects: $checkedConvert(
          json,
          'effects',
          (v) => (v as List)
              ?.map((e) =>
                  e == null ? null : Effect.fromJson(e as Map<String, dynamic>))
              ?.toList()),
    );
    return val;
  });
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
  return $checkedNew('Skill', json, () {
    final val = Skill(
      state: $checkedConvert(json, 'state', (v) => v as String),
      openTime: $checkedConvert(json, 'openTime', (v) => v as String),
      openCondition: $checkedConvert(json, 'openCondition', (v) => v as String),
      openQuest: $checkedConvert(json, 'openQuest', (v) => v as String),
      enhanced: $checkedConvert(json, 'enhanced', (v) => v as bool),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      rank: $checkedConvert(json, 'rank', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      cd: $checkedConvert(json, 'cd', (v) => v as int),
      effects: $checkedConvert(
          json,
          'effects',
          (v) => (v as List)
              ?.map((e) =>
                  e == null ? null : Effect.fromJson(e as Map<String, dynamic>))
              ?.toList()),
    );
    return val;
  });
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
  return $checkedNew('Effect', json, () {
    final val = Effect(
      description: $checkedConvert(json, 'description', (v) => v as String),
      target: $checkedConvert(json, 'target', (v) => v as String),
      valueType: $checkedConvert(json, 'valueType', (v) => v as String),
      lvData: $checkedConvert(json, 'lvData', (v) => v as List),
    );
    return val;
  });
}

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'description': instance.description,
      'target': instance.target,
      'valueType': instance.valueType,
      'lvData': instance.lvData,
    };

SvtProfileData _$SvtProfileDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SvtProfileData', json, () {
    final val = SvtProfileData(
      profile: $checkedConvert(json, 'profile', (v) => v as String),
      profileJp: $checkedConvert(json, 'profileJp', (v) => v as String),
      condition: $checkedConvert(json, 'condition', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$SvtProfileDataToJson(SvtProfileData instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'profileJp': instance.profileJp,
      'condition': instance.condition,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return $checkedNew('User', json, () {
    final val = User(
      name: $checkedConvert(json, 'name', (v) => v as String),
      server: $checkedConvert(json, 'server', (v) => v as String),
      servants: $checkedConvert(
          json,
          'servants',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    int.parse(k),
                    e == null
                        ? null
                        : ServantStatus.fromJson(e as Map<String, dynamic>)),
              )),
      curPlanNo: $checkedConvert(json, 'curPlanNo', (v) => v as int),
      servantPlans: $checkedConvert(
          json,
          'servantPlans',
          (v) => (v as List)
              ?.map((e) => (e as Map<String, dynamic>)?.map(
                    (k, e) => MapEntry(
                        int.parse(k),
                        e == null
                            ? null
                            : ServantPlan.fromJson(e as Map<String, dynamic>)),
                  ))
              ?.toList()),
      items: $checkedConvert(
          json,
          'items',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      events: $checkedConvert(
          json,
          'events',
          (v) => v == null
              ? null
              : EventPlans.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
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
  return $checkedNew('ServantStatus', json, () {
    final val = ServantStatus(
      curVal: $checkedConvert(
          json,
          'curVal',
          (v) => v == null
              ? null
              : ServantPlan.fromJson(v as Map<String, dynamic>)),
      skillEnhanced: $checkedConvert(json, 'skillEnhanced',
          (v) => (v as List)?.map((e) => e as bool)?.toList()),
      treasureDeviceEnhanced:
          $checkedConvert(json, 'treasureDeviceEnhanced', (v) => v as int),
      treasureDeviceLv:
          $checkedConvert(json, 'treasureDeviceLv', (v) => v as int),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantStatusToJson(ServantStatus instance) =>
    <String, dynamic>{
      'curVal': instance.curVal,
      'skillEnhanced': instance.skillEnhanced,
      'treasureDeviceEnhanced': instance.treasureDeviceEnhanced,
      'treasureDeviceLv': instance.treasureDeviceLv,
    };

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('ServantPlan', json, () {
    final val = ServantPlan(
      favorite: $checkedConvert(json, 'favorite', (v) => v as bool),
      ascension: $checkedConvert(json, 'ascension', (v) => v as int),
      skills: $checkedConvert(
          json, 'skills', (v) => (v as List)?.map((e) => e as int)?.toList()),
      dress: $checkedConvert(
          json, 'dress', (v) => (v as List)?.map((e) => e as int)?.toList()),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
    );
    return val;
  });
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
  return $checkedNew('EventPlans', json, () {
    final val = EventPlans(
      limitEvents: $checkedConvert(
          json,
          'limitEvents',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : LimitEventPlan.fromJson(e as Map<String, dynamic>)),
              )),
      mainRecords: $checkedConvert(
          json,
          'mainRecords',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) =>
                    MapEntry(k, (e as List)?.map((e) => e as bool)?.toList()),
              )),
      exchangeTickets: $checkedConvert(
          json,
          'exchangeTickets',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) =>
                    MapEntry(k, (e as List)?.map((e) => e as int)?.toList()),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$EventPlansToJson(EventPlans instance) =>
    <String, dynamic>{
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
    };

LimitEventPlan _$LimitEventPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('LimitEventPlan', json, () {
    final val = LimitEventPlan(
      enable: $checkedConvert(json, 'enable', (v) => v as bool),
      rerun: $checkedConvert(json, 'rerun', (v) => v as bool),
      lottery: $checkedConvert(json, 'lottery', (v) => v as int),
      extra: $checkedConvert(
          json,
          'extra',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'extra': instance.extra,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('UserData', json, () {
    final val = UserData(
      language: $checkedConvert(json, 'language', (v) => v as String),
      useMobileNetwork:
          $checkedConvert(json, 'useMobileNetwork', (v) => v as bool),
      testAllowDownload:
          $checkedConvert(json, 'testAllowDownload', (v) => v as bool),
      sliderUrls: $checkedConvert(
          json,
          'sliderUrls',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
      galleries: $checkedConvert(
          json,
          'galleries',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as bool),
              )),
      serverDomain: $checkedConvert(json, 'serverDomain', (v) => v as String),
      curUsername: $checkedConvert(json, 'curUsername', (v) => v as String),
      users: $checkedConvert(
          json,
          'users',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(
                    k,
                    e == null
                        ? null
                        : User.fromJson(e as Map<String, dynamic>)),
              )),
      svtFilter: $checkedConvert(
          json,
          'svtFilter',
          (v) => v == null
              ? null
              : SvtFilterData.fromJson(v as Map<String, dynamic>)),
      craftFilter: $checkedConvert(
          json,
          'craftFilter',
          (v) => v == null
              ? null
              : CraftFilterData.fromJson(v as Map<String, dynamic>)),
      cmdCodeFilter: $checkedConvert(
          json,
          'cmdCodeFilter',
          (v) => v == null
              ? null
              : CmdCodeFilterData.fromJson(v as Map<String, dynamic>)),
      glpkParams: $checkedConvert(
          json,
          'glpkParams',
          (v) => v == null
              ? null
              : GLPKParams.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
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
  return $checkedNew('SvtFilterData', json, () {
    final val = SvtFilterData(
      favorite: $checkedConvert(json, 'favorite', (v) => v as bool),
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List)
              ?.map((e) => _$enumDecodeNullable(_$SvtCompareEnumMap, e))
              ?.toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List)?.map((e) => e as bool)?.toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool),
      hasDress: $checkedConvert(json, 'hasDress', (v) => v as bool),
      rarity: $checkedConvert(
          json,
          'rarity',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      className: $checkedConvert(
          json,
          'className',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      obtain: $checkedConvert(
          json,
          'obtain',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      npColor: $checkedConvert(
          json,
          'npColor',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      npType: $checkedConvert(
          json,
          'npType',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      attribute: $checkedConvert(
          json,
          'attribute',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      alignment1: $checkedConvert(
          json,
          'alignment1',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      alignment2: $checkedConvert(
          json,
          'alignment2',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      gender: $checkedConvert(
          json,
          'gender',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      trait: $checkedConvert(
          json,
          'trait',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      traitSpecial: $checkedConvert(
          json,
          'traitSpecial',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    $checkedConvert(
        json, 'filterString', (v) => val.filterString = v as String);
    return val;
  });
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
  return $checkedNew('CraftFilterData', json, () {
    final val = CraftFilterData(
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List)
              ?.map((e) => _$enumDecodeNullable(_$CraftCompareEnumMap, e))
              ?.toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List)?.map((e) => e as bool)?.toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool),
      rarity: $checkedConvert(
          json,
          'rarity',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      category: $checkedConvert(
          json,
          'category',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      atkHpType: $checkedConvert(
          json,
          'atkHpType',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    $checkedConvert(
        json, 'filterString', (v) => val.filterString = v as String);
    return val;
  });
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
  return $checkedNew('CmdCodeFilterData', json, () {
    final val = CmdCodeFilterData(
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List)
              ?.map((e) => _$enumDecodeNullable(_$CmdCodeCompareEnumMap, e))
              ?.toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List)?.map((e) => e as bool)?.toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool),
      rarity: $checkedConvert(
          json,
          'rarity',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      obtain: $checkedConvert(
          json,
          'obtain',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    $checkedConvert(
        json, 'filterString', (v) => val.filterString = v as String);
    return val;
  });
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
  return $checkedNew('FilterGroupData', json, () {
    final val = FilterGroupData(
      matchAll: $checkedConvert(json, 'matchAll', (v) => v as bool),
      invert: $checkedConvert(json, 'invert', (v) => v as bool),
      options: $checkedConvert(
          json,
          'options',
          (v) => (v as Map<String, dynamic>)?.map(
                (k, e) => MapEntry(k, e as bool),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$FilterGroupDataToJson(FilterGroupData instance) =>
    <String, dynamic>{
      'matchAll': instance.matchAll,
      'invert': instance.invert,
      'options': instance.options,
    };
