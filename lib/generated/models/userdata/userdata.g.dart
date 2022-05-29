// GENERATED CODE - DO NOT MODIFY BY HAND

part of userdata;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map json) => $checkedCreate(
      'UserData',
      json,
      ($checkedConvert) {
        final val = UserData(
          version: $checkedConvert('version', (v) => v as int?),
          curUserKey: $checkedConvert('curUserKey', (v) => v as int? ?? 0),
          users: $checkedConvert(
              'users',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          itemAbundantValue: $checkedConvert('itemAbundantValue',
              (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
          svtAscensionIcon:
              $checkedConvert('svtAscensionIcon', (v) => v as int? ?? 1),
          customSvtIcon: $checkedConvert(
              'customSvtIcon',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as String?),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'version': instance.version,
      'curUserKey': instance.curUserKey,
      'users': instance.users.map((e) => e.toJson()).toList(),
      'itemAbundantValue': instance.itemAbundantValue,
      'svtAscensionIcon': instance.svtAscensionIcon,
      'customSvtIcon':
          instance.customSvtIcon.map((k, e) => MapEntry(k.toString(), e)),
    };

User _$UserFromJson(Map json) => $checkedCreate(
      'User',
      json,
      ($checkedConvert) {
        final val = User(
          name: $checkedConvert('name', (v) => v as String? ?? 'Gudako'),
          isGirl: $checkedConvert('isGirl', (v) => v as bool? ?? true),
          use6thDrops:
              $checkedConvert('use6thDrops', (v) => v as bool? ?? true),
          region: $checkedConvert('region',
              (v) => $enumDecodeNullable(_$RegionEnumMap, v) ?? Region.jp),
          servants: $checkedConvert(
              'servants',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        SvtStatus.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          plans: $checkedConvert(
              'plans',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      UserPlan.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          sameEventPlan:
              $checkedConvert('sameEventPlan', (v) => v as bool? ?? true),
          curSvtPlanNo: $checkedConvert('curSvtPlanNo', (v) => v as int? ?? 0),
          items: $checkedConvert(
              'items',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
          craftEssences: $checkedConvert(
              'craftEssences',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int?),
                  )),
          mysticCodes: $checkedConvert(
              'mysticCodes',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
          summons: $checkedConvert('summons',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          use6thDropRate:
              $checkedConvert('use6thDropRate', (v) => v as bool? ?? true),
          freeLPParams: $checkedConvert(
              'freeLPParams',
              (v) => v == null
                  ? null
                  : FreeLPParams.fromJson(Map<String, dynamic>.from(v as Map))),
          luckyBagSvtScores: $checkedConvert(
              'luckyBagSvtScores',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        k as String,
                        (e as Map).map(
                          (k, e) => MapEntry(int.parse(k as String), e as int),
                        )),
                  )),
          saintQuartzPlan: $checkedConvert(
              'saintQuartzPlan',
              (v) => v == null
                  ? null
                  : SaintQuartzPlan.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'isGirl': instance.isGirl,
      'use6thDrops': instance.use6thDrops,
      'region': _$RegionEnumMap[instance.region],
      'servants':
          instance.servants.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'plans': instance.plans.map((e) => e.toJson()).toList(),
      'sameEventPlan': instance.sameEventPlan,
      'curSvtPlanNo': instance.curSvtPlanNo,
      'items': instance.items.map((k, e) => MapEntry(k.toString(), e)),
      'craftEssences':
          instance.craftEssences.map((k, e) => MapEntry(k.toString(), e)),
      'mysticCodes':
          instance.mysticCodes.map((k, e) => MapEntry(k.toString(), e)),
      'summons': instance.summons.toList(),
      'use6thDropRate': instance.use6thDropRate,
      'freeLPParams': instance.freeLPParams.toJson(),
      'luckyBagSvtScores': instance.luckyBagSvtScores.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'saintQuartzPlan': instance.saintQuartzPlan.toJson(),
    };

const _$RegionEnumMap = {
  Region.jp: 'jp',
  Region.cn: 'cn',
  Region.tw: 'tw',
  Region.na: 'na',
  Region.kr: 'kr',
};

SvtStatus _$SvtStatusFromJson(Map json) => $checkedCreate(
      'SvtStatus',
      json,
      ($checkedConvert) {
        final val = SvtStatus(
          cur: $checkedConvert(
              'cur',
              (v) => v == null
                  ? null
                  : SvtPlan.fromJson(Map<String, dynamic>.from(v as Map))),
          coin: $checkedConvert('coin', (v) => v as int? ?? 0),
          priority: $checkedConvert('priority', (v) => v as int? ?? 1),
          bond: $checkedConvert('bond', (v) => v as int? ?? 0),
          equipCmdCodes: $checkedConvert('equipCmdCodes',
              (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtStatusToJson(SvtStatus instance) => <String, dynamic>{
      'cur': instance.cur.toJson(),
      'coin': instance.coin,
      'priority': instance.priority,
      'bond': instance.bond,
      'equipCmdCodes': instance.equipCmdCodes,
    };

UserPlan _$UserPlanFromJson(Map json) => $checkedCreate(
      'UserPlan',
      json,
      ($checkedConvert) {
        final val = UserPlan(
          title: $checkedConvert('title', (v) => v as String? ?? ''),
          servants: $checkedConvert(
              'servants',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String),
                        SvtPlan.fromJson(Map<String, dynamic>.from(e as Map))),
                  )),
          limitEvents: $checkedConvert(
              'limitEvents',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        LimitEventPlan.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          mainStories: $checkedConvert(
              'mainStories',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        MainStoryPlan.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          tickets: $checkedConvert(
              'tickets',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        ExchangeTicketPlan.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserPlanToJson(UserPlan instance) => <String, dynamic>{
      'title': instance.title,
      'servants':
          instance.servants.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'limitEvents': instance.limitEvents
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'mainStories': instance.mainStories
          .map((k, e) => MapEntry(k.toString(), e.toJson())),
      'tickets':
          instance.tickets.map((k, e) => MapEntry(k.toString(), e.toJson())),
    };

SvtPlan _$SvtPlanFromJson(Map json) => $checkedCreate(
      'SvtPlan',
      json,
      ($checkedConvert) {
        final val = SvtPlan(
          favorite: $checkedConvert('favorite', (v) => v as bool? ?? false),
          ascension: $checkedConvert('ascension', (v) => v as int? ?? 0),
          skills: $checkedConvert('skills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          appendSkills: $checkedConvert('appendSkills',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          costumes: $checkedConvert(
              'costumes',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
          grail: $checkedConvert('grail', (v) => v as int? ?? 0),
          fouHp: $checkedConvert('fouHp', (v) => v as int? ?? 0),
          fouAtk: $checkedConvert('fouAtk', (v) => v as int? ?? 0),
          bondLimit: $checkedConvert('bondLimit', (v) => v as int? ?? 10),
          npLv: $checkedConvert('npLv', (v) => v as int?),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtPlanToJson(SvtPlan instance) => <String, dynamic>{
      'favorite': instance.favorite,
      'ascension': instance.ascension,
      'skills': instance.skills,
      'appendSkills': instance.appendSkills,
      'costumes': instance.costumes.map((k, e) => MapEntry(k.toString(), e)),
      'grail': instance.grail,
      'fouHp': instance.fouHp,
      'fouAtk': instance.fouAtk,
      'bondLimit': instance.bondLimit,
      'npLv': instance.npLv,
    };

LimitEventPlan _$LimitEventPlanFromJson(Map json) => $checkedCreate(
      'LimitEventPlan',
      json,
      ($checkedConvert) {
        final val = LimitEventPlan(
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? false),
          rerunGrails: $checkedConvert('rerunGrails', (v) => v as int? ?? 0),
          shop: $checkedConvert('shop', (v) => v as bool? ?? true),
          shopExcludeItem: $checkedConvert('shopExcludeItem',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toSet()),
          point: $checkedConvert('point', (v) => v as bool? ?? true),
          mission: $checkedConvert('mission', (v) => v as bool? ?? true),
          tower: $checkedConvert('tower', (v) => v as bool? ?? true),
          lotteries: $checkedConvert(
              'lotteries',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as int),
                  )),
          treasureBoxItems: $checkedConvert(
              'treasureBoxItems',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        (e as Map).map(
                          (k, e) => MapEntry(int.parse(k as String), e as int),
                        )),
                  )),
          fixedDrop: $checkedConvert('fixedDrop', (v) => v as bool? ?? true),
          questReward:
              $checkedConvert('questReward', (v) => v as bool? ?? true),
          extraFixedItems: $checkedConvert(
              'extraFixedItems',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as bool),
                  )),
          extraItems: $checkedConvert(
              'extraItems',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String),
                        (e as Map).map(
                          (k, e) => MapEntry(int.parse(k as String), e as int),
                        )),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'rerunGrails': instance.rerunGrails,
      'shop': instance.shop,
      'shopExcludeItem': instance.shopExcludeItem.toList(),
      'point': instance.point,
      'mission': instance.mission,
      'tower': instance.tower,
      'lotteries': instance.lotteries.map((k, e) => MapEntry(k.toString(), e)),
      'treasureBoxItems': instance.treasureBoxItems.map((k, e) =>
          MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
      'fixedDrop': instance.fixedDrop,
      'questReward': instance.questReward,
      'extraFixedItems':
          instance.extraFixedItems.map((k, e) => MapEntry(k.toString(), e)),
      'extraItems': instance.extraItems.map((k, e) =>
          MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
    };

MainStoryPlan _$MainStoryPlanFromJson(Map json) => $checkedCreate(
      'MainStoryPlan',
      json,
      ($checkedConvert) {
        final val = MainStoryPlan(
          fixedDrop: $checkedConvert('fixedDrop', (v) => v as bool? ?? false),
          questReward:
              $checkedConvert('questReward', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$MainStoryPlanToJson(MainStoryPlan instance) =>
    <String, dynamic>{
      'fixedDrop': instance.fixedDrop,
      'questReward': instance.questReward,
    };

ExchangeTicketPlan _$ExchangeTicketPlanFromJson(Map json) => $checkedCreate(
      'ExchangeTicketPlan',
      json,
      ($checkedConvert) {
        final val = ExchangeTicketPlan(
          counts: $checkedConvert('counts',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ExchangeTicketPlanToJson(ExchangeTicketPlan instance) =>
    <String, dynamic>{
      'counts': instance.counts,
    };

SaintQuartzPlan _$SaintQuartzPlanFromJson(Map json) => $checkedCreate(
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
            (v) => val.extraMissions = (v as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), e as bool),
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
