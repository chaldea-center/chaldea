// ignore_for_file: constant_identifier_names, non_constant_identifier_names

library gamedata;

import 'package:chaldea/components/utils.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as pathlib;

import '../version.dart';

part 'command_code.dart';

part 'common.dart';

part 'craft_essence.dart';

part 'enums.dart';

part 'event.dart';

part 'extra_data.dart';

part 'gamedata.g.dart';

part 'item.dart';

part 'mystic_code.dart';

part 'quest.dart';

part 'script.dart';

part 'servant.dart';

part 'skill.dart';

part 'war.dart';

@JsonSerializable()
class GameData {
  final DataVersion version;
  final Map<int, Servant> servants;
  final Map<int, CraftEssence> craftEssences;
  final Map<int, CommandCode> commandCodes;
  final Map<int, MysticCode> mysticCodes;
  final Map<int, Event> events;
  final Map<int, NiceWar> wars;
  final Map<int, Item> items;
  final Map<String, Map<int, int>> fixedDrops;
  final ExtraData extraData;
  final Map<int, ExchangeTicket> exchangeTickets;
  final Map<String, QuestPhase> questPhases;
  final MappingData mappingData;
  final ConstGameData constData;
  final DropRateData dropRateData;

  GameData({
    this.version = const DataVersion(),
    this.servants = const {},
    this.craftEssences = const {},
    this.commandCodes = const {},
    this.mysticCodes = const {},
    this.events = const {},
    this.wars = const {},
    this.items = const {},
    this.fixedDrops = const {},
    this.extraData = const ExtraData(),
    this.exchangeTickets = const {},
    this.questPhases = const {},
    this.mappingData = const MappingData(),
    this.constData = const ConstGameData(),
    this.dropRateData = const DropRateData(),
  });

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  static Future<GameData> readFromFolder(String folder) async {
    Map<String, dynamic> srcData = {};

    Future<dynamic> _readJson(String key, {String? fn, String? l2mKey}) async {
      final contents =
          await FilePlus(pathlib.join(folder, (fn ?? key) + '.json'))
              .readAsString();
      dynamic decoded = await readAndDecodeJsonAsync(contents: contents);
      if (l2mKey != null) {
        decoded = Map.fromIterable(decoded, key: (x) => x[l2mKey].toString());
      }
      print('finish reading $key');
      return srcData[key] = decoded;
    }

    await Future.wait([
      _readJson('version'),
      _readJson('servants', l2mKey: 'collectionNo'),
      _readJson('craftEssences', fn: 'craft_essences', l2mKey: 'collectionNo'),
      _readJson('commandCodes', fn: 'command_codes', l2mKey: 'collectionNo'),
      _readJson('mysticCodes', fn: 'mystic_codes', l2mKey: 'id'),
      _readJson('events', l2mKey: 'id'),
      _readJson('wars', l2mKey: 'id'),
      _readJson('items', l2mKey: 'id'),
      _readJson('fixedDrops', fn: 'fixed_drops'),
      _readJson('extraData', fn: 'extra_data'),
      _readJson('exchangeTickets', fn: 'exchange_tickets'),
      _readJson('questPhases', fn: 'quest_phases'),
      _readJson('mappingData', fn: 'mapping_data'),
      _readJson('constData', fn: 'const_data'),
    ]);

    return GameData.fromJson(srcData);
  }
}

@JsonSerializable()
class ExchangeTicket {
  final int key;
  final int year;
  final int month;
  final List<int> items;

  ExchangeTicket({
    required this.key,
    required this.year,
    required this.month,
    required this.items,
  });

  factory ExchangeTicket.fromJson(Map<String, dynamic> json) =>
      _$ExchangeTicketFromJson(json);
}

@JsonSerializable()
class ConstGameData {
  final Map<SvtClass, Map<SvtClass, int>> classRelation;
  final Map<SvtClass, int> classAttackRate;

  // rarity, lv, {qp,addLvMax,frameType}
  final Map<int, Map<int, Map>> svtGrailCost;

  // "requiredExp": 0,
  // "maxAp": 20,
  // "maxCost": 25,
  // "maxFriend": 28,
  // "gift": null
  final Map<int, Map> userLevel;
  final Map<CardType, Map<int, Map>> cardInfo;

  const ConstGameData({
    this.classRelation = const {},
    this.classAttackRate = const {},
    this.svtGrailCost = const {},
    this.userLevel = const {},
    this.cardInfo = const {},
  });

  factory ConstGameData.fromJson(Map<String, dynamic> json) =>
      _$ConstGameDataFromJson(json);
}

@JsonSerializable()
class DataVersion {
  final int timestamp;
  final String utc;
  @JsonKey(fromJson: DataVersion._parseAppVersion)
  final AppVersion minimalApp;
  final Map<String, DatFileVersion> files;

  const DataVersion({
    this.timestamp = 0,
    this.utc = "",
    this.minimalApp = const AppVersion(0, 0, 0),
    this.files = const {},
  });

  factory DataVersion.fromJson(Map<String, dynamic> json) =>
      _$DataVersionFromJson(json);

  static AppVersion _parseAppVersion(String s) => AppVersion.parse(s);
}

@JsonSerializable()
class DatFileVersion {
  int timestamp;
  String hash;

  DatFileVersion({
    required this.timestamp,
    required this.hash,
  });

  factory DatFileVersion.fromJson(Map<String, dynamic> json) =>
      _$DatFileVersionFromJson(json);
}

@JsonSerializable()
class MappingData {
  final Map<String, MappingBase<String>> itemNames;
  final Map<String, MappingBase<String>> mcNames;
  final Map<String, MappingBase<String>> costumeNames;
  final Map<String, MappingBase<String>> cvNames;
  final Map<String, MappingBase<String>> illustratorNames;
  final Map<String, MappingBase<String>> ccNames;
  final Map<String, MappingBase<String>> svtNames;
  final Map<String, MappingBase<String>> ceNames;
  final Map<String, MappingBase<String>> eventNames;
  final Map<String, MappingBase<String>> warNames;
  final Map<String, MappingBase<String>> questNames;
  final Map<String, MappingBase<String>> spotNames;
  final Map<String, MappingBase<String>> entityNames;
  final Map<String, MappingBase<String>> tdTypes;
  final Map<String, MappingBase<String>> bgmNames;
  final Map<String, MappingBase<String>> summonNames;
  final Map<String, MappingBase<String>> charaNames;
  final Map<String, MappingBase<String>> buffNames;
  final Map<String, MappingBase<String>> buffDetail;
  final Map<String, MappingBase<String>> funcPopuptext;
  final Map<String, MappingBase<String>> skillNames;
  final Map<String, MappingBase<String>> skillDetail;
  final Map<String, MappingBase<String>> tdNames;
  final Map<String, MappingBase<String>> tdRuby;
  final Map<String, MappingBase<String>> tdDetail;
  final Map<int, MappingBase<String>> trait;
  final Map<int, MappingBase<String>> mcDetail;
  final Map<int, MappingBase<String>> costumeDetail;
  final Map<int, MappingBase<Map<int, int>>> skillState;
  final Map<int, MappingBase<Map<int, int>>> tdState;

  const MappingData({
    this.itemNames = const {},
    this.mcNames = const {},
    this.costumeNames = const {},
    this.cvNames = const {},
    this.illustratorNames = const {},
    this.ccNames = const {},
    this.svtNames = const {},
    this.ceNames = const {},
    this.eventNames = const {},
    this.warNames = const {},
    this.questNames = const {},
    this.spotNames = const {},
    this.entityNames = const {},
    this.tdTypes = const {},
    this.bgmNames = const {},
    this.summonNames = const {},
    this.charaNames = const {},
    this.buffNames = const {},
    this.buffDetail = const {},
    this.funcPopuptext = const {},
    this.skillNames = const {},
    this.skillDetail = const {},
    this.tdNames = const {},
    this.tdRuby = const {},
    this.tdDetail = const {},
    this.trait = const {},
    this.mcDetail = const {},
    this.costumeDetail = const {},
    this.skillState = const {},
    this.tdState = const {},
  });

  factory MappingData.fromJson(Map<String, dynamic> json) {
    String _convertKey(String key) {
      return key.replaceAllMapped(
          RegExp(r'_([a-z])'), (match) => match.group(1)!.toUpperCase());
    }

    final json2 = {for (var e in json.entries) _convertKey(e.key): e.value};
    return _$MappingDataFromJson(json2);
  }
}

@JsonSerializable()
class MappingBase<T> {
  @JsonKey(name: 'JP')
  T? jp;
  @JsonKey(name: 'CN')
  T? cn;
  @JsonKey(name: 'TW')
  T? tw;
  @JsonKey(name: 'NA')
  T? na;
  @JsonKey(name: 'KR')
  T? kr;

  MappingBase({
    this.jp,
    this.cn,
    this.tw,
    this.na,
    this.kr,
  });

  factory MappingBase.fromJson(Map<String, dynamic> json) =>
      _$MappingBaseFromJson(json, _fromJsonT);

  static T _fromJsonT<T>(Object? obj) {
    if (obj == null) return null as T;
    if (obj is int || obj is double || obj is String) return obj as T;
    // Map<int,int>
    if (obj is Map) {
      if (obj.isEmpty) return Map.from(obj) as T;
      if (obj.values.first is int) {
        return <int, int>{for (var e in obj.entries) int.parse(e.key): e.value}
            as T;
      }
    }
    if (obj is List) {
      // List<LoreComment>
      if (obj.isEmpty) return List.from(obj) as T;
      final _first = obj.first;
      if (_first is Map &&
          _first.keys
              .toSet()
              .containsAll(['id', 'priority', 'condMessage', 'condType'])) {
        return obj.map((e) => LoreComment.fromJson(e)).toList() as T;
      }
    }
    return obj as T;
  }
}

@JsonSerializable()
class DropRateData {
  final DropRateSheet newData;
  final DropRateSheet legacyData;

  const DropRateData(
      {this.newData = const DropRateSheet(),
      this.legacyData = const DropRateSheet()});

  factory DropRateData.fromJson(Map<String, dynamic> json) =>
      _$DropRateDataFromJson(json);
}

@JsonSerializable()
class DropRateSheet {
  final List<int> questIds;
  final List<int> itemIds;
  final List<int> apCosts;
  final List<int> runs;

  /// drop rate, not ap rate
  @protected
  final Map<int, Map<int, double>> sparseMatrix;

  const DropRateSheet({
    this.questIds = const [],
    this.itemIds = const [],
    this.apCosts = const [],
    this.runs = const [],
    this.sparseMatrix = const {},
  });

  factory DropRateSheet.fromJson(Map<String, dynamic> json) =>
      _$DropRateSheetFromJson(json);
}
