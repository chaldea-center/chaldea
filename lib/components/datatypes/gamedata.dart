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
  @protected
  Map<String, Quest> freeQuests;
  Map<int, List<Quest>> svtQuests;
  Map<String, MysticCode> mysticCodes;
  Map<String, Summon> summons;
  PlanningData planningData;
  Map<String, List<EnemyDetail>> categorizedEnemies;
  Map<int, int> fsmSvtIdMapping;

  // Generated
  @JsonKey(ignore: true)
  Map<String, EnemyDetail> enemies = {};

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
    this.mysticCodes = const {},
    this.summons = const {},
    PlanningData? planningData,
    this.categorizedEnemies = const {},
    this.fsmSvtIdMapping = const {},
  })  : events = events ??
            Events(
              limitEvents: {},
              mainRecords: {},
              exchangeTickets: {},
              campaigns: {},
              extraMasterMissions: [],
            ),
        planningData = planningData ??
            PlanningData(
              dropRates: DropRateData(),
              legacyDropRates: DropRateData(),
              weeklyMissions: [],
            ),
        servantsWithUser = Map.of(servants) {
    for (final es in categorizedEnemies.values) {
      for (final e in es) {
        for (final key in [...e.ids, ...e.names]) {
          enemies[EnemyDetail.convertKey(key)] ??= e;
        }
      }
    }
  }

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
    if (freeQuests[key] != null) return freeQuests[key]!;
    for (var quest in freeQuests.values) {
      if (quest.place != null &&
          key.contains(quest.place!) &&
          key.contains(quest.name)) {
        return quest;
      }
      if (fullToHalf(quest.indexKey!) == fullToHalf(key)) {
        return quest;
      }
      return freeQuests.values.firstWhereOrNull(
          (quest) => key == quest.placeJp || key == quest.place);
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

  List<Map<String, int>> get appendSkillWithCoin => [
        {Items.servantCoin: 120},
        ...appendSkill,
      ];

  ItemCost({
    required this.ascension,
    required this.skill,
    required this.appendSkill,
  });

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);
}
