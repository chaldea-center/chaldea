import 'dart:math';
import 'dart:typed_data';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:chaldea/utils/extension.dart';
import 'network.dart';

abstract class FakerAgent<TRequest extends FRequestBase, TUser extends AutoLoginData,
    TNetworkManager extends NetworkManagerBase<TRequest, TUser>> {
  final TNetworkManager network;
  FakerAgent({required this.network});

  TUser get user => network.user;

  BattleEntity? curBattle;
  BattleEntity? lastBattle;
  BattleResultData? lastBattleResultData;
  FResponse? lastResp;

  Future<FResponse> gamedataTop({bool checkAppUpdate = true});

  Future<FResponse> loginTop();

  Future<FResponse> homeTop();

  Future<FResponse> followerList(
      {required int32_t questId, required int32_t questPhase, required bool isEnfoceRefresh});

  Future<FResponse> itemRecover({required int32_t recoverId, required int32_t num});

  Future<FResponse> shopPurchase({required int32_t id, required int32_t num, int32_t anotherPayFlag = 0});

  Future<FResponse> shopPurchaseByStone({required int32_t id, required int32_t num});

  Future<FResponse> battleSetup({
    required int32_t questId,
    required int32_t questPhase,
    required int64_t activeDeckId,
    required int64_t followerId,
    required int32_t followerClassId,
    int32_t itemId = 0,
    int32_t boostId = 0,
    int32_t enemySelect = 0,
    int32_t questSelect = 0,
    int64_t userEquipId = 0,
    required int32_t followerType,
    List<int> routeSelect = const [],
    int32_t followerRandomLimitCount = 0, //?
    String choiceRandomLimitCounts = "{}",
    int32_t followerSpoilerProtectionLimitCount = 4, //?
    required int32_t followerSupportDeckId,
    int32_t campaignItemId = 0,
    int32_t restartWave = 0,
  });

  Future<FResponse> battleResult({
    required int64_t battleId,
    required BattleResultType battleResult, // 0-none,1-win,2-lose,3-retire
    required BattleWinResultType winResult, // 1 or 1
    String scores = "",
    required BattleDataActionList action,
    List<List<int>> voicePlayedArray = const [], // [[svtId, x],...]
    List<int> aliveUniqueIds = const [], // add this if retire/fail
    List<BattleRaidResult> raidResult = const [],
    List<BattleSuperBossResult> superBossResult = const [],
    int32_t elapsedTurn = 1,
    required List<int32_t> usedTurnArray, // win 001, retire 100
    int32_t recordType = 1,
    Map<String, Object> recordJson = const {
      "turnMaxDamage": 0,
      "knockdownNum": 0,
      "totalDamageToAliveEnemy": 0,
    },
    List<Map<String, Object>> firstNpPlayList = const [],
    List<PlayerServantNoblePhantasmUsageDataEntity> playerServantNoblePhantasmUsageData =
        const [], // []/ [{"svtId":403500,"followerType":0,"seqId":403500,"addCount":3}]"
    // required  PlayerServantNoblePhantasmUsageData playerServantNoblePhantasmUsageData,
    Map<int, int> usedEquipSkillDict = const {},
    Map<int, int> svtCommonFlagDict = const {},
    List<int32_t> skillShiftUniqueIdArray = const [],
    List<int64_t> skillShiftNpcSvtIdArray = const [],
    List<int32_t> calledEnemyUniqueIdArray = const [],
    List<int32_t> routeSelectIdArray = const [],
    List<int32_t> dataLostUniqueIdArray = const [],
    List waveInfos = const [],
  });

  // extended

  Future<FResponse> battleSetupWithOptions(AutoBattleOptions options) async {
    final region = network.user.region;
    final quest = db.gameData.quests[options.questId];
    final mstData = network.mstData;
    if (quest == null) {
      throw Exception('quest ${options.questId} not found');
    }
    if (!quest.phases.contains(options.questPhase)) {
      throw Exception('Invalid phase ${options.questPhase}');
    }
    final userQuest = mstData.userQuest[quest.id];
    if (userQuest != null && userQuest.questPhase > options.questPhase) {
      throw Exception('Latest phase: ${userQuest.questPhase}, cannot start phase ${options.questPhase}');
    }
    if (mstData.userDeck[options.deckId] == null) {
      throw Exception('Deck ${options.deckId} not found');
    }
    final questPhaseEntity = await AtlasApi.questPhase(options.questId, options.questPhase, region: region);
    if (questPhaseEntity == null) {
      throw Exception('Quest ${options.questId}/${options.questPhase} not found');
    }
    final curAp = mstData.user!.calCurAp();
    if (questPhaseEntity.consumeType.useAp) {
      final consume = options.isHpHalf ? quest.consume ~/ 2 : quest.consume;
      if (curAp < consume) {
        throw Exception('AP not enough: $curAp<${questPhaseEntity.consume}');
      }
    }
    if (questPhaseEntity.consumeType.useItem) {
      for (final item in questPhaseEntity.consumeItem) {
        final itemNum = mstData.getItemNum(item.itemId);
        if (itemNum < item.amount) {
          throw Exception('Item not enough: $itemNum<${item.amount}');
        }
      }
    }

    int campaignItemId = 0;
    if (options.useCampaignItem) {
      List<UserItemEntity> campaignItems = [];
      final now = DateTime.now().timestamp;
      for (final userItem in mstData.userItem) {
        if (userItem.num <= 0) continue;
        final jpItem = db.gameData.items[userItem.itemId];
        if (jpItem != null && jpItem.type != ItemType.friendshipUpItem) continue;
        final item = region == Region.jp ? jpItem : await AtlasApi.item(userItem.itemId, region: region);
        if (item == null || item.type != ItemType.friendshipUpItem) continue;
        if (item.startedAt < now && item.endedAt > now) {
          campaignItems.add(userItem);
        }
      }
      if (campaignItems.isEmpty) {
        throw Exception('no valid Teapot item found');
      }
      print("Teapot count: ${{for (final x in campaignItems) x.itemId: x.num}}");
      if (campaignItems.length > 1) {
        throw Exception('multiple Teapot items found, why??? (${campaignItems.map((e) => e.itemId).join("/")})');
      }
      campaignItemId = campaignItems.single.itemId;
    }

    final (follower, followerSvt) = await _getValidSupport(
      questId: options.questId,
      questPhase: options.questPhase,
      useEventDeck: options.useEventDeck,
      enforceRefreshSupport: options.enfoceRefreshSupport,
      supportSvtIds: options.supportSvtIds.toList(),
      supportEquipIds: options.supportCeIds.toList(),
      supportEquipMaxLimitBreak: options.supportCeMaxLimitBreak,
    );

    // print({
    //   "questId": options.questId,
    //   "questPhase": options.questPhase,
    //   "activeDeckId": options.deckId,
    //   "followerId": follower.userId,
    //   "followerClassId": followerSvt.classId,
    //   "followerType": follower.type,
    //   "followerSupportDeckId": followerSvt.supportDeckId,
    // });
    return battleSetup(
      questId: options.questId,
      questPhase: options.questPhase,
      activeDeckId: options.deckId,
      followerId: follower.userId,
      followerClassId: followerSvt.classId,
      followerType: follower.type,
      followerSupportDeckId: followerSvt.supportDeckId,
      campaignItemId: campaignItemId,
    );
  }

  Future<(FollowerInfo follower, ServantLeaderInfo followerSvt)> _getValidSupport({
    required int questId,
    required int questPhase,
    required bool useEventDeck,
    required bool enforceRefreshSupport,
    required List<int> supportSvtIds,
    required List<int> supportEquipIds,
    required bool supportEquipMaxLimitBreak,
  }) async {
    int refreshCount = 0;
    List<FollowerInfo> followers = [];
    if (network.gameTop.region == Region.cn && !enforceRefreshSupport) {
      final oldUserFollower =
          network.mstData.userFollower.firstWhereOrNull((e) => e.expireAt > DateTime.now().timestamp + 300);
      if (oldUserFollower != null) {
        followers = oldUserFollower.followerInfo;
      }
    }
    while (true) {
      if (refreshCount > 0) followers.clear();
      if (followers.isEmpty) {
        if (refreshCount > 20) {
          throw Exception('After $refreshCount times refresh, no support svt is valid');
        }
        final resp = await followerList(
            questId: questId, questPhase: questPhase, isEnfoceRefresh: enforceRefreshSupport || refreshCount > 0);
        if (refreshCount > 0) {
          await Future.delayed(const Duration(seconds: 5));
        }
        followers = resp.data.mstData.userFollower.first.followerInfo;
      }
      refreshCount += 1;

      for (final follower in followers) {
        // skip FollowerType.follow
        if (follower.type != FollowerType.friend.value && follower.type != FollowerType.notFriend.value) {
          continue;
        }
        for (final svt in useEventDeck ? follower.eventUserSvtLeaderHash : follower.userSvtLeaderHash) {
          if (supportSvtIds.isNotEmpty && !supportSvtIds.contains(svt.svtId)) {
            continue;
          }
          if (supportEquipIds.isNotEmpty && !supportEquipIds.contains(svt.equipTarget1?.svtId)) {
            continue;
          }
          if (supportEquipMaxLimitBreak && svt.equipTarget1?.limitCount != 4) continue;
          return (follower, svt);
        }
      }
    }
  }

  Future<FResponse> battleResultWithOptions({
    required BattleEntity battleEntity,
    required BattleResultType resultType,
    required String actionLogs,
    List<int> usedTurnArray = const [],
  }) async {
    final stageCount = battleEntity.battleInfo!.enemyDeck.length;
    if (resultType == BattleResultType.cancel) {
      return battleResult(
        battleId: battleEntity.id,
        battleResult: BattleResultType.cancel,
        winResult: BattleWinResultType.none,
        action: BattleDataActionList(
            logs: "", dt: battleEntity.battleInfo!.enemyDeck.first.svts.map((e) => e.uniqueId).toList()),
        usedTurnArray: List.generate(stageCount, (i) => i == 0 ? 1 : 0),
        aliveUniqueIds: battleEntity.battleInfo!.enemyDeck.expand((e) => e.svts).map((e) => e.uniqueId).toList(),
      );
    } else if (resultType == BattleResultType.win) {
      final quest =
          await AtlasApi.questPhase(battleEntity.questId, battleEntity.questPhase, region: network.gameTop.region);
      final _usedTurnArray = List.generate(stageCount, (index) {
        int baseTurn = index == stageCount - 1 ? 1 : 0;
        final enemyCount = battleEntity.battleInfo!.enemyDeck.getOrNull(index)?.svts.length;
        if (enemyCount != null) {
          final posCount = quest?.stages.getOrNull(index)?.enemyFieldPosCountReal ?? 3;
          baseTurn += (enemyCount / posCount).ceil().clamp(1, 10) - 1;
        }
        return baseTurn;
      });
      usedTurnArray = [
        for (final (index, v) in _usedTurnArray.indexed) (usedTurnArray.getOrNull(index) ?? 0).clamp(v, 999),
      ];
      final totalTurns = Maths.sum(usedTurnArray.map((e) => max(1, e)));
      if (actionLogs.isEmpty) {
        actionLogs = List<String>.generate(totalTurns, (i) => const ['1B2B3B', '1B1D2C', '1B1C2B'][i % 3]).join('');
      }
      if (!RegExp(r'^' + (r'[123][BCD]' * totalTurns * 3) + r'$').hasMatch(actionLogs)) {
        throw Exception('Invalid action logs or not match turn length: $usedTurnArray, $actionLogs');
      }
      List<BattleRaidResult> raidResults = [];
      final enemies = battleEntity.battleInfo?.enemyDeck.expand((e) => e.svts).toList() ?? [];
      final userSvtIdMap = {
        for (final userSvt in battleEntity.battleInfo?.userSvt ?? <BattleUserServantData>[]) userSvt.id: userSvt,
      };
      for (final enemy in enemies) {
        final raidDay1 = enemy.enemyScript?['raid'] as int?;
        if (raidDay1 == null) continue;
        final userSvt = userSvtIdMap[enemy.userSvtId]!;
        final raidDay =
            battleEntity.battleInfo?.raidInfo.firstWhereOrNull((e) => e.uniqueId == enemy.uniqueId)?.day ?? -1;
        assert(raidDay1 == raidDay, 'raid day mismatch: $raidDay1 != $raidDay');
        raidResults.add(BattleRaidResult(
          uniqueId: enemy.uniqueId,
          day: raidDay,
          addDamage: userSvt.hp,
        ));
      }
      return battleResult(
        battleId: battleEntity.id,
        battleResult: BattleResultType.win,
        winResult: BattleWinResultType.normal,
        action: BattleDataActionList(
          logs: actionLogs,
          dt: battleEntity.battleInfo!.enemyDeck.last.svts.map((e) => e.uniqueId).toList(),
        ),
        usedTurnArray: usedTurnArray,
        raidResult: raidResults,
        aliveUniqueIds: [],
      );
    } else {
      throw Exception('resultType=$resultType not supported');
    }
  }

  Future<FResponse> terminalApSeedExchange(int32_t buyCount) {
    // TerminalApSeedExchangeManager__OnSelectExchangeItems
    // shop 13000000
    // item_103 + 40AP
    return shopPurchase(id: 13000000, num: buyCount, anotherPayFlag: 0);
  }
}

// PlayerServantNoblePhantasmUsageData
class PlayerServantNoblePhantasmUsageDataEntity {
  int svtId;
  int followerType;
  int seqId;
  int addCount;
  PlayerServantNoblePhantasmUsageDataEntity({
    required this.svtId,
    required this.followerType,
    required this.seqId,
    required this.addCount,
  });

  Map<String, int> getSaveData() {
    return {
      "svtId": svtId,
      "followerType": followerType,
      "seqId": seqId,
      "addCount": addCount,
    };
  }
}

class BattleDataActionList {
  // commandhistory(uniqueId+commadtype): 1B2B3B1B1D2C1B1C2B
  String logs;
  // current wave's enemy info("u"+uniqueId): u13u14u15
  List<int> dt;
  String hd;
  String data;

  BattleDataActionList({
    required this.logs,
    required this.dt,
    this.hd = "",
    this.data = "",
  });
  // { \"logs\":\"1B2B3B1B1D2C1B1C2B\", \"dt\":\"u13u14u15\", \"hd\":\"\", \"data\":\"\" }
  String getSaveData() {
    final dtStr = dt.map((e) => 'u$e').join();
    return """{ "logs":"$logs", "dt":"$dtStr", "hd":"$hd", "data":"$data" }""";
  }
}

class BitConverter {
  static List<int> getInt32(int32_t value) {
    final data = ByteData(4)..setInt32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  static List<int> getInt64(int64_t value) {
    final data = ByteData(8)..setInt64(0, value, Endian.little);
    return data.buffer.asUint8List();
  }
}
