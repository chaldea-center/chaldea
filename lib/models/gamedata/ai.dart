import 'package:chaldea/utils/utils.dart';
import '_helper.dart';
import 'common.dart';
import 'skill.dart';

part '../../generated/models/gamedata/ai.g.dart';

@JsonSerializable()
class NiceAiCollection {
  List<NiceAi> mainAis;
  List<NiceAi> relatedAis;
  List<StageLink> relatedQuests;
  NiceAiCollection({
    this.mainAis = const [],
    this.relatedAis = const [],
    this.relatedQuests = const [],
  });
  factory NiceAiCollection.fromJson(Map<String, dynamic> json) => _$NiceAiCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$NiceAiCollectionToJson(this);

  static List<NiceAi> sortedAis(List<NiceAi> ais) {
    ais = ais.toList();
    ais.sortByList((e) => [-e.priority, -e.probability, e.idx]);
    return ais;
  }
}

@JsonSerializable()
class NiceAi {
  int id;
  int idx;
  int actNumInt;
  NiceAiActNum actNum;
  int priority;
  int probability;

  NiceAiCond cond;
  bool condNegative;
  List<int> vals;

  NiceAiAct aiAct;
  // [changeThinking, id:message/playMotion]
  List<int> avals;
  Map<AiType, List<int>> parentAis;
  String infoText;
  // timing is only for field ai
  int? timing;
  AiTiming? timingDescription;

  NiceAi({
    required this.id,
    required this.idx,
    required this.actNumInt,
    this.actNum = NiceAiActNum.unknown,
    required this.priority,
    required this.probability,
    this.cond = NiceAiCond.none,
    this.condNegative = false,
    this.vals = const [],
    required this.aiAct,
    this.avals = const [],
    this.parentAis = const {},
    this.infoText = '',
    this.timing,
    this.timingDescription,
  });
  factory NiceAi.fromJson(Map<String, dynamic> json) => _$NiceAiFromJson(json);

  Map<String, dynamic> toJson() => _$NiceAiToJson(this);

  String get primaryKey => '$id:$idx';
}

@JsonSerializable()
class NiceAiAct {
  int id;
  NiceAiActType type;
  NiceAiActTarget target;
  List<NiceTrait> targetIndividuality;
  int? skillId;
  int? skillLv;
  NiceSkill? skill;
  int? noblePhantasmId;
  int? noblePhantasmLv;
  int? noblePhantasmOc; // 10000->100%
  NiceTd? noblePhantasm;

  NiceAiAct({
    required this.id,
    this.type = NiceAiActType.none,
    this.target = NiceAiActTarget.none,
    this.targetIndividuality = const [],
    this.skillId,
    this.skillLv,
    this.skill,
    this.noblePhantasmId,
    this.noblePhantasmLv,
    this.noblePhantasmOc,
    this.noblePhantasm,
  });
  factory NiceAiAct.fromJson(Map<String, dynamic> json) => _$NiceAiActFromJson(json);

  Map<String, dynamic> toJson() => _$NiceAiActToJson(this);
}

enum AiType {
  svt,
  field,
  ;

  static AiType? fromString(String s) {
    return AiType.values.firstWhere((e) => e.name == s);
  }
}

enum NiceAiActNum {
  nomal(0),
  anytime(-1),
  reactionPlyaerSkill(-3),
  reactionEnemyturnStart(-4),
  reactionEnemyturnEnd(-5),
  reactionDead(-6),
  reactionPlayeractionend(-7),
  reactionWavestart(-8),
  maxnp(-9),
  afterTurnPlayerEnd(-10),
  usenpTarget(-11),
  reactionTurnstart(-12),
  reactionPlayeractionstart(-13),
  reactionEntryUnit(-14),
  reactionBeforeResurrection(-15),
  reactionBeforeDead(-16),
  shiftServantAfter(-17),
  reactionBeforeMoveWave(-18),
  shiftServantBefore(-19),
  reactionEnemyTurnStartPriority(-401),
  reactionEnemyTurnEndPriority(-501),
  shiftServantBeforePriority(-1901),
  unknown(-9999),
  ;

  const NiceAiActNum(this.value);
  final int value;
}

enum NiceAiCond {
  none,
  hpHigher,
  hpLower,
  actcount,
  actcountMultiple,
  turn,
  turnMultiple,
  beforeActId,
  beforeActType,
  beforeNotActId,
  beforeNotActType,
  checkSelfBuff,
  checkSelfIndividuality,
  checkPtBuff,
  checkPtIndividuality,
  checkOpponentBuff,
  checkOpponentIndividuality,
  checkSelfBuffIndividuality,
  checkPtBuffIndividuality,
  checkOpponentBuffIndividuality,
  checkSelfNpturn,
  checkPtLowerNpturn,
  checkOpponentHeightNpgauge,
  actcountThisturn,
  checkPtHpHigher,
  checkPtHpLower,
  checkSelfNotBuffIndividuality,
  turnAndActcountThisturn,
  fieldturn,
  fieldturnMultiple,
  checkPtLowerTdturn,
  raidHpHigher,
  raidHpLower,
  raidCountHigher,
  raidCountLower,
  raidCountValueHigher,
  raidCountValueLower,
  checkSpace,
  turnHigher,
  turnLower,
  charactorTurnHigher,
  charactorTurnLower,
  countAlivePt,
  countAliveOpponent,
  countPtRestHigher,
  countPtRestLower,
  countOpponentRestHigher,
  countOpponentRestLower,
  countItemHigher,
  countItemLower,
  checkSelfBuffcountIndividuality,
  checkPtBuffcountIndividuality,
  checkSelfBuffActive,
  checkPtBuffActive,
  checkOpponentBuffActive,
  countEnemyCommandSpellHigher,
  checkPtAllIndividuality,
  checkOpponentAllIndividuality,
  starHigher,
  starLower,
  checkOpponentHpHigher,
  checkOpponentHpLower,
  checkTargetPosition,
  checkSelfBuffActiveAndPassiveIndividuality,
  checkPtBuffActiveAndPassiveIndividuality,
  checkOpponentBuffActiveAndPassiveIndividuality,
  checkPtAllBuff,
  checkOpponentAllBuff,
  checkPtAllBuffIndividuality,
  checkOpponentAllBuffIndividuality,
  countAlivePtAll,
  countAliveOpponentAll,
  checkPtAllBuffActive,
  checkOpponentAllBuffActive,
  countHigherBuffIndividualitySumPt,
  countHigherBuffIndividualitySumPtAll,
  countHigherBuffIndividualitySumOpponent,
  countHigherBuffIndividualitySumOpponentAll,
  countHigherBuffIndividualitySumSelf,
  countLowerBuffIndividualitySumPt,
  countLowerBuffIndividualitySumPtAll,
  countLowerBuffIndividualitySumOpponent,
  countLowerBuffIndividualitySumOpponentAll,
  countLowerBuffIndividualitySumSelf,
  countEqualBuffIndividualitySumPt,
  countEqualBuffIndividualitySumPtAll,
  countEqualBuffIndividualitySumOpponent,
  countEqualBuffIndividualitySumOpponentAll,
  countEqualBuffIndividualitySumSelf,
  existIndividualityOpponentFront,
  existIndividualityOpponentCenter,
  existIndividualityOpponentBack,
  totalCountHigherIndividualityPt,
  totalCountHigherIndividualityPtAll,
  totalCountHigherIndividualityOpponent,
  totalCountHigherIndividualityOpponentAll,
  totalCountHigherIndividualityAllField,
  totalCountLowerIndividualityPt,
  totalCountLowerIndividualityPtAll,
  totalCountLowerIndividualityOpponent,
  totalCountLowerIndividualityOpponentAll,
  totalCountLowerIndividualityAllField,
  totalCountEqualIndividualityPt,
  totalCountEqualIndividualityPtAll,
  totalCountEqualIndividualityOpponent,
  totalCountEqualIndividualityOpponentAll,
  totalCountEqualIndividualityAllField,
  ptFrontDeadEqual,
  ptCenterDeadEqual,
  ptBackDeadEqual,
  countHigherIndividualityPtFront,
  countHigherIndividualityPtCenter,
  countHigherIndividualityPtBack,
  countHigherIndividualityOpponentFront,
  countHigherIndividualityOpponentCenter,
  countHigherIndividualityOpponentBack,
  countLowerIndividualityPtFront,
  countLowerIndividualityPtCenter,
  countLowerIndividualityPtBack,
  countLowerIndividualityOpponentFront,
  countLowerIndividualityOpponentCenter,
  countLowerIndividualityOpponentBack,
  countEqualIndividualityPtFront,
  countEqualIndividualityPtCenter,
  countEqualIndividualityPtBack,
  countEqualIndividualityOpponentFront,
  countEqualIndividualityOpponentCenter,
  countEqualIndividualityOpponentBack,
  checkPrecedingEnemy,
  countHigherRemainTurn,
  countLowerRemainTurn,
  countHigherPlayerCommandSpell,
  countLowerPlayerCommandSpell,
  countEqualPlayerCommandSpell,
  checkMasterSkillThisturn,
  checkSelfNpturnHigher,
  checkSelfNpturnLower,
  checkUseSkillThisturn,
  countChainHigher,
  countChainLower,
  countChainEqual,
  checkSelectChain,
  countPlayerNpHigher,
  countPlayerNpLower,
  countPlayerNpEqual,
  countPlayerSkillHigher,
  countPlayerSkillLower,
  countPlayerSkillEqual,
  countPlayerSkillHigherIncludeMasterSkill,
  countPlayerSkillLowerIncludeMasterSkill,
  countPlayerSkillEqualIncludeMasterSkill,
  totalTurnHigher,
  totalTurnLower,
  totalTurnEqual,
  checkWarBoardSquareIndividuality,
  checkPtHigherNpgauge,
  checkSelfHigherNpgauge,
  checkBattleValueAbove,
  checkBattleValueEqual,
  checkBattleValueNotEqual,
  checkBattleValueBelow,
  checkBattleValueBetween,
  checkBattleValueNotBetween,
  checkUseMasterSkillIndex,
  checkUseMasterSkillIndexThisTurn,
  countMasterSkillHigherThisTurn,
  countMasterSkillLowerThisTurn,
  countMasterSkillEqualThisTurn,
  countMasterSkillHigherThisWave,
  countMasterSkillLowerThisWave,
  countMasterSkillEqualThisWave,
  countAvailablePlayerAndMasterSkillHigher,
  countAvailablePlayerAndMasterSkillLower,
  countAvailablePlayerAndMasterSkillEqual,
  countAvailablePlayerSkillHigher,
  countAvailablePlayerSkillLower,
  countAvailablePlayerSkillEqual,
  countAvailableMasterSkillHigher,
  countAvailableMasterSkillLower,
  countAvailableMasterSkillEqual,
}

enum AiTiming {
  dead(-6),
  // -3
  unknown(-1),
  waveStart(1),
  turnStart(2),
  turnPlayerStart(3),
  turnPlayerEnd(4),
  turnEnemyStart(5),
  turnEnemyEnd(6),
  // 7
  // 8
  ;

  const AiTiming(this.value);
  final int value;
}

enum NiceAiActType {
  none,
  random,
  attack,
  skillRandom,
  skill1,
  skill2,
  skill3,
  attackA,
  attackB,
  attackQ,
  attackACritical,
  attackBCritical,
  attackQCritical,
  attackCritical,
  skillId,
  skillIdCheckbuff,
  resurrection,
  playMotion,
  message,
  messageGroup,
  noblePhantasm,
  battleEnd,
  loseEnd,
  battleEndNotRelatedSurvivalStatus,
  changeThinking,
}

enum NiceAiActTarget {
  none,
  random,
  hpHigher,
  hpLower,
  npturnLower,
  npgaugeHigher,
  revenge,
  individualityActive,
  buffActive,
  front,
  center,
  back,
}

// enum NiceAiCondParameter
