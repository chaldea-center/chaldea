// GENERATED CODE - DO NOT MODIFY BY HAND

part of datatypes;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyValueEntry _$KeyValueEntryFromJson(Map<String, dynamic> json) =>
    KeyValueEntry(
      key: json['key'] as String?,
      value: json['value'],
    );

Map<String, dynamic> _$KeyValueEntryToJson(KeyValueEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

KeyValueListEntry _$KeyValueListEntryFromJson(Map<String, dynamic> json) =>
    KeyValueListEntry(
      key: json['key'] as String?,
      valueList: json['valueList'] as List<dynamic>?,
    );

Map<String, dynamic> _$KeyValueListEntryToJson(KeyValueListEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'valueList': instance.valueList,
    };

BiliTopLogin _$BiliTopLoginFromJson(Map<String, dynamic> json) => BiliTopLogin(
      response: json['response'],
      cache: json['cache'] == null
          ? null
          : BiliCache.fromJson(json['cache'] as Map<String, dynamic>),
      sign: json['sign'] as String?,
    );

BiliCache _$BiliCacheFromJson(Map<String, dynamic> json) => BiliCache(
      replaced: json['replaced'] == null
          ? null
          : BiliReplaced.fromJson(json['replaced'] as Map<String, dynamic>),
      updated: json['updated'] == null
          ? null
          : BiliUpdated.fromJson(json['updated'] as Map<String, dynamic>),
      serverTime: json['serverTime'] as int?,
    );

BiliUpdated _$BiliUpdatedFromJson(Map<String, dynamic> json) => BiliUpdated();

BiliReplaced _$BiliReplacedFromJson(Map<String, dynamic> json) => BiliReplaced(
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
      userSvtAppendPassiveSkill:
          (json['userSvtAppendPassiveSkill'] as List<dynamic>?)
              ?.map((e) =>
                  UserSvtAppendPassiveSkill.fromJson(e as Map<String, dynamic>))
              .toList(),
      userSvtCoin: (json['userSvtCoin'] as List<dynamic>?)
          ?.map((e) => UserSvtCoin.fromJson(e as Map<String, dynamic>))
          .toList(),
      userSvtAppendPassiveSkillLv: (json['userSvtAppendPassiveSkillLv']
              as List<dynamic>?)
          ?.map((e) =>
              UserSvtAppendPassiveSkillLv.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

UserItem _$UserItemFromJson(Map<String, dynamic> json) => UserItem(
      itemId: json['itemId'],
      num: json['num'],
    );

UserSvt _$UserSvtFromJson(Map<String, dynamic> json) => UserSvt(
      id: json['id'],
      svtId: json['svtId'],
      status: json['status'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      exp: json['exp'],
      adjustHp: json['adjustHp'],
      adjustAtk: json['adjustAtk'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      treasureDeviceLv1: json['treasureDeviceLv1'],
      exceedCount: json['exceedCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isLock: json['isLock'],
      hp: json['hp'] as int,
      atk: json['atk'] as int,
    );

UserSvtCollection _$UserSvtCollectionFromJson(Map<String, dynamic> json) =>
    UserSvtCollection(
      svtId: json['svtId'],
      status: json['status'],
      friendship: json['friendship'],
      friendshipRank: json['friendshipRank'],
      friendshipExceedCount: json['friendshipExceedCount'],
      costumeIds:
          (json['costumeIds'] as List<dynamic>).map((e) => e as int).toList(),
    );

UserGame _$UserGameFromJson(Map<String, dynamic> json) => UserGame(
      id: json['id'],
      userId: json['userId'],
      appname: json['appname'] as String?,
      name: json['name'] as String,
      birthDay: json['birthDay'],
      actMax: json['actMax'],
      genderType: json['genderType'],
      lv: json['lv'],
      exp: json['exp'],
      qp: json['qp'],
      costMax: json['costMax'],
      friendCode: json['friendCode'] as String,
      freeStone: json['freeStone'],
      chargeStone: json['chargeStone'],
      mana: json['mana'],
      rarePri: json['rarePri'],
      createdAt: json['createdAt'],
      message: json['message'] as String,
      stone: json['stone'] as int,
    );

UserSvtAppendPassiveSkill _$UserSvtAppendPassiveSkillFromJson(
        Map<String, dynamic> json) =>
    UserSvtAppendPassiveSkill(
      unlockNums:
          (json['unlockNums'] as List<dynamic>?)?.map((e) => e as int).toList(),
      svtId: json['svtId'],
    );

UserSvtCoin _$UserSvtCoinFromJson(Map<String, dynamic> json) => UserSvtCoin(
      svtId: json['svtId'],
      num: json['num'],
    );

UserSvtAppendPassiveSkillLv _$UserSvtAppendPassiveSkillLvFromJson(
        Map<String, dynamic> json) =>
    UserSvtAppendPassiveSkillLv(
      userSvtId: json['userSvtId'],
      appendPassiveSkillNums: (json['appendPassiveSkillNums'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      appendPassiveSkillLvs: (json['appendPassiveSkillLvs'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

CommandCode _$CommandCodeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'CommandCode',
      json,
      ($checkedConvert) {
        final val = CommandCode(
          gameId: $checkedConvert('gameId', (v) => v as int),
          no: $checkedConvert('no', (v) => v as int),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameOther: $checkedConvert('nameOther',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          rarity: $checkedConvert('rarity', (v) => v as int),
          icon: $checkedConvert('icon', (v) => v as String),
          illustration: $checkedConvert('illustration', (v) => v as String),
          illustrators: $checkedConvert('illustrators',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          illustratorsJp:
              $checkedConvert('illustratorsJp', (v) => v as String?),
          illustratorsEn:
              $checkedConvert('illustratorsEn', (v) => v as String?),
          skillIcon: $checkedConvert('skillIcon', (v) => v as String),
          skill: $checkedConvert('skill', (v) => v as String),
          skillEn: $checkedConvert('skillEn', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          obtain: $checkedConvert('obtain', (v) => v as String),
          category: $checkedConvert('category', (v) => v as String),
          categoryText: $checkedConvert('categoryText', (v) => v as String),
          characters: $checkedConvert('characters',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          niceSkills: $checkedConvert(
              'niceSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => NiceSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'niceSkills': instance.niceSkills,
    };

CraftEssence _$CraftEssenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CraftEssence',
      json,
      ($checkedConvert) {
        final val = CraftEssence(
          gameId: $checkedConvert('gameId', (v) => v as int),
          no: $checkedConvert('no', (v) => v as int),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          nameOther: $checkedConvert('nameOther',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          rarity: $checkedConvert('rarity', (v) => v as int),
          icon: $checkedConvert('icon', (v) => v as String),
          illustration: $checkedConvert('illustration', (v) => v as String),
          illustrators: $checkedConvert('illustrators',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          illustratorsJp:
              $checkedConvert('illustratorsJp', (v) => v as String?),
          illustratorsEn:
              $checkedConvert('illustratorsEn', (v) => v as String?),
          cost: $checkedConvert('cost', (v) => v as int),
          lvMax: $checkedConvert('lvMax', (v) => v as int),
          hpMin: $checkedConvert('hpMin', (v) => v as int),
          hpMax: $checkedConvert('hpMax', (v) => v as int),
          atkMin: $checkedConvert('atkMin', (v) => v as int),
          atkMax: $checkedConvert('atkMax', (v) => v as int),
          skillIcon: $checkedConvert('skillIcon', (v) => v as String?),
          skill: $checkedConvert('skill', (v) => v as String),
          skillMax: $checkedConvert('skillMax', (v) => v as String?),
          skillEn: $checkedConvert('skillEn', (v) => v as String?),
          skillMaxEn: $checkedConvert('skillMaxEn', (v) => v as String?),
          eventIcons: $checkedConvert('eventIcons',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          eventSkills: $checkedConvert('eventSkills',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          description: $checkedConvert('description', (v) => v as String?),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          category: $checkedConvert('category', (v) => v as String),
          categoryText: $checkedConvert('categoryText', (v) => v as String),
          characters: $checkedConvert('characters',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          bond: $checkedConvert('bond', (v) => v as int? ?? -1),
          valentine: $checkedConvert('valentine', (v) => v as int? ?? -1),
          niceSkills: $checkedConvert(
              'niceSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => NiceSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'lvMax': instance.lvMax,
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
      'niceSkills': instance.niceSkills,
    };

EnemyDetail _$EnemyDetailFromJson(Map<String, dynamic> json) => $checkedCreate(
      'EnemyDetail',
      json,
      ($checkedConvert) {
        final val = EnemyDetail(
          category: $checkedConvert('category', (v) => v as String),
          icon: $checkedConvert('icon', (v) => v as String?),
          ids: $checkedConvert('ids',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          names: $checkedConvert('names',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          classIcons: $checkedConvert('classIcons',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          attribute: $checkedConvert('attribute', (v) => v as String),
          traits: $checkedConvert('traits',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          actions: $checkedConvert('actions', (v) => v as int?),
          charges: $checkedConvert('charges',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          deathRate: $checkedConvert('deathRate', (v) => v as String?),
          noblePhantasm: $checkedConvert('noblePhantasm', (v) => v as String),
          skill: $checkedConvert('skill', (v) => v as String),
          hitsCommon: $checkedConvert('hitsCommon',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          hitsCritical: $checkedConvert('hitsCritical',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          hitsNp: $checkedConvert('hitsNp',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          firstStage: $checkedConvert('firstStage', (v) => v as String),
        );
        return val;
      },
    );

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

Events _$EventsFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Events',
      json,
      ($checkedConvert) {
        final val = Events(
          progressNA: $checkedConvert('progressNA', (v) => v as String?),
          progressTW: $checkedConvert('progressTW', (v) => v as String?),
          limitEvents: $checkedConvert(
              'limitEvents',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, LimitEvent.fromJson(e as Map<String, dynamic>)),
                  )),
          mainRecords: $checkedConvert(
              'mainRecords',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, MainRecord.fromJson(e as Map<String, dynamic>)),
                  )),
          exchangeTickets: $checkedConvert(
              'exchangeTickets',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, ExchangeTicket.fromJson(e as Map<String, dynamic>)),
                  )),
          campaigns: $checkedConvert(
              'campaigns',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, CampaignEvent.fromJson(e as Map<String, dynamic>)),
                  )),
          extraMasterMissions: $checkedConvert(
              'extraMasterMissions',
              (v) => (v as List<dynamic>)
                  .map((e) => MasterMission.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$EventsToJson(Events instance) => <String, dynamic>{
      'progressNA': instance.progressNA.toIso8601String(),
      'progressTW': instance.progressTW.toIso8601String(),
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'campaigns': instance.campaigns,
      'exchangeTickets': instance.exchangeTickets,
      'extraMasterMissions': instance.extraMasterMissions,
    };

LimitEvent _$LimitEventFromJson(Map<String, dynamic> json) => $checkedCreate(
      'LimitEvent',
      json,
      ($checkedConvert) {
        final val = LimitEvent(
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          startTimeJp: $checkedConvert('startTimeJp', (v) => v as String?),
          endTimeJp: $checkedConvert('endTimeJp', (v) => v as String?),
          startTimeCn: $checkedConvert('startTimeCn', (v) => v as String?),
          endTimeCn: $checkedConvert('endTimeCn', (v) => v as String?),
          bannerUrl: $checkedConvert('bannerUrl', (v) => v as String?),
          bannerUrlJp: $checkedConvert('bannerUrlJp', (v) => v as String?),
          grail: $checkedConvert('grail', (v) => v as int),
          crystal: $checkedConvert('crystal', (v) => v as int),
          grail2crystal: $checkedConvert('grail2crystal', (v) => v as int),
          foukun4: $checkedConvert('foukun4', (v) => v as int),
          rarePrism: $checkedConvert('rarePrism', (v) => v as int),
          welfareServant: $checkedConvert('welfareServant', (v) => v as int),
          items:
              $checkedConvert('items', (v) => Map<String, int>.from(v as Map)),
          lotteryLimit: $checkedConvert('lotteryLimit', (v) => v as int),
          lottery: $checkedConvert(
              'lottery', (v) => Map<String, int>.from(v as Map)),
          extra: $checkedConvert(
              'extra', (v) => Map<String, String>.from(v as Map)),
          extra2: $checkedConvert(
              'extra2', (v) => Map<String, String>.from(v as Map)),
          mainQuests: $checkedConvert(
              'mainQuests',
              (v) => (v as List<dynamic>)
                  .map((e) => Quest.fromJson(e as Map<String, dynamic>))
                  .toList()),
          freeQuests: $checkedConvert(
              'freeQuests',
              (v) => (v as List<dynamic>)
                  .map((e) => Quest.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'mainQuests': instance.mainQuests,
      'lotteryLimit': instance.lotteryLimit,
      'lottery': instance.lottery,
      'extra': instance.extra,
      'extra2': instance.extra2,
      'freeQuests': instance.freeQuests,
    };

MainRecord _$MainRecordFromJson(Map<String, dynamic> json) => $checkedCreate(
      'MainRecord',
      json,
      ($checkedConvert) {
        final val = MainRecord(
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          startTimeJp: $checkedConvert('startTimeJp', (v) => v as String?),
          endTimeJp: $checkedConvert('endTimeJp', (v) => v as String?),
          startTimeCn: $checkedConvert('startTimeCn', (v) => v as String?),
          endTimeCn: $checkedConvert('endTimeCn', (v) => v as String?),
          bannerUrl: $checkedConvert('bannerUrl', (v) => v as String?),
          bannerUrlJp: $checkedConvert('bannerUrlJp', (v) => v as String?),
          grail: $checkedConvert('grail', (v) => v as int),
          crystal: $checkedConvert('crystal', (v) => v as int),
          grail2crystal: $checkedConvert('grail2crystal', (v) => v as int),
          foukun4: $checkedConvert('foukun4', (v) => v as int),
          rarePrism: $checkedConvert('rarePrism', (v) => v as int),
          welfareServant: $checkedConvert('welfareServant', (v) => v as int),
          drops:
              $checkedConvert('drops', (v) => Map<String, int>.from(v as Map)),
          rewards: $checkedConvert(
              'rewards', (v) => Map<String, int>.from(v as Map)),
          mainQuests: $checkedConvert(
              'mainQuests',
              (v) => (v as List<dynamic>)
                  .map((e) => Quest.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'mainQuests': instance.mainQuests,
      'drops': instance.drops,
      'rewards': instance.rewards,
    };

CampaignEvent _$CampaignEventFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CampaignEvent',
      json,
      ($checkedConvert) {
        final val = CampaignEvent(
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          startTimeJp: $checkedConvert('startTimeJp', (v) => v as String?),
          endTimeJp: $checkedConvert('endTimeJp', (v) => v as String?),
          startTimeCn: $checkedConvert('startTimeCn', (v) => v as String?),
          endTimeCn: $checkedConvert('endTimeCn', (v) => v as String?),
          bannerUrl: $checkedConvert('bannerUrl', (v) => v as String?),
          bannerUrlJp: $checkedConvert('bannerUrlJp', (v) => v as String?),
          grail: $checkedConvert('grail', (v) => v as int),
          crystal: $checkedConvert('crystal', (v) => v as int),
          grail2crystal: $checkedConvert('grail2crystal', (v) => v as int),
          foukun4: $checkedConvert('foukun4', (v) => v as int),
          rarePrism: $checkedConvert('rarePrism', (v) => v as int),
          welfareServant: $checkedConvert('welfareServant', (v) => v as int),
          items:
              $checkedConvert('items', (v) => Map<String, int>.from(v as Map)),
          mainQuests: $checkedConvert(
              'mainQuests',
              (v) => (v as List<dynamic>)
                  .map((e) => Quest.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'mainQuests': instance.mainQuests,
    };

ExchangeTicket _$ExchangeTicketFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ExchangeTicket',
      json,
      ($checkedConvert) {
        final val = ExchangeTicket(
          monthJp: $checkedConvert('monthJp', (v) => v as String),
          items: $checkedConvert('items',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          monthCn: $checkedConvert('monthCn', (v) => v as String?),
          monthTw: $checkedConvert('monthTw', (v) => v as String?),
          monthEn: $checkedConvert('monthEn', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$ExchangeTicketToJson(ExchangeTicket instance) =>
    <String, dynamic>{
      'monthJp': instance.monthJp,
      'items': instance.items,
      'monthCn': instance.monthCn,
      'monthTw': instance.monthTw,
      'monthEn': instance.monthEn,
    };

MasterMission _$MasterMissionFromJson(Map<String, dynamic> json) =>
    MasterMission(
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

GameData _$GameDataFromJson(Map<String, dynamic> json) => $checkedCreate(
      'GameData',
      json,
      ($checkedConvert) {
        final val = GameData(
          version: $checkedConvert('version', (v) => v as String? ?? '0'),
          unavailableSvts: $checkedConvert(
              'unavailableSvts',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as int).toList() ??
                  const []),
          servants: $checkedConvert(
              'servants',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k),
                        Servant.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          costumes: $checkedConvert(
              'costumes',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k),
                        Costume.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          crafts: $checkedConvert(
              'crafts',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k),
                        CraftEssence.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          cmdCodes: $checkedConvert(
              'cmdCodes',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k),
                        CommandCode.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          items: $checkedConvert(
              'items',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) =>
                        MapEntry(k, Item.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          icons: $checkedConvert(
              'icons',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as String?),
                  ) ??
                  const {}),
          events: $checkedConvert(
              'events',
              (v) => v == null
                  ? null
                  : Events.fromJson(v as Map<String, dynamic>)),
          freeQuests: $checkedConvert(
              'freeQuests',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) =>
                        MapEntry(k, Quest.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          svtQuests: $checkedConvert(
              'svtQuests',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k),
                        (e as List<dynamic>)
                            .map((e) =>
                                Quest.fromJson(e as Map<String, dynamic>))
                            .toList()),
                  ) ??
                  const {}),
          mysticCodes: $checkedConvert(
              'mysticCodes',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k, MysticCode.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          summons: $checkedConvert(
              'summons',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) =>
                        MapEntry(k, Summon.fromJson(e as Map<String, dynamic>)),
                  ) ??
                  const {}),
          planningData: $checkedConvert(
              'planningData',
              (v) => v == null
                  ? null
                  : PlanningData.fromJson(v as Map<String, dynamic>)),
          categorizedEnemies: $checkedConvert(
              'categorizedEnemies',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k,
                        (e as List<dynamic>)
                            .map((e) =>
                                EnemyDetail.fromJson(e as Map<String, dynamic>))
                            .toList()),
                  ) ??
                  const {}),
          fsmSvtIdMapping: $checkedConvert(
              'fsmSvtIdMapping',
              (v) =>
                  (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k), e as int),
                  ) ??
                  const {}),
        );
        return val;
      },
    );

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
      'mysticCodes': instance.mysticCodes,
      'summons': instance.summons,
      'planningData': instance.planningData,
      'categorizedEnemies': instance.categorizedEnemies,
      'fsmSvtIdMapping':
          instance.fsmSvtIdMapping.map((k, e) => MapEntry(k.toString(), e)),
    };

ItemCost _$ItemCostFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ItemCost',
      json,
      ($checkedConvert) {
        final val = ItemCost(
          ascension: $checkedConvert(
              'ascension',
              (v) => (v as List<dynamic>)
                  .map((e) => Map<String, int>.from(e as Map))
                  .toList()),
          skill: $checkedConvert(
              'skill',
              (v) => (v as List<dynamic>)
                  .map((e) => Map<String, int>.from(e as Map))
                  .toList()),
          appendSkill: $checkedConvert(
              'appendSkill',
              (v) => (v as List<dynamic>)
                  .map((e) => Map<String, int>.from(e as Map))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ItemCostToJson(ItemCost instance) => <String, dynamic>{
      'ascension': instance.ascension,
      'skill': instance.skill,
      'appendSkill': instance.appendSkill,
    };

PlanningData _$PlanningDataFromJson(Map<String, dynamic> json) => PlanningData(
      dropRates:
          DropRateData.fromJson(json['dropRates'] as Map<String, dynamic>),
      legacyDropRates: DropRateData.fromJson(
          json['legacyDropRates'] as Map<String, dynamic>),
      weeklyMissions: (json['weeklyMissions'] as List<dynamic>)
          .map((e) => WeeklyMissionQuest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlanningDataToJson(PlanningData instance) =>
    <String, dynamic>{
      'dropRates': instance.dropRates,
      'legacyDropRates': instance.legacyDropRates,
      'weeklyMissions': instance.weeklyMissions,
    };

DropRateData _$DropRateDataFromJson(Map<String, dynamic> json) => DropRateData(
      freeCounts: (json['freeCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as int),
          ) ??
          const {},
      sampleNum: (json['sampleNum'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      colNames: (json['colNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rowNames: (json['rowNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      costs: (json['costs'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      sparseMatrix: (json['sparseMatrix'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                int.parse(k),
                (e as Map<String, dynamic>).map(
                  (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
                )),
          ) ??
          const {},
    );

Map<String, dynamic> _$DropRateDataToJson(DropRateData instance) =>
    <String, dynamic>{
      'freeCounts': instance.freeCounts,
      'sampleNum': instance.sampleNum,
      'colNames': instance.colNames,
      'rowNames': instance.rowNames,
      'costs': instance.costs,
      'sparseMatrix': instance.sparseMatrix.map((k, e) =>
          MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
    };

WeeklyMissionQuest _$WeeklyMissionQuestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WeeklyMissionQuest',
      json,
      ($checkedConvert) {
        final val = WeeklyMissionQuest(
          chapter: $checkedConvert('chapter', (v) => v as String),
          place: $checkedConvert('place', (v) => v as String),
          placeJp: $checkedConvert('placeJp', (v) => v as String),
          ap: $checkedConvert('ap', (v) => v as int),
          enemyTraits: $checkedConvert(
              'enemyTraits', (v) => Map<String, int>.from(v as Map)),
          servantTraits: $checkedConvert(
              'servantTraits', (v) => Map<String, int>.from(v as Map)),
          servants: $checkedConvert('servants',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          battlefields: $checkedConvert('battlefields',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
    );

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

GLPKParams _$GLPKParamsFromJson(Map<String, dynamic> json) => $checkedCreate(
      'GLPKParams',
      json,
      ($checkedConvert) {
        final val = GLPKParams(
          use6th: $checkedConvert('use6th', (v) => v as bool?),
          rows: $checkedConvert('rows',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          blacklist: $checkedConvert('blacklist',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          minCost: $checkedConvert('minCost', (v) => v as int? ?? 0),
          costMinimize:
              $checkedConvert('costMinimize', (v) => v as bool? ?? true),
          maxColNum: $checkedConvert('maxColNum', (v) => v as int? ?? -1),
          extraCols: $checkedConvert('extraCols',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          integerResult:
              $checkedConvert('integerResult', (v) => v as bool? ?? false),
          useAP20: $checkedConvert('useAP20', (v) => v as bool? ?? true),
          planItemCounts: $checkedConvert(
              'planItemCounts',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as int),
                  )),
          planItemWeights: $checkedConvert(
              'planItemWeights',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, (e as num).toDouble()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$GLPKParamsToJson(GLPKParams instance) =>
    <String, dynamic>{
      'use6th': instance.use6th,
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

GLPKSolution _$GLPKSolutionFromJson(Map<String, dynamic> json) => GLPKSolution(
      destination: json['destination'] as int? ?? 0,
      originalItems: (json['originalItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      totalCost: json['totalCost'] as int?,
      totalNum: json['totalNum'] as int?,
      countVars: (json['countVars'] as List<dynamic>?)
          ?.map(
              (e) => GLPKVariable<dynamic>.fromJson(e as Map<String, dynamic>))
          .toList(),
      weightVars: (json['weightVars'] as List<dynamic>?)
          ?.map(
              (e) => GLPKVariable<dynamic>.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GLPKSolutionToJson(GLPKSolution instance) =>
    <String, dynamic>{
      'destination': instance.destination,
      'originalItems': instance.originalItems,
      'totalCost': instance.totalCost,
      'totalNum': instance.totalNum,
      'countVars': instance.countVars,
      'weightVars': instance.weightVars,
    };

GLPKVariable<T> _$GLPKVariableFromJson<T>(Map<String, dynamic> json) =>
    GLPKVariable<T>(
      name: json['name'] as String,
      value: _Converter<T>().fromJson(json['value'] as Object),
      cost: json['cost'] as int,
      detail: (json['detail'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, _Converter<T>().fromJson(e as Object)),
      ),
    );

Map<String, dynamic> _$GLPKVariableToJson<T>(GLPKVariable<T> instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': _Converter<T>().toJson(instance.value),
      'cost': instance.cost,
      'detail':
          instance.detail.map((k, e) => MapEntry(k, _Converter<T>().toJson(e))),
    };

BasicGLPKParams _$BasicGLPKParamsFromJson(Map<String, dynamic> json) =>
    BasicGLPKParams(
      colNames: (json['colNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rowNames: (json['rowNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      AMat: (json['AMat'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as num).toList())
          .toList(),
      bVec: (json['bVec'] as List<dynamic>?)?.map((e) => e as num).toList(),
      cVec: (json['cVec'] as List<dynamic>?)?.map((e) => e as num).toList(),
      integer: json['integer'] as bool?,
    );

Map<String, dynamic> _$BasicGLPKParamsToJson(BasicGLPKParams instance) =>
    <String, dynamic>{
      'colNames': instance.colNames,
      'rowNames': instance.rowNames,
      'AMat': instance.AMat,
      'bVec': instance.bVec,
      'cVec': instance.cVec,
      'integer': instance.integer,
    };

Item _$ItemFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Item',
      json,
      ($checkedConvert) {
        final val = Item(
          id: $checkedConvert('id', (v) => v as int),
          itemId: $checkedConvert('itemId', (v) => v as int),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          category: $checkedConvert('category', (v) => v as int),
          rarity: $checkedConvert('rarity', (v) => v as int? ?? 0),
          description: $checkedConvert('description', (v) => v as String?),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
        );
        return val;
      },
    );

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

MysticCode _$MysticCodeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'MysticCode',
      json,
      ($checkedConvert) {
        final val = MysticCode(
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          icon1: $checkedConvert('icon1', (v) => v as String),
          icon2: $checkedConvert('icon2', (v) => v as String),
          image1: $checkedConvert('image1', (v) => v as String),
          image2: $checkedConvert('image2', (v) => v as String),
          obtains: $checkedConvert('obtains',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          obtainsEn: $checkedConvert('obtainsEn',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          expPoints: $checkedConvert('expPoints',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          skills: $checkedConvert(
              'skills',
              (v) => (v as List<dynamic>)
                  .map((e) => Skill.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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

NiceSkill _$NiceSkillFromJson(Map<String, dynamic> json) => NiceSkill(
      id: json['id'] as int,
      num: json['num'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String,
      detail: json['detail'] as String,
      type: json['type'] as String,
      strengthStatus: json['strengthStatus'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int,
      condQuestPhase: json['condQuestPhase'] as int,
      conLv: json['conLv'] as int,
      condLimitCount: json['condLimitCount'] as int,
      icon: json['icon'] as String,
      coolDown:
          (json['coolDown'] as List<dynamic>).map((e) => e as int).toList(),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => NiceFunction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NiceSkillToJson(NiceSkill instance) => <String, dynamic>{
      'id': instance.id,
      'num': instance.num,
      'name': instance.name,
      'ruby': instance.ruby,
      'detail': instance.detail,
      'type': instance.type,
      'strengthStatus': instance.strengthStatus,
      'priority': instance.priority,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'conLv': instance.conLv,
      'condLimitCount': instance.condLimitCount,
      'icon': instance.icon,
      'coolDown': instance.coolDown,
      'functions': instance.functions,
    };

NiceNoblePhantasm _$NiceNoblePhantasmFromJson(Map<String, dynamic> json) =>
    NiceNoblePhantasm(
      id: json['id'] as int,
      num: json['num'] as int,
      card: json['card'] as String,
      name: json['name'] as String,
      ruby: json['ruby'] as String,
      rank: json['rank'] as String,
      type: json['type'] as String,
      detail: json['detail'] as String,
      npGain: (json['npGain'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      npDistribution: (json['npDistribution'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      strengthStatus: json['strengthStatus'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int,
      condQuestPhase: json['condQuestPhase'] as int,
      individuality: (json['individuality'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      functions: (json['functions'] as List<dynamic>)
          .map((e) => NiceFunction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NiceNoblePhantasmToJson(NiceNoblePhantasm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'num': instance.num,
      'card': instance.card,
      'name': instance.name,
      'ruby': instance.ruby,
      'rank': instance.rank,
      'type': instance.type,
      'detail': instance.detail,
      'npGain': instance.npGain,
      'npDistribution': instance.npDistribution,
      'strengthStatus': instance.strengthStatus,
      'priority': instance.priority,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
      'individuality': instance.individuality,
      'functions': instance.functions,
    };

NiceFunction _$NiceFunctionFromJson(Map<String, dynamic> json) => NiceFunction(
      funcId: json['funcId'] as int,
      funcType: json['funcType'] as String,
      funcTargetType: json['funcTargetType'] as String,
      funcTargetTeam: json['funcTargetTeam'] as String,
      funcPopupText: json['funcPopupText'] as String,
      buffs: (json['buffs'] as List<dynamic>)
          .map((e) => NiceBuff.fromJson(e as Map<String, dynamic>))
          .toList(),
      svals: (json['svals'] as List<dynamic>)
          .map((e) => NiceEffectVal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NiceFunctionToJson(NiceFunction instance) =>
    <String, dynamic>{
      'funcId': instance.funcId,
      'funcType': instance.funcType,
      'funcTargetType': instance.funcTargetType,
      'funcTargetTeam': instance.funcTargetTeam,
      'funcPopupText': instance.funcPopupText,
      'buffs': instance.buffs,
      'svals': instance.svals,
    };

NiceBuff _$NiceBuffFromJson(Map<String, dynamic> json) => NiceBuff(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      type: json['type'] as String,
      buffGroup: json['buffGroup'] as int,
    );

Map<String, dynamic> _$NiceBuffToJson(NiceBuff instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'detail': instance.detail,
      'type': instance.type,
      'buffGroup': instance.buffGroup,
    };

NiceEffectVal _$NiceEffectValFromJson(Map<String, dynamic> json) =>
    NiceEffectVal(
      rate: json['Rate'] as int?,
      turn: json['Turn'] as int?,
      count: json['Count'] as int?,
      value: json['Value'] as int?,
    );

Map<String, dynamic> _$NiceEffectValToJson(NiceEffectVal instance) =>
    <String, dynamic>{
      'Rate': instance.rate,
      'Turn': instance.turn,
      'Count': instance.count,
      'Value': instance.value,
    };

Quest _$QuestFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Quest',
      json,
      ($checkedConvert) {
        final val = Quest(
          chapter: $checkedConvert('chapter', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          indexKey: $checkedConvert('indexKey', (v) => v as String?),
          level: $checkedConvert('level', (v) => v as int),
          bondPoint: $checkedConvert('bondPoint', (v) => v as int),
          experience: $checkedConvert('experience', (v) => v as int),
          qp: $checkedConvert('qp', (v) => v as int),
          isFree: $checkedConvert('isFree', (v) => v as bool),
          hasChoice: $checkedConvert('hasChoice', (v) => v as bool),
          battles: $checkedConvert(
              'battles',
              (v) => (v as List<dynamic>)
                  .map((e) => Battle.fromJson(e as Map<String, dynamic>))
                  .toList()),
          rewards: $checkedConvert(
              'rewards', (v) => Map<String, int>.from(v as Map)),
          enhancement: $checkedConvert('enhancement', (v) => v as String?),
          conditions: $checkedConvert('conditions', (v) => v as String?),
        );
        return val;
      },
    );

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

Battle _$BattleFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Battle',
      json,
      ($checkedConvert) {
        final val = Battle(
          ap: $checkedConvert('ap', (v) => v as int),
          place: $checkedConvert('place', (v) => v as String?),
          placeJp: $checkedConvert('placeJp', (v) => v as String?),
          placeEn: $checkedConvert('placeEn', (v) => v as String?),
          enemies: $checkedConvert(
              'enemies',
              (v) => (v as List<dynamic>)
                  .map((e) => (e as List<dynamic>)
                      .map((e) => e == null
                          ? null
                          : Enemy.fromJson(e as Map<String, dynamic>))
                      .toList())
                  .toList()),
          drops:
              $checkedConvert('drops', (v) => Map<String, int>.from(v as Map)),
        );
        return val;
      },
    );

Map<String, dynamic> _$BattleToJson(Battle instance) => <String, dynamic>{
      'ap': instance.ap,
      'place': instance.place,
      'placeJp': instance.placeJp,
      'placeEn': instance.placeEn,
      'enemies': instance.enemies,
      'drops': instance.drops,
    };

Enemy _$EnemyFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Enemy',
      json,
      ($checkedConvert) {
        final val = Enemy(
          name: $checkedConvert('name',
              (v) => (v as List<dynamic>).map((e) => e as String?).toList()),
          shownName: $checkedConvert('shownName',
              (v) => (v as List<dynamic>).map((e) => e as String?).toList()),
          className: $checkedConvert('className',
              (v) => (v as List<dynamic>).map((e) => e as String?).toList()),
          rank: $checkedConvert('rank',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          hp: $checkedConvert(
              'hp', (v) => (v as List<dynamic>).map((e) => e as int).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$EnemyToJson(Enemy instance) => <String, dynamic>{
      'name': instance.name,
      'shownName': instance.shownName,
      'className': instance.className,
      'rank': instance.rank,
      'hp': instance.hp,
    };

Servant _$ServantFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Servant',
      json,
      ($checkedConvert) {
        final val = Servant(
          no: $checkedConvert('no', (v) => v as int),
          svtId: $checkedConvert('svtId', (v) => v as int),
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          icon: $checkedConvert('icon', (v) => v as String),
          info: $checkedConvert('info',
              (v) => ServantBaseInfo.fromJson(v as Map<String, dynamic>)),
          noblePhantasm: $checkedConvert(
              'noblePhantasm',
              (v) => (v as List<dynamic>)
                  .map((e) => NoblePhantasm.fromJson(e as Map<String, dynamic>))
                  .toList()),
          noblePhantasmEn: $checkedConvert(
              'noblePhantasmEn',
              (v) => (v as List<dynamic>)
                  .map((e) => NoblePhantasm.fromJson(e as Map<String, dynamic>))
                  .toList()),
          activeSkills: $checkedConvert(
              'activeSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => ActiveSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          activeSkillsEn: $checkedConvert(
              'activeSkillsEn',
              (v) => (v as List<dynamic>)
                  .map((e) => ActiveSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          passiveSkills: $checkedConvert(
              'passiveSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => Skill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          passiveSkillsEn: $checkedConvert(
              'passiveSkillsEn',
              (v) => (v as List<dynamic>)
                  .map((e) => Skill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          appendSkills: $checkedConvert(
              'appendSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => Skill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          niceSkills: $checkedConvert(
              'niceSkills',
              (v) => (v as List<dynamic>)
                  .map((e) => NiceSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          niceClassPassive: $checkedConvert(
              'niceClassPassive',
              (v) => (v as List<dynamic>)
                  .map((e) => NiceSkill.fromJson(e as Map<String, dynamic>))
                  .toList()),
          niceNoblePhantasms: $checkedConvert(
              'niceNoblePhantasms',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      NiceNoblePhantasm.fromJson(e as Map<String, dynamic>))
                  .toList()),
          coinSummonNum: $checkedConvert('coinSummonNum', (v) => v as int),
          itemCost: $checkedConvert(
              'itemCost', (v) => ItemCost.fromJson(v as Map<String, dynamic>)),
          costumeNos: $checkedConvert('costumeNos',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          bondPoints: $checkedConvert('bondPoints',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          profiles: $checkedConvert(
              'profiles',
              (v) => (v as List<dynamic>)
                  .map(
                      (e) => SvtProfileData.fromJson(e as Map<String, dynamic>))
                  .toList()),
          voices: $checkedConvert(
              'voices',
              (v) => (v as List<dynamic>)
                  .map((e) => VoiceTable.fromJson(e as Map<String, dynamic>))
                  .toList()),
          bondCraft: $checkedConvert('bondCraft', (v) => v as int),
          valentineCraft: $checkedConvert('valentineCraft',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          icons: $checkedConvert(
              'icons',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      KeyValueListEntry.fromJson(e as Map<String, dynamic>))
                  .toList()),
          sprites: $checkedConvert(
              'sprites',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      KeyValueListEntry.fromJson(e as Map<String, dynamic>))
                  .toList()),
          atkGrowth: $checkedConvert('atkGrowth',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
          hpGrowth: $checkedConvert('hpGrowth',
              (v) => (v as List<dynamic>).map((e) => e as int).toList()),
        );
        return val;
      },
    );

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
      'niceSkills': instance.niceSkills,
      'niceClassPassive': instance.niceClassPassive,
      'niceNoblePhantasms': instance.niceNoblePhantasms,
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
      'atkGrowth': instance.atkGrowth,
      'hpGrowth': instance.hpGrowth,
    };

ServantBaseInfo _$ServantBaseInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ServantBaseInfo',
      json,
      ($checkedConvert) {
        final val = ServantBaseInfo(
          gameId: $checkedConvert('gameId', (v) => v as int),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          namesOther: $checkedConvert('namesOther',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          namesJpOther: $checkedConvert('namesJpOther',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          namesEnOther: $checkedConvert('namesEnOther',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          nicknames: $checkedConvert('nicknames',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          obtain: $checkedConvert('obtain', (v) => v as String),
          obtains: $checkedConvert('obtains',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          rarity: $checkedConvert('rarity', (v) => v as int),
          rarity2: $checkedConvert('rarity2', (v) => v as int),
          weight: $checkedConvert('weight', (v) => v as String),
          height: $checkedConvert('height', (v) => v as String),
          gender: $checkedConvert('gender', (v) => v as String),
          illustrator: $checkedConvert('illustrator', (v) => v as String),
          illustratorJp: $checkedConvert('illustratorJp', (v) => v as String?),
          illustratorEn: $checkedConvert('illustratorEn', (v) => v as String?),
          className: $checkedConvert('className', (v) => v as String),
          attribute: $checkedConvert('attribute', (v) => v as String),
          isHumanoid: $checkedConvert('isHumanoid', (v) => v as bool),
          isWeakToEA: $checkedConvert('isWeakToEA', (v) => v as bool),
          isTDNS: $checkedConvert('isTDNS', (v) => v as bool),
          cv: $checkedConvert('cv',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          cvJp: $checkedConvert('cvJp',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          cvEn: $checkedConvert('cvEn',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          alignments: $checkedConvert('alignments',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          traits: $checkedConvert('traits',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          ability: $checkedConvert(
              'ability', (v) => Map<String, String>.from(v as Map)),
          illustrations: $checkedConvert(
              'illustrations', (v) => Map<String, String>.from(v as Map)),
          cards: $checkedConvert('cards',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          cardHits: $checkedConvert(
              'cardHits', (v) => Map<String, int>.from(v as Map)),
          cardHitsDamage: $checkedConvert(
              'cardHitsDamage',
              (v) => (v as Map<String, dynamic>).map(
                    (k, e) => MapEntry(
                        k, (e as List<dynamic>).map((e) => e as int).toList()),
                  )),
          npRate: $checkedConvert(
              'npRate', (v) => Map<String, String>.from(v as Map)),
          atkMin: $checkedConvert('atkMin', (v) => v as int),
          hpMin: $checkedConvert('hpMin', (v) => v as int),
          atkMax: $checkedConvert('atkMax', (v) => v as int),
          hpMax: $checkedConvert('hpMax', (v) => v as int),
          atk90: $checkedConvert('atk90', (v) => v as int),
          hp90: $checkedConvert('hp90', (v) => v as int),
          atk100: $checkedConvert('atk100', (v) => v as int),
          hp100: $checkedConvert('hp100', (v) => v as int),
          starRate: $checkedConvert('starRate', (v) => v as String),
          deathRate: $checkedConvert('deathRate', (v) => v as String),
          criticalRate: $checkedConvert('criticalRate', (v) => v as String),
        );
        return val;
      },
    );

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

NoblePhantasm _$NoblePhantasmFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'NoblePhantasm',
      json,
      ($checkedConvert) {
        final val = NoblePhantasm(
          state: $checkedConvert('state', (v) => v as String?),
          openCondition: $checkedConvert('openCondition', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          upperName: $checkedConvert('upperName', (v) => v as String),
          upperNameJp: $checkedConvert('upperNameJp', (v) => v as String?),
          color: $checkedConvert('color', (v) => v as String?),
          category: $checkedConvert('category', (v) => v as String),
          rank: $checkedConvert('rank', (v) => v as String?),
          typeText: $checkedConvert('typeText', (v) => v as String?),
          effects: $checkedConvert(
              'effects',
              (v) => (v as List<dynamic>)
                  .map((e) => Effect.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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

ActiveSkill _$ActiveSkillFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ActiveSkill',
      json,
      ($checkedConvert) {
        final val = ActiveSkill(
          cnState: $checkedConvert('cnState', (v) => v as int),
          skills: $checkedConvert(
              'skills',
              (v) => (v as List<dynamic>)
                  .map((e) => Skill.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ActiveSkillToJson(ActiveSkill instance) =>
    <String, dynamic>{
      'cnState': instance.cnState,
      'skills': instance.skills,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Skill',
      json,
      ($checkedConvert) {
        final val = Skill(
          state: $checkedConvert('state', (v) => v as String),
          openCondition: $checkedConvert('openCondition', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          rank: $checkedConvert('rank', (v) => v as String?),
          icon: $checkedConvert('icon', (v) => v as String),
          cd: $checkedConvert('cd', (v) => v as int),
          effects: $checkedConvert(
              'effects',
              (v) => (v as List<dynamic>)
                  .map((e) => Effect.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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

Effect _$EffectFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Effect',
      json,
      ($checkedConvert) {
        final val = Effect(
          description: $checkedConvert('description', (v) => v as String),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          lvData: $checkedConvert('lvData',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$EffectToJson(Effect instance) => <String, dynamic>{
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'lvData': instance.lvData,
    };

SvtProfileData _$SvtProfileDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SvtProfileData',
      json,
      ($checkedConvert) {
        final val = SvtProfileData(
          title: $checkedConvert('title', (v) => v as String?),
          description: $checkedConvert('description', (v) => v as String?),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
          descriptionEn: $checkedConvert('descriptionEn', (v) => v as String?),
          condition: $checkedConvert('condition', (v) => v as String?),
          conditionEn: $checkedConvert('conditionEn', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtProfileDataToJson(SvtProfileData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'descriptionJp': instance.descriptionJp,
      'descriptionEn': instance.descriptionEn,
      'condition': instance.condition,
      'conditionEn': instance.conditionEn,
    };

VoiceTable _$VoiceTableFromJson(Map<String, dynamic> json) => $checkedCreate(
      'VoiceTable',
      json,
      ($checkedConvert) {
        final val = VoiceTable(
          section: $checkedConvert('section', (v) => v as String),
          table: $checkedConvert(
              'table',
              (v) => (v as List<dynamic>)
                  .map((e) => VoiceRecord.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$VoiceTableToJson(VoiceTable instance) =>
    <String, dynamic>{
      'section': instance.section,
      'table': instance.table,
    };

VoiceRecord _$VoiceRecordFromJson(Map<String, dynamic> json) => $checkedCreate(
      'VoiceRecord',
      json,
      ($checkedConvert) {
        final val = VoiceRecord(
          title: $checkedConvert('title', (v) => v as String),
          text: $checkedConvert('text', (v) => v as String?),
          textJp: $checkedConvert('textJp', (v) => v as String?),
          textEn: $checkedConvert('textEn', (v) => v as String?),
          condition: $checkedConvert('condition', (v) => v as String?),
          voiceFile: $checkedConvert('voiceFile', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$VoiceRecordToJson(VoiceRecord instance) =>
    <String, dynamic>{
      'title': instance.title,
      'text': instance.text,
      'textJp': instance.textJp,
      'textEn': instance.textEn,
      'condition': instance.condition,
      'voiceFile': instance.voiceFile,
    };

Costume _$CostumeFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Costume',
      json,
      ($checkedConvert) {
        final val = Costume(
          no: $checkedConvert('no', (v) => v as int),
          gameId: $checkedConvert('gameId', (v) => v as int),
          svtNo: $checkedConvert('svtNo', (v) => v as int),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String),
          nameEn: $checkedConvert('nameEn', (v) => v as String),
          icon: $checkedConvert('icon', (v) => v as String),
          avatar: $checkedConvert('avatar', (v) => v as String),
          models: $checkedConvert('models',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          illustration: $checkedConvert('illustration', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          descriptionJp: $checkedConvert('descriptionJp', (v) => v as String?),
          itemCost: $checkedConvert(
              'itemCost', (v) => Map<String, int>.from(v as Map)),
          obtain: $checkedConvert('obtain', (v) => v as String?),
          obtainEn: $checkedConvert('obtainEn', (v) => v as String?),
        );
        return val;
      },
    );

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

Summon _$SummonFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Summon',
      json,
      ($checkedConvert) {
        final val = Summon(
          mcLink: $checkedConvert('mcLink', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          nameJp: $checkedConvert('nameJp', (v) => v as String?),
          nameEn: $checkedConvert('nameEn', (v) => v as String?),
          startTimeJp: $checkedConvert('startTimeJp', (v) => v as String?),
          endTimeJp: $checkedConvert('endTimeJp', (v) => v as String?),
          startTimeCn: $checkedConvert('startTimeCn', (v) => v as String?),
          endTimeCn: $checkedConvert('endTimeCn', (v) => v as String?),
          bannerUrl: $checkedConvert('bannerUrl', (v) => v as String?),
          bannerUrlJp: $checkedConvert('bannerUrlJp', (v) => v as String?),
          associatedEvents: $checkedConvert('associatedEvents',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          associatedSummons: $checkedConvert('associatedSummons',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          category: $checkedConvert('category', (v) => v as int),
          classPickUp: $checkedConvert('classPickUp', (v) => v as bool),
          roll11: $checkedConvert('roll11', (v) => v as bool),
          dataList: $checkedConvert(
              'dataList',
              (v) => (v as List<dynamic>)
                  .map((e) => SummonData.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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

SummonData _$SummonDataFromJson(Map<String, dynamic> json) => $checkedCreate(
      'SummonData',
      json,
      ($checkedConvert) {
        final val = SummonData(
          name: $checkedConvert('name', (v) => v as String),
          svts: $checkedConvert(
              'svts',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      SummonDataBlock.fromJson(e as Map<String, dynamic>))
                  .toList()),
          crafts: $checkedConvert(
              'crafts',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      SummonDataBlock.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SummonDataToJson(SummonData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'svts': instance.svts,
      'crafts': instance.crafts,
    };

SummonDataBlock _$SummonDataBlockFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SummonDataBlock',
      json,
      ($checkedConvert) {
        final val = SummonDataBlock(
          isSvt: $checkedConvert('isSvt', (v) => v as bool),
          rarity: $checkedConvert('rarity', (v) => v as int),
          weight: $checkedConvert('weight', (v) => (v as num).toDouble()),
          display: $checkedConvert('display', (v) => v as bool),
          ids: $checkedConvert(
              'ids', (v) => (v as List<dynamic>).map((e) => e as int).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SummonDataBlockToJson(SummonDataBlock instance) =>
    <String, dynamic>{
      'isSvt': instance.isSvt,
      'rarity': instance.rarity,
      'weight': instance.weight,
      'display': instance.display,
      'ids': instance.ids,
    };

SvtFilterData _$SvtFilterDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SvtFilterData',
      json,
      ($checkedConvert) {
        final val = SvtFilterData(
          favorite: $checkedConvert('favorite', (v) => v as int?),
          planFavorite: $checkedConvert('planFavorite', (v) => v as int?),
          display: $checkedConvert(
              'display',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => _$enumDecode(_$SvtCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
          hasDress: $checkedConvert('hasDress', (v) => v as bool?),
          svtDuplicated: $checkedConvert(
              'svtDuplicated',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          planCompletion: $checkedConvert(
              'planCompletion',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          skillLevel: $checkedConvert(
              'skillLevel',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          priority: $checkedConvert(
              'priority',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          rarity: $checkedConvert(
              'rarity',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          className: $checkedConvert(
              'className',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          obtain: $checkedConvert(
              'obtain',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          npColor: $checkedConvert(
              'npColor',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          npType: $checkedConvert(
              'npType',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          attribute: $checkedConvert(
              'attribute',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          alignment1: $checkedConvert(
              'alignment1',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          alignment2: $checkedConvert(
              'alignment2',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          gender: $checkedConvert(
              'gender',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          trait: $checkedConvert(
              'trait',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          special: $checkedConvert(
              'special',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          effectScope: $checkedConvert(
              'effectScope',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          effects: $checkedConvert(
              'effects',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtFilterDataToJson(SvtFilterData instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'planFavorite': instance.planFavorite,
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
      'effectScope': instance.effectScope,
      'effects': instance.effects,
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

CraftFilterData _$CraftFilterDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CraftFilterData',
      json,
      ($checkedConvert) {
        final val = CraftFilterData(
          display: $checkedConvert(
              'display',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => _$enumDecode(_$CraftCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
          rarity: $checkedConvert(
              'rarity',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          category: $checkedConvert(
              'category',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          atkHpType: $checkedConvert(
              'atkHpType',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          status: $checkedConvert(
              'status',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          effects: $checkedConvert(
              'effects',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

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
      'effects': instance.effects,
    };

const _$CraftCompareEnumMap = {
  CraftCompare.no: 'no',
  CraftCompare.rarity: 'rarity',
  CraftCompare.atk: 'atk',
  CraftCompare.hp: 'hp',
};

CmdCodeFilterData _$CmdCodeFilterDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CmdCodeFilterData',
      json,
      ($checkedConvert) {
        final val = CmdCodeFilterData(
          display: $checkedConvert(
              'display',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => _$enumDecode(_$CmdCodeCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
          rarity: $checkedConvert(
              'rarity',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          category: $checkedConvert(
              'category',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
          effects: $checkedConvert(
              'effects',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$CmdCodeFilterDataToJson(CmdCodeFilterData instance) =>
    <String, dynamic>{
      'display': instance.display,
      'sortKeys':
          instance.sortKeys.map((e) => _$CmdCodeCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
      'rarity': instance.rarity,
      'category': instance.category,
      'effects': instance.effects,
    };

const _$CmdCodeCompareEnumMap = {
  CmdCodeCompare.no: 'no',
  CmdCodeCompare.rarity: 'rarity',
};

SummonFilterData _$SummonFilterDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SummonFilterData',
      json,
      ($checkedConvert) {
        final val = SummonFilterData(
          favorite: $checkedConvert('favorite', (v) => v as bool?),
          reversed: $checkedConvert('reversed', (v) => v as bool?),
          showBanner: $checkedConvert('showBanner', (v) => v as bool?),
          showOutdated: $checkedConvert('showOutdated', (v) => v as bool?),
          category: $checkedConvert(
              'category',
              (v) => v == null
                  ? null
                  : FilterGroupData.fromJson(v as Map<String, dynamic>)),
        );
        return val;
      },
    );

Map<String, dynamic> _$SummonFilterDataToJson(SummonFilterData instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'reversed': instance.reversed,
      'showBanner': instance.showBanner,
      'showOutdated': instance.showOutdated,
      'category': instance.category,
    };

FilterGroupData _$FilterGroupDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'FilterGroupData',
      json,
      ($checkedConvert) {
        final val = FilterGroupData(
          matchAll: $checkedConvert('matchAll', (v) => v as bool?),
          invert: $checkedConvert('invert', (v) => v as bool?),
          options: $checkedConvert(
              'options',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as bool),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$FilterGroupDataToJson(FilterGroupData instance) =>
    <String, dynamic>{
      'matchAll': instance.matchAll,
      'invert': instance.invert,
      'options': instance.options,
    };

SaintQuartzPlan _$SaintQuartzPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SaintQuartzPlan',
      json,
      ($checkedConvert) {
        final val = SaintQuartzPlan(
          curSQ: $checkedConvert('curSQ', (v) => v as int?),
          curTicket: $checkedConvert('curTicket', (v) => v as int?),
          curApple: $checkedConvert('curApple', (v) => v as int?),
          startDate: $checkedConvert('startDate',
              (v) => v == null ? null : DateTime.parse(v as String)),
          endDate: $checkedConvert(
              'endDate', (v) => v == null ? null : DateTime.parse(v as String)),
          accLogin: $checkedConvert('accLogin', (v) => v as int?),
          continuousLogin: $checkedConvert('continuousLogin', (v) => v as int?),
          eventDateDelta: $checkedConvert('eventDateDelta', (v) => v as int?),
          weeklyMission: $checkedConvert('weeklyMission', (v) => v as bool?),
          minusPlannedBanner:
              $checkedConvert('minusPlannedBanner', (v) => v as bool?),
        );
        $checkedConvert(
            'extraMissions',
            (v) => val.extraMissions = (v as Map<String, dynamic>).map(
                  (k, e) => MapEntry(int.parse(k), e as bool),
                ));
        return val;
      },
    );

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

User _$UserFromJson(Map<String, dynamic> json) => $checkedCreate(
      'User',
      json,
      ($checkedConvert) {
        final val = User(
          key: $checkedConvert('key', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          server: $checkedConvert(
              'server', (v) => _$enumDecodeNullable(_$GameServerEnumMap, v)),
          servants: $checkedConvert(
              'servants',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k),
                        ServantStatus.fromJson(e as Map<String, dynamic>)),
                  )),
          curSvtPlanNo: $checkedConvert('curSvtPlanNo', (v) => v as int?),
          servantPlans: $checkedConvert(
              'servantPlans',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => (e as Map<String, dynamic>).map(
                        (k, e) => MapEntry(int.parse(k),
                            ServantPlan.fromJson(e as Map<String, dynamic>)),
                      ))
                  .toList()),
          items: $checkedConvert(
              'items',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as int),
                  )),
          events: $checkedConvert(
              'events',
              (v) => v == null
                  ? null
                  : EventPlans.fromJson(v as Map<String, dynamic>)),
          crafts: $checkedConvert(
              'crafts',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k), e as int),
                  )),
          mysticCodes: $checkedConvert(
              'mysticCodes',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as int),
                  )),
          plannedSummons: $checkedConvert('plannedSummons',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          saintQuartzPlan: $checkedConvert(
              'saintQuartzPlan',
              (v) => v == null
                  ? null
                  : SaintQuartzPlan.fromJson(v as Map<String, dynamic>)),
          isMasterGirl: $checkedConvert('isMasterGirl', (v) => v as bool?),
          use6thDropRate: $checkedConvert('use6thDropRate', (v) => v as bool?),
          msProgress: $checkedConvert('msProgress', (v) => v as int?),
          duplicatedServants: $checkedConvert(
              'duplicatedServants',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(int.parse(k), e as int),
                  )),
          glpkParams: $checkedConvert(
              'glpkParams',
              (v) => v == null
                  ? null
                  : GLPKParams.fromJson(v as Map<String, dynamic>)),
          luckyBagSvtScores: $checkedConvert(
              'luckyBagSvtScores',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k,
                        (e as Map<String, dynamic>).map(
                          (k, e) => MapEntry(int.parse(k), e as int),
                        )),
                  )),
          supportSetups: $checkedConvert(
              'supportSetups',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => SupportSetup.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

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
      'use6thDropRate': instance.use6thDropRate,
      'msProgress': instance.msProgress,
      'duplicatedServants':
          instance.duplicatedServants.map((k, e) => MapEntry(k.toString(), e)),
      'glpkParams': instance.glpkParams,
      'luckyBagSvtScores': instance.luckyBagSvtScores.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'supportSetups': instance.supportSetups,
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

ServantStatus _$ServantStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ServantStatus',
      json,
      ($checkedConvert) {
        final val = ServantStatus(
          favorite: $checkedConvert('favorite', (v) => v as bool?),
          curVal: $checkedConvert(
              'curVal',
              (v) => v == null
                  ? null
                  : ServantPlan.fromJson(v as Map<String, dynamic>)),
          coin: $checkedConvert('coin', (v) => v as int?),
          npLv: $checkedConvert('npLv', (v) => v as int?),
          priority: $checkedConvert('priority', (v) => v as int?),
          equipCmdCodes: $checkedConvert('equipCmdCodes',
              (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
          skillIndex: $checkedConvert('skillIndex',
              (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
          npIndex: $checkedConvert('npIndex', (v) => v as int?),
        );
        return val;
      },
    );

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

ServantPlan _$ServantPlanFromJson(Map<String, dynamic> json) => $checkedCreate(
      'ServantPlan',
      json,
      ($checkedConvert) {
        final val = ServantPlan(
          favorite: $checkedConvert('favorite', (v) => v as bool?),
          ascension: $checkedConvert('ascension', (v) => v as int?),
          skills: $checkedConvert('skills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          dress: $checkedConvert('dress',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          appendSkills: $checkedConvert('appendSkills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          grail: $checkedConvert('grail', (v) => v as int?),
          fouHp: $checkedConvert('fouHp', (v) => v as int?),
          fouAtk: $checkedConvert('fouAtk', (v) => v as int?),
          bondLimit: $checkedConvert('bondLimit', (v) => v as int?),
        );
        return val;
      },
    );

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

EventPlans _$EventPlansFromJson(Map<String, dynamic> json) => $checkedCreate(
      'EventPlans',
      json,
      ($checkedConvert) {
        final val = EventPlans(
          limitEvents: $checkedConvert(
              'limitEvents',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k, LimitEventPlan.fromJson(e as Map<String, dynamic>)),
                  )),
          mainRecords: $checkedConvert(
              'mainRecords',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k, MainRecordPlan.fromJson(e as Map<String, dynamic>)),
                  )),
          exchangeTickets: $checkedConvert(
              'exchangeTickets',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k,
                        ExchangeTicketPlan.fromJson(e as Map<String, dynamic>)),
                  )),
          campaigns: $checkedConvert(
              'campaigns',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(
                        k, CampaignPlan.fromJson(e as Map<String, dynamic>)),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$EventPlansToJson(EventPlans instance) =>
    <String, dynamic>{
      'limitEvents': instance.limitEvents,
      'mainRecords': instance.mainRecords,
      'exchangeTickets': instance.exchangeTickets,
      'campaigns': instance.campaigns,
    };

LimitEventPlan _$LimitEventPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LimitEventPlan',
      json,
      ($checkedConvert) {
        final val = LimitEventPlan(
          enabled: $checkedConvert('enabled', (v) => v as bool?),
          rerun: $checkedConvert('rerun', (v) => v as bool?),
          lottery: $checkedConvert('lottery', (v) => v as int?),
          extra: $checkedConvert(
              'extra',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as int),
                  )),
          extra2: $checkedConvert(
              'extra2',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as int),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'rerun': instance.rerun,
      'lottery': instance.lottery,
      'extra': instance.extra,
      'extra2': instance.extra2,
    };

MainRecordPlan _$MainRecordPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MainRecordPlan',
      json,
      ($checkedConvert) {
        final val = MainRecordPlan(
          drop: $checkedConvert('drop', (v) => v as bool?),
          reward: $checkedConvert('reward', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$MainRecordPlanToJson(MainRecordPlan instance) =>
    <String, dynamic>{
      'drop': instance.drop,
      'reward': instance.reward,
    };

ExchangeTicketPlan _$ExchangeTicketPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ExchangeTicketPlan',
      json,
      ($checkedConvert) {
        final val = ExchangeTicketPlan(
          item1: $checkedConvert('item1', (v) => v as int?),
          item2: $checkedConvert('item2', (v) => v as int?),
          item3: $checkedConvert('item3', (v) => v as int?),
        );
        return val;
      },
    );

Map<String, dynamic> _$ExchangeTicketPlanToJson(ExchangeTicketPlan instance) =>
    <String, dynamic>{
      'item1': instance.item1,
      'item2': instance.item2,
      'item3': instance.item3,
    };

CampaignPlan _$CampaignPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CampaignPlan',
      json,
      ($checkedConvert) {
        final val = CampaignPlan(
          enabled: $checkedConvert('enabled', (v) => v as bool?),
          rerun: $checkedConvert('rerun', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CampaignPlanToJson(CampaignPlan instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'rerun': instance.rerun,
    };

SupportSetup _$SupportSetupFromJson(Map<String, dynamic> json) => SupportSetup(
      index: json['index'] as int? ?? 0,
      svtNo: json['svtNo'] as int?,
      lv: json['lv'] as int?,
      imgPath: json['imgPath'] as String?,
      cached: json['cached'] as bool? ?? true,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
      dx: (json['dx'] as num?)?.toDouble() ?? 0,
      dy: (json['dy'] as num?)?.toDouble() ?? 0,
      showActiveSkill: json['showActiveSkill'] as bool? ?? true,
      showAppendSkill: json['showAppendSkill'] as bool? ?? false,
    );

Map<String, dynamic> _$SupportSetupToJson(SupportSetup instance) =>
    <String, dynamic>{
      'index': instance.index,
      'svtNo': instance.svtNo,
      'lv': instance.lv,
      'imgPath': instance.imgPath,
      'cached': instance.cached,
      'scale': instance.scale,
      'dx': instance.dx,
      'dy': instance.dy,
      'showActiveSkill': instance.showActiveSkill,
      'showAppendSkill': instance.showAppendSkill,
    };

AppSetting _$AppSettingFromJson(Map<String, dynamic> json) => $checkedCreate(
      'AppSetting',
      json,
      ($checkedConvert) {
        final val = AppSetting(
          language: $checkedConvert('language', (v) => v as String?),
          themeMode: $checkedConvert(
              'themeMode',
              (v) => _$enumDecodeNullable(_$ThemeModeEnumMap, v,
                  unknownValue: ThemeMode.system)),
          favoritePreferred:
              $checkedConvert('favoritePreferred', (v) => v as bool?),
          autoResetFilter:
              $checkedConvert('autoResetFilter', (v) => v as bool?),
          downloadSource: $checkedConvert('downloadSource', (v) => v as int?),
          autoUpdateApp: $checkedConvert('autoUpdateApp', (v) => v as bool?),
          autoUpdateDataset:
              $checkedConvert('autoUpdateDataset', (v) => v as bool?),
          autorotate: $checkedConvert('autorotate', (v) => v as bool?),
          classFilterStyle: $checkedConvert(
              'classFilterStyle',
              (v) => _$enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v,
                  unknownValue: SvtListClassFilterStyle.auto)),
          onlyAppendSkillTwo:
              $checkedConvert('onlyAppendSkillTwo', (v) => v as bool?),
          svtPlanSliderMode:
              $checkedConvert('svtPlanSliderMode', (v) => v as bool?),
          sortedSvtTabs: $checkedConvert(
              'sortedSvtTabs',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => _$enumDecodeNullable(_$SvtTabEnumMap, e,
                      unknownValue: SvtTab.plan))
                  .toList()),
          priorityTags: $checkedConvert(
              'priorityTags',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as String),
                  )),
          showAccountAtHome:
              $checkedConvert('showAccountAtHome', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$AppSettingToJson(AppSetting instance) =>
    <String, dynamic>{
      'language': instance.language,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'favoritePreferred': instance.favoritePreferred,
      'autoResetFilter': instance.autoResetFilter,
      'classFilterStyle':
          _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle],
      'onlyAppendSkillTwo': instance.onlyAppendSkillTwo,
      'autoUpdateApp': instance.autoUpdateApp,
      'autoUpdateDataset': instance.autoUpdateDataset,
      'autorotate': instance.autorotate,
      'downloadSource': instance.downloadSource,
      'svtPlanSliderMode': instance.svtPlanSliderMode,
      'sortedSvtTabs':
          instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]).toList(),
      'priorityTags': instance.priorityTags,
      'showAccountAtHome': instance.showAccountAtHome,
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

CarouselSetting _$CarouselSettingFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CarouselSetting',
      json,
      ($checkedConvert) {
        final val = CarouselSetting(
          updateTime: $checkedConvert('updateTime', (v) => v as int?),
          urls: $checkedConvert(
              'urls',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as String),
                  )),
          enabled: $checkedConvert('enabled', (v) => v as bool?),
          enableMooncell: $checkedConvert('enableMooncell', (v) => v as bool?),
          enableJp: $checkedConvert('enableJp', (v) => v as bool?),
          enableUs: $checkedConvert('enableUs', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) =>
    <String, dynamic>{
      'updateTime': instance.updateTime,
      'urls': instance.urls,
      'enabled': instance.enabled,
      'enableMooncell': instance.enableMooncell,
      'enableJp': instance.enableJp,
      'enableUs': instance.enableUs,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => $checkedCreate(
      'UserData',
      json,
      ($checkedConvert) {
        final val = UserData(
          version: $checkedConvert('version', (v) => v as int?),
          appSetting: $checkedConvert(
              'appSetting',
              (v) => v == null
                  ? null
                  : AppSetting.fromJson(v as Map<String, dynamic>)),
          carouselSetting: $checkedConvert(
              'carouselSetting',
              (v) => v == null
                  ? null
                  : CarouselSetting.fromJson(v as Map<String, dynamic>)),
          galleries: $checkedConvert(
              'galleries',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) => MapEntry(k, e as bool),
                  )),
          curUserKey: $checkedConvert('curUserKey', (v) => v as String?),
          users: $checkedConvert(
              'users',
              (v) => (v as Map<String, dynamic>?)?.map(
                    (k, e) =>
                        MapEntry(k, User.fromJson(e as Map<String, dynamic>)),
                  )),
          svtFilter: $checkedConvert(
              'svtFilter',
              (v) => v == null
                  ? null
                  : SvtFilterData.fromJson(v as Map<String, dynamic>)),
          craftFilter: $checkedConvert(
              'craftFilter',
              (v) => v == null
                  ? null
                  : CraftFilterData.fromJson(v as Map<String, dynamic>)),
          cmdCodeFilter: $checkedConvert(
              'cmdCodeFilter',
              (v) => v == null
                  ? null
                  : CmdCodeFilterData.fromJson(v as Map<String, dynamic>)),
          summonFilter: $checkedConvert(
              'summonFilter',
              (v) => v == null
                  ? null
                  : SummonFilterData.fromJson(v as Map<String, dynamic>)),
          itemAbundantValue: $checkedConvert('itemAbundantValue',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
        );
        return val;
      },
    );

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
