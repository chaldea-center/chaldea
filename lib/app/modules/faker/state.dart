import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/faker/shared/network.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FakerRuntime {
  static final Map<AutoLoginData, FakerRuntime> _runtimes = {};
  static final Set<Object> _awakeTasks = {};

  final FakerAgent agent;
  State? _rootState;
  final List<State> _dependencies = [];

  // runtime data
  final runningTask = ValueNotifier<bool>(false);
  final teapots = <int, Item>{};
  GameConstants constants = ConstData.constants;
  // stats
  final totalRewards = <int, int>{};
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();
  List<GachaInfos> lastGachaResult = [];

  FakerRuntime._(this.agent, this._rootState);

  // common
  late final mstData = agent.network.mstData;
  Region get region => agent.user.region;
  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  BuildContext get context => _rootState!.context;
  bool get mounted => _rootState != null && context.mounted;

  void addDependency(State s) {
    if (!_dependencies.contains(s)) _dependencies.add(s);
  }

  void removeDependency(State s) {
    _dependencies.remove(s);
  }

  void update() {
    for (final s in [_rootState, ..._dependencies]) {
      if (s != null && s.mounted) {
        // ignore: invalid_use_of_protected_member
        s.setState(() {});
      }
    }
  }

  Future<T?> _showDialog<T>(Widget child, {bool barrierDismissible = true}) async {
    if (!mounted) return null;
    return child.showDialog(context, barrierDismissible: barrierDismissible);
  }

  // init

  static Future<FakerRuntime> init(AutoLoginData user, State state) async {
    final top = (await showEasyLoading(AtlasApi.gametopsRaw))?.of(user.region);
    if (top == null) {
      throw SilentException('fetch game data failed');
    }
    final previous = _runtimes[user];
    if (previous != null && previous.mounted) {
      throw SilentException('Another window has already opened user (${user.serverName} ${user.userGame?.name})');
    }
    if (!state.mounted) {
      throw SilentException('Context already disposed');
    }
    if (previous != null) {
      previous._rootState = state;
      return previous;
    }
    final FakerAgent agent = switch (user) {
      AutoLoginDataJP() => FakerAgentJP.s(gameTop: top, user: user),
      AutoLoginDataCN() => FakerAgentCN.s(gameTop: top, user: user),
    };
    return _runtimes[user] = FakerRuntime._(agent, state);
  }

  Future<void> loadInitData() async {
    // teapots
    if (teapots.isEmpty) {
      List<Item> items;
      if (agent.user.region == Region.jp) {
        items = db.gameData.items.values.toList();
      } else {
        items = (await AtlasApi.exportedData(
              'nice_item',
              (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
              region: region,
            )) ??
            [];
      }
      final now = DateTime.now().timestamp;
      for (final item in items) {
        if (item.type == ItemType.friendshipUpItem && item.endedAt > now) {
          teapots[item.id] = item;
        }
      }
    }
    // constants
    if (region == Region.jp) {
      constants = ConstData.constants;
    } else {
      final v = await AtlasApi.exportedData('NiceConstant', (v) => GameConstants.fromJson(v), region: region);
      if (v != null) {
        constants = v;
      }
    }
    update();
  }

  void dispose() {
    _rootState = null;
  }

  // task

  void lockTask(VoidCallback callback) {
    if (runningTask.value) {
      _showDialog(SimpleCancelOkDialog(
        title: Text(S.current.error),
        content: const Text("task is till running"),
        hideCancel: true,
      ));
      return;
    }
    callback();
    update();
  }

  Future<void> runTask(Future Function() task) async {
    if (runningTask.value) {
      _showDialog(SimpleCancelOkDialog(
        title: Text(S.current.error),
        content: const Text("previous task is till running"),
        hideCancel: true,
      ));
      return;
    }
    try {
      runningTask.value = true;
      EasyLoading.show();
      update();
      await task();
      EasyLoading.dismiss();
    } catch (e, s) {
      logger.e('task failed', e, s);
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        EasyLoading.dismiss();
        _showDialog(
          SimpleCancelOkDialog(
            title: Text(S.current.error),
            scrollable: true,
            content: Text(e is SilentException ? e.message.toString() : e.toString()),
            hideCancel: true,
          ),
          barrierDismissible: false,
        );
      } else {
        EasyLoading.showError(e.toString());
      }
    } finally {
      runningTask.value = false;
    }
    update();
  }

  Future<T> withWakeLock<T>(Object tag, Future<T> Function() task) async {
    try {
      WakelockPlus.enable();
      _awakeTasks.add(tag);
      return await task();
    } finally {
      _awakeTasks.remove(tag);
      if (_awakeTasks.isEmpty) {
        WakelockPlus.disable();
      }
    }
  }

  // agents

  Future<void> startLoop() async {
    if (agent.curBattle != null) {
      throw SilentException('last battle not finished');
    }
    final battleOption = this.battleOption;
    if (battleOption.loopCount <= 0) {
      throw SilentException('loop count (${battleOption.loopCount}) must >0');
    }
    if (battleOption.targetDrops.values.any((v) => v <= 0)) {
      throw SilentException('loop target drop num must >0');
    }
    if (battleOption.winTargetItemNum.values.any((v) => v <= 0)) {
      throw SilentException('win target drop num must >0');
    }
    if (battleOption.recoverIds.isNotEmpty && battleOption.waitApRecover) {
      throw SilentException('Do not turn on both apple recover and wait AP recover');
    }
    final questPhaseEntity =
        await AtlasApi.questPhase(battleOption.questId, battleOption.questPhase, region: agent.user.region);
    if (questPhaseEntity == null) {
      throw SilentException('quest not found');
    }
    if (battleOption.loopCount > 1 &&
        !(questPhaseEntity.afterClear == QuestAfterClearType.repeatLast &&
            battleOption.questPhase == questPhaseEntity.phases.lastOrNull)) {
      throw SilentException('Not repeatable quest or phase');
    }
    final now = DateTime.now().timestamp;
    if (questPhaseEntity.openedAt > now || questPhaseEntity.closedAt < now) {
      throw SilentException('quest not open');
    }
    if (battleOption.winTargetItemNum.isNotEmpty && !questPhaseEntity.flags.contains(QuestFlag.actConsumeBattleWin)) {
      throw SilentException('Win target drops should be used only if Quest has flag actConsumeBattleWin');
    }
    final shouldUseEventDeck = db.gameData.others.shouldUseEventDeck(questPhaseEntity.id);
    if (battleOption.useEventDeck != null && battleOption.useEventDeck != shouldUseEventDeck) {
      throw SilentException('This quest should set "Use Event Deck"=$shouldUseEventDeck');
    }
    int finishedCount = 0, totalCount = battleOption.loopCount;
    List<int> elapseSeconds = [];
    curLoopDropStat.reset();
    EasyLoading.showProgress(finishedCount / totalCount, status: 'Battle $finishedCount/$totalCount');
    while (finishedCount < totalCount) {
      _checkStop();
      checkSvtKeep();
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption);
      }

      final int startTime = DateTime.now().timestamp;
      final msg =
          'Battle ${finishedCount + 1}/$totalCount, ${Maths.mean(elapseSeconds).round()}s/${(Maths.sum(elapseSeconds) / 60).toStringAsFixed(1)}m';
      logger.t(msg);
      EasyLoading.showProgress((finishedCount + 0.5) / totalCount, status: msg);

      await _ensureEnoughApItem(quest: questPhaseEntity, option: battleOption);

      update();

      final setupResp = await agent.battleSetupWithOptions(battleOption);
      update();

      final battleEntity = setupResp.data.mstData.battles.single;
      final curBattleDrops = battleEntity.battleInfo?.getTotalDrops() ?? {};
      logger.t('battle id: ${battleEntity.id}');

      bool shouldRetire = false;
      FResponse resultResp;
      if (battleOption.winTargetItemNum.isNotEmpty) {
        shouldRetire = true;
        for (final (itemId, targetNum) in battleOption.winTargetItemNum.items) {
          if ((curBattleDrops[itemId] ?? 0) >= targetNum) {
            shouldRetire = false;
            break;
          }
        }
      }

      if (shouldRetire) {
        await Future.delayed(const Duration(seconds: 4));
        resultResp = await agent.battleResultWithOptions(
          battleEntity: battleEntity,
          resultType: BattleResultType.cancel,
          actionLogs: "",
        );
      } else {
        final delay = battleOption.battleDuration ?? (agent.network.gameTop.region == Region.cn ? 40 : 20);
        await Future.delayed(Duration(seconds: delay));
        resultResp = await agent.battleResultWithOptions(
          battleEntity: battleEntity,
          resultType: BattleResultType.win,
          actionLogs: battleOption.actionLogs,
        );
        // if win
        totalDropStat.totalCount += 1;
        curLoopDropStat.totalCount += 1;
        Map<int, int> resultBattleDrops;
        final lastBattleResultData = agent.lastBattleResultData;
        if (lastBattleResultData != null && lastBattleResultData.battleId == battleEntity.id) {
          resultBattleDrops = {};
          for (final drop in lastBattleResultData.resultDropInfos) {
            resultBattleDrops.addNum(drop.objectId, drop.num);
          }
          for (final reward in lastBattleResultData.rewardInfos) {
            totalRewards.addNum(reward.objectId, reward.num);
          }
          for (final reward in lastBattleResultData.friendshipRewardInfos) {
            totalRewards.addNum(reward.objectId, reward.num);
          }
        } else {
          resultBattleDrops = curBattleDrops;
          logger.t('last battle result data not found, use cur_battle_drops');
        }
        totalDropStat.items.addDict(resultBattleDrops);
        curLoopDropStat.items.addDict(resultBattleDrops);
        totalRewards.addDict(resultBattleDrops);

        // check total drop target of this loop
        if (battleOption.targetDrops.isNotEmpty) {
          for (final (itemId, targetNum) in battleOption.targetDrops.items.toList()) {
            final curDropNum = curLoopDropStat.items[itemId] ?? 0;
            if (curDropNum > 0) {
              battleOption.targetDrops[itemId] = targetNum - curDropNum;
            }
          }
          final reachedItems =
              battleOption.targetDrops.keys.where((itemId) => battleOption.targetDrops[itemId]! <= 0).toList();
          if (reachedItems.isNotEmpty) {
            throw SilentException(
                'Target drop reaches: ${reachedItems.map((e) => GameCardMixin.anyCardItemName(e).l).join(', ')}');
          }
        }
      }
      for (final item in resultResp.data.mstData.userItem) {
        totalRewards.addNum(item.itemId, 0);
      }

      finishedCount += 1;
      battleOption.loopCount -= 1;

      elapseSeconds.add(DateTime.now().timestamp - startTime);
      update();
      await Future.delayed(const Duration(seconds: 2));
      if (battleOption.stopIfBondLimit) {
        _checkFriendship(battleOption);
      }
    }
    logger.t('finished all $finishedCount battles');
    _showDialog(
      SimpleCancelOkDialog(
        title: const Text('Finished'),
        content: Text('$finishedCount battles'),
        hideCancel: true,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> seedWait(final int maxBuyCount) async {
    int boughtCount = 0;
    while (boughtCount < maxBuyCount) {
      const int apUnit = 40, seedUnit = 1;
      final apCount = mstData.user?.calCurAp() ?? 0;
      final seedCount = mstData.getItemOrSvtNum(Items.blueSaplingId);
      if (seedCount <= 0) {
        throw SilentException('no Blue Sapling left');
      }
      int buyCount = Maths.min([maxBuyCount, apCount ~/ apUnit, seedCount ~/ seedUnit]);
      if (buyCount > 0) {
        await agent.terminalApSeedExchange(buyCount);
        boughtCount += buyCount;
      }
      update();
      EasyLoading.show(status: 'Seed $boughtCount/$maxBuyCount - waiting...');
      await Future.delayed(const Duration(minutes: 1));
      _checkStop();
    }
  }

  // gacha

  Future<void> fpGachaDraw() async {
    final counts = mstData.countSvtKeep();
    final userGame = mstData.user!;
    if (counts.svtCount >= userGame.svtKeep + 100) {
      throw SilentException('${S.current.servant}: ${counts.svtCount}>=${userGame.svtKeep}+100');
    }
    if (counts.svtEquipCount >= userGame.svtEquipKeep + 100) {
      throw SilentException('${S.current.craft_essence}: ${counts.svtEquipCount}>=${userGame.svtEquipKeep}+100');
    }
    if (counts.ccCount >= constants.maxUserCommandCode + 100) {
      throw SilentException('${S.current.command_code}: ${counts.ccCount}>=${constants.maxUserCommandCode}+100');
    }
    final fp = mstData.tblUserGame[mstData.user?.userId]?.friendPoint ?? 0;
    if (fp < 2000) {
      throw SilentException('${Items.friendPoint?.lName.l ?? "Friend Point"} <2000');
    }
    final option = agent.user.gacha;
    final gacha = await AtlasApi.gacha(option.gachaId, region: region);
    if (gacha == null) {
      throw SilentException('Gacha ${option.gachaId} not found');
    }
    if (gacha.type != GachaType.freeGacha) {
      throw SilentException('Only FP Gacha supported: ${gacha.type}');
    }
    final resp = await agent.gachaDraw(gachaId: option.gachaId, num: 10, gachaSubId: option.gachaSubId);
    try {
      final infos = resp.data.getResponseNull('gacha_draw')?.success?['gachaInfos'];
      if (infos != null) {
        lastGachaResult = (infos as List).map((e) => GachaInfos.fromJson(e)).toList();
      }
    } catch (e, s) {
      logger.e('parse gacha_infos failed', e, s);
    }
  }

  Future<void> loopFpGachaDraw() async {
    final initCount = agent.user.gacha.loopCount;
    while (agent.user.gacha.loopCount > 0) {
      _checkStop();
      EasyLoading.show(status: 'Draw FP gacha ${initCount - agent.user.gacha.loopCount + 1}/$initCount...');
      await fpGachaDraw();
      agent.user.gacha.loopCount -= 1;
      update();

      final counts = mstData.countSvtKeep();
      final userGame = mstData.user!;
      if (counts.svtCount >= userGame.svtKeep + 100 || counts.ccCount >= constants.maxUserCommandCode + 100) {
        await sellServant();
      }
      if (counts.svtEquipCount >= userGame.svtEquipKeep + 100) {
        await svtEquipCombine(30);
      }
    }
  }

  Future<void> sellServant() async {
    List<int> sellUserSvtIds = [], sellCommandCodes = [];
    final timeLimit = DateTime.now().timestamp - 3600 * 36;
    for (final userSvt in mstData.userSvt) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null || svt.rarity > 3 || svt.rarity == 0 || userSvt.locked) continue;
      if (!svt.obtains.contains(SvtObtain.friendPoint)) continue;
      if (userSvt.createdAt < timeLimit) continue;
      sellUserSvtIds.add(userSvt.id);
    }
    final equippedCC = mstData.userSvtCommandCode.expand((e) => e.userCommandCodeIds).toSet();
    for (final userCC in mstData.userCommandCode) {
      final cc = db.gameData.commandCodesById[userCC.commandCodeId];
      if (userCC.locked || cc == null || cc.rarity > 2 || equippedCC.contains(userCC.id)) continue;
      if (userCC.createdAt < timeLimit) continue;
      sellCommandCodes.add(userCC.id);
    }
    sellUserSvtIds.sort2((e) => -e);
    sellUserSvtIds = sellUserSvtIds.take(200).toList();
    sellCommandCodes.sort2((e) => -e);
    sellCommandCodes = sellCommandCodes.take(100).toList();
    EasyLoading.show(status: 'Sell ${sellUserSvtIds.length} servants, ${sellCommandCodes.length} Command Codes');
    if (sellUserSvtIds.isNotEmpty || sellCommandCodes.isNotEmpty) {
      await agent.sellServant(servantUserIds: sellUserSvtIds, commandCodeUserIds: sellCommandCodes);
    }
    update();
  }

  Future<void> svtEquipCombine([int count = 1]) async {
    final gachaOption = agent.user.gacha;
    EasyLoading.show(status: 'Combine Craft Essence ...');
    while (count > 0) {
      final targetCEs = mstData.userSvt.where((userSvt) {
        final ce = db.gameData.craftEssencesById[userSvt.svtId];
        if (ce == null) return false;
        if (!userSvt.locked) return false;
        final maxLv = userSvt.maxLv;
        if (maxLv == null || userSvt.lv >= maxLv - 1) return false;
        if (gachaOption.ceEnhanceBaseUserSvtIds.contains(userSvt.id)) return true;
        if (gachaOption.ceEnhanceBaseSvtIds.contains(userSvt.svtId)) {
          return userSvt.limitCount == 4;
        }
        return false;
      }).toList();
      if (targetCEs.isEmpty) {
        throw SilentException('No valid Target Craft Essence');
      }
      targetCEs.sort2((e) => e.lv);
      final targetCE = targetCEs.first;
      final combineCEs = mstData.userSvt.where((userSvt) {
        final ce = db.gameData.craftEssencesById[userSvt.svtId];
        if (ce == null || userSvt.locked || userSvt.lv != 1) return false;
        final bool isExp = ce.flags.contains(SvtFlag.svtEquipExp);
        if (ce.rarity > 4) {
          return false;
        } else if (ce.rarity == 4) {
          return gachaOption.feedExp4 && isExp;
        } else if (ce.rarity == 3) {
          if (isExp) {
            return gachaOption.feedExp3;
          }
          return ce.obtain == CEObtain.permanent;
        } else {
          return true;
        }
      }).toList();
      combineCEs.sort2((e) => -e.createdAt);
      if (combineCEs.isEmpty) {
        update();
        return;
      }
      final combineCEIds = combineCEs.take(20).map((e) => e.id).toList();
      await agent.servantEquipCombine(baseUserSvtId: targetCE.id, materialSvtIds: combineCEIds);
      count -= 1;
      update();
    }
  }

  // helpers

  void _checkStop() {
    if (agent.network.stopFlag) {
      agent.network.stopFlag = false;
      throw SilentException('Manual Stop');
    }
  }

  void checkSvtKeep() {
    final counts = mstData.countSvtKeep();
    final user = mstData.user!;
    if (counts.svtCount >= user.svtKeep) {
      throw SilentException('${S.current.servant}: ${counts.svtCount}>=${user.svtKeep}');
    }
    if (counts.svtEquipCount >= user.svtEquipKeep) {
      throw SilentException('${S.current.craft_essence}: ${counts.svtEquipCount}>=${user.svtEquipKeep}');
    }
    if (counts.ccCount >= constants.maxUserCommandCode) {
      throw SilentException('${S.current.command_code}: ${counts.ccCount}>=${constants.maxUserCommandCode}');
    }
  }

  void _checkFriendship(AutoBattleOptions option) {
    final svts = mstData.userDeck[battleOption.deckId]!.deckInfo?.svts ?? [];
    for (final svt in svts) {
      if (svt.userSvtId > 0) {
        final userSvt = mstData.userSvt[svt.userSvtId];
        if (userSvt == null) {
          throw SilentException('UserSvt ${svt.userSvtId} not found');
        }
        final dbSvt = db.gameData.servantsById[userSvt.svtId];
        if (dbSvt == null) {
          throw SilentException('Unknown Servant ID ${userSvt.svtId}');
        }
        final svtCollection = mstData.userSvtCollection[userSvt.svtId];
        if (svtCollection == null) {
          throw SilentException('UserServantCollection ${userSvt.svtId} not found');
        }
        if (dbSvt.type == SvtType.heroine) continue;
        final maxBondLv = 10 + svtCollection.friendshipExceedCount;
        if (svtCollection.friendshipRank >= maxBondLv) {
          throw SilentException('Svt No.${dbSvt.collectionNo} ${dbSvt.lName.l} reaches max bond Lv.$maxBondLv');
        }
      }
    }
  }

  Future<void> _ensureEnoughApItem({required QuestPhase quest, required AutoBattleOptions option}) async {
    if (quest.consumeType.useItem) {
      for (final item in quest.consumeItem) {
        final own = mstData.getItemOrSvtNum(item.itemId);
        if (own < item.amount) {
          throw SilentException('Consume Item not enough: ${item.itemId}: $own<${item.amount}');
        }
      }
    }
    if (quest.consumeType.useAp) {
      final apConsume = option.isApHalf ? quest.consume ~/ 2 : quest.consume;
      if (mstData.user!.calCurAp() >= apConsume) {
        return;
      }
      for (final recoverId in option.recoverIds) {
        final recover = mstRecovers[recoverId];
        if (recover == null) continue;
        if (recover.recoverType == RecoverType.stone && mstData.user!.stone > 0) {
          await agent.shopPurchaseByStone(id: recover.targetId, num: 1);
          break;
        } else if (recover.recoverType == RecoverType.item) {
          final item = db.gameData.items[recover.targetId];
          if (item == null) continue;
          if (item.type == ItemType.apAdd) {
            final count = ((apConsume - mstData.user!.calCurAp()) / item.value).ceil();
            if (count > 0 && count < mstData.getItemOrSvtNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          } else if (item.type == ItemType.apRecover) {
            final count =
                ((apConsume - mstData.user!.calCurAp()) / (item.value / 1000 * mstData.user!.actMax).ceil()).ceil();
            if (count > 0 && count < mstData.getItemOrSvtNum(item.id)) {
              await agent.itemRecover(recoverId: recoverId, num: count);
              break;
            }
          }
        } else {
          continue;
        }
      }
      if (mstData.user!.calCurAp() >= quest.consume) {
        return;
      }
      if (option.waitApRecover) {
        while (mstData.user!.calCurAp() < quest.consume) {
          update();
          EasyLoading.show(status: 'Battle - waiting AP recover...');
          await Future.delayed(const Duration(minutes: 1));
          _checkStop();
        }
        return;
      }
      throw SilentException('AP not enough: ${mstData.user!.calCurAp()}<${quest.consume}');
    }
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
