import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'quest.dart' show Gift;
import 'servant.dart';
import 'skill.dart';

part '../../generated/models/gamedata/const_data.g.dart';

@JsonSerializable()
class ConstGameData {
  final Map<Attribute, Map<Attribute, int>> attributeRelation;
  final Map<BuffAction, BuffActionDetail> buffActions;
  final Map<CardType, Map<int, CardInfo>> cardInfo;
  final Map<SvtClass, int> classAttackRate;
  final Map<SvtClass, Map<SvtClass, int>> classRelation;
  final GameConstants constants;
  final Map<int, Map<int, GrailCostDetail>>
      svtGrailCost; // <rarity, <grail_count, detail>>
  final Map<int, MasterUserLvDetail> userLevel;
  final Map<int, int> bondLimitQp = {
    10: 10000000,
    11: 12000000,
    12: 14000000,
    13: 16000000,
    14: 18000000
  };

  ConstGameData({
    required this.attributeRelation,
    required Map<dynamic, BuffActionDetail> buffActions,
    required this.cardInfo,
    required this.classAttackRate,
    required this.classRelation,
    required this.constants,
    required this.svtGrailCost,
    required this.userLevel,
  }) : buffActions = buffActions.map(
          (key, value) => MapEntry(
            $enumDecode(_$BuffActionEnumMap, key as String,
                unknownValue: BuffAction.none),
            value,
          ),
        );

  ConstGameData.empty()
      : attributeRelation = const {},
        buffActions = const {},
        cardInfo = const {},
        classAttackRate = const {},
        classRelation = const {},
        constants = const GameConstants(),
        svtGrailCost = const {},
        userLevel = const {};

  factory ConstGameData.fromJson(Map<String, dynamic> json) =>
      _$ConstGameDataFromJson(json);
}

@JsonSerializable()
class BuffActionDetail {
  BuffLimit limit;
  @JsonKey(fromJson: toEnumListBuffType)
  List<BuffType> plusTypes;
  @JsonKey(fromJson: toEnumListBuffType)
  List<BuffType> minusTypes;
  int baseParam;
  int baseValue;
  bool isRec;
  int plusAction;
  List<int> maxRate;

  BuffActionDetail({
    required this.limit,
    required List<BuffType?> plusTypes,
    required List<BuffType?> minusTypes,
    required this.baseParam,
    required this.baseValue,
    required this.isRec,
    required this.plusAction,
    required this.maxRate,
  })  : plusTypes = plusTypes.whereType<BuffType>().toList(),
        minusTypes = minusTypes.whereType<BuffType>().toList();

  factory BuffActionDetail.fromJson(Map<String, dynamic> json) =>
      _$BuffActionDetailFromJson(json);
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

  factory CardInfo.fromJson(Map<String, dynamic> json) =>
      _$CardInfoFromJson(json);
}

@JsonSerializable()
class GrailCostDetail {
  int qp;
  int addLvMax;
  SvtFrameType frameType;

  GrailCostDetail({
    required this.qp,
    required this.addLvMax,
    required this.frameType,
  });

  factory GrailCostDetail.fromJson(Map<String, dynamic> json) =>
      _$GrailCostDetailFromJson(json);
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

  factory MasterUserLvDetail.fromJson(Map<String, dynamic> json) =>
      _$MasterUserLvDetailFromJson(json);
}

@JsonSerializable()
class GameConstants {
  final int attackRate; // 230
  final int attackRateRandomMax; // 1100
  final int attackRateRandomMin; // 900
  final int backsideClassImageId; // 102
  final int backsideSvtEquipImageId; // 103
  final int backsideSvtImageId; // 101
  final int battleEffectIdAvoidance; // 6216
  final int battleEffectIdAvoidancePierce; // 6217
  final int battleEffectIdInvincible; // 6214
  final int battleEffectIdInvinciblePierce; // 6215
  final int battleItemDispColumn; // 7
  final int bpExpression; // 1
  final int chainbonusArtsRate; // 200
  final int chainbonusBusterRate; // 200
  final int chainbonusQuick; // 10
  final int commandArts; // 4001
  final int commandBuster; // 4002
  final int commandCardPrmUpMax; // 500
  final int commandCodeDetachingItemId; // 5003
  final int commandQuick; // 4003
  final int criticalAttackRate; // 2000
  final int criticalIndividuality; // 4100
  final int criticalRatePerStar; // 100
  final int criticalStarRate; // 200
  final int criticalTdPointRate; // 2000
  final int deckMax; // 10
  final int enemyAttackRateArts; // 1000
  final int enemyAttackRateBuster; // 1500
  final int enemyAttackRateQuick; // 800
  final int enemyMaxBattleCount; // 5
  final int extraAttackRateGrand; // 3500
  final int extraAttackRateSingle; // 2000
  final int extraCriticalRate; // 0
  final int followerListExpireAt; // 3600
  final int followerRefreshResetTime; // 10
  final int followFriendPoint; // 50
  final int friendNum; // 28
  final int fullTdPoint; // 10000
  final int heroineChangecardvoice; // 800104
  final int hydeSvtId; // 600710
  final int jekyllSvtId; // 600700
  final int largeSuccessMultExp; // 2000
  final int largeSuccessRate; // 100
  final int mashuChangeQuestId; // 1000501
  final int mashuChangeWarId; // 105
  final int mashuSvtId1; // 800100
  final int mashuSvtId2; // 800101
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
  final int maxUserCommandCode; // 350
  final int maxUserEquipExpUpRatio; // 3000
  final int maxUserItem; // 999999999
  final int maxUserLv; // 160
  final int maxUserSvt; // 600
  final int maxUserSvtEquip; // 600
  final int maxUserSvtEquipStorage; // 100
  final int maxUserSvtStorage; // 100
  final int menuChange; // 1
  final int overKillNpRate; // 1500
  final int overKillStarAdd; // 300
  final int overKillStarRate; // 1000
  final int starRateMax; // 3000
  final int statusUpAdjustAtk; // 10
  final int statusUpAdjustHp; // 10
  final int statusUpBuff; // 3004
  final int superSuccessMultExp; // 3000
  final int superSuccessRate; // 20
  final int supportDeckMax; // 10
  final int swimsuitMeltSvtId; // 304000
  final int tamamocatStunBuffId; // 178
  final int tamamocatTreasureDeviceId1; // 701601
  final int tamamocatTreasureDeviceId2; // 701602
  final int temporaryIgnoreSleepModeForTreasureDeviceSvtId1; // 500100
  final int temporaryIgnoreSleepModeForTreasureDeviceSvtId2; // 600900
  final int treasuredeviceIdMashu3; // 800104
  final int userAct; // 20
  final int userCost; // 56

  const GameConstants({
    this.attackRate = 230,
    this.attackRateRandomMax = 1100,
    this.attackRateRandomMin = 900,
    this.backsideClassImageId = 102,
    this.backsideSvtEquipImageId = 103,
    this.backsideSvtImageId = 101,
    this.battleEffectIdAvoidance = 6216,
    this.battleEffectIdAvoidancePierce = 6217,
    this.battleEffectIdInvincible = 6214,
    this.battleEffectIdInvinciblePierce = 6215,
    this.battleItemDispColumn = 7,
    this.bpExpression = 1,
    this.chainbonusArtsRate = 200,
    this.chainbonusBusterRate = 200,
    this.chainbonusQuick = 10,
    this.commandArts = 4001,
    this.commandBuster = 4002,
    this.commandCardPrmUpMax = 500,
    this.commandCodeDetachingItemId = 5003,
    this.commandQuick = 4003,
    this.criticalAttackRate = 2000,
    this.criticalIndividuality = 4100,
    this.criticalRatePerStar = 100,
    this.criticalStarRate = 200,
    this.criticalTdPointRate = 2000,
    this.deckMax = 10,
    this.enemyAttackRateArts = 1000,
    this.enemyAttackRateBuster = 1500,
    this.enemyAttackRateQuick = 800,
    this.enemyMaxBattleCount = 5,
    this.extraAttackRateGrand = 3500,
    this.extraAttackRateSingle = 2000,
    this.extraCriticalRate = 0,
    this.followerListExpireAt = 3600,
    this.followerRefreshResetTime = 10,
    this.followFriendPoint = 50,
    this.friendNum = 28,
    this.fullTdPoint = 10000,
    this.heroineChangecardvoice = 800104,
    this.hydeSvtId = 600710,
    this.jekyllSvtId = 600700,
    this.largeSuccessMultExp = 2000,
    this.largeSuccessRate = 100,
    this.mashuChangeQuestId = 1000501,
    this.mashuChangeWarId = 105,
    this.mashuSvtId1 = 800100,
    this.mashuSvtId2 = 800101,
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
    this.maxUserCommandCode = 350,
    this.maxUserEquipExpUpRatio = 3000,
    this.maxUserItem = 999999999,
    this.maxUserLv = 160,
    this.maxUserSvt = 600,
    this.maxUserSvtEquip = 600,
    this.maxUserSvtEquipStorage = 100,
    this.maxUserSvtStorage = 100,
    this.menuChange = 1,
    this.overKillNpRate = 1500,
    this.overKillStarAdd = 300,
    this.overKillStarRate = 1000,
    this.starRateMax = 3000,
    this.statusUpAdjustAtk = 10,
    this.statusUpAdjustHp = 10,
    this.statusUpBuff = 3004,
    this.superSuccessMultExp = 3000,
    this.superSuccessRate = 20,
    this.supportDeckMax = 10,
    this.swimsuitMeltSvtId = 304000,
    this.tamamocatStunBuffId = 178,
    this.tamamocatTreasureDeviceId1 = 701601,
    this.tamamocatTreasureDeviceId2 = 701602,
    this.temporaryIgnoreSleepModeForTreasureDeviceSvtId1 = 500100,
    this.temporaryIgnoreSleepModeForTreasureDeviceSvtId2 = 600900,
    this.treasuredeviceIdMashu3 = 800104,
    this.userAct = 20,
    this.userCost = 56,
  }); // 56
  factory GameConstants.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> json2 = {};
    for (final key in json.keys) {
      final segments = key.split('_').map((e) => e.toLowerCase()).toList();
      for (int index = 1; index < segments.length; index++) {
        String s = segments[index];
        segments[index] = s.substring(0, 1).toUpperCase() + s.substring(1);
      }
      String key2 = segments.join('');
      json2[key2] = json[key];
    }
    return _$GameConstantsFromJson(json2);
  }
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

@JsonEnum(alwaysCreate: true)
enum BuffAction {
  none,
  commandAtk,
  commandDef,
  atk,
  defence,
  defencePierce,
  specialdefence,
  damage,
  damageIndividuality,
  damageIndividualityActiveonly,
  selfdamage,
  criticalDamage,
  npdamage,
  givenDamage,
  receiveDamage,
  pierceInvincible,
  invincible,
  breakAvoidance,
  avoidance,
  overwriteBattleclass,
  overwriteClassrelatioAtk,
  overwriteClassrelatioDef,
  commandNpAtk,
  commandNpDef,
  dropNp,
  dropNpDamage,
  commandStarAtk,
  commandStarDef,
  criticalPoint,
  starweight,
  turnendNp,
  turnendStar,
  turnendHpRegain,
  turnendHpReduce,
  gainHp,
  turnvalNp,
  grantState,
  resistanceState,
  avoidState,
  donotAct,
  donotSkill,
  donotNoble,
  donotRecovery,
  individualityAdd,
  individualitySub,
  hate,
  criticalRate,
  avoidInstantdeath,
  resistInstantdeath,
  nonresistInstantdeath,
  regainNpUsedNoble,
  functionDead,
  maxhpRate,
  maxhpValue,
  functionWavestart,
  functionSelfturnend,
  giveGainHp,
  functionCommandattack,
  functionDeadattack,
  functionEntry,
  chagetd,
  grantSubstate,
  toleranceSubstate,
  grantInstantdeath,
  functionDamage,
  functionReflection,
  multiattack,
  giveNp,
  resistanceDelayNpturn,
  pierceDefence,
  gutsHp,
  funcgainNp,
  funcHpReduce,
  functionNpattack,
  fixCommandcard,
  donotGainnp,
  fieldIndividuality,
  donotActCommandtype,
  damageEventPoint,
  damageSpecial,
  functionAttack,
  functionCommandcodeattack,
  donotNobleCondMismatch,
  donotSelectCommandcard,
  donotReplace,
  shortenUserEquipSkill,
  tdTypeChange,
  overwriteClassRelation,
  functionCommandattackBefore,
  functionGuts,
  criticalRateDamageTaken,
  criticalStarDamageTaken,
  skillRankChange,
  avoidanceIndividuality,
  changeCommandCardType,
  specialInvincible,
  preventDeathByDamage,
  functionCommandcodeattackAfter,
  functionAttackBefore,
  donotSkillSelect,
  invisibleBattleChara,
  buffRate,
  counterFunction,
  notTargetSkill,
}

enum BuffLimit {
  none,
  upper,
  lower,
  normal,
}
