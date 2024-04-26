// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/toplogin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FateTopLogin _$FateTopLoginFromJson(Map json) => FateTopLogin(
      response: (json['response'] as List<dynamic>?)
              ?.map((e) => FateResponseDetail.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      cache: json['cache'] == null ? null : UserMstCache.fromJson(Map<String, dynamic>.from(json['cache'] as Map)),
      sign: json['sign'] as String?,
    );

FateResponseDetail _$FateResponseDetailFromJson(Map json) => FateResponseDetail(
      resCode: json['resCode'] as String?,
      success: json['success'] as Map?,
      fail: json['fail'] as Map?,
      nid: json['nid'] as String?,
    );

UserMstCache _$UserMstCacheFromJson(Map json) => UserMstCache(
      replaced:
          json['replaced'] == null ? null : UserMstData.fromJson(Map<String, dynamic>.from(json['replaced'] as Map)),
      updated: json['updated'] == null ? null : UserMstData.fromJson(Map<String, dynamic>.from(json['updated'] as Map)),
      serverTime: (json['serverTime'] as num?)?.toInt(),
    );

UserMstData _$UserMstDataFromJson(Map json) => UserMstData(
      userGame: (json['userGame'] as List<dynamic>?)
          ?.map((e) => UserGame.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCollection: (json['userSvtCollection'] as List<dynamic>?)
          ?.map((e) => UserSvtCollection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvt: (json['userSvt'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtStorage: (json['userSvtStorage'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtAppendPassiveSkill: (json['userSvtAppendPassiveSkill'] as List<dynamic>?)
          ?.map((e) => UserSvtAppendPassiveSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtAppendPassiveSkillLv: (json['userSvtAppendPassiveSkillLv'] as List<dynamic>?)
          ?.map((e) => UserSvtAppendPassiveSkillLv.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userCommandCodeCollection: (json['userCommandCodeCollection'] as List<dynamic>?)
          ?.map((e) => UserCommandCodeCollection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userCommandCode: (json['userCommandCode'] as List<dynamic>?)
          ?.map((e) => UserCommandCode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCommandCode: (json['userSvtCommandCode'] as List<dynamic>?)
          ?.map((e) => UserSvtCommandCode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCommandCard: (json['userSvtCommandCard'] as List<dynamic>?)
          ?.map((e) => UserSvtCommandCard.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userItem: (json['userItem'] as List<dynamic>?)
          ?.map((e) => UserItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCoin: (json['userSvtCoin'] as List<dynamic>?)
          ?.map((e) => UserSvtCoin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userEquip: (json['userEquip'] as List<dynamic>?)
          ?.map((e) => UserEquip.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSupportDeck: (json['userSupportDeck'] as List<dynamic>?)
          ?.map((e) => UserSupportDeck.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtLeader: (json['userSvtLeader'] as List<dynamic>?)
          ?.map((e) => UserSvtLeader.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userClassBoardSquare: (json['userClassBoardSquare'] as List<dynamic>?)
          ?.map((e) => UserClassBoardSquare.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userPresentBox: (json['userPresentBox'] as List<dynamic>?)
          ?.map((e) => UserPresentBox.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userGacha: (json['userGacha'] as List<dynamic>?)
          ?.map((e) => UserGacha.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userEventMission: (json['userEventMission'] as List<dynamic>?)
          ?.map((e) => UserEventMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userShop: (json['userShop'] as List<dynamic>?)
          ?.map((e) => UserShop.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userQuest: (json['userQuest'] as List<dynamic>?)
          ?.map((e) => UserQuest.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

UserItem _$UserItemFromJson(Map json) => UserItem(
      itemId: json['itemId'],
      num: json['num'],
    );

UserSvt _$UserSvtFromJson(Map json) => UserSvt(
      id: json['id'],
      svtId: json['svtId'],
      status: json['status'],
      limitCount: json['limitCount'],
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
      hp: (json['hp'] as num).toInt(),
      atk: (json['atk'] as num).toInt(),
    );

UserSvtCollection _$UserSvtCollectionFromJson(Map json) => UserSvtCollection(
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

UserGame _$UserGameFromJson(Map json) => UserGame(
      userId: json['userId'],
      name: json['name'] as String,
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
      friendCode: json['friendCode'] as String,
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
      message: json['message'] as String,
      flag: json['flag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      userEquipId: json['userEquipId'],
      id: json['id'],
      appuid: json['appuid'],
      appname: json['appname'] as String?,
    );

Map<String, dynamic> _$UserGameToJson(UserGame instance) => <String, dynamic>{
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
      'grade': instance.grade,
      'friendKeep': instance.friendKeep,
      'commandSpellRecoverAt': instance.commandSpellRecoverAt,
      'svtKeep': instance.svtKeep,
      'svtEquipKeep': instance.svtEquipKeep,
      'svtStorageAdjust': instance.svtStorageAdjust,
      'svtEquipStorageAdjust': instance.svtEquipStorageAdjust,
      'freeStone': instance.freeStone,
      'chargeStone': instance.chargeStone,
      'stone': instance.stone,
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
    };

UserSvtAppendPassiveSkill _$UserSvtAppendPassiveSkillFromJson(Map json) => UserSvtAppendPassiveSkill(
      unlockNums: (json['unlockNums'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      svtId: json['svtId'],
    );

UserSvtCoin _$UserSvtCoinFromJson(Map json) => UserSvtCoin(
      svtId: json['svtId'],
      num: json['num'],
    );

UserSvtAppendPassiveSkillLv _$UserSvtAppendPassiveSkillLvFromJson(Map json) => UserSvtAppendPassiveSkillLv(
      userSvtId: json['userSvtId'],
      appendPassiveSkillNums: (json['appendPassiveSkillNums'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      appendPassiveSkillLvs: (json['appendPassiveSkillLvs'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

UserEquip _$UserEquipFromJson(Map json) => UserEquip(
      id: json['id'],
      equipId: json['equipId'],
      lv: json['lv'],
      exp: json['exp'],
    );

UserCommandCodeCollection _$UserCommandCodeCollectionFromJson(Map json) => UserCommandCodeCollection(
      commandCodeId: json['commandCodeId'],
      status: json['status'],
      getNum: json['getNum'],
    );

UserCommandCode _$UserCommandCodeFromJson(Map json) => UserCommandCode(
      id: json['id'],
      commandCodeId: json['commandCodeId'],
      status: json['status'],
    );

UserSvtCommandCode _$UserSvtCommandCodeFromJson(Map json) => UserSvtCommandCode(
      userCommandCodeIds: json['userCommandCodeIds'],
      svtId: json['svtId'],
    );

UserSvtCommandCard _$UserSvtCommandCardFromJson(Map json) => UserSvtCommandCard(
      commandCardParam: json['commandCardParam'],
      svtId: json['svtId'],
    );

UserSupportDeck _$UserSupportDeckFromJson(Map json) => UserSupportDeck(
      supportDeckId: json['supportDeckId'],
      name: json['name'],
    );

UserSvtLeader _$UserSvtLeaderFromJson(Map json) => UserSvtLeader(
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

UserClassBoardSquare _$UserClassBoardSquareFromJson(Map json) => UserClassBoardSquare(
      classBoardBaseId: json['classBoardBaseId'],
      classBoardSquareIds: json['classBoardSquareIds'],
      classBoardUnlockSquareIds: json['classBoardUnlockSquareIds'],
    );

UserPresentBox _$UserPresentBoxFromJson(Map json) => UserPresentBox(
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

UserGacha _$UserGachaFromJson(Map json) => UserGacha(
      gachaId: json['gachaId'],
      num: json['num'],
      freeDrawAt: json['freeDrawAt'],
      status: json['status'],
      createdAt: json['createdAt'],
    );

UserEventMission _$UserEventMissionFromJson(Map json) => UserEventMission(
      userId: json['userId'],
      missionId: json['missionId'],
      missionTargetId: json['missionTargetId'],
      missionProgressType: json['missionProgressType'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserShop _$UserShopFromJson(Map json) => UserShop(
      shopId: json['shopId'],
      num: json['num'],
      flag: json['flag'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );

UserQuest _$UserQuestFromJson(Map json) => UserQuest(
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
      mainSupportDeckIds: (json['mainSupportDeckIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      eventSupportDeckIds: (json['eventSupportDeckIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
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
