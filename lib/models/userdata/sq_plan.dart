part of 'userdata.dart';

@JsonSerializable(checked: true)
class SaintQuartzPlan {
  int curSQ;
  int curTicket;
  int curApple;

  // login
  DateTime startDate;
  DateTime endDate;
  int accLogin = 0;
  int continuousLogin = 1;

  // event, in days
  int eventDateDelta;

  // mission
  bool weeklyMission;
  Map<int, bool> extraMissions;
  bool minusPlannedBanner;

  @JsonKey(ignore: true)
  VoidCallback? onSolved;

  MasterMission? get extraMission => db.gameData.extraMasterMission[10001];

  SaintQuartzPlan({
    int? curSQ,
    int? curTicket,
    int? curApple,
    DateTime? startDate,
    DateTime? endDate,
    int? accLogin,
    int? continuousLogin,
    int? eventDateDelta,
    bool? weeklyMission,
    Map<int, bool>? missions,
    bool? minusPlannedBanner,
  })  : curSQ = curSQ ?? 0,
        curTicket = curTicket ?? 0,
        curApple = curApple ?? 0,
        startDate = startDate ?? DateUtils.dateOnly(DateTime.now()),
        endDate = endDate ?? DateUtils.dateOnly(DateTime.now()),
        accLogin = accLogin ?? 1,
        continuousLogin = continuousLogin ?? 1,
        eventDateDelta = eventDateDelta ?? 365,
        weeklyMission = weeklyMission ?? true,
        extraMissions = missions ?? {},
        minusPlannedBanner = minusPlannedBanner ?? true {
    validate();
  }

  void validate() {
    continuousLogin = continuousLogin.clamp2(1, 7);
    eventDateDelta = eventDateDelta.clamp2(0);
    if (!endDate.isAfter(startDate)) {
      endDate = DateUtils.addDaysToDate(startDate, 365);
    }
  }

  bool isInRange(int? jp) {
    if (jp == null) return false;
    final _date = DateUtils.dateOnly(
        DateUtils.addDaysToDate(jp.sec2date(), eventDateDelta));
    return !_date.isBefore(startDate) && !_date.isAfter(endDate);
  }

  factory SaintQuartzPlan.fromJson(Map<String, dynamic> data) =>
      _$SaintQuartzPlanFromJson(data);

  Map<String, dynamic> toJson() => _$SaintQuartzPlanToJson(this);

  @JsonKey(ignore: true)
  List<SQDayDetail> solution = [];

  List<SQDayDetail> solve() {
    print('solving SQ plan');
    validate();
    Map<String, SQDayDetail> dataMap = {};
    dataMap[startDate.toDateString()] = SQDayDetail(
      date: startDate,
      accLogin: accLogin,
      accSQ: curSQ,
      accTicket: curTicket,
      accApple: curApple.toDouble(),
    );
    for (int day = 1; day <= endDate.difference(startDate).inDays; day++) {
      final date = DateUtils.dateOnly(DateUtils.addDaysToDate(startDate, day));
      int sq = 0, ticket = 0;
      double apple = 0;
      // daily login: 2(1), 4(1), 6(2), 7(1 tickets), Mon.(21=3)
      // 50 days: +30
      // 1st of month: 5 tickets
      int _continuousLogin = (continuousLogin + day - 1) % 7 + 1;
      if (_continuousLogin == 2 || _continuousLogin == 4) {
        sq += 1;
      } else if (_continuousLogin == 6) {
        sq += 2;
      } else if (_continuousLogin == 7) {
        ticket += 1;
      }
      if (date.weekday == 1 && weeklyMission) {
        sq += 3;
      }
      int _accLogin = accLogin + day;
      if (_accLogin % 50 == 0) {
        sq += 30;
      }
      // shop ticket
      if (date.day == 1) {
        ticket += 5;
      }
      dataMap[date.toDateString()] = SQDayDetail(
        date: date,
        accLogin: _accLogin,
        continuousLogin: _continuousLogin,
        addSQ: sq,
        addTicket: ticket,
        addApple: apple,
      );
    }
    // check event
    void _checkEvent({
      Event? event,
      DateTime? startDate,
      Map<int, int>? items,
      String? name,
    }) {
      if (event != null) {
        startDate ??= event.startedAt.sec2date();
        items ??= event.statItemFixed;
        name ??= event.shownName;
      }
      items ??= {};
      if (startDate == null) return;

      startDate = DateUtils.dateOnly(
          DateUtils.addDaysToDate(startDate, eventDateDelta));
      final detail = dataMap[startDate.toDateString()];
      if (detail == null) return;

      detail.addSQ += items[Items.stoneId] ?? 0;
      detail.addTicket += items[Items.summonTicketId] ?? 0;
      detail.addApple += (items[Items.goldAppleId] ?? 0) +
          (items[Items.silverAppleId] ?? 0) / 2 +
          (items[Items.bronzeAppleId] ?? 0) / 14.2;
      if (event != null) detail.events.add(event);
    }

    db.gameData.events.values.forEach((e) => _checkEvent(event: e));
    db.gameData.mainStories.values.forEach((e) => _checkEvent(
          name: e.lLongName.l,
          items: {...e.itemDrop, ...e.itemReward},
          // startDate: e.extra.
        ));
    // check master mission
    final Map<int, int> extraMissionItems = {};
    if (extraMission != null) {
      for (final mission in extraMission!.missions) {
        if (extraMissions[mission.id] != true) continue;
        for (final gift in mission.gifts) {
          extraMissionItems.addNum(gift.objectId, gift.num);
        }
      }
    }
    _checkEvent(
      startDate: DateUtils.addDaysToDate(endDate, -eventDateDelta),
      items: extraMissionItems,
      name: 'Extra Mission',
    );

    db.gameData.wiki.summons.values.forEach((summon) {
      DateTime? startDate = summon.startTime.jp?.sec2date();
      if (startDate == null) return;
      startDate = DateUtils.dateOnly(
          DateUtils.addDaysToDate(startDate, eventDateDelta));
      final detail = dataMap[startDate.toDateString()];
      if (detail == null) return;
      detail.summons.add(summon);
    });

    solution = dataMap.values.toList();
    solution.sort((a, b) => a.date.compareTo(b.date));
    for (int index = 1; index < solution.length; index++) {
      final lastDate = solution[index - 1], curDate = solution[index];
      curDate
        ..accSQ = lastDate.accSQ + curDate.addSQ
        ..accTicket = lastDate.accTicket + curDate.addTicket
        ..accApple = lastDate.accApple + curDate.addApple;
    }
    if (onSolved != null) onSolved!();
    return solution;
  }
}

class SQDayDetail {
  DateTime date;
  int accLogin;
  int continuousLogin;
  int addSQ;
  int accSQ;
  int addTicket;
  int accTicket;
  double addApple;
  double accApple;
  List<Event> events;
  List<LimitedSummon> summons;

  SQDayDetail({
    required this.date,
    this.accLogin = 0,
    int continuousLogin = 0,
    this.addSQ = 0,
    this.accSQ = 0,
    this.addTicket = 0,
    this.accTicket = 0,
    this.addApple = 0,
    this.accApple = 0,
    List<Event>? events,
    List<LimitedSummon>? summons,
  })  : continuousLogin = continuousLogin.clamp2(1, 7),
        events = events ?? [],
        summons = summons ?? [];
}
