part of 'runtime.dart';

class _FakerRuntimeData {
  // battle
  final battleTotalRewards = <int, int>{};
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();
  // gacha
  final gachaResultStat = _GachaDrawStatData();
  final randomMissionStat = _RandomMissionLoopStat();
}

class _FakerGameData {
  final Region region;
  _FakerGameData(this.region);

  GameTimerData timerData = GameTimerData();

  Map<int, Item> get teapots {
    final now = DateTime.now().timestamp;
    return {
      for (final item in timerData.items.values)
        if (item.type == ItemType.friendshipUpItem && item.endedAt > now) item.id: item,
    };
  }

  Future<void> init({GameTop? gameTop, bool refresh = false}) async {
    GameTimerData? _timerData;
    if (gameTop != null && !refresh) {
      final localTimerData = await AtlasApi.timerData(region, expireAfter: kExpireCacheOnly);
      if (localTimerData != null && localTimerData.updatedAt > DateTime.now().timestamp - 3 * kSecsPerDay) {
        if (localTimerData.hash != null && localTimerData.hash == gameTop.hash) {
          _timerData = localTimerData;
        }
      }
    }
    _timerData ??= await AtlasApi.timerData(region, expireAfter: refresh ? Duration.zero : null);
    timerData = _timerData ?? timerData;
  }
}

class _DropStatData {
  int totalCount = 0;
  Map<int, int> items = {};
  // Map<int, int> groups = {};

  void reset() {
    totalCount = 0;
    items.clear();
  }
}

class _GachaDrawStatData {
  int totalCount = 0;
  Map<int, int> servants = {};
  Map<int, int> coins = {}; //<svtId, num>
  List<GachaInfos> lastDrawResult = [];
  UserServantEntity? lastEnhanceBaseCE;
  List<UserServantEntity> lastEnhanceMaterialCEs = [];
  List<UserServantEntity> lastSellServants = [];

  void reset() {
    totalCount = 0;
    servants.clear();
    coins.clear();
    lastDrawResult = [];
    lastEnhanceBaseCE = null;
    lastEnhanceMaterialCEs = [];
    lastSellServants = [];
  }
}

class _RandomMissionLoopStat {
  //
  List<int> randomMissionIds = [];
  Map<int, EventMission> eventMissions = {};
  List<int> itemIds = [];

  List<Quest> cqs0 = [];
  List<Quest> fqs0 = [];
  List<QuestPhase> cqs = [];
  List<QuestPhase> fqs = [];

  BattleResultData? lastBattleResultData;
  Set<int> lastAddedMissionIds = {};
  RandomMissionOption curLoopData = RandomMissionOption();

  Future<void> load(FakerRuntime runtime) async {
    Event? event;
    final now = DateTime.now().timestamp;
    for (final userRandomMission in runtime.mstData.userEventRandomMission) {
      final _event = runtime.gameData.timerData.events[userRandomMission.missionTargetId];
      if (_event != null && _event.startedAt < now && _event.endedAt > now) {
        event = _event;
        break;
      }
    }
    if (event == null) return;
    final maxRank = Maths.max(event.randomMissions.map((e) => e.condNum), 0);
    randomMissionIds = event.randomMissions.where((e) => e.condNum == maxRank).map((e) => e.missionId).toList();
    randomMissionIds.sort();
    final missionMap = {for (final m in event.missions) m.id: m};
    eventMissions = {};
    for (final id in randomMissionIds) {
      final mission = eventMissions[id] = missionMap[id]!;
      itemIds.addAll(mission.gifts.map((e) => e.objectId));
    }
    itemIds = itemIds.toSet().toList();
    itemIds.sort2((e) => db.gameData.items[e]?.priority ?? 0, reversed: true);
    final allQuests = db.gameData.wars[event.warIds.firstOrNull]?.quests ?? [];
    cqs0 = allQuests.where((e) => e.consume == 5 && e.flags.contains(QuestFlag.dropFirstTimeOnly)).toList();
    fqs0 = allQuests.where((e) => e.isAnyFree && e.consume > 0).toList();
  }
}
