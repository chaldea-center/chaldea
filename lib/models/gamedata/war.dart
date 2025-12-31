import 'package:chaldea/app/app.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import '../db.dart';
import '_helper.dart';
import 'gamedata.dart';

part '../../generated/models/gamedata/war.g.dart';

@JsonSerializable()
class NiceWar with RouteInfo {
  int id;
  List<List<double>> coordinates;
  String age;
  String? _name;
  String? _longName;
  @JsonKey(unknownEnumValue: WarFlag.none)
  List<WarFlag> flags;
  String? banner;
  String? headerImage;
  int priority;
  int parentWarId;
  int materialParentWarId;
  int parentBlankEarthSpotId;
  String emptyMessage;
  Bgm? bgm;
  @protected
  String? scriptId;
  @protected
  String? script;
  WarStartType startType;
  int targetId;
  int _eventId;
  String eventName;
  int lastQuestId;
  List<WarRelease> releaseConditions;
  List<WarAdd> warAdds;
  List<WarGroup> groups;
  List<WarMap> maps;
  List<NiceSpot> spots;
  List<SpotRoad> spotRoads;
  List<WarQuestSelection> questSelections;

  NiceWar({
    required this.id,
    this.coordinates = const [],
    this.age = "",
    String name = "",
    String longName = "",
    this.flags = const [],
    this.banner,
    this.headerImage,
    this.priority = 0,
    this.parentWarId = 0,
    this.materialParentWarId = 0,
    this.parentBlankEarthSpotId = 0,
    this.emptyMessage = "",
    this.bgm,
    this.scriptId,
    this.script,
    this.startType = WarStartType.none,
    this.targetId = 0,
    int eventId = 0,
    this.eventName = "",
    this.lastQuestId = 0,
    this.releaseConditions = const [],
    this.warAdds = const [],
    this.groups = const [],
    this.maps = const [],
    this.spots = const [],
    this.spotRoads = const [],
    this.questSelections = const [],
  }) : _name = _fixName(name, id, eventName),
       _longName = _fixName(longName, id, eventName),
       _eventId = eventId {
    if (banner != null) {
      // fixed when released
      // if (id == 404) {
      //   banner = banner!.replaceAll('/questboard_cap_closed.png', '/questboard_cap405.png');
      // } else if (id == 405) {
      //   banner = banner!.replaceAll(RegExp(r'/questboard.*.png'), '/questboard_cap_closed_406.png');
      // }
    }
  }

  Set<int> get parentWars => {
    parentWarId,
    materialParentWarId,
    for (final warAdd in warAdds)
      if (warAdd.type == WarOverwriteType.parentWar || warAdd.type == WarOverwriteType.materialParentWar)
        warAdd.overwriteId,
  }.where((e) => e != 0).toSet();

  // if default banner is null, find overwriteBanner
  String? get shownBanner {
    if (parentWarId == ConstData.constants.grandBoardWarId) {
      // return "https://news.fate-go.jp/wp-content/uploads/2025/grand_saber_rbhun/top_banner02.png";
      return extra.officialBanner.jp;
    }
    String? banner;
    if (this.banner != null) {
      banner = this.banner;
    } else {
      for (final warAdd in warAdds) {
        if (warAdd.overwriteBanner != null) {
          banner = warAdd.overwriteBanner;
          break;
        }
      }
    }

    if (banner == null) return null;

    if (id == 407 && (banner.endsWith('questboard_cap409.png') || banner.endsWith('questboard_cap_closed_409.png'))) {
      banner = banner.replaceAll(RegExp(r'questboard_.*?409\.png'), 'questboard_cap410.png');
    } else if (banner.endsWith('questboard_cap14000.png')) {
      return banner.replaceFirst('cap14000', 'cap401');
    } else if (banner.endsWith('questboard_cap15000.png')) {
      return banner.replaceFirst('cap15000', 'cap410');
    }

    final event = this.event;
    if (_eventId == 0 || event == null || id == 8348 || id < 1000) {
      return banner;
    }
    if (_warMCBanner.containsKey(id)) {
      return WikiTool.mcFileUrl(_warMCBanner[id]!);
    }
    // Revival SABER WARS ~ Valentine 2020(JP)
    // if (event.startedAt >= 1521104400 && event.startedAt <= 1581498000) {
    //   return banner.replaceFirst('/JP/', '/NA/');
    // }
    return banner;
  }

  List<String> getShownBanners() {
    final warAdds = this.warAdds.toList()..sort2((e) => -e.startedAt);

    final eventAdds = event?.eventAdds ?? [];
    List<String> warBanners = {
      for (final warAdd in warAdds) ?warAdd.overwriteBanner,
      for (final eventAdd in eventAdds) ?eventAdd.overwriteBanner,
    }.toList();
    warBanners = {
      ?shownBanner,
      if (parentWarId != ConstData.constants.grandBoardWarId) ?banner,
      ...warBanners.take(id == WarId.chaldeaGate ? 4 : 6).toList().reversed,
    }.toList();
    warBanners = warBanners.map((url) {
      if (url.endsWith('questboard_cap409.png')) {
        url = url.replaceFirst('questboard_cap409.png', 'questboard_cap_closed_409.png');
      }
      return url;
    }).toList();
    return warBanners;
  }

  int get eventId {
    if (_eventId == 0) return ConstData.extraWarEventMapping[id] ?? _eventId;
    return _eventId;
  }

  ScriptLink? get startScript {
    if (script != null && scriptId != null && scriptId!.isNotEmpty && scriptId != 'NONE' && scriptId != '0') {
      return ScriptLink(scriptId: scriptId!, script: script!);
    }
    return null;
  }

  static String? _fixName(String name, int warId, String eventName) {
    if (['', '-'].contains(name)) return null;
    if (warId != WarId.chaldeaGate &&
        !['', '-'].contains(eventName) &&
        const ['カルデアゲート', '迦勒底之门', '迦勒底之門', 'Chaldea Gate', '칼데아 게이트'].contains(name)) {
      return eventName;
    }
    return name;
  }

  factory NiceWar.fromJson(Map<String, dynamic> json) => _$NiceWarFromJson(json);

  String get name => lName.jp;
  String get longName => lLongName.jp;

  String get lShortName {
    if (id == 305) {
      return '${lName.l} (1)';
    } else if (id == 306) {
      return '${lName.l} (2)';
    } else {
      return lName.l;
    }
  }

  Transl<String, String> get lLongName {
    final warName = (flags.contains(WarFlag.subFolder) ? _name : _longName) ?? _defaultName;
    return Transl.warNames(warName);
  }

  Transl<String, String> get lName {
    String warName = _name ?? _longName ?? _defaultName;
    if (Transl.md.warNames.containsKey(warName)) {
      return Transl.warNames(warName);
    } else {
      return Transl.eventNames(warName);
    }
  }

  String get _defaultName {
    if (eventName.isNotEmpty) return eventName;
    return 'War $id';
  }

  bool get isMainStory => (id >= 100 && id < 1000) || flags.contains(WarFlag.mainScenario);

  bool get isGrandBoardWar => id == WarId.grandBoardWar || parentWarId == WarId.grandBoardWar;

  Event? get event => db.gameData.events[eventId];
  // exclude 1.7/1.5.1-1.5.4/2.7
  Event? get eventReal => isMainStory ? null : db.gameData.events[_eventId];

  NiceWar? get releaseCondWar {
    Quest? firstMainQuest;
    NiceWar? condWar;
    final quests = spots.expand((e) => e.quests);
    if (startType == WarStartType.quest) {
      firstMainQuest = quests.firstWhereOrNull((q) => q.id == targetId);
    }
    if (firstMainQuest == null) {
      final mainQuests = quests.where((e) => e.type == QuestType.main).toList();
      mainQuests.sort2((e) => -e.priority);
      firstMainQuest = mainQuests.getOrNull(0);
    }
    if (firstMainQuest != null) {
      final targetId = firstMainQuest.releaseConditions
          .firstWhereOrNull((cond) => cond.type == CondType.questClear)
          ?.targetId;
      final condQuest = db.gameData.quests[targetId];
      if (targetId == condQuest?.war?.lastQuestId) {
        // usually only main story use the lastQuestId
        condWar = condQuest?.war;
      }
    }
    return condWar;
  }

  @override
  String get route => Routes.warI(id);

  bool isOutdated() => false;

  List<Quest> get quests => [for (final spot in spots) ...spot.quests];

  WarExtra get extra => db.gameData.wiki.wars.putIfAbsent(id, () => WarExtra(id: id));

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemReward = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemDrop = {};

  void calcItems(GameData gameData) {
    itemReward.clear();
    itemDrop.clear();

    for (final spot in spots) {
      for (final quest in spot.quests) {
        // special cases
        // 1 - 復刻:Servant・Summer・Festival！ ライト版
        if (id == 9069 && quest.releaseConditions.any((cond) => cond.type == CondType.notQuestClearPhase)) {
          continue;
        }
        // Interlude in main story
        if (quest.type == QuestType.friendship) {
          continue;
        }
        if (quest.flags.contains(QuestFlag.branch)) {
          continue;
        }
        if (quest.warId < 1000 &&
            quest.type == QuestType.event &&
            quest.closedAt - quest.openedAt < const Duration(days: 365).inSeconds) {
          continue;
        }
        // 1000825: 终局特异点 section 12
        // 3000540: Atlantis section 18
        if ([1000825, 3000540].contains(quest.id)) {
          continue;
        }
        if (gameData.constData.excludeRewardQuests.contains(quest.id)) {
          continue;
        }

        // Grand Board War
        if (parentWarId == WarId.grandBoardWar && quest.consumeItem.firstOrNull?.itemId == Items.stormPodId) {
          continue;
        }

        Gift.checkAddGifts(itemReward, quest.giftsWithPhasePresents);
        if (quest.type != QuestType.warBoard) {
          for (final phase in quest.phases) {
            final fixedDrop = gameData.dropData.fixedDrops[quest.id * 100 + phase];
            if (fixedDrop == null) continue;
            itemDrop.addDict(fixedDrop.items);
          }
        }
        for (final phase in quest.phases) {
          Gift.checkAddGifts(itemReward, gameData.questPhaseDetails[quest.id * 100 + phase]?.gifts ?? []);
        }
      }
    }
    for (final selection in questSelections) {
      final quest = selection.quest;
      if (quest.type == QuestType.friendship) continue;
      Gift.checkAddGifts(itemReward, quest.giftsWithPhasePresents);
      for (final phase in quest.phases) {
        final fixedDrop = gameData.dropData.fixedDrops[quest.id * 100 + phase];
        if (fixedDrop == null) continue;
        itemDrop.addDict(fixedDrop.items);
      }
    }
  }

  Map<String, dynamic> toJson() => _$NiceWarToJson(this);
}

@JsonSerializable()
class WarMap {
  int id;
  String? mapImage;
  int mapImageW;
  int mapImageH;
  List<MapGimmick> mapGimmicks;
  String? headerImage;
  Bgm bgm;

  WarMap({
    required this.id,
    this.mapImage,
    this.mapImageW = 0,
    this.mapImageH = 0,
    this.mapGimmicks = const [],
    this.headerImage,
    required this.bgm,
  });

  bool get hasSize => mapImageW > 0 && mapImageH > 0;

  factory WarMap.fromJson(Map<String, dynamic> json) => _$WarMapFromJson(json);

  Map<String, dynamic> toJson() => _$WarMapToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class MapGimmick {
  int id;
  String? image;
  int x;
  int y;
  int depthOffset;
  int scale;
  CondType dispCondType;
  int dispTargetId;
  int dispTargetValue;
  CondType dispCondType2;
  int dispTargetId2;
  int dispTargetValue2;
  // int actionAnimTime;
  // int actionEffectId;
  int startedAt;
  int endedAt;

  MapGimmick({
    required this.id,
    this.image,
    required this.x,
    required this.y,
    this.depthOffset = 0,
    this.scale = 0,
    this.dispCondType = CondType.none,
    this.dispTargetId = 0,
    this.dispTargetValue = 0,
    this.dispCondType2 = CondType.none,
    this.dispTargetId2 = 0,
    this.dispTargetValue2 = 0,
    this.startedAt = 0,
    this.endedAt = 0,
  });

  factory MapGimmick.fromJson(Map<String, dynamic> json) => _$MapGimmickFromJson(json);

  Map<String, dynamic> toJson() => _$MapGimmickToJson(this);
}

@JsonSerializable()
class NiceSpot {
  int id;
  bool blankEarth;
  List<int> joinSpotIds;
  int mapId;
  String name;
  @protected
  String? image;
  num x;
  num y;
  int imageOfsX;
  int imageOfsY;
  int nameOfsX;
  int nameOfsY;
  int questOfsX;
  int questOfsY;
  int nextOfsX;
  int nextOfsY;
  String closedMessage;
  List<SpotAdd> spotAdds;
  List<Quest> quests;

  NiceSpot({
    required this.id,
    this.blankEarth = false,
    this.joinSpotIds = const [],
    required this.mapId,
    required this.name,
    this.image,
    this.x = 0,
    this.y = 0,
    this.imageOfsX = 0,
    this.imageOfsY = 0,
    this.nameOfsX = 0,
    this.nameOfsY = 0,
    this.questOfsX = 0,
    this.questOfsY = 0,
    this.nextOfsX = 0,
    this.nextOfsY = 0,
    this.closedMessage = "",
    this.spotAdds = const [],
    this.quests = const [],
  });

  factory NiceSpot.fromJson(Map<String, dynamic> json) => _$NiceSpotFromJson(json);

  Transl<String, String> get lName => Transl.spotNames(name);

  WarMap? get map => db.gameData.maps[mapId];

  String? get shownImage {
    final _map = map;
    if (_map != null && _map.mapImageW == 0 && _map.mapImageH == 0) return null;
    return image;
  }

  Map<String, dynamic> toJson() => _$NiceSpotToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class SpotAdd {
  // # spotId: int
  int priority;
  SpotOverwriteType overrideType;
  int targetId;
  String targetText;
  CondType condType;
  int condTargetId;
  int condNum;

  SpotAdd({
    this.priority = 0,
    this.overrideType = SpotOverwriteType.none,
    this.targetId = 0,
    this.targetText = "",
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
  });

  factory SpotAdd.fromJson(Map<String, dynamic> json) => _$SpotAddFromJson(json);

  String? get overwriteSpotName {
    if (overrideType == SpotOverwriteType.name && targetText.isNotEmpty) {
      return targetText;
    }
    return null;
  }

  Map<String, dynamic> toJson() => _$SpotAddToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class SpotRoad {
  int id;
  int warId;
  int mapId;
  String image;
  int srcSpotId;
  int dstSpotId;
  CondType dispCondType;
  int dispTargetId;
  int dispTargetValue;
  CondType dispCondType2;
  int dispTargetId2;
  int dispTargetValue2;
  CondType activeCondType;
  int activeTargetId;
  int activeTargetValue;

  SpotRoad({
    required this.id,
    required this.warId,
    required this.mapId,
    required this.image,
    required this.srcSpotId,
    required this.dstSpotId,
    this.dispCondType = CondType.none,
    this.dispTargetId = 0,
    this.dispTargetValue = 0,
    this.dispCondType2 = CondType.none,
    this.dispTargetId2 = 0,
    this.dispTargetValue2 = 0,
    this.activeCondType = CondType.none,
    this.activeTargetId = 0,
    this.activeTargetValue = 0,
  });

  factory SpotRoad.fromJson(Map<String, dynamic> json) => _$SpotRoadFromJson(json);

  Map<String, dynamic> toJson() => _$SpotRoadToJson(this);
}

@JsonSerializable()
class WarAdd {
  int warId;
  WarOverwriteType type;
  int priority;
  int overwriteId;
  String overwriteStr;
  String? overwriteBanner;
  @CondTypeConverter()
  CondType condType;
  int targetId;
  int value;
  int startedAt;
  int endedAt;

  WarAdd({
    required this.warId,
    this.type = WarOverwriteType.unknown,
    required this.priority,
    required this.overwriteId,
    this.overwriteStr = "",
    this.overwriteBanner,
    this.condType = CondType.none,
    this.targetId = 0,
    this.value = 0,
    required this.startedAt,
    required this.endedAt,
  });

  factory WarAdd.fromJson(Map<String, dynamic> json) => _$WarAddFromJson(json);

  Map<String, dynamic> toJson() => _$WarAddToJson(this);
}

@JsonSerializable()
class WarGroup {
  int id;
  QuestAfterClearType questAfterClear;
  QuestType questType;

  WarGroup({required this.id, this.questAfterClear = QuestAfterClearType.close, this.questType = QuestType.main});

  factory WarGroup.fromJson(Map<String, dynamic> json) => _$WarGroupFromJson(json);

  Map<String, dynamic> toJson() => _$WarGroupToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class WarRelease {
  int priority;
  CondType condType;
  int condId;
  int condNum;
  WarReleaseDisplayType warDisplayType;
  String closedDialogMessage;

  WarRelease({
    this.priority = 0,
    this.condType = CondType.none,
    this.condId = 0,
    this.condNum = 0,
    this.warDisplayType = WarReleaseDisplayType.hide,
    this.closedDialogMessage = "",
  });

  factory WarRelease.fromJson(Map<String, dynamic> json) => _$WarReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$WarReleaseToJson(this);
}

@JsonSerializable()
class WarQuestSelection {
  Quest quest;
  String? shortcutBanner;
  int priority;

  WarQuestSelection({required this.quest, this.shortcutBanner, required this.priority});

  factory WarQuestSelection.fromJson(Map<String, dynamic> json) => _$WarQuestSelectionFromJson(json);

  Map<String, dynamic> toJson() => _$WarQuestSelectionToJson(this);
}

class WarFlagConverter extends JsonConverter<WarFlag, String> {
  const WarFlagConverter();
  @override
  WarFlag fromJson(String value) => decodeEnum(_$WarFlagEnumMap, value, WarFlag.none);
  @override
  String toJson(WarFlag obj) => _$WarFlagEnumMap[obj] ?? obj.name;
}

enum WarFlag {
  none, // added
  withMap,
  showOnMaterial,
  folderSortPrior,
  storyShortcut,
  isEvent,
  closeAfterClear,
  mainScenario,
  isWarIconLeft,
  clearedReturnToTitle,
  noClearMarkWithClear,
  noClearMarkWithComplete,
  notEntryBannerActive,
  shop,
  blackMarkWithClear,
  dispFirstQuest,
  effectDisappearBanner,
  whiteMarkWithClear,
  subFolder,
  dispEarthPointWithoutMap,
  isWarIconFree,
  isWarIconCenter,
  noticeBoard,
  changeDispClosedMessage,
  chapterSubIdJapaneseNumeralsNormal,
  caldeagatePriorityDisplay,
  areaBoardShortcut,
}

enum WarOverwriteType {
  unknown, // custom none
  bgm,
  parentWar,
  banner,
  bgImage,
  svtImage,
  flag,
  baseMapId,
  name,
  longName,
  materialParentWar,
  coordinates,
  effectChangeBlackMark,
  questBoardSectionImage,
  warForceDisp,
  warForceHide,
  startType,
  noticeDialogText,
  clearMark,
  effectChangeWhiteMark,
  commandSpellIcon,
  masterFaceIcon,
  priority,
  recommendSupportHeaderImgId,
}

enum WarStartType { none, script, quest }

enum WarReleaseDisplayType { hide, open, close, announcement }

enum SpotOverwriteType { none, flag, pathPointRatio, pathPointRatioLimit, namePanelOffsetX, namePanelOffsetY, name }

abstract class WarId {
  static const chaldeaGate = 9999;
  static const rankup = 1001;
  static const daily = 1002;
  static const interlude = 1003;
  static const mainInterlude = 1004;
  static const advanced = 1006;
  static const ordealCall = 401;
  static const grandBoardWar = 8395;
}

const Map<int, String> _warMCBanner = {
  // in NA and wiki
  8353: '情人节2020_关卡标题_jp.png',
  8352: '救援！_Amazones.com_关卡标题_jp.png',
  9074: '阎魔亭复刻_关卡标题_jp.png',
  8351: '圣诞节2019_南丁格尔的圣诞颂歌_关卡标题_jp.png',
  9073: 'Saber_Wars_2_关卡标题_jp.png',
  9072: '神秘之国的ONILAND!!复刻_关卡标题_jp.png',
  8350: 'BATTLE_IN_NEWYORK_2019_v2_关卡标题_jp.png', // 'BATTLE_IN_NEWYORK_2019_关卡标题_jp.png'
  9071: '拜见！_拉斯维加斯御前比试_关卡标题_jp.png',
  9069: '从者·夏日·庆典！复刻_关卡标题_jp.png',
  9068: '唠唠叨叨最终本能寺2019_关卡标题_jp.png',
  8347: '迷惑鸣凤庄考察_关卡标题_jp.png',
  9058: '淑女·莱妮丝事件簿_关卡标题_jp.png',
  9057: '唠唠叨叨帝都圣杯奇谭复刻_关卡标题_jp.png',
  9056: '德川回天迷宫_大奥_关卡标题_jp.png',
  8346: '旧时蜘蛛余残怀古共纺丝_关卡标题_jp.png',
  9053: '深海电脑乐土_SE.RA.PH复刻_关卡标题_jp.png',
  8335: '情人节2019_关卡标题_jp.png',
  9052: '魔法少女纪行复刻_关卡标题_jp.png',
  9051: '阎魔亭_关卡标题_jp.png',
  8313: '圣诞节2018_关卡标题_jp.png',
  8308: '圣诞节2017复刻_关卡标题_jp.png',
  9050: '神秘之国的ONILAND!!_关卡标题_jp.png',
  9049: '万圣节2018复刻_关卡标题.png',
  8290: 'BATTLE_IN_NEWYORK_2018_关卡标题_jp.png',
  9048: 'Fate_Accel_Zero_Order复刻_关卡标题.png',
  9046: '从者·夏日·庆典！_关卡标题.png',
  8273: 'https://media.fgo.wiki/4/46/复刻：All_The_States%27Men%21_～从漫画了解合众国开拓史～_关卡标题.png',
  9040: '夏日2018第二部复刻_关卡标题.png',
  9035: '夏日2018第一部复刻_关卡标题.png',
  9033: '唠唠叨叨帝都圣杯奇谭_关卡标题.png',
  8240: '唠唠叨叨明治维新复刻_关卡标题.png',
  8238: '虚月馆杀人事件_关卡标题.png',
  9032: 'Apocrypha_Inheritance_of_Glory_关卡标题.png',
  8230: '星之三藏复刻_关卡标题.png',
  8225: 'Saber_Wars复刻_关卡标题.png',

  // only in wiki
  8349: '迦勒底之门_4周年庆_jp.png',
  9031: '空之境界_the_Garden_of_Order复刻_关卡标题_jp.png',
  8208: '情人节2018_关卡标题_jp.png',
  8200: '鬼乐百重塔_关卡标题_jp.png',
  8196: '赝作复刻_关卡标题.png',
  8188: '圣诞节2018_关卡标题.png',
  8183: '圣诞节2017复刻_关卡标题.png',
  9029: '姬路城大决战_关卡标题.png',
  9022: '超极☆大南瓜村复刻_关卡标题.png',
  8161: '尼禄祭再临2018_关卡标题.png',
  9021: '死亡监狱·夏日大逃脱_关卡标题.png',
  9018: '难解难分·夏日锦标赛！_关卡标题.png',
  8156: '从漫画了解合众国开拓史_关卡标题.png',
  9015: '迦勒底灼热之旅复刻_关卡标题.png',
  9014: '迦勒底夏日回忆复刻_关卡标题.png',
  9013: '鬼岛复刻_关卡标题.png',
  8123: '罗生门复刻_关卡标题.png',
  9010: '深海电脑乐土_SE.RA.PH_关卡标题.png',
  8113: '唠唠叨叨明治维新_关卡标题.png',
  8109: '唠唠叨叨本能寺复刻_关卡标题.png',
  8098: '巧克力小姐的大惊小怪复刻_关卡标题.png',
};

const kLB7SpotLayers = <int, int>{
  31102: 1,
  31103: 1,
  31104: 1,
  31105: 1,
  31106: 2,
  31107: 2,
  31108: 3,
  31109: 3,
  31110: 3,
  31111: 3,
  31112: 4,
  31113: 5,
  31114: 5,
  31115: 3,
  31116: 5,
  31117: 6,
  31118: 7,
  31119: 7,
  31120: 5,
  31121: 3,
  31122: 8,
  31123: 6,
  31124: 8,
  31125: 9,
  31126: 9,
  31127: 9,
  31130: 5,
  31137: 2,
  31138: 3,
  31150: 9,
  31151: 9,
  31152: 9,
  31153: 8,
  31154: 8,
  31155: 8,
  31156: 7,
  31157: 7,
  31158: 6,
  31159: 6,
  31160: 6,
  31161: 3,
  31162: 9,
  31163: 9,
  31164: 9,
  31169: 7,
  31170: 6,
  31171: 6,
  31172: 6,
  31173: 5,
  31174: 5,
  31175: 4,
  31176: 4,
  31177: 4,
  31178: 4,
  31179: 4,
  31180: 3,
  31181: 3,
  31184: 5,
  31185: 3,
};
