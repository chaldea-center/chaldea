import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';

part '../../generated/models/gamedata/toplogin.g.dart';

// ignore: unused_element
int _toInt(dynamic v, [int? k]) {
  if (v is int) {
    return v;
  } else if (v is String) {
    return k == null ? int.parse(v) : int.tryParse(v) ?? k;
  } else if (v is double) {
    return v.toInt();
  } else {
    throw TypeError();
  }
}

int? _toIntNull(dynamic v, [int? k]) {
  if (v == null) return k;
  return _toInt(v, k);
}

@JsonSerializable(createToJson: false)
class BiliTopLogin {
  dynamic response;
  BiliCache cache;
  String sign;

  BiliReplaced get body => cache.replaced;

  BiliTopLogin({this.response, BiliCache? cache, String? sign})
      : cache = cache ?? BiliCache(),
        sign = sign ?? '';

  factory BiliTopLogin.fromJson(Map<String, dynamic> data) =>
      _$BiliTopLoginFromJson(data);

  /// base64 maybe url-encoded
  static BiliTopLogin tryBase64(String encoded) {
    encoded = encoded.trim();
    // eyJy
    if (encoded.startsWith('ey')) {
      encoded = utf8.decode(base64Decode(Uri.decodeFull(encoded).trim()));
    }
    return BiliTopLogin.fromJson(jsonDecode(encoded));
  }
}

@JsonSerializable(createToJson: false)
class BiliCache {
  // deleted: {} // mostly empty
  BiliReplaced replaced;
  BiliUpdated updated;
  DateTime? serverTime;

  BiliCache({BiliReplaced? replaced, BiliUpdated? updated, int? serverTime})
      : replaced = replaced ?? BiliReplaced(),
        updated = updated ?? BiliUpdated(),
        serverTime = serverTime == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(serverTime * 1000);

  factory BiliCache.fromJson(Map<String, dynamic> data) {
    (data['replaced'] as Map)
        .addAll(Map<String, dynamic>.from(data['updated'] ?? {}));
    return _$BiliCacheFromJson(data);
  }
}

@JsonSerializable(createToJson: false)
class BiliUpdated {
  BiliUpdated();

  factory BiliUpdated.fromJson(Map<String, dynamic> data) =>
      _$BiliUpdatedFromJson(data);
}

@JsonSerializable(createToJson: false)
class BiliReplaced {
  List<UserItem> userItem;

  /// svt: including servant and craft essence
  List<UserSvt> userSvt;
  List<UserSvt> userSvtStorage;
  List<UserSvtCollection> userSvtCollection;
  List<UserGame> userGame;
  List<UserSvtAppendPassiveSkill> userSvtAppendPassiveSkill;
  List<UserSvtCoin> userSvtCoin;
  List<UserSvtAppendPassiveSkillLv> userSvtAppendPassiveSkillLv;

  // transformed
  @JsonKey(ignore: true)
  Map<int, UserSvtCoin> coinMap = {};

  @JsonKey(ignore: true)
  Map<int, UserSvtAppendPassiveSkill> appendSkillMap = {};
  @JsonKey(ignore: true)
  Map<int, UserSvtAppendPassiveSkillLv> appendSkillLvMap = {};

  BiliReplaced({
    List<UserItem>? userItem,
    List<UserSvt>? userSvt,
    List<UserSvt>? userSvtStorage,
    List<UserSvtCollection>? userSvtCollection,
    List<UserGame>? userGame,
    List<UserSvtAppendPassiveSkill>? userSvtAppendPassiveSkill,
    List<UserSvtCoin>? userSvtCoin,
    List<UserSvtAppendPassiveSkillLv>? userSvtAppendPassiveSkillLv,
  })  : userItem = userItem ?? [],
        userSvt = userSvt ?? [],
        userSvtStorage = userSvtStorage ?? [],
        userSvtCollection = userSvtCollection ?? [],
        userGame = userGame ?? [],
        userSvtAppendPassiveSkill = userSvtAppendPassiveSkill ?? [],
        userSvtCoin = userSvtCoin ?? [],
        userSvtAppendPassiveSkillLv = userSvtAppendPassiveSkillLv ?? [] {
    for (final e in this.userSvtCoin) {
      coinMap[e.svtId] = e;
    }
    for (final e in this.userSvtAppendPassiveSkill) {
      appendSkillMap[e.svtId] = e;
    }
    for (final e in this.userSvtAppendPassiveSkillLv) {
      appendSkillLvMap[e.userSvtId] = e;
    }
  }

  UserGame? get firstUser => userGame.getOrNull(0);

  List<int> getSvtAppendSkillLv(UserSvt svt) {
    final Map<int, int> lvs = Map.fromIterable(
        appendSkillMap[svt.svtId]?.unlockNums ?? <int>[],
        value: (_) => 1);
    final appendLv = appendSkillLvMap[svt.id];
    if (appendLv != null) {
      lvs.addAll(Map.fromIterables(
          appendLv.appendPassiveSkillNums, appendLv.appendPassiveSkillLvs));
    }
    return List.generate(3, (index) => lvs[100 + index] ?? 0);
  }

  factory BiliReplaced.fromJson(Map<String, dynamic> data) =>
      _$BiliReplacedFromJson(data);
}

// Example:
// "userId": "100114639326",
// "itemId": "16",
// "num": "2650",
// "updatedAt": "1504378320",
// "createdAt": "1504378320"
@JsonSerializable(createToJson: false)
class UserItem {
  int itemId;
  int num;

  /// custom defined

  /// name in dataset, not in api response
  // @JsonKey(ignore: true)
  // String? indexKey;

  UserItem({
    required dynamic itemId,
    required dynamic num,
  })  : itemId = _toInt(itemId),
        num = _toInt(num);

  factory UserItem.fromJson(Map<String, dynamic> data) =>
      _$UserItemFromJson(data);
}

// Example:
// "id": "389441277",
// "userId": "100114639326",
// "svtId": "100300",
// "limitCount": "4",
// "dispLimitCount": 3,
// "lv": "80",
// "exp": "8532000",
// "adjustHp": "0",
// "adjustAtk": "0",
// "status": "0",
// "condVal": "0",
// "skillLv1": "1",
// "skillLv2": "1",
// "skillLv3": "1",
// "treasureDeviceLv1": "5",
// "treasureDeviceLv2": "1",
// "treasureDeviceLv3": "1",
// "exceedCount": "0",
// "selectTreasureDeviceIdx": "0",
// "equipTargetId1": "0",
// "displayInfo": "{\"img\":4,\"disp\":3,\"cmd\":3,\"icon\":4,\"ptr\":3}",
// "createdAt": "1555501785",
// "updatedAt": "1555501785",
// "isLock": "1",
// "imageLimitCount": 4,
// "commandCardLimitCount": 3,
// "iconLimitCount": 4,
// "portraitLimitCount": 3,
// "battleVoice": 0,
// "randomLimitCount": 0,
// "randomLimitCountSupport": 0,
// "limitCountSupport": 0,
// "hp": 10623,
// "atk": 7726
@JsonSerializable(createToJson: false)
class UserSvt {
  int id; // unique id for every card
  int svtId;

  // 0-unlock, 1-locked, 2-?
  // 17-party member, -127-Mash
  int? status;
  int limitCount; // ascension
  // int dispLimitCount;
  int lv;
  int exp;
  int adjustHp; // adjustHp*10=FUFU
  int adjustAtk;
  int skillLv1;
  int skillLv2;
  int skillLv3;
  int treasureDeviceLv1;

  // int treasureDeviceLv2;
  // int treasureDeviceLv3;
  int exceedCount; // grail
  DateTime createdAt;
  DateTime? updatedAt;
  // @protected
  int? isLock; //cn only
  int hp;
  int atk;

  /// custom defined

  /// index key=collection id, in dataset
  // @JsonKey(ignore: true)
  // int? indexKey;
  @JsonKey(ignore: true)
  bool inStorage = false;
  @JsonKey(ignore: true)
  List<int>? appendLvs;

  bool get locked {
    if (isLock != null) {
      return isLock == 1;
    } else {
      return status != 0;
    }
  }

  UserSvt({
    required dynamic id,
    required dynamic svtId,
    required dynamic status,
    required dynamic limitCount, // ascension
    required dynamic lv,
    required dynamic exp,
    required dynamic adjustHp,
    required dynamic adjustAtk,
    required dynamic skillLv1,
    required dynamic skillLv2,
    required dynamic skillLv3,
    required dynamic treasureDeviceLv1,
    required dynamic exceedCount,
    required dynamic createdAt,
    required dynamic updatedAt,
    required dynamic isLock,
    required this.hp,
    required this.atk,
  })  : assert(status != null || isLock != null),
        id = _toInt(id),
        svtId = _toInt(svtId),
        status = _toInt(status),
        limitCount = _toInt(limitCount),
        lv = _toInt(lv),
        exp = _toInt(exp),
        adjustHp = _toInt(adjustHp),
        adjustAtk = _toInt(adjustAtk),
        skillLv1 = _toInt(skillLv1),
        skillLv2 = _toInt(skillLv2),
        skillLv3 = _toInt(skillLv3),
        treasureDeviceLv1 = _toInt(treasureDeviceLv1),
        exceedCount = _toInt(exceedCount),
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(_toInt(createdAt) * 1000),
        updatedAt = updatedAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(_toInt(updatedAt) * 1000),
        isLock = _toIntNull(isLock);

  factory UserSvt.fromJson(Map<String, dynamic> data) =>
      _$UserSvtFromJson(data);
}

//  {
//             "userId": "100106535477",
//             "svtId": "103200",
//             "status": "1",
//             "maxLv": "0",
//             "maxHp": "0",
//             "maxAtk": "0",
//             "maxLimitCount": "0",
//             "skillLv1": "1",
//             "skillLv2": "1",
//             "skillLv3": "1",
//             "treasureDeviceLv1": "1",
//             "treasureDeviceLv2": "1",
//             "treasureDeviceLv3": "1",
//             "svtCommonFlag": "0",
//             "flag": "0",
//             "friendship": "0",
//             "friendshipRank": "0",
//             "friendshipExceedCount": "0",
//             "voicePlayed": "0",
//             "voicePlayed2": "0",
//             "tdPlayed": [],
//             "getNum": "0",
//             "costumeIds": [],
//             "updatedAt": "1568449630",
//             "createdAt": "1568449630"
//         },
@JsonSerializable(createToJson: false)
class UserSvtCollection {
  int svtId;

  /// 1-已遭遇, 2-已契约
  int status;
  int friendship;
  int friendshipRank;
  int friendshipExceedCount;

  /// costume: x start from 11, -x when unlock.
  /// maybe out of order, need to sort when parsing
  /// include mash's story costume.
  List<int> costumeIds;

  // List<int> releasedCostumeIds; // jp only now

  UserSvtCollection({
    required dynamic svtId,
    required dynamic status,
    required dynamic friendship,
    required dynamic friendshipRank,
    required dynamic friendshipExceedCount,
    required List<int> costumeIds,
    // required List<int> releasedCostumeIds,
  })  : svtId = _toInt(svtId),
        status = _toInt(status),
        friendship = _toInt(friendship),
        friendshipRank = _toInt(friendshipRank),
        friendshipExceedCount = _toInt(friendshipExceedCount),
        costumeIds = costumeIds..sort((a, b) => a.abs() - b.abs());

  bool get isOwned => status == 2;

  Map<int, int> costumeIdsTo01() {
    Map<int, int> result = {};
    for (final costumeId in costumeIds) {
      final costume = db.gameData.servantsById[svtId]?.profile.costume.values
          .firstWhereOrNull((e) => e.id == costumeId);
      if (costume != null) {
        result[costume.battleCharaId] = 1;
      }
    }
    return result;
  }

  factory UserSvtCollection.fromJson(Map<String, dynamic> data) =>
      _$UserSvtCollectionFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserGame {
  int? id; //cn only
  int userId;

  // String usk;
  String? appname; // username of bili account
  String name;
  DateTime? birthDay;
  int actMax;
  int genderType;
  int lv;
  int exp;
  int qp;
  int costMax;
  String friendCode;

  // int favoriteUserSvtId;
  int freeStone;
  int chargeStone;
  int mana;
  int rarePri;

  // DateTime zerotime;
  DateTime createdAt;
  String message;
  int stone;

  UserGame({
    required dynamic id,
    required dynamic userId,
    required this.appname,
    required this.name,
    required dynamic birthDay,
    required dynamic actMax,
    required dynamic genderType,
    required dynamic lv,
    required dynamic exp,
    required dynamic qp,
    required dynamic costMax,
    required this.friendCode,
    required dynamic freeStone,
    required dynamic chargeStone,
    required dynamic mana,
    required dynamic rarePri,
    required dynamic createdAt,
    required this.message,
    required this.stone,
  })  : id = _toIntNull(id),
        userId = _toInt(userId),
        birthDay = birthDay == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(_toInt(birthDay) * 1000),
        actMax = _toInt(actMax),
        genderType = _toInt(genderType),
        lv = _toInt(lv),
        exp = _toInt(exp),
        qp = _toInt(qp),
        costMax = _toInt(costMax),
        freeStone = _toInt(freeStone),
        chargeStone = _toInt(chargeStone),
        mana = _toInt(mana),
        rarePri = _toInt(rarePri),
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(_toInt(createdAt) * 1000);

  factory UserGame.fromJson(Map<String, dynamic> data) =>
      _$UserGameFromJson(data);
}

// {
//   "unlockNums": [
//       100,
//       101,
//       102
//   ],
//   "userId": xxxxx,
//   "svtId": 100100
// },
@JsonSerializable(createToJson: false)
class UserSvtAppendPassiveSkill {
  List<int> unlockNums;
  int svtId;

  UserSvtAppendPassiveSkill({
    List<int>? unlockNums,
    dynamic svtId,
  })  : unlockNums = unlockNums ?? [],
        svtId = _toInt(svtId);

  factory UserSvtAppendPassiveSkill.fromJson(Map<String, dynamic> data) =>
      _$UserSvtAppendPassiveSkillFromJson(data);
}

// {
//   "userId": xxxxx,
//   "svtId": 100100,
//   "num": 50,
//   "updatedAt": 1629921881,
//   "createdAt": 1627812677
// }
@JsonSerializable(createToJson: false)
class UserSvtCoin {
  int svtId;
  int num;

  UserSvtCoin({
    dynamic svtId,
    dynamic num,
  })  : svtId = _toInt(svtId),
        num = _toInt(num);

  factory UserSvtCoin.fromJson(Map<String, dynamic> data) =>
      _$UserSvtCoinFromJson(data);
}

// unlock order, only contains svts has unlocked append skill
// {
//   "appendPassiveSkillNums": [
//       101,
//       102,
//       100
//   ],
//   "appendPassiveSkillLvs": [
//       8,
//       7,
//       7
//   ],
//   "userSvtId": 75957046446,
//   "userId": 8634742
// },
@JsonSerializable(createToJson: false)
class UserSvtAppendPassiveSkillLv {
  int userSvtId;
  List<int> appendPassiveSkillNums;
  List<int> appendPassiveSkillLvs;

  UserSvtAppendPassiveSkillLv({
    dynamic userSvtId,
    required this.appendPassiveSkillNums,
    required this.appendPassiveSkillLvs,
  }) : userSvtId = _toInt(userSvtId);

  // List<int> toLvs() {
  //   final lvs =
  //       Map.fromIterables(appendPassiveSkillNums, appendPassiveSkillLvs);
  //   return [
  //     lvs[100] ?? 0,
  //     lvs[101] ?? 0,
  //     lvs[102] ?? 0,
  //   ];
  // }

  factory UserSvtAppendPassiveSkillLv.fromJson(Map<String, dynamic> data) =>
      _$UserSvtAppendPassiveSkillLvFromJson(data);
}
