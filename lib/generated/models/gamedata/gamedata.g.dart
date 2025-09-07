// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/gamedata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map json) => GameData(
  version: json['version'] == null ? null : DataVersion.fromJson(Map<String, dynamic>.from(json['version'] as Map)),
  items: (json['items'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), Item.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  bgms: (json['bgms'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), BgmEntity.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  entities: (json['entities'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), BasicServant.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  baseFunctions: (json['baseFunctions'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), BaseFunction.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  baseSkills: (json['baseSkills'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), BaseSkill.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  baseTds: (json['baseTds'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), BaseTd.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  servants:
      (json['servants'] as List<dynamic>?)
          ?.map((e) => Servant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  craftEssences:
      (json['craftEssences'] as List<dynamic>?)
          ?.map((e) => CraftEssence.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  commandCodes:
      (json['commandCodes'] as List<dynamic>?)
          ?.map((e) => CommandCode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  mysticCodes: (json['mysticCodes'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), MysticCode.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  campaigns: (json['campaigns'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), Event.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  events: (json['events'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), Event.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  wars: (json['wars'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), NiceWar.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  classBoards: (json['classBoards'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), ClassBoard.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  grandGraphs: (json['grandGraphs'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), GrandGraph.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  questPhases: (json['questPhases'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), QuestPhase.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  exchangeTickets: (json['exchangeTickets'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), ExchangeTicket.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  enemyMasters: (json['enemyMasters'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), EnemyMaster.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  masterMissions: (json['masterMissions'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), MstMasterMission.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  extraMasterMission: (json['extraMasterMission'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), MasterMission.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  questGroups: (json['questGroups'] as List<dynamic>?)
      ?.map((e) => QuestGroup.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  questPhaseDetails: (json['questPhaseDetails'] as List<dynamic>?)
      ?.map((e) => BasicQuestPhaseDetail.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  gachas: (json['gachas'] as Map?)?.map(
    (k, e) => MapEntry(int.parse(k as String), NiceGacha.fromJson(Map<String, dynamic>.from(e as Map))),
  ),
  wiki: json['wiki'] == null ? null : WikiData.fromJson(Map<String, dynamic>.from(json['wiki'] as Map)),
  mappingData: json['mappingData'] == null
      ? null
      : MappingData.fromJson(Map<String, dynamic>.from(json['mappingData'] as Map)),
  constData: json['constData'] == null
      ? null
      : ConstGameData.fromJson(Map<String, dynamic>.from(json['constData'] as Map)),
  dropData: json['dropData'] == null ? null : DropData.fromJson(Map<String, dynamic>.from(json['dropData'] as Map)),
  addData: json['addData'] == null ? null : GameDataAdd.fromJson(Map<String, dynamic>.from(json['addData'] as Map)),
  spoilerRegion: _$JsonConverterFromJson<String, Region>(json['spoilerRegion'], const RegionConverter().fromJson),
  removeOldDataRegion: _$JsonConverterFromJson<String, Region>(
    json['removeOldDataRegion'],
    const RegionConverter().fromJson,
  ),
);

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

GameDataAdd _$GameDataAddFromJson(Map json) => GameDataAdd(
  svts: (json['svts'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  ces: (json['ces'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  ccs: (json['ccs'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  items: (json['items'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  events: (json['events'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  wars: (json['wars'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
);

DataVersion _$DataVersionFromJson(Map json) => DataVersion(
  timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
  utc: json['utc'] as String? ?? "",
  minimalApp: json['minimalApp'] as String? ?? '1.0.0',
  files:
      (json['files'] as Map?)?.map(
        (k, e) => MapEntry(k as String, FileVersion.fromJson(Map<String, dynamic>.from(e as Map))),
      ) ??
      const {},
);

Map<String, dynamic> _$DataVersionToJson(DataVersion instance) => <String, dynamic>{
  'timestamp': instance.timestamp,
  'utc': instance.utc,
  'minimalApp': instance.minimalApp,
  'files': instance.files.map((k, e) => MapEntry(k, e.toJson())),
};

FileVersion _$FileVersionFromJson(Map json) => FileVersion(
  key: json['key'] as String,
  filename: json['filename'] as String,
  size: (json['size'] as num).toInt(),
  timestamp: (json['timestamp'] as num).toInt(),
  hash: json['hash'] as String,
  minSize: (json['minSize'] as num).toInt(),
  minHash: json['minHash'] as String,
);

Map<String, dynamic> _$FileVersionToJson(FileVersion instance) => <String, dynamic>{
  'key': instance.key,
  'filename': instance.filename,
  'size': instance.size,
  'timestamp': instance.timestamp,
  'hash': instance.hash,
  'minSize': instance.minSize,
  'minHash': instance.minHash,
};

GameTops _$GameTopsFromJson(Map json) => GameTops(
  jp: GameTop.fromJson(Map<String, dynamic>.from(json['JP'] as Map)),
  na: GameTop.fromJson(Map<String, dynamic>.from(json['NA'] as Map)),
  cn: GameTop.fromJson(Map<String, dynamic>.from(json['CN'] as Map)),
);

Map<String, dynamic> _$GameTopsToJson(GameTops instance) => <String, dynamic>{
  'JP': instance.jp.toJson(),
  'NA': instance.na.toJson(),
  'CN': instance.cn.toJson(),
};

GameAppVerCode _$GameAppVerCodeFromJson(Map json) =>
    GameAppVerCode(appVer: json['appVer'] as String, verCode: json['verCode'] as String? ?? "");

Map<String, dynamic> _$GameAppVerCodeToJson(GameAppVerCode instance) => <String, dynamic>{
  'appVer': instance.appVer,
  'verCode': instance.verCode,
};

GameTop _$GameTopFromJson(Map json) => GameTop(
  region: const RegionConverter().fromJson(json['region'] as String),
  gameServer: json['gameServer'] as String,
  appVer: json['appVer'] as String,
  verCode: json['verCode'] as String? ?? "",
  hash: json['hash'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  serverHash: json['serverHash'] as String,
  serverTimestamp: (json['serverTimestamp'] as num).toInt(),
  dataVer: (json['dataVer'] as num).toInt(),
  dateVer: (json['dateVer'] as num?)?.toInt() ?? 0,
  assetbundleFolder: json['assetbundleFolder'] as String? ?? "",
  unityVer: json['unityVer'] as String?,
);

Map<String, dynamic> _$GameTopToJson(GameTop instance) => <String, dynamic>{
  'appVer': instance.appVer,
  'verCode': instance.verCode,
  'region': const RegionConverter().toJson(instance.region),
  'gameServer': instance.gameServer,
  'hash': instance.hash,
  'timestamp': instance.timestamp,
  'serverHash': instance.serverHash,
  'serverTimestamp': instance.serverTimestamp,
  'dataVer': instance.dataVer,
  'dateVer': instance.dateVer,
  'assetbundleFolder': instance.assetbundleFolder,
  'unityVer': instance.unityVer,
};

AssetBundleDecrypt _$AssetBundleDecryptFromJson(Map json) => AssetBundleDecrypt(
  folderName: json['folderName'] as String,
  animalName: json['animalName'] as String,
  zooName: json['zooName'] as String,
);

Map<String, dynamic> _$AssetBundleDecryptToJson(AssetBundleDecrypt instance) => <String, dynamic>{
  'folderName': instance.folderName,
  'animalName': instance.animalName,
  'zooName': instance.zooName,
};

GameTimerData _$GameTimerDataFromJson(Map json) => GameTimerData(
  updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
  hash: json['hash'] as String?,
  timestamp: (json['timestamp'] as num?)?.toInt(),
  events:
      (json['events'] as List<dynamic>?)?.map((e) => Event.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  gachas:
      (json['gachas'] as List<dynamic>?)
          ?.map((e) => NiceGacha.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  masterMissions:
      (json['masterMissions'] as List<dynamic>?)
          ?.map((e) => MasterMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  shops:
      (json['shops'] as List<dynamic>?)?.map((e) => NiceShop.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  items:
      (json['items'] as List<dynamic>?)?.map((e) => Item.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  constants: json['constants'] == null
      ? null
      : GameConstants.fromJson(Map<String, dynamic>.from(json['constants'] as Map)),
);
