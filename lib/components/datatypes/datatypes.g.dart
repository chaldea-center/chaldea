// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyValueEntry _$KeyValueEntryFromJson(Map<String, dynamic> json) {
  return KeyValueEntry(
    key: json['key'] as String?,
    value: json['value'],
  );
}

Map<String, dynamic> _$KeyValueEntryToJson(KeyValueEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

KeyValueListEntry _$KeyValueListEntryFromJson(Map<String, dynamic> json) {
  return KeyValueListEntry(
    key: json['key'] as String?,
    valueList: json['valueList'] as List<dynamic>?,
  );
}

Map<String, dynamic> _$KeyValueListEntryToJson(KeyValueListEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'valueList': instance.valueList,
    };

BiliTopLogin _$BiliTopLoginFromJson(Map<String, dynamic> json) {
  return BiliTopLogin(
    response: json['response'],
    cache: json['cache'] == null
        ? null
        : BiliCache.fromJson(json['cache'] as Map<String, dynamic>),
    sign: json['sign'] as String?,
  );
}

BiliCache _$BiliCacheFromJson(Map<String, dynamic> json) {
  return BiliCache(
    replaced: json['replaced'] == null
        ? null
        : BiliReplaced.fromJson(json['replaced'] as Map<String, dynamic>),
    updated: json['updated'] == null
        ? null
        : BiliUpdated.fromJson(json['updated'] as Map<String, dynamic>),
    serverTime: json['serverTime'] as int?,
  );
}

BiliUpdated _$BiliUpdatedFromJson(Map<String, dynamic> json) {
  return BiliUpdated();
}

BiliReplaced _$BiliReplacedFromJson(Map<String, dynamic> json) {
  return BiliReplaced(
    userItem: (json['userItem'] as List<dynamic>?)
        ?.map((e) => UserItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    userSvt: (json['userSvt'] as List<dynamic>?)
        ?.map((e) => UserSvt.fromJson(e as Map<String, dynamic>))
        .toList(),
    userSvtStorage: (json['userSvtStorage'] as List<dynamic>?)
        ?.map((e) => UserSvt.fromJson(e as Map<String, dynamic>))
        .toList(),
    userSvtCollection: (json['userSvtCollection'] as List<dynamic>?)
        ?.map((e) => UserSvtCollection.fromJson(e as Map<String, dynamic>))
        .toList(),
    userGame: (json['userGame'] as List<dynamic>?)
        ?.map((e) => UserGame.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

UserItem _$UserItemFromJson(Map<String, dynamic> json) {
  return UserItem(
    itemId: json['itemId'] as String,
    num: json['num'] as String,
  );
}

UserSvt _$UserSvtFromJson(Map<String, dynamic> json) {
  return UserSvt(
    id: json['id'] as String,
    svtId: json['svtId'] as String,
    limitCount: json['limitCount'] as String,
    lv: json['lv'] as String,
    exp: json['exp'] as String,
    adjustHp: json['adjustHp'] as String,
    adjustAtk: json['adjustAtk'] as String,
    skillLv1: json['skillLv1'] as String,
    skillLv2: json['skillLv2'] as String,
    skillLv3: json['skillLv3'] as String,
    treasureDeviceLv1: json['treasureDeviceLv1'] as String,
    exceedCount: json['exceedCount'] as String,
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
    isLock: json['isLock'] as String,
    hp: json['hp'] as int,
    atk: json['atk'] as int,
  );
}

UserSvtCollection _$UserSvtCollectionFromJson(Map<String, dynamic> json) {
  return UserSvtCollection(
    svtId: json['svtId'] as String,
    status: json['status'] as String,
    friendship: json['friendship'] as String,
    friendshipRank: json['friendshipRank'] as String,
    friendshipExceedCount: json['friendshipExceedCount'] as String,
    costumeIds:
        (json['costumeIds'] as List<dynamic>).map((e) => e as int).toList(),
  );
}

UserGame _$UserGameFromJson(Map<String, dynamic> json) {
  return UserGame(
    id: json['id'] as String,
    userId: json['userId'] as String,
    appname: json['appname'] as String?,
    name: json['name'] as String,
    birthDay: json['birthDay'] as String?,
    actMax: json['actMax'] as String,
    genderType: json['genderType'] as String,
    lv: json['lv'] as String,
    exp: json['exp'] as String,
    qp: json['qp'] as String,
    costMax: json['costMax'] as String,
    friendCode: json['friendCode'] as String,
    freeStone: json['freeStone'] as String,
    chargeStone: json['chargeStone'] as String,
    mana: json['mana'] as String,
    rarePri: json['rarePri'] as String,
    createdAt: json['createdAt'] as String,
    message: json['message'] as String,
    stone: json['stone'] as int,
  );
}

CommandCode _$CommandCodeFromJson(Map<String, dynamic> json) {
  return $checkedNew('CommandCode', json, () {
    final val = CommandCode(
      gameId: $checkedConvert(json, 'gameId', (v) => v as int),
      no: $checkedConvert(json, 'no', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String),
      nameOther: $checkedConvert(json, 'nameOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illustration: $checkedConvert(json, 'illustration', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      illustratorsJp:
          $checkedConvert(json, 'illustratorsJp', (v) => v as String?),
      illustratorsEn:
          $checkedConvert(json, 'illustratorsEn', (v) => v as String?),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      skillEn: $checkedConvert(json, 'skillEn', (v) => v as String?),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      descriptionEn:
          $checkedConvert(json, 'descriptionEn', (v) => v as String?),
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
      'gameId': instance.gameId,
      'no': instance.no,
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'nameOther': instance.nameOther,
      'rarity': instance.rarity,
      'icon': instance.icon,
      'illustration': instance.illustration,
      'illustrators': instance.illustrators,
      'illustratorsJp': instance.illustratorsJp,
      'illustratorsEn': instance.illustratorsEn,
      'skillIcon': instance.skillIcon,
      'skill': instance.skill,
      'skillEn': instance.skillEn,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'obtain': instance.obtain,
      'category': instance.category,
      'categoryText': instance.categoryText,
      'characters': instance.characters,
    };

CraftEssence _$CraftEssenceFromJson(Map<String, dynamic> json) {
  return $checkedNew('CraftEssence', json, () {
    final val = CraftEssence(
      gameId: $checkedConvert(json, 'gameId', (v) => v as int),
      no: $checkedConvert(json, 'no', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String),
      nameOther: $checkedConvert(json, 'nameOther',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      illustration: $checkedConvert(json, 'illustration', (v) => v as String),
      illustrators: $checkedConvert(json, 'illustrators',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      illustratorsJp:
          $checkedConvert(json, 'illustratorsJp', (v) => v as String?),
      illustratorsEn:
          $checkedConvert(json, 'illustratorsEn', (v) => v as String?),
      cost: $checkedConvert(json, 'cost', (v) => v as int),
      hpMin: $checkedConvert(json, 'hpMin', (v) => v as int),
      hpMax: $checkedConvert(json, 'hpMax', (v) => v as int),
      atkMin: $checkedConvert(json, 'atkMin', (v) => v as int),
      atkMax: $checkedConvert(json, 'atkMax', (v) => v as int),
      skillIcon: $checkedConvert(json, 'skillIcon', (v) => v as String?),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      skillMax: $checkedConvert(json, 'skillMax', (v) => v as String?),
      skillEn: $checkedConvert(json, 'skillEn', (v) => v as String?),
      skillMaxEn: $checkedConvert(json, 'skillMaxEn', (v) => v as String?),
      eventIcons: $checkedConvert(json, 'eventIcons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      eventSkills: $checkedConvert(json, 'eventSkills',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      descriptionEn:
          $checkedConvert(json, 'descriptionEn', (v) => v as String?),
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
      'gameId': instance.gameId,
      'no': instance.no,
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'nameOther': instance.nameOther,
      'rarity': instance.rarity,
      'icon': instance.icon,
      'illustration': instance.illustration,
      'illustrators': instance.illustrators,
      'illustratorsJp': instance.illustratorsJp,
      'illustratorsEn': instance.illustratorsEn,
      'cost': instance.cost,
      'hpMin': instance.hpMin,
      'hpMax': instance.hpMax,
      'atkMin': instance.atkMin,
      'atkMax': instance.atkMax,
      'skillIcon': instance.skillIcon,
      'skill': instance.skill,
      'skillMax': instance.skillMax,
      'skillEn': instance.skillEn,
      'skillMaxEn': instance.skillMaxEn,
      'eventIcons': instance.eventIcons,
      'eventSkills': instance.eventSkills,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'category': instance.category,
      'categoryText': instance.categoryText,
      'characters': instance.characters,
      'bond': instance.bond,
      'valentine': instance.valentine,
    };

EnemyDetail _$EnemyDetailFromJson(Map<String, dynamic> json) {
  return $checkedNew('EnemyDetail', json, () {
    final val = EnemyDetail(
      category: $checkedConvert(json, 'category', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String?),
      ids: $checkedConvert(json, 'ids',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      names: $checkedConvert(json, 'names',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      classIcons: $checkedConvert(json, 'classIcons',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      attribute: $checkedConvert(json, 'attribute', (v) => v as String),
      traits: $checkedConvert(json, 'traits',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      actions: $checkedConvert(json, 'actions', (v) => v as int?),
      charges: $checkedConvert(json, 'charges',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      deathRate: $checkedConvert(json, 'deathRate', (v) => v as String?),
      noblePhantasm: $checkedConvert(json, 'noblePhantasm', (v) => v as String),
      skill: $checkedConvert(json, 'skill', (v) => v as String),
      hitsCommon: $checkedConvert(json, 'hitsCommon',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      hitsCritical: $checkedConvert(json, 'hitsCritical',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      hitsNp: $checkedConvert(json, 'hitsNp',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      firstStage: $checkedConvert(json, 'firstStage', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$EnemyDetailToJson(EnemyDetail instance) =>
    <String, dynamic>{
      'category': instance.category,
      'icon': instance.icon,
      'ids': instance.ids,
      'names': instance.names,
      'classIcons': instance.classIcons,
      'attribute': instance.attribute,
      'traits': instance.traits,
      'actions': instance.actions,
      'charges': instance.charges,
      'deathRate': instance.deathRate,
      'noblePhantasm': instance.noblePhantasm,
      'skill': instance.skill,
      'hitsCommon': instance.hitsCommon,
      'hitsCritical': instance.hitsCritical,
      'hitsNp': instance.hitsNp,
      'firstStage': instance.firstStage,
    };

Events _$EventsFromJson(Map<String, dynamic> json) {
  return $checkedNew('Events', json, () {
    final val = Events(
      progressNA: $checkedConvert(json, 'progressNA', (v) => v as String?),
      progressTW: $checkedConvert(json, 'progressTW', (v) => v as String?),
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
      campaigns: $checkedConvert(
          json,
          'campaigns',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k, CampaignEvent.fromJson(e as Map<String, dynamic>)),
              )),
      extraMasterMissions: $checkedConvert(
          json,
          'extraMasterMissions',
          (v) => (v as List<dynamic>)
              .map((e) => MasterMission.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'progressNA': instance.progressNA.toIso8601String(),
      'progressTW': instance.progressTW.toIso8601String(),
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'campaigns': instance.campaigns,
      'exchangeTickets': instance.exchangeTickets,
      'extraMasterMissions': instance.extraMasterMissions,
    };

LimitEvent _$LimitEventFromJson(Map<String, dynamic> json) {
  return $checkedNew('LimitEvent', json, () {
    final val = LimitEvent(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      bannerUrlJp: $checkedConvert(json, 'bannerUrlJp', (v) => v as String?),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      foukun4: $checkedConvert(json, 'foukun4', (v) => v as int),
      rarePrism: $checkedConvert(json, 'rarePrism', (v) => v as int),
      welfareServant: $checkedConvert(json, 'welfareServant', (v) => v as int),
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
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'bannerUrlJp': instance.bannerUrlJp,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'foukun4': instance.foukun4,
      'rarePrism': instance.rarePrism,
      'welfareServant': instance.welfareServant,
      'items': instance.items,
      'lotteryLimit': instance.lotteryLimit,
      'lottery': instance.lottery,
      'extra': instance.extra,
    };

MainRecord _$MainRecordFromJson(Map<String, dynamic> json) {
  return $checkedNew('MainRecord', json, () {
    final val = MainRecord(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      bannerUrlJp: $checkedConvert(json, 'bannerUrlJp', (v) => v as String?),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      foukun4: $checkedConvert(json, 'foukun4', (v) => v as int),
      rarePrism: $checkedConvert(json, 'rarePrism', (v) => v as int),
      welfareServant: $checkedConvert(json, 'welfareServant', (v) => v as int),
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
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'bannerUrlJp': instance.bannerUrlJp,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'foukun4': instance.foukun4,
      'rarePrism': instance.rarePrism,
      'welfareServant': instance.welfareServant,
      'drops': instance.drops,
      'rewards': instance.rewards,
    };

CampaignEvent _$CampaignEventFromJson(Map<String, dynamic> json) {
  return $checkedNew('CampaignEvent', json, () {
    final val = CampaignEvent(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      startTimeJp: $checkedConvert(json, 'startTimeJp', (v) => v as String?),
      endTimeJp: $checkedConvert(json, 'endTimeJp', (v) => v as String?),
      startTimeCn: $checkedConvert(json, 'startTimeCn', (v) => v as String?),
      endTimeCn: $checkedConvert(json, 'endTimeCn', (v) => v as String?),
      bannerUrl: $checkedConvert(json, 'bannerUrl', (v) => v as String?),
      bannerUrlJp: $checkedConvert(json, 'bannerUrlJp', (v) => v as String?),
      grail: $checkedConvert(json, 'grail', (v) => v as int),
      crystal: $checkedConvert(json, 'crystal', (v) => v as int),
      grail2crystal: $checkedConvert(json, 'grail2crystal', (v) => v as int),
      foukun4: $checkedConvert(json, 'foukun4', (v) => v as int),
      rarePrism: $checkedConvert(json, 'rarePrism', (v) => v as int),
      welfareServant: $checkedConvert(json, 'welfareServant', (v) => v as int),
      items: $checkedConvert(
          json, 'items', (v) => Map<String, int>.from(v as Map)),
    );
    return val;
  });
}

Map<String, dynamic> _$CampaignEventToJson(CampaignEvent instance) =>
    <String, dynamic>{
      'mcLink': instance.mcLink,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'bannerUrlJp': instance.bannerUrlJp,
      'grail': instance.grail,
      'crystal': instance.crystal,
      'grail2crystal': instance.grail2crystal,
      'foukun4': instance.foukun4,
      'rarePrism': instance.rarePrism,
      'welfareServant': instance.welfareServant,
      'items': instance.items,
    };

ExchangeTicket _$ExchangeTicketFromJson(Map<String, dynamic> json) {
  return $checkedNew('ExchangeTicket', json, () {
    final val = ExchangeTicket(
      monthJp: $checkedConvert(json, 'monthJp', (v) => v as String),
      items: $checkedConvert(json, 'items',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      monthCn: $checkedConvert(json, 'monthCn', (v) => v as String?),
      monthTw: $checkedConvert(json, 'monthTw', (v) => v as String?),
      monthEn: $checkedConvert(json, 'monthEn', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$ExchangeTicketToJson(ExchangeTicket instance) =>
    <String, dynamic>{
      'monthJp': instance.monthJp,
      'items': instance.items,
      'monthCn': instance.monthCn,
      'monthTw': instance.monthTw,
      'monthEn': instance.monthEn,
    };

MasterMission _$MasterMissionFromJson(Map<String, dynamic> json) {
  return MasterMission(
    id: json['id'] as int,
    flag: json['flag'] as int,
    type: json['type'] as String,
    dispNo: json['dispNo'] as int,
    name: json['name'] as String,
    detail: json['detail'] as String,
    startedAt: json['startedAt'] as int,
    endedAt: json['endedAt'] as int,
    closedAt: json['closedAt'] as int,
    rewards: (json['rewards'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(int.parse(k), e as int),
    ),
  );
}

Map<String, dynamic> _$MasterMissionToJson(MasterMission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'flag': instance.flag,
      'type': instance.type,
      'dispNo': instance.dispNo,
      'name': instance.name,
      'detail': instance.detail,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'closedAt': instance.closedAt,
      'rewards': instance.rewards.map((k, e) => MapEntry(k.toString(), e)),
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('GameData', json, () {
    final val = GameData(
      version: $checkedConvert(json, 'version', (v) => v as String),
      unavailableSvts: $checkedConvert(json, 'unavailableSvts',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
      servants: $checkedConvert(
          json,
          'servants',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    int.parse(k), Servant.fromJson(e as Map<String, dynamic>)),
              )),
      costumes: $checkedConvert(
          json,
          'costumes',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    int.parse(k), Costume.fromJson(e as Map<String, dynamic>)),
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
      categorizedEnemies: $checkedConvert(
          json,
          'categorizedEnemies',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) =>
                            EnemyDetail.fromJson(e as Map<String, dynamic>))
                        .toList()),
              )),
      fsmSvtIdMapping: $checkedConvert(
          json,
          'fsmSvtIdMapping',
          (v) => (v as Map<String, dynamic>).map(
                (k, e) => MapEntry(int.parse(k), e as int),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'version': instance.version,
      'unavailableSvts': instance.unavailableSvts,
      'servants': instance.servants.map((k, e) => MapEntry(k.toString(), e)),
      'costumes': instance.costumes.map((k, e) => MapEntry(k.toString(), e)),
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
      'categorizedEnemies': instance.categorizedEnemies,
      'fsmSvtIdMapping':
          instance.fsmSvtIdMapping.map((k, e) => MapEntry(k.toString(), e)),
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
      appendSkill: $checkedConvert(
          json,
          'appendSkill',
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
      'appendSkill': instance.appendSkill,
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
      blacklist: $checkedConvert(json, 'blacklist',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
      minCost: $checkedConvert(json, 'minCost', (v) => v as int?),
      costMinimize: $checkedConvert(json, 'costMinimize', (v) => v as bool?),
      maxColNum: $checkedConvert(json, 'maxColNum', (v) => v as int?),
      extraCols: $checkedConvert(json, 'extraCols',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
      integerResult: $checkedConvert(json, 'integerResult', (v) => v as bool?),
      useAP20: $checkedConvert(json, 'useAP20', (v) => v as bool?),
      planItemCounts: $checkedConvert(
          json,
          'planItemCounts',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      planItemWeights: $checkedConvert(
          json,
          'planItemWeights',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toDouble()),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$GLPKParamsToJson(GLPKParams instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'planItemCounts': instance.planItemCounts,
      'planItemWeights': instance.planItemWeights,
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

Item _$ItemFromJson(Map<String, dynamic> json) {
  return $checkedNew('Item', json, () {
    final val = Item(
      id: $checkedConvert(json, 'id', (v) => v as int),
      itemId: $checkedConvert(json, 'itemId', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      category: $checkedConvert(json, 'category', (v) => v as int),
      rarity: $checkedConvert(json, 'rarity', (v) => v as int?) ?? 0,
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'category': instance.category,
      'rarity': instance.rarity,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
    };

MysticCode _$MysticCodeFromJson(Map<String, dynamic> json) {
  return $checkedNew('MysticCode', json, () {
    final val = MysticCode(
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp: $checkedConvert(json, 'descriptionJp', (v) => v as String),
      descriptionEn:
          $checkedConvert(json, 'descriptionEn', (v) => v as String?),
      icon1: $checkedConvert(json, 'icon1', (v) => v as String),
      icon2: $checkedConvert(json, 'icon2', (v) => v as String),
      image1: $checkedConvert(json, 'image1', (v) => v as String),
      image2: $checkedConvert(json, 'image2', (v) => v as String),
      obtains: $checkedConvert(json, 'obtains',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      obtainsEn: $checkedConvert(json, 'obtainsEn',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
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
      'nameEn': instance.nameEn,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'icon1': instance.icon1,
      'icon2': instance.icon2,
      'image1': instance.image1,
      'image2': instance.image2,
      'obtains': instance.obtains,
      'obtainsEn': instance.obtainsEn,
      'expPoints': instance.expPoints,
      'skills': instance.skills,
    };

Quest _$QuestFromJson(Map<String, dynamic> json) {
  return $checkedNew('Quest', json, () {
    final val = Quest(
      chapter: $checkedConvert(json, 'chapter', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
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
      'nameEn': instance.nameEn,
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
      place: $checkedConvert(json, 'place', (v) => v as String?),
      placeJp: $checkedConvert(json, 'placeJp', (v) => v as String?),
      placeEn: $checkedConvert(json, 'placeEn', (v) => v as String?),
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
      'placeEn': instance.placeEn,
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
          (v) => (v as List<dynamic>).map((e) => e as String?).toList()),
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
      svtId: $checkedConvert(json, 'svtId', (v) => v as int),
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      info: $checkedConvert(json, 'info',
          (v) => ServantBaseInfo.fromJson(v as Map<String, dynamic>)),
      noblePhantasm: $checkedConvert(
          json,
          'noblePhantasm',
          (v) => (v as List<dynamic>)
              .map((e) => NoblePhantasm.fromJson(e as Map<String, dynamic>))
              .toList()),
      noblePhantasmEn: $checkedConvert(
          json,
          'noblePhantasmEn',
          (v) => (v as List<dynamic>)
              .map((e) => NoblePhantasm.fromJson(e as Map<String, dynamic>))
              .toList()),
      activeSkills: $checkedConvert(
          json,
          'activeSkills',
          (v) => (v as List<dynamic>)
              .map((e) => ActiveSkill.fromJson(e as Map<String, dynamic>))
              .toList()),
      activeSkillsEn: $checkedConvert(
          json,
          'activeSkillsEn',
          (v) => (v as List<dynamic>)
              .map((e) => ActiveSkill.fromJson(e as Map<String, dynamic>))
              .toList()),
      passiveSkills: $checkedConvert(
          json,
          'passiveSkills',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
      passiveSkillsEn: $checkedConvert(
          json,
          'passiveSkillsEn',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
      appendSkills: $checkedConvert(
          json,
          'appendSkills',
          (v) => (v as List<dynamic>)
              .map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList()),
      coinSummonNum: $checkedConvert(json, 'coinSummonNum', (v) => v as int),
      itemCost: $checkedConvert(json, 'itemCost',
          (v) => ItemCost.fromJson(v as Map<String, dynamic>)),
      costumeNos: $checkedConvert(json, 'costumeNos',
          (v) => (v as List<dynamic>).map((e) => e as int).toList()),
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
      icons: $checkedConvert(
          json,
          'icons',
          (v) => (v as List<dynamic>)
              .map((e) => KeyValueListEntry.fromJson(e as Map<String, dynamic>))
              .toList()),
      sprites: $checkedConvert(
          json,
          'sprites',
          (v) => (v as List<dynamic>)
              .map((e) => KeyValueListEntry.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantToJson(Servant instance) => <String, dynamic>{
      'no': instance.no,
      'svtId': instance.svtId,
      'mcLink': instance.mcLink,
      'icon': instance.icon,
      'info': instance.info,
      'noblePhantasm': instance.noblePhantasm,
      'noblePhantasmEn': instance.noblePhantasmEn,
      'activeSkills': instance.activeSkills,
      'activeSkillsEn': instance.activeSkillsEn,
      'passiveSkills': instance.passiveSkills,
      'passiveSkillsEn': instance.passiveSkillsEn,
      'appendSkills': instance.appendSkills,
      'coinSummonNum': instance.coinSummonNum,
      'itemCost': instance.itemCost,
      'costumeNos': instance.costumeNos,
      'bondPoints': instance.bondPoints,
      'profiles': instance.profiles,
      'voices': instance.voices,
      'bondCraft': instance.bondCraft,
      'valentineCraft': instance.valentineCraft,
      'icons': instance.icons,
      'sprites': instance.sprites,
    };

ServantBaseInfo _$ServantBaseInfoFromJson(Map<String, dynamic> json) {
  return $checkedNew('ServantBaseInfo', json, () {
    final val = ServantBaseInfo(
      gameId: $checkedConvert(json, 'gameId', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String),
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
      illustratorJp:
          $checkedConvert(json, 'illustratorJp', (v) => v as String?),
      illustratorEn:
          $checkedConvert(json, 'illustratorEn', (v) => v as String?),
      className: $checkedConvert(json, 'className', (v) => v as String),
      attribute: $checkedConvert(json, 'attribute', (v) => v as String),
      isHumanoid: $checkedConvert(json, 'isHumanoid', (v) => v as bool),
      isWeakToEA: $checkedConvert(json, 'isWeakToEA', (v) => v as bool),
      isTDNS: $checkedConvert(json, 'isTDNS', (v) => v as bool),
      cv: $checkedConvert(json, 'cv',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      cvJp: $checkedConvert(json, 'cvJp',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      cvEn: $checkedConvert(json, 'cvEn',
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
      'gameId': instance.gameId,
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
      'illustratorJp': instance.illustratorJp,
      'illustratorEn': instance.illustratorEn,
      'className': instance.className,
      'attribute': instance.attribute,
      'isHumanoid': instance.isHumanoid,
      'isWeakToEA': instance.isWeakToEA,
      'isTDNS': instance.isTDNS,
      'cv': instance.cv,
      'cvJp': instance.cvJp,
      'cvEn': instance.cvEn,
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

NoblePhantasm _$NoblePhantasmFromJson(Map<String, dynamic> json) {
  return $checkedNew('NoblePhantasm', json, () {
    final val = NoblePhantasm(
      state: $checkedConvert(json, 'state', (v) => v as String?),
      openCondition:
          $checkedConvert(json, 'openCondition', (v) => v as String?),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      upperName: $checkedConvert(json, 'upperName', (v) => v as String),
      upperNameJp: $checkedConvert(json, 'upperNameJp', (v) => v as String?),
      color: $checkedConvert(json, 'color', (v) => v as String?),
      category: $checkedConvert(json, 'category', (v) => v as String),
      rank: $checkedConvert(json, 'rank', (v) => v as String?),
      typeText: $checkedConvert(json, 'typeText', (v) => v as String?),
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

Map<String, dynamic> _$NoblePhantasmToJson(NoblePhantasm instance) =>
    <String, dynamic>{
      'state': instance.state,
      'openCondition': instance.openCondition,
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
      openCondition:
          $checkedConvert(json, 'openCondition', (v) => v as String?),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
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
      'openCondition': instance.openCondition,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'rank': instance.rank,
      'icon': instance.icon,
      'cd': instance.cd,
      'effects': instance.effects,
    };

Effect _$EffectFromJson(Map<String, dynamic> json) {
  return $checkedNew('Effect', json, () {
    final val = Effect(
      description: $checkedConvert(json, 'description', (v) => v as String),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      descriptionEn:
          $checkedConvert(json, 'descriptionEn', (v) => v as String?),
      lvData: $checkedConvert(json, 'lvData',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'lvData': instance.lvData,
    };

SvtProfileData _$SvtProfileDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SvtProfileData', json, () {
    final val = SvtProfileData(
      title: $checkedConvert(json, 'title', (v) => v as String?),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      descriptionEn:
          $checkedConvert(json, 'descriptionEn', (v) => v as String?),
      condition: $checkedConvert(json, 'condition', (v) => v as String?),
      conditionEn: $checkedConvert(json, 'conditionEn', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$SvtProfileDataToJson(SvtProfileData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'condition': instance.condition,
      'conditionEn': instance.conditionEn,
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
      textEn: $checkedConvert(json, 'textEn', (v) => v as String?),
      condition: $checkedConvert(json, 'condition', (v) => v as String?),
      voiceFile: $checkedConvert(json, 'voiceFile', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$VoiceRecordToJson(VoiceRecord instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'textJp': instance.textJp,
      'textEn': instance.textEn,
      'condition': instance.condition,
      'voiceFile': instance.voiceFile,
    };

Costume _$CostumeFromJson(Map<String, dynamic> json) {
  return $checkedNew('Costume', json, () {
    final val = Costume(
      no: $checkedConvert(json, 'no', (v) => v as int),
      gameId: $checkedConvert(json, 'gameId', (v) => v as int),
      svtNo: $checkedConvert(json, 'svtNo', (v) => v as int),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String),
      icon: $checkedConvert(json, 'icon', (v) => v as String),
      avatar: $checkedConvert(json, 'avatar', (v) => v as String),
      models: $checkedConvert(json, 'models',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      illustration: $checkedConvert(json, 'illustration', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      descriptionJp:
          $checkedConvert(json, 'descriptionJp', (v) => v as String?),
      itemCost: $checkedConvert(
          json, 'itemCost', (v) => Map<String, int>.from(v as Map)),
      obtain: $checkedConvert(json, 'obtain', (v) => v as String?),
      obtainEn: $checkedConvert(json, 'obtainEn', (v) => v as String?),
    );
    return val;
  });
}

Map<String, dynamic> _$CostumeToJson(Costume instance) => <String, dynamic>{
      'no': instance.no,
      'gameId': instance.gameId,
      'svtNo': instance.svtNo,
      'name': instance.name,
      'nameJp': instance.nameJp,
      'nameEn': instance.nameEn,
      'icon': instance.icon,
      'avatar': instance.avatar,
      'models': instance.models,
      'illustration': instance.illustration,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'itemCost': instance.itemCost,
      'obtain': instance.obtain,
      'obtainEn': instance.obtainEn,
    };

Summon _$SummonFromJson(Map<String, dynamic> json) {
  return $checkedNew('Summon', json, () {
    final val = Summon(
      mcLink: $checkedConvert(json, 'mcLink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      nameJp: $checkedConvert(json, 'nameJp', (v) => v as String?),
      nameEn: $checkedConvert(json, 'nameEn', (v) => v as String?),
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
      category: $checkedConvert(json, 'category', (v) => v as int),
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
      'nameEn': instance.nameEn,
      'startTimeJp': instance.startTimeJp,
      'endTimeJp': instance.endTimeJp,
      'startTimeCn': instance.startTimeCn,
      'endTimeCn': instance.endTimeCn,
      'bannerUrl': instance.bannerUrl,
      'bannerUrlJp': instance.bannerUrlJp,
      'associatedEvents': instance.associatedEvents,
      'associatedSummons': instance.associatedSummons,
      'category': instance.category,
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

SvtFilterData _$SvtFilterDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SvtFilterData', json, () {
    final val = SvtFilterData(
      favorite: $checkedConvert(json, 'favorite', (v) => v as int?),
      display: $checkedConvert(
          json,
          'display',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$SvtCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
      hasDress: $checkedConvert(json, 'hasDress', (v) => v as bool?),
      svtDuplicated: $checkedConvert(
          json,
          'svtDuplicated',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
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
      special: $checkedConvert(
          json,
          'special',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

Map<String, dynamic> _$SvtFilterDataToJson(SvtFilterData instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'display': instance.display,
      'sortKeys': instance.sortKeys.map((e) => _$SvtCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'hasDress': instance.hasDress,
      'svtDuplicated': instance.svtDuplicated,
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
      'special': instance.special,
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
      display: $checkedConvert(
          json,
          'display',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$CraftCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
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
      status: $checkedConvert(
          json,
          'status',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

Map<String, dynamic> _$CraftFilterDataToJson(CraftFilterData instance) =>
    <String, dynamic>{
      'display': instance.display,
      'sortKeys':
          instance.sortKeys.map((e) => _$CraftCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'rarity': instance.rarity,
      'category': instance.category,
      'atkHpType': instance.atkHpType,
      'status': instance.status,
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
      display: $checkedConvert(
          json,
          'display',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
      sortKeys: $checkedConvert(
          json,
          'sortKeys',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecode(_$CmdCodeCompareEnumMap, e))
              .toList()),
      sortReversed: $checkedConvert(json, 'sortReversed',
          (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
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
    return val;
  });
}

Map<String, dynamic> _$CmdCodeFilterDataToJson(CmdCodeFilterData instance) =>
    <String, dynamic>{
      'display': instance.display,
      'sortKeys':
          instance.sortKeys.map((e) => _$CmdCodeCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'rarity': instance.rarity,
      'category': instance.category,
    };

const _$CmdCodeCompareEnumMap = {
  CmdCodeCompare.no: 'no',
  CmdCodeCompare.rarity: 'rarity',
};

SummonFilterData _$SummonFilterDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('SummonFilterData', json, () {
    final val = SummonFilterData(
      favorite: $checkedConvert(json, 'favorite', (v) => v as bool?),
      reversed: $checkedConvert(json, 'reversed', (v) => v as bool?),
      showBanner: $checkedConvert(json, 'showBanner', (v) => v as bool?),
      showOutdated: $checkedConvert(json, 'showOutdated', (v) => v as bool?),
      category: $checkedConvert(
          json,
          'category',
          (v) => v == null
              ? null
              : FilterGroupData.fromJson(v as Map<String, dynamic>)),
    );
    return val;
  });
}

Map<String, dynamic> _$SummonFilterDataToJson(SummonFilterData instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'reversed': instance.reversed,
      'showBanner': instance.showBanner,
      'showOutdated': instance.showOutdated,
      'category': instance.category,
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

User _$UserFromJson(Map<String, dynamic> json) {
  return $checkedNew('User', json, () {
    final val = User(
      key: $checkedConvert(json, 'key', (v) => v as String?),
      name: $checkedConvert(json, 'name', (v) => v as String?),
      server: $checkedConvert(
          json, 'server', (v) => _$enumDecodeNullable(_$GameServerEnumMap, v)),
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
      crafts: $checkedConvert(
          json,
          'crafts',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), e as int),
              )),
      mysticCodes: $checkedConvert(
          json,
          'mysticCodes',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      plannedSummons: $checkedConvert(json, 'plannedSummons',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
      saintQuartzPlan: $checkedConvert(
          json,
          'saintQuartzPlan',
          (v) => v == null
              ? null
              : SaintQuartzPlan.fromJson(v as Map<String, dynamic>)),
      isMasterGirl: $checkedConvert(json, 'isMasterGirl', (v) => v as bool?),
      msProgress: $checkedConvert(json, 'msProgress', (v) => v as int?),
      duplicatedServants: $checkedConvert(
          json,
          'duplicatedServants',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), e as int),
              )),
      glpkParams: $checkedConvert(
          json,
          'glpkParams',
          (v) => v == null
              ? null
              : GLPKParams.fromJson(v as Map<String, dynamic>)),
      luckyBagSvtScores: $checkedConvert(
          json,
          'luckyBagSvtScores',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k,
                    (e as Map<String, dynamic>).map(
                      (k, e) => MapEntry(int.parse(k), e as int),
                    )),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'server': _$GameServerEnumMap[instance.server],
      'servants': User._servantsToJson(instance.servants),
      'servantPlans': User._servantPlansToJson(instance.servantPlans),
      'curSvtPlanNo': instance.curSvtPlanNo,
      'items': instance.items,
      'events': instance.events,
      'crafts': User._craftsPlanToJson(instance.crafts),
      'mysticCodes': instance.mysticCodes,
      'plannedSummons': instance.plannedSummons.toList(),
      'saintQuartzPlan': instance.saintQuartzPlan,
      'isMasterGirl': instance.isMasterGirl,
      'msProgress': instance.msProgress,
      'duplicatedServants':
          instance.duplicatedServants.map((k, e) => MapEntry(k.toString(), e)),
      'glpkParams': instance.glpkParams,
      'luckyBagSvtScores': instance.luckyBagSvtScores.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
    };

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$GameServerEnumMap = {
  GameServer.jp: 'jp',
  GameServer.cn: 'cn',
  GameServer.tw: 'tw',
  GameServer.en: 'en',
};

ServantStatus _$ServantStatusFromJson(Map<String, dynamic> json) {
  return $checkedNew('ServantStatus', json, () {
    final val = ServantStatus(
      favorite: $checkedConvert(json, 'favorite', (v) => v as bool?),
      curVal: $checkedConvert(
          json,
          'curVal',
          (v) => v == null
              ? null
              : ServantPlan.fromJson(v as Map<String, dynamic>)),
      coin: $checkedConvert(json, 'coin', (v) => v as int?),
      npLv: $checkedConvert(json, 'npLv', (v) => v as int?),
      priority: $checkedConvert(json, 'priority', (v) => v as int?),
      equipCmdCodes: $checkedConvert(json, 'equipCmdCodes',
          (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
      skillIndex: $checkedConvert(json, 'skillIndex',
          (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
      npIndex: $checkedConvert(json, 'npIndex', (v) => v as int?),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantStatusToJson(ServantStatus instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'curVal': instance.curVal,
      'coin': instance.coin,
      'npLv': instance.npLv,
      'priority': instance.priority,
      'equipCmdCodes': instance.equipCmdCodes,
      'skillIndex': instance.skillIndex,
      'npIndex': instance.npIndex,
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
      appendSkills: $checkedConvert(json, 'appendSkills',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
      grail: $checkedConvert(json, 'grail', (v) => v as int?),
      fouHp: $checkedConvert(json, 'fouHp', (v) => v as int?),
      fouAtk: $checkedConvert(json, 'fouAtk', (v) => v as int?),
      bondLimit: $checkedConvert(json, 'bondLimit', (v) => v as int?),
    );
    return val;
  });
}

Map<String, dynamic> _$ServantPlanToJson(ServantPlan instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'ascension': instance.ascension,
      'skills': instance.skills,
      'appendSkills': instance.appendSkills,
      'dress': instance.dress,
      'grail': instance.grail,
      'fouHp': instance.fouHp,
      'fouAtk': instance.fouAtk,
      'bondLimit': instance.bondLimit,
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
                    k, MainRecordPlan.fromJson(e as Map<String, dynamic>)),
              )),
      exchangeTickets: $checkedConvert(
          json,
          'exchangeTickets',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, ExchangeTicketPlan.fromJson(e as Map<String, dynamic>)),
              )),
      campaigns: $checkedConvert(
          json,
          'campaigns',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, CampaignPlan.fromJson(e as Map<String, dynamic>)),
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
      'campaigns': instance.campaigns,
    };

LimitEventPlan _$LimitEventPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('LimitEventPlan', json, () {
    final val = LimitEventPlan(
      enabled: $checkedConvert(json, 'enabled', (v) => v as bool?),
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
      'enabled': instance.enabled,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'extra': instance.extra,
    };

MainRecordPlan _$MainRecordPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('MainRecordPlan', json, () {
    final val = MainRecordPlan(
      drop: $checkedConvert(json, 'drop', (v) => v as bool?),
      reward: $checkedConvert(json, 'reward', (v) => v as bool?),
    );
    return val;
  });
}

Map<String, dynamic> _$MainRecordPlanToJson(MainRecordPlan instance) =>
    <String, dynamic>{
      'drop': instance.drop,
      'reward': instance.reward,
    };

ExchangeTicketPlan _$ExchangeTicketPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('ExchangeTicketPlan', json, () {
    final val = ExchangeTicketPlan(
      item1: $checkedConvert(json, 'item1', (v) => v as int?),
      item2: $checkedConvert(json, 'item2', (v) => v as int?),
      item3: $checkedConvert(json, 'item3', (v) => v as int?),
    );
    return val;
  });
}

Map<String, dynamic> _$ExchangeTicketPlanToJson(ExchangeTicketPlan instance) =>
    <String, dynamic>{
      'item1': instance.item1,
      'item2': instance.item2,
      'item3': instance.item3,
    };

CampaignPlan _$CampaignPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('CampaignPlan', json, () {
    final val = CampaignPlan(
      enabled: $checkedConvert(json, 'enabled', (v) => v as bool?),
      rerun: $checkedConvert(json, 'rerun', (v) => v as bool?),
    );
    return val;
  });
}

Map<String, dynamic> _$CampaignPlanToJson(CampaignPlan instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'rerun': instance.rerun,
    };

SaintQuartzPlan _$SaintQuartzPlanFromJson(Map<String, dynamic> json) {
  return $checkedNew('SaintQuartzPlan', json, () {
    final val = SaintQuartzPlan(
      curSQ: $checkedConvert(json, 'curSQ', (v) => v as int?),
      curTicket: $checkedConvert(json, 'curTicket', (v) => v as int?),
      curApple: $checkedConvert(json, 'curApple', (v) => v as int?),
      startDate: $checkedConvert(json, 'startDate',
          (v) => v == null ? null : DateTime.parse(v as String)),
      endDate: $checkedConvert(json, 'endDate',
          (v) => v == null ? null : DateTime.parse(v as String)),
      accLogin: $checkedConvert(json, 'accLogin', (v) => v as int?),
      continuousLogin:
          $checkedConvert(json, 'continuousLogin', (v) => v as int?),
      eventDateDelta: $checkedConvert(json, 'eventDateDelta', (v) => v as int?),
      weeklyMission: $checkedConvert(json, 'weeklyMission', (v) => v as bool?),
      minusPlannedBanner:
          $checkedConvert(json, 'minusPlannedBanner', (v) => v as bool?),
    );
    $checkedConvert(
        json,
        'extraMissions',
        (v) => val.extraMissions = (v as Map<String, dynamic>).map(
              (k, e) => MapEntry(int.parse(k), e as bool),
            ));
    return val;
  });
}

Map<String, dynamic> _$SaintQuartzPlanToJson(SaintQuartzPlan instance) =>
    <String, dynamic>{
      'curSQ': instance.curSQ,
      'curTicket': instance.curTicket,
      'curApple': instance.curApple,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'accLogin': instance.accLogin,
      'continuousLogin': instance.continuousLogin,
      'eventDateDelta': instance.eventDateDelta,
      'weeklyMission': instance.weeklyMission,
      'extraMissions':
          instance.extraMissions.map((k, e) => MapEntry(k.toString(), e)),
      'minusPlannedBanner': instance.minusPlannedBanner,
    };

AppSetting _$AppSettingFromJson(Map<String, dynamic> json) {
  return $checkedNew('AppSetting', json, () {
    final val = AppSetting(
      language: $checkedConvert(json, 'language', (v) => v as String?),
      themeMode: $checkedConvert(
          json,
          'themeMode',
          (v) => _$enumDecodeNullable(_$ThemeModeEnumMap, v,
              unknownValue: ThemeMode.system)),
      favoritePreferred:
          $checkedConvert(json, 'favoritePreferred', (v) => v as bool?),
      autoResetFilter:
          $checkedConvert(json, 'autoResetFilter', (v) => v as bool?),
      downloadSource: $checkedConvert(json, 'downloadSource', (v) => v as int?),
      autoUpdateApp: $checkedConvert(json, 'autoUpdateApp', (v) => v as bool?),
      autoUpdateDataset:
          $checkedConvert(json, 'autoUpdateDataset', (v) => v as bool?),
      autorotate: $checkedConvert(json, 'autorotate', (v) => v as bool?),
      classFilterStyle: $checkedConvert(
          json,
          'classFilterStyle',
          (v) => _$enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v,
              unknownValue: SvtListClassFilterStyle.auto)),
      svtPlanSliderMode:
          $checkedConvert(json, 'svtPlanSliderMode', (v) => v as bool?),
      sortedSvtTabs: $checkedConvert(
          json,
          'sortedSvtTabs',
          (v) => (v as List<dynamic>?)
              ?.map((e) => _$enumDecodeNullable(_$SvtTabEnumMap, e,
                  unknownValue: SvtTab.plan))
              .toList()),
      priorityTags: $checkedConvert(
          json,
          'priorityTags',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
    );
    return val;
  });
}

Map<String, dynamic> _$AppSettingToJson(AppSetting instance) =>
    <String, dynamic>{
      'language': instance.language,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'favoritePreferred': instance.favoritePreferred,
      'autoResetFilter': instance.autoResetFilter,
      'classFilterStyle':
          _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle],
      'autoUpdateApp': instance.autoUpdateApp,
      'autoUpdateDataset': instance.autoUpdateDataset,
      'autorotate': instance.autorotate,
      'downloadSource': instance.downloadSource,
      'svtPlanSliderMode': instance.svtPlanSliderMode,
      'sortedSvtTabs':
          instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]).toList(),
      'priorityTags': instance.priorityTags,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$SvtListClassFilterStyleEnumMap = {
  SvtListClassFilterStyle.auto: 'auto',
  SvtListClassFilterStyle.singleRow: 'singleRow',
  SvtListClassFilterStyle.singleRowExpanded: 'singleRowExpanded',
  SvtListClassFilterStyle.twoRow: 'twoRow',
  SvtListClassFilterStyle.doNotShow: 'doNotShow',
};

const _$SvtTabEnumMap = {
  SvtTab.plan: 'plan',
  SvtTab.skill: 'skill',
  SvtTab.np: 'np',
  SvtTab.info: 'info',
  SvtTab.illustration: 'illustration',
  SvtTab.sprite: 'sprite',
  SvtTab.summon: 'summon',
  SvtTab.voice: 'voice',
  SvtTab.quest: 'quest',
};

CarouselSetting _$CarouselSettingFromJson(Map<String, dynamic> json) {
  return $checkedNew('CarouselSetting', json, () {
    final val = CarouselSetting(
      updateTime: $checkedConvert(json, 'updateTime', (v) => v as int?),
      urls: $checkedConvert(
          json,
          'urls',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              )),
      enableMooncell:
          $checkedConvert(json, 'enableMooncell', (v) => v as bool?),
      enableJp: $checkedConvert(json, 'enableJp', (v) => v as bool?),
      enableUs: $checkedConvert(json, 'enableUs', (v) => v as bool?),
    );
    return val;
  });
}

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) =>
    <String, dynamic>{
      'updateTime': instance.updateTime,
      'urls': instance.urls,
      'enableMooncell': instance.enableMooncell,
      'enableJp': instance.enableJp,
      'enableUs': instance.enableUs,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return $checkedNew('UserData', json, () {
    final val = UserData(
      version: $checkedConvert(json, 'version', (v) => v as int?),
      appSetting: $checkedConvert(
          json,
          'appSetting',
          (v) => v == null
              ? null
              : AppSetting.fromJson(v as Map<String, dynamic>)),
      carouselSetting: $checkedConvert(
          json,
          'carouselSetting',
          (v) => v == null
              ? null
              : CarouselSetting.fromJson(v as Map<String, dynamic>)),
      galleries: $checkedConvert(
          json,
          'galleries',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as bool),
              )),
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
      summonFilter: $checkedConvert(
          json,
          'summonFilter',
          (v) => v == null
              ? null
              : SummonFilterData.fromJson(v as Map<String, dynamic>)),
      itemAbundantValue: $checkedConvert(json, 'itemAbundantValue',
          (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'version': instance.version,
      'appSetting': instance.appSetting,
      'carouselSetting': instance.carouselSetting,
      'galleries': instance.galleries,
      'users': instance.users,
      'svtFilter': instance.svtFilter,
      'craftFilter': instance.craftFilter,
      'cmdCodeFilter': instance.cmdCodeFilter,
      'summonFilter': instance.summonFilter,
      'itemAbundantValue': instance.itemAbundantValue,
      'curUserKey': instance.curUserKey,
    };
