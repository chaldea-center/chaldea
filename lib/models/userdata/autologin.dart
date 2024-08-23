import 'dart:convert';

import 'package:chaldea/utils/extension.dart';
import '../faker/jp/network.dart';
import '../gamedata/common.dart';
import '../gamedata/toplogin.dart';
import '_helper.dart';

part '../../generated/models/userdata/autologin.g.dart';

@JsonSerializable()
class AuthSaveData {
  final String? source; // bytes in base64
  final String? code;

  final String userId;
  final String authKey;
  final String secretKey;
  final String? saveDataVer;
  final String? userCreateServer;

  int get userIdInt => int.parse(userId);

  AuthSaveData({
    this.source,
    this.code,
    required this.userId,
    required this.authKey,
    required this.secretKey,
    this.saveDataVer,
    this.userCreateServer,
  });

  bool get isValid => isValidKeys(userId, authKey, secretKey);

  static String normTransferCode(String code) {
    code = code.trim();
    if (!code.startsWith('ZSv/')) {
      int start = code.indexOf('ZSv/');
      if (start >= 0 && start < 5) {
        code = code.substring(start);
      }
    }
    return code;
  }

  static bool isValidCode(String code) {
    code = normTransferCode(code);
    try {
      base64Decode(code);
    } catch (e) {
      return false;
    }
    return true;
  }

  static bool isValidKeys(String userId, String authKey, String secretKey) {
    if (int.tryParse(userId) == null || userId.length < 9) return false;
    if (authKey.length != 29) return false;
    if (secretKey.length != 29) return false;
    return true;
  }

  static bool checkGameServer(Region region, String server) {
    if (region == Region.jp) return server.contains('fate-go.jp');
    if (region == Region.na) return server.contains('fate-go.us');
    return false;
  }

  factory AuthSaveData.fromJson(Map<String, dynamic> json) => _$AuthSaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSaveDataToJson(this);
}

sealed class AutoLoginData {
  @RegionConverter()
  Region region;
  String userAgent;

  int _curBattleOptionIndex;
  int get curBattleOptionIndex => _curBattleOptionIndex.clamp2(0, battleOptions.length - 1);
  set curBattleOptionIndex(int v) => _curBattleOptionIndex = v.clamp2(0, battleOptions.length - 1);

  List<AutoBattleOptions> battleOptions;
  AutoBattleOptions get curBattleOption {
    if (battleOptions.isEmpty) battleOptions.add(AutoBattleOptions());
    return battleOptions[curBattleOptionIndex];
  }

  int? lastLogin;
  UserGameEntity? userGame;

  @JsonKey(includeFromJson: false, includeToJson: false)
  FResponse? response;

  AutoLoginData({
    this.region = Region.jp,
    this.userAgent = '',
    int? curBattleOptionIndex,
    List<AutoBattleOptions>? battleOptions,
    this.lastLogin,
    this.userGame,
  })  : battleOptions = battleOptions ?? [AutoBattleOptions()],
        _curBattleOptionIndex = curBattleOptionIndex ?? 0;

  String get serverName;
  String get internalId;

  bool validate();
}

@JsonSerializable(converters: [RegionConverter()])
class AutoLoginDataJP extends AutoLoginData {
  AuthSaveData? auth;
  String? deviceInfo;
  NACountry country;

  AutoLoginDataJP({
    super.region,
    this.auth,
    this.deviceInfo,
    this.country = NACountry.unitedStates,
    super.userAgent,
    super.curBattleOptionIndex,
    super.battleOptions,
    super.lastLogin,
    super.userGame,
  });

  factory AutoLoginDataJP.fromJson(Map<String, dynamic> json) => _$AutoLoginDataJPFromJson(json);

  Map<String, dynamic> toJson() => _$AutoLoginDataJPToJson(this);

  @override
  String get serverName => region.upper;

  @override
  String get internalId => auth?.userId ?? 'null';

  @override
  bool validate() {
    return auth != null && auth!.isValid;
  }
}

enum BiliGameServer {
  ios,
  android,
  uo,
  ;

  String get shownName => switch (this) {
        ios => 'iOS',
        android => '安卓B服',
        uo => '安卓渠道服',
      };
}

@JsonSerializable(converters: [RegionConverter()])
class AutoLoginDataCN extends AutoLoginData {
  @override
  Region get region => Region.cn;

  BiliGameServer gameServer;
  bool isAndroidDevice;
  int uid; // rkuid
  String accessToken;
  String username;
  String nickname;
  String deviceId;
  int get rkchannel => switch (gameServer) {
        BiliGameServer.android => 24,
        BiliGameServer.ios => 996,
        BiliGameServer.uo => 24,
      };
  int get cPlat => isAndroidDevice ? 3 : 2; // 系统? ios-2,android-3
  int get uPlat => switch (gameServer) {
        BiliGameServer.android => 3,
        BiliGameServer.ios => 2,
        BiliGameServer.uo => 3,
      }; // 账号? ios-2,android-3
  String os;
  String ptype;

  AutoLoginDataCN({
    super.region = Region.cn,
    this.gameServer = BiliGameServer.android,
    this.isAndroidDevice = true,
    this.uid = 0,
    this.accessToken = '',
    this.username = '',
    this.nickname = '',
    this.deviceId = '',
    // this.rkchannel = 24,
    // this.cPlat = 3,
    // this.uPlat = 3,
    this.os = '',
    this.ptype = '',
    super.userAgent,
    super.curBattleOptionIndex,
    super.battleOptions,
    super.lastLogin,
    super.userGame,
  });

  factory AutoLoginDataCN.fromJson(Map<String, dynamic> json) => _$AutoLoginDataCNFromJson(json);

  Map<String, dynamic> toJson() => _$AutoLoginDataCNToJson(this);

  @override
  String get serverName => '${region.localName} ${gameServer.shownName}';

  @override
  String get internalId => 'UID $uid';

  String getOS() {
    if (os.trim().isNotEmpty) return os;
    return isAndroidDevice ? "Android OS 7.1.2 / API-25 (N2G48C/4565141)" : "iPadOS 15.2";
  }

  String getPtype() {
    if (ptype.trim().isNotEmpty) return ptype;
    return isAndroidDevice ? "vivo V1938CT" : "iPad7,3";
  }

  @override
  bool validate() {
    return gameServer != BiliGameServer.uo &&
        uid > 0 &&
        accessToken.isNotEmpty &&
        rkchannel > 0 &&
        cPlat > 0 &&
        uPlat > 0 &&
        deviceId.isNotEmpty &&
        username.isNotEmpty &&
        nickname.isNotEmpty;
  }
}

@JsonSerializable()
class AutoBattleOptions {
  String name;
  // setup
  int questId;
  int questPhase;
  bool isHpHalf = false;
  bool useEventDeck;
  int deckId;
  bool enfoceRefreshSupport;
  Set<int> supportSvtIds;
  Set<int> supportCeIds;
  bool supportCeMaxLimitBreak;
  bool useCampaignItem;
  // result
  bool stopIfBondLimit;
  BattleResultType resultType;
  BattleWinResultType winType;
  String actionLogs;
  List<int> usedTurnArray;
  // loop
  List<int> recoverIds;
  int loopCount;
  Map<int, int> targetDrops; // any of target drop reaches
  Map<int, int> winTargetItemNum; // win only if any target reaches, only for QuestFlag.actConsumeBattleWin
  int? battleDuration;

  AutoBattleOptions({
    this.name = '',
    this.questId = 0,
    this.questPhase = 0,
    this.useEventDeck = false,
    this.isHpHalf = false,
    this.deckId = 0,
    this.enfoceRefreshSupport = false,
    Set<int>? supportSvtIds,
    Set<int>? supportCeIds,
    this.supportCeMaxLimitBreak = true,
    this.useCampaignItem = false,
    this.stopIfBondLimit = true,
    this.resultType = BattleResultType.win,
    this.winType = BattleWinResultType.normal,
    this.actionLogs = '',
    List<int>? usedTurnArray,
    List<int>? recoverIds,
    this.loopCount = 0,
    Map<int, int>? targetDrops,
    Map<int, int>? winTargetItemNum,
  })  : supportSvtIds = supportSvtIds ?? {},
        supportCeIds = supportCeIds ?? {},
        usedTurnArray = usedTurnArray ?? [],
        recoverIds = recoverIds ?? [],
        targetDrops = targetDrops ?? {},
        winTargetItemNum = winTargetItemNum ?? {};

  factory AutoBattleOptions.fromJson(Map<String, dynamic> json) => _$AutoBattleOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$AutoBattleOptionsToJson(this);
}

enum NACountry {
  // none(0),
  unitedStates(840),
  canada(124),
  australia(36),
  unitedKingdom(826),
  germany(276),
  france(250),
  singapore(702),
  italy(380),
  spain(724),
  philippines(608),
  mexico(484),
  thailand(764),
  netherlands(528),
  brazil(76),
  finland(246),
  sweden(752),
  chile(152),
  newZealand(554),
  poland(616),
  switzerland(756),
  austria(40),
  ireland(372),
  belgium(56),
  norway(576),
  denmark(208),
  portugal(620),
  ;

  const NACountry(this.countryId);
  final int countryId;

  String get displayName => name.toTitle();
}

enum BattleResultType {
  none(0),
  win(1),
  lose(2),
  cancel(3),
  interruption(4),
  ;

  const BattleResultType(this.value);
  final int value;
}

enum BattleWinResultType {
  none(0),
  normal(1),
  timeLimit(2),
  lose(3),
  ;

  const BattleWinResultType(this.value);
  final int value;
}
