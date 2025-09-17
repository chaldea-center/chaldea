library;

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/packages/app_info.dart';
import '../../utils/basic.dart';
import '../../utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'battle.dart';
import 'glpk.dart';

part 'sq_plan.dart';
part '../../generated/models/userdata/userdata.g.dart';

/// user data will be shared across devices and cloud
@JsonSerializable()
class UserData {
  static const int modelVersion = 4;

  final int version;
  String get appVer => AppInfo.versionString;
  @JsonKey(includeFromJson: false, includeToJson: false)
  int previousVersion;

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
  // 1-4, -1=user svt's cur ascension
  int svtAscensionIcon;
  bool preferAprilFoolIcon;
  Map<int, String?> customSvtIcon;

  UserData({
    int? version,
    String? appVer,
    this.previousVersion = 0,
    int curUserKey = 0,
    List<User>? users,
    List<int?>? itemAbundantValue,
    this.svtAscensionIcon = 1,
    this.preferAprilFoolIcon = false,
    Map<int, String?>? customSvtIcon,
  }) : version = UserData.modelVersion,
       _curUserKey = curUserKey.clamp(0, (users?.length ?? 1) - 1),
       users = users?.isNotEmpty == true ? users! : <User>[User()],
       itemAbundantValue = List.generate(3, (index) => itemAbundantValue?.getOrNull(index) ?? 0, growable: false),
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
    final previousVersion = json['version'];
    UserData userData;
    if (previousVersion == 2) {
      // v1.x data
      userData = UserData();
    } else if (previousVersion == 3) {
      List users = json['users'] ?? [];
      for (final Map user in users) {
        List svtPlans = user['svtPlanGroups'] ?? [];
        if (svtPlans.isNotEmpty) {
          user['plans'] = svtPlans.map((e) => {'servants': e}).toList();
        } else {
          user['plans'] = [{}];
        }
        final Map plan = user['plans'][0];
        plan['limitEvents'] = user['events'];
        plan['mainStories'] = user['mainStories'];
        plan['tickets'] = user['exchangeTickets'];
      }
      userData = _$UserDataFromJson(json);
    } else {
      userData = _$UserDataFromJson(json);
    }
    if (previousVersion is int || previousVersion == null) {
      userData.previousVersion = previousVersion ?? 0;
    }
    return userData;
  }

  Map<String, dynamic> toJson() {
    sort();
    return _$UserDataToJson(this);
  }

  void validate() {
    if (users.isEmpty) {
      users.add(User());
    }
    curUserKey = curUserKey.clamp2(0, users.length - 1);
    for (final user in users) {
      user.validate();
    }
    if (svtAscensionIcon != -1) {
      svtAscensionIcon = svtAscensionIcon.clamp(1, 4);
    }
  }

  void sort() {
    for (final user in users) {
      user.sort();
    }
    customSvtIcon = sortDict(customSvtIcon);
  }
}

const kSvtPlanMaxNum = 5;

@JsonSerializable(converters: [LockPlanConverter()])
class User {
  final String id;
  String name;
  bool isGirl;
  @RegionConverter()
  Region region;
  Map<int, int> dupServantMapping; // <new id, original id>
  Map<int, SvtStatus> servants;
  Map<int, ClassBoardPlan> classBoards;
  List<UserPlan> plans;
  bool sameEventPlan;

  int get curSvtPlanNo => _curSvtPlanNo.clamp(0, plans.length - 1);
  set curSvtPlanNo(int v) => _curSvtPlanNo = v.clamp(0, plans.length - 1);
  int _curSvtPlanNo;

  Map<int, int> items;

  Map<int, CraftStatus> craftEssences;
  Map<int, CmdCodeStatus> cmdCodes;
  Map<int, int> mysticCodes;
  Set<String> summons;
  Set<int> myRoomMusic;

  FreeLPParams freeLPParams;
  Map<String, Map<int, int>> luckyBagSvtScores;

  SaintQuartzPlan saintQuartzPlan;

  BattleSimUserData battleSim;

  String? lastImportId;

  User({
    String? id,
    this.name = 'Gudako',
    this.isGirl = true,
    this.region = Region.jp,
    Map<int, SvtStatus>? servants,
    Map<int, int>? dupServantMapping,
    List<UserPlan>? plans,
    this.sameEventPlan = true,
    int curSvtPlanNo = 0,
    Map<int, int>? items,
    Map<int, CraftStatus>? craftEssences,
    Map<int, CmdCodeStatus>? cmdCodes,
    Map<int, int>? mysticCodes,
    Set<String>? summons,
    Set<int>? myRoomMusic,
    Map<int, ClassBoardPlan>? classBoards,
    FreeLPParams? freeLPParams,
    Map<String, Map<int, int>>? luckyBagSvtScores,
    SaintQuartzPlan? saintQuartzPlan,
    BattleSimUserData? battleSim,
    this.lastImportId,
  }) : id = id ?? const Uuid().v4(),
       servants = servants ?? {},
       dupServantMapping = dupServantMapping ?? {},
       plans = List.generate(kSvtPlanMaxNum, (index) => plans?.getOrNull(index) ?? UserPlan()),
       _curSvtPlanNo = curSvtPlanNo.clamp(0, kSvtPlanMaxNum - 1),
       items = items ?? {},
       craftEssences = craftEssences ?? {},
       cmdCodes = cmdCodes ?? {},
       mysticCodes = mysticCodes ?? {},
       summons = summons ?? {},
       myRoomMusic = myRoomMusic ?? {},
       classBoards = classBoards ?? {},
       freeLPParams = freeLPParams ?? FreeLPParams(),
       luckyBagSvtScores = luckyBagSvtScores ?? {},
       saintQuartzPlan = saintQuartzPlan ?? SaintQuartzPlan(),
       battleSim = battleSim ?? BattleSimUserData();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  UserPlan get curPlan_ => plans[curSvtPlanNo];
  Map<int, SvtPlan> get curSvtPlan => curPlan_.servants;
  UserPlan get _curEventPlan => plans[sameEventPlan ? 0 : curSvtPlanNo];

  void ensurePlanLarger() {
    curSvtPlan.forEach((key, plan) {
      plan.validate(servants[key]?.cur, db.gameData.servantsWithDup[key]);
    });
  }

  SvtPlan svtPlanOf(int no) => curSvtPlan.putIfAbsent(no, () => SvtPlan())..validate();

  SvtStatus svtStatusOf(int no) {
    final status = servants.putIfAbsent(no, () => SvtStatus())..cur.validate();
    return status;
  }

  CraftStatus ceStatusOf(int no) => craftEssences.putIfAbsent(no, () => CraftStatus());
  CmdCodeStatus ccStatusOf(int no) => cmdCodes.putIfAbsent(no, () => CmdCodeStatus());

  LimitEventPlan limitEventPlanOf(int eventId) =>
      _curEventPlan.limitEvents.putIfAbsent(eventId, () => LimitEventPlan());

  MainStoryPlan mainStoryOf(int warId) => _curEventPlan.mainStories.putIfAbsent(warId, () => MainStoryPlan());

  ExchangeTicketPlan ticketOf(int key) => _curEventPlan.tickets.putIfAbsent(key, () => ExchangeTicketPlan());

  ClassBoardPlan classBoardStatusOf(int boardId) => classBoards.putIfAbsent(boardId, () => ClassBoardPlan());

  LockPlan classBoardUnlockedOf(int boardId, int squareId) => LockPlan.from(
    classBoardStatusOf(boardId).unlockedSquares.contains(squareId),
    curPlan_.classBoardPlan(boardId).unlockedSquares.contains(squareId),
  );
  LockPlan classBoardEnhancedOf(int boardId, int squareId) => LockPlan.from(
    classBoardStatusOf(boardId).enhancedSquares.contains(squareId),
    curPlan_.classBoardPlan(boardId).enhancedSquares.contains(squareId),
  );

  void validate() {
    if (plans.isEmpty) {
      plans.add(UserPlan());
    }
    curSvtPlanNo = curSvtPlanNo.clamp2(0, plans.length - 1);
    for (final (collectionNo, status) in servants.items) {
      status.validate(db.gameData.servantsWithDup[collectionNo]);
    }
    for (final key in servants.keys) {
      servants[key]!.validate(db.gameData.servantsWithDup[key]);
    }
    for (final group in plans) {
      for (final plan in group.servants.entries) {
        plan.value.validate(servants[plan.key]?.cur, db.gameData.servantsWithDup[plan.key]);
      }
    }
    craftEssences.forEach((key, value) {
      value.validate(db.gameData.craftEssences[key]?.lvMax);
    });
    cmdCodes.forEach((key, value) {
      value.validate();
    });
  }

  String getFriendlyPlanName([int? planNo]) {
    planNo ??= curSvtPlanNo;
    String name = '${S.current.plan} ${planNo + 1}';
    String? customName = plans.getOrNull(planNo)?.title;
    if (customName != null && customName.isNotEmpty) name += ' - $customName';
    return name;
  }

  void sort() {
    servants = sortDict(servants);
    classBoards = sortDict(classBoards);
    for (final board in classBoards.values) {
      board.enhancedSquares = sortSet(board.enhancedSquares);
      board.unlockedSquares = sortSet(board.unlockedSquares);
    }
    for (final plan in plans) {
      plan.sort();
    }
    items = sortDict(items);
    craftEssences = sortDict(craftEssences);
    mysticCodes = sortDict(mysticCodes);
    cmdCodes = sortDict(cmdCodes);
    summons = (summons.toList()..sort()).toSet();
    myRoomMusic = (myRoomMusic.toList()..sort()).toSet();
    classBoards = sortDict(classBoards);
    luckyBagSvtScores = sortDict(luckyBagSvtScores);
    freeLPParams.planItemCounts = sortDict(freeLPParams.planItemCounts);
    freeLPParams.planItemWeights = sortDict(freeLPParams.planItemWeights);
    freeLPParams.blacklist = (freeLPParams.blacklist.toList()..sort()).toSet();
    freeLPParams.extraCols.sort();
  }

  int? addDupServant(Servant svt) {
    // collectionNo: 1-4
    // id: 6-7
    // dup: 8: 1xxxxxii
    int minId = 10000000 + svt.originalCollectionNo * 100 + 1;
    int maxId = minId + 98;
    for (int id = minId; id < maxId; id++) {
      if (dupServantMapping.containsKey(id)) continue;
      dupServantMapping[id] = svt.originalCollectionNo;
      return id;
    }
    return null;
  }
}

@JsonSerializable()
class SvtStatus {
  SvtPlan cur;
  int priority; //1-5

  /// current bond, 5.5=5
  int bond;
  List<int?> equipCmdCodes;
  // 0~25 -> 0~500
  List<int>? cmdCardStrengthen;
  bool grandSvt;

  SvtStatus({
    SvtPlan? cur,
    this.priority = 1,
    this.bond = 0,
    List<int?>? equipCmdCodes,
    List<int>? cmdCardStrengthen,
    this.grandSvt = false,
  }) : cur = cur ?? SvtPlan(),
       equipCmdCodes = List.generate(5, (index) => equipCmdCodes?.getOrNull(index)),
       cmdCardStrengthen = cmdCardStrengthen == null
           ? null
           : List.generate(5, (index) => cmdCardStrengthen.getOrNull(index) ?? 0);

  factory SvtStatus.fromJson(Map<String, dynamic> json) => _$SvtStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SvtStatusToJson(this);

  void validate([Servant? svt]) {
    bond = bond.clamp2(0, 15);
    priority = priority.clamp2(1, 5);
    cur.bondLimit = cur.bondLimit.clamp2(bond, 15);
    cur.validate(null, svt);
    // equipCmdCodes
    if (cmdCardStrengthen != null) {
      for (int index = 0; index < cmdCardStrengthen!.length; index++) {
        cmdCardStrengthen![index] = cmdCardStrengthen![index].clamp(0, 25);
      }
    }
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get favorite => cur.favorite;

  set favorite(bool v) => cur.favorite = v;

  int? getCmdCode(int index) {
    return equipCmdCodes.getOrNull(index);
  }

  void setCmdCode(int index, int? collectionNo) {
    if (equipCmdCodes.length < 5) equipCmdCodes.length = 5;
    if (index >= 0 && index < 5) {
      equipCmdCodes[index] = collectionNo;
    }
  }

  void setCmdCard(int index, int strengthen) {
    if (strengthen < 0 || strengthen > 25) return;
    cmdCardStrengthen ??= List.generate(5, (index) => 0);
    cmdCardStrengthen![index] = strengthen;
  }
}

@JsonSerializable()
class UserPlan {
  String title;
  Map<int, SvtPlan> servants;
  Map<int, LimitEventPlan> limitEvents;
  Map<int, MainStoryPlan> mainStories;
  Map<int, ExchangeTicketPlan> tickets;
  Map<int, ClassBoardPlan> classBoards;
  // misc
  Map<int, bool> recipes;

  UserPlan({
    this.title = '',
    Map<int, SvtPlan>? servants,
    Map<int, LimitEventPlan>? limitEvents,
    Map<int, MainStoryPlan>? mainStories,
    Map<int, ExchangeTicketPlan>? tickets,
    Map<int, ClassBoardPlan>? classBoards,
    Map<int, bool>? recipes,
  }) : servants = servants ?? {},
       limitEvents = limitEvents ?? {},
       mainStories = mainStories ?? {},
       tickets = tickets ?? {},
       classBoards = classBoards ?? {},
       recipes = recipes ?? {};

  factory UserPlan.fromJson(Map<String, dynamic> json) => _$UserPlanFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlanToJson(this);

  ClassBoardPlan classBoardPlan(int boardId) => classBoards.putIfAbsent(boardId, () => ClassBoardPlan());

  void clear() {
    servants.clear();
    limitEvents.clear();
    mainStories.clear();
    tickets.clear();
    classBoards.clear();
  }

  void sort() {
    servants = sortDict(servants);
    limitEvents = sortDict(limitEvents);
    mainStories = sortDict(mainStories);
    tickets = sortDict(tickets);
    classBoards = sortDict(classBoards);
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

  // 0-50, ★4 fou-kun
  int fouHp;
  int fouAtk;
  // 0-20, ★3 fou-kun
  int fouHp3;
  int fouAtk3;

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
    this.fouHp3 = 20,
    this.fouAtk3 = 20,
    this.bondLimit = 10,
    int? npLv,
  }) : skills = List.generate(kActiveSkillNums.length, (index) => skills?.getOrNull(index) ?? 1, growable: false),
       costumes = costumes ?? {},
       appendSkills = List.generate(
         kAppendSkillNums.length,
         (index) => appendSkills?.getOrNull(index) ?? 0,
         growable: false,
       ),
       _npLv = npLv {
    validate();
  }

  factory SvtPlan.empty() => SvtPlan(fouHp3: 0, fouAtk3: 0);

  SvtPlan.max(Servant svt)
    : favorite = true,
      ascension = 4,
      skills = List.filled(kActiveSkillNums.length, 10),
      appendSkills = List.filled(kAppendSkillNums.length, 10),
      costumes = svt.costumeMaterials.map((key, value) => MapEntry(key, 1)),
      grail = _grailCostByRarity[svt.rarity] + 10,
      fouHp = 50,
      fouAtk = 50,
      fouHp3 = 20,
      fouAtk3 = 20,
      bondLimit = 15,
      _npLv = 5;
  static const _grailCostByRarity = [10, 10, 10, 9, 7, 5];

  factory SvtPlan.fromJson(Map<String, dynamic> json) => _$SvtPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SvtPlanToJson(this);

  List<int> getSkills(bool isActive) {
    return isActive ? skills : appendSkills;
  }

  void validate([SvtPlan? lower, Servant? svt]) {
    if (svt != null && svt.type == SvtType.enemyCollectionDetail) {
      favorite = false;
    }
    ascension = ascension.clamp2(lower?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = skills[i].clamp2(lower?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < appendSkills.length; i++) {
      appendSkills[i] = appendSkills[i].clamp2(lower?.appendSkills[i] ?? 0, 10);
    }
    if (svt != null) {
      costumes.removeWhere((key, value) => !svt.profile.costume.keys.contains(key));
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
    grail = grail.clamp2(lower?.grail ?? 0, _grailLvs == null ? 20 : Maths.max(_grailLvs));
    fouHp = fouHp.clamp2(lower?.fouHp ?? 0, 50);
    fouAtk = fouAtk.clamp2(lower?.fouAtk ?? 0, 50);
    fouHp3 = fouHp3.clamp2(lower?.fouHp3 ?? 0, 20);
    fouAtk3 = fouAtk3.clamp2(lower?.fouAtk3 ?? 0, 20);
    bondLimit = bondLimit.clamp2(lower?.bondLimit ?? 10, 15);

    if (_npLv == null && svt != null) {
      if (svt.rarity <= 3 || svt.obtains.contains(SvtObtain.eventReward)) {
        _npLv = 5;
      }
    }
    if (lower != null && lower._npLv != null) {
      _npLv = npLv.clamp2(lower.npLv, 5);
    }
  }

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, skills.length, 1);
    costumes.clear();
    appendSkills.fillRange(0, appendSkills.length, 0);
    grail = 0;
    fouHp = fouAtk = 0;
    fouHp3 = fouAtk3 = 20;
    bondLimit = 10;
  }

  void setMax({int skill = 10, bool isActive = true}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    if (isActive) {
      skills.fillRange(0, skills.length, skill);
    } else {
      appendSkills.fillRange(0, appendSkills.length, skill);
    }
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
  Map<int, int> shopBuyCount;
  bool point;
  bool mission;
  bool tower;
  Map<int, int> lotteries;
  Map<int, Map<int, int>> treasureBoxItems;
  bool fixedDrop;
  bool questReward;
  bool warBoard;
  Map<int, bool> extraFixedItems;
  Map<int, Map<int, int>> extraItems;

  Map<int, int> customItems;

  LimitEventPlan({
    this.enabled = false,
    this.rerunGrails = 0,
    this.shop = true,
    Map<int, int>? shopBuyCount,
    this.point = true,
    this.mission = true,
    this.tower = true,
    Map<int, int>? lotteries,
    Map<int, Map<int, int>>? treasureBoxItems,
    this.fixedDrop = true,
    this.questReward = true,
    this.warBoard = true,
    Map<int, bool>? extraFixedItems,
    Map<int, Map<int, int>>? extraItems,
    Map<int, int>? customItems,
  }) : shopBuyCount = shopBuyCount ?? {},
       lotteries = lotteries ?? {},
       treasureBoxItems = treasureBoxItems ?? {},
       extraFixedItems = extraFixedItems ?? {},
       extraItems = extraItems ?? {},
       customItems = customItems ?? {};

  factory LimitEventPlan.fromJson(Map<String, dynamic> json) => _$LimitEventPlanFromJson(json);

  Map<String, dynamic> toJson() => _$LimitEventPlanToJson(this);

  void reset() {
    enabled = false;
    shop = true;
    shopBuyCount.clear();
    point = true;
    mission = true;
    tower = true;
    lotteries.clear();
    treasureBoxItems.clear();
    fixedDrop = true;
    questReward = true;
    extraItems.clear();
    customItems.clear();
  }

  void planAll() {
    enabled = true;
    shop = true;
    shopBuyCount.clear();
    point = true;
    mission = true;
    tower = true;
    // lotteries.clear();
    // treasureBoxItems.clear();
    // digging.clear();
    fixedDrop = true;
    questReward = true;
    // extraItems.clear();
  }

  LimitEventPlan copy() {
    return LimitEventPlan(
      enabled: enabled,
      rerunGrails: rerunGrails,
      shop: shop,
      shopBuyCount: Map.of(shopBuyCount),
      point: point,
      mission: mission,
      tower: tower,
      lotteries: Map.of(lotteries),
      treasureBoxItems: treasureBoxItems.map((key, value) => MapEntry(key, Map.of(value))),
      fixedDrop: fixedDrop,
      questReward: questReward,
      extraFixedItems: Map.of(extraFixedItems),
      extraItems: extraItems.map((key, value) => MapEntry(key, Map.of(value))),
      customItems: Map.of(customItems),
    );
  }
}

@JsonSerializable()
class MainStoryPlan {
  bool fixedDrop;
  bool questReward;

  MainStoryPlan({this.fixedDrop = false, this.questReward = false});

  factory MainStoryPlan.fromJson(Map<String, dynamic> json) => _$MainStoryPlanFromJson(json);

  Map<String, dynamic> toJson() => _$MainStoryPlanToJson(this);

  bool get enabled => fixedDrop || questReward;
}

@JsonSerializable()
class ExchangeTicketPlan {
  @protected
  List<int> counts;

  int get length => counts.length;
  int operator [](int index) => counts.getOrNull(index) ?? 0;
  void operator []=(int index, int value) {
    if (index >= counts.length) counts.fixLength(index + 1, () => 0);
    counts[index] = value;
  }

  Iterable<int> getRange(int start, int end) => counts.getRange(start, end);

  ExchangeTicketPlan({List<int>? counts})
    : counts = List.generate(max(3, counts?.length ?? 0), (index) => counts?.getOrNull(index) ?? 0);

  factory ExchangeTicketPlan.fromJson(Map<String, dynamic> json) => _$ExchangeTicketPlanFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeTicketPlanToJson(this);

  bool get enabled => counts.any((e) => e > 0);

  void clear() {
    counts.fillRange(0, length, 0);
  }
}

@JsonSerializable()
class CraftStatus {
  static const notMet = 0;
  static const met = 1;
  static const owned = 2;

  static const List<int> values = [notMet, met, owned];

  static String shownText(int status) {
    assert(values.contains(status), status);
    return [S.current.card_status_not_met, S.current.card_status_met, S.current.card_status_owned].getOrNull(status) ??
        status.toString();
  }

  String get statusText => shownText(status);

  int status;
  int lv;
  int limitCount;

  CraftStatus({this.status = CraftStatus.notMet, this.lv = 1, this.limitCount = 0});

  bool get favorite => status == CraftStatus.owned;

  void validate(int? maxLv) {
    status = status.clamp(0, 2);
    limitCount = limitCount.clamp(0, 4);
    if (maxLv != null && maxLv > 1) {
      lv = lv.clamp(1, maxLv);
    }
  }

  factory CraftStatus.fromJson(Map<String, dynamic> json) => _$CraftStatusFromJson(json);

  Map<String, dynamic> toJson() => _$CraftStatusToJson(this);
}

@JsonSerializable()
class CmdCodeStatus {
  static const notMet = 0;
  static const met = 1;
  static const owned = 2;

  static const List<int> values = [notMet, met, owned];

  static String shownText(int status) => CraftStatus.shownText(status);

  String get statusText => shownText(status);

  int status;
  int count;

  CmdCodeStatus({this.status = CmdCodeStatus.notMet, this.count = 0});

  void validate() {
    status = status.clamp(0, 2);
    count = count.clamp2(0);
  }

  factory CmdCodeStatus.fromJson(Map<String, dynamic> json) => _$CmdCodeStatusFromJson(json);

  Map<String, dynamic> toJson() => _$CmdCodeStatusToJson(this);
}

@JsonSerializable(converters: [LockPlanConverter()])
class ClassBoardPlan {
  Set<int> unlockedSquares;
  Set<int> enhancedSquares;

  ClassBoardPlan({Set<int>? unlockedSquares, Set<int>? enhancedSquares})
    : unlockedSquares = unlockedSquares ?? {},
      enhancedSquares = enhancedSquares ?? {};

  ClassBoardPlan.full(ClassBoard board)
    : unlockedSquares = {
        for (final square in board.squares)
          if (square.lock != null) square.id,
      },
      enhancedSquares = {
        for (final square in board.squares)
          if (square.targetSkill != null || square.targetCommandSpell != null) square.id,
      };

  void validate() {
    //
  }

  factory ClassBoardPlan.fromJson(dynamic json) => _$ClassBoardPlanFromJson(Map<String, dynamic>.from(json));

  Map<String, dynamic> toJson() => _$ClassBoardPlanToJson(this);
}

@JsonEnum(alwaysCreate: true, valueField: "value")
enum LockPlan {
  none(0),
  planned(1),
  full(2);

  const LockPlan(this.value);
  final int value;

  String get dispPlan {
    switch (this) {
      case LockPlan.none:
        return '0';
      case LockPlan.planned:
        return '0→1';
      case LockPlan.full:
        return '1';
    }
  }

  bool get current => this == LockPlan.full;
  bool get target => this != LockPlan.none;

  LockPlan updateCurrent(bool v) {
    if (v) return LockPlan.full;
    if (this == LockPlan.full) return LockPlan.planned;
    return this;
  }

  static LockPlan from(bool cur, bool target) {
    if (cur) return full;
    if (target) return planned;
    return none;
  }
}

class LockPlanConverter extends JsonConverter<LockPlan, int> {
  const LockPlanConverter();
  @override
  LockPlan fromJson(int value) => decodeEnum(_$LockPlanEnumMap, value, LockPlan.none);
  @override
  int toJson(LockPlan obj) => _$LockPlanEnumMap[obj] ?? obj.value;
}
