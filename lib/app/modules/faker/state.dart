import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/faker/cn/agent.dart';
import 'package:chaldea/models/faker/jp/agent.dart';
import 'package:chaldea/models/faker/shared/agent.dart';
import 'package:chaldea/models/faker/shared/network.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class FakerRuntime {
  static final Map<AutoLoginData, FakerRuntime> _runtimes = {};
  static final Set<Object> _awakeTasks = {};

  final FakerAgent agent;
  final _FakerGameData gameData;
  FakerRuntime._(this.agent) : gameData = _FakerGameData(agent.user.region);

  // runtime data
  final runningTask = ValueNotifier<bool>(false);
  final activeToast = ValueNotifier<String?>(null);
  // stats - battle
  final totalRewards = <int, int>{};
  final totalDropStat = _DropStatData();
  final curLoopDropStat = _DropStatData();
  // stats - gacha
  final gachaResultStat = _GachaDrawStatData();

  // common
  late final mstData = agent.network.mstData;
  Region get region => agent.user.region;
  AutoBattleOptions get battleOption => agent.user.curBattleOption;

  final Map<State, bool> _dependencies = {}; // <state, isRoot>

  BuildContext? get context => _dependencies.keys.firstWhereOrNull((e) => e.mounted)?.context;
  bool get mounted => context != null;
  bool get hasMultiRoots => _dependencies.values.where((e) => e).length > 1;

  void addDependency(State s) {
    if (!_dependencies.containsKey(s)) _dependencies[s] = false;
  }

  void removeDependency(State s) {
    _dependencies.remove(s);
  }

  void update() async {
    await null; // in case called during parent build?
    for (final s in _dependencies.keys) {
      if (s.mounted) {
        // ignore: invalid_use_of_protected_member
        s.setState(() {});
      }
    }
  }

  void displayToast(String? msg, {double? progress}) {
    activeToast.value = msg;
    if (db.settings.fakerSettings.showProgressToast) {
      if (progress == null) {
        EasyLoading.show(status: msg);
      } else {
        EasyLoading.showProgress(progress, status: msg);
      }
    }
  }

  void dismissToast() {
    activeToast.value = null;
    EasyLoading.dismiss();
  }

  Future<T?> _showDialog<T>(Widget child, {bool barrierDismissible = true}) async {
    BuildContext? ctx;
    for (final state in _dependencies.keys) {
      if (state.mounted && AppRouter.of(state.context) == router) {
        ctx = state.context;
      }
    }
    if (ctx == null) {
      for (final state in _dependencies.keys) {
        if (state.mounted) {
          ctx = state.context;
        }
      }
    }
    if (ctx == null) return null;
    return child.showDialog(ctx, barrierDismissible: barrierDismissible);
  }

  // init

  static Future<FakerRuntime> init(AutoLoginData user, State state) async {
    final top = (await showEasyLoading(AtlasApi.gametopsRaw))?.of(user.region);
    if (top == null) {
      throw SilentException('fetch game data failed');
    }

    if (!state.mounted) {
      throw SilentException('Context already disposed');
    }

    FakerRuntime runtime = _runtimes.putIfAbsent(user, () {
      final FakerAgent agent = switch (user) {
        AutoLoginDataJP() => FakerAgentJP.s(gameTop: top, user: user),
        AutoLoginDataCN() => FakerAgentCN.s(gameTop: top, user: user),
      };
      return FakerRuntime._(agent);
    });
    runtime._dependencies[state] = true;
    return runtime;
  }

  Future<void> loadInitData() async {
    await gameData.init();
    update();
  }

  void dispose(State state) {
    _dependencies.remove(state);
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

  Future<void> runTask(Future Function() task, {bool check = true}) async {
    if (check && runningTask.value) {
      _showDialog(SimpleCancelOkDialog(
        title: Text(S.current.error),
        content: const Text("previous task is till running"),
        hideCancel: true,
      ));
      return;
    }
    try {
      if (check) runningTask.value = true;
      displayToast('running task...');
      update();
      await task();
      dismissToast();
    } catch (e, s) {
      logger.e('task failed', e, s);
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        dismissToast();
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
      if (check) runningTask.value = false;
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
    // if (battleOption.targetDrops.values.any((v) => v < 0)) {
    //   throw SilentException('loop target drop num must >=0 (0=always)');
    // }
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
    agent.network.lastTaskStartedAt = 0;
    displayToast('Battle $finishedCount/$totalCount', progress: finishedCount / totalCount);
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
      displayToast(msg, progress: (finishedCount + 0.5) / totalCount);

      await _ensureEnoughApItem(quest: questPhaseEntity, option: battleOption);

      update();
      if (questPhaseEntity.flags.contains(QuestFlag.noBattle) && questPhaseEntity.stages.isNotEmpty) {
        throw SilentException('noBattle flag but ${questPhaseEntity.stages.length} stages');
      }
      FResponse setupResp;
      try {
        setupResp = await agent.battleSetupWithOptions(battleOption);
      } on NidCheckException catch (e, s) {
        if (e.nid == 'battle_setup' && e.detail?.resCode == '99' && e.detail?.fail?['errorType'] == 0) {
          logger.e('battle setup failed with nid check, retry', e, s);
          await Future.delayed(Duration(seconds: 10));
          setupResp = await agent.battleSetupWithOptions(battleOption);
        } else {
          rethrow;
        }
      }
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

      if (questPhaseEntity.flags.contains(QuestFlag.raid)) {
        await agent.battleTurn(battleId: battleEntity.id);
      }

      if (shouldRetire) {
        await Future.delayed(const Duration(seconds: 1));
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
            final dropNum = resultBattleDrops[itemId];
            if (dropNum == null || dropNum <= 0) continue;
            battleOption.targetDrops[itemId] = targetNum - dropNum;
          }
          final reachedItems = battleOption.targetDrops.keys
              .where((itemId) => resultBattleDrops.containsKey(itemId) && battleOption.targetDrops[itemId]! <= 0)
              .toList();
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
      if (questPhaseEntity.flags.contains(QuestFlag.raid) && finishedCount % 5 == 1) {
        // update raid info
        await agent.homeTop();
      }
      update();
      await Future.delayed(const Duration(milliseconds: 100));
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
      displayToast('Seed $boughtCount/$maxBuyCount - waiting...');
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
    if (counts.ccCount >= gameData.constants.maxUserCommandCode + 100) {
      throw SilentException(
          '${S.current.command_code}: ${counts.ccCount}>=${gameData.constants.maxUserCommandCode}+100');
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
        gachaResultStat.lastDrawResult = (infos as List).map((e) => GachaInfos.fromJson(e)).toList();
        gachaResultStat.totalCount += gachaResultStat.lastDrawResult.length;
        for (final info in gachaResultStat.lastDrawResult) {
          gachaResultStat.servants.addNum(info.objectId, info.num);
          if (info.svtCoinNum > 0 && info.type == GiftType.servant.value) {
            gachaResultStat.coins.addNum(info.objectId, info.svtCoinNum);
          }
        }
      }
    } catch (e, s) {
      logger.e('parse gacha_infos failed', e, s);
    }
  }

  Future<void> loopFpGachaDraw() async {
    final initCount = agent.user.gacha.loopCount;
    while (agent.user.gacha.loopCount > 0) {
      _checkStop();
      displayToast('Draw FP gacha ${initCount - agent.user.gacha.loopCount + 1}/$initCount...');
      await fpGachaDraw();
      agent.user.gacha.loopCount -= 1;
      update();

      final counts = mstData.countSvtKeep();
      final userGame = mstData.user!;
      if (counts.svtCount >= userGame.svtKeep + 100 || counts.ccCount >= gameData.constants.maxUserCommandCode + 100) {
        await sellServant();
      }
      if (counts.svtEquipCount >= userGame.svtEquipKeep + 100) {
        await svtEquipCombine(30);
      }
    }
  }

  Future<void> sellServant() async {
    List<UserServantEntity> sellUserSvts = [];
    List<UserCommandCodeEntity> sellCommandCodes = [];
    final timeLimit = DateTime.now().timestamp - 3600 * 36;
    sellUserSvts.addAll(mstData.userSvt.where((userSvt) {
      final entity = db.gameData.entities[userSvt.svtId];
      if (userSvt.locked ||
          userSvt.lv != 1 ||
          entity == null ||
          userSvt.createdAt < timeLimit ||
          agent.user.gacha.sellKeepSvtIds.contains(userSvt.svtId)) return false;
      if (entity.type == SvtType.combineMaterial && entity.rarity <= 3) return true;
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt == null || svt.rarity > 3 || svt.rarity == 0) return false;
      if (!svt.obtains.contains(SvtObtain.friendPoint)) return false;
      return true;
    }));

    final equippedCC = mstData.userSvtCommandCode.expand((e) => e.userCommandCodeIds).toSet();
    sellCommandCodes.addAll(mstData.userCommandCode.where((userCC) {
      final cc = db.gameData.commandCodesById[userCC.commandCodeId];
      if (userCC.locked || cc == null || cc.rarity > 2 || equippedCC.contains(userCC.id)) return false;
      if (userCC.createdAt < timeLimit) return false;
      return true;
    }));
    sellUserSvts.sort2((e) => -e.id);
    sellUserSvts = sellUserSvts.take(200).toList();
    sellCommandCodes.sort2((e) => -e.id);
    sellCommandCodes = sellCommandCodes.take(100).toList();
    displayToast('Sell ${sellUserSvts.length} servants, ${sellCommandCodes.length} Command Codes');
    if (sellUserSvts.isNotEmpty || sellCommandCodes.isNotEmpty) {
      await agent.sellServant(
        servantUserIds: sellUserSvts.map((e) => e.id).toList(),
        commandCodeUserIds: sellCommandCodes.map((e) => e.id).toList(),
      );
      gachaResultStat.lastSellServants = sellUserSvts.toList();
      gachaResultStat.lastSellServants.sort((a, b) => SvtFilterData.compareId(a.svtId, b.svtId,
          keys: const [SvtCompare.rarity, SvtCompare.className], reversed: const [true, false]));
    }
    update();
  }

  Future<void> svtEquipCombine([int count = 1]) async {
    final gachaOption = agent.user.gacha;
    displayToast('Combine Craft Essence ...');
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
      List<UserServantEntity> combineMaterialCEs = mstData.userSvt.where((userSvt) {
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
      combineMaterialCEs.sort2((e) => -e.createdAt);
      if (combineMaterialCEs.isEmpty) {
        update();
        return;
      }
      combineMaterialCEs = combineMaterialCEs.take(20).toList();
      await agent.servantEquipCombine(
          baseUserSvtId: targetCE.id, materialSvtIds: combineMaterialCEs.map((e) => e.id).toList());
      count -= 1;
      gachaResultStat.lastEnhanceBaseCE = targetCE;
      gachaResultStat.lastEnhanceMaterialCEs = combineMaterialCEs.toList();
      gachaResultStat.lastEnhanceMaterialCEs.sort(
          (a, b) => CraftFilterData.compare(a.dbCE, b.dbCE, keys: const [CraftCompare.rarity], reversed: const [true]));
      update();
    }
  }

  // box gacha
  Future<void> boxGachaDraw({required EventLottery lottery, required int num, required Ref<int> loopCount}) async {
    final boxGachaId = lottery.id;
    while (loopCount.value > 0) {
      final userBoxGacha = mstData.userBoxGacha[boxGachaId];
      if (userBoxGacha == null) throw SilentException('BoxGacha $boxGachaId not in user data');
      final maxNum = lottery.getMaxNum(userBoxGacha.boxIndex);
      if (userBoxGacha.isReset && userBoxGacha.drawNum == maxNum) {
        await agent.boxGachaReset(gachaId: boxGachaId);
        update();
        continue;
      }
      // if (userBoxGacha.isReset) throw SilentException('isReset=true, not tested');
      num = min(num, maxNum - userBoxGacha.drawNum);
      if (userBoxGacha.resetNum <= 10 && num > 10) {
        throw SilentException('Cannot draw $num times in first 10 lotteries');
      }
      final ownItemCount = mstData.userItem[lottery.cost.itemId]?.num ?? 0;
      if (ownItemCount < lottery.cost.amount) {
        throw SilentException('Item noy enough: $ownItemCount');
      }
      num = min(num, ownItemCount ~/ lottery.cost.amount);
      if (num <= 0 || num > 100) {
        throw SilentException('Invalid draw num: $num');
      }
      if (mstData.userPresentBox.length >= (gameData.constants.maxPresentBoxNum - 10)) {
        throw SilentException('Present Box Full');
      }
      await agent.boxGachaDraw(gachaId: boxGachaId, num: num);
      loopCount.value -= 1;
      update();
    }
  }

  //
  Future<void> svtCombine({int? loopCount}) async {
    final options = agent.user.svtCombine;
    while ((loopCount ?? options.loopCount) > 0) {
      final UserServantEntity? baseUserSvt = mstData.userSvt[options.baseUserSvtId];
      if (baseUserSvt == null) throw SilentException('user svt ${options.baseUserSvtId} not found');
      final baseSvt = baseUserSvt.dbSvt;
      if (baseSvt == null) throw SilentException('svt ${baseUserSvt.svtId} not found');
      if (baseSvt.rarity == 0 || baseSvt.type != SvtType.normal || baseSvt.collectionNo == 0) {
        throw SilentException('Invalid base svt');
      }
      final maxLv = baseUserSvt.maxLv;
      if (maxLv == null || baseUserSvt.lv >= maxLv) {
        throw SilentException('Lv.${baseUserSvt.lv}>=maxLv $maxLv');
      }
      List<UserServantEntity> candidateMaterialSvts = mstData.userSvt.where((userSvt) {
        final svt = userSvt.dbEntity;
        if (svt == null || svt.type != SvtType.combineMaterial) return false;
        if (userSvt.locked || userSvt.lv != 1) return false;
        if (!options.svtMaterialRarities.contains(svt.rarity)) return false;
        return true;
      }).toList();
      candidateMaterialSvts.sort2((e) => e.dbEntity?.rarity ?? 999);

      List<int> materialSvtIds = [];
      final curLvExp = baseSvt.expGrowth.getOrNull(baseUserSvt.lv - 1),
          nextAsenExp = baseSvt.expGrowth.getOrNull((baseUserSvt.maxLv ?? baseSvt.lvMax) - 1);
      if (curLvExp == null || nextAsenExp == null || curLvExp >= nextAsenExp || curLvExp > baseUserSvt.exp) {
        throw SilentException('no valid exp data found: $curLvExp <= ${baseUserSvt.exp} <= $nextAsenExp');
      }
      int needExp = nextAsenExp - baseUserSvt.exp;
      int totalGetExp = 0, totalUseQp = 0;
      for (final userSvt in candidateMaterialSvts) {
        final svt = userSvt.dbEntity!;
        final sameClass = svt.classId == SvtClass.ALL.value || svt.classId == baseSvt.classId;
        int getExp = (1000 * (pow(3, svt.rarity - 1)) * (sameClass ? 1.2 : 1)).round();
        int useQp = ((100 + (baseUserSvt.lv - 1) * 30) * ([1, 1.5, 2, 4, 6][baseSvt.rarity - 1])).round();
        if (totalGetExp >= needExp || materialSvtIds.length >= options.maxMaterialCount) break;
        if (options.doubleExp) getExp *= 2;
        totalGetExp += getExp;
        totalUseQp += useQp;
        materialSvtIds.add(userSvt.id);
      }

      if (materialSvtIds.isEmpty) {
        throw SilentException('No valid 种火 found');
      }

      await agent.servantCombine(
        baseUserSvtId: options.baseUserSvtId,
        materialSvtIds: materialSvtIds,
        useQp: totalUseQp,
        getExp: totalGetExp,
      );
      if (loopCount != null) {
        loopCount -= 1;
      } else {
        options.loopCount -= 1;
      }
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
    if (counts.ccCount >= gameData.constants.maxUserCommandCode) {
      throw SilentException('${S.current.command_code}: ${counts.ccCount}>=${gameData.constants.maxUserCommandCode}');
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
        int dt = mstData.user!.actRecoverAt - DateTime.now().timestamp;
        if ((recover.id == 1 || recover.id == 2) && option.waitApRecoverGold && dt > 300 && dt % 300 < 240) {
          final waitUntil = DateTime.now().timestamp + dt % 300 + 2;
          while (true) {
            final now = DateTime.now().timestamp;
            if (now >= waitUntil) break;
            displayToast('Wait ${waitUntil - now} seconds...');
            await Future.delayed(Duration(seconds: min(5, waitUntil - now)));
            _checkStop();
          }
        }
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
            if (count > 0 && count <= mstData.getItemOrSvtNum(item.id)) {
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
          displayToast('Battle - waiting AP recover...');
          await Future.delayed(const Duration(minutes: 1));
          _checkStop();
        }
        return;
      }
      throw SilentException('AP not enough: ${mstData.user!.calCurAp()}<${quest.consume}');
    }
  }
}

class _FakerGameData {
  final Region region;
  _FakerGameData(this.region);

  final teapots = <int, Item>{};
  GameConstants constants = ConstData.constants;
  Map<int, MasterMission> masterMissions = {};

  Future<void> init() async {
    // teapots
    if (teapots.isEmpty) {
      List<Item> items;
      if (region == Region.jp) {
        items = db.gameData.items.values.toList();
      } else {
        items = (await AtlasApi.exportedData(
          'nice_item',
          (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
          region: region,
        ))!;
      }
      final now = DateTime.now().timestamp;
      for (final item in items) {
        if (item.type == ItemType.friendshipUpItem && item.endedAt > now) {
          teapots[item.id] = item;
        }
      }
    }
  }

  Future<void> loadConstants() async {
    if (region == Region.jp) {
      constants = ConstData.constants;
    } else {
      final v = await AtlasApi.exportedData('NiceConstant', (v) => GameConstants.fromJson(v), region: region);
      constants = v!;
    }
  }

  Future<void> loadMasterMissions() async {
    final now = DateTime.now().timestamp;
    final mms = (await AtlasApi.masterMissions(region: region))!;
    mms.removeWhere((mm) => mm.startedAt > now + 7 * kSecsPerDay || mm.closedAt < now);
    masterMissions = {for (final mm in mms) mm.id: mm};
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
