/// Servant data
part of datatypes;

@JsonSerializable(checked: true)
class GameData {
  String version;
  List<int> unavailableSvts;

  /// Be careful when access [servants] and [servantsWithUser]
  Map<int, Servant> servants;
  Map<int, Costume> costumes;
  Map<int, CraftEssence> crafts;
  Map<int, CommandCode> cmdCodes;
  Map<String, Item> items;
  Map<String, String?> icons; //key: filename, value: original filename
  Events events;
  Map<String, Quest> freeQuests;
  Map<int, List<Quest>> svtQuests;
  GLPKData glpk;
  Map<String, MysticCode> mysticCodes;
  Map<String, Summon> summons;

  Map<int, int> fsmSvtIdMapping;

  @JsonKey(ignore: true)
  Map<int, Servant> servantsWithUser;

  GameData({
    this.version = '0',
    this.unavailableSvts = const [],
    this.servants = const {},
    this.costumes = const {},
    this.crafts = const {},
    this.cmdCodes = const {},
    this.items = const {},
    this.icons = const {},
    Events? events,
    this.freeQuests = const {},
    this.svtQuests = const {},
    GLPKData? glpk,
    this.mysticCodes = const {},
    this.summons = const {},
    this.fsmSvtIdMapping = const {},
  })  : events = events ??
            Events(
              limitEvents: {},
              mainRecords: {},
              exchangeTickets: {},
              campaigns: {},
            ),
        glpk = glpk ??
            GLPKData(
              colNames: [],
              rowNames: [],
              costs: [],
              matrix: [],
              freeCounts: {},
              weeklyMissionData: [],
            ),
        servantsWithUser = Map.of(servants);

  void updateSvtCrafts() {
    servants.forEach((key, svt) {
      // svt.bondCraft = -1;
      svt.valentineCraft.clear();
    });
    for (final craft in crafts.values) {
      if (craft.bond > 0) {
        servants[craft.bond]?.bondCraft = craft.no;
      }
      if (craft.valentine > 0) {
        servants[craft.valentine]?.valentineCraft.add(craft.no);
      }
    }
  }

  void updateUserDuplicatedServants([Map<int, int>? duplicated]) {
    duplicated ??= db.curUser.duplicatedServants;
    servantsWithUser = Map.of(servants);
    duplicated.forEach((duplicatedSvtNo, originSvtNo) {
      if (!servants.containsKey(duplicatedSvtNo) &&
          servants.containsKey(originSvtNo)) {
        servantsWithUser[duplicatedSvtNo] =
            servants[originSvtNo]!.duplicate(duplicatedSvtNo);
      }
    });
  }

  Quest? getFreeQuest(String key) {
    if (freeQuests.containsKey(key)) return freeQuests[key]!;
    for (var quest in freeQuests.values) {
      if (key.contains(quest.place!) && key.contains(quest.name)) {
        return quest;
      }
      if (fullToHalf(quest.indexKey!) == fullToHalf(key)) {
        return quest;
      }
    }
  }

  factory GameData.fromJson(Map<String, dynamic> data) =>
      _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

@JsonSerializable(checked: true)
class ItemCost {
  List<Map<String, int>> ascension;
  List<Map<String, int>> skill;
  List<Map<String, int>> appendSkill;

  // see db.gamedata.costumes
  // @deprecated
  // List<Map<String, int>> dress;

  ItemCost({
    required this.ascension,
    required this.skill,
    required this.appendSkill,
  });

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);
}
