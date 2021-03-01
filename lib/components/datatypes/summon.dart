//@dart=2.9
part of datatypes;

@JsonSerializable(checked: true)
class Summon {
  String mcLink;
  String name;
  String nameJp;
  String startTimeJp;
  String endTimeJp;
  String startTimeCn;
  String endTimeCn;
  String bannerUrl;
  String bannerUrlJp;
  List<String> associatedEvents;
  List<String> associatedSummons;

  /// 0-common summon, 1-SSR, 2-SSR+SR
  int luckyBag;
  bool classPickUp;
  bool roll11;
  List<SummonData> dataList;

  String get indexKey => mcLink;

  List<int> allSvts([bool includeHidden = false]) {
    Set<int> all = {};
    for (var data in dataList) {
      for (var block in data.svts) {
        if (block.display || includeHidden) {
          all.addAll(block.ids);
        }
      }
    }
    return all.toList();
  }

  List<int> allCrafts([bool includeHidden = false]) {
    Set<int> all = {};
    for (var data in dataList) {
      for (var block in data.crafts) {
        if (block.display || includeHidden) {
          all.addAll(block.ids);
        }
      }
    }
    return all.toList();
  }

  Summon({
    this.mcLink,
    this.name,
    this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
    this.bannerUrlJp,
    this.associatedEvents,
    this.associatedSummons,
    this.luckyBag,
    this.classPickUp,
    this.roll11,
    this.dataList,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  bool isOutdated() {
    DateTime start = DateTimeEnhance.tryParse(startTimeCn);
    DateTime end = DateTimeEnhance.tryParse(endTimeCn);
    DateTime now = DateTime.now();
    if (end != null && end.isBefore(now)) return true;
    if (start != null && now.difference(start).inDays > 30) return true;
    return false;
  }

  bool hasSinglePickupSvt(int id) {
    for (var data in dataList) {
      for (var block in data.svts) {
        if (block.ids.length == 1 && block.ids.single == id) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasSinglePickupCraft(int id) {
    for (var data in dataList) {
      for (var block in data.crafts) {
        if (block.ids.length == 1 && block.ids.single == id) {
          return true;
        }
      }
    }
    return false;
  }

  factory Summon.fromJson(Map<String, dynamic> data) => _$SummonFromJson(data);

  Map<String, dynamic> toJson() => _$SummonToJson(this);
}

@JsonSerializable(checked: true)
class SummonData {
  String name;
  List<SummonDataBlock> svts;
  List<SummonDataBlock> crafts;

  SummonData({this.name, this.svts, this.crafts});

  factory SummonData.fromJson(Map<String, dynamic> data) =>
      _$SummonDataFromJson(data);

  Map<String, dynamic> toJson() => _$SummonDataToJson(this);
}

@JsonSerializable(checked: true)
class SummonDataBlock {
  bool isSvt;
  int rarity;
  double weight;
  bool display;
  List<int> ids;

  SummonDataBlock({
    this.isSvt,
    this.rarity,
    this.weight,
    this.display,
    this.ids,
  });

  factory SummonDataBlock.fromJson(Map<String, dynamic> data) =>
      _$SummonDataBlockFromJson(data);

  Map<String, dynamic> toJson() => _$SummonDataBlockToJson(this);
}
