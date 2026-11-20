import 'package:chaldea/app/faker/runtime.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';

import 'network.dart';

class FakerAgentData {
  final mstData_ = MasterDataManager();

  // login result
  final loginResultHistory = <LoginResultData>[];

  // battle
  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  BattleResultData? lastBattleWinResultData;
  FResponse? lastResp;

  final battleTotalRewards = <int, int>{};
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();

  // raid
  Map<int, Map<int, EventRaidInfoRecord>> raidRecords = {};

  // gacha
  final gachaResultStat = _GachaDrawStatData();

  // event
  final randomMissionStat = _RandomMissionLoopStat();

  final treasureBoxStat = _TreasureBoxDrawStat();
  final recipeStat = _RecipeCreateStat();

  // ---------------------------------------------------------------------------
  // response post-processing

  LoginResultData? updateLoginResult(FateTopLogin resp) {
    LoginResultData? result;
    for (final response in resp.responses) {
      if (!response.isSuccess()) continue;
      final success = response.success ?? {};
      if (LoginResultData.fieldMap.values.any(success.containsKey)) {
        try {
          result = LoginResultData.fromJson(success);
          result.updateServerTime(resp.serverTime?.timestamp);
          if (result.isNotEmpty) {
            loginResultHistory.insert(0, result);
          }
        } catch (e) {
          logger.e('LoginResultData parse failed in nid [${response.nid}]');
        }
      }
    }
    return result;
  }

  /// Entry point for response side effects owned by faker state: cache-table
  /// effects first, then per-nid handlers. Each handler is isolated so that one
  /// failure does not prevent the remaining handlers from running.
  void postProcessResponse(FResponse resp) {
    resp.runPostProcess(null, () => _postProcessCacheTables(resp.data));
    for (final detail in resp.data.responses) {
      _postProcessDetail(detail, resp);
    }
  }

  void _postProcessDetail(FateResponseDetail detail, FResponse resp) {
    resp.runPostProcess(detail.nid, () {
      switch (detail.nid) {
        case 'battle_setup':
          _postBattleSetup(detail, resp);
          break;
        case 'battle_resume':
          _postBattleResume(detail, resp);
          break;
        case 'battle_result':
          _postBattleResult(detail, resp);
          break;
        case 'battle_turn':
          _postBattleTurn(detail, resp);
          break;
      }
    });
  }

  void _postBattleSetup(FateResponseDetail detail, FResponse resp) {
    if (!detail.isSuccess()) return;
    _updateCurrentBattle(resp);
  }

  void _postBattleResume(FateResponseDetail detail, FResponse resp) {
    if (!detail.isSuccess()) return;
    _updateCurrentBattle(resp);
  }

  void _postBattleResult(FateResponseDetail detail, FResponse resp) {
    if (!detail.isSuccess()) return;
    lastBattle = curBattle;
    curBattle = null;
    try {
      lastBattleResultData = BattleResultData.fromJson(resp.data.getResponse('battle_result').success!);
      if (lastBattleResultData != null && lastBattleResultData!.battleResult == BattleResultType.win.value) {
        lastBattleWinResultData = lastBattleResultData;
      }
    } catch (e, s) {
      logger.e('parse battle result data failed', e, s);
    }
    mstData_.battles.clear();
  }

  /// Raid progress carried by the `battle_turn` success payload rather than the
  /// cache tables, so it stays a nid-based handler.
  void _postBattleTurn(FateResponseDetail detail, FResponse resp) {
    if (!detail.isSuccess()) return;
    final turnSuccess = resp.data.getResponseNull('battle_turn')?.success;
    if (turnSuccess == null) return;
    final now = DateTime.now().timestamp;
    final raidInfos = (turnSuccess['raidInfo'] as List?) ?? [];
    final battleId = int.tryParse(resp.request.params['battleId'] ?? '');
    if (battleId == null) return;
    int? eventId;
    for (final (eId, records) in raidRecords.items) {
      if (records.values.expand((e) => e.history).any((e) => e.battleId == battleId)) {
        eventId = eId;
        break;
      }
    }
    if (eventId == null) return;
    for (final rawRaid in raidInfos) {
      final raid = BattleRaidInfo.fromJson(Map<String, dynamic>.from(rawRaid as Map));
      getRaidRecord(
        eventId,
        raid.day,
      ).history.add((timestamp: resp.data.serverTime?.timestamp ?? now, raidInfo: raid, battleId: battleId));
    }
  }

  void _updateCurrentBattle(FResponse resp) {
    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity == null) return;
    lastBattle = curBattle ?? battleEntity;
    curBattle = battleEntity;
  }

  EventRaidInfoRecord getRaidRecord(int eventId, int day) =>
      raidRecords.putIfAbsent(eventId, () => {}).putIfAbsent(day, () => EventRaidInfoRecord());

  /// Post-processing driven by master data cache changes. Raid tables such as
  /// `mstEventRaid` and `battles` only exist in the response cache, so these
  /// handlers intentionally do not depend on the response nid.
  void _postProcessCacheTables(FateTopLogin data) {
    final updated = (data.cache['updated'] as Map?) ?? const {};
    final replaced = (data.cache['replaced'] as Map?) ?? const {};
    bool changed(String table) => updated.containsKey(table) || replaced.containsKey(table);

    final now = DateTime.now().timestamp;
    if (changed('mstEventRaid') || changed('totalEventRaid')) {
      _updateRaidInfoFromTables(data, now);
      _shrinkRaidHistory();
    }
    if (changed('battles')) {
      _updateRaidInfoFromBattleSetup(data, now);
    }
  }

  void _updateRaidInfoFromTables(FateTopLogin data, int now) {
    for (final eventRaid in data.mstData.mstEventRaid) {
      getRaidRecord(eventRaid.eventId, eventRaid.day).eventRaid = eventRaid;
    }
    for (final totalRaid in data.mstData.totalEventRaid) {
      final record = getRaidRecord(totalRaid.eventId, totalRaid.day);
      record.totalRaid = totalRaid;
      record.history.add((
        timestamp: data.serverTime?.timestamp ?? now,
        raidInfo: BattleRaidInfo(
          day: totalRaid.day,
          uniqueId: 0,
          maxHp: record.eventRaid?.maxHp ?? 0,
          totalDamage: totalRaid.totalDamage,
        ),
        battleId: null,
      ));
    }
  }

  void _updateRaidInfoFromBattleSetup(FateTopLogin data, int now) {
    final battleEntity = data.mstData.battles.firstOrNull;
    final setupRaidInfos = battleEntity?.battleInfo?.raidInfo ?? [];
    if (battleEntity == null || setupRaidInfos.isEmpty) return;
    for (final raid in setupRaidInfos) {
      getRaidRecord(
        battleEntity.eventId,
        raid.day,
      ).history.add((timestamp: data.serverTime?.timestamp ?? now, raidInfo: raid, battleId: battleEntity.id));
    }
  }

  void _shrinkRaidHistory() {
    const raidHistoryMaxLength = 100;
    for (final record in raidRecords.values.expand((e) => e.values)) {
      if (record.history.length > raidHistoryMaxLength) {
        record.history.removeRange(0, record.history.length - raidHistoryMaxLength);
      }
    }
  }
}

class EventRaidInfoRecord {
  EventRaidEntity? eventRaid;
  List<({int timestamp, BattleRaidInfo raidInfo, int? battleId})> history = [];
  TotalEventRaidEntity? totalRaid;
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
  SummonControlResultData? lastSummonResult;
  UserServantEntity? lastEnhanceBaseCE;
  List<UserServantEntity> lastEnhanceMaterialCEs = [];
  List<UserServantEntity> lastSellServants = [];

  void reset() {
    totalCount = 0;
    servants.clear();
    coins.clear();
    lastSummonResult = null;
    lastEnhanceBaseCE = null;
    lastEnhanceMaterialCEs = [];
    lastSellServants = [];
  }
}

class _RandomMissionLoopStat {
  //
  Event? event;
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
    this.event = event;
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

class _TreasureBoxDrawStat {
  Map<int, int> treasureBoxDrawNums = {};
  Map<int, int> giftCounts = {};
}

class _RecipeCreateStat {
  Map<int, int> recipeCreateNums = {};
  Map<int, int> giftCounts = {};
}
