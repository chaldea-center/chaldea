import 'package:chaldea/utils/extension.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'quest.dart' show Gift;
import 'servant.dart';
import 'skill.dart';

part '../../generated/models/gamedata/const_data.g.dart';

@JsonSerializable(converters: [SvtClassConverter(), BuffActionConverter()])
class ConstGameData {
  final Map<Attribute, Map<Attribute, int>> attributeRelation;
  final Map<BuffAction, BuffActionDetail> buffActions;
  final Map<CardType, Map<int, CardInfo>> cardInfo;
  final Map<int, SvtClassInfo> classInfo;
  final Map<int, Map<int, int>> classRelation;
  final GameConstants constants;
  final Map<int, Map<int, GrailCostDetail>>
      svtGrailCost; // <rarity, <grail_count, detail>>
  final Map<int, MasterUserLvDetail> userLevel;
  final Map<int, SvtExpCurve> svtExp;
  final Map<int, int> bondLimitQp = {
    10: 10000000,
    11: 12000000,
    12: 14000000,
    13: 16000000,
    14: 18000000
  };
  final Map<BuffType, BuffAction> buffTypeActionMap;

  final Map<int, int> svtClassCardImageIdRemap = {
    285: 123,
    351: 223,
  };

  ConstGameData({
    this.attributeRelation = const {},
    this.buffActions = const {},
    this.cardInfo = const {},
    this.classInfo = const {},
    this.classRelation = const {},
    this.constants = const GameConstants(),
    this.svtGrailCost = const {},
    this.userLevel = const {},
    this.svtExp = const {},
  }) : buffTypeActionMap = {
          for (final entry in buffActions.entries)
            for (final type in [
              ...entry.value.plusTypes,
              ...entry.value.minusTypes
            ])
              type: entry.key
        };

  factory ConstGameData.fromJson(Map<String, dynamic> json) {
    jsonMigrated(json, 'classInfo', 'classInfo2');
    jsonMigrated(json, 'classRelation', 'classRelation2');
    return _$ConstGameDataFromJson(json);
  }

  List<int> getSvtCurve(
      int growthCurve, int baseValue, int maxValue, int? maxLv) {
    final expData = svtExp[growthCurve];
    if (expData == null) return [];
    // atkBase + (atkMax - atkBase) * exp.curve // 1000
    if (maxLv == null) {
      return expData.curve
          .skip(1)
          .map((e) => baseValue + (maxValue - baseValue) * e ~/ 1000)
          .toList();
    }
    return [
      for (int index = 1; index < expData.lv.length; index++)
        if (expData.lv[index] <= maxLv)
          baseValue + (maxValue - baseValue) * expData.curve[index] ~/ 1000
    ];
  }
}

@JsonSerializable(converters: [BuffTypeConverter()])
class BuffActionDetail {
  BuffLimit limit;
  List<BuffType> plusTypes;
  List<BuffType> minusTypes;
  int baseParam;
  int baseValue;
  bool isRec;
  int plusAction;
  List<int> maxRate;

  BuffActionDetail({
    required this.limit,
    required this.plusTypes,
    required this.minusTypes,
    required this.baseParam,
    required this.baseValue,
    required this.isRec,
    required this.plusAction,
    required this.maxRate,
  });

  factory BuffActionDetail.fromJson(Map<String, dynamic> json) =>
      _$BuffActionDetailFromJson(json);
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

  factory SvtClassInfo.fromJson(Map<String, dynamic> json) =>
      _$SvtClassInfoFromJson(json);
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
    this.frameType = SvtFrameType.gold,
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

  factory SvtExpCurve.fromJson(Map<String, dynamic> json) =>
      _$SvtExpCurveFromJson(json);
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
      exp: curve?.exp.skip(skip).toList() ?? [],
      hp: curve?.curve
              .skip(skip)
              .map((e) => hpBase + (hpMax - hpBase) * e ~/ 1000)
              .toList() ??
          [],
      atk: curve?.curve
              .skip(skip)
              .map((e) => atkBase + (atkMax - atkBase) * e ~/ 1000)
              .toList() ??
          [],
    );
  }
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

class BuffActionConverter extends JsonConverter<BuffAction, String> {
  const BuffActionConverter();
  @override
  BuffAction fromJson(String value) =>
      decodeEnum(_$BuffActionEnumMap, value, BuffAction.unknown);
  @override
  String toJson(BuffAction obj) => _$BuffActionEnumMap[obj] ?? obj.name;
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
  functionCommandattack(57),
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
  functionAttack(80),
  functionCommandcodeattack(81),
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
  ;

  final int id;
  const BuffAction(this.id);
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
