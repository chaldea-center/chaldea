import 'package:flutter/widgets.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/game_card.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import '../../app/modules/enemy/quest_enemy.dart';
import '../db.dart';
import '_helper.dart';
import 'common.dart';
import 'item.dart';
import 'mappings.dart';
import 'script.dart';
import 'servant.dart';
import 'skill.dart';
import 'war.dart';

part '../../generated/models/gamedata/quest.g.dart';

@JsonSerializable()
class BasicQuest {
  int id;
  String name;
  QuestType type;
  @QuestFlagConverter()
  List<QuestFlag> flags;
  ConsumeType consumeType;
  int consume;
  int spotId;
  int warId;
  String warLongName;
  int priority;
  int noticeAt;
  int openedAt;
  int closedAt;

  BasicQuest({
    required this.id,
    required this.name,
    required this.type,
    this.flags = const [],
    required this.consumeType,
    required this.consume,
    required this.spotId,
    required this.warId,
    required this.warLongName,
    required this.priority,
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  });

  factory BasicQuest.fromJson(Map<String, dynamic> json) =>
      _$BasicQuestFromJson(json);
}

@JsonSerializable()
class Quest with RouteInfo {
  int id;
  String name;
  QuestType type;
  @QuestFlagConverter()
  List<QuestFlag> flags;
  ConsumeType consumeType;
  int consume;
  List<ItemAmount> consumeItem;
  QuestAfterClearType afterClear;
  String recommendLv;
  int spotId;
  @protected
  String spotName;
  int warId;
  String warLongName;
  int chapterId;
  int chapterSubId;
  String chapterSubStr;
  String? giftIcon;
  List<Gift> gifts;
  List<QuestRelease> releaseConditions;
  List<int> phases;
  List<int> phasesWithEnemies;
  List<int> phasesNoBattle;
  List<QuestPhaseScript> phaseScripts;
  int priority; // large=top
  int noticeAt;
  int openedAt;
  int closedAt;

  Quest({
    required this.id,
    required this.name,
    required this.type,
    this.flags = const [],
    this.consumeType = ConsumeType.ap,
    required this.consume,
    this.consumeItem = const [],
    required this.afterClear,
    required this.recommendLv,
    required this.spotId,
    required String spotName,
    required this.warId,
    this.warLongName = '',
    this.chapterId = 0,
    this.chapterSubId = 0,
    this.chapterSubStr = "",
    this.giftIcon,
    this.gifts = const [],
    this.releaseConditions = const [],
    required this.phases,
    this.phasesWithEnemies = const [],
    this.phasesNoBattle = const [],
    this.phaseScripts = const [],
    required this.priority,
    required this.noticeAt,
    required this.openedAt,
    required this.closedAt,
  }) : spotName = spotName == '0' ? '' : spotName;

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);

  int getPhaseKey(int phase) => id * 100 + phase;

  Transl<String, String> get lName {
    final names = Transl.questNames(name);
    if (names.maybeOf(null) == null && name.startsWith('強化クエスト')) {
      final match = RegExp(r'^強化クエスト (.*?)(\s+\d+)?$').firstMatch(name);
      if (match != null) {
        final name2 = <String?>[
          Transl.questNames('強化クエスト').l,
          Transl.svtNames(match.group(1)!).l,
          match.group(2)?.trim()
        ].whereType<String>().join(' ');
        return Transl.questNames(name2);
      }
    }
    return names;
  }

  NiceSpot? get spot => db.gameData.spots[spotId];
  NiceWar? get war => db.gameData.wars[warId];

  @override
  String get route => Routes.questI(id);

  Transl<String, String> get lSpot {
    final spot = this.spot;
    if (spot == null) return Transl.spotNames(spotName);
    String shownName = spotName;
    Set<String> allNames = {spotName};
    for (final add in spot.spotAdds) {
      final name2 = add.overwriteSpotName;
      if (name2 == null) continue;
      allNames.add(name2);
      if ((add.condType == CondType.questClear && id > add.condTargetId) ||
          (add.condType == CondType.questClearPhase &&
              id >= add.condTargetId)) {
        shownName = add.targetText;
      }
    }
    return Transl.spotNames(shownName);
    // final extraNames = allNames.where((e) => e != shownName).toList();
    // if (extraNames.isEmpty) return Transl.spotNames(shownName);
    // final m = MappingBase<String>().convert<String>((v, region) {
    //   String _cvt(String s) => Transl.spotNames(s).of(region);
    //   if (region == Region.jp) return '$shownName (${extraNames.join(" / ")})';
    //   return '${_cvt(shownName)} (${extraNames.map((e) => _cvt(e)).join(" / ")})';
    // });
    // return Transl({m.jp!: m}, m.jp!, m.jp!);
  }

  String get lDispName {
    // 群島-10308, 裏山-20314
    if (isMainStoryFree) {
      return const [10308, 20314].contains(spotId)
          ? '${lSpot.l}(${lName.l})'
          : lSpot.l;
    }
    return lName.l;
  }

  String get chapter {
    if (type == QuestType.main) {
      if (chapterSubStr.isEmpty && chapterSubId != 0) {
        return S.current.quest_chapter_n(chapterSubId);
      } else {
        return Transl.questNames(chapterSubStr).l.trim();
      }
    }
    return '';
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

  bool get isDomusQuest =>
      isMainStoryFree || db.gameData.dropRate.newData.questIds.contains(id);

  // exclude challenge quest, raid
  bool get isAnyFree {
    if (afterClear != QuestAfterClearType.repeatLast) return false;
    if (type == QuestType.free) return true;
    if (flags.any((flag) => flag.name.toLowerCase().contains('raid'))) {
      return false;
    }
    if (flags.contains(QuestFlag.noBattle)) return false;
    return !(consumeType == ConsumeType.ap && consume <= 5);
  }

  List<String> get allScriptIds {
    return [
      for (final phase in phaseScripts) ...phase.scripts.map((e) => e.scriptId)
    ];
  }
}

@JsonSerializable(converters: [SvtClassConverter()])
class QuestPhase extends Quest {
  int phase;
  List<SvtClass> className;
  List<NiceTrait> individuality;
  int qp;
  int exp;
  int bond;
  bool isNpcOnly;
  int battleBgId;
  QuestPhaseExtraDetail? extraDetail;
  List<ScriptLink> scripts;
  List<QuestMessage> messages;
  List<QuestPhaseRestriction> restrictions;
  List<SupportServant> supportServants;
  List<Stage> stages;
  List<EnemyDrop> drops;

  QuestPhase({
    required super.id,
    required super.name,
    required super.type,
    super.flags = const [],
    super.consumeType = ConsumeType.ap,
    required super.consume,
    super.consumeItem = const [],
    required super.afterClear,
    required super.recommendLv,
    required super.spotId,
    required super.spotName,
    required super.warId,
    super.warLongName = '',
    super.chapterId = 0,
    super.chapterSubId = 0,
    super.chapterSubStr = "",
    super.gifts = const [],
    super.releaseConditions = const [],
    required super.phases,
    super.phasesWithEnemies = const [],
    super.phasesNoBattle = const [],
    super.phaseScripts = const [],
    required super.priority,
    required super.noticeAt,
    required super.openedAt,
    required super.closedAt,
    required this.phase,
    this.className = const [],
    this.individuality = const [],
    required this.qp,
    required this.exp,
    required this.bond,
    this.isNpcOnly = false,
    required this.battleBgId,
    this.extraDetail,
    this.scripts = const [],
    this.messages = const [],
    this.restrictions = const [],
    this.supportServants = const [],
    this.stages = const [],
    this.drops = const [],
  });

  int get key => getPhaseKey(phase);

  List<QuestEnemy> get allEnemies =>
      [for (final stage in stages) ...stage.enemies];

  @override
  Transl<String, String> get lSpot {
    final spot = this.spot;
    if (spot == null) return Transl.spotNames(spotName);
    String shownName = spotName;
    for (final add in spot.spotAdds) {
      if (add.overrideType != SpotOverwriteType.name ||
          add.targetText.isEmpty) {
        continue;
      }
      if (add.condType == CondType.questClear && id > add.condTargetId) {
        shownName = add.targetText;
      } else if (add.condType == CondType.questClearPhase) {
        if (id > add.condTargetId ||
            (id == add.condTargetId && phase > add.condNum)) {
          shownName = add.targetText;
        }
      }
    }
    return Transl.spotNames(shownName);
  }

  factory QuestPhase.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseFromJson(json);
}

@JsonSerializable()
class BaseGift {
  // int id;
  GiftType type;
  int objectId;

  // int priority;
  int num;

  BaseGift({
    // required this.id,
    this.type = GiftType.item,
    required this.objectId,
    // required this.priority,
    required this.num,
  });

  factory BaseGift.fromJson(Map<String, dynamic> json) =>
      _$BaseGiftFromJson(json);

  bool get isStatItem {
    if ([GiftType.equip, GiftType.eventSvtJoin, GiftType.eventPointBuff]
        .contains(type)) return false;
    return true;
  }

  Item? toItem() {
    if (type == GiftType.item) return db.gameData.items[objectId];
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
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
    String? name,
    bool showName = false,
    bool showOne = true,
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
        icon ??= db.gameData.mysticCodes[objectId]?.icon;
        onTap ??= () {
          router.push(url: Routes.mysticCodeI(objectId));
        };
        break;
      case GiftType.questRewardIcon:
        icon ??= Atlas.assetItem(objectId);
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
      text: text ?? ((num > 1 || (num == 1 && showOne)) ? num.format() : null),
      padding: padding,
      onTap: onTap,
      jumpToDetail: jumpToDetail,
      popDetail: popDetail,
      name: name,
      showName: showName,
    );
  }

  String get shownName {
    String? name;
    if (type == GiftType.equip) {
      name = db.gameData.mysticCodes[objectId]?.lName.l;
    }
    name ??= GameCardMixin.anyCardItemName(objectId).l;
    return name;
  }

  void routeTo() {
    String? route;
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
        route = Routes.mysticCodeI(objectId);
        break;
      case GiftType.questRewardIcon:
        break;
      case GiftType.eventPointBuff:
        break;
      case GiftType.eventBoardGameToken:
        break;
    }
    route ??= GameCardMixin.getRoute(objectId);
    if (route != null) {
      router.push(url: route);
    }
  }
}

@JsonSerializable()
class GiftAdd {
  int priority;
  String replacementGiftIcon;
  @CondTypeConverter()
  CondType condType;
  int targetId;
  int targetNum;
  List<BaseGift> replacementGifts;

  GiftAdd({
    required this.priority,
    required this.replacementGiftIcon,
    required this.condType,
    required this.targetId,
    required this.targetNum,
    required this.replacementGifts,
  });

  factory GiftAdd.fromJson(Map<String, dynamic> json) =>
      _$GiftAddFromJson(json);
}

@JsonSerializable()
class Gift extends BaseGift {
  List<GiftAdd> giftAdds;
  Gift({
    // required this.id,
    super.type = GiftType.item,
    required super.objectId,
    // required this.priority,
    // ignore: avoid_types_as_parameter_names
    required super.num,
    this.giftAdds = const [],
  });

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

  static void checkAddGifts(Map<int, int> stat, List<Gift> gifts,
      [int setNum = 1]) {
    Map<int, int> repls = {};
    if (gifts.any((gift) => gift.giftAdds.isNotEmpty)) {
      final giftAdd =
          gifts.firstWhere((e) => e.giftAdds.isNotEmpty).giftAdds.first;
      final replGifts = giftAdd.replacementGifts;
      for (final gift in replGifts) {
        if (giftAdd.replacementGiftIcon.endsWith('Items/19.png') &&
            gift.objectId == Items.crystalId) {
          repls.addNum(Items.grailToCrystalId, gift.num * setNum);
          repls.addNum(Items.grailId, -gift.num * setNum);
        } else if (gift.objectId == Items.rarePrismId) {
          repls.addNum(gift.objectId, gift.num * setNum);
        }
      }
    }
    for (final gift in gifts) {
      if (gift.isStatItem) stat.addNum(gift.objectId, gift.num * setNum);
    }
    stat.addDict(repls);
  }
}

@JsonSerializable()
class Stage {
  int wave;
  Bgm bgm;

  List<FieldAi> fieldAis;
  List<int> call;
  int? turn;
  StageLimitActType? limitAct;
  int? enemyFieldPosCount;
  int? enemyActCount;
  List<StageStartMovie> waveStartMovies;
  List<QuestEnemy> enemies;

  Stage({
    required this.wave,
    required this.bgm,
    this.fieldAis = const [],
    this.call = const [],
    this.turn,
    this.limitAct,
    this.enemyFieldPosCount,
    this.enemyActCount,
    this.waveStartMovies = const [],
    this.enemies = const [],
  });

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);

  bool hasExtraInfo() {
    return bgm.id != 0 ||
        fieldAis.isNotEmpty ||
        call.isNotEmpty ||
        turn != null ||
        // limitAct != null ||
        enemyFieldPosCount != null ||
        enemyActCount != null ||
        waveStartMovies.isNotEmpty;
  }
}

@JsonSerializable()
class StageStartMovie {
  String waveStartMovie;

  StageStartMovie({required this.waveStartMovie});

  factory StageStartMovie.fromJson(Map<String, dynamic> json) =>
      _$StageStartMovieFromJson(json);
}

@JsonSerializable()
class QuestRelease {
  @CondTypeConverter()
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
  @CondTypeConverter()
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
class NpcServant {
  int? npcId; // non-null
  String name;
  BasicServant svt;
  int lv;
  int atk;
  int hp;
  List<NiceTrait> traits;
  EnemySkill? skills;
  SupportServantTd? noblePhantasm;
  SupportServantLimit limit;

  NpcServant({
    this.npcId,
    required this.name,
    required this.svt,
    required this.lv,
    required this.atk,
    required this.hp,
    this.traits = const [],
    this.skills,
    this.noblePhantasm,
    required this.limit,
  });

  factory NpcServant.fromJson(Map<String, dynamic> json) =>
      _$NpcServantFromJson(json);
}

@JsonSerializable()
class SupportServant {
  int id;
  int priority;
  String name;
  BasicServant svt;
  int lv;
  int atk;
  int hp;
  List<NiceTrait> traits;
  EnemySkill skills;
  SupportServantTd noblePhantasm;
  List<SupportServantEquip> equips;
  SupportServantScript? script;
  List<SupportServantRelease> releaseConditions;
  SupportServantLimit limit;
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
    required this.skills,
    required this.noblePhantasm,
    this.equips = const [],
    this.script,
    this.releaseConditions = const [],
    required this.limit,
  });

  factory SupportServant.fromJson(Map<String, dynamic> json) =>
      _$SupportServantFromJson(json);

  String get shownName {
    if (name.isEmpty || name == "NONE") {
      return svt.name;
    }
    return name;
  }
}

@JsonSerializable()
class SupportServantRelease {
  @CondTypeConverter()
  CondType type;
  int targetId;
  int value;

  SupportServantRelease({
    this.type = CondType.none,
    required this.targetId,
    required this.value,
  });

  factory SupportServantRelease.fromJson(Map<String, dynamic> json) =>
      _$SupportServantReleaseFromJson(json);
}

@JsonSerializable()
class SupportServantTd {
  int noblePhantasmId;
  NiceTd? noblePhantasm;
  int noblePhantasmLv;

  SupportServantTd({
    required this.noblePhantasmId,
    this.noblePhantasm,
    required this.noblePhantasmLv,
  });

  factory SupportServantTd.fromJson(Map<String, dynamic> json) =>
      _$SupportServantTdFromJson(json);
}

@JsonSerializable()
class SupportServantEquip {
  CraftEssence equip;
  int lv;
  int limitCount;

  SupportServantEquip({
    required this.equip,
    required this.lv,
    required this.limitCount,
  });

  factory SupportServantEquip.fromJson(Map<String, dynamic> json) =>
      _$SupportServantEquipFromJson(json);
}

@JsonSerializable()
class SupportServantScript {
  int? dispLimitCount;
  int? eventDeckIndex;

  SupportServantScript({
    this.dispLimitCount,
    this.eventDeckIndex,
  });

  factory SupportServantScript.fromJson(Map<String, dynamic> json) =>
      _$SupportServantScriptFromJson(json);
}

@JsonSerializable()
class SupportServantLimit {
  int limitCount;

  SupportServantLimit({
    required this.limitCount,
  });

  factory SupportServantLimit.fromJson(Map<String, dynamic> json) =>
      _$SupportServantLimitFromJson(json);
}

@JsonSerializable()
class EnemyDrop extends BaseGift {
  int dropCount;
  int runs;

  // double dropExpected;
  // double dropVariance;

  EnemyDrop({
    required super.type,
    required super.objectId,
    // ignore: avoid_types_as_parameter_names
    required super.num,
    required this.dropCount,
    required this.runs,
    // required this.dropExpected,
    // required this.dropVariance,
  });

  factory EnemyDrop.fromJson(Map<String, dynamic> json) =>
      _$EnemyDropFromJson(json);
}

@JsonSerializable()
class EnemyLimit {
  int limitCount;
  int imageLimitCount;
  int dispLimitCount;
  int commandCardLimitCount;
  int iconLimitCount;
  int portraitLimitCount;
  int battleVoice;
  int exceedCount;

  EnemyLimit({
    this.limitCount = 0,
    this.imageLimitCount = 0,
    this.dispLimitCount = 0,
    this.commandCardLimitCount = 0,
    this.iconLimitCount = 0,
    this.portraitLimitCount = 0,
    this.battleVoice = 0,
    this.exceedCount = 0,
  });

  factory EnemyLimit.fromJson(Map<String, dynamic> json) =>
      _$EnemyLimitFromJson(json);
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
  // int? hpGaugeType;
  // int? imageSvtId;
  // int? condVal;

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
class QuestEnemy with GameCardMixin {
  DeckType deck;
  int deckId;
  int userSvtId;
  int uniqueId;
  int npcId;
  EnemyRoleType roleType;
  @override
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

  EnemySkill skills;
  EnemyPassive classPassive;

  EnemyTd noblePhantasm;
  EnemyServerMod serverMod;

  EnemyAi? ai;
  EnemyScript enemyScript;
  Map<String, dynamic>? originalEnemyScript;
  EnemyInfoScript? infoScript;
  Map<String, dynamic>? originalInfoScript;

  EnemyLimit? limit;
  EnemyMisc? misc;

  QuestEnemy({
    required this.deck,
    required this.deckId,
    required this.userSvtId,
    required this.uniqueId,
    required this.npcId,
    required this.roleType,
    required this.name,
    required this.svt,
    this.drops = const [],
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
    this.ai,
    EnemyScript? enemyScript,
    this.originalEnemyScript,
    this.infoScript,
    this.originalInfoScript,
    this.limit,
    this.misc,
  })  : skills = skills ?? EnemySkill(),
        classPassive = classPassive ?? EnemyPassive(),
        noblePhantasm = noblePhantasm ?? EnemyTd(),
        enemyScript = enemyScript ?? EnemyScript();

  factory QuestEnemy.fromJson(Map<String, dynamic> json) {
    final enemy = _$QuestEnemyFromJson(json);
    enemy.enemyScript.setSource(enemy.originalEnemyScript);
    enemy.infoScript?.setSource(enemy.originalInfoScript);
    return enemy;
  }

  String get lShownName {
    if (name.isEmpty || name == 'NONE') {
      return svt.lName.l;
    }
    String? _name =
        Transl.md.svtNames[name]?.l ?? Transl.md.entityNames[name]?.l;
    if (_name != null) return _name;
    return name.replaceFirstMapped(RegExp(r'^(.+?)(\s*)([A-Z\uff21-\uff3a])$'),
        (match) {
      String a = Transl.svtNames(match.group(1)!).l,
          b = match.group(2)!,
          c = match.group(3)!;
      if (Transl.isEN && b.isEmpty && c.isNotEmpty) b = ' ';
      return '$a$b$c';
    });
  }

  @override
  Transl<String, String> get lName => svt.lName;

  @override
  int get collectionNo => svt.collectionNo;

  @override
  String? get icon => svt.icon;

  @override
  String? get borderedIcon => icon;

  @override
  int get id => svt.id;

  @override
  int get rarity => svt.rarity;

  @override
  String get route => Routes.enemyI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Quest? quest}) {
    super.routeTo(
      child: QuestEnemyDetail(enemy: this, quest: quest),
      popDetails: popDetails,
    );
  }
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

// appear
// billBoardGroup
// boss
// call
// Cane
// change
// changeAttri
// deadChangePos
// death
// dispLimitCount
// forceDropItem
// hpBarType
// isHideShadow
// isSkillShiftInfo
// kill
// leader
// leave
// missionTargetSkillShift
// multiTargetCore
// multiTargetUnder
// multiTargetUp
// NoMotion
// NoSkipDead
// noVoice
// npc
// probability_type
// raid
// shift
// shiftClear
// shiftPosition
// skillShift
// speed1_dead
// startPos
// superBoss
// surt
// svt_change
// svtVoiceId
// transformAfterName
// treasureDeviceVoiceId
// treasureDeviceName
// treasureDeviceRuby
// voice
@JsonSerializable()
class EnemyScript with DataScriptBase {
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
      _$EnemyScriptFromJson(json)..setSource(json);

  bool get isRare => source.containsKey('probability_type') == true;

  int? get dispBreakShift => source['dispBreakShift'] as int?;
}

@JsonSerializable()
class EnemyInfoScript with DataScriptBase {
  bool? isAddition;

  EnemyInfoScript({
    this.isAddition,
  });

  factory EnemyInfoScript.fromJson(Map<String, dynamic> json) =>
      _$EnemyInfoScriptFromJson(json)..setSource(json);
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

  List<int> get skillIds =>
      [skillId1, skillId2, skillId3].where((e) => e != 0).toList();

  factory EnemySkill.fromJson(Map<String, dynamic> json) =>
      _$EnemySkillFromJson(json);
}

@JsonSerializable()
class EnemyTd {
  int noblePhantasmId;
  NiceTd? noblePhantasm;
  int noblePhantasmLv;
  int noblePhantasmLv1;
  int? noblePhantasmLv2;
  int? noblePhantasmLv3;

  EnemyTd({
    this.noblePhantasmId = 0,
    this.noblePhantasm,
    this.noblePhantasmLv = 0,
    this.noblePhantasmLv1 = 0,
    this.noblePhantasmLv2,
    this.noblePhantasmLv3,
  });

  factory EnemyTd.fromJson(Map<String, dynamic> json) =>
      _$EnemyTdFromJson(json);
}

@JsonSerializable()
class EnemyPassive {
  List<NiceSkill> classPassive;
  List<NiceSkill> addPassive;
  List<int>? addPassiveLvs;
  List<int>? appendPassiveSkillIds;
  List<int>? appendPassiveSkillLvs;

  EnemyPassive({
    this.classPassive = const [],
    this.addPassive = const [],
    this.appendPassiveSkillIds,
    this.appendPassiveSkillLvs,
  });

  factory EnemyPassive.fromJson(Map<String, dynamic> json) =>
      _$EnemyPassiveFromJson(json);
}

// class EnemyLimit{}

@JsonSerializable()
class EnemyAi {
  int aiId;
  int actPriority;
  int maxActNum;
  int? minActNum;

  EnemyAi({
    required this.aiId,
    required this.actPriority,
    required this.maxActNum,
    this.minActNum,
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
class QuestPhaseAiNpc {
  NpcServant npc;
  QuestEnemy? detail;
  List<int> aiIds;

  QuestPhaseAiNpc({
    required this.npc,
    this.detail,
    this.aiIds = const [],
  });

  factory QuestPhaseAiNpc.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseAiNpcFromJson(json);
}

@JsonSerializable()
class QuestPhaseExtraDetail {
  List<int>? questSelect;
  int? singleForceSvtId;
  String? hintTitle;
  String? hintMessage;
  QuestPhaseAiNpc? aiNpc;
  List<QuestPhaseAiNpc>? aiMultiNpc;

  QuestPhaseExtraDetail({
    this.questSelect,
    this.singleForceSvtId,
    this.hintTitle,
    this.hintMessage,
    this.aiNpc,
    this.aiMultiNpc,
  });

  factory QuestPhaseExtraDetail.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseExtraDetailFromJson(json);
}

@JsonSerializable()
class Restriction {
  int id;
  String name;
  RestrictionType type;
  RestrictionRangeType rangeType;
  List<int> targetVals;
  List<int> targetVals2;

  Restriction({
    required this.id,
    this.name = '',
    this.type = RestrictionType.none,
    this.rangeType = RestrictionRangeType.none,
    this.targetVals = const [],
    this.targetVals2 = const [],
  });

  factory Restriction.fromJson(Map<String, dynamic> json) =>
      _$RestrictionFromJson(json);
}

@JsonSerializable()
class QuestPhaseRestriction {
  Restriction restriction;
  FrequencyType frequencyType;
  String dialogMessage;
  String noticeMessage;
  String title;

  QuestPhaseRestriction({
    required this.restriction,
    this.frequencyType = FrequencyType.none,
    this.dialogMessage = '',
    this.noticeMessage = '',
    this.title = '',
  });

  factory QuestPhaseRestriction.fromJson(Map<String, dynamic> json) =>
      _$QuestPhaseRestrictionFromJson(json);
}

///

class QuestFlagConverter extends JsonConverter<QuestFlag, String> {
  const QuestFlagConverter();
  @override
  QuestFlag fromJson(String value) =>
      decodeEnum(_$QuestFlagEnumMap, value, QuestFlag.none);
  @override
  String toJson(QuestFlag obj) => _$QuestFlagEnumMap[obj] ?? obj.name;
}

enum QuestType {
  main(1),
  free(2),
  friendship(3),
  event(5),
  heroballad(6),
  warBoard(7),
  ;

  final int id;
  const QuestType(this.id);
  String get shownName {
    switch (this) {
      case QuestType.main:
        return S.current.main_quest;
      case QuestType.free:
        return S.current.free_quest;
      case QuestType.friendship:
        return S.current.interlude;
      case QuestType.event:
        return S.current.event;
      case QuestType.heroballad:
      case QuestType.warBoard:
        return S.current.war_board;
    }
  }
}

final kQuestTypeIds = {for (final t in QuestType.values) t.id: t};

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

@JsonEnum(alwaysCreate: true)
enum QuestFlag {
  none,
  noBattle,
  raid,
  raidConnection,
  noContinue,
  noDisplayRemain,
  raidLastDay,
  closedHideCostItem,
  closedHideCostNum,
  closedHideProgress,
  closedHideRecommendLv,
  closedHideTrendClass,
  closedHideReward,
  noDisplayConsume,
  superBoss,
  noDisplayMissionNotify,
  hideProgress,
  dropFirstTimeOnly,
  chapterSubIdJapaneseNumerals,
  supportOnlyForceBattle,
  eventDeckNoSupport,
  fatigueBattle,
  supportSelectAfterScript,
  branch,
  userEventDeck,
  noDisplayRaidRemain,
  questMaxDamageRecord,
  enableFollowQuest,
  supportSvtMultipleSet,
  supportOnlyBattle,
  actConsumeBattleWin,
  vote,
  hideMaster,
  disableMasterSkill,
  disableCommandSpeel,
  supportSvtEditablePosition,
  branchScenario,
  questKnockdownRecord,
  notRetrievable,
  displayLoopmark,
  boostItemConsumeBattleWin,
  playScenarioWithMapscreen,
  battleRetreatQuestClear,
  battleResultLoseQuestClear,
  branchHaving,
  noDisplayNextIcon,
  windowOnly,
  changeMasters,
  notDisplayResultGetPoint,
  forceToNoDrop,
  displayConsumeIcon,
  harvest,
  reconstruction,
  enemyImmediateAppear,
  noSupportList,
  live,
  forceDisplayEnemyInfo,
  alloutBattle,
  recollection,
  notSingleSupportOnly,
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
  energy,
}

enum DeckType {
  enemy,
  call,
  shift,
  change,
  transform,
  skillShift,
  missionTargetSkillShift,
  aiNpc,
}

enum RestrictionType {
  none, // custom
  individuality,
  rarity,
  totalCost,
  lv,
  supportOnly,
  uniqueSvtOnly,
  fixedSupportPosition,
  fixedMySvtIndividualityPositionMain,
  fixedMySvtIndividualitySingle,
  svtNum,
  mySvtNum,
  mySvtOrNpc,
  alloutBattleUniqueSvt,
  fixedSvtIndividualityPositionMain,
  uniqueIndividuality,
  mySvtOrSupport,
  dataLostBattleUniqueSvt,
}

enum RestrictionRangeType {
  none,
  equal,
  notEqual,
  above,
  below,
  between,
}

enum FrequencyType {
  once,
  onceUntilReboot,
  everyTime,
  valentine,
  everyTimeAfter,
  none,
}

enum StageLimitActType {
  win,
  lose,
}
