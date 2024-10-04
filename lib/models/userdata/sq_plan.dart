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

  // mission
  bool weeklyMission;
  bool limitedMission;
  bool campaignLoginBonus;
  Map<int, bool> extraMissions; // not included

  bool minusPlannedBanner; // not implemented
  // view options
  bool favoriteSummonOnly;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final notifier = ValueNotifier<int>(0);

  MasterMission? get extraMission => db.gameData.extraMasterMission[MasterMission.kExtraMasterMissionId];

  SaintQuartzPlan({
    this.curSQ = 0,
    this.curTicket = 0,
    this.curApple = 0,
    DateTime? startDate,
    DateTime? endDate,
    this.accLogin = 1,
    this.continuousLogin = 1,
    this.weeklyMission = true,
    this.limitedMission = true,
    this.campaignLoginBonus = true,
    Map<int, bool>? missions,
    bool? minusPlannedBanner,
    this.favoriteSummonOnly = false,
  })  : startDate = startDate ?? DateUtils.dateOnly(DateTime.now()),
        endDate = endDate ?? DateUtils.dateOnly(DateTime.now()),
        extraMissions = missions ?? {},
        minusPlannedBanner = minusPlannedBanner ?? true {
    validate();
  }

  void validate() {
    continuousLogin = continuousLogin.clamp2(1, 7);
    if (!endDate.isAfter(startDate)) {
      endDate = DateUtils.addDaysToDate(startDate, 365);
    }
  }

  bool isInRange(int? jp) {
    if (jp == null) return false;
    return jp >= startDate.timestamp && jp <= endDate.timestamp;
  }

  factory SaintQuartzPlan.fromJson(Map<String, dynamic> data) => _$SaintQuartzPlanFromJson(data);

  Map<String, dynamic> toJson() => _$SaintQuartzPlanToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false)
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
    if (limitedMission) {
      for (final mm in db.gameData.masterMissions.values) {
        if (mm.type != MissionType.limited && mm.type != MissionType.complete) continue;
        if (!isInRange(mm.startedAt)) continue;
        final detail = dataMap[DateUtils.dateOnly(mm.startedAt.sec2date()).toDateString()];
        if (detail == null) continue;
        for (final (objectId, count) in mm.gifts.items) {
          if (objectId == Items.stoneId) {
            detail.addSQ += count;
          } else if (objectId == Items.summonTicketId) {
            detail.addTicket += count;
          } else if (objectId == Items.goldAppleId) {
            detail.addApple += count;
          } else if (objectId == Items.silverAppleId) {
            detail.addApple += count / 2;
          } else if (objectId == Items.bronzeAppleId) {
            detail.addApple += count / 14.4;
          }
        }
      }
    }
    if (campaignLoginBonus) {
      final presents = db.runtimeData.dailyBonusData?.userPresentBox ?? [];
      for (final present in presents) {
        if (present.giftType != GiftType.item.value) continue;
        if (present.fromType == PresentFromType.totalLogin.value ||
            present.fromType == PresentFromType.seqLogin.value) {
          continue;
        }
        if (!isInRange(present.createdAt)) continue;
        final detail = dataMap[DateUtils.dateOnly(present.createdAt.sec2date()).toDateString()];
        if (detail == null) continue;
        if (present.objectId == Items.stoneId) {
          detail.addSQ += present.num;
        } else if (present.objectId == Items.summonTicketId) {
          detail.addTicket += present.num;
        } else if (present.objectId == Items.goldAppleId) {
          detail.addApple += present.num;
        } else if (present.objectId == Items.silverAppleId) {
          detail.addApple += present.num / 2;
        } else if (present.objectId == Items.bronzeAppleId) {
          detail.addApple += present.num / 14.4;
        }
        detail.presents.add(present);
      }
    }

    // check event
    void _checkEvent({
      Event? event,
      DateTime? start,
      Map<int, int>? items,
      String? name,
    }) {
      if (event != null) {
        start ??= event.startedAt.sec2date();
        items ??= event.statItemFixed;
        name ??= event.shownName;
      }
      items ??= {};
      if (start == null) return;

      start = DateUtils.dateOnly(start);
      final detail = dataMap[start.toDateString()];
      if (detail == null) return;

      detail.addSQ += items[Items.stoneId] ?? 0;
      detail.addTicket += items[Items.summonTicketId] ?? 0;
      detail.addApple += (items[Items.goldAppleId] ?? 0) +
          (items[Items.silverAppleId] ?? 0) / 2 +
          (items[Items.bronzeAppleId] ?? 0) / 14.4;
      if (event != null) {
        if (event.type != EventType.eventQuest && event.isEmpty && event.campaigns.isNotEmpty) {
          // pass
        } else {
          detail.events.add(event);
        }
      }
    }

    for (final event in db.gameData.events.values) {
      _checkEvent(event: event);
    }
    for (final war in db.gameData.mainStories.values) {
      _checkEvent(
        name: war.lLongName.l,
        items: {...war.itemDrop, ...war.itemReward},
        // startDate: war.extra.
      );
    }
    // check master mission
    // final Map<int, int> extraMissionItems = {};
    // if (extraMission != null) {
    //   for (final mission in extraMission!.missions) {
    //     if (extraMissions[mission.id] != true) continue;
    //     for (final gift in mission.gifts) {
    //       extraMissionItems.addNum(gift.objectId, gift.num);
    //     }
    //   }
    // }
    // _checkEvent(
    //   startDate: DateUtils.addDaysToDate(endDate, -eventDateDelta),
    //   items: extraMissionItems,
    //   name: 'Extra Mission',
    // );

    for (final summon in db.gameData.wiki.summons.values) {
      DateTime? startDate = summon.startTime.jp?.sec2date();
      if (startDate == null) continue;
      startDate = DateUtils.dateOnly(startDate);
      final detail = dataMap[startDate.toDateString()];
      if (detail == null) continue;
      if (!favoriteSummonOnly || db.curUser.summons.contains(summon.id)) {
        detail.summons.add(summon);
      }
    }

    solution = dataMap.values.toList();
    solution.sort((a, b) => a.date.compareTo(b.date));
    for (int index = 1; index < solution.length; index++) {
      final lastDate = solution[index - 1], curDate = solution[index];
      curDate
        ..accSQ = lastDate.accSQ + curDate.addSQ
        ..accTicket = lastDate.accTicket + curDate.addTicket
        ..accApple = lastDate.accApple + curDate.addApple;
    }
    if (favoriteSummonOnly) {
      solution.retainWhere((e) => e.summons.isNotEmpty);
    }
    notifier.value = DateTime.now().microsecondsSinceEpoch;
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
  List<UserPresentBoxEntity> presents;

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
    List<UserPresentBoxEntity>? presents,
  })  : continuousLogin = continuousLogin.clamp(1, 7),
        events = events ?? [],
        summons = summons ?? [],
        presents = presents ?? [];
}
