// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

import 'package:crclib/catalog.dart';

import 'package:chaldea/utils/extension.dart';
import '../../utils/basic.dart';
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
export 'enemy_master.dart';
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

@JsonSerializable(converters: [RegionConverter()], createToJson: false)
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
  WikiData wiki;
  MappingData mappingData;
  ConstGameData constData;
  DropData dropData;
  Map<int, BaseSkill> baseSkills;
  Map<int, BaseTd> baseTds;
  Map<int, BaseFunction> baseFunctions;
  _GameDataAdd? addData;
  Region? spoilerRegion;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Servant> servantsById;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, CraftEssence> craftEssencesById;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, CommandCode> commandCodesById;

  Map<int, Servant> get servantsNoDup => servants;
  bool get isValid => version.timestamp > 0 && servantsById.isNotEmpty && items.length > 1;

  GameData({
    DataVersion? version,
    List<Servant> servants = const [],
    List<CraftEssence> craftEssences = const [],
    List<CommandCode> commandCodes = const [],
    Map<int, MysticCode>? mysticCodes,
    Map<int, Event>? events,
    Map<int, NiceWar>? wars,
    Map<int, Item>? items,
    Map<int, QuestPhase>? questPhases,
    Map<int, ExchangeTicket>? exchangeTickets,
    Map<int, BasicServant>? entities,
    Map<int, BgmEntity>? bgms,
    Map<int, MasterMission>? extraMasterMission,
    WikiData? wiki,
    MappingData? mappingData,
    ConstGameData? constData,
    DropData? dropData,
    Map<int, BaseTd>? baseTds,
    Map<int, BaseSkill>? baseSkills,
    Map<int, BaseFunction>? baseFunctions,
    this.addData,
    this.spoilerRegion,
  })  : version = version ?? DataVersion(),
        servants = {
          for (final svt in servants)
            if (svt.collectionNo > 0) svt.collectionNo: svt
        },
        servantsById = {for (final svt in servants) svt.id: svt},
        craftEssences = {
          for (final ce in craftEssences)
            if (ce.collectionNo > 0) ce.collectionNo: ce
        },
        craftEssencesById = {for (final ce in craftEssences) ce.id: ce},
        commandCodes = {
          for (final cc in commandCodes)
            if (cc.collectionNo > 0) cc.collectionNo: cc
        },
        commandCodesById = {for (final cc in commandCodes) cc.id: cc},
        mysticCodes = mysticCodes ?? {},
        events = events ?? {},
        wars = wars ?? {},
        items = items ?? {},
        questPhases = questPhases ?? {},
        exchangeTickets = exchangeTickets ?? {},
        entities = entities ?? {},
        bgms = bgms ?? {},
        extraMasterMission = extraMasterMission ?? {},
        wiki = wiki ?? WikiData(),
        mappingData = mappingData ?? MappingData(),
        constData = constData ?? ConstGameData(),
        dropData = dropData ?? DropData(),
        baseTds = baseTds ?? {},
        baseSkills = baseSkills ?? {},
        baseFunctions = baseFunctions ?? {} {
    // process
    for (final func in this.baseFunctions.values) {
      for (final buff in func.buffs) {
        baseBuffs[buff.id] = buff;
      }
    }
    if (addData != null) {
      for (final svt in addData!.svt.values) {
        if (svt.collectionNo > 0) this.servants[svt.collectionNo] ??= svt;
      }
      for (final ce in addData!.ce.values) {
        if (ce.collectionNo > 0) this.craftEssences[ce.collectionNo] ??= ce;
      }
      for (final cc in addData!.cc.values) {
        if (cc.collectionNo > 0) this.commandCodes[cc.collectionNo] ??= cc;
      }
    }
    // remove spoiler
    if (this.version.timestamp > 0 && spoilerRegion != null && spoilerRegion != Region.jp) {
      void _remove<T>(Map<int, T> dict, MappingList<int> releases) {
        final released = releases.ofRegion(spoilerRegion);
        if (released == null || released.isEmpty) return;
        dict.removeWhere((key, _) => !released.contains(key));
      }

      _remove(this.servants, this.mappingData.svtRelease);
      _remove(this.craftEssences, this.mappingData.ceRelease);
      _remove(this.commandCodes, this.mappingData.ccRelease);
      _remove(this.entities, this.mappingData.entityRelease);
    }
    this.items.remove(9305420); // 完璧なお正月 is CE
    // other generated maps
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
        for (final costume in svt.profile.costume.values) costume.costumeCollectionNo: costume
    };
    costumesById = {for (final costume in costumes.values) costume.battleCharaId: costume};
    mainStories = {
      for (final war in wars.values)
        if (war.isMainStory) war.id: war
    };
    shops = {
      for (final event in events.values)
        for (final shop in event.shop) shop.id: shop
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
    craftEssencesById = craftEssences.map((key, value) => MapEntry(value.id, value));
    commandCodesById = commandCodes.map((key, value) => MapEntry(value.id, value));
    // calculation at last
    for (final war in wars.values) {
      war.calcItems(this);
    }
    for (final event in events.values) {
      event.calcItems(this);
    }
    for (final svt in servants.values) {
      svt.extraAssets.charaFigure.story?.keys.forEach((charaId) {
        storyCharaFigures[charaId ~/ 10] = svt.id;
      });
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

  // for new added card, bordered icon has not been generated
  bool isJustAddedCard(int id) {
    // return true;
    final addData = this.addData;
    if (addData == null || DateTime.now().timestamp - version.timestamp > 1800) {
      return false;
    }
    final svt = addData.svt[id];
    if (svt != null && Maths.max(servants.keys, 0) - svt.collectionNo < 5) {
      return true;
    }
    return (addData.ce[id] ?? addData.cc[id]) != null;
  }

  factory GameData.fromJson(Map<String, dynamic> json) => _$GameDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class _GameDataAdd {
  Map<int, Servant> svt;
  Map<int, CraftEssence> ce;
  Map<int, CommandCode> cc;

  _GameDataAdd({
    List<Servant> svt = const [],
    List<CraftEssence> ce = const [],
    List<CommandCode> cc = const [],
  })  : svt = {for (var x in svt) x.id: x},
        ce = {for (var x in ce) x.id: x},
        cc = {for (var x in cc) x.id: x};

  factory _GameDataAdd.fromJson(Map<String, dynamic> json) => _$GameDataAddFromJson(json);
}

mixin _GameDataExtra {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Buff> baseBuffs = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  late _ProcessedData others;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, NiceCostume> costumes = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, NiceCostume> costumesById = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, NiceWar> mainStories;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, NiceShop> shops;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, NiceSpot> spots;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, WarMap> maps;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, Quest> quests;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Servant> servantsWithDup = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> storyCharaFigures = {};
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

  AppVersion get appVersion => AppVersion.tryParse(minimalApp) ?? const AppVersion(1, 0, 0);

  factory DataVersion.fromJson(Map<String, dynamic> json) => _$DataVersionFromJson(json);

  Map<String, dynamic> toJson() => _$DataVersionToJson(this);

  String text([bool twoLine = true]) {
    if (timestamp <= 0) return '0';
    String s = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toStringShort(omitSec: true);
    if (twoLine) return s.replaceFirst(' ', '\n');
    return s;
  }

  @override
  String toString() {
    return '$runtimeType($utc, ${files.length} files)';
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
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

  factory FileVersion.fromJson(Map<String, dynamic> json) => _$FileVersionFromJson(json);

  Map<String, dynamic> toJson() => _$FileVersionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.screamingSnake)
class GameTops {
  GameTop jp;
  GameTop na;

  GameTops({
    required this.jp,
    required this.na,
  });

  factory GameTops.fromJson(Map<String, dynamic> json) => _$GameTopsFromJson(json);

  GameTop? of(Region region) {
    switch (region) {
      case Region.jp:
        return jp;
      case Region.na:
        return na;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => _$GameTopsToJson(this);
}

@JsonSerializable()
class GameTop {
  @RegionConverter()
  Region region;
  String gameServer;
  String appVer;
  String verCode;
  int dataVer;
  int dateVer;
  // String assetbundle;
  String assetbundleFolder;

  GameTop({
    required this.region,
    required this.gameServer,
    required this.appVer,
    required this.verCode,
    required this.dataVer,
    required this.dateVer,
    // required this.assetbundle,
    required this.assetbundleFolder,
  });

  String get host {
    String _host = gameServer.endsWith('/') ? gameServer.substring(0, gameServer.length - 1) : gameServer;
    if (!_host.toLowerCase().startsWith(RegExp(r'http(s)?://'))) {
      return 'https://$_host';
    }
    return _host;
  }

  int get folderCrc => Crc32().convert(utf8.encode(assetbundleFolder)).toBigInt().toInt();

  factory GameTop.fromJson(Map<String, dynamic> json) => _$GameTopFromJson(json);

  Map<String, dynamic> toJson() => _$GameTopToJson(this);
}

@JsonSerializable()
class AssetBundleDecrypt {
  String folderName;
  String animalName;
  String zooName;

  AssetBundleDecrypt({
    required this.folderName,
    required this.animalName,
    required this.zooName,
  });
  factory AssetBundleDecrypt.fromJson(Map<String, dynamic> json) => _$AssetBundleDecryptFromJson(json);

  Map<String, dynamic> toJson() => _$AssetBundleDecryptToJson(this);
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

  Set<FuncType> get allFuncs => {...svtFuncs, ...ceFuncs, ...ccFuncs, ...mcFuncs};
  Set<BuffType> get allBuffs => {...svtBuffs, ...ceBuffs, ...ccBuffs, ...mcBuffs};

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
