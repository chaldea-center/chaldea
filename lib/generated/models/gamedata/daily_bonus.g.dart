// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/daily_bonus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyBonusData _$DailyBonusDataFromJson(Map json) => DailyBonusData(
      info: DailyBonusAccountInfo.fromJson(Map<String, dynamic>.from(json['info'] as Map)),
      userPresentBox: (json['userPresentBox'] as List<dynamic>?)
              ?.map((e) => UserPresentBox.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      campaignbonus: (json['campaignbonus'] as List<dynamic>?)
              ?.map((e) => CampaignBonusData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

DailyBonusAccountInfo _$DailyBonusAccountInfoFromJson(Map json) => DailyBonusAccountInfo(
      userId: json['userId'] as int,
      region: const RegionConverter().fromJson(json['region'] as String),
      start: json['start'] as int,
      startSeqLoginCount: json['startSeqLoginCount'] as int,
      startTotalLoginCount: json['startTotalLoginCount'] as int,
    );

CampaignBonusData _$CampaignBonusDataFromJson(Map json) => CampaignBonusData(
      name: json['name'] as String,
      detail: json['detail'] as String,
      addDetail: json['addDetail'] as String,
      isDeemedLogin: json['isDeemedLogin'] as bool,
      items: (json['items'] as List<dynamic>?)?.map((e) => e as Map).toList() ?? const [],
      script: Map<String, dynamic>.from(json['script'] as Map),
      eventId: json['eventId'] as int,
      day: json['day'] as int,
    );
