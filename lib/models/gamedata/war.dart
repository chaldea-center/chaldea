import 'dart:math';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '_helper.dart';
import 'gamedata.dart';

part '../../generated/models/gamedata/war.g.dart';

const kExtraWarEventMapping = <int, int>{
  108: 80038,
  201: 80044,
  202: 80059,
  203: 80072,
  204: 80077,
};

@JsonSerializable()
class NiceWar with RouteInfo {
  int id;
  List<List<double>> coordinates;
  String age;
  String? _name;
  String? _longName;
  @WarFlagConverter()
  List<WarFlag> flags;
  String? banner;
  String? headerImage;
  int priority;
  int parentWarId;
  int materialParentWarId;
  String emptyMessage;
  Bgm bgm;
  @protected
  String? scriptId;
  @protected
  String? script;
  WarStartType startType;
  int targetId;
  int _eventId;
  String eventName;
  int lastQuestId;
  List<WarAdd> warAdds;
  List<WarMap> maps;
  List<NiceSpot> spots;
  List<SpotRoad> spotRoads;
  List<WarQuestSelection> questSelections;

  // if default banner is null, find overwriteBanner
  String? get shownBanner {
    if (banner != null) return banner;
    for (final warAdd in warAdds) {
      if (warAdd.overwriteBanner != null) return warAdd.overwriteBanner;
    }
    return null;
  }

  int get eventId {
    if (_eventId == 0) return kExtraWarEventMapping[id] ?? _eventId;
    return _eventId;
  }

  ScriptLink? get startScript {
    if (script != null &&
        scriptId != null &&
        scriptId!.isNotEmpty &&
        scriptId != 'NONE') {
      return ScriptLink(scriptId: scriptId!, script: script!);
    }
    return null;
  }

  NiceWar({
    required this.id,
    required this.coordinates,
    required this.age,
    required String name,
    required String longName,
    this.flags = const [],
    this.banner,
    this.headerImage,
    required this.priority,
    this.parentWarId = 0,
    this.materialParentWarId = 0,
    this.emptyMessage = "",
    required this.bgm,
    this.scriptId,
    this.script,
    required this.startType,
    required this.targetId,
    int eventId = 0,
    this.eventName = "",
    required this.lastQuestId,
    this.warAdds = const [],
    this.maps = const [],
    this.spots = const [],
    this.spotRoads = const [],
    this.questSelections = const [],
  })  : _name = ['', '-'].contains(name) ? null : name,
        _longName = ['', '-'].contains(longName) ? null : longName,
        _eventId = eventId;

  factory NiceWar.fromJson(Map<String, dynamic> json) =>
      _$NiceWarFromJson(json);

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
    final warName =
        (flags.contains(WarFlag.subFolder) ? _name : _longName) ?? _defaultName;
    return Transl.warNames(warName);
  }

  Transl<String, String> get lName {
    final warName = _name ?? _longName ?? _defaultName;
    return Transl.warNames(warName);
  }

  String get _defaultName {
    if (id == 312) return '奏章 プロローグ';
    return 'War $id';
  }

  bool get isMainStory => id >= 100 && id < 1000;

  Event? get event => db.gameData.events[eventId];

  @override
  String get route => Routes.warI(id);

  bool isOutdated() => false;

  List<Quest> get quests => [for (final spot in spots) ...spot.quests];

  WarExtra get extra =>
      db.gameData.wiki.wars.putIfAbsent(id, () => WarExtra(id: id));

  @JsonKey(ignore: true)
  Map<int, int> itemReward = {};
  @JsonKey(ignore: true)
  Map<int, int> itemDrop = {};

  void calcItems(GameData gameData) {
    itemReward.clear();
    itemDrop.clear();

    for (final spot in spots) {
      for (final quest in spot.quests) {
        // special cases
        // 1 - 復刻:Servant・Summer・Festival！ ライト版
        if (id == 9069 &&
            quest.releaseConditions
                .any((cond) => cond.type == CondType.notQuestClearPhase)) {
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
            quest.closedAt - quest.openedAt <
                const Duration(days: 365).inSeconds) {
          continue;
        }
        // 1000825: 终局特异点 section 12
        // 3000540: Atlantis section 18
        if ([1000825, 3000540].contains(quest.id)) {
          continue;
        }

        Gift.checkAddGifts(itemReward, quest.gifts);
        for (final phase in quest.phases) {
          final fixedDrop = gameData.fixedDrops[quest.id * 100 + phase];
          if (fixedDrop == null) continue;
          itemDrop.addDict(fixedDrop.items);
        }
        int arrows = _countArrows(quest);
        itemReward.addNum(Items.quartzFragmentId, arrows);
        itemReward.addNum(Items.blueSaplingId, arrows);
      }
    }
    for (final selection in questSelections) {
      final quest = selection.quest;
      if (quest.type == QuestType.friendship) continue;
      Gift.checkAddGifts(itemReward, quest.gifts);
      for (final phase in quest.phases) {
        final fixedDrop = gameData.fixedDrops[quest.id * 100 + phase];
        if (fixedDrop == null) continue;
        itemDrop.addDict(fixedDrop.items);
      }
    }
  }

  int _countArrows(Quest quest) {
    if (!isMainStory || quest.type != QuestType.main) {
      return 0;
    }
    if (quest.flags.contains(QuestFlag.branch)) {
      return 0;
    }
    if (quest.id == targetId && startType == WarStartType.quest) {
      if (flags.contains(WarFlag.dispFirstQuest)) {
        return max(0, quest.phases.length - 1);
      } else {
        return 0;
      }
    }
    // the first training quest for starter
    if (quest.id == 1000000) return 0;
    if ([
      1000825, // 终局特异点 dup chapter 12
      2000217, // 1.5.2
      2000317, // 1.5.3
      3000500,
      3000501,
      3000502,
      3000503, // LB 2.5.1 intro.
    ].contains(quest.id)) {
      return 0;
    }
    return quest.phases.length;
  }
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
    required this.mapImageW,
    required this.mapImageH,
    this.mapGimmicks = const [],
    this.headerImage,
    required this.bgm,
  });

  factory WarMap.fromJson(Map<String, dynamic> json) => _$WarMapFromJson(json);
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
  // int startedAt;
  // int endedAt;

  MapGimmick({
    required this.id,
    this.image,
    required this.x,
    required this.y,
    required this.depthOffset,
    required this.scale,
    required this.dispCondType,
    required this.dispTargetId,
    required this.dispTargetValue,
    required this.dispCondType2,
    required this.dispTargetId2,
    required this.dispTargetValue2,
  });

  factory MapGimmick.fromJson(Map<String, dynamic> json) =>
      _$MapGimmickFromJson(json);
}

@JsonSerializable()
class NiceSpot {
  int id;
  List<int> joinSpotIds;
  int mapId;
  String name;
  @protected
  String? image;
  int x;
  int y;
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
    this.joinSpotIds = const [],
    required this.mapId,
    required this.name,
    this.image,
    required this.x,
    required this.y,
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

  factory NiceSpot.fromJson(Map<String, dynamic> json) =>
      _$NiceSpotFromJson(json);

  WarMap? get map => db.gameData.maps[mapId];

  String? get shownImage {
    final _map = map;
    if (_map != null && _map.mapImageW == 0 && _map.mapImageH == 0) return null;
    return image;
  }
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
    required this.condTargetId,
    this.condNum = 0,
  });

  factory SpotAdd.fromJson(Map<String, dynamic> json) =>
      _$SpotAddFromJson(json);

  String? get overwriteSpotName {
    if (overrideType == SpotOverwriteType.name && targetText.isNotEmpty) {
      return targetText;
    }
    return null;
  }
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
    required this.dispCondType,
    required this.dispTargetId,
    required this.dispTargetValue,
    required this.dispCondType2,
    required this.dispTargetId2,
    required this.dispTargetValue2,
    required this.activeCondType,
    required this.activeTargetId,
    required this.activeTargetValue,
  });

  factory SpotRoad.fromJson(Map<String, dynamic> json) =>
      _$SpotRoadFromJson(json);
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
    required this.condType,
    required this.targetId,
    required this.value,
    required this.startedAt,
    required this.endedAt,
  });

  factory WarAdd.fromJson(Map<String, dynamic> json) => _$WarAddFromJson(json);
}

@JsonSerializable()
class WarQuestSelection {
  Quest quest;
  String? shortcutBanner;
  int priority;

  WarQuestSelection({
    required this.quest,
    this.shortcutBanner,
    required this.priority,
  });

  factory WarQuestSelection.fromJson(Map<String, dynamic> json) =>
      _$WarQuestSelectionFromJson(json);
}

class WarFlagConverter extends JsonConverter<WarFlag, String> {
  const WarFlagConverter();
  @override
  WarFlag fromJson(String value) =>
      decodeEnum(_$WarFlagEnumMap, value, WarFlag.none);
  @override
  String toJson(WarFlag obj) => _$WarFlagEnumMap[obj] ?? obj.name;
}

@JsonEnum(alwaysCreate: true)
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
}

enum WarStartType {
  none,
  script,
  quest,
}

enum SpotOverwriteType {
  none,
  flag,
  pathPointRatio,
  pathPointRatioLimit,
  namePanelOffsetX,
  namePanelOffsetY,
  name,
}
