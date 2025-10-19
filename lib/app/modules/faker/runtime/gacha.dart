part of '../state.dart';

extension FakerRuntimeGacha on FakerRuntime {
  Future<void> loopFpGachaDraw() async {
    final initCount = agent.user.gacha.loopCount;
    while (agent.user.gacha.loopCount > 0) {
      _checkStop();
      displayToast('Draw FP gacha ${initCount - agent.user.gacha.loopCount + 1}/$initCount...');
      await gachaDraw(hundredDraw: agent.user.gacha.hundredDraw);
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

  bool checkHasFreeGachaDraw(NiceGacha gacha) {
    final now = DateTime.now().timestamp;
    final userGacha = mstData.userGacha[gacha.id];
    return userGacha != null &&
        DateTimeX.findNextHourAt(userGacha.freeDrawAt, region.getGachaResetUTC(gacha.type)) < now;
  }

  Future<void> gachaDraw({bool hundredDraw = false}) async {
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
    final option = agent.user.gacha;
    final gacha =
        gameData.timerData.gachas.firstWhereOrNull((e) => e.id == option.gachaId) ??
        await AtlasApi.gacha(option.gachaId, region: region);
    if (gacha == null) {
      throw SilentException('Gacha ${option.gachaId} not found');
    }
    final now = DateTime.now().timestamp;
    final bool hasFreeDraw = checkHasFreeGachaDraw(gacha);

    int drawNum;

    if (gacha.isFpGacha) {
      final fp = mstData.tblUserGame[mstData.user?.userId]?.friendPoint ?? 0;
      if (fp < 2000) {
        throw SilentException('${Items.friendPoint?.lName.l ?? "Friend Point"} <2000');
      }
      drawNum = hundredDraw && !hasFreeDraw ? 100 : 10;
    } else {
      if (gacha.freeDrawFlag <= 0) {
        throw SilentException('This gacha is not freeDraw gacha');
      }
      if (!hasFreeDraw) {
        throw SilentException('Story gacha has no free draw today!');
      }
      drawNum = 1;
    }

    final FResponse resp;

    if (gacha.isFpGacha) {
      final validSubs = gacha.gachaSubs.where((sub) {
        if (sub.openedAt > now || sub.closedAt <= now) return false;
        bool? condMatch = CommonRelease.check(sub.releaseConditions, (release) {
          if (release.condType == CondType.questClear) {
            return (mstData.userQuest[release.condId]?.clearNum ?? 0) > 0;
          } else if (release.condType == CondType.questNotClear) {
            return (mstData.userQuest[release.condId]?.clearNum ?? 0) <= 0;
          } else if (release.condType == CondType.eventScriptPlay) {
            final userEvent = mstData.userEvent[release.condId];
            return userEvent != null && (userEvent.scriptFlag & (1 << release.condNum) != 0);
          }
          return null;
        });
        if (condMatch == false) return false;
        return true;
      }).toList();
      final gachaSubId = option.gachaSubs[option.gachaId] ?? 0;
      if (validSubs.isEmpty) {
        if (gachaSubId != 0) {
          throw SilentException('No valid gacha sub, gachaSubId should be 0');
        }
      } else {
        int maxPriority = Maths.max(validSubs.map((e) => e.priority));
        final validSub = validSubs.firstWhere((e) => e.priority == maxPriority);
        if (gachaSubId != validSub.id) {
          throw SilentException('Valid gacha sub id should be ${validSub.id}');
        }
      }
      resp = await agent.gachaDraw(gachaId: option.gachaId, num: drawNum, gachaSubId: gachaSubId);
    } else {
      final storyAdjustIds = gacha.storyAdjusts
          .where((adjust) {
            if (adjust.condType == CondType.questClear) {
              if ((mstData.userQuest[adjust.targetId]?.clearNum ?? 0) <= 0) return false;
            } else {
              throw SilentException(
                'Story Adjust cond not supported: ${adjust.condType}-${adjust.targetId}-${adjust.value}',
              );
            }
            return true;
          })
          .map((e) => e.adjustId)
          .toList();
      resp = await agent.gachaDraw(
        gachaId: option.gachaId,
        num: drawNum,
        gachaSubId: 0,
        storyAdjustIds: storyAdjustIds,
        shopIdIdx: 1,
        ticketItemId: 0,
      );
    }

    try {
      final infos = resp.data.getResponseNull('gacha_draw')?.success?['gachaInfos'];
      if (infos != null) {
        gachaResultStat.lastDrawResult = (infos as List).map((e) => GachaInfos.fromJson(e)).toList();
        if (gacha.isFpGacha) {
          gachaResultStat.totalCount += gachaResultStat.lastDrawResult.length;
          for (final info in gachaResultStat.lastDrawResult) {
            gachaResultStat.servants.addNum(info.objectId, info.num);
            if (info.svtCoinNum > 0 && info.type == GiftType.servant.value) {
              gachaResultStat.coins.addNum(info.objectId, info.svtCoinNum);
            }
          }
        }
      }
    } catch (e, s) {
      logger.e('parse gacha_infos failed', e, s);
    }
  }

  Future<void> sellServant() async {
    List<UserServantEntity> sellUserSvts = [];
    List<UserCommandCodeEntity> sellCommandCodes = [];
    final timeLimit = DateTime.now().timestamp - 3600 * 36;
    sellUserSvts.addAll(
      mstData.userSvt.where((userSvt) {
        final entity = db.gameData.entities[userSvt.svtId];
        if (userSvt.isLocked() ||
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
      gachaResultStat.lastSellServants.sort((a, b) => SvtFilterData.compareId(a.svtId, b.svtId));
    }
    update();
  }
}
