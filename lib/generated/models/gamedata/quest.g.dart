// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicQuest _$BasicQuestFromJson(Map json) => BasicQuest(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      flags: (json['flags'] as List<dynamic>?)?.map((e) => const QuestFlagConverter().fromJson(e as String)).toList() ??
          const [],
      afterClear: $enumDecodeNullable(_$QuestAfterClearTypeEnumMap, json['afterClear']) ?? QuestAfterClearType.close,
      consumeType: $enumDecodeNullable(_$ConsumeTypeEnumMap, json['consumeType']) ?? ConsumeType.ap,
      consume: (json['consume'] as num?)?.toInt() ?? 0,
      spotId: (json['spotId'] as num?)?.toInt() ?? 0,
      warId: (json['warId'] as num?)?.toInt() ?? 0,
      warLongName: json['warLongName'] as String?,
      priority: (json['priority'] as num).toInt(),
      noticeAt: (json['noticeAt'] as num).toInt(),
      openedAt: (json['openedAt'] as num).toInt(),
      closedAt: (json['closedAt'] as num).toInt(),
    );

Map<String, dynamic> _$BasicQuestToJson(BasicQuest instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$QuestTypeEnumMap[instance.type]!,
      'flags': instance.flags.map(const QuestFlagConverter().toJson).toList(),
      'afterClear': _$QuestAfterClearTypeEnumMap[instance.afterClear]!,
      'consumeType': _$ConsumeTypeEnumMap[instance.consumeType]!,
      'consume': instance.consume,
      'spotId': instance.spotId,
      'warId': instance.warId,
      'warLongName': instance.warLongName,
      'priority': instance.priority,
      'noticeAt': instance.noticeAt,
      'openedAt': instance.openedAt,
      'closedAt': instance.closedAt,
    };

const _$QuestTypeEnumMap = {
  QuestType.main: 'main',
  QuestType.free: 'free',
  QuestType.friendship: 'friendship',
  QuestType.event: 'event',
  QuestType.heroballad: 'heroballad',
  QuestType.warBoard: 'warBoard',
};

const _$QuestAfterClearTypeEnumMap = {
  QuestAfterClearType.close: 'close',
  QuestAfterClearType.repeatFirst: 'repeatFirst',
  QuestAfterClearType.repeatLast: 'repeatLast',
  QuestAfterClearType.resetInterval: 'resetInterval',
  QuestAfterClearType.closeDisp: 'closeDisp',
};

const _$ConsumeTypeEnumMap = {
  ConsumeType.none: 'none',
  ConsumeType.ap: 'ap',
  ConsumeType.rp: 'rp',
  ConsumeType.item: 'item',
  ConsumeType.apAndItem: 'apAndItem',
};

Quest _$QuestFromJson(Map json) => Quest(
      id: (json['id'] as num?)?.toInt() ?? -1,
      name: json['name'] as String? ?? '',
      type: $enumDecodeNullable(_$QuestTypeEnumMap, json['type']) ?? QuestType.event,
      flags: (json['flags'] as List<dynamic>?)?.map((e) => const QuestFlagConverter().fromJson(e as String)).toList() ??
          const [],
      consumeType: $enumDecodeNullable(_$ConsumeTypeEnumMap, json['consumeType']) ?? ConsumeType.ap,
      consume: (json['consume'] as num?)?.toInt() ?? 0,
      consumeItem: (json['consumeItem'] as List<dynamic>?)
              ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterClear: $enumDecodeNullable(_$QuestAfterClearTypeEnumMap, json['afterClear']) ?? QuestAfterClearType.close,
      recommendLv: json['recommendLv'] as String? ?? '',
      spotId: (json['spotId'] as num?)?.toInt() ?? 0,
      spotName: json['spotName'] as String?,
      warId: (json['warId'] as num?)?.toInt() ?? 0,
      warLongName: json['warLongName'] as String?,
      chapterId: (json['chapterId'] as num?)?.toInt() ?? 0,
      chapterSubId: (json['chapterSubId'] as num?)?.toInt() ?? 0,
      chapterSubStr: json['chapterSubStr'] as String? ?? "",
      giftIcon: json['giftIcon'] as String?,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      presents: (json['presents'] as List<dynamic>?)
              ?.map((e) => QuestPhasePresent.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseOverwrites: (json['releaseOverwrites'] as List<dynamic>?)
              ?.map((e) => QuestReleaseOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      phases: (json['phases'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phasesWithEnemies:
          (json['phasesWithEnemies'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phaseScripts: (json['phaseScripts'] as List<dynamic>?)
              ?.map((e) => QuestPhaseScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      noticeAt: (json['noticeAt'] as num?)?.toInt() ?? 0,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$QuestTypeEnumMap[instance.type]!,
      'flags': instance.flags.map(const QuestFlagConverter().toJson).toList(),
      'consumeType': _$ConsumeTypeEnumMap[instance.consumeType]!,
      'consume': instance.consume,
      'consumeItem': instance.consumeItem.map((e) => e.toJson()).toList(),
      'afterClear': _$QuestAfterClearTypeEnumMap[instance.afterClear]!,
      'recommendLv': instance.recommendLv,
      'spotId': instance.spotId,
      'warId': instance.warId,
      'chapterId': instance.chapterId,
      'chapterSubId': instance.chapterSubId,
      'chapterSubStr': instance.chapterSubStr,
      'giftIcon': instance.giftIcon,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'presents': instance.presents.map((e) => e.toJson()).toList(),
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'releaseOverwrites': instance.releaseOverwrites.map((e) => e.toJson()).toList(),
      'phases': instance.phases,
      'phasesWithEnemies': instance.phasesWithEnemies,
      'phasesNoBattle': instance.phasesNoBattle,
      'phaseScripts': instance.phaseScripts.map((e) => e.toJson()).toList(),
      'priority': instance.priority,
      'noticeAt': instance.noticeAt,
      'openedAt': instance.openedAt,
      'closedAt': instance.closedAt,
      'spotName': instance.spotName,
      'warLongName': instance.warLongName,
    };

QuestPhase _$QuestPhaseFromJson(Map json) => QuestPhase(
      id: (json['id'] as num?)?.toInt() ?? -1,
      name: json['name'] as String? ?? '',
      type: $enumDecodeNullable(_$QuestTypeEnumMap, json['type']) ?? QuestType.event,
      flags: (json['flags'] as List<dynamic>?)?.map((e) => const QuestFlagConverter().fromJson(e as String)).toList() ??
          const [],
      consumeType: $enumDecodeNullable(_$ConsumeTypeEnumMap, json['consumeType']) ?? ConsumeType.ap,
      consume: (json['consume'] as num?)?.toInt() ?? 0,
      consumeItem: (json['consumeItem'] as List<dynamic>?)
              ?.map((e) => ItemAmount.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterClear: $enumDecodeNullable(_$QuestAfterClearTypeEnumMap, json['afterClear']) ?? QuestAfterClearType.close,
      recommendLv: json['recommendLv'] as String? ?? '',
      spotId: (json['spotId'] as num?)?.toInt() ?? 0,
      spotName: json['spotName'] as String?,
      warId: (json['warId'] as num?)?.toInt() ?? 0,
      warLongName: json['warLongName'] as String?,
      chapterId: (json['chapterId'] as num?)?.toInt() ?? 0,
      chapterSubId: (json['chapterSubId'] as num?)?.toInt() ?? 0,
      chapterSubStr: json['chapterSubStr'] as String? ?? "",
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      presents: (json['presents'] as List<dynamic>?)
              ?.map((e) => QuestPhasePresent.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      giftIcon: json['giftIcon'] as String?,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => QuestRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseOverwrites: (json['releaseOverwrites'] as List<dynamic>?)
              ?.map((e) => QuestReleaseOverwrite.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      phases: (json['phases'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phasesWithEnemies:
          (json['phasesWithEnemies'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phasesNoBattle: (json['phasesNoBattle'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      phaseScripts: (json['phaseScripts'] as List<dynamic>?)
              ?.map((e) => QuestPhaseScript.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      noticeAt: (json['noticeAt'] as num?)?.toInt() ?? 0,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
      phase: (json['phase'] as num?)?.toInt() ?? 1,
      className:
          (json['className'] as List<dynamic>?)?.map((e) => const SvtClassConverter().fromJson(e as String)).toList() ??
              const [],
      individuality: (json['individuality'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      qp: (json['qp'] as num?)?.toInt() ?? 0,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      bond: (json['bond'] as num?)?.toInt() ?? 0,
      isNpcOnly: json['isNpcOnly'] as bool? ?? false,
      enemyHash: json['enemyHash'] as String?,
      enemyHashes: (json['availableEnemyHashes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      dropsFromAllHashes: json['dropsFromAllHashes'] as bool?,
      battleBg: json['battleBg'] == null ? null : BattleBg.fromJson(Map<String, dynamic>.from(json['battleBg'] as Map)),
      extraDetail: json['extraDetail'] == null
          ? null
          : QuestPhaseExtraDetail.fromJson(Map<String, dynamic>.from(json['extraDetail'] as Map)),
      scripts: (json['scripts'] as List<dynamic>?)
              ?.map((e) => ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => QuestMessage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => QuestHint.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      restrictions: (json['restrictions'] as List<dynamic>?)
              ?.map((e) => QuestPhaseRestriction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      supportServants: (json['supportServants'] as List<dynamic>?)
              ?.map((e) => SupportServant.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      stages:
          (json['stages'] as List<dynamic>?)?.map((e) => Stage.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      drops: (json['drops'] as List<dynamic>?)
              ?.map((e) => EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QuestPhaseToJson(QuestPhase instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$QuestTypeEnumMap[instance.type]!,
      'flags': instance.flags.map(const QuestFlagConverter().toJson).toList(),
      'consumeType': _$ConsumeTypeEnumMap[instance.consumeType]!,
      'consume': instance.consume,
      'consumeItem': instance.consumeItem.map((e) => e.toJson()).toList(),
      'afterClear': _$QuestAfterClearTypeEnumMap[instance.afterClear]!,
      'recommendLv': instance.recommendLv,
      'spotId': instance.spotId,
      'warId': instance.warId,
      'chapterId': instance.chapterId,
      'chapterSubId': instance.chapterSubId,
      'chapterSubStr': instance.chapterSubStr,
      'giftIcon': instance.giftIcon,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'presents': instance.presents.map((e) => e.toJson()).toList(),
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'releaseOverwrites': instance.releaseOverwrites.map((e) => e.toJson()).toList(),
      'phases': instance.phases,
      'phasesWithEnemies': instance.phasesWithEnemies,
      'phasesNoBattle': instance.phasesNoBattle,
      'phaseScripts': instance.phaseScripts.map((e) => e.toJson()).toList(),
      'priority': instance.priority,
      'noticeAt': instance.noticeAt,
      'openedAt': instance.openedAt,
      'closedAt': instance.closedAt,
      'spotName': instance.spotName,
      'warLongName': instance.warLongName,
      'phase': instance.phase,
      'className': instance.className.map(const SvtClassConverter().toJson).toList(),
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'qp': instance.qp,
      'exp': instance.exp,
      'bond': instance.bond,
      'isNpcOnly': instance.isNpcOnly,
      'enemyHash': instance.enemyHash,
      'availableEnemyHashes': instance.enemyHashes,
      'dropsFromAllHashes': instance.dropsFromAllHashes,
      'battleBg': instance.battleBg?.toJson(),
      'extraDetail': instance.extraDetail?.toJson(),
      'scripts': instance.scripts.map((e) => e.toJson()).toList(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'hints': instance.hints.map((e) => e.toJson()).toList(),
      'restrictions': instance.restrictions.map((e) => e.toJson()).toList(),
      'supportServants': instance.supportServants.map((e) => e.toJson()).toList(),
      'stages': instance.stages.map((e) => e.toJson()).toList(),
      'drops': instance.drops.map((e) => e.toJson()).toList(),
    };

BaseGift _$BaseGiftFromJson(Map json) => BaseGift(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$GiftTypeEnumMap, json['type'], unknownValue: GiftType.unknown),
      objectId: (json['objectId'] as num).toInt(),
      num: (json['num'] as num).toInt(),
    );

Map<String, dynamic> _$BaseGiftToJson(BaseGift instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$GiftTypeEnumMap[instance.type]!,
      'objectId': instance.objectId,
      'num': instance.num,
    };

const _$GiftTypeEnumMap = {
  GiftType.unknown: 'unknown',
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
  GiftType.eventCommandAssist: 'eventCommandAssist',
  GiftType.eventHeelPortrait: 'eventHeelPortrait',
  GiftType.battleItem: 'battleItem',
};

GiftAdd _$GiftAddFromJson(Map json) => GiftAdd(
      priority: (json['priority'] as num).toInt(),
      replacementGiftIcon: json['replacementGiftIcon'] as String,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: (json['targetId'] as num).toInt(),
      targetNum: (json['targetNum'] as num).toInt(),
      replacementGifts: (json['replacementGifts'] as List<dynamic>)
          .map((e) => BaseGift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$GiftAddToJson(GiftAdd instance) => <String, dynamic>{
      'priority': instance.priority,
      'replacementGiftIcon': instance.replacementGiftIcon,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'targetId': instance.targetId,
      'targetNum': instance.targetNum,
      'replacementGifts': instance.replacementGifts.map((e) => e.toJson()).toList(),
    };

Gift _$GiftFromJson(Map json) => Gift(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$GiftTypeEnumMap, json['type'], unknownValue: GiftType.unknown),
      objectId: (json['objectId'] as num).toInt(),
      num: (json['num'] as num).toInt(),
      giftAdds: (json['giftAdds'] as List<dynamic>?)
              ?.map((e) => GiftAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GiftToJson(Gift instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$GiftTypeEnumMap[instance.type]!,
      'objectId': instance.objectId,
      'num': instance.num,
      'giftAdds': instance.giftAdds.map((e) => e.toJson()).toList(),
    };

Stage _$StageFromJson(Map json) => Stage(
      wave: (json['wave'] as num).toInt(),
      bgm: json['bgm'] == null ? null : Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      startEffectId: (json['startEffectId'] as num?)?.toInt() ?? 1,
      fieldAis: (json['fieldAis'] as List<dynamic>?)
          ?.map((e) => FieldAi.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      call: (json['call'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      turn: (json['turn'] as num?)?.toInt(),
      limitAct: $enumDecodeNullable(_$StageLimitActTypeEnumMap, json['limitAct']),
      enemyFieldPosCount: (json['enemyFieldPosCount'] as num?)?.toInt(),
      enemyActCount: (json['enemyActCount'] as num?)?.toInt(),
      battleBg: json['battleBg'] == null ? null : BattleBg.fromJson(Map<String, dynamic>.from(json['battleBg'] as Map)),
      NoEntryIds: (json['NoEntryIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      waveStartMovies: (json['waveStartMovies'] as List<dynamic>?)
              ?.map((e) => StageStartMovie.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      originalScript: (json['originalScript'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      cutin: json['cutin'] == null ? null : StageCutin.fromJson(Map<String, dynamic>.from(json['cutin'] as Map)),
      aiAllocations: (json['aiAllocations'] as List<dynamic>?)
          ?.map((e) => AiAllocationInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      enemies: (json['enemies'] as List<dynamic>?)
          ?.map((e) => QuestEnemy.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$StageToJson(Stage instance) => <String, dynamic>{
      'originalScript': instance.originalScript,
      'wave': instance.wave,
      'bgm': instance.bgm?.toJson(),
      'startEffectId': instance.startEffectId,
      'fieldAis': instance.fieldAis.map((e) => e.toJson()).toList(),
      'call': instance.call,
      'turn': instance.turn,
      'limitAct': _$StageLimitActTypeEnumMap[instance.limitAct],
      'enemyFieldPosCount': instance.enemyFieldPosCount,
      'enemyActCount': instance.enemyActCount,
      'battleBg': instance.battleBg?.toJson(),
      'NoEntryIds': instance.NoEntryIds,
      'waveStartMovies': instance.waveStartMovies.map((e) => e.toJson()).toList(),
      'cutin': instance.cutin?.toJson(),
      'aiAllocations': instance.aiAllocations?.map((e) => e.toJson()).toList(),
      'enemies': instance.enemies.map((e) => e.toJson()).toList(),
    };

const _$StageLimitActTypeEnumMap = {
  StageLimitActType.win: 'win',
  StageLimitActType.lose: 'lose',
};

AiAllocationInfo _$AiAllocationInfoFromJson(Map json) => AiAllocationInfo(
      aiIds: (json['aiIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      applySvtType: (json['applySvtType'] as List<dynamic>?)
              ?.map((e) =>
                  $enumDecode(_$AiAllocationApplySvtFlagEnumMap, e, unknownValue: AiAllocationApplySvtFlag.unknown))
              .toList() ??
          const [],
      individuality: json['individuality'] == null
          ? null
          : NiceTrait.fromJson(Map<String, dynamic>.from(json['individuality'] as Map)),
    );

Map<String, dynamic> _$AiAllocationInfoToJson(AiAllocationInfo instance) => <String, dynamic>{
      'aiIds': instance.aiIds,
      'applySvtType': instance.applySvtType.map((e) => _$AiAllocationApplySvtFlagEnumMap[e]!).toList(),
      'individuality': instance.individuality?.toJson(),
    };

const _$AiAllocationApplySvtFlagEnumMap = {
  AiAllocationApplySvtFlag.all: 'all',
  AiAllocationApplySvtFlag.own: 'own',
  AiAllocationApplySvtFlag.friend: 'friend',
  AiAllocationApplySvtFlag.npc: 'npc',
  AiAllocationApplySvtFlag.unknown: 'unknown',
};

StageCutin _$StageCutinFromJson(Map json) => StageCutin(
      runs: (json['runs'] as num).toInt(),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => StageCutInSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      drops: (json['drops'] as List<dynamic>?)
              ?.map((e) => EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StageCutinToJson(StageCutin instance) => <String, dynamic>{
      'runs': instance.runs,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
      'drops': instance.drops.map((e) => e.toJson()).toList(),
    };

StageCutInSkill _$StageCutInSkillFromJson(Map json) => StageCutInSkill(
      skill: NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
      appearCount: (json['appearCount'] as num).toInt(),
    );

Map<String, dynamic> _$StageCutInSkillToJson(StageCutInSkill instance) => <String, dynamic>{
      'skill': instance.skill.toJson(),
      'appearCount': instance.appearCount,
    };

StageStartMovie _$StageStartMovieFromJson(Map json) => StageStartMovie(
      waveStartMovie: json['waveStartMovie'] as String,
    );

Map<String, dynamic> _$StageStartMovieToJson(StageStartMovie instance) => <String, dynamic>{
      'waveStartMovie': instance.waveStartMovie,
    };

QuestRelease _$QuestReleaseFromJson(Map json) => QuestRelease(
      type: const CondTypeConverter().fromJson(json['type'] as String),
      targetId: (json['targetId'] as num).toInt(),
      value: (json['value'] as num?)?.toInt() ?? 0,
      closedMessage: json['closedMessage'] as String? ?? "",
    );

Map<String, dynamic> _$QuestReleaseToJson(QuestRelease instance) => <String, dynamic>{
      'type': const CondTypeConverter().toJson(instance.type),
      'targetId': instance.targetId,
      'value': instance.value,
      'closedMessage': instance.closedMessage,
    };

QuestReleaseOverwrite _$QuestReleaseOverwriteFromJson(Map json) => QuestReleaseOverwrite(
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condId: (json['condId'] as num?)?.toInt() ?? 0,
      condNum: (json['condNum'] as num?)?.toInt() ?? 0,
      closedMessage: json['closedMessage'] as String? ?? "",
      overlayClosedMessage: json['overlayClosedMessage'] as String? ?? "",
      eventId: (json['eventId'] as num?)?.toInt() ?? 0,
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuestReleaseOverwriteToJson(QuestReleaseOverwrite instance) => <String, dynamic>{
      'priority': instance.priority,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condId': instance.condId,
      'condNum': instance.condNum,
      'closedMessage': instance.closedMessage,
      'overlayClosedMessage': instance.overlayClosedMessage,
      'eventId': instance.eventId,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

QuestPhaseScript _$QuestPhaseScriptFromJson(Map json) => QuestPhaseScript(
      phase: (json['phase'] as num).toInt(),
      scripts: (json['scripts'] as List<dynamic>)
          .map((e) => ScriptLink.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$QuestPhaseScriptToJson(QuestPhaseScript instance) => <String, dynamic>{
      'phase': instance.phase,
      'scripts': instance.scripts.map((e) => e.toJson()).toList(),
    };

QuestMessage _$QuestMessageFromJson(Map json) => QuestMessage(
      idx: (json['idx'] as num).toInt(),
      message: json['message'] as String,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: (json['targetId'] as num).toInt(),
      targetNum: (json['targetNum'] as num).toInt(),
    );

Map<String, dynamic> _$QuestMessageToJson(QuestMessage instance) => <String, dynamic>{
      'idx': instance.idx,
      'message': instance.message,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'targetId': instance.targetId,
      'targetNum': instance.targetNum,
    };

QuestHint _$QuestHintFromJson(Map json) => QuestHint(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      leftIndent: (json['leftIndent'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuestHintToJson(QuestHint instance) => <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
      'leftIndent': instance.leftIndent,
    };

QuestPhasePresent _$QuestPhasePresentFromJson(Map json) => QuestPhasePresent(
      phase: (json['phase'] as num?)?.toInt() ?? 0,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      giftIcon: json['giftIcon'] as String?,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condId: (json['condId'] as num?)?.toInt() ?? 0,
      condNum: (json['condNum'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$QuestPhasePresentToJson(QuestPhasePresent instance) => <String, dynamic>{
      'phase': instance.phase,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'giftIcon': instance.giftIcon,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condId': instance.condId,
      'condNum': instance.condNum,
    };

NpcServant _$NpcServantFromJson(Map json) => NpcServant(
      npcId: (json['npcId'] as num?)?.toInt(),
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: (json['lv'] as num).toInt(),
      atk: (json['atk'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skills: json['skills'] == null ? null : EnemySkill.fromJson(Map<String, dynamic>.from(json['skills'] as Map)),
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : SupportServantTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      limit: SupportServantLimit.fromJson(Map<String, dynamic>.from(json['limit'] as Map)),
      flags: (json['flags'] as List<dynamic>?)
              ?.map(
                  (e) => $enumDecode(_$NpcServantFollowerFlagEnumMap, e, unknownValue: NpcServantFollowerFlag.unknown))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NpcServantToJson(NpcServant instance) => <String, dynamic>{
      'npcId': instance.npcId,
      'name': instance.name,
      'svt': instance.svt.toJson(),
      'lv': instance.lv,
      'atk': instance.atk,
      'hp': instance.hp,
      'traits': instance.traits.map((e) => e.toJson()).toList(),
      'skills': instance.skills?.toJson(),
      'noblePhantasm': instance.noblePhantasm?.toJson(),
      'limit': instance.limit.toJson(),
      'flags': instance.flags.map((e) => _$NpcServantFollowerFlagEnumMap[e]!).toList(),
    };

const _$NpcServantFollowerFlagEnumMap = {
  NpcServantFollowerFlag.unknown: 'unknown',
  NpcServantFollowerFlag.npc: 'npc',
  NpcServantFollowerFlag.hideSupport: 'hideSupport',
  NpcServantFollowerFlag.notUsedTreasureDevice: 'notUsedTreasureDevice',
  NpcServantFollowerFlag.noDisplayBonusIcon: 'noDisplayBonusIcon',
  NpcServantFollowerFlag.applySvtChange: 'applySvtChange',
  NpcServantFollowerFlag.hideEquip: 'hideEquip',
  NpcServantFollowerFlag.noDisplayBonusIconEquip: 'noDisplayBonusIconEquip',
  NpcServantFollowerFlag.hideTreasureDeviceLv: 'hideTreasureDeviceLv',
  NpcServantFollowerFlag.hideTreasureDeviceDetail: 'hideTreasureDeviceDetail',
  NpcServantFollowerFlag.hideRarity: 'hideRarity',
  NpcServantFollowerFlag.notClassBoard: 'notClassBoard',
};

SupportServant _$SupportServantFromJson(Map json) => SupportServant(
      id: (json['id'] as num).toInt(),
      npcSvtFollowerId: (json['npcSvtFollowerId'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num).toInt(),
      name: json['name'] as String,
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      lv: (json['lv'] as num).toInt(),
      atk: (json['atk'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skills: EnemySkill.fromJson(Map<String, dynamic>.from(json['skills'] as Map)),
      passiveSkills: (json['passiveSkills'] as List<dynamic>?)
              ?.map((e) => SupportServantPassiveSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      noblePhantasm: SupportServantTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      followerFlags: (json['followerFlags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$NpcFollowerEntityFlagEnumMap, e, unknownValue: NpcFollowerEntityFlag.none))
              .toList() ??
          const [],
      equips: (json['equips'] as List<dynamic>?)
              ?.map((e) => SupportServantEquip.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SupportServantScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => SupportServantRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      limit: SupportServantLimit.fromJson(Map<String, dynamic>.from(json['limit'] as Map)),
      detail: json['detail'] == null ? null : QuestEnemy.fromJson(Map<String, dynamic>.from(json['detail'] as Map)),
    );

Map<String, dynamic> _$SupportServantToJson(SupportServant instance) => <String, dynamic>{
      'id': instance.id,
      'npcSvtFollowerId': instance.npcSvtFollowerId,
      'priority': instance.priority,
      'name': instance.name,
      'svt': instance.svt.toJson(),
      'lv': instance.lv,
      'atk': instance.atk,
      'hp': instance.hp,
      'traits': instance.traits.map((e) => e.toJson()).toList(),
      'skills': instance.skills.toJson(),
      'passiveSkills': instance.passiveSkills.map((e) => e.toJson()).toList(),
      'noblePhantasm': instance.noblePhantasm.toJson(),
      'followerFlags': instance.followerFlags.map((e) => _$NpcFollowerEntityFlagEnumMap[e]!).toList(),
      'equips': instance.equips.map((e) => e.toJson()).toList(),
      'script': instance.script?.toJson(),
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'limit': instance.limit.toJson(),
      'detail': instance.detail?.toJson(),
    };

const _$NpcFollowerEntityFlagEnumMap = {
  NpcFollowerEntityFlag.none: 'none',
  NpcFollowerEntityFlag.recommendedIcon: 'recommendedIcon',
  NpcFollowerEntityFlag.isMySvtOrNpc: 'isMySvtOrNpc',
  NpcFollowerEntityFlag.fixedNpc: 'fixedNpc',
};

SupportServantRelease _$SupportServantReleaseFromJson(Map json) => SupportServantRelease(
      type: json['type'] == null ? CondType.none : const CondTypeConverter().fromJson(json['type'] as String),
      targetId: (json['targetId'] as num).toInt(),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$SupportServantReleaseToJson(SupportServantRelease instance) => <String, dynamic>{
      'type': const CondTypeConverter().toJson(instance.type),
      'targetId': instance.targetId,
      'value': instance.value,
    };

SupportServantPassiveSkill _$SupportServantPassiveSkillFromJson(Map json) => SupportServantPassiveSkill(
      skillId: (json['skillId'] as num?)?.toInt() ?? 0,
      skill: json['skill'] == null ? null : NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
      skillLv: (json['skillLv'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SupportServantPassiveSkillToJson(SupportServantPassiveSkill instance) => <String, dynamic>{
      'skillId': instance.skillId,
      'skill': instance.skill?.toJson(),
      'skillLv': instance.skillLv,
    };

SupportServantTd _$SupportServantTdFromJson(Map json) => SupportServantTd(
      noblePhantasmId: (json['noblePhantasmId'] as num).toInt(),
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : NiceTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      noblePhantasmLv: (json['noblePhantasmLv'] as num).toInt(),
    );

Map<String, dynamic> _$SupportServantTdToJson(SupportServantTd instance) => <String, dynamic>{
      'noblePhantasmId': instance.noblePhantasmId,
      'noblePhantasm': instance.noblePhantasm?.toJson(),
      'noblePhantasmLv': instance.noblePhantasmLv,
    };

SupportServantEquip _$SupportServantEquipFromJson(Map json) => SupportServantEquip(
      equip: CraftEssence.fromJson(Map<String, dynamic>.from(json['equip'] as Map)),
      lv: (json['lv'] as num).toInt(),
      limitCount: (json['limitCount'] as num).toInt(),
    );

Map<String, dynamic> _$SupportServantEquipToJson(SupportServantEquip instance) => <String, dynamic>{
      'equip': instance.equip.toJson(),
      'lv': instance.lv,
      'limitCount': instance.limitCount,
    };

SupportServantScript _$SupportServantScriptFromJson(Map json) => SupportServantScript(
      dispLimitCount: (json['dispLimitCount'] as num?)?.toInt(),
      eventDeckIndex: (json['eventDeckIndex'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SupportServantScriptToJson(SupportServantScript instance) => <String, dynamic>{
      'dispLimitCount': instance.dispLimitCount,
      'eventDeckIndex': instance.eventDeckIndex,
    };

SupportServantLimit _$SupportServantLimitFromJson(Map json) => SupportServantLimit(
      limitCount: (json['limitCount'] as num).toInt(),
    );

Map<String, dynamic> _$SupportServantLimitToJson(SupportServantLimit instance) => <String, dynamic>{
      'limitCount': instance.limitCount,
    };

EnemyDrop _$EnemyDropFromJson(Map json) => EnemyDrop(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: $enumDecodeNullable(_$GiftTypeEnumMap, json['type'], unknownValue: GiftType.unknown) ?? GiftType.item,
      objectId: (json['objectId'] as num).toInt(),
      num: (json['num'] as num?)?.toInt() ?? 1,
      dropCount: (json['dropCount'] as num).toInt(),
      runs: (json['runs'] as num).toInt(),
    );

Map<String, dynamic> _$EnemyDropToJson(EnemyDrop instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$GiftTypeEnumMap[instance.type]!,
      'objectId': instance.objectId,
      'num': instance.num,
      'dropCount': instance.dropCount,
      'runs': instance.runs,
    };

EnemyLimit _$EnemyLimitFromJson(Map json) => EnemyLimit(
      limitCount: (json['limitCount'] as num?)?.toInt() ?? 0,
      imageLimitCount: (json['imageLimitCount'] as num?)?.toInt() ?? 0,
      dispLimitCount: (json['dispLimitCount'] as num?)?.toInt() ?? 0,
      commandCardLimitCount: (json['commandCardLimitCount'] as num?)?.toInt() ?? 0,
      iconLimitCount: (json['iconLimitCount'] as num?)?.toInt() ?? 0,
      portraitLimitCount: (json['portraitLimitCount'] as num?)?.toInt() ?? 0,
      battleVoice: (json['battleVoice'] as num?)?.toInt() ?? 0,
      exceedCount: (json['exceedCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EnemyLimitToJson(EnemyLimit instance) => <String, dynamic>{
      'limitCount': instance.limitCount,
      'imageLimitCount': instance.imageLimitCount,
      'dispLimitCount': instance.dispLimitCount,
      'commandCardLimitCount': instance.commandCardLimitCount,
      'iconLimitCount': instance.iconLimitCount,
      'portraitLimitCount': instance.portraitLimitCount,
      'battleVoice': instance.battleVoice,
      'exceedCount': instance.exceedCount,
    };

EnemyMisc _$EnemyMiscFromJson(Map json) => EnemyMisc(
      displayType: (json['displayType'] as num?)?.toInt() ?? 1,
      npcSvtType: (json['npcSvtType'] as num?)?.toInt() ?? 2,
      passiveSkill: (json['passiveSkill'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      equipTargetId1: (json['equipTargetId1'] as num?)?.toInt() ?? 0,
      equipTargetIds: (json['equipTargetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      npcSvtClassId: (json['npcSvtClassId'] as num?)?.toInt() ?? 0,
      overwriteSvtId: (json['overwriteSvtId'] as num?)?.toInt() ?? 0,
      commandCardParam: (json['commandCardParam'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      status: (json['status'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EnemyMiscToJson(EnemyMisc instance) => <String, dynamic>{
      'displayType': instance.displayType,
      'npcSvtType': instance.npcSvtType,
      'passiveSkill': instance.passiveSkill,
      'equipTargetId1': instance.equipTargetId1,
      'equipTargetIds': instance.equipTargetIds,
      'npcSvtClassId': instance.npcSvtClassId,
      'overwriteSvtId': instance.overwriteSvtId,
      'commandCardParam': instance.commandCardParam,
      'status': instance.status,
    };

QuestEnemy _$QuestEnemyFromJson(Map json) => QuestEnemy(
      deck: $enumDecodeNullable(_$DeckTypeEnumMap, json['deck']) ?? DeckType.enemy,
      deckId: (json['deckId'] as num).toInt(),
      npcId: (json['npcId'] as num?)?.toInt() ?? -1,
      roleType: $enumDecodeNullable(_$EnemyRoleTypeEnumMap, json['roleType']) ?? EnemyRoleType.normal,
      name: json['name'] as String? ?? "",
      svt: BasicServant.fromJson(Map<String, dynamic>.from(json['svt'] as Map)),
      drops: (json['drops'] as List<dynamic>?)
              ?.map((e) => EnemyDrop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      lv: (json['lv'] as num).toInt(),
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      atk: (json['atk'] as num).toInt(),
      hp: (json['hp'] as num).toInt(),
      adjustAtk: (json['adjustAtk'] as num?)?.toInt() ?? 0,
      adjustHp: (json['adjustHp'] as num?)?.toInt() ?? 0,
      deathRate: (json['deathRate'] as num).toInt(),
      criticalRate: (json['criticalRate'] as num).toInt(),
      recover: (json['recover'] as num?)?.toInt() ?? 0,
      chargeTurn: (json['chargeTurn'] as num?)?.toInt() ?? 0,
      traits: (json['traits'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      skills: json['skills'] == null ? null : EnemySkill.fromJson(Map<String, dynamic>.from(json['skills'] as Map)),
      classPassive: json['classPassive'] == null
          ? null
          : EnemyPassive.fromJson(Map<String, dynamic>.from(json['classPassive'] as Map)),
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : EnemyTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      serverMod: json['serverMod'] == null
          ? null
          : EnemyServerMod.fromJson(Map<String, dynamic>.from(json['serverMod'] as Map)),
      ai: json['ai'] == null ? null : EnemyAi.fromJson(Map<String, dynamic>.from(json['ai'] as Map)),
      enemyScript: json['enemyScript'] == null
          ? null
          : EnemyScript.fromJson(Map<String, dynamic>.from(json['enemyScript'] as Map)),
      originalEnemyScript: (json['originalEnemyScript'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      infoScript: json['infoScript'] == null
          ? null
          : EnemyInfoScript.fromJson(Map<String, dynamic>.from(json['infoScript'] as Map)),
      originalInfoScript: (json['originalInfoScript'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      limit: json['limit'] == null ? null : EnemyLimit.fromJson(Map<String, dynamic>.from(json['limit'] as Map)),
      misc: json['misc'] == null ? null : EnemyMisc.fromJson(Map<String, dynamic>.from(json['misc'] as Map)),
    );

Map<String, dynamic> _$QuestEnemyToJson(QuestEnemy instance) => <String, dynamic>{
      'deck': _$DeckTypeEnumMap[instance.deck]!,
      'deckId': instance.deckId,
      'npcId': instance.npcId,
      'roleType': _$EnemyRoleTypeEnumMap[instance.roleType]!,
      'name': instance.name,
      'svt': instance.svt.toJson(),
      'drops': instance.drops.map((e) => e.toJson()).toList(),
      'lv': instance.lv,
      'exp': instance.exp,
      'atk': instance.atk,
      'hp': instance.hp,
      'adjustAtk': instance.adjustAtk,
      'adjustHp': instance.adjustHp,
      'deathRate': instance.deathRate,
      'criticalRate': instance.criticalRate,
      'recover': instance.recover,
      'chargeTurn': instance.chargeTurn,
      'traits': instance.traits.map((e) => e.toJson()).toList(),
      'skills': instance.skills.toJson(),
      'classPassive': instance.classPassive.toJson(),
      'noblePhantasm': instance.noblePhantasm.toJson(),
      'serverMod': instance.serverMod.toJson(),
      'ai': instance.ai?.toJson(),
      'enemyScript': instance.enemyScript.toJson(),
      'originalEnemyScript': instance.originalEnemyScript,
      'infoScript': instance.infoScript.toJson(),
      'originalInfoScript': instance.originalInfoScript,
      'limit': instance.limit.toJson(),
      'misc': instance.misc?.toJson(),
    };

const _$DeckTypeEnumMap = {
  DeckType.enemy: 'enemy',
  DeckType.call: 'call',
  DeckType.shift: 'shift',
  DeckType.change: 'change',
  DeckType.transform: 'transform',
  DeckType.skillShift: 'skillShift',
  DeckType.missionTargetSkillShift: 'missionTargetSkillShift',
  DeckType.aiNpc: 'aiNpc',
  DeckType.svtFollower: 'svtFollower',
};

const _$EnemyRoleTypeEnumMap = {
  EnemyRoleType.normal: 'normal',
  EnemyRoleType.danger: 'danger',
  EnemyRoleType.servant: 'servant',
};

EnemyServerMod _$EnemyServerModFromJson(Map json) => EnemyServerMod(
      tdRate: (json['tdRate'] as num?)?.toInt() ?? 1000,
      tdAttackRate: (json['tdAttackRate'] as num?)?.toInt() ?? 1000,
      starRate: (json['starRate'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EnemyServerModToJson(EnemyServerMod instance) => <String, dynamic>{
      'tdRate': instance.tdRate,
      'tdAttackRate': instance.tdAttackRate,
      'starRate': instance.starRate,
    };

EnemyScript _$EnemyScriptFromJson(Map json) => EnemyScript(
      deathType: $enumDecodeNullable(_$SvtDeathTypeEnumMap, json['deathType']),
      hpBarType: (json['hpBarType'] as num?)?.toInt(),
      leader: json['leader'] as bool?,
      call: (json['call'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      shift: (json['shift'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      shiftClear: (json['shiftClear'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$EnemyScriptToJson(EnemyScript instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('deathType', _$SvtDeathTypeEnumMap[instance.deathType]);
  writeNotNull('hpBarType', instance.hpBarType);
  writeNotNull('leader', instance.leader);
  writeNotNull('call', instance.call);
  writeNotNull('shift', instance.shift);
  writeNotNull('shiftClear', instance.shiftClear?.map((e) => e.toJson()).toList());
  return val;
}

const _$SvtDeathTypeEnumMap = {
  SvtDeathType.normal: 'normal',
  SvtDeathType.escape: 'escape',
  SvtDeathType.stand: 'stand',
  SvtDeathType.effect: 'effect',
  SvtDeathType.wait: 'wait',
  SvtDeathType.energy: 'energy',
  SvtDeathType.crystal: 'crystal',
};

EnemyInfoScript _$EnemyInfoScriptFromJson(Map json) => EnemyInfoScript();

Map<String, dynamic> _$EnemyInfoScriptToJson(EnemyInfoScript instance) => <String, dynamic>{};

EnemySkill _$EnemySkillFromJson(Map json) => EnemySkill(
      skillId1: (json['skillId1'] as num?)?.toInt() ?? 0,
      skillId2: (json['skillId2'] as num?)?.toInt() ?? 0,
      skillId3: (json['skillId3'] as num?)?.toInt() ?? 0,
      skill1: json['skill1'] == null ? null : NiceSkill.fromJson(Map<String, dynamic>.from(json['skill1'] as Map)),
      skill2: json['skill2'] == null ? null : NiceSkill.fromJson(Map<String, dynamic>.from(json['skill2'] as Map)),
      skill3: json['skill3'] == null ? null : NiceSkill.fromJson(Map<String, dynamic>.from(json['skill3'] as Map)),
      skillLv1: (json['skillLv1'] as num?)?.toInt() ?? 0,
      skillLv2: (json['skillLv2'] as num?)?.toInt() ?? 0,
      skillLv3: (json['skillLv3'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EnemySkillToJson(EnemySkill instance) => <String, dynamic>{
      'skillId1': instance.skillId1,
      'skillId2': instance.skillId2,
      'skillId3': instance.skillId3,
      'skill1': instance.skill1?.toJson(),
      'skill2': instance.skill2?.toJson(),
      'skill3': instance.skill3?.toJson(),
      'skillLv1': instance.skillLv1,
      'skillLv2': instance.skillLv2,
      'skillLv3': instance.skillLv3,
    };

EnemyTd _$EnemyTdFromJson(Map json) => EnemyTd(
      noblePhantasmId: (json['noblePhantasmId'] as num?)?.toInt() ?? 0,
      noblePhantasm: json['noblePhantasm'] == null
          ? null
          : NiceTd.fromJson(Map<String, dynamic>.from(json['noblePhantasm'] as Map)),
      noblePhantasmLv: (json['noblePhantasmLv'] as num?)?.toInt() ?? 1,
      noblePhantasmLv1: (json['noblePhantasmLv1'] as num?)?.toInt() ?? 0,
      noblePhantasmLv2: (json['noblePhantasmLv2'] as num?)?.toInt(),
      noblePhantasmLv3: (json['noblePhantasmLv3'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EnemyTdToJson(EnemyTd instance) => <String, dynamic>{
      'noblePhantasmId': instance.noblePhantasmId,
      'noblePhantasm': instance.noblePhantasm?.toJson(),
      'noblePhantasmLv': instance.noblePhantasmLv,
      'noblePhantasmLv1': instance.noblePhantasmLv1,
      'noblePhantasmLv2': instance.noblePhantasmLv2,
      'noblePhantasmLv3': instance.noblePhantasmLv3,
    };

EnemyPassive _$EnemyPassiveFromJson(Map json) => EnemyPassive(
      classPassive: (json['classPassive'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      addPassive: (json['addPassive'] as List<dynamic>?)
          ?.map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      addPassiveLvs: (json['addPassiveLvs'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      appendPassiveSkillIds: (json['appendPassiveSkillIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      appendPassiveSkillLvs: (json['appendPassiveSkillLvs'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$EnemyPassiveToJson(EnemyPassive instance) => <String, dynamic>{
      'classPassive': instance.classPassive.map((e) => e.toJson()).toList(),
      'addPassive': instance.addPassive.map((e) => e.toJson()).toList(),
      'addPassiveLvs': instance.addPassiveLvs,
      'appendPassiveSkillIds': instance.appendPassiveSkillIds,
      'appendPassiveSkillLvs': instance.appendPassiveSkillLvs,
    };

EnemyAi _$EnemyAiFromJson(Map json) => EnemyAi(
      aiId: (json['aiId'] as num).toInt(),
      actPriority: (json['actPriority'] as num).toInt(),
      maxActNum: (json['maxActNum'] as num).toInt(),
      minActNum: (json['minActNum'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EnemyAiToJson(EnemyAi instance) => <String, dynamic>{
      'aiId': instance.aiId,
      'actPriority': instance.actPriority,
      'maxActNum': instance.maxActNum,
      'minActNum': instance.minActNum,
    };

FieldAi _$FieldAiFromJson(Map json) => FieldAi(
      raid: (json['raid'] as num?)?.toInt(),
      day: (json['day'] as num?)?.toInt(),
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$FieldAiToJson(FieldAi instance) => <String, dynamic>{
      'raid': instance.raid,
      'day': instance.day,
      'id': instance.id,
    };

QuestPhaseAiNpc _$QuestPhaseAiNpcFromJson(Map json) => QuestPhaseAiNpc(
      npc: NpcServant.fromJson(Map<String, dynamic>.from(json['npc'] as Map)),
      detail: json['detail'] == null ? null : QuestEnemy.fromJson(Map<String, dynamic>.from(json['detail'] as Map)),
      aiIds: (json['aiIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    );

Map<String, dynamic> _$QuestPhaseAiNpcToJson(QuestPhaseAiNpc instance) => <String, dynamic>{
      'npc': instance.npc.toJson(),
      'detail': instance.detail?.toJson(),
      'aiIds': instance.aiIds,
    };

QuestPhaseExtraDetail _$QuestPhaseExtraDetailFromJson(Map json) => QuestPhaseExtraDetail(
      questSelect: (json['questSelect'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      singleForceSvtId: (json['singleForceSvtId'] as num?)?.toInt(),
      hintTitle: json['hintTitle'] as String?,
      hintMessage: json['hintMessage'] as String?,
      aiNpc: json['aiNpc'] == null ? null : QuestPhaseAiNpc.fromJson(Map<String, dynamic>.from(json['aiNpc'] as Map)),
      aiMultiNpc: (json['aiMultiNpc'] as List<dynamic>?)
          ?.map((e) => QuestPhaseAiNpc.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      overwriteEquipSkills: json['overwriteEquipSkills'] == null
          ? null
          : OverwriteEquipSkills.fromJson(Map<String, dynamic>.from(json['overwriteEquipSkills'] as Map)),
      addEquipSkills: json['addEquipSkills'] == null
          ? null
          : OverwriteEquipSkills.fromJson(Map<String, dynamic>.from(json['addEquipSkills'] as Map)),
      waveSetup: (json['waveSetup'] as num?)?.toInt(),
      masterImageId: (json['masterImageId'] as num?)?.toInt(),
      IgnoreBattlePointUp: (json['IgnoreBattlePointUp'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      useEventDeckNo: (json['useEventDeckNo'] as num?)?.toInt(),
      masterSkillDelay: (json['masterSkillDelay'] as num?)?.toInt(),
      masterSkillDelayInfo: json['masterSkillDelayInfo'] as String?,
    )..interruptibleQuest = (json['interruptibleQuest'] as num?)?.toInt();

Map<String, dynamic> _$QuestPhaseExtraDetailToJson(QuestPhaseExtraDetail instance) => <String, dynamic>{
      'questSelect': instance.questSelect,
      'singleForceSvtId': instance.singleForceSvtId,
      'hintTitle': instance.hintTitle,
      'hintMessage': instance.hintMessage,
      'aiNpc': instance.aiNpc?.toJson(),
      'aiMultiNpc': instance.aiMultiNpc?.map((e) => e.toJson()).toList(),
      'overwriteEquipSkills': instance.overwriteEquipSkills?.toJson(),
      'addEquipSkills': instance.addEquipSkills?.toJson(),
      'waveSetup': instance.waveSetup,
      'interruptibleQuest': instance.interruptibleQuest,
      'masterImageId': instance.masterImageId,
      'IgnoreBattlePointUp': instance.IgnoreBattlePointUp,
      'useEventDeckNo': instance.useEventDeckNo,
      'masterSkillDelay': instance.masterSkillDelay,
      'masterSkillDelayInfo': instance.masterSkillDelayInfo,
    };

OverwriteEquipSkills _$OverwriteEquipSkillsFromJson(Map json) => OverwriteEquipSkills(
      iconId: (json['iconId'] as num?)?.toInt(),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => OverwriteEquipSkill.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OverwriteEquipSkillsToJson(OverwriteEquipSkills instance) => <String, dynamic>{
      'iconId': instance.iconId,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
    };

OverwriteEquipSkill _$OverwriteEquipSkillFromJson(Map json) => OverwriteEquipSkill(
      id: (json['id'] as num).toInt(),
      lv: (json['lv'] as num?)?.toInt() ?? 0,
      condId: (json['condId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OverwriteEquipSkillToJson(OverwriteEquipSkill instance) => <String, dynamic>{
      'id': instance.id,
      'lv': instance.lv,
      'condId': instance.condId,
    };

Restriction _$RestrictionFromJson(Map json) => Restriction(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      type: $enumDecodeNullable(_$RestrictionTypeEnumMap, json['type']) ?? RestrictionType.none,
      rangeType: $enumDecodeNullable(_$RestrictionRangeTypeEnumMap, json['rangeType']) ?? RestrictionRangeType.none,
      targetVals: (json['targetVals'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      targetVals2: (json['targetVals2'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    );

Map<String, dynamic> _$RestrictionToJson(Restriction instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$RestrictionTypeEnumMap[instance.type]!,
      'rangeType': _$RestrictionRangeTypeEnumMap[instance.rangeType]!,
      'targetVals': instance.targetVals,
      'targetVals2': instance.targetVals2,
    };

const _$RestrictionTypeEnumMap = {
  RestrictionType.none: 'none',
  RestrictionType.individuality: 'individuality',
  RestrictionType.rarity: 'rarity',
  RestrictionType.totalCost: 'totalCost',
  RestrictionType.lv: 'lv',
  RestrictionType.supportOnly: 'supportOnly',
  RestrictionType.uniqueSvtOnly: 'uniqueSvtOnly',
  RestrictionType.fixedSupportPosition: 'fixedSupportPosition',
  RestrictionType.fixedMySvtIndividualityPositionMain: 'fixedMySvtIndividualityPositionMain',
  RestrictionType.fixedMySvtIndividualitySingle: 'fixedMySvtIndividualitySingle',
  RestrictionType.svtNum: 'svtNum',
  RestrictionType.mySvtNum: 'mySvtNum',
  RestrictionType.mySvtOrNpc: 'mySvtOrNpc',
  RestrictionType.alloutBattleUniqueSvt: 'alloutBattleUniqueSvt',
  RestrictionType.fixedSvtIndividualityPositionMain: 'fixedSvtIndividualityPositionMain',
  RestrictionType.uniqueIndividuality: 'uniqueIndividuality',
  RestrictionType.mySvtOrSupport: 'mySvtOrSupport',
  RestrictionType.dataLostBattleUniqueSvt: 'dataLostBattleUniqueSvt',
};

const _$RestrictionRangeTypeEnumMap = {
  RestrictionRangeType.none: 'none',
  RestrictionRangeType.equal: 'equal',
  RestrictionRangeType.notEqual: 'notEqual',
  RestrictionRangeType.above: 'above',
  RestrictionRangeType.below: 'below',
  RestrictionRangeType.between: 'between',
};

QuestPhaseRestriction _$QuestPhaseRestrictionFromJson(Map json) => QuestPhaseRestriction(
      restriction: Restriction.fromJson(Map<String, dynamic>.from(json['restriction'] as Map)),
      frequencyType: $enumDecodeNullable(_$FrequencyTypeEnumMap, json['frequencyType']) ?? FrequencyType.none,
      dialogMessage: json['dialogMessage'] as String? ?? '',
      noticeMessage: json['noticeMessage'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );

Map<String, dynamic> _$QuestPhaseRestrictionToJson(QuestPhaseRestriction instance) => <String, dynamic>{
      'restriction': instance.restriction.toJson(),
      'frequencyType': _$FrequencyTypeEnumMap[instance.frequencyType]!,
      'dialogMessage': instance.dialogMessage,
      'noticeMessage': instance.noticeMessage,
      'title': instance.title,
    };

const _$FrequencyTypeEnumMap = {
  FrequencyType.none: 'none',
  FrequencyType.once: 'once',
  FrequencyType.onceUntilReboot: 'onceUntilReboot',
  FrequencyType.everyTime: 'everyTime',
  FrequencyType.valentine: 'valentine',
  FrequencyType.everyTimeAfter: 'everyTimeAfter',
  FrequencyType.everyTimeBefore: 'everyTimeBefore',
  FrequencyType.onceUntilRemind: 'onceUntilRemind',
};

QuestGroup _$QuestGroupFromJson(Map json) => QuestGroup(
      questId: (json['questId'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      groupId: (json['groupId'] as num).toInt(),
    );

Map<String, dynamic> _$QuestGroupToJson(QuestGroup instance) => <String, dynamic>{
      'questId': instance.questId,
      'type': instance.type,
      'groupId': instance.groupId,
    };

BattleBg _$BattleBgFromJson(Map json) => BattleBg(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$BattleFieldEnvironmentGrantTypeEnumMap, json['type']) ??
          BattleFieldEnvironmentGrantType.none,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      imageId: (json['imageId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BattleBgToJson(BattleBg instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$BattleFieldEnvironmentGrantTypeEnumMap[instance.type]!,
      'priority': instance.priority,
      'individuality': instance.individuality.map((e) => e.toJson()).toList(),
      'imageId': instance.imageId,
    };

const _$BattleFieldEnvironmentGrantTypeEnumMap = {
  BattleFieldEnvironmentGrantType.none: 'none',
  BattleFieldEnvironmentGrantType.stage: 'stage',
  BattleFieldEnvironmentGrantType.function_: 'function',
};

BasicQuestPhaseDetail _$BasicQuestPhaseDetailFromJson(Map json) => BasicQuestPhaseDetail(
      questId: (json['questId'] as num).toInt(),
      phase: (json['phase'] as num).toInt(),
      classIds: (json['classIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      qp: (json['qp'] as num?)?.toInt() ?? 0,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      bond: (json['bond'] as num?)?.toInt() ?? 0,
      giftId: (json['giftId'] as num?)?.toInt() ?? 0,
      gifts: (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      spotId: (json['spotId'] as num?)?.toInt(),
      consumeType: (json['consumeType'] as num?)?.toInt(),
      actConsume: (json['actConsume'] as num?)?.toInt(),
      recommendLv: json['recommendLv'] as String?,
    );

Map<String, dynamic> _$BasicQuestPhaseDetailToJson(BasicQuestPhaseDetail instance) => <String, dynamic>{
      'questId': instance.questId,
      'phase': instance.phase,
      'classIds': instance.classIds,
      'qp': instance.qp,
      'exp': instance.exp,
      'bond': instance.bond,
      'giftId': instance.giftId,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'spotId': instance.spotId,
      'consumeType': instance.consumeType,
      'actConsume': instance.actConsume,
      'recommendLv': instance.recommendLv,
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
  QuestFlag.chapterSubIdJapaneseNumeralsCalligraphy: 'chapterSubIdJapaneseNumeralsCalligraphy',
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
  QuestFlag.notSingleSupportOnly: 'notSingleSupportOnly',
  QuestFlag.disableChapterSub: 'disableChapterSub',
};
