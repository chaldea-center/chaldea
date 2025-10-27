// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/daily_bonus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyBonusData _$DailyBonusDataFromJson(Map json) => DailyBonusData(
  info: DailyBonusAccountInfo.fromJson(Map<String, dynamic>.from(json['info'] as Map)),
  userPresentBox:
      (json['userPresentBox'] as List<dynamic>?)
          ?.map((e) => UserPresentBoxEntity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  campaignbonus:
      (json['campaignbonus'] as List<dynamic>?)?.map((e) => CampaignBonusData.fromJson(e as Map)).toList() ?? const [],
);

DailyBonusAccountInfo _$DailyBonusAccountInfoFromJson(Map json) => DailyBonusAccountInfo(
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  region: const RegionConverter().fromJson(json['region'] as String),
  start: (json['start'] as num).toInt(),
  startSeqLoginCount: (json['startSeqLoginCount'] as num).toInt(),
  startTotalLoginCount: (json['startTotalLoginCount'] as num).toInt(),
);
