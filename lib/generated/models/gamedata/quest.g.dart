// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicQuest _$BasicQuestFromJson(Map json) => BasicQuest(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      flags: json['flags'] == null
          ? const []
          : toEnumListQuestFlag(json['flags'] as List),
      consumeType: $enumDecode(_$ConsumeTypeEnumMap, json['consumeType']),
      consume: json['consume'] as int,
      spotId: json['spotId'] as int,
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String,
      priority: json['priority'] as int,
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
    );

const _$QuestTypeEnumMap = {
  QuestType.main: 'main',
  QuestType.free: 'free',
  QuestType.friendship: 'friendship',
  QuestType.event: 'event',
  QuestType.heroballad: 'heroballad',
  QuestType.warBoard: 'warBoard',
};

const _$ConsumeTypeEnumMap = {
  ConsumeType.none: 'none',
  ConsumeType.ap: 'ap',
  ConsumeType.rp: 'rp',
  ConsumeType.item: 'item',
  ConsumeType.apAndItem: 'apAndItem',
};

Quest _$QuestFromJson(Map json) => Quest(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      flags: json['flags'] == null
          ? const []
          : toEnumListQuestFlag(json['flags'] as List),
      consumeType:
          $enumDecodeNullable(_$ConsumeTypeEnumMap, json['consumeType']) ??
              ConsumeType.ap,
      consume: json['consume'] as int,
      consumeItem: (json['consumeItem'] as List<dynamic>?)
              ?.map((e) =>
                  ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterClear: $enumDecode(_$QuestAfterClearTypeEnumMap, json['afterClear']),
      recommendLv: json['recommendLv'] as String,
      spotId: json['spotId'] as int,
      spotName: json['spotName'] as String,
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String? ?? '',
      chapterId: json['chapterId'] as int? ?? 0,
      chapterSubId: json['chapterSubId'] as int? ?? 0,
      chapterSubStr: json['chapterSubStr'] as String? ?? "",
      giftIcon: json['giftIcon'] as String?,
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) =>
                  QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      phases: (json['phases'] as List<dynamic>).map((e) => e as int).toList(),
      phasesWithEnemies: (json['phasesWithEnemies'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      phaseScripts: (json['phaseScripts'] as List<dynamic>?)
              ?.map((e) => QuestPhaseScript.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      priority: json['priority'] as int,
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
    );

const _$QuestAfterClearTypeEnumMap = {
  QuestAfterClearType.close: 'close',
  QuestAfterClearType.repeatFirst: 'repeatFirst',
  QuestAfterClearType.repeatLast: 'repeatLast',
  QuestAfterClearType.resetInterval: 'resetInterval',
  QuestAfterClearType.closeDisp: 'closeDisp',
};

QuestPhase _$QuestPhaseFromJson(Map json) => QuestPhase(
      id: json['id'] as int,
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      flags: json['flags'] == null
          ? const []
          : toEnumListQuestFlag(json['flags'] as List),
      consumeType:
          $enumDecodeNullable(_$ConsumeTypeEnumMap, json['consumeType']) ??
              ConsumeType.ap,
      consume: json['consume'] as int,
      consumeItem: (json['consumeItem'] as List<dynamic>?)
              ?.map((e) =>
                  ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterClear: $enumDecode(_$QuestAfterClearTypeEnumMap, json['afterClear']),
      recommendLv: json['recommendLv'] as String,
      spotId: json['spotId'] as int,
      spotName: json['spotName'] as String,
      warId: json['warId'] as int,
      warLongName: json['warLongName'] as String? ?? '',
      chapterId: json['chapterId'] as int? ?? 0,
      chapterSubId: json['chapterSubId'] as int? ?? 0,
      chapterSubStr: json['chapterSubStr'] as String? ?? "",
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) =>
                  QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      phases: (json['phases'] as List<dynamic>).map((e) => e as int).toList(),
      phasesWithEnemies: (json['phasesWithEnemies'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      phaseScripts: (json['phaseScripts'] as List<dynamic>?)
              ?.map((e) => QuestPhaseScript.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      priority: json['priority'] as int,
      noticeAt: json['noticeAt'] as int,
      openedAt: json['openedAt'] as int,
      closedAt: json['closedAt'] as int,
      phase: json['phase'] as int,
      className: (json['className'] as List<dynamic>?)
              ?.map((e) => const SvtClassConverter().fromJson(e as String))
              .toList() ??
          const [],
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      qp: json['qp'] as int,
      exp: json['exp'] as int,
      bond: json['bond'] as int,
      isNpcOnly: json['isNpcOnly'] as bool? ?? false,
      battleBgId: json['battleBgId'] as int,
      extraDetail: json['extraDetail'] == null
          ? null
          : QuestPhaseExtraDetail.fromJson(
              Map<String, dynamic>.from(json['extraDetail'] as Map)),
      scripts: (json['scripts'] as List<dynamic>?)
              ?.map((e) =>
                  ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  QuestMessage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      restrictions: (json['restrictions'] as List<dynamic>?)
              ?.map((e) => QuestPhaseRestriction.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      supportServants: (json['supportServants'] as List<dynamic>?)
              ?.map((e) =>
                  SupportServant.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => Stage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      drops: (json['drops'] as List<dynamic>?)
              ?.map((e) =>
                  EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    )..giftIcon = json['giftIcon'] as String?;

BaseGift _$BaseGiftFromJson(Map json) => BaseGift(
      type:
          $enumDecodeNullable(_$GiftTypeEnumMap, json['type']) ?? GiftType.item,
      objectId: json['objectId'] as int,
      num: json['num'] as int,
    );

const _$GiftTypeEnumMap = {
  GiftType.servant: 'servant',
  GiftType.item: 'item',
  GiftType.friendship: 'friendship',
  GiftType.userExp: 'userExp',
  GiftType.equip: 'equip',
  GiftType.eventSvtJoin: 'eventSvtJoin',
  GiftType.eventSvtGet: 'eventSvtGet',
  GiftType.questRewardIcon: 'questRewardIcon',
  GiftType.costumeRelease: 'costumeRelease',
  GiftType.costumeGet: 'costumeGet',
  GiftType.commandCode: 'commandCode',
  GiftType.eventPointBuff: 'eventPointBuff',
  GiftType.eventBoardGameToken: 'eventBoardGameToken',
};

GiftAdd _$GiftAddFromJson(Map json) => GiftAdd(
      priority: json['priority'] as int,
      replacementGiftIcon: json['replacementGiftIcon'] as String,
      condType: toEnumCondType(json['condType'] as Object),
      targetId: json['targetId'] as int,
      targetNum: json['targetNum'] as int,
      replacementGifts: (json['replacementGifts'] as List<dynamic>)
          .map((e) => BaseGift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Gift _$GiftFromJson(Map json) => Gift(
      type:
          $enumDecodeNullable(_$GiftTypeEnumMap, json['type']) ?? GiftType.item,
      objectId: json['objectId'] as int,
      num: json['num'] as int,
      giftAdds: (json['giftAdds'] as List<dynamic>?)
              ?.map(
                  (e) => GiftAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Stage _$StageFromJson(Map json) => Stage(
      wave: json['wave'] as int,
      bgm: Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      fieldAis: (json['fieldAis'] as List<dynamic>?)
              ?.map(
                  (e) => FieldAi.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      call: (json['call'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      enemyFieldPosCount: json['enemyFieldPosCount'] as int?,
      waveStartMovies: (json['waveStartMovies'] as List<dynamic>?)
              ?.map((e) =>
                  StageStartMovie.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      enemies: (json['enemies'] as List<dynamic>?)
              ?.map((e) =>
                  QuestEnemy.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

StageStartMovie _$StageStartMovieFromJson(Map json) => StageStartMovie(
      waveStartMovie: json['waveStartMovie'] as String,
    );

QuestRelease _$QuestReleaseFromJson(Map json) => QuestRelease(
      type: toEnumCondType(json['type'] as Object),
      targetId: json['targetId'] as int,
      value: json['value'] as int? ?? 0,
      closedMessage: json['closedMessage'] as String? ?? "",
    );

QuestPhaseScript _$QuestPhaseScriptFromJson(Map json) => QuestPhaseScript(
      phase: json['phase'] as int,
      scripts: (json['scripts'] as List<dynamic>)
          .map((e) => ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

QuestMessage _$QuestMessageFromJson(Map json) => QuestMessage(
      idx: json['idx'] as int,
      message: json['message'] as String,
      condType: toEnumCondType(json['condType'] as Object),
      targetId: json['targetId'] as int,
      targetNum: json['targetNum'] as int,
    );

NpcServant _$NpcServantFromJson(Map json) => NpcServant(
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: json['lv'] as int,
      atk: json['atk'] as int,
      hp: json['hp'] as int,
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skills: json['skills'] == null
          ? null
          : EnemySkill.fromJson(
              Map<String, dynamic>.from(json['skills'] as Map)),
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : SupportServantTd.fromJson(
              Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      limit: SupportServantLimit.fromJson(
          Map<String, dynamic>.from(json['limit'] as Map)),
    );

SupportServant _$SupportServantFromJson(Map json) => SupportServant(
      id: json['id'] as int,
      priority: json['priority'] as int,
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: json['lv'] as int,
      atk: json['atk'] as int,
      hp: json['hp'] as int,
      traits: (json['traits'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      skills:
          EnemySkill.fromJson(Map<String, dynamic>.from(json['skills'] as Map)),
      noblePhantasm: SupportServantTd.fromJson(
          Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      equips: (json['equips'] as List<dynamic>?)
              ?.map((e) => SupportServantEquip.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SupportServantScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => SupportServantRelease.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      limit: SupportServantLimit.fromJson(
          Map<String, dynamic>.from(json['limit'] as Map)),
    );

SupportServantRelease _$SupportServantReleaseFromJson(Map json) =>
    SupportServantRelease(
      type: json['type'] == null
          ? CondType.none
          : toEnumCondType(json['type'] as Object),
      targetId: json['targetId'] as int,
      value: json['value'] as int,
    );

SupportServantTd _$SupportServantTdFromJson(Map json) => SupportServantTd(
      noblePhantasmId: json['noblePhantasmId'] as int,
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : NiceTd.fromJson(
              Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      noblePhantasmLv: json['noblePhantasmLv'] as int,
    );

SupportServantEquip _$SupportServantEquipFromJson(Map json) =>
    SupportServantEquip(
      equip: CraftEssence.fromJson(
          Map<String, dynamic>.from(json['equip'] as Map)),
      lv: json['lv'] as int,
      limitCount: json['limitCount'] as int,
    );

SupportServantScript _$SupportServantScriptFromJson(Map json) =>
    SupportServantScript(
      dispLimitCount: json['dispLimitCount'] as int?,
      eventDeckIndex: json['eventDeckIndex'] as int?,
    );

SupportServantLimit _$SupportServantLimitFromJson(Map json) =>
    SupportServantLimit(
      limitCount: json['limitCount'] as int,
    );

EnemyDrop _$EnemyDropFromJson(Map json) => EnemyDrop(
      type:
          $enumDecodeNullable(_$GiftTypeEnumMap, json['type']) ?? GiftType.item,
      objectId: json['objectId'] as int,
      num: json['num'] as int,
      dropCount: json['dropCount'] as int,
      runs: json['runs'] as int,
    );

EnemyLimit _$EnemyLimitFromJson(Map json) => EnemyLimit(
      limitCount: json['limitCount'] as int? ?? 0,
      imageLimitCount: json['imageLimitCount'] as int? ?? 0,
      dispLimitCount: json['dispLimitCount'] as int? ?? 0,
      commandCardLimitCount: json['commandCardLimitCount'] as int? ?? 0,
      iconLimitCount: json['iconLimitCount'] as int? ?? 0,
      portraitLimitCount: json['portraitLimitCount'] as int? ?? 0,
      battleVoice: json['battleVoice'] as int? ?? 0,
      exceedCount: json['exceedCount'] as int? ?? 0,
    );

EnemyMisc _$EnemyMiscFromJson(Map json) => EnemyMisc(
      displayType: json['displayType'] as int? ?? 1,
      npcSvtType: json['npcSvtType'] as int? ?? 2,
      passiveSkill: (json['passiveSkill'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      equipTargetId1: json['equipTargetId1'] as int? ?? 0,
      equipTargetIds: (json['equipTargetIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      npcSvtClassId: json['npcSvtClassId'] as int? ?? 0,
      overwriteSvtId: json['overwriteSvtId'] as int? ?? 0,
      commandCardParam: (json['commandCardParam'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      status: json['status'] as int? ?? 0,
    );

QuestEnemy _$QuestEnemyFromJson(Map json) => QuestEnemy(
      deck: $enumDecode(_$DeckTypeEnumMap, json['deck']),
      deckId: json['deckId'] as int,
      userSvtId: json['userSvtId'] as int,
      uniqueId: json['uniqueId'] as int,
      npcId: json['npcId'] as int,
      roleType: $enumDecode(_$EnemyRoleTypeEnumMap, json['roleType']),
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: json['lv'] as int,
      exp: json['exp'] as int? ?? 0,
      atk: json['atk'] as int,
      hp: json['hp'] as int,
      adjustAtk: json['adjustAtk'] as int? ?? 0,
      adjustHp: json['adjustHp'] as int? ?? 0,
      deathRate: json['deathRate'] as int,
      criticalRate: json['criticalRate'] as int,
      recover: json['recover'] as int? ?? 0,
      chargeTurn: json['chargeTurn'] as int? ?? 0,
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skills: json['skills'] == null
          ? null
          : EnemySkill.fromJson(
              Map<String, dynamic>.from(json['skills'] as Map)),
      classPassive: json['classPassive'] == null
          ? null
          : EnemyPassive.fromJson(
              Map<String, dynamic>.from(json['classPassive'] as Map)),
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : EnemyTd.fromJson(
              Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      serverMod: EnemyServerMod.fromJson(
          Map<String, dynamic>.from(json['serverMod'] as Map)),
      ai: json['ai'] == null
          ? null
          : EnemyAi.fromJson(Map<String, dynamic>.from(json['ai'] as Map)),
      enemyScript: json['enemyScript'] == null
          ? null
          : EnemyScript.fromJson(
              Map<String, dynamic>.from(json['enemyScript'] as Map)),
      limit: json['limit'] == null
          ? null
          : EnemyLimit.fromJson(
              Map<String, dynamic>.from(json['limit'] as Map)),
      misc: json['misc'] == null
          ? null
          : EnemyMisc.fromJson(Map<String, dynamic>.from(json['misc'] as Map)),
    );

const _$DeckTypeEnumMap = {
  DeckType.enemy: 'enemy',
  DeckType.call: 'call',
  DeckType.shift: 'shift',
  DeckType.change: 'change',
  DeckType.transform: 'transform',
  DeckType.skillShift: 'skillShift',
  DeckType.missionTargetSkillShift: 'missionTargetSkillShift',
};

const _$EnemyRoleTypeEnumMap = {
  EnemyRoleType.normal: 'normal',
  EnemyRoleType.danger: 'danger',
  EnemyRoleType.servant: 'servant',
};

EnemyServerMod _$EnemyServerModFromJson(Map json) => EnemyServerMod(
      tdRate: json['tdRate'] as int,
      tdAttackRate: json['tdAttackRate'] as int,
      starRate: json['starRate'] as int,
    );

EnemyScript _$EnemyScriptFromJson(Map json) => EnemyScript(
      deathType:
          $enumDecodeNullable(_$EnemyDeathTypeEnumMap, json['deathType']),
      hpBarType: json['hpBarType'] as int?,
      leader: json['leader'] as bool?,
      call: (json['call'] as List<dynamic>?)?.map((e) => e as int).toList(),
      shift: (json['shift'] as List<dynamic>?)?.map((e) => e as int).toList(),
      shiftClear: (json['shiftClear'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$EnemyDeathTypeEnumMap = {
  EnemyDeathType.escape: 'escape',
  EnemyDeathType.stand: 'stand',
  EnemyDeathType.effect: 'effect',
  EnemyDeathType.wait: 'wait',
  EnemyDeathType.energy: 'energy',
};

EnemySkill _$EnemySkillFromJson(Map json) => EnemySkill(
      skillId1: json['skillId1'] as int? ?? 0,
      skillId2: json['skillId2'] as int? ?? 0,
      skillId3: json['skillId3'] as int? ?? 0,
      skill1: json['skill1'] == null
          ? null
          : NiceSkill.fromJson(
              Map<String, dynamic>.from(json['skill1'] as Map)),
      skill2: json['skill2'] == null
          ? null
          : NiceSkill.fromJson(
              Map<String, dynamic>.from(json['skill2'] as Map)),
      skill3: json['skill3'] == null
          ? null
          : NiceSkill.fromJson(
              Map<String, dynamic>.from(json['skill3'] as Map)),
      skillLv1: json['skillLv1'] as int? ?? 0,
      skillLv2: json['skillLv2'] as int? ?? 0,
      skillLv3: json['skillLv3'] as int? ?? 0,
    );

EnemyTd _$EnemyTdFromJson(Map json) => EnemyTd(
      noblePhantasmId: json['noblePhantasmId'] as int? ?? 0,
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : NiceTd.fromJson(
              Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      noblePhantasmLv: json['noblePhantasmLv'] as int? ?? 0,
      noblePhantasmLv1: json['noblePhantasmLv1'] as int? ?? 0,
    );

EnemyPassive _$EnemyPassiveFromJson(Map json) => EnemyPassive(
      classPassive: (json['classPassive'] as List<dynamic>?)
              ?.map((e) =>
                  NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      addPassive: (json['addPassive'] as List<dynamic>?)
              ?.map((e) =>
                  NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EnemyAi _$EnemyAiFromJson(Map json) => EnemyAi(
      aiId: json['aiId'] as int,
      actPriority: json['actPriority'] as int,
      maxActNum: json['maxActNum'] as int,
    );

FieldAi _$FieldAiFromJson(Map json) => FieldAi(
      raid: json['raid'] as int?,
      day: json['day'] as int?,
      id: json['id'] as int,
    );

QuestPhaseAiNpc _$QuestPhaseAiNpcFromJson(Map json) => QuestPhaseAiNpc(
      npc: NpcServant.fromJson(Map<String, dynamic>.from(json['npc'] as Map)),
      aiIds: (json['aiIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
    );

QuestPhaseExtraDetail _$QuestPhaseExtraDetailFromJson(Map json) =>
    QuestPhaseExtraDetail(
      questSelect: (json['questSelect'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      singleForceSvtId: json['singleForceSvtId'] as int?,
      hintTitle: json['hintTitle'] as String?,
      hintMessage: json['hintMessage'] as String?,
      aiNpc: json['aiNpc'] == null
          ? null
          : QuestPhaseAiNpc.fromJson(
              Map<String, dynamic>.from(json['aiNpc'] as Map)),
    );

Restriction _$RestrictionFromJson(Map json) => Restriction(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: $enumDecodeNullable(_$RestrictionTypeEnumMap, json['type']) ??
          RestrictionType.none,
      rangeType: $enumDecodeNullable(
              _$RestrictionRangeTypeEnumMap, json['rangeType']) ??
          RestrictionRangeType.none,
      targetVals: (json['targetVals'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      targetVals2: (json['targetVals2'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );

const _$RestrictionTypeEnumMap = {
  RestrictionType.none: 'none',
  RestrictionType.individuality: 'individuality',
  RestrictionType.rarity: 'rarity',
  RestrictionType.totalCost: 'totalCost',
  RestrictionType.lv: 'lv',
  RestrictionType.supportOnly: 'supportOnly',
  RestrictionType.uniqueSvtOnly: 'uniqueSvtOnly',
  RestrictionType.fixedSupportPosition: 'fixedSupportPosition',
  RestrictionType.fixedMySvtIndividualityPositionMain:
      'fixedMySvtIndividualityPositionMain',
  RestrictionType.fixedMySvtIndividualitySingle:
      'fixedMySvtIndividualitySingle',
  RestrictionType.svtNum: 'svtNum',
  RestrictionType.mySvtNum: 'mySvtNum',
  RestrictionType.mySvtOrNpc: 'mySvtOrNpc',
  RestrictionType.alloutBattleUniqueSvt: 'alloutBattleUniqueSvt',
  RestrictionType.fixedSvtIndividualityPositionMain:
      'fixedSvtIndividualityPositionMain',
  RestrictionType.uniqueIndividuality: 'uniqueIndividuality',
  RestrictionType.mySvtOrSupport: 'mySvtOrSupport',
};

const _$RestrictionRangeTypeEnumMap = {
  RestrictionRangeType.none: 'none',
  RestrictionRangeType.equal: 'equal',
  RestrictionRangeType.notEqual: 'notEqual',
  RestrictionRangeType.above: 'above',
  RestrictionRangeType.below: 'below',
  RestrictionRangeType.between: 'between',
};

QuestPhaseRestriction _$QuestPhaseRestrictionFromJson(Map json) =>
    QuestPhaseRestriction(
      restriction: Restriction.fromJson(
          Map<String, dynamic>.from(json['restriction'] as Map)),
      frequencyType:
          $enumDecodeNullable(_$FrequencyTypeEnumMap, json['frequencyType']) ??
              FrequencyType.none,
      dialogMessage: json['dialogMessage'] as String? ?? '',
      noticeMessage: json['noticeMessage'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );

const _$FrequencyTypeEnumMap = {
  FrequencyType.once: 'once',
  FrequencyType.onceUntilReboot: 'onceUntilReboot',
  FrequencyType.everyTime: 'everyTime',
  FrequencyType.valentine: 'valentine',
  FrequencyType.everyTimeAfter: 'everyTimeAfter',
  FrequencyType.none: 'none',
};

const _$QuestFlagEnumMap = {
  QuestFlag.none: 'none',
  QuestFlag.noBattle: 'noBattle',
  QuestFlag.raid: 'raid',
  QuestFlag.raidConnection: 'raidConnection',
  QuestFlag.noContinue: 'noContinue',
  QuestFlag.noDisplayRemain: 'noDisplayRemain',
  QuestFlag.raidLastDay: 'raidLastDay',
  QuestFlag.closedHideCostItem: 'closedHideCostItem',
  QuestFlag.closedHideCostNum: 'closedHideCostNum',
  QuestFlag.closedHideProgress: 'closedHideProgress',
  QuestFlag.closedHideRecommendLv: 'closedHideRecommendLv',
  QuestFlag.closedHideTrendClass: 'closedHideTrendClass',
  QuestFlag.closedHideReward: 'closedHideReward',
  QuestFlag.noDisplayConsume: 'noDisplayConsume',
  QuestFlag.superBoss: 'superBoss',
  QuestFlag.noDisplayMissionNotify: 'noDisplayMissionNotify',
  QuestFlag.hideProgress: 'hideProgress',
  QuestFlag.dropFirstTimeOnly: 'dropFirstTimeOnly',
  QuestFlag.chapterSubIdJapaneseNumerals: 'chapterSubIdJapaneseNumerals',
  QuestFlag.supportOnlyForceBattle: 'supportOnlyForceBattle',
  QuestFlag.eventDeckNoSupport: 'eventDeckNoSupport',
  QuestFlag.fatigueBattle: 'fatigueBattle',
  QuestFlag.supportSelectAfterScript: 'supportSelectAfterScript',
  QuestFlag.branch: 'branch',
  QuestFlag.userEventDeck: 'userEventDeck',
  QuestFlag.noDisplayRaidRemain: 'noDisplayRaidRemain',
  QuestFlag.questMaxDamageRecord: 'questMaxDamageRecord',
  QuestFlag.enableFollowQuest: 'enableFollowQuest',
  QuestFlag.supportSvtMultipleSet: 'supportSvtMultipleSet',
  QuestFlag.supportOnlyBattle: 'supportOnlyBattle',
  QuestFlag.actConsumeBattleWin: 'actConsumeBattleWin',
  QuestFlag.vote: 'vote',
  QuestFlag.hideMaster: 'hideMaster',
  QuestFlag.disableMasterSkill: 'disableMasterSkill',
  QuestFlag.disableCommandSpeel: 'disableCommandSpeel',
  QuestFlag.supportSvtEditablePosition: 'supportSvtEditablePosition',
  QuestFlag.branchScenario: 'branchScenario',
  QuestFlag.questKnockdownRecord: 'questKnockdownRecord',
  QuestFlag.notRetrievable: 'notRetrievable',
  QuestFlag.displayLoopmark: 'displayLoopmark',
  QuestFlag.boostItemConsumeBattleWin: 'boostItemConsumeBattleWin',
  QuestFlag.playScenarioWithMapscreen: 'playScenarioWithMapscreen',
  QuestFlag.battleRetreatQuestClear: 'battleRetreatQuestClear',
  QuestFlag.battleResultLoseQuestClear: 'battleResultLoseQuestClear',
  QuestFlag.branchHaving: 'branchHaving',
  QuestFlag.noDisplayNextIcon: 'noDisplayNextIcon',
  QuestFlag.windowOnly: 'windowOnly',
  QuestFlag.changeMasters: 'changeMasters',
  QuestFlag.notDisplayResultGetPoint: 'notDisplayResultGetPoint',
  QuestFlag.forceToNoDrop: 'forceToNoDrop',
  QuestFlag.displayConsumeIcon: 'displayConsumeIcon',
  QuestFlag.harvest: 'harvest',
  QuestFlag.reconstruction: 'reconstruction',
  QuestFlag.enemyImmediateAppear: 'enemyImmediateAppear',
  QuestFlag.noSupportList: 'noSupportList',
  QuestFlag.live: 'live',
  QuestFlag.forceDisplayEnemyInfo: 'forceDisplayEnemyInfo',
  QuestFlag.alloutBattle: 'alloutBattle',
  QuestFlag.recollection: 'recollection',
};
