// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/utils/extension.dart';
import '../version.dart';
import 'command_code.dart';
import 'common.dart';
import 'const_data.dart';
import 'drop_rate.dart';
import 'event.dart';
import 'item.dart';
import 'mappings.dart';
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
export 'game_card.dart';
export 'item.dart';
export 'mappings.dart';
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

  Map<int, FixedDrop> fixedDrops;
  WikiData wiki;
  MappingData mappingData;
  ConstGameData constData;
  DropRateData dropRate;
  Map<int, BaseSkill> baseSkills;
  Map<int, BaseTd> baseTds;
  Map<int, BaseFunction> baseFunctions;

  @JsonKey(ignore: true)
  late _ProcessedData others;
  @JsonKey(ignore: true)
  Map<int, NiceCostume> costumes = {};

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
    Map<int, FixedDrop>? fixedDrops,
    WikiData? wiki,
    MappingData? mappingData,
    ConstGameData? constData,
    DropRateData? dropRate,
    Map<int, BaseTd>? baseTds,
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
        fixedDrops = fixedDrops ?? {},
        wiki = wiki ?? WikiData(),
        mappingData = mappingData ?? MappingData(),
        constData = constData ?? ConstGameData.empty(),
        dropRate = dropRate ?? DropRateData(),
        baseTds = baseTds ?? {},
        baseSkills = baseSkills ?? {},
        baseFunctions = baseFunctions ?? {} {
    preprocess();
    others = _ProcessedData(this);
  }

  @JsonKey(ignore: true)
  late Map<int, NiceWar> mainStories;
  @JsonKey(ignore: true)
  late Map<int, NiceSpot> spots;
  @JsonKey(ignore: true)
  late Map<int, Quest> quests;

  @JsonKey(ignore: true)
  late Map<int, Servant> servantsById;
  @JsonKey(ignore: true)
  late Map<int, CraftEssence> craftEssencesById;
  @JsonKey(ignore: true)
  late Map<int, CommandCode> commandCodesById;

  void preprocess() {
    items[Items.grailToCrystalId] = Item(
      id: Items.grailToCrystalId,
      name: '聖杯→伝承結晶',
      type: ItemType.none,
      detail: '既にクリアした復刻イベントで、聖杯がクリア報酬だったクエストでは、報酬が伝承結晶に置き換わる。',
      icon: 'https://static.atlasacademy.io/JP/Items/19.png',
      background: ItemBGType.zero,
      priority: 299,
      dropPriority: 8900,
    );
    costumes = {
      for (final svt in servants.values)
        for (final costume in svt.profile.costume.values)
          costume.costumeCollectionNo: costume
    };
    mainStories = {
      for (final war in wars.values)
        if (war.isMainStory) war.id: war
    };
    spots = {
      for (final war in wars.values)
        for (final spot in war.spots) spot.id: spot
    };
    quests = {
      for (final spot in spots.values)
        for (final quest in spot.quests) quest.id: quest
    };
    servantsById = servants.map((key, value) => MapEntry(value.id, value));
    craftEssencesById =
        craftEssences.map((key, value) => MapEntry(value.id, value));
    commandCodesById =
        commandCodes.map((key, value) => MapEntry(value.id, value));
    // calculation at last
    for (final war in wars.values) {
      war.calcItems(this);
    }
    for (final event in events.values) {
      event.calcItems(this);
    }
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

  QuestPhase? getQuestPhase(int id, [int? phase]) {
    if (phase != null) return questPhases[id * 100 + phase];
    return questPhases[id * 100 + 1] ?? questPhases[id * 100 + 3];
  }
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
    String s = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        .toStringShort(omitSec: true);
    if (twoLine) return s.replaceFirst(' ', '\n');
    return s;
  }

  @override
  String toString() {
    return '$runtimeType($utc, ${files.length} files)';
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

class _ProcessedData {
  final GameData gameData;
  _ProcessedData(this.gameData) {
    for (final svt in gameData.servants.values) {
      for (final costume in svt.profile.costume.values) {
        costumeSvtMap[costume.costumeCollectionNo] = svt;
      }
    }
    _initFuncBuff();
  }
  Map<int, Servant> costumeSvtMap = {};

  Set<FuncType> svtFuncs = {};
  Set<BuffType> svtBuffs = {};
  Set<FuncType> ceFuncs = {};
  Set<BuffType> ceBuffs = {};
  Set<FuncType> ccFuncs = {};
  Set<BuffType> ccBuffs = {};

  void _initFuncBuff() {
    for (final svt in gameData.servants.values) {
      for (final skill in [
        ...svt.skills,
        ...svt.noblePhantasms,
        ...svt.classPassive,
        ...svt.appendPassive.map((e) => e.skill)
      ]) {
        for (final func in NiceFunction.filterFuncs(
            funcs: skill.functions, showPlayer: true, showEnemy: false)) {
          svtFuncs.add(func.funcType);
          svtBuffs.addAll(func.buffs.map((e) => e.type));
        }
      }
    }
    for (final ce in gameData.craftEssences.values) {
      for (final skill in ce.skills) {
        for (final func in NiceFunction.filterFuncs(
            funcs: skill.functions, showPlayer: true, showEnemy: false)) {
          ceFuncs.add(func.funcType);
          ceBuffs.addAll(func.buffs.map((e) => e.type));
        }
      }
    }
    for (final ce in gameData.craftEssences.values) {
      for (final skill in ce.skills) {
        for (final func in NiceFunction.filterFuncs(
            funcs: skill.functions, showPlayer: true, showEnemy: false)) {
          ccFuncs.add(func.funcType);
          ceBuffs.addAll(func.buffs.map((e) => e.type));
        }
      }
    }
  }
}
