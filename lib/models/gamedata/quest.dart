import 'package:chaldea/models/gamedata/game_card.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../app/app.dart';
import '../db.dart';
import 'common.dart';
import 'item.dart';
import 'script.dart';
import 'servant.dart';
import 'skill.dart';
import 'wiki_data.dart';

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
  String spotName;
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
    required this.spotName,
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

  Transl<String, String> get lName => Transl.questNames(name);

  Transl<String, String> get lSpot => Transl.spotNames(spotName);

  void routeTo() => router.push(url: Routes.questI(id));

  String get lDispName {
    // 群島-10308, 裏山-20314
    if (isMainStoryFree) {
      return const [10308, 20314].contains(spotId)
          ? '${lSpot.l}(${lName.l})'
          : lSpot.l;
    }
    return lName.l;
  }

  String get dispName {
    if (isMainStoryFree) {
      return const [10308, 20314].contains(spotId)
          ? '$spotName($name)'
          : spotName;
    }
    return name;
  }

  bool get isMainStoryFree =>
      type == QuestType.free &&
      afterClear == QuestAfterClearType.repeatLast &&
      warId < 1000;

  // exclude challenge quest
  bool get isAnyFree =>
      afterClear == QuestAfterClearType.repeatLast &&
      !(consumeType == ConsumeType.ap && consume <= 5);
}

@JsonSerializable()
class QuestPhase extends Quest {
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
    required int id,
    required String name,
    required QuestType type,
    ConsumeType consumeType = ConsumeType.ap,
    required int consume,
    List<ItemAmount> consumeItem = const [],
    required QuestAfterClearType afterClear,
    required String recommendLv,
    required int spotId,
    required String spotName,
    required int warId,
    String warLongName = '',
    int chapterId = 0,
    int chapterSubId = 0,
    String chapterSubStr = "",
    List<Gift> gifts = const [],
    List<QuestRelease> releaseConditions = const [],
    required List<int> phases,
    List<int> phasesWithEnemies = const [],
    List<int> phasesNoBattle = const [],
    List<QuestPhaseScript> phaseScripts = const [],
    required int noticeAt,
    required int openedAt,
    required int closedAt,
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
  }) : super(
          id: id,
          name: name,
          type: type,
          consumeType: consumeType,
          consume: consume,
          consumeItem: consumeItem,
          afterClear: afterClear,
          recommendLv: recommendLv,
          spotId: spotId,
          spotName: spotName,
          warId: warId,
          warLongName: warLongName,
          chapterId: chapterId,
          chapterSubId: chapterSubId,
          chapterSubStr: chapterSubStr,
          gifts: gifts,
          releaseConditions: releaseConditions,
          phases: phases,
          phasesWithEnemies: phasesWithEnemies,
          phasesNoBattle: phasesNoBattle,
          phaseScripts: phaseScripts,
          noticeAt: noticeAt,
          openedAt: openedAt,
          closedAt: closedAt,
        );

  int get key => id * 10 + phase;

  List<QuestEnemy> get allEnemies =>
      [for (final stage in stages) ...stage.enemies];

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
    if (type == GiftType.equip || type == GiftType.eventSvtJoin) return false;
    return true;
  }

  Item? toItem() {
    if (type == GiftType.item) return db2.gameData.items[objectId];
    return null;
  }

  Widget iconBuilder({
    required BuildContext context,
    String? icon,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
  }) {
    switch (type) {
      case GiftType.servant:
      case GiftType.item:
      case GiftType.commandCode:
      case GiftType.eventSvtJoin:
      case GiftType.eventSvtGet:
      case GiftType.costumeRelease:
      case GiftType.costumeGet:
        break;
      case GiftType.friendship:
        break;
      case GiftType.userExp:
        break;
      case GiftType.equip:
        break;
      case GiftType.questRewardIcon:
        icon ??= Atlas.assetItem(9);
        break;
      case GiftType.eventPointBuff:
        break;
      case GiftType.eventBoardGameToken:
        break;
    }
    return GameCardMixin.anyCardItemBuilder(
      context: context,
      id: objectId,
      icon: icon,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text ?? (num > 0 ? num.format() : null),
      padding: padding,
      textPadding: textPadding,
      onTap: onTap,
      jumpToDetail: jumpToDetail,
      popDetail: popDetail,
    );
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
class EnemyDrop extends Gift {
  int dropCount;
  int runs;

  // double dropExpected;
  // double dropVariance;

  EnemyDrop({
    required GiftType type,
    required int objectId,
    required int num,
    required this.dropCount,
    required this.runs,
    // required this.dropExpected,
    // required this.dropVariance,
  }) : super(type: type, objectId: objectId, num: num);

  factory EnemyDrop.fromJson(Map<String, dynamic> json) =>
      _$EnemyDropFromJson(json);
}

@JsonSerializable()
class EnemyMisc {
  int displayType;
  int npcSvtType;
  List<int>? passiveSkill;
  int equipTargetId1;
  List<int>? equipTargetIds;
  int npcSvtClassId;
  int overwriteSvtId;

  // List<int> userCommandCodeIds;
  List<int>? commandCardParam;
  int status;

  EnemyMisc({
    this.displayType = 1,
    this.npcSvtType = 2,
    this.passiveSkill,
    this.equipTargetId1 = 0,
    this.equipTargetIds,
    this.npcSvtClassId = 0,
    this.overwriteSvtId = 0,
    this.commandCardParam,
    this.status = 0,
  });

  factory EnemyMisc.fromJson(Map<String, dynamic> json) =>
      _$EnemyMiscFromJson(json);
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
  EnemyScript enemyScript;

  // limit
  EnemyMisc misc;

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
    EnemyMisc? misc,
  })  : classPassive = classPassive ?? EnemyPassive(),
        enemyScript = enemyScript ?? EnemyScript(),
        misc = misc ?? EnemyMisc();

  // skills = skills ?? EnemySkill(),
  // noblePhantasm = noblePhantasm ?? EnemyTd(),

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
  closeDisp,
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
