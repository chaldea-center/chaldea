library userdata;

import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../packages/language.dart';
import '../../utils/basic.dart';
import '../../utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'glpk.dart';

part 'sq_plan.dart';
part '../../generated/models/userdata/userdata.g.dart';

/// user data will be shared across devices and cloud
@JsonSerializable()
class UserData {
  static const int modelVersion = 4;

  final int version;

  int get curUserKey {
    if (users.isEmpty) users.add(User());
    if (_curUserKey < 0 || _curUserKey >= users.length) {
      _curUserKey = 0;
    }
    return _curUserKey;
  }

  int _curUserKey;
  set curUserKey(int v) {
    _curUserKey = v.clamp(0, users.length - 1);
  }

  User get curUser => users[curUserKey];

  List<User> users;
  List<int> itemAbundantValue;
  int svtAscensionIcon;
  Map<int, String?> customSvtIcon;

  UserData({
    this.version = UserData.modelVersion,
    int curUserKey = 0,
    List<User>? users,
    List<int?>? itemAbundantValue,
    this.svtAscensionIcon = 1,
    Map<int, String?>? customSvtIcon,
  })  : _curUserKey = curUserKey.clamp(0, (users?.length ?? 1) - 1),
        users = users?.isNotEmpty == true ? users! : <User>[User()],
        itemAbundantValue = List.generate(
            3, (index) => itemAbundantValue?.getOrNull(index) ?? 0,
            growable: false),
        customSvtIcon = customSvtIcon ?? {} {
    validate();
  }

  String validUsername(String baseName) {
    int i = 2;
    String newName = baseName = baseName.replaceFirst(RegExp(r' \(\d+\)$'), '');
    do {
      newName = '$baseName ($i)';
      i++;
    } while (users.any((user) => user.name == newName));
    return newName;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    if (json['version'] == 2) {
      return UserData.fromLegacy(json);
    } else if (json['version'] == 3) {
      List users = json['users'] ?? [];
      for (final Map user in users) {
        List svtPlans = user['svtPlanGroups'] ?? [];
        if (svtPlans.isNotEmpty) {
          user['plans'] = svtPlans.map((e) => {'servants': e}).toList();
        } else {
          user['plans'] = {};
        }
        final Map plan = user['plans'][0];
        plan['limitEvents'] = user['events'];
        plan['mainStories'] = user['mainStories'];
        plan['tickets'] = user['exchangeTickets'];
      }
      return _$UserDataFromJson(json);
    }
    return _$UserDataFromJson(json);
  }

  factory UserData.fromLegacy(Map<String, dynamic> oldData) {
    List<User> users = [];
    Map<String, int> itemNameMap = {};
    for (final item in db.gameData.items.values) {
      itemNameMap[item.lName.cn] = item.id;
    }
    for (final oldUser
        in Map<String, Map<String, dynamic>>.from(oldData['users']!).values) {
      Map<int, SvtStatus> statuses = {};
      List<UserPlan> plans = [];
      for (final String idStr in Map.from(oldUser['servants'] ?? {}).keys) {
        final id = int.parse(idStr);
        final oldStatus =
            Map<String, dynamic>.from(oldUser['servants']?[idStr]);
        statuses[id] = SvtStatus(
          cur: _convertLegacyPlan(oldStatus['curVal'], oldStatus['npLv']),
          coin: (oldStatus['coin'] as int?) ?? 0,
          priority: (oldStatus['priority'] as int?) ?? 1,
          equipCmdCodes: List.from((oldStatus['equipCmdCodes'] as List?) ?? []),
        );
      }
      print(
          'user ${oldUser['name']}: ${oldUser['servantPlans']?.length} plans');
      for (final svtPlans
          in List<Map<String, dynamic>>.from((oldUser['servantPlans'] ?? []))) {
        plans.add(UserPlan(
            servants: svtPlans.map((key, value) =>
                MapEntry(int.parse(key), _convertLegacyPlan(value, null)))));
      }
      final user = User(
        name: oldUser['name'] ?? 'unknown',
        isGirl: (oldUser['isMasterGirl'] as bool?) ?? true,
        use6thDrops: (oldUser['use6thDropRate'] as bool?) ?? true,
        region: {
              'jp': Region.jp,
              'cn': Region.cn,
              'tw': Region.tw,
              'en': Region.na
            }[oldUser['server']] ??
            Region.jp,
        servants: statuses,
        plans: plans,
        curSvtPlanNo: 0,
        items: {},
        craftEssences: Map<String, int>.from(oldUser['crafts'] ?? {})
            .map((key, value) => MapEntry(int.parse(key), value)),
        mysticCodes: null,
        summons: null,
        freeLPParams: null,
      );
      for (final entry
          in Map<String, int>.from(oldUser['items'] ?? {}).entries) {
        if (itemNameMap.containsKey(entry.key)) {
          user.items[itemNameMap[entry.key]!] = entry.value;
        }
      }
      user.validate();
      users.add(user);
    }
    return UserData(users: users);
  }

  static SvtPlan _convertLegacyPlan(Map<String, dynamic>? oldPlan, int? npLv) {
    if (oldPlan == null) return SvtPlan();
    return SvtPlan(
      favorite: (oldPlan['favorite'] as bool?) ?? false,
      ascension: (oldPlan['ascension'] as int?) ?? 0,
      skills: List.generate(
          3, (index) => (oldPlan['skills'] as List?)?.getOrNull(index) ?? 0),
      appendSkills: List.generate(3,
          (index) => (oldPlan['appendSkills'] as List?)?.getOrNull(index) ?? 0),
      costumes: null,
      grail: (oldPlan['grail'] as int?) ?? 0,
      fouHp: (oldPlan['fouHp'] as int?) ?? 0,
      fouAtk: (oldPlan['fouAtk'] as int?) ?? 0,
      bondLimit: (oldPlan['bondLimit'] as int?) ?? 0,
      npLv: npLv,
    );
  }

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  void validate() {
    if (users.isEmpty) {
      users.add(User());
    }
    curUserKey = curUserKey.clamp2(0, users.length - 1);
    for (final user in users) {
      user.validate();
    }
    svtAscensionIcon = svtAscensionIcon.clamp(1, 4);
  }
}

const kSvtPlanMaxNum = 5;

@JsonSerializable()
class User {
  String name;
  bool isGirl;
  bool use6thDrops;

  Region region;
  Map<int, SvtStatus> servants;
  List<UserPlan> plans;
  bool sameEventPlan;

  int get curSvtPlanNo => _curSvtPlanNo.clamp(0, plans.length - 1);
  int _curSvtPlanNo;

  set curSvtPlanNo(int v) => _curSvtPlanNo = v.clamp(0, plans.length - 1);

  Map<int, int> items;

  // 1-met, 2-owned, else 0
  Map<int, int> craftEssences;
  Map<int, int> mysticCodes;
  Set<String> summons;

  bool use6thDropRate;
  FreeLPParams freeLPParams;
  Map<String, Map<int, int>> luckyBagSvtScores;

  SaintQuartzPlan saintQuartzPlan;

  User({
    this.name = 'Gudako',
    this.isGirl = true,
    this.use6thDrops = true,
    this.region = Region.jp,
    Map<int, SvtStatus>? servants,
    List<UserPlan>? plans,
    this.sameEventPlan = true,
    int curSvtPlanNo = 0,
    Map<int, int>? items,
    Map<int, int?>? craftEssences,
    Map<int, int>? mysticCodes,
    Set<String>? summons,
    this.use6thDropRate = true,
    FreeLPParams? freeLPParams,
    Map<String, Map<int, int>>? luckyBagSvtScores,
    SaintQuartzPlan? saintQuartzPlan,
  })  : servants = servants ?? {},
        plans = List.generate(
            kSvtPlanMaxNum, (index) => plans?.getOrNull(index) ?? UserPlan()),
        _curSvtPlanNo = curSvtPlanNo.clamp(0, kSvtPlanMaxNum - 1),
        items = items ?? {},
        craftEssences = {
          if (craftEssences != null)
            for (final e in craftEssences.entries)
              if (e.value != null) e.key: e.value!
        },
        mysticCodes = mysticCodes ?? {},
        summons = summons ?? {},
        freeLPParams = freeLPParams ?? FreeLPParams(),
        luckyBagSvtScores = luckyBagSvtScores ?? {},
        saintQuartzPlan = saintQuartzPlan ?? SaintQuartzPlan();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  UserPlan get curPlan_ => plans[curSvtPlanNo];
  Map<int, SvtPlan> get curSvtPlan => curPlan_.servants;
  UserPlan get _curEventPlan => plans[sameEventPlan ? 0 : curSvtPlanNo];

  void ensurePlanLarger() {
    curSvtPlan.forEach((key, plan) {
      plan.validate(servants[key]?.cur, db.gameData.servants[key]);
    });
  }

  SvtPlan svtPlanOf(int no) =>
      curSvtPlan.putIfAbsent(no, () => SvtPlan())..validate();

  SvtStatus svtStatusOf(int no) {
    final status = servants.putIfAbsent(no, () => SvtStatus())..cur.validate();
    return status;
  }

  LimitEventPlan limitEventPlanOf(int eventId) =>
      _curEventPlan.limitEvents.putIfAbsent(eventId, () => LimitEventPlan());

  MainStoryPlan mainStoryOf(int warId) =>
      _curEventPlan.mainStories.putIfAbsent(warId, () => MainStoryPlan());

  ExchangeTicketPlan ticketOf(int key) =>
      _curEventPlan.tickets.putIfAbsent(key, () => ExchangeTicketPlan());

  void validate() {
    if (plans.isEmpty) {
      plans.add(UserPlan());
    }
    curSvtPlanNo = curSvtPlanNo.clamp2(0, plans.length - 1);
    servants.values.forEach((e) => e.validate());
    for (final key in servants.keys) {
      servants[key]!.validate(db.gameData.servants[key]);
    }
    for (final group in plans) {
      for (final plan in group.servants.entries) {
        plan.value
            .validate(servants[plan.key]?.cur, db.gameData.servants[plan.key]);
      }
    }
  }

  String getFriendlyPlanName([int? planNo]) {
    planNo ??= curSvtPlanNo;
    String name = '${S.current.plan} ${planNo + 1}';
    String? customName = plans.getOrNull(planNo)?.title;
    if (customName != null && customName.isNotEmpty) name += ' - $customName';
    return name;
  }
}

@JsonSerializable()
class SvtStatus {
  SvtPlan cur;
  int coin;
  int priority; //1-5

  /// current bond, 5.5=5
  int bond;
  List<int?> equipCmdCodes;

  SvtStatus({
    SvtPlan? cur,
    this.coin = 0,
    this.priority = 1,
    this.bond = 0,
    List<int?>? equipCmdCodes,
  })  : cur = cur ?? SvtPlan(),
        equipCmdCodes =
            List.generate(5, (index) => equipCmdCodes?.getOrNull(index));

  factory SvtStatus.fromJson(Map<String, dynamic> json) =>
      _$SvtStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SvtStatusToJson(this);

  void validate([Servant? svt]) {
    bond = bond.clamp2(0, 15);
    coin = coin.clamp2(0);
    priority = priority.clamp2(1, 5);
    cur.bondLimit = cur.bondLimit.clamp2(bond, 15);
    cur.validate(null, svt);
    // equipCmdCodes
  }

  @JsonKey(ignore: true)
  bool get favorite => cur.favorite;

  set favorite(bool v) => cur.favorite = v;
}

@JsonSerializable()
class UserPlan {
  String title;
  Map<int, SvtPlan> servants;
  Map<int, LimitEventPlan> limitEvents;
  Map<int, MainStoryPlan> mainStories;
  Map<int, ExchangeTicketPlan> tickets;
  UserPlan({
    this.title = '',
    Map<int, SvtPlan>? servants,
    Map<int, LimitEventPlan>? limitEvents,
    Map<int, MainStoryPlan>? mainStories,
    Map<int, ExchangeTicketPlan>? tickets,
  })  : servants = servants ?? {},
        limitEvents = limitEvents ?? {},
        mainStories = mainStories ?? {},
        tickets = tickets ?? {};

  factory UserPlan.fromJson(Map<String, dynamic> json) =>
      _$UserPlanFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlanToJson(this);

  void clear() {
    servants.clear();
    limitEvents.clear();
    mainStories.clear();
    tickets.clear();
  }
}

@JsonSerializable()
class SvtPlan {
  /// for cur status favorite=owned
  bool favorite;
  int ascension; // 0-4
  List<int> skills; // 1-10
  List<int> appendSkills; // 0-10
  Map<int, int> costumes; // costume battleCharaId

  int grail; // 0~

  // 0-50, only ★4 fou-kun planned
  int fouHp;
  int fouAtk;

  // bond's upper limit, 5.5=6
  int bondLimit;

  // set it later according to rarity and event svt?
  int? _npLv;

  int get npLv => _npLv ?? 1;

  set npLv(int v) => _npLv = v;

  SvtPlan({
    this.favorite = false,
    this.ascension = 0,
    List<int>? skills,
    List<int>? appendSkills,
    Map<int, int>? costumes,
    this.grail = 0,
    this.fouHp = 0,
    this.fouAtk = 0,
    this.bondLimit = 10,
    int? npLv,
  })  : skills = List.generate(3, (index) => skills?.getOrNull(index) ?? 1,
            growable: false),
        costumes = costumes ?? {},
        appendSkills = List.generate(
            3, (index) => appendSkills?.getOrNull(index) ?? 0,
            growable: false),
        _npLv = npLv {
    validate();
  }

  static SvtPlan empty = SvtPlan();

  SvtPlan.max(Servant svt)
      : favorite = true,
        ascension = 4,
        skills = const [10, 10, 10],
        appendSkills = const [10, 10, 10],
        costumes = svt.costumeMaterials.map((key, value) => MapEntry(key, 1)),
        grail = _grailCostByRarity[svt.rarity] + 10,
        fouHp = 50,
        fouAtk = 50,
        bondLimit = 15,
        _npLv = 5;
  static const _grailCostByRarity = [10, 10, 10, 9, 7, 5];

  factory SvtPlan.fromJson(Map<String, dynamic> json) =>
      _$SvtPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SvtPlanToJson(this);

  void validate([SvtPlan? lower, Servant? svt]) {
    ascension = ascension.clamp2(lower?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = skills[i].clamp2(lower?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < appendSkills.length; i++) {
      appendSkills[i] = appendSkills[i].clamp2(lower?.appendSkills[i] ?? 0, 10);
    }
    if (svt != null) {
      costumes
          .removeWhere((key, value) => !svt.profile.costume.keys.contains(key));
    }
    for (final id in costumes.keys.toList()) {
      costumes[id] = costumes[id] == 1 ? 1 : 0;
    }
    if (lower != null) {
      for (final id in lower.costumes.keys.toList()) {
        costumes[id] = (costumes[id] ?? 0).clamp2(lower.costumes[id] ?? 0, 1);
      }
    }
    final _grailLvs = db.gameData.constData.svtGrailCost[svt?.rarity]?.keys;
    grail = grail.clamp2(
        lower?.grail ?? 0, _grailLvs == null ? 20 : Maths.max(_grailLvs));
    fouHp = fouHp.clamp2(lower?.fouHp ?? 0, 50);
    fouAtk = fouAtk.clamp2(lower?.fouAtk ?? 0, 50);
    bondLimit = bondLimit.clamp2(lower?.bondLimit ?? 10, 15);

    if (_npLv == null && svt != null) {
      if (svt.rarity <= 3 ||
          svt.extra.obtains.contains(SvtObtain.eventReward)) {
        _npLv = 5;
      }
    }
    if (_npLv != null) {
      _npLv = _npLv!.clamp2(lower?.npLv ?? 1, 5);
    }
  }

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, 3, 1);
    costumes.clear();
    appendSkills.fillRange(0, 3, 0);
    grail = 0;
    fouHp = fouAtk = -20;
    bondLimit = 0;
  }

  void setMax({int skill = 10}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    skills.fillRange(0, 3, skill);
    // costumes;
    // appendSkills.fillRange(0, 3, skill);
    // grail = grail;
    // fouHp, fouAtk
  }
}

@JsonSerializable()
class LimitEventPlan {
  bool enabled;
  int rerunGrails;

  bool shop;
  Set<int> shopExcludeItem;
  bool point;
  bool mission;
  bool tower;
  Map<int, int> lotteries;
  Map<int, Map<int, int>> treasureBoxItems;
  bool fixedDrop;
  bool questReward;
  Map<int, Map<int, int>> extraItems;

  LimitEventPlan({
    this.enabled = false,
    this.rerunGrails = 0,
    this.shop = true,
    Set<int>? shopExcludeItem,
    this.point = true,
    this.mission = true,
    this.tower = true,
    Map<int, int>? lotteries,
    Map<int, Map<int, int>>? treasureBoxItems,
    this.fixedDrop = true,
    this.questReward = true,
    Map<int, Map<int, int>>? extraItems,
  })  : shopExcludeItem = shopExcludeItem ?? {},
        lotteries = lotteries ?? {},
        treasureBoxItems = treasureBoxItems ?? {},
        extraItems = extraItems ?? {};

  factory LimitEventPlan.fromJson(Map<String, dynamic> json) =>
      _$LimitEventPlanFromJson(json);

  Map<String, dynamic> toJson() => _$LimitEventPlanToJson(this);

  void reset() {
    enabled = false;
    shop = true;
    shopExcludeItem.clear();
    point = true;
    mission = true;
    tower = true;
    lotteries.clear();
    treasureBoxItems.clear();
    fixedDrop = true;
    questReward = true;
    extraItems.clear();
  }

  void planAll() {
    enabled = true;
    shop = true;
    // shopExcludeItem.clear();
    point = true;
    mission = true;
    tower = true;
    // lotteries.clear();
    // treasureBoxItems.clear();
    fixedDrop = true;
    questReward = true;
    // extraItems.clear();
  }

  LimitEventPlan copy() {
    return LimitEventPlan(
      enabled: enabled,
      shop: shop,
      shopExcludeItem: Set.of(shopExcludeItem),
      point: point,
      mission: mission,
      tower: tower,
      lotteries: Map.of(lotteries),
      treasureBoxItems:
          treasureBoxItems.map((key, value) => MapEntry(key, Map.of(value))),
      fixedDrop: fixedDrop,
      questReward: questReward,
      extraItems: extraItems.map((key, value) => MapEntry(key, Map.of(value))),
    );
  }
}

@JsonSerializable()
class MainStoryPlan {
  bool fixedDrop;
  bool questReward;

  MainStoryPlan({
    this.fixedDrop = false,
    this.questReward = false,
  });

  factory MainStoryPlan.fromJson(Map<String, dynamic> json) =>
      _$MainStoryPlanFromJson(json);

  Map<String, dynamic> toJson() => _$MainStoryPlanToJson(this);

  bool get enabled => fixedDrop || questReward;
}

@JsonSerializable()
class ExchangeTicketPlan {
  List<int> counts;

  ExchangeTicketPlan({List<int>? counts})
      : counts = List.generate(3, (index) => counts?.getOrNull(index) ?? 0,
            growable: false);

  factory ExchangeTicketPlan.fromJson(Map<String, dynamic> json) =>
      _$ExchangeTicketPlanFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeTicketPlanToJson(this);

  bool get enabled => counts.any((e) => e > 0);
}

enum Region {
  jp,
  cn,
  tw,
  na,
  kr,
}

const _regionLanguage = {
  Region.jp: Language.jp,
  Region.cn: Language.chs,
  Region.tw: Language.cht,
  Region.na: Language.en,
  Region.kr: Language.ko,
};

extension RegionX on Region {
  String toUpper() {
    return name.toUpperCase();
  }

  String get localName {
    switch (this) {
      case Region.jp:
        return S.current.region_jp;
      case Region.cn:
        return S.current.region_cn;
      case Region.tw:
        return S.current.region_tw;
      case Region.na:
        return S.current.region_na;
      case Region.kr:
        return S.current.region_kr;
    }
  }

  Language toLanguage() => _regionLanguage[this]!;
}

class CraftStatus {
  CraftStatus._();
  static const notMet = 0;
  static const met = 1;
  static const owned = 2;

  static const List<int> values = [notMet, met, owned];

  static String shownText(int status) {
    assert(values.contains(status), status);
    return [
          S.current.ce_status_not_met,
          S.current.ce_status_met,
          S.current.ce_status_owned
        ].getOrNull(status) ??
        status.toString();
  }
}
