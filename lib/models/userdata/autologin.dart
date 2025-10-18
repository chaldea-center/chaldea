import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import '../faker/jp/network.dart';
import '../gamedata/common.dart';
import '../gamedata/item.dart';
import '../gamedata/mappings.dart';
import '../gamedata/toplogin.dart';
import '_helper.dart';

part '../../generated/models/userdata/autologin.g.dart';

@JsonSerializable()
class FakerSettings {
  bool dumpResponse;
  bool apRecoveredNotification;
  int maxFollowerListRetryCount;
  bool showProgressToast = true;
  List<AutoLoginDataJP> jpAutoLogins;
  List<AutoLoginDataCN> cnAutoLogins;

  FakerSettings({
    this.dumpResponse = false,
    this.apRecoveredNotification = false,
    this.maxFollowerListRetryCount = 20,
    this.showProgressToast = true,
    List<AutoLoginDataJP>? jpAutoLogins,
    List<AutoLoginDataCN>? cnAutoLogins,
  }) : jpAutoLogins = jpAutoLogins ?? [],
       cnAutoLogins = cnAutoLogins ?? [];

  factory FakerSettings.fromJson(Map<String, dynamic> json) => _$FakerSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$FakerSettingsToJson(this);

  List<AutoLoginData> get allAccounts {
    List<AutoLoginData> accounts = [...jpAutoLogins, ...cnAutoLogins];
    accounts.sort2((e) => e.priority);
    return accounts;
  }
}

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
  int priority;
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

  //
  Set<int> recoveredAps;
  Set<int> shopTargetIds;

  // gacha
  GachaOption gacha;
  SvtCombineOption svtCombine;
  PresentBoxFilterData presentBox;
  RandomMissionOption randomMission;

  //
  int? lastLogin;
  UserGameEntity? userGame;
  Map<int, int> userItems = {};
  RequestOptionsSaveData? lastRequestOptions;

  @JsonKey(includeFromJson: false, includeToJson: false)
  FResponse? response;

  AutoLoginData({
    this.priority = 0,
    this.region = Region.jp,
    this.userAgent = '',
    int? curBattleOptionIndex,
    List<AutoBattleOptions>? battleOptions,
    Set<int>? recoveredAps,
    Set<int>? shopTargetIds,
    GachaOption? gacha,
    SvtCombineOption? svtCombine,
    PresentBoxFilterData? presentBox,
    RandomMissionOption? randomMission,
    this.lastLogin,
    this.userGame,
    Map<int, int>? userItems,
    this.lastRequestOptions,
  }) : battleOptions = battleOptions ?? [AutoBattleOptions()],
       recoveredAps = recoveredAps ?? {},
       shopTargetIds = shopTargetIds ?? {Items.summonTicketId, Items.lanternId},
       gacha = gacha ?? GachaOption(),
       svtCombine = svtCombine ?? SvtCombineOption(),
       presentBox = presentBox ?? PresentBoxFilterData(),
       randomMission = randomMission ?? RandomMissionOption(),
       _curBattleOptionIndex = curBattleOptionIndex ?? 0,
       userItems = userItems ?? {};

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
    super.priority,
    super.region,
    this.auth,
    this.deviceInfo,
    this.country = NACountry.unitedStates,
    super.userAgent,
    super.curBattleOptionIndex,
    super.battleOptions,
    super.recoveredAps,
    super.shopTargetIds,
    super.gacha,
    super.svtCombine,
    super.presentBox,
    super.randomMission,
    super.lastLogin,
    super.userGame,
    super.userItems,
    super.lastRequestOptions,
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
  uo;

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
    super.priority,
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
    super.recoveredAps,
    super.shopTargetIds,
    super.gacha,
    super.svtCombine,
    super.presentBox,
    super.randomMission,
    super.lastLogin,
    super.userGame,
    super.userItems,
    super.lastRequestOptions,
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
  bool isApHalf = false;
  bool? useEventDeck;
  int deckId;
  bool enfoceRefreshSupport;
  Set<int> supportSvtIds;
  Set<int> supportEquipIds;
  Set<int> grandSupportEquipIds;
  bool supportEquipMaxLimitBreak;
  int npcSupportId = 0;
  bool useCampaignItem;
  int campaignItemId = 0;
  // result
  bool stopIfBondLimit;
  BattleResultType resultType;
  BattleWinResultType winType;
  String actionLogs;
  List<int> usedTurnArray;
  bool enableSkillShift;
  List<int> skillShiftEnemyUniqueIds;

  // loop
  List<int> recoverIds;
  int loopCount;
  Map<int, int> targetDrops; // any of target drop reaches
  Map<int, int> winTargetItemNum; // win only if any target reaches, only for QuestFlag.actConsumeBattleWin
  int? battleDuration;
  bool waitApRecover = false;
  bool waitApRecoverGold = false;

  AutoBattleOptions({
    this.name = '',
    this.questId = 0,
    this.questPhase = 0,
    this.useEventDeck,
    this.isApHalf = false,
    this.deckId = 0,
    this.enfoceRefreshSupport = false,
    Set<int>? supportSvtIds,
    Set<int>? supportEquipIds,
    Set<int>? grandSupportEquipIds,
    this.supportEquipMaxLimitBreak = true,
    this.npcSupportId = 0,
    this.useCampaignItem = false,
    this.campaignItemId = 0,
    this.stopIfBondLimit = true,
    this.resultType = BattleResultType.win,
    this.winType = BattleWinResultType.normal,
    this.actionLogs = '',
    List<int>? usedTurnArray,
    this.enableSkillShift = true,
    List<int>? skillShiftEnemyUniqueIds,
    List<int>? recoverIds,
    this.loopCount = 0,
    Map<int, int>? targetDrops,
    Map<int, int>? winTargetItemNum,
    this.battleDuration,
    this.waitApRecover = false,
    this.waitApRecoverGold = false,
  }) : supportSvtIds = supportSvtIds ?? {},
       supportEquipIds = supportEquipIds ?? {},
       grandSupportEquipIds = grandSupportEquipIds ?? {},
       usedTurnArray = usedTurnArray ?? [],
       skillShiftEnemyUniqueIds = skillShiftEnemyUniqueIds ?? [],
       recoverIds = recoverIds ?? [],
       targetDrops = targetDrops ?? {},
       winTargetItemNum = winTargetItemNum ?? {};

  factory AutoBattleOptions.fromJson(Map<String, dynamic> json) => _$AutoBattleOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$AutoBattleOptionsToJson(this);
}

@JsonSerializable()
class RequestOptionsSaveData {
  int createdAt;
  String path;
  String key;
  String url;
  String formData;
  Map<String, dynamic> headers;
  bool success;

  RequestOptionsSaveData({
    required this.createdAt,
    required this.path,
    required this.key,
    required this.url,
    required this.formData,
    required this.headers,
    this.success = false,
  });

  factory RequestOptionsSaveData.fromJson(Map<String, dynamic> json) => _$RequestOptionsSaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$RequestOptionsSaveDataToJson(this);
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
  portugal(620);

  const NACountry(this.countryId);
  final int countryId;

  String get displayName => name.toTitle();
}

enum BattleResultType {
  none(0),
  win(1),
  lose(2),
  cancel(3),
  interruption(4);

  const BattleResultType(this.value);
  final int value;
}

enum BattleWinResultType {
  none(0),
  normal(1),
  timeLimit(2),
  lose(3);

  const BattleWinResultType(this.value);
  final int value;
}

@JsonSerializable()
class GachaOption {
  // gacha
  int gachaId;
  Map<int, int> gachaSubs; // <gachaId, subId>
  int get gachaSubId => gachaSubs[gachaId] ?? 0;
  int loopCount;
  bool hundredDraw;
  // enhance
  Set<int> ceEnhanceBaseUserSvtIds;
  Set<int> ceEnhanceBaseSvtIds;
  bool feedExp3;
  bool feedExp4;
  // sell
  Set<int> sellKeepSvtIds = {};
  Set<int> sellKeepCommandCodeIds = {};

  GachaOption({
    this.gachaId = 0,
    Map<int, int>? gachaSubs,
    this.loopCount = 0,
    this.hundredDraw = false,
    Set<int>? ceEnhanceBaseUserSvtIds,
    Set<int>? ceEnhanceBaseSvtIds,
    this.feedExp3 = false,
    this.feedExp4 = false,
    Set<int>? sellKeepSvtIds,
    Set<int>? sellKeepCommandCodeIds,
  }) : gachaSubs = gachaSubs ?? {},
       ceEnhanceBaseUserSvtIds = ceEnhanceBaseUserSvtIds ?? {},
       ceEnhanceBaseSvtIds = ceEnhanceBaseSvtIds ?? {},
       sellKeepSvtIds = sellKeepSvtIds ?? {},
       sellKeepCommandCodeIds = sellKeepCommandCodeIds ?? {};

  factory GachaOption.fromJson(Map<String, dynamic> json) => _$GachaOptionFromJson(json);

  Map<String, dynamic> toJson() => _$GachaOptionToJson(this);
}

@JsonSerializable()
class SvtCombineOption {
  int baseUserSvtId;
  int maxMaterialCount;
  int loopCount;
  Set<int> svtMaterialRarities;
  bool doubleExp = false;

  SvtCombineOption({
    this.baseUserSvtId = 0,
    this.maxMaterialCount = 20,
    this.loopCount = 0,
    Set<int>? svtMaterialRarities,
    this.doubleExp = false,
  }) : svtMaterialRarities = svtMaterialRarities ?? {};

  factory SvtCombineOption.fromJson(Map<String, dynamic> json) => _$SvtCombineOptionFromJson(json);

  Map<String, dynamic> toJson() => _$SvtCombineOptionToJson(this);
}

@JsonSerializable()
class PresentBoxFilterData {
  bool reversed = false;

  int maxNum = 0;
  @JsonKey(unknownEnumValue: PresentType.servantExp)
  Set<PresentType> presentTypes;
  Set<int> presentFromType = {};
  Set<int> rarities;

  PresentBoxFilterData({
    this.reversed = false,
    this.maxNum = 0,
    Set<PresentType>? presentTypes,
    Set<int>? presentFromType,
    Set<int>? rarities,
  }) : presentTypes = presentTypes ?? {},
       presentFromType = presentFromType ?? {},
       rarities = rarities ?? {};

  void reset() {
    presentTypes.clear();
    presentFromType.clear();
    rarities.clear();
    maxNum = 0;
  }

  factory PresentBoxFilterData.fromJson(Map<String, dynamic> json) => _$PresentBoxFilterDataFromJson(json);

  Map<String, dynamic> toJson() => _$PresentBoxFilterDataToJson(this);
}

@JsonSerializable()
class RandomMissionOption {
  int cqTeamIndex;
  int fqTeamIndex;
  int maxFreeCount;
  Map<int, double> itemWeights;
  Set<int> enabledQuests;
  int discardMissionMinLeftNum;
  int discardLoopCount;

  // stat data
  Map<int, int> dropItems;
  Map<int, int> giftItems;
  Map<int, int> questCounts;
  int cqCount;
  int fqCount;
  int totalAp;

  RandomMissionOption({
    this.cqTeamIndex = 0,
    this.fqTeamIndex = 0,
    this.maxFreeCount = 0,
    Map<int, double>? itemWeights,
    Set<int>? enabledQuests,
    this.discardMissionMinLeftNum = -1,
    this.discardLoopCount = 0,
    Map<int, int>? dropItems,
    Map<int, int>? giftItems,
    Map<int, int>? questCounts,
    this.cqCount = 0,
    this.fqCount = 0,
    this.totalAp = 0,
  }) : itemWeights = itemWeights ?? {},
       enabledQuests = enabledQuests ?? {},
       dropItems = dropItems ?? {},
       giftItems = giftItems ?? {},
       questCounts = questCounts ?? {};

  factory RandomMissionOption.fromJson(Map<String, dynamic> json) => _$RandomMissionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$RandomMissionOptionToJson(this);

  double getItemWeight(int itemId) {
    double? weight = itemWeights[itemId];
    if (weight != null) return weight;
    if (itemId < 1000) return 0;
    return 1.0;
  }

  bool isImportant(int itemId) => getItemWeight(itemId) >= 2.0;

  void resetStatData() {
    dropItems = {};
    giftItems = {};
    questCounts = {};
    cqCount = 0;
    fqCount = 0;
    totalAp = 0;
  }
}

enum PresentType {
  servant,
  servantExp,
  statusUp,
  svtEquip,
  svtEquipExp,
  commandCode,
  fruit,
  summonTicket,
  itemSelect,
  stone,
  manaPrism,
  eventItem,
  others;

  String get shownName {
    return switch (this) {
          PresentType.servant => S.current.servant,
          PresentType.servantExp => '${S.current.servant}(EXP)',
          PresentType.statusUp => S.current.foukun,
          PresentType.svtEquip => S.current.craft_essence,
          PresentType.svtEquipExp => '${S.current.craft_essence}(EXP)',
          PresentType.commandCode => S.current.command_code,
          PresentType.fruit => S.current.item_apple,
          PresentType.summonTicket => Items.summonTicket?.lName.l,
          PresentType.itemSelect => S.current.exchange_ticket,
          PresentType.stone => Items.stone?.lName.l,
          PresentType.manaPrism => Items.manaPrism?.lName.l,
          PresentType.eventItem => Transl.enums(ItemCategory.event, (e) => e.itemCategory).l,
          PresentType.others => S.current.general_others,
        } ??
        name;
  }
}

@JsonSerializable()
class AppWidgetConfig {
  WidgetBackgroundConfig background;
  WidgetLayoutType layoutType;

  AppWidgetConfig({WidgetBackgroundConfig? background, this.layoutType = WidgetLayoutType.medium})
    : background = background ?? WidgetBackgroundConfig();

  factory AppWidgetConfig.fromJson(Map<String, dynamic> json) => _$AppWidgetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppWidgetConfigToJson(this);
}

@JsonSerializable()
class WidgetBackgroundConfig {
  WidgetBackgroundType type;
  String? colorHex;
  List<String>? gradientHex;
  String? imagePath;
  double blurRadius;

  WidgetBackgroundConfig({
    this.type = WidgetBackgroundType.color,
    this.colorHex,
    this.gradientHex,
    this.imagePath,
    this.blurRadius = 10.0,
  });

  factory WidgetBackgroundConfig.fromJson(Map<String, dynamic> json) => _$WidgetBackgroundConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetBackgroundConfigToJson(this);
}

// let id: String
// let name: String
// var gameServer: String
// var biliServer: String = ""
// var actMax: Int = 144
// var actRecoverAt: Int
// var carryOverActPoint: Int = 0

@JsonSerializable()
class WidgetAccountInfo {
  String id;
  String name;
  @RegionConverter()
  Region gameServer;
  String biliServer;
  int actMax;
  int actRecoverAt;
  int carryOverActPoint;

  WidgetAccountInfo({
    required this.id,
    this.name = "",
    this.gameServer = Region.jp,
    this.biliServer = "",
    this.actMax = 0,
    this.actRecoverAt = 0,
    this.carryOverActPoint = 0,
  });

  factory WidgetAccountInfo.fromJson(Map<String, dynamic> json) => _$WidgetAccountInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetAccountInfoToJson(this);
}

enum WidgetBackgroundType { color, gradient, image }

enum WidgetLayoutType { small, medium }
