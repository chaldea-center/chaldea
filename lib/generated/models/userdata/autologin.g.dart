// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/autologin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAuth _$UserAuthFromJson(Map json) => $checkedCreate(
      'UserAuth',
      json,
      ($checkedConvert) {
        final val = UserAuth(
          code: $checkedConvert('code', (v) => v as String?),
          userId: $checkedConvert('userId', (v) => v as String),
          authKey: $checkedConvert('authKey', (v) => v as String),
          secretKey: $checkedConvert('secretKey', (v) => v as String),
          saveDataVer: $checkedConvert('saveDataVer', (v) => v as String?),
          userCreateServer: $checkedConvert('userCreateServer', (v) => v as String?),
          friendCode: $checkedConvert('friendCode', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserAuthToJson(UserAuth instance) => <String, dynamic>{
      'code': instance.code,
      'userId': instance.userId,
      'authKey': instance.authKey,
      'secretKey': instance.secretKey,
      'saveDataVer': instance.saveDataVer,
      'userCreateServer': instance.userCreateServer,
      'friendCode': instance.friendCode,
      'name': instance.name,
    };

AutoLoginData _$AutoLoginDataFromJson(Map json) => $checkedCreate(
      'AutoLoginData',
      json,
      ($checkedConvert) {
        final val = AutoLoginData(
          region:
              $checkedConvert('region', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
          auth:
              $checkedConvert('auth', (v) => v == null ? null : UserAuth.fromJson(Map<String, dynamic>.from(v as Map))),
          userAgent: $checkedConvert('userAgent', (v) => v as String?),
          deviceInfo: $checkedConvert('deviceInfo', (v) => v as String?),
          country:
              $checkedConvert('country', (v) => $enumDecodeNullable(_$NACountryEnumMap, v) ?? NACountry.unitedStates),
        );
        return val;
      },
    );

Map<String, dynamic> _$AutoLoginDataToJson(AutoLoginData instance) => <String, dynamic>{
      'region': const RegionConverter().toJson(instance.region),
      'auth': instance.auth?.toJson(),
      'userAgent': instance.userAgent,
      'deviceInfo': instance.deviceInfo,
      'country': _$NACountryEnumMap[instance.country]!,
    };

const _$NACountryEnumMap = {
  NACountry.unitedStates: 'unitedStates',
  NACountry.canada: 'canada',
  NACountry.australia: 'australia',
  NACountry.unitedKingdom: 'unitedKingdom',
  NACountry.germany: 'germany',
  NACountry.france: 'france',
  NACountry.singapore: 'singapore',
  NACountry.italy: 'italy',
  NACountry.spain: 'spain',
  NACountry.philippines: 'philippines',
  NACountry.mexico: 'mexico',
  NACountry.thailand: 'thailand',
  NACountry.netherlands: 'netherlands',
  NACountry.brazil: 'brazil',
  NACountry.finland: 'finland',
  NACountry.sweden: 'sweden',
  NACountry.chile: 'chile',
  NACountry.newZealand: 'newZealand',
  NACountry.poland: 'poland',
  NACountry.switzerland: 'switzerland',
  NACountry.austria: 'austria',
  NACountry.ireland: 'ireland',
  NACountry.belgium: 'belgium',
  NACountry.norway: 'norway',
  NACountry.denmark: 'denmark',
  NACountry.portugal: 'portugal',
};
