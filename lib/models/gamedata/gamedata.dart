// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';

import 'package:archive/archive.dart';

import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import '../db.dart' show ConstData;
import '../userdata/version.dart';
import '_helper.dart';
import 'class_board.dart';
import 'command_code.dart';
import 'common.dart';
import 'const_data.dart';
import 'drop_rate.dart';
import 'enemy_master.dart';
import 'event.dart';
import 'gacha.dart';
import 'game_card.dart';
import 'item.dart';
import 'mappings.dart';
import 'mystic_code.dart';
import 'quest.dart';
import 'raw.dart';
import 'servant.dart';
import 'skill.dart';
import 'war.dart';
import 'wiki_data.dart';

export 'ai.dart';
export 'class_board.dart';
export 'command_code.dart';
export 'common.dart';
export 'const_data.dart';
export 'daily_bonus.dart';
export 'drop_rate.dart';
export 'enemy_master.dart';
export 'event.dart';
export 'game_card.dart';
export 'gift.dart';
export 'item.dart';
export 'mappings.dart';
export 'message.dart';
export 'mystic_code.dart';
export 'quest.dart';
export 'recover.dart';
export 'script.dart';
export 'servant.dart';
export 'skill.dart';
export 'war.dart';
export 'misc.dart';
export 'wiki_data.dart';
export 'reverse.dart';
export 'gacha.dart';

part '../../generated/models/gamedata/gamedata.g.dart';

// part 'helpers/adapters.dart';

@JsonSerializable(converters: [RegionConverter()], createToJson: false)
class GameData with _GameDataExtra {
  static final kMinCompatibleVer = DateTime.utc(2025, 2, 20);
  DataVersion version;
  @protected
  Map<int, Servant> servants;
  Map<int, CraftEssence> craftEssences;
  Map<int, CommandCode> commandCodes;
  Map<int, MysticCode> mysticCodes;
  Map<int, Event> campaigns;
  Map<int, Event> events;
  Map<int, NiceWar> wars;
  Map<int, ClassBoard> classBoards;
  Map<int, GrandGraph> grandGraphs;
  Map<int, Item> items;
  Map<int, QuestPhase> questPhases;
  Map<int, ExchangeTicket> exchangeTickets;
  Map<int, BasicServant> entities;
  Map<int, BgmEntity> bgms;
  Map<int, EnemyMaster> enemyMasters;
  Map<int, MstMasterMission> masterMissions;
  Map<int, MasterMission> extraMasterMission;
  List<QuestGroup> questGroups;
  Map<int, BasicQuestPhaseDetail> questPhaseDetails;
  Map<int, NiceGacha> gachas;
  WikiData wiki;
  MappingData mappingData;
  ConstGameData constData;
  DropData dropData;
  Map<int, BaseSkill> baseSkills;
  Map<int, BaseTd> baseTds;
  Map<int, BaseFunction> baseFunctions;
  GameDataAdd? addData;
  Region? spoilerRegion;
  final Region? removeOldDataRegion;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Servant> servantsById;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, CraftEssence> craftEssencesById;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<CraftEssence> allCraftEssences;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, CommandCode> commandCodesById;

  Map<int, Servant> get servantsNoDup => servants;
  bool get isValid => version.timestamp > 0 && servantsById.isNotEmpty && items.length > 1;

  GameData({
    DataVersion? version,
    // parse shared data types in _GameLoadingTempData first
    Map<int, Item>? items,
    Map<int, BgmEntity>? bgms,
    Map<int, BasicServant>? entities,
    Map<int, BaseFunction>? baseFunctions,
    Map<int, BaseSkill>? baseSkills,
    Map<int, BaseTd>? baseTds,
    //
    List<Servant> servants = const [],
    List<CraftEssence> craftEssences = const [],
    List<CommandCode> commandCodes = const [],
    Map<int, MysticCode>? mysticCodes,
    Map<int, Event>? campaigns,
    Map<int, Event>? events,
    Map<int, NiceWar>? wars,
    Map<int, ClassBoard>? classBoards,
    Map<int, GrandGraph>? grandGraphs,
    Map<int, QuestPhase>? questPhases,
    Map<int, ExchangeTicket>? exchangeTickets,
    Map<int, EnemyMaster>? enemyMasters,
    Map<int, MstMasterMission>? masterMissions,
    Map<int, MasterMission>? extraMasterMission,
    List<QuestGroup>? questGroups,
    List<BasicQuestPhaseDetail>? questPhaseDetails,
    Map<int, NiceGacha>? gachas,
    WikiData? wiki,
    MappingData? mappingData,
    ConstGameData? constData,
    DropData? dropData,
    this.addData,
    this.spoilerRegion,
    this.removeOldDataRegion,
  }) : version = version ?? DataVersion(),
       servantsById = {for (final svt in _sortCards(servants)) svt.id: svt},
       servants = {
         for (final svt in _sortCards(servants))
           if (svt.collectionNo > 0) svt.collectionNo: svt,
       },
       allCraftEssences = _sortCards(craftEssences),
       craftEssencesById = {for (final ce in _sortCards(craftEssences)) ce.id: ce},
       craftEssences = {
         for (final ce in _sortCards(craftEssences))
           if (ce.collectionNo > 0) ce.collectionNo: ce,
       },
       commandCodesById = {for (final cc in _sortCards(commandCodes)) cc.id: cc},
       commandCodes = {
         for (final cc in _sortCards(commandCodes))
           if (cc.collectionNo > 0) cc.collectionNo: cc,
       },
       mysticCodes = mysticCodes ?? {},
       campaigns = campaigns ?? {},
       events = events ?? {},
       wars = wars ?? {},
       classBoards = classBoards ?? {},
       grandGraphs = grandGraphs ?? {},
       items = items ?? {},
       questPhases = questPhases ?? {},
       exchangeTickets = exchangeTickets ?? {},
       entities = entities ?? {},
       bgms = bgms ?? {},
       enemyMasters = enemyMasters ?? {},
       masterMissions = masterMissions ?? {},
       extraMasterMission = extraMasterMission ?? {},
       questGroups = questGroups ?? [],
       questPhaseDetails = {
         for (final phase in questPhaseDetails ?? <BasicQuestPhaseDetail>[]) phase.questId * 100 + phase.phase: phase,
       },
       gachas = gachas ?? {},
       wiki = wiki ?? WikiData(),
       mappingData = mappingData ?? MappingData(),
       constData = constData ?? ConstGameData(),
       dropData = dropData ?? DropData(),
       baseTds = baseTds ?? {},
       baseSkills = baseSkills ?? {},
       baseFunctions = baseFunctions ?? {} {
    if (removeOldDataRegion != null) {
      bool _shouldRemove(int jpTime, MappingBase<int>? regionTimes, int latest, int? inferLatest) {
        final t = removeOldDataRegion == Region.jp ? jpTime : regionTimes?.ofRegion(removeOldDataRegion);
        if (t == null) {
          if (inferLatest != null) return jpTime < inferLatest;
          return false;
        }
        return t < latest;
      }

      final latest = DateTime.now().subtract(const Duration(days: 30)).timestamp;
      final inferLatest = DateTime.now().timestamp - (removeOldDataRegion!.eventDelayMonth + 3) * 30 * 24 * 3600;
      final warIdsToRemove = <int>{};
      this.events.removeWhere((eventId, event) {
        final eventAdd = this.wiki.events[eventId];
        final remove = _shouldRemove(event.startedAt, eventAdd?.startTime, latest, inferLatest);
        if (remove) warIdsToRemove.addAll(event.warIds);
        return remove;
      });
      this.campaigns.removeWhere((eventId, event) {
        return _shouldRemove(event.startedAt, this.wiki.events[eventId]?.startTime, latest, inferLatest);
      });
      this.wars.removeWhere((warId, war) {
        if (war.isMainStory) return false;
        if (war.parentWars.contains(WarId.mainInterlude)) return false;
        return warIdsToRemove.contains(warId);
      });
      this.gachas.removeWhere((gachaId, gacha) {
        return gacha.closedAt < inferLatest;
      });
      this.wiki.summons.removeWhere((_, summon) {
        return _shouldRemove(summon.endTime.jp ?? 0, summon.endTime, latest, inferLatest);
      });
    }
    // merge mc campaigns
    String trim(String s) => s.replaceAll(RegExp(r'[\s\n]'), '');
    Set<String> eventKeys = this.events.values.map((e) => [e.extra.mcLink, trim(e.name)].join('/')).toSet();
    final campaignsToAdd = this.campaigns.values.where(
      (e) => !eventKeys.contains([e.extra.mcLink, trim(e.name)].join('/')),
    );
    this.events.addAll({for (final e in campaignsToAdd) e.id: e});

    // process
    for (final func in this.baseFunctions.values) {
      for (final buff in func.buffs) {
        baseBuffs[buff.id] = buff;
      }
    }

    // remove spoiler
    if (this.version.timestamp > 0 && spoilerRegion != null && spoilerRegion != Region.jp) {
      void _remove(Map<int, GameCardMixin> dict, MappingList<int> releases) {
        final released = releases.ofRegion(spoilerRegion);
        if (released == null || released.isEmpty) return;
        dict.removeWhere((key, v) => !released.contains(v.id));
      }

      _remove(this.servants, this.mappingData.entityRelease);
      _remove(this.craftEssences, this.mappingData.entityRelease);
      _remove(this.commandCodes, this.mappingData.ccRelease);
      _remove(this.entities, this.mappingData.entityRelease);
    }
    this.items.remove(9305420); // 完璧なお正月 is CE
    // other generated maps
    preprocess();
  }

  static List<T> _sortCards<T extends GameCardMixin>(List<T> cards) {
    return cards.toList()..sort2((e) => e.collectionNo);
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
      startedAt: 0,
      endedAt: kNeverClosedTimestamp,
    );
    costumes = {
      for (final svt in servants.values)
        for (final costume in svt.profile.costume.values)
          if (costume.costumeCollectionNo != 0) costume.costumeCollectionNo: costume,
    };
    costumesByCharaId = {
      for (final svt in servants.values)
        for (final costume in svt.profile.costume.values) costume.battleCharaId: costume,
    };
    mainStories = {
      for (final war in wars.values)
        if (war.isMainStory) war.id: war,
    };
    shops = {
      for (final event in events.values)
        for (final shop in event.shop) shop.id: shop,
    };
    spots = {
      for (final war in wars.values)
        for (final spot in war.spots) spot.id: spot,
    };
    maps = {
      for (final war in wars.values)
        for (final map in war.maps) map.id: map,
    };
    quests = {
      for (final spot in spots.values)
        for (final quest in spot.quests) quest.id: quest,
    };
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
    grandGraphDetails = {
      for (final graph in grandGraphs.values)
        for (final detail in graph.details) detail.baseClassId: detail,
    };
    others = _ProcessedData(this);

    // drop data
    for (final quest in quests.values) {
      final questPhase = getQuestPhase(quest.id);
      if (questPhase == null ||
          questPhase.consume <= 0 ||
          !(quest.warId < 1000 && quest.isAnyFree && quest.phases.length == 3)) {
        continue;
      }
      if (dropData.domusAurea.questIds.contains(quest.id)) continue;
      if (questPhase.drops.isEmpty || questPhase.drops.first.runs < 50) continue;
      final runs = questPhase.drops.first.runs;
      Map<int, int> drops = {};
      for (final drop in questPhase.drops) {
        if (drop.type != GiftType.item || drop.objectId == Items.qpId) continue;
        final item = items[drop.objectId];
        if (item == null ||
            !const [ItemCategory.normal, ItemCategory.ascension, ItemCategory.skill].contains(item.category)) {
          continue;
        }
        drops.addNum(drop.objectId, drop.num * drop.dropCount);
      }
      dropData.domusAurea.addQuest(
        questId: quest.id,
        ap: questPhase.consume,
        run: runs,
        bond: questPhase.bond,
        exp: questPhase.exp,
        drops: {for (final (k, v) in drops.items) k: v / runs * 100},
      );
    }
    dropData.domusAurea.initMatrix();
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
    return addData.svts.contains(id) || addData.ccs.contains(id) || addData.ces.contains(id);
  }

  factory GameData.fromJson(Map<String, dynamic> json) => _$GameDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class GameDataAdd {
  // all are id not collectionNo
  List<int> svts;
  List<int> ces;
  List<int> ccs;
  List<int> items;
  List<int> events; // only EventType.eventQuest
  List<int> wars;

  GameDataAdd({
    this.svts = const [],
    this.ces = const [],
    this.ccs = const [],
    this.items = const [],
    this.events = const [],
    this.wars = const [],
  });

  factory GameDataAdd.fromJson(Map<String, dynamic> json) => _$GameDataAddFromJson(json);
}

mixin _GameDataExtra {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Buff> baseBuffs = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  late _ProcessedData others;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, NiceCostume> costumes = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, NiceCostume> costumesByCharaId = {};
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<int, GrandGraphDetail> grandGraphDetails;
}

@JsonSerializable(createToJson: true)
class DataVersion {
  final int timestamp;
  final String utc;
  @protected
  final String minimalApp;
  final Map<String, FileVersion> files;

  DataVersion({this.timestamp = 0, this.utc = "", this.minimalApp = '1.0.0', this.files = const {}});

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
  GameTop cn;

  GameTops({required this.jp, required this.na, required this.cn});

  factory GameTops.fromJson(Map<String, dynamic> json) => _$GameTopsFromJson(json);

  GameTop? of(Region region) {
    switch (region) {
      case Region.jp:
        return jp;
      case Region.na:
        return na;
      case Region.cn:
        return cn;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() => _$GameTopsToJson(this);
}

@JsonSerializable()
class GameAppVerCode {
  String appVer;
  String verCode;

  GameAppVerCode({required this.appVer, this.verCode = ""});

  factory GameAppVerCode.fromJson(Map<String, dynamic> json) => _$GameAppVerCodeFromJson(json);

  Map<String, dynamic> toJson() => _$GameAppVerCodeToJson(this);
}

@JsonSerializable()
class GameTop extends GameAppVerCode {
  @RegionConverter()
  Region region;
  String gameServer;
  // String appVer;
  // String verCode;
  String hash;
  int timestamp;
  String serverHash;
  int serverTimestamp;
  int dataVer; // int32
  int dateVer; // int64
  // String assetbundle;
  String assetbundleFolder;
  String? unityVer;

  GameTop({
    required this.region,
    required this.gameServer,
    required super.appVer,
    super.verCode,
    required this.hash,
    required this.timestamp,
    required this.serverHash,
    required this.serverTimestamp,
    required this.dataVer,
    this.dateVer = 0, // CN has no dateVer
    // required this.assetbundle,
    this.assetbundleFolder = "",
    this.unityVer,
  });

  String get host {
    String _host = gameServer.endsWith('/') ? gameServer.substring(0, gameServer.length - 1) : gameServer;
    if (!_host.toLowerCase().startsWith(RegExp(r'http(s)?://'))) {
      return 'https://$_host';
    }
    return _host;
  }

  int get folderCrc => getCrc32(utf8.encode(assetbundleFolder));

  factory GameTop.fromJson(Map<String, dynamic> json) => _$GameTopFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameTopToJson(this);

  GameTop copy() => GameTop.fromJson(toJson());

  void updateFrom(GameTop other) {
    if (other.region != region) return;
    appVer = other.appVer;
    verCode = other.verCode;
    if (other.dateVer > dateVer) dateVer = other.dateVer;
    if (other.dataVer > dataVer) {
      dataVer = other.dataVer;
      assetbundleFolder = other.assetbundleFolder;
    }
    unityVer = other.unityVer;
  }

  void updateFromRegionInfo(RegionInfo info) {
    final dataVer = info.dataVer, dateVer = info.dateVer, folder = info.assetbundle?.folderName;
    if (dataVer != null && dataVer > this.dataVer) this.dataVer = dataVer;
    if (dateVer != null && dateVer > this.dateVer) this.dateVer = dateVer;
    if (info.timestamp > timestamp && folder != null) {
      assetbundleFolder = folder;
    }
  }
}

@JsonSerializable()
class AssetBundleDecrypt {
  String folderName;
  String animalName;
  String zooName;

  AssetBundleDecrypt({required this.folderName, required this.animalName, required this.zooName});
  factory AssetBundleDecrypt.fromJson(Map<String, dynamic> json) => _$AssetBundleDecryptFromJson(json);

  Map<String, dynamic> toJson() => _$AssetBundleDecryptToJson(this);
}

class _ProcessedData {
  final GameData gameData;

  Map<int, EnemyMasterBattle> enemyMasterBattles = {};
  Map<int, EventMission> eventMissions = {};
  Map<int, Map<int, EventPointGroup>> eventPointGroups = {}; // eventId, groupId
  Map<int, EventPointBuff> eventPointBuffs = {};
  Map<int, EventPointGroup> eventPointBuffGroups = {};
  Map<QuestGroupType, Map<int, List<int>>> questGroups = {}; // <type,<groupId, questIds>>
  Map<int, List<int>> eventQuestGroups = {}; // QuestGroupType.eventQuest: <eventId=groupId, questIds>
  Map<int, List<int>> eventTowerQuestGroups = {}; // QuestGroupType.eventTower: <towerId, questIds>

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

  Map<int, Map<int, int>> spotMultiFrees = {}; // <warId, <spotId, fq count>>
  Map<String, List<NiceGacha>> gachaGroups = {};

  _ProcessedData(this.gameData) {
    for (final svt in gameData.servants.values) {
      for (final costume in svt.profile.costume.values) {
        costumeSvtMap[costume.battleCharaId] = svt;
      }
    }
    enemyMasterBattles = {
      for (final master in gameData.enemyMasters.values)
        for (final battle in master.battles) battle.id: battle,
    };
    eventMissions = {
      for (final mm in gameData.extraMasterMission.values)
        for (final m in mm.missions) m.id: m,
      for (final event in gameData.events.values)
        for (final m in event.missions) m.id: m,
    };
    eventPointGroups = {
      for (final event in gameData.events.values)
        if (event.pointGroups.isNotEmpty)
          event.id: {for (final pointGroup in event.pointGroups) pointGroup.groupId: pointGroup},
    };
    eventPointBuffs = {
      for (final event in gameData.events.values)
        for (final pointBuff in event.pointBuffs) pointBuff.id: pointBuff,
    };
    eventPointBuffGroups = {
      for (final event in gameData.events.values)
        for (final group in event.pointGroups) group.groupId: group,
    };
    for (final quest in gameData.questGroups) {
      final type = quest.type2;
      questGroups.putIfAbsent(type, () => {}).putIfAbsent(quest.groupId, () => []).add(quest.questId);
      if (type == QuestGroupType.eventQuest) {
        eventQuestGroups.putIfAbsent(quest.groupId, () => []).add(quest.questId);
      } else if (type == QuestGroupType.eventTower) {
        eventTowerQuestGroups.putIfAbsent(quest.groupId, () => []).add(quest.questId);
      }
    }
    for (final war in gameData.wars.values) {
      final maps = {for (final map in war.maps) map.id: map};
      final group = spotMultiFrees.putIfAbsent(war.id, () => {});
      for (final spot in war.spots) {
        final map = maps[spot.mapId];
        if ((map != null && map.hasSize) || spot.blankEarth) {
          for (final quest in spot.quests) {
            if (quest.isAnyFree) {
              group.addNum(spot.id, 1);
            }
          }
        }
      }
      group.removeWhere((key, value) => value <= 1);
    }
    spotMultiFrees.removeWhere((key, value) => value.isEmpty);

    gachaGroups = {};
    for (final gacha in gameData.gachas.values) {
      gachaGroups.putIfAbsent(gacha.detailUrlPrefix, () => []).add(gacha);
    }
    for (final group in gachaGroups.values) {
      group.sort2((e) => e.openedAt);
    }
    _initFuncBuff();
  }

  List<int> getQuestsOfGroup(QuestGroupType type, int groupId) {
    return questGroups[type]?[groupId] ?? [];
  }

  EventPointGroup? getEventPointGroup(int? eventId, int groupId) {
    EventPointGroup? group = eventPointGroups[eventId]?[groupId];
    group ??= eventPointGroups.values.lastWhereOrNull((e) => e.containsKey(groupId))?[groupId];
    return group;
  }

  bool shouldUseEventDeck(int questId) {
    for (final (eventId, questIds) in eventQuestGroups.items) {
      if (eventId > 0 && questIds.contains(questId)) {
        return true;
      }
    }
    return false;
  }

  void _initFuncBuff() {
    for (final svt in gameData.servants.values) {
      for (final skill in [
        ...svt.skills,
        ...svt.noblePhantasms,
        ...svt.classPassive,
        ...svt.appendPassive.map((e) => e.skill),
      ]) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
          funcs: skill.functions,
          includeTrigger: true,
          gameData: gameData,
        )) {
          svtFuncs.add(func.funcType);
          svtBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final ce in gameData.craftEssences.values) {
      for (final skill in ce.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
          funcs: skill.functions,
          includeTrigger: true,
          gameData: gameData,
        )) {
          ceFuncs.add(func.funcType);
          ceBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final cc in gameData.commandCodes.values) {
      for (final skill in cc.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
          funcs: skill.functions,
          includeTrigger: true,
          gameData: gameData,
        )) {
          ccFuncs.add(func.funcType);
          ccBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
    for (final mc in gameData.mysticCodes.values) {
      for (final skill in mc.skills) {
        for (final func in NiceFunction.filterFuncs<BaseFunction>(
          funcs: skill.functions,
          includeTrigger: true,
          gameData: gameData,
        )) {
          mcFuncs.add(func.funcType);
          mcBuffs.addAll(func.buffs.map((e) => e.type));
          funcTargets.add(func.funcTargetType);
        }
      }
    }
  }
}

@JsonSerializable(createToJson: false)
class GameTimerData {
  int updatedAt;
  List<Event> events;
  List<NiceGacha> gachas;
  List<MasterMission> masterMissions;
  List<NiceShop> shops;
  List<Item> items;
  GameConstants constants;

  GameTimerData({
    int? updatedAt,
    this.events = const [],
    this.gachas = const [],
    this.masterMissions = const [],
    this.shops = const [],
    this.items = const [],
    GameConstants? constants,
  }) : updatedAt = updatedAt ?? DateTime.now().timestamp,
       constants = constants ?? ConstData.constants;

  List<NiceShop> get shownShops => shops.where((e) => e.payType != PayType.anonymous).toList();

  factory GameTimerData.fromJson(Map<String, dynamic> json) => _$GameTimerDataFromJson(json);
}
