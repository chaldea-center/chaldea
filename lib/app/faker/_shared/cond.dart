part of '../runtime.dart';

class FakerCondCheck {
  final FakerRuntime runtime;
  final MasterDataManager mstData;
  FakerCondCheck(this.runtime) : mstData = runtime.agent.network.mstData;

  bool isCondOpen2(CondType condType, List<int> targetIds, int targetNum, {bool defaultResult = true}) {
    switch (condType) {
      case CondType.questNotClearAnd:
        if (targetIds.isEmpty) return false;
        for (final questId in targetIds) {
          if ((mstData.userQuest[questId]?.clearNum ?? 0) > 0) {
            return false;
          }
        }
        return true;
      case CondType.notShopPurchase:
        for (final shopId in targetIds) {
          if ((mstData.userShop[shopId]?.num ?? 0) == 0) return true;
        }
        return false;
      case CondType.purchaseShop:
        int num2 = 0;
        for (final shopId in targetIds) {
          num2 += (mstData.userShop[shopId]?.num ?? 0);
        }
        return targetNum > 0 && num2 == targetNum;
      case CondType.questClear: // {1: [94149606] - 1, 2: [94034014, 94034112] - 2}
        return targetIds.where(isQuestClear).length >= targetNum;
      case CondType.eventMissionClear: // {1: [11861] - 1}
        return targetIds.where((targetId) => mstData.getMissionProgress(targetId).isClearOrAchieve).length >= targetNum;
      case CondType.eventMissionAchieve: // {1: [80576268] - 1}
        return targetIds
                .where((targetId) => mstData.getMissionProgress(targetId) == MissionProgressType.achieve)
                .length >=
            targetNum;
      default:
        break;
    }
    assert(targetIds.length <= 1, '$condType-$targetIds-$targetNum');
    return isCondOpen(condType, targetIds.isEmpty ? 0 : targetIds[0], targetNum, defaultResult: defaultResult);
  }

  bool isCondOpen(CondType condType, int targetId, int condValue, {bool defaultResult = true}) {
    switch (condType) {
      case CondType.svtGet:
        return mstData.userSvtCollection[condValue]?.status == 2;
      case CondType.notSvtHaving:
        return mstData.userSvt.followedBy(mstData.userSvtStorage).every((e) => e.svtId != condValue);
      case CondType.svtHaving:
        return mstData.userSvt.followedBy(mstData.userSvtStorage).any((e) => e.svtId == condValue);
      case CondType.questClear:
        return (mstData.userQuest[condValue]?.clearNum ?? 0) > 0;
      case CondType.questNotClear:
        return (mstData.userQuest[condValue]?.clearNum ?? 0) == 0;
      case CondType.questClearPhase:
        final userQuest = mstData.userQuest[condValue];
        return userQuest != null && userQuest.questPhase >= condValue;
      case CondType.date:
        return DateTime.now().timestamp > condValue;
      case CondType.eventMissionAchieve:
        return mstData.userEventMission[condValue]?.missionProgressType == MissionProgressType.achieve.value;
      case CondType.notEquipGet:
        return mstData.userEquip.every((e) => e.equipId != condValue);
      case CondType.equipGet:
        return mstData.userEquip.any((e) => e.equipId == condValue);
      // case CondType.questGroupClear:
      // case CondType.eventPoint:
      // case CondType.itemGet:
      // case CondType.notSvtCostumeReleased:
      // case CondType.shopGroupLimitNum:
      // case CondType.commonRelease:
      // case CondType.purchaseQpShop:
      // case CondType.shopReleased:
      case CondType.forceFalse:
        return false;
      default:
      //
    }
    return defaultResult;
  }

  int? getProgressNum(CondType condType, List<int> targetIds, int targetNum) {
    switch (condType) {
      case CondType.missionConditionDetail:
        final condDetailId = targetIds.firstOrNull ?? 0;
        return mstData.userEventMissionCondDetail[condDetailId]?.progressNum ?? 0;
      case CondType.eventMissionClear:
        return targetIds.where((mid) {
          final progressType = mstData.userEventMission[mid]?.missionProgressType;
          return progressType == MissionProgressType.clear.value || progressType == MissionProgressType.achieve.value;
        }).length;
      case CondType.eventMissionAchieve:
        return targetIds.where((mid) {
          final progressType = mstData.userEventMission[mid]?.missionProgressType;
          return progressType == MissionProgressType.achieve.value;
        }).length;
      case CondType.questClear:
        return targetIds.where((questId) {
          return (mstData.userQuest[questId]?.clearNum ?? 0) > 0;
        }).length;
      default:
        return null;
    }
  }

  bool isQuestClear(int questId) {
    return (mstData.userQuest[questId]?.clearNum ?? 0) > 0;
  }
}
