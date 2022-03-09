import 'package:chaldea/app/app.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

import '../db.dart';
import 'gamedata.dart';

part '../../generated/models/gamedata/war.g.dart';

@JsonSerializable()
class NiceWar {
  int id;
  List<List<double>> coordinates;
  String age;
  String name;
  String longName;
  String? banner;
  String? headerImage;
  int priority;
  int parentWarId;
  int materialParentWarId;
  String emptyMessage;
  Bgm bgm;
  String scriptId;
  String script;
  WarStartType startType;
  int targetId;
  int eventId;
  String eventName;
  int lastQuestId;
  List<WarAdd> warAdds;
  List<NiceMap> maps;
  List<NiceSpot> spots;
  List<SpotRoad> spotRoads;

  NiceWar({
    required this.id,
    required this.coordinates,
    required this.age,
    required this.name,
    required this.longName,
    this.banner,
    this.headerImage,
    required this.priority,
    this.parentWarId = 0,
    this.materialParentWarId = 0,
    this.emptyMessage = "クエストがありません",
    required this.bgm,
    required this.scriptId,
    required this.script,
    required this.startType,
    required this.targetId,
    this.eventId = 0,
    this.eventName = "",
    required this.lastQuestId,
    this.warAdds = const [],
    this.maps = const [],
    this.spots = const [],
    this.spotRoads = const [],
  });

  factory NiceWar.fromJson(Map<String, dynamic> json) =>
      _$NiceWarFromJson(json);

  bool get isMainStory => id >= 100 && id < 1000;

  Transl<String, String> get lLongName => Transl.warNames(longName);

  String get route => Routes.warI(id);

  bool isOutdated() => false;

  List<Quest> get quests => [for (final spot in spots) ...spot.quests];

  WarExtra get extra =>
      db2.gameData.wikiData.wars.putIfAbsent(id, () => WarExtra(id: id));

  @JsonKey(ignore: true)
  Map<int, int> itemReward = {};
  @JsonKey(ignore: true)
  Map<int, int> itemDrop = {};

  void calcItems(GameData gameData) {
    itemReward.clear();
    itemDrop.clear();
    for (final spot in spots) {
      for (final quest in spot.quests) {
        for (final gift in quest.gifts) {
          if (gift.isStatItem) itemReward.addNum(gift.objectId, gift.num);
        }
        for (final phase in quest.phases) {
          final fixedDrop = gameData.fixedDrops[quest.id * 100 + phase];
          if (fixedDrop == null) continue;
          itemDrop.addDict(fixedDrop.items);
        }
      }
    }
  }
}

@JsonSerializable()
class NiceMap {
  int id;
  String? mapImage;
  int mapImageW;
  int mapImageH;
  String? headerImage;
  Bgm bgm;

  NiceMap({
    required this.id,
    this.mapImage,
    required this.mapImageW,
    required this.mapImageH,
    this.headerImage,
    required this.bgm,
  });

  factory NiceMap.fromJson(Map<String, dynamic> json) =>
      _$NiceMapFromJson(json);
}

@JsonSerializable()
class NiceSpot {
  int id;
  List<int> joinSpotIds;
  int mapId;
  String name;
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
    this.quests = const [],
  });

  factory NiceSpot.fromJson(Map<String, dynamic> json) =>
      _$NiceSpotFromJson(json);
}

@JsonSerializable()
class SpotRoad {
  int id;
  int warId;
  int mapId;
  String? image;
  int srcSpotId;
  int dstSpotId;
  @JsonKey(fromJson: toEnumCondType)
  CondType dispCondType;
  int dispTargetId;
  int dispTargetValue;
  @JsonKey(fromJson: toEnumCondType)
  CondType dispCondType2;
  int dispTargetId2;
  int dispTargetValue2;
  @JsonKey(fromJson: toEnumCondType)
  CondType activeCondType;
  int activeTargetId;
  int activeTargetValue;

  SpotRoad({
    required this.id,
    required this.warId,
    required this.mapId,
    this.image,
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
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  int targetId;
  int value;
  int startedAt;
  int endedAt;

  WarAdd({
    required this.warId,
    required this.type,
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

enum WarOverwriteType {
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
}
enum WarStartType {
  none,
  script,
  quest,
}
