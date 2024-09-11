import 'dart:convert';

import 'package:chaldea/utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'quest.dart' show Gift;
import 'servant.dart';
import 'skill.dart';

part '../../generated/models/gamedata/const_data.g.dart';

@JsonSerializable(converters: [BuffActionConverter(), ServantSubAttributeConverter()])
class ConstGameData {
  final Map<String, String> cnReplace;
  final Map<ServantSubAttribute, Map<ServantSubAttribute, int>> attributeRelation;
  final Map<BuffAction, BuffActionInfo> buffActions;
  final Map<CardType, Map<int, CardInfo>> cardInfo;
  final Map<int, SvtClassInfo> classInfo;
  final Map<int, Map<int, int>> classRelation;
  final GameConstants constants;
  final GameConstantStr constantStr;
  final Map<int, Map<int, GrailCostDetail>> svtGrailCost; // <rarity, <grail_count, detail>>
  final Map<int, MasterUserLvDetail> userLevel;
  final Map<int, SvtExpCurve> svtExp;
  final Map<int, FuncTypeDetail> funcTypeDetail;
  final Map<int, BuffTypeDetail> buffTypeDetail;
  final List<String> destinyOrderSummons;
  final List<SvtClass> destinyOrderClasses = [...SvtClassX.regular, SvtClass.EXTRA1, SvtClass.EXTRA2];

  final Map<int, int> bondLimitQp = {10: 10000000, 11: 12000000, 12: 14000000, 13: 16000000, 14: 18000000};
  final Map<BuffType, List<BuffAction>> buffTypeActionMap;

  final Map<int, int> svtClassCardImageIdRemap = {
    285: 123,
    351: 223,
  };
  final Map<int, List<SvtLimitHide>> svtLimitHides;
  // <eventId, <buffGroupId, skillNum>>
  //   // summer 2023
  //   80442: {
  //     8044203: 2,
  //     8044202: 3,
  //     8044204: 4,
  //     8044205: 5,
  //     8044201: 6,
  //     8044206: 7,
  //   }
  final Map<int, Map<int, int>> eventPointBuffGroupSkillNumMap;
  final List<int> laplaceUploadAllowAiQuests;
  final List<int> excludeRewardQuests; // when counting war fixed drop and rewards
  final List<int> randomEnemyQuests;
  final Map<int, List<int>> svtFaceLimits;
  final ConstDataConfig config;

  ConstGameData({
    this.cnReplace = const {},
    this.attributeRelation = const {},
    this.buffActions = const {},
    this.cardInfo = const {},
    this.classInfo = const {},
    this.classRelation = const {},
    this.constants = const GameConstants(),
    this.constantStr = const GameConstantStr(),
    this.svtGrailCost = const {},
    this.userLevel = const {},
    this.svtExp = const {},
    this.funcTypeDetail = const {},
    this.buffTypeDetail = const {},
    this.svtLimitHides = const {},
    this.eventPointBuffGroupSkillNumMap = const {},
    this.laplaceUploadAllowAiQuests = const [],
    this.excludeRewardQuests = const [],
    this.randomEnemyQuests = const [],
    this.svtFaceLimits = const {},
    this.config = const ConstDataConfig(),
    this.destinyOrderSummons = const [],
  }) : buffTypeActionMap = {} {
    for (final entry in buffActions.entries) {
      for (final type in [...entry.value.plusTypes, ...entry.value.minusTypes]) {
        buffTypeActionMap.putIfAbsent(type, () => []).add(entry.key);
      }
    }
  }

  List<SvtLimitHide> getSvtLimitHides(int svtId, int? limitCount) {
    Set<SvtLimitHide> hides = {...?svtLimitHides[-1], ...?svtLimitHides[svtId]};
    if (limitCount != null) {
      hides.retainWhere((e) => e.limits.contains(-1) || e.limits.contains(limitCount));
    }
    return hides.toList();
  }

  List<int> getSvtCurve(int growthCurve, int baseValue, int maxValue, int? maxLv) {
    final expData = svtExp[growthCurve];
    if (expData == null) return [];
    // atkBase + (atkMax - atkBase) * exp.curve // 1000
    if (maxLv == null) {
      return expData.curve.skip(1).map((e) => baseValue + (maxValue - baseValue) * e ~/ 1000).toList();
    }
    return [
      for (int index = 1; index < expData.lv.length; index++)
        if (expData.lv[index] <= maxLv) baseValue + (maxValue - baseValue) * expData.curve[index] ~/ 1000
    ];
  }

  int getClassRelation(SvtClass attacker, SvtClass defender) {
    return getClassIdRelation(attacker.value, defender.value);
  }

  int getClassIdRelation(final int attacker, final int defender) {
    return classRelation[classInfo[attacker]?.relationId]?[classInfo[defender]?.relationId] ?? 1000;
  }

  int getAttributeRelation(final ServantSubAttribute attacker, final ServantSubAttribute defender) {
    return attributeRelation[attacker]?[defender] ?? 1000;
  }

  bool isIgnoreValueUpFuncType(FuncType funcType) {
    return funcTypeDetail[funcType.value]?.ignoreValueUp ?? false;
  }

  bool isIgnoreValueUpBuffType(BuffType buffType) {
    return funcTypeDetail[buffType.value]?.ignoreValueUp ?? false;
  }

  factory ConstGameData.fromJson(Map<String, dynamic> json) {
    return _$ConstGameDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ConstGameDataToJson(this);
}

@JsonSerializable()
class ConstDataConfig {
  final String autoLoginMinVerJp;
  final String autoLoginMinVerNa;

  const ConstDataConfig({
    this.autoLoginMinVerJp = '999.999.999',
    this.autoLoginMinVerNa = '2.5.0',
  });

  factory ConstDataConfig.fromJson(Map<String, dynamic> json) => _$ConstDataConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConstDataConfigToJson(this);
}

@JsonSerializable(converters: [BuffTypeConverter(), BuffActionConverter()])
class BuffActionInfo {
  BuffLimit limit;
  List<BuffType> plusTypes;
  List<BuffType> minusTypes;
  int baseParam;
  int baseValue;
  bool isRec;
  BuffAction plusAction; // check .isNotNone (not none or unknown) before using this field
  List<int> maxRate;

  BuffActionInfo({
    required this.limit,
    required this.plusTypes,
    required this.minusTypes,
    required this.baseParam,
    required this.baseValue,
    required this.isRec,
    required this.plusAction,
    required this.maxRate,
  });

  factory BuffActionInfo.fromJson(Map<String, dynamic> json) => _$BuffActionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BuffActionInfoToJson(this);
}

@JsonSerializable()
class SvtClassInfo {
  int id;
  int attri;
  String name;
  int individuality;
  int attackRate;
  int imageId;
  int iconImageId;
  int frameId;
  int priority;
  int groupType;
  int relationId;
  int supportGroup;
  int autoSelSupportType;
  SvtClass? get className => kSvtClassIds[id];

  SvtClassInfo({
    required this.id,
    required this.attri,
    this.name = '',
    this.individuality = 0,
    required this.attackRate,
    required this.imageId,
    required this.iconImageId,
    required this.frameId,
    required this.priority,
    required this.groupType,
    required this.relationId,
    required this.supportGroup,
    required this.autoSelSupportType,
  });

  factory SvtClassInfo.fromJson(Map<String, dynamic> json) => _$SvtClassInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SvtClassInfoToJson(this);
}

@JsonSerializable()
class CardInfo {
  List<NiceTrait> individuality;
  int adjustAtk;
  int adjustTdGauge;
  int adjustCritical;
  int addAtk;
  int addTdGauge;
  int addCritical;

  CardInfo({
    required this.individuality,
    required this.adjustAtk,
    required this.adjustTdGauge,
    required this.adjustCritical,
    required this.addAtk,
    required this.addTdGauge,
    required this.addCritical,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) => _$CardInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CardInfoToJson(this);
}

@JsonSerializable()
class GrailCostDetail {
  int qp;
  int addLvMax;
  SvtFrameType frameType;

  GrailCostDetail({
    required this.qp,
    required this.addLvMax,
    this.frameType = SvtFrameType.gold,
  });

  factory GrailCostDetail.fromJson(Map<String, dynamic> json) => _$GrailCostDetailFromJson(json);

  Map<String, dynamic> toJson() => _$GrailCostDetailToJson(this);
}

@JsonSerializable()
class MasterUserLvDetail {
  int requiredExp;
  int maxAp;
  int maxCost;
  int maxFriend;
  Gift? gift;

  MasterUserLvDetail({
    required this.requiredExp,
    required this.maxAp,
    required this.maxCost,
    required this.maxFriend,
    this.gift,
  });

  factory MasterUserLvDetail.fromJson(Map<String, dynamic> json) => _$MasterUserLvDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MasterUserLvDetailToJson(this);
}

@JsonSerializable()
class SvtExpCurve {
  int type;
  List<int> lv;
  List<int> exp;
  List<int> curve;

  SvtExpCurve({
    required this.type,
    required this.lv,
    required this.exp,
    required this.curve,
  });

  factory SvtExpCurve.fromJson(Map<String, dynamic> json) => _$SvtExpCurveFromJson(json);

  Map<String, dynamic> toJson() => _$SvtExpCurveToJson(this);
}

@JsonSerializable()
class FuncTypeDetail {
  final FuncType funcType;
  final bool ignoreValueUp;
  final List<NiceTrait> individuality;

  FuncTypeDetail({
    this.funcType = FuncType.unknown,
    required this.ignoreValueUp,
    this.individuality = const [],
  });

  factory FuncTypeDetail.fromJson(Map<String, dynamic> json) => _$FuncTypeDetailFromJson(json);

  Map<String, dynamic> toJson() => _$FuncTypeDetailToJson(this);
}

@JsonSerializable()
class BuffTypeDetail {
  final BuffType buffType;
  final bool ignoreValueUp;

  BuffTypeDetail({
    this.buffType = BuffType.unknown,
    required this.ignoreValueUp,
  });

  factory BuffTypeDetail.fromJson(Map<String, dynamic> json) => _$BuffTypeDetailFromJson(json);

  Map<String, dynamic> toJson() => _$BuffTypeDetailToJson(this);
}

class SvtExpData {
  int type;
  List<int> lv;
  List<int> exp;
  List<int> atk;
  List<int> hp;
  SvtExpData._({
    required this.type,
    required this.lv,
    required this.exp,
    required this.atk,
    required this.hp,
  });

  static SvtExpData from({
    required int type,
    SvtExpCurve? curve,
    required int atkBase,
    required int atkMax,
    required int hpBase,
    required int hpMax,
  }) {
    curve ??= db.gameData.constData.svtExp[type];
    int skip = curve?.lv.getOrNull(0) == 0 ? 1 : 0;
    return SvtExpData._(
      type: type,
      lv: curve?.lv.skip(skip).toList() ?? [],
      exp: curve?.exp.toList() ?? [],
      hp: curve?.curve.skip(skip).map((e) => hpBase + (hpMax - hpBase) * e ~/ 1000).toList() ?? [],
      atk: curve?.curve.skip(skip).map((e) => atkBase + (atkMax - atkBase) * e ~/ 1000).toList() ?? [],
    );
  }
}

@JsonSerializable()
class GameConstants {
  final int k20220731BoostRate1; // 200
  final int accountingInitializeTimeout; // 60
  final int aftreChangeFreeDrawNum; // 10
  final int attackRate; // 230
  final int attackRateRandomMax; // 1100
  final int attackRateRandomMin; // 900
  final int backsideClassImageId; // 102
  final int backsideSvtEquipImageId; // 103
  final int backsideSvtImageId; // 101
  final int battleEffectId3003001; // 3048001
  final int battleEffectIdAvoidance; // 6216
  final int battleEffectIdAvoidancePierce; // 6217
  final int battleEffectIdInvincible; // 6214
  final int battleEffectIdInvinciblePierce; // 6215
  final int battleEffectIdSpecialInvincible; // 2001003
  final int battleItemDispColumn; // 7
  final int battleMsgBaseTime; // 1000
  final int battleMsgInterval; // 250
  final int battleTimePerChara; // 50
  final int beforeChangeFreeDrawNum; // 1
  final int bpExpression; // 1
  final int campaignResetAt; // 4
  final int canSelectSvtMaterialFlag; // 4
  final int chainbonusArtsRate; // 200
  final int chainbonusBusterRate; // 200
  final int chainbonusQuick; // 20
  final int chapter1PrologueWarId; // 100
  final int chapter2EpilogueWarId; // 309
  final int chapter2PrologueWarId; // 300
  final int chapterFEndId; // 1000011
  final int chapterFStartId; // 1000001
  final int classBoardReleaseQuestId; // 4000100
  final int closeSecretTreasureDeviceQuestClear; // 1
  final int closeSecretTreasureDeviceSvtGet; // 1
  final int coinRoomGet; // 1
  final int coinRoomMax; // 2000
  final int coinRoomMaxNum; // 2
  final int coinRoomReleaseQuestId; // 3001101
  final int combineLimitSpecialPrivilegeId; // 100
  final int comebackTargetDay; // 1704027600
  final int commandArts; // 4001
  final int commandBuster; // 4002
  final int commandCardPrmUpMax; // 500
  final int commandCodeDetachingItemId; // 5003
  final int commandQuick; // 4003
  final int commandSpellRecoverAt; // 0
  final int convertDeckUserEquipAt; // 1481099400
  final int criticalAttackRate; // 2000
  final int criticalIndividuality; // 4100
  final int criticalRatePerStar; // 100
  final int criticalStarRate; // 200
  final int criticalTdPointRate; // 2000
  final int deckMax; // 10
  final int defaultLockBoardGroupId; // 0
  final int disableFriendshipExceed; // 0
  final int disableServantEffectFilter; // 0
  final int enableApRecover; // 0
  final int enablePresentHistory; // 1
  final int enableSerialCode; // 0
  final int enemyAttackRateArts; // 1000
  final int enemyAttackRateBuster; // 1500
  final int enemyAttackRateQuick; // 800
  final int enemyMaxBattleCount; // 5
  final int equipGetEffectId; // 1
  final int eventBoardGameMapPosition; // 1800
  final int eventBoardGameNextBoardQuestId; // 94047745
  final int eventBoardGameNextRoundQuestId; // 94047744
  final int eventDailyPointResetAt; // 10
  final int eventIdRaid1; // 80018
  final int eventIdRaid2; // 80022
  final int eventItemPanelType; // 1
  final int eventRewardMuteSvtId109820770; // 1
  final int eventRewardMuteSvtId109823880; // 1
  final int eventTowerFadeoutPlayTime; // 1000
  final int eventTowerProgressQuest1; // 94020001
  final int eventTowerProgressQuest2; // 94020013
  final int expirationDate; // 1893423600
  final int extendFriendValue; // 5
  final int extendSvtEquipValue; // 5
  final int extendSvtValue; // 5
  final int extraAttackRateGrand; // 3500
  final int extraAttackRateSingle; // 2000
  final int extraCriticalRate; // 0
  final int fesWarId; // 108
  final int firstEquipId; // 1
  final int fixEventSupportDeckNum; // 3
  final int fixMainSupportDeckNum; // 3
  final int flag20200805; // 1
  final int flag20210801; // 1
  final int flag20211217; // 1
  final int flag20220101; // 1
  final int flag20220119; // 1
  final int flag20220511; // 1
  final int flag20220730; // 1
  final int flag20230402; // 1
  final int flag20230730; // 1
  final int flagCineraria4; // 0
  final int followerListExpireAt; // 3600
  final int followerRefreshResetTime; // 10
  final int followFriendPoint; // 50
  final int followNum; // 10
  final int fourPillars; // 9934821
  final int freeDrawNumChangeAt; // 1475679600
  final int freeGachaResetAt; // 0
  final int friendpointBoostItemEffectId; // 3
  final int friendGachaAddLimit; // 100
  final int friendGachaCommandCodeAddLimit; // 100
  final int friendNum; // 37
  final int friendOfferedNum; // 20
  final int friendPoint; // 25
  final int fullTdPoint; // 10000
  final int gachaDailyMaxDrawNumResetAt; // 4
  final int gachaExtraRequiredCount; // 10
  final int gamedataResetAt; // 0
  final int gameOverCommandSpellId; // 2
  final int heroineChangecardvoice; // 800104
  final int hydeSvtId; // 600710
  final int individualityIsSupport; // 7000
  final int isEventPointMenu; // 1
  final int isIosExamination; // 0
  final int itemIdQp; // 1
  final int jekyllSvtId; // 600700
  final int largeSuccessMultExp; // 2000
  final int largeSuccessRate; // 100
  final int lastWarId; // 403
  final int limitedPeriodVoiceChangeType; // 0
  final int limitedShopRemainDays; // 1000
  final int loginDay; // 1459436400
  final int loginResetAt; // 4
  final int mashuChangeQuestId; // 1000501
  final int mashuChangeWarId; // 105
  final int mashuSvtId1; // 800100
  final int mashuSvtId2; // 800101
  final int mashuSvtId3; // 800102
  final int mashuTdGradeUpQuestId; // 3001301
  final int mashuTdGradeUpQuestPhase; // 3
  final int masterMissionAlertTime; // 259200
  final int masterMissionSvtId1; // 9000001
  final int maxBlackListNum; // 50
  final int maxCommandSpell; // 3
  final int maxDropFactor; // 1000
  final int maxEventPoint; // 999999999
  final int maxExpFactor; // 3000
  final int maxFriendpoint; // 999999999
  final int maxFriendpointBoostItemDailyReceive; // 100
  final int maxFriendpointBoostItemUse; // 3
  final int maxFriendshipRank; // 5
  final int maxFriendCode; // 999999999
  final int maxFriendHistoryNum; // 100
  final int maxFriendShipUpRatio; // 3000
  final int maxMana; // 999999999
  final int maxNearPresentOffsetNum; // 50
  final int maxPresentBoxHistoryNum; // 0
  final int maxPresentBoxNum; // 400
  final int maxPresentReceiveNum; // 99
  final int maxQp; // 2000000000
  final int maxQpDropUpRatio; // 3000
  final int maxQpFactor; // 3000
  final int maxRarePri; // 999999999
  final int maxRp; // 8
  final int maxStone; // 999999999
  final int maxUserCommandCode; // 450
  final int maxUserEquipExpUpRatio; // 3000
  final int maxUserItem; // 999999999
  final int maxUserLv; // 170
  final int maxUserSvt; // 800
  final int maxUserSvtEquip; // 800
  final int maxUserSvtEquipStorage; // 100
  final int maxUserSvtStorage; // 100
  final int memoryDeckLimitByQuest; // 100
  final int menuChange; // 1
  final int minLogicCancerLvUpProb; // 100
  final int monthlyShopRemainDays; // 3
  final int mstBuffIndvAddBuffActive; // 1
  final int needRebootTime; // 86400
  final int nothinkAiactid; // 1002
  final int notChangeBehaviorTransformSvtId; // 600700
  final int notFriendPoint; // 10
  final int npcFriendPoint; // 200
  final int npDoubleBurst; // 1000
  final int npTripleBurst; // 1500
  final int oneAct; // 300
  final int oneCommandSpell; // 86400
  final int oneRp; // 3600
  final int otherImageLimitCount; // 10
  final int overKillNpRate; // 1500
  final int overKillStarAdd; // 300
  final int overKillStarRate; // 1000
  final int perSameCommand; // 0
  final int presentValidTime; // 31536000
  final int prologueQuestId; // 1000000
  final int qp; // 0
  final int questInfoFlagCombineMaterial; // 0
  final int questInfoFlagItem; // 0
  final int questInfoFlagSvtEquip; // 0
  final int raceAddPointBase; // 2
  final int raceRewardRankMax; // 3
  final int raceTargetGoalRank; // 3
  final int raidDefeatedEffectTime; // 0
  final int raidMarkdispStep; // 4
  final int raidTutorialQuestId; // 94004504
  final int recoveryValue; // 2
  final int requestRaidUpdateEventMap; // 60
  final int requestTopHomeExpirationDateSecUpdateEventMap; // 900
  final int retrievableQuestConfirmBoost; // 1
  final int revertBuffLowerLimit; // 1
  final int sameClassMuliExp; // 1200
  final int shop04ShopState; // 0
  final int shopSpecialItemEnable; // 1
  final int startingMemberFriendshipRate; // 1200
  final int starRateMax; // 3000
  final int statusUpAdjustAtk; // 10
  final int statusUpAdjustHp; // 10
  final int statusUpBuff; // 3004
  final int superSuccessMultExp; // 3000
  final int superSuccessRate; // 20
  final int supportDeckMax; // 10
  final int svtBackQuestId; // 1000822
  final int svtBackQuestPhase; // 1
  final int svtLeaveQuestId; // 1000819
  final int svtLeaveQuestPhase; // 1
  final int svtRecoveryNum; // 5
  final int swimsuitMeltSvtId; // 304000
  final int tamamocatStunBuffId; // 178
  final int tamamocatTreasureDeviceId1; // 701601
  final int tamamocatTreasureDeviceId2; // 701602
  final int temporaryIgnoreSleepModeForTreasureDeviceSvtId1; // 500100
  final int temporaryIgnoreSleepModeForTreasureDeviceSvtId2; // 600900
  final int timeStatusCondQuestId; // 94027502
  final int titleFlowOld; // 0
  final int treasuredeviceIdMashu3; // 800104
  final int treasureDeviceDispStatusEffectFlag; // 0
  final int tutorialFavoriteQuestId; // 1000011
  final int tutorialGachaId; // 101
  final int tutorialLabel1StAnniversarySvtKeepAdjust; // 125
  final int tutorialLabelBattleResultWinLose; // 123
  final int tutorialLabelCaldeaGate; // 129
  final int tutorialLabelChapter2Prologue; // 204
  final int tutorialLabelCombine; // 104
  final int tutorialLabelDailyQuest; // 130
  final int tutorialLabelDeck; // 202
  final int tutorialLabelDeck2; // 205
  final int tutorialLabelDeckInSvtEquip; // 113
  final int tutorialLabelDeckScene; // 109
  final int tutorialLabelDeckSvtEquip; // 110
  final int tutorialLabelEnd; // 102
  final int tutorialLabelEventGacha; // 111
  final int tutorialLabelEventMission; // 114
  final int tutorialLabelEventReward; // 112
  final int tutorialLabelFavorite1; // 105
  final int tutorialLabelFavorite2; // 106
  final int tutorialLabelFes; // 127
  final int tutorialLabelFixCostume; // 206
  final int tutorialLabelFreindStoryQuest; // 131
  final int tutorialLabelGachaScene; // 107
  final int tutorialLabelGachaSvtEquip; // 108
  final int tutorialLabelIbarakiRaidBattle; // 117
  final int tutorialLabelIbarakiRaidEventReward; // 118
  final int tutorialLabelIbarakiRaidTerminal; // 116
  final int tutorialLabelMashuChange; // 115
  final int tutorialLabelMasterMission; // 207
  final int tutorialLabelMyroom; // 128
  final int tutorialLabelOnigashimaLoginGift; // 124
  final int tutorialLabelPresentBox; // 201
  final int tutorialLabelRaid2Battle; // 120
  final int tutorialLabelRaid2Battle2; // 122
  final int tutorialLabelRaid2EventReward; // 121
  final int tutorialLabelRaid2Map; // 119
  final int tutorialLabelShop; // 103
  final int tutorialLabelStoneGacha; // 101
  final int tutorialLabelSvtLeave; // 126
  final int tutorialMizugiCultivQuestId; // 94005701
  final int tutorialMizugiMapId; // 9005
  final int tutorialMizugiResetQuestId; // 94005891
  final int tutorialNpcSvtId1; // 1
  final int tutorialNpcSvtId2; // 2
  final int tutorialNpcSvtId3; // 3
  final int tutorialQuestId1; // 1000000
  final int tutorialQuestId2; // 1000001
  final int tutorialQuestId3; // 1000002
  final int tutorialQuestId4; // 1000003
  final int tutorialQuestId4Phase; // 1
  final int tutorialSupportQuestId; // 1000006
  final int tutorialSupportQuestPhase; // 2
  final int userAct; // 20
  final int userCost; // 56
  final int userFreeStone; // 30
  final int userFriendPoint; // 0
  final int userOrderCnt; // 3
  final int userStartId; // 1000001
  final int userSvt; // 50
  final int userSvtEquip; // 50
  final int valentineReleaseAt; // 1455080400
  final int warboardMaxServantCacheCount; // 0
  final int warboardMiddleMemoryServantCacheCount; // 0
  final int warBoardBattleEndReduceBuffTurnFlag; // 1
  final int warBoardBattleLoseBgm; // 0

  const GameConstants({
    this.k20220731BoostRate1 = 200,
    this.accountingInitializeTimeout = 60,
    this.aftreChangeFreeDrawNum = 10,
    this.attackRate = 230,
    this.attackRateRandomMax = 1100,
    this.attackRateRandomMin = 900,
    this.backsideClassImageId = 102,
    this.backsideSvtEquipImageId = 103,
    this.backsideSvtImageId = 101,
    this.battleEffectId3003001 = 3048001,
    this.battleEffectIdAvoidance = 6216,
    this.battleEffectIdAvoidancePierce = 6217,
    this.battleEffectIdInvincible = 6214,
    this.battleEffectIdInvinciblePierce = 6215,
    this.battleEffectIdSpecialInvincible = 2001003,
    this.battleItemDispColumn = 7,
    this.battleMsgBaseTime = 1000,
    this.battleMsgInterval = 250,
    this.battleTimePerChara = 50,
    this.beforeChangeFreeDrawNum = 1,
    this.bpExpression = 1,
    this.campaignResetAt = 4,
    this.canSelectSvtMaterialFlag = 4,
    this.chainbonusArtsRate = 200,
    this.chainbonusBusterRate = 200,
    this.chainbonusQuick = 20,
    this.chapter1PrologueWarId = 100,
    this.chapter2EpilogueWarId = 309,
    this.chapter2PrologueWarId = 300,
    this.chapterFEndId = 1000011,
    this.chapterFStartId = 1000001,
    this.classBoardReleaseQuestId = 4000100,
    this.closeSecretTreasureDeviceQuestClear = 1,
    this.closeSecretTreasureDeviceSvtGet = 1,
    this.coinRoomGet = 1,
    this.coinRoomMax = 2000,
    this.coinRoomMaxNum = 2,
    this.coinRoomReleaseQuestId = 3001101,
    this.combineLimitSpecialPrivilegeId = 100,
    this.comebackTargetDay = 1704027600,
    this.commandArts = 4001,
    this.commandBuster = 4002,
    this.commandCardPrmUpMax = 500,
    this.commandCodeDetachingItemId = 5003,
    this.commandQuick = 4003,
    this.commandSpellRecoverAt = 0,
    this.convertDeckUserEquipAt = 1481099400,
    this.criticalAttackRate = 2000,
    this.criticalIndividuality = 4100,
    this.criticalRatePerStar = 100,
    this.criticalStarRate = 200,
    this.criticalTdPointRate = 2000,
    this.deckMax = 10,
    this.defaultLockBoardGroupId = 0,
    this.disableFriendshipExceed = 0,
    this.disableServantEffectFilter = 0,
    this.enableApRecover = 0,
    this.enablePresentHistory = 1,
    this.enableSerialCode = 0,
    this.enemyAttackRateArts = 1000,
    this.enemyAttackRateBuster = 1500,
    this.enemyAttackRateQuick = 800,
    this.enemyMaxBattleCount = 5,
    this.equipGetEffectId = 1,
    this.eventBoardGameMapPosition = 1800,
    this.eventBoardGameNextBoardQuestId = 94047745,
    this.eventBoardGameNextRoundQuestId = 94047744,
    this.eventDailyPointResetAt = 10,
    this.eventIdRaid1 = 80018,
    this.eventIdRaid2 = 80022,
    this.eventItemPanelType = 1,
    this.eventRewardMuteSvtId109820770 = 1,
    this.eventRewardMuteSvtId109823880 = 1,
    this.eventTowerFadeoutPlayTime = 1000,
    this.eventTowerProgressQuest1 = 94020001,
    this.eventTowerProgressQuest2 = 94020013,
    this.expirationDate = 1893423600,
    this.extendFriendValue = 5,
    this.extendSvtEquipValue = 5,
    this.extendSvtValue = 5,
    this.extraAttackRateGrand = 3500,
    this.extraAttackRateSingle = 2000,
    this.extraCriticalRate = 0,
    this.fesWarId = 108,
    this.firstEquipId = 1,
    this.fixEventSupportDeckNum = 3,
    this.fixMainSupportDeckNum = 3,
    this.flag20200805 = 1,
    this.flag20210801 = 1,
    this.flag20211217 = 1,
    this.flag20220101 = 1,
    this.flag20220119 = 1,
    this.flag20220511 = 1,
    this.flag20220730 = 1,
    this.flag20230402 = 1,
    this.flag20230730 = 1,
    this.flagCineraria4 = 0,
    this.followerListExpireAt = 3600,
    this.followerRefreshResetTime = 10,
    this.followFriendPoint = 50,
    this.followNum = 10,
    this.fourPillars = 9934821,
    this.freeDrawNumChangeAt = 1475679600,
    this.freeGachaResetAt = 0,
    this.friendpointBoostItemEffectId = 3,
    this.friendGachaAddLimit = 100,
    this.friendGachaCommandCodeAddLimit = 100,
    this.friendNum = 37,
    this.friendOfferedNum = 20,
    this.friendPoint = 25,
    this.fullTdPoint = 10000,
    this.gachaDailyMaxDrawNumResetAt = 4,
    this.gachaExtraRequiredCount = 10,
    this.gamedataResetAt = 0,
    this.gameOverCommandSpellId = 2,
    this.heroineChangecardvoice = 800104,
    this.hydeSvtId = 600710,
    this.individualityIsSupport = 7000,
    this.isEventPointMenu = 1,
    this.isIosExamination = 0,
    this.itemIdQp = 1,
    this.jekyllSvtId = 600700,
    this.largeSuccessMultExp = 2000,
    this.largeSuccessRate = 100,
    this.lastWarId = 403,
    this.limitedPeriodVoiceChangeType = 0,
    this.limitedShopRemainDays = 1000,
    this.loginDay = 1459436400,
    this.loginResetAt = 4,
    this.mashuChangeQuestId = 1000501,
    this.mashuChangeWarId = 105,
    this.mashuSvtId1 = 800100,
    this.mashuSvtId2 = 800101,
    this.mashuSvtId3 = 800102,
    this.mashuTdGradeUpQuestId = 3001301,
    this.mashuTdGradeUpQuestPhase = 3,
    this.masterMissionAlertTime = 259200,
    this.masterMissionSvtId1 = 9000001,
    this.maxBlackListNum = 50,
    this.maxCommandSpell = 3,
    this.maxDropFactor = 1000,
    this.maxEventPoint = 999999999,
    this.maxExpFactor = 3000,
    this.maxFriendpoint = 999999999,
    this.maxFriendpointBoostItemDailyReceive = 100,
    this.maxFriendpointBoostItemUse = 3,
    this.maxFriendshipRank = 5,
    this.maxFriendCode = 999999999,
    this.maxFriendHistoryNum = 100,
    this.maxFriendShipUpRatio = 3000,
    this.maxMana = 999999999,
    this.maxNearPresentOffsetNum = 50,
    this.maxPresentBoxHistoryNum = 0,
    this.maxPresentBoxNum = 400,
    this.maxPresentReceiveNum = 99,
    this.maxQp = 2000000000,
    this.maxQpDropUpRatio = 3000,
    this.maxQpFactor = 3000,
    this.maxRarePri = 999999999,
    this.maxRp = 8,
    this.maxStone = 999999999,
    this.maxUserCommandCode = 450,
    this.maxUserEquipExpUpRatio = 3000,
    this.maxUserItem = 999999999,
    this.maxUserLv = 170,
    this.maxUserSvt = 800,
    this.maxUserSvtEquip = 800,
    this.maxUserSvtEquipStorage = 100,
    this.maxUserSvtStorage = 100,
    this.memoryDeckLimitByQuest = 100,
    this.menuChange = 1,
    this.minLogicCancerLvUpProb = 100,
    this.monthlyShopRemainDays = 3,
    this.mstBuffIndvAddBuffActive = 1,
    this.needRebootTime = 86400,
    this.nothinkAiactid = 1002,
    this.notChangeBehaviorTransformSvtId = 600700,
    this.notFriendPoint = 10,
    this.npcFriendPoint = 200,
    this.npDoubleBurst = 1000,
    this.npTripleBurst = 1500,
    this.oneAct = 300,
    this.oneCommandSpell = 86400,
    this.oneRp = 3600,
    this.otherImageLimitCount = 10,
    this.overKillNpRate = 1500,
    this.overKillStarAdd = 300,
    this.overKillStarRate = 1000,
    this.perSameCommand = 0,
    this.presentValidTime = 31536000,
    this.prologueQuestId = 1000000,
    this.qp = 0,
    this.questInfoFlagCombineMaterial = 0,
    this.questInfoFlagItem = 0,
    this.questInfoFlagSvtEquip = 0,
    this.raceAddPointBase = 2,
    this.raceRewardRankMax = 3,
    this.raceTargetGoalRank = 3,
    this.raidDefeatedEffectTime = 0,
    this.raidMarkdispStep = 4,
    this.raidTutorialQuestId = 94004504,
    this.recoveryValue = 2,
    this.requestRaidUpdateEventMap = 60,
    this.requestTopHomeExpirationDateSecUpdateEventMap = 900,
    this.retrievableQuestConfirmBoost = 1,
    this.revertBuffLowerLimit = 1,
    this.sameClassMuliExp = 1200,
    this.shop04ShopState = 0,
    this.shopSpecialItemEnable = 1,
    this.startingMemberFriendshipRate = 1200,
    this.starRateMax = 3000,
    this.statusUpAdjustAtk = 10,
    this.statusUpAdjustHp = 10,
    this.statusUpBuff = 3004,
    this.superSuccessMultExp = 3000,
    this.superSuccessRate = 20,
    this.supportDeckMax = 10,
    this.svtBackQuestId = 1000822,
    this.svtBackQuestPhase = 1,
    this.svtLeaveQuestId = 1000819,
    this.svtLeaveQuestPhase = 1,
    this.svtRecoveryNum = 5,
    this.swimsuitMeltSvtId = 304000,
    this.tamamocatStunBuffId = 178,
    this.tamamocatTreasureDeviceId1 = 701601,
    this.tamamocatTreasureDeviceId2 = 701602,
    this.temporaryIgnoreSleepModeForTreasureDeviceSvtId1 = 500100,
    this.temporaryIgnoreSleepModeForTreasureDeviceSvtId2 = 600900,
    this.timeStatusCondQuestId = 94027502,
    this.titleFlowOld = 0,
    this.treasuredeviceIdMashu3 = 800104,
    this.treasureDeviceDispStatusEffectFlag = 0,
    this.tutorialFavoriteQuestId = 1000011,
    this.tutorialGachaId = 101,
    this.tutorialLabel1StAnniversarySvtKeepAdjust = 125,
    this.tutorialLabelBattleResultWinLose = 123,
    this.tutorialLabelCaldeaGate = 129,
    this.tutorialLabelChapter2Prologue = 204,
    this.tutorialLabelCombine = 104,
    this.tutorialLabelDailyQuest = 130,
    this.tutorialLabelDeck = 202,
    this.tutorialLabelDeck2 = 205,
    this.tutorialLabelDeckInSvtEquip = 113,
    this.tutorialLabelDeckScene = 109,
    this.tutorialLabelDeckSvtEquip = 110,
    this.tutorialLabelEnd = 102,
    this.tutorialLabelEventGacha = 111,
    this.tutorialLabelEventMission = 114,
    this.tutorialLabelEventReward = 112,
    this.tutorialLabelFavorite1 = 105,
    this.tutorialLabelFavorite2 = 106,
    this.tutorialLabelFes = 127,
    this.tutorialLabelFixCostume = 206,
    this.tutorialLabelFreindStoryQuest = 131,
    this.tutorialLabelGachaScene = 107,
    this.tutorialLabelGachaSvtEquip = 108,
    this.tutorialLabelIbarakiRaidBattle = 117,
    this.tutorialLabelIbarakiRaidEventReward = 118,
    this.tutorialLabelIbarakiRaidTerminal = 116,
    this.tutorialLabelMashuChange = 115,
    this.tutorialLabelMasterMission = 207,
    this.tutorialLabelMyroom = 128,
    this.tutorialLabelOnigashimaLoginGift = 124,
    this.tutorialLabelPresentBox = 201,
    this.tutorialLabelRaid2Battle = 120,
    this.tutorialLabelRaid2Battle2 = 122,
    this.tutorialLabelRaid2EventReward = 121,
    this.tutorialLabelRaid2Map = 119,
    this.tutorialLabelShop = 103,
    this.tutorialLabelStoneGacha = 101,
    this.tutorialLabelSvtLeave = 126,
    this.tutorialMizugiCultivQuestId = 94005701,
    this.tutorialMizugiMapId = 9005,
    this.tutorialMizugiResetQuestId = 94005891,
    this.tutorialNpcSvtId1 = 1,
    this.tutorialNpcSvtId2 = 2,
    this.tutorialNpcSvtId3 = 3,
    this.tutorialQuestId1 = 1000000,
    this.tutorialQuestId2 = 1000001,
    this.tutorialQuestId3 = 1000002,
    this.tutorialQuestId4 = 1000003,
    this.tutorialQuestId4Phase = 1,
    this.tutorialSupportQuestId = 1000006,
    this.tutorialSupportQuestPhase = 2,
    this.userAct = 20,
    this.userCost = 56,
    this.userFreeStone = 30,
    this.userFriendPoint = 0,
    this.userOrderCnt = 3,
    this.userStartId = 1000001,
    this.userSvt = 50,
    this.userSvtEquip = 50,
    this.valentineReleaseAt = 1455080400,
    this.warboardMaxServantCacheCount = 0,
    this.warboardMiddleMemoryServantCacheCount = 0,
    this.warBoardBattleEndReduceBuffTurnFlag = 1,
    this.warBoardBattleLoseBgm = 0,
  });

  factory GameConstants.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> json2 = {};
    for (final key in json.keys) {
      String key2 = _cvtKey(key);
      json2[key2] = json[key];
    }
    return _$GameConstantsFromJson(json2);
  }

  Map<String, dynamic> toJson() => _$GameConstantsToJson(this);

  static String _cvtKey(String key) {
    final segments = key.split('_').map((e) => e.toLowerCase()).toList();
    for (int index = 1; index < segments.length; index++) {
      String s = segments[index];
      segments[index] = s.substring(0, 1).toUpperCase() + s.substring(1);
    }
    String key2 = segments.join('');
    if (key2.startsWith(RegExp(r'\d'))) {
      key2 = 'k$key2';
    }
    return key2;
  }

  static String cvtMstConstant(String content) {
    final srcData = List<Map>.from(jsonDecode(content));
    List<(String, int)> items = srcData.map((e) => (_cvtKey(e['name']), e['value'] as int)).toList();
    StringBuffer buffer = StringBuffer("class GameConstants {\n");

    for (final (key, value) in items) {
      buffer.writeln('  final int $key;  // $value');
    }
    buffer.writeln();
    buffer.writeln("  const GameConstants({");
    for (final (key, value) in items) {
      buffer.writeln("   this.$key = $value,");
    }
    buffer.writeln('  });');
    buffer.writeln("\n}");

    return buffer.toString();
  }
}

@JsonSerializable()
class GameConstantStr {
  final List<int> extendTurnBuffType; // 1,9,11,13,15,18,25,50,51,52,70,72,89,90,110,112,116,121,137,144,148,160,162
  final List<int> invalidSacrificeIndiv; // 3076
  // final int materialMainInterludeWarId; // 307
  final List<int> notReduceCountWithNoDamageBuff; // 42, 21, 23, 91, 105, 196
  final List<int> starRefreshBuffType; // 2,61
  final List<int> subPtBuffIndivi; // 3055
  final List<int> svtExitPtBuffIndivi; // 3069
  final List<int> playableBeastClassIds;

  const GameConstantStr({
    this.extendTurnBuffType = const [
      //
      1, 9, 11, 13, 15, 18, 25, 50, 51, 52, 70, 72, 89, 90, 110, 112, 116, 121, 137, 144, 148, 160, 162
    ],
    this.invalidSacrificeIndiv = const [3076],
    // this.materialMainInterludeWarId = 307,
    this.notReduceCountWithNoDamageBuff = const [42, 21, 23, 91, 105, 196],
    this.starRefreshBuffType = const [2, 61],
    this.subPtBuffIndivi = const [3055],
    this.svtExitPtBuffIndivi = const [3069],
    this.playableBeastClassIds = const [33, 38],
  });

  factory GameConstantStr.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> json2 = {};
    for (final key in json.keys) {
      String key2 = GameConstants._cvtKey(key);
      json2[key2] = json[key];
    }
    return _$GameConstantStrFromJson(json2);
  }

  Map<String, dynamic> toJson() => _$GameConstantStrToJson(this);
}

@JsonSerializable()
class SvtLimitHide {
  final List<int> limits;
  final List<int> tds;
  final Map<int, List<int>> activeSkills;
  final List<int> classPassives;
  final List<int> addPassives;

  const SvtLimitHide({
    this.limits = const [],
    this.tds = const [],
    this.activeSkills = const {},
    this.classPassives = const [],
    this.addPassives = const [],
  });

  factory SvtLimitHide.fromJson(Map<String, dynamic> json) => _$SvtLimitHideFromJson(json);

  Map<String, dynamic> toJson() => _$SvtLimitHideToJson(this);
}

enum SvtFrameType {
  black,
  bronze,
  silver,
  gold,
  frame0801,
  frame0802,
  frame0803,
  frame0804,
}

// String or int
class BuffActionConverter extends JsonConverter<BuffAction, dynamic> {
  const BuffActionConverter();
  @override
  BuffAction fromJson(dynamic value) {
    if (value == null) return BuffAction.none;
    if (value is int) {
      return BuffAction.values.firstWhere((e) => e.value == value, orElse: () => BuffAction.unknown);
    } else if (value is String) {
      return deprecatedTypes[value] ?? decodeEnum(_$BuffActionEnumMap, value, BuffAction.unknown);
    } else {
      throw UnsupportedError("BuffAction value must be int or string: ${value.runtimeType} $value");
    }
  }

  @override
  String toJson(BuffAction obj) => _$BuffActionEnumMap[obj] ?? obj.name;

  static Map<String, BuffAction> deprecatedTypes = {
    "functionCommandattack": BuffAction.functionCommandattackAfter,
    "functionAttack": BuffAction.functionAttackAfter,
    "functionCommandcodeattack": BuffAction.functionCommandcodeattackBefore,
  };
}

@JsonEnum(alwaysCreate: true)
enum BuffAction {
  unknown(-1), // custom
  none(0),
  commandAtk(1),
  commandDef(2),
  atk(3),
  defence(4),
  defencePierce(5),
  specialdefence(6),
  damage(7),
  damageIndividuality(8),
  damageIndividualityActiveonly(9),
  selfdamage(10),
  criticalDamage(11),
  npdamage(12),
  givenDamage(13),
  receiveDamage(14),
  pierceInvincible(15),
  invincible(16),
  breakAvoidance(17),
  avoidance(18),
  overwriteBattleclass(19),
  overwriteClassrelatioAtk(20),
  overwriteClassrelatioDef(21),
  commandNpAtk(22),
  commandNpDef(23),
  dropNp(24),
  dropNpDamage(25),
  commandStarAtk(26),
  commandStarDef(27),
  criticalPoint(28),
  starweight(29),
  turnendNp(30),
  turnendStar(31),
  turnendHpRegain(32),
  turnendHpReduce(33),
  gainHp(34),
  turnvalNp(35),
  grantState(36),
  resistanceState(37),
  avoidState(38),
  donotAct(39),
  donotSkill(40),
  donotNoble(41),
  donotRecovery(42),
  individualityAdd(43),
  individualitySub(44),
  hate(45),
  criticalRate(46),
  avoidInstantdeath(47),
  resistInstantdeath(48),
  nonresistInstantdeath(49),
  regainNpUsedNoble(50),
  functionDead(51),
  maxhpRate(52),
  maxhpValue(53),
  functionWavestart(54),
  functionSelfturnend(55),
  giveGainHp(56),
  functionCommandattackAfter(57), // functionCommandattack
  functionDeadattack(58),
  functionEntry(59),
  chagetd(60),
  grantSubstate(61),
  toleranceSubstate(62),
  grantInstantdeath(63),
  functionDamage(64),
  functionReflection(65),
  multiattack(66),
  giveNp(67),
  resistanceDelayNpturn(68),
  pierceDefence(69),
  gutsHp(70),
  funcgainNp(71),
  funcHpReduce(72),
  functionNpattack(73),
  fixCommandcard(74),
  donotGainnp(75),
  fieldIndividuality(76),
  donotActCommandtype(77),
  damageEventPoint(78),
  damageSpecial(79),
  functionAttackAfter(80), // functionAttack
  functionCommandcodeattackBefore(81), // functionCommandcodeattack
  donotNobleCondMismatch(82),
  donotSelectCommandcard(83),
  donotReplace(84),
  shortenUserEquipSkill(85),
  tdTypeChange(86),
  overwriteClassRelation(87),
  functionCommandattackBefore(88),
  functionGuts(89),
  criticalRateDamageTaken(90),
  criticalStarDamageTaken(91),
  skillRankChange(92),
  avoidanceIndividuality(93),
  changeCommandCardType(94),
  specialInvincible(95),
  preventDeathByDamage(96),
  functionCommandcodeattackAfter(97),
  functionAttackBefore(98),
  donotSkillSelect(99),
  invisibleBattleChara(100),
  buffRate(101),
  counterFunction(102),
  notTargetSkill(103),
  toFieldChangeField(104),
  toFieldAvoidBuff(105),
  grantStateUpOnly(106),
  turnendHpReduceToRegain(107),
  functionSelfturnstart(108),
  overwriteDeadType(109),
  actionCount(110),
  shiftGuts(111),
  toFieldSubIndividualityField(112),
  masterSkillValueUp(113),
  buffConvert(114),
  subFieldIndividuality(115),
  functionCommandcodeattackBeforeMainOnly(116),
  functionCommandcodeattackAfterMainOnly(117),
  functionCommandattackBeforeMainOnly(118),
  functionCommandattackAfterMainOnly(119),
  functionAttackBeforeMainOnly(120),
  functionAttackAfterMainOnly(121),
  functionSkillAfter(122),
  functionSkillAfterMainOnly(123),
  functionTreasureDeviceAfter(124),
  functionTreasureDeviceAfterMainOnly(125),
  guts(126),
  preventInvisibleWhenInstantDeath(127),
  overwriteSubattribute(128),
  avoidanceAttackDeathDamage(129),
  avoidFunctionExecuteSelf(130),
  functionContinue(131),
  pierceSubdamage(132),
  receiveDamagePierce(133),
  specialReceiveDamage(134),
  funcHpReduceValue(135),
  changeBgm(136),
  functionConfirmCommand(137),
  functionSkillBefore(138),
  functionSkillTargetedBefore(139),
  functionFieldIndividualityChanged(140),
  functionTreasureDeviceBefore(141),
  functionStepInAfter(142),
  shortenSkillAfterUseSkill(143),
  pierceSpecialInvincible(144),
  ;

  final int value;
  const BuffAction(this.value);

  bool get isNotNone => this != none && this != unknown;
}

enum BuffLimit {
  none,
  upper,
  lower,
  normal,
}

const kBuffActionPercentTypes = {
  BuffAction.atk: 10,
  BuffAction.buffRate: 10,
  BuffAction.commandAtk: 10,
  BuffAction.commandDef: 10,
  BuffAction.commandNpAtk: 10,
  BuffAction.commandNpDef: 10,
  BuffAction.commandStarAtk: 10,
  BuffAction.commandStarDef: 10,
  BuffAction.criticalDamage: 10,
  BuffAction.criticalPoint: 10,
  BuffAction.criticalRate: 10,
  BuffAction.criticalRateDamageTaken: 10,
  BuffAction.criticalStarDamageTaken: 10,
  BuffAction.damage: 10,
  BuffAction.damageEventPoint: 10,
  BuffAction.damageIndividuality: 10,
  BuffAction.damageIndividualityActiveonly: 10,
  BuffAction.damageSpecial: 10,
  BuffAction.defence: 10,
  BuffAction.defencePierce: 10,
  BuffAction.dropNp: 10,
  BuffAction.dropNpDamage: 10,
  BuffAction.funcHpReduce: 10,
  BuffAction.funcgainNp: 10,
  BuffAction.gainHp: 10,
  BuffAction.giveGainHp: 10,
  BuffAction.grantInstantdeath: 10,
  BuffAction.grantState: 10,
  BuffAction.grantStateUpOnly: 10,
  BuffAction.hate: 10,
  BuffAction.nonresistInstantdeath: 10,
  BuffAction.npdamage: 10,
  BuffAction.resistInstantdeath: 10,
  BuffAction.resistanceState: 10,
  BuffAction.specialdefence: 10,
  BuffAction.starweight: 10,
  BuffAction.toleranceSubstate: 10,
  BuffAction.turnendNp: 100,
  BuffAction.masterSkillValueUp: 10,
  BuffAction.maxhpRate: 10,
};

const kBuffTypePercentType = <BuffType, int>{
  BuffType.masterSkillValueUp: 10,
  BuffType.shiftGutsRatio: 10,
  BuffType.gutsRatio: 10,
};

const kFuncValPercentType = <FuncType, int>{
  FuncType.gainNpFromTargets: 100,
  FuncType.gainNp: 100,
  FuncType.gainNpBuffIndividualSum: 100,
  FuncType.gainNpIndividualSum: 100,
  FuncType.gainMultiplyNp: 10,
  FuncType.lossNp: 100,
  FuncType.damageNp: 10,
  FuncType.damageNpSafe: 10,
  FuncType.damageNpHpratioLow: 10,
  FuncType.damageNpIndividual: 10,
  FuncType.damageNpAndCheckIndividuality: 10,
  FuncType.damageNpIndividualSum: 10,
  FuncType.damageNpPierce: 10,
  FuncType.damageNpRare: 10,
  FuncType.damageNpStateIndividualFix: 10,
  FuncType.damageNpCounter: 10,
  FuncType.damageNpBattlePointPhase: 10,
  FuncType.gainHpPer: 10,
  FuncType.qpDropUp: 10,
};
