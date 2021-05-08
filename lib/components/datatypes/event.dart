part of datatypes;

@JsonSerializable(checked: true)
class Events {
  Map<String, LimitEvent> limitEvents; //key: event.name=mcLink
  Map<String, MainRecord> mainRecords; //key: event.chapter
  Map<String, ExchangeTicket> exchangeTickets; //key: event.monthCn

  Events({
    required this.limitEvents,
    required this.mainRecords,
    required this.exchangeTickets,
  });

  factory Events.fromJson(Map<String, dynamic> data) => _$EventsFromJson(data);

  Map<String, dynamic> toJson() => _$EventsToJson(this);

  Map<String, int> getAllItems(EventPlans eventPlans) {
    List<Map<String, int>> resultList = [];
    limitEvents.forEach((name, event) {
      resultList.add(event.getItems(eventPlans.limitEvents[name]));
    });
    mainRecords.forEach((name, event) {
      resultList.add(event.getItems(eventPlans.mainRecords[name]));
    });
    final startDate = DateTime.now().subtract(Duration(days: 31 * 4));
    exchangeTickets.forEach((name, event) {
      if (event.curDate.isAfter(startDate)) {
        resultList.add(event.getItems(eventPlans.exchangeTickets[name]));
      }
    });
    return sumDict(resultList);
  }

  Map<String, EventBase> get allEvents {
    return Map<String, EventBase>()..addAll(limitEvents)..addAll(mainRecords);
  }
}

abstract class EventBase {
  late String mcLink;
  late String name;
  late String nameJp;
  late String? nameEn;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  String? bannerUrlJp;
  late int grail;
  late int crystal;
  late int grail2crystal;

  String get indexKey => mcLink;

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String? get lBannerUrl =>
      Language.isCN ? bannerUrl ?? bannerUrlJp : bannerUrlJp ?? bannerUrl;

  static List<T> sortEvents<T extends EventBase>(List<T> events,
      {bool reversed = false, bool inPlace = true}) {
    List<T> jpEvents =
        events.where((e) => e.startTimeJp?.toDateTime() != null).toList();
    final cnEvents = events.where((e) => !jpEvents.contains(e));
    jpEvents.sort((a, b) =>
        a.startTimeJp!.toDateTime()!.compareTo(b.startTimeJp!.toDateTime()!));
    cnEvents.forEach((e) {
      final curDate = e.startTimeCn?.toDateTime();
      if (curDate == null) {
        jpEvents.add(e);
        return;
      }
      for (int i = 0; i < jpEvents.length; i++) {
        final date = jpEvents[i].startTimeCn?.toDateTime();
        if (date == null) {
          continue;
        }
        if (date.compareTo(curDate) >= 0) {
          jpEvents.insert(i, e);
          return;
        }
      }
      jpEvents.add(e);
    });
    if (reversed) {
      jpEvents = jpEvents.reversed.toList();
    }
    if (inPlace) {
      events.setAll(0, jpEvents);
      return events;
    }
    return jpEvents;
  }

  bool isSameEvent(String? name) {
    if (name?.replaceAll('_', ' ') == indexKey.replaceAll('_', ' ')) {
      return true;
    }
    return false;
  }
}

@JsonSerializable(checked: true)
class LimitEvent extends EventBase {
  String name;
  String nameJp;
  String? nameEn;
  String mcLink;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  String? bannerUrlJp;
  int grail;
  int crystal;
  int grail2crystal;
  Map<String, int> items;
  int lotteryLimit; //>0 limited
  Map<String, int> lottery;
  Map<String, String> extra;

  LimitEvent({
    required this.mcLink,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.startTimeJp,
    required this.endTimeJp,
    required this.startTimeCn,
    required this.endTimeCn,
    required this.bannerUrl,
    required this.bannerUrlJp,
    required this.grail,
    required this.crystal,
    required this.grail2crystal,
    required this.items,
    required this.lotteryLimit,
    required this.lottery,
    required this.extra,
  }); //item-comment

  Map<String, int> itemsWithRare([LimitEventPlan? plan]) {
    return Map.from(items)
      ..addAll({
        Item.grail: grail + (plan?.rerun == false ? grail2crystal : 0),
        Item.crystal: crystal + (plan?.rerun == false ? 0 : grail2crystal)
      })
      ..removeWhere((key, value) => value <= 0);
  }

  Map<String, int> getItems(LimitEventPlan? plan) {
    if (plan == null || !plan.enable) {
      return {};
    }
    Map<String, int> lotterySum =
        lottery.isNotEmpty == true ? multiplyDict(lottery, plan.lottery) : {};
    return sumDict([
      itemsWithRare(plan),
      plan.extra..removeWhere((key, value) => !extra.containsKey(key)),
      lotterySum,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  bool isOutdated() {
    return checkEventOutdated(
        timeJp: startTimeJp?.toDateTime(), timeCn: startTimeCn?.toDateTime());
  }

  factory LimitEvent.fromJson(Map<String, dynamic> data) =>
      _$LimitEventFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventToJson(this);
}

@JsonSerializable(checked: true)
class MainRecord extends EventBase {
  String mcLink;
  String name;
  String nameJp;
  String? nameEn;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  String? bannerUrlJp;
  int grail;
  int crystal;
  int grail2crystal;
  Map<String, int> drops;
  Map<String, int> rewards;

  MainRecord({
    required this.mcLink,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.startTimeJp,
    required this.endTimeJp,
    required this.startTimeCn,
    required this.endTimeCn,
    required this.bannerUrl,
    required this.bannerUrlJp,
    required this.grail,
    required this.crystal,
    required this.grail2crystal,
    required this.drops,
    required this.rewards,
  });

  String get chapter => _splitChapterTitle(name)[0];

  String get title => _splitChapterTitle(name)[1];

  String get chapterJp => _splitChapterTitle(nameJp)[0];

  String get titleJp => _splitChapterTitle(nameJp)[1];

  String get localizedName {
    if (Language.isEN) {
      return localizeNoun(name, nameJp, Localized.chapter.of(name));
    }
    return localizeNoun(name, nameJp, null);
  }

  String get localizedChapter => localizeNoun(chapter, chapterJp, null);

  String get localizedTitle => localizeNoun(title, titleJp, null);

  List<String> _splitChapterTitle(String longName) {
    if (longName.startsWith('序')) {
      return [longName, ''];
    } else if (longName.startsWith('Lostbelt')) {
      final splits = longName.split(' ');
      return [splits.sublist(0, 2).join(' '), splits.sublist(2).join(' ')];
    } else {
      final splits = longName.split(' ');
      return [splits.sublist(0, 1).join(' '), splits.sublist(1).join(' ')];
    }
  }

  factory MainRecord.fromJson(Map<String, dynamic> data) =>
      _$MainRecordFromJson(data);

  Map<String, dynamic> toJson() => _$MainRecordToJson(this);

  Map<String, int> get rewardsWithRare {
    return Map.from(rewards)
      ..addAll({Item.grail: grail, Item.crystal: crystal})
      ..removeWhere((key, value) => value <= 0);
  }

  Map<String, int> getItems(List<bool>? plan) {
    if (plan == null) return {};
    assert(plan.length == 2, 'incorrect main record plan: $plan');
    return sumDict([
      if (plan[0]) drops,
      if (plan[1]) rewardsWithRare,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  bool isOutdated() {
    return checkEventOutdated(
        timeJp: startTimeJp?.toDateTime(), timeCn: startTimeCn?.toDateTime());
  }
}

///  Exchange Ticket starts from:
///    * jp = (2017, 08)
///    * cn = (2018, 11), +15
///    * en = (2019, 08), +24, with additional 2019-7 not included
@JsonSerializable(checked: true)
class ExchangeTicket {
  String monthJp; //format: 2020-01
  List<String> items;

  @JsonKey(ignore: true)
  DateTime dateJp;
  @JsonKey(ignore: true)
  DateTime dateCn;
  @JsonKey(ignore: true)
  DateTime dateEn;

  @JsonKey(name: 'monthCn')
  String get monthCn => dateToStr(dateCn);

  @JsonKey(ignore: false)
  String get monthEn => dateToStr(dateEn);

  int get days {
    return DateTime(curDate.year, curDate.month + 1, 1, 1)
        .difference(curDate)
        .inDays;
  }

  ExchangeTicket({
    required this.monthJp,
    required this.items,
    // don't import but export these two
    String? monthCn,
    String? monthEn,
  })  : dateJp = monthToDate(monthJp),
        dateCn = monthToDate(monthJp, 15),
        dateEn = monthToDate(monthJp, 24);

  DateTime get curDate {
    switch (db.curUser.server) {
      case GameServer.jp:
        return dateJp;
      case GameServer.cn:
        return dateCn;
      case GameServer.en:
        return dateEn;
    }
  }

  String dateToStr([DateTime? date]) {
    date ??= curDate;
    return '${date.year}-${date.month.toString().padLeft(2, "0")}';
  }

  /// [monthString] format: 2020-01
  static DateTime monthToDate(String monthString, [int dMonth = 0]) {
    assert(RegExp(r'^\d+\-\d+$').hasMatch(monthString),
        'Invalid ticket date format: $monthString');
    int year = int.parse(monthString.split('-')[0]);
    int month = int.parse(monthString.split('-')[1]);
    year += (month - 1 + dMonth) ~/ 12;
    month = (month - 1 + dMonth) % 12 + 1;
    return DateTime(year, month);
  }

  factory ExchangeTicket.fromJson(Map<String, dynamic> data) =>
      _$ExchangeTicketFromJson(data);

  Map<String, dynamic> toJson() => _$ExchangeTicketToJson(this);

  Map<String, int> getItems(List<int>? plan) {
    if (plan == null) return {};
    assert(plan.length == 3, 'incorrect main record plan: $plan');
    Map<String, int> result = {};
    for (var i = 0; i < 3; i++) {
      result[items[i]] = plan[i];
    }
    return result;
  }

  bool isOutdated([int months = 4]) {
    return DateTime.now().checkOutdated(curDate, Duration(days: months * 31));
  }
}
