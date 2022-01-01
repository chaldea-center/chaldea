part of gamedata;

@JsonSerializable()
class QuestRelease {
  CondType type;
  int targetId;
  int value;
  String closedMessage;

  QuestRelease({
    required this.type,
    required this.targetId,
    required this.value,
    required this.closedMessage,
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
    required this.consumeType,
    required this.consume,
    required this.consumeItem,
    required this.afterClear,
    required this.recommendLv,
    required this.spotId,
    required this.warId,
    required this.warLongName,
    required this.chapterId,
    required this.chapterSubId,
    required this.chapterSubStr,
    required this.gifts,
    required this.releaseConditions,
    required this.phases,
    required this.phasesWithEnemies,
    required this.phasesNoBattle,
    required this.phaseScripts,
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}

@JsonSerializable()
class QuestMessage {
  int idx;
  String message;
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

  // skills
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
class Stage {
  int wave;
  Bgm bgm;

  // fieldAis
  // calls
  List<QuestEnemy> enemies;

  Stage({
    required this.wave,
    required this.bgm,
    required this.enemies,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);
}

enum DeckType {
  enemy,
  call,
  shift,
  change,
  transform,
  skillShift,
  missionTargetSkillShift
}

@JsonSerializable()
class EnemyDrop {
  GiftType type;
  int objectId;
  int num;
  int dropCount;
  int runs;
  double dropExpected;
  double dropVariance;

  EnemyDrop({
    required this.type,
    required this.objectId,
    required this.num,
    required this.dropCount,
    required this.runs,
    required this.dropExpected,
    required this.dropVariance,
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
  List<EnemyDrop> drops;
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

  // skills
  EnemyPassive classPassive;

// noblePhantasm
  EnemyServerMod serverMod;

// ai
  EnemyScript enemyScript;

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
    required this.drops,
    required this.lv,
    required this.exp,
    required this.atk,
    required this.hp,
    required this.adjustAtk,
    required this.adjustHp,
    required this.deathRate,
    required this.criticalRate,
    required this.recover,
    required this.chargeTurn,
    required this.traits,
    required this.classPassive,
    required this.serverMod,
    required this.enemyScript,
  });

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
class EnemyPassive {
  List<NiceSkill> classPassive;
  List<NiceSkill> addPassive;

  EnemyPassive({
    required this.classPassive,
    required this.addPassive,
  });

  factory EnemyPassive.fromJson(Map<String, dynamic> json) =>
      _$EnemyPassiveFromJson(json);
}

@JsonSerializable()
class QuestPhase implements Quest {
  @override
  QuestAfterClearType afterClear;
  @override
  String recommendLv;
  @override
  int chapterId;
  @override
  int chapterSubId;
  @override
  String chapterSubStr;
  @override
  int closedAt;
  @override
  int consume;
  @override
  List<ItemAmount> consumeItem;
  @override
  ConsumeType consumeType;
  @override
  List<Gift> gifts;
  @override
  int id;
  @override
  String name;
  @override
  int noticeAt;
  @override
  int openedAt;
  @override
  List<int> phasesNoBattle;
  @override
  List<QuestPhaseScript> phaseScripts;
  @override
  List<int> phases;
  @override
  List<int> phasesWithEnemies;
  @override
  List<QuestRelease> releaseConditions;
  @override
  int spotId;
  @override
  QuestType type;
  @override
  int warId;
  @override
  String warLongName;
  int phase;
  List<SvtClass> className;
  List<NiceTrait> individuality;
  int qp;
  int exp;
  int bond;
  int battleBgId;
  List<ScriptLink> scripts;
  List<QuestMessage> messages;
  List<SupportServant> supportServants;
  List<Stage> stages;
  List<EnemyDrop> drops;

  QuestPhase({
    required this.afterClear,
    required this.recommendLv,
    required this.chapterId,
    required this.chapterSubId,
    required this.chapterSubStr,
    required this.closedAt,
    required this.consume,
    required this.consumeItem,
    required this.consumeType,
    required this.gifts,
    required this.id,
    required this.name,
    required this.noticeAt,
    required this.openedAt,
    required this.phasesNoBattle,
    required this.phaseScripts,
    required this.phases,
    required this.phasesWithEnemies,
    required this.releaseConditions,
    required this.spotId,
    required this.type,
    required this.warId,
    required this.warLongName,
    required this.phase,
    required this.className,
    required this.individuality,
    required this.qp,
    required this.exp,
    required this.bond,
    required this.battleBgId,
    required this.scripts,
    required this.messages,
    required this.supportServants,
    required this.stages,
    required this.drops,
  });

  factory QuestPhase.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseFromJson(json);
}
