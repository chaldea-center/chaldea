//@dart=2.9
part of datatypes;

@JsonSerializable(checked: true)
class Events {
  Map<String, LimitEvent> limitEvents; //key: event.name=mcLink
  Map<String, MainRecord> mainRecords; //key: event.chapter
  Map<String, ExchangeTicket> exchangeTickets; //key: event.monthCn

  Events({this.limitEvents, this.mainRecords, this.exchangeTickets}) {
    limitEvents ??= {};
    mainRecords ??= {};
    exchangeTickets ??= {};
  }

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
}

@JsonSerializable(checked: true)
class LimitEvent {
  String name;
  String nameJp;
  String startTimeJp;
  String endTimeJp;
  String startTimeCn;
  String endTimeCn;
  String bannerUrl;
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
        .firstWhere((event) => event.value.name == name)
        .key;
  }

  LimitEvent({
    this.name,
    this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
    this.grail,
    this.crystal,
    this.grail2crystal,
    this.items,
    this.lotteryLimit,
    this.lottery,
    this.extra,
  }); //item-comment

  String get localizedName => localizeNoun(name, nameJp, null);

  Map<String, int> itemsWithRare([LimitEventPlan plan]) {
    return Map.from(items)
      ..addAll({
        Item.grail: grail + (plan?.rerun == false ? grail2crystal : 0),
        Item.crystal: crystal + (plan?.rerun == false ? 0 : grail2crystal)
      })
      ..removeWhere((key, value) => value <= 0);
  }

  Map<String, int> getItems(LimitEventPlan plan) {
    if (plan == null || !plan.enable) {
      return {};
    }
    Map<String, int> lotterySum =
        lottery?.isNotEmpty == true ? multiplyDict(lottery, plan.lottery) : {};
    return sumDict([
      itemsWithRare(plan),
      plan.extra..removeWhere((key, value) => !extra.containsKey(key)),
      lotterySum,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  bool isOutdated([int dm = 1]) {
    if (startTimeCn?.isNotEmpty == true) {
      final endDate = DateTime.now().subtract(Duration(days: 31 * dm));
      return DateTime.parse(startTimeCn).isBefore(endDate);
    } else {
      return false;
    }
  }

  factory LimitEvent.fromJson(Map<String, dynamic> data) =>
      _$LimitEventFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventToJson(this);
}

@JsonSerializable(checked: true)
class MainRecord {
  String name;
  String nameJp;
  String startTimeJp;
  String endTimeJp;
  String startTimeCn;
  String endTimeCn;
  String bannerUrl;
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
    this.name,
    this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
    this.grail,
    this.crystal,
    this.grail2crystal,
    this.drops,
    this.rewards,
  });

  String get chapter => _splitChapterTitle(name)[0];

  String get title => _splitChapterTitle(name)[1];

  String get chapterJp => _splitChapterTitle(nameJp ?? name)[0];

  String get titleJp => _splitChapterTitle(nameJp ?? name)[1];

  String get localizedName => localizeNoun(name, nameJp, null);

  String get localizedChapter => localizeNoun(chapter, chapterJp, null);

  String get localizedTitle => localizeNoun(title, titleJp, null);

  List<String> _splitChapterTitle(String longName) {
    if (longName.startsWith('序')) {
      return [longName, null];
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

  Map<String, int> getItems(List<bool> plan) {
    if (plan == null) return {};
    assert(plan.length == 2, 'incorrect main record plan: $plan');
    return sumDict([
      if (plan[0]) drops,
      if (plan[1]) rewardsWithRare,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  bool isOutdated([int dm = 1]) {
    if (startTimeCn?.isNotEmpty == true) {
      final endDate = DateTime.now().subtract(Duration(days: 31 * dm));
      return DateTime.parse(startTimeCn).isBefore(endDate);
    } else {
      return false;
    }
  }
}

@JsonSerializable(checked: true)
class ExchangeTicket {
  int days;
  String month; //2020-01
  String monthJp;
  List<String> items;

  ExchangeTicket({this.days, this.month, this.monthJp, this.items});

  factory ExchangeTicket.fromJson(Map<String, dynamic> data) =>
      _$ExchangeTicketFromJson(data);

  Map<String, dynamic> toJson() => _$ExchangeTicketToJson(this);

  Map<String, int> getItems(List<int> plan) {
    if (plan == null) return {};
    assert(plan.length == 3, 'incorrect main record plan: $plan');
    Map<String, int> result = {};
    for (var i = 0; i < 3; i++) {
      result[items[i]] = plan[i];
    }
    return result;
  }

  bool isOutdated([int months = 4]) {
    final startDate = DateTime.now().subtract(Duration(days: 31 * months));
    return DateTime.parse(month + '-01').isBefore(startDate);
  }
}
