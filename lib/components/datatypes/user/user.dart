// userdata: plan etc.
part of datatypes;

@JsonSerializable(checked: true)
class User {
  String? key;
  String name;

  GameServer? _server;

  GameServer get server {
    if (_server == null) {
      Language lang =
          Language.getLanguage(db.appSetting.language) ?? Language.current;
      switch (lang) {
        case Language.eng:
          _server = GameServer.en;
          break;
        case Language.jpn:
          _server = GameServer.jp;
          break;
        case Language.chs:
          _server = GameServer.cn;
          break;
        default:
          _server = GameServer.cn;
          break;
      }
    }
    return _server!;
  }

  set server(GameServer value) => _server = value;

  @JsonKey(toJson: _servantsToJson)
  Map<int, ServantStatus> servants;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  @JsonKey(toJson: _servantPlansToJson)
  List<Map<int, ServantPlan>> servantPlans;
  int curSvtPlanNo;
  Map<int, String> svtPlanNames;

  /// user own items, key: item name, value: item count
  Map<String, int> items;
  EventPlans events;

  /// ce id: status. status=0,1,2
  @JsonKey(toJson: _craftsPlanToJson)
  Map<int, int> crafts;
  Map<String, int> mysticCodes;
  Set<String> plannedSummons;
  SaintQuartzPlan saintQuartzPlan;
  bool isMasterGirl;
  bool use6thDropRate;

  /// milliseconds of event's startTimeJP
  int msProgress;

  // <svt_no_for_user, origin_svt_user>
  Map<int, int> duplicatedServants;

  // glpk
  GLPKParams glpkParams;

  Map<String, Map<int, int>> luckyBagSvtScores;
  List<SupportSetup> supportSetups;

  User({
    this.key,
    String? name,
    GameServer? server,
    Map<int, ServantStatus>? servants,
    int? curSvtPlanNo,
    Map<int, String>? svtPlanNames,
    List<Map<int, ServantPlan>>? servantPlans,
    Map<String, int>? items,
    EventPlans? events,
    Map<int, int>? crafts,
    Map<String, int>? mysticCodes,
    Set<String>? plannedSummons,
    SaintQuartzPlan? saintQuartzPlan,
    bool? isMasterGirl,
    bool? use6thDropRate,
    int? msProgress,
    Map<int, int>? duplicatedServants,
    GLPKParams? glpkParams,
    Map<String, Map<int, int>>? luckyBagSvtScores,
    List<SupportSetup>? supportSetups,
  })  : name = name?.isNotEmpty == true ? name! : 'default',
        _server = server,
        servants = servants ?? {},
        curSvtPlanNo = curSvtPlanNo ?? 0,
        svtPlanNames = svtPlanNames ?? {},
        servantPlans = servantPlans ?? [],
        items = items ?? {},
        events = events ?? EventPlans(),
        crafts = crafts ?? {},
        mysticCodes = mysticCodes ?? {},
        plannedSummons = plannedSummons ?? <String>{},
        saintQuartzPlan = saintQuartzPlan ?? SaintQuartzPlan(),
        isMasterGirl = isMasterGirl ?? true,
        use6thDropRate = use6thDropRate ?? true,
        msProgress = msProgress ?? -1,
        duplicatedServants = duplicatedServants ?? {},
        glpkParams = glpkParams ?? GLPKParams(),
        luckyBagSvtScores = luckyBagSvtScores ?? {},
        supportSetups = supportSetups ?? [] {
    this.curSvtPlanNo =
        fixValidRange(this.curSvtPlanNo, 0, this.servantPlans.length);
    fillListValue(this.servantPlans, max(5, this.servantPlans.length),
        (_) => <int, ServantPlan>{});
  }

  Map<int, ServantPlan> get curSvtPlan {
    curSvtPlanNo = fixValidRange(curSvtPlanNo, 0, servantPlans.length - 1);
    return servantPlans[curSvtPlanNo];
  }

  String getFriendlyPlanName([int? planNo]) {
    planNo ??= curSvtPlanNo;
    String name = '${S.current.plan} ${planNo + 1}';
    String? customName = svtPlanNames[planNo];
    if (customName != null && customName.isNotEmpty) name += ' - $customName';
    return name;
  }

  Servant addDuplicatedForServant(Servant svt, [int? newNo]) {
    for (int no = svt.originNo * 1000 + 1;
        no < svt.originNo * 1000 + 999;
        no++) {
      if (!db.gameData.servantsWithUser.containsKey(no)) {
        duplicatedServants[no] = svt.originNo;
        final newSvt = svt.duplicate(no);
        db.gameData.servantsWithUser[no] = newSvt;
        return newSvt;
        // return
      }
    }
    return svt;
  }

  void removeDuplicatedServant(int svtNo) {
    assert(db.gameData.servants[svtNo] == null, '$svtNo is not duplicated');
    if (db.gameData.servants[svtNo] != null) return;

    duplicatedServants.remove(svtNo);
    servants.remove(svtNo);
    servantPlans.forEach((plans) {
      plans.remove(svtNo);
    });
    db.gameData.updateUserDuplicatedServants();
  }

  void ensurePlanLarger() {
    curSvtPlan.forEach((key, plan) {
      plan.validate(servants[key]?.curVal);
    });
  }

  ServantPlan svtPlanOf(int no) =>
      curSvtPlan.putIfAbsent(no, () => ServantPlan())..validate();

  ServantStatus svtStatusOf(int no) {
    final status = servants.putIfAbsent(no, () => ServantStatus())
      ..curVal.validate();
    final svt = db.gameData.servantsWithUser[no];

    if (svt != null &&
        status.isEmpty &&
        (svt.info.rarity <= 3 || svt.info.obtain == '活动')) {
      status.npLv = 5;
    }
    return status;
  }

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // can be sorted before saving
  static Map<String, ServantStatus> _servantsToJson(
      Map<int, ServantStatus> data) {
    return data.map((k, e) => MapEntry(k.toString(), e))
      ..removeWhere((key, value) => value.isEmpty);
  }

  static List<Map<String, ServantPlan>> _servantPlansToJson(
      List<Map<int, ServantPlan>> data) {
    return data
        .map((e) => e.map((k, e) => MapEntry(k.toString(), e))
          ..removeWhere((key, value) => value.isEmpty))
        .toList();
  }

  static Map<String, int> _craftsPlanToJson(Map<int, int> data) {
    return data.map((k, e) => MapEntry(k.toString(), e))
      ..removeWhere((key, value) => value == 0);
  }
}

@JsonSerializable(checked: true)
class ServantStatus {
  bool get favorite => curVal.favorite;

  set favorite(bool v) => curVal.favorite = v;

  ServantPlan curVal;
  int coin;
  int npLv;

  /// priority 1-5
  int priority;

  List<int?> equipCmdCodes;

  /// null-not set, >=0 index, sorted from non-enhanced to enhanced
  List<int?> skillIndex; //length=3
  /// default 0, origin order in wiki
  int npIndex;

  ServantStatus({
    bool? favorite,
    ServantPlan? curVal,
    int? coin,
    int? npLv,
    int? priority,
    List<int?>? equipCmdCodes,
    List<int?>? skillIndex,
    int? npIndex,
  })  : curVal = curVal ?? ServantPlan(),
        coin = coin ?? 0,
        npLv = npLv ?? 1,
        priority = priority ?? 1,
        equipCmdCodes = equipCmdCodes ?? List.generate(5, (index) => null),
        skillIndex = List.generate(3, (index) => skillIndex?.getOrNull(index)),
        npIndex = npIndex ?? 0 {
    validate();
  }

  void validate([Servant? svt]) {
    curVal.validate();
    npLv = fixValidRange(npLv, 1, 5);
    coin = fixValidRange(coin, 0);
    npIndex = fixValidRange(
        npIndex, 0, svt == null ? null : svt.lNoblePhantasm.length - 1);
    int skillNum = svt?.lActiveSkills.length ?? 3;
    skillIndex.length = skillNum;
    for (int i = 0; i < skillNum; i++) {
      if (skillIndex[i] != null) {
        if (svt != null &&
            svt.lActiveSkills.getOrNull(i)?.skills.getOrNull(skillIndex[i]!) ==
                null) {
          skillIndex[i] = null;
        }
      }
    }
    priority = fixValidRange(priority, 1, 5);
  }

  void reset() {
    curVal.reset();
    coin = 0;
    npLv = 1;
    priority = 1;
    resetEnhancement();
  }

  void resetEnhancement() {
    skillIndex.fillRange(0, skillIndex.length, null);
    npIndex = 0;
  }

  bool get isEmpty {
    return curVal.isEmpty &&
        coin == 0 &&
        (npLv == 1 || npLv == 5) &&
        priority == 1 &&
        equipCmdCodes.whereType<int>().isEmpty;
  }

  factory ServantStatus.fromJson(Map<String, dynamic> data) =>
      _$ServantStatusFromJson(data);

  Map<String, dynamic> toJson() => _$ServantStatusToJson(this);
}

@JsonSerializable(checked: true)
class ServantPlan {
  /// TODO: how to remove it and use [ServantStatus.favorite] instead?
  bool favorite;
  int ascension;
  List<int> skills; // length 3
  List<int> appendSkills; // length 3
  List<int> dress;
  int grail;

  /// ★3 0-100=-20->0
  /// ★4 1000-2000=0->50, 流星のフォウくん/日輪のフォウくん
  int fouHp;
  int fouAtk;

  /// max limit for bond, should from 10 to 15, chaldea lantern cost
  int bondLimit;

  ServantPlan({
    bool? favorite,
    int? ascension,
    List<int>? skills,
    List<int>? dress,
    List<int>? appendSkills,
    int? grail,
    int? fouHp,
    int? fouAtk,
    int? bondLimit,
  })  : favorite = favorite ?? false,
        ascension = ascension ?? 0,
        skills = List.generate(3, (index) => skills?.getOrNull(index) ?? 1),
        dress = List.generate(
            dress?.length ?? 0, (index) => dress?.getOrNull(index) ?? 0),
        appendSkills =
            List.generate(3, (index) => appendSkills?.getOrNull(index) ?? 0),
        grail = grail ?? 0,
        fouHp = fouHp ?? 0,
        fouAtk = fouAtk ?? 0,
        bondLimit = bondLimit ?? 5 {
    validate();
  }

  int get shownFouHp => Item.fouValToShown(fouHp);

  int get shownFouAtk => Item.fouValToShown(fouAtk);

  int get lanternCost => max(0, bondLimit - 10);

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, 3, 1);
    dress.fillRange(0, dress.length, 0);
    appendSkills.fillRange(0, 3, 0);
    grail = 0;
    fouHp = fouAtk = -20;
    bondLimit = 0;
  }

  bool get isEmpty {
    return favorite == false &&
        ascension == 0 &&
        skills.every((e) => e == 1) &&
        dress.every((e) => e == 0) &&
        appendSkills.every((e) => e == 0) &&
        grail == 0 &&
        fouHp == -20 &&
        fouAtk == -20 &&
        bondLimit == 0;
  }

  void setMax({int skill = 10}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    skills.fillRange(0, 3, skill);
    dress.fillRange(0, dress.length, 1);
    // appendSkills.fillRange(0, 3, skill);
    // grail = grail;
    // fouHp, fouAtk
  }

  void fixDressLength(int length, [int fill = 0]) {
    fillListValue(dress, length, (_) => fill);
  }

  void validate([ServantPlan? lowerPlan, int? rarity]) {
    lowerPlan?.validate(null, rarity);
    ascension = fixValidRange(ascension, lowerPlan?.ascension ?? 0, 4);
    for (int i = 0; i < skills.length; i++) {
      skills[i] = fixValidRange(skills[i], lowerPlan?.skills[i] ?? 1, 10);
    }
    for (int i = 0; i < appendSkills.length; i++) {
      appendSkills[i] =
          fixValidRange(appendSkills[i], lowerPlan?.appendSkills[i] ?? 0, 10);
    }
    for (int i = 0; i < dress.length; i++) {
      dress[i] = fixValidRange(dress[i], lowerPlan?.dress.getOrNull(i) ?? 0, 1);
    }
    // check grail max limit when used
    grail = fixValidRange(grail, lowerPlan?.grail ?? 0,
        rarity == null ? null : Grail.maxGrailCount(rarity));
    fouHp = fixValidRange(fouHp, lowerPlan?.fouHp ?? -20, 50);
    fouAtk = fixValidRange(fouAtk, lowerPlan?.fouAtk ?? -20, 50);
    bondLimit = fixValidRange(bondLimit, lowerPlan?.bondLimit ?? 5, 15);
  }

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data)..validate();

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan copyWith({
    bool? favorite,
    int? ascension,
    List<int>? skills,
    List<int>? dress,
    List<int>? appendSkills,
    int? grail,
    int? fouHp,
    int? fouAtk,
    int? bondLimit,
  }) {
    return ServantPlan(
      favorite: favorite ?? this.favorite,
      ascension: ascension ?? this.ascension,
      skills: skills ?? this.skills,
      dress: dress ?? this.dress,
      appendSkills: appendSkills ?? this.appendSkills,
      grail: grail ?? this.grail,
      fouHp: fouHp ?? this.fouHp,
      fouAtk: fouAtk ?? this.fouAtk,
      bondLimit: bondLimit ?? this.bondLimit,
    );
  }

  void copyFrom(ServantPlan other) {
    favorite = other.favorite;
    ascension = other.ascension;
    skills = List.of(other.skills);
    dress = List.of(other.dress);
    appendSkills = List.of(other.appendSkills);
    grail = other.grail;
    fouHp = other.fouHp;
    fouAtk = other.fouAtk;
    bondLimit = other.bondLimit;
  }

  static ServantPlan from(ServantPlan other) => ServantPlan()..copyFrom(other);
}

@JsonSerializable(checked: true)
class EventPlans {
  Map<String, LimitEventPlan> limitEvents;

  Map<String, MainRecordPlan> mainRecords;

  /// key: monthJp
  Map<String, ExchangeTicketPlan> exchangeTickets;

  Map<String, CampaignPlan> campaigns;

  EventPlans({
    Map<String, LimitEventPlan>? limitEvents,
    Map<String, MainRecordPlan>? mainRecords,
    Map<String, ExchangeTicketPlan>? exchangeTickets,
    Map<String, CampaignPlan>? campaigns,
  })  : limitEvents = limitEvents ?? {},
        mainRecords = mainRecords ?? {},
        exchangeTickets = exchangeTickets ?? {},
        campaigns = campaigns ?? {};

  LimitEventPlan limitEventOf(String indexKey) =>
      limitEvents.putIfAbsent(indexKey, () => LimitEventPlan());

  MainRecordPlan mainRecordOf(String indexKey) =>
      mainRecords.putIfAbsent(indexKey, () => MainRecordPlan());

  ExchangeTicketPlan exchangeTicketOf(String indexKey) =>
      exchangeTickets.putIfAbsent(indexKey, () => ExchangeTicketPlan());

  CampaignPlan campaignEventPlanOf(String indexKey) =>
      campaigns.putIfAbsent(indexKey, () => CampaignPlan());

  factory EventPlans.fromJson(Map<String, dynamic> data) =>
      _$EventPlansFromJson(data);

  Map<String, dynamic> toJson() {
    return _$EventPlansToJson(EventPlans(
      limitEvents: Map.of(limitEvents)
        ..removeWhere((key, value) => value.isEmpty),
      mainRecords: Map.of(mainRecords)
        ..removeWhere((key, value) => !value.enabled),
      exchangeTickets: Map.of(exchangeTickets)
        ..removeWhere((key, value) => !value.enabled),
      campaigns: Map.of(campaigns)..removeWhere((key, value) => !value.enabled),
    ));
  }
}

@JsonSerializable(checked: true)
class LimitEventPlan {
  bool enabled;
  bool rerun;
  int lottery;
  Map<String, int> extra;
  Map<String, int> extra2;

  LimitEventPlan({
    bool? enabled,
    bool? rerun,
    int? lottery,
    Map<String, int>? extra,
    Map<String, int>? extra2,
  })  : enabled = enabled ?? false,
        rerun = rerun ?? true,
        lottery = lottery ?? 0,
        extra = extra ?? {},
        extra2 = extra2 ?? {};

  bool get isEmpty {
    return !enabled &&
        rerun &&
        lottery == 0 &&
        (extra.isEmpty || extra.values.every((e) => e == 0));
  }

  factory LimitEventPlan.fromJson(Map<String, dynamic> data) =>
      _$LimitEventPlanFromJson(data);

  Map<String, dynamic> toJson() =>
      _$LimitEventPlanToJson(this)..remove('enable');
}

@JsonSerializable(checked: true)
class MainRecordPlan {
  bool drop;
  bool reward;

  bool get enabled => drop || reward;

  MainRecordPlan({
    bool? drop,
    bool? reward,
  })  : drop = drop ?? false,
        reward = reward ?? false;

  factory MainRecordPlan.fromJson(Map<String, dynamic> data) =>
      _$MainRecordPlanFromJson(data);

  Map<String, dynamic> toJson() => _$MainRecordPlanToJson(this);
}

@JsonSerializable(checked: true)
class ExchangeTicketPlan {
  int item1;
  int item2;
  int item3;

  bool get enabled => items.any((e) => e > 0);

  /// cannot write value to [items], use [setAt] instead
  List<int> get items => List.unmodifiable([item1, item2, item3]);

  void setAt(int index, int value) {
    if (index == 0) {
      item1 = value;
    } else if (index == 1) {
      item2 = value;
    } else if (index == 2) {
      item3 = value;
    }
  }

  ExchangeTicketPlan({
    int? item1,
    int? item2,
    int? item3,
  })  : item1 = item1 ?? 0,
        item2 = item2 ?? 0,
        item3 = item3 ?? 0;

  factory ExchangeTicketPlan.fromJson(Map<String, dynamic> data) =>
      _$ExchangeTicketPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ExchangeTicketPlanToJson(this);
}

@JsonSerializable(checked: true)
class CampaignPlan {
  bool enabled;
  bool rerun;

  CampaignPlan({
    bool? enabled,
    bool? rerun,
  })  : enabled = enabled ?? false,
        rerun = rerun ?? true;

  factory CampaignPlan.fromJson(Map<String, dynamic> data) =>
      _$CampaignPlanFromJson(data);

  Map<String, dynamic> toJson() => _$CampaignPlanToJson(this);
}

@JsonSerializable()
class SupportSetup {
  int index;
  int? svtNo;
  int? lv;
  String? imgPath;
  bool cached;
  double scale;
  double dx;
  double dy;
  bool showActiveSkill;
  bool showAppendSkill;
  static const List<String> allClasses = [
    'All',
    ...SvtFilterData.regularClassesData,
    'Extra',
  ];

  SupportSetup({
    this.index = 0,
    this.svtNo,
    this.lv,
    this.imgPath,
    this.cached = true,
    this.scale = 1,
    this.dx = 0,
    this.dy = 0,
    this.showActiveSkill = true,
    this.showAppendSkill = false,
  });

  @JsonKey(ignore: true)
  Offset get offset => Offset(dx, dy);

  set offset(Offset offset) {
    dx = offset.dx;
    dy = offset.dy;
  }

  Servant? get servant => db.gameData.servants[svtNo];

  ServantStatus? get status =>
      svtNo == null ? null : db.curUser.svtStatusOf(svtNo!);

  String? get clsName {
    index = fixValidRange(index, 0, allClasses.length);
    return servant?.stdClassName ?? allClasses[index];
  }

  int? get resolvedLv => lv ?? defaultLv();

  int? defaultLv() {
    if (servant == null) return null;
    final curVal = status!.curVal;
    if (curVal.grail > 0) {
      return Grail.grailToLvMax(servant!.rarity, curVal.grail);
    } else {
      return Grail.maxAscensionGrailLvs(
          rarity: servant!.rarity)[curVal.ascension + 1];
    }
  }

  void reset() {
    svtNo = null;
    lv = null;
    scale = 1;
    dx = dy = 0;
    imgPath = null;
    cached = true;
  }

  factory SupportSetup.fromJson(Map<String, dynamic> data) =>
      _$SupportSetupFromJson(data);

  Map<String, dynamic> toJson() => _$SupportSetupToJson(this);
}

enum GameServer {
  jp,
  cn,
  tw,
  en,
}

extension GameServerUtil on GameServer {
  String get localized {
    switch (this) {
      case GameServer.jp:
        return S.current.server_jp;
      case GameServer.cn:
        return S.current.server_cn;
      case GameServer.tw:
        return S.current.server_tw;
      case GameServer.en:
        return S.current.server_na;
    }
  }
}
