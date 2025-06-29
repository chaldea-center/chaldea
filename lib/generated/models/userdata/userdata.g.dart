// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/userdata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map json) => $checkedCreate('UserData', json, ($checkedConvert) {
  final val = UserData(
    version: $checkedConvert('version', (v) => (v as num?)?.toInt()),
    appVer: $checkedConvert('appVer', (v) => v as String?),
    curUserKey: $checkedConvert('curUserKey', (v) => (v as num?)?.toInt() ?? 0),
    users: $checkedConvert(
      'users',
      (v) => (v as List<dynamic>?)?.map((e) => User.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    itemAbundantValue: $checkedConvert(
      'itemAbundantValue',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
    ),
    svtAscensionIcon: $checkedConvert('svtAscensionIcon', (v) => (v as num?)?.toInt() ?? 1),
    preferAprilFoolIcon: $checkedConvert('preferAprilFoolIcon', (v) => v as bool? ?? false),
    customSvtIcon: $checkedConvert(
      'customSvtIcon',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String?)),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'version': instance.version,
  'appVer': instance.appVer,
  'curUserKey': instance.curUserKey,
  'users': instance.users.map((e) => e.toJson()).toList(),
  'itemAbundantValue': instance.itemAbundantValue,
  'svtAscensionIcon': instance.svtAscensionIcon,
  'preferAprilFoolIcon': instance.preferAprilFoolIcon,
  'customSvtIcon': instance.customSvtIcon.map((k, e) => MapEntry(k.toString(), e)),
};

User _$UserFromJson(Map json) => $checkedCreate('User', json, ($checkedConvert) {
  final val = User(
    id: $checkedConvert('id', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String? ?? 'Gudako'),
    isGirl: $checkedConvert('isGirl', (v) => v as bool? ?? true),
    region: $checkedConvert('region', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
    servants: $checkedConvert(
      'servants',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), SvtStatus.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    dupServantMapping: $checkedConvert(
      'dupServantMapping',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    plans: $checkedConvert(
      'plans',
      (v) => (v as List<dynamic>?)?.map((e) => UserPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    sameEventPlan: $checkedConvert('sameEventPlan', (v) => v as bool? ?? true),
    curSvtPlanNo: $checkedConvert('curSvtPlanNo', (v) => (v as num?)?.toInt() ?? 0),
    items: $checkedConvert(
      'items',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    craftEssences: $checkedConvert(
      'craftEssences',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), CraftStatus.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    cmdCodes: $checkedConvert(
      'cmdCodes',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), CmdCodeStatus.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    mysticCodes: $checkedConvert(
      'mysticCodes',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    summons: $checkedConvert('summons', (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
    myRoomMusic: $checkedConvert('myRoomMusic', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
    classBoards: $checkedConvert(
      'classBoards',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), ClassBoardPlan.fromJson(e))),
    ),
    freeLPParams: $checkedConvert(
      'freeLPParams',
      (v) => v == null ? null : FreeLPParams.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    luckyBagSvtScores: $checkedConvert(
      'luckyBagSvtScores',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(k as String, (e as Map).map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt()))),
      ),
    ),
    saintQuartzPlan: $checkedConvert(
      'saintQuartzPlan',
      (v) => v == null ? null : SaintQuartzPlan.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    battleSim: $checkedConvert(
      'battleSim',
      (v) => v == null ? null : BattleSimUserData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isGirl': instance.isGirl,
  'region': const RegionConverter().toJson(instance.region),
  'dupServantMapping': instance.dupServantMapping.map((k, e) => MapEntry(k.toString(), e)),
  'servants': instance.servants.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'classBoards': instance.classBoards.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'plans': instance.plans.map((e) => e.toJson()).toList(),
  'sameEventPlan': instance.sameEventPlan,
  'curSvtPlanNo': instance.curSvtPlanNo,
  'items': instance.items.map((k, e) => MapEntry(k.toString(), e)),
  'craftEssences': instance.craftEssences.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'cmdCodes': instance.cmdCodes.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'mysticCodes': instance.mysticCodes.map((k, e) => MapEntry(k.toString(), e)),
  'summons': instance.summons.toList(),
  'myRoomMusic': instance.myRoomMusic.toList(),
  'freeLPParams': instance.freeLPParams.toJson(),
  'luckyBagSvtScores': instance.luckyBagSvtScores.map(
    (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e))),
  ),
  'saintQuartzPlan': instance.saintQuartzPlan.toJson(),
  'battleSim': instance.battleSim.toJson(),
};

SvtStatus _$SvtStatusFromJson(Map json) => $checkedCreate('SvtStatus', json, ($checkedConvert) {
  final val = SvtStatus(
    cur: $checkedConvert('cur', (v) => v == null ? null : SvtPlan.fromJson(Map<String, dynamic>.from(v as Map))),
    priority: $checkedConvert('priority', (v) => (v as num?)?.toInt() ?? 1),
    bond: $checkedConvert('bond', (v) => (v as num?)?.toInt() ?? 0),
    equipCmdCodes: $checkedConvert(
      'equipCmdCodes',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
    ),
    cmdCardStrengthen: $checkedConvert(
      'cmdCardStrengthen',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    grandSvt: $checkedConvert('grandSvt', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$SvtStatusToJson(SvtStatus instance) => <String, dynamic>{
  'cur': instance.cur.toJson(),
  'priority': instance.priority,
  'bond': instance.bond,
  'equipCmdCodes': instance.equipCmdCodes,
  'cmdCardStrengthen': instance.cmdCardStrengthen,
  'grandSvt': instance.grandSvt,
};

UserPlan _$UserPlanFromJson(Map json) => $checkedCreate('UserPlan', json, ($checkedConvert) {
  final val = UserPlan(
    title: $checkedConvert('title', (v) => v as String? ?? ''),
    servants: $checkedConvert(
      'servants',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), SvtPlan.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    limitEvents: $checkedConvert(
      'limitEvents',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), LimitEventPlan.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    mainStories: $checkedConvert(
      'mainStories',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), MainStoryPlan.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    tickets: $checkedConvert(
      'tickets',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), ExchangeTicketPlan.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    classBoards: $checkedConvert(
      'classBoards',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), ClassBoardPlan.fromJson(e))),
    ),
    recipes: $checkedConvert('recipes', (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as bool))),
  );
  return val;
});

Map<String, dynamic> _$UserPlanToJson(UserPlan instance) => <String, dynamic>{
  'title': instance.title,
  'servants': instance.servants.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'limitEvents': instance.limitEvents.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'mainStories': instance.mainStories.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'tickets': instance.tickets.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'classBoards': instance.classBoards.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'recipes': instance.recipes.map((k, e) => MapEntry(k.toString(), e)),
};

SvtPlan _$SvtPlanFromJson(Map json) => $checkedCreate('SvtPlan', json, ($checkedConvert) {
  final val = SvtPlan(
    favorite: $checkedConvert('favorite', (v) => v as bool? ?? false),
    ascension: $checkedConvert('ascension', (v) => (v as num?)?.toInt() ?? 0),
    skills: $checkedConvert('skills', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    appendSkills: $checkedConvert(
      'appendSkills',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    costumes: $checkedConvert(
      'costumes',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    grail: $checkedConvert('grail', (v) => (v as num?)?.toInt() ?? 0),
    fouHp: $checkedConvert('fouHp', (v) => (v as num?)?.toInt() ?? 0),
    fouAtk: $checkedConvert('fouAtk', (v) => (v as num?)?.toInt() ?? 0),
    fouHp3: $checkedConvert('fouHp3', (v) => (v as num?)?.toInt() ?? 20),
    fouAtk3: $checkedConvert('fouAtk3', (v) => (v as num?)?.toInt() ?? 20),
    bondLimit: $checkedConvert('bondLimit', (v) => (v as num?)?.toInt() ?? 10),
    npLv: $checkedConvert('npLv', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$SvtPlanToJson(SvtPlan instance) => <String, dynamic>{
  'favorite': instance.favorite,
  'ascension': instance.ascension,
  'skills': instance.skills,
  'appendSkills': instance.appendSkills,
  'costumes': instance.costumes.map((k, e) => MapEntry(k.toString(), e)),
  'grail': instance.grail,
  'fouHp': instance.fouHp,
  'fouAtk': instance.fouAtk,
  'fouHp3': instance.fouHp3,
  'fouAtk3': instance.fouAtk3,
  'bondLimit': instance.bondLimit,
  'npLv': instance.npLv,
};

LimitEventPlan _$LimitEventPlanFromJson(Map json) => $checkedCreate('LimitEventPlan', json, ($checkedConvert) {
  final val = LimitEventPlan(
    enabled: $checkedConvert('enabled', (v) => v as bool? ?? false),
    rerunGrails: $checkedConvert('rerunGrails', (v) => (v as num?)?.toInt() ?? 0),
    shop: $checkedConvert('shop', (v) => v as bool? ?? true),
    shopBuyCount: $checkedConvert(
      'shopBuyCount',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    point: $checkedConvert('point', (v) => v as bool? ?? true),
    mission: $checkedConvert('mission', (v) => v as bool? ?? true),
    tower: $checkedConvert('tower', (v) => v as bool? ?? true),
    lotteries: $checkedConvert(
      'lotteries',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    treasureBoxItems: $checkedConvert(
      'treasureBoxItems',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(
          int.parse(k as String),
          (e as Map).map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
        ),
      ),
    ),
    fixedDrop: $checkedConvert('fixedDrop', (v) => v as bool? ?? true),
    questReward: $checkedConvert('questReward', (v) => v as bool? ?? true),
    warBoard: $checkedConvert('warBoard', (v) => v as bool? ?? true),
    extraFixedItems: $checkedConvert(
      'extraFixedItems',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as bool)),
    ),
    extraItems: $checkedConvert(
      'extraItems',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(
          int.parse(k as String),
          (e as Map).map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
        ),
      ),
    ),
    customItems: $checkedConvert(
      'customItems',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
  );
  return val;
});

Map<String, dynamic> _$LimitEventPlanToJson(LimitEventPlan instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'rerunGrails': instance.rerunGrails,
  'shop': instance.shop,
  'shopBuyCount': instance.shopBuyCount.map((k, e) => MapEntry(k.toString(), e)),
  'point': instance.point,
  'mission': instance.mission,
  'tower': instance.tower,
  'lotteries': instance.lotteries.map((k, e) => MapEntry(k.toString(), e)),
  'treasureBoxItems': instance.treasureBoxItems.map(
    (k, e) => MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e))),
  ),
  'fixedDrop': instance.fixedDrop,
  'questReward': instance.questReward,
  'warBoard': instance.warBoard,
  'extraFixedItems': instance.extraFixedItems.map((k, e) => MapEntry(k.toString(), e)),
  'extraItems': instance.extraItems.map((k, e) => MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
  'customItems': instance.customItems.map((k, e) => MapEntry(k.toString(), e)),
};

MainStoryPlan _$MainStoryPlanFromJson(Map json) => $checkedCreate('MainStoryPlan', json, ($checkedConvert) {
  final val = MainStoryPlan(
    fixedDrop: $checkedConvert('fixedDrop', (v) => v as bool? ?? false),
    questReward: $checkedConvert('questReward', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$MainStoryPlanToJson(MainStoryPlan instance) => <String, dynamic>{
  'fixedDrop': instance.fixedDrop,
  'questReward': instance.questReward,
};

ExchangeTicketPlan _$ExchangeTicketPlanFromJson(Map json) =>
    $checkedCreate('ExchangeTicketPlan', json, ($checkedConvert) {
      final val = ExchangeTicketPlan(
        counts: $checkedConvert('counts', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
      );
      return val;
    });

Map<String, dynamic> _$ExchangeTicketPlanToJson(ExchangeTicketPlan instance) => <String, dynamic>{
  'counts': instance.counts,
};

CraftStatus _$CraftStatusFromJson(Map json) => $checkedCreate('CraftStatus', json, ($checkedConvert) {
  final val = CraftStatus(
    status: $checkedConvert('status', (v) => (v as num?)?.toInt() ?? CraftStatus.notMet),
    lv: $checkedConvert('lv', (v) => (v as num?)?.toInt() ?? 1),
    limitCount: $checkedConvert('limitCount', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$CraftStatusToJson(CraftStatus instance) => <String, dynamic>{
  'status': instance.status,
  'lv': instance.lv,
  'limitCount': instance.limitCount,
};

CmdCodeStatus _$CmdCodeStatusFromJson(Map json) => $checkedCreate('CmdCodeStatus', json, ($checkedConvert) {
  final val = CmdCodeStatus(
    status: $checkedConvert('status', (v) => (v as num?)?.toInt() ?? CmdCodeStatus.notMet),
    count: $checkedConvert('count', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$CmdCodeStatusToJson(CmdCodeStatus instance) => <String, dynamic>{
  'status': instance.status,
  'count': instance.count,
};

ClassBoardPlan _$ClassBoardPlanFromJson(Map json) => $checkedCreate('ClassBoardPlan', json, ($checkedConvert) {
  final val = ClassBoardPlan(
    unlockedSquares: $checkedConvert(
      'unlockedSquares',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
    ),
    enhancedSquares: $checkedConvert(
      'enhancedSquares',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ClassBoardPlanToJson(ClassBoardPlan instance) => <String, dynamic>{
  'unlockedSquares': instance.unlockedSquares.toList(),
  'enhancedSquares': instance.enhancedSquares.toList(),
};

SaintQuartzPlan _$SaintQuartzPlanFromJson(Map json) => $checkedCreate('SaintQuartzPlan', json, ($checkedConvert) {
  final val = SaintQuartzPlan(
    curSQ: $checkedConvert('curSQ', (v) => (v as num?)?.toInt() ?? 0),
    curTicket: $checkedConvert('curTicket', (v) => (v as num?)?.toInt() ?? 0),
    curApple: $checkedConvert('curApple', (v) => (v as num?)?.toInt() ?? 0),
    startDate: $checkedConvert('startDate', (v) => v == null ? null : DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => v == null ? null : DateTime.parse(v as String)),
    accLogin: $checkedConvert('accLogin', (v) => (v as num?)?.toInt() ?? 1),
    continuousLogin: $checkedConvert('continuousLogin', (v) => (v as num?)?.toInt() ?? 1),
    weeklyMission: $checkedConvert('weeklyMission', (v) => v as bool? ?? true),
    limitedMission: $checkedConvert('limitedMission', (v) => v as bool? ?? true),
    campaignLoginBonus: $checkedConvert('campaignLoginBonus', (v) => v as bool? ?? true),
    extraMissions: $checkedConvert(
      'extraMissions',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as bool)),
    ),
    minusPlannedBanner: $checkedConvert('minusPlannedBanner', (v) => v as bool?),
    favoriteSummonOnly: $checkedConvert('favoriteSummonOnly', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$SaintQuartzPlanToJson(SaintQuartzPlan instance) => <String, dynamic>{
  'curSQ': instance.curSQ,
  'curTicket': instance.curTicket,
  'curApple': instance.curApple,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'accLogin': instance.accLogin,
  'continuousLogin': instance.continuousLogin,
  'weeklyMission': instance.weeklyMission,
  'limitedMission': instance.limitedMission,
  'campaignLoginBonus': instance.campaignLoginBonus,
  'extraMissions': instance.extraMissions.map((k, e) => MapEntry(k.toString(), e)),
  'minusPlannedBanner': instance.minusPlannedBanner,
  'favoriteSummonOnly': instance.favoriteSummonOnly,
};

const _$LockPlanEnumMap = {LockPlan.none: 0, LockPlan.planned: 1, LockPlan.full: 2};
