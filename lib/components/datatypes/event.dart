part of datatypes;

@JsonSerializable()
class Events {
  Map<String, LimitEvent> limitEvents;
  Map<String, MainRecord> mainRecords;
  Map<String, ExchangeTicket> exchangeTickets;

  Events({this.limitEvents, this.mainRecords, this.exchangeTickets}) {
    limitEvents ??= {};
    mainRecords ??= {};
    exchangeTickets ??= {};
  }

  factory Events.fromJson(Map<String, dynamic> data) => _$EventsFromJson(data);

  Map<String, dynamic> toJson() => _$EventsToJson(this);

  Map<String, int> getAllItems(Plans plan) {
    List<Map<String, int>> resultList = [];
    limitEvents.forEach((name, event) {
      resultList.add(event.getAllItems(plan.limitEvents[name]));
    });
    mainRecords.forEach((name, event) {
      resultList.add(event.getAllItems(plan.mainRecords[name]));
    });
    exchangeTickets.forEach((name, event) {
      resultList.add(event.getAllItems(plan.exchangeTickets[name]));
    });
    return sumDict(resultList);
  }
}

@JsonSerializable()
class LimitEvent {
  String name;
  String link;
  String startTimeJp;
  String endTimeJp;
  String startTimeCn;
  String endTimeCn;
  int grail;
  int crystal;
  int grail2crystal;
  int qp;
  Map<String, int> items;
  String category;
  Map<String, String> extra;

//  List<Map<String, double>> hunting;
  Map<String, int> lottery;

  LimitEvent({
    this.name,
    this.link,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.grail,
    this.crystal,
    this.grail2crystal,
    this.qp,
    this.items,
    this.category,
    this.extra,
    this.lottery,
  });

  factory LimitEvent.fromJson(Map<String, dynamic> data) =>
      _$LimitEventFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventToJson(this);

  Map<String, int> getAllItems(LimitEventPlan plan) {
    if (plan == null || !plan.enable) {
      return {};
    }
    Map<String, int> lotterySum =
        lottery == null ? {} : multiplyDict(lottery, plan.lottery);
    return sumDict([items, plan.hunting, lotterySum]);
  }
}

@JsonSerializable()
class MainRecord {
  String name;
  String startTimeJp;
  Map<String, int> drops;
  Map<String, int> rewards;

  MainRecord({this.name, this.startTimeJp, this.drops, this.rewards});

  factory MainRecord.fromJson(Map<String, dynamic> data) =>
      _$MainRecordFromJson(data);

  Map<String, dynamic> toJson() => _$MainRecordToJson(this);

  Map<String, int> getAllItems(List<bool> plan) {
    if (plan == null) {
      return {};
    }
    assert(plan.length == 2, 'incorrect main record plan: $plan');
    return sumDict([if (plan[0]) drops, if (plan[1]) rewards]);
  }
}

@JsonSerializable()
class ExchangeTicket {
  int days;
  String monthJp;
  String monthCn;
  List<String> items;

  ExchangeTicket({this.days, this.monthJp, this.monthCn, this.items});

  factory ExchangeTicket.fromJson(Map<String, dynamic> data) =>
      _$ExchangeTicketFromJson(data);

  Map<String, dynamic> toJson() => _$ExchangeTicketToJson(this);

  Map<String, int> getAllItems(List<int> plan) {
    if (plan == null) {
      return {};
    }
    assert(plan.length == 3, 'incorrect main record plan: $plan');
    Map<String, int> result = {};
    for (var i = 0; i < 3; i++) {
      result[items[i]] = plan[i];
    }
    return result;
  }
}
