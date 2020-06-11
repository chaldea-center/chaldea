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

  factory LimitEvent.fromJson(Map<String, dynamic> data) =>
      _$LimitEventFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventToJson(this);

  Map<String, int> getItems(LimitEventPlan plan) {
    if (plan == null || !plan.enable) {
      return {};
    }
    Map<String, int> lotterySum = lotteryLimit > 0
        ? multiplyDict(lottery, lotteryLimit)
        : lottery?.isNotEmpty == true
            ? multiplyDict(lottery, plan.lottery)
            : {};
    return sumDict([items, plan.extra, lotterySum]);
  }

  bool isNotOutdated([int dm = 1]) {
    if (startTimeCn?.isNotEmpty == true) {
      final endDate = DateTime.now().subtract(Duration(days: 31 * dm));
      return DateTime.parse(startTimeCn).isAfter(endDate);
    } else {
      return true;
    }
  }
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
  String chapter;
  String title;
  Map<String, int> drops;
  Map<String, int> rewards;

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
    this.chapter,
    this.title,
    this.drops,
    this.rewards,
  });

  factory MainRecord.fromJson(Map<String, dynamic> data) =>
      _$MainRecordFromJson(data);

  Map<String, dynamic> toJson() => _$MainRecordToJson(this);

  Map<String, int> getItems(List<bool> plan) {
    if (plan == null) return {};
    assert(plan.length == 2, 'incorrect main record plan: $plan');
    return sumDict([if (plan[0]) drops, if (plan[1]) rewards]);
  }

  bool isNotOutdated([int dm = 1]) {
    if (startTimeCn?.isNotEmpty == true) {
      final endDate = DateTime.now().subtract(Duration(days: 31 * dm));
      return DateTime.parse(startTimeCn).isAfter(endDate);
    } else {
      return true;
    }
  }
}

@JsonSerializable(checked: true)
class ExchangeTicket {
  int days;
  String month; //2020/01
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

  bool isNotOutdated([int months = 4]) {
    final startDate = DateTime.now().subtract(Duration(days: 31 * months));
    return DateTime.parse(month + '-01').isAfter(startDate);
  }
}
