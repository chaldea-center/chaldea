import '_helper.dart';
import 'common.dart';
import 'mst_tables.dart';

part '../../generated/models/gamedata/daily_bonus.g.dart';

@JsonSerializable(createToJson: false)
class DailyBonusData {
  DailyBonusAccountInfo info;
  List<UserPresentBoxEntity> userPresentBox;
  List<CampaignBonusData> campaignbonus;

  DailyBonusData({required this.info, this.userPresentBox = const [], this.campaignbonus = const []});

  factory DailyBonusData.fromJson(Map<String, dynamic> json) => _$DailyBonusDataFromJson(json);

  int? get lastPresentTime {
    if (userPresentBox.isEmpty) return null;
    return userPresentBox.last.createdAt;
  }
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
    this.userId = 0,
    // required this.friendCode,
    required this.region,
    // required this.name,
    required this.start,
    required this.startSeqLoginCount,
    required this.startTotalLoginCount,
  });

  factory DailyBonusAccountInfo.fromJson(Map<String, dynamic> json) => _$DailyBonusAccountInfoFromJson(json);
}
