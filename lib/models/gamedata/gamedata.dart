// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';

import 'package:chaldea/utils/extension.dart';
import '../userdata/version.dart';
import '_helper.dart';
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
export 'reverse.dart';

part '../../generated/models/gamedata/gamedata.g.dart';

// part 'helpers/adapters.dart';

@JsonSerializable()
class GameData with _GameDataExtra {
  DataVersion version;
  @protected
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
  Map<int, BgmEntity> bgms;
  Map<int, MasterMission> extraMasterMission;

  Map<int, FixedDrop> fixedDrops;
  WikiData wiki;
  MappingData mappingData;
  ConstGameData constData;
  DropRateData dropRate;
  Map<int, BaseSkill> baseSkills;
  Map<int, BaseTd> baseTds;
  Map<int, BaseFunction> baseFunctions;

  Map<int, Servant> get servantsNoDup => servants;
  bool get isValid =>
      version.timestamp > 0 && servantsById.isNotEmpty && items.length > 1;

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
    Map<int, BgmEntity>? bgms,
    Map<int, MasterMission>? extraMasterMission,
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
        extraMasterMission = extraMasterMission ?? {},
        fixedDrops = fixedDrops ?? {},
        wiki = wiki ?? WikiData(),
        mappingData = mappingData ?? MappingData(),
        constData = constData ?? ConstGameData.empty(),
        dropRate = dropRate ?? DropRateData(),
        baseTds = baseTds ?? {},
        baseSkills = baseSkills ?? {},
        baseFunctions = baseFunctions ?? {} {
    for (final func in this.baseFunctions.values) {
      for (final buff in func.buffs) {
        baseBuffs[buff.id] = buff;
      }
    }
    preprocess();
  }

  void preprocess() {
    updateDupServants({});
    items[Items.grailToCrystalId] = Item(
      id: Items.grailToCrystalId,
      name: '聖杯→伝承結晶',
      type: ItemType.none,
      detail: '既にクリアした復刻イベントで、聖杯がクリア報酬だったクエストでは、報酬が伝承結晶に置き換わる。',
      icon: 'https://static.atlasacademy.io/JP/Items/19.png',
      background: ItemBGType.zero,
      priority: 395,
      dropPriority: 8900,
    );
    costumes = {
      for (final svt in servants.values)
        for (final costume in svt.profile.costume.values)
          costume.costumeCollectionNo: costume
    };
    costumesById = {
      for (final costume in costumes.values) costume.battleCharaId: costume
    };
    mainStories = {
      for (final war in wars.values)
        if (war.isMainStory) war.id: war
    };
    spots = {
      for (final war in wars.values)
        for (final spot in war.spots) spot.id: spot
    };
    maps = {
      for (final war in wars.values)
        for (final map in war.maps) map.id: map
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
    others = _ProcessedData(this);
  }

  void updateDupServants(Map<int, int> dupServants) {
    servantsWithDup = Map.of(servants);
    dupServants.forEach((customId, originId) {
      if (servantsWithDup.containsKey(customId)) return;
      final svt = servantsWithDup[originId];
      if (svt == null) return;
      servantsWithDup[customId] = svt.copyWith(collectionNo: customId);
    });
  }

  QuestPhase? getQuestPhase(int id, [int? phase]) {
    if (phase != null) return questPhases[id * 100 + phase];
    return questPhases[id * 100 + 1] ?? questPhases[id * 100 + 3];
  }

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);

  static Future<GameData> fromJsonAsync(Map<String, dynamic> json) async {
    return GameData(
      version: json['version'] == null
          ? null
          : DataVersion.fromJson(
              Map<String, dynamic>.from(json['version'] as Map)),
      servants: await (json['servants'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            Servant.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      craftEssences: await (json['craftEssences'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            CraftEssence.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      commandCodes: await (json['commandCodes'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            CommandCode.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      mysticCodes: await (json['mysticCodes'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            MysticCode.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      events: await (json['events'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            Event.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      wars: await (json['wars'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            NiceWar.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      items: await (json['items'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            Item.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      questPhases: await (json['questPhases'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            QuestPhase.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      exchangeTickets: await (json['exchangeTickets'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            ExchangeTicket.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      entities: await (json['entities'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            BasicServant.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      bgms: await (json['bgms'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            BgmEntity.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      extraMasterMission: await (json['extraMasterMission'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            MasterMission.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      fixedDrops: await (json['fixedDrops'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            FixedDrop.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      wiki: json['wiki'] == null
          ? null
          : WikiData.fromJson(Map<String, dynamic>.from(json['wiki'] as Map)),
      mappingData: json['mappingData'] == null
          ? null
          : MappingData.fromJson(
              Map<String, dynamic>.from(json['mappingData'] as Map)),
      constData: json['constData'] == null
          ? null
          : ConstGameData.fromJson(
              Map<String, dynamic>.from(json['constData'] as Map)),
      dropRate: json['dropRate'] == null
          ? null
          : DropRateData.fromJson(
              Map<String, dynamic>.from(json['dropRate'] as Map)),
      baseTds: await (json['baseTds'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            BaseTd.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      baseSkills: await (json['baseSkills'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            BaseSkill.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      baseFunctions: await (json['baseFunctions'] as Map?)?.mapAsync(
        (k, e) async => MapEntry(int.parse(k as String),
            BaseFunction.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    );
  }
}

mixin _GameDataExtra {
  @JsonKey(ignore: true)
  Map<int, Buff> baseBuffs = {};
  @JsonKey(ignore: true)
  late _ProcessedData others;
  @JsonKey(ignore: true)
  Map<int, NiceCostume> costumes = {};
  @JsonKey(ignore: true)
  Map<int, NiceCostume> costumesById = {};
  @JsonKey(ignore: true)
  late Map<int, NiceWar> mainStories;
  @JsonKey(ignore: true)
  late Map<int, NiceSpot> spots;
  @JsonKey(ignore: true)
  late Map<int, WarMap> maps;
  @JsonKey(ignore: true)
  late Map<int, Quest> quests;
  @JsonKey(ignore: true)
  late Map<int, Servant> servantsById;
  @JsonKey(ignore: true)
  late Map<int, CraftEssence> craftEssencesById;
  @JsonKey(ignore: true)
  late Map<int, CommandCode> commandCodesById;
  @JsonKey(ignore: true)
  Map<int, Servant> servantsWithDup = {};
}

extension _AsyncIterMap<K, V> on Map<K, V> {
  Future<Map<K2, V2>> mapAsync<K2, V2>(
      Future<MapEntry<K2, V2>> Function(K key, V value) convert) async {
    return Map.fromEntries([
      for (final entry in entries) await convert(entry.key, entry.value),
    ]);
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

  AppVersion get appVersion =>
      AppVersion.tryParse(minimalApp) ?? const AppVersion(1, 0, 0);

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

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

@JsonSerializable(createToJson: true)
class FileVersion {
  String key;
  String filename;
  int size;
  int timestamp;
  String hash;
  int minSize;
  String minHash;

  FileVersion({
    required this.key,
    required this.filename,
    required this.size,
    required this.timestamp,
    required this.hash,
    required this.minSize,
    required this.minHash,
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
  Set<FuncType> mcFuncs = {};
  Set<BuffType> mcBuffs = {};

  Set<FuncTargetType> funcTargets = {};

  Set<FuncType> get allFuncs =>
      {...svtFuncs, ...ceFuncs, ...ccFuncs, ...mcFuncs};
  Set<BuffType> get allBuffs =>
      {...svtBuffs, ...ceBuffs, ...ccBuffs, ...mcBuffs};

  void _initFuncBuff() {
    for (final svt in gameData.servants.values) {
      for (final skill in [
        ...svt.skills,
        ...svt.noblePhantasms,
        ...svt.classPassive,
        ...svt.appendPassive.map((e) => e.skill)
      ]) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
            funcs: skill.functions, includeTrigger: true, gameData: gameData)) {
          svtFuncs.add(func.funcType);
          svtBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final ce in gameData.craftEssences.values) {
      for (final skill in ce.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
            funcs: skill.functions, includeTrigger: true, gameData: gameData)) {
          ceFuncs.add(func.funcType);
          ceBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final cc in gameData.commandCodes.values) {
      for (final skill in cc.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
            funcs: skill.functions, includeTrigger: true, gameData: gameData)) {
          ccFuncs.add(func.funcType);
          ccBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final mc in gameData.mysticCodes.values) {
      for (final skill in mc.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
            funcs: skill.functions, includeTrigger: true, gameData: gameData)) {
          mcFuncs.add(func.funcType);
          mcBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
  }
}
