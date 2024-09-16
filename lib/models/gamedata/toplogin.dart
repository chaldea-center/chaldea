import 'dart:convert';
import 'dart:io';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/skill.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import '_helper.dart';
import 'command_code.dart';
import 'common.dart';
import 'item.dart';
import 'servant.dart';

part '../../generated/models/gamedata/toplogin.g.dart';

// ignore: unused_element
int _toInt(dynamic v, [int? k]) {
  if (v == null) {
    if (k != null) return k;
    // assert(() {
    //   throw ArgumentError.notNull('_toInt.v');
    // }());
    return 0;
  }
  if (v is int) {
    return v;
  } else if (v is String) {
    if (k == null) {
      try {
        return int.parse(v);
      } on FormatException catch (e) {
        if (e.message == 'Positive input exceeds the limit of integer') {
          print(e);
          return 0;
        }
        rethrow;
      }
    } else {
      return int.tryParse(v) ?? k;
    }
  } else if (v is double) {
    return v.toInt();
  } else {
    throw ArgumentError('_toInt.v: ${v.runtimeType} $v');
  }
}

int? _toIntNull(dynamic v, [int? k]) {
  if (v == null) return k;
  return _toInt(v, k);
}

List<int> _toIntList(dynamic v, [int? k = 0]) {
  if (v == null) return [];
  if (v is String) {
    if (v.trim().isEmpty) return [];
    v = jsonDecode(v);
  }
  if (v is List) {
    return v.map((e) => _toInt(e, k)).toList();
  }
  throw ArgumentError('${v.runtimeType}: $v cannot be converted to List<int>');
}

// ignore: unused_element
bool _toBool(dynamic v, [bool? k]) {
  if (v == null) {
    if (k != null) return k;
    // assert(() {
    //   throw ArgumentError.notNull('_toBool.v');
    // }());
    return false;
  }
  if (v is bool) {
    return v;
  } else if (v is int) {
    return v != 0;
  } else if (v is String) {
    v = v.toLowerCase();
    if (v == 'true') {
      return true;
    } else if (v == 'false') {
      return false;
    }
    final v2 = int.tryParse(v);
    if (v2 != null) {
      return v2 != 0;
    }
    assert(() {
      throw ArgumentError('_toBool.v: unknown string: ${v.runtimeType} $v');
    }());

    return k ?? false;
  } else {
    throw ArgumentError('_toBool.v: ${v.runtimeType} $v');
  }
}

bool? _toBoolNull(dynamic v, [bool? k]) {
  if (v == null) return k;
  return _toBool(v, k);
}

@JsonSerializable(createToJson: false)
class FateTopLogin {
  @JsonKey(name: 'response')
  List<FateResponseDetail> responses;
  Map<String, dynamic> cache;
  String sign;

  FateTopLogin({this.responses = const [], Map<String, dynamic>? cache, String? sign})
      : cache = cache ?? {},
        sign = sign ?? '' {
    mstData.updateCache(this.cache);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? rawMap;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Region? region;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final mstData = MasterDataManager();

  DateTime? get serverTime => (cache['serverTime'] as int?)?.sec2date();

  FateResponseDetail getResponse(String nid) {
    final result = getResponseNull(nid);
    if (result != null) return result;
    final errors = responses.where((e) => !e.isSuccess()).map((e) => '[${e.nid}] ${e.resCode} ${e.fail}').toList();
    if (errors.isNotEmpty) {
      throw Exception('response nid="$nid" not found, error found:\n${errors.join("\n")}');
    }
    throw Exception('response nid="$nid" not found: ${responses.map((e) => "[${e.nid}] ${e.resCode}").join(" ")}');
  }

  FateResponseDetail? getResponseNull(String nid) {
    for (final resp in responses) {
      if (resp.nid == nid) return resp;
    }
    return null;
  }

  bool isSuccess(String nid) {
    return responses.any((e) => e.nid == nid && e.isSuccess());
  }

  factory FateTopLogin.fromJson(Map<String, dynamic> data) => _$FateTopLoginFromJson(data)..rawMap = Map.of(data);

  factory FateTopLogin.parseAny(dynamic data) => FateTopLogin.fromJson(parseToMap(data));

  static Map<String, dynamic> parseToMap(dynamic data) {
    if (data is Map) {
      return Map.from(data);
    }
    if (data is String) {
      return Map.from(jsonDecode(tryBase64Decode(data)));
    }
    if (data is List<int>) {
      List<int> bytes = data;
      if (ByteFormatDetector.isGzip(bytes)) {
        bytes = gzip.decode(bytes);
      } else if (ByteFormatDetector.isZlib(bytes)) {
        bytes = ZLibCodec(raw: false).decode(bytes);
      } else if (ByteFormatDetector.isJsonMap(bytes) || ByteFormatDetector.isJsonMapBase64(bytes)) {
        // do nothing
      } else {
        try {
          bytes = ZLibCodec(raw: true).decode(bytes);
        } catch (e, s) {
          logger.t('not deflate compressed: ${bytes.take(10).toList()}', e, s);
        }
      }
      return Map.from(jsonDecode(tryBase64Decode(utf8.decode(bytes))));
    }
    throw FormatException('Unsupported format: ${data.runtimeType}');
  }

  static String tryBase64Decode(String content) {
    content = content.trim();
    try {
      // eyJy
      if (content.startsWith('ey')) {
        content = utf8.decode(base64Decode(Uri.decodeFull(content).trim()));
      }
    } catch (e) {
      //
    }
    return content;
  }

  /// base64 maybe url-encoded
  static FateTopLogin fromBase64(String encoded) {
    encoded = tryBase64Decode(encoded);
    final json = Map<String, dynamic>.from(jsonDecode(encoded));
    Region? region;
    try {
      region = guessRegion(json);
    } catch (e) {
      print(e);
    }
    return FateTopLogin.fromJson(json)..region = region;
  }

  // may be deflate, gzip
  static FateTopLogin fromBytes(List<int> bytes) {
    String? contents;
    try {
      contents = utf8.decode(bytes);
    } catch (e) {} // ignore: empty_catches
    if (contents == null) {
      try {
        if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
          contents = utf8.decode(gzip.decode(bytes));
        }
      } catch (e) {} // ignore: empty_catches
    }
    if (contents == null) {
      try {
        contents = utf8.decode(ZLibCodec(raw: true).decode(bytes));
      } catch (e) {} // ignore: empty_catches
    }
    if (contents == null) {
      throw const FormatException("Unknown byte format, gzip or raw deflate or plain utf8");
    }
    return fromBase64(contents);
  }

  static Region? guessRegion(Map? data) {
    if (data == null) return null;
    if ((data['cache']?['replaced'] as Map?)?.containsKey('globalUser') == true) {
      return Region.na;
    }
    final Map? userGame = data['cache']?['replaced']?['userGame']?[0];
    final String? friendCode = userGame?['friendCode']?.toString();
    if (userGame == null) return null;
    if (userGame['rkchannel']?.toString() == '1000') {
      return Region.tw;
    } else if (friendCode != null && friendCode.length >= 12) {
      return Region.cn;
    }
    return Region.jp;
  }
}

@JsonSerializable(createToJson: false)
class FateResponseDetail {
  String? resCode;
  Map? success;
  Map? fail;
  String? nid;
  // CN
  String? usk;
  List<String>? encryptApi;

  bool isSuccess() => resCode == '00' || resCode == '0';

  int? get code => resCode == null ? null : int.tryParse(resCode!);

  FateResponseDetail({
    this.resCode,
    this.success,
    this.fail,
    this.nid,
    this.usk,
    this.encryptApi,
  });

  factory FateResponseDetail.fromJson(Map<String, dynamic> data) => _$FateResponseDetailFromJson(data);
}

final _$mstMasterSchemes = <String, (Type, DataMaster Function(String mstName))>{
  "userGame": (UserGameEntity, (mstName) => DataMaster<int, UserGameEntity>(mstName, UserGameEntity.fromJson)),
  "userLogin": (UserLoginEntity, (mstName) => DataMaster<int, UserLoginEntity>(mstName, UserLoginEntity.fromJson)),
  "userSvtCollection": (
    UserServantCollectionEntity,
    (mstName) => DataMaster<_IntStr, UserServantCollectionEntity>(mstName, UserServantCollectionEntity.fromJson)
  ),
  "userSvtStorage": (
    UserServantEntity,
    (mstName) => DataMaster<int, UserServantEntity>(mstName, UserServantEntity.fromJson)
  ),
  "userSvt": (UserServantEntity, (mstName) => DataMaster<int, UserServantEntity>(mstName, UserServantEntity.fromJson)),
  "userSvtAppendPassiveSkill": (
    UserServantAppendPassiveSkillEntity,
    (mstName) =>
        DataMaster<_IntStr, UserServantAppendPassiveSkillEntity>(mstName, UserServantAppendPassiveSkillEntity.fromJson)
  ),
  "userSvtAppendPassiveSkillLv": (
    UserServantAppendPassiveSkillLvEntity,
    (mstName) =>
        DataMaster<int, UserServantAppendPassiveSkillLvEntity>(mstName, UserServantAppendPassiveSkillLvEntity.fromJson)
  ),
  "userCommandCodeCollection": (
    UserCommandCodeCollectionEntity,
    (mstName) => DataMaster<_IntStr, UserCommandCodeCollectionEntity>(mstName, UserCommandCodeCollectionEntity.fromJson)
  ),
  "userCommandCode": (
    UserCommandCodeEntity,
    (mstName) => DataMaster<int, UserCommandCodeEntity>(mstName, UserCommandCodeEntity.fromJson)
  ),
  "userSvtCommandCode": (
    UserServantCommandCodeEntity,
    (mstName) => DataMaster<_IntStr, UserServantCommandCodeEntity>(mstName, UserServantCommandCodeEntity.fromJson)
  ),
  "userSvtCommandCard": (
    UserServantCommandCardEntity,
    (mstName) => DataMaster<_IntStr, UserServantCommandCardEntity>(mstName, UserServantCommandCardEntity.fromJson)
  ),
  "userItem": (UserItemEntity, (mstName) => DataMaster<_IntStr, UserItemEntity>(mstName, UserItemEntity.fromJson)),
  "userSvtCoin": (
    UserSvtCoinEntity,
    (mstName) => DataMaster<_IntStr, UserSvtCoinEntity>(mstName, UserSvtCoinEntity.fromJson)
  ),
  "userEquip": (UserEquipEntity, (mstName) => DataMaster<int, UserEquipEntity>(mstName, UserEquipEntity.fromJson)),
  "userSupportDeck": (
    UserSupportDeckEntity,
    (mstName) => DataMaster<_IntStr, UserSupportDeckEntity>(mstName, UserSupportDeckEntity.fromJson)
  ),
  "userSvtLeader": (
    UserServantLeaderEntity,
    (mstName) => DataMaster<String, UserServantLeaderEntity>(mstName, UserServantLeaderEntity.fromJson)
  ),
  "userClassBoardSquare": (
    UserClassBoardSquareEntity,
    (mstName) => DataMaster<_IntStr, UserClassBoardSquareEntity>(mstName, UserClassBoardSquareEntity.fromJson)
  ),
  "userPresentBox": (
    UserPresentBoxEntity,
    (mstName) => DataMaster<_IntStr, UserPresentBoxEntity>(mstName, UserPresentBoxEntity.fromJson)
  ),
  "userGacha": (UserGachaEntity, (mstName) => DataMaster<_IntStr, UserGachaEntity>(mstName, UserGachaEntity.fromJson)),
  "userEventMission": (
    UserEventMissionEntity,
    (mstName) => DataMaster<_IntStr, UserEventMissionEntity>(mstName, UserEventMissionEntity.fromJson)
  ),
  "userEventPoint": (
    UserEventPointEntity,
    (mstName) => DataMaster<String, UserEventPointEntity>(mstName, UserEventPointEntity.fromJson)
  ),
  "mstEventRaid": (
    EventRaidEntity,
    (mstName) => DataMaster<String, EventRaidEntity>(mstName, EventRaidEntity.fromJson)
  ),
  "totalEventRaid": (
    TotalEventRaidEntity,
    (mstName) => DataMaster<String, TotalEventRaidEntity>(mstName, TotalEventRaidEntity.fromJson)
  ),
  "userEventRaid": (
    UserEventRaidEntity,
    (mstName) => DataMaster<String, UserEventRaidEntity>(mstName, UserEventRaidEntity.fromJson)
  ),
  "userShop": (UserShopEntity, (mstName) => DataMaster<_IntStr, UserShopEntity>(mstName, UserShopEntity.fromJson)),
  "userQuest": (UserQuestEntity, (mstName) => DataMaster<_IntStr, UserQuestEntity>(mstName, UserQuestEntity.fromJson)),
  "userDeck": (UserDeckEntity, (mstName) => DataMaster<int, UserDeckEntity>(mstName, UserDeckEntity.fromJson)),
  "userEventDeck": (
    UserEventDeckEntity,
    (mstName) => DataMaster<String, UserEventDeckEntity>(mstName, UserEventDeckEntity.fromJson)
  ),
  "userAccountLinkage": (
    UserAccountLinkageEntity,
    (mstName) => DataMaster<int, UserAccountLinkageEntity>(mstName, UserAccountLinkageEntity.fromJson)
  ),
  "battle": (BattleEntity, (mstName) => DataMaster<int, BattleEntity>(mstName, BattleEntity.fromJson)),
  "userFollower": (
    UserFollowerEntity,
    (mstName) => DataMaster<int, UserFollowerEntity>(mstName, UserFollowerEntity.fromJson)
  ),
};

final _$mstMasterSchemesByType = <Type, (String, DataMaster Function(String mstName))>{
  for (final (key, value) in _$mstMasterSchemes.items) value.$1: (key, value.$2),
};

class DataMaster<K, V extends DataEntityBase<K>> with Iterable<V> {
  final String mstName;
  final V Function(Map<String, dynamic>) entityFromJson;

  @protected
  final Map<K, V> lookup = {};

  @override
  Iterator<V> get iterator => lookup.values.iterator;

  V? operator [](Object? key) => lookup[key];

  List<V> get list => lookup.values.toList();

  DataMaster(this.mstName, this.entityFromJson);

  void clear() {
    lookup.clear();
  }

  void _catchError(void Function() callback) {
    try {
      return callback();
    } catch (e, s) {
      logger.e('master scheme parse failed: $mstName $V', e, s);
    }
  }

  void updated(List<Map<String, dynamic>> entities) {
    _catchError(() {
      for (final obj in entities) {
        final entity = entityFromJson(obj);
        lookup[entity.primaryKey] = entity;
      }
    });
  }

  void replaced(List<Map<String, dynamic>> entities) {
    _catchError(() {
      lookup.clear();
      for (final obj in entities) {
        final entity = entityFromJson(obj);
        lookup[entity.primaryKey] = entity;
      }
    });
  }

  void deleted(List<Map<String, dynamic>> entities) {
    _catchError(() {
      for (final obj in entities) {
        final entity = entityFromJson(obj);
        lookup.remove(entity.primaryKey);
      }
    });
  }
}

class MasterDataManager {
  final Map<String, DataMaster> datalist = {};

  DataMaster<K, V> get<K, V extends DataEntityBase<K>>() {
    assert(() {
      if (V == UserServantEntity) {
        throw ArgumentError('userSvt and userSvtStorage both use UserServantEntity');
      }
      return true;
    }());
    if (!_$mstMasterSchemesByType.containsKey(V)) {
      throw UnimplementedError('DataMaster<$K,$V> not implemented');
    }
    final (mstName, ctor) = _$mstMasterSchemesByType[V]!;
    return datalist.putIfAbsent(mstName, () => ctor(mstName)) as DataMaster<K, V>;
  }

  DataMaster<K, V>? getByName<K, V extends DataEntityBase<K>>(String mstName) {
    if (datalist.containsKey(mstName)) return datalist[mstName]! as DataMaster<K, V>;
    if (!_$mstMasterSchemes.containsKey(mstName)) {
      // throw UnimplementedError('DataMaster $mstName not implemented');
      return null;
    }
    final (_, ctor) = _$mstMasterSchemes[mstName]!;
    return datalist.putIfAbsent(mstName, () => ctor(mstName)) as DataMaster<K, V>;
  }

  void updateCache(Map cache) {
    Map _get(String act) => (cache[act] as Map?) ?? {};
    for (final (mstName, list) in _get('deleted').items) {
      getByName(mstName)?.deleted(List.from(list));
    }
    for (final (mstName, list) in _get('updated').items) {
      getByName(mstName)?.updated(List.from(list));
    }
    for (final (mstName, list) in _get('replaced').items) {
      getByName(mstName)?.replaced(List.from(list));
    }
  }

  UserGameEntity? get user => userGame.firstOrNull;

  List<int> getSvtAppendSkillLv(UserServantEntity svt) {
    final Map<int, int> lvs =
        Map.fromIterable(userSvtAppendPassiveSkill[svt.svtId]?.unlockNums ?? <int>[], value: (_) => 1);
    final appendLv = userSvtAppendPassiveSkillLv[svt.id];
    if (appendLv != null) {
      lvs.addAll(Map.fromIterables(appendLv.appendPassiveSkillNums, appendLv.appendPassiveSkillLvs));
    }
    return List.generate(kAppendSkillNums.length, (index) => lvs[100 + index] ?? 0);
  }

  int getItemNum(int itemId, [int _default = 0]) {
    final user = this.user;
    if (itemId == Items.qpId) {
      return user?.qp ?? _default;
    } else if (itemId == Items.stoneId) {
      // stone=free+charge
      return user?.stone ?? _default;
    } else if (itemId == Items.manaPrismId) {
      return user?.mana ?? _default;
    } else if (itemId == Items.rarePrismId) {
      return user?.rarePri ?? _default;
    } else {
      int? count = userItem[itemId]?.num;
      final item = db.gameData.items[itemId];
      if (item != null) {
        if (item.type == ItemType.eventPoint && count == null) {
          return userEventPoint[_createPK2(item.eventId, item.eventGroupId)]?.value ?? _default;
        }
      }
      return count ?? _default;
    }
  }

  // mst schemes

  DataMaster<int, UserGameEntity> get userGame => get<int, UserGameEntity>();
  DataMaster<int, UserLoginEntity> get userLogin => get<int, UserLoginEntity>();
  // svt and ce
  DataMaster<_IntStr, UserServantCollectionEntity> get userSvtCollection => get<_IntStr, UserServantCollectionEntity>();
  DataMaster<int, UserServantEntity> get userSvt => getByName('userSvt')!;
  DataMaster<int, UserServantEntity> get userSvtStorage => getByName('userSvtStorage')!;
  DataMaster<_IntStr, UserServantAppendPassiveSkillEntity> get userSvtAppendPassiveSkill =>
      get<_IntStr, UserServantAppendPassiveSkillEntity>();
  DataMaster<int, UserServantAppendPassiveSkillLvEntity> get userSvtAppendPassiveSkillLv =>
      get<int, UserServantAppendPassiveSkillLvEntity>();
  // cc
  DataMaster<_IntStr, UserCommandCodeCollectionEntity> get userCommandCodeCollection =>
      get<_IntStr, UserCommandCodeCollectionEntity>();
  DataMaster<int, UserCommandCodeEntity> get userCommandCode => get<int, UserCommandCodeEntity>();
  DataMaster<_IntStr, UserServantCommandCodeEntity> get userSvtCommandCode =>
      get<_IntStr, UserServantCommandCodeEntity>();
  DataMaster<_IntStr, UserServantCommandCardEntity> get userSvtCommandCard =>
      get<_IntStr, UserServantCommandCardEntity>();
  // items
  DataMaster<_IntStr, UserItemEntity> get userItem => get<_IntStr, UserItemEntity>();
  DataMaster<_IntStr, UserSvtCoinEntity> get userSvtCoin => get<_IntStr, UserSvtCoinEntity>();
  DataMaster<int, UserEquipEntity> get userEquip => get<int, UserEquipEntity>();
  // support deck
  DataMaster<_IntStr, UserSupportDeckEntity> get userSupportDeck => get<_IntStr, UserSupportDeckEntity>();
  DataMaster<String, UserServantLeaderEntity> get userSvtLeader => get<String, UserServantLeaderEntity>();
  DataMaster<_IntStr, UserClassBoardSquareEntity> get userClassBoardSquare =>
      get<_IntStr, UserClassBoardSquareEntity>();
  DataMaster<_IntStr, UserPresentBoxEntity> get userPresentBox => get<_IntStr, UserPresentBoxEntity>();
  DataMaster<_IntStr, UserGachaEntity> get userGacha => get<_IntStr, UserGachaEntity>();
  DataMaster<_IntStr, UserEventMissionEntity> get userEventMission => get<_IntStr, UserEventMissionEntity>();
  DataMaster<String, UserEventPointEntity> get userEventPoint => get<String, UserEventPointEntity>();
  DataMaster<_IntStr, UserShopEntity> get userShop => get<_IntStr, UserShopEntity>();
  // event/quest
  DataMaster<_IntStr, UserQuestEntity> get userQuest => get<_IntStr, UserQuestEntity>();

  DataMaster<int, UserDeckEntity> get userDeck => get<int, UserDeckEntity>();
  DataMaster<String, UserEventDeckEntity> get userEventDeck => get<String, UserEventDeckEntity>();

  DataMaster<int, BattleEntity> get battles => get<int, BattleEntity>();
  DataMaster<int, UserFollowerEntity> get userFollower => get<int, UserFollowerEntity>();

  // userEventPoint, userGachaExtraCount,
  // userEventSuperBoss, userSvtVoicePlayed, userQuest
  // userEventMissionFix,
  // userPrivilege
  // userEventMissionConditionDetail, userGachaDrawLog,userQuestRoute,userNpcSvtRecord,userCoinRoom
  // userEventRaid
  // // userEvent.tutorial: int may exceed int64
  // userQuestInfo,userEvent,
  // beforeBirthDay

  // account
  DataMaster<int, UserAccountLinkageEntity> get userAccountLinkage => get<int, UserAccountLinkageEntity>();
}

// dw use "userId:key" as primary key, here use int key directly
typedef _IntStr = int;

String _createPK2(Object k1, Object k2) => '$k1:$k2';
// String _createPK3(Object k1, Object k2, Object k3) => '$k1:$k2:$k3';

abstract class DataEntityBase<T> {
  T get primaryKey;
}

@JsonSerializable(createToJson: false)
class UserItemEntity extends DataEntityBase<_IntStr> {
  // int userId;
  int itemId;
  int num;

  @override
  _IntStr get primaryKey => itemId;

  static _IntStr createPK(int itemId) => itemId;

  UserItemEntity({
    required dynamic itemId,
    required dynamic num,
  })  : itemId = _toInt(itemId),
        num = _toInt(num);

  factory UserItemEntity.fromJson(Map<String, dynamic> data) => _$UserItemEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserServantEntity extends DataEntityBase<int> {
  int id; // unique id for every card
  int svtId;

  // 0-unlock, 1-locked
  // 17-party member, -127-Mash
  // public enum UserServantEntity.StatusFlag
  //   LOCK = 1;
  //   EVENT_JOIN = 2;
  //   WITHDRAWAL = 4;
  //   APRIL_FOOL_CANCEL = 8;
  //   CHOICE = 16;
  //   NO_PERIOD = 32;
  //   COND_JOIN = 64;
  //   ADD_FRIENDSHIP_HEROINE = 128;
  int? status;
  int limitCount; // ascension
  int dispLimitCount;
  int imageLimitCount;
  int commandCardLimitCount;
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
  int createdAt;
  int updatedAt;
  // @protected
  int? isLock; //cn only
  int hp;
  int atk;

  /// custom defined

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool inStorage = false;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<int>? appendLvs;

  bool get locked {
    if (isLock != null) {
      return isLock == 1;
    } else {
      return status != null && status! & 1 != 0;
    }
  }

  bool get isWithdraw {
    return status != null && status! & 4 != 0;
  }

  @override
  int get primaryKey => id;

  static int createPK(int id) => id;

  UserServantEntity({
    dynamic id,
    dynamic svtId,
    dynamic status,
    dynamic limitCount, // ascension
    dynamic dispLimitCount,
    dynamic imageLimitCount,
    dynamic commandCardLimitCount,
    dynamic lv,
    dynamic exp,
    dynamic adjustHp,
    dynamic adjustAtk,
    dynamic skillLv1,
    dynamic skillLv2,
    dynamic skillLv3,
    dynamic treasureDeviceLv1,
    dynamic exceedCount,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic isLock,
    dynamic hp,
    dynamic atk,
  })  : id = _toInt(id),
        svtId = _toInt(svtId),
        status = _toInt(status),
        limitCount = _toInt(limitCount),
        dispLimitCount = _toInt(dispLimitCount),
        imageLimitCount = _toInt(imageLimitCount),
        commandCardLimitCount = _toInt(commandCardLimitCount),
        lv = _toInt(lv),
        exp = _toInt(exp),
        adjustHp = _toInt(adjustHp),
        adjustAtk = _toInt(adjustAtk),
        skillLv1 = _toInt(skillLv1),
        skillLv2 = _toInt(skillLv2),
        skillLv3 = _toInt(skillLv3),
        treasureDeviceLv1 = _toInt(treasureDeviceLv1),
        exceedCount = _toInt(exceedCount),
        createdAt = _toInt(createdAt),
        updatedAt = _toInt(updatedAt, 0),
        isLock = _toIntNull(isLock),
        hp = _toInt(hp),
        atk = _toInt(atk);

  factory UserServantEntity.fromJson(Map<String, dynamic> data) => _$UserServantEntityFromJson(data);

  Servant? get dbSvt => db.gameData.servantsById[svtId];
  CraftEssence? get dbCE => db.gameData.craftEssencesById[svtId];
}

@JsonSerializable(createToJson: false)
class UserServantCollectionEntity extends DataEntityBase<_IntStr> {
  int userId;
  int svtId;

  /// 1-已遭遇, 2-已契约
  int status;
  int maxLv;
  int maxHp;
  int maxAtk;
  int maxLimitCount;
  int skillLv1;
  int skillLv2;
  int skillLv3;
  int treasureDeviceLv1; // CN: treasureDeviceLv2~3
  int svtCommonFlag;
  int flag;
  int friendship;
  int friendshipRank;
  int friendshipExceedCount;
  // int voicePlayed; // may exceed int64
  // int voicePlayed2;
  // List<int> tdPlayed;
  int getNum;
  int totalGetNum;

  /// costume: x start from 11, -x when unlock.
  /// maybe out of order, need to sort when parsing
  /// include mash's story costume.
  List<int> costumeIds;
  List<int> releasedCostumeIds; // always positive, reach unlock condition but haven't unlock
  int updatedAt;
  int createdAt;
  // commandCodes: null // deprecated?
  // commandCardParams: null // deprecated?
  // dateTimeOfGachas: null // new in JP
  @override
  _IntStr get primaryKey => svtId;

  static _IntStr createPK(int svtId) => svtId;

  UserServantCollectionEntity({
    dynamic userId,
    dynamic svtId,
    dynamic status,
    dynamic maxLv,
    dynamic maxHp,
    dynamic maxAtk,
    dynamic maxLimitCount,
    dynamic skillLv1,
    dynamic skillLv2,
    dynamic skillLv3,
    dynamic treasureDeviceLv1,
    dynamic svtCommonFlag,
    dynamic flag,
    dynamic friendship,
    dynamic friendshipRank,
    dynamic friendshipExceedCount,
    dynamic getNum,
    dynamic totalGetNum,
    dynamic costumeIds,
    dynamic releasedCostumeIds,
    dynamic updatedAt,
    dynamic createdAt,
    // List<int> releasedCostumeIds,
  })  : userId = _toInt(userId),
        svtId = _toInt(svtId),
        status = _toInt(status),
        maxLv = _toInt(maxLv),
        maxHp = _toInt(maxHp),
        maxAtk = _toInt(maxAtk),
        maxLimitCount = _toInt(maxLimitCount),
        skillLv1 = _toInt(skillLv1),
        skillLv2 = _toInt(skillLv2),
        skillLv3 = _toInt(skillLv3),
        treasureDeviceLv1 = _toInt(treasureDeviceLv1),
        svtCommonFlag = _toInt(svtCommonFlag),
        flag = _toInt(flag),
        friendship = _toInt(friendship),
        friendshipRank = _toInt(friendshipRank),
        friendshipExceedCount = _toInt(friendshipExceedCount),
        getNum = _toInt(getNum, 0),
        totalGetNum = _toInt(totalGetNum, 0),
        costumeIds = _toIntList(costumeIds)..sort((a, b) => a.abs() - b.abs()),
        releasedCostumeIds = _toIntList(releasedCostumeIds)..sort((a, b) => a.abs() - b.abs()),
        updatedAt = _toInt(updatedAt),
        createdAt = _toInt(createdAt);

  bool get isOwned => status == 2;

  Map<int, int> costumeIdsTo01() {
    Map<int, int> result = {};
    for (final costumeId in costumeIds) {
      final costume =
          db.gameData.servantsById[svtId]?.profile.costume.values.firstWhereOrNull((e) => e.id == costumeId);
      if (costume != null) {
        result[costume.battleCharaId] = 1;
      }
    }
    return result;
  }

  factory UserServantCollectionEntity.fromJson(Map<String, dynamic> data) =>
      _$UserServantCollectionEntityFromJson(data);
}

@JsonSerializable(createToJson: true)
class UserGameEntity extends DataEntityBase<int> {
  int userId;
  String name;
  int? birthDay;
  int actMax;
  int actRecoverAt;
  int carryOverActPoint;
  int rpRecoverAt;
  int carryOverRaidPoint;
  int genderType;
  int lv;
  int exp;
  int qp;
  int costMax;
  String friendCode;
  int favoriteUserSvtId;
  int pushUserSvtId;
  int commandSpellRecoverAt;
  int friendKeep;
  int svtKeep;
  int svtEquipKeep;
  int svtStorageAdjust;
  int svtEquipStorageAdjust;
  int freeStone;
  int chargeStone;
  int stone;
  int? grade; // not exist
  int? stoneVerifiAt;
  int mana;
  int rarePri;
  int activeDeckId;
  int mainSupportDeckId;
  int eventSupportDeckId;
  List<int> fixMainSupportDeckIds;
  List<int> fixEventSupportDeckIds;
  int tutorial1;
  int tutorial2;
  String message;
  int flag;
  int updatedAt;
  int createdAt;
  // not in UserGameEntity but exists
  int userEquipId;

  // bilibili only
  int? id;
  // String usk;
  // int? rksdkid;
  // int? rkchannel;  // ios=996,android=24,渠道服=?
  String? appuid; // (int) bilibili uid, may exceed int64 for 渠道服
  String? appname; // bilibili username, not nickname/display name
  // int? friendKeepBase;
  // int? friendKeepAdjust;
  // int? svtKeepBase;
  // int? svtKeepAdjust;
  // int? svtEquipKeepBase;
  // int? svtEquipKeepAdjust;
  int? regtime;

  @override
  int get primaryKey => userId;

  static int createPK(int userId) => userId;

  UserGameEntity({
    dynamic userId,
    this.name = "",
    dynamic birthDay,
    dynamic actMax,
    dynamic actRecoverAt,
    dynamic carryOverActPoint,
    dynamic rpRecoverAt,
    dynamic carryOverRaidPoint,
    dynamic genderType,
    dynamic lv,
    dynamic exp,
    dynamic qp,
    dynamic costMax,
    this.friendCode = "",
    dynamic favoriteUserSvtId,
    dynamic pushUserSvtId,
    dynamic grade,
    dynamic friendKeep,
    dynamic commandSpellRecoverAt,
    dynamic svtKeep,
    dynamic svtEquipKeep,
    dynamic svtStorageAdjust,
    dynamic svtEquipStorageAdjust,
    dynamic freeStone,
    dynamic chargeStone,
    dynamic stone,
    dynamic stoneVerifiAt,
    dynamic mana,
    dynamic rarePri,
    dynamic activeDeckId,
    dynamic mainSupportDeckId,
    dynamic eventSupportDeckId,
    dynamic fixMainSupportDeckIds,
    dynamic fixEventSupportDeckIds,
    dynamic tutorial1,
    dynamic tutorial2,
    this.message = "",
    dynamic flag,
    dynamic updatedAt,
    dynamic createdAt,
    dynamic userEquipId,
    dynamic id,
    dynamic appuid,
    this.appname,
    dynamic regtime,
  })  : userId = _toInt(userId),
        birthDay = _toIntNull(birthDay),
        actMax = _toInt(actMax),
        actRecoverAt = _toInt(actRecoverAt),
        carryOverActPoint = _toInt(carryOverActPoint),
        rpRecoverAt = _toInt(rpRecoverAt),
        carryOverRaidPoint = _toInt(carryOverRaidPoint),
        genderType = _toInt(genderType),
        lv = _toInt(lv),
        exp = _toInt(exp),
        qp = _toInt(qp),
        costMax = _toInt(costMax),
        favoriteUserSvtId = _toInt(favoriteUserSvtId),
        pushUserSvtId = _toInt(pushUserSvtId),
        grade = _toIntNull(grade),
        friendKeep = _toInt(friendKeep),
        commandSpellRecoverAt = _toInt(commandSpellRecoverAt),
        svtKeep = _toInt(svtKeep),
        svtEquipKeep = _toInt(svtEquipKeep),
        svtStorageAdjust = _toInt(svtStorageAdjust),
        svtEquipStorageAdjust = _toInt(svtEquipStorageAdjust),
        freeStone = _toInt(freeStone),
        chargeStone = _toInt(chargeStone),
        stone = _toInt(stone),
        stoneVerifiAt = _toIntNull(stoneVerifiAt),
        mana = _toInt(mana),
        rarePri = _toInt(rarePri),
        activeDeckId = _toInt(activeDeckId),
        mainSupportDeckId = _toInt(mainSupportDeckId),
        eventSupportDeckId = _toInt(eventSupportDeckId),
        fixMainSupportDeckIds = _toIntList(fixMainSupportDeckIds),
        fixEventSupportDeckIds = _toIntList(fixEventSupportDeckIds),
        tutorial1 = _toInt(tutorial1),
        tutorial2 = _toInt(tutorial2),
        flag = _toInt(flag),
        updatedAt = _toInt(updatedAt),
        createdAt = _toInt(createdAt),
        userEquipId = _toInt(userEquipId),
        id = _toIntNull(id),
        appuid = appuid?.toString(),
        regtime = _toIntNull(regtime);

  factory UserGameEntity.fromJson(Map<String, dynamic> data) => _$UserGameEntityFromJson(data);

  Map<String, dynamic> toJson() => _$UserGameEntityToJson(this);

  int calCurAp() {
    return (actMax - (actRecoverAt - DateTime.now().timestamp) / 300).floor().clamp(0, actMax) + carryOverActPoint;
  }
}

@JsonSerializable(createToJson: false)
class UserLoginEntity extends DataEntityBase<int> {
  int userId;
  int seqLoginCount;
  int totalLoginCount;
  int lastLoginAt;

  @override
  int get primaryKey => userId;

  static int createPK(int userId) => userId;

  UserLoginEntity({
    dynamic userId,
    dynamic seqLoginCount,
    dynamic totalLoginCount,
    dynamic lastLoginAt,
  })  : userId = _toInt(userId),
        seqLoginCount = _toInt(seqLoginCount),
        totalLoginCount = _toInt(totalLoginCount),
        lastLoginAt = _toInt(lastLoginAt);

  factory UserLoginEntity.fromJson(Map<String, dynamic> data) => _$UserLoginEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserServantAppendPassiveSkillEntity extends DataEntityBase<_IntStr> {
  int userId;
  List<int> unlockNums;
  int svtId;

  @override
  _IntStr get primaryKey => svtId;

  static _IntStr createPK(int svtId) => svtId;

  UserServantAppendPassiveSkillEntity({
    dynamic userId,
    List<int>? unlockNums,
    dynamic svtId,
  })  : userId = _toInt(userId),
        unlockNums = unlockNums ?? [],
        svtId = _toInt(svtId);

  factory UserServantAppendPassiveSkillEntity.fromJson(Map<String, dynamic> data) =>
      _$UserServantAppendPassiveSkillEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserSvtCoinEntity extends DataEntityBase<_IntStr> {
  int userId;
  int svtId;
  int num;

  @override
  _IntStr get primaryKey => svtId;

  static _IntStr createPK(int svtId) => svtId;

  UserSvtCoinEntity({
    dynamic userId,
    dynamic svtId,
    dynamic num,
  })  : userId = _toInt(userId),
        svtId = _toInt(svtId),
        num = _toInt(num);

  factory UserSvtCoinEntity.fromJson(Map<String, dynamic> data) => _$UserSvtCoinEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserServantAppendPassiveSkillLvEntity extends DataEntityBase<int> {
  int userSvtId;
  List<int> appendPassiveSkillNums;
  List<int> appendPassiveSkillLvs;

  @override
  int get primaryKey => userSvtId;

  static int createPK(int userSvtId) => userSvtId;

  UserServantAppendPassiveSkillLvEntity({
    dynamic userSvtId,
    required this.appendPassiveSkillNums,
    required this.appendPassiveSkillLvs,
  }) : userSvtId = _toInt(userSvtId);

  factory UserServantAppendPassiveSkillLvEntity.fromJson(Map<String, dynamic> data) =>
      _$UserServantAppendPassiveSkillLvEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserEquipEntity extends DataEntityBase<int> {
  int id;
  // int userId;
  int equipId;
  int lv;
  int exp;
  // updatedAt, createdAt

  @override
  int get primaryKey => id;

  static int createPK(int id) => id;

  UserEquipEntity({
    dynamic id,
    dynamic equipId,
    dynamic lv,
    dynamic exp,
  })  : id = _toInt(id),
        equipId = _toInt(equipId),
        lv = _toInt(lv),
        exp = _toInt(exp);

  factory UserEquipEntity.fromJson(Map<String, dynamic> data) => _$UserEquipEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserCommandCodeCollectionEntity extends DataEntityBase<_IntStr> {
  int userId;
  int commandCodeId;
  int status; // 0-find, 2-got
  int getNum;
  // updatedAt, createdAt

  @override
  _IntStr get primaryKey => commandCodeId;

  static _IntStr createPK(int commandCodeId) => commandCodeId;

  UserCommandCodeCollectionEntity({
    dynamic userId,
    dynamic commandCodeId,
    dynamic status,
    dynamic getNum,
  })  : userId = _toInt(userId),
        commandCodeId = _toInt(commandCodeId),
        status = _toInt(status),
        getNum = _toInt(getNum);
  factory UserCommandCodeCollectionEntity.fromJson(Map<String, dynamic> data) =>
      _$UserCommandCodeCollectionEntityFromJson(data);

  CommandCode? get dbCC => db.gameData.commandCodesById[commandCodeId];
}

@JsonSerializable(createToJson: false)
class UserCommandCodeEntity extends DataEntityBase<int> {
  int id;
  // int userId;
  int commandCodeId;
  int status; // StatusFlag.LOCK=1,CHOICE=16
  // createdAt, updatedAt

  @override
  int get primaryKey => id;

  static int createPK(int id) => id;

  UserCommandCodeEntity({
    dynamic id,
    dynamic commandCodeId,
    dynamic status,
    dynamic svtId,
  })  : id = _toInt(id),
        commandCodeId = _toInt(commandCodeId),
        status = _toInt(status);
  factory UserCommandCodeEntity.fromJson(Map<String, dynamic> data) => _$UserCommandCodeEntityFromJson(data);

  CommandCode? get dbCC => db.gameData.commandCodesById[commandCodeId];
}

@JsonSerializable(createToJson: false)
class UserServantCommandCodeEntity extends DataEntityBase<_IntStr> {
  int userId;
  List<int> userCommandCodeIds;
  int svtId;
  // createdAt

  @override
  _IntStr get primaryKey => svtId;

  static _IntStr createPK(int svtId) => svtId;

  UserServantCommandCodeEntity({
    dynamic userId,
    dynamic userCommandCodeIds,
    dynamic svtId,
  })  : userId = _toInt(userId),
        userCommandCodeIds = _toIntList(userCommandCodeIds),
        svtId = _toInt(svtId);
  factory UserServantCommandCodeEntity.fromJson(Map<String, dynamic> data) =>
      _$UserServantCommandCodeEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserServantCommandCardEntity extends DataEntityBase<_IntStr> {
  int userId;
  List<int> commandCardParam;
  int svtId;
  // createdAt

  @override
  _IntStr get primaryKey => svtId;

  static _IntStr createPK(int svtId) => svtId;

  UserServantCommandCardEntity({
    dynamic userId,
    dynamic commandCardParam,
    dynamic svtId,
  })  : userId = _toInt(userId),
        commandCardParam = _toIntList(commandCardParam),
        svtId = _toInt(svtId);
  factory UserServantCommandCardEntity.fromJson(Map<String, dynamic> data) =>
      _$UserServantCommandCardEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserSupportDeckEntity extends DataEntityBase<_IntStr> {
  int userId;
  int supportDeckId;
  String name;
  // createdAt, updatedAt

  @override
  _IntStr get primaryKey => supportDeckId;

  static _IntStr createPK(int supportDeckId) => supportDeckId;

  UserSupportDeckEntity({
    dynamic userId,
    dynamic supportDeckId,
    dynamic name,
  })  : userId = _toInt(userId),
        supportDeckId = _toInt(supportDeckId),
        name = name.toString();
  factory UserSupportDeckEntity.fromJson(Map<String, dynamic> data) => _$UserSupportDeckEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserServantLeaderEntity extends DataEntityBase<String> {
  int userId;
  int supportDeckId;
  int classId;
  int userSvtId;
  int svtId;
  int limitCount;
  int dispLimitCount;
  int lv;
  int exp;
  int hp;
  int atk;
  int adjustHp;
  int adjustAtk;
  int skillId1;
  int skillId2;
  int skillId3;
  int skillLv1;
  int skillLv2;
  int skillLv3;
  List<dynamic> classPassive;
  int treasureDeviceId;
  int treasureDeviceLv;
  int exceedCount;
  SvtLeaderEquipTargetInfo? equipTarget1;
  // Map displayInfo; cn json string
  List<SvtLeaderCommandCodeStatus> commandCode;
  List<int> commandCardParam;
  // int updatedAt;
  // int createdAt; // not in jp
  int imageLimitCount;
  int commandCardLimitCount;
  int iconLimitCount;
  int portraitLimitCount;
  int battleVoice;
  // int randomLimitCountSupport;  //cn
  // List<int?> randomLimitCountTargets; // jp
  List<SvtLeaderAppendSkillStatus> appendPassiveSkill;
  // int eventSvtPoint;
  // Map script;
  // int limitCountSupport;

  @override
  String get primaryKey => _createPK2(classId, supportDeckId);

  static String createPK(int classId, int supportDeckId) => _createPK2(classId, supportDeckId);

  UserServantLeaderEntity({
    dynamic userId,
    dynamic supportDeckId,
    dynamic classId,
    dynamic userSvtId,
    dynamic svtId,
    dynamic limitCount,
    dynamic dispLimitCount,
    dynamic lv,
    dynamic exp,
    dynamic hp,
    dynamic atk,
    dynamic adjustHp,
    dynamic adjustAtk,
    dynamic skillId1,
    dynamic skillId2,
    dynamic skillId3,
    dynamic skillLv1,
    dynamic skillLv2,
    dynamic skillLv3,
    dynamic classPassive,
    dynamic treasureDeviceId,
    dynamic treasureDeviceLv,
    dynamic exceedCount,
    this.equipTarget1,
    // dynamic displayInfo,
    List<SvtLeaderCommandCodeStatus>? commandCode,
    dynamic commandCardParam,
    // dynamic updatedAt,
    // dynamic createdAt,
    dynamic imageLimitCount,
    dynamic commandCardLimitCount,
    dynamic iconLimitCount,
    dynamic portraitLimitCount,
    dynamic battleVoice,
    dynamic randomLimitCountSupport,
    // dynamic limitCountSupport,
    List<SvtLeaderAppendSkillStatus>? appendPassiveSkill,
  })  : userId = _toInt(userId),
        supportDeckId = _toInt(supportDeckId),
        classId = _toInt(classId),
        userSvtId = _toInt(userSvtId),
        svtId = _toInt(svtId),
        limitCount = _toInt(limitCount),
        dispLimitCount = _toInt(dispLimitCount),
        lv = _toInt(lv),
        exp = _toInt(exp),
        hp = _toInt(hp),
        atk = _toInt(atk),
        adjustHp = _toInt(adjustHp),
        adjustAtk = _toInt(adjustAtk),
        skillId1 = _toInt(skillId1),
        skillId2 = _toInt(skillId2),
        skillId3 = _toInt(skillId3),
        skillLv1 = _toInt(skillLv1),
        skillLv2 = _toInt(skillLv2),
        skillLv3 = _toInt(skillLv3),
        classPassive = _toIntList(classPassive),
        treasureDeviceId = _toInt(treasureDeviceId),
        treasureDeviceLv = _toInt(treasureDeviceLv),
        exceedCount = _toInt(exceedCount),
        // displayInfo=jsonDecode(displayInfo??"{}"),
        commandCode = commandCode ?? [],
        commandCardParam = _toIntList(commandCardParam),
        // updatedAt = _toInt(updatedAt),
        // createdAt = _toInt(createdAt),
        imageLimitCount = _toInt(imageLimitCount),
        commandCardLimitCount = _toInt(commandCardLimitCount),
        iconLimitCount = _toInt(iconLimitCount),
        portraitLimitCount = _toInt(portraitLimitCount),
        battleVoice = _toInt(battleVoice),
        // randomLimitCountSupport=_toInt(randomLimitCountSupport),
        // limitCountSupport=_toInt(limitCountSupport);
        appendPassiveSkill = appendPassiveSkill ?? [];

  factory UserServantLeaderEntity.fromJson(Map<String, dynamic> data) => _$UserServantLeaderEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class SvtLeaderEquipTargetInfo {
  // int userId;
  int userSvtId;
  int svtId;
  int limitCount;
  int lv;
  int exp;
  int hp;
  int atk;
  int skillId1;
  int skillLv1;
  int skillId2;
  int skillLv2;
  int skillId3;
  int skillLv3;
  List addSkills; // {int num; int skillId}
  // int updatedAt;
  SvtLeaderEquipTargetInfo({
    dynamic userSvtId,
    dynamic svtId,
    dynamic limitCount,
    dynamic lv,
    dynamic exp,
    dynamic hp,
    dynamic atk,
    dynamic skillId1,
    dynamic skillLv1,
    dynamic skillId2,
    dynamic skillLv2,
    dynamic skillId3,
    dynamic skillLv3,
    List<Map>? addSkills,
    // dynamic updatedAt,
  })  : userSvtId = _toInt(userSvtId),
        svtId = _toInt(svtId),
        limitCount = _toInt(limitCount),
        lv = _toInt(lv),
        exp = _toInt(exp),
        hp = _toInt(hp),
        atk = _toInt(atk),
        skillId1 = _toInt(skillId1),
        skillLv1 = _toInt(skillLv1),
        skillId2 = _toInt(skillId2, 0),
        skillLv2 = _toInt(skillLv2, 0),
        skillId3 = _toInt(skillId3, 0),
        skillLv3 = _toInt(skillLv3, 0),
        addSkills = addSkills ?? [];

  factory SvtLeaderEquipTargetInfo.fromJson(Map<String, dynamic> data) => _$SvtLeaderEquipTargetInfoFromJson(data);
}

@JsonSerializable(createToJson: false)
class SvtLeaderAppendSkillStatus {
  int skillId;
  int skillLv;
  SvtLeaderAppendSkillStatus({
    dynamic skillId,
    dynamic skillLv,
  })  : skillId = _toInt(skillId),
        skillLv = _toInt(skillLv);

  factory SvtLeaderAppendSkillStatus.fromJson(Map<String, dynamic> data) => _$SvtLeaderAppendSkillStatusFromJson(data);
}

@JsonSerializable(createToJson: false)
class SvtLeaderCommandCodeStatus {
  int idx;
  int commandCodeId;
  int userCommandCodeId;

  SvtLeaderCommandCodeStatus({
    dynamic idx,
    dynamic commandCodeId,
    dynamic userCommandCodeId,
  })  : idx = _toInt(idx),
        commandCodeId = _toInt(commandCodeId),
        userCommandCodeId = _toInt(userCommandCodeId);

  factory SvtLeaderCommandCodeStatus.fromJson(Map<String, dynamic> data) => _$SvtLeaderCommandCodeStatusFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserClassBoardSquareEntity extends DataEntityBase<_IntStr> {
  int userId;
  int classBoardBaseId;
  List<int> classBoardSquareIds;
  List<int> classBoardUnlockSquareIds;
  // int updatedAt;
  // int createdAt;

  @override
  _IntStr get primaryKey => classBoardBaseId;

  static _IntStr createPK(int classBoardBaseId) => classBoardBaseId;

  UserClassBoardSquareEntity({
    dynamic userId,
    dynamic classBoardBaseId,
    dynamic classBoardSquareIds,
    dynamic classBoardUnlockSquareIds,
  })  : userId = _toInt(userId),
        classBoardBaseId = _toInt(classBoardBaseId),
        classBoardSquareIds = _toIntList(classBoardSquareIds),
        classBoardUnlockSquareIds = _toIntList(classBoardUnlockSquareIds);

  factory UserClassBoardSquareEntity.fromJson(Map<String, dynamic> data) => _$UserClassBoardSquareEntityFromJson(data);
}

enum UserPresentBoxFlag {
  importantForEvent,
  indefinitePeriod,
  payTypeRarePri,
  importantForLimit,
}

@JsonSerializable(createToJson: false)
class UserPresentBoxEntity extends DataEntityBase<_IntStr> {
  int receiveUserId;
  int presentId;
  int messageRefType;
  int messageId;
  String message;
  int fromType;
  int giftType;
  int objectId;
  int num;
  int limitCount;
  int lv;
  int flag;
  int updatedAt;
  int createdAt;

  List<UserPresentBoxFlag> get flags => [
        for (final v in UserPresentBoxFlag.values)
          if (flag & (1 << (v.index + 1)) != 0) v,
      ];

  @override
  _IntStr get primaryKey => presentId;

  static _IntStr createPK(int presentId) => presentId;

  UserPresentBoxEntity({
    dynamic receiveUserId,
    dynamic presentId,
    dynamic messageRefType,
    dynamic messageId,
    dynamic message,
    dynamic fromType,
    dynamic giftType,
    dynamic objectId,
    dynamic num,
    dynamic limitCount,
    dynamic lv,
    dynamic flag,
    dynamic updatedAt,
    dynamic createdAt,
  })  : receiveUserId = _toInt(receiveUserId),
        presentId = _toInt(presentId),
        messageRefType = _toInt(messageRefType),
        messageId = _toInt(messageId),
        message = message.toString(),
        fromType = _toInt(fromType),
        giftType = _toInt(giftType),
        objectId = _toInt(objectId),
        num = _toInt(num),
        limitCount = _toInt(limitCount),
        lv = _toInt(lv),
        flag = _toInt(flag),
        updatedAt = _toInt(updatedAt),
        createdAt = _toInt(createdAt);
  factory UserPresentBoxEntity.fromJson(Map<String, dynamic> data) => _$UserPresentBoxEntityFromJson(data);
}

enum PresentFromType {
  totalLogin(1),
  seqLogin(2),
  ;

  const PresentFromType(this.value);
  final int value;
}

@JsonSerializable(createToJson: false)
class UserGachaEntity extends DataEntityBase<_IntStr> {
  int userId;
  int gachaId;
  int num;
  int freeDrawAt;
  int status;
  // only in CN (and TW?)
  int? createdAt;

  @override
  _IntStr get primaryKey => gachaId;

  static _IntStr createPK(int gachaId) => gachaId;

  UserGachaEntity({
    dynamic userId,
    dynamic gachaId,
    dynamic num,
    dynamic freeDrawAt,
    dynamic status,
    dynamic createdAt,
  })  : userId = _toInt(userId),
        gachaId = _toInt(gachaId),
        num = _toInt(num),
        freeDrawAt = _toInt(freeDrawAt),
        status = _toInt(status, 0),
        createdAt = _toIntNull(createdAt);
  factory UserGachaEntity.fromJson(Map<String, dynamic> data) => _$UserGachaEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserEventMissionEntity extends DataEntityBase<_IntStr> {
  int userId;
  int missionId;
  int missionTargetId;
  int missionProgressType;
  int updatedAt;
  int createdAt;

  @override
  _IntStr get primaryKey => missionId;

  static _IntStr createPK(int missionId) => missionId;

  UserEventMissionEntity({
    dynamic userId,
    dynamic missionId,
    dynamic missionTargetId,
    dynamic missionProgressType,
    dynamic updatedAt,
    dynamic createdAt,
  })  : userId = _toInt(userId),
        missionId = _toInt(missionId),
        missionTargetId = _toInt(missionTargetId),
        missionProgressType = _toInt(missionProgressType),
        updatedAt = _toInt(updatedAt),
        createdAt = _toInt(createdAt);
  factory UserEventMissionEntity.fromJson(Map<String, dynamic> data) => _$UserEventMissionEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserEventPointEntity extends DataEntityBase<String> {
  int userId;
  int eventId;
  int groupId;
  int value;

  @override
  String get primaryKey => _createPK2(eventId, groupId);

  static String createPK(int eventId, int groupId) => _createPK2(eventId, groupId);

  UserEventPointEntity({
    dynamic userId,
    dynamic eventId,
    dynamic groupId,
    dynamic value,
  })  : userId = _toInt(userId),
        eventId = _toInt(eventId),
        groupId = _toInt(groupId),
        value = _toInt(value);
  factory UserEventPointEntity.fromJson(Map<String, dynamic> data) => _$UserEventPointEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class EventRaidEntity extends DataEntityBase<String> {
  static const int kSubGroupIndexStart = 1;
  int eventId;
  int day;
  int groupIndex;
  int subGroupIndex;
  String name;
  int maxHp; // maxHp is max battle count for most raids
  int iconId;
  int bossColor;
  // int flag;
  int startedAt;
  int endedAt;
  int timeLimitAt;
  List<String> splitAiMode;
  List<int> splitHp;
  // int giftId;
  // int presentMessageId;
  // int loginMessageId；
  // int defeatNormaAt;
  // CN
  // int defeatBaseAt;
  // int correctStartTime;
  // int damageAdjustId;

  @override
  String get primaryKey => _createPK2(eventId, day);

  static String createPK(int eventId, int day) => _createPK2(eventId, day);

  EventRaidEntity({
    dynamic eventId,
    dynamic day,
    dynamic groupIndex,
    dynamic subGroupIndex,
    dynamic name,
    dynamic maxHp,
    dynamic iconId,
    dynamic bossColor,
    dynamic startedAt,
    dynamic endedAt,
    dynamic timeLimitAt,
    dynamic splitAiMode,
    dynamic splitHp,
  })  : eventId = _toInt(eventId),
        day = _toInt(day),
        groupIndex = _toInt(groupIndex),
        subGroupIndex = _toInt(subGroupIndex),
        name = name?.toString() ?? "",
        maxHp = _toInt(maxHp),
        iconId = _toInt(iconId),
        bossColor = _toInt(bossColor),
        startedAt = _toInt(startedAt),
        endedAt = _toInt(endedAt),
        timeLimitAt = _toInt(timeLimitAt),
        splitAiMode = List.from(splitAiMode ?? []),
        splitHp = _toIntList(splitHp);

  factory EventRaidEntity.fromJson(Map<String, dynamic> data) => _$EventRaidEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserEventRaidEntity extends DataEntityBase<String> {
  int userId;
  int eventId;
  int day;
  int damage;

  @override
  String get primaryKey => _createPK2(eventId, day);

  static String createPK(int eventId, int day) => _createPK2(eventId, day);

  UserEventRaidEntity({
    dynamic userId,
    dynamic eventId,
    dynamic day,
    dynamic damage,
  })  : userId = _toInt(userId),
        eventId = _toInt(eventId),
        day = _toInt(day),
        damage = _toInt(damage);
  factory UserEventRaidEntity.fromJson(Map<String, dynamic> data) => _$UserEventRaidEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class TotalEventRaidEntity extends DataEntityBase<String> {
  int eventId;
  int day;
  int totalDamage;
  int defeatedAt;

  @override
  String get primaryKey => _createPK2(eventId, day);

  static String createPK(int eventId, int day) => _createPK2(eventId, day);

  TotalEventRaidEntity({
    dynamic eventId,
    dynamic day,
    dynamic totalDamage,
    dynamic defeatedAt,
  })  : eventId = _toInt(eventId),
        day = _toInt(day),
        totalDamage = _toInt(totalDamage),
        defeatedAt = _toInt(defeatedAt);
  factory TotalEventRaidEntity.fromJson(Map<String, dynamic> data) => _$TotalEventRaidEntityFromJson(data);
}

@JsonSerializable(createToJson: true, createFactory: false)
class BattleRaidResult {
  int uniqueId;
  int day;
  int addDamage;

  BattleRaidResult({
    required this.uniqueId,
    required this.day,
    required this.addDamage,
  });
  // factory BattleRaidResult.fromJson(Map<String, dynamic> data) => _$BattleRaidResultFromJson(data);

  Map<String, dynamic> toJson() => _$BattleRaidResultToJson(this);

  int64_t getStatusLong() {
    return addDamage + day + uniqueId;
  }
}

@JsonSerializable(createToJson: true, createFactory: false)
class BattleSuperBossResult {
  int superBossId;
  int uniqueId;
  int addDamage;

  BattleSuperBossResult({
    required this.superBossId,
    required this.uniqueId,
    required this.addDamage,
  });
  // factory BattleSuperBossResult.fromJson(Map<String, dynamic> data) => _$BattleSuperBossResultFromJson(data);

  Map<String, dynamic> toJson() => _$BattleSuperBossResultToJson(this);

  int64_t getStatusLong() {
    return addDamage + superBossId + uniqueId;
  }
}

@JsonSerializable(createToJson: false)
class UserShopEntity extends DataEntityBase<_IntStr> {
  int userId;
  int shopId;
  int num;
  int flag;
  int updatedAt;
  int createdAt; // jp no createdAt

  @override
  _IntStr get primaryKey => shopId;

  static _IntStr createPK(int shopId) => shopId;

  UserShopEntity({
    dynamic userId,
    dynamic shopId,
    dynamic num,
    dynamic flag,
    dynamic updatedAt,
    dynamic createdAt,
  })  : userId = _toInt(userId),
        shopId = _toInt(shopId),
        num = _toInt(num),
        flag = _toInt(flag),
        updatedAt = _toInt(updatedAt ?? createdAt, 0),
        createdAt = _toInt(createdAt ?? updatedAt, 0);

  factory UserShopEntity.fromJson(Map<String, dynamic> data) => _$UserShopEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserQuestEntity extends DataEntityBase<_IntStr> {
  int userId;
  int questId;
  int questPhase;
  int clearNum;
  bool isEternalOpen;
  int expireAt;
  // int keyExpireAt;  // CN
  // int keyCountRemain;  // CN
  // int isHide; // CN
  int challengeNum;
  bool isNew;
  int lastStartedAt;
  int status;
  int updatedAt;
  int createdAt;

  @override
  _IntStr get primaryKey => questId;

  static _IntStr createPK(int questId) => questId;

  UserQuestEntity({
    dynamic userId,
    dynamic questId,
    dynamic questPhase,
    dynamic clearNum,
    dynamic isEternalOpen,
    dynamic expireAt,
    dynamic challengeNum,
    dynamic isNew,
    dynamic lastStartedAt,
    dynamic status,
    dynamic updatedAt,
    dynamic createdAt,
  })  : userId = _toInt(userId),
        questId = _toInt(questId),
        questPhase = _toInt(questPhase),
        clearNum = _toInt(clearNum),
        isEternalOpen = _toBool(isEternalOpen),
        expireAt = _toInt(expireAt),
        challengeNum = _toInt(challengeNum),
        isNew = _toBool(isNew),
        lastStartedAt = _toInt(lastStartedAt),
        status = _toInt(status),
        updatedAt = _toInt(updatedAt),
        createdAt = _toInt(createdAt);

  factory UserQuestEntity.fromJson(Map<String, dynamic> data) => _$UserQuestEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserFollowerEntity extends DataEntityBase<int> {
  List<FollowerInfo> followerInfo;
  int64_t userId;
  int64_t expireAt;
  // bool isDelete; // CN

  @override
  int get primaryKey => userId;

  static int createPK(int userId) => userId;

  UserFollowerEntity({
    this.followerInfo = const [],
    dynamic userId,
    dynamic expireAt,
  })  : userId = _toInt(userId),
        expireAt = _toInt(expireAt);

  factory UserFollowerEntity.fromJson(Map<String, dynamic> data) => _$UserFollowerEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class FollowerInfo {
  int userId;
  String userName;
  int userLv;
  int type;
  List<ServantLeaderInfo> userSvtLeaderHash;
  List<ServantLeaderInfo> eventUserSvtLeaderHash;
  int tutorial1;
  String message;
  int pushUserSvtId;
  //  int npcFollowerSvtId;
  //  int npcInitIdx;
  //  bool isMySvtOrNpc;
  //  bool isFixedNpc;
  //  int imageSvtId;

  List<int> mainSupportDeckIds;
  List<int> eventSupportDeckIds;
  // List<ClassBoardInfo> userClassBoardInfo;

  FollowerInfo({
    required dynamic userId,
    required dynamic userName,
    required dynamic userLv,
    required dynamic type,
    required List<ServantLeaderInfo>? userSvtLeaderHash,
    required List<ServantLeaderInfo>? eventUserSvtLeaderHash,
    required dynamic tutorial1,
    required dynamic message,
    required dynamic pushUserSvtId,
    required dynamic mainSupportDeckIds,
    required dynamic eventSupportDeckIds,
    // required dynamic userClassBoardInfo,
  })  : userId = _toInt(userId),
        userName = userName.toString(),
        userLv = _toInt(userLv),
        type = _toInt(type),
        tutorial1 = _toInt(tutorial1),
        message = message.toString(),
        pushUserSvtId = _toInt(pushUserSvtId),
        userSvtLeaderHash = userSvtLeaderHash ?? [],
        eventUserSvtLeaderHash = eventUserSvtLeaderHash ?? [],
        mainSupportDeckIds = _toIntList(mainSupportDeckIds),
        eventSupportDeckIds = _toIntList(eventSupportDeckIds);

  factory FollowerInfo.fromJson(Map<String, dynamic> data) => _$FollowerInfoFromJson(data);
}

@JsonSerializable(createToJson: false)
class ServantLeaderInfo {
  int supportDeckId;
  int userId;
  int classId;
  int userSvtId;
  int svtId;
  int limitCount;
  int lv;
  int exp;
  int hp;
  int atk;
  int adjustAtk;
  int adjustHp;
  int skillId1;
  int skillId2;
  int skillId3;
  int skillLv1;
  int skillLv2;
  int skillLv3;
  List<int> classPassive;
  int treasureDeviceId;
  int treasureDeviceLv;
  int exceedCount;
  SvtLeaderEquipTargetInfo? equipTarget1;
  int updatedAt;
  int imageLimitCount;
  int dispLimitCount;
  int commandCardLimitCount;
  int iconLimitCount;
  int portraitLimitCount;
  List<int> randomLimitCountTargets;

  List<Map> commandCode; // {int idx; int commandCodeId; int userCommandCodeId}
  List<int> commandCardParam;
  List<Map> appendPassiveSkill; //{int skillId; int skillLv;}
  int eventSvtPoint;
  // int battleVoice;

  ServantLeaderInfo({
    required dynamic supportDeckId,
    required dynamic userId,
    required dynamic classId,
    required dynamic userSvtId,
    required dynamic svtId,
    required dynamic limitCount,
    required dynamic lv,
    required dynamic exp,
    required dynamic hp,
    required dynamic atk,
    required dynamic adjustAtk,
    required dynamic adjustHp,
    required dynamic skillId1,
    required dynamic skillId2,
    required dynamic skillId3,
    required dynamic skillLv1,
    required dynamic skillLv2,
    required dynamic skillLv3,
    required dynamic classPassive,
    required dynamic treasureDeviceId,
    required dynamic treasureDeviceLv,
    required dynamic exceedCount,
    this.equipTarget1,
    required dynamic updatedAt,
    required dynamic imageLimitCount,
    required dynamic dispLimitCount,
    required dynamic commandCardLimitCount,
    required dynamic iconLimitCount,
    required dynamic portraitLimitCount,
    required dynamic randomLimitCountTargets,
    List<Map>? commandCode,
    required dynamic commandCardParam,
    List<Map>? appendPassiveSkill,
    required dynamic eventSvtPoint,
  })  : supportDeckId = _toInt(supportDeckId),
        userId = _toInt(userId),
        classId = _toInt(classId),
        userSvtId = _toInt(userSvtId),
        svtId = _toInt(svtId),
        limitCount = _toInt(limitCount),
        lv = _toInt(lv),
        exp = _toInt(exp),
        hp = _toInt(hp),
        atk = _toInt(atk),
        adjustAtk = _toInt(adjustAtk),
        adjustHp = _toInt(adjustHp),
        skillId1 = _toInt(skillId1),
        skillId2 = _toInt(skillId2),
        skillId3 = _toInt(skillId3),
        skillLv1 = _toInt(skillLv1),
        skillLv2 = _toInt(skillLv2),
        skillLv3 = _toInt(skillLv3),
        classPassive = _toIntList(classPassive),
        treasureDeviceId = _toInt(treasureDeviceId),
        treasureDeviceLv = _toInt(treasureDeviceLv),
        exceedCount = _toInt(exceedCount),
        updatedAt = _toInt(updatedAt),
        imageLimitCount = _toInt(imageLimitCount),
        dispLimitCount = _toInt(dispLimitCount),
        commandCardLimitCount = _toInt(commandCardLimitCount),
        iconLimitCount = _toInt(iconLimitCount),
        portraitLimitCount = _toInt(portraitLimitCount),
        randomLimitCountTargets = _toIntList(randomLimitCountTargets),
        commandCode = commandCode ?? [],
        commandCardParam = _toIntList(commandCardParam),
        appendPassiveSkill = appendPassiveSkill ?? [],
        eventSvtPoint = _toInt(eventSvtPoint);

  factory ServantLeaderInfo.fromJson(Map<String, dynamic> data) => _$ServantLeaderInfoFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserAccountLinkageEntity extends DataEntityBase<int> {
  int userId;
  int type; // 1-aniplex, 2=0?
  int linkedAt;

  @override
  int get primaryKey => userId;

  static int createPK(int userId) => userId;

  UserAccountLinkageEntity({
    dynamic userId,
    dynamic type,
    dynamic linkedAt,
  })  : userId = _toInt(userId),
        type = _toInt(type),
        linkedAt = _toInt(linkedAt);

  factory UserAccountLinkageEntity.fromJson(Map<String, dynamic> data) => _$UserAccountLinkageEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserDeckEntity extends DataEntityBase<int> {
  int id;
  int userId;
  int deckNo;
  String name;
  DeckServantEntity? deckInfo;
  int cost;

  @override
  int get primaryKey => id;

  static int createPK(int id) => id;

  UserDeckEntity({
    dynamic id,
    dynamic userId,
    dynamic deckNo,
    dynamic name,
    this.deckInfo,
    dynamic cost,
  })  : id = _toInt(id),
        userId = _toInt(userId),
        deckNo = _toInt(deckNo),
        name = name.toString(),
        cost = _toInt(cost);

  factory UserDeckEntity.fromJson(Map<String, dynamic> data) => _$UserDeckEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class UserEventDeckEntity extends DataEntityBase<String> {
  int userId;
  int eventId;
  int deckNo;
  DeckServantEntity? deckInfo;

  @override
  String get primaryKey => createPK(eventId, deckNo);

  static String createPK(int eventId, int deckNo) => _createPK2(eventId, deckNo);

  UserEventDeckEntity({
    dynamic userId,
    dynamic eventId,
    dynamic deckNo,
    this.deckInfo,
  })  : userId = _toInt(userId),
        eventId = _toInt(eventId),
        deckNo = _toInt(deckNo);

  factory UserEventDeckEntity.fromJson(Map<String, dynamic> data) => _$UserEventDeckEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class DeckServantEntity {
  List<DeckServantData> svts;
  int userEquipId;
  //  List<DeckWaveServantData> waveSvts;

  DeckServantEntity({
    List<DeckServantData>? svts,
    dynamic userEquipId,
  })  : svts = svts ?? [],
        userEquipId = _toInt(userEquipId);
  factory DeckServantEntity.fromJson(Map<String, dynamic> data) => _$DeckServantEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class DeckServantData {
  int id;
  int userSvtId;
  List<int> userSvtEquipIds;

  // for non-user svt
  int? svtId;
  List<int>? svtEquipIds;

  bool isFollowerSvt;
  int npcFollowerSvtId;
  int? followerType;
  int? initPos;

  DeckServantData({
    dynamic id,
    dynamic userSvtId,
    dynamic svtId,
    dynamic userSvtEquipIds,
    dynamic svtEquipIds,
    dynamic isFollowerSvt,
    dynamic npcFollowerSvtId,
    dynamic followerType,
    dynamic initPos,
  })  : id = _toInt(id),
        userSvtId = _toInt(userSvtId),
        svtId = _toIntNull(svtId),
        userSvtEquipIds = _toIntList(userSvtEquipIds),
        svtEquipIds = svtEquipIds == null ? null : _toIntList(svtEquipIds),
        isFollowerSvt = _toBool(isFollowerSvt),
        npcFollowerSvtId = _toInt(npcFollowerSvtId),
        followerType = _toIntNull(followerType),
        initPos = _toIntNull(initPos);
  factory DeckServantData.fromJson(Map<String, dynamic> data) => _$DeckServantDataFromJson(data);
}

@JsonSerializable(createToJson: false)
class BattleEntity extends DataEntityBase<int> {
  BattleInfoData? battleInfo;
  int64_t id;
  int battleType;
  int questId;
  int questPhase;
  int64_t userId;
  int64_t? targetId;
  int64_t? followerId;
  int? followerType;

  // int rankingId;
  // int seed;
  // int status;
  // int commandSpellCnt;
  // int commandSpellMax;
  // int result;
  // int eventId;
  // int rankingEventId;
  // int verifyMode;
  // int questSelect;
  //  List<CommandCodeInfo> userCommandCode;
  int64_t createdAt;

  @override
  int get primaryKey => id;

  static int createPK(int id) => id;

  BattleEntity({
    this.battleInfo,
    dynamic id,
    dynamic battleType,
    dynamic questId,
    dynamic questPhase,
    dynamic userId,
    dynamic targetId,
    dynamic followerId,
    dynamic followerType,
    dynamic createdAt,
  })  : id = _toInt(id),
        battleType = _toInt(battleType),
        questId = _toInt(questId),
        questPhase = _toInt(questPhase),
        userId = _toInt(userId),
        targetId = _toIntNull(targetId),
        followerId = _toIntNull(followerId),
        followerType = _toIntNull(followerType),
        createdAt = _toInt(createdAt, 0);

  factory BattleEntity.fromJson(Map<String, dynamic> data) => _$BattleEntityFromJson(data);
}

@JsonSerializable(createToJson: false)
class BattleInfoData {
  int32_t dataVer;
  String appVer;
  int32_t userEquipId;
  bool useEventEquip;
  List<BattleUserServantData> userSvt;
  DeckData? myDeck;
  List<DeckData> enemyDeck;
  List<BattleRaidInfo> raidInfo;
  List<BattleRaidInfo> startRaidInfo;
  List<Map> superBossInfo;

  BattleInfoData({
    dynamic dataVer,
    dynamic appVer,
    dynamic userEquipId,
    dynamic useEventEquip,
    this.userSvt = const [],
    this.myDeck,
    this.enemyDeck = const [],
    this.raidInfo = const [],
    this.startRaidInfo = const [],
    this.superBossInfo = const [],
  })  : dataVer = _toInt(dataVer),
        appVer = appVer.toString(),
        userEquipId = _toInt(userEquipId),
        useEventEquip = _toBool(useEventEquip);

  factory BattleInfoData.fromJson(Map<String, dynamic> data) => _$BattleInfoDataFromJson(data);

  Map<int, int> getTotalDrops() {
    final drops = enemyDeck.expand((e) => e.svts).expand((e) => e.dropInfos).toList();
    Map<int, int> dropItems = {};
    for (final drop in drops) {
      dropItems.addNum(drop.objectId, drop.num);
    }
    return dropItems;
  }
}

@JsonSerializable(createToJson: false)
class DeckData {
  List<BattleDeckServantData> svts;
  int? followerType;
  int? stageId;

  DeckData({
    this.svts = const [],
    dynamic followerType,
    dynamic stageId,
  })  : followerType = _toIntNull(followerType),
        stageId = _toIntNull(stageId);

  factory DeckData.fromJson(Map<String, dynamic> data) => _$DeckDataFromJson(data);
}

@JsonSerializable(createToJson: false)
class BattleDeckServantData {
  int uniqueId;
  String? name;
  int? roleType;
  List<DropInfo> dropInfos;
  int npcId;
  Map? enemyScript;
  // Map? infoScript;
  int? index;
  int id;
  int userSvtId;
  List<int>? userSvtEquipIds;
  bool isFollowerSvt;
  int? npcFollowerSvtId;
  int? followerType;

  BattleDeckServantData({
    dynamic uniqueId,
    dynamic name,
    dynamic roleType,
    this.dropInfos = const [],
    dynamic npcId,
    this.enemyScript,
    // this.infoScript,
    dynamic index,
    dynamic id,
    dynamic userSvtId,
    dynamic userSvtEquipIds,
    dynamic isFollowerSvt,
    dynamic npcFollowerSvtId,
    dynamic followerType,
  })  : uniqueId = _toInt(uniqueId),
        name = name?.toString(),
        roleType = _toIntNull(roleType),
        npcId = _toInt(npcId, 0),
        index = _toIntNull(index),
        id = _toInt(id),
        userSvtId = _toInt(userSvtId),
        userSvtEquipIds = _toIntList(userSvtEquipIds),
        isFollowerSvt = _toBool(isFollowerSvt),
        npcFollowerSvtId = _toIntNull(npcFollowerSvtId),
        followerType = _toIntNull(followerType);

  factory BattleDeckServantData.fromJson(Map<String, dynamic> data) => _$BattleDeckServantDataFromJson(data);
}

@JsonSerializable(createToJson: false)
class BattleUserServantData {
  int id;
  int? userId;
  int svtId;

  int lv;
  int exp;
  int atk;
  int hp;
  int? adjustAtk;
  int? adjustHp;
  // recover: int | None = None
  // chargeTurn: int | None = None
  int skillId1;
  int skillId2;
  int skillId3;
  int skillLv1;
  int skillLv2;
  int skillLv3;
  int? treasureDeviceId;
  int? treasureDeviceLv;
  // tdRate: int | None = None
  // tdAttackRate: int | None = None
  // deathRate: int | None = None
  // criticalRate: int | None = None
  // starRate: int | None = None
  // individuality: list[int]
  // classPassive: list[int]
  // addPassive: list[int] | None = None
  // addPassiveLvs: list[int] | None = None
  // aiId: int | None = None
  // actPriority: int | None = None
  // maxActNum: int | None = None
  // minActNum: int | None = None
  // displayType: int | None = None
  // npcSvtType: int | None = None
  // passiveSkill: list[int] | None = None
  int? equipTargetId1;
  List<int>? equipTargetIds;
  // npcSvtClassId: int | None = None
  // overwriteSvtId: int | None = None
  // userCommandCodeIds: list[int] | None = None
  // commandCardParam: list[int] | None = None
  // afterLimitCount: list[int] | None = None
  // afterIconLimitCount: list[int] | None = None
  List<int>? appendPassiveSkillIds;
  List<int>? appendPassiveSkillLvs;
  int limitCount; // for battle-setup ce, support ce's limitCounts may be zero
  // imageLimitCount: int | None = None
  int dispLimitCount;
  // commandCardLimitCount: int
  // iconLimitCount: int
  // portraitLimitCount: int
  // randomLimitCount: int | None = None
  // randomLimitCountSupport: int | None = None
  // limitCountSupport: int | None = None
  // battleVoice: int
  // treasureDeviceLv1: int | None = None
  // treasureDeviceLv2: int | None = None
  // treasureDeviceLv3: int | None = None
  // exceedCount: int
  // status: int | None = None
  // condVal: int | None = None
  // enemyScript: dict[str, Any] | None = None
  // hpGaugeType: int | None = None
  // imageSvtId: int | None = None
  // createdAt: int | None = None

  BattleUserServantData({
    dynamic id,
    dynamic userId,
    dynamic svtId,
    dynamic lv,
    dynamic exp,
    dynamic atk,
    dynamic hp,
    dynamic adjustAtk,
    dynamic adjustHp,
    dynamic skillId1,
    dynamic skillId2,
    dynamic skillId3,
    dynamic skillLv1,
    dynamic skillLv2,
    dynamic skillLv3,
    dynamic treasureDeviceId,
    dynamic treasureDeviceLv,
    dynamic equipTargetId1,
    dynamic equipTargetIds,
    dynamic appendPassiveSkillIds,
    dynamic appendPassiveSkillLvs,
    dynamic limitCount,
    dynamic dispLimitCount,
  })  : id = _toInt(id),
        userId = _toIntNull(userId),
        svtId = _toInt(svtId),
        lv = _toInt(lv),
        exp = _toInt(exp),
        atk = _toInt(atk),
        hp = _toInt(hp),
        adjustAtk = _toIntNull(adjustAtk),
        adjustHp = _toIntNull(adjustHp),
        skillId1 = _toInt(skillId1, 0),
        skillId2 = _toInt(skillId2, 0),
        skillId3 = _toInt(skillId3, 0),
        skillLv1 = _toInt(skillLv1, 0),
        skillLv2 = _toInt(skillLv2, 0),
        skillLv3 = _toInt(skillLv3, 0),
        treasureDeviceId = _toIntNull(treasureDeviceId),
        treasureDeviceLv = _toIntNull(treasureDeviceLv),
        equipTargetId1 = _toIntNull(equipTargetId1),
        equipTargetIds = _toIntList(equipTargetIds),
        appendPassiveSkillIds = _toIntList(appendPassiveSkillIds),
        appendPassiveSkillLvs = _toIntList(appendPassiveSkillLvs),
        limitCount = _toInt(limitCount),
        dispLimitCount = _toInt(dispLimitCount, 0);

  factory BattleUserServantData.fromJson(Map<String, dynamic> data) => _$BattleUserServantDataFromJson(data);
}

@JsonSerializable(createToJson: false)
class BattleRaidInfo {
  int day;
  int uniqueId;
  int maxHp;
  int totalDamage;

  BattleRaidInfo({
    dynamic day,
    dynamic uniqueId,
    dynamic maxHp,
    dynamic totalDamage,
  })  : day = _toInt(day),
        uniqueId = _toInt(uniqueId),
        maxHp = _toInt(maxHp),
        totalDamage = _toInt(totalDamage);

  factory BattleRaidInfo.fromJson(Map<String, dynamic> data) => _$BattleRaidInfoFromJson(data);
}

@JsonSerializable(createToJson: false)
class DropInfo {
  int type;
  int objectId;
  int num;
  int limitCount;
  int lv;
  int rarity;
  bool? isRateUp;
  int? originalNum;
  int? effectType;
  bool? isAdd;

  DropInfo({
    dynamic type,
    dynamic objectId,
    dynamic num,
    dynamic limitCount,
    dynamic lv,
    dynamic rarity,
    dynamic isRateUp,
    dynamic originalNum,
    dynamic effectType,
    dynamic isAdd,
  })  : type = _toInt(type),
        objectId = _toInt(objectId),
        num = _toInt(num),
        limitCount = _toInt(limitCount),
        lv = _toInt(lv),
        rarity = _toInt(rarity),
        isRateUp = _toBoolNull(isRateUp),
        originalNum = _toIntNull(originalNum),
        effectType = _toIntNull(effectType),
        isAdd = _toBoolNull(isAdd);

  factory DropInfo.fromJson(Map<String, dynamic> data) => _$DropInfoFromJson(data);
}

// BattleResultComponent.resultData
@JsonSerializable(createToJson: false)
class BattleResultData {
  int battleId;
  int battleResult;
  int eventId;

  int followerId;
  int followerClassId;
  int followerSupportDeckId;
  int followerType;
  int followerStatus;

  List<UserGameEntity> oldUserGame;
  List<UserQuestEntity> oldUserQuest;
  List<UserEquipEntity> oldUserEquip;
  List<UserServantCollectionEntity> oldUserSvtCollection;
  List<UserServantEntity> oldUserSvt; // usually empty

  Map myDeck; // DeckData, id+userSvtId

  int firstClearRewardQp;
  int originalPhaseClearQp;
  int phaseClearQp;
  int friendshipExpBase;

  List friendshipRewardInfos; // List<BattleFriendshipRewardInfo>
  List warClearReward; // List<WarClearReward>
  List<DropInfo> rewardInfos; // List<QuestRewardInfo>, 星光之砂
  List<DropInfo> resultDropInfos;

  BattleResultData({
    dynamic battleId,
    dynamic battleResult,
    dynamic eventId,
    dynamic followerId,
    dynamic followerClassId,
    dynamic followerSupportDeckId,
    dynamic followerType,
    dynamic followerStatus,
    List<UserGameEntity>? oldUserGame,
    List<UserQuestEntity>? oldUserQuest,
    List<UserEquipEntity>? oldUserEquip,
    List<UserServantCollectionEntity>? oldUserSvtCollection,
    List<UserServantEntity>? oldUserSvt,
    dynamic myDeck,
    dynamic firstClearRewardQp,
    dynamic originalPhaseClearQp,
    dynamic phaseClearQp,
    dynamic friendshipExpBase,
    dynamic friendshipRewardInfos,
    dynamic warClearReward,
    List<DropInfo>? rewardInfos,
    List<DropInfo>? resultDropInfos,
  })  : battleId = _toInt(battleId),
        battleResult = _toInt(battleResult),
        eventId = _toInt(eventId, 0),
        followerId = _toInt(followerId, 0),
        followerClassId = _toInt(followerClassId, 0),
        followerSupportDeckId = _toInt(followerSupportDeckId, 0),
        followerType = _toInt(followerType, 0),
        followerStatus = _toInt(followerStatus, 0),
        oldUserGame = oldUserGame ?? [],
        oldUserQuest = oldUserQuest ?? [],
        oldUserEquip = oldUserEquip ?? [],
        oldUserSvtCollection = oldUserSvtCollection ?? [],
        oldUserSvt = oldUserSvt ?? [],
        myDeck = myDeck as Map? ?? {},
        firstClearRewardQp = _toInt(firstClearRewardQp, 0),
        originalPhaseClearQp = _toInt(originalPhaseClearQp, 0),
        phaseClearQp = _toInt(phaseClearQp, 0),
        friendshipExpBase = _toInt(friendshipExpBase, 0),
        friendshipRewardInfos = friendshipRewardInfos as List? ?? [],
        warClearReward = warClearReward as List? ?? [],
        rewardInfos = rewardInfos ?? [],
        resultDropInfos = resultDropInfos ?? [];

  factory BattleResultData.fromJson(Map<dynamic, dynamic> data) => _$BattleResultDataFromJson(data);
}
