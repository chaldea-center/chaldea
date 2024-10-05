// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/autologin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FakerSettings _$FakerSettingsFromJson(Map json) => $checkedCreate(
      'FakerSettings',
      json,
      ($checkedConvert) {
        final val = FakerSettings(
          dumpResponse: $checkedConvert('dumpResponse', (v) => v as bool? ?? false),
          apRecoveredNotification: $checkedConvert('apRecoveredNotification', (v) => v as bool? ?? false),
          maxFollowerListRetryCount: $checkedConvert('maxFollowerListRetryCount', (v) => (v as num?)?.toInt() ?? 20),
          jpAutoLogins: $checkedConvert(
              'jpAutoLogins',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoLoginDataJP.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          cnAutoLogins: $checkedConvert(
              'cnAutoLogins',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoLoginDataCN.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$FakerSettingsToJson(FakerSettings instance) => <String, dynamic>{
      'dumpResponse': instance.dumpResponse,
      'apRecoveredNotification': instance.apRecoveredNotification,
      'maxFollowerListRetryCount': instance.maxFollowerListRetryCount,
      'jpAutoLogins': instance.jpAutoLogins.map((e) => e.toJson()).toList(),
      'cnAutoLogins': instance.cnAutoLogins.map((e) => e.toJson()).toList(),
    };

AuthSaveData _$AuthSaveDataFromJson(Map json) => $checkedCreate(
      'AuthSaveData',
      json,
      ($checkedConvert) {
        final val = AuthSaveData(
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

Map<String, dynamic> _$AuthSaveDataToJson(AuthSaveData instance) => <String, dynamic>{
      'source': instance.source,
      'code': instance.code,
      'userId': instance.userId,
      'authKey': instance.authKey,
      'secretKey': instance.secretKey,
      'saveDataVer': instance.saveDataVer,
      'userCreateServer': instance.userCreateServer,
    };

AutoLoginDataJP _$AutoLoginDataJPFromJson(Map json) => $checkedCreate(
      'AutoLoginDataJP',
      json,
      ($checkedConvert) {
        final val = AutoLoginDataJP(
          priority: $checkedConvert('priority', (v) => (v as num?)?.toInt() ?? 0),
          region:
              $checkedConvert('region', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
          auth: $checkedConvert(
              'auth', (v) => v == null ? null : AuthSaveData.fromJson(Map<String, dynamic>.from(v as Map))),
          deviceInfo: $checkedConvert('deviceInfo', (v) => v as String?),
          country:
              $checkedConvert('country', (v) => $enumDecodeNullable(_$NACountryEnumMap, v) ?? NACountry.unitedStates),
          userAgent: $checkedConvert('userAgent', (v) => v as String? ?? ''),
          curBattleOptionIndex: $checkedConvert('curBattleOptionIndex', (v) => (v as num?)?.toInt()),
          battleOptions: $checkedConvert(
              'battleOptions',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoBattleOptions.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          recoveredAps:
              $checkedConvert('recoveredAps', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          lastLogin: $checkedConvert('lastLogin', (v) => (v as num?)?.toInt()),
          userGame: $checkedConvert(
              'userGame', (v) => v == null ? null : UserGameEntity.fromJson(Map<String, dynamic>.from(v as Map))),
          userItems: $checkedConvert(
              'userItems',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$AutoLoginDataJPToJson(AutoLoginDataJP instance) => <String, dynamic>{
      'priority': instance.priority,
      'region': const RegionConverter().toJson(instance.region),
      'userAgent': instance.userAgent,
      'curBattleOptionIndex': instance.curBattleOptionIndex,
      'battleOptions': instance.battleOptions.map((e) => e.toJson()).toList(),
      'recoveredAps': instance.recoveredAps.toList(),
      'lastLogin': instance.lastLogin,
      'userGame': instance.userGame?.toJson(),
      'userItems': instance.userItems.map((k, e) => MapEntry(k.toString(), e)),
      'auth': instance.auth?.toJson(),
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

AutoLoginDataCN _$AutoLoginDataCNFromJson(Map json) => $checkedCreate(
      'AutoLoginDataCN',
      json,
      ($checkedConvert) {
        final val = AutoLoginDataCN(
          priority: $checkedConvert('priority', (v) => (v as num?)?.toInt() ?? 0),
          region:
              $checkedConvert('region', (v) => v == null ? Region.cn : const RegionConverter().fromJson(v as String)),
          gameServer: $checkedConvert(
              'gameServer', (v) => $enumDecodeNullable(_$BiliGameServerEnumMap, v) ?? BiliGameServer.android),
          isAndroidDevice: $checkedConvert('isAndroidDevice', (v) => v as bool? ?? true),
          uid: $checkedConvert('uid', (v) => (v as num?)?.toInt() ?? 0),
          accessToken: $checkedConvert('accessToken', (v) => v as String? ?? ''),
          username: $checkedConvert('username', (v) => v as String? ?? ''),
          nickname: $checkedConvert('nickname', (v) => v as String? ?? ''),
          deviceId: $checkedConvert('deviceId', (v) => v as String? ?? ''),
          os: $checkedConvert('os', (v) => v as String? ?? ''),
          ptype: $checkedConvert('ptype', (v) => v as String? ?? ''),
          userAgent: $checkedConvert('userAgent', (v) => v as String? ?? ''),
          curBattleOptionIndex: $checkedConvert('curBattleOptionIndex', (v) => (v as num?)?.toInt()),
          battleOptions: $checkedConvert(
              'battleOptions',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoBattleOptions.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          recoveredAps:
              $checkedConvert('recoveredAps', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          lastLogin: $checkedConvert('lastLogin', (v) => (v as num?)?.toInt()),
          userGame: $checkedConvert(
              'userGame', (v) => v == null ? null : UserGameEntity.fromJson(Map<String, dynamic>.from(v as Map))),
          userItems: $checkedConvert(
              'userItems',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$AutoLoginDataCNToJson(AutoLoginDataCN instance) => <String, dynamic>{
      'priority': instance.priority,
      'userAgent': instance.userAgent,
      'curBattleOptionIndex': instance.curBattleOptionIndex,
      'battleOptions': instance.battleOptions.map((e) => e.toJson()).toList(),
      'recoveredAps': instance.recoveredAps.toList(),
      'lastLogin': instance.lastLogin,
      'userGame': instance.userGame?.toJson(),
      'userItems': instance.userItems.map((k, e) => MapEntry(k.toString(), e)),
      'region': const RegionConverter().toJson(instance.region),
      'gameServer': _$BiliGameServerEnumMap[instance.gameServer]!,
      'isAndroidDevice': instance.isAndroidDevice,
      'uid': instance.uid,
      'accessToken': instance.accessToken,
      'username': instance.username,
      'nickname': instance.nickname,
      'deviceId': instance.deviceId,
      'os': instance.os,
      'ptype': instance.ptype,
    };

const _$BiliGameServerEnumMap = {
  BiliGameServer.ios: 'ios',
  BiliGameServer.android: 'android',
  BiliGameServer.uo: 'uo',
};

AutoBattleOptions _$AutoBattleOptionsFromJson(Map json) => $checkedCreate(
      'AutoBattleOptions',
      json,
      ($checkedConvert) {
        final val = AutoBattleOptions(
          name: $checkedConvert('name', (v) => v as String? ?? ''),
          questId: $checkedConvert('questId', (v) => (v as num?)?.toInt() ?? 0),
          questPhase: $checkedConvert('questPhase', (v) => (v as num?)?.toInt() ?? 0),
          useEventDeck: $checkedConvert('useEventDeck', (v) => v as bool?),
          isApHalf: $checkedConvert('isApHalf', (v) => v as bool? ?? false),
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
          waitApRecover: $checkedConvert('waitApRecover', (v) => v as bool? ?? false),
        );
        $checkedConvert('battleDuration', (v) => val.battleDuration = (v as num?)?.toInt());
        return val;
      },
    );

Map<String, dynamic> _$AutoBattleOptionsToJson(AutoBattleOptions instance) => <String, dynamic>{
      'name': instance.name,
      'questId': instance.questId,
      'questPhase': instance.questPhase,
      'isApHalf': instance.isApHalf,
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
      'battleDuration': instance.battleDuration,
      'waitApRecover': instance.waitApRecover,
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
