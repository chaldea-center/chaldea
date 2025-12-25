import 'package:chaldea/app/faker/runtime.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'network.dart';

class FakerAgentData {
  final mstData_ = MasterDataManager();

  // login result
  final loginResultData = LoginResultData();

  LoginResultData? updateLoginResult(FateTopLogin resp) {
    LoginResultData? result;
    for (final response in resp.responses) {
      if (!response.isSuccess()) continue;
      final success = response.success ?? {};
      if (LoginResultData.fieldMap.values.any(success.containsKey)) {
        try {
          result = LoginResultData.fromJson(success);
          result.updateServerTime(resp.serverTime?.timestamp);
          loginResultData.mergeLoginBonus(result);
        } catch (e) {
          logger.e('LoginResultData parse failed in nid [${response.nid}]');
        }
      }
    }
    return result;
  }

  // battle
  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  BattleResultData? lastBattleWinResultData;
  FResponse? lastResp;

  final battleTotalRewards = <int, int>{};
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();

  void onBattleSetup(FResponse resp) {
    final battleEntity = resp.data.mstData.battles.firstOrNull;
    if (battleEntity != null) {
      lastBattle = curBattle ?? battleEntity;
      curBattle = battleEntity;
    }
    updateRaidInfo(battleSetupResp: resp);
  }

  void onBattleResult(FResponse resp) {
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

  // raid
  Map<int, Map<int, EventRaidInfoRecord>> raidRecords = {};

  EventRaidInfoRecord getRaidRecord(int eventId, int day) =>
      raidRecords.putIfAbsent(eventId, () => {}).putIfAbsent(day, () => EventRaidInfoRecord());

  void updateRaidInfo({FResponse? homeResp, FResponse? battleSetupResp, FResponse? battleTurnResp}) {
    final now = DateTime.now().timestamp;
    // home top
    if (homeResp != null) {
      for (final eventRaid in homeResp.data.mstData.mstEventRaid) {
        getRaidRecord(eventRaid.eventId, eventRaid.day).eventRaid = eventRaid;
      }
      for (final totalRaid in homeResp.data.mstData.totalEventRaid) {
        final record = getRaidRecord(totalRaid.eventId, totalRaid.day);
        record.totalRaid = totalRaid;
        record.history.add((
          timestamp: homeResp.data.serverTime?.timestamp ?? now,
          raidInfo: BattleRaidInfo(
            day: totalRaid.day,
            uniqueId: 0,
            maxHp: record.eventRaid?.maxHp ?? 0,
            totalDamage: totalRaid.totalDamage,
          ),
          battleId: null,
        ));
      }

      // shrink
      const raidHistoryMaxLength = 100;
      for (final record in raidRecords.values.expand((e) => e.values)) {
        if (record.history.length > raidHistoryMaxLength) {
          record.history.removeRange(0, record.history.length - raidHistoryMaxLength);
        }
      }
    }
    // battle setup
    final battleEntity = battleSetupResp?.data.mstData.battles.firstOrNull;
    final setupRaidInfos = battleEntity?.battleInfo?.raidInfo ?? [];
    if (battleEntity != null && setupRaidInfos.isNotEmpty) {
      for (final raid in setupRaidInfos) {
        getRaidRecord(battleEntity.eventId, raid.day).history.add((
          timestamp: battleSetupResp?.data.serverTime?.timestamp ?? now,
          raidInfo: raid,
          battleId: battleEntity.id,
        ));
      }
    }
    // battle turn
    final turnSuccess = battleTurnResp?.data.getResponseNull('battle_turn')?.success;
    if (battleTurnResp != null && turnSuccess != null) {
      final raidInfos = (turnSuccess['raidInfo'] as List?) ?? [];
      final battleId = int.tryParse(battleTurnResp.request.params['battleId'] ?? '');
      if (battleId != null) {
        int? eventId;
        for (final (eId, records) in raidRecords.items) {
          if (records.values.expand((e) => e.history).any((e) => e.battleId == battleId)) {
            eventId = eId;
            break;
          }
        }
        if (eventId != null) {
          for (final rawRaid in raidInfos) {
            final raid = BattleRaidInfo.fromJson(Map<String, dynamic>.from(rawRaid as Map));
            getRaidRecord(eventId, raid.day).history.add((
              timestamp: battleTurnResp.data.serverTime?.timestamp ?? now,
              raidInfo: raid,
              battleId: battleId,
            ));
          }
        }
      }
    }
  }

  // gacha
  final gachaResultStat = _GachaDrawStatData();

  // event
  final randomMissionStat = _RandomMissionLoopStat();
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
