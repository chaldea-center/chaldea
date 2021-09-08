part of datatypes;

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
  static BiliTopLogin fromBase64(String encoded) {
    String body = Uri.decodeFull(encoded).trim();
    return BiliTopLogin.fromJson(jsonDecode(utf8.decode(base64Decode(body))));
  }
}

@JsonSerializable(createToJson: false)
class BiliCache {
  BiliReplaced replaced;
  BiliUpdated updated;
  DateTime? serverTime;

  BiliCache({BiliReplaced? replaced, BiliUpdated? updated, int? serverTime})
      : replaced = replaced ?? BiliReplaced(),
        updated = updated ?? BiliUpdated(),
        serverTime = serverTime == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(serverTime * 1000);

  factory BiliCache.fromJson(Map<String, dynamic> data) =>
      _$BiliCacheFromJson(data);
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

  BiliReplaced({
    List<UserItem>? userItem,
    List<UserSvt>? userSvt,
    List<UserSvt>? userSvtStorage,
    List<UserSvtCollection>? userSvtCollection,
    List<UserGame>? userGame,
  })  : userItem = userItem ?? [],
        userSvt = userSvt ?? [],
        userSvtStorage = userSvtStorage ?? [],
        userSvtCollection = userSvtCollection ?? [],
        userGame = userGame ?? [];

  UserGame? get firstUser => userGame.getOrNull(0);

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
  @JsonKey(ignore: true)
  String? indexKey;

  UserItem({required String itemId, required String num})
      : itemId = int.parse(itemId),
        num = int.tryParse(num) ?? 0;

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
  DateTime updatedAt;
  bool isLock;
  int hp;
  int atk;

  /// custom defined

  /// index key=collection id, in dataset
  @JsonKey(ignore: true)
  int? indexKey;
  @JsonKey(ignore: true)
  bool inStorage = false;

  UserSvt({
    required String id,
    required String svtId,
    required String limitCount, // ascension
    required String lv,
    required String exp,
    required String adjustHp,
    required String adjustAtk,
    required String skillLv1,
    required String skillLv2,
    required String skillLv3,
    required String treasureDeviceLv1,
    required String exceedCount,
    required String createdAt,
    required String updatedAt,
    required String isLock,
    required this.hp,
    required this.atk,
  })  : id = int.parse(id),
        svtId = int.parse(svtId),
        limitCount = int.parse(limitCount),
        lv = int.parse(lv),
        exp = int.parse(exp),
        adjustHp = int.parse(adjustHp),
        adjustAtk = int.parse(adjustAtk),
        skillLv1 = int.parse(skillLv1),
        skillLv2 = int.parse(skillLv2),
        skillLv3 = int.parse(skillLv3),
        treasureDeviceLv1 = int.parse(treasureDeviceLv1),
        exceedCount = int.parse(exceedCount),
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt) * 1000),
        updatedAt =
            DateTime.fromMillisecondsSinceEpoch(int.parse(updatedAt) * 1000),
        isLock = isLock == '1';

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

  UserSvtCollection({
    required String svtId,
    required String status,
    required String friendship,
    required String friendshipRank,
    required String friendshipExceedCount,
    required List<int> costumeIds,
  })  : svtId = int.parse(svtId),
        status = int.parse(status),
        friendship = int.parse(friendship),
        friendshipRank = int.parse(friendshipRank),
        friendshipExceedCount = int.parse(friendshipExceedCount),
        costumeIds = costumeIds..sort((a, b) => a.abs() - b.abs());

  bool get isOwned => status == 2;

  List<int> costumeIdsTo01() {
    final n = MathUtils.max(costumeIds.map((e) => e.abs()));
    final result = <int>[];
    for (int i = 11; i <= n; i++) {
      result.add(costumeIds.contains(i) ? 1 : 0);
    }
    return result;
  }

  factory UserSvtCollection.fromJson(Map<String, dynamic> data) =>
      _$UserSvtCollectionFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserGame {
  int id;
  String userId;

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
  int friendCode;

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
    required String id,
    required this.userId,
    required this.appname,
    required this.name,
    required String? birthDay,
    required String actMax,
    required String genderType,
    required String lv,
    required String exp,
    required String qp,
    required String costMax,
    required String friendCode,
    required String freeStone,
    required String chargeStone,
    required String mana,
    required String rarePri,
    required String createdAt,
    required this.message,
    required this.stone,
  })  : id = int.parse(id),
        birthDay = birthDay == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(int.parse(birthDay) * 1000),
        actMax = int.parse(actMax),
        genderType = int.parse(genderType),
        lv = int.parse(lv),
        exp = int.parse(exp),
        qp = int.parse(qp),
        costMax = int.parse(costMax),
        friendCode = int.parse(friendCode),
        freeStone = int.parse(freeStone),
        chargeStone = int.parse(chargeStone),
        mana = int.parse(mana),
        rarePri = int.parse(rarePri),
        createdAt =
            DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt) * 1000);

  factory UserGame.fromJson(Map<String, dynamic> data) =>
      _$UserGameFromJson(data);
}
