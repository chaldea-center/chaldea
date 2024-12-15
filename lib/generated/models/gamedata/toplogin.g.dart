// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/toplogin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FateTopLogin _$FateTopLoginFromJson(Map json) => FateTopLogin(
      responses: (json['response'] as List<dynamic>?)
              ?.map((e) => FateResponseDetail.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      cache: (json['cache'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      sign: json['sign'] as String?,
    );

FateResponseDetail _$FateResponseDetailFromJson(Map json) => FateResponseDetail(
      resCode: json['resCode'] as String?,
      success: json['success'] as Map?,
      fail: json['fail'] as Map?,
      nid: json['nid'] as String?,
      usk: json['usk'] as String?,
      encryptApi: (json['encryptApi'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

UserItemEntity _$UserItemEntityFromJson(Map json) => UserItemEntity(
      itemId: json['itemId'],
      num: json['num'],
    );

UserServantEntity _$UserServantEntityFromJson(Map json) => UserServantEntity(
      id: json['id'],
      svtId: json['svtId'],
      status: json['status'],
      limitCount: json['limitCount'],
      dispLimitCount: json['dispLimitCount'],
      imageLimitCount: json['imageLimitCount'],
      commandCardLimitCount: json['commandCardLimitCount'],
      lv: json['lv'],
      exp: json['exp'],
      adjustHp: json['adjustHp'],
      adjustAtk: json['adjustAtk'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      treasureDeviceLv1: json['treasureDeviceLv1'],
      exceedCount: json['exceedCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isLock: json['isLock'],
      hp: json['hp'],
      atk: json['atk'],
    );

UserServantCollectionEntity _$UserServantCollectionEntityFromJson(Map json) => UserServantCollectionEntity(
      userId: json['userId'],
      svtId: json['svtId'],
      status: json['status'],
      maxLv: json['maxLv'],
      maxHp: json['maxHp'],
      maxAtk: json['maxAtk'],
      maxLimitCount: json['maxLimitCount'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      treasureDeviceLv1: json['treasureDeviceLv1'],
      svtCommonFlag: json['svtCommonFlag'],
      flag: json['flag'],
      friendship: json['friendship'],
      friendshipRank: json['friendshipRank'],
      friendshipExceedCount: json['friendshipExceedCount'],
      getNum: json['getNum'],
      totalGetNum: json['totalGetNum'],
      costumeIds: json['costumeIds'],
      releasedCostumeIds: json['releasedCostumeIds'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserGameEntity _$UserGameEntityFromJson(Map json) => UserGameEntity(
      userId: json['userId'],
      name: json['name'] as String? ?? "",
      birthDay: json['birthDay'],
      actMax: json['actMax'],
      actRecoverAt: json['actRecoverAt'],
      carryOverActPoint: json['carryOverActPoint'],
      rpRecoverAt: json['rpRecoverAt'],
      carryOverRaidPoint: json['carryOverRaidPoint'],
      genderType: json['genderType'],
      lv: json['lv'],
      exp: json['exp'],
      qp: json['qp'],
      costMax: json['costMax'],
      friendCode: json['friendCode'] as String? ?? "",
      favoriteUserSvtId: json['favoriteUserSvtId'],
      pushUserSvtId: json['pushUserSvtId'],
      grade: json['grade'],
      friendKeep: json['friendKeep'],
      commandSpellRecoverAt: json['commandSpellRecoverAt'],
      svtKeep: json['svtKeep'],
      svtEquipKeep: json['svtEquipKeep'],
      svtStorageAdjust: json['svtStorageAdjust'],
      svtEquipStorageAdjust: json['svtEquipStorageAdjust'],
      freeStone: json['freeStone'],
      chargeStone: json['chargeStone'],
      stone: json['stone'],
      stoneVerifiAt: json['stoneVerifiAt'],
      mana: json['mana'],
      rarePri: json['rarePri'],
      activeDeckId: json['activeDeckId'],
      mainSupportDeckId: json['mainSupportDeckId'],
      eventSupportDeckId: json['eventSupportDeckId'],
      fixMainSupportDeckIds: json['fixMainSupportDeckIds'],
      fixEventSupportDeckIds: json['fixEventSupportDeckIds'],
      tutorial1: json['tutorial1'],
      tutorial2: json['tutorial2'],
      message: json['message'] as String? ?? "",
      flag: json['flag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      userEquipId: json['userEquipId'],
      id: json['id'],
      appuid: json['appuid'],
      appname: json['appname'] as String?,
      regtime: json['regtime'],
    );

Map<String, dynamic> _$UserGameEntityToJson(UserGameEntity instance) => <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'birthDay': instance.birthDay,
      'actMax': instance.actMax,
      'actRecoverAt': instance.actRecoverAt,
      'carryOverActPoint': instance.carryOverActPoint,
      'rpRecoverAt': instance.rpRecoverAt,
      'carryOverRaidPoint': instance.carryOverRaidPoint,
      'genderType': instance.genderType,
      'lv': instance.lv,
      'exp': instance.exp,
      'qp': instance.qp,
      'costMax': instance.costMax,
      'friendCode': instance.friendCode,
      'favoriteUserSvtId': instance.favoriteUserSvtId,
      'pushUserSvtId': instance.pushUserSvtId,
      'commandSpellRecoverAt': instance.commandSpellRecoverAt,
      'friendKeep': instance.friendKeep,
      'svtKeep': instance.svtKeep,
      'svtEquipKeep': instance.svtEquipKeep,
      'svtStorageAdjust': instance.svtStorageAdjust,
      'svtEquipStorageAdjust': instance.svtEquipStorageAdjust,
      'freeStone': instance.freeStone,
      'chargeStone': instance.chargeStone,
      'stone': instance.stone,
      'grade': instance.grade,
      'stoneVerifiAt': instance.stoneVerifiAt,
      'mana': instance.mana,
      'rarePri': instance.rarePri,
      'activeDeckId': instance.activeDeckId,
      'mainSupportDeckId': instance.mainSupportDeckId,
      'eventSupportDeckId': instance.eventSupportDeckId,
      'fixMainSupportDeckIds': instance.fixMainSupportDeckIds,
      'fixEventSupportDeckIds': instance.fixEventSupportDeckIds,
      'tutorial1': instance.tutorial1,
      'tutorial2': instance.tutorial2,
      'message': instance.message,
      'flag': instance.flag,
      'updatedAt': instance.updatedAt,
      'createdAt': instance.createdAt,
      'userEquipId': instance.userEquipId,
      'id': instance.id,
      'appuid': instance.appuid,
      'appname': instance.appname,
      'regtime': instance.regtime,
    };

TblUserEntity _$TblUserEntityFromJson(Map json) => TblUserEntity(
      userId: json['userId'],
      friendPoint: json['friendPoint'],
    );

UserLoginEntity _$UserLoginEntityFromJson(Map json) => UserLoginEntity(
      userId: json['userId'],
      seqLoginCount: json['seqLoginCount'],
      totalLoginCount: json['totalLoginCount'],
      lastLoginAt: json['lastLoginAt'],
    );

UserServantAppendPassiveSkillEntity _$UserServantAppendPassiveSkillEntityFromJson(Map json) =>
    UserServantAppendPassiveSkillEntity(
      userId: json['userId'],
      unlockNums: (json['unlockNums'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      svtId: json['svtId'],
    );

UserSvtCoinEntity _$UserSvtCoinEntityFromJson(Map json) => UserSvtCoinEntity(
      userId: json['userId'],
      svtId: json['svtId'],
      num: json['num'],
    );

UserServantAppendPassiveSkillLvEntity _$UserServantAppendPassiveSkillLvEntityFromJson(Map json) =>
    UserServantAppendPassiveSkillLvEntity(
      userSvtId: json['userSvtId'],
      appendPassiveSkillNums: (json['appendPassiveSkillNums'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      appendPassiveSkillLvs: (json['appendPassiveSkillLvs'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

UserEquipEntity _$UserEquipEntityFromJson(Map json) => UserEquipEntity(
      id: json['id'],
      equipId: json['equipId'],
      lv: json['lv'],
      exp: json['exp'],
    );

UserCommandCodeCollectionEntity _$UserCommandCodeCollectionEntityFromJson(Map json) => UserCommandCodeCollectionEntity(
      userId: json['userId'],
      commandCodeId: json['commandCodeId'],
      status: json['status'],
      getNum: json['getNum'],
    );

UserCommandCodeEntity _$UserCommandCodeEntityFromJson(Map json) => UserCommandCodeEntity(
      id: json['id'],
      commandCodeId: json['commandCodeId'],
      status: json['status'],
      createdAt: json['createdAt'],
    );

UserServantCommandCodeEntity _$UserServantCommandCodeEntityFromJson(Map json) => UserServantCommandCodeEntity(
      userId: json['userId'],
      userCommandCodeIds: json['userCommandCodeIds'],
      svtId: json['svtId'],
    );

UserServantCommandCardEntity _$UserServantCommandCardEntityFromJson(Map json) => UserServantCommandCardEntity(
      userId: json['userId'],
      commandCardParam: json['commandCardParam'],
      svtId: json['svtId'],
    );

UserSupportDeckEntity _$UserSupportDeckEntityFromJson(Map json) => UserSupportDeckEntity(
      userId: json['userId'],
      supportDeckId: json['supportDeckId'],
      name: json['name'],
    );

UserServantLeaderEntity _$UserServantLeaderEntityFromJson(Map json) => UserServantLeaderEntity(
      userId: json['userId'],
      supportDeckId: json['supportDeckId'],
      classId: json['classId'],
      userSvtId: json['userSvtId'],
      svtId: json['svtId'],
      limitCount: json['limitCount'],
      dispLimitCount: json['dispLimitCount'],
      lv: json['lv'],
      exp: json['exp'],
      hp: json['hp'],
      atk: json['atk'],
      adjustHp: json['adjustHp'],
      adjustAtk: json['adjustAtk'],
      skillId1: json['skillId1'],
      skillId2: json['skillId2'],
      skillId3: json['skillId3'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      classPassive: json['classPassive'],
      treasureDeviceId: json['treasureDeviceId'],
      treasureDeviceLv: json['treasureDeviceLv'],
      exceedCount: json['exceedCount'],
      equipTarget1: json['equipTarget1'] == null
          ? null
          : SvtLeaderEquipTargetInfo.fromJson(Map<String, dynamic>.from(json['equipTarget1'] as Map)),
      commandCode: (json['commandCode'] as List<dynamic>?)
          ?.map((e) => SvtLeaderCommandCodeStatus.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      commandCardParam: json['commandCardParam'],
      imageLimitCount: json['imageLimitCount'],
      commandCardLimitCount: json['commandCardLimitCount'],
      iconLimitCount: json['iconLimitCount'],
      portraitLimitCount: json['portraitLimitCount'],
      battleVoice: json['battleVoice'],
      appendPassiveSkill: (json['appendPassiveSkill'] as List<dynamic>?)
          ?.map((e) => SvtLeaderAppendSkillStatus.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

SvtLeaderEquipTargetInfo _$SvtLeaderEquipTargetInfoFromJson(Map json) => SvtLeaderEquipTargetInfo(
      userSvtId: json['userSvtId'],
      svtId: json['svtId'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      exp: json['exp'],
      hp: json['hp'],
      atk: json['atk'],
      skillId1: json['skillId1'],
      skillLv1: json['skillLv1'],
      skillId2: json['skillId2'],
      skillLv2: json['skillLv2'],
      skillId3: json['skillId3'],
      skillLv3: json['skillLv3'],
      addSkills: (json['addSkills'] as List<dynamic>?)?.map((e) => e as Map).toList(),
    );

SvtLeaderAppendSkillStatus _$SvtLeaderAppendSkillStatusFromJson(Map json) => SvtLeaderAppendSkillStatus(
      skillId: json['skillId'],
      skillLv: json['skillLv'],
    );

SvtLeaderCommandCodeStatus _$SvtLeaderCommandCodeStatusFromJson(Map json) => SvtLeaderCommandCodeStatus(
      idx: json['idx'],
      commandCodeId: json['commandCodeId'],
      userCommandCodeId: json['userCommandCodeId'],
    );

UserClassBoardSquareEntity _$UserClassBoardSquareEntityFromJson(Map json) => UserClassBoardSquareEntity(
      userId: json['userId'],
      classBoardBaseId: json['classBoardBaseId'],
      classBoardSquareIds: json['classBoardSquareIds'],
      classBoardUnlockSquareIds: json['classBoardUnlockSquareIds'],
    );

UserPresentBoxEntity _$UserPresentBoxEntityFromJson(Map json) => UserPresentBoxEntity(
      receiveUserId: json['receiveUserId'],
      presentId: json['presentId'],
      messageRefType: json['messageRefType'],
      messageId: json['messageId'],
      message: json['message'],
      fromType: json['fromType'],
      giftType: json['giftType'],
      objectId: json['objectId'],
      num: json['num'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      flag: json['flag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserGachaEntity _$UserGachaEntityFromJson(Map json) => UserGachaEntity(
      userId: json['userId'],
      gachaId: json['gachaId'],
      num: json['num'],
      freeDrawAt: json['freeDrawAt'],
      status: json['status'],
      createdAt: json['createdAt'],
    );

UserEventEntity _$UserEventEntityFromJson(Map json) => UserEventEntity(
      userId: json['userId'],
      eventId: json['eventId'],
      value: json['value'],
      flag: json['flag'],
      scriptFlag: json['scriptFlag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserEventMissionEntity _$UserEventMissionEntityFromJson(Map json) => UserEventMissionEntity(
      userId: json['userId'],
      missionId: json['missionId'],
      missionTargetId: json['missionTargetId'],
      missionProgressType: json['missionProgressType'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserEventMissionCondDetailEntity _$UserEventMissionCondDetailEntityFromJson(Map json) =>
    UserEventMissionCondDetailEntity(
      userId: json['userId'],
      conditionDetailId: json['conditionDetailId'],
      missionTargetId: json['missionTargetId'],
      progressNum: json['progressNum'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserEventPointEntity _$UserEventPointEntityFromJson(Map json) => UserEventPointEntity(
      userId: json['userId'],
      eventId: json['eventId'],
      groupId: json['groupId'],
      value: json['value'],
    );

UserEventTradeEntity _$UserEventTradeEntityFromJson(Map json) => UserEventTradeEntity(
      eventId: json['eventId'],
      updatedAt: json['updatedAt'],
      tradeList: (json['tradeList'] as List<dynamic>?)
          ?.map((e) => EventTradeInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      resultList: (json['resultList'] as List<dynamic>?)
          ?.map((e) => EventTradeResultInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pickupList: (json['pickupList'] as List<dynamic>?)
          ?.map((e) => EventCraftPickupInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EventTradeInfo _$EventTradeInfoFromJson(Map json) => EventTradeInfo(
      storeIdx: json['storeIdx'],
      tradeGoodsId: json['tradeGoodsId'],
      tradeNum: json['tradeNum'],
      maxTradeNum: json['maxTradeNum'],
      getNum: json['getNum'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
    );

EventTradeResultInfo _$EventTradeResultInfoFromJson(Map json) => EventTradeResultInfo(
      tradeGoodsId: json['tradeGoodsId'],
      getNum: json['getNum'],
    );

EventCraftPickupInfo _$EventCraftPickupInfoFromJson(Map json) => EventCraftPickupInfo(
      tradeGoodsId: json['tradeGoodsId'],
      itemId: json['itemId'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
    );

EventRaidEntity _$EventRaidEntityFromJson(Map json) => EventRaidEntity(
      eventId: json['eventId'],
      day: json['day'],
      groupIndex: json['groupIndex'],
      subGroupIndex: json['subGroupIndex'],
      name: json['name'],
      maxHp: json['maxHp'],
      iconId: json['iconId'],
      bossColor: json['bossColor'],
      startedAt: json['startedAt'],
      endedAt: json['endedAt'],
      timeLimitAt: json['timeLimitAt'],
      splitAiMode: json['splitAiMode'],
      splitHp: json['splitHp'],
      defeatNormaAt: json['defeatNormaAt'],
      defeatBaseAt: json['defeatBaseAt'],
      correctStartTime: json['correctStartTime'],
    );

UserEventRaidEntity _$UserEventRaidEntityFromJson(Map json) => UserEventRaidEntity(
      userId: json['userId'],
      eventId: json['eventId'],
      day: json['day'],
      damage: json['damage'],
    );

TotalEventRaidEntity _$TotalEventRaidEntityFromJson(Map json) => TotalEventRaidEntity(
      eventId: json['eventId'],
      day: json['day'],
      totalDamage: json['totalDamage'],
      defeatedAt: json['defeatedAt'],
    );

Map<String, dynamic> _$BattleRaidResultToJson(BattleRaidResult instance) => <String, dynamic>{
      'uniqueId': instance.uniqueId,
      'day': instance.day,
      'addDamage': instance.addDamage,
    };

Map<String, dynamic> _$BattleSuperBossResultToJson(BattleSuperBossResult instance) => <String, dynamic>{
      'superBossId': instance.superBossId,
      'uniqueId': instance.uniqueId,
      'addDamage': instance.addDamage,
    };

UserShopEntity _$UserShopEntityFromJson(Map json) => UserShopEntity(
      userId: json['userId'],
      shopId: json['shopId'],
      num: json['num'],
      flag: json['flag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserQuestEntity _$UserQuestEntityFromJson(Map json) => UserQuestEntity(
      userId: json['userId'],
      questId: json['questId'],
      questPhase: json['questPhase'],
      clearNum: json['clearNum'],
      isEternalOpen: json['isEternalOpen'],
      expireAt: json['expireAt'],
      challengeNum: json['challengeNum'],
      isNew: json['isNew'],
      lastStartedAt: json['lastStartedAt'],
      status: json['status'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserFollowerEntity _$UserFollowerEntityFromJson(Map json) => UserFollowerEntity(
      followerInfo: (json['followerInfo'] as List<dynamic>?)
              ?.map((e) => FollowerInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      userId: json['userId'],
      expireAt: json['expireAt'],
    );

FollowerInfo _$FollowerInfoFromJson(Map json) => FollowerInfo(
      userId: json['userId'],
      userName: json['userName'],
      userLv: json['userLv'],
      type: json['type'],
      userSvtLeaderHash: (json['userSvtLeaderHash'] as List<dynamic>?)
          ?.map((e) => ServantLeaderInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      eventUserSvtLeaderHash: (json['eventUserSvtLeaderHash'] as List<dynamic>?)
          ?.map((e) => ServantLeaderInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tutorial1: json['tutorial1'],
      message: json['message'],
      pushUserSvtId: json['pushUserSvtId'],
      mainSupportDeckIds: json['mainSupportDeckIds'],
      eventSupportDeckIds: json['eventSupportDeckIds'],
    );

ServantLeaderInfo _$ServantLeaderInfoFromJson(Map json) => ServantLeaderInfo(
      supportDeckId: json['supportDeckId'],
      userId: json['userId'],
      classId: json['classId'],
      userSvtId: json['userSvtId'],
      svtId: json['svtId'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      exp: json['exp'],
      hp: json['hp'],
      atk: json['atk'],
      adjustAtk: json['adjustAtk'],
      adjustHp: json['adjustHp'],
      skillId1: json['skillId1'],
      skillId2: json['skillId2'],
      skillId3: json['skillId3'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      classPassive: json['classPassive'],
      treasureDeviceId: json['treasureDeviceId'],
      treasureDeviceLv: json['treasureDeviceLv'],
      exceedCount: json['exceedCount'],
      equipTarget1: json['equipTarget1'] == null
          ? null
          : SvtLeaderEquipTargetInfo.fromJson(Map<String, dynamic>.from(json['equipTarget1'] as Map)),
      updatedAt: json['updatedAt'],
      imageLimitCount: json['imageLimitCount'],
      dispLimitCount: json['dispLimitCount'],
      commandCardLimitCount: json['commandCardLimitCount'],
      iconLimitCount: json['iconLimitCount'],
      portraitLimitCount: json['portraitLimitCount'],
      randomLimitCountTargets: json['randomLimitCountTargets'],
      commandCode: (json['commandCode'] as List<dynamic>?)?.map((e) => e as Map).toList(),
      commandCardParam: json['commandCardParam'],
      appendPassiveSkill: (json['appendPassiveSkill'] as List<dynamic>?)?.map((e) => e as Map).toList(),
      eventSvtPoint: json['eventSvtPoint'],
    );

UserAccountLinkageEntity _$UserAccountLinkageEntityFromJson(Map json) => UserAccountLinkageEntity(
      userId: json['userId'],
      type: json['type'],
      linkedAt: json['linkedAt'],
    );

UserDeckEntity _$UserDeckEntityFromJson(Map json) => UserDeckEntity(
      id: json['id'],
      userId: json['userId'],
      deckNo: json['deckNo'],
      name: json['name'],
      deckInfo: json['deckInfo'] == null
          ? null
          : DeckServantEntity.fromJson(Map<String, dynamic>.from(json['deckInfo'] as Map)),
      cost: json['cost'],
    );

Map<String, dynamic> _$UserDeckEntityToJson(UserDeckEntity instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deckNo': instance.deckNo,
      'name': instance.name,
      'deckInfo': instance.deckInfo?.toJson(),
      'cost': instance.cost,
    };

UserEventDeckEntity _$UserEventDeckEntityFromJson(Map json) => UserEventDeckEntity(
      userId: json['userId'],
      eventId: json['eventId'],
      deckNo: json['deckNo'],
      deckInfo: json['deckInfo'] == null
          ? null
          : DeckServantEntity.fromJson(Map<String, dynamic>.from(json['deckInfo'] as Map)),
    );

DeckServantEntity _$DeckServantEntityFromJson(Map json) => DeckServantEntity(
      svts: (json['svts'] as List<dynamic>?)
          ?.map((e) => DeckServantData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userEquipId: json['userEquipId'],
      waveSvts: json['waveSvts'] as List<dynamic>?,
    );

Map<String, dynamic> _$DeckServantEntityToJson(DeckServantEntity instance) => <String, dynamic>{
      'svts': instance.svts.map((e) => e.toJson()).toList(),
      'userEquipId': instance.userEquipId,
      'waveSvts': instance.waveSvts,
    };

DeckServantData _$DeckServantDataFromJson(Map json) => DeckServantData(
      id: json['id'],
      userSvtId: json['userSvtId'],
      userId: json['userId'],
      svtId: json['svtId'],
      userSvtEquipIds: json['userSvtEquipIds'],
      svtEquipIds: json['svtEquipIds'],
      isFollowerSvt: json['isFollowerSvt'],
      npcFollowerSvtId: json['npcFollowerSvtId'],
      followerType: json['followerType'],
      initPos: json['initPos'],
    );

Map<String, dynamic> _$DeckServantDataToJson(DeckServantData instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'userSvtId': instance.userSvtId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('svtId', instance.svtId);
  val['userSvtEquipIds'] = instance.userSvtEquipIds;
  writeNotNull('svtEquipIds', instance.svtEquipIds);
  val['isFollowerSvt'] = instance.isFollowerSvt;
  val['npcFollowerSvtId'] = instance.npcFollowerSvtId;
  writeNotNull('followerType', instance.followerType);
  writeNotNull('initPos', instance.initPos);
  return val;
}

BattleEntity _$BattleEntityFromJson(Map json) => BattleEntity(
      battleInfo: json['battleInfo'] == null
          ? null
          : BattleInfoData.fromJson(Map<String, dynamic>.from(json['battleInfo'] as Map)),
      id: json['id'],
      battleType: json['battleType'],
      questId: json['questId'],
      questPhase: json['questPhase'],
      userId: json['userId'],
      targetId: json['targetId'],
      followerId: json['followerId'],
      followerType: json['followerType'],
      eventId: json['eventId'],
      createdAt: json['createdAt'],
    );

BattleInfoData _$BattleInfoDataFromJson(Map json) => BattleInfoData(
      dataVer: json['dataVer'],
      appVer: json['appVer'],
      userEquipId: json['userEquipId'],
      useEventEquip: json['useEventEquip'],
      userSvt: (json['userSvt'] as List<dynamic>?)
              ?.map((e) => BattleUserServantData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      myDeck: json['myDeck'] == null ? null : DeckData.fromJson(Map<String, dynamic>.from(json['myDeck'] as Map)),
      enemyDeck: (json['enemyDeck'] as List<dynamic>?)
              ?.map((e) => DeckData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      raidInfo: (json['raidInfo'] as List<dynamic>?)
              ?.map((e) => BattleRaidInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      startRaidInfo: (json['startRaidInfo'] as List<dynamic>?)
              ?.map((e) => BattleRaidInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      superBossInfo: (json['superBossInfo'] as List<dynamic>?)?.map((e) => e as Map).toList() ?? const [],
    );

DeckData _$DeckDataFromJson(Map json) => DeckData(
      svts: (json['svts'] as List<dynamic>?)
              ?.map((e) => BattleDeckServantData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      followerType: json['followerType'],
      stageId: json['stageId'],
    );

BattleDeckServantData _$BattleDeckServantDataFromJson(Map json) => BattleDeckServantData(
      uniqueId: json['uniqueId'],
      name: json['name'],
      roleType: json['roleType'],
      dropInfos: (json['dropInfos'] as List<dynamic>?)
              ?.map((e) => DropInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      npcId: json['npcId'],
      enemyScript: json['enemyScript'] as Map?,
      index: json['index'],
      id: json['id'],
      userSvtId: json['userSvtId'],
      userSvtEquipIds: json['userSvtEquipIds'],
      isFollowerSvt: json['isFollowerSvt'],
      npcFollowerSvtId: json['npcFollowerSvtId'],
      followerType: json['followerType'],
    );

BattleUserServantData _$BattleUserServantDataFromJson(Map json) => BattleUserServantData(
      id: json['id'],
      userId: json['userId'],
      svtId: json['svtId'],
      lv: json['lv'],
      exp: json['exp'],
      atk: json['atk'],
      hp: json['hp'],
      adjustAtk: json['adjustAtk'],
      adjustHp: json['adjustHp'],
      skillId1: json['skillId1'],
      skillId2: json['skillId2'],
      skillId3: json['skillId3'],
      skillLv1: json['skillLv1'],
      skillLv2: json['skillLv2'],
      skillLv3: json['skillLv3'],
      treasureDeviceId: json['treasureDeviceId'],
      treasureDeviceLv: json['treasureDeviceLv'],
      equipTargetId1: json['equipTargetId1'],
      equipTargetIds: json['equipTargetIds'],
      appendPassiveSkillIds: json['appendPassiveSkillIds'],
      appendPassiveSkillLvs: json['appendPassiveSkillLvs'],
      limitCount: json['limitCount'],
      dispLimitCount: json['dispLimitCount'],
    );

BattleRaidInfo _$BattleRaidInfoFromJson(Map json) => BattleRaidInfo(
      day: json['day'],
      uniqueId: json['uniqueId'],
      maxHp: json['maxHp'],
      totalDamage: json['totalDamage'],
    );

DropInfo _$DropInfoFromJson(Map json) => DropInfo(
      type: json['type'],
      objectId: json['objectId'],
      num: json['num'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      rarity: json['rarity'],
      isRateUp: json['isRateUp'],
      originalNum: json['originalNum'],
      effectType: json['effectType'],
      isAdd: json['isAdd'],
    );

BattleFriendshipRewardInfo _$BattleFriendshipRewardInfoFromJson(Map json) => BattleFriendshipRewardInfo(
      isNew: json['isNew'],
      userSvtId: json['userSvtId'],
      mstGiftId: json['mstGiftId'],
      type: json['type'],
      targetSvtId: json['targetSvtId'],
      objectId: json['objectId'],
      num: json['num'],
      limitCount: json['limitCount'],
      lv: json['lv'],
      rarity: json['rarity'],
    );

BattleResultData _$BattleResultDataFromJson(Map json) => BattleResultData(
      battleId: json['battleId'],
      battleResult: json['battleResult'],
      eventId: json['eventId'],
      followerId: json['followerId'],
      followerClassId: json['followerClassId'],
      followerSupportDeckId: json['followerSupportDeckId'],
      followerType: json['followerType'],
      followerStatus: json['followerStatus'],
      oldUserGame: (json['oldUserGame'] as List<dynamic>?)
          ?.map((e) => UserGameEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      oldUserQuest: (json['oldUserQuest'] as List<dynamic>?)
          ?.map((e) => UserQuestEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      oldUserEquip: (json['oldUserEquip'] as List<dynamic>?)
          ?.map((e) => UserEquipEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      oldUserSvtCollection: (json['oldUserSvtCollection'] as List<dynamic>?)
          ?.map((e) => UserServantCollectionEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      oldUserSvt: (json['oldUserSvt'] as List<dynamic>?)
          ?.map((e) => UserServantEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      myDeck: json['myDeck'],
      firstClearRewardQp: json['firstClearRewardQp'],
      originalPhaseClearQp: json['originalPhaseClearQp'],
      phaseClearQp: json['phaseClearQp'],
      friendshipExpBase: json['friendshipExpBase'],
      friendshipRewardInfos: (json['friendshipRewardInfos'] as List<dynamic>?)
          ?.map((e) => BattleFriendshipRewardInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      warClearReward: json['warClearReward'],
      rewardInfos: (json['rewardInfos'] as List<dynamic>?)
          ?.map((e) => DropInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      resultDropInfos: (json['resultDropInfos'] as List<dynamic>?)
          ?.map((e) => DropInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

GachaInfos _$GachaInfosFromJson(Map json) => GachaInfos(
      isNew: json['isNew'],
      userSvtId: json['userSvtId'],
      type: json['type'],
      objectId: json['objectId'],
      num: json['num'],
      limitCount: json['limitCount'],
      sellQp: json['sellQp'],
      sellMana: json['sellMana'],
      svtCoinNum: json['svtCoinNum'],
    );

Map<String, dynamic> _$GachaInfosToJson(GachaInfos instance) => <String, dynamic>{
      'type': instance.type,
      'objectId': instance.objectId,
      'num': instance.num,
      'isNew': instance.isNew,
      'userSvtId': instance.userSvtId,
      'limitCount': instance.limitCount,
      'sellQp': instance.sellQp,
      'sellMana': instance.sellMana,
      'svtCoinNum': instance.svtCoinNum,
    };
