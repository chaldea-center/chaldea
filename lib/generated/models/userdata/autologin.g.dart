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
          showProgressToast: $checkedConvert('showProgressToast', (v) => v as bool? ?? true),
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
      'showProgressToast': instance.showProgressToast,
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
          gacha: $checkedConvert(
              'gacha', (v) => v == null ? null : GachaOption.fromJson(Map<String, dynamic>.from(v as Map))),
          svtCombine: $checkedConvert(
              'svtCombine', (v) => v == null ? null : SvtCombineOption.fromJson(Map<String, dynamic>.from(v as Map))),
          presentBox: $checkedConvert('presentBox',
              (v) => v == null ? null : PresentBoxFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
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
      'gacha': instance.gacha.toJson(),
      'svtCombine': instance.svtCombine.toJson(),
      'presentBox': instance.presentBox.toJson(),
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
          gacha: $checkedConvert(
              'gacha', (v) => v == null ? null : GachaOption.fromJson(Map<String, dynamic>.from(v as Map))),
          svtCombine: $checkedConvert(
              'svtCombine', (v) => v == null ? null : SvtCombineOption.fromJson(Map<String, dynamic>.from(v as Map))),
          presentBox: $checkedConvert('presentBox',
              (v) => v == null ? null : PresentBoxFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
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
      'gacha': instance.gacha.toJson(),
      'svtCombine': instance.svtCombine.toJson(),
      'presentBox': instance.presentBox.toJson(),
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
          campaignItemId: $checkedConvert('campaignItemId', (v) => (v as num?)?.toInt() ?? 0),
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
          waitApRecoverGold: $checkedConvert('waitApRecoverGold', (v) => v as bool? ?? false),
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
      'campaignItemId': instance.campaignItemId,
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
      'waitApRecoverGold': instance.waitApRecoverGold,
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

GachaOption _$GachaOptionFromJson(Map json) => $checkedCreate(
      'GachaOption',
      json,
      ($checkedConvert) {
        final val = GachaOption(
          gachaId: $checkedConvert('gachaId', (v) => (v as num?)?.toInt() ?? 0),
          gachaSubId: $checkedConvert('gachaSubId', (v) => (v as num?)?.toInt() ?? 0),
          loopCount: $checkedConvert('loopCount', (v) => (v as num?)?.toInt() ?? 0),
          ceEnhanceBaseUserSvtIds: $checkedConvert(
              'ceEnhanceBaseUserSvtIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          ceEnhanceBaseSvtIds: $checkedConvert(
              'ceEnhanceBaseSvtIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          feedExp3: $checkedConvert('feedExp3', (v) => v as bool? ?? false),
          feedExp4: $checkedConvert('feedExp4', (v) => v as bool? ?? false),
          sellKeepSvtIds:
              $checkedConvert('sellKeepSvtIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          sellKeepCommandCodeIds: $checkedConvert(
              'sellKeepCommandCodeIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
        );
        return val;
      },
    );

Map<String, dynamic> _$GachaOptionToJson(GachaOption instance) => <String, dynamic>{
      'gachaId': instance.gachaId,
      'gachaSubId': instance.gachaSubId,
      'loopCount': instance.loopCount,
      'ceEnhanceBaseUserSvtIds': instance.ceEnhanceBaseUserSvtIds.toList(),
      'ceEnhanceBaseSvtIds': instance.ceEnhanceBaseSvtIds.toList(),
      'feedExp3': instance.feedExp3,
      'feedExp4': instance.feedExp4,
      'sellKeepSvtIds': instance.sellKeepSvtIds.toList(),
      'sellKeepCommandCodeIds': instance.sellKeepCommandCodeIds.toList(),
    };

SvtCombineOption _$SvtCombineOptionFromJson(Map json) => $checkedCreate(
      'SvtCombineOption',
      json,
      ($checkedConvert) {
        final val = SvtCombineOption(
          baseUserSvtId: $checkedConvert('baseUserSvtId', (v) => (v as num?)?.toInt() ?? 0),
          maxMaterialCount: $checkedConvert('maxMaterialCount', (v) => (v as num?)?.toInt() ?? 20),
          loopCount: $checkedConvert('loopCount', (v) => (v as num?)?.toInt() ?? 0),
          svtMaterialRarities: $checkedConvert(
              'svtMaterialRarities', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          doubleExp: $checkedConvert('doubleExp', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtCombineOptionToJson(SvtCombineOption instance) => <String, dynamic>{
      'baseUserSvtId': instance.baseUserSvtId,
      'maxMaterialCount': instance.maxMaterialCount,
      'loopCount': instance.loopCount,
      'svtMaterialRarities': instance.svtMaterialRarities.toList(),
      'doubleExp': instance.doubleExp,
    };

PresentBoxFilterData _$PresentBoxFilterDataFromJson(Map json) => $checkedCreate(
      'PresentBoxFilterData',
      json,
      ($checkedConvert) {
        final val = PresentBoxFilterData(
          reversed: $checkedConvert('reversed', (v) => v as bool? ?? false),
          maxNum: $checkedConvert('maxNum', (v) => (v as num?)?.toInt() ?? 0),
          presentTypes: $checkedConvert(
              'presentTypes',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecode(_$PresentTypeEnumMap, e, unknownValue: PresentType.servantExp))
                  .toSet()),
          rarities: $checkedConvert('rarities', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
        );
        return val;
      },
    );

Map<String, dynamic> _$PresentBoxFilterDataToJson(PresentBoxFilterData instance) => <String, dynamic>{
      'reversed': instance.reversed,
      'maxNum': instance.maxNum,
      'presentTypes': instance.presentTypes.map((e) => _$PresentTypeEnumMap[e]!).toList(),
      'rarities': instance.rarities.toList(),
    };

const _$PresentTypeEnumMap = {
  PresentType.servant: 'servant',
  PresentType.servantExp: 'servantExp',
  PresentType.statusUp: 'statusUp',
  PresentType.svtEquip: 'svtEquip',
  PresentType.svtEquipExp: 'svtEquipExp',
  PresentType.commandCode: 'commandCode',
  PresentType.fruit: 'fruit',
  PresentType.summonTicket: 'summonTicket',
  PresentType.itemSelect: 'itemSelect',
  PresentType.stone: 'stone',
  PresentType.manaPrism: 'manaPrism',
  PresentType.eventItem: 'eventItem',
  PresentType.others: 'others',
};
