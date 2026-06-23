part of '../runtime.dart';

class FakerCondCheck {
  final FakerRuntime runtime;
  final MasterDataManager mstData;
  FakerCondCheck(this.runtime) : mstData = runtime.agent.network.mstData;

  bool? isCondOpen2(CondType condType, List<int> targetIds, int targetNum) {
    // for unknown, call isCondOpen(condType, targetIds[0], 0 );
    if (targetIds.isEmpty) return false;
    if (targetIds.length == 1) {
      return isCondOpen(condType, targetIds.single, targetNum);
    }

    switch (condType) {
      case .none:
        return true;
      case .forceFalse:
        return false;
      case .unknown:
        return null;
      case .eventMissionClear:
      case .eventMissionAchieve:
      case .purchaseShop:
      case .svtHaving:
      case .questAvailable:
      case .svtGet:
      case .svtGroup:
      case .event:
      case .purchaseQpShop:
      case .purchaseStoneShop:
      case .questClear:
        int count = 0;
        for (final targetId in targetIds) {
          final v = isCondOpen(condType, targetId, 0);
          if (v == null) return null;
          if (v) count += 1;
        }
        return count >= targetNum;
      case .questClearNum:
        return mstData.helper.getQuestClearCountFromIds(targetIds) >= targetNum;
      case .questClearNumEqual:
        return mstData.helper.getQuestClearCountFromIds(targetIds) == targetNum;
      case .questClearNumBelow:
        return mstData.helper.getQuestClearCountFromIds(targetIds) <= targetNum;
      case .questChallengeNum:
        return mstData.helper.getQuestChallengeCountFromIds(targetIds) >= targetNum;
      case .questChallengeNumEqual:
        return mstData.helper.getQuestChallengeCountFromIds(targetIds) == targetNum;
      case .questChallengeNumBelow:
        return mstData.helper.getQuestChallengeCountFromIds(targetIds) <= targetNum;
      case .questNotClear:
      case .notShopPurchase:
      case .notSvtGet:
      case .notSvtHaving:
        int count = 0;
        final cond2 = CondType.getNegativeSideCond(condType);
        if (cond2 == null) {
          assert(false, '$condType: getNegativeSideCond return null');
          return null;
        }
        for (final targetId in targetIds) {
          if (isCondOpen(cond2, targetId, 0) == true) {
            count++;
          }
        }
        return count < targetNum;
      default:
        return isCondOpen(condType, targetIds[0], 0);
    }
  }

  bool? isCondOpen(CondType condType, int targetId, int condValue) {
    switch (condType) {
      case .none:
        return true;
      case .forceFalse:
        return false;
      case .unknown:
        return null;
      case .questClear:
        return isQuestClear(targetId, beforeClearQuestId: condValue, isCheckResetFlag: false);
      case .itemGet:
        final userItem = mstData.userItem[targetId];
        return userItem != null && userItem.num >= condValue;
      case .svtLevel:
        return isServantLevel(targetId, condValue);
      case .svtLimit:
        return isServantLimit(targetId, condValue);
      case .svtGet:
        return isServantGet(targetId);
      case .svtFriendship:
        return isServantFriendShip(targetId, condValue);
      case .purchaseQpShop:
      case .purchaseStoneShop:
        return isPurchaseQpOrStoneShop(targetId, null);
      case .missionConditionDetail:
        return isMissionCondDetail(targetId, condValue);
      case .eventMissionClear:
        return isMissionClear(targetId);
      case .eventMissionAchieve:
        return isMissionAchieve(targetId);
      case .questClearNum:
        return isQuestClearNum(targetId, condValue);
      case .questChallengeNum:
        return mstData.helper.getQuestChallengeCountFromIds([targetId]) >= condValue;
      case .purchaseShop:
        return isPurchaseShop(targetId, num: 1);
      case .svtHaving:
        return isServantHaving(targetId);
      case .questChallengeNumEqual:
        return mstData.helper.getQuestChallengeCountFromIds([targetId]) == condValue;
      case .questChallengeNumBelow:
        return mstData.helper.getQuestChallengeCountFromIds([targetId]) <= condValue;
      case .questClearPhase:
        return isQuestPhaseClear(targetId, condValue);
      case .notQuestClearPhase:
        return !isQuestPhaseClear(targetId, condValue, isCheckResetFlag: true);
      case .costumeGet:
        return isCostumeGet(targetId, condValue);
      case .questNotClearAnd:
        return isQuestClear(targetId, beforeClearQuestId: condValue, isCheckResetFlag: false);
      case .eventScriptPlay:
        return isEventScriptFlagChecked(targetId, condValue);
      case .svtCostumeReleased:
        return isReleaseCostume(targetId, condValue);
      case .playerGenderType:
        return isPlayerGenderType(targetId);
      case .date:
        return DateTime.now().timestamp > condValue;
      case .commandCodeGet:
        return mstData.userCommandCodeCollection[targetId]?.isGet == true;
      case CondType.equipGet:
        return mstData.userEquip.any((e) => e.equipId == targetId);

      case .shopReleased:
        // targetId=shopGroupId
        break;
      case .svtGroup:
      case .event:
        break;

      default:
        break;
    }

    const _kKnownNegativeConds = <CondType>{
      .notSvtGet,
      .notSvtHaving,
      .notCommandCodeGet,
      .notEquipGet,
      .notItemGet,
      .questNotClear,
      .notQuestClearPhase,
      .notCostumeGet,
      .notSvtGroup,
      .notQuestClearRaw,
      .notQuestGroupClearRaw,
      .notEventMissionClear,
      .notEventMissionAchieve,
      .notSvtCostumeReleased,
      .notShopPurchase,
      .notEventStatus,
    };
    if (_kKnownNegativeConds.contains(condType)) {
      final cond2 = CondType.getNegativeSideCond(condType);
      if (cond2 != null) {
        final result = isCondOpen(cond2, targetId, condValue);
        if (result != null) {
          return !result;
        }
        assert(false, '$condType ->negative $cond2, result null');
      }
    }

    return null;
  }

  bool? isOpenForShop(CondType condType, List<int> targetIds, int targetNum) {
    switch (condType) {
      case .none:
        return true;
      case .forceFalse:
        return false;
      case .unknown:
        return null;
      case .purchaseShop:
        return isShopPurchase(targetIds, targetNum);
      case .notShopPurchase:
        return isNotShopPurchase(targetIds);
      case .questNotClearAnd:
        return isQuestNotClearAndCond(targetIds);
      default:
        return isCondOpen2(condType, targetIds, targetNum);
    }
  }

  bool _testSvtCollection(int svtId, bool Function(UserServantCollectionEntity collection) test) {
    final collection = mstData.userSvtCollection[svtId];
    return collection != null && test(collection);
  }

  // bool _testUserSvt(int svtId, bool Function(UserServantEntity svt) test) {
  //   return mstData.userSvt.followedBy(mstData.userSvtStorage).any((e) => e.svtId == svtId && test(e));
  // }

  int? getEventMissionProgressNum(CondType condType, List<int> targetIds, int targetNum) {
    switch (condType) {
      case CondType.missionConditionDetail:
        final condDetailId = targetIds.firstOrNull ?? 0;
        return mstData.userEventMissionCondDetail[condDetailId]?.progressNum ?? 0;
      case CondType.eventMissionClear:
      case CondType.eventMissionAchieve:
        return targetIds.where((mid) {
          int? progressType;
          final mission = runtime.gameData.timerData.eventMissions[mid];
          if (mission != null && mission.type == .daily) {
            for (final cond in mission.conds) {
              if (cond.missionProgressType == .clear &&
                  cond.condType == .missionConditionDetail &&
                  cond.targetIds.isNotEmpty) {
                final userCondDetail = mstData.userEventMissionCondDetail[cond.targetIds.first];
                if (userCondDetail == null) continue;
                if (runtime.region.getDateTimeByOffset(userCondDetail.updatedAt).day !=
                    runtime.region.getDateTimeByOffset(DateTime.now().timestamp).day) {
                  // not same day
                  progressType = MissionProgressType.none.value;
                } else {
                  progressType = userCondDetail.progressNum >= cond.targetNum
                      ? MissionProgressType.achieve.value
                      : MissionProgressType.none.value;
                }
                break;
              }
            }
          }
          progressType ??= mstData.userEventMission[mid]?.missionProgressType;
          if (progressType == null) return false;
          if (progressType == MissionProgressType.achieve.value) return true;
          if (progressType == MissionProgressType.clear.value && condType == .eventMissionClear) return true;
          return false;
        }).length;
      case CondType.questClear:
        return targetIds.where(mstData.isQuestClear).length;
      default:
        return null;
    }
  }

  MissionProgressType getEventMissionProgress(int eventMissionId) {
    final mission = runtime.gameData.timerData.eventMissions[eventMissionId];
    // TODO: check daily updatedAt
    if (mission != null && mission.type == .daily) {
      for (final cond in mission.conds) {
        if (cond.missionProgressType != .clear || cond.targetIds.isEmpty) {
          continue;
        }
        if (cond.condType == .missionConditionDetail) {
          final userCondDetail = mstData.userEventMissionCondDetail[cond.targetIds.first];
          if (userCondDetail == null) continue;
          if (runtime.region.getDateTimeByOffset(userCondDetail.updatedAt).day !=
              runtime.region.getDateTimeByOffset(DateTime.now().timestamp).day) {
            // not same day
            return MissionProgressType.none;
          }

          int? progressNum = mstData.userEventMissionCondDetail[cond.targetIds.first]?.progressNum;
          return progressNum != null && progressNum >= cond.targetNum
              ? MissionProgressType.achieve
              : MissionProgressType.none;
        } else if (cond.condType == .eventMissionClear) {
          return cond.targetIds.where((targetId) => getEventMissionProgress(targetId).isClearOrAchieve).length >=
                  cond.targetNum
              ? MissionProgressType.achieve
              : MissionProgressType.none;
        }
      }
    }
    final progress = mstData.userEventMission[eventMissionId]?.missionProgressType;
    if (progress == null) return MissionProgressType.none;
    return MissionProgressType.fromValue(progress);
  }

  // details

  bool isQuestClear(int condQuestId, {int beforeClearQuestId = -1, bool isCheckResetFlag = false}) {
    final userQuest = mstData.userQuest[condQuestId];
    if (userQuest == null) return false;
    if (isCheckResetFlag && userQuest.hasStatusFlag(.reset)) {
      return false;
    }
    // skip check IsResetInterval
    int clearNum = userQuest.getClearNum();
    if (beforeClearQuestId > 0 && beforeClearQuestId == condQuestId) {
      clearNum = 0;
    }
    return clearNum > 0;
  }

  bool isQuestClearNum(int condId, int condVal) {
    final entity = mstData.userQuest[condId];
    return entity != null && entity.getClearNum() >= condVal;
  }

  bool isQuestPhaseClear(
    int condQuestId,
    int condQuestPhase, {
    int beforeClearQuestId = -1,
    bool isCheckResetFlag = false,
  }) {
    if (condQuestPhase <= 0) {
      return isQuestClear(condQuestId, beforeClearQuestId: beforeClearQuestId, isCheckResetFlag: isCheckResetFlag);
    }
    final entity = mstData.userQuest[condQuestId];
    if (entity == null) return false;
    if (isCheckResetFlag && entity.hasStatusFlag(.reset)) return false;
    int phase = entity.getQuestPhase();
    if (beforeClearQuestId > 0 && beforeClearQuestId == condQuestId) {
      phase--;
    }
    return phase >= condQuestPhase;
  }

  bool isQuestEnable(int openQuestId, int closeQuestId) {
    if (openQuestId > 0) {
      final entity = mstData.userQuest[openQuestId];
      if (entity == null) return false;
      if (entity.getClearNum() <= 0) return false;
    }
    if (closeQuestId > 0) {
      final entity2 = mstData.userQuest[closeQuestId];
      if (entity2 != null && entity2.getClearNum() > 0) return false;
    }
    return true;
  }

  bool isServantLevel(int svtId, int condLv) {
    return _testSvtCollection(svtId, (e) => e.maxLv >= condLv);
  }

  bool isUserServantLimit(int userSvtId, int condLimitCount) {
    final userSvt = mstData.userSvt[userSvtId] ?? mstData.userSvtStorage[userSvtId];
    return userSvt != null && userSvt.limitCount >= condLimitCount;
  }

  bool isServantLimit(int svtId, int condLimitCount) {
    return _testSvtCollection(svtId, (e) => e.maxLimitCount >= condLimitCount);
  }

  bool isServantGet(int svtId) {
    return _testSvtCollection(svtId, (e) => e.isGet);
  }

  // bool isUserServantGet(int userSvtId){
  //   return false;
  // }

  bool isServantHaving(int svtId, {bool checkPresentBox = true}) {
    for (final userSvt in mstData.userSvtAndStorage) {
      // check baseSvtId==svtId
      if (userSvt.svtId == svtId) return true;
    }
    if (checkPresentBox) {
      for (final present in mstData.userPresentBox) {
        if (present.giftType == GiftType.servant.value && present.objectId == svtId) {
          return true;
        }
      }
    }
    return false;
  }

  bool isServantFriendShip(int svtId, int condFriendshipRank) {
    return _testSvtCollection(svtId, (e) => e.friendshipRank >= condFriendshipRank);
  }

  // bool isServantGroup(int condGroup);
  // bool isEvent(int condId);

  bool isPurchaseQpOrStoneShop(int shopId, NiceShop? shop) {
    final userShop = mstData.userShop[shopId];
    if (userShop == null) return false;
    shop ??= runtime.gameData.timerData.shops[shopId];
    if (shop != null && shop.limitNum > 0) {
      return userShop.num > shop.limitNum;
    }
    return userShop.num > 0;
  }

  bool isPurchaseShop(int shopId, {int num = 1}) {
    final userShop = mstData.userShop[shopId];
    if (userShop == null) return false;
    return userShop.num >= max(1, num);
  }

  bool isMissionCondDetail(int condId, int condVal) {
    final detail = mstData.userEventMissionCondDetail[condId];
    return detail != null && detail.progressNum >= condVal;
  }

  bool isMissionClear(int eventMissionId) {
    return getEventMissionProgress(eventMissionId).isClearOrAchieve;
  }

  bool isMissionAchieve(int eventMissionId) {
    return getEventMissionProgress(eventMissionId) == .achieve;
  }

  bool isCostumeGet(int svtId, int costumeId) {
    return _testSvtCollection(svtId, (collection) => collection.costumeIds.contains(costumeId));
  }

  bool isReleaseCostume(int svtId, int costumeId) {
    return _testSvtCollection(svtId, (collection) => collection.costumeIds.any((e) => e.abs() == costumeId));
  }

  bool isEventScriptFlagChecked(int eventId, int flagId) {
    final entity = mstData.userEvent[eventId];
    return entity != null && entity.hasScriptFlag(flagId);
  }

  bool isPlayerGenderType(int gender) {
    return mstData.user?.genderType == gender;
  }

  bool isShopPurchase(List<int> shopIds, int num) {
    int num2 = Maths.sum((shopIds.map((e) => mstData.userShop[e]?.num)));
    return num > 0 && num2 == num;
  }

  bool isNotShopPurchase(List<int> shopIds) {
    return shopIds.any((e) => (mstData.userShop[e]?.num ?? 0) == 0);
  }

  bool isQuestNotClearAndCond(List<int> condQuestIds) {
    if (condQuestIds.isNotEmpty) {
      for (final questId in condQuestIds) {
        final entity = mstData.userQuest[questId];
        if (entity != null && entity.getClearNum() > 0) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  // end
}
