import '_helper.dart';
import 'common.dart';
import 'toplogin.dart';

part '../../generated/models/gamedata/daily_bonus.g.dart';

@JsonSerializable(createToJson: false)
class DailyBonusData {
  DailyBonusAccountInfo info;
  List<UserPresentBox> userPresentBox;
  List<CampaignBonusData> campaignbonus;

  DailyBonusData({
    required this.info,
    this.userPresentBox = const [],
    this.campaignbonus = const [],
  });

  factory DailyBonusData.fromJson(Map<String, dynamic> json) => _$DailyBonusDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class DailyBonusAccountInfo {
  int userId;
  // String friendCode;
  @RegionConverter()
  Region region;
  // String name;
  int start;
  int startSeqLoginCount;
  int startTotalLoginCount;

  DailyBonusAccountInfo({
    required this.userId,
    // required this.friendCode,
    required this.region,
    // required this.name,
    required this.start,
    required this.startSeqLoginCount,
    required this.startTotalLoginCount,
  });

  factory DailyBonusAccountInfo.fromJson(Map<String, dynamic> json) => _$DailyBonusAccountInfoFromJson(json);
}

@JsonSerializable(createToJson: false)
class CampaignBonusData {
  String name;
  String detail;
  String addDetail;
  bool isDeemedLogin;
  List<Map> items;
  Map<String, dynamic> script;
  int eventId;
  int day;

  CampaignBonusData({
    required this.name,
    required this.detail,
    required this.addDetail,
    required this.isDeemedLogin,
    this.items = const [],
    required this.script,
    required this.eventId,
    required this.day,
  });

  factory CampaignBonusData.fromJson(Map<String, dynamic> json) => _$CampaignBonusDataFromJson(json);
}
