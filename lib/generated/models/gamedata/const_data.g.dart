// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/const_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstGameData _$ConstGameDataFromJson(Map json) => ConstGameData(
      attributeRelation: (json['attributeRelation'] as Map?)?.map(
            (k, e) => MapEntry(
                $enumDecode(_$AttributeEnumMap, k),
                (e as Map).map(
                  (k, e) => MapEntry($enumDecode(_$AttributeEnumMap, k), e as int),
                )),
          ) ??
          const {},
      buffActions: (json['buffActions'] as Map?)?.map(
            (k, e) => MapEntry(const BuffActionConverter().fromJson(k as String),
                BuffActionDetail.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      cardInfo: (json['cardInfo'] as Map?)?.map(
            (k, e) => MapEntry(
                $enumDecode(_$CardTypeEnumMap, k),
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), CardInfo.fromJson(Map<String, dynamic>.from(e as Map))),
                )),
          ) ??
          const {},
      classInfo: (json['classInfo'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), SvtClassInfo.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      classRelation: (json['classRelation'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), e as int),
                )),
          ) ??
          const {},
      constants: json['constants'] == null
          ? const GameConstants()
          : GameConstants.fromJson(Map<String, dynamic>.from(json['constants'] as Map)),
      svtGrailCost: (json['svtGrailCost'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) =>
                      MapEntry(int.parse(k as String), GrailCostDetail.fromJson(Map<String, dynamic>.from(e as Map))),
                )),
          ) ??
          const {},
      userLevel: (json['userLevel'] as Map?)?.map(
            (k, e) =>
                MapEntry(int.parse(k as String), MasterUserLvDetail.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      svtExp: (json['svtExp'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), SvtExpCurve.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

const _$AttributeEnumMap = {
  Attribute.human: 'human',
  Attribute.sky: 'sky',
  Attribute.earth: 'earth',
  Attribute.star: 'star',
  Attribute.beast: 'beast',
  Attribute.void_: 'void',
};

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
};

BuffActionDetail _$BuffActionDetailFromJson(Map json) => BuffActionDetail(
      limit: $enumDecode(_$BuffLimitEnumMap, json['limit']),
      plusTypes:
          (json['plusTypes'] as List<dynamic>).map((e) => const BuffTypeConverter().fromJson(e as String)).toList(),
      minusTypes:
          (json['minusTypes'] as List<dynamic>).map((e) => const BuffTypeConverter().fromJson(e as String)).toList(),
      baseParam: json['baseParam'] as int,
      baseValue: json['baseValue'] as int,
      isRec: json['isRec'] as bool,
      plusAction: json['plusAction'] as int,
      maxRate: (json['maxRate'] as List<dynamic>).map((e) => e as int).toList(),
    );

const _$BuffLimitEnumMap = {
  BuffLimit.none: 'none',
  BuffLimit.upper: 'upper',
  BuffLimit.lower: 'lower',
  BuffLimit.normal: 'normal',
};

SvtClassInfo _$SvtClassInfoFromJson(Map json) => SvtClassInfo(
      id: json['id'] as int,
      attri: json['attri'] as int,
      name: json['name'] as String? ?? '',
      individuality: json['individuality'] as int? ?? 0,
      attackRate: json['attackRate'] as int,
      imageId: json['imageId'] as int,
      iconImageId: json['iconImageId'] as int,
      frameId: json['frameId'] as int,
      priority: json['priority'] as int,
      groupType: json['groupType'] as int,
      relationId: json['relationId'] as int,
      supportGroup: json['supportGroup'] as int,
      autoSelSupportType: json['autoSelSupportType'] as int,
    );

CardInfo _$CardInfoFromJson(Map json) => CardInfo(
      individuality: (json['individuality'] as List<dynamic>)
          .map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      adjustAtk: json['adjustAtk'] as int,
      adjustTdGauge: json['adjustTdGauge'] as int,
      adjustCritical: json['adjustCritical'] as int,
      addAtk: json['addAtk'] as int,
      addTdGauge: json['addTdGauge'] as int,
      addCritical: json['addCritical'] as int,
    );

GrailCostDetail _$GrailCostDetailFromJson(Map json) => GrailCostDetail(
      qp: json['qp'] as int,
      addLvMax: json['addLvMax'] as int,
      frameType: $enumDecodeNullable(_$SvtFrameTypeEnumMap, json['frameType']) ?? SvtFrameType.gold,
    );

const _$SvtFrameTypeEnumMap = {
  SvtFrameType.black: 'black',
  SvtFrameType.bronze: 'bronze',
  SvtFrameType.silver: 'silver',
  SvtFrameType.gold: 'gold',
  SvtFrameType.frame0801: 'frame0801',
  SvtFrameType.frame0802: 'frame0802',
  SvtFrameType.frame0803: 'frame0803',
  SvtFrameType.frame0804: 'frame0804',
};

MasterUserLvDetail _$MasterUserLvDetailFromJson(Map json) => MasterUserLvDetail(
      requiredExp: json['requiredExp'] as int,
      maxAp: json['maxAp'] as int,
      maxCost: json['maxCost'] as int,
      maxFriend: json['maxFriend'] as int,
      gift: json['gift'] == null ? null : Gift.fromJson(Map<String, dynamic>.from(json['gift'] as Map)),
    );

SvtExpCurve _$SvtExpCurveFromJson(Map json) => SvtExpCurve(
      type: json['type'] as int,
      lv: (json['lv'] as List<dynamic>).map((e) => e as int).toList(),
      exp: (json['exp'] as List<dynamic>).map((e) => e as int).toList(),
      curve: (json['curve'] as List<dynamic>).map((e) => e as int).toList(),
    );

GameConstants _$GameConstantsFromJson(Map json) => GameConstants(
      attackRate: json['attackRate'] as int? ?? 230,
      attackRateRandomMax: json['attackRateRandomMax'] as int? ?? 1100,
      attackRateRandomMin: json['attackRateRandomMin'] as int? ?? 900,
      backsideClassImageId: json['backsideClassImageId'] as int? ?? 102,
      backsideSvtEquipImageId: json['backsideSvtEquipImageId'] as int? ?? 103,
      backsideSvtImageId: json['backsideSvtImageId'] as int? ?? 101,
      battleEffectIdAvoidance: json['battleEffectIdAvoidance'] as int? ?? 6216,
      battleEffectIdAvoidancePierce: json['battleEffectIdAvoidancePierce'] as int? ?? 6217,
      battleEffectIdInvincible: json['battleEffectIdInvincible'] as int? ?? 6214,
      battleEffectIdInvinciblePierce: json['battleEffectIdInvinciblePierce'] as int? ?? 6215,
      battleItemDispColumn: json['battleItemDispColumn'] as int? ?? 7,
      bpExpression: json['bpExpression'] as int? ?? 1,
      chainbonusArtsRate: json['chainbonusArtsRate'] as int? ?? 200,
      chainbonusBusterRate: json['chainbonusBusterRate'] as int? ?? 200,
      chainbonusQuick: json['chainbonusQuick'] as int? ?? 10,
      commandArts: json['commandArts'] as int? ?? 4001,
      commandBuster: json['commandBuster'] as int? ?? 4002,
      commandCardPrmUpMax: json['commandCardPrmUpMax'] as int? ?? 500,
      commandCodeDetachingItemId: json['commandCodeDetachingItemId'] as int? ?? 5003,
      commandQuick: json['commandQuick'] as int? ?? 4003,
      criticalAttackRate: json['criticalAttackRate'] as int? ?? 2000,
      criticalIndividuality: json['criticalIndividuality'] as int? ?? 4100,
      criticalRatePerStar: json['criticalRatePerStar'] as int? ?? 100,
      criticalStarRate: json['criticalStarRate'] as int? ?? 200,
      criticalTdPointRate: json['criticalTdPointRate'] as int? ?? 2000,
      deckMax: json['deckMax'] as int? ?? 10,
      enemyAttackRateArts: json['enemyAttackRateArts'] as int? ?? 1000,
      enemyAttackRateBuster: json['enemyAttackRateBuster'] as int? ?? 1500,
      enemyAttackRateQuick: json['enemyAttackRateQuick'] as int? ?? 800,
      enemyMaxBattleCount: json['enemyMaxBattleCount'] as int? ?? 5,
      extraAttackRateGrand: json['extraAttackRateGrand'] as int? ?? 3500,
      extraAttackRateSingle: json['extraAttackRateSingle'] as int? ?? 2000,
      extraCriticalRate: json['extraCriticalRate'] as int? ?? 0,
      followerListExpireAt: json['followerListExpireAt'] as int? ?? 3600,
      followerRefreshResetTime: json['followerRefreshResetTime'] as int? ?? 10,
      followFriendPoint: json['followFriendPoint'] as int? ?? 50,
      friendNum: json['friendNum'] as int? ?? 28,
      fullTdPoint: json['fullTdPoint'] as int? ?? 10000,
      heroineChangecardvoice: json['heroineChangecardvoice'] as int? ?? 800104,
      hydeSvtId: json['hydeSvtId'] as int? ?? 600710,
      jekyllSvtId: json['jekyllSvtId'] as int? ?? 600700,
      largeSuccessMultExp: json['largeSuccessMultExp'] as int? ?? 2000,
      largeSuccessRate: json['largeSuccessRate'] as int? ?? 100,
      mashuChangeQuestId: json['mashuChangeQuestId'] as int? ?? 1000501,
      mashuChangeWarId: json['mashuChangeWarId'] as int? ?? 105,
      mashuSvtId1: json['mashuSvtId1'] as int? ?? 800100,
      mashuSvtId2: json['mashuSvtId2'] as int? ?? 800101,
      maxBlackListNum: json['maxBlackListNum'] as int? ?? 50,
      maxCommandSpell: json['maxCommandSpell'] as int? ?? 3,
      maxDropFactor: json['maxDropFactor'] as int? ?? 1000,
      maxEventPoint: json['maxEventPoint'] as int? ?? 999999999,
      maxExpFactor: json['maxExpFactor'] as int? ?? 3000,
      maxFriendpoint: json['maxFriendpoint'] as int? ?? 999999999,
      maxFriendpointBoostItemDailyReceive: json['maxFriendpointBoostItemDailyReceive'] as int? ?? 100,
      maxFriendpointBoostItemUse: json['maxFriendpointBoostItemUse'] as int? ?? 3,
      maxFriendshipRank: json['maxFriendshipRank'] as int? ?? 5,
      maxFriendCode: json['maxFriendCode'] as int? ?? 999999999,
      maxFriendHistoryNum: json['maxFriendHistoryNum'] as int? ?? 100,
      maxFriendShipUpRatio: json['maxFriendShipUpRatio'] as int? ?? 3000,
      maxMana: json['maxMana'] as int? ?? 999999999,
      maxNearPresentOffsetNum: json['maxNearPresentOffsetNum'] as int? ?? 50,
      maxPresentBoxHistoryNum: json['maxPresentBoxHistoryNum'] as int? ?? 0,
      maxPresentBoxNum: json['maxPresentBoxNum'] as int? ?? 400,
      maxPresentReceiveNum: json['maxPresentReceiveNum'] as int? ?? 99,
      maxQp: json['maxQp'] as int? ?? 2000000000,
      maxQpDropUpRatio: json['maxQpDropUpRatio'] as int? ?? 3000,
      maxQpFactor: json['maxQpFactor'] as int? ?? 3000,
      maxRarePri: json['maxRarePri'] as int? ?? 999999999,
      maxRp: json['maxRp'] as int? ?? 8,
      maxStone: json['maxStone'] as int? ?? 999999999,
      maxUserCommandCode: json['maxUserCommandCode'] as int? ?? 350,
      maxUserEquipExpUpRatio: json['maxUserEquipExpUpRatio'] as int? ?? 3000,
      maxUserItem: json['maxUserItem'] as int? ?? 999999999,
      maxUserLv: json['maxUserLv'] as int? ?? 160,
      maxUserSvt: json['maxUserSvt'] as int? ?? 600,
      maxUserSvtEquip: json['maxUserSvtEquip'] as int? ?? 600,
      maxUserSvtEquipStorage: json['maxUserSvtEquipStorage'] as int? ?? 100,
      maxUserSvtStorage: json['maxUserSvtStorage'] as int? ?? 100,
      menuChange: json['menuChange'] as int? ?? 1,
      overKillNpRate: json['overKillNpRate'] as int? ?? 1500,
      overKillStarAdd: json['overKillStarAdd'] as int? ?? 300,
      overKillStarRate: json['overKillStarRate'] as int? ?? 1000,
      starRateMax: json['starRateMax'] as int? ?? 3000,
      statusUpAdjustAtk: json['statusUpAdjustAtk'] as int? ?? 10,
      statusUpAdjustHp: json['statusUpAdjustHp'] as int? ?? 10,
      statusUpBuff: json['statusUpBuff'] as int? ?? 3004,
      superSuccessMultExp: json['superSuccessMultExp'] as int? ?? 3000,
      superSuccessRate: json['superSuccessRate'] as int? ?? 20,
      supportDeckMax: json['supportDeckMax'] as int? ?? 10,
      swimsuitMeltSvtId: json['swimsuitMeltSvtId'] as int? ?? 304000,
      tamamocatStunBuffId: json['tamamocatStunBuffId'] as int? ?? 178,
      tamamocatTreasureDeviceId1: json['tamamocatTreasureDeviceId1'] as int? ?? 701601,
      tamamocatTreasureDeviceId2: json['tamamocatTreasureDeviceId2'] as int? ?? 701602,
      temporaryIgnoreSleepModeForTreasureDeviceSvtId1:
          json['temporaryIgnoreSleepModeForTreasureDeviceSvtId1'] as int? ?? 500100,
      temporaryIgnoreSleepModeForTreasureDeviceSvtId2:
          json['temporaryIgnoreSleepModeForTreasureDeviceSvtId2'] as int? ?? 600900,
      treasuredeviceIdMashu3: json['treasuredeviceIdMashu3'] as int? ?? 800104,
      userAct: json['userAct'] as int? ?? 20,
      userCost: json['userCost'] as int? ?? 56,
    );

const _$BuffActionEnumMap = {
  BuffAction.unknown: 'unknown',
  BuffAction.none: 'none',
  BuffAction.commandAtk: 'commandAtk',
  BuffAction.commandDef: 'commandDef',
  BuffAction.atk: 'atk',
  BuffAction.defence: 'defence',
  BuffAction.defencePierce: 'defencePierce',
  BuffAction.specialdefence: 'specialdefence',
  BuffAction.damage: 'damage',
  BuffAction.damageIndividuality: 'damageIndividuality',
  BuffAction.damageIndividualityActiveonly: 'damageIndividualityActiveonly',
  BuffAction.selfdamage: 'selfdamage',
  BuffAction.criticalDamage: 'criticalDamage',
  BuffAction.npdamage: 'npdamage',
  BuffAction.givenDamage: 'givenDamage',
  BuffAction.receiveDamage: 'receiveDamage',
  BuffAction.pierceInvincible: 'pierceInvincible',
  BuffAction.invincible: 'invincible',
  BuffAction.breakAvoidance: 'breakAvoidance',
  BuffAction.avoidance: 'avoidance',
  BuffAction.overwriteBattleclass: 'overwriteBattleclass',
  BuffAction.overwriteClassrelatioAtk: 'overwriteClassrelatioAtk',
  BuffAction.overwriteClassrelatioDef: 'overwriteClassrelatioDef',
  BuffAction.commandNpAtk: 'commandNpAtk',
  BuffAction.commandNpDef: 'commandNpDef',
  BuffAction.dropNp: 'dropNp',
  BuffAction.dropNpDamage: 'dropNpDamage',
  BuffAction.commandStarAtk: 'commandStarAtk',
  BuffAction.commandStarDef: 'commandStarDef',
  BuffAction.criticalPoint: 'criticalPoint',
  BuffAction.starweight: 'starweight',
  BuffAction.turnendNp: 'turnendNp',
  BuffAction.turnendStar: 'turnendStar',
  BuffAction.turnendHpRegain: 'turnendHpRegain',
  BuffAction.turnendHpReduce: 'turnendHpReduce',
  BuffAction.gainHp: 'gainHp',
  BuffAction.turnvalNp: 'turnvalNp',
  BuffAction.grantState: 'grantState',
  BuffAction.resistanceState: 'resistanceState',
  BuffAction.avoidState: 'avoidState',
  BuffAction.donotAct: 'donotAct',
  BuffAction.donotSkill: 'donotSkill',
  BuffAction.donotNoble: 'donotNoble',
  BuffAction.donotRecovery: 'donotRecovery',
  BuffAction.individualityAdd: 'individualityAdd',
  BuffAction.individualitySub: 'individualitySub',
  BuffAction.hate: 'hate',
  BuffAction.criticalRate: 'criticalRate',
  BuffAction.avoidInstantdeath: 'avoidInstantdeath',
  BuffAction.resistInstantdeath: 'resistInstantdeath',
  BuffAction.nonresistInstantdeath: 'nonresistInstantdeath',
  BuffAction.regainNpUsedNoble: 'regainNpUsedNoble',
  BuffAction.functionDead: 'functionDead',
  BuffAction.maxhpRate: 'maxhpRate',
  BuffAction.maxhpValue: 'maxhpValue',
  BuffAction.functionWavestart: 'functionWavestart',
  BuffAction.functionSelfturnend: 'functionSelfturnend',
  BuffAction.giveGainHp: 'giveGainHp',
  BuffAction.functionCommandattackAfter: 'functionCommandattackAfter',
  BuffAction.functionDeadattack: 'functionDeadattack',
  BuffAction.functionEntry: 'functionEntry',
  BuffAction.chagetd: 'chagetd',
  BuffAction.grantSubstate: 'grantSubstate',
  BuffAction.toleranceSubstate: 'toleranceSubstate',
  BuffAction.grantInstantdeath: 'grantInstantdeath',
  BuffAction.functionDamage: 'functionDamage',
  BuffAction.functionReflection: 'functionReflection',
  BuffAction.multiattack: 'multiattack',
  BuffAction.giveNp: 'giveNp',
  BuffAction.resistanceDelayNpturn: 'resistanceDelayNpturn',
  BuffAction.pierceDefence: 'pierceDefence',
  BuffAction.gutsHp: 'gutsHp',
  BuffAction.funcgainNp: 'funcgainNp',
  BuffAction.funcHpReduce: 'funcHpReduce',
  BuffAction.functionNpattack: 'functionNpattack',
  BuffAction.fixCommandcard: 'fixCommandcard',
  BuffAction.donotGainnp: 'donotGainnp',
  BuffAction.fieldIndividuality: 'fieldIndividuality',
  BuffAction.donotActCommandtype: 'donotActCommandtype',
  BuffAction.damageEventPoint: 'damageEventPoint',
  BuffAction.damageSpecial: 'damageSpecial',
  BuffAction.functionAttackAfter: 'functionAttackAfter',
  BuffAction.functionCommandcodeattackBefore: 'functionCommandcodeattackBefore',
  BuffAction.donotNobleCondMismatch: 'donotNobleCondMismatch',
  BuffAction.donotSelectCommandcard: 'donotSelectCommandcard',
  BuffAction.donotReplace: 'donotReplace',
  BuffAction.shortenUserEquipSkill: 'shortenUserEquipSkill',
  BuffAction.tdTypeChange: 'tdTypeChange',
  BuffAction.overwriteClassRelation: 'overwriteClassRelation',
  BuffAction.functionCommandattackBefore: 'functionCommandattackBefore',
  BuffAction.functionGuts: 'functionGuts',
  BuffAction.criticalRateDamageTaken: 'criticalRateDamageTaken',
  BuffAction.criticalStarDamageTaken: 'criticalStarDamageTaken',
  BuffAction.skillRankChange: 'skillRankChange',
  BuffAction.avoidanceIndividuality: 'avoidanceIndividuality',
  BuffAction.changeCommandCardType: 'changeCommandCardType',
  BuffAction.specialInvincible: 'specialInvincible',
  BuffAction.preventDeathByDamage: 'preventDeathByDamage',
  BuffAction.functionCommandcodeattackAfter: 'functionCommandcodeattackAfter',
  BuffAction.functionAttackBefore: 'functionAttackBefore',
  BuffAction.donotSkillSelect: 'donotSkillSelect',
  BuffAction.invisibleBattleChara: 'invisibleBattleChara',
  BuffAction.buffRate: 'buffRate',
  BuffAction.counterFunction: 'counterFunction',
  BuffAction.notTargetSkill: 'notTargetSkill',
  BuffAction.toFieldChangeField: 'toFieldChangeField',
  BuffAction.toFieldAvoidBuff: 'toFieldAvoidBuff',
  BuffAction.grantStateUpOnly: 'grantStateUpOnly',
  BuffAction.turnendHpReduceToRegain: 'turnendHpReduceToRegain',
  BuffAction.functionSelfturnstart: 'functionSelfturnstart',
  BuffAction.overwriteDeadType: 'overwriteDeadType',
  BuffAction.actionCount: 'actionCount',
  BuffAction.shiftGuts: 'shiftGuts',
  BuffAction.toFieldSubIndividualityField: 'toFieldSubIndividualityField',
  BuffAction.masterSkillValueUp: 'masterSkillValueUp',
  BuffAction.buffConvert: 'buffConvert',
  BuffAction.subFieldIndividuality: 'subFieldIndividuality',
  BuffAction.functionCommandcodeattackBeforeMainOnly: 'functionCommandcodeattackBeforeMainOnly',
  BuffAction.functionCommandcodeattackAfterMainOnly: 'functionCommandcodeattackAfterMainOnly',
  BuffAction.functionCommandattackBeforeMainOnly: 'functionCommandattackBeforeMainOnly',
  BuffAction.functionCommandattackAfterMainOnly: 'functionCommandattackAfterMainOnly',
  BuffAction.functionAttackBeforeMainOnly: 'functionAttackBeforeMainOnly',
  BuffAction.functionAttackAfterMainOnly: 'functionAttackAfterMainOnly',
};
