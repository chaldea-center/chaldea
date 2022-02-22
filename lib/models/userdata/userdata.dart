library userdata;

import 'package:chaldea/generated/l10n.dart';

import '../../packages/language.dart';
import '../../utils/basic.dart';
import '../../utils/extension.dart';
import '../gamedata/servant.dart';
import '_helper.dart';

part '../../generated/models/userdata/userdata.g.dart';

/// user data will be shared across devices and cloud
@JsonSerializable()
class UserData {
  static const int modelVersion = 1;

  final int version;

  int curUserKey;
  List<User> users;
  List<int> itemAbundantValue;

  UserData({
    this.version = UserData.modelVersion,
    this.curUserKey = 0,
    List<User>? users,
    List<int?>? itemAbundantValue,
  })  : users = users?.isNotEmpty == true ? users! : <User>[User()],
        itemAbundantValue = List.generate(
            3, (index) => itemAbundantValue?.getOrNull(index) ?? 0,
            growable: false) {
    validate();
  }

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  void validate() {
    if (users.isEmpty) {
      users.add(User());
    }
    curUserKey = Maths.fixValidRange(curUserKey, 0, users.length - 1);
    for (final user in users) {
      user.validate();
    }
  }
}

@JsonSerializable()
class User {
  String name;
  bool isGirl;
  bool use6thDrops;

  Region region;
  Map<int, SvtStatus> servants;
  List<Map<int, SvtPlan>> svtPlanGroups;
  int curSvtPlanNo;
  Map<int, String> planNames;

  Map<int, int> items;

  //  events, main story, tickets
  Map<int, EventPlan> events;
  Map<int, MainStoryPlan> mainStories;
  Map<int, ExchangeTicketPlan> exchangeTickets;

  Map<int, CraftStatus> craftEssences;
  Map<int, int> mysticCodes;
  Set<String> summons;

  User({
    this.name = 'Gudako',
    this.isGirl = true,
    this.use6thDrops = true,
    this.region = Region.jp,
    Map<int, SvtStatus>? servants,
    List<Map<int, SvtPlan>>? svtPlanGroups,
    this.curSvtPlanNo = 0,
    Map<int, String>? planNames,
    Map<int, int>? items,
    Map<int, EventPlan>? events,
    Map<int, MainStoryPlan>? mainStories,
    Map<int, ExchangeTicketPlan>? exchangeTickets,
    Map<int, CraftStatus?>? craftEssences,
    Map<int, int>? mysticCodes,
    Set<String>? summons,
  })  : servants = servants ?? {},
        svtPlanGroups = svtPlanGroups ?? [],
        planNames = planNames ?? {},
        items = items ?? {},
        events = events ?? {},
        mainStories = mainStories ?? {},
        exchangeTickets = exchangeTickets ?? {},
        craftEssences = {
          if (craftEssences != null)
            for (final e in craftEssences.entries)
              if (e.value != null) e.key: e.value!
        },
        mysticCodes = mysticCodes ?? {},
        summons = summons ?? {};

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  Map<int, SvtPlan> get curPlan => svtPlanGroups[curSvtPlanNo];

  void ensurePlanLarger() {
    curPlan.forEach((key, plan) {
      plan.validate(servants[key]?.cur);
    });
  }

  SvtPlan svtPlanOf(int no) =>
      curPlan.putIfAbsent(no, () => SvtPlan())..validate();

  SvtStatus svtStatusOf(int no) {
    final status = servants.putIfAbsent(no, () => SvtStatus())..cur.validate();
    return status;
  }

  EventPlan eventPlanOf(int eventId) =>
      events.putIfAbsent(eventId, () => EventPlan());

  MainStoryPlan mainStoryOf(int warId) =>
      mainStories.putIfAbsent(warId, () => MainStoryPlan());

  ExchangeTicketPlan ticketOf(int key) =>
      exchangeTickets.putIfAbsent(key, () => ExchangeTicketPlan());

  void validate() {
    if (svtPlanGroups.isEmpty) {
      svtPlanGroups.add(<int, SvtPlan>{});
    }
    curSvtPlanNo =
        Maths.fixValidRange(curSvtPlanNo, 0, svtPlanGroups.length - 1);
    servants.values.forEach((e) => e.validate());
    for (final status in servants.values) {
      status.validate();
    }
    for (final group in svtPlanGroups) {
      for (final plan in group.entries) {
        plan.value.validate(servants[plan.key]?.cur);
      }
    }
  }

  String getFriendlyPlanName([int? planNo]) {
    planNo ??= curSvtPlanNo;
    String name = '${S.current.plan} ${planNo + 1}';
    String? customName = planNames[planNo];
    if (customName != null && customName.isNotEmpty) name += ' - $customName';
    return name;
  }
}

enum CraftStatus { owned, met, notMet }

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

  void validate() {
    bond = Maths.fixValidRange(bond, 0, 15);
    coin = Maths.fixValidRange(coin, 0);
    priority = Maths.fixValidRange(priority, 1, 5);
    cur.bondLimit = Maths.fixValidRange(cur.bondLimit, bond, 15);
    cur.validate();
    // equipCmdCodes
  }
}

@JsonSerializable()
class SvtPlan {
  /// for cur status favorite=owned
  bool favorite;
  int ascension;
  List<int> skills;
  List<int> appendSkills;
  Map<int, int> costumes; // costume id

  int grail;

  // 0-50, only ★4 fou-kun planned
  int fouHp;
  int fouAtk;

  // bond's upper limit, 5.5=6
  int bondLimit;

  // set it later according to rarity and event svt?
  int? npLv;

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
    this.npLv,
  })  : skills = List.generate(3, (index) => skills?.getOrNull(index) ?? 1,
            growable: false),
        costumes = costumes ?? {},
        appendSkills = List.generate(
            3, (index) => appendSkills?.getOrNull(index) ?? 0,
            growable: false) {
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
        npLv = 5;
  static const _grailCostByRarity = [10, 10, 10, 9, 7, 5];

  factory SvtPlan.fromJson(Map<String, dynamic> json) =>
      _$SvtPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SvtPlanToJson(this);

  void validate([SvtPlan? lower]) {
    ascension = ascension.clamp(lower?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = skills[i].clamp(lower?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < appendSkills.length; i++) {
      appendSkills[i] = appendSkills[i].clamp(lower?.appendSkills[i] ?? 0, 10);
    }
    for (final id in costumes.keys.toList()) {
      costumes[id] = costumes[id] == 0 ? 0 : 1;
    }
    if (lower != null) {
      for (final id in lower.costumes.keys.toList()) {
        costumes[id] = (costumes[id] ?? 0).clamp(lower.costumes[id] ?? 0, 1);
      }
    }
    grail = grail.clamp(0, 20);
    fouHp = fouHp.clamp(lower?.fouHp ?? 0, 50);
    fouAtk = fouAtk.clamp(lower?.fouAtk ?? 0, 50);
    bondLimit = bondLimit.clamp(lower?.bondLimit ?? 10, 15);
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
class EventPlan {
  bool planned;

  bool shop;
  Set<int> shopExcludeItem;
  bool point;
  bool mission;
  bool tower;
  Map<int, int> lotteries;
  bool treasureBox;
  Map<int, int> treasureBoxItems;
  bool fixedDrop;
  bool questReward;
  bool extra;
  Map<int, Map<int, int>> extraItems;

  EventPlan({
    this.planned = false,
    this.shop = true,
    Set<int>? shopExcludeItem,
    this.point = true,
    this.mission = true,
    this.tower = true,
    Map<int, int>? lotteries,
    this.treasureBox = true,
    Map<int, int>? treasureBoxItems,
    this.fixedDrop = true,
    this.questReward = true,
    this.extra = true,
    Map<int, Map<int, int>>? extraItems,
  })  : shopExcludeItem = shopExcludeItem ?? {},
        lotteries = lotteries ?? {},
        treasureBoxItems = treasureBoxItems ?? {},
        extraItems = extraItems ?? {};

  factory EventPlan.fromJson(Map<String, dynamic> json) =>
      _$EventPlanFromJson(json);

  Map<String, dynamic> toJson() => _$EventPlanToJson(this);

  void reset() {
    planned = false;
    shop = true;
    shopExcludeItem.clear();
    point = true;
    mission = true;
    tower = true;
    lotteries.clear();
    treasureBox = true;
    treasureBoxItems.clear();
    fixedDrop = true;
    questReward = true;
    extraItems.clear();
  }

  void planAll() {
    planned = true;
    shop = true;
    // shopExcludeItem.clear();
    point = true;
    mission = true;
    tower = true;
    // lotteries.clear();
    treasureBox = true;
    // treasureBoxItems.clear();
    fixedDrop = true;
    questReward = true;
    // extraItems.clear();
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

  bool get planned => fixedDrop || questReward;
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

  bool get planned => counts.any((e) => e > 0);
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
    return EnumUtil.upperCase(this);
  }

  Language toLanguage() => _regionLanguage[this]!;
}
