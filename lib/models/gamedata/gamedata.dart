// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:chaldea/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../version.dart';
import 'command_code.dart';
import 'common.dart';
import 'const_data.dart';
import 'drop_rate.dart';
import 'event.dart';
import 'item.dart';
import 'mystic_code.dart';
import 'quest.dart';
import 'servant.dart';
import 'skill.dart';
import 'war.dart';
import 'wiki_data.dart';

export 'command_code.dart';
export 'common.dart';
export 'const_data.dart';
export 'drop_rate.dart';
export 'event.dart';
export 'item.dart';
export 'mystic_code.dart';
export 'quest.dart';
export 'script.dart';
export 'servant.dart';
export 'skill.dart';
export 'war.dart';
export 'wiki_data.dart';

part '../../generated/models/gamedata/gamedata.g.dart';

// part 'helpers/adapters.dart';

@JsonSerializable()
class GameData {
  DataVersion version;
  Map<int, Servant> servants;
  Map<int, CraftEssence> craftEssences;
  Map<int, CommandCode> commandCodes;
  Map<int, MysticCode> mysticCodes;
  Map<int, Event> events;
  Map<int, NiceWar> wars;
  Map<int, Item> items;
  Map<int, QuestPhase> questPhases;
  Map<int, ExchangeTicket> exchangeTickets;
  Map<int, BasicServant> entities;
  Map<int, Bgm> bgms;

  Map<String, LimitedSummon> summons;
  Map<int, FixedDrop> fixedDrops;
  WikiData wikiData;
  MappingData mappingData;
  ConstGameData constData;
  DropRateData dropRateData;
  Map<int, BaseSkill> baseSkills;
  Map<int, BaseFunction> baseFunctions;

  GameData({
    DataVersion? version,
    Map<int, Servant>? servants,
    Map<int, CraftEssence>? craftEssences,
    Map<int, CommandCode>? commandCodes,
    Map<int, MysticCode>? mysticCodes,
    Map<int, Event>? events,
    Map<int, NiceWar>? wars,
    Map<int, Item>? items,
    Map<int, QuestPhase>? questPhases,
    Map<int, ExchangeTicket>? exchangeTickets,
    Map<int, BasicServant>? entities,
    Map<int, Bgm>? bgms,
    Map<String, LimitedSummon>? summons,
    Map<int, FixedDrop>? fixedDrops,
    WikiData? wikiData,
    MappingData? mappingData,
    ConstGameData? constData,
    DropRateData? dropRateData,
    Map<int, BaseSkill>? baseSkills,
    Map<int, BaseFunction>? baseFunctions,
  })  : version = version ?? DataVersion(),
        servants = servants ?? {},
        craftEssences = craftEssences ?? {},
        commandCodes = commandCodes ?? {},
        mysticCodes = mysticCodes ?? {},
        events = events ?? {},
        wars = wars ?? {},
        items = items ?? {},
        questPhases = questPhases ?? {},
        exchangeTickets = exchangeTickets ?? {},
        entities = entities ?? {},
        bgms = bgms ?? {},
        summons = summons ?? {},
        fixedDrops = fixedDrops ?? {},
        wikiData = wikiData ?? WikiData(),
        mappingData = mappingData ?? MappingData(),
        constData = constData ?? ConstGameData.empty(),
        dropRateData = dropRateData ?? DropRateData(),
        baseSkills = baseSkills ?? {},
        baseFunctions = baseFunctions ?? {} {
    preprocess();
  }

  @JsonKey(ignore: true)
  late Map<int, Servant> servantsById;
  @JsonKey(ignore: true)
  late Map<int, CraftEssence> craftEssencesById;
  @JsonKey(ignore: true)
  late Map<int, CommandCode> commandCodesById;

  void preprocess() {
    servantsById = servants.map((key, value) => MapEntry(value.id, value));
    craftEssencesById =
        craftEssences.map((key, value) => MapEntry(value.id, value));
    commandCodesById =
        commandCodes.map((key, value) => MapEntry(value.id, value));
  }

  factory GameData.fromMergedFile(Map<String, dynamic> data) {
    Map<String, dynamic> data2 = Map.of(data);
    void _list2map(String key, {String? id, String Function(dynamic)? idFn}) {
      assert(id != null || idFn != null);
      idFn ??= (item) => item[id!]!.toString();
      data2[key] = Map.fromIterable(data2[key], key: idFn);
    }

    _list2map('servants', id: 'collectionNo');
    _list2map('commandCodes', id: 'collectionNo');
    _list2map('craftEssences', id: 'collectionNo');
    _list2map('events', id: 'id');
    _list2map('wars', id: 'id');
    _list2map('exchangeTickets', id: 'key');
    _list2map('items', id: 'id');
    _list2map('mysticCodes', id: 'id');
    _list2map('questPhases',
        idFn: (phase) => '${phase["id"]}/${phase["phase"]}');
    return GameData.fromJson(data2);
  }

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);
}

@JsonSerializable(createToJson: true)
class DataVersion {
  final int timestamp;
  final String utc;
  @protected
  final String minimalApp;
  final Map<String, FileVersion> files;

  DataVersion({
    this.timestamp = 0,
    this.utc = "",
    this.minimalApp = '1.0.0',
    this.files = const {},
  });

  AppVersion get appVersion => AppVersion.parse(minimalApp);

  factory DataVersion.fromJson(Map<String, dynamic> json) =>
      _$DataVersionFromJson(json);

  Map<String, dynamic> toJson() => _$DataVersionToJson(this);

  String text([bool twoLine = true]) {
    if (timestamp <= 0) return '0';
    String s =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toStringShort();
    if (twoLine) return s.replaceFirst(' ', '\n');
    return s;
  }

  @override
  String toString() {
    return 'DatVersion($utc, ${files.length} files)';
  }
}

@JsonSerializable(createToJson: true)
class FileVersion {
  String key;
  String filename;
  int size;
  int timestamp;
  String hash;

  FileVersion({
    required this.key,
    required this.filename,
    required this.size,
    required this.timestamp,
    required this.hash,
  });

  factory FileVersion.fromJson(Map<String, dynamic> json) =>
      _$FileVersionFromJson(json);

  Map<String, dynamic> toJson() => _$FileVersionToJson(this);
}
