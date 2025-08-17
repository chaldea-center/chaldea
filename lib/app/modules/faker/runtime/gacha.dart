part of '../state.dart';

extension FakerRuntimeGacha on FakerRuntime {
  Future<void> loopFpGachaDraw() async {
    final initCount = agent.user.gacha.loopCount;
    while (agent.user.gacha.loopCount > 0) {
      _checkStop();
      displayToast('Draw FP gacha ${initCount - agent.user.gacha.loopCount + 1}/$initCount...');
      await fpGachaDraw(hundredDraw: agent.user.gacha.hundredDraw);
      agent.user.gacha.loopCount -= 1;
      update();

      final counts = mstData.countSvtKeep();
      final userGame = mstData.user!;
      if (counts.svtCount >= userGame.svtKeep + 100 ||
          counts.ccCount >= gameData.timerData.constants.maxUserCommandCode + 100) {
        await sellServant();
      }
      if (counts.svtEquipCount >= userGame.svtEquipKeep + 100) {
        await svtEquipCombine(30);
      }
    }
  }

  Future<void> fpGachaDraw({bool hundredDraw = false}) async {
    final counts = mstData.countSvtKeep();
    final userGame = mstData.user!;
    if (counts.svtCount >= userGame.svtKeep + 100) {
      throw SilentException('${S.current.servant}: ${counts.svtCount}>=${userGame.svtKeep}+100');
    }
    if (counts.svtEquipCount >= userGame.svtEquipKeep + 100) {
      throw SilentException('${S.current.craft_essence}: ${counts.svtEquipCount}>=${userGame.svtEquipKeep}+100');
    }
    if (counts.ccCount >= gameData.timerData.constants.maxUserCommandCode + 100) {
      throw SilentException(
        '${S.current.command_code}: ${counts.ccCount}>=${gameData.timerData.constants.maxUserCommandCode}+100',
      );
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
    int drawNum = 10;
    final userGacha = mstData.userGacha[option.gachaId];
    if (hundredDraw && userGacha != null && userGacha.freeDrawAt > 0) {
      final freeDrawAt = DateTime.fromMillisecondsSinceEpoch(
        userGacha.freeDrawAt * 1000,
        isUtc: true,
      ).add(Duration(hours: region.timezone));
      final now = DateTime.now().toUtc().add(Duration(hours: region.timezone));
      if (now.isAfter(freeDrawAt) && now.timestamp < freeDrawAt.timestamp + kSecsPerDay && now.day == freeDrawAt.day) {
        drawNum = 100;
      }
    }
    final resp = await agent.gachaDraw(gachaId: option.gachaId, num: drawNum, gachaSubId: option.gachaSubId);
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

  Future<void> storyFreeDraw(int gachaId) async {
    final gacha = gameData.timerData.gachas.firstWhereOrNull((e) => e.id == gachaId);
    if (gacha == null) {
      throw SilentException('Gacha $gachaId not found');
    }
    final gachaName = '$gachaId-${gacha.lName}';
    final userGacha = mstData.userGacha[gachaId];
    if (userGacha == null) {
      throw SilentException('User Gacha not found: $gachaName');
    }
    if (gacha.freeDrawFlag <= 0) {
      throw SilentException('Not free gacha: $gachaName');
    }
    final now = DateTime.now().timestamp;
    if (gacha.openedAt > now || gacha.closedAt <= now) {
      throw SilentException('Gacha not open: $gachaName');
    }

    int resetHourUTC;
    switch (gacha.type) {
      case GachaType.freeGacha:
        resetHourUTC = region.fpFreeGachaResetUTC;
      case GachaType.payGacha:
        resetHourUTC = region.storyFreeGachaResetUTC;
      default:
        throw SilentException('Not free story gacha: ${gacha.type}');
    }

    final nextFreeDraw = DateTimeX.findNextHourAt(userGacha.freeDrawAt, resetHourUTC);
    if (nextFreeDraw >= now) {
      throw SilentException('Already free draw today, next free draw at ${nextFreeDraw.sec2date().toStringShort()}');
    }
    // agent.gachaDraw;
    throw UnimplementedError('Paid gacha not supported');
  }

  Future<void> sellServant() async {
    List<UserServantEntity> sellUserSvts = [];
    List<UserCommandCodeEntity> sellCommandCodes = [];
    final timeLimit = DateTime.now().timestamp - 3600 * 36;
    sellUserSvts.addAll(
      mstData.userSvt.where((userSvt) {
        final entity = db.gameData.entities[userSvt.svtId];
        if (userSvt.locked ||
            userSvt.lv != 1 ||
            entity == null ||
            userSvt.createdAt < timeLimit ||
            agent.user.gacha.sellKeepSvtIds.contains(userSvt.svtId)) {
          return false;
        }
        if (entity.type == SvtType.combineMaterial && entity.rarity <= 3) return true;
        final svt = db.gameData.servantsById[userSvt.svtId];
        if (svt == null || svt.rarity > 3 || svt.rarity == 0) return false;
        if (!svt.obtains.contains(SvtObtain.friendPoint)) return false;
        return true;
      }),
    );

    final equippedCC = mstData.userSvtCommandCode.expand((e) => e.userCommandCodeIds).toSet();
    sellCommandCodes.addAll(
      mstData.userCommandCode.where((userCC) {
        final cc = db.gameData.commandCodesById[userCC.commandCodeId];
        if (userCC.locked || cc == null || cc.rarity > 2 || equippedCC.contains(userCC.id)) return false;
        if (userCC.createdAt < timeLimit) return false;
        return true;
      }),
    );
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
      gachaResultStat.lastSellServants.sort(
        (a, b) => SvtFilterData.compareId(
          a.svtId,
          b.svtId,
          keys: const [SvtCompare.rarity, SvtCompare.className],
          reversed: const [true, false],
        ),
      );
    }
    update();
  }
}
