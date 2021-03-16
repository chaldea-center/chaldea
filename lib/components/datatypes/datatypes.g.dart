// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandCode _$CommandCodeFromJson(Map<String, dynamic> json) {
  return $checkedNew('CommandCode', json, () {
    final val = CommandCode(
      no: $checkedConvert(json, 'no', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameOther: $checkedConvert(json, 'nameOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illustration: $checkedConvert(json, 'illustration', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      obtain: $checkedConvert(json, 'obtain', (v) => v as String),
      category: $checkedConvert(json, 'category', (v) => v as String),
      categoryText: $checkedConvert(json, 'categoryText', (v) => v as String),
      characters: $checkedConvert(json, 'characters',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$CommandCodeToJson(CommandCode instance) =>
    <String, dynamic>{
      'no': instance.no,
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameOther': instance.nameOther,
      'rarity': instance.rarity,
      'icon': instance.icon,
      'illustration': instance.illustration,
      'illustrators': instance.illustrators,
      'skillIcon': instance.skillIcon,
      'skill': instance.skill,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'obtain': instance.obtain,
      'category': instance.category,
      'categoryText': instance.categoryText,
      'characters': instance.characters,
    };

CraftEssence _$CraftEssenceFromJson(Map<String, dynamic> json) {
  return $checkedNew('CraftEssence', json, () {
    final val = CraftEssence(
      no: $checkedConvert(json, 'no', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameOther: $checkedConvert(json, 'nameOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illustration: $checkedConvert(json, 'illustration', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      cost: $checkedConvert(json, 'cost', (v) => v as int),
      hpMin: $checkedConvert(json, 'hpMin', (v) => v as int),
      hpMax: $checkedConvert(json, 'hpMax', (v) => v as int),
      atkMin: $checkedConvert(json, 'atkMin', (v) => v as int),
      atkMax: $checkedConvert(json, 'atkMax', (v) => v as int),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String?),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      skillMax: $checkedConvert(json, 'skillMax', (v) => v as String?),
      eventIcons: $checkedConvert(json, 'eventIcons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      eventSkills: $checkedConvert(json, 'eventSkills',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      category: $checkedConvert(json, 'category', (v) => v as String),
      categoryText: $checkedConvert(json, 'categoryText', (v) => v as String),
      characters: $checkedConvert(json, 'characters',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      bond: $checkedConvert(json, 'bond', (v) => v as int),
      valentine: $checkedConvert(json, 'valentine', (v) => v as int),
    );
    return val;
  });
}

Map<String, dynamic> _$CraftEssenceToJson(CraftEssence instance) =>
    <String, dynamic>{
      'no': instance.no,
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameOther': instance.nameOther,
      'rarity': instance.rarity,
      'icon': instance.icon,
      'illustration': instance.illustration,
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
      'categoryText': instance.categoryText,
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
          (v) => (v as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, LimitEvent.fromJson(e as Map<String, dynamic>)),
              )),
      mainRecords: $checkedConvert(
          json,
          'mainRecords',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, MainRecord.fromJson(e as Map<String, dynamic>)),
              )),
      exchangeTickets: $checkedConvert(
          json,
          'exchangeTickets',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k, ExchangeTicket.fromJson(e as Map<String, dynamic>)),
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
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      items: $checkedConvert(
          json, 'items', (v) => Map<String, int>.from(v as Map)),
      lotteryLimit: $checkedConvert(json, 'lotteryLimit', (v) => v as int),
      lottery: $checkedConvert(
          json, 'lottery', (v) => Map<String, int>.from(v as Map)),
      extra: $checkedConvert(
          json, 'extra', (v) => Map<String, String>.from(v as Map)),
    );
    return val;
  });
}

Map<String, dynamic> _$LimitEventToJson(LimitEvent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameJp': instance.nameJp,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'items': instance.items,
      'lotteryLimit': instance.lotteryLimit,
      'lottery': instance.lottery,
      'extra': instance.extra,
    };

MainRecord _$MainRecordFromJson(Map<String, dynamic> json) {
  return $checkedNew('MainRecord', json, () {
    final val = MainRecord(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      drops: $checkedConvert(
          json, 'drops', (v) => Map<String, int>.from(v as Map)),
      rewards: $checkedConvert(
          json, 'rewards', (v) => Map<String, int>.from(v as Map)),
    );
    return val;
  });
}

Map<String, dynamic> _$MainRecordToJson(MainRecord instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameJp': instance.nameJp,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'drops': instance.drops,
      'rewards': instance.rewards,
    };

ExchangeTicket _$ExchangeTicketFromJson(Map<String, dynamic> json) {
  return $checkedNew('ExchangeTicket', json, () {
    final val = ExchangeTicket(
      days: $checkedConvert(json, 'days', (v) => v as int),
      month: $checkedConvert(json, 'month', (v) => v as String),
      monthJp: $checkedConvert(json, 'monthJp', (v) => v as String),
      items: $checkedConvert(json, 'items',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$ExchangeTicketToJson(ExchangeTicket instance) =>
    <String, dynamic>{
      'days': instance.days,
      'month': instance.month,
      'monthJp': instance.monthJp,
      'items': instance.items,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('GameData', json, () {
    final val = GameData(
      version: $checkedConvert(json, 'version', (v) => v as String),
      servants: $checkedConvert(
          json,
          'servants',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    int.parse(k), Servant.fromJson(e as Map<String, dynamic>)),
              )),
      crafts: $checkedConvert(
          json,
          'crafts',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(int.parse(k),
                    CraftEssence.fromJson(e as Map<String, dynamic>)),
              )),
      cmdCodes: $checkedConvert(
          json,
          'cmdCodes',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(int.parse(k),
                    CommandCode.fromJson(e as Map<String, dynamic>)),
              )),
      items: $checkedConvert(
          json,
          'items',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, Item.fromJson(e as Map<String, dynamic>)),
              )),
      icons: $checkedConvert(
          json, 'icons', (v) => Map<String, String>.from(v as Map)),
      events: $checkedConvert(json, 'events',
          (v) => v == null ? null : Events.fromJson(v as Map<String, dynamic>)),
      freeQuests: $checkedConvert(
          json,
          'freeQuests',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, Quest.fromJson(e as Map<String, dynamic>)),
              )),
      svtQuests: $checkedConvert(
          json,
          'svtQuests',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    int.parse(k),
                    (e as List<dynamic>)
                        .map((e) => Quest.fromJson(e as Map<String, dynamic>))
                        .toList()),
              )),
      glpk: $checkedConvert(
          json,
          'glpk',
          (v) =>
              v == null ? null : GLPKData.fromJson(v as Map<String, dynamic>)),
      mysticCodes: $checkedConvert(
          json,
          'mysticCodes',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, MysticCode.fromJson(e as Map<String, dynamic>)),
              )),
      summons: $checkedConvert(
          json,
          'summons',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) =>
                    MapEntry(k, Summon.fromJson(e as Map<String, dynamic>)),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'version': instance.version,
      'servants': instance.servants.map((k, e) => MapEntry(k.toString(), e)),
      'crafts': instance.crafts.map((k, e) => MapEntry(k.toString(), e)),
      'cmdCodes': instance.cmdCodes.map((k, e) => MapEntry(k.toString(), e)),
      'items': instance.items,
      'icons': instance.icons,
      'events': instance.events,
      'freeQuests': instance.freeQuests,
      'svtQuests': instance.svtQuests.map((k, e) => MapEntry(k.toString(), e)),
      'glpk': instance.glpk,
      'mysticCodes': instance.mysticCodes,
      'summons': instance.summons,
    };

ItemCost _$ItemCostFromJson(Map<String, dynamic> json) {
  return $checkedNew('ItemCost', json, () {
    final val = ItemCost(
      ascension: $checkedConvert(
          json,
          'ascension',
          (v) => (v as List<dynamic>)
              .map((e) => Map<String, int>.from(e as Map))
              .toList()),
      skill: $checkedConvert(
          json,
          'skill',
          (v) => (v as List<dynamic>)
              .map((e) => Map<String, int>.from(e as Map))
              .toList()),
      dressName: $checkedConvert(json, 'dressName',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      dressNameJp: $checkedConvert(json, 'dressNameJp',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      dress: $checkedConvert(
          json,
          'dress',
          (v) => (v as List<dynamic>)
              .map((e) => Map<String, int>.from(e as Map))
              .toList()),
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
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      category: $checkedConvert(json, 'category', (v) => v as int),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int?) ?? 0,
    );
    return val;
  });
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'category': instance.category,
      'rarity': instance.rarity,
    };

GLPKData _$GLPKDataFromJson(Map<String, dynamic> json) {
  return GLPKData(
    colNames:
        (json['colNames'] as List<dynamic>).map((e) => e as String).toList(),
    rowNames:
        (json['rowNames'] as List<dynamic>).map((e) => e as String).toList(),
    costs: (json['costs'] as List<dynamic>).map((e) => e as int).toList(),
    matrix: (json['matrix'] as List<dynamic>)
        .map((e) =>
            (e as List<dynamic>).map((e) => (e as num).toDouble()).toList())
        .toList(),
    freeCounts: Map<String, int>.from(json['freeCounts'] as Map),
    weeklyMissionData: (json['weeklyMissionData'] as List<dynamic>)
        .map((e) => WeeklyMissionQuest.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$GLPKDataToJson(GLPKData instance) => <String, dynamic>{
      'colNames': instance.colNames,
      'rowNames': instance.rowNames,
      'costs': instance.costs,
      'matrix': instance.matrix,
      'freeCounts': instance.freeCounts,
      'weeklyMissionData': instance.weeklyMissionData,
    };

WeeklyMissionQuest _$WeeklyMissionQuestFromJson(Map<String, dynamic> json) {
  return $checkedNew('WeeklyMissionQuest', json, () {
    final val = WeeklyMissionQuest(
      chapter: $checkedConvert(json, 'chapter', (v) => v as String),
      place: $checkedConvert(json, 'place', (v) => v as String),
      placeJp: $checkedConvert(json, 'placeJp', (v) => v as String),
      ap: $checkedConvert(json, 'ap', (v) => v as int),
      enemyTraits: $checkedConvert(
          json, 'enemyTraits', (v) => Map<String, int>.from(v as Map)),
      servantTraits: $checkedConvert(
          json, 'servantTraits', (v) => Map<String, int>.from(v as Map)),
      servants: $checkedConvert(json, 'servants',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      battlefields: $checkedConvert(json, 'battlefields',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$WeeklyMissionQuestToJson(WeeklyMissionQuest instance) =>
    <String, dynamic>{
      'chapter': instance.chapter,
      'place': instance.place,
      'placeJp': instance.placeJp,
      'ap': instance.ap,
      'servantTraits': instance.servantTraits,
      'enemyTraits': instance.enemyTraits,
      'servants': instance.servants,
      'battlefields': instance.battlefields,
    };

GLPKParams _$GLPKParamsFromJson(Map<String, dynamic> json) {
  return $checkedNew('GLPKParams', json, () {
    final val = GLPKParams(
      rows: $checkedConvert(json, 'rows',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
      counts: $checkedConvert(json, 'counts',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
      weights: $checkedConvert(
          json,
          'weights',
          (v) => (v as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList()),
      blacklist: $checkedConvert(json, 'blacklist',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
      minCost: $checkedConvert(json, 'minCost', (v) => v as int?),
      costMinimize: $checkedConvert(json, 'costMinimize', (v) => v as bool?),
      maxColNum: $checkedConvert(json, 'maxColNum', (v) => v as int?),
      extraCols: $checkedConvert(json, 'extraCols',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
      integerResult: $checkedConvert(json, 'integerResult', (v) => v as bool?),
      useAP20: $checkedConvert(json, 'useAP20', (v) => v as bool?),
    );
    return val;
  });
}

Map<String, dynamic> _$GLPKParamsToJson(GLPKParams instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'counts': instance.counts,
      'weights': instance.weights,
      'blacklist': instance.blacklist.toList(),
      'minCost': instance.minCost,
      'costMinimize': instance.costMinimize,
      'maxColNum': instance.maxColNum,
      'extraCols': instance.extraCols,
      'integerResult': instance.integerResult,
      'useAP20': instance.useAP20,
    };

GLPKSolution _$GLPKSolutionFromJson(Map<String, dynamic> json) {
  return GLPKSolution(
    destination: json['destination'] as int?,
    totalCost: json['totalCost'] as int?,
    totalNum: json['totalNum'] as int?,
    countVars: (json['countVars'] as List<dynamic>?)
        ?.map((e) => GLPKVariable.fromJson(e as Map<String, dynamic>))
        .toList(),
    weightVars: (json['weightVars'] as List<dynamic>?)
        ?.map((e) => GLPKVariable.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$GLPKSolutionToJson(GLPKSolution instance) =>
    <String, dynamic>{
      'destination': instance.destination,
      'totalCost': instance.totalCost,
      'totalNum': instance.totalNum,
      'countVars': instance.countVars,
      'weightVars': instance.weightVars,
    };

GLPKVariable<T> _$GLPKVariableFromJson<T>(Map<String, dynamic> json) {
  return GLPKVariable<T>(
    name: json['name'] as String,
    value: _Converter<T>().fromJson(json['value'] as Object),
    cost: json['cost'] as int,
    detail: (json['detail'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, _Converter<T>().fromJson(e as Object)),
    ),
  );
}

Map<String, dynamic> _$GLPKVariableToJson<T>(GLPKVariable<T> instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': _Converter<T>().toJson(instance.value),
      'cost': instance.cost,
      'detail':
          instance.detail.map((k, e) => MapEntry(k, _Converter<T>().toJson(e))),
    };

BasicGLPKParams _$BasicGLPKParamsFromJson(Map<String, dynamic> json) {
  return BasicGLPKParams(
    colNames:
        (json['colNames'] as List<dynamic>?)?.map((e) => e as String).toList(),
    rowNames:
        (json['rowNames'] as List<dynamic>?)?.map((e) => e as String).toList(),
    AMat: (json['AMat'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as num).toList())
        .toList(),
    bVec: (json['bVec'] as List<dynamic>?)?.map((e) => e as num).toList(),
    cVec: (json['cVec'] as List<dynamic>?)?.map((e) => e as num).toList(),
    integer: json['integer'] as bool?,
  );
}

Map<String, dynamic> _$BasicGLPKParamsToJson(BasicGLPKParams instance) =>
    <String, dynamic>{
      'colNames': instance.colNames,
      'rowNames': instance.rowNames,
      'AMat': instance.AMat,
      'bVec': instance.bVec,
      'cVec': instance.cVec,
      'integer': instance.integer,
    };

MysticCode _$MysticCodeFromJson(Map<String, dynamic> json) {
  return $checkedNew('MysticCode', json, () {
    final val = MysticCode(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp: $checkedConvert(json, 'descriptionJp', (v) => v as String),
      icon1: $checkedConvert(json, 'icon1', (v) => v as String),
      icon2: $checkedConvert(json, 'icon2', (v) => v as String),
      image1: $checkedConvert(json, 'image1', (v) => v as String),
      image2: $checkedConvert(json, 'image2', (v) => v as String),
      obtains: $checkedConvert(json, 'obtains',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      expPoints: $checkedConvert(json, 'expPoints',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      skills: $checkedConvert(
          json,
          'skills',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$MysticCodeToJson(MysticCode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameJp': instance.nameJp,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'icon1': instance.icon1,
      'icon2': instance.icon2,
      'image1': instance.image1,
      'image2': instance.image2,
      'obtains': instance.obtains,
      'expPoints': instance.expPoints,
      'skills': instance.skills,
    };

Quest _$QuestFromJson(Map<String, dynamic> json) {
  return $checkedNew('Quest', json, () {
    final val = Quest(
      chapter: $checkedConvert(json, 'chapter', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      indexKey: $checkedConvert(json, 'indexKey', (v) => v as String?),
      level: $checkedConvert(json, 'level', (v) => v as int),
      bondPoint: $checkedConvert(json, 'bondPoint', (v) => v as int),
      experience: $checkedConvert(json, 'experience', (v) => v as int),
      qp: $checkedConvert(json, 'qp', (v) => v as int),
      isFree: $checkedConvert(json, 'isFree', (v) => v as bool),
      hasChoice: $checkedConvert(json, 'hasChoice', (v) => v as bool),
      battles: $checkedConvert(
          json,
          'battles',
          (v) => (v as List<dynamic>)
              .map((e) => Battle.fromJson(e as Map<String, dynamic>))
              .toList()),
      rewards: $checkedConvert(
          json, 'rewards', (v) => Map<String, int>.from(v as Map)),
      enhancement: $checkedConvert(json, 'enhancement', (v) => v as String?),
      conditions: $checkedConvert(json, 'conditions', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'chapter': instance.chapter,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'indexKey': instance.indexKey,
      'level': instance.level,
      'bondPoint': instance.bondPoint,
      'experience': instance.experience,
      'qp': instance.qp,
      'isFree': instance.isFree,
      'hasChoice': instance.hasChoice,
      'battles': instance.battles,
      'rewards': instance.rewards,
      'enhancement': instance.enhancement,
      'conditions': instance.conditions,
    };

Battle _$BattleFromJson(Map<String, dynamic> json) {
  return $checkedNew('Battle', json, () {
    final val = Battle(
      ap: $checkedConvert(json, 'ap', (v) => v as int),
      place: $checkedConvert(json, 'place', (v) => v as String),
      placeJp: $checkedConvert(json, 'placeJp', (v) => v as String?),
      enemies: $checkedConvert(
          json,
          'enemies',
          (v) => (v as List<dynamic>)
              .map((e) => (e as List<dynamic>)
                  .map((e) => Enemy.fromJson(e as Map<String, dynamic>))
                  .toList())
              .toList()),
      drops: $checkedConvert(
          json, 'drops', (v) => Map<String, int>.from(v as Map)),
    );
    return val;
  });
}

Map<String, dynamic> _$BattleToJson(Battle instance) => <String, dynamic>{
      'ap': instance.ap,
      'place': instance.place,
      'placeJp': instance.placeJp,
      'enemies': instance.enemies,
      'drops': instance.drops,
    };

Enemy _$EnemyFromJson(Map<String, dynamic> json) {
  return $checkedNew('Enemy', json, () {
    final val = Enemy(
      name: $checkedConvert(json, 'name',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      shownName: $checkedConvert(json, 'shownName',
          (v) => (v as List<dynamic>).map((e) => e as String?).toList()),
      className: $checkedConvert(json, 'className',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      rank: $checkedConvert(json, 'rank',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      hp: $checkedConvert(json, 'hp',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
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
      info: $checkedConvert(json, 'info',
          (v) => ServantBaseInfo.fromJson(v as Map<String, dynamic>)),
      nobelPhantasm: $checkedConvert(
          json,
          'nobelPhantasm',
          (v) => (v as List<dynamic>)
              .map((e) => NobelPhantasm.fromJson(e as Map<String, dynamic>))
              .toList()),
      activeSkills: $checkedConvert(
          json,
          'activeSkills',
          (v) => (v as List<dynamic>)
              .map((e) => ActiveSkill.fromJson(e as Map<String, dynamic>))
              .toList()),
      passiveSkills: $checkedConvert(
          json,
          'passiveSkills',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
      itemCost: $checkedConvert(json, 'itemCost',
          (v) => ItemCost.fromJson(v as Map<String, dynamic>)),
      bondPoints: $checkedConvert(json, 'bondPoints',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      profiles: $checkedConvert(
          json,
          'profiles',
          (v) => (v as List<dynamic>)
              .map((e) => SvtProfileData.fromJson(e as Map<String, dynamic>))
              .toList()),
      voices: $checkedConvert(
          json,
          'voices',
          (v) => (v as List<dynamic>)
              .map((e) => VoiceTable.fromJson(e as Map<String, dynamic>))
              .toList()),
      bondCraft: $checkedConvert(json, 'bondCraft', (v) => v as int),
      valentineCraft: $checkedConvert(json, 'valentineCraft',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
    );
    return val;
  });
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
      'bondPoints': instance.bondPoints,
      'profiles': instance.profiles,
      'voices': instance.voices,
      'bondCraft': instance.bondCraft,
      'valentineCraft': instance.valentineCraft,
    };

ServantBaseInfo _$ServantBaseInfoFromJson(Map<String, dynamic> json) {
  return $checkedNew('ServantBaseInfo', json, () {
    final val = ServantBaseInfo(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      namesOther: $checkedConvert(json, 'namesOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      namesJpOther: $checkedConvert(json, 'namesJpOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      namesEnOther: $checkedConvert(json, 'namesEnOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      nicknames: $checkedConvert(json, 'nicknames',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      obtain: $checkedConvert(json, 'obtain', (v) => v as String),
      obtains: $checkedConvert(json, 'obtains',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
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
      isTDNS: $checkedConvert(json, 'isTDNS', (v) => v as bool),
      cv: $checkedConvert(json, 'cv',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      alignments: $checkedConvert(json, 'alignments',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      traits: $checkedConvert(json, 'traits',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      ability: $checkedConvert(
          json, 'ability', (v) => Map<String, String>.from(v as Map)),
      illustrations: $checkedConvert(
          json, 'illustrations', (v) => Map<String, String>.from(v as Map)),
      cards: $checkedConvert(json, 'cards',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      cardHits: $checkedConvert(
          json, 'cardHits', (v) => Map<String, int>.from(v as Map)),
      cardHitsDamage: $checkedConvert(
          json,
          'cardHitsDamage',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as int).toList()),
              )),
      npRate: $checkedConvert(
          json, 'npRate', (v) => Map<String, String>.from(v as Map)),
      atkMin: $checkedConvert(json, 'atkMin', (v) => v as int),
      hpMin: $checkedConvert(json, 'hpMin', (v) => v as int),
      atkMax: $checkedConvert(json, 'atkMax', (v) => v as int),
      hpMax: $checkedConvert(json, 'hpMax', (v) => v as int),
      atk90: $checkedConvert(json, 'atk90', (v) => v as int),
      hp90: $checkedConvert(json, 'hp90', (v) => v as int),
      atk100: $checkedConvert(json, 'atk100', (v) => v as int),
      hp100: $checkedConvert(json, 'hp100', (v) => v as int),
      starRate: $checkedConvert(json, 'starRate', (v) => v as String),
      deathRate: $checkedConvert(json, 'deathRate', (v) => v as String),
      criticalRate: $checkedConvert(json, 'criticalRate', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantBaseInfoToJson(ServantBaseInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'namesOther': instance.namesOther,
      'namesJpOther': instance.namesJpOther,
      'namesEnOther': instance.namesEnOther,
      'nicknames': instance.nicknames,
      'obtain': instance.obtain,
      'obtains': instance.obtains,
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
      'isTDNS': instance.isTDNS,
      'cv': instance.cv,
      'alignments': instance.alignments,
      'traits': instance.traits,
      'ability': instance.ability,
      'illustrations': instance.illustrations,
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

NobelPhantasm _$NobelPhantasmFromJson(Map<String, dynamic> json) {
  return $checkedNew('NobelPhantasm', json, () {
    final val = NobelPhantasm(
      state: $checkedConvert(json, 'state', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      upperName: $checkedConvert(json, 'upperName', (v) => v as String),
      upperNameJp: $checkedConvert(json, 'upperNameJp', (v) => v as String),
      color: $checkedConvert(json, 'color', (v) => v as String),
      category: $checkedConvert(json, 'category', (v) => v as String),
      rank: $checkedConvert(json, 'rank', (v) => v as String?),
      typeText: $checkedConvert(json, 'typeText', (v) => v as String),
      effects: $checkedConvert(
          json,
          'effects',
          (v) => (v as List<dynamic>)
              .map((e) => Effect.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$NobelPhantasmToJson(NobelPhantasm instance) =>
    <String, dynamic>{
      'state': instance.state,
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

ActiveSkill _$ActiveSkillFromJson(Map<String, dynamic> json) {
  return $checkedNew('ActiveSkill', json, () {
    final val = ActiveSkill(
      cnState: $checkedConvert(json, 'cnState', (v) => v as int),
      skills: $checkedConvert(
          json,
          'skills',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$ActiveSkillToJson(ActiveSkill instance) =>
    <String, dynamic>{
      'cnState': instance.cnState,
      'skills': instance.skills,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) {
  return $checkedNew('Skill', json, () {
    final val = Skill(
      state: $checkedConvert(json, 'state', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      rank: $checkedConvert(json, 'rank', (v) => v as String?),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      cd: $checkedConvert(json, 'cd', (v) => v as int),
      effects: $checkedConvert(
          json,
          'effects',
          (v) => (v as List<dynamic>)
              .map((e) => Effect.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
      'state': instance.state,
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
      lvData: $checkedConvert(json, 'lvData',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'description': instance.description,
      'lvData': instance.lvData,
    };

SvtProfileData _$SvtProfileDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SvtProfileData', json, () {
    final val = SvtProfileData(
      title: $checkedConvert(json, 'title', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp: $checkedConvert(json, 'descriptionJp', (v) => v as String),
      condition: $checkedConvert(json, 'condition', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$SvtProfileDataToJson(SvtProfileData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'condition': instance.condition,
    };

VoiceTable _$VoiceTableFromJson(Map<String, dynamic> json) {
  return $checkedNew('VoiceTable', json, () {
    final val = VoiceTable(
      section: $checkedConvert(json, 'section', (v) => v as String),
      table: $checkedConvert(
          json,
          'table',
          (v) => (v as List<dynamic>)
              .map((e) => VoiceRecord.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$VoiceTableToJson(VoiceTable instance) =>
    <String, dynamic>{
      'section': instance.section,
      'table': instance.table,
    };

VoiceRecord _$VoiceRecordFromJson(Map<String, dynamic> json) {
  return $checkedNew('VoiceRecord', json, () {
    final val = VoiceRecord(
      title: $checkedConvert(json, 'title', (v) => v as String),
      text: $checkedConvert(json, 'text', (v) => v as String?),
      textJp: $checkedConvert(json, 'textJp', (v) => v as String?),
      condition: $checkedConvert(json, 'condition', (v) => v as String?),
      voiceFile: $checkedConvert(json, 'voiceFile', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$VoiceRecordToJson(VoiceRecord instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'textJp': instance.textJp,
      'condition': instance.condition,
      'voiceFile': instance.voiceFile,
    };

Summon _$SummonFromJson(Map<String, dynamic> json) {
  return $checkedNew('Summon', json, () {
    final val = Summon(
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      bannerUrlJp: $checkedConvert(json, 'bannerUrlJp', (v) => v as String?),
      associatedEvents: $checkedConvert(json, 'associatedEvents',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      associatedSummons: $checkedConvert(json, 'associatedSummons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      luckyBag: $checkedConvert(json, 'luckyBag', (v) => v as int),
      classPickUp: $checkedConvert(json, 'classPickUp', (v) => v as bool),
      roll11: $checkedConvert(json, 'roll11', (v) => v as bool),
      dataList: $checkedConvert(
          json,
          'dataList',
          (v) => (v as List<dynamic>)
              .map((e) => SummonData.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$SummonToJson(Summon instance) => <String, dynamic>{
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'bannerUrlJp': instance.bannerUrlJp,
      'associatedEvents': instance.associatedEvents,
      'associatedSummons': instance.associatedSummons,
      'luckyBag': instance.luckyBag,
      'classPickUp': instance.classPickUp,
      'roll11': instance.roll11,
      'dataList': instance.dataList,
    };

SummonData _$SummonDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SummonData', json, () {
    final val = SummonData(
      name: $checkedConvert(json, 'name', (v) => v as String),
      svts: $checkedConvert(
          json,
          'svts',
          (v) => (v as List<dynamic>)
              .map((e) => SummonDataBlock.fromJson(e as Map<String, dynamic>))
              .toList()),
      crafts: $checkedConvert(
          json,
          'crafts',
          (v) => (v as List<dynamic>)
              .map((e) => SummonDataBlock.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$SummonDataToJson(SummonData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'svts': instance.svts,
      'crafts': instance.crafts,
    };

SummonDataBlock _$SummonDataBlockFromJson(Map<String, dynamic> json) {
  return $checkedNew('SummonDataBlock', json, () {
    final val = SummonDataBlock(
      isSvt: $checkedConvert(json, 'isSvt', (v) => v as bool),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      weight: $checkedConvert(json, 'weight', (v) => (v as num).toDouble()),
      display: $checkedConvert(json, 'display', (v) => v as bool),
      ids: $checkedConvert(json, 'ids',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$SummonDataBlockToJson(SummonDataBlock instance) =>
    <String, dynamic>{
      'isSvt': instance.isSvt,
      'rarity': instance.rarity,
      'weight': instance.weight,
      'display': instance.display,
      'ids': instance.ids,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return $checkedNew('User', json, () {
    final val = User(
      name: $checkedConvert(json, 'name', (v) => v as String?),
      servants: $checkedConvert(
          json,
          'servants',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k),
                    ServantStatus.fromJson(e as Map<String, dynamic>)),
              )),
      curSvtPlanNo: $checkedConvert(json, 'curSvtPlanNo', (v) => v as int?),
      servantPlans: $checkedConvert(
          json,
          'servantPlans',
          (v) => (v as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>).map(
                    (k, e) => MapEntry(int.parse(k),
                        ServantPlan.fromJson(e as Map<String, dynamic>)),
                  ))
              .toList()),
      items: $checkedConvert(
          json,
          'items',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      events: $checkedConvert(
          json,
          'events',
          (v) => v == null
              ? null
              : EventPlans.fromJson(v as Map<String, dynamic>)),
      mysticCodes: $checkedConvert(
          json,
          'mysticCodes',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      plannedSummons: $checkedConvert(json, 'plannedSummons',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
      isMasterGirl: $checkedConvert(json, 'isMasterGirl', (v) => v as bool?),
      msProgress: $checkedConvert(json, 'msProgress', (v) => v as int?),
    );
    return val;
  });
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'servants': instance.servants.map((k, e) => MapEntry(k.toString(), e)),
      'curSvtPlanNo': instance.curSvtPlanNo,
      'servantPlans': instance.servantPlans
          .map((e) => e.map((k, e) => MapEntry(k.toString(), e)))
          .toList(),
      'items': instance.items,
      'events': instance.events,
      'mysticCodes': instance.mysticCodes,
      'plannedSummons': instance.plannedSummons.toList(),
      'isMasterGirl': instance.isMasterGirl,
      'msProgress': instance.msProgress,
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
      npLv: $checkedConvert(json, 'npLv', (v) => v as int?),
      skillIndex: $checkedConvert(json, 'skillIndex',
          (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
      npIndex: $checkedConvert(json, 'npIndex', (v) => v as int?),
      priority: $checkedConvert(json, 'priority', (v) => v as int?),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantStatusToJson(ServantStatus instance) =>
    <String, dynamic>{
      'curVal': instance.curVal,
      'npLv': instance.npLv,
      'skillIndex': instance.skillIndex,
      'npIndex': instance.npIndex,
      'priority': instance.priority,
    };

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('ServantPlan', json, () {
    final val = ServantPlan(
      favorite: $checkedConvert(json, 'favorite', (v) => v as bool?),
      ascension: $checkedConvert(json, 'ascension', (v) => v as int?),
      skills: $checkedConvert(json, 'skills',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
      dress: $checkedConvert(json, 'dress',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
      grail: $checkedConvert(json, 'grail', (v) => v as int?),
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
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, LimitEventPlan.fromJson(e as Map<String, dynamic>)),
              )),
      mainRecords: $checkedConvert(
          json,
          'mainRecords',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as bool).toList()),
              )),
      exchangeTickets: $checkedConvert(
          json,
          'exchangeTickets',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, (e as List<dynamic>).map((e) => e as int).toList()),
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
      enable: $checkedConvert(json, 'enable', (v) => v as bool?),
      rerun: $checkedConvert(json, 'rerun', (v) => v as bool?),
      lottery: $checkedConvert(json, 'lottery', (v) => v as int?),
      extra: $checkedConvert(
          json,
          'extra',
          (v) => (v as Map<String, dynamic>?)?.map(
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
      language: $checkedConvert(json, 'language', (v) => v as String?),
      sliderUpdateTime:
          $checkedConvert(json, 'sliderUpdateTime', (v) => v as String?),
      sliderUrls: $checkedConvert(
          json,
          'sliderUrls',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
      galleries: $checkedConvert(
          json,
          'galleries',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              )),
      serverRoot: $checkedConvert(json, 'serverRoot', (v) => v as String?),
      previousBuildNumber:
          $checkedConvert(json, 'previousBuildNumber', (v) => v as int?),
      curUserKey: $checkedConvert(json, 'curUserKey', (v) => v as String?),
      users: $checkedConvert(
          json,
          'users',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, User.fromJson(e as Map<String, dynamic>)),
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
      itemAbundantValue: $checkedConvert(json, 'itemAbundantValue',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'language': instance.language,
      'sliderUpdateTime': instance.sliderUpdateTime,
      'sliderUrls': instance.sliderUrls,
      'galleries': instance.galleries,
      'serverRoot': instance.serverRoot,
      'previousBuildNumber': instance.previousBuildNumber,
      'curUserKey': instance.curUserKey,
      'users': instance.users,
      'svtFilter': instance.svtFilter,
      'craftFilter': instance.craftFilter,
      'cmdCodeFilter': instance.cmdCodeFilter,
      'glpkParams': instance.glpkParams,
      'itemAbundantValue': instance.itemAbundantValue,
    };

SvtFilterData _$SvtFilterDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SvtFilterData', json, () {
    final val = SvtFilterData(
      favorite: $checkedConvert(json, 'favorite', (v) => v as int?),
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$SvtCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool?),
      hasDress: $checkedConvert(json, 'hasDress', (v) => v as bool?),
      planCompletion: $checkedConvert(
          json,
          'planCompletion',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      skillLevel: $checkedConvert(
          json,
          'skillLevel',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      priority: $checkedConvert(
          json,
          'priority',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
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
      'sortKeys': instance.sortKeys.map((e) => _$SvtCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'useGrid': instance.useGrid,
      'hasDress': instance.hasDress,
      'planCompletion': instance.planCompletion,
      'skillLevel': instance.skillLevel,
      'priority': instance.priority,
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

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$SvtCompareEnumMap = {
  SvtCompare.no: 'no',
  SvtCompare.className: 'className',
  SvtCompare.rarity: 'rarity',
  SvtCompare.atk: 'atk',
  SvtCompare.hp: 'hp',
  SvtCompare.priority: 'priority',
};

CraftFilterData _$CraftFilterDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('CraftFilterData', json, () {
    final val = CraftFilterData(
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$CraftCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool?),
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
          instance.sortKeys.map((e) => _$CraftCompareEnumMap[e]).toList(),
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
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$CmdCodeCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
      useGrid: $checkedConvert(json, 'useGrid', (v) => v as bool?),
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
          instance.sortKeys.map((e) => _$CmdCodeCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'useGrid': instance.useGrid,
      'rarity': instance.rarity,
      'category': instance.category,
    };

const _$CmdCodeCompareEnumMap = {
  CmdCodeCompare.no: 'no',
  CmdCodeCompare.rarity: 'rarity',
};

FilterGroupData _$FilterGroupDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('FilterGroupData', json, () {
    final val = FilterGroupData(
      matchAll: $checkedConvert(json, 'matchAll', (v) => v as bool?),
      invert: $checkedConvert(json, 'invert', (v) => v as bool?),
      options: $checkedConvert(
          json,
          'options',
          (v) => (v as Map<String, dynamic>?)?.map(
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
