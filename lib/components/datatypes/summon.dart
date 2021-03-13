part of datatypes;

@JsonSerializable(checked: true)
class Summon {
  String mcLink;
  String name;
  String? nameJp;
  String? startTimeJp;
  String? endTimeJp;
  String? startTimeCn;
  String? endTimeCn;
  String? bannerUrl;
  String? bannerUrlJp;
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
    required this.mcLink,
    required this.name,
    this.nameJp,
    this.startTimeJp,
    this.endTimeJp,
    this.startTimeCn,
    this.endTimeCn,
    this.bannerUrl,
    this.bannerUrlJp,
    required this.associatedEvents,
    required this.associatedSummons,
    required this.luckyBag,
    required this.classPickUp,
    required this.roll11,
    required this.dataList,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  bool isOutdated() {
    return checkEventOutdated(
        timeJp: startTimeJp?.toDateTime(), timeCn: startTimeCn?.toDateTime());
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

  List<SummonDataBlock> get allBlocks => []..addAll(svts)..addAll(crafts);

  SummonData({
    required this.name,
    required this.svts,
    required this.crafts,
  });

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
    required this.isSvt,
    required this.rarity,
    required this.weight,
    required this.display,
    required this.ids,
  });

  factory SummonDataBlock.fromJson(Map<String, dynamic> data) =>
      _$SummonDataBlockFromJson(data);

  Map<String, dynamic> toJson() => _$SummonDataBlockToJson(this);
}
