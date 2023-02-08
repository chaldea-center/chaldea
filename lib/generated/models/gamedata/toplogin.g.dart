// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/toplogin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FateTopLogin _$FateTopLoginFromJson(Map json) => FateTopLogin(
      response: (json['response'] as List<dynamic>?)
              ?.map((e) =>
                  _ResponseDetail.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      cache: json['cache'] == null
          ? null
          : UserMstCache.fromJson(
              Map<String, dynamic>.from(json['cache'] as Map)),
      sign: json['sign'] as String?,
    );

_ResponseDetail _$ResponseDetailFromJson(Map json) => _ResponseDetail(
      resCode: json['resCode'] as String?,
      success: json['success'] as Map?,
      fail: json['fail'] as Map?,
      nid: json['nid'] as String?,
    );

UserMstCache _$UserMstCacheFromJson(Map json) => UserMstCache(
      replaced: json['replaced'] == null
          ? null
          : UserMstData.fromJson(
              Map<String, dynamic>.from(json['replaced'] as Map)),
      updated: json['updated'] == null
          ? null
          : UserMstData.fromJson(
              Map<String, dynamic>.from(json['updated'] as Map)),
      serverTime: json['serverTime'] as int?,
    );

UserMstData _$UserMstDataFromJson(Map json) => UserMstData(
      userGame: (json['userGame'] as List<dynamic>?)
          ?.map((e) => UserGame.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCollection: (json['userSvtCollection'] as List<dynamic>?)
          ?.map((e) =>
              UserSvtCollection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvt: (json['userSvt'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtStorage: (json['userSvtStorage'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtAppendPassiveSkill:
          (json['userSvtAppendPassiveSkill'] as List<dynamic>?)
              ?.map((e) => UserSvtAppendPassiveSkill.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
      userSvtAppendPassiveSkillLv:
          (json['userSvtAppendPassiveSkillLv'] as List<dynamic>?)
              ?.map((e) => UserSvtAppendPassiveSkillLv.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
      userCommandCodeCollection:
          (json['userCommandCodeCollection'] as List<dynamic>?)
              ?.map((e) => UserCommandCodeCollection.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
      userCommandCode: (json['userCommandCode'] as List<dynamic>?)
          ?.map((e) =>
              UserCommandCode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCommandCode: (json['userSvtCommandCode'] as List<dynamic>?)
          ?.map((e) =>
              UserSvtCommandCode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userItem: (json['userItem'] as List<dynamic>?)
          ?.map((e) => UserItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCoin: (json['userSvtCoin'] as List<dynamic>?)
          ?.map(
              (e) => UserSvtCoin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userEquip: (json['userEquip'] as List<dynamic>?)
          ?.map((e) => UserEquip.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSupportDeck: (json['userSupportDeck'] as List<dynamic>?)
          ?.map((e) =>
              UserSupportDeck.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtLeader: (json['userSvtLeader'] as List<dynamic>?)
          ?.map((e) =>
              UserSvtLeader.fromJson(Map<String, dynamic>.from(e as Map)))
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
      hp: json['hp'] as int,
      atk: json['atk'] as int,
    );

UserSvtCollection _$UserSvtCollectionFromJson(Map json) => UserSvtCollection(
      svtId: json['svtId'],
      status: json['status'],
      friendship: json['friendship'],
      friendshipRank: json['friendshipRank'],
      friendshipExceedCount: json['friendshipExceedCount'],
      costumeIds:
          (json['costumeIds'] as List<dynamic>).map((e) => e as int).toList(),
    );

UserGame _$UserGameFromJson(Map json) => UserGame(
      id: json['id'],
      userId: json['userId'],
      appname: json['appname'] as String?,
      name: json['name'] as String,
      birthDay: json['birthDay'],
      actMax: json['actMax'],
      genderType: json['genderType'],
      lv: json['lv'],
      exp: json['exp'],
      qp: json['qp'],
      costMax: json['costMax'],
      friendCode: json['friendCode'] as String,
      freeStone: json['freeStone'],
      chargeStone: json['chargeStone'],
      mana: json['mana'],
      rarePri: json['rarePri'],
      createdAt: json['createdAt'],
      message: json['message'] as String,
      stone: json['stone'] as int,
    );

UserSvtAppendPassiveSkill _$UserSvtAppendPassiveSkillFromJson(Map json) =>
    UserSvtAppendPassiveSkill(
      unlockNums:
          (json['unlockNums'] as List<dynamic>?)?.map((e) => e as int).toList(),
      svtId: json['svtId'],
    );

UserSvtCoin _$UserSvtCoinFromJson(Map json) => UserSvtCoin(
      svtId: json['svtId'],
      num: json['num'],
    );

UserSvtAppendPassiveSkillLv _$UserSvtAppendPassiveSkillLvFromJson(Map json) =>
    UserSvtAppendPassiveSkillLv(
      userSvtId: json['userSvtId'],
      appendPassiveSkillNums: (json['appendPassiveSkillNums'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      appendPassiveSkillLvs: (json['appendPassiveSkillLvs'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

UserEquip _$UserEquipFromJson(Map json) => UserEquip(
      id: json['id'],
      equipId: json['equipId'],
      lv: json['lv'],
      exp: json['exp'],
    );

UserCommandCodeCollection _$UserCommandCodeCollectionFromJson(Map json) =>
    UserCommandCodeCollection(
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
          : SvtLeaderEquipTargetInfo.fromJson(
              Map<String, dynamic>.from(json['equipTarget1'] as Map)),
      commandCode: (json['commandCode'] as List<dynamic>?)
          ?.map((e) => SvtLeaderCommandCodeStatus.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      commandCardParam: json['commandCardParam'],
      imageLimitCount: json['imageLimitCount'],
      commandCardLimitCount: json['commandCardLimitCount'],
      iconLimitCount: json['iconLimitCount'],
      portraitLimitCount: json['portraitLimitCount'],
      battleVoice: json['battleVoice'],
      appendPassiveSkill: (json['appendPassiveSkill'] as List<dynamic>?)
          ?.map((e) => SvtLeaderAppendSkillStatus.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

SvtLeaderEquipTargetInfo _$SvtLeaderEquipTargetInfoFromJson(Map json) =>
    SvtLeaderEquipTargetInfo(
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
    );

SvtLeaderAppendSkillStatus _$SvtLeaderAppendSkillStatusFromJson(Map json) =>
    SvtLeaderAppendSkillStatus(
      skillId: json['skillId'],
      skillLv: json['skillLv'],
    );

SvtLeaderCommandCodeStatus _$SvtLeaderCommandCodeStatusFromJson(Map json) =>
    SvtLeaderCommandCodeStatus(
      idx: json['idx'],
      commandCodeId: json['commandCodeId'],
      userCommandCodeId: json['userCommandCodeId'],
    );
