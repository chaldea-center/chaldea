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
          source: $checkedConvert('source', (v) => v as String?),
          code: $checkedConvert('code', (v) => v as String?),
          userId: $checkedConvert('userId', (v) => v as String),
          authKey: $checkedConvert('authKey', (v) => v as String),
          secretKey: $checkedConvert('secretKey', (v) => v as String),
          saveDataVer: $checkedConvert('saveDataVer', (v) => v as String?),
          userCreateServer: $checkedConvert('userCreateServer', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserAuthToJson(UserAuth instance) => <String, dynamic>{
      'source': instance.source,
      'code': instance.code,
      'userId': instance.userId,
      'authKey': instance.authKey,
      'secretKey': instance.secretKey,
      'saveDataVer': instance.saveDataVer,
      'userCreateServer': instance.userCreateServer,
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
          useThisDevice: $checkedConvert('useThisDevice', (v) => v as bool? ?? false),
          lastLogin: $checkedConvert('lastLogin', (v) => (v as num?)?.toInt()),
          userGame: $checkedConvert(
              'userGame', (v) => v == null ? null : UserGameEntity.fromJson(Map<String, dynamic>.from(v as Map))),
          battleOptions: $checkedConvert(
              'battleOptions',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoBattleOptions.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          curBattleOptionIndex: $checkedConvert('curBattleOptionIndex', (v) => (v as num?)?.toInt()),
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
      'useThisDevice': instance.useThisDevice,
      'lastLogin': instance.lastLogin,
      'curBattleOptionIndex': instance.curBattleOptionIndex,
      'battleOptions': instance.battleOptions.map((e) => e.toJson()).toList(),
      'userGame': instance.userGame?.toJson(),
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

AutoBattleOptions _$AutoBattleOptionsFromJson(Map json) => $checkedCreate(
      'AutoBattleOptions',
      json,
      ($checkedConvert) {
        final val = AutoBattleOptions(
          questId: $checkedConvert('questId', (v) => (v as num?)?.toInt() ?? 0),
          questPhase: $checkedConvert('questPhase', (v) => (v as num?)?.toInt() ?? 0),
          useEventDeck: $checkedConvert('useEventDeck', (v) => v as bool? ?? false),
          isHpHalf: $checkedConvert('isHpHalf', (v) => v as bool? ?? false),
          deckId: $checkedConvert('deckId', (v) => (v as num?)?.toInt() ?? 0),
          enfoceRefreshSupport: $checkedConvert('enfoceRefreshSupport', (v) => v as bool? ?? false),
          supportSvtIds:
              $checkedConvert('supportSvtIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          supportCeIds:
              $checkedConvert('supportCeIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          supportCeMaxLimitBreak: $checkedConvert('supportCeMaxLimitBreak', (v) => v as bool? ?? true),
          useCampaignItem: $checkedConvert('useCampaignItem', (v) => v as bool? ?? false),
          stopIfBondLimit: $checkedConvert('stopIfBondLimit', (v) => v as bool? ?? true),
          resultType: $checkedConvert(
              'resultType', (v) => $enumDecodeNullable(_$BattleResultTypeEnumMap, v) ?? BattleResultType.win),
          winType: $checkedConvert(
              'winType', (v) => $enumDecodeNullable(_$BattleWinResultTypeEnumMap, v) ?? BattleWinResultType.normal),
          actionLogs: $checkedConvert('actionLogs', (v) => v as String? ?? ''),
          usedTurnArray:
              $checkedConvert('usedTurnArray', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
          recoverIds:
              $checkedConvert('recoverIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
          loopCount: $checkedConvert('loopCount', (v) => (v as num?)?.toInt() ?? 0),
          targetDrops: $checkedConvert(
              'targetDrops',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
          winTargetItemNum: $checkedConvert(
              'winTargetItemNum',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$AutoBattleOptionsToJson(AutoBattleOptions instance) => <String, dynamic>{
      'questId': instance.questId,
      'questPhase': instance.questPhase,
      'isHpHalf': instance.isHpHalf,
      'useEventDeck': instance.useEventDeck,
      'deckId': instance.deckId,
      'enfoceRefreshSupport': instance.enfoceRefreshSupport,
      'supportSvtIds': instance.supportSvtIds.toList(),
      'supportCeIds': instance.supportCeIds.toList(),
      'supportCeMaxLimitBreak': instance.supportCeMaxLimitBreak,
      'useCampaignItem': instance.useCampaignItem,
      'stopIfBondLimit': instance.stopIfBondLimit,
      'resultType': _$BattleResultTypeEnumMap[instance.resultType]!,
      'winType': _$BattleWinResultTypeEnumMap[instance.winType]!,
      'actionLogs': instance.actionLogs,
      'usedTurnArray': instance.usedTurnArray,
      'recoverIds': instance.recoverIds,
      'loopCount': instance.loopCount,
      'targetDrops': instance.targetDrops.map((k, e) => MapEntry(k.toString(), e)),
      'winTargetItemNum': instance.winTargetItemNum.map((k, e) => MapEntry(k.toString(), e)),
    };

const _$BattleResultTypeEnumMap = {
  BattleResultType.none: 'none',
  BattleResultType.win: 'win',
  BattleResultType.lose: 'lose',
  BattleResultType.cancel: 'cancel',
  BattleResultType.interruption: 'interruption',
};

const _$BattleWinResultTypeEnumMap = {
  BattleWinResultType.none: 'none',
  BattleWinResultType.normal: 'normal',
  BattleWinResultType.timeLimit: 'timeLimit',
  BattleWinResultType.lose: 'lose',
};
