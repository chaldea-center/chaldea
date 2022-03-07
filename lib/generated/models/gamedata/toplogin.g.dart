// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/toplogin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiliTopLogin _$BiliTopLoginFromJson(Map json) => BiliTopLogin(
      response: json['response'],
      cache: json['cache'] == null
          ? null
          : BiliCache.fromJson(Map<String, dynamic>.from(json['cache'] as Map)),
      sign: json['sign'] as String?,
    );

BiliCache _$BiliCacheFromJson(Map json) => BiliCache(
      replaced: json['replaced'] == null
          ? null
          : BiliReplaced.fromJson(
              Map<String, dynamic>.from(json['replaced'] as Map)),
      updated: json['updated'] == null
          ? null
          : BiliUpdated.fromJson(
              Map<String, dynamic>.from(json['updated'] as Map)),
      serverTime: json['serverTime'] as int?,
    );

BiliUpdated _$BiliUpdatedFromJson(Map json) => BiliUpdated();

BiliReplaced _$BiliReplacedFromJson(Map json) => BiliReplaced(
      userItem: (json['userItem'] as List<dynamic>?)
          ?.map((e) => UserItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvt: (json['userSvt'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtStorage: (json['userSvtStorage'] as List<dynamic>?)
          ?.map((e) => UserSvt.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtCollection: (json['userSvtCollection'] as List<dynamic>?)
          ?.map((e) =>
              UserSvtCollection.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userGame: (json['userGame'] as List<dynamic>?)
          ?.map((e) => UserGame.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtAppendPassiveSkill:
          (json['userSvtAppendPassiveSkill'] as List<dynamic>?)
              ?.map((e) => UserSvtAppendPassiveSkill.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList(),
      userSvtCoin: (json['userSvtCoin'] as List<dynamic>?)
          ?.map(
              (e) => UserSvtCoin.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      userSvtAppendPassiveSkillLv:
          (json['userSvtAppendPassiveSkillLv'] as List<dynamic>?)
              ?.map((e) => UserSvtAppendPassiveSkillLv.fromJson(
                  Map<String, dynamic>.from(e as Map)))
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
