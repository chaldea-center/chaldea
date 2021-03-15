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
      if (DateTime.parse(event.month + '01').isAfter(startDate)) {
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
  late String name;
  late String nameJp;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  late int grail;
  late int crystal;
  late int grail2crystal;

  String get indexKey;

  String get localizedName;

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
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  int grail;
  int crystal;
  int grail2crystal;
  Map<String, int> items;
  int lotteryLimit; //>0 limited
  Map<String, int> lottery;
  Map<String, String> extra;

  String get indexKey {
    if (db.gameData.events.limitEvents.containsKey(name)) {
      return name;
    }
    return db.gameData.events.limitEvents.entries
        .firstWhere((event) => event.value == this)
        .key;
  }

  LimitEvent({
    required this.name,
    required this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
    required this.grail,
    required this.crystal,
    required this.grail2crystal,
    required this.items,
    required this.lotteryLimit,
    required this.lottery,
    required this.extra,
  }); //item-comment

  String get localizedName => localizeNoun(name, nameJp, null);

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
  String name;
  String nameJp;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  int grail;
  int crystal;
  int grail2crystal;
  Map<String, int> drops;
  Map<String, int> rewards;

  String get indexKey {
    if (db.gameData.events.mainRecords.containsKey(name)) {
      return name;
    } else {
      return db.gameData.events.mainRecords.entries
          .firstWhere((element) => element.value.name == name)
          .key;
    }
  }

  MainRecord({
    required this.name,
    required this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
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

  String get localizedName => localizeNoun(name, nameJp, null);

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

@JsonSerializable(checked: true)
class ExchangeTicket {
  int days;
  String month; //format: 2020-01
  String monthJp;
  List<String> items;

  ExchangeTicket({
    required this.days,
    required this.month,
    required this.monthJp,
    required this.items,
  });

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
    return checkEventOutdated(
      timeJp: DateTime.parse('${monthJp}01'.replaceAll('-', '')),
      timeCn: DateTime.parse('${month}01'.replaceAll('-', '')),
      duration: Duration(days: 31 * months),
    );
  }
}
