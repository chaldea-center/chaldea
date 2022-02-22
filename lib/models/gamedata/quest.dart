import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'item.dart';
import 'script.dart';
import 'servant.dart';
import 'skill.dart';

part '../../generated/models/gamedata/quest.g.dart';

@JsonSerializable()
class BasicQuest {
  int id;
  String name;
  QuestType type;
  ConsumeType consumeType;
  int consume;
  int spotId;
  int warId;
  String warLongName;
  int noticeAt;
  int openedAt;
  int closedAt;

  BasicQuest({
    required this.id,
    required this.name,
    required this.type,
    required this.consumeType,
    required this.consume,
    required this.spotId,
    required this.warId,
    required this.warLongName,
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  });

  factory BasicQuest.fromJson(Map<String, dynamic> json) =>
      _$BasicQuestFromJson(json);
}

@JsonSerializable()
class Quest {
  int id;
  String name;
  QuestType type;
  ConsumeType consumeType;
  int consume;
  List<ItemAmount> consumeItem;
  QuestAfterClearType afterClear;
  String recommendLv;
  int spotId;
  int warId;
  String warLongName;
  int chapterId;
  int chapterSubId;
  String chapterSubStr;
  List<Gift> gifts;
  List<QuestRelease> releaseConditions;
  List<int> phases;
  List<int> phasesWithEnemies;
  List<int> phasesNoBattle;
  List<QuestPhaseScript> phaseScripts;
  int noticeAt;
  int openedAt;
  int closedAt;

  Quest({
    required this.id,
    required this.name,
    required this.type,
    this.consumeType = ConsumeType.ap,
    required this.consume,
    this.consumeItem = const [],
    required this.afterClear,
    required this.recommendLv,
    required this.spotId,
    required this.warId,
    this.warLongName = '',
    this.chapterId = 0,
    this.chapterSubId = 0,
    this.chapterSubStr = "",
    this.gifts = const [],
    this.releaseConditions = const [],
    required this.phases,
    this.phasesWithEnemies = const [],
    this.phasesNoBattle = const [],
    this.phaseScripts = const [],
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}

@JsonSerializable()
class QuestPhase implements Quest {
  @override
  int id;
  @override
  String name;
  @override
  QuestType type;
  @override
  ConsumeType consumeType;
  @override
  int consume;
  @override
  List<ItemAmount> consumeItem;
  @override
  QuestAfterClearType afterClear;
  @override
  String recommendLv;
  @override
  int spotId;
  @override
  int warId;
  @override
  String warLongName;
  @override
  int chapterId;
  @override
  int chapterSubId;
  @override
  String chapterSubStr;
  @override
  List<Gift> gifts;
  @override
  List<QuestRelease> releaseConditions;
  @override
  List<int> phases;
  @override
  List<int> phasesWithEnemies;
  @override
  List<int> phasesNoBattle;
  @override
  List<QuestPhaseScript> phaseScripts;
  @override
  int noticeAt;
  @override
  int openedAt;
  @override
  int closedAt;
  int phase;
  List<SvtClass> className;
  List<NiceTrait> individuality;
  int qp;
  int exp;
  int bond;
  int battleBgId;
  QuestPhaseExtraDetail extraDetail;
  List<ScriptLink> scripts;
  List<QuestMessage> messages;
  List<SupportServant> supportServants;
  List<Stage> stages;
  List<EnemyDrop> drops;

  QuestPhase({
    required this.id,
    required this.name,
    required this.type,
    this.consumeType = ConsumeType.ap,
    required this.consume,
    this.consumeItem = const [],
    required this.afterClear,
    required this.recommendLv,
    required this.spotId,
    required this.warId,
    this.warLongName = '',
    this.chapterId = 0,
    this.chapterSubId = 0,
    this.chapterSubStr = "",
    this.gifts = const [],
    this.releaseConditions = const [],
    required this.phases,
    this.phasesWithEnemies = const [],
    this.phasesNoBattle = const [],
    this.phaseScripts = const [],
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
    required this.phase,
    this.className = const [],
    this.individuality = const [],
    required this.qp,
    required this.exp,
    required this.bond,
    required this.battleBgId,
    required this.extraDetail,
    this.scripts = const [],
    this.messages = const [],
    this.supportServants = const [],
    this.stages = const [],
    this.drops = const [],
  });

  int get key => id * 10 + phase;

  factory QuestPhase.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseFromJson(json);
}

@JsonSerializable()
class Gift {
  // int id;
  GiftType type;
  int objectId;

  // int priority;
  int num;

  Gift({
    // required this.id,
    this.type = GiftType.item,
    required this.objectId,
    // required this.priority,
    required this.num,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

  bool get isStatItem {
    return (type == GiftType.item || type == GiftType.servant) &&
        Items.isStatItem(objectId);
  }
}

@JsonSerializable()
class Stage {
  int wave;
  Bgm bgm;

  List<FieldAi> fieldAis;
  List<int> calls;
  List<QuestEnemy> enemies;

  Stage({
    required this.wave,
    required this.bgm,
    this.fieldAis = const [],
    this.calls = const [],
    this.enemies = const [],
  });

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);
}

@JsonSerializable()
class QuestRelease {
  @JsonKey(fromJson: toEnumCondType)
  CondType type;
  int targetId;
  int value;
  String closedMessage;

  QuestRelease({
    required this.type,
    required this.targetId,
    this.value = 0,
    this.closedMessage = "",
  });

  factory QuestRelease.fromJson(Map<String, dynamic> json) =>
      _$QuestReleaseFromJson(json);
}

@JsonSerializable()
class QuestPhaseScript {
  int phase;
  List<ScriptLink> scripts;

  QuestPhaseScript({
    required this.phase,
    required this.scripts,
  });

  factory QuestPhaseScript.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseScriptFromJson(json);
}

@JsonSerializable()
class QuestMessage {
  int idx;
  String message;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int targetId;
  int targetNum;

  QuestMessage({
    required this.idx,
    required this.message,
    required this.condType,
    required this.targetId,
    required this.targetNum,
  });

  factory QuestMessage.fromJson(Map<String, dynamic> json) =>
      _$QuestMessageFromJson(json);
}

@JsonSerializable()
class SupportServant {
  int id;
  int priority;
  String name;
  BasicServant svt;

  // releaseConditions
  int lv;
  int atk;
  int hp;
  List<NiceTrait> traits;

  // skills;
  // noblePhantasm
  // equips
  //  script
  // limit
  // misc

  SupportServant({
    required this.id,
    required this.priority,
    required this.name,
    required this.svt,
    required this.lv,
    required this.atk,
    required this.hp,
    required this.traits,
  });

  factory SupportServant.fromJson(Map<String, dynamic> json) =>
      _$SupportServantFromJson(json);
}

@JsonSerializable()
class EnemyDrop {
  GiftType type;
  int objectId;
  int num;
  int dropCount;
  int runs;

  // double dropExpected;
  // double dropVariance;

  EnemyDrop({
    required this.type,
    required this.objectId,
    required this.num,
    required this.dropCount,
    required this.runs,
    // required this.dropExpected,
    // required this.dropVariance,
  });

  factory EnemyDrop.fromJson(Map<String, dynamic> json) =>
      _$EnemyDropFromJson(json);
}

@JsonSerializable()
class QuestEnemy {
  DeckType deck;
  int deckId;
  int userSvtId;
  int uniqueId;
  int npcId;
  EnemyRoleType roleType;
  String name;
  BasicServant svt;

  // List<EnemyDrop> drops;
  int lv;
  int exp;
  int atk;
  int hp;
  int adjustAtk;
  int adjustHp;
  int deathRate;
  int criticalRate;
  int recover;
  int chargeTurn;
  List<NiceTrait> traits;

  // EnemySkill skills;
  EnemyPassive classPassive;

  // EnemyTd noblePhantasm;
  EnemyServerMod serverMod;

  // EnemyAi ai;
  // EnemyScript enemyScript;

  // limit
  // misc

  QuestEnemy({
    required this.deck,
    required this.deckId,
    required this.userSvtId,
    required this.uniqueId,
    required this.npcId,
    required this.roleType,
    required this.name,
    required this.svt,
    // this.drops = const [],
    required this.lv,
    this.exp = 0,
    required this.atk,
    required this.hp,
    this.adjustAtk = 0,
    this.adjustHp = 0,
    required this.deathRate,
    required this.criticalRate,
    this.recover = 0,
    this.chargeTurn = 0,
    this.traits = const [],
    EnemySkill? skills,
    EnemyPassive? classPassive,
    EnemyTd? noblePhantasm,
    required this.serverMod,
    // required this.ai,
    EnemyScript? enemyScript,
  }) : classPassive = classPassive ?? EnemyPassive();

  // skills = skills ?? EnemySkill(),
  // noblePhantasm = noblePhantasm ?? EnemyTd(),
  // enemyScript = enemyScript ?? EnemyScript();

  factory QuestEnemy.fromJson(Map<String, dynamic> json) =>
      _$QuestEnemyFromJson(json);
}

@JsonSerializable()
class EnemyServerMod {
  int tdRate;
  int tdAttackRate;
  int starRate;

  // lots of others

  EnemyServerMod({
    required this.tdRate,
    required this.tdAttackRate,
    required this.starRate,
  });

  factory EnemyServerMod.fromJson(Map<String, dynamic> json) =>
      _$EnemyServerModFromJson(json);
}

@JsonSerializable()
class EnemyScript {
  // lots of fields are skipped
  EnemyDeathType? deathType;
  int? hpBarType;
  bool? leader;
  List<int>? call;
  List<int>? shift;
  List<NiceTrait>? shiftClear;

  EnemyScript({
    this.deathType,
    this.hpBarType,
    this.leader,
    this.call,
    this.shift,
    this.shiftClear,
  });

  factory EnemyScript.fromJson(Map<String, dynamic> json) =>
      _$EnemyScriptFromJson(json);
}

@JsonSerializable()
class EnemySkill {
  int skillId1;
  int skillId2;
  int skillId3;
  NiceSkill? skill1;
  NiceSkill? skill2;
  NiceSkill? skill3;
  int skillLv1;
  int skillLv2;
  int skillLv3;

  EnemySkill({
    this.skillId1 = 0,
    this.skillId2 = 0,
    this.skillId3 = 0,
    this.skill1,
    this.skill2,
    this.skill3,
    this.skillLv1 = 0,
    this.skillLv2 = 0,
    this.skillLv3 = 0,
  });

  factory EnemySkill.fromJson(Map<String, dynamic> json) =>
      _$EnemySkillFromJson(json);
}

@JsonSerializable()
class EnemyTd {
  int noblePhantasmId;
  NiceTd? noblePhantasm;
  int noblePhantasmLv;
  int noblePhantasmLv1;

  EnemyTd({
    this.noblePhantasmId = 0,
    this.noblePhantasm,
    this.noblePhantasmLv = 0,
    this.noblePhantasmLv1 = 0,
  });

  factory EnemyTd.fromJson(Map<String, dynamic> json) =>
      _$EnemyTdFromJson(json);
}

@JsonSerializable()
class EnemyPassive {
  List<NiceSkill> classPassive;
  List<NiceSkill> addPassive;

  EnemyPassive({
    this.classPassive = const [],
    this.addPassive = const [],
  });

  factory EnemyPassive.fromJson(Map<String, dynamic> json) =>
      _$EnemyPassiveFromJson(json);
}

// class EnemyLimit{}
// class EnemyMisc{}

@JsonSerializable()
class EnemyAi {
  int aiId;
  int actPriority;
  int maxActNum;

  EnemyAi({
    required this.aiId,
    required this.actPriority,
    required this.maxActNum,
  });

  factory EnemyAi.fromJson(Map<String, dynamic> json) =>
      _$EnemyAiFromJson(json);
}

@JsonSerializable()
class FieldAi {
  int? raid;
  int? day;
  int id;

  FieldAi({
    this.raid,
    this.day,
    required this.id,
  });

  factory FieldAi.fromJson(Map<String, dynamic> json) =>
      _$FieldAiFromJson(json);
}

@JsonSerializable()
class QuestPhaseExtraDetail {
  List<int>? questSelect;
  int? singleForceSvtId;

  QuestPhaseExtraDetail({
    this.questSelect,
    this.singleForceSvtId,
  });

  factory QuestPhaseExtraDetail.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseExtraDetailFromJson(json);
}

enum QuestType {
  main,
  free,
  friendship,
  event,
  heroballad,
  warBoard,
}

enum ConsumeType {
  none,
  ap,
  rp,
  item,
  apAndItem,
}

enum QuestAfterClearType {
  close,
  repeatFirst,
  repeatLast,
  resetInterval,
}

enum GiftType {
  servant,
  item,
  friendship,
  userExp,
  equip,
  eventSvtJoin,
  eventSvtGet,
  questRewardIcon,
  costumeRelease,
  costumeGet,
  commandCode,
  eventPointBuff,
  eventBoardGameToken,
}
enum EnemyRoleType {
  normal,
  danger,
  servant,
}

enum EnemyDeathType {
  escape,
  stand,
  effect,
  wait,
}

enum DeckType {
  enemy,
  call,
  shift,
  change,
  transform,
  skillShift,
  missionTargetSkillShift,
}
