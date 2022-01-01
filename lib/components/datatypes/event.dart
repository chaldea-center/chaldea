part of datatypes;

@JsonSerializable(checked: true)
class Events {
  DateTime progressNA;
  DateTime progressTW;
  Map<String, LimitEvent> limitEvents; //key: event.name=mcLink
  Map<String, MainRecord> mainRecords; //key: event.chapter
  Map<String, CampaignEvent> campaigns; //key: event.name=mcLink
  Map<String, ExchangeTicket> exchangeTickets; //key: event.monthCn
  List<MasterMission> extraMasterMissions;

  Events({
    String? progressNA,
    String? progressTW,
    required this.limitEvents,
    required this.mainRecords,
    required this.exchangeTickets,
    required this.campaigns,
    required this.extraMasterMissions,
  })  : progressNA = _parseDate(progressNA, 365 * 2),
        progressTW = _parseDate(progressTW, 648);

  static DateTime _parseDate(String? time, [int days = 0]) {
    return time?.toDateTime() ?? DateTime.now().subtract(Duration(days: days));
  }

  factory Events.fromJson(Map<String, dynamic> data) => _$EventsFromJson(data);

  Map<String, dynamic> toJson() => _$EventsToJson(this);

  Map<String, int> getAllItems(EventPlans eventPlans) {
    List<Map<String, int>> resultList = [];
    limitEvents.forEach((name, event) {
      resultList.add(event.getItems(eventPlans.limitEvents[name]));
    });
    campaigns.forEach((name, event) {
      resultList.add(event.getItems(eventPlans.campaigns[name]));
    });
    mainRecords.forEach((name, event) {
      resultList.add(event.getItems(eventPlans.mainRecords[name]));
    });
    final startDate = DateTime.now().subtract(const Duration(days: 31 * 4));
    exchangeTickets.forEach((name, event) {
      if (event.curDate.isAfter(startDate)) {
        resultList.add(event.getItems(eventPlans.exchangeTickets[name]));
      }
    });
    return Maths.sumDict(resultList);
  }

  Map<String, EventBase> get allEvents {
    return <String, EventBase>{}
      ..addAll(limitEvents)
      ..addAll(mainRecords);
  }
}

class EventBase {
  String mcLink;
  String name;
  String? nameJp;
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
  int foukun4;
  int rarePrism;
  int welfareServant;
  Map<String, int> items;
  List<Quest> mainQuests;

  EventBase({
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
    required this.foukun4,
    required this.rarePrism,
    required this.welfareServant,
    required this.items,
    required this.mainQuests,
  });

  //
  String get indexKey => mcLink;

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String? get lBannerUrl =>
      Language.isCN ? bannerUrl ?? bannerUrlJp : bannerUrlJp ?? bannerUrl;

  bool isOutdated() {
    return checkEventOutdated(
        timeJp: startTimeJp?.toDateTime(), timeCn: startTimeCn?.toDateTime());
  }

  Map<String, int> _itemsWithRare([bool? rerun]) {
    return Map.from(items)
      ..addAll({
        Items.grail: grail + (rerun == false ? grail2crystal : 0),
        Items.crystal: crystal + (rerun == false ? 0 : grail2crystal),
        Items.fou4Atk: foukun4,
        Items.fou4Hp: foukun4,
        Items.rarePri: rarePrism,
      })
      ..removeWhere((key, value) => value <= 0);
  }

  bool get couldPlan => _itemsWithRare().isNotEmpty;

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

  Widget resolveDetailPage() {
    if (this is LimitEvent) {
      return LimitEventDetailPage(event: this as LimitEvent);
    } else if (this is MainRecord) {
      return MainRecordDetailPage(record: this as MainRecord);
    } else if (this is CampaignEvent) {
      return CampaignDetailPage(event: this as CampaignEvent);
    } else {
      throw TypeError();
    }
  }
}

@JsonSerializable(checked: true)
class LimitEvent extends EventBase {
  int lotteryLimit; //>0 limited
  Map<String, int> lottery;
  Map<String, String> extra;
  Map<String, String> extra2;
  List<Quest> freeQuests;

  LimitEvent({
    required String name,
    required String? nameJp,
    required String? nameEn,
    required String mcLink,
    required String? startTimeJp,
    required String? endTimeJp,
    required String? startTimeCn,
    required String? endTimeCn,
    required String? bannerUrl,
    required String? bannerUrlJp,
    required int grail,
    required int crystal,
    required int grail2crystal,
    required int foukun4,
    required int rarePrism,
    required int welfareServant,
    required Map<String, int> items,
    required this.lotteryLimit,
    required this.lottery,
    required this.extra,
    required this.extra2,
    required List<Quest> mainQuests,
    required this.freeQuests,
  }) : super(
          name: name,
          nameJp: nameJp,
          nameEn: nameEn,
          mcLink: mcLink,
          startTimeJp: startTimeJp,
          endTimeJp: endTimeJp,
          startTimeCn: startTimeCn,
          endTimeCn: endTimeCn,
          bannerUrl: bannerUrl,
          bannerUrlJp: bannerUrlJp,
          grail: grail,
          crystal: crystal,
          grail2crystal: grail2crystal,
          foukun4: foukun4,
          rarePrism: rarePrism,
          welfareServant: welfareServant,
          items: items,
          mainQuests: mainQuests,
        );

  Map<String, int> itemsWithRare([LimitEventPlan? plan]) {
    return super._itemsWithRare(plan?.rerun);
  }

  Map<String, int> getItems([LimitEventPlan? plan]) {
    if (plan == null || !plan.enabled) {
      return {};
    }
    Map<String, int> lotterySum =
        lottery.isNotEmpty ? Maths.multiplyDict(lottery, plan.lottery) : {};
    return Maths.sumDict([
      itemsWithRare(plan),
      plan.extra..removeWhere((key, value) => !extra.containsKey(key)),
      plan.extra2..removeWhere((key, value) => !extra2.containsKey(key)),
      lotterySum,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  // @override
  // bool get couldPlan =>
  //     super.couldPlan || lottery.isNotEmpty || extra.isNotEmpty;

  factory LimitEvent.fromJson(Map<String, dynamic> data) =>
      _$LimitEventFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventToJson(this);
}

@JsonSerializable(checked: true)
class MainRecord extends EventBase {
  Map<String, int> drops;
  @protected
  Map<String, int> rewards;

  @override
  @JsonKey(ignore: true)
  Map<String, int> get items => Maths.sumDict([drops, rewardsWithRare]);

  MainRecord({
    required String name,
    required String? nameJp,
    required String? nameEn,
    required String mcLink,
    required String? startTimeJp,
    required String? endTimeJp,
    required String? startTimeCn,
    required String? endTimeCn,
    required String? bannerUrl,
    required String? bannerUrlJp,
    required int grail,
    required int crystal,
    required int grail2crystal,
    required int foukun4,
    required int rarePrism,
    required int welfareServant,
    // required Map<String, int> items,
    required this.drops,
    required this.rewards,
    required List<Quest> mainQuests,
  }) : super(
          name: name,
          nameJp: nameJp,
          nameEn: nameEn,
          mcLink: mcLink,
          startTimeJp: startTimeJp,
          endTimeJp: endTimeJp,
          startTimeCn: startTimeCn,
          endTimeCn: endTimeCn,
          bannerUrl: bannerUrl,
          bannerUrlJp: bannerUrlJp,
          grail: grail,
          crystal: crystal,
          grail2crystal: grail2crystal,
          foukun4: foukun4,
          rarePrism: rarePrism,
          welfareServant: welfareServant,
          items: {},
          mainQuests: mainQuests,
        );

  String get chapter => _splitChapterTitle(name)[0];

  String get title => _splitChapterTitle(name)[1];

  String get chapterJp => _splitChapterTitle(nameJp ?? name)[0];

  String get titleJp => _splitChapterTitle(nameJp ?? name)[1];

  @override
  String get localizedName {
    if (Language.isEnOrKr) {
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
      ..addAll({Items.grail: grail, Items.crystal: crystal})
      ..removeWhere((key, value) => value <= 0);
  }

  Map<String, int> getItems([MainRecordPlan? plan]) {
    if (plan == null) return {};
    // assert(plan.length == 2, 'incorrect main record plan: $plan');
    return Maths.sumDict([
      if (plan.drop) drops,
      if (plan.reward) rewardsWithRare,
    ])
      ..removeWhere((key, value) => value <= 0);
  }

  @override
  bool isOutdated() {
    return checkEventOutdated(
        timeJp: startTimeJp?.toDateTime(), timeCn: startTimeCn?.toDateTime());
  }
}

@JsonSerializable(checked: true)
class CampaignEvent extends EventBase {
  CampaignEvent({
    required String name,
    required String? nameJp,
    required String? nameEn,
    required String mcLink,
    required String? startTimeJp,
    required String? endTimeJp,
    required String? startTimeCn,
    required String? endTimeCn,
    required String? bannerUrl,
    required String? bannerUrlJp,
    required int grail,
    required int crystal,
    required int grail2crystal,
    required int foukun4,
    required int rarePrism,
    required int welfareServant,
    required Map<String, int> items,
    required List<Quest> mainQuests,
  }) : super(
          name: name,
          nameJp: nameJp,
          nameEn: nameEn,
          mcLink: mcLink,
          startTimeJp: startTimeJp,
          endTimeJp: endTimeJp,
          startTimeCn: startTimeCn,
          endTimeCn: endTimeCn,
          bannerUrl: bannerUrl,
          bannerUrlJp: bannerUrlJp,
          grail: grail,
          crystal: crystal,
          grail2crystal: grail2crystal,
          foukun4: foukun4,
          rarePrism: rarePrism,
          welfareServant: welfareServant,
          items: items,
          mainQuests: mainQuests,
        );

  Map<String, int> itemsWithRare([CampaignPlan? plan]) {
    return super._itemsWithRare(plan?.rerun);
  }

  Map<String, int> getItems([CampaignPlan? plan]) {
    if (plan == null || !plan.enabled) {
      return {};
    }
    return Map.of(itemsWithRare(plan))..removeWhere((key, value) => value <= 0);
  }

  factory CampaignEvent.fromJson(Map<String, dynamic> data) =>
      _$CampaignEventFromJson(data);

  Map<String, dynamic> toJson() => _$CampaignEventToJson(this);
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
  DateTime dateTw;
  @JsonKey(ignore: true)
  DateTime dateEn;

  @JsonKey(name: 'monthCn')
  String get monthCn => dateToStr(dateCn);

  @JsonKey(ignore: false)
  String get monthTw => dateToStr(dateTw);

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
    String? monthTw,
    String? monthEn,
  })  : dateJp = monthToDate(monthJp),
        dateCn = monthToDate(monthJp, 15),
        dateTw = monthToDate(monthJp, 21),
        dateEn = monthToDate(monthJp, 24);

  DateTime get curDate {
    switch (db.curUser.server) {
      case GameServer.jp:
        return dateJp;
      case GameServer.cn:
        return dateCn;
      case GameServer.tw:
        return dateTw;
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

  Map<String, int> getItems(ExchangeTicketPlan? plan) {
    if (plan == null) return {};
    Map<String, int> result = {};
    for (var i = 0; i < 3; i++) {
      result[items[i]] = plan.items[i];
    }
    return result;
  }

  bool isOutdated([int months = 4]) {
    return DateTime.now().checkOutdated(curDate, Duration(days: months * 31));
  }
}

@JsonSerializable()
class MasterMission {
  int id;
  int flag;
  String type;
  int dispNo;
  String name;
  String detail;
  int startedAt;
  int endedAt;
  int closedAt;
  Map<int, int> rewards;

  MasterMission({
    required this.id,
    required this.flag,
    required this.type,
    required this.dispNo,
    required this.name,
    required this.detail,
    required this.startedAt,
    required this.endedAt,
    required this.closedAt,
    required this.rewards,
  });

  DateTime get startedDateTime =>
      DateTime.fromMillisecondsSinceEpoch(startedAt * 1000);

  Map<String, int> get itemRewards {
    Map<String, int> map = {};
    rewards.forEach((key, value) {
      final item = db.gameData.items.values
          .firstWhereOrNull((item) => item.itemId == key);
      if (item != null) map[item.name] = value;
    });
    return map;
  }

  factory MasterMission.fromJson(Map<String, dynamic> data) =>
      _$MasterMissionFromJson(data);

  Map<String, dynamic> toJson() => _$MasterMissionToJson(this);
}
